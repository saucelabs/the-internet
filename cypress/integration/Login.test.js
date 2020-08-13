describe('Login', () => {
  beforeEach(() => {
    cy.visit('https://the-internet.herokuapp.com/login')
  });
  context('High Priority', () => {
    it('Should be able to fill in the inputs', () => {
      // Testing a standard username input
      // Finding the input by name value
      cy.get('[name=username]').type('Username');
      cy.get('[name=username]').should('have.value', 'Username');
      // Testing a standard password input
      // Finding the input by index value
      cy.get('input').eq(1).type('Password');
      cy.get('input').eq(1).should('have.value', 'Password');
    });

    it('Should throw an error message if the incorrect Username is given, and should not login', () => {
      // Testing a purposefully incorrect username input, expect to recieve error
      cy.get('input').eq(0).type('NotTomSmith');
      cy.get('button').eq(0).click();
      // Testing the error handler to be visible and correct
      cy.get('[id=flash]').should('be.visible');
      cy.contains('Your username is invalid!');
      // Testing  the page did not change
      cy.url().should('eq', 'https://the-internet.herokuapp.com/login');
    });

  });

  context('Low Priority', () => {

  });
});
