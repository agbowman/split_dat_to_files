CREATE PROGRAM dm_purge_edit_template:dba
 FREE SET reply
 RECORD reply(
   1 updt_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET c_df = "YYYYMMDDHHMMSScc;;d"
 SET c_del_high_log = 1
 SET c_del_dtl_log = 2
 SET c_audit = 3
 SET c_ptf_delete = 1
 SET c_ptf_update = 2
 SET c_active = 1
 SET c_inactive = 2
 SET c_tmpl_changed = 3
 SET c_sf_success = 1
 SET c_sf_failed = 2
 IF ((request->action="DEL"))
  DELETE  FROM dm_purge_table t
   WHERE (t.template_nbr=request->template_nbr)
    AND t.feature_nbr IN (request->feature_nbr, 0)
  ;end delete
  DELETE  FROM dm_adm_purge_table t
   WHERE (t.template_nbr=request->template_nbr)
    AND (t.feature_nbr=request->feature_nbr)
  ;end delete
  DELETE  FROM dm_purge_token t
   WHERE (t.template_nbr=request->template_nbr)
    AND t.feature_nbr IN (request->feature_nbr, 0)
  ;end delete
  DELETE  FROM dm_adm_purge_token t
   WHERE (t.template_nbr=request->template_nbr)
    AND (t.feature_nbr=request->feature_nbr)
  ;end delete
  DELETE  FROM dm_purge_template t
   WHERE (t.template_nbr=request->template_nbr)
    AND t.feature_nbr IN (request->feature_nbr, 0)
  ;end delete
  DELETE  FROM dm_adm_purge_template t
   WHERE (t.template_nbr=request->template_nbr)
    AND (t.feature_nbr=request->feature_nbr)
  ;end delete
 ELSE
  DELETE  FROM dm_purge_table t
   WHERE (t.template_nbr=request->template_nbr)
    AND t.feature_nbr IN (request->feature_nbr, 0)
  ;end delete
  DELETE  FROM dm_adm_purge_table t
   WHERE (t.template_nbr=request->template_nbr)
    AND (t.feature_nbr=request->feature_nbr)
  ;end delete
  DELETE  FROM dm_purge_token t
   WHERE (t.template_nbr=request->template_nbr)
    AND t.feature_nbr IN (request->feature_nbr, 0)
  ;end delete
  DELETE  FROM dm_adm_purge_token t
   WHERE (t.template_nbr=request->template_nbr)
    AND (t.feature_nbr=request->feature_nbr)
  ;end delete
  DELETE  FROM dm_purge_template t
   WHERE (t.template_nbr=request->template_nbr)
    AND t.feature_nbr IN (request->feature_nbr, 0)
  ;end delete
  DELETE  FROM dm_adm_purge_template t
   WHERE (t.template_nbr=request->template_nbr)
    AND (t.feature_nbr=request->feature_nbr)
  ;end delete
  INSERT  FROM dm_purge_template t
   SET t.template_nbr = request->template_nbr, t.feature_nbr = request->feature_nbr, t.schema_dt_tm
     = cnvtdatetime(cnvtdate2(substring(1,8,request->schema_date),"YYYYMMDD"),cnvtint(substring(9,6,
       request->schema_date))),
    t.name = request->name, t.program_str = request->program_str, t.active_ind = request->active_ind,
    t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->
    updt_applctx,
    t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_cnt = 0
  ;end insert
  INSERT  FROM dm_adm_purge_template t
   SET t.template_nbr = request->template_nbr, t.feature_nbr = request->feature_nbr, t.schema_dt_tm
     = cnvtdatetime(cnvtdate2(substring(1,8,request->schema_date),"YYYYMMDD"),cnvtint(substring(9,6,
       request->schema_date))),
    t.name = request->name, t.program_str = request->program_str, t.active_ind = request->active_ind,
    t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->
    updt_applctx,
    t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_cnt = 0
  ;end insert
  IF (size(request->tokens,5) > 0)
   INSERT  FROM dm_purge_token t,
     (dummyt d1  WITH seq = value(size(request->tokens,5)))
    SET t.template_nbr = request->template_nbr, t.feature_nbr = request->feature_nbr, t.schema_dt_tm
      = cnvtdatetime(cnvtdate2(substring(1,8,request->schema_date),"YYYYMMDD"),cnvtint(substring(9,6,
        request->schema_date))),
     t.token_str = request->tokens[d1.seq].token_str, t.prompt_str = request->tokens[d1.seq].
     prompt_str, t.data_type_flag = request->tokens[d1.seq].data_type_flag,
     t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->
     updt_applctx,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_cnt = 0
    PLAN (d1)
     JOIN (t)
    WITH nocounter, outerjoin = d1
   ;end insert
   INSERT  FROM dm_adm_purge_token t,
     (dummyt d1  WITH seq = value(size(request->tokens,5)))
    SET t.template_nbr = request->template_nbr, t.feature_nbr = request->feature_nbr, t.schema_dt_tm
      = cnvtdatetime(cnvtdate2(substring(1,8,request->schema_date),"YYYYMMDD"),cnvtint(substring(9,6,
        request->schema_date))),
     t.token_str = request->tokens[d1.seq].token_str, t.prompt_str = request->tokens[d1.seq].
     prompt_str, t.data_type_flag = request->tokens[d1.seq].data_type_flag,
     t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->
     updt_applctx,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_cnt = 0
    PLAN (d1)
     JOIN (t)
    WITH nocounter, outerjoin = d1
   ;end insert
  ENDIF
  IF (size(request->tables,5) > 0)
   INSERT  FROM dm_purge_table t,
     (dummyt d1  WITH seq = value(size(request->tables,5)))
    SET t.template_nbr = request->template_nbr, t.feature_nbr = request->feature_nbr, t.schema_dt_tm
      = cnvtdatetime(cnvtdate2(substring(1,8,request->schema_date),"YYYYMMDD"),cnvtint(substring(9,6,
        request->schema_date))),
     t.parent_table = request->tables[d1.seq].parent_table, t.child_table = request->tables[d1.seq].
     child_table, t.child_where = request->tables[d1.seq].child_where,
     t.purge_type_flag = request->tables[d1.seq].purge_type_flag, t.parent_col1 = request->tables[d1
     .seq].parent_col1, t.child_col1 = request->tables[d1.seq].child_col1,
     t.parent_col2 = request->tables[d1.seq].parent_col2, t.child_col2 = request->tables[d1.seq].
     child_col2, t.parent_col3 = request->tables[d1.seq].parent_col3,
     t.child_col3 = request->tables[d1.seq].child_col3, t.parent_col4 = request->tables[d1.seq].
     parent_col4, t.child_col4 = request->tables[d1.seq].child_col4,
     t.parent_col5 = request->tables[d1.seq].parent_col5, t.child_col5 = request->tables[d1.seq].
     child_col5, t.updt_task = reqinfo->updt_task,
     t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->updt_applctx, t.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     t.updt_cnt = 0
    PLAN (d1)
     JOIN (t)
    WITH nocounter, outerjoin = d1
   ;end insert
   INSERT  FROM dm_adm_purge_table t,
     (dummyt d1  WITH seq = value(size(request->tables,5)))
    SET t.template_nbr = request->template_nbr, t.feature_nbr = request->feature_nbr, t.schema_dt_tm
      = cnvtdatetime(cnvtdate2(substring(1,8,request->schema_date),"YYYYMMDD"),cnvtint(substring(9,6,
        request->schema_date))),
     t.parent_table = request->tables[d1.seq].parent_table, t.child_table = request->tables[d1.seq].
     child_table, t.child_where = request->tables[d1.seq].child_where,
     t.purge_type_flag = request->tables[d1.seq].purge_type_flag, t.parent_col1 = request->tables[d1
     .seq].parent_col1, t.child_col1 = request->tables[d1.seq].child_col1,
     t.parent_col2 = request->tables[d1.seq].parent_col2, t.child_col2 = request->tables[d1.seq].
     child_col2, t.parent_col3 = request->tables[d1.seq].parent_col3,
     t.child_col3 = request->tables[d1.seq].child_col3, t.parent_col4 = request->tables[d1.seq].
     parent_col4, t.child_col4 = request->tables[d1.seq].child_col4,
     t.parent_col5 = request->tables[d1.seq].parent_col5, t.child_col5 = request->tables[d1.seq].
     child_col5, t.updt_task = reqinfo->updt_task,
     t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->updt_applctx, t.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     t.updt_cnt = 0
    PLAN (d1)
     JOIN (t)
    WITH nocounter, outerjoin = d1
   ;end insert
  ENDIF
  DECLARE omf_get_pers_full() = c255
  SELECT INTO "nl:"
   updt_name = omf_get_pers_full(reqinfo->updt_id)
   FROM dual
   DETAIL
    reply->updt_name = updt_name
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
END GO
