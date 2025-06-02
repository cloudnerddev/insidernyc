/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class ChartDataProvider {
    global ChartDataProvider() {

    }
    global abstract List<lwcc.ChartDataProvider.ChartData> getData();
    global abstract void init(Object param0);
global class ChartData {
    @AuraEnabled
    global String bgColor;
    @AuraEnabled
    global List<Object> detail;
    @AuraEnabled
    global List<String> labels;
    global ChartData() {

    }
}
}
