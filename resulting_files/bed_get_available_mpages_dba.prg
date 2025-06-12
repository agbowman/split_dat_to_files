CREATE PROGRAM bed_get_available_mpages:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 mpages[*]
      2 category_name = vc
      2 br_datamart_category_id = f8
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i8
      2 total_items = i8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET mpagecount = 0
 SELECT INTO "nl:"
  FROM br_datamart_category bdc
  PLAN (bdc
   WHERE bdc.viewpoint_capable_ind=1)
  ORDER BY bdc.category_name
  DETAIL
   mpagecount = (mpagecount+ 1), stat = alterlist(reply->mpages,mpagecount), reply->mpages[mpagecount
   ].category_name = bdc.category_name,
   reply->mpages[mpagecount].br_datamart_category_id = bdc.br_datamart_category_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error on DocSet section relationship insert",serrmsg)
 ENDIF
 SUBROUTINE logerror(message,details)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = message
   SET reply->status_data.subeventstatus[1].targetobjectvalue = details
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
