/***********************************************************
* Date: 2019-July-31
* Developer: Linda Nguyen
* Description: Installed fieldSetForm Package
*
* --CHANGE LOG--
* DATE                DEVELOPER        CHANGE
* 2019-July-31        Linda Nguyen     Tweaked for Insider
************************************************************/
public class FieldSetMember {
    
    public FieldSetMember(Schema.FieldSetMember f, String val, Boolean renderField) {
        this.DBRequired = f.DBRequired;
        this.fieldPath = f.fieldPath;
        this.label = f.label;
        this.required = f.required;
        this.type = '' + f.getType();
        this.val = val;
        this.renderField = renderField;
    }
    
    public FieldSetMember(Boolean DBRequired) {
        this.DBRequired = DBRequired;
    }
    
    @AuraEnabled
    public Boolean DBRequired { get;set; }
    
    @AuraEnabled
    public String fieldPath { get;set; }
    
    @AuraEnabled
    public String label { get;set; }
    
    @AuraEnabled
    public Boolean required { get;set; }
    
    @AuraEnabled
    public String type { get; set; }
    
    @AuraEnabled
    public String val { get; set; }
    
    @AuraEnabled
    public Boolean renderField { get; set; }
}