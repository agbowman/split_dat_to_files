CREATE PROGRAM dm_get_dm_pw:dba
 RECORD reply(
   1 pw_value = c30
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  a.info_char
  FROM dm_info a
  WHERE a.info_domain="DATA MANAGEMENT"
   AND a.info_name="DM_PW"
  DETAIL
   reply->pw_value = a.info_char
  WITH nocounter
 ;end select
 CALL echo(reply->pw_value)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
