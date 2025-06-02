({
    // Fetch the accounts from the Apex controller
    getLinkedHates: function(component) {
        console.log('getLinkedHates');

        var action = component.get('c.getLinkedHates');
        action.setParams({
            "hateId": component.get("v.recordId")
        });
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log(state);

            console.log(actionResult.getReturnValue());
            component.set('v.linkedHateList', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
    
})