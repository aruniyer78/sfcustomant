public with sharing class FleerCorverList{
    //table 1 items
    public String contractNo{get;set;}
    public String paymentMethos{get;set;}
    public String fleetCode{get;set;}
    public String subfleetCode{get;set;}
    public String ext{get;set;}
    public boolean fpHP{get;set;}
    public boolean fpOL{get;set;}
    public boolean fpAL{get;set;}
    public boolean fpFL{get;set;}
    public boolean FeetypeFinanced{get;set;}
    public boolean FeetypePaid{get;set;}
    public boolean FeetypeWaived{get;set;}
    public boolean FeetypeNa{get;set;}
    public boolean pmADV{get;set;}
    public boolean pmARR{get;set;}
        
    //table2 items
    public boolean q1_1{get;set;}
    public boolean q1_2{get;set;}
    public String q2{get;set;}
    public String q3{get;set;}
    public boolean q4_1{get;set;}
    public boolean q4_2{get;set;}
    public boolean q5_1{get;set;}
    public boolean q5_2{get;set;}
    public boolean q6_1{get;set;}
    public boolean q6_2{get;set;}
    public boolean q7_1{get;set;}
    public boolean q7_2{get;set;}
    public String q8_1{get;set;}
    public String q8_2{get;set;}
    public boolean q9{get;set;}
    public String q11_1{get;set;}
    public boolean q11_2{get;set;}    
    public boolean q12_1{get;set;}
    public boolean q12_2{get;set;}
    public boolean q13{get;set;}    
    public boolean q14_1{get;set;}
    public boolean q14_2{get;set;}
    public boolean q15{get;set;}
    public boolean q10{get;set;}

    
   // private static final string WORD_CONTENT_TYPE='application/msword';
    
    private Lead_Account__c leadc;
    public String contentType {get;set;}
    
    public FleerCorverList(ApexPages.StandardController stdController) {

        this.leadc = (Lead_Account__c)stdController.getRecord();
        Leadc = [Select l.Vehicle_Model_Interest__c,  
                       l.RORAC__c, 
                       l.RV_Balloon_Amount__c, 
                       l.Payment_Type__c, 
                       l.OwnerId, 
                       l.Orig_Fee__c, 
                       l.Id, 
                       l.Finance_Amount__c, 
                       l.Financial_Product__c,
                       l.Financial_Product2__c,
                       l.Fee_Type__c, 
                       l.Doc_Fee__c, 
                       l.Dealer_Commission__c, 
                       l.Customer_Name__c, 
                       l.Contract_Rate__c,  
                       l.Close_Date__c, 
                       l.Base_Rate__c, 
                       l.Assigned_Dealer__r.Name 
                From Lead_Account__c l where id=:leadc.id][0];

        Set<String> financeProductBase = new Set<String>{'Operating Lease','Fully Maintained Operating Lease'};

        if(getUrlParam('isDownload')=='true'){
            //table 1 itmes setting
            contractNo = getUrlParam('contractNo');
            paymentMethos = getUrlParam('paymentMethos');
            fleetCode = getUrlParam('fleetCode');
            subfleetCode = getUrlParam('subfleetCode');
            ext = getUrlParam('ext');

            //table 2 items
            q1_1 = getUrlBooleanParam('q1_1');
            q1_2 = getUrlBooleanParam('q1_2');
            q2 = getUrlParam('q2');
            q3 = getUrlParam('q3');
            q4_1 = getUrlBooleanParam('q4_1');
            q4_2 = getUrlBooleanParam('q4_2');
            q5_1 = getUrlBooleanParam('q5_1');
            q5_2 = getUrlBooleanParam('q5_2');
            q6_1 = getUrlBooleanParam('q6_1');
            q6_2 = getUrlBooleanParam('q6_2');
            q7_1 = getUrlBooleanParam('q7_1');
            q7_2 = getUrlBooleanParam('q7_2');
            q8_1 = getUrlParam('q8_1');
            q8_2 = getUrlParam('q8_2');
            q11_1 = getUrlParam('q11_1');
            q11_2 = getUrlBooleanParam('q11_2');
            q12_1 = getUrlBooleanParam('q12_1');
            q12_2 = getUrlBooleanParam('q12_2');
            q13 = getUrlBooleanParam('q13');
            q14_1 = getUrlBooleanParam('q14_1');
            q14_2 = getUrlBooleanParam('q14_2');
            q15 = getUrlBooleanParam('q15');
            q9 = getUrlBooleanParam('q9');
            q10 = getUrlBooleanParam('q10');
            fpHP = getUrlBooleanParam('fpHP');
            fpFL = getUrlBooleanParam('fpFL');
            fpOL = getUrlBooleanParam('fpOL');
            fpAL = getUrlBooleanParam('fpAL');
            FeetypeFinanced = getUrlBooleanParam('FeetypeFinanced');
            FeetypePaid = getUrlBooleanParam('FeetypePaid');
            FeetypeWaived = getUrlBooleanParam('FeetypeWaived');
            FeetypeNa = getUrlBooleanParam('FeetypeNa');
            pmADV = getUrlBooleanParam('pmADV');
            pmARR = getUrlBooleanParam('pmARR');
        }else{
            q2 = 'N/A';
            q8_1 = 'N/A';
            q11_1 = 'N/A';
            //FINANCE PRODUCT Checkbox
            if(leadc.Financial_Product2__c == 'Hire Purchase'){
                fpHP = true;
            }
            if(leadc.Financial_Product2__c == 'Finance Lease'){
                fpFL = true;
            }
            if(leadc.Financial_Product2__c == 'Operating Lease'){
                fpOL = true;
            }
            if(leadc.Financial_Product2__c == 'Asset Loan'){
                fpAL = true;
            }
            //FEES Checkbox
            if(leadc.Fee_Type__c == 'Financed'){
                FeetypeFinanced = true;
            }
            if(leadc.Fee_Type__c == 'Paid'){
                FeetypePaid = true;
            }
            if(leadc.Fee_Type__c == 'Waived'){
                FeetypeWaived = true;
            }
            if(leadc.Fee_Type__c == ''){
                FeetypeNa = true;
            }
            //PAYMENT MODE:
            if(leadc.Payment_Type__c == 'Advance'){
                pmADV = true;
            }
            if(leadc.Payment_Type__c == 'Arrears'){
                pmARR = true;
            }
        }
    }
    
    public PageReference generateDoc(){
 //       contentType = WORD_CONTENT_TYPE;
        PageReference newpage = Page.Fleet_checklist_output;
        newpage = setItemValue(newpage);
        newpage.setRedirect(true);
        return newpage;
    }

    public PageReference setItemValue(PageReference p){
        p.getParameters().put('id',leadc.id); 
        p.getParameters().put('isDownload','true'); 

        //table 1 items
        p.getParameters().put('fpHP',String.valueOf(this.fpHP));        
        p.getParameters().put('fpFL',String.valueOf(this.fpFL));
        p.getParameters().put('fpOL',String.valueOf(fpOL));
        p.getParameters().put('fpAL',String.valueOf(fpAL));
        p.getParameters().put('FeetypePaid',String.valueOf(FeetypePaid));
        p.getParameters().put('FeetypeFinanced',String.valueOf(FeetypeFinanced));
        p.getParameters().put('FeetypeWaived',String.valueOf(FeetypeWaived));
        p.getParameters().put('FeetypeNa',String.valueOf(FeetypeNa));
        p.getParameters().put('pmADV',String.valueOf(pmADV));
        p.getParameters().put('pmARR',String.valueOf(pmARR));
        p.getParameters().put('paymentMethos',this.paymentMethos);        
        p.getParameters().put('contractNo',this.contractNo);
        p.getParameters().put('fleetCode',fleetCode);
        p.getParameters().put('subfleetCode',subfleetCode);
        p.getParameters().put('ext',ext);

        //table 2 items
        p.getParameters().put('q1_1',String.valueOf(q1_1));
        p.getParameters().put('q1_2',String.valueOf(q1_2));
        p.getParameters().put('q2',q2);
        p.getParameters().put('q3',q3);
        p.getParameters().put('q4_1',String.valueOf(q4_1));
        p.getParameters().put('q4_2',String.valueOf(q4_2));
        p.getParameters().put('q5_1',String.valueOf(q5_1));
        p.getParameters().put('q5_2',String.valueOf(q5_2));
        p.getParameters().put('q6_1',String.valueOf(q6_1));
        p.getParameters().put('q6_2',String.valueOf(q6_2));
        p.getParameters().put('q7_1',String.valueOf(q7_1));
        p.getParameters().put('q7_2',String.valueOf(q7_2));
        p.getParameters().put('q8_1',q8_1);
        p.getParameters().put('q8_2',q8_2);
        p.getParameters().put('q11_1',q11_1);
        p.getParameters().put('q11_2',String.valueOf(q11_2));
        p.getParameters().put('q12_1',String.valueOf(q12_1));
        p.getParameters().put('q12_2',String.valueOf(q12_2));
        p.getParameters().put('q13',String.valueOf(q13));
        p.getParameters().put('q14_1',String.valueOf(q14_1));
        p.getParameters().put('q14_2',String.valueOf(q14_2));
        p.getParameters().put('q15',String.valueOf(q15));
        p.getParameters().put('q9',String.valueOf(q9));
        p.getParameters().put('q10',String.valueOf(q10));

        
        return p;
    }
    
    private String getUrlParam(String key){
        return ApexPages.currentPage().getParameters().get(key);
    }
    
    private boolean getUrlBooleanParam(String key){
        return getUrlParam(key)=='true'?true:false;
    }
    
    private String getfieldStr(String str){
        system.debug(str);
        return str==null?'':str;
    }

    public static String currency(String i) {
        String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
        return s.substring(0,s.length()-1);
    }

    public List<SelectOption> items;
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes',' Yes '));
        options.add(new SelectOption('N/A',' N/A '));
        return options;
    }

}