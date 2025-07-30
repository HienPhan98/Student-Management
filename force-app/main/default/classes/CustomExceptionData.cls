public class CustomExceptionData {
    private String className;
    private String methodName;
    private String typeName;
    private String message;
    private String lineOfCode;
    
    public CustomExceptionData(String className, String methodName, String typeName, String message, String lineOfCode) {
        this.className = className;
        this.methodName = methodName;
        this.typeName = typeName;
        this.message = message;
        this.lineOfCode = lineOfCode;
    }
}