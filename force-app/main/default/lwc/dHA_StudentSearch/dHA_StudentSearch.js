import { LightningElement, wire } from "lwc";
import getAllClasses from "@salesforce/apex/StudentClassController.getAllClasses";
import searchStudents from "@salesforce/apex/StudentClassController.searchStudents";
import getRecentlyViewedStudents from "@salesforce/apex/StudentClassController.getRecentlyViewedStudents";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import DHA_StudentSearchDetailModal from "c/dHA_StudentSearchDetailModal";

const actions = [
  { label: 'Show details', name: 'show_details' },
];

const columns = [
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

export default class dHA_StudentSearch extends LightningElement {
  classes = [];
  dataTable = [];
  allResults = [];
  columns = columns;
  sortDirection = "asc";
  sortedBy;
  isLoaded = true;

  retrievedResults = 0;
  recordsPerPage = 15;
  currentPage = 1;
  totalPages = 0;
  paginatedData = [];
  startIndex = 0;
  endIndex = this.recordsPerPage;
  isFirstPage = true;
  isLastPage = true;

  resetPaginatedData() {
    this.retrievedResults = 0;
    this.totalPages = 0;
    this.startIndex = 0;
    this.endIndex = this.recordsPerPage;
    this.currentPage = 1;
    this.isFirstPage = true;
    this.isLastPage = true;
  }

  @wire(getAllClasses)
  wiredAllClasses({ error, data }) {
    if (data) {
      this.classes = data.map((item) => ({
        label: item.Name,
        value: item.Id
      }));
    } else if (error) {
      const err = JSON.parse(error.body.message); // JSON.parse
      this.showToast(
        "Failed!",
        `${err.className} - ${err.methodName} - ${err.message} - ${err.lineOfCode}`,
        "error"
      );
    }
  }

  @wire(getRecentlyViewedStudents)
  wiredRecentlyViewedStudents({ error, data }) {
    if (data) {
      this.showDataOnTable(data);
    } else if (error) {
      const err = JSON.parse(error.body.message); // JSON.parse
      this.showToast(
        "Failed!",
        `${err.className} - ${err.methodName} - ${err.message} - ${err.lineOfCode}`,
        "error"
      );
    }
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    })
    this.dispatchEvent(event);
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
      this.dataTable = [];
      this.showToast(
        "Failed!",
        "No student was found with your inputs",
        "error"
      );
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

    //Apply the previous sort direction and column
    this.sortDataDirection(this.sortedBy, this.sortDirection);
  }

  async handleSearch() {
    try {
      this.resetPaginatedData(); //reset index and current page for paginated data
      this.isLoaded = !this.isLoaded; //show spinner while waiting for data loading
      this.allResults = [];

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
        this.isLoaded = !this.isLoaded;
        this.showToast(
          "Failed!",
          "Please provide at least 1 condition to search for students",
          "error")
        return;
      }
      this.allResults = await searchStudents({
        name: studentName.value,
        birthDate: birthDate.value,
        classId: classId.value
      });

      //paginate data table
      this.retrievedResults = this.allResults.length;
      this.totalPages = Math.ceil(this.allResults.length / this.recordsPerPage);

      //on first search paginates with number of recordsPerPage
      this.paginatedData = this.allResults.slice(this.startIndex, this.endIndex);
      this.isLoaded = !this.isLoaded;
      //show data on table
      if (this.paginatedData.length > this.recordsPerPage) { this.isLastPage = false; }
      this.showDataOnTable(this.paginatedData);
    } catch (error) {
      const err = JSON.parse(error.body.message); // JSON.parse
      this.showToast(
        "Failed!",
        `${err.className} - ${err.methodName} - ${err.message} - ${err.lineOfCode}`,
        "error");
    }
  }

  handleNext() {
    this.isFirstPage = false;
    this.currentPage++;
    this.startIndex += this.recordsPerPage;
    this.endIndex += this.recordsPerPage;
    //check if there's no data left in table
    if (this.currentPage === this.totalPages) {
      this.isLastPage = true;
    }
    this.paginatedData = this.allResults.slice(this.startIndex, this.endIndex);
    //show data on table
    this.showDataOnTable(this.paginatedData);
  }

  handlePrevious() {
    this.isLastPage = false;
    this.currentPage--;
    this.startIndex -= this.recordsPerPage;
    this.endIndex -= this.recordsPerPage;
    //check if there's no data left in table
    if (this.currentPage === 1) {
      this.isFirstPage = true;
    }
    this.paginatedData = this.allResults.slice(this.startIndex, this.endIndex);
    //show data on table
    this.showDataOnTable(this.paginatedData);
  }

  handleClear() {
    this.template.querySelector('[data-name="studentNameInput"]').value = "";
    this.template.querySelector('[data-name="birthdateInput"]').value = "";
    this.template.querySelector('[data-name="classInput"]').value = "";
    this.allResults = [];
    this.dataTable = [];
    this.resetPaginatedData();
  }

  async handleRowAction(event) {
    try {
      const actionName = event.detail.action.name;
      const selectedRows = event.detail.row;
      switch (actionName) {
        case "show_details":
          {
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
