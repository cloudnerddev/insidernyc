({
    // Fetch the accounts from the Apex controller
    getLinkedPaymentMethods: function(component) {
        console.log('getLinkedPaymentMethods');

        var action = component.get('c.getLinkedPaymentMethods');
        action.setParams({
            "paymentMethodId": component.get("v.recordId")
        });
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log(state);

            console.log(actionResult.getReturnValue());
            component.set('v.linkedPaymentMethodList', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
    
})