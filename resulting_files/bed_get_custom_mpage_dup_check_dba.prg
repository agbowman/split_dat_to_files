CREATE PROGRAM bed_get_custom_mpage_dup_check:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 display_dup_ind = i2
    1 identifier_dup_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET reply->display_dup_ind = 0
 SET reply->identifier_dup_ind = 0
 SELECT INTO "nl:"
  FROM br_datamart_category b
  WHERE ((cnvtupper(b.category_name)=cnvtupper(request->display)) OR (cnvtupper(b.category_mean)=
  cnvtupper(request->identifier)))
  DETAIL
   IF (cnvtupper(b.category_name)=cnvtupper(request->display))
    reply->display_dup_ind = 1
   ENDIF
   IF (cnvtupper(b.category_mean)=cnvtupper(request->identifier))
    reply->identifier_dup_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
