public class RecursiveTriggerHandler{
    public static Boolean isFirstTime = TRUE;
    public static boolean runOnce(){
        if(isFirstTime){
            isFirstTime = FALSE;
            return TRUE;
        }else{
            return isFirstTime;
        }
    }
}