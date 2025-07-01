/*
* Log Application Errors asynchronously using Nebula logger package.
*/
public class LoggingUtility {
    
    /**
     * Logs an error message and saves the log based on the provided saveFlag.
     *
     * @param msg      The error message to log.
     * @param saveFlag Determines whether to save the log or not.
     */
    public static void logError(String msg, Boolean saveFlag) {
        Logger.error(msg);
        if (saveFlag) {
            Logger.saveLog();
        }
    }
        
    /**
     * Logs an error from the provided exception and saves the log based on the saveFlag.
     * 
     * @param ex        The exception to log.
     * @param saveFlag  Determines whether to save the log or not.
     */
    public static void logError(Exception ex, Boolean saveFlag) {
        StackTraceParser parser = new StackTraceParser(ex);
        String apexClassName = safecopy(parser.className, 60);
        String errString = apexClassName + ' threw an error on line ' + ex.getLineNumber() + ': ' + ex.getMessage();
        Logger.error(errString);
        
        if (saveFlag) {
            Logger.saveLog();
        }
    }
    
    /**
     * Logs any errors in the saveResults and saves the log if there are any errors.
     *
     * @param saveResults    The list of Database.SaveResult objects.
     * @param objectList     The list of SObject records.
     * @param apexClassName  The name of the Apex class.
     */
    public static void logError(List<Database.SaveResult> saveResults, List<SObject> objectList, String apexClassName) {
        Boolean hasError = false;
        
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults.get(i).isSuccess()) {
                hasError = true;
                String recordId = null;
                try {
                    recordId = objectList.isEmpty() ? null : (String) objectList[i].get('Id');
                } catch (System.SObjectException ex) {
                   // eat this exception intentionally BECAUSE Platform Events don't define an ID field  
                }
                list<Database.Error> dbErrorList = saveResults.get(i).getErrors();
                for(Database.Error dbError: dbErrorList){
                    Logger.error(composeErrorMessage(dbError,apexClassName,recordId));                                    
                }
               
            }
        }
        
        if (hasError) {
            Logger.saveLog();
        }
    }
    
    /**
     * Logs any errors in the deleteResults and saves the log if there are any errors.
     *
     * @param saveResults    The list of Database.DeleteResult objects.
     * @param objectList     The list of SObject records.
     * @param apexClassName  The name of the Apex class.
     */
    public static void logError(List<Database.DeleteResult> deleteResults, List<SObject> objectList, String apexClassName) {
        Boolean hasError = false;
        
        for (Integer i = 0; i < deleteResults.size(); i++) {
            if (!deleteResults.get(i).isSuccess()) {
                hasError = true;
                String recordId = objectList.isEmpty() ? null : (String) objectList[i].get('Id');
                list<Database.Error> dbErrorList = deleteResults.get(i).getErrors();
                for(Database.Error dbError: dbErrorList){
                    Logger.error(composeErrorMessage(dbError,apexClassName,recordId));                                    
                }
               
            }
        }
        
        if (hasError) {
            Logger.saveLog();
        }
    }
    
    /**
     * Logs any errors in the undeleteResults and saves the log if there are any errors.
     *
     * @param saveResults    The list of Database.DeleteResult objects.
     * @param objectList     The list of SObject records.
     * @param apexClassName  The name of the Apex class.
     */
    public static void logError(List<Database.unDeleteResult> undeleteResults, List<SObject> objectList, String apexClassName) {
        Boolean hasError = false;
        
        for (Integer i = 0; i < undeleteResults.size(); i++) {
            if (!undeleteResults.get(i).isSuccess()) {
                hasError = true;
                String recordId = objectList.isEmpty() ? null : (String) objectList[i].get('Id');
                list<Database.Error> dbErrorList = undeleteResults.get(i).getErrors();
                for(Database.Error dbError: dbErrorList){
                    Logger.error(composeErrorMessage(dbError,apexClassName,recordId));                                    
                }
               
            }
        }
        
        if (hasError) {
            Logger.saveLog();
        }
    }
    
    /**
     * Logs any errors in the UpsertResults and saves the log if there are any errors.
     *
     * @param upsertResults  The list of Database.UpsertResult objects.
     * @param objectList     The list of SObject records.
     * @param apexClassName  The name of the Apex class.
     */
    public static void logError(List<Database.upsertResult> upsertResults, List<SObject> objectList, String apexClassName) {
        Boolean hasError = false;
        
        for (Integer i = 0; i < upsertResults.size(); i++) {
            if (!upsertResults.get(i).isSuccess()) {
                hasError = true;
                String recordId = objectList.isEmpty() ? null : (String) objectList[i].get('Id');
                list<Database.Error> dbErrorList = upsertResults.get(i).getErrors();
                for(Database.Error dbError: dbErrorList){
                    Logger.error(composeErrorMessage(dbError,apexClassName,recordId));                                    
                }
               
            }
        }
        
        if (hasError) {
            Logger.saveLog();
        }
    }
    
    
     /**
     * Logs the flow errors based on the provided list of LogFaultDetail objects.
     * Saves the log if there are any errors.
     *
     * @param faults  The list of LogFaultDetail objects containing flow error details.
     */
    @InvocableMethod(label='Log Flow Error' category='Logging')
    public static void logFlowError(List<LogFaultDetail> faults) {
        Boolean hasError = false;
        
        for (LogFaultDetail fault : faults) {
            hasError = true;
            String errString = 'Flow name: ' + fault.flowName + ' | Flow Element Name: ' + fault.flowElement + ' | Error: ' + fault.message;
            logError(errString, false);
        }
        
        if (hasError) {
            Logger.saveLog();
        }
    }
    
    /**
     * Data structure to hold the flow error details.
     */
    public class LogFaultDetail {
        @InvocableVariable(required=true)
        public String flowName;
        
        @InvocableVariable
        public String flowElement;
        
        @InvocableVariable
        public String message;
    }
    
    public static String composeErrorMessage(final Database.Error dbError, final String context, final String recordId) {
        return context + ((recordId == null) ? '' :  ' threw an error for record Id: ' + recordId) + ' - ' + dbError.getMessage();
    }
    
    /**
     * Logs the LWC error with the provided error message and LWC name.
     * Saves the log.
     * 
     * @param error    The error message.
     * @param lwcName  The name of the LWC component.
     */
    @AuraEnabled
    public static string logLwcError(String error, String lwcName) {
        String errString = 'LWC name: ' + lwcName + ' | Error: ' + error;
        logError(errString, true);
        return errString;
    }
    /**
* Copies a  substring from the given string, ensuring the length is not exceeded. 
* If the length is exceeded, it returns the substring up to the given length.
* @param val The string to be copied
* @param maxLen The maximum length of the copied string
* @return The copied string
**/
    public static String safecopy(String val, Integer maxLen) {
        return (val == null) ? null : val.left(maxLen);
    }
    
    public class StackTraceParser {
        public final string context;
        public final string className;
        public final string methodName;
        public final string stackTrace;
        /**
        * Parse the stacktrace and initialize the results
        **/ 
        public StackTraceParser(final Exception ex) {
            stackTrace=ex.getStackTraceString();
            List<String> parts = stackTrace.split(':');
            final String classPart = parts[0];
            List<String> tokens = classPart.split('\\.');
            /**
              * Scenarios
              * 
              * Anonymous Apex --> AnonymousBlock
              * Outer Class --> Class.Classname.Methodname
              * Inner Class --> Class.OuterClassName.InnerClassName.MethodName
              * 
            **/ 
            // First token is always the context
            context=tokens[0];
            // Last token can always be interpretted as methodname
            methodName=tokens[tokens.size()-1];
            
            if (tokens.size() > 2) {
                tokens.remove(0); // Remove Context
                tokens.remove(tokens.size()-1); // Remove Method
            }
            // Whatever is left we treat as the className
            className=String.join(tokens,'.'); 
        }
    }
    
}