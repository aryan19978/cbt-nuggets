public class CBTN_TriggerRecursionHandler  {
    public static Boolean caseRunBeforeOnce = true;
    public static Boolean caseRunAfterOnce = true;

    public static Boolean caseRunBeforeOnce()
    {
        if(caseRunBeforeOnce)
        {
            caseRunBeforeOnce = false;
            return true;
        }
        else
        {
            return caseRunBeforeOnce;
        }
    }

    public static Boolean caseRunAfterOnce()
    {
        if(caseRunAfterOnce)
        {
            caseRunAfterOnce = false;
            return true;
        }
        else
        {
            return caseRunAfterOnce;
        }
    }
}