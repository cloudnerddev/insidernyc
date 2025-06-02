({
    // Fetch the accounts from the Apex controller
    getRelatedConfirmedCases: function(component) {
        var action = component.get('c.getRelatedConfirmedCases');
        action.setParams({
            "caseId": component.get("v.recordId")
        });
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set('v.cases', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})