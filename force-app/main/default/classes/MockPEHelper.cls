/**
* Mock for Platform Event type trigger helpers
**/
@IsTest
public class MockPEHelper extends AbstractBasePETriggerHelper {
        public String getName() {
            return MockPEHelper.class.getName();
        }
        public Boolean bFinalizeAfterInsert=false;
        public Integer cPreviewAfterInsert=0;
        public Integer cMeetsAfterInsert=0;
        public Integer cProcessAfterInsert=0;
        /**
         * Overrideable Virtual methods to support AFTER INSERT phase for PE
        **/ 
        public override virtual void previewAfterInsert(final SObject current) {
            super.previewAfterInsert(current);
            cPreviewAfterInsert++;
        }  
        public override virtual Boolean meetsEntryCriteriaAfterInsert(final SObject current) {
            super.meetsEntryCriteriaAfterInsert(current);
            cMeetsAfterInsert++;
            return true; 
        } 
        public override virtual void processRecordAfterInsert(final SObject current)  {
            super.processRecordAfterInsert(current);
            cProcessAfterInsert++;        
        }
        public override virtual void finalizeAfterInsert() {
            super.finalizeAfterInsert();
            bFinalizeAfterInsert=true;
        }
}