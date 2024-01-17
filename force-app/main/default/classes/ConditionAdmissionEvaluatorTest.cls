/**
 * Created By: Moiyyad Sufi - CloudJunction
 * 
 * Last Modified Date: Moiyyad - 13-1-2024
 * 
 */
@isTest
private class ConditionAdmissionEvaluatorTest {

    @isTest
    static void conditionAdmissionInvocableTest() {
        Account a = new Account(
        Name = 'abc'
        );
        insert a;
        
        ResidentialLoanApplication r = new ResidentialLoanApplication(
			Name = 'abc',
            AccountId = a.Id,
            Debt_Items_to_Pay_off__c =1
        );
        insert r;
        
        Task t = new Task(
        	Subject = 'Debts to be paid prior to funding',
            System_Logic__c = 'Omitted',
            WhatId = r.Id
        );
        insert t;
        
        Test.StartTest();
        ConditionAdmissionEvaluator.invokeConditionAdmissionEvaluator(new List<Id>{r.Id});
        Test.StopTest();
        System.assertEquals([Select System_Logic__c FROM Task].System_Logic__c,'Admitted');
    }
    
    @isTest
    static void conditionAdmissionEvaluatorUtilTest() {
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('abc','STRING','Equal To','abc'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('abc','STRING','Not Equal To','abc'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('abc','STRING','Greater Than','abcd'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('abc','STRING','Greater Than Equal To','abcd'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('abc','STRING','Lesser Than','abcd'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('abc','STRING','Lesser Than Equal To','abcd'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('abc','STRING','Contains','ab'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('a','STRING','Not Contains','ab'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('abc','STRING','In','abcd'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('ac','STRING','Not In','ab'),true );

        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Equal To','true'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Not Equal To','true'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Greater Than','true'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Greater Than Equal To','true'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Lesser Than','true'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Lesser Than Equal To','true'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Contains','true'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Not Contains','true'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','In','true'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('true','BOOLEAN','Not In','true'),false );

        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10.0','CURRENCY','Equal To','10'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','Not Equal To','10'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','Greater Than','16.43'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','Greater Than Equal To','10.00'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','Lesser Than','234'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','Lesser Than Equal To','19.91'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','Contains','10'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','Not Contains','10'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','In','10'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','CURRENCY','Not In','9'),true );
        
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10.0','INTEGER','Equal To','10'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','Not Equal To','10'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','Greater Than','16'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','Greater Than Equal To','10.00'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','Lesser Than','234'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','Lesser Than Equal To','20'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','Contains','10'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','Not Contains','10'),false );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','In','10'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('10','INTEGER','Not In','9'),true );
                    
                    
                   
                   

        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('2022-10-06','DATE','Greater Than','2021-12-12'),true );
        System.assertEquals(ConditionAdmissionEvaluatorUtil.evaluate('2020-10-06T00:00:00.000Z','DATETIME','Equal To','2020-10-06T00:00:00.000Z'),true );

    }
}