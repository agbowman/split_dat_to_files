CREATE PROGRAM cps_rdm_ens_ref_datastats:dba
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
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script cps_rdm_ens_ref_datastats.prg..."
 CALL echo("Starting cps_rdm_ens_ref_datastats.prg")
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE req_knt = i4 WITH public, constant(size(treq->qual,5))
 IF (req_knt < 1)
  CALL echo("No data passed into treq.")
  GO TO exit_script
 ENDIF
 DECLARE next_id = f8 WITH public, noconstant(0.0)
 DECLARE active_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE inactive_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE update_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(null))
 IF ((reqdata->active_status_cd < 1))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1
   DETAIL
    active_status_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (active_status_cd < 1)
   SET failed = select_error
   SET tabe_name = "CODE_VALUE"
   SET serrmsg = "Failure finding the code_value for ACTIVE from code_set 48"
   GO TO exit_script
  ENDIF
 ELSE
  SET active_status_cd = reqdata->active_status_cd
 ENDIF
 IF ((reqdata->inactive_status_cd < 1))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE"
    AND cv.active_ind=1
   DETAIL
    inactive_status_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (inactive_status_cd < 1)
   SET failed = select_error
   SET tabe_name = "CODE_VALUE"
   SET serrmsg = "Failure finding the code_value for INACTIVE from code_set 48"
   GO TO exit_script
  ENDIF
 ELSE
  SET inactive_status_cd = reqdata->inactive_status_cd
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET update_dt_tm = cnvtlookbehind("3,MIN",cnvtdatetime(curdate,curtime3))
 DELETE  FROM (dummyt d  WITH seq = value(req_knt)),
   ref_datastats rd
  SET rd.seq = 1
  PLAN (d)
   JOIN (rd
   WHERE (rd.chart_definition_id=treq->qual[d.seq].chart_definition_id)
    AND rd.updt_dt_tm < cnvtdatetime(update_dt_tm))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = delete_error
  SET table_name = "REF_DATASTATS"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO req_knt)
   IF ((treq->qual[i].ref_datastats_id < 1))
    SET next_id = 0.0
    SET ierrcode = error(serrmsg,0)
    SET ierrcode = 0
    SELECT INTO "nl:"
     next_seq_nbr = seq(pco_seq,nextval)"#################;rp0"
     FROM dual
     DETAIL
      next_id = cnvtreal(next_seq_nbr)
     WITH nocounter, format
    ;end select
    SET ierrcode = error(serrmsg,0)
    IF (ierrcode > 0)
     SET failed = gen_nbr_error
     SET table_name = "PCO_SEQ"
     GO TO exit_script
    ENDIF
    SET treq->qual[i].ref_datastats_id = next_id
   ENDIF
 ENDFOR
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM ref_datastats rd,
   (dummyt d  WITH seq = value(req_knt))
  SET rd.ref_datastats_id = treq->qual[d.seq].ref_datastats_id, rd.last_action_seq = 1, rd
   .chart_definition_id = treq->qual[d.seq].chart_definition_id,
   rd.x_min_val = treq->qual[d.seq].x_min_val, rd.x_max_val = treq->qual[d.seq].x_max_val, rd
   .median_value = treq->qual[d.seq].median_value,
   rd.mean_value = treq->qual[d.seq].mean_value, rd.coeffnt_var_value = treq->qual[d.seq].
   coeffnt_var_value, rd.std_dev_value = treq->qual[d.seq].std_dev_value,
   rd.box_cox_power_value = treq->qual[d.seq].box_cox_power_value, rd.active_ind = treq->qual[d.seq].
   active_ind, rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), rd.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3), rd.active_status_prsnl_id = reqinfo->updt_id,
   rd.active_status_cd =
   IF ((treq->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (rd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "REF_DATASTATS"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM ref_datastats_hist rd,
   (dummyt d  WITH seq = value(req_knt))
  SET rd.ref_datastats_id = treq->qual[d.seq].ref_datastats_id, rd.action_seq = 1, rd
   .chart_definition_id = treq->qual[d.seq].chart_definition_id,
   rd.x_min_val = treq->qual[d.seq].x_min_val, rd.x_max_val = treq->qual[d.seq].x_max_val, rd
   .median_value = treq->qual[d.seq].median_value,
   rd.mean_value = treq->qual[d.seq].mean_value, rd.coeffnt_var_value = treq->qual[d.seq].
   coeffnt_var_value, rd.std_dev_value = treq->qual[d.seq].std_dev_value,
   rd.box_cox_power_value = treq->qual[d.seq].box_cox_power_value, rd.active_ind = treq->qual[d.seq].
   active_ind, rd.action_type_flag = 0,
   rd.action_dt_tm = cnvtdatetime(curdate,curtime3), rd.beg_effective_dt_tm = cnvtdatetime(curdate,
    curtime3), rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
   rd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rd.active_status_prsnl_id = reqinfo->
   updt_id, rd.active_status_cd =
   IF ((treq->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   ,
   rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3), rd.updt_task =
   reqinfo->updt_task,
   rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (rd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "REF_DATASTATS_HIST"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  ROLLBACK
  SET readme_data->status = "F"
  IF (failed=select_error)
   SET readme_data->message = concat("Failure: SELECT:",table_name,serrmsg)
  ELSEIF (failed=insert_error)
   SET readme_data->message = concat("Failure: INSERT:",table_name,serrmsg)
  ELSEIF (failed=update_error)
   SET readme_data->message = concat("Failure: UPDATE:",table_name,serrmsg)
  ELSEIF (failed=input_error)
   SET readme_data->message = concat("Failure: VALIDATION:",table_name,serrmsg)
  ELSEIF (failed=gen_nbr_error)
   SET readme_data->message = concat("Failure: GEN_NBR_ERROR:",table_name,serrmsg)
  ELSE
   SET readme_data->message = concat("Failure: UNKNOWN:",table_name,serrmsg)
  ENDIF
  CALL echo(build("Failure: ",table_name))
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Success: cps_rdm_ens_ref_datastats finishted successfully"
  CALL echo(build("Success: cps_rdm_ens_ref_datastats"))
 ENDIF
 SET cps_script_version = "002 09/17/09 AB017375"
END GO
