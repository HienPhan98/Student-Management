import LightningModal from "lightning/modal";

export default class DHA_StudentSearchDetailModal extends LightningModal {
  activeSections = ["studentInfo", "studyResultInfo"];

  handleSectionToggle(event) {
    const openSections = event.detail.openSections;

    if (openSections.length === 0) {
      this.activeSectionsMessage = "All sections are closed";
    } else {
      this.activeSectionsMessage = "Open sections: " + openSections.join(", ");
    }
  }
}
