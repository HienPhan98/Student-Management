import { LightningElement, wire } from "lwc";
import getAllClasses from "@salesforce/apex/StudentClassController.getAllClasses";
import searchStudents from "@salesforce/apex/StudentClassController.searchStudents";
import getRecentlyViewedStudents from "@salesforce/apex/StudentClassController.getRecentlyViewedStudents";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import DHA_StudentSearchDetailModal from "c/dHA_StudentSearchDetailModal";

const actions = [
  { label: 'Show details', name: 'show_details' },
];

export default class dHA_StudentSearch extends LightningElement {
  classes = [];
  dataTable = [];
  columns = [];
  sortDirection = "asc";
  sortedBy;
  isLoaded = true;

  @wire(getAllClasses)
  wiredAllClasses({ error, data }) {
    if (data) {
      this.classes = data.map((item) => ({
        label: item.Name,
        value: item.Id
      }));
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

  @wire(getRecentlyViewedStudents)
  wiredRecentlyViewedStudents({ error, data }) {
    if (data) {
      this.showDataOnTable(data);
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

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
        return primer(x[field]);
      }
      : function (x) {
        return x[field];
      };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  sortDataDirection(sortedBy, sortDirection) {
    const cloneData = [...this.dataTable];
    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.dataTable = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    this.sortDataDirection(sortedBy, sortDirection);
  }

  showDataOnTable(listStudents) {
    //check if no record was found with filter values, then return error immediately
    if (listStudents.length === 0) {
      //Remove all records found before in table data
      this.dataTable = null;
      this.columns = null;
      const event = new ShowToastEvent({
        title: "Failed!",
        message: "No student was found with your inputs",
        variant: "error"
      });
      this.dispatchEvent(event);
      return;
    }

    //set data of table
    this.dataTable = listStudents.map((item) => ({
      studentId: item.Id,
      studentCode: item.Student_Code__c,
      studentName: item.Name,
      studentBirthdate: item.Birthdate__c,
      studentAddress: item.Address__c,
      studentEmail: item.Email__c,
      recordLink: `/lightning/r/DHA_Student__c/${item.Id}/view`
    }));

    //set columns of table
    this.columns = [
      {
        label: "Student Code",
        fieldName: "studentCode",
        type: "text",
        hideDefaultActions: true,
        sortable: true
      },
      {
        label: "Student Name",
        fieldName: "recordLink",
        type: "url",
        hideDefaultActions: true,
        typeAttributes: {
          label: { fieldName: "studentName" },
          target: "_blank"
        },
        cellAttributes: {
          class: "slds-text-link_reset"
        }
      },
      {
        label: "Birthdate",
        fieldName: "studentBirthdate",
        type: "date-local",
        hideDefaultActions: true,
        typeAttributes: {
          day: "2-digit",
          month: "2-digit"
        }
      },
      {
        label: "Address",
        fieldName: "studentAddress",
        hideDefaultActions: true,
        type: "text"
      },
      {
        label: "Email",
        fieldName: "studentEmail",
        hideDefaultActions: true,
        type: "email"
      },
      { type: "action", typeAttributes: { rowActions: actions } }
    ];
    //Apply the previous sort direction and column
    this.sortDataDirection(this.sortedBy, this.sortDirection);
  }

  async handleSearch() {
    try {
      this.isLoaded = !this.isLoaded; //show spinner while waiting for data loading
      this.dataTable = null;
      this.columns = null;
      const studentName = this.template.querySelector('[data-name="studentNameInput"]');
      const birthDate = this.template.querySelector('[data-name="birthdateInput"]');
      const classId = this.template.querySelector('[data-name="classInput"]');
      const allNonValue = !studentName.value && !birthDate.value && !classId.value;

      //check if there's any validity from input components
      const allValidInput = [...[studentName, birthDate]].reduce((validSoFar, inputFields) => {
        inputFields.reportValidity();
        return validSoFar && inputFields.checkValidity();
      }, true);

      if (!allValidInput) {
        this.isLoaded = !this.isLoaded;
        return;
      }

      //check if there's not any input is filled
      if (allNonValue) {
        const event = new ShowToastEvent({
          title: "Failed!",
          message: "Please provide at least 1 condition to search for students",
          variant: "error"
        });
        this.isLoaded = !this.isLoaded;
        this.dispatchEvent(event);
        return;
      }
      this.dataTable = await searchStudents({
        name: studentName.value,
        birthDate: birthDate.value,
        classId: classId.value
      });
      this.isLoaded = !this.isLoaded;
      console.log("length dataTable is" + this.dataTable.length);
      //show data on table
      this.showDataOnTable(this.dataTable);

    } catch (err) {
      const error = err.body.message;
      const event = new ShowToastEvent({
        title: "Failed!",
        message: `${error.className} - ${error.methodName} - ${error.message} - ${error.lineOfCode}`,
        variant: "error"
      });
      this.dispatchEvent(event);
    }
  }

  handleClear() {
    this.template.querySelector('[data-name="studentNameInput"]').value = "";
    this.template.querySelector('[data-name="birthdateInput"]').value = "";
    this.template.querySelector('[data-name="classInput"]').value = "";
    this.dataTable = null;
    this.columns = null;
  }

  async handleRowAction(event) {
    try {
      const actionName = event.detail.action.name;
      const selectedRows = event.detail.row;
      switch (actionName) {
        case "show_details":
          {
            console.log("lalalala");
            await DHA_StudentSearchDetailModal.open({
              size: "medium",
              description: "Student Detail",
              recordId: selectedRows.studentId // Pass to modal via @api decoration
            });
          }
          break;
        default:
      }
    } catch (error) {
      console.error(JSON.stringify(error));
    }

  }
}
