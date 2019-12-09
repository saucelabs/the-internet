describe('Add Delete Button', () => {
    before(() => {
        cy.visit('http://the-internet.herokuapp.com/');
    });

    it('Go to the Add/Deletet Page', () => {
        cy.get('#content > ul > li:nth-child(2) > a').click();
        cy.title().should('include', 'The Internet')
    });
    
    it('Should click Add Element Button',() =>{
        var i = 0;
        for (i = 0; i < 5 ; i++) { 
          //Place code inside the loop that you want to repeat
          cy.get('button').click({multiple: true});
         } 
       
        });


    it('Should click Delete Element Button',()=> {
        cy.wait(500)
        cy.get('.added-manually').click();
    });
});