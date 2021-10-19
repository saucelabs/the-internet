# Testing the login component with Cypress
I decided to test the login component locally instead of the deployed [the-internet](https://the-internet.herokuapp.com/login) as that is how I would test a newly developed feature. 

## Cypress tests for the login component
The Cypress tests can be found in `./cypress/integration/login_spec.js`

##  Setup of the app
Install needed gems with `bundle install` and then start the app server with `rackup`

## Run the Cypress tests
Start Cypress with `npx cypress open` and run the `login_spec.js`







