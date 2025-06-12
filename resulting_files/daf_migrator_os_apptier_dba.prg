CREATE PROGRAM daf_migrator_os_apptier:dba
 IF (validate(request->info_domain,"-1")="-1")
  FREE RECORD request
  RECORD request(
    1 info_domain = vc
    1 info_name = vc
  )
 ENDIF
 RECORD reply(
   1 platformflag = i2
   1 sourceplatformflag = i2
   1 sourcecidbenvname = vc
   1 sourcestageddate = dq8
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 IF (((size(request->info_domain,1)=0) OR (size(request->info_name,1)=0)) )
  SET reply->status_data.status = "F"
  SET reply->message = "Request structure contains no data."
  GO TO exit_script
 ENDIF
 IF (cursys2="AIX")
  CALL echo("The OS is AIX")
  SET reply->platformflag = 2
 ELSEIF (cursys2="VMS")
  CALL echo("The OS is VMS")
  SET reply->platformflag = 3
 ELSEIF (cursys2="HPX")
  CALL echo("The OS is HP-UX")
  SET reply->platformflag = 4
 ELSEIF (cursys2="LNX")
  CALL echo("The OS is Linux")
  SET reply->platformflag = 5
 ELSE
  SET reply->status_data.status = "F"
  SET reply->message = "The CURSYS2 value could not be recognized."
 ENDIF
 SELECT INTO "nl:"
  di.info_char, di.info_number, di.info_date
  FROM dm_info di
  WHERE (di.info_domain=request->info_domain)
   AND (di.info_name=request->info_name)
  DETAIL
   reply->sourceplatformflag = di.info_number, reply->sourcecidbenvname = trim(di.info_char,3), reply
   ->sourcestageddate = cnvtdatetime(di.info_date)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Error reading DM_INFO table:",errmsg)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->message = "The operation completed successfully."
#exit_script
END GO
