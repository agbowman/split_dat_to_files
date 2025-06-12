CREATE PROGRAM dm_add_upt_prg_arch_req:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 ccl_error_msg = c132
    1 request_id = f8
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET pass_info_error = 14
 SET ccl_error = 15
 SET req_complete_error = 16
 SET data_error = 17
 SET proc_id_error = 18
 SET log_id_error = 19
 SET failed = false
 SET table_name = fillstring(50," ")
 SET req_id = 0
 SET new_dep_id = 0
 SET new_ind_id = 0
 SET init_updt_cnt = 0
 SET process_active_ind = 0
 SET table_name = fillstring(30," ")
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET pa_dummy = 0
 SET pa_cd = 0
 SET nbr_of_entries = 0
 SET nbr_of_entries = size(dm_prg_arch_req->pa_req,5)
 FOR (ent_cnt = 1 TO nbr_of_entries)
   IF (trim(dm_prg_arch_req->pa_req[ent_cnt].purge_archive_flag) != ""
    AND (dm_prg_arch_req->pa_req[ent_cnt].search_process_id != 0)
    AND trim(dm_prg_arch_req->pa_req[ent_cnt].key_col_name) != ""
    AND trim(dm_prg_arch_req->pa_req[ent_cnt].key_col_value) != ""
    AND trim(dm_prg_arch_req->pa_req[ent_cnt].table_name) != ""
    AND (dm_prg_arch_req->pa_req[ent_cnt].purge_archive_dt_tm != 0))
    SET table_name = "PA_SEARCH_PROCESS"
    SELECT INTO "nl:"
     p.search_process_id
     FROM pa_search_process p
     WHERE (p.search_process_id=dm_prg_arch_req->pa_req[ent_cnt].search_process_id)
     DETAIL
      process_active_ind = p.active_ind
     WITH nocounter
    ;end select
    IF (((curqual=0) OR (process_active_ind=0)) )
     SET failed = proc_id_error
     SET reply->status_data.subeventstatus[1].operationname = "PROC_ID_ERROR"
     GO TO exit_script
    ENDIF
    SET table_name = "PA_LOG"
    SELECT INTO "nl:"
     pl.log_id
     FROM pa_log pl
     WHERE (pl.log_id=dm_prg_arch_req->pa_req[ent_cnt].log_id)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = log_id_error
     SET reply->status_data.subeventstatus[1].operationname = "LOG_ID_ERROR"
     GO TO exit_script
    ENDIF
    SET table_name = "CODE_VALUE"
    SELECT
     IF (cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].purge_archive_flag)="P")
      WHERE cv.code_set=14259
       AND cv.active_ind=true
       AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND cv.cdf_meaning="PURGE_PEND"
     ELSEIF (cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].purge_archive_flag)="A")
      WHERE cv.code_set=14259
       AND cv.active_ind=true
       AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND cv.cdf_meaning="ARCH_PEND"
     ELSE
     ENDIF
     INTO "nl:"
     cv.code_value
     FROM code_value cv
     DETAIL
      pa_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = select_error
     SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
     GO TO exit_script
    ENDIF
    SET table_name = "PA_REQUEST"
    SET cur_meaning = fillstring(12," ")
    SELECT INTO "nl:"
     par.request_id
     FROM pa_request par
     WHERE par.table_name=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].table_name))
      AND par.key_col_name=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].key_col_name))
      AND par.key_col_value=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].key_col_value))
     DETAIL
      req_id = par.request_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET table_name = "PA_REQUEST"
     SELECT INTO "nl:"
      dm_x = seq(pa_request_seq,nextval)
      FROM dual
      DETAIL
       req_id = cnvtreal(dm_x)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR_ERROR"
      GO TO exit_script
     ENDIF
     SET reply->request_id = req_id
     INSERT  FROM pa_request par
      SET par.request_id = req_id, par.search_process_id = dm_prg_arch_req->pa_req[ent_cnt].
       search_process_id, par.log_id = dm_prg_arch_req->pa_req[ent_cnt].log_id,
       par.key_col_name = trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].key_col_name)), par
       .key_col_value = trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].key_col_value)), par
       .purge_archive_cd = pa_cd,
       par.description = trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].description)), par
       .table_name = trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].table_name)), par
       .purge_archive_dt_tm = cnvtdatetime(dm_prg_arch_req->pa_req[ent_cnt].purge_archive_dt_tm),
       par.create_dt_tm = cnvtdatetime(curdate,curtime3), par.updt_cnt = init_updt_cnt, par
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       par.updt_id = reqinfo->updt_id, par.updt_task = reqinfo->updt_task, par.updt_applctx = reqinfo
       ->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      SET reply->status_data.subeventstatus[1].operationname = "INSERT_ERROR"
      GO TO exit_script
     ENDIF
     SET nbr_of_dep = 0
     SET nbr_of_dep = size(dm_prg_arch_req->pa_req[ent_cnt].pa_req_dep,5)
     SET table_name = "PA_REQ_DEPENDENCY"
     FOR (dep_cnt = 1 TO nbr_of_dep)
       CALL insert_pa_req_dep(pa_dummy)
     ENDFOR
     SET nbr_of_ind = 0
     SET nbr_of_ind = size(dm_prg_arch_req->pa_req[ent_cnt].pa_req_ind,5)
     SET table_name = "PA_REQ_INDEX"
     FOR (ind_cnt = 1 TO nbr_of_ind)
       CALL insert_pa_req_ind(pa_dummy)
     ENDFOR
    ELSE
     SET table_name = "PA_REQUEST"
     SET cur_meaning = fillstring(12," ")
     SELECT INTO "nl:"
      cv.cdf_meaning
      FROM code_value cv,
       pa_request par
      PLAN (par
       WHERE par.table_name=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].table_name))
        AND par.key_col_name=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].key_col_name))
        AND par.key_col_value=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].key_col_value)))
       JOIN (cv
       WHERE cv.code_value=par.purge_archive_cd)
      DETAIL
       cur_meaning = cv.cdf_meaning
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = data_error
      SET reply->status_data.subeventstatus[1].operationname = "DATA_ERROR"
      GO TO exit_script
     ENDIF
     IF (((cur_meaning="PURGE_COMP") OR (cur_meaning="ARCH_COMP")) )
      SET failed = req_complete_error
      SET reply->status_data.subeventstatus[1].operationname = "REQ_COMPLETE_ERROR"
      GO TO exit_script
     ENDIF
     UPDATE  FROM pa_request par
      SET par.search_process_id = dm_prg_arch_req->pa_req[ent_cnt].search_process_id, par.log_id =
       dm_prg_arch_req->pa_req[ent_cnt].log_id, par.purge_archive_cd = pa_cd,
       par.description =
       IF (trim(dm_prg_arch_req->pa_req[ent_cnt].description)="") description
       ELSE trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].description))
       ENDIF
       , par.table_name = trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].table_name)), par
       .purge_archive_dt_tm = cnvtdatetime(dm_prg_arch_req->pa_req[ent_cnt].purge_archive_dt_tm),
       par.updt_cnt = (par.updt_cnt+ 1), par.updt_dt_tm = cnvtdatetime(curdate,curtime3), par.updt_id
        = reqinfo->updt_id,
       par.updt_task = reqinfo->updt_task, par.updt_applctx = reqinfo->updt_applctx
      WHERE par.table_name=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].table_name))
       AND par.key_col_name=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].key_col_name))
       AND par.key_col_value=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].key_col_value))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      SET reply->status_data.subeventstatus[1].operationname = "UPDATE_ERROR"
      GO TO exit_script
     ENDIF
     DELETE  FROM pa_req_dependency
      WHERE request_id=req_id
     ;end delete
     DELETE  FROM pa_req_index
      WHERE request_id=req_id
     ;end delete
     SET nbr_of_dep = 0
     SET nbr_of_dep = size(dm_prg_arch_req->pa_req[ent_cnt].pa_req_dep,5)
     SET table_name = "PA_REQ_DEPENDENCY"
     FOR (dep_cnt = 1 TO nbr_of_dep)
       CALL insert_pa_req_dep(pa_dummy)
     ENDFOR
     SET nbr_of_ind = 0
     SET nbr_of_ind = size(dm_prg_arch_req->pa_req[ent_cnt].pa_req_ind,5)
     SET table_name = "PA_REQ_INDEX"
     FOR (ind_cnt = 1 TO nbr_of_ind)
       CALL insert_pa_req_ind(pa_dummy)
     ENDFOR
    ENDIF
   ELSE
    SET failed = pass_info_error
    SET reply->status_data.subeventstatus[1].operationname = "PASS_INFO_ERROR"
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE insert_pa_req_dep(dummy)
   IF (trim(dm_prg_arch_req->pa_req[ent_cnt].pa_req_dep[dep_cnt].table_name) != ""
    AND trim(dm_prg_arch_req->pa_req[ent_cnt].pa_req_dep[dep_cnt].column_name) != ""
    AND trim(dm_prg_arch_req->pa_req[ent_cnt].pa_req_dep[dep_cnt].column_value) != "")
    SELECT INTO "nl:"
     dm_x = seq(pa_req_dependency_seq,nextval)
     FROM dual
     DETAIL
      new_dep_id = cnvtreal(dm_x)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = gen_nbr_error
     SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR_ERROR"
     GO TO exit_script
    ENDIF
    INSERT  FROM pa_req_dependency pard
     SET pard.dependency_id = new_dep_id, pard.request_id = req_id, pard.table_name = trim(cnvtupper(
        dm_prg_arch_req->pa_req[ent_cnt].pa_req_dep[dep_cnt].table_name)),
      pard.column_name = trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].pa_req_dep[dep_cnt].
        column_name)), pard.column_value = trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].
        pa_req_dep[dep_cnt].column_value)), pard.updt_cnt = init_updt_cnt,
      pard.updt_dt_tm = cnvtdatetime(curdate,curtime3), pard.updt_id = reqinfo->updt_id, pard
      .updt_task = reqinfo->updt_task,
      pard.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = insert_error
     SET reply->status_data.subeventstatus[1].operationname = "INSERT_ERROR"
     GO TO exit_script
    ENDIF
   ELSE
    SET failed = pass_info_error
    SET reply->status_data.subeventstatus[1].operationname = "PASS_INFO_ERROR"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_pa_req_ind(dummy)
   IF (trim(dm_prg_arch_req->pa_req[ent_cnt].pa_req_ind[ind_cnt].index_type) != ""
    AND trim(dm_prg_arch_req->pa_req[ent_cnt].pa_req_ind[ind_cnt].index_value) != "")
    SET ind_cd = 0
    SET table_name = "CODE_VALUE"
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=14260
      AND cv.cdf_meaning=trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].pa_req_ind[ind_cnt].
       index_type))
      AND cv.active_ind=true
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     DETAIL
      ind_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = select_error
     SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     dm_x = seq(pa_req_index_seq,nextval)
     FROM dual
     DETAIL
      new_ind_id = cnvtreal(dm_x)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = gen_nbr_error
     SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR_ERROR"
     GO TO exit_script
    ENDIF
    INSERT  FROM pa_req_index pari
     SET pari.index_id = new_ind_id, pari.request_id = req_id, pari.index_type_cd = ind_cd,
      pari.index_value = trim(cnvtupper(dm_prg_arch_req->pa_req[ent_cnt].pa_req_ind[ind_cnt].
        index_value)), pari.updt_cnt = init_updt_cnt, pari.updt_dt_tm = cnvtdatetime(curdate,curtime3
       ),
      pari.updt_id = reqinfo->updt_id, pari.updt_task = reqinfo->updt_task, pari.updt_applctx =
      reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = insert_error
     SET reply->status_data.subeventstatus[1].operationname = "INSERT_ERROR"
     GO TO exit_script
    ENDIF
   ELSE
    SET failed = pass_info_error
    SET reply->status_data.subeventstatus[1].operationname = "PASS_INFO_ERROR"
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  SET reply->status_data.subeventstatus[1].operationname = "CCL_ERROR"
  SET reply->ccl_error_msg = emsg
 ENDIF
 IF (failed != false)
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
END GO
