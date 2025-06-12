CREATE PROGRAM aps_get_hist_case_report:dba
 RECORD reply(
   1 case_event_cd = f8
   1 catalog_cd = f8
   1 event_cd = f8
   1 description = vc
   1 short_description = vc
   1 status_prsnl_name = vc
   1 status_dt_tm = dq8
   1 qa_flag_ind = i2
   1 flag_type_cd = f8
   1 flag_type_disp = c40
   1 flag_type_desc = vc
   1 flag_type_mean = c12
   1 updt_cnt = i4
   1 section_qual[5]
     2 task_assay_cd = f8
     2 event_cd = f8
     2 history_activity_cd = f8
     2 section_sequence = i4
     2 result_type_cd = f8
     2 result_type_disp = c40
     2 result_type_desc = vc
     2 result_type_mean = c12
     2 status_cd = f8
     2 status_disp = c40
     2 required_ind = i2
     2 description = vc
   1 status_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD event(
   1 qual[*]
     2 parent_cd = f8
     2 event_cd = f8
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET catalog_cd = 0.0
 SET section_cnt = 0
 DECLARE drpteventid = f8 WITH protect, noconstant(0.0)
 DECLARE ddeletedstatuscd = f8 WITH protect, noconstant(0.0)
 SET ddeletedstatuscd = uar_get_code_by("MEANING",48,"DELETED")
 IF (ddeletedstatuscd=0)
  CALL subevent_add("UAR","F","UAR_GET_CODE_BY","48_DELETED")
  GO TO exit_script
 ENDIF
 IF ((request->catalog_cd=0.0))
  SELECT INTO "nl:"
   prr.prefix_id
   FROM prefix_report_r prr
   WHERE (request->prefix_cd=prr.prefix_id)
    AND ((prr.primary_ind=1) OR (prr.reporting_sequence=0))
   DETAIL
    IF (prr.primary_ind=1)
     reply->catalog_cd = prr.catalog_cd
    ELSE
     catalog_cd = prr.catalog_cd
    ENDIF
   WITH nocounter
  ;end select
  IF ((reply->catalog_cd=0.0))
   SET reply->catalog_cd = catalog_cd
  ENDIF
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PREFIX_REPORT_R"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->catalog_cd = request->catalog_cd
 ENDIF
 IF ((request->report_id > 0.0))
  SELECT INTO "nl:"
   cr.report_id
   FROM case_report cr,
    (dummyt d1  WITH seq = 1),
    ap_qa_info aq,
    prsnl p
   PLAN (cr
    WHERE (request->report_id=cr.report_id))
    JOIN (p
    WHERE cr.status_prsnl_id=p.person_id)
    JOIN (d1)
    JOIN (aq
    WHERE cr.case_id=aq.case_id
     AND aq.active_ind=1)
   DETAIL
    drpteventid = cr.event_id, reply->catalog_cd = cr.catalog_cd, reply->updt_cnt = cr.updt_cnt,
    reply->status_dt_tm = cr.status_dt_tm, reply->status_prsnl_name = trim(p.name_full_formatted),
    reply->status_prsnl_id = p.person_id,
    reply->flag_type_cd = aq.flag_type_cd
   WITH nocounter, outerjoin = d1
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  SET drpteventid = 0.0
 ENDIF
 SELECT INTO "nl:"
  ptr.catalog_cd, crc_report_type_flag = decode(crc.seq,crc.report_type_flag,0), nclinicaleventind =
  evaluate(nullind(ce.task_assay_cd),0,1,0)
  FROM service_directory sd,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   cyto_report_control crc,
   profile_task_r ptr,
   discrete_task_assay dt,
   clinical_event ce
  PLAN (sd
   WHERE (reply->catalog_cd=sd.catalog_cd))
   JOIN (d1)
   JOIN (crc
   WHERE sd.catalog_cd=crc.catalog_cd)
   JOIN (d2)
   JOIN (ptr
   WHERE sd.catalog_cd=ptr.catalog_cd)
   JOIN (dt
   WHERE ptr.task_assay_cd=dt.task_assay_cd)
   JOIN (ce
   WHERE outerjoin(dt.task_assay_cd)=ce.task_assay_cd
    AND outerjoin(drpteventid)=ce.parent_event_id
    AND outerjoin(cnvtdatetime(curdate,curtime3)) >= ce.valid_from_dt_tm
    AND outerjoin(cnvtdatetime(curdate,curtime3)) <= ce.valid_until_dt_tm
    AND outerjoin(ddeletedstatuscd) != ce.record_status_cd)
  ORDER BY ptr.sequence
  HEAD REPORT
   reply->description = sd.description, reply->short_description = sd.short_description, reply->
   qa_flag_ind = crc_report_type_flag
  DETAIL
   IF (((nclinicaleventind=1) OR (ptr.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm))
   )
    section_cnt = (section_cnt+ 1)
    IF (mod(section_cnt,5)=1
     AND section_cnt != 1)
     stat = alter(reply->section_qual,(section_cnt+ 4))
    ENDIF
    reply->section_qual[section_cnt].task_assay_cd = ptr.task_assay_cd, reply->section_qual[
    section_cnt].section_sequence = ptr.sequence, reply->section_qual[section_cnt].
    history_activity_cd = dt.history_activity_type_cd,
    reply->section_qual[section_cnt].result_type_cd = dt.default_result_type_cd, reply->section_qual[
    section_cnt].required_ind = ptr.pending_ind, reply->section_qual[section_cnt].description = dt
    .description
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = crc
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROFILE_TASK_R"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(event->qual,(size(reply->section_qual,5)+ 2))
 SET code_set = 73
 SET cdf_meaning = "APS01"
 EXECUTE cpm_get_cd_for_cdf
 SET event->qual[1].parent_cd = code_value
 SET event->qual[2].parent_cd = reply->catalog_cd
 FOR (x = 1 TO size(reply->section_qual,5))
   SET event->qual[(x+ 2)].parent_cd = reply->section_qual[x].task_assay_cd
 ENDFOR
 EXECUTE aps_get_event_codes
 SET reply->case_event_cd = event->qual[1].event_cd
 SET reply->event_cd = event->qual[2].event_cd
 FOR (x = 1 TO size(reply->section_qual,5))
   SET reply->section_qual[x].event_cd = event->qual[(x+ 2)].event_cd
 ENDFOR
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  IF (section_cnt != 5)
   SET stat = alter(reply->section_qual,section_cnt)
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->section_qual,1)
 ENDIF
END GO
