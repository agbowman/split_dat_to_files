CREATE PROGRAM cps_ens_ref_dataset:dba
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
      2 ref_dataset_id = f8
      2 action_seq = i4
      2 action_ind = i2
      2 chart_definition_id = f8
      2 display_name = vc
      2 display_type_cd = f8
      2 active_ind = i2
      2 point[*]
        3 ref_datapoint_id = f8
        3 action_seq = i4
        3 action_ind = i2
        3 x_val = f8
        3 y_val = f8
        3 active_ind = i2
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
 DECLARE max_point_knt = i4 WITH public, noconstant(0)
 DECLARE point_knt = i4 WITH public, noconstant(0)
 DECLARE next_id = f8 WITH public, noconstant(0.0)
 DECLARE active_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE inactive_status_cd = f8 WITH public, noconstant(0.0)
 IF ((reqdata->active_status_cd < 1))
  SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_status_cd)
  IF (active_status_cd < 1)
   SET failed = select_error
   SET tabe_name = "CODE_VALUE"
   SET serrmsg = "Failure finding the code_value for ACTIVE from code_set 48"
  ENDIF
  GO TO exit_script
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
 SET stat = alterlist(reply->qual,req_knt)
 FOR (i = 1 TO req_knt)
   SET reply->qual[i].ref_dataset_id = request->qual[i].ref_dataset_id
   SET reply->qual[i].action_seq = request->qual[i].action_seq
   SET reply->qual[i].action_ind = request->qual[i].action_ind
   SET reply->qual[i].chart_definition_id = request->qual[i].chart_definition_id
   SET reply->qual[i].display_name = request->qual[i].display_name
   SET reply->qual[i].display_type_cd = request->qual[i].display_type_cd
   SET reply->qual[i].active_ind = request->qual[i].active_ind
   SET point_knt = size(request->qual[i].point,5)
   IF (max_point_knt < point_knt)
    SET max_point_knt = point_knt
   ENDIF
   SET stat = alterlist(reply->qual[i].point,point_knt)
   FOR (j = 1 TO point_knt)
     SET reply->qual[i].point[j].ref_datapoint_id = request->qual[i].point[j].ref_datapoint_id
     SET reply->qual[i].point[j].action_seq = request->qual[i].point[j].action_seq
     SET reply->qual[i].point[j].action_ind = request->qual[i].point[j].action_ind
     SET reply->qual[i].point[j].x_val = request->qual[i].point[j].x_val
     SET reply->qual[i].point[j].y_val = request->qual[i].point[j].y_val
     SET reply->qual[i].point[j].active_ind = request->qual[i].point[j].active_ind
   ENDFOR
 ENDFOR
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_knt)),
   ref_dataset rd
  PLAN (d
   WHERE d.seq > 0)
   JOIN (rd
   WHERE (rd.chart_definition_id=request->qual[d.seq].chart_definition_id)
    AND (rd.display_name=request->qual[d.seq].display_name))
  DETAIL
   IF ((reply->qual[d.seq].ref_dataset_id > 0)
    AND (rd.ref_dataset_id != reply->qual[d.seq].ref_dataset_id))
    reply->qual[d.seq].action_ind = 3
   ELSE
    reply->qual[d.seq].action_ind = 2, reply->qual[d.seq].ref_dataset_id = rd.ref_dataset_id
   ENDIF
   reply->qual[d.seq].action_seq = rd.last_action_seq
   IF ((reply->qual[d.seq].action_ind != 3))
    IF ((rd.display_type_cd != reply->qual[d.seq].display_type_cd))
     reply->qual[d.seq].action_ind = 1
    ENDIF
    IF ((rd.active_ind != reply->qual[d.seq].active_ind))
     reply->qual[d.seq].action_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DETERMINE_SET_ACTION"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_knt)),
   (dummyt d2  WITH seq = value(max_point_knt)),
   ref_datapoint rd
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE d2.seq > 0
    AND d2.seq <= size(reply->qual[d1.seq].point,5))
   JOIN (rd
   WHERE (rd.ref_dataset_id=reply->qual[d1.seq].ref_dataset_id)
    AND (rd.x_val=reply->qual[d1.seq].point[d2.seq].x_val)
    AND (rd.y_val=reply->qual[d1.seq].point[d2.seq].y_val))
  DETAIL
   IF ((reply->qual[d1.seq].point[d2.seq].ref_datapoint_id > 0)
    AND (rd.ref_datapoint_id != reply->qual[d1.seq].point[d2.seq].ref_datapoint_id))
    reply->qual[d1.seq].point[d2.seq].action_ind = 3
   ELSE
    reply->qual[d1.seq].point[d2.seq].action_ind = 2, reply->qual[d1.seq].point[d2.seq].
    ref_datapoint_id = rd.ref_datapoint_id
   ENDIF
   reply->qual[d1.seq].point[d2.seq].action_seq = rd.last_action_seq
   IF ((reply->qual[d1.seq].point[d2.seq].action_ind != 3)
    AND (reply->qual[d1.seq].action_ind != 3))
    IF ((rd.active_ind != reply->qual[d1.seq].point[d2.seq].active_ind))
     reply->qual[d1.seq].point[d2.seq].action_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DETERMINE_SET_ACTION"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO req_knt)
  IF ((reply->qual[i].ref_dataset_id < 1)
   AND (reply->qual[i].action_ind=0))
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
   SET reply->qual[i].ref_dataset_id = next_id
  ENDIF
  FOR (j = 1 TO value(size(reply->qual[i].point,5)))
    IF ((reply->qual[i].point[j].ref_datapoint_id < 1)
     AND (reply->qual[i].point[j].action_ind=0))
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
      SET table_name = "PCO_SEQ2"
      GO TO exit_script
     ENDIF
     SET reply->qual[i].point[j].ref_datapoint_id = next_id
    ENDIF
  ENDFOR
 ENDFOR
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM ref_dataset rd,
   (dummyt d  WITH seq = value(req_knt))
  SET rd.ref_dataset_id = reply->qual[d.seq].ref_dataset_id, rd.last_action_seq = (reply->qual[d.seq]
   .action_seq+ 1), rd.chart_definition_id = reply->qual[d.seq].chart_definition_id,
   rd.display_name = reply->qual[d.seq].display_name, rd.display_type_cd = reply->qual[d.seq].
   display_type_cd, rd.active_ind = reply->qual[d.seq].active_ind,
   rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), rd.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), rd.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.active_status_prsnl_id = reqinfo->updt_id, rd.active_status_cd =
   IF ((reply->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id,
   rd.updt_dt_tm = cnvtdatetime(curdate,curtime3), rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0,
   rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0
    AND (reply->qual[d.seq].action_ind=0))
   JOIN (rd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "REF_DATASET"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM ref_dataset_hist rd,
   (dummyt d  WITH seq = value(req_knt))
  SET rd.ref_dataset_id = reply->qual[d.seq].ref_dataset_id, rd.action_seq = (reply->qual[d.seq].
   action_seq+ 1), rd.chart_definition_id = reply->qual[d.seq].chart_definition_id,
   rd.display_name = reply->qual[d.seq].display_name, rd.display_type_cd = reply->qual[d.seq].
   display_type_cd, rd.action_type_flag = reply->qual[d.seq].action_ind,
   rd.action_dt_tm = cnvtdatetime(curdate,curtime3), rd.active_ind = reply->qual[d.seq].active_ind,
   rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), rd.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3), rd.active_status_prsnl_id = reqinfo->updt_id,
   rd.active_status_cd =
   IF ((reply->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0
    AND (reply->qual[d.seq].action_ind=0))
   JOIN (rd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "REF_DATASET_HIST"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 UPDATE  FROM ref_dataset rd,
   (dummyt d  WITH seq = value(req_knt))
  SET rd.last_action_seq = (reply->qual[d.seq].action_seq+ 1), rd.chart_definition_id = reply->qual[d
   .seq].chart_definition_id, rd.display_name = reply->qual[d.seq].display_name,
   rd.display_type_cd = reply->qual[d.seq].display_type_cd, rd.active_ind = reply->qual[d.seq].
   active_ind, rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), rd.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3), rd.active_status_prsnl_id = reqinfo->updt_id,
   rd.active_status_cd =
   IF ((reply->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.updt_task = reqinfo->updt_task, rd.updt_cnt = (rd.updt_cnt+ 1), rd.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE d.seq > 0
    AND (reply->qual[d.seq].action_ind=1))
   JOIN (rd
   WHERE (rd.ref_dataset_id=reply->qual[d.seq].ref_dataset_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = update_error
  SET table_name = "REF_DATASET"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM ref_dataset_hist rd,
   (dummyt d  WITH seq = value(req_knt))
  SET rd.ref_dataset_id = reply->qual[d.seq].ref_dataset_id, rd.action_seq = (reply->qual[d.seq].
   action_seq+ 1), rd.chart_definition_id = reply->qual[d.seq].chart_definition_id,
   rd.display_name = reply->qual[d.seq].display_name, rd.display_type_cd = reply->qual[d.seq].
   display_type_cd, rd.action_type_flag = reply->qual[d.seq].action_ind,
   rd.action_dt_tm = cnvtdatetime(curdate,curtime3), rd.active_ind = reply->qual[d.seq].active_ind,
   rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), rd.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3), rd.active_status_prsnl_id = reqinfo->updt_id,
   rd.active_status_cd =
   IF ((reply->qual[d.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE d.seq > 0
    AND (reply->qual[d.seq].action_ind=1))
   JOIN (rd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = update_error
  SET table_name = "REF_DATASET_HIST"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM ref_datapoint rd,
   (dummyt d1  WITH seq = value(req_knt)),
   (dummyt d2  WITH seq = value(max_point_knt))
  SET rd.ref_datapoint_id = reply->qual[d1.seq].point[d2.seq].ref_datapoint_id, rd.last_action_seq =
   (reply->qual[d1.seq].point[d2.seq].action_seq+ 1), rd.ref_dataset_id = reply->qual[d1.seq].
   ref_dataset_id,
   rd.x_val = reply->qual[d1.seq].point[d2.seq].x_val, rd.y_val = reply->qual[d1.seq].point[d2.seq].
   y_val, rd.active_ind = reply->qual[d1.seq].point[d2.seq].active_ind,
   rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), rd.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2003"), rd.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.active_status_prsnl_id = reqinfo->updt_id, rd.active_status_cd =
   IF ((reply->qual[d1.seq].point[d2.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id,
   rd.updt_dt_tm = cnvtdatetime(curdate,curtime3), rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0,
   rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE d2.seq > 0
    AND d2.seq <= size(reply->qual[d1.seq].point,5)
    AND (reply->qual[d1.seq].point[d2.seq].action_ind=0))
   JOIN (rd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "REF_DATAPOINT"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM ref_datapoint_hist rd,
   (dummyt d1  WITH seq = value(req_knt)),
   (dummyt d2  WITH seq = value(max_point_knt))
  SET rd.ref_datapoint_id = reply->qual[d1.seq].point[d2.seq].ref_datapoint_id, rd.action_seq = (
   reply->qual[d1.seq].point[d2.seq].action_seq+ 1), rd.ref_dataset_id = reply->qual[d1.seq].
   ref_dataset_id,
   rd.x_val = reply->qual[d1.seq].point[d2.seq].x_val, rd.y_val = reply->qual[d1.seq].point[d2.seq].
   y_val, rd.action_type_flag = reply->qual[d1.seq].point[d2.seq].action_ind,
   rd.action_dt_tm = cnvtdatetime(curdate,curtime3), rd.active_ind = reply->qual[d1.seq].point[d2.seq
   ].active_ind, rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2003"), rd.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3), rd.active_status_prsnl_id = reqinfo->updt_id,
   rd.active_status_cd =
   IF ((reply->qual[d1.seq].point[d2.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE d2.seq > 0
    AND d2.seq <= size(reply->qual[d1.seq].point,5)
    AND (reply->qual[d1.seq].point[d2.seq].action_ind=0))
   JOIN (rd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "REF_DATAPOINT_HIST"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 UPDATE  FROM ref_datapoint rd,
   (dummyt d1  WITH seq = value(req_knt)),
   (dummyt d2  WITH seq = value(max_point_knt))
  SET rd.last_action_seq = (reply->qual[d1.seq].point[d2.seq].action_seq+ 1), rd.ref_dataset_id =
   reply->qual[d1.seq].ref_dataset_id, rd.x_val = reply->qual[d1.seq].point[d2.seq].x_val,
   rd.y_val = reply->qual[d1.seq].point[d2.seq].y_val, rd.active_ind = reply->qual[d1.seq].point[d2
   .seq].active_ind, rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2003"), rd.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3), rd.active_status_prsnl_id = reqinfo->updt_id,
   rd.active_status_cd =
   IF ((reply->qual[d1.seq].point[d2.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.updt_task = reqinfo->updt_task, rd.updt_cnt = (rd.updt_cnt+ 1), rd.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE d2.seq > 0
    AND d2.seq <= size(reply->qual[d1.seq].point,5)
    AND (reply->qual[d1.seq].point[d2.seq].action_ind=1))
   JOIN (rd
   WHERE (rd.ref_datapoint_id=reply->qual[d1.seq].point[d2.seq].ref_datapoint_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "REF_DATAPOINT_HIST"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,0)
 SET ierrcode = 0
 INSERT  FROM ref_datapoint_hist rd,
   (dummyt d1  WITH seq = value(req_knt)),
   (dummyt d2  WITH seq = value(max_point_knt))
  SET rd.ref_datapoint_id = reply->qual[d1.seq].point[d2.seq].ref_datapoint_id, rd.action_seq = (
   reply->qual[d1.seq].point[d2.seq].action_seq+ 1), rd.ref_dataset_id = reply->qual[d1.seq].
   ref_dataset_id,
   rd.x_val = reply->qual[d1.seq].point[d2.seq].x_val, rd.y_val = reply->qual[d1.seq].point[d2.seq].
   y_val, rd.action_type_flag = reply->qual[d1.seq].point[d2.seq].action_ind,
   rd.action_dt_tm = cnvtdatetime(curdate,curtime3), rd.active_ind = reply->qual[d1.seq].point[d2.seq
   ].active_ind, rd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.end_effective_dt_tm = cnvtdatetime("31-DEC-2003"), rd.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3), rd.active_status_prsnl_id = reqinfo->updt_id,
   rd.active_status_cd =
   IF ((reply->qual[d1.seq].point[d2.seq].active_ind=1)) active_status_cd
   ELSE inactive_status_cd
   ENDIF
   , rd.updt_id = reqinfo->updt_id, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rd.updt_task = reqinfo->updt_task, rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE d2.seq > 0
    AND d2.seq <= size(reply->qual[d1.seq].point,5)
    AND (reply->qual[d1.seq].point[d2.seq].action_ind=1))
   JOIN (rd
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,0)
 IF (ierrcode > 0)
  SET failed = update_error
  SET table_name = "REF_DATAPOINT_HIST"
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
 SET cps_script_version = "000 11/05/03 SF3151"
END GO
