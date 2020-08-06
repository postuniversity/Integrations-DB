using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;

namespace OffBoardingOnBoarding.Data
{
    /// <summary>
    /// 
    /// </summary>
    public class OffBoardingOnBoardingDataFromSQL : ISqlQuery
    {
        /// <summary>
        /// 
        /// </summary>
        public string ConnectionString { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FileFolder { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FileName { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string SqlQUery { get; set; }
        /// <summary>
        /// /
        /// </summary>
        public string Delimeter { get; set; }
        /// <summary>
        /// /
        /// </summary>
        public string UpdateSuccessfulRunTimeQuery { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public OffBoardingOnBoardingDataFromSQL()
        {
            ConnectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ToString();
            FileFolder = ConfigurationManager.AppSettings["FileFolder"].ToString();
            FileName = ConfigurationManager.AppSettings["FileName"].ToString();
            SqlQUery = ConfigurationManager.AppSettings["SqlQuery"].ToString();
            Delimeter = ConfigurationManager.AppSettings["Delimiter"].ToString();
            UpdateSuccessfulRunTimeQuery = ConfigurationManager.AppSettings["UpdateSuccessfulRunTimeQuery"].ToString();
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="log"></param>
        public OffBoardingOnBoardingDataFromSQL(log4net.ILog log)
        {
            Log = log;
        }
        //private  readonly Log log = new Log(Logger);
        /// <summary>
        /// 
        /// </summary>
        //private readonly Log log = new Log();

        /// <summary>
        /// /
        /// </summary>
        public log4net.ILog Log { get; }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public int GenerateFileFromSqlQuery()
        {
            bool successfulRun = false;
            var successfulRunTime = DateTime.Now;
            var sqlFormattedSuccessfulRunTime = successfulRunTime.ToString("yyyy-MM-dd HH:mm:ss.fff", CultureInfo.CreateSpecificCulture("en-US"));
            var filefolderformattted = String.Format(FileFolder + FileName, successfulRunTime.ToString("yyyyMMddHHmmss"));
            var sqlstringformatted = string.Format(SqlQUery, sqlFormattedSuccessfulRunTime);
            
            try
            {
                using (FileStream fs = new FileStream(filefolderformattted, FileMode.CreateNew, FileAccess.ReadWrite))
                {
                    using (StreamWriter sw = new StreamWriter(fs))
                    {
                        //Connecting to the server
                        using (SqlConnection con = new SqlConnection(ConnectionString))
                        {
                            //Get the SQL query
                            using (SqlCommand cmd = new SqlCommand(sqlstringformatted, con))
                            {
                                con.Open();
                                cmd.CommandType = CommandType.Text;
                                string fileHeader = string.Empty;

                                //Used datareader to execute the query
                                using (SqlDataReader reader = cmd.ExecuteReader())
                                {
                                    //write headers
                                    for (int i = 0; i < reader.FieldCount; i++)
                                    {
                                        fileHeader = fileHeader + reader.GetName(i) + Delimeter;
                                    }
                                    fileHeader = fileHeader.Remove(fileHeader.Length - 1, 1) + Environment.NewLine;
                                    sw.Write(fileHeader);

                                    //write Data
                                    GenerateFile(sw, reader);
                                }
                                con.Close();
                                successfulRun = true;
                            }
                        }
                    }
                }
                //log.Message("GenerateFileFromSqlQuery", "File Generated Successfully", "Info", "", null);
                if (successfulRun == true)
                {
                    var UpdateSuccessfulRunTimeQueryformat = string.Format(UpdateSuccessfulRunTimeQuery, sqlFormattedSuccessfulRunTime);
                    //Update SuccessfulRunTime in Table
                    UpdateSuccessfulRunTime(UpdateSuccessfulRunTimeQueryformat);
                }
                return 0;
            }
            catch (Exception ex)
            {
                //log.Message("GenerateFileFromSqlQuery", "", "Error", "", ex);
                return -1;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sw"></param>
        /// <param name="reader"></param>
        private void GenerateFile(StreamWriter sw, SqlDataReader reader)
        {
            while (reader.Read())
            {
                String fileData = string.Empty;

                for (int i = 0; i < reader.FieldCount; i++)
                {
                    //Check for advanced datatypes
                    if (reader.GetFieldType(i) == typeof(Byte[]) && reader.IsDBNull(i) == false)
                    {
                        byte[] byteArray = (Byte[])reader.GetValue(i);
                        string byteString = Convert.ToBase64String(byteArray);
                        fileData = fileData + byteString + Delimeter;
                    }
                    else
                        fileData = fileData + reader.GetValue(i) + Delimeter;
                }

                //Write every row by removing last delimiter and move to next line
                fileData = fileData.Remove(fileData.Length - 1, 1) + Environment.NewLine;
                sw.Write(fileData);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="UpdateSuccessfulRunTimeQueryformat"></param>
        private void UpdateSuccessfulRunTime(string UpdateSuccessfulRunTimeQueryformat)
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(UpdateSuccessfulRunTimeQueryformat, con))
                {
                    con.Open();
                    cmd.CommandType = CommandType.Text;
                    SqlDataReader reader = cmd.ExecuteReader();
                    //log.Message("UpdateSuccessfulRunTime", "Updated Successful Runtime in table", "Info", "", null);
                }
            }
        }
    }
}
