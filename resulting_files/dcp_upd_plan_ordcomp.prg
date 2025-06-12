CREATE PROGRAM dcp_upd_plan_ordcomp
 SET modify = predeclare
 RECORD comp(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
   1 updt_cnt = f8
   1 last_action_seq = i4
   1 long_blob_id = f8
   1 dose_info_hist_blob_id = f8
 )
 DECLARE comp_count = i2 WITH constant(value(size(request->complist,5)))
 DECLARE activated_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"ACTIVATED"))
 DECLARE included_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"INCLUDED"))
 DECLARE excluded_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"EXCLUDED"))
 DECLARE skipped_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"SKIPPED"))
 DECLARE i = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE long_blob_id = f8 WITH noconstant(0.0)
 DECLARE dose_info_hist_blob_id = f8 WITH noconstant(0.0)
 DECLARE comp_action_cd = f8 WITH noconstant(0.0)
 DECLARE comp_status_cd = f8 WITH noconstant(0.0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (comp_count <= 0)
  CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP","Nothing to UPDATE - compList is EMPTY")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO comp_count)
   SET comp_action_cd = uar_get_code_by("MEANING",16829,nullterm(cnvtupper(request->complist[i].
      comp_action_mean)))
   IF ((request->complist[i].comp_action_mean="MODIFY"))
    IF ((request->complist[i].activated_ind=1))
     SET comp_status_cd = activated_status_cd
    ELSEIF ((request->complist[i].included_ind=1))
     SET comp_status_cd = included_status_cd
    ELSEIF ((request->complist[i].skipped_ind=1))
     SET comp_status_cd = skipped_status_cd
    ELSE
     SET comp_status_cd = excluded_status_cd
    ENDIF
   ENDIF
   SET comp->updt_cnt = 0
   SET comp->last_action_seq = 0
   SET comp->long_blob_id = 0.0
   SET comp->dose_info_hist_blob_id = 0.0
   SET long_blob_id = 0.0
   SET dose_info_hist_blob_id = 0.0
   SELECT INTO "nl:"
    apc.*
    FROM act_pw_comp apc
    WHERE (apc.act_pw_comp_id=request->complist[i].act_pw_comp_id)
    HEAD REPORT
     comp->parent_entity_id =
     IF ((request->complist[i].parent_entity_id != 0)) request->complist[i].parent_entity_id
     ELSE apc.parent_entity_id
     ENDIF
     , stemp = validate(request->complist[i].parent_entity_name,"")
     IF (stemp IN ("PROPOSAL", "ORDERS"))
      comp->parent_entity_name = trim(stemp)
     ELSE
      comp->parent_entity_name = trim(apc.parent_entity_name)
     ENDIF
     comp->updt_cnt = apc.updt_cnt, comp->last_action_seq = apc.last_action_seq, comp->long_blob_id
      = apc.long_blob_id,
     comp->dose_info_hist_blob_id = apc.dose_info_hist_blob_id
    WITH forupdate(apc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_ORDCOMP","Unable to lock row on ACT_PW_COMP table"
     )
    GO TO exit_script
   ENDIF
   IF ((comp->updt_cnt != request->complist[i].updt_cnt))
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_ORDCOMP",
     "Unable to update - COMPONENT has been changed by a different user")
    GO TO exit_script
   ENDIF
   IF (validate(request->complist[i].inactivate_blob_ind,0)=1
    AND (comp->long_blob_id > 0.0))
    SELECT INTO "nl:"
     lb.*
     FROM long_blob lb
     WHERE (lb.long_blob_id=comp->long_blob_id)
     WITH forupdate(lb), nocounter
    ;end select
    IF (curqual=0)
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_ORDCOMP","Unable to lock row on long_blob table")
     GO TO exit_script
    ENDIF
    UPDATE  FROM long_blob lb
     SET lb.active_ind = 0
     WHERE (lb.long_blob_id=comp->long_blob_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_ORDCOMP","Unable to inactivate row on LONG_BLOB")
     GO TO exit_script
    ENDIF
   ELSE
    IF ((request->complist[i].xml_order_detail_blob != null)
     AND (request->complist[i].remove_blob_ind=0))
     IF ((((comp->long_blob_id=request->complist[i].long_blob_id)) OR ((comp->long_blob_id=0))) )
      SELECT INTO "nl:"
       nextseqnum = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        long_blob_id = nextseqnum
       WITH nocounter
      ;end select
      IF (long_blob_id=0.0)
       CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP",
        "Unable to generate new long_blob_id for component detail string")
       GO TO exit_script
      ENDIF
      INSERT  FROM long_blob lb
       SET lb.long_blob = request->complist[i].xml_order_detail_blob, lb.long_blob_id = long_blob_id,
        lb.parent_entity_id = request->complist[i].act_pw_comp_id,
        lb.parent_entity_name = "ACT_PW_COMP", lb.active_ind = 1, lb.active_status_cd = reqdata->
        active_status_cd,
        lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo
        ->updt_id, lb.updt_applctx = reqinfo->updt_applctx,
        lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->
        updt_id,
        lb.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP","Unable to insert into LONG_BLOB")
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF ((request->complist[i].xml_order_detail != null)
     AND (request->complist[i].remove_blob_ind=0))
     IF ((((comp->long_blob_id=request->complist[i].long_blob_id)) OR ((comp->long_blob_id=0))) )
      SELECT INTO "nl:"
       nextseqnum = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        long_blob_id = nextseqnum
       WITH nocounter
      ;end select
      IF (long_blob_id=0.0)
       CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP",
        "Unable to generate new long_blob_id for component detail string")
       GO TO exit_script
      ENDIF
      INSERT  FROM long_blob lb
       SET lb.long_blob = request->complist[i].xml_order_detail, lb.long_blob_id = long_blob_id, lb
        .parent_entity_id = request->complist[i].act_pw_comp_id,
        lb.parent_entity_name = "ACT_PW_COMP", lb.active_ind = 1, lb.active_status_cd = reqdata->
        active_status_cd,
        lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo
        ->updt_id, lb.updt_applctx = reqinfo->updt_applctx,
        lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->
        updt_id,
        lb.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP","Unable to insert into LONG_BLOB")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((request->complist[i].dose_info_hist_blob_text != null)
    AND (request->complist[i].update_dose_info_blob_ind=1))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      dose_info_hist_blob_id = nextseqnum
     WITH nocounter
    ;end select
    IF (dose_info_hist_blob_id=0.0)
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP",
      "Unable to generate new long_blob_id for component detail string")
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
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP","Unable to insert into LONG_BLOB")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->complist[i].dose_info_hist_blob != null)
    AND (request->complist[i].update_dose_info_blob_ind=1))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      dose_info_hist_blob_id = nextseqnum
     WITH nocounter
    ;end select
    IF (dose_info_hist_blob_id=0.0)
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP",
      "Unable to generate new long_blob_id for component detail string")
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
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP","Unable to insert into LONG_BLOB")
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM act_pw_comp apc
    SET apc.comp_status_cd = comp_status_cd, apc.included_ind =
     IF ((request->complist[i].included_ind=1)) 1
     ELSE 0
     ENDIF
     , apc.included_dt_tm =
     IF ((request->complist[i].included_ind=1)
      AND (request->complist[i].activated_ind=0)) cnvtdatetime(curdate,curtime3)
     ELSE apc.included_dt_tm
     ENDIF
     ,
     apc.activated_ind =
     IF ((request->complist[i].activated_ind=1)) 1
     ELSE 0
     ENDIF
     , apc.activated_dt_tm =
     IF ((request->complist[i].activated_ind=1)) cnvtdatetime(curdate,curtime3)
     ELSE apc.activated_dt_tm
     ENDIF
     , apc.activated_prsnl_id =
     IF ((request->complist[i].activated_ind=1)) reqinfo->updt_id
     ELSE apc.activated_prsnl_id
     ENDIF
     ,
     apc.last_action_seq = (apc.last_action_seq+ 1), apc.order_sentence_id =
     IF ((request->complist[i].order_sentence_id != 0)) request->complist[i].order_sentence_id
     ELSE apc.order_sentence_id
     ENDIF
     , apc.parent_entity_id =
     IF ((request->complist[i].parent_entity_id != 0)) request->complist[i].parent_entity_id
     ELSE apc.parent_entity_id
     ENDIF
     ,
     apc.parent_entity_name = trim(comp->parent_entity_name), apc.linked_to_tf_ind = request->
     complist[i].linked_to_tf_ind, apc.duration_qty = request->complist[i].duration_qty,
     apc.duration_unit_cd = request->complist[i].duration_unit_cd, apc.sequence =
     IF ((request->complist[i].sequence > 0)) request->complist[i].sequence
     ELSE apc.sequence
     ENDIF
     , apc.offset_quantity = request->complist[i].offset_quantity,
     apc.offset_unit_cd = request->complist[i].offset_unit_cd, apc.long_blob_id =
     IF (long_blob_id > 0) long_blob_id
     ELSEIF ((request->complist[i].remove_blob_ind=1)) 0
     ELSE apc.long_blob_id
     ENDIF
     , apc.cross_phase_group_ind = request->complist[i].cross_phase_group_ind,
     apc.included_tz =
     IF ((request->complist[i].included_ind=1)
      AND (request->complist[i].activated_ind=0)) request->patient_tz
     ELSE apc.included_tz
     ENDIF
     , apc.activated_tz =
     IF ((request->complist[i].activated_ind=1)) request->patient_tz
     ELSE apc.activated_tz
     ENDIF
     , apc.missing_required_ind = validate(request->complist[i].missing_required_ind,0),
     apc.default_os_ind = validate(request->complist[i].default_os_ind,1), apc.min_tolerance_interval
      = request->complist[i].min_tolerance_interval, apc.min_tolerance_interval_unit_cd = request->
     complist[i].min_tolerance_interval_unit_cd,
     apc.act_pw_comp_group_nbr = request->complist[i].act_pw_comp_group_nbr, apc
     .reject_protocol_review_ind = request->complist[i].reject_protocol_review_ind, apc.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     apc.updt_id = reqinfo->updt_id, apc.updt_task = reqinfo->updt_task, apc.updt_applctx = reqinfo->
     updt_applctx,
     apc.updt_cnt = (apc.updt_cnt+ 1), apc.dose_info_hist_blob_id =
     IF (dose_info_hist_blob_id > 0) dose_info_hist_blob_id
     ELSEIF ((request->complist[i].update_dose_info_blob_ind=1)) 0.0
     ELSE apc.dose_info_hist_blob_id
     ENDIF
     , apc.unlink_start_dt_tm_ind = request->complist[i].unlink_start_dt_tm_ind
    WHERE (apc.act_pw_comp_id=request->complist[i].act_pw_comp_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_ORDCOMP",
     "Failed to update row on ACT_PW_COMP table")
    GO TO exit_script
   ENDIF
   INSERT  FROM pw_comp_action pca
    SET pca.act_pw_comp_id = request->complist[i].act_pw_comp_id, pca.pw_comp_action_seq = (comp->
     last_action_seq+ 1), pca.comp_status_cd = comp_status_cd,
     pca.action_type_cd = comp_action_cd, pca.action_dt_tm = cnvtdatetime(curdate,curtime3), pca
     .action_tz = request->user_tz,
     pca.action_prsnl_id = reqinfo->updt_id, pca.parent_entity_name = trim(comp->parent_entity_name),
     pca.parent_entity_id = comp->parent_entity_id,
     pca.updt_dt_tm = cnvtdatetime(curdate,curtime3), pca.updt_id = reqinfo->updt_id, pca.updt_task
      = reqinfo->updt_task,
     pca.updt_cnt = 0, pca.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_ORDCOMP","Failed to update PW_COMP_ACTION table")
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
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     opname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (targetname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL report_failure("CCL ERROR","F","DCP_UPD_PLAN_ORDCOMP",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "011"
 SET mod_date = "July 20, 2011"
END GO
