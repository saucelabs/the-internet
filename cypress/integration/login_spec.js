describe('login page', () => {
	const correct_username = 'tomsmith'
	const correct_password = 'SuperSecretPassword!'

	beforeEach('', () => {
		cy.visit('/login')
	})

	it('has the correct title', () => {
		cy.contains('h2','Login Page')
	})

	it('gives an error message when username is wrong', () => {
		cy.get('[data-cy="inputUsername"]')
			.type('WrongUsername')

		cy.get('[data-cy="buttonLogin"]')
			.click()

		cy.contains('#flash', 'Your username is invalid!')
	})

	it('gives an error message when password is wrong', () => {
		cy.get('[data-cy="inputUsername"]')
			.type(correct_username)

		cy.get('[data-cy="inputPassword"]')
			.type('WrongPassword')

		cy.get('[data-cy="buttonLogin"]')
			.click()
			
		cy.contains('#flash', 'Your password is invalid!')
	})

	it('can log into and out of the secure area', () => {
		cy.get('[data-cy="inputUsername"]')
			.type(correct_username)

		cy.get('[data-cy="inputPassword"]')
			.type(correct_password)

		cy.get('[data-cy="buttonLogin"]')
			.click()

		cy.url().should('eq',`${Cypress.config("baseUrl")}/secure`)
		cy.contains('#flash', 'You logged into a secure area!')
		cy.contains('h2', 'Secure Area')

		cy.get('[data-cy="buttonLogout"]')
			.click()

		cy.url().should('eq',`${Cypress.config("baseUrl")}/login`)
		cy.contains('#flash','You logged out of the secure area!')
	})
})

describe('secure area', () => {
	
	it('forces you to log in to access the secure area', () => {
		cy.visit('/secure')

		cy.url().should('eq',`${Cypress.config("baseUrl")}/login`)
		cy.contains('You must login to view the secure area!')
	})
})