class AddRemoveElementsPage {
  visit() {
	cy.visit("/add_remove_elements/");
  }

  addElement() {
	cy.get("button[onclick='addElement()']").click();
  }

  removeElement() {
	cy.get(".added-manually").click();
  }

  getElement() {
	return cy.get(".added-manually");
  }
}

export default new AddRemoveElementsPage();