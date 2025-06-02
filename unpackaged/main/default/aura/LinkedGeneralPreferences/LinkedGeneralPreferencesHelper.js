({
    // Fetch the accounts from the Apex controller
    getLinkedGeneralPreferences: function(component) {
        console.log('getLinkedGeneralPreferences');

        var action = component.get('c.getLinkedGeneralPreferences');
        action.setParams({
            "generalPreferenceId": component.get("v.recordId")
        });
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log(state);

            console.log(actionResult.getReturnValue());
            component.set('v.linkedGeneralPreferenceList', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
    
})