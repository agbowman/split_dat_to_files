CREATE PROGRAM aps_chg_case_report:dba
 RECORD tmp(
   1 task_assay_qual[*]
     2 task_assay_cd = f8
 )
 RECORD reply(
   1 case_updt_cnt = i4
   1 report_qual[*]
     2 report_index = i4
     2 report_id = f8
     2 report_updt_cnt = i4
     2 status_cd = f8
     2 status_disp = c40
     2 skip_ind = i2
     2 updt_id = f8
     2 updt_name_full_formatted = vc
     2 section_qual[*]
       3 section_index = i4
       3 report_detail_id = f8
       3 section_updt_cnt = i4
       3 image_qual[*]
         4 image_index = i4
         4 blob_ref_id = f8
         4 tbnl_long_blob_id = f8
         4 chartable_note_id = f8
         4 chartable_note_updt_cnt = i4
         4 non_chartable_note_id = f8
         4 non_chartable_note_updt_cnt = i4
         4 image_updt_cnt = i4
     2 image_qual[*]
       3 image_index = i4
       3 blob_ref_id = f8
       3 tbnl_long_blob_id = f8
       3 chartable_note_id = f8
       3 chartable_note_updt_cnt = i4
       3 non_chartable_note_id = f8
       3 non_chartable_note_updt_cnt = i4
       3 image_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 entity_qual[*]
     2 folder_id = f8
     2 entity_id = f8
     2 parent_entity_name = c32
     2 entity_type_flag = i2
     2 accession_nbr = c21
   1 status_cd = f8
   1 status_disp = c40
   1 spec_qual[*]
     2 id = f8
     2 order_id = f8
     2 status_cd = f8
 )
