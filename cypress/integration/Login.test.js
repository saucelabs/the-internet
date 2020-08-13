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

    it('Should throw an error message if the incorrect Password is given with correct Username, and should not login', () => {
      // Testing a purposefully incorrect username input, expect to recieve error
      cy.get('input').eq(0).type('tomsmith');
      cy.get('input').eq(1).type('NotSuperSecret')
      cy.get('button').eq(0).click();
      // Testing the error handler to be visible and correct
      cy.get('[id=flash]').should('be.visible');
      cy.contains('Your password is invalid!');
      // Testing  the page did not change
      cy.url().should('eq', 'https://the-internet.herokuapp.com/login');
    });

    it('Should login when correct Username and Password are given', () => {
      cy.get('[name=username]').eq(0).type('tomsmith');
      cy.get('[name=password]').type('SuperSecretPassword!');
      cy.get('button').eq(0).click();
      // Testing the error handler to be visible and correct
      cy.get('[id=flash]').should('be.visible');
      cy.contains('You logged into a secure area!');
      // Testing the page did change
      cy.url().should('eq', 'https://the-internet.herokuapp.com/secure');
    });

    it('Should redirect to login page with error message if user tries to go to secure site without proper login', () => {
      // Testing automatic routing to secure page, expect error handling
      cy.visit('https://the-internet.herokuapp.com/secure');
      cy.get('[id=flash]').should('be.visible');
      cy.contains('You must login to view the secure area!');
      cy.url().should('eq', 'https://the-internet.herokuapp.com/login');
    });

    it('Should return to login page when logout button is clicked after successful login', () => {
      // First get a successful login to test
      cy.get('[name=username]').eq(0).type('tomsmith');
      cy.get('[name=password]').type('SuperSecretPassword!');
      cy.get('button').eq(0).click();
      cy.url().should('eq', 'https://the-internet.herokuapp.com/secure');
      // Testing the logout button
      cy.get('a').eq(2).click();
      cy.url().should('eq', 'https://the-internet.herokuapp.com/login');
    });

  });

  context('Low Priority', () => {
    it('Should accept letters, numbers, and symbols as inputs in username and password input fields', () => {
      cy.get('input').eq(0).type('Strong22U$ername!');
      cy.get('input').eq(0).should('have.value', 'Strong22U$ername!');
      cy.get('input').eq(1).type('Protected14P@$sword?');
      cy.get('input').eq(1).should('have.value', 'Protected14P@$sword?');
    });

    it('Should be able to keep password private during recording, if needed by developer', () => {
      cy.get('input').eq(1).type('SuperSecretPassword!', { log: false });
    });

    it('Shoud redirect to GitHub when green banner is clicked from both pages', () => {
      // Testing login page green banner
      cy.get('img').parent()
      // Do not want to simulate click and leave application
        .should('have.attr', 'href')
        .and('include', 'github.com/tourdedave/the-internet');
      // Testing Secure page green banner
      cy.get('[name=username]').eq(0).type('tomsmith');
      cy.get('[name=password]').type('SuperSecretPassword!');
      cy.get('button').eq(0).click();
      cy.get('img').parent()
        .should('have.attr', 'href')
        .and('include', 'github.com/tourdedave/the-internet');
    });

    it('Should direct to Elemental Selenium when bottom link is clicked from both pages', () => {
      cy.get('a').eq(1)
      // Do not want to simulate click and leave application
        .should('have.attr', 'href')
        .and('include', 'elementalselenium.com');
      // Testing Secure page 
      cy.get('[name=username]').eq(0).type('tomsmith');
      cy.get('[name=password]').type('SuperSecretPassword!');
      cy.get('button').eq(0).click();
      cy.get('a').eq(3)
        .should('have.attr', 'href')
        .and('include', 'elementalselenium.com');
    })

    // Was attempting to test a successful Fetch call on login button but Cypress does not support
    // API call testing at the moment, and the suggested XML testing reports back as unreliable.

    // it('Should send a successful fetch request on submit', () => {
    //   cy.server({
    //     onResponse(response) {
    //       if (response.url.includes('/secure')) {
    //         console.log('response', response.body);
    //       }
    //     }
    //   });
    //   cy.route({
    //     method: 'GET',
    //     url: 'https://the-internet.herokuapp.com/secure',
    //   }).as('getLogin');
    //   cy.get('[name=username]').eq(0).type('tomsmith');
    //   cy.get('[name=password]').type('SuperSecretPassword!');
    //   cy.get('button').eq(0).click();
    //   cy.wait('@getLogin');
    // });
  });
});
