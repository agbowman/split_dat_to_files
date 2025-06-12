CREATE PROGRAM dcp_get_auth_addenda_config:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 info_domain = c80
    1 info_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 info_char = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  di.info_char
  FROM dm_info di
  WHERE (di.info_domain=request->info_domain)
   AND (di.info_name=request->info_name)
  DETAIL
   reply->info_char = di.info_char
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_INFO"
 ENDIF
END GO
