CREATE PROGRAM bed_ens_app_group_rel:dba
 RECORD requestin(
   1 list_0[*]
     2 application_group = c40
     2 application_group_category = c40
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET last_app_group_category_id = 0.0
 SET last_app_group_category = fillstring(40," ")
 SET app_group_code_value = 0.0
 SET app_cnt = size(requestin->list_0,5)
 SET sequence = 0
 FOR (x = 1 TO app_cnt)
   IF (last_app_group_category != cnvtupper(requestin->list_0[x].application_group_category))
    SET sequence = 0
    SELECT INTO "NL:"
     FROM br_app_category bac
     WHERE bac.active_ind=1
      AND cnvtupper(bac.description)=cnvtupper(requestin->list_0[x].application_group_category)
     DETAIL
      last_app_group_category_id = bac.category_id, last_app_group_category = cnvtupper(bac
       .description)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to find application group category ",trim(requestin->list_0[x].
       application_group_category),".")
     GO TO exit_script
    ENDIF
   ENDIF
   SET app_group_code_value = 0.0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.active_ind=1
     AND cv.code_set=500
     AND cnvtupper(cv.display)=cnvtupper(requestin->list_0[x].application_group)
    DETAIL
     app_group_code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to find application group ",trim(requestin->list_0[x].
      application_group),".")
    GO TO exit_script
   ENDIF
   SET sequence = (sequence+ 1)
   INSERT  FROM br_app_cat_comp bacc
    SET bacc.category_id = last_app_group_category_id, bacc.application_group_cd =
     app_group_code_value, bacc.sequence = sequence,
     bacc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bacc.updt_id = reqinfo->updt_id, bacc
     .updt_task = reqinfo->updt_task,
     bacc.updt_applctx = reqinfo->updt_applctx, bacc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert application group ",trim(requestin->list_0[x].
      application_group)," for positon category ",trim(requestin->list_0[x].
      application_group_category)," into the br_app_cat_comp table.")
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_APP_GROUP_REL","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
