/**********************************************************************************************************************************
 * 
 * 
 * Created By: Moiyyad Sufi - CloudJunction
 * 
 * Last Modified Date: Moiyyad - 13-1-2024
 * 
 * Description: 
 * Util Class for ConditionAdmissionEvaluator
 * 
 * ADT:
 * 
 * public with sharing class ConditionAdmissionEvaluatorUtil {
 * 
 *      // Evaluate conditions
 *      public static Boolean evaluate(Object operator, String operatorType, String operation, String operand) {}
 * 
 *      // Reduce a boolean array to a single value based on ANY/ALL
 *      public static Boolean reduceBooleanList(List<Boolean> boolList, String mode) {
 *
 * 
 *      // return Field Type given an object and field
 *      public static String getFieldType(String fieldName, String objectApiName) {}
 * 
 * }
 * 
 * Prerequisites:
 * - Create Conditions using Conditions_Admissions_Mapping_mdt and Conditions_Admissions_Criteria_mdt
 * 
 * Dependencies:
 * ConditionAdmissionEvaluator.cls
 * 
 * Test Class:
 * ConditionAdmissionEvaluatorTest
 ********************************************************************************************************************************/

public with sharing class ConditionAdmissionEvaluatorUtil {

    //Evaluate conditions
    public static Boolean evaluate(Object operator, String operatorType, String operation, String operand) {
        operatorType = operatorType.toUpperCase();
        
        System.debug('##Operator:'+operator+'##type:'+operatorType+'##operation:'+operation+'##operand'+operand);
        
        if(operatorType == 'STRING' || operatorType == 'PHONE' || operatorType == 'EMAIL' 
            || operatorType == 'PICKLIST' || operatorType == 'ENCRYPTEDSTRING' || operatorType == 'REFERENCE'
            || operatorType == 'TEXTAREA' || operatorType == 'URL' || operatorType == 'COMBOBOX'
            || operatorType == 'ID'
            ) {
                String castedOperator;
                String castedOperand;
                if(String.ISBLANK(String.valueOf(operator))) {
                	castedOperator = '';
                } else {
                    castedOperator = String.valueOf(operator);
                }
                
                if(String.ISBLANK(String.valueOf(operand))) {
                	castedOperand  ='';
                } else {
                    castedOperand = String.valueOf(operand);
                }
                System.debug(castedOperator);
                System.debug(castedOperand);
                switch on operation {
                    when 'Equal To' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Equal To' {
                        return castedOperator != castedOperand;
                    }
                    when 'Greater Than' {
                        return castedOperator.compareTo(castedOperand) > 0;
                    }
                    when 'Greater Than Equal To' {
                        return castedOperator.compareTo(castedOperand) >= 0;
                    }
                    when 'Lesser Than' {
                        return castedOperator.compareTo(castedOperand) < 0;
                    }
                    when 'Lesser Than Equal To' {
                        return castedOperator.compareTo(castedOperand) <= 0;
                    }
                    when 'Contains' {
                        return castedOperator.contains(castedOperand);
                    }
                    when 'Not Contains' {
                        return !castedOperator.contains(castedOperand);
                    }
                    when 'In' {
                        return castedOperand.contains(castedOperator);
                    }
                    when 'Not In' {
                        return !castedOperand.contains(castedOperator);
                    }
                    when else {
                        return null;
                    }
                }
            } else if(operatorType == 'BOOLEAN') {
                Boolean castedOperator = Boolean.valueOf(operator);
                Boolean castedOperand = Boolean.valueOf(operand.deleteWhitespace().toLowerCase());

                switch on operation {
                    when 'Equal To' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Equal To' {
                        return castedOperator != castedOperand;
                    }
                    when 'Greater Than' {
                        return castedOperator != castedOperand;
                    }
                    when 'Greater Than Equal To' {
                        return castedOperator == castedOperand;
                    }
                    when 'Lesser Than' {
                        return castedOperator != castedOperand;
                    }
                    when 'Lesser Than Equal To' {
                        return castedOperator == castedOperand;
                    }
                    when 'Contains' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Contains' {
                        return castedOperator != castedOperand;
                    }
                    when 'In' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not In' {
                        return castedOperator != castedOperand;
                    }
                    when else {
                        return null;
                    }
                }
            }else if(operatorType == 'DOUBLE' || operatorType == 'CURRENCY' || operatorType == 'PERCENT') {
                if(operator == null || operand == null) return false;
                
                Double castedOperator = Double.valueOf(String.valueOf(operator).deleteWhitespace());
                Double castedOperand = Double.valueOf(operand.deleteWhitespace());

                switch on operation {
                    when 'Equal To' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Equal To' {
                        return castedOperator != castedOperand;
                    }
                    when 'Greater Than' {
                        return castedOperator > castedOperand;
                    }
                    when 'Greater Than Equal To' {
                        return castedOperator >= castedOperand;
                    }
                    when 'Lesser Than' {
                        return castedOperator < castedOperand;
                    }
                    when 'Lesser Than Equal To' {
                        return castedOperator <= castedOperand;
                    }
                    when 'Contains' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Contains' {
                        return castedOperator != castedOperand;
                    }
                    when 'In' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not In' {
                        return castedOperator != castedOperand;
                    }
                    when else {
                        return null;
                    }
                }
                } else if(operatorType == 'INTEGER' || operatorType == 'LONG') {
                
                if(operator == null || operand == null) return false;

                Long castedOperator = Long.valueOf(String.valueOf(operator).deleteWhitespace());
                Long castedOperand = Long.valueOf(operand.deleteWhitespace());

                switch on operation {
                    when 'Equal To' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Equal To' {
                        return castedOperator != castedOperand;
                    }
                    when 'Greater Than' {
                        return castedOperator > castedOperand;
                    }
                    when 'Greater Than Equal To' {
                        return castedOperator >= castedOperand;
                    }
                    when 'Lesser Than' {
                        return castedOperator < castedOperand;
                    }
                    when 'Lesser Than Equal To' {
                        return castedOperator <= castedOperand;
                    }
                    when 'Contains' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Contains' {
                        return castedOperator != castedOperand;
                    }
                    when 'In' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not In' {
                        return castedOperator != castedOperand;
                    }
                    when else {
                        return null;
                    }
                }

            } else if(operatorType == 'DATE' || operatorType == 'DATETIME') {
                if(operator == null || operand == null) return false;

                DateTime castedOperator;
                DateTime castedOperand;
                if(operatorType == 'DATE') {
                    castedOperator = (DateTime)JSON.deserialize('"' + String.valueOf(operator).deleteWhitespace().toLowerCase()+'T00:00:00.000Z' + '"', DateTime.class);
                	castedOperand = (DateTime)JSON.deserialize('"' + String.valueOf(operand).deleteWhitespace().toLowerCase()+'T00:00:00.000Z' + '"', DateTime.class);
                } else {
                	
                    castedOperator = (DateTime)JSON.deserialize('"' + String.valueOf(operator).deleteWhitespace().toLowerCase() + '"', DateTime.class);
                	castedOperand = (DateTime)JSON.deserialize('"' + String.valueOf(operand).deleteWhitespace().toLowerCase() + '"', DateTime.class);
                }

                switch on operation {
                    when 'Equal To' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Equal To' {
                        return castedOperator != castedOperand;
                    }
                    when 'Greater Than' {
                        return castedOperator > castedOperand;
                    }
                    when 'Greater Than Equal To' {
                        return castedOperator >= castedOperand;
                    }
                    when 'Lesser Than' {
                        return castedOperator < castedOperand;
                    }
                    when 'Lesser Than Equal To' {
                        return castedOperator <= castedOperand;
                    }
                    when 'Contains' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not Contains' {
                        return castedOperator != castedOperand;
                    }
                    when 'In' {
                        return castedOperator == castedOperand;
                    }
                    when 'Not In' {
                        return castedOperator != castedOperand;
                    }
                    when else {
                        return null;
                    }
                }
            }
            return false;
        }

    // Reduce a boolean array to a single value based on ANY/ALL
    public static Boolean reduceBooleanList(List<Boolean> boolList, String mode) {
        if(mode == 'ANY') {
            for (Boolean element : boolList) {
                if (element) {
                    return true;
                }
            }
            // If no element is true, return false
            return false;
        } else if(mode == 'ALL') {
            for (Boolean element : boolList) {
                if (!element) {
                    // If any element is false, return false
                    return false;
                }
            }
            // If all elements are true or the array is empty, return true
            return true;
        }
        return false;
    }

    // return Field Type given an object and field
    public static String getFieldType(String fieldName, String objectApiName) {
        SObjectType r = ((SObject)(Type.forName('Schema.'+objectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        return String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
    }
}