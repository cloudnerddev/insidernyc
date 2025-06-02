({
    doInit: function(component, event, helper) {
        // Fetch the lnked address list from the Apex controller
        helper.getLinkedAddresses(component);
    },openTabWithSubtab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var focusid = event.currentTarget.dataset.focusid;
        var openid = event.currentTarget.dataset.openid;
        console.log(focusid);
        console.log(openid);

        workspaceAPI.openTab({
            //url: '/lightning/r/Account/'+linkid+'/view',
            url: '/lightning/r/'+focusid+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                //url: '/lightning/r/Case/'+addressid+'/view',

                url: '/lightning/r/'+openid+'/view',
                focus: true
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})