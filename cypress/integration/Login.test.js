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

  });

  context('Low Priority', () => {

  });
});
