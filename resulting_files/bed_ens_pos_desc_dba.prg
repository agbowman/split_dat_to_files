CREATE PROGRAM bed_ens_pos_desc:dba
 RECORD requestin(
   1 list_0[*]
     2 position = c40
     2 description = vc
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
 SET position_code_value = 0
 SET pos_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO pos_cnt)
   SET position_code_value = 0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.active_ind=1
     AND cv.code_set=88
     AND cv.br_client_id=0
     AND cnvtupper(cv.display)=cnvtupper(requestin->list_0[x].position)
    DETAIL
     position_code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat(trim(requestin->list_0[x].position)," was not found on cs88.")
    GO TO exit_script
   ENDIF
   SET new_id = 0.0
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM br_long_text lt
    SET lt.long_text_id = new_id, lt.long_text = requestin->list_0[x].description, lt
     .parent_entity_id = position_code_value,
     lt.parent_entity_name = "CODE_VALUE", lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id
      = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat(trim(requestin->list_0[x].position),
     " description was not inserted into the br_long_text table.")
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_POS_DESC","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
