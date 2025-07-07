public with sharing class CustomExceptionData {
    private String className;
    private String methodName;
    private String message;
    private String lineOfCode;

    public CustomExceptionData(String className, String methodName, String message, String lineOfCode) {
        this.className = className;
        this.methodName = methodName;
        this.message = message;
        this.lineOfCode = lineOfCode;
    }
}