describe('Add Delete Button', () => {
    before(() => {
        cy.visit('http://the-internet.herokuapp.com/');
    });

    it('Go to the Add/Delete Page', () => {
        cy.get('#content > ul > li:nth-child(2) > a').click();
        cy.title().should('include', 'The Internet')
    });
    
    it('Should click Add Element Button 15 times',() =>{
        var i = 0;
        for (i = 0; i < 15 ; i++) { 
          //Place code inside the loop that you want to repeat
          cy.get('#content > div > button').click({multiple: true});
         } 
       
    });

    it('Should click Delete  Element Button 15 times',() =>{
        var i = 0;
        for (i = 0; i < 15 ; i++) { 
          //Place code inside the loop that you want to repeat
          cy.get('#elements > :nth-child(1)').click({multiple: true});
         } 
       
    });
  
});