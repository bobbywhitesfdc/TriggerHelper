/**
 * This Test class Mocks the DBExecutor class 
 *  Performs dark magic by faking out System Classes that cannot be directly instantiated.
 *  Simulates DML failures so that error handling capabilities can be properly tested.
 **/ 
@IsTest(isParallel=true)
public class MockDMLExecutor extends DMLExecutor  {
    /**
     * Mocked Insert that return errors on Even rows
     **/ 
    public override List<Database.SaveResult> insertData(List<SObject> records, Boolean dmlAllOrNone) {
        final List<Database.SaveResult> result = new List<Database.SaveResult>();
        for(Integer i=0; i < records.size(); i++) {
            Boolean success = (Math.mod(i,2)==1); //Evens fail, Odds succeed
            String errMessage='Mock Error message';
            String statusCode='REQUIRED_FIELD_MISSING'; // hardcode this
            final String drJson= createDBSRJson(records[i],success,statusCode,errMessage);
            Database.SaveResult dr = (Database.SaveResult) JSON.deserialize(drJson,Database.SaveResult.class);
            System.AssertEquals(success,dr.isSuccess(),'Mock Database.SaveResult success indicator incorrect');
            result.add(dr);
        }
        return result;
    }
    
    /**
     * Mocked Update that return errors on Even rows
     **/ 
    public override List<Database.SaveResult> updateData(List<SObject> records, Boolean dmlAllOrNone) {
        final List<Database.SaveResult> result = new List<Database.SaveResult>();
        for(Integer i=0; i < records.size(); i++) {
            Boolean success = (Math.mod(i,2)==1); //Evens fail, Odds succeed
            String errMessage='Mock Error message';
            String statusCode='REQUIRED_FIELD_MISSING'; // hardcode this
            final String drJson= createDBSRJson(records[i],success,statusCode,errMessage);
            Database.SaveResult dr = (Database.SaveResult) JSON.deserialize(drJson,Database.SaveResult.class);
            System.AssertEquals(success,dr.isSuccess(),'Mock Database.SaveResult success indicator incorrect');
            result.add(dr);
        }
        return result;
    }
    
    /**
     * Mocked Upsert that return errors on Even rows
     **/    
    public override List<Database.UpsertResult> upsertData(List<SObject> records, Schema.SObjectField externalIdField, Boolean dmlAllOrNone) {
        final List<Database.UpsertResult> result = new List<Database.UpsertResult>();
        for(Integer i=0; i < records.size(); i++) {
            Boolean success = (Math.mod(i,2)==1); //Evens fail, Odds succeed
            String errMessage='Mock Error message';
            String statusCode='REQUIRED_FIELD_MISSING'; // hardcode this
            final String drJson= createDBSRJson(records[i],success,statusCode,errMessage);
            Database.UpsertResult dr = (Database.UpsertResult) JSON.deserialize(drJson,Database.UpsertResult.class);
            System.AssertEquals(success,dr.isSuccess(),'Mock Database.UpsertResult success indicator incorrect');
            result.add(dr);
        }
        return result;
    }

    
    /**
     * Mocked delete that return errors on Even rows
     **/ 
    public override List<Database.DeleteResult> deleteData(List<SObject> records, Boolean dmlAllOrNone) {
        final List<Database.DeleteResult> result = new List<Database.DeleteResult>();
        for(Integer i=0; i < records.size(); i++) {
            Boolean success = (Math.mod(i,2)==1); //Evens fail, Odds succeed
            String errMessage='Mock Error message';
            String statusCode='REQUIRED_FIELD_MISSING'; // hardcode this
            final String drJson= createDBSRJson(records[i],success,statusCode,errMessage);
            Database.DeleteResult dr = (Database.DeleteResult) JSON.deserialize(drJson,Database.DeleteResult.class);
            System.AssertEquals(success,dr.isSuccess(),'Mock Database.DeleteResult success indicator incorrect');
            result.add(dr);
        }
        return result;
    }
    /**
     * Mocked undelete that return errors on Even rows
     **/     
    public override List<Database.UndeleteResult> undeleteData(List<SObject> records, Boolean dmlAllOrNone) {
        final List<Database.UndeleteResult> result = new List<Database.UndeleteResult>();
        for(Integer i=0; i < records.size(); i++) {
            Boolean success = (Math.mod(i,2)==1); //Evens fail, Odds succeed
            System.Debug('Undelete i='+i + ' success=' + success);
            String errMessage='Mock Error message';
            String statusCode='FIELD_CUSTOM_VALIDATION_EXCEPTION';
            final String drJson= createDBSRJson(records[i],success,statusCode,errMessage);
            Database.UndeleteResult dr = (Database.UndeleteResult) JSON.deserialize(drJson,Database.UndeleteResult.class);
            System.AssertEquals(success,dr.isSuccess(),'Mock Database.UndeleteResult success indicator incorrect');
            result.add(dr);
        }
        return result;
    }

    /**
     * Mocked Publish that return errors on Odd rows
     **/ 
    public override List<Database.SaveResult> publish(List<SObject> records) {
        final List<Database.SaveResult> result = new List<Database.SaveResult>();
        for(Integer i=0; i < records.size(); i++) {
            Boolean success = (Math.mod(i,2)==1); //Evens fail, Odds succeed
            String errMessage='Mock Error message';
            String statusCode='REQUIRED_FIELD_MISSING'; // hardcode this
            final String drJson= createDBSRJson(records[i],success,statusCode,errMessage);
            Database.SaveResult dr = (Database.SaveResult) JSON.deserialize(drJson,Database.SaveResult.class);
            System.AssertEquals(success,dr.isSuccess(),'Mock Database.SaveResult success indicator incorrect');
            result.add(dr);
        }
        return result;
    }
    
    /**
     * Cannot directly create any of the Database.xxxResult objects, so hacking this with JSon deserialization
     **/ 
    public static String createDBSRJson(final SObject sourceRecord,Boolean success, String statusCode, String errorMsg) {
        //{"id":"00QDF00000FFf6V2AT","success":false,"errors":[{"statusCode":"REQUIRED_FIELD_MISSING","message":"Required fields are missing: [LastName]","fields":["LastName"]}]}
        //{"id":"a1IDF00000XEwwc2AD","success":true}
        //{"id":"a1IDF00000XEwwS2AT","success":false,"errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"Prevent Undelete validation","fields":[]}]}
        //{"success":false,"errors":[{"statusCode":"INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY","message":"insufficient access rights on cross-reference id: 0LQDF000000wkyh","fields":[]}]}
    JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        if (sourceRecord.Id!=null) gen.writeIdField('id',sourceRecord.id);
        gen.writeBooleanField('success',success);
        
        // write the Errors
        List<MockError> errors = new List<MockError>();
        if (!success) {
            errors.add(new MockError(statusCode,errorMsg));
            gen.writeObjectField('errors',errors); 
        } 
        
        gen.writeEndObject();
        
        // Get the JSON string.
        String pretty = gen.getAsString();
        System.debug(pretty);
        return pretty;        
    }
    public class MockError {
        public MockError(String sc, String msg) {
           statusCode=sc;
           message=msg;
           fields=new List<String>();
        }
        public String statusCode;
        public String message;
        public List<String> fields;
    }
    
}