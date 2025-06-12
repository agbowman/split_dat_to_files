CREATE PROGRAM aps_chg_cyto_report:dba
 RECORD tmp(
   1 task_assay_qual[*]
     2 task_assay_cd = f8
 )
 RECORD temp_event(
   1 event_qual[*]
     2 event_id = f8
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
 RECORD dtemp(
   1 beg_of_day = dq8
   1 end_of_day = dq8
   1 beg_of_day_abs = dq8
   1 end_of_day_abs = dq8
   1 beg_of_month = dq8
   1 end_of_month = dq8
   1 beg_of_month_abs = dq8
   1 end_of_month_abs = dq8
 )
 SUBROUTINE change_times(start_date,end_date)
  CALL getstartofday(start_date,0)
  CALL getendofday(end_date,0)
 END ;Subroutine
 SUBROUTINE getstartofdayabs(date_time,date_offset)
  CALL getstartofday(date_time,date_offset)
  SET dtemp->beg_of_day_abs = cnvtdatetimeutc(dtemp->beg_of_day,2)
 END ;Subroutine
 SUBROUTINE getstartofday(date_time,date_offset)
   SET dtemp->beg_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),0)
 END ;Subroutine
 SUBROUTINE getendofdayabs(date_time,date_offset)
  CALL getendofday(date_time,date_offset)
  SET dtemp->end_of_day_abs = cnvtdatetimeutc(dtemp->end_of_day,2)
 END ;Subroutine
 SUBROUTINE getendofday(date_time,date_offset)
   SET dtemp->end_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),235959)
 END ;Subroutine
 SUBROUTINE getstartofmonthabs(date_time,month_offset)
  CALL getstartofmonth(date_time,month_offset)
  SET dtemp->beg_of_month_abs = cnvtdatetimeutc(dtemp->beg_of_month,2)
 END ;Subroutine
 SUBROUTINE getstartofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) <= 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = (((month(date_time)+ month_offset) - 1)/ 12)
    SET nmonthremainder = mod((month(date_time)+ month_offset),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->beg_of_month = cnvtdatetime(cnvtdate2(date_string,"ddmmyyyy"),0)
 END ;Subroutine
 SUBROUTINE getendofmonthabs(date_time,month_offset)
  CALL getendofmonth(date_time,month_offset)
  SET dtemp->end_of_month_abs = cnvtdatetimeutc(dtemp->end_of_month,2)
 END ;Subroutine
 SUBROUTINE getendofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) < 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = ((month(date_time)+ month_offset)/ 12)
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->end_of_month = cnvtdatetime((cnvtdate2(date_string,"ddmmyyyy") - 1),235959)
 END ;Subroutine
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET count = 0
 SET cur_updt_cnt = 0
 SET cur_status_cd = 0.0
 SET updt_array[100] = 0
 SET monthis = format(cnvtdatetime(request->screen_dt_tm),"mmm;;d")
 SET yearis = cnvtint(year(request->screen_dt_tm))
 SET firstofmonth = build("01-",monthis,"-",yearis," 00:00:00.00")
 SET first_day_of_month = cnvtdatetime(firstofmonth)
 SET gyn_cases_is = 0
 SET gyn_cases_rs = 0
 SET gyn_slides_is = 0.0
 SET gyn_slides_rs = 0.0
 SET ngyn_slides_is = 0.0
 SET ngyn_slides_rs = 0.0
 SET ngyn_cases_is = 0
 SET ngyn_cases_rs = 0
 SET normal_cases = 0
 SET normal_slides = 0.0
 SET normal_slides_requeued = 0.0
 SET chr_cases = 0
 SET chr_slides = 0.0
 SET chr_slides_requeued = 0.0
 SET prev_atypical_cases = 0
 SET prev_atypical_slides = 0.0
 SET prev_atyp_slides_requeued = 0.0
 SET prev_abnormal_cases = 0
 SET prev_abnormal_slides = 0.0
 SET prev_abn_slides_requeued = 0.0
 SET unsat_cases = 0
 SET unsat_slides = 0.0
 SET unsat_slides_requeued = 0.0
 SET exceeded_limit_cases = 0
 SET exceeded_limit_slides = 0.0
 SET user_preference_cases = 0
 SET user_preference_slides = 0.0
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
 DECLARE neventcnt = i2 WITH protect, noconstant(0)
 DECLARE dserviceresourcecd = f8 WITH protect, noconstant(0.0)
 DECLARE deleteinsertfut(insert_ind=i2) = null
 DECLARE case_cnt_ind = i2
 SET qaflags = 0
 SET unsat = 1
 SET norm = 2
 SET abnorm = 4
 SET atyp = 8
 SET chr = 16
 IF ((request->review_reason_flag=7))
  SET request->qaflag_bitword = 0
 ENDIF
 SET qaflags = request->qaflag_bitword
 IF (cnvtint(size(request->report_qual,5)) > 0)
  SET images_changed = 1
 ENDIF
 CALL getstartofdayabs(request->screen_dt_tm,0)
 CALL getstartofmonthabs(request->screen_dt_tm,0)
 IF ((request->status_mean > " "))
  SET stat = uar_get_meaning_by_codeset(1305,nullterm(request->status_mean),1,request->status_cd)
  IF ((request->status_cd=0))
   CALL handle_errors("UAR","F","1305",request->status_mean)
   GO TO exit_script
  ENDIF
  SET reply->status_cd = request->status_cd
  IF (images_changed=1)
   SET request->report_qual[1].status_cd = request->status_cd
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
   cr.status_cd = request->status_cd, cr.updt_dt_tm = cnvtdatetime(curdate,curtime), cr.updt_id =
   reqinfo->updt_id,
   cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->updt_applctx, cr.updt_cnt = (
   cur_updt_cnt+ 1),
   cr.signing_location_cd =
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
   SET a.parent_id = request->report_id, a.action_flag = nactionflag, a.active_ind = 1,
    a.flex1_id = request->proxy_id, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id =
    reqinfo->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed
    SET aoed.action_flag = nactionflag, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr =
     curtimezoneapp,
     aoed.parent_id = request->report_id, aoed.sequence = 1, aoed.updt_applctx = reqinfo->
     updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime3), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((request->status_mean IN ("VERIFIED", "SIGNINPROC")))
  INSERT  FROM ap_ops_exception a
   SET a.parent_id = request->report_id, a.action_flag = 6, a.active_ind = 1,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
    reqinfo->updt_task,
    a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed
    SET aoed.action_flag = 6, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = request->report_id, aoed.sequence = 1, aoed.updt_applctx = reqinfo->
     updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime3), aoed.updt_id = reqinfo->
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
   cur_updt_cnt = rt.updt_cnt, dserviceresourcecd = rt.service_resource_cd
  WITH forupdate(rt)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","REPORT_TASK")
  GO TO exit_script
 ENDIF
 UPDATE  FROM report_task rt
  SET rt.service_resource_cd =
   IF ((request->service_resource_cd > 0)) request->service_resource_cd
   ELSE rt.service_resource_cd
   ENDIF
   , rt.editing_prsnl_id = 0, rt.last_edit_dt_tm = cnvtdatetime(request->edit_dt_tm),
   rt.last_task_assay_cd = request->last_task_assay_cd, rt.responsible_pathologist_id =
   IF (supdaterptresp="T"
    AND (request->path_or_resi_flg=pathologist)) request->responsibility_id
   ELSE rt.responsible_pathologist_id
   ENDIF
   , rt.responsible_resident_id =
   IF (supdaterptresp="T"
    AND (request->path_or_resi_flg=resident)) request->responsibility_id
   ELSE rt.responsible_resident_id
   ENDIF
   ,
   rt.updt_dt_tm = cnvtdatetime(curdate,curtime), rt.updt_id = reqinfo->updt_id, rt.updt_task =
   reqinfo->updt_task,
   rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = (cur_updt_cnt+ 1)
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
    count = (count+ 1), updt_array[count] = rdt.updt_cnt
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
    .seq].status_cd, rdt.modified_ind = request->section_qual[d.seq].modified_ind,
    rdt.updt_dt_tm = cnvtdatetime(curdate,curtime), rdt.updt_id = reqinfo->updt_id, rdt.updt_task =
    reqinfo->updt_task,
    rdt.updt_applctx = reqinfo->updt_applctx, rdt.updt_cnt = (updt_array[d.seq]+ 1)
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
    ta_count = (ta_count+ 1)
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
    WITH nocounter, forupdate(apt)
   ;end select
   IF (curqual=0)
    CALL handle_errors("LOCK","F","TABLE","AP_PROMPT_TEST")
    GO TO exit_script
   ENDIF
   UPDATE  FROM ap_prompt_test apt,
     (dummyt d  WITH seq = value(size(tmp->task_assay_qual,5)))
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
 SET case_cnt_ind = 1
 IF ((request->sequence > 0)
  AND (request->slide_cnt > 0)
  AND (request->slide_cnt_total > 0))
  SELECT INTO "nl:"
   FROM cyto_screening_event cse
   WHERE (cse.sequence=request->sequence)
    AND (cse.case_id=request->case_id)
   DETAIL
    IF ((cse.screener_id=request->screener_id)
     AND datetimecmp(cnvtdatetime(request->screen_dt_tm),cse.screen_dt_tm)=0)
     case_cnt_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","CYTO_SCREENING_EVENT")
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM cyto_screening_event cse
  SET cse.case_id = request->case_id, cse.sequence = (request->sequence+ 1), cse.screener_id =
   request->screener_id,
   cse.screen_dt_tm = cnvtdatetime(request->screen_dt_tm), cse.verify_ind =
   IF ((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC"))) 1
   ELSE 0
   ENDIF
   , cse.review_reason_flag = request->review_reason_flag,
   cse.initial_screener_ind = request->initial_ind, cse.reference_range_factor_id = request->
   reference_range_factor_id, cse.nomenclature_id = request->nomenclature_id,
   cse.diagnostic_category_cd = request->diagnostic_category_cd, cse.endocerv_ind = request->
   endocerv_ind, cse.adequacy_flag = request->adequacy_flag,
   cse.standard_rpt_id = request->standard_rpt_cd, cse.event_id = request->event_id, cse
   .service_resource_cd = dserviceresourcecd,
   cse.active_ind = 1, cse.valid_from_dt_tm = cnvtdatetime(request->valid_from_dt_tm), cse.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   cse.updt_id = reqinfo->updt_id, cse.updt_task = reqinfo->updt_task, cse.updt_applctx = reqinfo->
   updt_applctx,
   cse.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL handle_errors("INSERT","F","TABLE","CYTO_SCREENING_EVENT")
  GO TO exit_script
 ENDIF
 IF ((request->pathologist_ind=0))
  IF ((request->slide_cnt_total=0))
   SET request->slide_cnt_total = request->slide_cnt
  ENDIF
  SELECT INTO "nl:"
   dcc.prsnl_id
   FROM daily_cytology_counts dcc
   WHERE (request->screener_id=dcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_day_abs)=dcc.record_dt_tm
  ;end select
  IF (curqual=0)
   INSERT  FROM daily_cytology_counts dcc
    SET dcc.prsnl_id = request->screener_id, dcc.screen_hours = 8, dcc.record_dt_tm = cnvtdatetime(
      dtemp->beg_of_day_abs),
     dcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcc.updt_id = reqinfo->updt_id, dcc.updt_task
      = reqinfo->updt_task,
     dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    CALL handle_errors("INSERT","F","TABLE","DAILY_CYTOLOGY_COUNTS")
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   dcc.prsnl_id
   FROM daily_cytology_counts dcc
   WHERE (request->screener_id=dcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_day_abs)=dcc.record_dt_tm
   DETAIL
    gyn_cases_is = dcc.gyn_cases_is, gyn_cases_rs = dcc.gyn_cases_rs, gyn_slides_is = dcc
    .gyn_slides_is,
    gyn_slides_rs = dcc.gyn_slides_rs, ngyn_slides_is = dcc.ngyn_slides_is, ngyn_slides_rs = dcc
    .ngyn_slides_rs,
    ngyn_cases_is = dcc.ngyn_cases_is, ngyn_cases_rs = dcc.ngyn_cases_rs, normal_cases = dcc
    .normal_cases,
    normal_slides = dcc.normal_slides, normal_slides_requeued = dcc.normal_slides_requeued, chr_cases
     = dcc.chr_cases,
    chr_slides = dcc.chr_slides, chr_slides_requeued = dcc.chr_slides_requeued, prev_atypical_cases
     = dcc.prev_atypical_cases,
    prev_atypical_slides = dcc.prev_atypical_slides, prev_atyp_slides_requeued = dcc
    .prev_atyp_slides_requeued, prev_abnormal_cases = dcc.prev_abnormal_cases,
    prev_abnormal_slides = dcc.prev_abnormal_slides, prev_abn_slides_requeued = dcc
    .prev_abn_slides_requeued, unsat_cases = dcc.unsat_cases,
    unsat_slides = dcc.unsat_slides, unsat_slides_requeued = dcc.unsat_slides_requeued,
    exceeded_limit_cases = dcc.exceeded_limit_cases,
    exceeded_limit_slides = dcc.exceeded_limit_slides, user_preference_cases = dcc
    .user_preference_cases, user_preference_slides = dcc.user_preference_slides,
    cur_updt_cnt = dcc.updt_cnt
   WITH nocounter, forupdate(dcc)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
  UPDATE  FROM daily_cytology_counts dcc
   SET dcc.gyn_cases_is =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=1)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (gyn_cases_is+ 1)
    ELSE dcc.gyn_cases_is
    ENDIF
    , dcc.gyn_slides_is =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=1)
     AND (request->slide_cnt > 0)) (gyn_slides_is+ request->slide_cnt)
    ELSE gyn_slides_is
    ENDIF
    , dcc.gyn_cases_rs =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=0)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (gyn_cases_rs+ 1)
    ELSE dcc.gyn_cases_rs
    ENDIF
    ,
    dcc.gyn_slides_rs =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=0)
     AND (request->slide_cnt > 0)) (gyn_slides_rs+ request->slide_cnt)
    ELSE gyn_slides_rs
    ENDIF
    , dcc.ngyn_cases_is =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=1)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (ngyn_cases_is+ 1)
    ELSE dcc.ngyn_cases_is
    ENDIF
    , dcc.ngyn_slides_is =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=1)
     AND (request->slide_cnt > 0)) (ngyn_slides_is+ request->slide_cnt)
    ELSE ngyn_slides_is
    ENDIF
    ,
    dcc.ngyn_cases_rs =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=0)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (ngyn_cases_rs+ 1)
    ELSE dcc.ngyn_cases_rs
    ENDIF
    , dcc.ngyn_slides_rs =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=0)
     AND (request->slide_cnt > 0)) (ngyn_slides_rs+ request->slide_cnt)
    ELSE ngyn_slides_rs
    ENDIF
    , dcc.exceeded_limit_cases =
    IF ((request->review_reason_flag=1)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (exceeded_limit_cases+ 1)
    ELSE dcc.exceeded_limit_cases
    ENDIF
    ,
    dcc.exceeded_limit_slides =
    IF ((request->review_reason_flag=1)
     AND (request->slide_cnt > 0)) (exceeded_limit_slides+ request->slide_cnt)
    ELSE dcc.exceeded_limit_slides
    ENDIF
    , dcc.unsat_cases =
    IF (band(qaflags,unsat)=unsat) (unsat_cases+ 1)
    ELSE dcc.unsat_cases
    ENDIF
    , dcc.unsat_slides =
    IF (band(qaflags,unsat)=unsat) (unsat_slides+ request->slide_cnt_total)
    ELSE dcc.unsat_slides
    ENDIF
    ,
    dcc.unsat_slides_requeued =
    IF ((request->review_reason_flag=2)) (unsat_slides_requeued+ request->slide_cnt_total)
    ELSE dcc.unsat_slides_requeued
    ENDIF
    , dcc.normal_cases =
    IF (band(qaflags,norm)=norm) (normal_cases+ 1)
    ELSE dcc.normal_cases
    ENDIF
    , dcc.normal_slides =
    IF (band(qaflags,norm)=norm) (normal_slides+ request->slide_cnt_total)
    ELSE dcc.normal_slides
    ENDIF
    ,
    dcc.normal_slides_requeued =
    IF ((request->review_reason_flag=3)) (normal_slides_requeued+ request->slide_cnt_total)
    ELSE dcc.normal_slides_requeued
    ENDIF
    , dcc.prev_atypical_cases =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_cases+ 1)
    ELSE dcc.prev_atypical_cases
    ENDIF
    , dcc.prev_atypical_slides =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_slides+ request->slide_cnt_total)
    ELSE dcc.prev_atypical_slides
    ENDIF
    ,
    dcc.prev_atyp_slides_requeued =
    IF ((request->review_reason_flag=4)) (prev_atyp_slides_requeued+ request->slide_cnt_total)
    ELSE dcc.prev_atyp_slides_requeued
    ENDIF
    , dcc.prev_abnormal_cases =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_cases+ 1)
    ELSE dcc.prev_abnormal_cases
    ENDIF
    , dcc.prev_abnormal_slides =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_slides+ request->slide_cnt_total)
    ELSE dcc.prev_abnormal_slides
    ENDIF
    ,
    dcc.prev_abn_slides_requeued =
    IF ((request->review_reason_flag=5)) (prev_abn_slides_requeued+ request->slide_cnt_total)
    ELSE dcc.prev_abn_slides_requeued
    ENDIF
    , dcc.chr_cases =
    IF (band(qaflags,chr)=chr) (chr_cases+ 1)
    ELSE dcc.chr_cases
    ENDIF
    , dcc.chr_slides =
    IF (band(qaflags,chr)=chr) (chr_slides+ request->slide_cnt_total)
    ELSE dcc.chr_slides
    ENDIF
    ,
    dcc.chr_slides_requeued =
    IF ((request->review_reason_flag=6)) (chr_slides_requeued+ request->slide_cnt_total)
    ELSE dcc.chr_slides_requeued
    ENDIF
    , dcc.user_preference_cases =
    IF ((request->review_reason_flag=8)) (user_preference_cases+ 1)
    ELSE dcc.user_preference_cases
    ENDIF
    , dcc.user_preference_slides =
    IF ((request->review_reason_flag=8)) (user_preference_slides+ request->slide_cnt_total)
    ELSE dcc.user_preference_slides
    ENDIF
    ,
    dcc.updt_dt_tm = cnvtdatetime(curdate,curtime), dcc.updt_id = reqinfo->updt_id, dcc.updt_task =
    reqinfo->updt_task,
    dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt = (cur_updt_cnt+ 1)
   WHERE (request->screener_id=dcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_day_abs)=dcc.record_dt_tm
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   mcc.prsnl_id
   FROM monthly_cytology_counts mcc
   WHERE (request->screener_id=mcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_month_abs)=mcc.record_dt_tm
  ;end select
  IF (curqual=0)
   INSERT  FROM monthly_cytology_counts mcc
    SET mcc.prsnl_id = request->screener_id, mcc.screen_hours = 8, mcc.record_dt_tm = cnvtdatetime(
      dtemp->beg_of_month_abs),
     mcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), mcc.updt_id = reqinfo->updt_id, mcc.updt_task
      = reqinfo->updt_task,
     mcc.updt_applctx = reqinfo->updt_applctx, mcc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    CALL handle_errors("INSERT","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   mcc.prsnl_id
   FROM monthly_cytology_counts mcc
   WHERE (request->screener_id=mcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_month_abs)=mcc.record_dt_tm
   DETAIL
    gyn_cases_is = mcc.gyn_cases_is, gyn_cases_rs = mcc.gyn_cases_rs, gyn_slides_is = mcc
    .gyn_slides_is,
    gyn_slides_rs = mcc.gyn_slides_rs, ngyn_slides_is = mcc.ngyn_slides_is, ngyn_slides_rs = mcc
    .ngyn_slides_rs,
    ngyn_cases_is = mcc.ngyn_cases_is, ngyn_cases_rs = mcc.ngyn_cases_rs, normal_cases = mcc
    .normal_cases,
    normal_slides = mcc.normal_slides, normal_slides_requeued = mcc.normal_slides_requeued, chr_cases
     = mcc.chr_cases,
    chr_slides = mcc.chr_slides, chr_slides_requeued = mcc.chr_slides_requeued, prev_atypical_cases
     = mcc.prev_atypical_cases,
    prev_atypical_slides = mcc.prev_atypical_slides, prev_atyp_slides_requeued = mcc
    .prev_atyp_slides_requeued, prev_abnormal_cases = mcc.prev_abnormal_cases,
    prev_abnormal_slides = mcc.prev_abnormal_slides, prev_abn_slides_requeued = mcc
    .prev_abn_slides_requeued, unsat_cases = mcc.unsat_cases,
    unsat_slides = mcc.unsat_slides, unsat_slides_requeued = mcc.unsat_slides_requeued,
    exceeded_limit_cases = mcc.exceeded_limit_cases,
    exceeded_limit_slides = mcc.exceeded_limit_slides, user_preference_cases = mcc
    .user_preference_cases, user_preference_slides = mcc.user_preference_slides,
    cur_updt_cnt = mcc.updt_cnt
   WITH nocounter, forupdate(mcc)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
  UPDATE  FROM monthly_cytology_counts mcc
   SET mcc.gyn_cases_is =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=1)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (gyn_cases_is+ 1)
    ELSE mcc.gyn_cases_is
    ENDIF
    , mcc.gyn_slides_is =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=1)
     AND (request->slide_cnt > 0)) (gyn_slides_is+ request->slide_cnt)
    ELSE gyn_slides_is
    ENDIF
    , mcc.gyn_cases_rs =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=0)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (gyn_cases_rs+ 1)
    ELSE mcc.gyn_cases_rs
    ENDIF
    ,
    mcc.gyn_slides_rs =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=0)
     AND (request->slide_cnt > 0)) (gyn_slides_rs+ request->slide_cnt)
    ELSE gyn_slides_rs
    ENDIF
    , mcc.ngyn_cases_is =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=1)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (ngyn_cases_is+ 1)
    ELSE mcc.ngyn_cases_is
    ENDIF
    , mcc.ngyn_slides_is =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=1)
     AND (request->slide_cnt > 0)) (ngyn_slides_is+ request->slide_cnt)
    ELSE ngyn_slides_is
    ENDIF
    ,
    mcc.ngyn_cases_rs =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=0)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (ngyn_cases_rs+ 1)
    ELSE mcc.ngyn_cases_rs
    ENDIF
    , mcc.ngyn_slides_rs =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=0)
     AND (request->slide_cnt > 0)) (ngyn_slides_rs+ request->slide_cnt)
    ELSE ngyn_slides_rs
    ENDIF
    , mcc.exceeded_limit_cases =
    IF ((request->review_reason_flag=1)
     AND (request->slide_cnt > 0)
     AND case_cnt_ind > 0) (exceeded_limit_cases+ 1)
    ELSE mcc.exceeded_limit_cases
    ENDIF
    ,
    mcc.exceeded_limit_slides =
    IF ((request->review_reason_flag=1)
     AND (request->slide_cnt > 0)) (exceeded_limit_slides+ request->slide_cnt)
    ELSE mcc.exceeded_limit_slides
    ENDIF
    , mcc.unsat_cases =
    IF (band(qaflags,unsat)=unsat) (unsat_cases+ 1)
    ELSE mcc.unsat_cases
    ENDIF
    , mcc.unsat_slides =
    IF (band(qaflags,unsat)=unsat) (unsat_slides+ request->slide_cnt_total)
    ELSE mcc.unsat_slides
    ENDIF
    ,
    mcc.unsat_slides_requeued =
    IF ((request->review_reason_flag=2)) (unsat_slides_requeued+ request->slide_cnt_total)
    ELSE mcc.unsat_slides_requeued
    ENDIF
    , mcc.normal_cases =
    IF (band(qaflags,norm)=norm) (normal_cases+ 1)
    ELSE mcc.normal_cases
    ENDIF
    , mcc.normal_slides =
    IF (band(qaflags,norm)=norm) (normal_slides+ request->slide_cnt_total)
    ELSE mcc.normal_slides
    ENDIF
    ,
    mcc.normal_slides_requeued =
    IF ((request->review_reason_flag=3)) (normal_slides_requeued+ request->slide_cnt_total)
    ELSE mcc.normal_slides_requeued
    ENDIF
    , mcc.prev_atypical_cases =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_cases+ 1)
    ELSE mcc.prev_atypical_cases
    ENDIF
    , mcc.prev_atypical_slides =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_slides+ request->slide_cnt_total)
    ELSE mcc.prev_atypical_slides
    ENDIF
    ,
    mcc.prev_atyp_slides_requeued =
    IF ((request->review_reason_flag=4)) (prev_atyp_slides_requeued+ request->slide_cnt_total)
    ELSE mcc.prev_atyp_slides_requeued
    ENDIF
    , mcc.prev_abnormal_cases =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_cases+ 1)
    ELSE mcc.prev_abnormal_cases
    ENDIF
    , mcc.prev_abnormal_slides =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_slides+ request->slide_cnt_total)
    ELSE mcc.prev_abnormal_slides
    ENDIF
    ,
    mcc.prev_abn_slides_requeued =
    IF ((request->review_reason_flag=5)) (prev_abn_slides_requeued+ request->slide_cnt_total)
    ELSE mcc.prev_abn_slides_requeued
    ENDIF
    , mcc.chr_cases =
    IF (band(qaflags,chr)=chr) (chr_cases+ 1)
    ELSE mcc.chr_cases
    ENDIF
    , mcc.chr_slides =
    IF (band(qaflags,chr)=chr) (chr_slides+ request->slide_cnt_total)
    ELSE mcc.chr_slides
    ENDIF
    ,
    mcc.chr_slides_requeued =
    IF ((request->review_reason_flag=6)) (chr_slides_requeued+ request->slide_cnt_total)
    ELSE mcc.chr_slides_requeued
    ENDIF
    , mcc.user_preference_cases =
    IF ((request->review_reason_flag=8)) (user_preference_cases+ 1)
    ELSE mcc.user_preference_cases
    ENDIF
    , mcc.user_preference_slides =
    IF ((request->review_reason_flag=8)) (user_preference_slides+ request->slide_cnt_total)
    ELSE mcc.user_preference_slides
    ENDIF
    ,
    mcc.updt_dt_tm = cnvtdatetime(curdate,curtime), mcc.updt_id = reqinfo->updt_id, mcc.updt_task =
    reqinfo->updt_task,
    mcc.updt_applctx = reqinfo->updt_applctx, mcc.updt_cnt = (cur_updt_cnt+ 1)
   WHERE (request->screener_id=mcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_month_abs)=mcc.record_dt_tm
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ENDIF
 SET slide_cnt = size(request->slide_qual,5)
 IF (slide_cnt > 0)
  SELECT INTO "nl:"
   s.slide_id
   FROM slide s,
    (dummyt d  WITH seq = value(slide_cnt))
   PLAN (d)
    JOIN (s
    WHERE (request->slide_qual[d.seq].slide_id=s.slide_id))
   WITH forupdate(s)
  ;end select
  IF (((curqual=0) OR (curqual != slide_cnt)) )
   CALL handle_errors("SELECT","F","TABLE","SLIDE")
   GO TO exit_script
  ENDIF
  UPDATE  FROM slide s,
    (dummyt d  WITH seq = value(slide_cnt))
   SET s.screening_ind = 1, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s.updt_id = reqinfo->
    updt_id,
    s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (s
    WHERE (request->slide_qual[d.seq].slide_id=s.slide_id))
   WITH nocounter
  ;end update
  IF (curqual != slide_cnt)
   CALL handle_errors("UPDATE","F","TABLE","SLIDE")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC"))) OR ((request
 ->resp_case_rpt_flg > 1))) )
  IF ((request->primary_ind=1))
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
     IF ((request->path_or_resi_flg=pathologist)
      AND (request->resp_case_rpt_flg > 1)) request->responsibility_id
     ELSE pc.responsible_pathologist_id
     ENDIF
     , pc.responsible_resident_id =
     IF ((request->path_or_resi_flg=resident)
      AND (request->resp_case_rpt_flg > 1)) request->responsibility_id
     ELSE pc.responsible_resident_id
     ENDIF
     ,
     pc.chr_ind =
     IF ((request->clin_high_risk_ind > - (1))) request->clin_high_risk_ind
     ELSE pc.chr_ind
     ENDIF
     , pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_id = reqinfo->updt_id,
     pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (
     cur_updt_cnt+ 1)
    WHERE (request->case_id=pc.case_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","F","TABLE","PATHOLOGY_CASE")
    GO TO exit_script
   ELSEIF (images_changed=1)
    SET request->case_updt_cnt = (cur_updt_cnt+ 1)
   ENDIF
  ENDIF
  IF ((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC"))
   AND (request->flag_type_cd > 0))
   INSERT  FROM ap_qa_info aqi
    SET aqi.qa_flag_id = seq(pathnet_seq,nextval), aqi.case_id = request->case_id, aqi.flag_type_cd
      = request->flag_type_cd,
     aqi.activated_id = request->screener_id, aqi.activated_dt_tm = cnvtdatetime(request->edit_dt_tm),
     aqi.person_id = request->person_id,
     aqi.active_ind = 1, aqi.updt_dt_tm = cnvtdatetime(curdate,curtime), aqi.updt_id = reqinfo->
     updt_id,
     aqi.updt_task = reqinfo->updt_task, aqi.updt_applctx = reqinfo->updt_applctx, aqi.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("INSERT","F","TABLE","AP_QA_INFO")
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->status_mean IN ("CORRECTED", "CSIGNINPROC"))
   AND (request->follow_up_type_cd=0))
   CALL deleteinsertfut(0)
  ELSEIF ((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC"))
   AND (request->follow_up_type_cd > 0))
   CALL deleteinsertfut(1)
  ENDIF
 ELSE
  IF ((request->clin_high_risk_ind > - (1)))
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
    SET pc.chr_ind = request->clin_high_risk_ind, pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc
     .updt_id = reqinfo->updt_id,
     pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (
     cur_updt_cnt+ 1)
    WHERE (request->case_id=pc.case_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","F","TABLE","PATHOLOGY_CASE")
    GO TO exit_script
   ELSEIF (images_changed=1)
    SET request->case_updt_cnt = (cur_updt_cnt+ 1)
   ENDIF
  ENDIF
 ENDIF
 IF ((request->status_mean IN ("VERIFIED", "CORRECTED", "SIGNINPROC", "CSIGNINPROC")))
  IF ((request->primary_ind=0))
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
  IF (((no_primary_rpt_exists_ind=1) OR ((request->primary_ind=1))) )
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
     spec_cnt = (spec_cnt+ 1), stat = alterlist(reply->spec_qual,spec_cnt), reply->spec_qual[spec_cnt
     ].id = pt.case_specimen_id,
     reply->spec_qual[spec_cnt].order_id = pt.order_id, reply->spec_qual[spec_cnt].status_cd = pt
     .status_cd
    WITH nocounter, forupdate(pt)
   ;end select
   IF (spec_cnt > 0)
    UPDATE  FROM processing_task pt,
      (dummyt d  WITH seq = value(spec_cnt))
     SET pt.status_cd = verified_status_cd, pt.status_prsnl_id =
      IF ((reply->spec_qual[d.seq].status_cd=processing_status_cd)) pt.status_prsnl_id
      ELSE reqinfo->updt_id
      ENDIF
      , pt.status_dt_tm = cnvtdatetime(curdate,curtime3),
      pt.updt_dt_tm = cnvtdatetime(curdate,curtime3), pt.updt_id = reqinfo->updt_id, pt.updt_task =
      reqinfo->updt_task,
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
  IF ( NOT (validate(req200118,0)))
   EXECUTE aps_add_departmental_images
  ELSE
   EXECUTE aps_add_departmental_images  WITH replace("REQUEST","REQ200118"), replace("REPLY",
    "REP200118")
  ENDIF
  IF ((reply->status_data.status="F"))
   SET error_cnt = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->status_mean IN ("VERIFIED", "CORRECTED")))
  IF ( NOT (validate(req200118,0)))
   EXECUTE aps_del_departmental_images
  ELSE
   EXECUTE aps_del_departmental_images  WITH replace("REQUEST","REQ200118"), replace("REPLY",
    "REP200118")
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
 SUBROUTINE deleteinsertfut(insert_ind)
   SELECT INTO "nl:"
    afe.followup_event_id
    FROM ap_ft_event afe
    WHERE (afe.case_id=request->case_id)
     AND afe.origin_flag=0
     AND afe.term_dt_tm = null
    HEAD REPORT
     neventcnt = 0
    DETAIL
     neventcnt = (neventcnt+ 1), stat = alterlist(temp_event->event_qual,neventcnt), temp_event->
     event_qual[neventcnt].event_id = afe.followup_event_id
    WITH forupdate(afe)
   ;end select
   IF (curqual != 0
    AND neventcnt > 0)
    SELECT INTO "nl:"
     ftcl.followup_event_id
     FROM ft_term_candidate_list ftcl,
      (dummyt d  WITH seq = value(neventcnt))
     PLAN (d)
      JOIN (ftcl
      WHERE (ftcl.followup_event_id=temp_event->event_qual[d.seq].event_id))
     WITH forupdate(ftcl)
    ;end select
    IF (curqual != 0)
     DELETE  FROM ft_term_candidate_list ftcl,
       (dummyt d  WITH seq = value(neventcnt))
      SET ftcl.followup_event_id = temp_event->event_qual[d.seq].event_id
      PLAN (d)
       JOIN (ftcl
       WHERE (ftcl.followup_event_id=temp_event->event_qual[d.seq].event_id))
      WITH nocounter
     ;end delete
    ENDIF
    DELETE  FROM ap_ft_event afe,
      (dummyt d  WITH seq = value(neventcnt))
     SET afe.followup_event_id = temp_event->event_qual[d.seq].event_id
     PLAN (d)
      JOIN (afe
      WHERE (afe.followup_event_id=temp_event->event_qual[d.seq].event_id))
     WITH nocounter
    ;end delete
   ENDIF
   FREE SET temp_event
   IF (insert_ind=1)
    INSERT  FROM ap_ft_event fte
     SET fte.followup_event_id = seq(pathnet_seq,nextval), fte.case_id = request->case_id, fte
      .followup_type_cd = request->follow_up_type_cd,
      fte.expected_term_dt = cnvtdatetime(request->expected_term_dt), fte.initial_notif_dt_tm =
      cnvtdatetime(request->initial_notif_dt_tm), fte.first_overdue_dt_tm = cnvtdatetime(request->
       first_overdue_dt_tm),
      fte.final_overdue_dt_tm = cnvtdatetime(request->final_overdue_dt_tm), fte
      .initial_notif_print_flag = 0, fte.first_overdue_print_flag = 0,
      fte.final_overdue_print_flag = 0, fte.person_id = request->person_id, fte.origin_flag = 0,
      fte.origin_dt_tm = cnvtdatetime(request->edit_dt_tm), fte.origin_prsnl_id = request->
      screener_id, fte.updt_dt_tm = cnvtdatetime(curdate,curtime),
      fte.updt_id = reqinfo->updt_id, fte.updt_task = reqinfo->updt_task, fte.updt_applctx = reqinfo
      ->updt_applctx,
      fte.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL handle_errors("INSERT","F","TABLE","AP_FT_EVENT")
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("***** commit *****")
 ENDIF
#end_of_program
END GO
