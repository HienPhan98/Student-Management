import { LightningElement, api, wire } from 'lwc';
import getDetailStudyResultInfoV2 from '@salesforce/apex/StudentClassController.getDetailStudyResultInfoV2';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class DHA_StudentStudyResult extends LightningElement {

    @api recordId; // automatically receive from the System when placed in the Record Page Layout

    data = [];
    columns = [];

    @wire(getDetailStudyResultInfoV2, { studentId: '$recordId' })
    wiredGetDetailStudentResultInfoV2({ data, error }) {
        if (data) {
            this.data=null;
            if (data.length > 0) {
                this.data = data.map(item =>
                ({
                    studyResultName: item.Name,
                    className: item.DHA_Class_Assignment__r.DHA_Class__r.Name,
                    finalScore: item.Final_Score__c,
                    studyResult: item.Result__c,
                    studyResultRecordLink: `/lightning/r/DHA_Study_Result__c/${item.Id}/view`,
                    classRecordLink: `/lightning/r/DHA_Class__c/${item.DHA_Class_Assignment__r.DHA_Class__r.Id}/view`
                })
                );
                this.columns = [
                    {
                        label: 'Study Result Name', fieldName: 'studyResultRecordLink', type: 'url',
                        typeAttributes: {
                            label: { fieldName: 'studyResultName' },
                            target: '_blank',
                        },
                        hideDefaultActions: true
                    },
                    {
                        label: 'Class', fieldName: 'classRecordLink', type: 'url',
                        typeAttributes: {
                            label: { fieldName: 'className' },
                            target: '_blank',
                        },
                        hideDefaultActions: true
                    },
                    { label: 'Final Score', fieldName: 'finalScore', type: 'text', hideDefaultActions: true },
                    { label: 'Result', fieldName: 'studyResult', type: 'text', hideDefaultActions: true }
                ]
            }
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