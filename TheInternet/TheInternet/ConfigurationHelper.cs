//using System.IO;
//using Microsoft.Extensions.Configuration;

//namespace TheInternet
//{
//    internal static class ConfigurationHelper
//    {
//        public static IConfiguration AppSettings { get; }

//        public static string TheInternetBaseUrl => AppSettings["The_Internet"];
//        static ConfigurationHelper()
//        {
//            AppSettings = new ConfigurationBuilder()
//                .SetBasePath(Directory.GetCurrentDirectory())
//                .AddJsonFile("appSettings.json")
//                .Build();
//        }

//    }

//}