import { LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { deleteRecord } from 'lightning/uiRecordApi';
import createClassAssignment from '@salesforce/apex/StudentClassController.createClassAssignment';
import { NavigationMixin } from 'lightning/navigation';

export default class DHA_NewStudentRecordForm extends NavigationMixin(LightningElement) {
    rows = [];
    options = [];
    rowCounter = 0;
    actionType;

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        })
        this.dispatchEvent(event);
    }

    handleAddClass() {
        this.rows = [
            ...this.rows,
            { id: ++this.rowCounter, classId: null }
        ];
    }

    removeRow(event) {
        const selectedRowId = event.target.dataset.id;
        this.rows = this.rows.filter(row => row.id !== parseInt(selectedRowId, 10));
    }

    handleClassChange(event) {
        const selectedRowId = parseInt(event.target.dataset.id, 10);
        const selectedClassId = event.detail.recordId;

        this.rows = this.rows.map(row => {
            if (row.id === selectedRowId) {
                return { ...row, classId: selectedClassId }
            }
            return row;
        })
        console.log(JSON.stringify(this.rows));

        // Two approaches below are the same purpose, but only update in place, to guarantee reactivity of LWC
        // --> reassign this.rows = [...this.rows] after finish, or @track rows
        // for(let i=0; i < this.rows.length;i++){
        //     if(this.rows[i].id === selectedRowId){
        //         this.rows[i].classId = selectedClassId;
        //     }
        // }

        // this.rows.forEach(row => {
        //     if(row.id === selectedRowId){
        //         row.classId = selectedClassId;
        //     }
        // }
        // )
    }

    setActionType(event) {
        this.actionType = event.target.dataset.action;
    }

    async handleSuccess(event) {
        const newStudentId = event.detail.id;
        const classIds = this.rows.map(row => row.classId);
        classIds.forEach(item => console.log('classIds: ' + item));
        if (classIds.length !== 0) {
            try {
                await createClassAssignment({ studentId: newStudentId, classIds: classIds });
            } catch (error) {
                await deleteRecord(newStudentId);
                const err = JSON.parse(error.body.message); // JSON.parse
                this.showToast(
                    "Failed!",
                    `${err.className} - ${err.methodName} - ${err.message} - ${err.lineOfCode}`,
                    "error");
                return;
            }
        }

        this.showToast(
            "Success!",
            "New Student Created",
            "success"
        );

        if (this.actionType === 'save') {
            this.navigateToAllListView();
        } else if (this.actionType === 'saveAndNew') {
            // Reset all fields in the form
            const inputFields = this.template.querySelectorAll(
                'lightning-input-field'
            );
            if (inputFields) {
                inputFields.forEach(field => {
                    field.reset();
                });
            }
        }
    }

    navigateToAllListView() {
        // Navigate back to the List View of this object
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'DHA_Student__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            }
        });
    }


    handleCancel() {
        // Navigate back to the List View of this object
        this.navigateToAllListView();
    }
}
