({   
    invoke : function(component, event, helper) {
    
                var record = component.get("v.recordId");
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/pdffiller_sfree__airslateApp?buttonId="+$A.get("$Label.c.Un_Signed_Quote_Button_Id")+"&recordId="+ record +"&objectName=Quote"
                });
                urlEvent.fire();    
    }})