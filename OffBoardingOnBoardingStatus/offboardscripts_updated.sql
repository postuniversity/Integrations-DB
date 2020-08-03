	  -- 1. table  
	   select * from Customer.OffBoardOnBoardStatusReport;
      --1.1 drop table Customer.OffBoardOnBoardStatusReport;
	  -- 1.2
	  Create Table Customer.OffBoardOnBoardStatusReport(
														[Id] INT IDENTITY NOT NULL PRIMARY KEY,
														[Source] VARCHAR(50) NOT NULL, -- sql or odata
														[StartTime] [datetime] NOT NULL, -- start time of report generation
														[EndTime] [datetime] NULL,  -- end time of report generation
														[Comments] [ntext] NULL, -- sql query or odata url with additional info
														[Status] [varchar](50) NOT NULL, -- completed, error, ok, etc
														[SuccessfulRuntime] [DATETIME], -- next run will based on this time so that (this time - 365 days)
														[TotalRecordCount] [int] NULL, -- total no of records going into file
														[OutputFileName] [varchar](2500) NULL, -- outputfile name
														[OutputFileLocation] [varchar](2500) NULL, -- location where file is saved
														[UserId] [int] NOT NULL,
														[DateAdded] [datetime],
														[DateLstMod] [datetime] NOT NULL)
	GO

	---save data
	******** -- saveinfo*******************************
	 **************************************************************************************************
	IF OBJECT_ID ( '[customer].[SaveOffBoardOnBoardStatusReport]', 'P' ) IS NOT NULL
        DROP PROCEDURE [customer].[SaveOffBoardOnBoardStatusReport];
       GO

	CREATE PROCEDURE [customer].[SaveOffBoardOnBoardStatusReport] 
			  @Source varchar(50),-- sql or odata
			  @StartTime varchar(50), -- convert to datetie when inserting
			  @EndTime varchar(50) , -- convert to datetime when inserting
			  @Comments ntext , -- additional details like sql query or odataurl
			  @Status varchar(50) , -- status completed or error
			  @SuccessfulRuntime varchar(50), -- last successful runtime
			  @TotalRecordCount int, -- no of records in report
			  @OutputFileName varchar (250), -- 
			  @OutputFileLocation varchar(2500), -- 
			  @UserId int, 
			  @id int output
	AS
		BEGIN
		 declare @dt datetime;
		       if isnull(@SuccessfulRuntime,'')= ''  
			   begin
			      set  @SuccessfulRuntime = null;
				  set  @EndTime = null ;
			   end

				SET NOCOUNT ON;
					INSERT INTO  OffBoardOnBoardStatusReport([Source],[StartTime],[EndTime],[Comments],[Status],[SuccessfulRuntime],[TotalRecordCount],[OutputFileName], [OutputFileLocation], [UserId],[DateAdded],[DateLstMod])
						VALUES (@Source,
								CAST(@StartTime as DateTime),
								CAST(@EndTime as DateTime),
								@Comments,
								@Status,
								CAST(@SuccessfulRuntime as datetime),
								@TotalRecordCount,
								@OutputFileName,
								@OutputFileLocation,
								@UserId,
								getdate(),
								getdate()
								)
      
			SET @id=SCOPE_IDENTITY()
			RETURN  @id
	END

	----send null
		DECLARE @answer int
		declare @strstarttime varchar(25) = CONVERT(varchar(23), getdate(), 121)
		execute SaveOffBoardOnBoardStatusReport 'sql', @strstarttime,'','comments','inprogress','',1,null,null,1,@answer OUTPUT
		SELECT 'Result = ', @answer
		GO

	

	****************-- updateinfo **************update status report*******************************************************************************

		IF OBJECT_ID ( '[customer].[UpdateOffBoardOnBoardStatusReport]', 'P' ) IS NOT NULL
				DROP PROCEDURE [customer].[UpdateOffBoardOnBoardStatusReport];
		GO

		CREATE PROCEDURE [customer].[UpdateOffBoardOnBoardStatusReport]  
			@id int,
			@Status varchar(50), -- error? inprogress,completed
			@successfulruntime varchar(50),
			@endtime varchar(50)
		AS
			SET NOCOUNT ON;

			update OffBoardOnBoardStatusReport
			set [status] = @status,
				[successfulruntime] = cast (@successfulruntime as datetime), --  getdate(),
				[endtime] = cast(@endtime as datetime), --   getdate() ,
				DateLstMod = getdate()
			where [id] = @id;

			****test*********************************
			declare @cmptime varchar(24) = convert(varchar(24),getdate(),121);
			exec [customer].[UpdateOffBoardOnBoardStatusReport]  1,'completed',@cmptime,@cmptime;

************************view**********************************************************************************
	  --drop view vw_OffBoardOnBoardStudents
	  -- view
	  create view vw_OffBoardOnBoardStudents
		as
		SELECT  ae.SyStudentID,
				syst.Email,
				ae.AdEnrollID,
				ae.SyCampusID,
				ae.adTermID,
				ae.adProgramDescrip,
				ae.SySchoolStatusID,
				syss.Code,
				ae.StatusDate
		FROM AdEnroll ae INNER JOIN SyStudent Syst ON ae.SyStudentID= syst.SyStudentId 
			             INNER JOIN SySchoolStatus  syss on ae.SySchoolStatusID=syss.SySchoolStatusID
		WHERE syss.code IN ('NOSHOW','CANCEL','GRAD','REV','DISMISS','INELIG');

		select * from vw_OffBoardOnBoardStudents; -- total 60976
****************-- generte report***************generate report************************************************************************
	  -- get students data (looks from today if no rows exists )
	    IF OBJECT_ID('Customer.uspGetOffBoardOnBoardStudents', 'P') IS NOT NULL  
			   DROP PROCEDURE Customer.uspGetOffBoardOnBoardStudents;  
		GO  

		CREATE PROCEDURE Customer.uspGetOffBoardOnBoardStudents 
		 AS 
		   SET NOCOUNT ON;
		   
		   declare @maxid int;
		   declare @lastReporteGeneratedDate datetime;

		   -- get most recent id (for first run it will be 0)
			  select  @maxid = coalesce(max(id),0) 
			   from customer.offboardonboardstatusreport 
			    where [status] = 'completed';

			-- first run - get from today
			if ( @maxid = 0)				
					set @lastReporteGeneratedDate = getdate();
				
		    else --  not the first run, get the last successfule runtime
				begin
					select @lastReporteGeneratedDate = successfulruntime
						from customer.offboardonboardstatusreport 
					     where id = @maxid;
				 end;
			
             -- get students 
			  print '@lastReporteGeneratedDate :' + convert(varchar(24),@lastReporteGeneratedDate,121)
				select * from customer.vw_OffBoardOnBoardStudents s
				where StatusDate <= DateAdd(yy,-1,@lastReporteGeneratedDate);
							
		RETURN  
        GO
		****Test**
		exec Customer.uspGetOffBoardOnBoardStudents
		****************************************************************************************************************
	  
	  
