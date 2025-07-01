/**
* Test the DesignByContract class
**/
@IsTest(isParallel=true)
public class DesignByContractUtilTest {
    public static testMethod void deprecation() {
        final String msg ='Deprecated method XXX';
        try {
            DesignByContractUtil.deprecated(msg);
            System.Assert(false,'Must not reach this line');
        } catch(DesignByContractUtil.DeprecationException depEx) {
            System.AssertEquals(msg,depEx.getMessage(),'Wrong message');
        }
    }
    public static testMethod void assertTrue() {
        final String msg = 'Test Assert Message';
        try {
            DesignByContractUtil.assert(true,msg);
            System.Assert(true,'Must continue to reach this line');
        } catch(DesignByContractUtil.DBCAssertionException depEx) {
            System.Assert(false,'Must not throw ex');
        }
    }
    public static testMethod void assertFalse() {
       final String msg = 'Test Assert Message';
         try {
            DesignByContractUtil.assert(false,msg);
            System.Assert(true,'Must NOT to reach this line');
        } catch(DesignByContractUtil.DBCAssertionException depEx) {
            System.Assert(true,'Expected Exception caught');
        }
    }
    public static testMethod void assertEqualsTrue() {
        final String msg = 'Test Assert Message';
        try {
            DesignByContractUtil.assertEquals(1,1,msg);
            System.Assert(true,'Must continue to reach this line');
        } catch(DesignByContractUtil.DBCAssertionException depEx) {
            System.Assert(false,'Must not throw ex');
        }
    }
    public static testMethod void assertEqualsFalse() {
       final String msg = 'Test Assert Message';
         try {
            DesignByContractUtil.assertEquals(0,1,msg);
            System.Assert(true,'Must NOT to reach this line');
        } catch(DesignByContractUtil.DBCAssertionException depEx) {
            System.Assert(true,'Expected Exception caught');
        }
    } 
    public static testMethod void assertNotEqualsTrue() {
        final String msg = 'Test Assert Message';
        try {
            DesignByContractUtil.assertNotEquals(0,1,msg);
            System.Assert(true,'Must continue to reach this line');
        } catch(DesignByContractUtil.DBCAssertionException depEx) {
            System.Assert(false,'Must not throw ex');
        }
    }
    public static testMethod void assertNotEqualsFalse() {
       final String msg = 'Test Assert Message';
         try {
            DesignByContractUtil.assertNotEquals(1,1,msg);
            System.Assert(true,'Must NOT to reach this line');
        } catch(DesignByContractUtil.DBCAssertionException depEx) {
            System.Assert(true,'Expected Exception caught');
        }
    }   
   /**
    *     
    * public static void assertEquals(final Object expected, final Object actual,final String msg) {
        if (expected!=actual) {
            throw new DBCAssertionException(msg+' Expected:' + expected + ' Actual:' + actual);
        }
    }
    public static void assertNotEquals(final Object expected, final Object actual,final String msg) {
        if (expected==actual) {
            throw new DBCAssertionException(msg+' NOT Expected:' + expected + ' Actual:' + actual);
        }
    }


    public class DeprecationException extends Exception {}
    public class DBCAssertionException extends Exception {}
**/
}