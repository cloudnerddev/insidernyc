({
    /**
     * Get the columns to display in the datatable from the fieldset
     * */
    getColumns : function( cmp ) {
        console.log('getColumns');

        // Get columns from the fieldset
        let action = cmp.get("c.getFieldset");

        action.setCallback( this, function( response ) {
            let state = response.getState();
            if (state === "SUCCESS") {
                var fieldSetArray = JSON.parse(response.getReturnValue());

                //define action column
                var actions = {
                    type: 'action', typeAttributes: {
                        rowActions: [
                            { label: 'Delete', name: 'delete' }
                        ]
                    }
                };

                //push actions to into the first column
                fieldSetArray.unshift(actions);
                cmp.set("v.fieldsetColumns", fieldSetArray);
            }
            else if (state === "INCOMPLETE") {
                this.handleErrors([{message: 'network error getting flightlines'}], cmp);
            }
            else if (state === "ERROR") {
                this.handleErrors(response.getError(), cmp, 'info');
            }
        } );

        $A.enqueueAction(action);
    },

    /**
     * Get the list of the airline tickets from the source flight
     * */
    getTickets : function( cmp ) {
        console.log('getTickets');

        let action = cmp.get("c.getAirlineTickets");
        action.setParams({
            flightId: cmp.get('v.recordId')
        });

        action.setCallback( this, function( response ) {
            let state = response.getState();
            if (state === "SUCCESS") {
                var lines = response.getReturnValue();
                if(!lines.length){
                    //If there are no lines to clone, show a message then navigate to the cloned flight
                    this.handleErrors([{message: 'Flight has no airline tickets'}], cmp, 'info' , this.navigateToClonedFlight);
                }
                cmp.set( "v.lstTickets", lines );
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                this.handleErrors(response.getError(), cmp);
            }
        } );

        $A.enqueueAction(action);
    },

    /**
     * Clone source flight lines and override with values from the datatable
     * */
    cloneAirlineTickets: function( cmp ) {
        console.log('cloneAirlineTickets');

        let action = cmp.get("c.cloneAirlineTickets");
        action.setParams({
            sourceFlightId: cmp.get("v.recordId"),
            clonedFlight: cmp.get("v.clonedFlight"),
            lstTickets: cmp.get("v.lstTickets"),
            changes: cmp.get("v.draftValues")
        });

        action.setCallback(this, function( response ) {
            cmp.set("v.loading", false);
            let state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.clonedFlightId', response.getReturnValue());
                this.navigateToClonedFlight(cmp);
            }
            else if (state === "INCOMPLETE") {
                this.handleErrors([{message: 'Unable to create the flight - network error'}], cmp);
            }
            else if (state === "ERROR") {
                this.handleErrors(response.getError(), cmp);
            }

        } );

        $A.enqueueAction(action);
    },

    /**
     * Go to the cloned flight
     * */
    navigateToClonedFlight: function( cmp ) {
        console.log('cloneAirlineTickets');

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get('v.clonedFlightId')
        });
        navEvt.fire();
    },

    /**
     * Display errors or information windows.  Can't use Toast
     * because there's a Salesforce bug which causes them to appear
     * behind modal windows
     * */
    handleErrors: function(errors, cmp, type, onclose){
        let variant = 'error';
        let message = 'Unknown error';

        if(type){
            variant = type;
        }

        if (errors && Array.isArray(errors) && errors.length > 0) {
            message = errors[0].message;
        }

        let msgParams = {
            "variant": "error",
            "header": "Information",
            "message": message
        };

        if(onclose){
           msgParams.closeCallback = function(){ onclose(cmp) };
        }

        cmp.find('notifLib').showNotice(msgParams);

        console.error(message);
    }
})