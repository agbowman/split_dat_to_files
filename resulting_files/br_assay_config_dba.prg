CREATE PROGRAM br_assay_config:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_assay_config.prg> script"
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
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE error_msg = vc
 SET skip_ind = 0
 SET assay_cnt = size(requestin->list_0,5)
 SET prev_result_type = fillstring(40," ")
 SET prev_activity_type = fillstring(40," ")
 SET bb_process_type_mean = fillstring(40," ")
 SET result_type_code_value = 0.0
 SET activity_type_code_value = 0.0
 SET bb_process_code_value = 0.0
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
   SET bb_process_code_value = 0.0
   IF (cnvtupper(trim(requestin->list_0[x].activity_type_mean))="BB")
    IF (((bb_process_code_value=0) OR (bb_process_type_mean != cnvtupper(requestin->list_0[x].
     bb_result_process_mean))) )
     SET bb_process_type_mean = fillstring(40," ")
     SET bb_process_type_mean = cnvtupper(requestin->list_0[x].bb_result_process_mean)
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=1636
       AND cv.cdf_meaning=bb_process_type_mean
       AND cv.active_ind=1
      DETAIL
       bb_process_code_value = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM br_auto_dta ba
    WHERE (ba.mnemonic=requestin->list_0[x].mnemonic)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET skip_ind = 1
   ENDIF
   IF (skip_ind=0)
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
       100,trim(requestin->list_0[x].description)), b.bb_result_processing_cd = bb_process_code_value,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: Inserting into br_auto_dta: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET skip_ind = 0
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_assay_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
