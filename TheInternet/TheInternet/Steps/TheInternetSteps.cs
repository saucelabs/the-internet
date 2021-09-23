using System;
using TechTalk.SpecFlow;
using FluentAssertions;
using OpenQA.Selenium;


namespace TheInternet.Steps

{
    [Binding]
    public class TheInternetSteps
    {

        private readonly IWebDriver _driver;

        public TheInternetSteps(IWebDriver driver)
        {
            _driver = driver;
        }


        [Given(@"the user wants to login to the Internet")]
        public void GivenTheUserWantsToLoginToTheInternet()
        {
            //Navigat to url
            _driver.Navigate().GoToUrl("https://the-internet.herokuapp.com/basic_auth");
        }

        [When(@"the user logins on the Internet '(.*)'")]
        public void WhenTheUserLoginsOnTheInternet(string inlog)
        {
            // if statement als de klant gaat inloggen

            _driver.FindElement(By.Id("username")).SendKeys("tomsmith");
            _driver.FindElement(By.Id("password")).SendKeys("SuperSecretPassword!");
            _driver.FindElement(By.ClassName("radius")).Click();

        }
        [When(@"the user log out on the Internet")]
        public void WhenTheUserLogOutOnTheInternet()
        {
            //ScenarioContext.Current.Pending();
        }

        [Then(@"the logout is succesfull")]
        public void ThenTheLogoutIsSuccesfull()
        {
            //ScenarioContext.Current.Pending();
        }



        [Then(@"the login is succesfull")]
        public void ThenTheLoginIsSuccesfull()
        {
         // usser is succesfull logged

         _driver.FindElement(By.Id("flash"));
         _driver.PageSource.Should().Contain("Welcom to the Secure Area");

        }

    }
}