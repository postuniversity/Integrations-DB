using System;
using System.Collections.Generic;
using System.Text;
using log4net;

namespace OffBoardingOnBoarding.Data
{
    public class Log
    {
        public Log()
        {

        }
        public Log(ILog logger)
        {
            Logger = logger;
        }
        public ILog Logger { get; set; }

        public void Message(string Page, string logMessage, string Severity, string StudentID, Exception ex)
        {
            if (ex != null)
            {
                logMessage += " - Exception Message:";
                if (ex.Message != null)
                {
                    logMessage += Convert.ToString(ex.Message);
                    logMessage += " | Source: " + Convert.ToString(ex.Source);
                    if (ex.InnerException != null && ex.InnerException.Message != null)
                        logMessage += " | Inner Exception:" + Convert.ToString(ex.InnerException.Message);
                    logMessage += " | Stack Trace : " + Convert.ToString(ex.StackTrace);
                }

            }

            if (Severity == "Info")
            {
                Logger = log4net.LogManager.GetLogger("","InfoLogFile");
                Logger.Info("Info" + "|" + StudentID + "|" + logMessage);
            }
            else if (Severity == "Error")
            {
                Logger = log4net.LogManager.GetLogger("","ErrorLogFile");
                Logger.Error("Error" + "|" + StudentID + "|" + logMessage);
            }

        }
    }
}
