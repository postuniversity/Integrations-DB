namespace OffBoardingOnBoarding.Data
{
    /// <summary>
    /// 
    /// </summary>
    public interface IODataQuery
    {
      int GenerateFileFromOdataQuery(string odataQuery, string cnsAPIKey);
    }
}
