/**
 * @description       : 
 * @author            : Ahad Faroque
 * @group             : 
 * @last modified on  : 10-04-2022
 * @last modified by  : M Hamza Siddiqui @ mhamzas.com
**/
@isTest
private without sharing class DeepCloneRLA_Test {

    @isTest
    public static void deepCLoneRLA_Testmethod(){
        
        
        /* Data Bank Start */
        set<string> setOfOppIds = new set<string>();
        Account acc = New Account();
        acc.FirstName = 'Test First Name';
        acc.LastName = 'Test Last Name';
        acc.PersonMailingCity = 'Toronto';
        acc.PersonMailingState = 'Ontario';
        acc.PersonMailingCountry = 'CANADA';
        acc.PersonMailingPostalCode = 'ON 3131 31';
     
        //acc.Street_Direction__c = 'Test Street Description';
        //acc.PersonMailingStreet = 'Street 1';
        // acc.Street_Number__c = 'STN 213';
        //acc.Street_Type__c = 'Camp';
        //acc.Unit_Number__c = 'STU 212';
        
        insert acc;
        
        system.debug('acc ID =>' + acc.Id);
    
        
        Opportunity opp = New Opportunity ();
        
        opp.Name = 'New Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Need Analysis';
        opp.CloseDate = date.today();
        // opp.Deal_Type__c  = 'Approval';
        // opp.Estimated_Close_Date__c = date.today();
        // opp.Financing_Waiver_Date__c = date.today();
        // opp.Ref_Improvement_Amount__c = 25000;
        // opp.Ref_Improvement_Description__c = 'Test Ref Description';
        // opp.Ref_Improvements_Flag__c = True;
        // opp.Ref_Purpose__c = 'Test Ref Purpose';
        // opp.Source_Application_ID__c = 'Source Application Id';
        // opp.Tax_Pay_Or__c = 'Borrower';
        // opp.Third_Party_Application_Flag__c = true;
        // opp.JSON__c = 'Opportunity JSON';
        opp.Amount = 55000;
        opp.Description = 'Test Opportunity Description';
        // opp.Down_Payment_Source_Type__c = 'Existing Equity';            
        
        insert opp;
        system.debug('opp ID =>' + opp.Id);
 
     /*      ResidentialLoanApplication Secrla =  New ResidentialLoanApplication();
        Secrla.FilogixId__c = 'CLJT-2';
        Secrla.Name = 'Test RLA 2';
        Secrla.AccountId = acc.Id;
        Secrla.OpportunityId = opp.id;
        
        insert Secrla;

         LoanApplicationProperty lap = New LoanApplicationProperty();
        
        lap.LoanApplicationId    = rla.id;
    
        lap.PropertyValue = 75000;
        lap.ExpNetMonthlyRentalInc = 90000;
      
        lap.RequestedLoanAmount = 45000;
   //     lap.PropertyExtIdentifier = 'PropertyExtIdentifier Test External ID';
        lap.LoanPurposeType = 'Purchase';

        lap.IsManufacturedHome = true;

        lap.IsMixedUseProperty = false;
        lap.Name = 'Test Loan Application Property';
      
        lap.PropertyUseType = 'Owner Occupied and Rental';
        //    lap.CJA_Mortgage__PropertyAddress,
  
        lap.UnitsFinancedCount =  3;
        lap.PropertyStreet = 'Test Property Street';
        lap.PropertyCity = 'Toronto';
   
        lap.PropertyPostalCode = 'CW 213 313';
        lap.PropertyCountry = 'CA';
        lap.PropertyState = 'Ontario';
        lap.ExpMonthlyRentalIncome = 33000;
    
            
        insert lap;    
        
        Down_Payment_Source__c dps = New Down_Payment_Source__c();
        
        dps.Amount__c = 54000;
        dps.Description__c = 'Down Payment Source Description';
   //     dps.CJA_Mortgage__Source_Type__c = 'RRSP';
        dps.Application__c = Secrla.id;
        
        insert dps;
        system.debug('dps ID =>' + dps.Id);
      
      */
        ResidentialLoanApplication rla =  New ResidentialLoanApplication();
        
        rla.Name = 'Test RLA';
        rla.AccountId = acc.Id;
        rla.OpportunityId = opp.id;
   
        rla.InitialBuydownRate = 250000;
        rla.InterestRate = 14;
        rla.AmortizationType = 'Fixed Rate';
    
   //     rla.CJA_Mortgage__Premium__c = 25000;
        rla.IsInterestOnly = false;
        rla.IntOnlyTermMonthCount = 24;
     
        // rla.Cash_Back_Override__c = true;
        // rla.Cash_Back_Percentage__c = 15;
        // rla.Commercial__c = true;
        // rla.Current_Mortgage_Number__c = 2;
        // rla.Existing_Mortgage__c = true;
        // rla.Existing_Mortgage_Holder__c = 'Test';
        // rla.Heloc__c = true;
        // rla.Is_Insured__c = true;
        // rla.Insurance_Adjustment_Date__c = date.TODAY().addMonths(3);
    
   
   
        // rla.Balance_Remaining__c = 5200;

        insert rla;
        setOfOppIds.add(rla.OpportunityId);
        
        system.debug('rla ID =>' + rla.Id);
        
        
        LoanApplicant lapplicant = New LoanApplicant ();
        
        lapplicant.LoanApplicationId = rla.Id;
        lapplicant.ContactId = acc.PersonContactId;
        lapplicant.ApplicantExtIdentifier = 'test-la-1';
        lapplicant.PreferredLanguage = 'English';
        lapplicant.MaritalStatus = 'Married';
        lapplicant.Name = 'Test Applicant 1';
        lapplicant.DependentCount = 4;
        //lapplicant.Preferred_Contact_Method__c = 'Email';
        //lapplicant.Primary_Applicant__c = false;
        //lapplicant.Social_Insurance_Number__c = '4313242';
        //lapplicant.Relationship_To_Primary_Applicant__c = 'Spouse';
        //lapplicant.Existing_Client__c = true;
        //lapplicant.First_Time_Buyer__c = true;
        //lapplicant.Identification_Country__c = 'CA';
        //lapplicant.Identification_Number__c = 'LA1234';
        //lapplicant.Identification_Type__c = 'Country';
        
        insert lapplicant;
        
        LoanApplicantAddress lappAddress = New LoanApplicantAddress();
        
        lappAddress.Name = 'Test Loan Applicant Address';
        lappAddress.LoanApplicationId = rla.id;
        lappAddress.LoanApplicantId = lapplicant.id;
        lappAddress.ResidenceCity = 'Toronto';
        lappAddress.ResidenceState = 'Ontario';
        lappAddress.ResidenceCountry = 'CANADA';
        lappAddress.ResidencePostalCode = 'ON 313 313';
      
        //lappAddress.Street_Direction__c = 'NW';
 
        lappAddress.ResidenceYearCount = 4;
        lappAddress.AddressOwnership = 'Own';
        //lappAddress.Street_Type__c = 'Bypass'; 
        //lappAddress.Unit_Number__c = '45'; 
        lappAddress.MonthlyRentPayment = 55000;
        
        insert lappAddress;

        LoanApplicationAsset loanAppAsset = New LoanApplicationAsset();
        
        loanAppAsset.Name = 'Test Loan Application Asset';
        loanAppAsset.LoanApplicationId = rla.id;
        
        insert loanAppAsset;
        
        LoanApplicantAsset lapasset = New LoanApplicantAsset();
        
        lapasset.LoanApplicantId = lapplicant.Id;
        lapasset.LoanApplicationAssetId = loanAppAsset.Id;
  
        insert lapasset;
        
        LoanApplicantIncome lapIncome = New LoanApplicantIncome();
        lapIncome.Name = 'Test Loan Applicant Income';
        lapIncome.LoanApplicantId = lapplicant.Id;
        //lapIncome.Description__c = 'Loan Applicant Income Description';
        lapIncome.IncomeSourceType = 'Mortgage Differential Payments';
        lapIncome.MonthlyIncomeAmount  = 200000;
        //lapIncome.Income_Period__c = 'Semi Annual';
        lapIncome.LoanApplicationId = rla.id;
        lapIncome.IncomeExtIdentifier = 'Income External Id';
            
        insert lapIncome;
        
        
        LoanApplicantEmployment lappEmp = New  LoanApplicantEmployment();
        
        lappEmp.loanapplicantId = lapplicant.id;
        lappEmp.LoanApplicationId   = rla.id;
        lappEmp.JobTitle = 'CEO';
        lappEmp.EmployerName = 'Test Filogix';
        //lappEmp.History_Status__c = 'Previous';
        //lappEmp.History_Type__c = 'Part Time';
        lappEmp.MonthlyIncome = 150000;
        //lappEmp.Industry_Sector__c = 'Leisure Entertainment';
        //lappEmp.Company_Type__c = 'Enterprise';
        lappEmp.IsSelfEmployed = False;
        //lappEmp.Income_Frequency__c = 'Monthly';
        //lappEmp.Occupation__c = 'Management';
        lappEmp.Name = 'Test Loan Applicant Employment';
        //lappEmp.Income_Description__c = 'Loan Applicant Income Description';
        //lappEmp.Type__c = 'Other Employment Income';
        lappEmp.CurrentJobAdditionalMonthCount = 2;
        lappEmp.EmployerStreet = 'Richardson Street';
        lappEmp.EmployerCity = 'Toronto';
        lappEmp.EmployerPostalCode = 'TW 323 213';
        lappEmp.EmployerCountry = 'CANADA';
        lappEmp.EmployerState = 'Ontario'; 
        lappEmp.EmployerPhone = '555 444 331 1';
        
        insert lappEmp;
        
        LoanApplicationLiability lappLiability = New LoanApplicationLiability();
        
        lappLiability.Name = 'Test Loan Application Liability';
        lappLiability.CreditLimitAmount = 70000;
        //lappLiability.Liability_Description__c = 'Test Loan Application Liability Description';
        lappLiability.MonthlyPaymentAmount = 3500;
    //    lappLiability.Liability_PayOff_Type__c = 'Test Payoff Type';
        lappLiability.OtherLiabilityType = 'Credit Card';
        //lappLiability.Maturity_Date__c = date.today().addMonths(4);
        //lappLiability.Monthly_Payment_Override__c = true; 
        //lappLiability.Liability_Amount__c = 35000;
        lappLiability.LoanApplicationId = rla.Id;
        
        insert lappLiability;
        
        LoanApplicantLiability loanapplicantLiability = New LoanApplicantLiability();
        
        loanapplicantLiability.LoanApplicantId = lapplicant.id;
        loanapplicantLiability.LoanApplicationLiabilityId = lappLiability.id;
       
        insert loanapplicantLiability;
        
        LoanApplicationProperty loanApplicationProp = New LoanApplicationProperty();

        loanApplicationProp.Name = 'Loan Application Property';
        //loanApplicationProp.Appraised_Value__c = 200000;
        loanApplicationProp.LoanApplicationId = rla.id;
        //loanApplicationProp.Appraisal_Date__c = date.today().addMonths(7);
        //loanApplicationProp.Style__c = 'Storey and a Half';
        loanApplicationProp.PropertyValue = 180000;
        loanApplicationProp.ExpNetMonthlyRentalInc = 7000;
        //loanApplicationProp.feesIncludeHeat__c  = true;
        //loanApplicationProp.Garage_Size__c = 'Double';
        //loanApplicationProp.Garage_Type__c = 'Attached';
        //loanApplicationProp.Heat__c = 'Forced Air Gas Oil Electric';
    
        //loanApplicationProp.legalLine1__c = 'Test Legal Line 1';
        //loanApplicationProp.legalLine2__c = 'Test Legal Line 2';
        //loanApplicationProp.legalLine3__c = 'Test Legal Line 3';
        //loanApplicationProp.livingSpace__c = 23;
        //loanApplicationProp.livingSpaceUnitOfMeasurDd__c = 'Sq Ft';
        loanApplicationProp.RequestedLoanAmount = 190000;
        loanApplicationProp.PropertyExtIdentifier = 'Test External Id';
        loanApplicationProp.LoanPurposeType = 'Purchase';
        //loanApplicationProp.lotSize__c = 2300;
        //loanApplicationProp.lotSizeUnitOfMeasure__c = 'Hectares';
        loanApplicationProp.IsManufacturedHome = True;
        loanApplicationProp.IsMixedUseProperty = True;
        //loanApplicationProp.Construction_Type__c = 'Existing';
        //loanApplicationProp.numberOfUnits__c = 24;
        loanApplicationProp.PropertyUseType = 'Owner Occupied';
        //loanApplicationProp.Property_Type__c = 'condo';
        //loanApplicationProp.purchasePrice__c = 60000;
        //loanApplicationProp.realtorInfo__c = 'Test Realtor Info';
        //loanApplicationProp.rentalOffsetOption__c = 'Add Percentage to Gross Income';
        //loanApplicationProp.Sewage_Type__c = 'Municipal';
        //loanApplicationProp.structureAge__c = 45;
        //loanApplicationProp.taxationYear__c = 2020;
        loanApplicationProp.UnitsFinancedCount = 20;
        //loanApplicationProp.Water_Type__c = 'Municipal';
        loanApplicationProp.PropertyStreet = 'Loan Application Property Street';
        loanApplicationProp.PropertyCity = 'Loan Application Property City';
        //loanApplicationProp.PropertyStreetNumber__c = '4';
        //loanApplicationProp.PropertyUnitNumber__c = '31';
        loanApplicationProp.PropertyPostalCode = 'ON 13 131';
        loanApplicationProp.PropertyCountry = 'CANADA';
        loanApplicationProp.PropertyState = 'ONTARIO'; 
        //loanApplicationProp.Direction__c = 'NW';
        loanApplicationProp.ExpMonthlyRentalIncome = 5000;
        //loanApplicationProp.Rental_Income_Options__c = 'Semi Annual';
        loanApplicationProp.CJA_Mortgage__Rental_Income_Type__c = 'Other Employment Income';
        loanApplicationProp.CJA_Mortgage__Rental_IncPercentInTds__c = 25;
        loanApplicationProp.CJA_Mortgage__Structure_Type__c = 'Modular Home Semi Detached'; 
        loanApplicationProp.CJA_Mortgage__Street_Type__c = 'Boulevard';
        loanApplicationProp.CJA_Mortgage__Original_Purchase_Price__c = 40000; 
        loanApplicationProp.CJA_Mortgage__Purchase_Date__c = date.today().addmonths(6);
    
        
        insert loanApplicationProp;
        
        /*
        PropertyExpense__c propExp = New CJA_Mortgage__PropertyExpense__c();
        
        propExp.CJA_Mortgage__propertyExpenseAmount__c = 25000;
        propExp.CJA_Mortgage__Loan_Application__c = rla.Id;
        propExp.CJA_Mortgage__Loan_Application_Property__c = loanApplicationProp.id; 
        
        insert propExp;
        
        PropertyExpense__c propExp2 = New PropertyExpense__c();
        
        propExp2.propertyExpenseAmount__c = 1000;
        propExp2.Loan_Application__c = rla.Id;
        
        insert propExp2;
        */
        CJA_Mortgage__Down_Payment_Source__c dp = new CJA_Mortgage__Down_Payment_Source__c();
        
        dp.Name = 'dp source';
        dp.CJA_Mortgage__Application__c = rla.id;
        insert dp;
        
        LoanApplicantDeclaration dec = New LoanApplicantDeclaration();
        
        dec.Name = 'Loan applicant declaration';
        dec.HasDeclaredBankruptcy = true;
        dec.LoanApplicationId = rla.id;
        dec.LoanApplicantId = lapplicant.Id;
        
        
        insert dec;
        
        CJA_Mortgage__Mortgage__c mortgage = New CJA_Mortgage__Mortgage__c();
        
        mortgage.Name = 'First Mortgage';
        mortgage.CJA_Mortgage__Loan_Application__c = rla.id;
        mortgage.CJA_Mortgage__Loan_Application_Property__c = loanApplicationProp.id; 
        
        insert mortgage;
        
        CJA_Mortgage__Application_Fee__c appfee = New CJA_Mortgage__Application_Fee__c();
        
        appfee.CJA_Mortgage__Application__c = rla.Id;
        appfee.CJA_Mortgage__Amount__c = 200;
        appfee.CJA_Mortgage__Mortgage__c = mortgage.Id;
        
        insert appfee;
        
        //Test when Cloning executed for RLA only
        //To strore RLA Ids
        List<String> RLAIdsList = New List <String>();
        
        RLAIdsList.add(rla.Id);
        
        //Calling and add and Invocable variable
        DeepCloneRLA.Requests  req = New DeepCloneRla.Requests();
        req.inputCollection = RLAIdsList;
        
        //Adding element in Invocable variable list
        List<DeepCloneRLA.Requests> RequestListRLA = New List<DeepCloneRLA.Requests>();
        RequestListRLA.add(req);
        
        //Test when Cloning executed for RLA only
        //To strore Opp Ids
        List<String> OppIdsList = New List <String>();
        
        //Calling and add and Invocable variable
        OppIdsList.add(rla.OpportunityId);
        DeepCloneRLA.Requests  reqopp = New DeepCloneRla.Requests();
        reqopp.inputCollection = OppIdsList;
        
        //Adding element in Invocable variable list
        List<DeepCloneRLA.Requests> RequestListOpp = New List<DeepCloneRLA.Requests>();
        RequestListOpp.add(reqopp);
        
   
        DeepCloneRLA.InvokeCloningFunction(RequestListRLA);
        DeepCloneRLA.InvokeCloningFunction(RequestListOpp);


    }
    
}