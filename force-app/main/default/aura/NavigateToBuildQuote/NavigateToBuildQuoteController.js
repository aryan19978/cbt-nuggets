({    
    
    fetchButtonId : function(component, event, helper) {
        
    },
    
    invoke : function(component, event, helper) {
        var action = component.get("c.fetchQuoteButtonValue");
        action.setParams({
            LabelValue:"Signed"
        });
        action.setCallback(this, function(response){
            console.log(response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ButtonID", response.getReturnValue());
                
                var record = component.get("v.recordId");
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/pdffiller_sfree__airslateApp?buttonId="+component.get("v.ButtonID")+"&recordId="+ record +"&objectName=Quote"
                });
                urlEvent.fire(); 
            }
        });
        $A.enqueueAction(action);
    }
})