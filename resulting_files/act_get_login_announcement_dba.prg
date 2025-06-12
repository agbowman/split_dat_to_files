CREATE PROGRAM act_get_login_announcement:dba
 RECORD reply(
   1 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
#system_announce
 SELECT INTO "nl:"
  l.long_text_id
  FROM dcp_entity_reltn d,
   long_text l
  PLAN (d
   WHERE d.entity_reltn_mean="WEBLGN ANCMT"
    AND d.entity1_id=0
    AND d.entity1_display="SYSTEM"
    AND d.entity2_display="LOGIN ANNOUNCEMENT"
    AND d.entity2_name="LONG_TEXT"
    AND d.active_ind=1
    AND (d.updt_applctx=request->application_number))
   JOIN (l
   WHERE l.long_text_id=d.entity2_id)
  DETAIL
   reply->text = l.long_text
  WITH nocounter
 ;end select
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("text:",reply->text))
END GO
