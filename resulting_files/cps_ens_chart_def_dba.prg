CREATE PROGRAM cps_ens_chart_def:dba
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
      2 chart_definition_id = f8
      2 action_ind = i2
      2 last_action_seq = i4
      2 chart_source_cd = f8
      2 chart_type_cd = f8
      2 sex_cd = f8
      2 min_age = f8
      2 max_age = f8
      2 chart_title = vc
      2 version = vc
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
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_knt)),
   chart_definition cd
  PLAN (d
   WHERE d.seq > 0)
   JOIN (cd
   WHERE (cd.chart_source_cd=request->qual[d.seq].chart_source_cd)
    AND (cd.chart_type_cd=request->qual[d.seq].chart_type_cd)
    AND (cd.sex_cd=request->qual[d.seq].sex_cd)
    AND (cd.min_age=request->qual[d.seq].min_age)
    AND (cd.max_age=request->qual[d.seq].max_age)
    AND (cd.y_axis_unit_cd=request->qual[d.seq].y_axis_unit_cd))
  HEAD cd.chart_definition_id
   IF ((request->qual[d.seq].chart_definition_id > 0)
    AND (request->qual[d.seq].chart_definition_id != cd.chart_definition_id))
    request->qual[d.seq].action_ind = 3
   ELSE
    request->qual[d.seq].action_ind = 2, request->qual[d.seq].chart_definition_id = cd
    .chart_definition_id
   ENDIF
   request->qual[d.seq].action_seq = cd.last_action_seq
   IF ((request->qual[d.seq].action_ind != 3))
    IF ((request->qual[d.seq].chart_definition_id < 1))
     request->qual[d.seq].chart_definition_id = cd.chart_definition_id
    ENDIF
    IF ((cd.chart_title != request->qual[d.seq].chart_title))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.version != request->qual[d.seq].version))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.version != request->qual[d.seq].version))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.y_axis_min_val != request->qual[d.seq].y_axis_min_val))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.y_axis_max_val != request->qual[d.seq].y_axis_max_val))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.y_axis_unit_cd != request->qual[d.seq].y_axis_unit_cd))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.y_type_cd != request->qual[d.seq].y_type_cd))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.x_type_cd != request->qual[d.seq].x_type_cd))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.x_axis_section1_min_val != request->qual[d.seq].x_axis_section1_min_val))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.x_axis_section1_max_val != request->qual[d.seq].x_axis_section1_max_val))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.x_axis_section2_min_val != request->qual[d.seq].x_axis_section2_min_val))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.x_axis_section2_max_val != request->qual[d.seq].x_axis_section2_max_val))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.x_axis_section2_multiplier != request->qual[d.seq].x_axis_section2_multiplier))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.x_axis_section1_unit_cd != request->qual[d.seq].x_axis_section1_unit_cd))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.x_axis_section2_unit_cd != request->qual[d.seq].x_axis_section2_unit_cd))
     request->qual[d.seq].action_ind = 1
    ENDIF
    IF ((cd.active_ind != request->qual[d.seq].active_ind))
     request->qual[d.seq].action_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DETERMIN_ACTION"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO req_knt)
   IF ((request->qual[i].chart_definition_id < 1)
    AND (request->qual[i].action_ind=0))
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
    SET request->qual[i].chart_definition_id = next_id
   ENDIF
 ENDFOR
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM chart_definition cd,
   (dummyt d  WITH seq = value(req_knt))
  SET cd.chart_definition_id = request->qual[d.seq].chart_definition_id, cd.last_action_seq = (
   request->qual[d.seq].action_seq+ 1), cd.chart_source_cd = request->qual[d.seq].chart_source_cd,
   cd.chart_type_cd = request->qual[d.seq].chart_type_cd, cd.sex_cd = request->qual[d.seq].sex_cd, cd
   .min_age = request->qual[d.seq].min_age,
   cd.max_age = request->qual[d.seq].max_age, cd.chart_title = request->qual[d.seq].chart_title, cd
   .x_type_cd = request->qual[d.seq].x_type_cd,
   cd.y_type_cd = request->qual[d.seq].y_type_cd, cd.y_axis_min_val = request->qual[d.seq].
   y_axis_min_val, cd.y_axis_max_val = request->qual[d.seq].y_axis_max_val,
   cd.y_axis_unit_cd = request->qual[d.seq].y_axis_unit_cd, cd.x_axis_section1_min_val = request->
   qual[d.seq].x_axis_section1_min_val, cd.x_axis_section1_max_val = request->qual[d.seq].
   x_axis_section1_max_val,
   cd.x_axis_section2_min_val = request->qual[d.seq].x_axis_section2_min_val, cd
   .x_axis_section2_max_val = request->qual[d.seq].x_axis_section2_max_val, cd
   .x_axis_section2_multiplier = request->qual[d.seq].x_axis_section2_multiplier,
   cd.x_axis_section1_unit_cd = request->qual[d.seq].x_axis_section1_unit_cd, cd
   .x_axis_section2_unit_cd = request->qual[d.seq].x_axis_section2_unit_cd, cd.version = request->
   qual[d.seq].version,
   cd.active_ind = request->qual[d.seq].active_ind, cd.beg_effective_dt_tm = cnvtdatetime(curdate,
    curtime3), cd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00"),
   cd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cd.active_status_prsnl_id = reqinfo->
   updt_id, cd.active_status_cd =
   IF ((request->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   ,
   cd.updt_id = reqinfo->updt_id, cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_task =
   reqinfo->updt_task,
   cd.updt_cnt = 0, cd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0
    AND (request->qual[d.seq].action_ind=0))
   JOIN (cd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "CHART_DEFINITION"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM chart_definition_hist cd,
   (dummyt d  WITH seq = value(req_knt))
  SET cd.chart_definition_id = request->qual[d.seq].chart_definition_id, cd.action_seq = (request->
   qual[d.seq].action_seq+ 1), cd.chart_source_cd = request->qual[d.seq].chart_source_cd,
   cd.chart_type_cd = request->qual[d.seq].chart_type_cd, cd.sex_cd = request->qual[d.seq].sex_cd, cd
   .min_age = request->qual[d.seq].min_age,
   cd.max_age = request->qual[d.seq].max_age, cd.chart_title = request->qual[d.seq].chart_title, cd
   .x_type_cd = request->qual[d.seq].x_type_cd,
   cd.y_type_cd = request->qual[d.seq].y_type_cd, cd.y_axis_min_val = request->qual[d.seq].
   y_axis_min_val, cd.y_axis_max_val = request->qual[d.seq].y_axis_max_val,
   cd.y_axis_unit_cd = request->qual[d.seq].y_axis_unit_cd, cd.x_axis_section1_min_val = request->
   qual[d.seq].x_axis_section1_min_val, cd.x_axis_section1_max_val = request->qual[d.seq].
   x_axis_section1_max_val,
   cd.x_axis_section2_min_val = request->qual[d.seq].x_axis_section2_min_val, cd
   .x_axis_section2_max_val = request->qual[d.seq].x_axis_section2_max_val, cd
   .x_axis_section2_multiplier = request->qual[d.seq].x_axis_section2_multiplier,
   cd.x_axis_section1_unit_cd = request->qual[d.seq].x_axis_section1_unit_cd, cd
   .x_axis_section2_unit_cd = request->qual[d.seq].x_axis_section2_unit_cd, cd.version = request->
   qual[d.seq].version,
   cd.action_type_flag = request->qual[d.seq].action_ind, cd.action_dt_tm = cnvtdatetime(curdate,
    curtime3), cd.active_ind = request->qual[d.seq].active_ind,
   cd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cd.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 00:00"), cd.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   cd.active_status_prsnl_id = reqinfo->updt_id, cd.active_status_cd =
   IF ((request->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , cd.updt_id = reqinfo->updt_id,
   cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_task = reqinfo->updt_task, cd.updt_cnt = 0,
   cd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0
    AND (request->qual[d.seq].action_ind=0))
   JOIN (cd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "CHART_DEFINITION_HIST"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 UPDATE  FROM chart_definition cd,
   (dummyt d  WITH seq = value(req_knt))
  SET cd.last_action_seq = (request->qual[d.seq].action_seq+ 1), cd.chart_source_cd = request->qual[d
   .seq].chart_source_cd, cd.chart_type_cd = request->qual[d.seq].chart_type_cd,
   cd.sex_cd = request->qual[d.seq].sex_cd, cd.min_age = request->qual[d.seq].min_age, cd.max_age =
   request->qual[d.seq].max_age,
   cd.chart_title = request->qual[d.seq].chart_title, cd.x_type_cd = request->qual[d.seq].x_type_cd,
   cd.y_type_cd = request->qual[d.seq].y_type_cd,
   cd.y_axis_min_val = request->qual[d.seq].y_axis_min_val, cd.y_axis_max_val = request->qual[d.seq].
   y_axis_max_val, cd.y_axis_unit_cd = request->qual[d.seq].y_axis_unit_cd,
   cd.x_axis_section1_min_val = request->qual[d.seq].x_axis_section1_min_val, cd
   .x_axis_section1_max_val = request->qual[d.seq].x_axis_section1_max_val, cd
   .x_axis_section2_min_val = request->qual[d.seq].x_axis_section2_min_val,
   cd.x_axis_section2_max_val = request->qual[d.seq].x_axis_section2_max_val, cd
   .x_axis_section2_multiplier = request->qual[d.seq].x_axis_section2_multiplier, cd
   .x_axis_section1_unit_cd = request->qual[d.seq].x_axis_section1_unit_cd,
   cd.x_axis_section2_unit_cd = request->qual[d.seq].x_axis_section2_unit_cd, cd.version = request->
   qual[d.seq].version, cd.active_ind = request->qual[d.seq].active_ind,
   cd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cd.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 00:00"), cd.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   cd.active_status_prsnl_id = reqinfo->updt_id, cd.active_status_cd =
   IF ((request->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , cd.updt_id = reqinfo->updt_id,
   cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_task = reqinfo->updt_task, cd.updt_cnt = (
   cd.updt_cnt+ 1),
   cd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0
    AND (request->qual[d.seq].action_ind=1))
   JOIN (cd
   WHERE (cd.chart_definition_id=request->qual[d.seq].chart_definition_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = update_error
  SET table_name = "CHART_DEFINITION"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM chart_definition_hist cd,
   (dummyt d  WITH seq = value(req_knt))
  SET cd.chart_definition_id = request->qual[d.seq].chart_definition_id, cd.action_seq = (request->
   qual[d.seq].action_seq+ 1), cd.chart_source_cd = request->qual[d.seq].chart_source_cd,
   cd.chart_type_cd = request->qual[d.seq].chart_type_cd, cd.sex_cd = request->qual[d.seq].sex_cd, cd
   .min_age = request->qual[d.seq].min_age,
   cd.max_age = request->qual[d.seq].max_age, cd.chart_title = request->qual[d.seq].chart_title, cd
   .x_type_cd = request->qual[d.seq].x_type_cd,
   cd.y_type_cd = request->qual[d.seq].y_type_cd, cd.y_axis_min_val = request->qual[d.seq].
   y_axis_min_val, cd.y_axis_max_val = request->qual[d.seq].y_axis_max_val,
   cd.y_axis_unit_cd = request->qual[d.seq].y_axis_unit_cd, cd.x_axis_section1_min_val = request->
   qual[d.seq].x_axis_section1_min_val, cd.x_axis_section1_max_val = request->qual[d.seq].
   x_axis_section1_max_val,
   cd.x_axis_section2_min_val = request->qual[d.seq].x_axis_section2_min_val, cd
   .x_axis_section2_max_val = request->qual[d.seq].x_axis_section2_max_val, cd
   .x_axis_section2_multiplier = request->qual[d.seq].x_axis_section2_multiplier,
   cd.x_axis_section1_unit_cd = request->qual[d.seq].x_axis_section1_unit_cd, cd
   .x_axis_section2_unit_cd = request->qual[d.seq].x_axis_section2_unit_cd, cd.version = request->
   qual[d.seq].version,
   cd.action_type_flag = request->qual[d.seq].action_ind, cd.action_dt_tm = cnvtdatetime(curdate,
    curtime3), cd.active_ind = request->qual[d.seq].active_ind,
   cd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cd.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 00:00"), cd.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   cd.active_status_prsnl_id = reqinfo->updt_id, cd.active_status_cd =
   IF ((request->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , cd.updt_id = reqinfo->updt_id,
   cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd.updt_task = reqinfo->updt_task, cd.updt_cnt = 0,
   cd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0
    AND (request->qual[d.seq].action_ind=1))
   JOIN (cd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "CHART_DEFINITION_HIST"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
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
   reply->qual[knt].chart_definition_id = request->qual[d.seq].chart_definition_id, reply->qual[knt].
   action_ind = request->qual[d.seq].action_ind, reply->qual[knt].last_action_seq = (request->qual[d
   .seq].action_seq+ 1),
   reply->qual[knt].chart_source_cd = request->qual[d.seq].chart_source_cd, reply->qual[knt].
   chart_type_cd = request->qual[d.seq].chart_type_cd, reply->qual[knt].sex_cd = request->qual[d.seq]
   .sex_cd,
   reply->qual[knt].min_age = request->qual[d.seq].min_age, reply->qual[knt].max_age = request->qual[
   d.seq].max_age, reply->qual[knt].chart_title = request->qual[d.seq].chart_title,
   reply->qual[knt].version = request->qual[d.seq].version
  FOOT REPORT
   stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
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
 SET cps_script_version = "001 01/21/04 SF3151"
END GO
