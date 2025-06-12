CREATE PROGRAM daf_migrator_at_os_source:dba
 IF (validate(request->info_domain,"-1")="-1")
  FREE RECORD request
  RECORD request(
    1 info_domain = vc
    1 info_name = vc
  )
 ENDIF
 RECORD reply(
   1 platformflag = i2
   1 source_list[*]
     2 domainname = vc
     2 platformflag = i2
     2 cidbenvname = vc
     2 stageddate = dq8
     2 environmentid = f8
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
 DECLARE sourcecnt = i4 WITH public, noconstant(0)
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
  dadi.info_char, dadi.info_number, dadi.info_date
  FROM dm2_admin_dm_info dadi
  WHERE (dadi.info_domain=request->info_domain)
   AND dadi.info_name=patstring(concat(trim(request->info_name,3),"*"))
  DETAIL
   sourcecnt = (sourcecnt+ 1), stat = alterlist(reply->source_list,sourcecnt), reply->source_list[
   sourcecnt].domainname = trim(substring((size(trim(request->info_name,3),1)+ 3),40,dadi.info_name),
    3),
   reply->source_list[sourcecnt].platformflag = dadi.info_number, reply->source_list[sourcecnt].
   cidbenvname = trim(dadi.info_char,3), reply->source_list[sourcecnt].stageddate = cnvtdatetime(dadi
    .info_date),
   reply->source_list[sourcecnt].environmentid = dadi.info_long_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Error reading DM2_ADMIN_DM_INFO table:",errmsg)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->message = "The operation completed successfully."
#exit_script
END GO
