CREATE PROGRAM dm_ens_cv_filter:dba
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
 FREE RECORD reply
 RECORD reply(
   1 filter_qual = i4
   1 filter[*]
     2 status = i2
     2 code_value_filter_id = f8
     2 code_set = i4
     2 filter_type_cd = f8
     2 filter_ind = i2
     2 parent_entity_name1 = vc
     2 flex1_id = f8
     2 parent_entity_name2 = vc
     2 flex2_id = f8
     2 parent_entity_name3 = vc
     2 flex3_id = f8
     2 parent_entity_name4 = vc
     2 flex4_id = f8
     2 parent_entity_name5 = vc
     2 flex5_id = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->filter_qual = request->filter_qual
 SET stat = alterlist(reply->filter,reply->filter_qual)
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET loop_start = 1
 SET active_status_cd = 0.0
 SET inactive_status_cd = 0.0
 IF ((reqdata->active_status_cd > 0))
  SET active_status_cd = reqdata->active_status_cd
 ELSE
  SET code_value = 0.0
  SET code_set = 48
  SET cdf_meaning = "ACTIVE"
  EXECUTE cpm_get_cd_for_cdf
  SET active_status_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
    " from code_set ",trim(cnvtstring(code_set)))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reqdata->inactive_status_cd > 0))
  SET inactive_status_cd = reqdata->inactive_status_cd
 ELSE
  SET code_value = 0.0
  SET code_set = 48
  SET cdf_meaning = "INACTIVE"
  EXECUTE cpm_get_cd_for_cdf
  SET inactive_status_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
    " from code_set ",trim(cnvtstring(code_set)))
   GO TO exit_script
  ENDIF
 ENDIF
 SET now_dt_tm = cnvtdatetime(curdate,curtime3)
 SET end_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(request->filter_qual))
  PLAN (d
   WHERE d.seq > 0)
  DETAIL
   reply->filter[d.seq].code_value_filter_id = request->filter[d.seq].code_value_filter_id, reply->
   filter[d.seq].code_set = request->filter[d.seq].code_set, reply->filter[d.seq].filter_type_cd =
   request->filter[d.seq].filter_type_cd,
   reply->filter[d.seq].filter_ind = request->filter[d.seq].filter_ind, reply->filter[d.seq].
   parent_entity_name1 = request->filter[d.seq].parent_entity_name1, reply->filter[d.seq].flex1_id =
   request->filter[d.seq].flex1_id,
   reply->filter[d.seq].parent_entity_name2 = request->filter[d.seq].parent_entity_name2, reply->
   filter[d.seq].flex2_id = request->filter[d.seq].flex2_id, reply->filter[d.seq].parent_entity_name3
    = request->filter[d.seq].parent_entity_name3,
   reply->filter[d.seq].flex3_id = request->filter[d.seq].flex3_id, reply->filter[d.seq].
   parent_entity_name4 = request->filter[d.seq].parent_entity_name4, reply->filter[d.seq].flex4_id =
   request->filter[d.seq].flex4_id,
   reply->filter[d.seq].parent_entity_name5 = request->filter[d.seq].parent_entity_name5, reply->
   filter[d.seq].flex5_id = request->filter[d.seq].flex5_id, reply->filter[d.seq].active_ind =
   request->filter[d.seq].active_ind
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = input_error
  SET table_name = "REQUEST_REPLY"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO request->filter_qual)
   IF ((request->filter[i].code_value_filter_id > 0))
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM code_value_filter cvf
     SET cvf.code_set = request->filter[i].code_set, cvf.filter_type_cd = request->filter[i].
      filter_type_cd, cvf.filter_ind = request->filter[i].filter_ind,
      cvf.parent_entity_name1 = request->filter[i].parent_entity_name1, cvf.flex1_id = request->
      filter[i].flex1_id, cvf.parent_entity_name2 = request->filter[i].parent_entity_name2,
      cvf.flex2_id = request->filter[i].flex2_id, cvf.parent_entity_name3 = request->filter[i].
      parent_entity_name3, cvf.flex3_id = request->filter[i].flex3_id,
      cvf.parent_entity_name4 = request->filter[i].parent_entity_name4, cvf.flex4_id = request->
      filter[i].flex4_id, cvf.parent_entity_name5 = request->filter[i].parent_entity_name5,
      cvf.flex5_id = request->filter[i].flex5_id, cvf.updt_id = reqinfo->updt_id, cvf.updt_cnt = (cvf
      .updt_cnt+ 1),
      cvf.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvf.updt_task = reqinfo->updt_task, cvf
      .updt_applctx = reqinfo->updt_applctx,
      cvf.active_ind = request->filter[i].active_ind, cvf.active_status_cd =
      IF ((request->filter[i].active_ind > 0)) active_status_cd
      ELSE inactive_status_cd
      ENDIF
      , cvf.beg_effective_dt_tm =
      IF ((request->filter[i].beg_effective_dt_tm > 0)) cnvtdatetime(request->filter[i].
        beg_effective_dt_tm)
      ELSE cnvtdatetime(now_dt_tm)
      ENDIF
      ,
      cvf.end_effective_dt_tm =
      IF ((request->filter[i].end_effective_dt_tm > 0)
       AND (request->filter[i].active_ind > 0)) cnvtdatetime(request->filter[i].end_effective_dt_tm)
      ELSEIF ((request->filter[i].active_ind > 0)) cnvtdatetime(end_dt_tm)
      ELSE cnvtdatetime(now_dt_tm)
      ENDIF
     PLAN (cvf
      WHERE (cvf.code_value_filter_id=request->filter[i].code_value_filter_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "CODE_VALUE_FILTER"
     GO TO exit_script
    ELSE
     SET reply->filter[i].status = 1
    ENDIF
   ELSE
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     y = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      request->filter[i].code_value_filter_id = cnvtreal(y)
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = gen_nbr_error
     SET table_name = "REFERENCE_SEQ"
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM code_value_filter cvf
     SET cvf.code_value_filter_id = request->filter[i].code_value_filter_id, cvf.code_set = request->
      filter[i].code_set, cvf.filter_type_cd = request->filter[i].filter_type_cd,
      cvf.filter_ind = request->filter[i].filter_ind, cvf.parent_entity_name1 = request->filter[i].
      parent_entity_name1, cvf.flex1_id = request->filter[i].flex1_id,
      cvf.parent_entity_name2 = request->filter[i].parent_entity_name2, cvf.flex2_id = request->
      filter[i].flex2_id, cvf.parent_entity_name3 = request->filter[i].parent_entity_name3,
      cvf.flex3_id = request->filter[i].flex3_id, cvf.parent_entity_name4 = request->filter[i].
      parent_entity_name4, cvf.flex4_id = request->filter[i].flex4_id,
      cvf.parent_entity_name5 = request->filter[i].parent_entity_name5, cvf.flex5_id = request->
      filter[i].flex5_id, cvf.updt_id = reqinfo->updt_id,
      cvf.updt_cnt = 0, cvf.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvf.updt_task = reqinfo->
      updt_task,
      cvf.updt_applctx = reqinfo->updt_applctx, cvf.active_ind = 1, cvf.active_status_cd =
      active_status_cd,
      cvf.active_status_prsnl_id = reqinfo->updt_id, cvf.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), cvf.beg_effective_dt_tm =
      IF ((request->filter[i].beg_effective_dt_tm > 0)) cnvtdatetime(request->filter[i].
        beg_effective_dt_tm)
      ELSE cnvtdatetime(now_dt_tm)
      ENDIF
      ,
      cvf.end_effective_dt_tm =
      IF ((request->filter[i].end_effective_dt_tm > 0)) cnvtdatetime(request->filter[i].
        end_effective_dt_tm)
      ELSE cnvtdatetime(end_dt_tm)
      ENDIF
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "CODE_VALUE_FILTER"
     GO TO exit_script
    ELSE
     SET reply->filter[i].status = 1
     SET reply->filter[i].code_value_filter_id = request->filter[i].code_value_filter_id
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed != false)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GENERATE SEQ"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
