({
    doInit: function(component, event, helper) {
        // Fetch the cases list from the Apex controller
        helper.getRelatedConfirmedCases(component);
    },
    openTabWithSubtab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var accountid = event.currentTarget.dataset.accountid;
        var caseid = event.currentTarget.dataset.caseid;
        console.log(accountid);
        console.log(caseid);

        workspaceAPI.openTab({
            url: '/lightning/r/Account/'+accountid+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                url: '/lightning/r/Case/'+caseid+'/view',
                focus: true
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})