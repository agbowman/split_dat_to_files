CREATE PROGRAM bmdi_strt_model_hl7_map_import:dba
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
 SET count = 0
 SET index = 0
 SET readme_data->status = "F"
 SET serrormsg = "Failure - an error occured while importing data to the strt_model_hl7_map table"
 DECLARE temp_cd = f8 WITH public, noconstant(0.0)
 SET count = size(requestin->list_0,5)
 FOR (index = 1 TO count)
   IF (textlen(trim(requestin->list_0[index].segment_cdf)) > 0)
    SET temp_cd = 0.0
    SELECT INTO "nl:"
     cv.code_value, cv.cdf_meaning
     FROM code_value cv
     WHERE code_set=359572
      AND cv.cdf_meaning=trim(cnvtstring(requestin->list_0[index].segment_cdf))
     DETAIL
      temp_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=1)
     SET requestin->list_0[index].segment_cd = cnvtstring(temp_cd)
    ELSE
     SET requestin->list_0[index].segment_cd = cnvtstring(0)
    ENDIF
   ELSE
    SET requestin->list_0[index].segment_cd = cnvtstring(0)
   ENDIF
   SET requestin->list_0[index].component_format_cd = cnvtstring(0)
   IF (textlen(trim(requestin->list_0[index].component_cdf)) > 0)
    SET temp_cd = 0.0
    SELECT INTO "nl:"
     cv.code_value, cv.cdf_meaning
     FROM code_value cv
     WHERE code_set=359571
      AND cv.cdf_meaning=trim(cnvtstring(requestin->list_0[index].component_cdf))
     DETAIL
      temp_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=1)
     SET requestin->list_0[index].component_cd = cnvtstring(temp_cd)
    ELSE
     SET requestin->list_0[index].component_cd = cnvtstring(0)
    ENDIF
   ELSE
    SET requestin->list_0[index].component_cd = cnvtstring(0)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  smhm.strt_hl7_map_id, smhm.strt_model_id
  FROM strt_model_hl7_map smhm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (smhm
   WHERE smhm.strt_hl7_map_id=cnvtreal(requestin->list_0[d.seq].strt_hl7_map_id)
    AND smhm.strt_model_id=cnvtreal(requestin->list_0[d.seq].strt_model_id))
  DETAIL
   requestin->list_0[d.seq].exists_ind = cnvtstring(1)
  WITH nocounter
 ;end select
 IF (error(serrormsg,0) != 0)
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 UPDATE  FROM strt_model_hl7_map smhm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET smhm.strt_hl7_map_id = cnvtreal(requestin->list_0[d.seq].strt_hl7_map_id), smhm.strt_model_id
    = cnvtreal(requestin->list_0[d.seq].strt_model_id), smhm.segment_cd = cnvtreal(requestin->list_0[
    d.seq].segment_cd),
   smhm.field_position = cnvtint(requestin->list_0[d.seq].field_position), smhm.component_position =
   cnvtint(requestin->list_0[d.seq].component_position), smhm.component_format_cd = cnvtreal(
    requestin->list_0[d.seq].component_format_cd),
   smhm.max_length = cnvtint(requestin->list_0[d.seq].max_length), smhm.result_set_position = cnvtint
   (requestin->list_0[d.seq].result_set_position), smhm.required_ind = cnvtint(requestin->list_0[d
    .seq].required_ind),
   smhm.common_ind = cnvtint(requestin->list_0[d.seq].common_ind), smhm.component_cd = cnvtreal(
    requestin->list_0[d.seq].component_cd), smhm.updt_id = reqinfo->updt_id,
   smhm.updt_dt_tm = cnvtdatetime(curdate,curtime3), smhm.updt_task = reqinfo->updt_task, smhm
   .updt_applctx = reqinfo->updt_applctx,
   smhm.updt_cnt = cnvtint((smhm.updt_cnt+ 1)), smhm.strt_model_format_id = cnvtreal(requestin->
    list_0[d.seq].strt_model_format_id), smhm.component_order = cnvtint(requestin->list_0[d.seq].
    component_order)
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(1)))
   JOIN (smhm
   WHERE smhm.strt_hl7_map_id=cnvtreal(requestin->list_0[d.seq].strt_hl7_map_id)
    AND smhm.strt_model_id=cnvtreal(requestin->list_0[d.seq].strt_model_id))
  WITH nocounter
 ;end update
 IF (error(serrormsg,0) != 0)
  ROLLBACK
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 INSERT  FROM strt_model_hl7_map smhm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET smhm.strt_hl7_map_id = cnvtreal(requestin->list_0[d.seq].strt_hl7_map_id), smhm.strt_model_id
    = cnvtreal(requestin->list_0[d.seq].strt_model_id), smhm.segment_cd = cnvtreal(requestin->list_0[
    d.seq].segment_cd),
   smhm.field_position = cnvtint(requestin->list_0[d.seq].field_position), smhm.component_position =
   cnvtint(requestin->list_0[d.seq].component_position), smhm.component_format_cd = cnvtreal(
    requestin->list_0[d.seq].component_format_cd),
   smhm.max_length = cnvtint(requestin->list_0[d.seq].max_length), smhm.result_set_position = cnvtint
   (requestin->list_0[d.seq].result_set_position), smhm.required_ind = cnvtint(requestin->list_0[d
    .seq].required_ind),
   smhm.common_ind = cnvtint(requestin->list_0[d.seq].common_ind), smhm.component_cd = cnvtreal(
    requestin->list_0[d.seq].component_cd), smhm.updt_id = reqinfo->updt_id,
   smhm.updt_dt_tm = cnvtdatetime(curdate,curtime3), smhm.updt_task = reqinfo->updt_task, smhm
   .updt_applctx = reqinfo->updt_applctx,
   smhm.updt_cnt = 0, smhm.strt_model_format_id = cnvtreal(requestin->list_0[d.seq].
    strt_model_format_id), smhm.component_order = cnvtint(requestin->list_0[d.seq].component_order)
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(0)))
   JOIN (smhm)
  WITH nocounter
 ;end insert
 IF (error(serrormsg,0) != 0)
  ROLLBACK
  SET readme_data->message = serrormsg
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success - all strt_model_hl7_map rows inserted and update successfully."
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
