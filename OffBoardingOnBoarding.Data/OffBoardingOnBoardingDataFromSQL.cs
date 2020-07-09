using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace OffBoardingOnBoarding.Data
{
    public class OffBoardingOnBoardingDataFromSQL : ISqlQuery
    {
        //private  readonly Log log = new Log(Logger);
        private readonly Log log = new Log();
        public void GenerateFileFromSqlQuery()
       {
            String constring = ConfigurationManager.ConnectionStrings["ConnectionString"].ToString();
            bool successfulRun = false;
            DateTime successfulRunTime = DateTime.Now;
            string sqlFormattedSuccessfulRunTime = successfulRunTime.ToString("yyyy-MM-dd HH:mm:ss.fff");
            try
            {
                using (FileStream fs = new FileStream(String.Format(ConfigurationManager.AppSettings["FileFolder"].ToString() + ConfigurationManager.AppSettings["FileName"].ToString(), successfulRunTime.ToString("yyyyMMddHHmmss")), FileMode.CreateNew, FileAccess.ReadWrite))

                using (StreamWriter sw = new StreamWriter(fs))
                {
                    //Connecting to the server
                    using (SqlConnection con = new SqlConnection(constring))
                    {
                        //Get the SQL query
                        using (SqlCommand cmd = new SqlCommand(String.Format(ConfigurationManager.AppSettings["SqlQuery"].ToString(), sqlFormattedSuccessfulRunTime), con))
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
                                    fileHeader = fileHeader + reader.GetName(i) + ConfigurationManager.AppSettings["Delimiter"].ToString();
                                }
                                fileHeader = fileHeader.Remove(fileHeader.Length - 1, 1) + Environment.NewLine;
                                sw.Write(fileHeader);

                                //write Data
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
                                            fileData = fileData + byteString + ConfigurationManager.AppSettings["Delimiter"].ToString();
                                        }
                                        else
                                            fileData = fileData + reader.GetValue(i) + ConfigurationManager.AppSettings["Delimiter"].ToString();
                                    }

                                    //Write every row by removing last delimiter and move to next line
                                    fileData = fileData.Remove(fileData.Length - 1, 1) + Environment.NewLine;
                                    sw.Write(fileData);
                                }
                            }
                            con.Close();
                            successfulRun = true;
                        }
                    }
                }
                //log.Message("GenerateFileFromSqlQuery", "File Generated Successfully", "Info", "", null);
                if (successfulRun == true)
                {
                    //Update SuccessfulRunTime in Table
                    try
                    {
                        using (SqlConnection con = new SqlConnection(constring))
                        {
                            using (SqlCommand cmd = new SqlCommand(String.Format(ConfigurationManager.AppSettings["UpdateSuccessfulRunTimeQuery"].ToString(), sqlFormattedSuccessfulRunTime), con))
                            {
                                con.Open();
                                cmd.CommandType = CommandType.Text;
                                SqlDataReader reader = cmd.ExecuteReader();
                                log.Message("UpdateSuccessfulRunTime", "Updated Successful Runtime in table", "Info", "", null);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        log.Message("UpdateSuccessfulRunTime", "", "Error", "", ex);
                    }
                }
            }
            catch (Exception ex)
            {
                log.Message("GenerateFileFromSqlQuery", "", "Error", "", ex);
            }
        }
    }
}
