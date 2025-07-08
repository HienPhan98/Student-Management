import DHA_STUDENT_OBJECT from "@salesforce/schema/DHA_Student__c";
import NAME_FIELD from "@salesforce/schema/DHA_Student__c.Name";
import BIRTHDATE_FIELD from "@salesforce/schema/DHA_Student__c.Birthdate__c";
import GENDER_FIELD from "@salesforce/schema/DHA_Student__c.Gender__c";
import ADDRESS_FIELD from "@salesforce/schema/DHA_Student__c.Address__c";
import STUDENT_CODE_FIELD from "@salesforce/schema/DHA_Student__c.Student_Code__c";
import AGE_FIELD from "@salesforce/schema/DHA_Student__c.Age__c";
import EMAIL_FIELD from "@salesforce/schema/DHA_Student__c.Email__c";
import { wire } from "lwc";
import countAssignedClassesOfStudent from "@salesforce/apex/StudentClassController.countAssignedClassesOfStudent";
import countClassHaveFinalScore from "@salesforce/apex/StudentClassController.countClassHaveFinalScore";
import getAverageScores from "@salesforce/apex/StudentClassController.getAverageScores";

import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class DHA_StudentSearchDetailModal extends LightningModal {
  activeSections = ["studentInfo", "studyResultInfo"];
  objectApiName = DHA_STUDENT_OBJECT;
  nameField = NAME_FIELD;
  birthdateField = BIRTHDATE_FIELD;
  genderField = GENDER_FIELD;
  addressField = ADDRESS_FIELD;
  studentCodeField = STUDENT_CODE_FIELD;
  ageField = AGE_FIELD;
  emailField = EMAIL_FIELD;
  @api recordId;

  @wire(countAssignedClassesOfStudent, { studentId: '$recordId' })
  assignedClasses;

  @wire(countClassHaveFinalScore, { studentId: '$recordId' })
  classesHaveFinalScore;

  @wire(getAverageScores, { studentId: '$recordId' })
  wiredGetAverageScores({ data, error }) {
    if (data) {
      if (data.length === 0) {
        this.averageFinalScore = "0";
      } else { this.averageFinalScore = data.join(', '); }
    } else if (error) {
      console.log("Error: " + JSON.stringify(error));
    }
  }
}
