/**
 * @description       : 
 * @author            : Ahad Faroque 
 * @group             : 
 * @last modified on  : 01-28-2022
 * @last modified by  : Ahad Faroque
**/
public class DeepCloneRLA {
    
    @InvocableMethod(label='Deep Clone RLA with or without Opportunity' description='If action is executed from Opportunity, Opportunity will be cloned RLA, If its executed from RLA, Only Application and its related objects will be cloned.')
    public static List <Results> InvokeCloningFunction(List<Requests> requestList) {
        
        List<String> listofIds = requestList[0].inputCollection;

        
        //Return Cloned RLA Or Opportunity Ids
        List<Id> ListofIdtoReturn = New List<Id>();
        //Get sObject Name
        string sObjectType = DeepCloneRLA.findObjectNameFromRecordIdPrefix(listofIds[0]);
        
        
        //If Cloning is executed from Opportunity
        If(sObjectType == 'Opportunity'){
        
        List<Opportunity> oppList = [Select id from Opportunity where Id IN: listofIds LIMIT 1 ];
        
        Id CloneOppId = DeepCloneRLA.cloneRLAwithOpp(oppList[0].Id);
        
        ListofIdtoReturn.add(CloneOppId);
            
        }  
        
        //If Cloning is executed from Residential Loan Application
        
        If(sObjectType == 'ResidentialLoanApplication'){
            
            Id CloneRLAId =    DeepCloneRLA.cloneRLA(listofIds[0]);
            ListofIdtoReturn.add(CloneRLAId);
            
        }     
        
     //Create a Results object to hold the return values
        Results response = new Results();

        //Add the return values to the Results object
        response.outputId = ListofIdtoReturn[0];
        
        //Wrap the Results object in a List container 
        //(an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        system.debug('responseWrapper' + responseWrapper);
        return responseWrapper;   
        
    }

