import DHA_STUDENT_OBJECT from "@salesforce/schema/DHA_Student__c";
import NAME_FIELD from "@salesforce/schema/DHA_Student__c.Name";
import BIRTHDATE_FIELD from "@salesforce/schema/DHA_Student__c.Birthdate__c";
import GENDER_FIELD from "@salesforce/schema/DHA_Student__c.Gender__c";
import ADDRESS_FIELD from "@salesforce/schema/DHA_Student__c.Address__c";
import STUDENT_CODE_FIELD from "@salesforce/schema/DHA_Student__c.Student_Code__c";
import AGE_FIELD from "@salesforce/schema/DHA_Student__c.Age__c";
import EMAIL_FIELD from "@salesforce/schema/DHA_Student__c.Email__c";
import { wire } from "lwc";
import getSummaryStudyResultInfo from "@salesforce/apex/StudentClassController.getSummaryStudyResultInfo";
import getDetailStudyResultInfo from "@salesforce/apex/StudentClassController.getDetailStudyResultInfo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
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
  @api recordId; //will receive from the DHA_StudentSearch component via rowAction event
  assignedClasses;
  averageFinalScore;
  classesHaveFinalScore;
  data = [];
  columns = [];

  @wire(getSummaryStudyResultInfo, { studentId: '$recordId' })
  wiredGetSummaryStudyResultInfo({ data, error }) {
    if (data) {
      this.assignedClasses = data.numberOfAssignedClass;
      this.classesHaveFinalScore = data.numberOfClassHasFinalScore;
      if (data.averageFinalScores.length === 0) {
        this.averageFinalScore = "0";
      } else { this.averageFinalScore = data.averageFinalScores.join(', '); }
    } else if (error) {
      const err = error.body.message;
      const event = new ShowToastEvent({
        title: "Failed!",
        message: `${err.className} - ${err.methodName} - ${err.message} - ${err.lineOfCode}`,
        variant: "error"
      });
      this.dispatchEvent(event);
    }
  }

  @wire(getDetailStudyResultInfo, { studentId: '$recordId' })
  wiredGetDetailStudyResultInfo({ data, error }) {
    if (data) {
      let dataFilter = [];
      for (let i = 0; i < data.length; i++) {
        const studyResults = data[i].DHA_Study_Results__r;
        if (studyResults && studyResults.length > 0) {
          for (let j = 0; j < data[i].DHA_Study_Results__r.length; j++) {
            let object = {};
            object.className = data[i].DHA_Class__r.Name;
            object.classLink = `/lightning/r/DHA_Class__c/${data[i].DHA_Class__r.Id}/view`
            object.score1 = data[i].DHA_Study_Results__r[j].Score_1__c;
            object.score2 = data[i].DHA_Study_Results__r[j].Score_2__c;
            object.score3 = data[i].DHA_Study_Results__r[j].Score_3__c;
            object.finalScore = data[i].DHA_Study_Results__r[j].Final_Score__c;
            object.result = data[i].DHA_Study_Results__r[j].Result__c;
            dataFilter.push(object);
          }
        }
      }

      this.data = dataFilter;

      //set columns of table
      this.columns = [
        {
          label: "Class",
          fieldName: "classLink",
          type: "url",
          hideDefaultActions: true,
          typeAttributes: {
            label: { fieldName: "className" },
            target: "_blank"
          },
          cellAttributes: {
            class: "slds-text-link_reset"
          }
        },
        {
          label: "Score 1",
          fieldName: "score1",
          type: "text",
          hideDefaultActions: true,
        },
        {
          label: "Score 2",
          fieldName: "score2",
          type: "text",
          hideDefaultActions: true,
        },
        {
          label: "Score 3",
          fieldName: "score3",
          type: "text",
          hideDefaultActions: true,
        },
        {
          label: "Final Score",
          fieldName: "finalScore",
          type: "text",
          hideDefaultActions: true
        },
        {
          label: "Result",
          fieldName: "result",
          type: "text",
          hideDefaultActions: true
        }
      ];
    }
    else if (error) {
      const err = error.body.message;
      const event = new ShowToastEvent({
        title: "Failed!",
        message: `${err.className} - ${err.methodName} - ${err.message} - ${err.lineOfCode}`,
        variant: "error"
      });
      this.dispatchEvent(event);
    }
  }
}