#script
 SET reply->status_data.status = "F"
 SET count = 0
 SET cur_updt_cnt = 0
 SET cur_status_cd = 0.0
 SET updt_array[100] = 0
 SET failed = "F"
 SET error_cnt = 0
 SET primary_ind = 0
 SET ap_trans_stat_id = 0.0
 SET images_changed = 0
 SET nsecidx = 0
 DECLARE spec_cnt = i2 WITH protect, noconstant(0)
 DECLARE cancel_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE verified_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE processing_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE no_primary_rpt_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE supdaterptresp = c1 WITH protect, noconstant("F")
 DECLARE pathologist = i2 WITH protect, constant(1)
 DECLARE resident = i2 WITH protect, constant(2)
 IF (cnvtint(size(request->report_qual,5)) > 0)
  SET images_changed = 1
 ENDIF
 IF ((request->status_mean > " "))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=1305
    AND (cv.cdf_meaning=request->status_mean)
   DETAIL
    request->status_cd = cv.code_value, reply->status_cd = cv.code_value, reply->status_disp = cv
    .display
    IF (images_changed=1)
     request->report_qual[1].status_cd = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC"))) OR ((request
 ->resp_case_rpt_flg > 1))) )
  SELECT INTO "nl:"
   pr.primary_ind
   FROM prefix_report_r pr
   WHERE (request->prefix_cd=pr.prefix_id)
    AND (request->catalog_cd=pr.catalog_cd)
   HEAD REPORT
    primary_ind = 0
   DETAIL
    primary_ind = pr.primary_ind
   WITH nocounter
  ;end select
  IF (primary_ind=1)
   SELECT INTO "nl:"
    pc.case_id
    FROM pathology_case pc
    WHERE (request->case_id=pc.case_id)
    HEAD REPORT
     cur_updt_cnt = 0
    DETAIL
     cur_updt_cnt = pc.updt_cnt
    WITH forupdate(pc)
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","PATHOLOGY_CASE")
    GO TO exit_script
   ENDIF
   UPDATE  FROM pathology_case pc
    SET pc.main_report_cmplete_dt_tm =
     IF ((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC")))
      cnvtdatetime(request->edit_dt_tm)
     ELSE pc.main_report_cmplete_dt_tm
     ENDIF
     , pc.responsible_pathologist_id =
     IF ((request->path_or_resi_flg=pathologist)) request->responsibility_id
     ELSE pc.responsible_pathologist_id
     ENDIF
     , pc.responsible_resident_id =
     IF ((request->path_or_resi_flg=resident)) request->responsibility_id
     ELSE pc.responsible_resident_id
     ENDIF
     ,
     pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_id = reqinfo->updt_id, pc.updt_task =
     reqinfo->updt_task,
     pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (cur_updt_cnt+ 1)
    WHERE (request->case_id=pc.case_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UDPATE","F","TABLE","PATHOLOGY_CASE")
    GO TO exit_script
   ELSEIF (images_changed=1)
    SET request->case_updt_cnt = (cur_updt_cnt+ 1)
   ENDIF
  ENDIF
 ENDIF
 IF ((request->event_id=0))
  CALL handle_errors("VALIDATION","F","REQUEST","EVENT_ID IS 0")
  GO TO exit_script
 ENDIF
 IF ((request->status_prsnl_id=0))
  CALL handle_errors("VALIDATION","F","REQUEST","STATUS_PRSNL_ID IS 0")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cr.report_id
  FROM case_report cr
  WHERE (request->report_id=cr.report_id)
  HEAD REPORT
   cur_updt_cnt = 0
  DETAIL
   cur_updt_cnt = cr.updt_cnt, cur_status_cd = cr.status_cd
  WITH forupdate(cr)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","CASE_REPORT")
  GO TO exit_script
 ENDIF
 UPDATE  FROM case_report cr
  SET cr.event_id = request->event_id, cr.status_prsnl_id =
   IF ((cur_status_cd=request->status_cd)) cr.status_prsnl_id
   ELSE request->status_prsnl_id
   ENDIF
   , cr.status_dt_tm =
   IF ((cur_status_cd=request->status_cd)) cr.status_dt_tm
   ELSE cnvtdatetime(request->edit_dt_tm)
   ENDIF
   ,
   cr.status_cd = request->status_cd, cr.synoptic_stale_dt_tm = null, cr.updt_dt_tm = cnvtdatetime(
    curdate,curtime),
   cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->
   updt_applctx,
   cr.updt_cnt = (cur_updt_cnt+ 1), cr.signing_location_cd =
   IF ((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC"))) request->
    signing_location_cd
   ELSE cr.signing_location_cd
   ENDIF
  WHERE (request->report_id=cr.report_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UDPATE","F","TABLE","CASE_REPORT")
  GO TO exit_script
 ELSEIF (images_changed=1)
  SET request->report_qual[1].updt_cnt = (cur_updt_cnt+ 1)
 ENDIF
 IF ((request->status_mean IN ("CSIGNINPROC", "SIGNINPROC")))
  IF ((request->hold_verify_ind=0))
   SET nactionflag = 1
  ELSE
   SET nactionflag = - (1)
  ENDIF
  INSERT  FROM ap_ops_exception a
   SET a.parent_id = request->report_id, a.action_flag = nactionflag, a.flex1_id = request->proxy_id,
    a.active_ind = 1, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed
    SET aoed.action_flag = nactionflag, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr =
     curtimezoneapp,
     aoed.parent_id = request->report_id, aoed.sequence = 1, aoed.updt_applctx = reqinfo->
     updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(sysdate), aoed.updt_id = reqinfo->updt_id,
     aoed.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((request->status_mean IN ("VERIFIED", "SIGNINPROC")))
  INSERT  FROM ap_ops_exception aoe
   SET aoe.parent_id = request->report_id, aoe.action_flag = 6, aoe.active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed
    SET aoed.action_flag = 6, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = request->report_id, aoed.sequence = 1, aoed.updt_applctx = reqinfo->
     updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((((request->resp_case_rpt_flg=1)) OR ((request->resp_case_rpt_flg=3))) )
  SET supdaterptresp = "T"
 ELSE
  SET supdaterptresp = "F"
 ENDIF
 SELECT INTO "nl:"
  rt.report_id
  FROM report_task rt
  WHERE (request->report_id=rt.report_id)
  HEAD REPORT
   cur_updt_cnt = 0
  DETAIL
   cur_updt_cnt = rt.updt_cnt
  WITH forupdate(rt)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","REPORT_TASK")
  GO TO exit_script
 ENDIF
 UPDATE  FROM report_task rt
  SET rt.editing_prsnl_id = 0, rt.last_edit_dt_tm = cnvtdatetime(request->edit_dt_tm), rt
   .last_task_assay_cd = request->last_task_assay_cd,
   rt.responsible_pathologist_id =
   IF (supdaterptresp="T"
    AND (request->path_or_resi_flg=pathologist)) request->responsibility_id
   ELSE rt.responsible_pathologist_id
   ENDIF
   , rt.responsible_resident_id =
   IF (supdaterptresp="T"
    AND (request->path_or_resi_flg=resident)) request->responsibility_id
   ELSE rt.responsible_resident_id
   ENDIF
   , rt.updt_dt_tm = cnvtdatetime(curdate,curtime),
   rt.updt_id = reqinfo->updt_id, rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->
   updt_applctx,
   rt.updt_cnt = (cur_updt_cnt+ 1)
  WHERE (request->report_id=rt.report_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UDPATE","F","TABLE","REPORT_TASK")
  GO TO exit_script
 ENDIF
 IF ((request->section_cnt > 0))
  SELECT INTO "nl:"
   rdt.task_assay_cd
   FROM report_detail_task rdt,
    (dummyt d  WITH seq = value(request->section_cnt))
   PLAN (d)
    JOIN (rdt
    WHERE (request->section_qual[d.seq].task_assay_cd=rdt.task_assay_cd)
     AND (request->report_id=rdt.report_id))
   HEAD REPORT
    count = 0
   DETAIL
    count += 1, updt_array[count] = rdt.updt_cnt
    IF (images_changed=1)
     FOR (nsecidx = 1 TO cnvtint(size(request->report_qual[1].section_qual,5)))
       IF ((request->report_qual[1].section_qual[nsecidx].task_assay_cd=rdt.task_assay_cd))
        request->report_qual[1].section_qual[nsecidx].updt_cnt = (rdt.updt_cnt+ 1)
       ENDIF
     ENDFOR
    ENDIF
   WITH forupdate(rdt)
  ;end select
  IF (((curqual=0) OR ((count != request->section_cnt))) )
   CALL handle_errors("SELECT","F","TABLE","REPORT_DETAIL_TASK")
   GO TO exit_script
  ENDIF
  UPDATE  FROM report_detail_task rdt,
    (dummyt d  WITH seq = value(request->section_cnt))
   SET rdt.event_id = request->section_qual[d.seq].event_id, rdt.status_cd = request->section_qual[d
    .seq].status_cd, rdt.updt_dt_tm = cnvtdatetime(curdate,curtime),
    rdt.updt_id = reqinfo->updt_id, rdt.updt_task = reqinfo->updt_task, rdt.updt_applctx = reqinfo->
    updt_applctx,
    rdt.updt_cnt = (updt_array[d.seq]+ 1)
   PLAN (d)
    JOIN (rdt
    WHERE (request->section_qual[d.seq].task_assay_cd=rdt.task_assay_cd)
     AND (request->report_id=rdt.report_id))
   WITH nocounter
  ;end update
  IF ((curqual != request->section_cnt))
   CALL handle_errors("UPDATE","F","TABLE","REPORT_DETAIL_TASK")
   GO TO exit_script
  ENDIF
  SET ta_count = 0
  SELECT INTO "nl:"
   apt.task_assay_cd
   FROM ap_prompt_test apt,
    (dummyt d  WITH seq = value(request->section_cnt))
   PLAN (d)
    JOIN (apt
    WHERE (request->case_id=apt.accession_id)
     AND (request->section_qual[d.seq].task_assay_cd=apt.task_assay_cd)
     AND (request->section_qual[d.seq].event_id > 0.0)
     AND 1=apt.active_ind)
   HEAD REPORT
    ta_count = 0
   DETAIL
    ta_count += 1
    IF (mod(ta_count,10)=1)
     stat = alterlist(tmp->task_assay_qual,(ta_count+ 9))
    ENDIF
    tmp->task_assay_qual[ta_count].task_assay_cd = apt.task_assay_cd
   FOOT REPORT
    stat = alterlist(tmp->task_assay_qual,ta_count)
   WITH nocounter
  ;end select
  IF (ta_count > 0)
   SELECT INTO "nl:"
    apt.task_assay_cd
    FROM (dummyt d  WITH seq = value(ta_count)),
     ap_prompt_test apt
    PLAN (d)
     JOIN (apt
     WHERE (apt.accession_id=request->case_id)
      AND (apt.task_assay_cd=tmp->task_assay_qual[d.seq].task_assay_cd)
      AND apt.active_ind=1)
    DETAIL
     tmp->task_assay_qual[d.seq].task_assay_cd = apt.task_assay_cd
    WITH nocounter, forupdate(apt)
   ;end select
   IF (curqual != 0)
    UPDATE  FROM ap_prompt_test apt,
      (dummyt d  WITH seq = value(ta_count))
     SET apt.active_ind = 0, apt.updt_dt_tm = cnvtdatetime(curdate,curtime), apt.updt_id = reqinfo->
      updt_id,
      apt.updt_task = reqinfo->updt_task, apt.updt_applctx = reqinfo->updt_applctx, apt.updt_cnt = (
      apt.updt_cnt+ 1)
     PLAN (d)
      JOIN (apt
      WHERE (request->case_id=apt.accession_id)
       AND (tmp->task_assay_qual[d.seq].task_assay_cd=apt.task_assay_cd)
       AND 1=apt.active_ind)
     WITH nocounter
    ;end update
    IF (curqual != ta_count)
     CALL handle_errors("UPDATE","F","TABLE","AP_PROMPT_TEST")
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((((request->word_cnt > 0)) OR ((request->char_cnt > 0))) )
  SELECT INTO "nl:"
   seq_nbr = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    ap_trans_stat_id = seq_nbr
   WITH format, counter
  ;end select
  IF (curqual=0)
   CALL handle_errors("NEXTVAL","F","SEQ","PATHNET")
   GO TO exit_script
  ENDIF
  INSERT  FROM ap_trans_stat ats
   SET ats.ap_trans_stat_id = ap_trans_stat_id, ats.report_id = request->report_id, ats.case_type_cd
     = request->case_type_cd,
    ats.pathologist_id = request->status_prsnl_id, ats.transcriptionist_id = request->
    transcribed_by_id, ats.transcribed_dt_tm = cnvtdatetime(curdate,curtime),
    ats.nbr_words = request->word_cnt, ats.nbr_characters = request->char_cnt, ats.updt_dt_tm =
    cnvtdatetime(curdate,curtime),
    ats.updt_id = reqinfo->updt_id, ats.updt_task = reqinfo->updt_task, ats.updt_applctx = reqinfo->
    updt_applctx,
    ats.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual != 1)
   CALL handle_errors("INSERT","F","TABLE","AP_TRANS_STAT")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC")))
  IF (primary_ind=0)
   SELECT INTO "nl:"
    pr.primary_ind
    FROM prefix_report_r pr
    WHERE (request->prefix_cd=pr.prefix_id)
     AND pr.primary_ind=1
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET no_primary_rpt_exists_ind = 1
   ENDIF
  ENDIF
  IF (((no_primary_rpt_exists_ind=1) OR (primary_ind=1)) )
   SET stat = uar_get_meaning_by_codeset(1305,"CANCEL",1,cancel_status_cd)
   SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_status_cd)
   SET stat = uar_get_meaning_by_codeset(1305,"PROCESSING",1,processing_status_cd)
   IF (cancel_status_cd=0)
    CALL handle_errors("SELECT","F","TABLE","CODE_VALUE - CANCEL")
    GO TO exit_script
   ENDIF
   IF (verified_status_cd=0)
    CALL handle_errors("SELECT","F","TABLE","CODE_VALUE - VERIFIED")
    GO TO exit_script
   ENDIF
   IF (processing_status_cd=0)
    CALL handle_errors("SELECT","F","TABLE","CODE_VALUE - PROCESSING")
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    pt.case_id
    FROM processing_task pt
    WHERE (pt.case_id=request->case_id)
     AND  NOT (((pt.status_cd+ 0) IN (cancel_status_cd, verified_status_cd)))
     AND pt.create_inventory_flag=4
    HEAD REPORT
     spec_cnt = 0
    DETAIL
     spec_cnt += 1, stat = alterlist(reply->spec_qual,spec_cnt), reply->spec_qual[spec_cnt].id = pt
     .case_specimen_id,
     reply->spec_qual[spec_cnt].order_id = pt.order_id, reply->spec_qual[spec_cnt].status_cd = pt
     .status_cd
    WITH nocounter, forupdate(pt)
   ;end select
   IF (spec_cnt > 0)
    UPDATE  FROM processing_task pt,
      (dummyt d  WITH seq = value(spec_cnt))
     SET pt.status_cd = verified_status_cd, pt.status_prsnl_id = reqinfo->updt_id, pt.status_dt_tm =
      cnvtdatetime(sysdate),
      pt.updt_dt_tm = cnvtdatetime(sysdate), pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->
      updt_task,
      pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1)
     PLAN (d)
      JOIN (pt
      WHERE (pt.case_specimen_id=reply->spec_qual[d.seq].id)
       AND pt.create_inventory_flag=4)
     WITH nocounter
    ;end update
    IF (curqual != spec_cnt)
     CALL handle_errors("UDPATE","F","TABLE","PROCESSING_TASK")
     GO TO exit_script
    ENDIF
    INSERT  FROM ap_ops_exception aoe,
      (dummyt d  WITH seq = value(spec_cnt))
     SET aoe.parent_id = reply->spec_qual[d.seq].id, aoe.action_flag = 5, aoe.active_ind = 1,
      aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task
       = reqinfo->updt_task,
      aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
     PLAN (d)
      JOIN (aoe
      WHERE (aoe.parent_id=reply->spec_qual[d.seq].id)
       AND aoe.action_flag=5)
     WITH nocounter, outerjoin = d, dontexist
    ;end insert
    IF (curqual != spec_cnt)
     CALL handle_errors("INSERT","F","TABLE","AP_OPS_EXCEPTION")
     GO TO exit_script
    ENDIF
    IF (curutc=1)
     INSERT  FROM ap_ops_exception_detail aoed,
       (dummyt d  WITH seq = value(spec_cnt))
      SET aoed.action_flag = 5, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
       aoed.parent_id = reply->spec_qual[d.seq].id, aoed.sequence = 1, aoed.updt_applctx = reqinfo->
       updt_applctx,
       aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
       updt_id,
       aoed.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (aoed
       WHERE (aoed.parent_id=reply->spec_qual[d.seq].id)
        AND aoed.action_flag=5)
      WITH nocounter, outerjoin = d, dontexist
     ;end insert
     IF (curqual != spec_cnt)
      CALL handle_errors("INSERT","F","TABLE","AP_OPS_EXCEPTION_DETAIL")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (images_changed=1)
  EXECUTE aps_add_departmental_images
  IF ((reply->status_data.status="F"))
   SET error_cnt = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->status_mean IN ("VERIFIED", "CORRECTED")))
  EXECUTE aps_del_departmental_images
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->status_cd = 0
  SET reply->status_disp = ""
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 GO TO end_of_program
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_program
END GO
