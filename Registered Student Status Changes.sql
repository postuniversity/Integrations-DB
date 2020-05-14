-- Database Scripts
--WORKFLOW#1 SCRIPTS
DROP TABLE customer.RegisteredStatusByCourseMap
GO
Create Table customer.RegisteredStatusByCourseMap
(
RegisteredStatusByCourseMapId INT IDENTITY NOT NULL UNIQUE CLUSTERED,
InitialSySchoolStatusID INT NOT NULL REFERENCES SySchoolStatus(SySchoolStatusID),
SyStatusID INT NOT NULL ,
CourseSelected VARCHAR(1) NOT NULL,
FinalSySchoolStatusID INT NOT NULL,
[Description] VARCHAR(MAX) NOT NULL,
DateAdded DATETIME NOT NULL,
DateLstMod DATETIME NOT NULL,
CONSTRAINT [PK_RegisteredStatusByCourseMap] 
PRIMARY KEY (InitialSySchoolStatusID,CourseSelected,FinalSySchoolStatusID))
GO
INSERT INTO customer.RegisteredStatusByCourseMap (InitialSySchoolStatusID,SyStatusID,CourseSelected,FinalSySchoolStatusID,[Description],DateAdded,DateLstMod) VALUES
--Forward Status
(60,5,'Y',90,'Status Change from Provisionally Accepted to Registered Provisionally Accepted',GetDate(),''),
(101,7,'Y',91,'Status Change from Provisionally ReEntry(Re-Entry Category) to Registered Provisionally ReEntry',GetDate(),''),
(89,5,'Y',91,'Status Change from Provisionally ReEntry(FutureStart Category) to Registered Provisionally ReEntry',GetDate(),''),
(61,5,'Y',92,'Status Change from Provisionally ReAdmit to Registered Provisionally ReAdmit',GetDate(),''),
(79,5,'Y',93,'Status Change from Accepted to Registered Accepted',GetDate(),''),
(7,7,'Y',94,'Status Change from ReEntry(Re-Entry Category) to Registered ReEntry',GetDate(),''),
(105,5,'Y',94,'Status Change from ReEntry(FutureStart Category) to Registered ReEntry',GetDate(),''),
(96,5,'Y',95,'Status Change from ReAdmit to Registered ReAdmit',GetDate(),''),
--Reverse Staus
(90,5,'N',60,'Status Change from Registered Provisionally Accepted to Provisionally Accepted',GetDate(),''),
(91,5,'N',89,'Status Change from Registered Provisionally ReEntry to Provisionally ReEntry',GetDate(),''),
(92,5,'N',61,'Status Change from Registered Provisionally ReAdmit to Provisionally ReAdmit',GetDate(),''),
(93,5,'N',79,'Status Change from Registered Accepted to Accepted',GetDate(),''),
(94,5,'N',105,'Status Change from Registered ReEntry to ReEntry',GetDate(),''),
(95,5,'N',96,'Status Change from Registered ReAdmit to ReAdmit',GetDate(),'')
GO


--AutoEnrollment and WorkFlow#2 SCRIPTS
DROP TABLE customer.RegisteredStatusByPOGMap
GO
Create Table customer.RegisteredStatusByPOGMap   
(
RegisteredStatusByPOGMapId INT IDENTITY NOT NULL UNIQUE CLUSTERED,
InitialSySchoolStatusID INT NOT NULL,
SyStatusID INT NOT NULL,
FinalSySchoolStatusID INT NOT NULL,
[Description] VARCHAR(MAX) NOT NULL,
DateAdded DATETIME NOT NULL,
DateLstMod DATETIME NOT NULL
CONSTRAINT [PK_RegisteredStatusByPOGMap] PRIMARY KEY  
(InitialSySchoolStatusID,FinalSySchoolStatusID))
GO
INSERT INTO customer.RegisteredStatusByPOGMap(InitialSySchoolStatusID,SyStatusID,FinalSySchoolStatusID,[Description],DateAdded,DateLstMod)VALUES
(60,5,79,'Status Change (Provisionally Accepted, POG => Accepted)',GETDATE(),''),
(101,7,105,'Status Change (Provisionally ReEntry,POG => ReEntry)',GETDATE(),''),
(89,5,105,'Status Change (Provisionally ReEntry,POG => ReEntry)',GETDATE(),''),
(61,5,96,'Status Change (Provisionally ReAdmit,POG => ReAdmit)',GETDATE(),''),
(90,5,93,'Status Change (Registered Provisionally Accepted, POG => Registered Accepted)',GETDATE(),''),
(91,5,94,'Status Change (Registered Provisionally ReEntry,POG => Registered ReEntry)',GETDATE(),''),
(92,5,95,'Status Change (Registered Provisionally ReAdmit => Registered ReAdmit)',GETDATE(),''),
(88,5,13,'Status Change (Provisionally Active,POG => Active)',GETDATE(),'')
GO

