CREATE PROGRAM bed_ens_pos_category:dba
 RECORD requestin(
   1 list_0[*]
     2 action_flag = i2
     2 category = c40
     2 step_cat_mean = c100
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
 SET cat_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO cat_cnt)
   IF ((requestin->list_0[x].action_flag="1"))
    SET new_id = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_position_category bpc
     SET bpc.active_ind = 1, bpc.category_id = new_id, bpc.description = requestin->list_0[x].
      category,
      bpc.step_cat_mean = requestin->list_0[x].step_cat_mean, bpc.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), bpc.updt_id = reqinfo->updt_id,
      bpc.updt_task = reqinfo->updt_task, bpc.updt_applctx = reqinfo->updt_applctx, bpc.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert positon category ",trim(requestin->list_0[x].category),
      " into the br_position_category table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((requestin->list_0[x].action_flag="2"))
    UPDATE  FROM br_position_category bpc
     SET bpc.step_cat_mean = requestin->list_0[x].step_cat_mean
     WHERE cnvtupper(bpc.description)=cnvtupper(requestin->list_0[x].category)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update positon category ",trim(requestin->list_0[x].category),
      " from the br_position_category table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((requestin->list_0[x].action_flag="3"))
    UPDATE  FROM br_position_category bpc
     SET bpc.active_ind = 0
     WHERE cnvtupper(bpc.description)=cnvtupper(requestin->list_0[x].category)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete positon category ",trim(requestin->list_0[x].category),
      " from the br_position_category table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_POS_CATEGORY","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
