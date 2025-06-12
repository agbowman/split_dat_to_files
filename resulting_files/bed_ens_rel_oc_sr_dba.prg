CREATE PROGRAM bed_ens_rel_oc_sr:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_dta
 RECORD temp_dta(
   1 dta_list[*]
     2 task_assay_cd = f8
     2 result_type_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET first_only_ind = 0
 SET ok_to_inactivate_ind = 0
 SET dta_count = 0
 SET dta_tot_count = 0
 SET order_activity_type_cd = 0.0
 SET active_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the ACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SET inactive_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
   AND cv.active_ind=1
  DETAIL
   inactive_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the INACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SET micro_cd = 0.0
 SET bb_cd = 0.0
 SET ap_cd = 0.0
 SET hla_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=106
   AND cv.cdf_meaning IN ("BB", "MICROBIOLOGY", "AP", "HLA")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "BB":
     bb_cd = cv.code_value
    OF "MICROBIOLOGY":
     micro_cd = cv.code_value
    OF "AP":
     ap_cd = cv.code_value
    OF "HLA":
     hla_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET rel_cnt = size(request->rel_list,5)
 FOR (x = 1 TO rel_cnt)
   IF ((request->rel_list[x].action_flag=1))
    UPDATE  FROM orc_resource_list orl
     SET orl.sequence = request->rel_list[x].sequence, orl.primary_ind = request->rel_list[x].default,
      orl.active_status_cd = active_code_value,
      orl.active_status_prsnl_id = reqinfo->updt_id, orl.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), orl.active_ind = 1,
      orl.updt_dt_tm = cnvtdatetime(curdate,curtime3), orl.updt_id = reqinfo->updt_id, orl.updt_task
       = reqinfo->updt_task,
      orl.updt_cnt = (orl.updt_cnt+ 1), orl.updt_applctx = reqinfo->updt_applctx
     WHERE (orl.catalog_cd=request->rel_list[x].oc_code_value)
      AND (orl.service_resource_cd=request->rel_list[x].sr_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM orc_resource_list orl
      SET orl.catalog_cd = request->rel_list[x].oc_code_value, orl.service_resource_cd = request->
       rel_list[x].sr_code_value, orl.sequence = request->rel_list[x].sequence,
       orl.primary_ind = request->rel_list[x].default, orl.script_name = " ", orl.active_status_cd =
       active_code_value,
       orl.active_status_prsnl_id = reqinfo->updt_id, orl.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), orl.active_ind = 1,
       orl.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), orl.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100"), orl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       orl.updt_id = reqinfo->updt_id, orl.updt_task = reqinfo->updt_task, orl.updt_cnt = 0,
       orl.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",cnvtstring(request->rel_list[x].oc_code_value),
       " into orc_resource_list table.")
      GO TO exit_script
     ENDIF
    ENDIF
    UPDATE  FROM order_catalog orc
     SET orc.resource_route_lvl = 1, orc.updt_dt_tm = cnvtdatetime(curdate,curtime3), orc.updt_id =
      reqinfo->updt_id,
      orc.updt_task = reqinfo->updt_task, orc.updt_cnt = (orc.updt_cnt+ 1), orc.updt_applctx =
      reqinfo->updt_applctx
     WHERE (orc.catalog_cd=request->rel_list[x].oc_code_value)
     WITH nocounter
    ;end update
    SET order_activity_type_cd = 0.0
    SELECT INTO "NL:"
     FROM order_catalog oc,
      profile_task_r ptr,
      discrete_task_assay dta
     PLAN (oc
      WHERE oc.active_ind=1
       AND (oc.catalog_cd=request->rel_list[x].oc_code_value))
      JOIN (ptr
      WHERE (ptr.catalog_cd=request->rel_list[x].oc_code_value)
       AND ptr.active_ind=1)
      JOIN (dta
      WHERE dta.active_ind=1
       AND dta.task_assay_cd=ptr.task_assay_cd)
     HEAD REPORT
      stat = alterlist(temp_dta->dta_list,50), dta_count = 0, dta_tot_count = 0,
      order_activity_type_cd = oc.activity_type_cd
     DETAIL
      dta_count = (dta_count+ 1), dta_tot_count = (dta_tot_count+ 1)
      IF (dta_count > 50)
       stat = alterlist(temp_dta->dta_list,(dta_tot_count+ 50)), dta_count = 1
      ENDIF
      temp_dta->dta_list[dta_tot_count].task_assay_cd = ptr.task_assay_cd, temp_dta->dta_list[
      dta_tot_count].result_type_cd = dta.default_result_type_cd
     FOOT REPORT
      stat = alterlist(temp_dta->dta_list,dta_tot_count)
     WITH nocounter
    ;end select
    FOR (i = 1 TO dta_tot_count)
      SET need_to_activate_ind = 0
      SET need_to_upd_result = 0
      IF (order_activity_type_cd IN (micro_cd, bb_cd, ap_cd, hla_cd))
       SELECT INTO "NL:"
        FROM assay_processing_r apr
        WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
         AND (apr.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
        DETAIL
         IF (apr.active_ind=0)
          need_to_activate_ind = 1
         ENDIF
         IF ((apr.default_result_type_cd != temp_dta->dta_list[i].result_type_cd))
          need_to_upd_result = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual > 0)
        IF (((need_to_activate_ind=1) OR (need_to_upd_result=1)) )
         UPDATE  FROM assay_processing_r apr
          SET apr.default_result_type_cd = temp_dta->dta_list[i].result_type_cd, apr.active_ind = 1,
           apr.active_status_cd = active_code_value,
           apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id = reqinfo->updt_id, apr
           .updt_task = reqinfo->updt_task,
           apr.updt_applctx = reqinfo->updt_applctx
          WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
           AND (apr.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to activate and update service resource ",cnvtstring(request
            ->rel_list[x].sr_code_value)," assay ",cnvtstring(temp_dta->dta_list[i].task_assay_cd),
           " on the assay_processing_r table.")
          GO TO exit_script
         ENDIF
        ENDIF
       ELSE
        INSERT  FROM assay_processing_r apr
         SET apr.service_resource_cd = request->rel_list[x].sr_code_value, apr.default_result_type_cd
           = temp_dta->dta_list[i].result_type_cd, apr.dnld_assay_alias = null,
          apr.downld_ind = 0, apr.active_ind = 1, apr.task_assay_cd = temp_dta->dta_list[i].
          task_assay_cd,
          apr.display_sequence = 0, apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id =
          reqinfo->updt_id,
          apr.updt_task = reqinfo->updt_task, apr.updt_cnt = 1, apr.updt_applctx = reqinfo->
          updt_applctx,
          apr.active_status_cd = active_code_value, apr.active_status_prsnl_id = reqinfo->updt_id,
          apr.active_status_dt_tm = cnvtdatetime(curdate,curtime)
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_msg = concat("Unable to insert service resource ",cnvtstring(request->rel_list[x].
           sr_code_value)," assay ",cnvtstring(temp_dta->dta_list[i].task_assay_cd),
          " on the assay_processing_r table.")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      SET need_to_activate_ind = 0
      SELECT INTO "NL:"
       FROM assay_resource_translation art
       WHERE (art.service_resource_cd=request->rel_list[x].sr_code_value)
        AND (art.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
       DETAIL
        IF (art.active_ind=0)
         need_to_activate_ind = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (curqual=0)
       INSERT  FROM assay_resource_translation art
        SET art.service_resource_cd = request->rel_list[x].sr_code_value, art.active_ind = 1, art
         .process_sequence = null,
         art.task_assay_cd = temp_dta->dta_list[i].task_assay_cd, art.updt_dt_tm = cnvtdatetime(
          curdate,curtime3), art.updt_id = reqinfo->updt_id,
         art.updt_task = reqinfo->updt_task, art.updt_cnt = 1, art.updt_applctx = reqinfo->
         updt_applctx,
         art.active_status_cd = active_code_value, art.active_status_prsnl_id = reqinfo->updt_id, art
         .active_status_dt_tm = cnvtdatetime(curdate,curtime)
        WITH nocounter
       ;end insert
      ELSEIF (need_to_activate_ind=1)
       UPDATE  FROM assay_resource_translation art
        SET art.active_ind = 1, art.active_status_cd = active_code_value, art.active_status_prsnl_id
          = reqinfo->updt_id,
         art.active_status_dt_tm = cnvtdatetime(curdate,curtime), art.updt_dt_tm = cnvtdatetime(
          curdate,curtime3), art.updt_id = reqinfo->updt_id,
         art.updt_task = reqinfo->updt_task, art.updt_cnt = (art.updt_cnt+ 1), art.updt_applctx =
         reqinfo->updt_applctx
        WHERE (art.service_resource_cd=request->rel_list[x].sr_code_value)
         AND (art.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
        WITH nocounter
       ;end update
      ENDIF
    ENDFOR
   ELSEIF ((request->rel_list[x].action_flag=2))
    UPDATE  FROM orc_resource_list orl
     SET orl.catalog_cd = request->rel_list[x].oc_code_value, orl.service_resource_cd = request->
      rel_list[x].sr_code_value, orl.sequence = request->rel_list[x].sequence,
      orl.primary_ind = request->rel_list[x].default, orl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      orl.updt_id = reqinfo->updt_id,
      orl.updt_task = reqinfo->updt_task, orl.updt_cnt = (orl.updt_cnt+ 1), orl.updt_applctx =
      reqinfo->updt_applctx
     WHERE (orl.catalog_cd=request->rel_list[x].oc_code_value)
      AND (orl.service_resource_cd=request->rel_list[x].sr_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update ",cnvtstring(request->rel_list[x].oc_code_value),
      " on the orc_resource_list table.")
     GO TO exit_script
    ENDIF
    SET order_activity_type_cd = 0.0
    SELECT INTO "NL:"
     FROM order_catalog oc,
      profile_task_r ptr,
      discrete_task_assay dta
     PLAN (oc
      WHERE oc.active_ind=1
       AND (oc.catalog_cd=request->rel_list[x].oc_code_value))
      JOIN (ptr
      WHERE (ptr.catalog_cd=request->rel_list[x].oc_code_value)
       AND ptr.active_ind=1)
      JOIN (dta
      WHERE dta.active_ind=1
       AND dta.task_assay_cd=ptr.task_assay_cd)
     HEAD REPORT
      stat = alterlist(temp_dta->dta_list,50), dta_count = 0, dta_tot_count = 0,
      order_activity_type_cd = oc.activity_type_cd
     DETAIL
      dta_count = (dta_count+ 1), dta_tot_count = (dta_tot_count+ 1)
      IF (dta_count > 50)
       stat = alterlist(temp_dta->dta_list,(dta_tot_count+ 50)), dta_count = 1
      ENDIF
      temp_dta->dta_list[dta_tot_count].task_assay_cd = ptr.task_assay_cd, temp_dta->dta_list[
      dta_tot_count].result_type_cd = dta.default_result_type_cd
     FOOT REPORT
      stat = alterlist(temp_dta->dta_list,dta_tot_count)
     WITH nocounter
    ;end select
    FOR (i = 1 TO dta_tot_count)
      SET need_to_activate_ind = 0
      SET need_to_upd_result = 0
      IF (order_activity_type_cd IN (micro_cd, bb_cd, ap_cd, hla_cd))
       SELECT INTO "NL:"
        FROM assay_processing_r apr
        WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
         AND (apr.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
        DETAIL
         IF (apr.active_ind=0)
          need_to_activate_ind = 1
         ENDIF
         IF ((apr.default_result_type_cd != temp_dta->dta_list[i].result_type_cd))
          need_to_upd_result = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual > 0)
        IF (((need_to_activate_ind=1) OR (need_to_upd_result=1)) )
         UPDATE  FROM assay_processing_r apr
          SET apr.default_result_type_cd = temp_dta->dta_list[i].result_type_cd, apr.active_ind = 1,
           apr.active_status_cd = active_code_value,
           apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id = reqinfo->updt_id, apr
           .updt_task = reqinfo->updt_task,
           apr.updt_applctx = reqinfo->updt_applctx
          WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
           AND (apr.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to activate and update service resource ",cnvtstring(request
            ->rel_list[x].sr_code_value)," assay ",cnvtstring(temp_dta->dta_list[i].task_assay_cd),
           " on the assay_processing_r table.")
          GO TO exit_script
         ENDIF
        ENDIF
       ELSE
        INSERT  FROM assay_processing_r apr
         SET apr.service_resource_cd = request->rel_list[x].sr_code_value, apr.default_result_type_cd
           = temp_dta->dta_list[i].result_type_cd, apr.dnld_assay_alias = null,
          apr.downld_ind = 0, apr.active_ind = 1, apr.task_assay_cd = temp_dta->dta_list[i].
          task_assay_cd,
          apr.display_sequence = 0, apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id =
          reqinfo->updt_id,
          apr.updt_task = reqinfo->updt_task, apr.updt_cnt = 1, apr.updt_applctx = reqinfo->
          updt_applctx,
          apr.active_status_cd = active_code_value, apr.active_status_prsnl_id = reqinfo->updt_id,
          apr.active_status_dt_tm = cnvtdatetime(curdate,curtime)
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_msg = concat("Unable to insert service resource ",cnvtstring(request->rel_list[x].
           sr_code_value)," assay ",cnvtstring(temp_dta->dta_list[i].task_assay_cd),
          " on the assay_processing_r table.")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      SET need_to_activate_ind = 0
      SELECT INTO "NL:"
       FROM assay_resource_translation art
       WHERE (art.service_resource_cd=request->rel_list[x].sr_code_value)
        AND (art.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
       DETAIL
        IF (art.active_ind=0)
         need_to_activate_ind = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (curqual=0)
       INSERT  FROM assay_resource_translation art
        SET art.service_resource_cd = request->rel_list[x].sr_code_value, art.active_ind = 1, art
         .process_sequence = null,
         art.task_assay_cd = temp_dta->dta_list[i].task_assay_cd, art.updt_dt_tm = cnvtdatetime(
          curdate,curtime3), art.updt_id = reqinfo->updt_id,
         art.updt_task = reqinfo->updt_task, art.updt_cnt = 1, art.updt_applctx = reqinfo->
         updt_applctx,
         art.active_status_cd = active_code_value, art.active_status_prsnl_id = reqinfo->updt_id, art
         .active_status_dt_tm = cnvtdatetime(curdate,curtime)
        WITH nocounter
       ;end insert
      ELSEIF (need_to_activate_ind=1)
       UPDATE  FROM assay_resource_translation art
        SET art.active_ind = 1, art.active_status_cd = active_code_value, art.active_status_prsnl_id
          = reqinfo->updt_id,
         art.active_status_dt_tm = cnvtdatetime(curdate,curtime), art.updt_dt_tm = cnvtdatetime(
          curdate,curtime3), art.updt_id = reqinfo->updt_id,
         art.updt_task = reqinfo->updt_task, art.updt_cnt = (art.updt_cnt+ 1), art.updt_applctx =
         reqinfo->updt_applctx
        WHERE (art.service_resource_cd=request->rel_list[x].sr_code_value)
         AND (art.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
        WITH nocounter
       ;end update
      ENDIF
    ENDFOR
   ELSEIF ((request->rel_list[x].action_flag=3))
    DELETE  FROM orc_resource_list orl
     WHERE (orl.catalog_cd=request->rel_list[x].oc_code_value)
      AND (orl.service_resource_cd=request->rel_list[x].sr_code_value)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete ",cnvtstring(request->rel_list[x].oc_code_value),
      " from the orc_resource_list table.")
     GO TO exit_script
    ENDIF
    SET first_only_ind = 1
    SELECT INTO "NL:"
     FROM order_catalog oc,
      profile_task_r ptr
     PLAN (ptr
      WHERE (ptr.catalog_cd=request->rel_list[x].oc_code_value)
       AND ptr.active_ind=1)
      JOIN (oc
      WHERE oc.active_ind=1
       AND (oc.catalog_cd=request->rel_list[x].oc_code_value))
     HEAD REPORT
      stat = alterlist(temp_dta->dta_list,50), dta_count = 0, dta_tot_count = 0
     DETAIL
      IF (oc.resource_route_lvl > 1)
       first_only_ind = 0
      ELSE
       dta_count = (dta_count+ 1), dta_tot_count = (dta_tot_count+ 1)
       IF (dta_count > 50)
        stat = alterlist(temp_dta->dta_list,(dta_tot_count+ 50)), dta_count = 1
       ENDIF
       temp_dta->dta_list[dta_tot_count].task_assay_cd = ptr.task_assay_cd
      ENDIF
     FOOT REPORT
      stat = alterlist(temp_dta->dta_list,dta_tot_count)
     WITH nocounter
    ;end select
    IF (first_only_ind=1
     AND dta_tot_count > 0)
     FOR (i = 1 TO dta_tot_count)
       SET ok_to_inactivate_ind = 1
       SELECT INTO "NL:"
        FROM profile_task_r ptr,
         order_catalog oc,
         orc_resource_list orl
        PLAN (ptr
         WHERE (ptr.catalog_cd != request->rel_list[x].oc_code_value)
          AND (ptr.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
          AND ptr.active_ind=1)
         JOIN (oc
         WHERE oc.active_ind=1
          AND oc.catalog_cd=ptr.catalog_cd
          AND oc.resource_route_lvl=1)
         JOIN (orl
         WHERE orl.active_ind=1
          AND orl.catalog_cd=ptr.catalog_cd
          AND (orl.service_resource_cd=request->rel_list[x].sr_code_value))
        DETAIL
         ok_to_inactivate_ind = 0
        WITH nocounter
       ;end select
       IF (ok_to_inactivate_ind=1)
        SELECT INTO "NL:"
         FROM profile_task_r ptr,
          order_catalog oc,
          assay_resource_list arl
         PLAN (ptr
          WHERE (ptr.catalog_cd != request->rel_list[x].oc_code_value)
           AND (ptr.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
           AND ptr.active_ind=1)
          JOIN (oc
          WHERE oc.active_ind=1
           AND oc.catalog_cd=ptr.catalog_cd
           AND oc.resource_route_lvl > 1)
          JOIN (arl
          WHERE arl.active_ind=1
           AND arl.task_assay_cd=ptr.task_assay_cd
           AND (arl.service_resource_cd=request->rel_list[x].sr_code_value))
         DETAIL
          ok_to_inactivate_ind = 0
         WITH nocounter
        ;end select
       ENDIF
       IF (ok_to_inactivate_ind=1)
        UPDATE  FROM assay_processing_r apr
         SET apr.active_ind = 0, apr.active_status_cd = inactive_code_value, apr
          .active_status_prsnl_id = reqinfo->updt_id,
          apr.active_status_dt_tm = cnvtdatetime(curdate,curtime)
         WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
          AND apr.active_ind=1
          AND (apr.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
         WITH nocounter
        ;end update
        UPDATE  FROM assay_resource_translation art
         SET art.active_ind = 0, art.active_status_cd = inactive_code_value, art
          .active_status_prsnl_id = reqinfo->updt_id,
          art.active_status_dt_tm = cnvtdatetime(curdate,curtime)
         WHERE (art.service_resource_cd=request->rel_list[x].sr_code_value)
          AND art.active_ind=1
          AND (art.task_assay_cd=temp_dta->dta_list[i].task_assay_cd)
         WITH nocounter
        ;end update
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_OC_SR","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
