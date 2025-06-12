CREATE PROGRAM cv_get_historical_worklist_hx:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF (validate(proc_stat_ordered)=0)
  DECLARE cs_proc_stat = i4 WITH constant(4000341), public
  DECLARE proc_stat_ordered = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"ORDERED")),
  public
  DECLARE proc_stat_scheduled = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"SCHEDULED")),
  public
  DECLARE proc_stat_arrived = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"ARRIVED")),
  public
  DECLARE proc_stat_inprocess = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"INPROCESS")),
  public
  DECLARE proc_stat_completed = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"COMPLETED")),
  public
  DECLARE proc_stat_discontinued = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,
    "DISCONTINUED")), public
  DECLARE proc_stat_cancelled = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"CANCELLED")),
  public
  DECLARE proc_stat_verified = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"VERIFIED")),
  public
  DECLARE proc_stat_unsigned = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"UNSIGNED")),
  public
  DECLARE proc_stat_signed = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"SIGNED")),
  public
  DECLARE proc_stat_edreview = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"EDREVIEW")),
  public
  DECLARE cs_step_stat = i4 WITH constant(4000440), public
  DECLARE step_stat_notstarted = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"NOTSTARTED"
    )), public
  DECLARE step_stat_inprocess = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"INPROCESS")),
  public
  DECLARE step_stat_saved = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"SAVED")), public
  DECLARE step_stat_unsigned = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"UNSIGNED")),
  public
  DECLARE step_stat_completed = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"COMPLETED")),
  public
  DECLARE step_stat_discontinued = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,
    "DISCONTINUED")), public
  DECLARE step_stat_cancelled = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"CANCELLED")),
  public
  DECLARE step_stat_edreview = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"EDREVIEW")),
  public
  DECLARE cs_edreview_stat = i4 WITH constant(4002463), public
  DECLARE edreview_stat_available = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "AVAILABLE")), public
  DECLARE edreview_stat_agreed = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,"AGREED"
    )), public
  DECLARE edreview_stat_disagreed = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "DISAGREED")), public
  DECLARE edreview_stat_acknowledged = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "ACKNOWLEDGED")), public
  DECLARE edreview_stat_removed = f8 WITH constant(null), public
 ENDIF
 DECLARE org_idx = i4 WITH noconstant(0)
 DECLARE reply_idx = i4 WITH noconstant(0)
 DECLARE eoffset_org = i2 WITH constant(80), protect
 DECLARE emethod_person = i2 WITH constant(2000), protect
 DECLARE emethod_person_org = i2 WITH constant((emethod_person+ eoffset_org)), protect
 DECLARE emethod_proc = i2 WITH constant(1000), protect
 DECLARE req_organization_cnt = i4 WITH protect
 DECLARE method_flag = i2 WITH protect
 DECLARE proc_hx_size = i4 WITH noconstant(0)
 DECLARE setmodality(null) = null
 RECORD reply(
   1 cv_historical_procs[*]
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
     2 activity_subtype_mean = vc
     2 birth_dt_tm = dq8
     2 completed_dt_tm = dq8
     2 completed_location_cd = f8
     2 completed_location_disp = vc
     2 completed_tz = i4
     2 contributor_system_cd = f8
     2 contributor_system_disp = vc
     2 cv_proc_hx_id = f8
     2 created_study_uid = c64
     2 device_name = c25
     2 encntr_id = f8
     2 encntr_mrn = vc
     2 encounter_type_cd = f8
     2 encounter_type_disp = vc
     2 encounter_type_mean = c12
     2 encntr_mrn_raw = vc
     2 encntr_finnbr = vc
     2 frgn_sys_accession_reference = vc
     2 frgn_sys_order_reference = vc
     2 study_uid = vc
     2 group_event_id = f8
     2 ip_address = vc
     2 order_catalog_cd = f8
     2 order_catalog_disp = vc
     2 order_id = f8
     2 person_id = f8
     2 person_name_first = vc
     2 person_name_last = vc
     2 person_name_middle = vc
     2 reference_txt = vc
     2 station_name = vc
     2 status_cd = f8
     2 status_disp = vc
     2 status_mean = c12
     2 sex_cd = f8
     2 sex_disp = vc
     2 sex_mean = c12
     2 study_state_cd = f8
     2 study_state_disp = vc
     2 study_state_mean = c12
     2 event_cd = f8
     2 event_disp = vc
     2 event_mean = c12
     2 modality = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 IF (validate(request->organization)=1)
  SET req_organization_cnt = size(request->organization,5)
 ENDIF
 IF ((request->person_id > 0.0))
  SET method_flag = emethod_person
 ENDIF
 IF (req_organization_cnt > 0)
  SET method_flag += eoffset_org
 ENDIF
 IF ((request->proc_hx_id > 0.0))
  SET method_flag = emethod_proc
 ENDIF
 SELECT
  IF (method_flag=emethod_person_org)
   FROM cv_proc_hx c,
    encounter e
   PLAN (c
    WHERE (c.person_id=request->person_id))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id
     AND expand(org_idx,1,req_organization_cnt,e.organization_id,request->organization[org_idx].
     organization_id))
  ELSEIF (method_flag=emethod_person)
   FROM cv_proc_hx c,
    encounter e
   PLAN (c
    WHERE (c.person_id=request->person_id))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
  ELSEIF (method_flag=emethod_proc)
   FROM cv_proc_hx c,
    encounter e
   PLAN (c
    WHERE (c.cv_proc_hx_id=request->proc_hx_id))
    JOIN (e
    WHERE e.encntr_id=c.encntr_id)
  ELSE
  ENDIF
  INTO "nl:"
  c_activity_subtype_disp = uar_get_code_display(c.activity_subtype_cd), c_activity_subtype_mean =
  uar_get_code_meaning(c.activity_subtype_cd), c_completed_location_disp = uar_get_code_display(c
   .completed_location_cd),
  c_contributor_system_disp = uar_get_code_display(c.contributor_system_cd), c_encntr_type_disp =
  uar_get_code_display(e.encntr_type_cd), c_encntr_type_mean = uar_get_code_meaning(e.encntr_type_cd),
  c_order_catalog_disp = uar_get_code_display(c.order_catalog_cd), c_event_disp =
  uar_get_code_display(c.event_cd), c_event_mean = uar_get_code_meaning(c.event_cd)
  HEAD REPORT
   stat = alterlist(reply->cv_historical_procs,10), reply_idx = 0
  DETAIL
   reply_idx += 1
   IF (mod(reply_idx,10)=1
    AND reply_idx > 10)
    stat = alterlist(reply->cv_historical_procs,(reply_idx+ 9))
   ENDIF
   reply->cv_historical_procs[reply_idx].activity_subtype_cd = c.activity_subtype_cd, reply->
   cv_historical_procs[reply_idx].activity_subtype_disp = c_activity_subtype_disp, reply->
   cv_historical_procs[reply_idx].activity_subtype_mean = c_activity_subtype_mean,
   reply->cv_historical_procs[reply_idx].completed_location_cd = c.completed_location_cd, reply->
   cv_historical_procs[reply_idx].completed_location_disp = c_completed_location_disp, reply->
   cv_historical_procs[reply_idx].contributor_system_cd = c.contributor_system_cd,
   reply->cv_historical_procs[reply_idx].contributor_system_disp = c_contributor_system_disp, reply->
   cv_historical_procs[reply_idx].cv_proc_hx_id = c.cv_proc_hx_id, reply->cv_historical_procs[
   reply_idx].encntr_id = c.encntr_id,
   reply->cv_historical_procs[reply_idx].frgn_sys_accession_reference = c
   .frgn_sys_accession_reference, reply->cv_historical_procs[reply_idx].frgn_sys_order_reference = c
   .frgn_sys_order_reference, reply->cv_historical_procs[reply_idx].group_event_id = c.event_id,
   reply->cv_historical_procs[reply_idx].order_catalog_cd = c.order_catalog_cd, reply->
   cv_historical_procs[reply_idx].order_catalog_disp = c_order_catalog_disp, reply->
   cv_historical_procs[reply_idx].order_id = c.order_id,
   reply->cv_historical_procs[reply_idx].person_id = c.person_id, reply->cv_historical_procs[
   reply_idx].reference_txt = c.reference_txt, reply->cv_historical_procs[reply_idx].
   encounter_type_cd = e.encntr_type_cd,
   reply->cv_historical_procs[reply_idx].encounter_type_disp = c_encntr_type_disp, reply->
   cv_historical_procs[reply_idx].encounter_type_mean = c_encntr_type_mean, reply->
   cv_historical_procs[reply_idx].event_cd = c.event_cd,
   reply->cv_historical_procs[reply_idx].event_disp = c_event_disp, reply->cv_historical_procs[
   reply_idx].event_mean = c_event_mean
  FOOT REPORT
   stat = alterlist(reply->cv_historical_procs,reply_idx)
  WITH nocounter
 ;end select
 SET proc_hx_size = size(reply->cv_historical_procs,5)
 FOR (i = 1 TO proc_hx_size)
   CALL setmodality(i)
 ENDFOR
 SUBROUTINE setmodality(indx)
   SELECT
    ise.modality
    FROM im_study_parent_r imspr,
     im_study ims,
     im_acquired_study ia,
     im_mpps im,
     im_series ise
    PLAN (imspr
     WHERE (imspr.parent_entity_id=reply->cv_historical_procs[indx].cv_proc_hx_id))
     JOIN (ims
     WHERE ims.im_study_id=imspr.im_study_id)
     JOIN (ia
     WHERE ia.matched_study_id=ims.im_study_id)
     JOIN (im
     WHERE im.parent_entity_id=ia.im_acquired_study_id)
     JOIN (ise
     WHERE ise.im_mpps_id=im.im_mpps_id)
    DETAIL
     reply->cv_historical_procs[i].modality = ise.modality
    WITH nocounter
   ;end select
 END ;Subroutine
 IF (proc_hx_size > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FREE RECORD uid_rep
 RECORD uid_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE cv_get_study_uid_hx  WITH replace("REPLY","UID_REP"), replace("REQUEST","REPLY")
 IF ((uid_rep->status_data.status != "S"))
  CALL cv_log_msg(cv_error,build("cv_get_study_uid_hx exited with status=",uid_rep->status_data.
    status))
 ENDIF
 EXECUTE cv_fetch_demog_hx  WITH replace("REQUEST","REPLY")
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_FETCH_DEMOG_HX failed")
 ENDIF
#exit_script
 FREE RECORD uid_rep
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"cv_get_historical_worklist returned status = 'Z'")
 ELSEIF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"cv_get_historical_worklist failed")
 ENDIF
 CALL cv_log_msg_post("MOD 001 04/30/22 AS043139")
END GO
