public with sharing class StudentResultInformation {
    @AuraEnabled public Integer numberOfAssignedClass;
    @AuraEnabled public Integer numberOfClassHasFinalScore;
    @AuraEnabled public List<String> averageFinalScores;

    public StudentResultInformation(Integer assigned, Integer hasScore, List<String> avgScores) { 
      this.numberOfAssignedClass = assigned;
      this.numberOfClassHasFinalScore = hasScore;
      this.averageFinalScores = avgScores;  
    }
}