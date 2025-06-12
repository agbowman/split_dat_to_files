CREATE PROGRAM bmdi_strt_model_format_import:dba
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
 DECLARE count = i4
 DECLARE index = i4
 DECLARE serrormsg = vc WITH public, noconstant("")
 DECLARE temp_cd = f8 WITH public, noconstant(0.0)
 SET count = 0
 SET index = 0
 SET readme_data->status = "F"
 SET serrormsg =
 "Failure - an error occured while importing data to the strt_model_format_import table"
 SET count = size(requestin->list_0,5)
 FOR (index = 1 TO count)
   IF (textlen(trim(requestin->list_0[index].result_format_cdf)) > 0)
    SET temp_cd = 0.0
    SELECT INTO "nl:"
     cv.code_value, cv.cdf_meaning
     FROM code_value cv
     WHERE code_set=359575
      AND cv.cdf_meaning=trim(cnvtstring(requestin->list_0[index].result_format_cdf))
     DETAIL
      temp_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=1)
     SET requestin->list_0[index].result_format_cd = cnvtstring(temp_cd)
    ELSE
     SET requestin->list_0[index].result_format_cd = cnvtstring(0)
    ENDIF
   ELSE
    SET requestin->list_0[index].result_format_cd = cnvtstring(0)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  smf.strt_model_format_id, smf.strt_model_id, smf.model_version
  FROM strt_model_format smf,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (smf
   WHERE smf.strt_model_format_id=cnvtreal(requestin->list_0[d.seq].strt_model_format_id)
    AND smf.strt_model_id=cnvtreal(requestin->list_0[d.seq].strt_model_id)
    AND smf.model_version=cnvtint(requestin->list_0[d.seq].model_version))
  DETAIL
   requestin->list_0[d.seq].exists_ind = cnvtstring(1)
  WITH nocounter
 ;end select
 IF (error(serrormsg,0) != 0)
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 UPDATE  FROM strt_model_format smf,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET smf.strt_model_format_id = cnvtreal(requestin->list_0[d.seq].strt_model_format_id), smf
   .strt_model_id = cnvtreal(requestin->list_0[d.seq].strt_model_id), smf.model_version = cnvtint(
    requestin->list_0[d.seq].model_version),
   smf.result_format_cd = cnvtreal(requestin->list_0[d.seq].result_format_cd), smf.updt_id = reqinfo
   ->updt_id, smf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   smf.updt_task = reqinfo->updt_task, smf.updt_applctx = reqinfo->updt_applctx, smf.updt_cnt =
   cnvtint((smf.updt_cnt+ 1))
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(1)))
   JOIN (smf
   WHERE smf.strt_model_format_id=cnvtreal(requestin->list_0[d.seq].strt_model_format_id)
    AND smf.strt_model_id=cnvtreal(requestin->list_0[d.seq].strt_model_id)
    AND smf.model_version=cnvtint(requestin->list_0[d.seq].model_version))
  WITH nocounter
 ;end update
 IF (error(serrormsg,0) != 0)
  ROLLBACK
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 INSERT  FROM strt_model_format smf,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET smf.strt_model_format_id = cnvtreal(requestin->list_0[d.seq].strt_model_format_id), smf
   .strt_model_id = cnvtreal(requestin->list_0[d.seq].strt_model_id), smf.model_version = cnvtint(
    requestin->list_0[d.seq].model_version),
   smf.result_format_cd = cnvtreal(requestin->list_0[d.seq].result_format_cd), smf.updt_id = reqinfo
   ->updt_id, smf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   smf.updt_task = reqinfo->updt_task, smf.updt_applctx = reqinfo->updt_applctx, smf.updt_cnt = 0
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(0)))
   JOIN (smf)
  WITH nocounter
 ;end insert
 IF (error(serrormsg,0) != 0)
  ROLLBACK
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success - all strt_model_format rows inserted and update successfully."
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("##################################################")
  CALL echo(readme_data->message)
  CALL echo("##################################################")
 ENDIF
 COMMIT
END GO
