CREATE PROGRAM bed_ens_assay_ps:dba
 RECORD requestin(
   1 list_0[*]
     2 mnemonic = c40
     2 description = c60
     2 result_type_mean = vc
     2 activity_type_mean = vc
     2 bb_result_process_mean = vc
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET assay_cnt = size(requestin->list_0,5)
 SET prev_result_type = fillstring(40," ")
 SET prev_activity_type = fillstring(40," ")
 SET prev_bb_result_process = fillstring(40," ")
 SET result_type_code_value = 0.0
 SET activity_type_code_value = 0.0
 SET bb_result_process_cd = 0.0
 FOR (x = 1 TO assay_cnt)
   IF (((prev_result_type != cnvtupper(trim(requestin->list_0[x].result_type_mean))) OR (
   result_type_code_value=0)) )
    SET prev_result_type = cnvtupper(trim(requestin->list_0[x].result_type_mean))
    IF ((requestin->list_0[x].result_type_mean=""))
     SET result_type_code_value = 0.0
    ELSE
     SELECT DISTINCT INTO "NL"
      FROM code_value cv
      WHERE cv.active_ind=1
       AND cv.code_set=289
       AND cv.cdf_meaning=prev_result_type
      DETAIL
       result_type_code_value = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (((prev_activity_type != cnvtupper(trim(requestin->list_0[x].activity_type_mean))) OR (
   activity_type_code_value=0)) )
    SET prev_activity_type = cnvtupper(trim(requestin->list_0[x].activity_type_mean))
    SELECT DISTINCT INTO "NL"
     FROM code_value cv
     WHERE cv.active_ind=1
      AND cv.code_set=106
      AND cv.cdf_meaning=prev_activity_type
     DETAIL
      activity_type_code_value = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (prev_bb_result_process != cnvtupper(trim(requestin->list_0[x].bb_result_process_mean)))
    IF (prev_activity_type="BB")
     SET prev_bb_result_process = cnvtupper(trim(requestin->list_0[x].bb_result_process_mean))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.active_ind=1
       AND cv.code_set=1636
       AND cv.cdf_meaning=prev_bb_result_process
      DETAIL
       bb_result_process_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual > 1)
      SET bb_result_process_cd = 0.0
     ENDIF
    ELSE
     SET bb_result_process_cd = 0.0
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM br_auto_dta b
    WHERE b.mnemonic=substring(1,50,trim(requestin->list_0[x].mnemonic))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET new_id = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_auto_dta b
     SET b.task_assay_cd = new_id, b.activity_type_cd = activity_type_code_value, b.result_type_cd =
      result_type_code_value,
      b.mnemonic = substring(1,50,trim(requestin->list_0[x].mnemonic)), b.description = substring(1,
       100,trim(requestin->list_0[x].description)), b.bb_result_processing_cd = bb_result_process_cd,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].mnemonic),
      " into br_auto_dta table.")
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_ASSAY_PS","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
