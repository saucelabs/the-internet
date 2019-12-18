## Adding an outside loop

 var i = 0;
        for (i = 0; i < 15 ; i++) {     
          describe('Click the Add Element Button. Test: '+i, function() {
            it('Add multiple buttons', function() {
            cy.get('#content > div > button').click({multiple: true});
        });
    });'