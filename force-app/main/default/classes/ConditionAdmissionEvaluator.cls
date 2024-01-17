/**********************************************************************************************************************************
 * 
 * 
 * Created By: Moiyyad Sufi - CloudJunction
 * 
 * Last Modified Date: Moiyyad - 13-1-2024
 * 
 * Description: 
 * This class contains an invokeable action that evaluates conditions defined for RLA or a child of RLA
 * 
 * Invocation:
 * Call the invocable method with a list of Ids of a single object
 * @InvocableMethod(label='Invoke Condition Evaluation' description='Pass List of Ids of records and Condition Evaluation')
 * public static List<String> invokeConditionAdmissionEvaluator(List<Id> listOfIds) {
 * 
 * Prerequisites:
 * - Create Conditions using Conditions_Admissions_Mapping_mdt and Conditions_Admissions_Criteria_mdt
 * 
 * Dependencies:
 * ConditionAdmissionEvaluatorUtil.cls
 * 
 * Test Class:
 * ConditionAdmissionEvaluatorTest
 ********************************************************************************************************************************/

public without sharing class ConditionAdmissionEvaluator {
    // Exceptions Declaration
    public class InvalidParamException extends Exception {}
    public class InvalidObjectApiNameException extends Exception {}
    public class CustomMalformedQueryException extends Exception {}
    public class CriteriaEvaluationException extends Exception {}


    // Primitive Variables Declaration
    String objectApiName;
    String relationshipFieldName;

    // List or Set Declarations
    List<Id> listOfIds;
    List<Id> listOfRlaIds;
    List<sObject> recordsList;
    Set<String> conditionsSubjectsSet;
    

    // Map Declarations
    Map<Id, List<Conditions_Admission_Criterion__mdt>> mappingToCriteriaMap;
    Map<Id, Conditions_Admission_Mapping__mdt> mappingMap;
    Map<String, Task> mappingAndRecordTaskMap;
    Map<String, List<sObject>> rlaIdToRecordMap;


    // Begin Execution of invokable method for Condition Criteria Evaluation
    @InvocableMethod(label='Invoke Condition Evaluation' description='Pass List of Ids of records and Condition Evaluation')
    public static List<String> invokeConditionAdmissionEvaluator(List<Id> listOfIds) {
        
        // Class instantiation and and param checks
        ConditionAdmissionEvaluator evaluator = new ConditionAdmissionEvaluator();
        if(listOfIds == null || listOfIds.size() == 0) {
            throw new InvalidParamException('ConditionAdmissionEvaluator.invokeConditionAdmissionEvaluator invoked with null or empty list of parameters');
        }

        // Retrieve and validate object api name for which code is running
        evaluator.listOfIds = listOfIds;
        System.debug(listOfIds[0]);
        evaluator.objectApiName = String.valueOf(listOfIds[0].getsobjecttype());
        if(evaluator.objectApiName == null || evaluator.objectApiName.length() == 0) {
            throw new InvalidObjectApiNameException('ConditionAdmissionEvaluator.invokeConditionAdmissionEvaluator: Unable to parse Object Api Name for which conditions have to be evaluated');
        }

        // Create a class member Map of CMDTs Conditions_Admission_Mapping.Id to Conditions_Admission_Criteria
        // Return comma separated list of fields for which objects have to be queried
        String commaSepFieldList = evaluator.getConditionAdmissionList();
        if(commaSepFieldList == '') {
            return new List<String>();
        }
        System.debug(commaSepFieldList);

        // Query records with the fields passed in the commSepFieldList String
        // Create a class member Map of ResidentialLoanApplication.Id to related records list
        evaluator.getObjectRecords(commaSepFieldList);
        if(evaluator.recordsList.size() == 0 || evaluator.recordsList == null) {
            return new List<String>();
        }
        System.debug(evaluator.recordsList);

        // Create a class member Map of ResidentialLoanApplication.Id+Task.Subject to Task record
        evaluator.createTasksMap();
        if(evaluator.mappingAndRecordTaskMap == null || evaluator.mappingAndRecordTaskMap.size() == 0) {
            return new List<String>();
        }

        // Evaluate Conditions Criteria for each Conditions Mapping and each record
        System.debug('Criteria Evaluation Start');
        List<Task> taskUpdateList = evaluator.beginConditionCriteriaEval();
        If(taskUpdateList == null || taskUpdateList.size() == 0) {
            return new List<String>();
        }

        // Final Update of Tasks List
        
        update taskUpdateList;
    

        return new List<String>();
    }

    String getConditionAdmissionList() {

        // Initialize
        String commaSepFieldList = '';

        // Get Conditions Admission Mapping
        List<Conditions_Admission_Mapping__mdt> conditionAdmissionsMappingList = 
        [
            SELECT Id, Task_Subject__c, Boolean_Logic__c, Object_Api_Name__c, RLA_Relationship_Field_Api_Name__c, Field_To_Update_Api_Name__c, Field_Truthy_Update_Value__c, Field_Falsy_Update_Value__c, Child_Criteria_Reducer__c	
            FROM Conditions_Admission_Mapping__mdt
            WHERE Object_Api_Name__c = :this.objectApiName  WITH SECURITY_ENFORCED
        ];

        // Return if no Mapping exists for this object
        if(conditionAdmissionsMappingList.size() == 0) {
            return '';
        }

        // Create Map of Conditions_Admission_Mapping.Id to Conditions_Admission_Mapping
        // Add Relationship Field Name to String Comma Separated List of Fields to Query
        Set<Id> setOfMappingIds = new Set<Id>();
        this.conditionsSubjectsSet = new Set<String>();
        this.relationshipFieldName = conditionAdmissionsMappingList[0].RLA_Relationship_Field_Api_Name__c;
        this.mappingMap = new Map<Id, Conditions_Admission_Mapping__mdt>();
        for(Conditions_Admission_Mapping__mdt cam:conditionAdmissionsMappingList) {
            setOfMappingIds.add(cam.Id);
            mappingMap.put(cam.Id, cam);
            this.conditionsSubjectsSet.add(cam.Task_Subject__c);
            if(!commaSepFieldList.contains(cam.RLA_Relationship_Field_Api_Name__c)) {
                commaSepFieldList = commaSepFieldList + cam.RLA_Relationship_Field_Api_Name__c+',';
            }
        }

        // Get Conditions Admission Criteria related to the mappings
        List<Conditions_Admission_Criterion__mdt> conditionAdmissionsCriteriaList = 
        [
            SELECT Id, MasterLabel, Conditions_Admission_Mapping__c, Field_Api_Name__c, Operator__c, Value__c
            FROM Conditions_Admission_Criterion__mdt
            WHERE Conditions_Admission_Mapping__c IN :setOfMappingIds  WITH SECURITY_ENFORCED
        ];

        // Return if no Criteria exists for this object
        if(conditionAdmissionsCriteriaList.size() == 0) {
            return '';
        }

        //Variables Initialization
        this.mappingToCriteriaMap = new Map<Id,List<Conditions_Admission_Criterion__mdt>>();
        

        // Initialization of mappingToCriteriaMap
        for(Conditions_Admission_Criterion__mdt cac:conditionAdmissionsCriteriaList) {
            if(!commaSepFieldList.contains(cac.Field_Api_Name__c)) {
                commaSepFieldList = commaSepFieldList + cac.Field_Api_Name__c + ',';
            }

            if(!this.mappingToCriteriaMap.containsKey(cac.Conditions_Admission_Mapping__c)) {
                this.mappingToCriteriaMap.put(cac.Conditions_Admission_Mapping__c, new List<Conditions_Admission_Criterion__mdt>());
            }
            this.mappingToCriteriaMap.get(cac.Conditions_Admission_Mapping__c).add(cac);

        }
        System.debug(commaSepFieldList);
        commaSepFieldList = commaSepFieldList.removeEnd(',');
        return commaSepFieldList;
        
    }

    void getObjectRecords(String commaSepFieldList) {
        System.debug(listOfIds);
        
        // Query Records and store in this.
        String query = 
        'SELECT ' + String.escapeSingleQuotes(commaSepFieldList) 
            + ' FROM ' +  String.escapeSingleQuotes(this.objectApiName) 
            + ' WHERE Id IN :listOfIds';
        System.debug(query);
        try {
        	this.recordsList = Database.query(query);
        } catch(Exception e) {
            throw new CustomMalformedQueryException('ConditionAdmissionEvaluator incorrect query expression:'+ query+'; Further Details: '+e.getMessage());
        }
        listOfRlaIds = new List<Id>();

        // If the ids are for child object records of RLA, requery all child object records for reductive boolean processing
        if(this.objectApiName != 'ResidentialLoanApplication') {
            for(SObject rec: this.recordsList) {
                listOfRlaIds.add(String.valueOf(rec.get(relationshipFieldName))); 
            }
            query = 
                'SELECT ' + String.escapeSingleQuotes(commaSepFieldList) 
                + ' FROM ' +  String.escapeSingleQuotes(this.objectApiName) 
                + ' WHERE '+ String.escapeSingleQuotes(this.relationshipFieldName)
                + ' IN :listOfRlaIds';
            try {
                this.recordsList = Database.query(query);
            } catch(Exception e) {
                throw new CustomMalformedQueryException('ConditionAdmissionEvaluator incorrect query expression:'+ query+'; Further Details: '+e.getMessage());
            }
        }

        // Creation of Map of ResidentialLoanApplication.Id to List of records related to that RLA for which each criteria needs to be processed
        rlaIdToRecordMap = new Map<String, List<SObject>>();        
        for(SObject rec: this.recordsList) {
            If(rlaIdToRecordMap.containsKey(String.valueOf(rec.get(this.relationshipFieldName)))) {
                rlaIdToRecordMap.get(String.valueOf(rec.get(this.relationshipFieldName))).add(rec);
                 
            } else {
                rlaIdToRecordMap.put(String.valueOf(rec.get(this.relationshipFieldName)), new List<sObject>{rec});
            }
                   
        }
        System.debug('rlaIdToRecordMap+'+rlaIdToRecordMap);
    }


    void createTasksMap() {
        List<Id> taskWhatIdList;

        // Is the criteria evaluation to take place for the RLA or for its child records
        if(this.objectApiName != 'ResidentialLoanApplication') {
        	taskWhatIdList = listOfRlaIds;
        } else {
            taskWhatIdList = listOfIds;
        }

        // Query All Tasks related to Triggered Condition Admission Mapping records
        String query = 
            'SELECT Id, Subject, WhatId FROM Task WHERE WhatId IN :taskWhatIdList AND Subject IN :conditionsSubjectsSet';
        System.debug(query);
        List<Task> taskList;
        try{
        	taskList = Database.query(query);
        } catch(Exception e) {
            throw new CustomMalformedQueryException('ConditionAdmissionEvaluator.invokeConditionAdmissionEvaluator Error: Unexpected error when querying tasks for '+ this.objectApiName+'. Details: '+e.getMessage());
        }
        if(taskList.size() == 0) {
            return;
        }
        
        // Create a class member Map of ResidentialLoanApplication.Id+Task.Subject to Task record
        this.mappingAndRecordTaskMap = new Map<String, Task>();
        for(Task t:taskList) {
            this.mappingAndRecordTaskMap.put(t.WhatId + t.Subject, t);
        }
        System.debug(this.mappingAndRecordTaskMap);

    }

    List<Task> beginConditionCriteriaEval() {
        // TODO
        // For Each Condition Mappings
        //   For Each Rla in RecordMap
        //     For record related to current key in record map
        //       Evaluate Each Condition Criteria
        //          Store all criteria evaluations in an array
        //       Reduce array of criteria evaluations
        //     Add Task List Entry
        // return Task List

        List<Task> tasksToUpdate = new List<Task>();
        for(Id mappingId:mappingMap.keyset()) {
            String boolOperator = mappingMap.get(mappingId).Boolean_Logic__c;
            System.debug(mappingMap.get(mappingId).Task_Subject__c);
            

            for(Id rlaId: rlaIdToRecordMap.keySet()) {
                List<Boolean> valueList = new List<Boolean>();
                for(sObject objectRecord: rlaIdToRecordMap.get(rlaId)) {
                    Boolean value;
                    for(Conditions_Admission_Criterion__mdt criterion: mappingToCriteriaMap.get(mappingId)) {
                        try {
                            if(value == null) {
                                value = ConditionAdmissionEvaluatorUtil.evaluate(objectRecord.get(criterion.Field_Api_Name__c), ConditionAdmissionEvaluatorUtil.getFieldType(criterion.Field_Api_Name__c, objectApiName), criterion.Operator__c, criterion.Value__c);
                            } else if(boolOperator == 'AND') {
                                value = value && ConditionAdmissionEvaluatorUtil.evaluate(objectRecord.get(criterion.Field_Api_Name__c), ConditionAdmissionEvaluatorUtil.getFieldType(criterion.Field_Api_Name__c,objectApiName), criterion.Operator__c, criterion.Value__c);
                            } else if(boolOperator == 'OR') {
                                value = value || ConditionAdmissionEvaluatorUtil.evaluate(objectRecord.get(criterion.Field_Api_Name__c), ConditionAdmissionEvaluatorUtil.getFieldType(criterion.Field_Api_Name__c,objectApiName), criterion.Operator__c, criterion.Value__c);
                            }
                        } catch (Exception e) {
                            throw new CriteriaEvaluationException('ConditionAdmissionEvaluator evaluation exception for criteria:'+ mappingMap.get(mappingId).Task_Subject__c  
                            +'; Operand: '+objectRecord.get(criterion.Field_Api_Name__c)
                            +'; Operator: '+criterion.Operator__c
                            +'; Value: '+criterion.Value__c
                            +'; Operator Type: '+ConditionAdmissionEvaluatorUtil.getFieldType(criterion.Field_Api_Name__c,objectApiName)
                            );
                        }
                        
                        System.debug('field api name:'+ConditionAdmissionEvaluatorUtil.getFieldType(criterion.Field_Api_Name__c, objectApiName));

                        System.debug('Value:'+value);
                    }
                    valueList.add(value);
                    
                }
                System.debug('Before reduction: '+valueList);
                Boolean reducedValue = ConditionAdmissionEvaluatorUtil.reduceBooleanList(valueList, mappingMap.get(mappingId).Child_Criteria_Reducer__c);
                System.debug('After reduction: '+reducedValue);

                String valueToBeSet;
                if(reducedValue == true) {
                    valueToBeSet = mappingMap.get(mappingId).Field_Truthy_Update_Value__c;                    
                } else {
                    valueToBeSet = mappingMap.get(mappingId).Field_Falsy_Update_Value__c;
                }
                        
                Task t = new Task();
                if(mappingAndRecordTaskMap.containsKey(rlaId +  mappingMap.get(mappingId).Task_Subject__c)) {
                t.put('Id',mappingAndRecordTaskMap.get(rlaId +  mappingMap.get(mappingId).Task_Subject__c).Id);
                t.put(mappingMap.get(mappingId).Field_To_Update_Api_Name__c, valueToBeSet);
                tasksToUpdate.add(t);
                }
            }
        }
        return tasksToUpdate;
    }
}