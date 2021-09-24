using System;
using System.ComponentModel;
using TechTalk.SpecFlow;
using FluentAssertions;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using TheInternet.Helper;


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
            //normaal zou je hier een algemene ConfigurationHelper bouwen zodat je die Uri kan aanroepen alleen die /site toe te voegen. Hier kwam ik niet helemaal uit in mijn eentje, vandaar dat het nu vrij kort de bocht is gebouwd// 

            //Navigat to url
            IWebDriver driver = new ChromeDriver();
            String baseUrl = "https://the-internet.herokuapp.com/basic_auth/";
            driver.Navigate().GoToUrl(baseUrl);
        }

        [Given(@"the user wants to upload a file")]
        public void GivenTheUserWantsToUploadAFile()
        {
            //navigate to url upload page

            IWebDriver driver = new ChromeDriver();
            String baseUrl = "https://the-internet.herokuapp.com/upload";
            driver.Navigate().GoToUrl(baseUrl);
        }


        [When(@"the user logins on the Internet '(.*)'")]
        public void WhenTheUserLoginsOnTheInternet(string inlog)
        {
            // if statement als de klant gaat inloggen
            switch (inlog)
            {
                case "correct":
                    _driver.FindElement(By.Id("username")).SendKeys("tomsmith");
                    _driver.FindElement(By.Id("password")).SendKeys("SuperSecretPassword!");
                    _driver.FindElement(By.ClassName("radius")).Click();
                    break;
                case "wrong":
                    _driver.FindElement(By.Id("username")).SendKeys("Blabla");
                    _driver.FindElement(By.Id("password")).SendKeys("NotaPassword&");
                    _driver.FindElement(By.ClassName("radius")).Click();
                    break;
            }

            throw new Exception($"Input {inlog} cann't be found");
        }


        [When(@"the user log out on the Internet")]
        public void WhenTheUserLogOutOnTheInternet()
        {
            _driver.FindElement(By.XPath("//button[text()='logout]'")).Click();
        }

        [When(@"the user upload a file")]
        public void WhenTheUserUploadAFile()
        {
            //Hier struggle ik een beetje mee met het uploaden van een file, zoals je ziet....//

            var file = _driver.FindElement(By.Id("file-upload"));
            string filePath = @"C:\\Users\\kayung.cheung\\Desktop\\Temp\\the-internet\\TheInternet\\TheInternet\\InputFiles";
            file.Click();
            file.SendKeys(filePath);
            _driver.FindElement(By.Id("file-submit")).Click();

        }

        [Then(@"the logout is succesfull")]
        public void ThenTheLogoutIsSuccesfull()
        {
            var logout = _driver.FindElement(By.Id("flash"));
            logout.Should().Be("You logged out of the secure area!");
        }
        
        [Then(@"the login is succesfull")]
        public void ThenTheLoginIsSuccesfull()
        {
            _driver.FindElement(By.Id("flash"));
            _driver.PageSource.Should().Contain("Welcom to the Secure Area");

        }

        [Then(@"the upload is succesfull")]
        public void ThenTheUploadIsSuccesfull()
        {
            var succes = _driver.FindElement(By.Id("content"));
            succes.Should().Be("File Uploaded!");
        }
    }
}