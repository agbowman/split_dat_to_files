CREATE PROGRAM bed_imp_sol:dba
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
 SET nbr_sol = size(requestin->list_0,5)
 DECLARE last_sol_mean = vc
 SET last_sol_mean = " "
 FOR (x = 1 TO nbr_sol)
  IF (trim(requestin->list_0[x].sol_mean) > " "
   AND trim(requestin->list_0[x].sol_mean) != last_sol_mean)
   SET last_sol_mean = trim(requestin->list_0[x].sol_mean)
   UPDATE  FROM br_solution bs
    SET bs.solution_disp = trim(requestin->list_0[x].sol_disp), bs.updt_dt_tm = cnvtdatetime(curdate,
      curtime), bs.updt_id = 13
    WHERE bs.solution_mean=last_sol_mean
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM br_solution bs
     SET bs.solution_mean = trim(requestin->list_0[x].sol_mean), bs.solution_disp = trim(requestin->
       list_0[x].sol_disp), bs.updt_dt_tm = cnvtdatetime(curdate,curtime),
      bs.updt_id = 13
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = "Unable to add to BR_SOLUTION table"
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF (last_sol_mean > " ")
   IF (trim(requestin->list_0[x].step_mean) > " ")
    UPDATE  FROM br_solution_step bss
     SET bss.step_disp = trim(requestin->list_0[x].step_disp), bss.step_type = trim(requestin->
       list_0[x].step_type), bss.sequence = cnvtint(requestin->list_0[x].sequence),
      bss.updt_dt_tm = cnvtdatetime(curdate,curtime), bss.updt_id = 13
     WHERE bss.solution_mean=last_sol_mean
      AND bss.step_mean=trim(requestin->list_0[x].step_mean)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM br_solution_step bss
      SET bss.solution_mean = last_sol_mean, bss.step_mean = trim(requestin->list_0[x].step_mean),
       bss.step_disp = trim(requestin->list_0[x].step_disp),
       bss.step_type = trim(requestin->list_0[x].step_type), bss.sequence = cnvtint(requestin->
        list_0[x].sequence), bss.updt_dt_tm = cnvtdatetime(curdate,curtime),
       bss.updt_id = 13
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = "Unable to add to BR_SOLUTION_STEP table"
      GO TO exit_script
     ENDIF
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_SOL","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
