using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net.Http;

namespace OffBoardingOnBoarding.Data
{
    public class OffBoardingOnBoardingDataFromOData : IODataQuery
    {
        //private  readonly Log log = new Log(Logger);
        private readonly Log log = new Log();

        //public static ILog Logger { get; }

        public void GenerateFileFromOdataQuery()
        {
            String getOdataUrl = ConfigurationManager.AppSettings["OdataQuery"].ToString();
            String apiKeyValue = ConfigurationManager.AppSettings["CNSApiKey"].ToString();
            try
            {
                int j = 0;
                String jsonString = "";
                String fileHeader = string.Empty;
                String fileData = string.Empty;

                using (HttpClient client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("ApiKey", apiKeyValue);
                    //Get response from Odata Query
                    HttpResponseMessage response = client.GetAsync(getOdataUrl).Result;
                    response.EnsureSuccessStatusCode();
                    //Output from OdataQuery
                    jsonString = response.Content.ReadAsStringAsync().Result;
                }

                //Get all root values in dictionary as results[Deserializing json string] 
                JObject jsonObject = JObject.Parse(jsonString);
                IEnumerable<JToken> jTokens = jsonObject.Descendants().Where(p => p.Count() == 0);

                Dictionary<string, string> results = jTokens.Aggregate(new Dictionary<string, string>(), (properties, jToken) =>
                {
                    properties.Add(jToken.Path, jToken.ToString());
                    return properties;
                });
                results.Remove(results.Keys.First());

                //Write the dictionary data to file
                using (FileStream fs = new FileStream(String.Format(ConfigurationManager.AppSettings["FileFolder"].ToString() + ConfigurationManager.AppSettings["FileName"].ToString(), DateTime.Now.ToString("yyyyMMddHHmmss")), FileMode.CreateNew, FileAccess.ReadWrite))

                using (StreamWriter sw = new StreamWriter(fs))
                {
                    //Header(1st row)
                    foreach (string headers in results.Keys.Where(headers => headers.Contains("value[0]")))
                    {
                        fileHeader = fileHeader + ConfigurationManager.AppSettings["Delimiter"].ToString() + headers.Substring(9);
                    }
                    fileHeader = fileHeader.Substring(1) + Environment.NewLine;
                    sw.Write(fileHeader);
                    //Values
                    foreach (KeyValuePair<string, string> result in results)
                    {
                        if (result.Key == results.Keys.First())
                        {
                            fileData = result.Value;

                        }
                        else if (result.Key.Contains(String.Format("value[{0}]", j)))
                        {
                            fileData = fileData + ConfigurationManager.AppSettings["Delimiter"].ToString() + result.Value.ToString();
                        }
                        else
                        {
                            fileData = fileData + Environment.NewLine + result.Value.ToString();
                            j++;
                        }

                    }
                    sw.Write(fileData);
                }
               log.Message("GenerateFileFromOdataQuery", "File Generated Successfully", "Info", "", null);

            }

            catch (Exception ex)
            {
                log.Message("GenerateFileFromOdataQuery", "", "Error", "", ex);
            }
        }
      
    }
}
