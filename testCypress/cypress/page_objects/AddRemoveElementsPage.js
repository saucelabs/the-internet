class AddRemoveElementsPage {
  constructor() {
    this.addButtonSelector = "button[onclick='addElement()']";
    this.addedElementSelector = ".added-manually";
  }

  visit() {
    cy.visit("/add_remove_elements/");
  }

  addElement() {
    cy.get(this.addButtonSelector).click();
  }

  removeElement() {
    cy.get(this.addedElementSelector).click();
  }

  getElement() {
    return cy.get(this.addedElementSelector);
  }
}

export default new AddRemoveElementsPage();