    public static string cloneRLAwithOpp (string oppId){
 
        //All Inserting Lists
        List<LoanApplicant> applicantsToInsert = New List<LoanApplicant>();
        List<LoanApplicantAddress> applicantsaddrToInsert = New List<LoanApplicantAddress>();
        List<LoanApplicantEmployment> applicantEmploymentToInsert = New List<LoanApplicantEmployment>();
        List<LoanApplicantIncome> applicantIncometoInsert = New List<LoanApplicantIncome>();      
        List<LoanApplicationAsset> applicationAssettoInsert = New List<LoanApplicationAsset>();
        List<LoanApplicationLiability> applicationLiabilityToInsert = New List<LoanApplicationLiability>();
        List<CJA_Mortgage__Down_Payment_Source__c> DPSourcesToInsert = New List<CJA_Mortgage__Down_Payment_Source__c>();
        List<LoanApplicantDeclaration> DeclarationsToInsert = New List<LoanApplicantDeclaration>();
        List<LoanApplicationProperty> ApplicationPropToInsert = New List<LoanApplicationProperty>();
        List<CJA_Mortgage__Mortgage__c> MortgageToInsert = New List<CJA_Mortgage__Mortgage__c>();
        List<CJA_Mortgage__Application_Fee__c> AppFeetoInsert = New List<CJA_Mortgage__Application_Fee__c>();
		
        map<string,string> loanApplicantIdMap = New map<string,string>();
        
        /*
* Opportunity
*/ 
        
        string OpportunityFields = getFieldAPINames('Opportunity');
        string strOppfieldName = OpportunityFields.substring(0, OpportunityFields.length()-1);
        
        //Dynamic Query to Get Source Opportunity and clone it
        Opportunity sourceOpp = Database.query('select ' + strOppfieldName + ' from Opportunity ' + ' where id =: oppId');
        Opportunity cloneOpp = sourceOpp.clone(false, false, false);
        
        ResidentialLoanApplication rla = [Select id,Opportunityid from ResidentialLoanApplication where Opportunityid =: oppId LIMIT 1];
        
        
        string rlaID = rla.Id;
        
        cloneOpp.Name = sourceOpp.Name + ' - Copy';

        try{
            If(cloneOpp != null){
            insert cloneOpp;
            }        
        }    
        
        catch(exception e){
            
            system.debug('exeption on opp::' + e.getMessage());
        }
        
        
        /*
* RLA
*/ 
        //Get API field Names of RLA 
        string RLAFields = getFieldAPINames('ResidentialLoanApplication');
        string strfieldName = RLAFields.substring(0, RLAFields.length()-1);
        
        //Dynamic Query to Get Source RLA and clone it
        ResidentialLoanApplication sourceRLA = Database.query('select ' + strfieldName + ' from ResidentialLoanApplication ' + ' where id =: rlaID');
        ResidentialLoanApplication cloneRLA = sourceRLA.clone(false, false, false);
        
        //Do you own field Mapping
        cloneRLA.Name = sourceRLA.Name + ' - Copy';
        cloneRLA.CJA_Mortgage__FilogixId__c = null;
        cloneRLA.CJA_Mortgage__Last_Sync_Date__c = null;

        cloneRLA.OpportunityId = cloneOpp.Id;
        cloneRLA.CJA_Mortgage__Subject_Property__c = null;
        
        try{
            If(cloneRLA != null){
            insert cloneRLA;
            }        
        }    
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        /*
* Loan Applicants
*/ 
        //Get API field Names of RLA 
        string ApplicantFields = getFieldAPINames('LoanApplicant');
        string strfieldApplicantName = ApplicantFields.substring(0, ApplicantFields.length()-1);
        strfieldApplicantName.replace(',LoanApplicationId','');
        
        
        //Dynamic Query to Get Source Applicants and clone it  
        List<LoanApplicant> sourceLoanApplicants = Database.query('select ' + strfieldApplicantName + ' from LoanApplicant ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicant> cloneLoanApplicant = sourceLoanApplicants.deepclone(false,true,false);
        
        //Modify cloned Applicants
        
        //   system.debug('cloneRlaID:' + cloneRLA.Id);
        for (LoanApplicant sourcelapplicant : sourceLoanApplicants){
            for (LoanApplicant lapplicant : cloneLoanApplicant){
                
                if(sourcelapplicant.Name == lapplicant.Name  ){
                    
                    loanApplicant lapp = new LoanApplicant();
                    lapp = lapplicant;
                    
                    lapp.LoanApplicationId = cloneRLA.Id;
                    lapp.Source_Applicant_Id__c = sourcelapplicant.Id;
                    lapp.CJA_Mortgage__FilogixId__c = null;
                    applicantsToInsert.add(lapp);    
                    
                }
            }
        }
        
        try{
            
            system.debug('applicantsToInsert::'+ applicantsToInsert);
            If(applicantsToInsert.size() > 0){
                insert applicantsToInsert;            
            }
            
            List<LoanApplicant> app = [Select id,Source_Applicant_Id__c from loanApplicant where LoanApplicationId =: cloneRLA.Id];
        	List<LoanApplicant> loanApplicantstoDel = New List<LoanApplicant>();
            
            for (loanapplicant lapp : app ){
                
                If(!String.IsBlank(lapp.Source_Applicant_Id__c)){
                    loanApplicantIdMap.put(lapp.Source_Applicant_Id__c,lapp.id);
                }

                else{
                    loanApplicantstoDel.add(lapp);
                    system.debug('loanApplicantstoDel::'+ loanApplicantstoDel);
                }
                
            }
            
            
            If(loanApplicantstoDel.size() > 0){
                delete loanApplicantstoDel;            
            }

        }    
        
        catch(exception e){
            
            system.debug('exception at applicant:' + e.getMessage());
        }
        
        
        /*
* Loan Applicants Addreses
*/ 
        
        //Get API field Names of  Loan Applicant Addresses
        string ApplicantAddressFields = getFieldAPINames('LoanApplicantAddress');
        string strfieldApplicantAddress = ApplicantAddressFields.substring(0, ApplicantAddressFields.length()-1);
        
        //Dynamic Query to Get Source Applicant addresses and clone it      
        List<LoanApplicantAddress> sourceLoanApplicantAddreses = Database.query('select ' + strfieldApplicantAddress + ' from LoanApplicantAddress ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicantAddress> cloneLoanApplicantAddreses = sourceLoanApplicantAddreses.deepclone(false,true,false);
        
        
        //Modify cloned Applicant addresses
        
        for(LoanApplicant applicants : applicantsToInsert){
            for (LoanApplicantAddress lapplicantaddress : cloneLoanApplicantAddreses){
                
                if(applicants.Source_Applicant_Id__c == lapplicantaddress.LoanApplicantId){
                    
                    //field mapping for cloned applicant address records
                    //Embed New Applicant Ids to New Applicant Address Records            
                    LoanApplicantAddress lappadd = new LoanApplicantAddress();
                    lappadd = lapplicantaddress;
                    lappadd.LoanApplicantId = applicants.Id;
                    lappadd.LoanApplicationId = cloneRLA.Id;
                    applicantsaddrToInsert.add(lappadd);    
                    
                }
                
            }
        }
        
        try{
            If(applicantsaddrToInsert.size() > 0){
                
                insert applicantsaddrToInsert;
            }
        }    
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        /*
* Loan Applicants Employment
*/ 
        
        //Get API field Names of  Loan Applicant Employment
        string ApplicantEmploymentFields = getFieldAPINames('LoanApplicantEmployment');
        string strfieldApplicantEmployment = ApplicantEmploymentFields.substring(0, ApplicantEmploymentFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Employment and clone it      
        List<LoanApplicantEmployment> sourceLoanApplicantEmployment = Database.query('select ' + strfieldApplicantEmployment + ' from LoanApplicantEmployment ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicantEmployment> cloneLoanApplicantEmployment = sourceLoanApplicantEmployment.deepclone(false,true,false);
        
        
        //Modify cloned Applicant Employment
        
        for(LoanApplicant applicants : applicantsToInsert){
            for (LoanApplicantEmployment lapplicantemployment : cloneLoanApplicantEmployment){
                
                if(applicants.Source_Applicant_Id__c == lapplicantemployment.LoanApplicantId){
                    
                    //field mapping for cloned applicant Employment records
                    //Embed New Applicant Ids to New Applicant Employment Records            
                    LoanApplicantEmployment lappemp = new LoanApplicantEmployment();
                    lappemp = lapplicantemployment;
                    lappemp.CJA_Mortgage__FilogixId__c = null;
                    lappemp.LoanApplicantId = applicants.Id;
                    lappemp.LoanApplicationId = cloneRLA.Id;
                    applicantEmploymentToInsert.add(lappemp);    
                    
                }
                
            }
        }
        
        try{
            
            If(applicantEmploymentToInsert.size() > 0){
                
                insert applicantEmploymentToInsert;
            }    
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        /*
* Loan Applicants Income
*/ 
        
        //Get API field Names of  Loan Applicant Employment
        string ApplicantIncomeFields = getFieldAPINames('LoanApplicantIncome');
        string strfieldApplicantIncome = ApplicantIncomeFields.substring(0, ApplicantIncomeFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Employment and clone it      
        List<LoanApplicantIncome> sourceLoanApplicantIncome = Database.query('select ' + strfieldApplicantIncome + ' from LoanApplicantIncome ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicantIncome> cloneLoanApplicantIncome = sourceLoanApplicantIncome.deepclone(false,true,false);
        
        
        //Modify cloned Applicant Employment
        
        for(LoanApplicant applicants : applicantsToInsert){
            for (LoanApplicantIncome lapplicantIncome : cloneLoanApplicantIncome){
                
                if(applicants.Source_Applicant_Id__c == lapplicantIncome.LoanApplicantId){
                    
                    //field mapping for cloned applicant Employment records
                    //Embed New Applicant Ids to New Applicant Employment Records            
                    LoanApplicantIncome lappincome = new LoanApplicantIncome();
                    lappincome = lapplicantIncome;
                    lappincome.CJA_Mortgage__FilogixId__c =  null;
                    lappincome.LoanApplicantId = applicants.Id;
                    lappincome.LoanApplicationId = cloneRLA.Id;
                    applicantIncometoInsert.add(lappincome);    
                    
                }
                
            }
        }
        
        try{
            
            If(applicantIncometoInsert.size() > 0){
                
                insert applicantIncometoInsert;
            }  
        }   
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
          /*
* Declarations
*/       
        //Get API field Names of  Loan Applicant Declaration
        string ApplicantDeclarationFields = getFieldAPINames('LoanApplicantDeclaration');
        string strfieldApplicantDeclaration = ApplicantDeclarationFields.substring(0, ApplicantDeclarationFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Declaration and clone it      
        List<LoanApplicantDeclaration> sourceLoanApplicantDeclaration = Database.query('select ' + strfieldApplicantDeclaration + ' from LoanApplicantDeclaration ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicantDeclaration> cloneLoanApplicantDeclaration  = sourceLoanApplicantDeclaration.deepclone(false,true,false);
        
        //Modify cloned Applicant Declaration
        
        for(LoanApplicant applicants : applicantsToInsert){
            for (LoanApplicantDeclaration lapplicantdec : cloneLoanApplicantDeclaration){
                
                if(applicants.Source_Applicant_Id__c == lapplicantdec.LoanApplicantId){
                    
                    //field mapping for cloned applicant Declaration records
                    //Embed New Applicant Ids to New Applicant Declaration Records            
                    LoanApplicantDeclaration lappdec = new LoanApplicantDeclaration();
                    lappdec = lapplicantdec;
                    lappdec.LoanApplicantId = applicants.Id;
                    lappdec.LoanApplicationId = cloneRLA.Id;
                    DeclarationsToInsert.add(lappdec);    
                    
                }
                
            }
        }
        
        try{
            
            If(DeclarationsToInsert.size() > 0){
                
                insert DeclarationsToInsert;
            } 
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        
              /*
* Declarations
*/  
        
        
        //Get API field Names of  Loan Application Assets
        string ApplicationAssetsFields = getFieldAPINames('LoanApplicationAsset');
        string strfieldApplicationAssets = ApplicationAssetsFields.substring(0, ApplicationAssetsFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Employment and clone it      
        List<LoanApplicationAsset> sourceLoanApplicationAssets = Database.query('select ' + strfieldApplicationAssets + ' from LoanApplicationAsset ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicationAsset> cloneLoanApplicationAssets = sourceLoanApplicationAssets.deepclone(false,true,false);
        
        
        //Modify cloned Applicant Employment
        
        for (LoanApplicationAsset lapplicationAsset : cloneLoanApplicationAssets){
            
            //field mapping for cloned applicant LoanApplicationAsset records
            LoanApplicationAsset lappAsset = new LoanApplicationAsset();
            lappAsset = lapplicationAsset;
            lappAsset.CJA_Mortgage__FilogixId__c = null;
            lappAsset.LoanApplicationId = cloneRLA.Id;
            applicationAssettoInsert.add(lappAsset);    
            
        }
        
        try{
            
            If(applicationAssettoInsert.size() > 0){
                
                insert applicationAssettoInsert;
            }   
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
                 /*
* Loan Application Liability
*/  
        
        
        //Get API field Names of  Loan Application Liability
        string ApplicationLiabilityFields = getFieldAPINames('LoanApplicationLiability');
        string strfieldApplicationLiability = ApplicationLiabilityFields.substring(0, ApplicationLiabilityFields.length()-1);
        
        //Dynamic Query to Get Source Application Liability and clone it      
        List<LoanApplicationLiability> sourceLoanApplicationLiability = Database.query('select ' + strfieldApplicationLiability + ' from LoanApplicationLiability ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicationLiability> cloneLoanApplicationLiability = sourceLoanApplicationLiability.deepclone(false,true,false);
        
        
        //Modify cloned Application Liability
        
        for (LoanApplicationLiability lapplicationLiability : cloneLoanApplicationLiability){
            
            //field mapping for cloned  LoanApplication recoLiabilityrds
            LoanApplicationLiability lappLiability = new LoanApplicationLiability();
            lappLiability = lapplicationLiability;
            lappLiability.CJA_Mortgage__FilogixId__c = null;
            lappLiability.LoanApplicationId = cloneRLA.Id;
            applicationLiabilityToInsert.add(lappLiability);    
            
        }
        
        try{
            
            If(applicationLiabilityToInsert.size() > 0){
                
                insert applicationLiabilityToInsert;
            }    
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
                   /*
* Down Payment Sources
*/    
        //Get API field Names DownPaymentSources
        string ApplicationDownPaymentSources = getFieldAPINames('CJA_Mortgage__Down_Payment_Source__c');
        string strfieldApplicationDownPaymentSources = ApplicationDownPaymentSources.substring(0, ApplicationDownPaymentSources.length()-1);
        
        //Dynamic Query to Get Source Application DownPaymentSources and clone it      
        List<CJA_Mortgage__Down_Payment_Source__c> sourceLoanApplicationDPSources = Database.query('select ' + strfieldApplicationDownPaymentSources + ' from CJA_Mortgage__Down_Payment_Source__c ' + ' where CJA_Mortgage__Application__c =: rlaID');
        List<CJA_Mortgage__Down_Payment_Source__c> cloneLoanApplicationDPSources = sourceLoanApplicationDPSources.deepclone(false,true,false);
        
        //Modify cloned Application DownPaymentSources
        
        for (CJA_Mortgage__Down_Payment_Source__c lapplicationDPSource : cloneLoanApplicationDPSources){
            
            //field mapping for cloned  LoanApplication recoLiabilityrds
            CJA_Mortgage__Down_Payment_Source__c lappDPSources = new CJA_Mortgage__Down_Payment_Source__c();
            lappDPSources = lapplicationDPSource;
            lappDPSources.CJA_Mortgage__FilogixId__c = null;
            lappDPSources.CJA_Mortgage__Application__c = cloneRLA.Id;
            DPSourcesToInsert.add(lappDPSources);    
            
        }
        
        try{
            If(DPSourcesToInsert.size() > 0){
                
                insert DPSourcesToInsert;
            }
        }    
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        /*
* Loan Application Properties
*/ 
        //Get API field Names of Application Properties 
        string ApplicationPropertiesFields = getFieldAPINames('LoanApplicationProperty');
        string strfieldApplicationPropertyName = ApplicationPropertiesFields.substring(0, ApplicationPropertiesFields.length()-1);
        strfieldApplicantName.replace(',LoanApplicationId','');
        
        
        //Dynamic Query to Get Source Application Property and clone it  
        List<LoanApplicationProperty> sourceLoanApplicationProp = Database.query('select ' + strfieldApplicationPropertyName + ' from LoanApplicationProperty ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicationProperty> cloneLoanApplicationProp = sourceLoanApplicationProp.deepclone(false,true,false);
        
        //Modify cloned Application Property
        
        for (LoanApplicationProperty sourcelapplicationprop : sourceLoanApplicationProp){
            for (LoanApplicationProperty lapplicationprop : cloneLoanApplicationProp){
                
                if(sourcelapplicationprop.Name == lapplicationprop.Name ){
                    
                    LoanApplicationProperty lappprop = new LoanApplicationProperty();
                    lappprop = lapplicationprop;
                    
                    //field mapping for cloned application property records
                    lappprop.LoanApplicationId = cloneRLA.Id;
                    lappprop.Source_Property_Id__c = sourcelapplicationprop.Id;
                    lappprop.Id = null;
                    lappprop.CJA_Mortgage__FilogixId__c = null;
                    lappprop.CJA_Mortgage__Loan_Applicant__c = loanApplicantIdMap.get(sourcelapplicationprop.CJA_Mortgage__Loan_Applicant__c);
                    //lappprop.CJA_Mortgage__Loan_Applicant__c = !String.IsBlank(sourcelapplicationprop.CJA_Mortgage__Loan_Applicant__c) ? loanApplicantIdMap.get(sourcelapplicationprop.CJA_Mortgage__Loan_Applicant__c) : '' ;
                    
                    ApplicationPropToInsert.add(lappprop);    
                    
                }
            }
        }
        
        try{
            If(ApplicationPropToInsert.size() > 0){
                
                system.debug('applicationproptoInsert::'+ ApplicationPropToInsert[0].LoanApplicationId);
                insert ApplicationPropToInsert;
            }    
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }

          /*
* Mortgage
*/ 
        
        //Get API field Names of Mortgage
        string MortgageFields = getFieldAPINames('CJA_Mortgage__Mortgage__c');
        string strfieldMortgage = MortgageFields.substring(0, MortgageFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Declaration and clone it      
        List<CJA_Mortgage__Mortgage__c> sourcePropMortgage = Database.query('select ' + strfieldMortgage + ' from CJA_Mortgage__Mortgage__c ' + ' where CJA_Mortgage__Loan_Application__c =: rlaID');
        List<CJA_Mortgage__Mortgage__c> clonePropMortgage  = sourcePropMortgage.deepclone(false,true,false);
        
        //Modify cloned Applicant Declaration
        
        for(LoanApplicationProperty property : ApplicationPropToInsert){
            
            for (CJA_Mortgage__Mortgage__c mortgagesource : sourcePropMortgage){
                
                for (CJA_Mortgage__Mortgage__c mortgage : clonePropMortgage){
                    
                    if(property.Source_Property_Id__c == mortgage.CJA_Mortgage__Loan_Application_Property__c){
                        
                        //field mapping for cloned applicant Declaration records
                        //Embed New Applicant Ids to New Applicant Declaration Records            
                        CJA_Mortgage__Mortgage__c propmortg = new CJA_Mortgage__Mortgage__c();
                        propmortg = mortgage;
                        propmortg.CJA_Mortgage__Loan_Application_Property__c = property.Id;
                        propmortg.CJA_Mortgage__Loan_Application__c = cloneRLA.Id;
                        propmortg.CJA_Mortgage__FilogixId__c = null;
                        
                        if(mortgagesource.Name == mortgage.Name ){                            
                            propmortg.Source_Mortgage_ID__c = mortgagesource.Id;
                        }
                        
                        MortgageToInsert.add(propmortg);    
                        
                    }
                }
            }
        }
        
        try{
            
            If(MortgageToInsert.size() > 0){ 
                insert MortgageToInsert;
            }    
            
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
                  /*
* Application Fees
*/ 
        
        //Get API field Names of Application Fees
        string ApplicationFeesFields = getFieldAPINames('CJA_Mortgage__Application_Fee__c');
        string strfieldAppFees = ApplicationFeesFields.substring(0, ApplicationFeesFields.length()-1);
        
        //Dynamic Query to Get Source Application Fees and clone it      
        List<CJA_Mortgage__Application_Fee__c> sourceAppFees = Database.query('select ' + strfieldAppFees + ' from CJA_Mortgage__Application_Fee__c ' + ' where CJA_Mortgage__Application__c =: rlaID');
        List<CJA_Mortgage__Application_Fee__c> cloneAppFees  = sourceAppFees.deepclone(false,true,false);
        
        //Modify cloned Application Fees
        
        for(CJA_Mortgage__Mortgage__c mortgage : MortgageToInsert){
            for (CJA_Mortgage__Application_Fee__c applicationfee : cloneAppFees){
                
                if(mortgage.Source_Mortgage_Id__c == applicationfee.CJA_Mortgage__Mortgage__c){
                    
                    //field mapping for cloned Application Fee records
                    //Embed New Property Ids to New Application Fee Records            
                    CJA_Mortgage__Application_Fee__c appfee = new CJA_Mortgage__Application_Fee__c();
                    appfee = applicationfee;
                    appfee.CJA_Mortgage__FilogixId__c = null;
                    appfee.CJA_Mortgage__Mortgage__c = mortgage.Id;
                    appfee.CJA_Mortgage__Application__c = cloneRLA.Id;
                    AppFeetoInsert.add(appfee);    
                    
                }
                
            }
        }
        
        try{
            If(AppFeetoInsert.size() > 0){ 
                
                insert AppFeetoInsert;
            } 
        }
        
        catch(exception e){
            
            system.debug('exception at application fees:' + e.getMessage());
        }
  
                      /*
* Property Expense
*/ 
        
/*        //Get API field Names of PropertyExpense
        string PropExpFields = getFieldAPINames('PropertyExpense__c');
        string strfieldPropExp = PropExpFields.substring(0, PropExpFields.length()-1);
        
        //Dynamic Query to Get Source PropertyExpenses and clone it      
        List<PropertyExpense__c> sourcePropExp = Database.query('select ' + strfieldPropExp + ' from PropertyExpense__c ' + ' where Loan_Application__c =: rlaID');
        List<PropertyExpense__c> clonePropExp  = sourcePropExp.deepclone(false,true,false);
        
        //Modify cloned PropertyExpense
        
        for(LoanApplicationProperty property : ApplicationPropToInsert){
            for (PropertyExpense__c propexpense : clonePropExp){
                
                if(property.Source_Property_Id__c == propexpense.Loan_Application_Property__c && propexpense.Loan_Application_Property__c != null){
                    
                    //field mapping for cloned PropertyExpense records
                    //Embed New Property Ids to New PropertyExpense Records            
                    PropertyExpense__c pexp = new PropertyExpense__c();
                    pexp = propexpense;
                    pexp.CJA_Mortgage__FilogixId__c = null;
                    pexp.Loan_Application_Property__c = property.Id;
                    pexp.Loan_Application__c = cloneRLA.Id;
                    PropExpToInsert.add(pexp);    
                    
                }
                
                else{
                    
                    PropertyExpense__c pexp = new PropertyExpense__c();
                    pexp = propexpense;
                    pexp.CJA_Mortgage__FilogixId__c = null;
                    pexp.Loan_Application__c = cloneRLA.Id;
                    PropExpToInsert.add(pexp);    
                    
                }
            }
        }
        
        try {
            If(PropExpToInsert.size() > 0){ 
                
                insert PropExpToInsert;
            }    
        }
        
        catch(exception e){
            
            system.debug('exception at property exp:' + e.getMessage());
        }*/
        
        return cloneRla.OpportunityId;
    }
    
    
    public static string cloneRLA (string rlaID){
 
        //All Inserting Lists
        List<LoanApplicant> applicantsToInsert = New List<LoanApplicant>();
        List<LoanApplicantAddress> applicantsaddrToInsert = New List<LoanApplicantAddress>();
        List<LoanApplicantEmployment> applicantEmploymentToInsert = New List<LoanApplicantEmployment>();
        List<LoanApplicantIncome> applicantIncometoInsert = New List<LoanApplicantIncome>();      
        List<LoanApplicationAsset> applicationAssettoInsert = New List<LoanApplicationAsset>();
        List<LoanApplicationLiability> applicationLiabilityToInsert = New List<LoanApplicationLiability>();
        List<CJA_Mortgage__Down_Payment_Source__c> DPSourcesToInsert = New List<CJA_Mortgage__Down_Payment_Source__c>();
        List<LoanApplicantDeclaration> DeclarationsToInsert = New List<LoanApplicantDeclaration>();
        List<LoanApplicationProperty> ApplicationPropToInsert = New List<LoanApplicationProperty>();
        List<CJA_Mortgage__Mortgage__c> MortgageToInsert = New List<CJA_Mortgage__Mortgage__c>();
        ///List<PropertyExpense__c> PropExpToInsert = New List<PropertyExpense__c>();
        List<CJA_Mortgage__Application_Fee__c> AppFeetoInsert = New List<CJA_Mortgage__Application_Fee__c>();
        map<string,string> loanApplicantIdMap = New map<string,string>();

        
        /*
* RLA
*/ 
        //Get API field Names of RLA 
        string RLAFields = getFieldAPINames('ResidentialLoanApplication');
        string strfieldName = RLAFields.substring(0, RLAFields.length()-1);
        
        //Dynamic Query to Get Source RLA and clone it
        ResidentialLoanApplication sourceRLA = Database.query('select ' + strfieldName + ' from ResidentialLoanApplication ' + ' where id =: rlaID');
        ResidentialLoanApplication cloneRLA = sourceRLA.clone(false, false, false);
        
        //Do you own field Mapping
        cloneRLA.Name = sourceRLA.Name + ' - Copy';
        cloneRLA.CJA_Mortgage__FilogixId__c = null;
        cloneRLA.CJA_Mortgage__Last_Sync_Date__c = null;
        cloneRLA.CJA_Mortgage__Subject_Property__c = null;
        
        try{
            If(cloneRLA != null){
            insert cloneRLA;
            }        
        }    
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        /*
* Loan Applicants
*/ 
        //Get API field Names of RLA 
        string ApplicantFields = getFieldAPINames('LoanApplicant');
        string strfieldApplicantName = ApplicantFields.substring(0, ApplicantFields.length()-1);
        strfieldApplicantName.replace(',LoanApplicationId','');
        
        
        //Dynamic Query to Get Source Applicants and clone it  
        List<LoanApplicant> sourceLoanApplicants = Database.query('select ' + strfieldApplicantName + ' from LoanApplicant ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicant> cloneLoanApplicant = sourceLoanApplicants.deepclone(false,true,false);
        
        //Modify cloned Applicants
        
        //   system.debug('cloneRlaID:' + cloneRLA.Id);
        for (LoanApplicant sourcelapplicant : sourceLoanApplicants){
            for (LoanApplicant lapplicant : cloneLoanApplicant){
                
                if(sourcelapplicant.Name == lapplicant.Name ){
                    
                    loanApplicant lapp = new LoanApplicant();
                    lapp = lapplicant;
                    
                    //field mapping for cloned applicant records
                    lapp.LoanApplicationId = cloneRLA.Id;
                    lapp.Source_Applicant_Id__c = sourcelapplicant.Id;
                    lapp.Id = null;
                    lapp.CJA_Mortgage__FilogixId__c = null;
                    
                    applicantsToInsert.add(lapp);    
                    
                }
            }
        }
        
        try{
            
            system.debug('applicantsToInsert::'+ applicantsToInsert[0].LoanApplicationId);
           
            If(applicantsToInsert.size() > 0){
                
                insert applicantsToInsert;
            }
            
            List<LoanApplicant> app = [Select id,Source_Applicant_Id__c from loanApplicant where LoanApplicationId =: cloneRLA.Id];
        	List<LoanApplicant> loanApplicantstoDel = New List<LoanApplicant>();
            
            for (loanapplicant lapp : app ){
                
                If(!String.IsBlank(lapp.Source_Applicant_Id__c)){
                    loanApplicantIdMap.put(lapp.Source_Applicant_Id__c,lapp.id);
                }

                else{
                    loanApplicantstoDel.add(lapp);
                    system.debug('loanApplicantstoDel::'+ loanApplicantstoDel);
                }
                
            }
            
            
            If(loanApplicantstoDel.size() > 0){
                delete loanApplicantstoDel;            
            }
        }    
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        
        /*
* Loan Applicants Addreses
*/ 
        
        //Get API field Names of  Loan Applicant Addresses
        string ApplicantAddressFields = getFieldAPINames('LoanApplicantAddress');
        string strfieldApplicantAddress = ApplicantAddressFields.substring(0, ApplicantAddressFields.length()-1);
        
        //Dynamic Query to Get Source Applicant addresses and clone it      
        List<LoanApplicantAddress> sourceLoanApplicantAddreses = Database.query('select ' + strfieldApplicantAddress + ' from LoanApplicantAddress ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicantAddress> cloneLoanApplicantAddreses = sourceLoanApplicantAddreses.deepclone(false,true,false);
        
        
        //Modify cloned Applicant addresses
        
        for(LoanApplicant applicants : applicantsToInsert){
            for (LoanApplicantAddress lapplicantaddress : cloneLoanApplicantAddreses){
                
                if(applicants.Source_Applicant_Id__c == lapplicantaddress.LoanApplicantId){
                    
                    //field mapping for cloned applicant address records
                    //Embed New Applicant Ids to New Applicant Address Records            
                    LoanApplicantAddress lappadd = new LoanApplicantAddress();
                    lappadd = lapplicantaddress;
                    lappadd.LoanApplicantId = applicants.Id;
                    lappadd.LoanApplicationId = cloneRLA.Id;
                    applicantsaddrToInsert.add(lappadd);    
                    
                }
                
            }
        }
        
        try{
            If(applicantsaddrToInsert.size() > 0){
                
                insert applicantsaddrToInsert;
            }
        }    
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        /*
* Loan Applicants Employment
*/ 
        
        //Get API field Names of  Loan Applicant Employment
        string ApplicantEmploymentFields = getFieldAPINames('LoanApplicantEmployment');
        string strfieldApplicantEmployment = ApplicantEmploymentFields.substring(0, ApplicantEmploymentFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Employment and clone it      
        List<LoanApplicantEmployment> sourceLoanApplicantEmployment = Database.query('select ' + strfieldApplicantEmployment + ' from LoanApplicantEmployment ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicantEmployment> cloneLoanApplicantEmployment = sourceLoanApplicantEmployment.deepclone(false,true,false);
        
        
        //Modify cloned Applicant Employment
        
        for(LoanApplicant applicants : applicantsToInsert){
            for (LoanApplicantEmployment lapplicantemployment : cloneLoanApplicantEmployment){
                
                if(applicants.Source_Applicant_Id__c == lapplicantemployment.LoanApplicantId){
                    
                    //field mapping for cloned applicant Employment records
                    //Embed New Applicant Ids to New Applicant Employment Records            
                    LoanApplicantEmployment lappemp = new LoanApplicantEmployment();
                    lappemp = lapplicantemployment;
                    lappemp.CJA_Mortgage__FilogixId__c = null;
                    lappemp.LoanApplicantId = applicants.Id;
                    lappemp.LoanApplicationId = cloneRLA.Id;
                    applicantEmploymentToInsert.add(lappemp);    
                    
                }
                
            }
        }
        
        try{
            
            If(applicantEmploymentToInsert.size() > 0){
                
                insert applicantEmploymentToInsert;
            }    
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        /*
* Loan Applicants Income
*/ 
        
        //Get API field Names of  Loan Applicant Employment
        string ApplicantIncomeFields = getFieldAPINames('LoanApplicantIncome');
        string strfieldApplicantIncome = ApplicantIncomeFields.substring(0, ApplicantIncomeFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Employment and clone it      
        List<LoanApplicantIncome> sourceLoanApplicantIncome = Database.query('select ' + strfieldApplicantIncome + ' from LoanApplicantIncome ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicantIncome> cloneLoanApplicantIncome = sourceLoanApplicantIncome.deepclone(false,true,false);
        
        
        //Modify cloned Applicant Employment
        
        for(LoanApplicant applicants : applicantsToInsert){
            for (LoanApplicantIncome lapplicantIncome : cloneLoanApplicantIncome){
                
                if(applicants.Source_Applicant_Id__c == lapplicantIncome.LoanApplicantId){
                    
                    //field mapping for cloned applicant Employment records
                    //Embed New Applicant Ids to New Applicant Employment Records            
                    LoanApplicantIncome lappincome = new LoanApplicantIncome();
                    lappincome = lapplicantIncome;
                    lappincome.CJA_Mortgage__FilogixId__c =  null;
                    lappincome.LoanApplicantId = applicants.Id;
                    lappincome.LoanApplicationId = cloneRLA.Id;
                    applicantIncometoInsert.add(lappincome);    
                    
                }
                
            }
        }
        
        try{
            
            If(applicantIncometoInsert.size() > 0){
                
                insert applicantIncometoInsert;
            }  
        }   
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
          /*
* Declarations
*/       
        //Get API field Names of  Loan Applicant Declaration
        string ApplicantDeclarationFields = getFieldAPINames('LoanApplicantDeclaration');
        string strfieldApplicantDeclaration = ApplicantDeclarationFields.substring(0, ApplicantDeclarationFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Declaration and clone it      
        List<LoanApplicantDeclaration> sourceLoanApplicantDeclaration = Database.query('select ' + strfieldApplicantDeclaration + ' from LoanApplicantDeclaration ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicantDeclaration> cloneLoanApplicantDeclaration  = sourceLoanApplicantDeclaration.deepclone(false,true,false);
        
        //Modify cloned Applicant Declaration
        
        for(LoanApplicant applicants : applicantsToInsert){
            for (LoanApplicantDeclaration lapplicantdec : cloneLoanApplicantDeclaration){
                
                if(applicants.Source_Applicant_Id__c == lapplicantdec.LoanApplicantId){
                    
                    //field mapping for cloned applicant Declaration records
                    //Embed New Applicant Ids to New Applicant Declaration Records            
                    LoanApplicantDeclaration lappdec = new LoanApplicantDeclaration();
                    lappdec = lapplicantdec;
                    lappdec.LoanApplicantId = applicants.Id;
                    lappdec.LoanApplicationId = cloneRLA.Id;
                    DeclarationsToInsert.add(lappdec);    
                    
                }
                
            }
        }
        
        try{
            
            If(DeclarationsToInsert.size() > 0){
                
                insert DeclarationsToInsert;
            } 
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        
              /*
* Declarations
*/  
        
        
        //Get API field Names of  Loan Application Assets
        string ApplicationAssetsFields = getFieldAPINames('LoanApplicationAsset');
        string strfieldApplicationAssets = ApplicationAssetsFields.substring(0, ApplicationAssetsFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Employment and clone it      
        List<LoanApplicationAsset> sourceLoanApplicationAssets = Database.query('select ' + strfieldApplicationAssets + ' from LoanApplicationAsset ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicationAsset> cloneLoanApplicationAssets = sourceLoanApplicationAssets.deepclone(false,true,false);
        
        
        //Modify cloned Applicant Employment
        
        for (LoanApplicationAsset lapplicationAsset : cloneLoanApplicationAssets){
            
            //field mapping for cloned applicant LoanApplicationAsset records
            LoanApplicationAsset lappAsset = new LoanApplicationAsset();
            lappAsset = lapplicationAsset;
            lappAsset.CJA_Mortgage__FilogixId__c = null;
            lappAsset.LoanApplicationId = cloneRLA.Id;
            applicationAssettoInsert.add(lappAsset);    
            
        }
        
        try{
            
            If(applicationAssettoInsert.size() > 0){
                
                insert applicationAssettoInsert;
            }   
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
                 /*
* Loan Application Liability
*/  
        
        
        //Get API field Names of  Loan Application Liability
        string ApplicationLiabilityFields = getFieldAPINames('LoanApplicationLiability');
        string strfieldApplicationLiability = ApplicationLiabilityFields.substring(0, ApplicationLiabilityFields.length()-1);
        
        //Dynamic Query to Get Source Application Liability and clone it      
        List<LoanApplicationLiability> sourceLoanApplicationLiability = Database.query('select ' + strfieldApplicationLiability + ' from LoanApplicationLiability ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicationLiability> cloneLoanApplicationLiability = sourceLoanApplicationLiability.deepclone(false,true,false);
        
        
        //Modify cloned Application Liability
        
        for (LoanApplicationLiability lapplicationLiability : cloneLoanApplicationLiability){
            
            //field mapping for cloned  LoanApplication recoLiabilityrds
            LoanApplicationLiability lappLiability = new LoanApplicationLiability();
            lappLiability = lapplicationLiability;
            lappLiability.CJA_Mortgage__FilogixId__c = null;
            lappLiability.LoanApplicationId = cloneRLA.Id;
            applicationLiabilityToInsert.add(lappLiability);    
            
        }
        
        try{
            
            If(applicationLiabilityToInsert.size() > 0){
                
                insert applicationLiabilityToInsert;
            }    
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
                   /*
* Down Payment Sources
*/    
        //Get API field Names DownPaymentSources
        string ApplicationDownPaymentSources = getFieldAPINames('CJA_Mortgage__Down_Payment_Source__c');
        string strfieldApplicationDownPaymentSources = ApplicationDownPaymentSources.substring(0, ApplicationDownPaymentSources.length()-1);
        
        //Dynamic Query to Get Source Application DownPaymentSources and clone it      
        List<CJA_Mortgage__Down_Payment_Source__c> sourceLoanApplicationDPSources = Database.query('select ' + strfieldApplicationDownPaymentSources + ' from CJA_Mortgage__Down_Payment_Source__c ' + ' where CJA_Mortgage__Application__c =: rlaID');
        List<CJA_Mortgage__Down_Payment_Source__c> cloneLoanApplicationDPSources = sourceLoanApplicationDPSources.deepclone(false,true,false);
        
        //Modify cloned Application DownPaymentSources
        
        for (CJA_Mortgage__Down_Payment_Source__c lapplicationDPSource : cloneLoanApplicationDPSources){
            
            //field mapping for cloned  LoanApplication recoLiabilityrds
            CJA_Mortgage__Down_Payment_Source__c lappDPSources = new CJA_Mortgage__Down_Payment_Source__c();
            lappDPSources = lapplicationDPSource;
            lappDPSources.CJA_Mortgage__FilogixId__c = null;
            lappDPSources.CJA_Mortgage__Application__c = cloneRLA.Id;
            DPSourcesToInsert.add(lappDPSources);    
            
        }
        
        try{
            If(DPSourcesToInsert.size() > 0){
                
                insert DPSourcesToInsert;
            }
        }    
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
        /*
* Loan Application Properties
*/ 
        //Get API field Names of Application Properties 
        string ApplicationPropertiesFields = getFieldAPINames('LoanApplicationProperty');
        string strfieldApplicationPropertyName = ApplicationPropertiesFields.substring(0, ApplicationPropertiesFields.length()-1);
        strfieldApplicantName.replace(',LoanApplicationId','');
        
        
        //Dynamic Query to Get Source Application Property and clone it  
        List<LoanApplicationProperty> sourceLoanApplicationProp = Database.query('select ' + strfieldApplicationPropertyName + ' from LoanApplicationProperty ' + ' where LoanApplicationId =: rlaID');
        List<LoanApplicationProperty> cloneLoanApplicationProp = sourceLoanApplicationProp.deepclone(false,true,false);
        
        //Modify cloned Application Property
        
        for (LoanApplicationProperty sourcelapplicationprop : sourceLoanApplicationProp){
            for (LoanApplicationProperty lapplicationprop : cloneLoanApplicationProp){
                
                if(sourcelapplicationprop.Name == lapplicationprop.Name ){
                    
                    LoanApplicationProperty lappprop = new LoanApplicationProperty();
                    lappprop = lapplicationprop;
                    
                    //field mapping for cloned application property records
                    lappprop.LoanApplicationId = cloneRLA.Id;
                    lappprop.Source_Property_Id__c = sourcelapplicationprop.Id;
                    lappprop.Id = null;
                    lappprop.CJA_Mortgage__FilogixId__c = null;
                    lappprop.CJA_Mortgage__Loan_Applicant__c = loanApplicantIdMap.get(sourcelapplicationprop.CJA_Mortgage__Loan_Applicant__c);

                    ApplicationPropToInsert.add(lappprop);    
                    
                }
            }
        }
        
        try{
            If(ApplicationPropToInsert.size() > 0){
                
                system.debug('applicationproptoInsert::'+ ApplicationPropToInsert[0].LoanApplicationId);
                insert ApplicationPropToInsert;
            }    
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }

          /*
* Mortgage
*/ 
        
        //Get API field Names of Mortgage
        string MortgageFields = getFieldAPINames('CJA_Mortgage__Mortgage__c');
        string strfieldMortgage = MortgageFields.substring(0, MortgageFields.length()-1);
        
        //Dynamic Query to Get Source Applicant Declaration and clone it      
        List<CJA_Mortgage__Mortgage__c> sourcePropMortgage = Database.query('select ' + strfieldMortgage + ' from CJA_Mortgage__Mortgage__c ' + ' where CJA_Mortgage__Loan_Application__c =: rlaID');
        List<CJA_Mortgage__Mortgage__c> clonePropMortgage  = sourcePropMortgage.deepclone(false,true,false);
        
        //Modify cloned Applicant Declaration
        
        for(LoanApplicationProperty property : ApplicationPropToInsert){
            
            for (CJA_Mortgage__Mortgage__c mortgagesource : sourcePropMortgage){
                for (CJA_Mortgage__Mortgage__c mortgage : clonePropMortgage){
                    
                    if(property.Source_Property_Id__c == mortgage.CJA_Mortgage__Loan_Application_Property__c){
                        
                        //field mapping for cloned applicant Declaration records
                        //Embed New Applicant Ids to New Applicant Declaration Records            
                        CJA_Mortgage__Mortgage__c propmortg = new CJA_Mortgage__Mortgage__c();
                        propmortg = mortgage;
                        propmortg.CJA_Mortgage__Loan_Application_Property__c = property.Id;
                        propmortg.CJA_Mortgage__Loan_Application__c = cloneRLA.Id;
                        propmortg.CJA_Mortgage__FilogixId__c = null;
                        
                        if(mortgagesource.Name == mortgage.Name ){
                            
                            propmortg.Source_Mortgage_ID__c = mortgagesource.Id;
                            
                        }
                        
                        MortgageToInsert.add(propmortg);    
                        
                    }
                }
            }
        }
        
        try{
            
            If(MortgageToInsert.size() > 0){ 
                insert MortgageToInsert;
            }    
            
        }
        
        catch(exception e){
            
            system.debug('exception:' + e.getMessage());
        }
        
                  /*
* Application Fees
*/ 
        
        //Get API field Names of Application Fees
        string ApplicationFeesFields = getFieldAPINames('CJA_Mortgage__Application_Fee__c');
        string strfieldAppFees = ApplicationFeesFields.substring(0, ApplicationFeesFields.length()-1);
        
        //Dynamic Query to Get Source Application Fees and clone it      
        List<CJA_Mortgage__Application_Fee__c> sourceAppFees = Database.query('select ' + strfieldAppFees + ' from CJA_Mortgage__Application_Fee__c ' + ' where CJA_Mortgage__Application__c =: rlaID');
        List<CJA_Mortgage__Application_Fee__c> cloneAppFees  = sourceAppFees.deepclone(false,true,false);
        
        //Modify cloned Application Fees
        
        for(CJA_Mortgage__Mortgage__c mortgage : MortgageToInsert){
            for (CJA_Mortgage__Application_Fee__c applicationfee : cloneAppFees){
                
                if(mortgage.Source_Mortgage_Id__c == applicationfee.CJA_Mortgage__Mortgage__c){
                    
                    //field mapping for cloned Application Fee records
                    //Embed New Property Ids to New Application Fee Records            
                    CJA_Mortgage__Application_Fee__c appfee = new CJA_Mortgage__Application_Fee__c();
                    appfee = applicationfee;
                    appfee.CJA_Mortgage__FilogixId__c = null;
                    appfee.CJA_Mortgage__Mortgage__c = mortgage.Id;
                    appfee.CJA_Mortgage__Application__c = cloneRLA.Id;
                    AppFeetoInsert.add(appfee);    
                    
                }
                
            }
        }
        
        try{
            If(AppFeetoInsert.size() > 0){ 
                
                insert AppFeetoInsert;
            } 
        }
        
        catch(exception e){
            
            system.debug('exception at application fees:' + e.getMessage());
        }
  
                      /*
* Property Expense
*/ 
        
       /* //Get API field Names of PropertyExpense
        string PropExpFields = getFieldAPINames('PropertyExpense__c');
        string strfieldPropExp = PropExpFields.substring(0, PropExpFields.length()-1);
        
        //Dynamic Query to Get Source PropertyExpenses and clone it      
        List<PropertyExpense__c> sourcePropExp = Database.query('select ' + strfieldPropExp + ' from PropertyExpense__c ' + ' where Loan_Application__c =: rlaID');
        List<PropertyExpense__c> clonePropExp  = sourcePropExp.deepclone(false,true,false);
        
        //Modify cloned PropertyExpense
        
        for(LoanApplicationProperty property : ApplicationPropToInsert){
            for (PropertyExpense__c propexpense : clonePropExp){
                
                if(property.Source_Property_Id__c == propexpense.Loan_Application_Property__c && propexpense.Loan_Application_Property__c != null){
                    
                    //field mapping for cloned PropertyExpense records
                    //Embed New Property Ids to New PropertyExpense Records            
                    PropertyExpense__c pexp = new PropertyExpense__c();
                    pexp = propexpense;
                    pexp.CJA_Mortgage__FilogixId__c = null;
                    pexp.Loan_Application_Property__c = property.Id;
                    pexp.Loan_Application__c = cloneRLA.Id;
                    PropExpToInsert.add(pexp);    
                    
                }
                
                else{
                    
                    PropertyExpense__c pexp = new PropertyExpense__c();
                    pexp = propexpense;
                    pexp.CJA_Mortgage__FilogixId__c = null;
                    pexp.Loan_Application__c = cloneRLA.Id;
                    PropExpToInsert.add(pexp);    
                    
                }
            }
        }
        
        try {
            If(PropExpToInsert.size() > 0){ 
                
                insert PropExpToInsert;
            }    
        }
        
        catch(exception e){
            
            system.debug('exception at property exp:' + e.getMessage());
        }*/
        
        return cloneRla.id;
    }
    
    //This will return commaseperated api names of object fields
    public static string commaSeperatedAPINames(List<String> apiNamesList){
        
        List<String> tempList = apiNamesList;
        
        String commaSepratedList='';
        
        for(String str : tempList)
            
        {    
            commaSepratedList += str + ',' ;
            
        }
        
        commaSepratedList = commaSepratedList.subString(0,commaSepratedList.length());
        return commaSepratedList;
        
    }
    
    public static string  getFieldAPINames (string objectName){
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        
        List<String> fieldPINames = New List<String>();
        string commaseperatedfields;
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldPINames.add(dfield.getName());
        }
        
        commaseperatedfields = DeepCloneRLA.commaSeperatedAPINames(fieldPINames);
        return commaseperatedfields;
    }
    
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){

                //if (!sObj.contains('__')) to exclude managed package objects

                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
               // System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                  //  System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
    
    public class Requests {
        
        @InvocableVariable(required=true)
        public List<String> inputCollection;
    }    
    
    public class Results {     
        
        @InvocableVariable
        public Id outputId;
    }
    
    
}