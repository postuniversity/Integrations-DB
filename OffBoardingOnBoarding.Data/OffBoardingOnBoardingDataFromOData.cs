using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net.Http;

namespace OffBoardingOnBoarding.Data
{
    /// <summary>
    /// 
    /// </summary>
    public class OffBoardingOnBoardingDataFromOData : IODataQuery
    {    
        public int GenerateFileFromOdataQuery(string odataQuery, string cnsAPIKey)
        {             
            try
            {                
                var odataResult = string.Empty;
                //http call to get odata query
                using (HttpClient client = new HttpClient())
                {
                    //add apikey to headers
                    client.DefaultRequestHeaders.Add("ApiKey", cnsAPIKey);
                    //Get response from Odata Query
                    var httpResponse = client.GetAsync(odataQuery).Result;
                    httpResponse.EnsureSuccessStatusCode();
                    //Output from OdataQuery
                    odataResult = httpResponse.Content.ReadAsStringAsync().Result;
                }
                //Get all root values in dictionary as results[Deserializing json string] 
                var jsonData = getDataFromJSON(odataResult);
                //Write the dictionary data to file
                GenerateFile(jsonData);                
                //log.Message("GenerateFileFromOdataQuery", "File Generated Successfully", "Info", "", null);
                return 0;
            }
            catch (Exception ex)
            {
                return -1;
                //throw ;
                log.Message("GenerateFileFromOdataQuery", "", "Error", "", ex);                
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="results"></param>
        private void GenerateFile(Dictionary<string, string> results)
        {
            String fileHeader = string.Empty;
            String fileData = string.Empty;
            int j = 0;
            string fileFormatted = ConfigurationManager.AppSettings["FileFolder"].ToString() + ConfigurationManager.AppSettings["FileName"].ToString();

            using (FileStream fs = new FileStream(String.Format(fileFormatted, DateTime.Now.ToString("yyyyMMddHHmmss")), FileMode.CreateNew, FileAccess.ReadWrite))
            {
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
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="odataResult"></param>
        /// <returns></returns>
        private static Dictionary<string, string> getDataFromJSON(string odataResult)
        {
            JObject jsonObject = JObject.Parse(odataResult);

            IEnumerable<JToken> jTokens = jsonObject.Descendants().Where(p => p.Count() == 0);

            //get json nodes as Key,Values
            Dictionary<string, string> results = jTokens.Aggregate(new Dictionary<string, string>(), (properties, jToken) =>
            {
                properties.Add(jToken.Path, jToken.ToString());
                return properties;
            });
            //remove first value which is not usefule @odatacontext....
            results.Remove(results.Keys.First());
            return results;
        }
    }
}
