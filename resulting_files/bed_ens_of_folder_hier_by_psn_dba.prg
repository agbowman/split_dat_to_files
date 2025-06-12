CREATE PROGRAM bed_ens_of_folder_hier_by_psn:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pcnt = size(request->plist,5)
 IF ((request->component_flag=1))
  FOR (p = 1 TO pcnt)
    SET detail_prefs_id = 0.0
    SELECT INTO "NL:"
     FROM detail_prefs dp
     WHERE (dp.application_number=request->application_number)
      AND (dp.position_cd=request->plist[p].position_code_value)
      AND dp.prsnl_id=0.0
      AND dp.person_id=0.0
      AND dp.view_name="EASYSCRIPT"
      AND dp.view_seq=0
      AND dp.comp_name="EASYSCRIPT"
      AND dp.comp_seq=0
      AND dp.active_ind=1
     DETAIL
      detail_prefs_id = dp.detail_prefs_id
     WITH nocounter
    ;end select
    IF (detail_prefs_id=0.0)
     SELECT INTO "nl:"
      z = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       detail_prefs_id = cnvtreal(z)
      WITH format, nocounter
     ;end select
     INSERT  FROM detail_prefs dp
      SET dp.detail_prefs_id = detail_prefs_id, dp.application_number = request->application_number,
       dp.position_cd = request->plist[p].position_code_value,
       dp.prsnl_id = 0.0, dp.person_id = 0.0, dp.view_name = "EASYSCRIPT",
       dp.view_seq = 0, dp.comp_name = "EASYSCRIPT", dp.comp_seq = 0,
       dp.active_ind = 1, dp.updt_cnt = 0, dp.updt_id = reqinfo->updt_id,
       dp.updt_dt_tm = cnvtdatetime(curdate,curtime), dp.updt_task = reqinfo->updt_task, dp
       .updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "DETAIL_PREFS",
       nvp.parent_entity_id = detail_prefs_id,
       nvp.pvc_name = "ES_TAB_COUNT_3", nvp.pvc_value = "0", nvp.active_ind = 1,
       nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
        = " ",
       nvp.merge_id = 0.0, nvp.sequence = 0
      WITH nocounter
     ;end insert
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "DETAIL_PREFS",
       nvp.parent_entity_id = detail_prefs_id,
       nvp.pvc_name = "ES_TAB_COUNT", nvp.pvc_value = "3", nvp.active_ind = 1,
       nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
        = " ",
       nvp.merge_id = 0.0, nvp.sequence = 0
      WITH nocounter
     ;end insert
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "DETAIL_PREFS",
       nvp.parent_entity_id = detail_prefs_id,
       nvp.pvc_name = "ES_TAB_NAME_3", nvp.pvc_value = "Order Catalog", nvp.active_ind = 1,
       nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
        = " ",
       nvp.merge_id = 0.0, nvp.sequence = 0
      WITH nocounter
     ;end insert
    ELSE
     DELETE  FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=detail_prefs_id
       AND nvp.pvc_name="ES_TAB_ID_3_*"
      WITH nocounter
     ;end delete
     SET es_tab_count_3_exists = 0
     SET es_tab_count_exists = 0
     SET es_tab_name_3_exists = 0
     SELECT INTO "NL:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.parent_entity_id=detail_prefs_id
       AND nvp.pvc_name IN ("ES_TAB_COUNT_3", "ES_TAB_COUNT", "ES_TAB_NAME_3")
      DETAIL
       IF (nvp.pvc_name="ES_TAB_COUNT_3")
        es_tab_count_3_exists = 1
       ELSEIF (nvp.pvc_name="ES_TAB_COUNT")
        es_tab_count_exists = 1
       ELSEIF (nvp.pvc_name="ES_TAB_NAME_3")
        es_tab_name_3_exists = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (es_tab_count_3_exists=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
        "DETAIL_PREFS", nvp.parent_entity_id = detail_prefs_id,
        nvp.pvc_name = "ES_TAB_COUNT_3", nvp.pvc_value = "0", nvp.active_ind = 1,
        nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
         = " ",
        nvp.merge_id = 0.0, nvp.sequence = 0
       WITH nocounter
      ;end insert
     ENDIF
     IF (es_tab_count_exists=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
        "DETAIL_PREFS", nvp.parent_entity_id = detail_prefs_id,
        nvp.pvc_name = "ES_TAB_COUNT", nvp.pvc_value = "3", nvp.active_ind = 1,
        nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
         = " ",
        nvp.merge_id = 0.0, nvp.sequence = 0
       WITH nocounter
      ;end insert
     ENDIF
     IF (es_tab_name_3_exists=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
        "DETAIL_PREFS", nvp.parent_entity_id = detail_prefs_id,
        nvp.pvc_name = "ES_TAB_NAME_3", nvp.pvc_value = "Order Catalog", nvp.active_ind = 1,
        nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
         = " ",
        nvp.merge_id = 0.0, nvp.sequence = 0
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    SET fcnt = size(request->plist[p].flist,5)
    FOR (f = 1 TO fcnt)
      SET new_name_value_prefs_id = 0.0
      SELECT INTO "nl:"
       z = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        new_name_value_prefs_id = cnvtreal(z)
       WITH format, nocounter
      ;end select
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = new_name_value_prefs_id, nvp.parent_entity_name = "DETAIL_PREFS",
        nvp.parent_entity_id = detail_prefs_id,
        nvp.pvc_name = concat("ES_TAB_ID_3_",cnvtstring(f)), nvp.pvc_value = cnvtstring(request->
         plist[p].flist[f].folder_id), nvp.active_ind = 1,
        nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
         = " ",
        nvp.merge_id = 0.0, nvp.sequence = 0
       WITH nocounter
      ;end insert
    ENDFOR
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = cnvtstring(fcnt)
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.parent_entity_id=detail_prefs_id
      AND nvp.pvc_name="ES_TAB_COUNT_3"
     WITH nocounter
    ;end update
  ENDFOR
 ELSEIF ((request->component_flag=2))
  FOR (p = 1 TO pcnt)
    SET save_home_id = fillstring(256," ")
    SET save_root_id = fillstring(256," ")
    IF ((request->plist[p].flist[1].folder_id != 0))
     SET save_home_id = cnvtstring(request->plist[p].flist[1].folder_id)
    ENDIF
    IF ((request->plist[p].flist[2].folder_id != 0))
     SET save_root_id = cnvtstring(request->plist[p].flist[2].folder_id)
    ENDIF
    SET app_prefs_id = 0.0
    SELECT INTO "NL:"
     FROM app_prefs ap
     WHERE (ap.application_number=request->application_number)
      AND (ap.position_cd=request->plist[p].position_code_value)
      AND ap.prsnl_id=0.0
      AND ap.active_ind=1
     DETAIL
      app_prefs_id = ap.app_prefs_id
     WITH nocounter
    ;end select
    IF (app_prefs_id=0.0)
     SELECT INTO "nl:"
      z = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       app_prefs_id = cnvtreal(z)
      WITH format, nocounter
     ;end select
     INSERT  FROM app_prefs ap
      SET ap.app_prefs_id = app_prefs_id, ap.application_number = request->application_number, ap
       .position_cd = request->plist[p].position_code_value,
       ap.prsnl_id = 0.0, ap.active_ind = 1, ap.updt_cnt = 0,
       ap.updt_id = reqinfo->updt_id, ap.updt_dt_tm = cnvtdatetime(curdate,curtime), ap.updt_task =
       reqinfo->updt_task,
       ap.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    SET exists_ind = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND nvp.parent_entity_id=app_prefs_id
      AND nvp.pvc_name="INPT_CATALOG_BROWSER_HOME"
     DETAIL
      exists_ind = 1
     WITH nocounter
    ;end select
    IF (exists_ind=1)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = save_home_id, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
       updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="APP_PREFS"
       AND nvp.parent_entity_id=app_prefs_id
       AND nvp.pvc_name="INPT_CATALOG_BROWSER_HOME"
      WITH nocounter
     ;end update
    ELSE
     SET new_name_value_prefs_id = 0.0
     SELECT INTO "nl:"
      z = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       new_name_value_prefs_id = cnvtreal(z)
      WITH format, nocounter
     ;end select
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = new_name_value_prefs_id, nvp.parent_entity_name = "APP_PREFS",
       nvp.parent_entity_id = app_prefs_id,
       nvp.pvc_name = "INPT_CATALOG_BROWSER_HOME", nvp.pvc_value = save_home_id, nvp.active_ind = 1,
       nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
        = " ",
       nvp.merge_id = 0.0, nvp.sequence = 0
      WITH nocounter
     ;end insert
    ENDIF
    SET exists_ind = 0
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND nvp.parent_entity_id=app_prefs_id
      AND nvp.pvc_name="INPT_CATALOG_BROWSER_ROOT"
     DETAIL
      exists_ind = 1
     WITH nocounter
    ;end select
    IF (exists_ind=1)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = save_root_id, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = reqinfo->
       updt_id,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
       .updt_applctx = reqinfo->updt_applctx
      WHERE nvp.parent_entity_name="APP_PREFS"
       AND nvp.parent_entity_id=app_prefs_id
       AND nvp.pvc_name="INPT_CATALOG_BROWSER_ROOT"
      WITH nocounter
     ;end update
    ELSE
     SET new_name_value_prefs_id = 0.0
     SELECT INTO "nl:"
      z = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       new_name_value_prefs_id = cnvtreal(z)
      WITH format, nocounter
     ;end select
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = new_name_value_prefs_id, nvp.parent_entity_name = "APP_PREFS",
       nvp.parent_entity_id = app_prefs_id,
       nvp.pvc_name = "INPT_CATALOG_BROWSER_ROOT", nvp.pvc_value = save_root_id, nvp.active_ind = 1,
       nvp.updt_cnt = 0, nvp.updt_id = reqinfo->updt_id, nvp.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.merge_name
        = " ",
       nvp.merge_id = 0.0, nvp.sequence = 0
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
