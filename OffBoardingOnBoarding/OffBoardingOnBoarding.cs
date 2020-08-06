using OffBoardingOnBoarding.Data;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Text;

namespace OffBoardingOnBoardingLib
{
    internal class GenerateFile
    {

        //Declaring logger
        // private static ILog logger;
        private static void Main(string[] args)
        {
            
            //InitLog;
            //log4net.Config.XmlConfigurator.ConfigureAndWatch();
            // If directory does not exist, create it. 
            if (!Directory.Exists(ConfigurationManager.AppSettings["FileFolder"].ToString()))
            {
                Directory.CreateDirectory(ConfigurationManager.AppSettings["FileFolder"].ToString());
            }
            //Generate csv file using Odata query
            if (ConfigurationManager.AppSettings["Query"].ToString().ToUpper() == "ODATAQUERY")
                .GenerateFileFromOdataQuery();

            //Generate csv file using Sql query
            else if (ConfigurationManager.AppSettings["Query"].ToString().ToUpper() == "SQLQUERY")
                generateFile.GenerateFileFromSqlQuery();
        }
    }

        public class OffBoardingOnBoarding
    {
       
        public OffBoardingOnBoarding(IODataQuery odataQuery,ISqlQuery sqlQuery)
        {
            OdataQuery = odataQuery;
            SqlQuery = sqlQuery;
        }

        public IODataQuery OdataQuery { get; }
        public ISqlQuery SqlQuery { get; }

        public void GenerateFile()
        {
            if (!Directory.Exists(ConfigurationManager.AppSettings["FileFolder"].ToString()))
            {
                Directory.CreateDirectory(ConfigurationManager.AppSettings["FileFolder"].ToString());
            }
            //Generate csv file using Odata query
            if (ConfigurationManager.AppSettings["Query"].ToString().ToUpper() == "ODATAQUERY")
                OdataQuery.GenerateFileFromOdataQuery();

            //Generate csv file using Sql query
            else if (ConfigurationManager.AppSettings["Query"].ToString().ToUpper() == "SQLQUERY")
                SqlQuery.GenerateFileFromSqlQuery();
        }
    }
}
