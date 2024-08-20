import { Given, When, Then } from "@badeball/cypress-cucumber-preprocessor";
import AddRemoveElementsPage from "../support/AddRemoveElementsPage";

Given("I open the Add Remove Elements page", () => {
  AddRemoveElementsPage.visit();
});

When("I add an element", () => {
  AddRemoveElementsPage.addElement();
});

Then("I should see the element", () => {
  AddRemoveElementsPage.getElement().should("be.visible");
});

When("I remove the element", () => {
  AddRemoveElementsPage.removeElement();
});

Then("I should not see the element", () => {
  AddRemoveElementsPage.getElement().should("not.exist");
});
