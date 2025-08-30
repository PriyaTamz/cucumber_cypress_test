import { Given, When, Then } from '@badeball/cypress-cucumber-preprocessor';
import { selectors } from '../selectors/selectors';

Given('I am on the login page', function() {
    cy.fixture('testData.json').then((data) => {
        cy.visit(data.url);
    });
});

When('I enter valid credentials', function() {
    cy.fixture('testData.json').then((data) => {
        cy.get(selectors.usernameTextbox).type(data.username).should('have.value', data.username);
        cy.get(selectors.passwordTextbox).type(data.password).should('have.value', data.password);
    });
});

Then('I should be redirected to dashboard', function() {
    cy.get(selectors.loginButton).click();
});

