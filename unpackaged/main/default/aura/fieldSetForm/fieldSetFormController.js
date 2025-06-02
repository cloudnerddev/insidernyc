({
    doInit : function(component, event, helper) {
        console.log('doInit');

        if(component.get('v.mode')=='Edit') {
            component.set('v.inputModeBool', true);
        }
        
        if(component.get('v.buttonOverlay')=='Yes') {
            component.set('v.inputButtonOverlayBool', true);
            if(component.get('v.reasonAuditField')!=null) {
                component.set('v.inputReasonBool', true);
            }
        }else{
            $A.enqueueAction(component.get('c.queryData'));
        }
        
        /* REFRESHES CAUSE LABEL TO DISAPPEAR
        component.set("v.label", $A.get(labell));
        
        console.log('label: ' + component.get("v.label"));
        console.log('title: ' + component.get("v.title"));
		*/
    },
    fireRefreshView : function(component, event, helper) {
        console.log('fireRefreshView');

        $A.get('e.force:refreshView').fire();
    },
    handleToggle : function(component, event, helper) {        
        console.log('handleToggle');

        var inputModeBool = component.get("v.inputModeBool");
        component.set("v.inputModeBool", !inputModeBool);
    },
    
    overlayToggle : function(component, event, helper) {  
        console.log('overlayToggle');
        
        var proceed = false;
        
        if(component.get('v.reasonAuditField')!=null) {
            var inputReason = component.find("inputReason");
            if(inputReason.get("v.value")==null) {
                alert('Reason required!');
            } else {
                proceed = true;
            }
        } else {
            proceed = true
        }
        
        if(proceed==true) {
            var inputButtonOverlayBool = component.get("v.inputButtonOverlayBool");
            component.set("v.inputButtonOverlayBool", false);
            component.set("v.view", false);
            $A.enqueueAction(component.get('c.queryData'));
            
            if(component.get('v.buttonOverlay')=='Yes' && component.get('v.buttonOverlayAuditField')!=null) { 
                var action = component.get("c.updateAuditField"); 
                action.setParams({
                    typeName: component.get("v.objectApiName"), 
                    auditField: component.get("v.buttonOverlayAuditField"), 
                    recId: component.get('v.recordId')});
                $A.enqueueAction(action);
                console.log('buttonOverlayAuditField: ' + component.get("v.buttonOverlayAuditField"));
            };
            
            if(component.get('v.buttonOverlay')=='Yes' && component.get('v.reasonAuditField')!=null) { 
                var inputReason = component.find("inputReason");
                
                var action = component.get("c.updateReasonField"); 
                action.setParams({
                    typeName: component.get("v.objectApiName"), 
                    fieldName: component.get("v.reasonAuditField"), 
                    recId: component.get('v.recordId'),
                    reason: inputReason.get("v.value")});
                $A.enqueueAction(action);
                console.log('reasonAuditField: ' + component.get("v.reasonAuditField"));
            };
        }
    },
    queryData : function(component, event, helper) { 
        console.log('queryData');

        var action = component.get("c.getFields");
        action.setParams({
            typeName: component.get("v.objectApiName"), 
            fsName: component.get("v.fieldSetName"), 
            recId: component.get('v.recordId')});
        action.setCallback(this, function(a) {
            component.set("v.fields", a.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})