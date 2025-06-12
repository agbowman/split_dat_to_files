CREATE PROGRAM dcp_add_plan_ordcomp
 SET modify = predeclare
 DECLARE comp_count = i2 WITH constant(value(size(request->complist,5)))
 DECLARE end_date_string = c20 WITH constant("31-DEC-2100 00:00:00")
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE i = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE comp_action_cd = f8 WITH noconstant(0.0)
 DECLARE long_blob_id = f8 WITH noconstant(0.0), protect
 DECLARE dose_info_hist_blob_id = f8 WITH noconstant(0.0), protect
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (comp_count <= 0)
  CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP","Nothing to INSERT - compList is EMPTY")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO comp_count)
   SET long_blob_id = 0.0
   IF ((request->complist[i].xml_order_detail_blob != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_blob_id = nextseqnum
     WITH nocounter
    ;end select
    IF (long_blob_id=0.0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP",
      "Unable to generate new long_blob_id for component detail string")
     GO TO exit_script
    ENDIF
    INSERT  FROM long_blob lb
     SET lb.long_blob = request->complist[i].xml_order_detail_blob, lb.long_blob_id = long_blob_id,
      lb.parent_entity_id = request->complist[i].act_pw_comp_id,
      lb.parent_entity_name = "ACT_PW_COMP", lb.active_ind = 1, lb.active_status_cd = reqdata->
      active_status_cd,
      lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo->
      updt_id, lb.updt_applctx = reqinfo->updt_applctx,
      lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->updt_id,
      lb.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP","Unable to insert into LONG_BLOB")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->complist[i].xml_order_detail != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_blob_id = nextseqnum
     WITH nocounter
    ;end select
    IF (long_blob_id=0.0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP",
      "Unable to generate new long_blob_id for component detail string")
     GO TO exit_script
    ENDIF
    INSERT  FROM long_blob lb
     SET lb.long_blob = request->complist[i].xml_order_detail, lb.long_blob_id = long_blob_id, lb
      .parent_entity_id = request->complist[i].act_pw_comp_id,
      lb.parent_entity_name = "ACT_PW_COMP", lb.active_ind = 1, lb.active_status_cd = reqdata->
      active_status_cd,
      lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo->
      updt_id, lb.updt_applctx = reqinfo->updt_applctx,
      lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->updt_id,
      lb.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP","Unable to insert into LONG_BLOB")
     GO TO exit_script
    ENDIF
   ENDIF
   SET dose_info_hist_blob_id = 0.0
   IF ((request->complist[i].dose_info_hist_blob_text != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      dose_info_hist_blob_id = nextseqnum
     WITH nocounter
    ;end select
    IF (dose_info_hist_blob_id=0.0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP",
      "Unable to generate new dose_info_hist_blob_id for component detail string")
     GO TO exit_script
    ENDIF
    INSERT  FROM long_blob lb
     SET lb.long_blob = request->complist[i].dose_info_hist_blob_text, lb.long_blob_id =
      dose_info_hist_blob_id, lb.parent_entity_id = request->complist[i].act_pw_comp_id,
      lb.parent_entity_name = "ACT_PW_COMP", lb.active_ind = 1, lb.active_status_cd = reqdata->
      active_status_cd,
      lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo->
      updt_id, lb.updt_applctx = reqinfo->updt_applctx,
      lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->updt_id,
      lb.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP","Unable to insert into LONG_BLOB")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->complist[i].dose_info_hist_blob != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      dose_info_hist_blob_id = nextseqnum
     WITH nocounter
    ;end select
    IF (dose_info_hist_blob_id=0.0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP",
      "Unable to generate new dose_info_hist_blob_id for component detail string")
     GO TO exit_script
    ENDIF
    INSERT  FROM long_blob lb
     SET lb.long_blob = request->complist[i].dose_info_hist_blob, lb.long_blob_id =
      dose_info_hist_blob_id, lb.parent_entity_id = request->complist[i].act_pw_comp_id,
      lb.parent_entity_name = "ACT_PW_COMP", lb.active_ind = 1, lb.active_status_cd = reqdata->
      active_status_cd,
      lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo->
      updt_id, lb.updt_applctx = reqinfo->updt_applctx,
      lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->updt_id,
      lb.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP","Unable to insert into LONG_BLOB")
     GO TO exit_script
    ENDIF
   ENDIF
   SET comp_action_cd = uar_get_code_by("MEANING",16829,nullterm(cnvtupper(request->complist[i].
      comp_action_mean)))
   INSERT  FROM act_pw_comp apc
    SET apc.act_pw_comp_id = request->complist[i].act_pw_comp_id, apc.pathway_id = request->complist[
     i].pathway_id, apc.pathway_comp_id = request->complist[i].pathway_comp_id,
     apc.comp_type_cd = request->complist[i].comp_type_cd, apc.comp_status_cd = request->complist[i].
     comp_status_cd, apc.parent_entity_id = request->complist[i].parent_entity_id,
     apc.parent_entity_name = request->complist[i].parent_entity_name, apc.dcp_clin_cat_cd = request
     ->complist[i].dcp_clin_cat_cd, apc.dcp_clin_sub_cat_cd = request->complist[i].
     dcp_clin_sub_cat_cd,
     apc.sequence = request->complist[i].sequence, apc.encntr_id = request->complist[i].encntr_id,
     apc.person_id = request->complist[i].person_id,
     apc.required_ind = request->complist[i].required_ind, apc.included_ind = request->complist[i].
     included_ind, apc.included_dt_tm = cnvtdatetime(request->complist[i].included_dt_tm),
     apc.activated_ind = request->complist[i].activated_ind, apc.activated_dt_tm = cnvtdatetime(
      request->complist[i].activated_dt_tm), apc.activated_prsnl_id = request->complist[i].
     activated_id,
     apc.created_dt_tm = cnvtdatetime(curdate,curtime3), apc.linked_to_tf_ind = request->complist[i].
     linked_to_tf_ind, apc.persistent_ind = 0,
     apc.active_ind = request->complist[i].active_ind, apc.last_action_seq = 1, apc.order_sentence_id
      = request->complist[i].order_sentence_id,
     apc.ref_prnt_ent_name = request->complist[i].ref_prnt_ent_name, apc.ref_prnt_ent_id = request->
     complist[i].ref_prnt_ent_id, apc.duration_qty = request->complist[i].duration_qty,
     apc.duration_unit_cd = request->complist[i].duration_unit_cd, apc.comp_label = request->
     complist[i].comp_label, apc.offset_quantity = request->complist[i].offset_quantity,
     apc.offset_unit_cd = request->complist[i].offset_unit_cd, apc.long_blob_id = long_blob_id, apc
     .cross_phase_group_nbr = request->complist[i].cross_phase_group_nbr,
     apc.cross_phase_group_ind = request->complist[i].cross_phase_group_ind, apc.chemo_ind = request
     ->complist[i].chemo_ind, apc.chemo_related_ind = request->complist[i].chemo_related_ind,
     apc.missing_required_ind = validate(request->complist[i].missing_required_ind,0), apc
     .default_os_ind = validate(request->complist[i].default_os_ind,1), apc.included_tz =
     IF ((request->complist[i].included_dt_tm != null)) request->patient_tz
     ENDIF
     ,
     apc.activated_tz =
     IF ((request->complist[i].activated_dt_tm != null)) request->patient_tz
     ENDIF
     , apc.created_tz = request->patient_tz, apc.min_tolerance_interval = request->complist[i].
     min_tolerance_interval,
     apc.min_tolerance_interval_unit_cd = request->complist[i].min_tolerance_interval_unit_cd, apc
     .act_pw_comp_group_nbr = request->complist[i].act_pw_comp_group_nbr, apc
     .reject_protocol_review_ind = request->complist[i].reject_protocol_review_ind,
     apc.display_format_xml =
     IF (trim(request->complist[i].display_format_xml) > " ") trim(request->complist[i].
       display_format_xml)
     ELSE "<xml />"
     ENDIF
     , apc.unlink_start_dt_tm_ind = request->complist[i].unlink_start_dt_tm_ind, apc
     .lock_target_dose_flag = request->complist[i].lock_target_dose_flag,
     apc.updt_dt_tm = cnvtdatetime(curdate,curtime3), apc.updt_id = reqinfo->updt_id, apc.updt_task
      = reqinfo->updt_task,
     apc.updt_cnt = 0, apc.updt_applctx = reqinfo->updt_applctx, apc.dose_info_hist_blob_id =
     dose_info_hist_blob_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP",
     "Failed to insert a new row into ACT_PW_COMP table")
    GO TO exit_script
   ENDIF
   INSERT  FROM pw_comp_action pca
    SET pca.act_pw_comp_id = request->complist[i].act_pw_comp_id, pca.pw_comp_action_seq = 1, pca
     .comp_status_cd = request->complist[i].comp_status_cd,
     pca.action_type_cd = comp_action_cd, pca.action_dt_tm = cnvtdatetime(curdate,curtime3), pca
     .action_tz = request->user_tz,
     pca.action_prsnl_id = reqinfo->updt_id, pca.parent_entity_id = request->complist[i].
     parent_entity_id, pca.parent_entity_name = request->complist[i].parent_entity_name,
     pca.updt_dt_tm = cnvtdatetime(curdate,curtime3), pca.updt_id = reqinfo->updt_id, pca.updt_task
      = reqinfo->updt_task,
     pca.updt_cnt = 0, pca.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_ORDCOMP",
     "Failed to insert a new row into PW_COMP_ACTION table")
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = trim(opname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL report_failure("CCL ERROR","F","DCP_ADD_PLAN_ORDCOMP",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "015"
 SET mod_date = "October 24, 2012"
END GO
