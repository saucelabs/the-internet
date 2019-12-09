describe('Add Delete Button', () => {
    before(() => {
        cy.visit('http://the-internet.herokuapp.com/');
    });

    it('Go to the Add/Deletet Page', () => {
        cy.get('#content > ul > li:nth-child(2) > a').click();
        cy.title().should('include', 'The Internet')
    });
    
    it('Should click Add Element Button',() =>{
        cy.wait(500)
        cy.get('button').click();
    });

    it('Should click Delete Element Button',()=> {
        cy.wait(500)
        cy.get('.added-manually').click();
    });
})