--Category Mapping
Create Table customer.RegisteredStatusByCategoryMap   
(
RegisteredStatusByCategoryMapId INT IDENTITY NOT NULL UNIQUE CLUSTERED,
InitialSySchoolStatusID INT NOT NULL,
FinalSySchoolStatusID INT NOT NULL,
[Description] VARCHAR(MAX) NOT NULL,
DateAdded DATETIME NOT NULL,
DateLstMod DATETIME NOT NULL
CONSTRAINT [PK_RegisteredStatusByCategoryMap] PRIMARY KEY  
(InitialSySchoolStatusID,FinalSySchoolStatusID))
GO

Insert Into customer.RegisteredStatusByCategoryMap (InitialSySchoolStatusID,FinalSySchoolStatusID,[Description],DateAdded,DateLstMod)Values
(101,89,'Status Change from Provisioanlly Re-Entry(Re-Entry Category) to Provisioanlly Re-Entry(Future Start Category)',GETDATE(),''),
(7,105,'Status Change from Re-Entry(Re-Entry Category) to Re-Entry(Future Start Category)',GETDATE(),'')
GO

--*******************************************CUSTOMER_SCHEMA--Si_Configurations & SP*****************************************************************************
--Customer Schema Config Table
CREATE TABLE [customer].[si_Configurations](
	[ConfigurationId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Key] [varchar](200) NOT NULL,
	[Value] [varchar](max) NOT NULL,
	[DataType] [varchar](50) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[Prompt] [varchar](50) NOT NULL,
	[ListType] [char](1) NOT NULL,
	[ValueList] [varchar](1000) NULL,
	[LongPrompt] [varchar](255) NOT NULL,
	[MaxLength] [tinyint] NOT NULL,
	[UserId] [int] NOT NULL,
	[DateAdded] [datetime] NOT NULL,
	[DateLstMod] [datetime] NOT NULL,
	[TS] [timestamp] NOT NULL,
	[ConfigType] [varchar](1) NOT NULL,
	[PackageNameId] [int] NULL,
 CONSTRAINT [PK_si_Configurations_ConfigurationId] PRIMARY KEY CLUSTERED 
(
	[ConfigurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [customer].[si_Configurations] ADD  CONSTRAINT [Def_si_Configurations_DateAdded]  DEFAULT (getdate()) FOR [DateAdded]
GO

ALTER TABLE [customer].[si_Configurations] ADD  CONSTRAINT [Def_si_Configurations_DateLstMod]  DEFAULT (getdate()) FOR [DateLstMod]
GO

ALTER TABLE [customer].[si_Configurations] ADD  DEFAULT ('G') FOR [ConfigType]
GO

--Customer Schema Config Data 
Insert Into [customer].[si_Configurations]([Key],[Value],[DataType],[DisplayOrder],[Prompt],[ListType],[ValueList],[LongPrompt],[MaxLength],[UserId],[DateAdded]) values
('GetAutoEnroll_ProvisionallyAcceptedStatusCode','PROVACC','',40,'AutoEnroll_ProvisionallyAcceptedStatusCode','s','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Provisionally Accepted Ending status for AutoEnrollment Workflow',0,1,GETDATE()),
('GetAutoEnroll_ProvisionallyRe-AdmitStatusCode','PROVREAD','',40,'AutoEnroll_ProvisionallyRe-AdmitStatusCode','s','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Provisionally Re-Admit Ending status for AutoEnrollment Workflow',0,1,GETDATE()),
('GetRegistered_SchoolStatus_TriggerStatusCode','PROVACC,PROVREAD,PROVREN,PRVREN2,ACCEPT,REN2,REENTRY,READM','',40,'Registered_SchoolStatus_TriggerStatusCode','m','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Valid Status Codes to change Registered School Status',0,1,GETDATE()),
('GetRegistered_SchoolStatus_ReverseTriggerStatusCode','REGPRAC,REGPRVRA,REGPRVRE,REGACC,REGREAD,REGREN','',40,'Registered_SchoolStatus_ReverseTriggerStatusCode','m','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Valid Status Codes to change Non-Registered School Staus Change',0,1,GETDATE())
GO

--SP Depends on Configs

DROP PROCEDURE [customer].[SPROC_Registered_SchoolStatus_GetConfiguration]
GO
CREATE PROCEDURE [customer].[SPROC_Registered_SchoolStatus_GetConfiguration] @AdenrollID Int  
AS  
BEGIN  
 BEGIN TRANSACTION  
 BEGIN TRY  
  
 BEGIN  
 DECLARE @ValidStatusToMoveStatusForward VARCHAR(MAX)  
 DECLARE @ValidStatusToReverseStatusBack VARCHAR(MAX)
 ----Begin validTriggeringStatus Check
 SELECT @ValidStatusToMoveStatusForward = [value]  
 FROM [customer].[si_Configurations] a(NOLOCK)  
 WHERE [Key] = 'GetRegistered_SchoolStatus_TriggerStatusCode'  
 --select * from [customer].[si_Configurations] a (NOLOCK) WHERE [Key] = 'GetRegistered_SchoolStatus_TriggeringStatusCode'  
  
 CREATE TABLE #SySchoolStatus (  
  Id INT  
 ,Code VARCHAR(50)  
 )  
  
 INSERT INTO #SySchoolStatus (  
  Id  
 ,Code  
 )  
 SELECT 0  
 ,rtrim(ltrim(ListValue))  
 FROM dbo.dv_StrSplit(@ValidStatusToMoveStatusForward, ',')  
  
 UPDATE #SySchoolStatus  
 SET Id = b.SySchoolStatusId  
 FROM #SySchoolStatus a  
 JOIN SySchoolStatus b(NOLOCK)  
 ON b.Code = a.Code  
  
 -----Begin validReverseTriggeringStatus Check
  SELECT @ValidStatusToReverseStatusBack = [value]  
 FROM [customer].si_Configurations a(NOLOCK)  
 WHERE [Key] = 'GetRegistered_SchoolStatus_ReverseTriggerStatusCode'  
 --select * from [customer].si_Configurations a (NOLOCK) WHERE [Key] = 'GetRegistered_SchoolStatus_ReverseTriggerStatusCode'  
  
 CREATE TABLE #SyReverseSchoolStatus (  
  Id INT  
 ,Code VARCHAR(50)  
 )  
  
 INSERT INTO #SyReverseSchoolStatus (  
  Id  
 ,Code  
 )  
 SELECT 0  
 ,rtrim(ltrim(ListValue))  
 FROM dbo.dv_StrSplit(@ValidStatusToReverseStatusBack, ',')  
  
 UPDATE #SyReverseSchoolStatus  
 SET Id = b.SySchoolStatusId  
 FROM #SyReverseSchoolStatus a  
 JOIN SySchoolStatus b(NOLOCK)  
 ON b.Code = a.Code


 SELECT 
 CASE WHEN EXISTS  
  (  
  SELECT *  
  FROM Adenroll (Nolock)  
  JOIN #SySchoolStatus ON Adenroll.SyschoolstatusID = #SySchoolStatus.id  
  --WHERE AdenrollID = 71739  
  WHERE AdenrollID = @AdenrollID  
  )  
 THEN 'True'  
 ELSE 'False'  
 END as IsValidToMoveStatusForward,  
 CASE WHEN EXISTS  
  (  
  SELECT *  
  FROM Adenroll (Nolock)  
  JOIN #SyReverseSchoolStatus ON Adenroll.SyschoolstatusID = #SyReverseSchoolStatus.id  
  --WHERE AdenrollID = 71736  
  WHERE AdenrollID = @AdenrollID  
  )  
 THEN 'True'  
 ELSE 'False'  
 END as IsValidToReverseStatusBack,

   Count(*) AS RegisteredCourseStatusCount  
  FROM AdEnrollSched (Nolock)  
  --WHERE AdenrollID = 71736  
  WHERE AdenrollID = @AdenrollID and Status IN ('C','S')  
 END  
  
 IF OBJECT_ID('tempdb..#SySchoolStatus') IS NOT NULL  
 DROP TABLE #SySchoolStatus  
 IF OBJECT_ID('tempdb..#SyReverseSchoolStatus') IS NOT NULL  
 DROP TABLE #SyReverseSchoolStatus  
  
 COMMIT TRANSACTION  
 END TRY  
  
 BEGIN CATCH  
 ROLLBACK TRANSACTION  
 END CATCH  
END 

GO

--*******************************************Update Advisor Assignment*************************************************************

Update si_Configurations set [Value]=('ACCEPT,NDSENR,PROVACC,PROVREAD,PRVREN2,READM,REENTRY') where [Key]='GetAdvisorAssignment_TriggerStatusCodes'
