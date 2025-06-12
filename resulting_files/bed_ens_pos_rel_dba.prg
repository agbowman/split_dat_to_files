CREATE PROGRAM bed_ens_pos_rel:dba
 RECORD requestin(
   1 list_0[*]
     2 action_flag = i2
     2 category = c40
     2 position = c40
     2 sequence = i4
     2 physician_ind = i2
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
 SET last_position_category_id = 0.0
 SET last_position_category = fillstring(40," ")
 SET position_code_value = 0.0
 SET pos_cnt = size(requestin->list_0,5)
 SET max_sequence = 0
 FOR (x = 1 TO pos_cnt)
   IF (last_position_category != cnvtupper(requestin->list_0[x].category))
    SELECT INTO "NL:"
     FROM br_position_category bpc
     WHERE bpc.active_ind=1
      AND cnvtupper(bpc.description)=cnvtupper(requestin->list_0[x].category)
     DETAIL
      last_position_category_id = bpc.category_id, last_position_category = cnvtupper(bpc.description
       )
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to find postion category ",trim(requestin->list_0[x].category),
      ".")
     GO TO exit_script
    ENDIF
   ENDIF
   SET position_code_value = 0.0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.active_ind=1
     AND cv.code_set=88
     AND cnvtupper(cv.display)=cnvtupper(requestin->list_0[x].position)
    DETAIL
     position_code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to find position ",trim(requestin->list_0[x].position),".")
    GO TO exit_script
   ENDIF
   IF ((requestin->list_0[x].action_flag="1"))
    SET max_sequence = 0
    SELECT INTO "NL:"
     FROM br_position_cat_comp bpcc
     WHERE bpcc.category_id=last_position_category_id
     ORDER BY bpcc.sequence
     DETAIL
      max_sequence = bpcc.sequence
     WITH nocounter
    ;end select
    INSERT  FROM br_position_cat_comp bpcc
     SET bpcc.category_id = last_position_category_id, bpcc.position_cd = position_code_value, bpcc
      .sequence = (max_sequence+ 1),
      bpcc.physician_ind =
      IF ((((requestin->list_0[x].physician_ind="Y")) OR ((((requestin->list_0[x].physician_ind="y"))
       OR ((requestin->list_0[x].physician_ind="1"))) )) ) 1
      ELSE 0
      ENDIF
      , bpcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bpcc.updt_id = reqinfo->updt_id,
      bpcc.updt_task = reqinfo->updt_task, bpcc.updt_applctx = reqinfo->updt_applctx, bpcc.updt_cnt
       = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert position ",trim(requestin->list_0[x].position),
      " for positon category ",trim(requestin->list_0[x].category),
      " into the br_position_cat_comp table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((requestin->list_0[x].action_flag="2"))
    UPDATE  FROM br_position_cat_comp bpcc
     SET bpcc.sequence =
      IF (cnvtint(requestin->list_0[x].sequence) > 0) cnvtint(requestin->list_0[x].sequence)
      ELSE bpcc.sequence
      ENDIF
      , bpcc.physician_ind =
      IF ((((requestin->list_0[x].physician_ind="Y")) OR ((((requestin->list_0[x].physician_ind="y"))
       OR ((requestin->list_0[x].physician_ind="1"))) )) ) 1
      ELSE 0
      ENDIF
      , bpcc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bpcc.updt_id = reqinfo->updt_id, bpcc.updt_task = reqinfo->updt_task, bpcc.updt_applctx =
      reqinfo->updt_applctx,
      bpcc.updt_cnt = (bpcc.updt_cnt+ 1)
     WHERE bpcc.category_id=last_position_category_id
      AND bpcc.position_cd=position_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update position ",trim(requestin->list_0[x].position),
      " for positon category ",trim(requestin->list_0[x].category),
      " into the br_position_cat_comp table.")
     CALL echo(build("position_cd = ",cnvtstring(position_code_value),"cat_id = ",cnvtstring(
        last_position_category_id)))
     GO TO exit_script
    ENDIF
   ELSEIF ((requestin->list_0[x].action_flag="3"))
    DELETE  FROM br_position_cat_comp bpcc
     WHERE bpcc.category_id=last_position_category_id
      AND bpcc.position_cd=position_code_value
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete position ",trim(requestin->list_0[x].position),
      " for positon category ",trim(requestin->list_0[x].category),
      " into the br_position_cat_comp table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_POS_REL","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
