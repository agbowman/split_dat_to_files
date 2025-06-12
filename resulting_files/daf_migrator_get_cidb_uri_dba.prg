CREATE PROGRAM daf_migrator_get_cidb_uri:dba
 IF (validate(request->info_domain,"-1")="-1")
  FREE RECORD request
  RECORD request(
    1 info_domain = vc
    1 info_name = vc
  )
 ENDIF
 RECORD reply(
   1 message = vc
   1 cidb_location = vc
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
  SET reply->cidb_location = ""
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE (di.info_domain=request->info_domain)
   AND (di.info_name=request->info_name)
  DETAIL
   reply->cidb_location = trim(di.info_char,3)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to retrieve CIDB location:",errmsg)
  SET reply->cidb_location = ""
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "S"
  SET reply->message = "No DM_INFO row could be found."
  SET reply->cidb_location = ""
  GO TO exit_script
 ENDIF
 IF (size(reply->cidb_location,1)=0)
  SET reply->status_data.status = "S"
  SET reply->message = "The DM_INFO row does not contain a valid CIDB location."
  SET reply->cidb_location = ""
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->message = "Found the CIDB Location"
#exit_script
END GO
