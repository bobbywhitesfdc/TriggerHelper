/**
* Enforce the Design By Concept contracts using exceptions
**/
public with sharing class DesignByContractUtil {
    public static void assertEquals(final Object expected, final Object actual,final String msg) {
        if (expected!=actual) {
            throw new DBCAssertionException(msg+' Expected:' + expected + ' Actual:' + actual);
        }
    }
    public static void assertNotEquals(final Object expected, final Object actual,final String msg) {
        if (expected==actual) {
            throw new DBCAssertionException(msg+' NOT Expected:' + expected + ' Actual:' + actual);
        }
    }
    public static void assert(final Boolean criteria,final String msg) {
        if (criteria==null || !criteria) {
            throw new DBCAssertionException(msg);
        }
    }

    public static void deprecated(final String msg) {
       throw new DeprecationException(msg);
    }
    public class DeprecationException extends Exception {}
    public class DBCAssertionException extends Exception {}
}