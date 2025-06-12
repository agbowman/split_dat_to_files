CREATE PROGRAM cps_ens_ref_datastats:dba
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
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 ref_datastats_id = f8
      2 last_action_seq = i4
      2 action_ind = i2
      2 chart_definition_id = f8
      2 x_min_val = f8
      2 x_max_val = f8
      2 median_value = f8
      2 mean_value = f8
      2 coeffnt_var_value = f8
      2 std_dev_value = f8
      2 box_cox_power_value = f8
      2 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE req_knt = i4 WITH public, constant(size(request->qual,5))
 IF (req_knt < 1)
  GO TO exit_script
 ENDIF
 DECLARE next_id = f8 WITH public, noconstant(0.0)
 DECLARE active_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE inactive_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE update_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(null))
 IF ((reqdata->active_status_cd < 1))
  SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_status_cd)
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
  SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",1,inactive_status_cd)
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
  PLAN (d
   WHERE d.seq > 0)
   JOIN (rd
   WHERE (rd.chart_definition_id=request->qual[d.seq].chart_definition_id)
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
   IF ((request->qual[i].ref_datastats_id < 1))
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
    SET request->qual[i].ref_datastats_id = next_id
   ENDIF
 ENDFOR
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM ref_datastats rd,
   (dummyt d  WITH seq = value(req_knt))
  SET rd.ref_datastats_id = request->qual[d.seq].ref_datastats_id, rd.last_action_seq = (request->
   qual[d.seq].action_seq+ 1), rd.chart_definition_id = request->qual[d.seq].chart_definition_id,
   rd.x_min_val = request->qual[d.seq].x_min_val, rd.x_max_val = request->qual[d.seq].x_max_val, rd
   .median_value = request->qual[d.seq].median_value,
   rd.mean_value = request->qual[d.seq].mean_value, rd.coeffnt_var_value = request->qual[d.seq].
   coeffnt_var_value, rd.std_dev_value = request->qual[d.seq].std_dev_value,
   rd.box_cox_power_value = request->qual[d.seq].box_cox_power_value, rd.active_ind = request->qual[d
   .seq].active_ind, rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), rd.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3), rd.active_status_prsnl_id = reqinfo->updt_id,
   rd.active_status_cd =
   IF ((request->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0)
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
  SET rd.ref_datastats_id = request->qual[d.seq].ref_datastats_id, rd.action_seq = (request->qual[d
   .seq].action_seq+ 1), rd.chart_definition_id = request->qual[d.seq].chart_definition_id,
   rd.x_min_val = request->qual[d.seq].x_min_val, rd.x_max_val = request->qual[d.seq].x_max_val, rd
   .median_value = request->qual[d.seq].median_value,
   rd.mean_value = request->qual[d.seq].mean_value, rd.coeffnt_var_value = request->qual[d.seq].
   coeffnt_var_value, rd.std_dev_value = request->qual[d.seq].std_dev_value,
   rd.box_cox_power_value = request->qual[d.seq].box_cox_power_value, rd.active_ind = request->qual[d
   .seq].active_ind, rd.action_type_flag = 0,
   rd.action_dt_tm = cnvtdatetime(curdate,curtime3), rd.beg_effective_dt_tm = cnvtdatetime(curdate,
    curtime3), rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
   rd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rd.active_status_prsnl_id = reqinfo->
   updt_id, rd.active_status_cd =
   IF ((request->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   ,
   rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3), rd.updt_task =
   reqinfo->updt_task,
   rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0)
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
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_knt))
  PLAN (d
   WHERE d.seq > 0)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].ref_datastats_id = request->qual[d.seq].ref_datastats_id, reply->qual[knt].
   last_action_seq = request->qual[d.seq].action_seq, reply->qual[knt].action_ind = 0,
   reply->qual[knt].chart_definition_id = request->qual[d.seq].chart_definition_id, reply->qual[knt].
   x_min_val = request->qual[d.seq].x_min_val, reply->qual[knt].x_max_val = request->qual[d.seq].
   x_max_val,
   reply->qual[knt].median_value = request->qual[d.seq].median_value, reply->qual[knt].mean_value =
   request->qual[d.seq].mean_value, reply->qual[knt].coeffnt_var_value = request->qual[d.seq].
   coeffnt_var_value,
   reply->qual[knt].std_dev_value = request->qual[d.seq].std_dev_value, reply->qual[knt].
   box_cox_power_value = request->qual[d.seq].box_cox_power_value, reply->qual[knt].active_ind =
   request->qual[d.seq].active_ind
  FOOT REPORT
   stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "REPLY"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "PCO_SEQ GENERATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF (size(reply->qual,5) > 0)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET cps_script_version = "002 09/17/09 AB017375"
END GO
