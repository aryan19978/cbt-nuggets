({   
    fetchButtonId : function(component, event, helper) {
        var action = component.get("c.fetchQuoteButtonValue");
        action.setParams({
            LabelValue:"UnSigned"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ButtonID", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    invoke : function(component, event, helper) {
        var record = component.get("v.recordId");
        
        var urlEvent = $A.get("e.force:navigateToURL");
        // urlEvent.setParams({
        //     "url": "/apex/pdffiller_sfree__airslateApp?buttonId="+component.get("v.ButtonID")+"&recordId="+ record +"&objectName=Quote"
        // });
        urlEvent.setParams({
            "url": "/apex/pdffiller_sfree__airslateApp?buttonId=a0B75000000LPxYEAW&recordId="+ record +"&objectName=Quote"
        });
        urlEvent.fire();
    }})