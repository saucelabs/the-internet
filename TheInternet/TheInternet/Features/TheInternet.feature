Feature: BasicFeatures on the Internet

Scenario: Login on the Internet
Given the user wants to login to the Internet
When the user logins on the Internet 'correct'
Then the login is succesfull
When the user log out on the Internet
Then the logout is succesfull

Scenario: User upload a file
Given the user wants to upload a file
When the user upload a file
Then the upload is succesfull