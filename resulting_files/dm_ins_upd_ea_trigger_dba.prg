CREATE PROGRAM dm_ins_upd_ea_trigger:dba
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
 DECLARE v_req_cnt = i4
 DECLARE rdm_current_status = c1 WITH protect, noconstant("S")
 DECLARE rdm_problem_name = vc WITH protect, noconstant("S")
 RECORD action(
   1 row[*]
     2 app_action = i2
 )
 SET v_req_cnt = size(requestin->list_0,5)
 SET stat = alterlist(action->row,v_req_cnt)
 IF (currdb="DB2UDB")
  SELECT INTO "nl:"
   td.suffixed_table_name
   FROM dm_tables_doc td,
    (dummyt d  WITH seq = value(size(requestin->list_0,5)))
   PLAN (d)
    JOIN (td
    WHERE td.table_name=trim(requestin->list_0[d.seq].table_name))
   DETAIL
    requestin->list_0[d.seq].table_name = td.suffixed_table_name
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=28620
    AND cv.cdf_meaning=trim(cnvtupper(requestin->list_0[d.seq].activity_type_meaning),3)
    AND cv.active_ind=1)
  DETAIL
   requestin->list_0[d.seq].activity_type_meaning = cnvtstring(cv.code_value)
  WITH nocounter
 ;end select
 UPDATE  FROM dm_entity_activity_trigger ea,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET ea.active_ind = cnvtint(requestin->list_0[d.seq].active_ind), ea.updt_id = reqinfo->updt_id, ea
   .updt_applctx = reqinfo->updt_applctx,
   ea.updt_task = reqinfo->updt_task, ea.updt_dt_tm = cnvtdatetime(curdate,curtime3), ea.updt_cnt = (
   ea.updt_cnt+ 1)
  PLAN (d)
   JOIN (ea
   WHERE ea.table_name=trim(requestin->list_0[d.seq].table_name,3)
    AND ea.column_name=trim(requestin->list_0[d.seq].column_name,3)
    AND ((ea.pe_col_name=trim(requestin->list_0[d.seq].pe_col_name,3)) OR (ea.pe_col_name=null))
    AND ea.parent_name=trim(requestin->list_0[d.seq].parent_name,3)
    AND ea.entity_activity_type_cd=cnvtreal(requestin->list_0[d.seq].activity_type_meaning))
  WITH nocounter, status(action->row[d.seq].app_action)
 ;end update
 INSERT  FROM dm_entity_activity_trigger ea,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET ea.table_name = trim(requestin->list_0[d.seq].table_name,3), ea.column_name = trim(requestin->
    list_0[d.seq].column_name,3), ea.pe_col_name = trim(requestin->list_0[d.seq].pe_col_name,3),
   ea.parent_name = trim(requestin->list_0[d.seq].parent_name,3), ea.entity_activity_type_cd =
   cnvtreal(requestin->list_0[d.seq].activity_type_meaning), ea.active_ind = cnvtint(requestin->
    list_0[d.seq].active_ind),
   ea.updt_id = 0, ea.updt_applctx = 0.0, ea.updt_task = 0,
   ea.updt_dt_tm = cnvtdatetime(curdate,curtime3), ea.updt_cnt = 0
  PLAN (d
   WHERE (action->row[d.seq].app_action=0))
   JOIN (ea)
  WITH nocounter
 ;end insert
 SET rdm_current_status = "S"
 DECLARE row_cnt = i4
 SELECT INTO "nl"
  table_name
  FROM dm_entity_activity_trigger
  WITH nocounter
 ;end select
 SET row_cnt = curqual
#exit_program
 IF (row_cnt < size(requestin->list_0,5))
  SET readme_data->status = "F"
  SET readme_data->message =
  "dm_ins_upd_ea_trigger- failure, not all tables were loaded into dm_entity_activity_trigger table "
  ROLLBACK
  CALL echo(readme_data->message)
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "dm_entity_activity_trigger table was successfully updated."
 ENDIF
 EXECUTE dm_readme_status
 FREE RECORD action
END GO
