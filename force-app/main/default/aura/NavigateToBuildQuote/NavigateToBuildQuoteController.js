({    
    invoke : function(component, event, helper) {
        var record = component.get("v.recordId");
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/pdffiller_sfree__airslateApp?buttonId=a0B75000000LQDKEA4&recordId="+ record +"&objectName=Quote"
        });
        urlEvent.fire();
    }})