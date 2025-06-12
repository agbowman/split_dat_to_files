CREATE PROGRAM bed_imp_step:dba
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
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET nbr_steps = size(requestin->list_0,5)
 FOR (x = 1 TO nbr_steps)
   IF (trim(requestin->list_0[x].step_mean) > " ")
    UPDATE  FROM br_step bs
     SET bs.step_disp = trim(requestin->list_0[x].step_disp), bs.step_type = trim(requestin->list_0[x
       ].step_type), bs.step_cat_mean = trim(requestin->list_0[x].step_cat_mean),
      bs.step_cat_disp = trim(requestin->list_0[x].step_cat_disp), bs.est_min_to_complete = cnvtint(
       requestin->list_0[x].est_minutes), bs.default_seq = cnvtint(requestin->list_0[x].default_seq),
      bs.updt_dt_tm = cnvtdatetime(curdate,curtime), bs.updt_id = 13
     WHERE bs.step_mean=trim(requestin->list_0[x].step_mean)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM br_step bs
      SET bs.step_mean = trim(requestin->list_0[x].step_mean), bs.step_disp = trim(requestin->list_0[
        x].step_disp), bs.step_type = trim(requestin->list_0[x].step_type),
       bs.step_cat_mean = trim(requestin->list_0[x].step_cat_mean), bs.step_cat_disp = trim(requestin
        ->list_0[x].step_cat_disp), bs.est_min_to_complete = cnvtint(requestin->list_0[x].est_minutes
        ),
       bs.default_seq = cnvtint(requestin->list_0[x].default_seq), bs.updt_dt_tm = cnvtdatetime(
        curdate,curtime), bs.updt_id = 13
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = "Unable to add to BR_STEP table"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_STEP","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
