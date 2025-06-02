({
    // Fetch the accounts from the Apex controller
    getLinkedAddresses: function(component) {
        console.log('getLinkedAddresses');

        var action = component.get('c.getLinkedAddresses');
        action.setParams({
            "addressId": component.get("v.recordId")
        });
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log(state);

            console.log(actionResult.getReturnValue());
            component.set('v.linkedAddressList', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
    
})