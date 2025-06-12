CREATE PROGRAM cv_upd_order_event:dba
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
 IF (validate(reply) != 1)
  RECORD reply(
    1 event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Incoming reply not correct format for script")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 FREE RECORD clin_event_rep
 RECORD clin_event_rep(
   1 sb
     2 severitycd = i4
     2 statuscd = i4
     2 statustext = vc
     2 substatuslist[*]
       3 substatuscd = i4
   1 rb_list[*]
     2 event_id = f8
     2 valid_from_dt_tm = dq8
     2 event_cd = f8
     2 result_status_cd = f8
     2 contributor_system_cd = f8
     2 reference_nbr = vc
     2 collating_seq = vc
     2 parent_event_id = f8
     2 prsnl_list[*]
       3 event_prsnl_id = f8
       3 action_prsnl_id = f8
       3 action_type_cd = f8
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_tz = i4
       3 updt_cnt = i4
     2 clinical_event_id = f8
     2 updt_cnt = i4
     2 result_set_link_list[*]
       3 result_set_id = f8
       3 entry_type_cd = f8
       3 updt_cnt = i4
 )
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE enddate = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100"))
 DECLARE proc_class_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PROCEDURE"))
 DECLARE doc_class_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE root_rltn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE child_rltn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",24,"CHILD"))
 DECLARE rec_stat_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE powerchart_sys_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"POWERCHART"))
 DECLARE entry_mode_cardiology = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,
   "CARDIOLOGY"))
 DECLARE res_stat_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE res_stat_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"
   ))
 DECLARE res_stat_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE res_stat_inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE res_stat_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE res_stat_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE inquire_sec_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",87,"ROUTCLINICAL"))
 DECLARE str_fmt_alpha_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14113,"ALPHA"))
 DECLARE reqid = i4 WITH protect, constant(1000012)
 DECLARE taskid = i4 WITH protect, constant(1000012)
 DECLARE appid = i4 WITH protect, constant(1000012)
 DECLARE proc_status_meaning_ordered = vc WITH protect, constant("ORDERED")
 DECLARE proc_status_meaning_scheduled = vc WITH protect, constant("SCHEDULED")
 DECLARE proc_status_meaning_arrived = vc WITH protect, constant("ARRIVED")
 DECLARE proc_status_meaning_inprocess = vc WITH protect, constant("INPROCESS")
 DECLARE proc_status_meaning_completed = vc WITH protect, constant("COMPLETED")
 DECLARE proc_status_meaning_unsigned = vc WITH protect, constant("UNSIGNED")
 DECLARE proc_status_meaning_signed = vc WITH protect, constant("SIGNED")
 DECLARE proc_status_meaning_verified = vc WITH protect, constant("VERIFIED")
 DECLARE proc_status_meaning_discontinued = vc WITH protect, constant("DISCONTINUED")
 DECLARE proc_status_meaning_cancelled = vc WITH protect, constant("CANCELLED")
 DECLARE perform_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE verify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"VERIFY"))
 DECLARE sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ORDER"))
 DECLARE modify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"MODIFY"))
 DECLARE cv_action_comments1 = vc WITH protect, constant("Modified after Signed")
 DECLARE cv_action_status_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",103,
   "COMPLETED"))
 DECLARE cv_action_status_requested = f8 WITH protect, constant(uar_get_code_by("MEANING",103,
   "REQUESTED"))
 DECLARE cv_action_status_inerror = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"INERROR"
   ))
 DECLARE ensure_type_update = i2 WITH protect, constant(2)
 DECLARE ecg_cd = f8 WITH constant(uar_get_code_by("MEANING",5801,"ECG")), protect
 DECLARE study_state_not_matched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"N"))
 DECLARE doc_type_cd_dicom_pdf = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,
   "DICOMPDF"))
 DECLARE reviewed_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4390006,"REVIEWED")
  )
 DECLARE happ = i4 WITH noconstant(0), protect
 DECLARE htask = i4 WITH noconstant(0), protect
 DECLARE hreq = i4 WITH noconstant(0), protect
 DECLARE hcereqstruct = i4 WITH noconstant(0), protect
 DECLARE hreqclinevent = i4 WITH noconstant(0), protect
 DECLARE hrepstruct = i4 WITH noconstant(0), protect
 DECLARE hreqstringresult = i4 WITH noconstant(0), protect
 DECLARE hstatus = i4 WITH noconstant(0), protect
 DECLARE iret = i4 WITH noconstant(0), protect
 DECLARE hsb = i4 WITH noconstant(0), protect
 DECLARE hstatuslist = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE hcetype = i4 WITH noconstant(0), protect
 DECLARE hcestruct = i4 WITH noconstant(0), protect
 DECLARE hce = i4 WITH noconstant(0), protect
 DECLARE srvstat = i4 WITH noconstant(0), protect
 DECLARE idx2 = i4 WITH noconstant(0), protect
 DECLARE rblistcnt = i4 WITH noconstant(0), protect
 DECLARE hrblist = i4 WITH noconstant(0), protect
 DECLARE hreslist = i4 WITH noconstant(0), protect
 DECLARE hprsnllist = i4 WITH noconstant(0), protect
 DECLARE prsnllistcnt = i4 WITH noconstant(0), protect
 DECLARE ressetlinklistcnt = i4 WITH noconstant(0), protect
 DECLARE substatuslistcnt = i4 WITH noconstant(0), protect
 DECLARE dresultstatuscd = f8 WITH noconstant(0.0), protect
 DECLARE seventtag = vc WITH protect
 DECLARE sreferencenbr = vc WITH protect
 DECLARE saccessionnbr = vc WITH protect
 DECLARE sresultval = vc WITH protect
 DECLARE sprocstatus = vc WITH protect
 IF (str_fmt_alpha_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ALPHA;CODE_SET=14113")
  GO TO exit_script
 ENDIF
 IF (powerchart_sys_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=POWERCHART;CODE_SET=89")
  GO TO exit_script
 ENDIF
 IF (proc_class_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=PROCEDURE;CODE_SET=53")
  GO TO exit_script
 ENDIF
 IF (doc_class_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=DOC;CODE_SET=53")
  GO TO exit_script
 ENDIF
 IF (root_rltn_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ROOT;CODE_SET=24")
  GO TO exit_script
 ENDIF
 IF (child_rltn_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=CHILD;CODE_SET=24")
  GO TO exit_script
 ENDIF
 IF (rec_stat_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ACTIVE;CODE_SET=48")
  GO TO exit_script
 ENDIF
 IF (res_stat_auth_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=AUTH;CODE_SET=8")
  GO TO exit_script
 ENDIF
 IF (inquire_sec_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ROUTCLINICAL;CODE_SET=87")
  GO TO exit_script
 ENDIF
 IF (res_stat_altered_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ALTERED;CODE_SET=53")
  GO TO exit_script
 ENDIF
 IF (perform_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ROUTCLINICAL;CODE_SET=21")
  GO TO exit_script
 ENDIF
 IF (sign_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ROUTCLINICAL;CODE_SET=21")
  GO TO exit_script
 ENDIF
 IF (verify_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ROUTCLINICAL;CODE_SET=21")
  GO TO exit_script
 ENDIF
 IF (order_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ROUTCLINICAL;CODE_SET=21")
  GO TO exit_script
 ENDIF
 IF (cv_action_status_completed <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ROUTCLINICAL;CODE_SET=103")
  GO TO exit_script
 ENDIF
 IF (cv_action_status_inerror <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=ROUTCLINICAL;CODE_SET=103")
  GO TO exit_script
 ENDIF
 SET sprocstatus = uar_get_code_meaning(request->proc_status_cd)
 SET dresultstatuscd = getresultstatuscdforprocstatus(sprocstatus,request->event_id)
 IF ((request->action_tz=0))
  SET request->action_tz = curtimezoneapp
 ENDIF
 IF ((request->order_action_tz=0))
  SET request->order_action_tz = curtimezoneapp
 ENDIF
 SET seventtag = uar_get_code_display(request->proc_status_cd)
 SET iret = execceservercall(0)
 IF (iret != 0)
  CALL cv_log_stat(cv_error,"CALL","F","EXECCESERVERCALL",cnvtstring(iret))
  GO TO exit_script
 ENDIF
 SUBROUTINE (setparentrow(hreqstruct=i4) =i4)
   IF (validate(request->event_cd,0.0) <= 0.0)
    CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","EVENT_CD=0.0")
    RETURN(- (1))
   ENDIF
   IF (validate(request->catalog_cd,0.0) <= 0.0)
    CALL cv_log_msg(cv_info,"No catalog_cd defined")
   ENDIF
   IF (validate(request->order_id,0.0) <= 0.0)
    CALL cv_log_msg(cv_info,"No order_id defined")
   ENDIF
   IF (validate(request->accession_nbr) != 1)
    CALL cv_log_msg(cv_info,"No accession_nbr defined")
   ELSE
    SET saccessionnbr = request->accession_nbr
   ENDIF
   IF (validate(request->encntr_id,0.0) <= 0.0)
    CALL cv_log_msg(cv_info,"No encntr_id defined")
   ENDIF
   IF (validate(request->person_id,0.0) <= 0.0)
    CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","PERSON_ID=0.0")
    RETURN(- (1))
   ENDIF
   IF (validate(request->result_val) != 1)
    CALL cv_log_msg(cv_info,"No result_val defined")
   ELSE
    SET sresultval = request->result_val
   ENDIF
   IF (validate(request->event_end_dt_tm,0.0) <= 0.0)
    CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","EVENT_END_DT_TM=0.0")
    RETURN(- (1))
   ENDIF
   IF (validate(request->event_start_dt_tm,0.0) <= 0.0)
    CALL cv_log_msg(cv_info,"No event_start_dt_tm defined")
   ENDIF
   IF (validate(request->reference_nbr) != 1)
    CALL cv_log_msg(cv_info,"No reference_nbr defined")
   ELSE
    SET sreferencenbr = request->reference_nbr
   ENDIF
   IF (validate(request->event_id,0.0)=0.0)
    CALL cv_log_msg(cv_info,"No event_id definied. New clinical event.")
   ENDIF
   SET iret = uar_srvsetshort(hreqstruct,"ensure_type",ensure_type_update)
   CALL cv_log_msg(cv_info,build2("Ensure_type - SetShort(",ensure_type_update,"): ",iret))
   SET hreqclinevent = uar_srvgetstruct(hreqstruct,"clin_event")
   IF (hreqclinevent=0)
    CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hreqclinevent))
    RETURN(- (1))
   ENDIF
   CALL cv_log_msg(cv_debug,build2("Fill ParentRow properties for parent_event_id ->",request->
     event_id))
   SET iret = uar_srvsetdouble(hreqclinevent,"event_id",request->event_id)
   CALL cv_log_msg(cv_info,build2("event_id - SetDouble(",request->event_id,"): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"authentic_flag_ind",0)
   CALL cv_log_msg(cv_info,build2("authentic_flag_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"authentic_flag",1)
   CALL cv_log_msg(cv_info,build2("authentic_flag - SetShort(1): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"event_start_dt_tm_ind",0)
   CALL cv_log_msg(cv_info,build2("event_start_dt_tm_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"event_end_dt_tm_ind",0)
   CALL cv_log_msg(cv_info,build2("event_end_dt_tm_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"publish_flag_ind",0)
   CALL cv_log_msg(cv_info,build2("publish_flag_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"publish_flag",1)
   CALL cv_log_msg(cv_info,build2("publish_flag - SetShort(1): ",iret))
   SET iret = uar_srvsetlong(hreqclinevent,"subtable_bit_map",0)
   CALL cv_log_msg(cv_info,build2("subtable_bit_map - SetLong(0): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"subtable_bit_map_ind",0)
   CALL cv_log_msg(cv_info,build2("subtable_bit_map_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"valid_from_dt_tm_ind",0)
   CALL cv_log_msg(cv_info,build2("valid_from_dt_tm_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetdate(hreqclinevent,"valid_from_dt_tm",cnvtdatetime(now))
   CALL cv_log_msg(cv_info,build2("valid_from_dt_tm - SetDate(cnvtdatetime(NOW)): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"valid_until_dt_tm_ind",0)
   CALL cv_log_msg(cv_info,build2("valid_until_dt_tm_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetdate(hreqclinevent,"valid_until_dt_tm",cnvtdatetime(enddate))
   CALL cv_log_msg(cv_info,build2("valid_until_dt_tm - SetDate(",cnvtdatetime(enddate),"): ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"view_level_ind",0)
   CALL cv_log_msg(cv_info,build2("view_level_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetlong(hreqclinevent,"view_level",1)
   CALL cv_log_msg(cv_info,build2("view_level - SetLong(1): ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"contributor_system_cd",powerchart_sys_cd)
   CALL cv_log_msg(cv_info,build2("contributor_system_cd - SetDouble(",powerchart_sys_cd,"): ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"event_class_cd",proc_class_cd)
   CALL cv_log_msg(cv_info,build2("event_class_cd - SetDouble(",proc_class_cd,"): ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"event_reltn_cd",root_rltn_cd)
   CALL cv_log_msg(cv_info,build2("event_reltn_cd - SetDouble(",root_rltn_cd,"): ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"record_status_cd",rec_stat_cd)
   CALL cv_log_msg(cv_info,build2("record_status_cd - SetDouble(",rec_stat_cd,"): ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"result_status_cd",dresultstatuscd)
   CALL cv_log_msg(cv_info,build2("result_status_cd - SetDouble(",dresultstatuscd,"): ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"event_cd",request->event_cd)
   CALL cv_log_msg(cv_info,build2("event_cd - SetDouble(",request->event_cd,": ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"catalog_cd",request->catalog_cd)
   CALL cv_log_msg(cv_info,build2("catalog_cd - SetDouble(",request->catalog_cd,": ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"order_id",request->order_id)
   CALL cv_log_msg(cv_info,build2("order_id - SetDouble(",request->order_id,": ",iret))
   SET iret = uar_srvsetstring(hreqclinevent,"accession_nbr",nullterm(saccessionnbr))
   CALL cv_log_msg(cv_info,build2("accession_nbr - SetString(",nullterm(saccessionnbr),": ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"encntr_id",request->encntr_id)
   CALL cv_log_msg(cv_info,build2("encntr_id - SetDouble(",request->encntr_id,": ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"person_id",request->person_id)
   CALL cv_log_msg(cv_info,build2("person_id - SetDouble(",request->person_id,": ",iret))
   SET iret = uar_srvsetstring(hreqclinevent,"event_tag",nullterm(seventtag))
   CALL cv_log_msg(cv_info,build2("event_tag - SetString(",nullterm(seventtag),": ",iret))
   SET iret = uar_srvsetshort(hreqclinevent,"event_tag_set_flag",1)
   CALL cv_log_msg(cv_info,build2("event_tag_set_flag - SetShort(1): ",iret))
   SET iret = uar_srvsetdate(hreqclinevent,"event_end_dt_tm",cnvtdatetime(request->event_end_dt_tm))
   CALL cv_log_msg(cv_info,build2("event_end_dt_tm - SetDate(",cnvtdatetime(request->event_end_dt_tm),
     "): ",iret))
   SET iret = uar_srvsetdate(hreqclinevent,"event_start_dt_tm",cnvtdatetime(request->
     event_start_dt_tm))
   CALL cv_log_msg(cv_info,build2("event_start_dt_tm - SetDate(",cnvtdatetime(request->
      event_start_dt_tm),": ",iret))
   SET iret = uar_srvsetstring(hreqclinevent,"reference_nbr",nullterm(sreferencenbr))
   CALL cv_log_msg(cv_info,build2("reference_nbr - SetString(",sreferencenbr,"): ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"inquire_security_cd",inquire_sec_cd)
   CALL cv_log_msg(cv_info,build2("inquire_security_cd - SetDouble(",inquire_sec_cd,"): ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"normalcy_cd",request->proc_normalcy_cd)
   CALL cv_log_msg(cv_info,build2("normalcy_cd - SetDouble(",request->proc_normalcy_cd,": ",iret))
   SET iret = uar_srvsetdouble(hreqclinevent,"entry_mode_cd",entry_mode_cardiology)
   CALL cv_log_msg(cv_info,build2("entry_mode_cd - SetDouble(",entry_mode_cardiology,": ",iret))
   IF ((request->proc_status_cd=proc_stat_completed)
    AND dresultstatuscd=res_stat_inprogress_cd)
    SET hperformprsnlevent = uar_srvadditem(hreqclinevent,"event_prsnl_list")
    IF (hperformprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hperformprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hperformprsnlevent,"action_type_cd",perform_cd)
    SET iret = uar_srvsetdate(hperformprsnlevent,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hperformprsnlevent,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hperformprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hperformprsnlevent,"action_status_cd",cv_action_status_completed)
    SET iret = uar_srvsetlong(hperformprsnlevent,"action_tz",request->order_action_tz)
   ENDIF
   IF ((((request->proc_status_cd=proc_stat_signed)) OR ((request->proc_status_cd=proc_stat_signed)
    AND dresultstatuscd=res_stat_modified_cd)) )
    SET hsignprsnlevent = uar_srvadditem(hreqclinevent,"event_prsnl_list")
    IF (hsignprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hsignprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hsignprsnlevent,"action_type_cd",sign_cd)
    SET iret = uar_srvsetdate(hsignprsnlevent,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hsignprsnlevent,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hsignprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hsignprsnlevent,"action_status_cd",cv_action_status_completed)
    SET iret = uar_srvsetlong(hsignprsnlevent,"action_tz",request->action_tz)
   ENDIF
   IF ((request->proc_status_cd=proc_stat_signed)
    AND dresultstatuscd=res_stat_auth_cd)
    SET hverifyprsnlevent = uar_srvadditem(hreqclinevent,"event_prsnl_list")
    IF (hverifyprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hverifyprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hverifyprsnlevent,"action_type_cd",verify_cd)
    SET iret = uar_srvsetdate(hverifyprsnlevent,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hverifyprsnlevent,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hverifyprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hverifyprsnlevent,"action_status_cd",cv_action_status_completed)
    SET iret = uar_srvsetlong(hverifyprsnlevent,"action_tz",request->action_tz)
   ENDIF
   IF ((((request->proc_status_cd=proc_stat_signed)
    AND dresultstatuscd=res_stat_auth_cd) OR ((request->proc_status_cd=proc_stat_signed)
    AND dresultstatuscd=res_stat_inprogress_cd
    AND (request->doc_type_cd=doc_type_cd_dicom_pdf))) )
    SET horderprsnlevent = uar_srvadditem(hreqclinevent,"event_prsnl_list")
    IF (horderprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(horderprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(horderprsnlevent,"action_type_cd",order_cd)
    SET iret = uar_srvsetdate(horderprsnlevent,"action_dt_tm",cnvtdatetime(request->ordered_dt_tm))
    SET iret = uar_srvsetdouble(horderprsnlevent,"action_prsnl_id",request->order_prsnl_id)
    SET iret = uar_srvsetshort(horderprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(horderprsnlevent,"action_status_cd",cv_action_status_completed)
    SET iret = uar_srvsetlong(horderprsnlevent,"action_tz",request->action_tz)
   ENDIF
   IF ((request->proc_status_cd=proc_stat_signed)
    AND dresultstatuscd=res_stat_modified_cd)
    SET hamendprsnlevent = uar_srvadditem(hreqclinevent,"event_prsnl_list")
    IF (hamendprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hamendprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hamendprsnlevent,"action_type_cd",modify_cd)
    SET iret = uar_srvsetdate(hamendprsnlevent,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hamendprsnlevent,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hamendprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hamendprsnlevent,"action_status_cd",cv_action_status_completed)
    SET iret = uar_srvsetlong(hamendprsnlevent,"action_tz",request->action_tz)
   ENDIF
   IF ((request->proc_status_cd=proc_stat_completed)
    AND dresultstatuscd=res_stat_modified_cd)
    SET hsignerrprsnlevent_undo = uar_srvadditem(hreqclinevent,"event_prsnl_list")
    IF (hsignerrprsnlevent_undo=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hsignerrprsnlevent_undo))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hsignerrprsnlevent_undo,"action_type_cd",sign_cd)
    SET iret = uar_srvsetdate(hsignerrprsnlevent_undo,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hsignerrprsnlevent_undo,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hsignerrprsnlevent_undo,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hsignerrprsnlevent_undo,"action_status_cd",cv_action_status_inerror)
    SET iret = uar_srvsetlong(hsignerrprsnlevent_undo,"action_tz",request->action_tz)
   ENDIF
   IF ((request->proc_status_cd=proc_stat_ordered)
    AND dresultstatuscd=res_stat_modified_cd)
    SET hsignerrprsnlevent_unmatch = uar_srvadditem(hreqclinevent,"event_prsnl_list")
    IF (hsignerrprsnlevent_unmatch=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hsignerrprsnlevent_unmatch))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hsignerrprsnlevent_unmatch,"action_type_cd",sign_cd)
    SET iret = uar_srvsetdate(hsignerrprsnlevent_unmatch,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hsignerrprsnlevent_unmatch,"action_prsnl_id",request->
     verified_prsnl_id)
    SET iret = uar_srvsetshort(hsignerrprsnlevent_unmatch,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hsignerrprsnlevent_unmatch,"action_status_cd",
     cv_action_status_inerror)
    SET iret = uar_srvsetlong(hsignerrprsnlevent_unmatch,"action_tz",request->action_tz)
    SET hperformerrprsnlevent = uar_srvadditem(hreqclinevent,"event_prsnl_list")
    IF (hperformerrprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hperformerrprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hperformerrprsnlevent,"action_type_cd",perform_cd)
    SET iret = uar_srvsetdate(hperformerrprsnlevent,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hperformerrprsnlevent,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hperformerrprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hperformerrprsnlevent,"action_status_cd",cv_action_status_inerror)
    SET iret = uar_srvsetstring(hperformerrprsnlevent,"action_comment",nullterm(cv_action_comments1))
    SET iret = uar_srvsetlong(hperformerrprsnlevent,"action_tz",request->order_action_tz)
   ENDIF
   SET hreqstringresult = uar_srvadditem(hreqclinevent,"string_result")
   IF (hreqstringresult=0)
    CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVADDITEM",cnvtstring(hreqstringresult))
    RETURN(- (1))
   ENDIF
   SET iret = uar_srvsetdouble(hreqstringresult,"string_result_format_cd",str_fmt_alpha_cd)
   CALL cv_log_msg(cv_info,build2("string_result_format_cd - SetDouble(",str_fmt_alpha_cd,": ",iret))
   SET iret = uar_srvsetstring(hreqstringresult,"string_result_text",nullterm(seventtag))
   CALL cv_log_msg(cv_info,build2("string_result_text - SetString(",nullterm(seventtag),"): ",iret))
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (setchildrow(hreqstruct=i4) =i4)
   CALL cv_log_msg(cv_debug,build2("Entering SetChildRow with event_id ->",ce.event_id))
   SET hcetype = uar_srvcreatetypefrom(hreqstruct,"clin_event")
   CALL cv_log_msg(cv_debug,build("hCEType:",hcetype))
   SET hcestruct = uar_srvgetstruct(hreqstruct,"clin_event")
   CALL cv_log_msg(cv_debug,build("hCEStruct:",hcestruct))
   SET stat = uar_srvbinditemtype(hcestruct,"child_event_list",hcetype)
   SET hce = uar_srvadditem(hcestruct,"child_event_list")
   CALL cv_log_msg(cv_debug,build("hCE:",hce))
   IF (hce <= 0)
    CALL cv_log_stat(cv_error,"SETCHILDROW","F","UAR_SRVADDITEM","hCE=0")
    RETURN(- (1))
   ENDIF
   IF (hcetype)
    CALL uar_srvdestroytype(hcetype)
    SET hcetype = 0
   ENDIF
   SET iret = uar_srvsetdouble(hce,"event_id",ce.event_id)
   CALL cv_log_msg(cv_info,build2("event_id - SetDouble(",ce.event_id,"): ",iret))
   SET iret = uar_srvsetshort(hce,"authentic_flag_ind",0)
   CALL cv_log_msg(cv_info,build2("authentic_flag_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hce,"authentic_flag",ce.authentic_flag)
   CALL cv_log_msg(cv_info,build2("authentic_flag - SetShort(",ce.authentic_flag,"): ",iret))
   SET iret = uar_srvsetshort(hce,"event_start_dt_tm_ind",0)
   CALL cv_log_msg(cv_info,build2("event_start_dt_tm_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hce,"event_end_dt_tm_ind",0)
   CALL cv_log_msg(cv_info,build2("event_end_dt_tm_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hce,"publish_flag_ind",0)
   CALL cv_log_msg(cv_info,build2("publish_flag_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hce,"publish_flag",ce.publish_flag)
   CALL cv_log_msg(cv_info,build2("publish_flag - SetShort(",ce.publish_flag,"): ",iret))
   SET iret = uar_srvsetlong(hce,"subtable_bit_map",ce.subtable_bit_map)
   CALL cv_log_msg(cv_info,build2("subtable_bit_map - SetLong(",ce.subtable_bit_map,"): ",iret))
   SET iret = uar_srvsetshort(hce,"subtable_bit_map_ind",0)
   CALL cv_log_msg(cv_info,build2("subtable_bit_map_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetshort(hce,"valid_from_dt_tm_ind",0)
   CALL cv_log_msg(cv_info,build2("valid_from_dt_tm_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetdate(hce,"valid_from_dt_tm",cnvtdatetime(now))
   CALL cv_log_msg(cv_info,build2("valid_from_dt_tm - SetDate(cnvtdatetime(NOW)): ",iret))
   SET iret = uar_srvsetshort(hce,"valid_until_dt_tm_ind",0)
   CALL cv_log_msg(cv_info,build2("valid_until_dt_tm_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetdate(hce,"valid_until_dt_tm",cnvtdatetime(enddate))
   CALL cv_log_msg(cv_info,build2("valid_until_dt_tm - SetDate(",cnvtdatetime(enddate),"): ",iret))
   SET iret = uar_srvsetshort(hce,"view_level_ind",0)
   CALL cv_log_msg(cv_info,build2("view_level_ind - SetShort(0): ",iret))
   SET iret = uar_srvsetlong(hce,"view_level",ce.view_level)
   CALL cv_log_msg(cv_info,build2("view_level - SetLong(",ce.view_level,"): ",iret))
   SET iret = uar_srvsetdouble(hce,"contributor_system_cd",ce.contributor_system_cd)
   CALL cv_log_msg(cv_info,build2("contributor_system_cd - SetDouble(",ce.contributor_system_cd,"): ",
     iret))
   SET iret = uar_srvsetdouble(hce,"event_class_cd",ce.event_class_cd)
   CALL cv_log_msg(cv_info,build2("event_class_cd - SetDouble(",ce.event_class_cd,"): ",iret))
   SET iret = uar_srvsetdouble(hce,"event_reltn_cd",ce.event_reltn_cd)
   CALL cv_log_msg(cv_info,build2("event_reltn_cd - SetDouble(",ce.event_reltn_cd,"): ",iret))
   SET iret = uar_srvsetdouble(hce,"record_status_cd",ce.record_status_cd)
   CALL cv_log_msg(cv_info,build2("record_status_cd - SetDouble(",ce.record_status_cd,"): ",iret))
   SET iret = uar_srvsetdouble(hce,"result_status_cd",dresultstatuscd)
   CALL cv_log_msg(cv_info,build2("result_status_cd - SetDouble(",dresultstatuscd,"): ",iret))
   SET iret = uar_srvsetdouble(hce,"event_cd",ce.event_cd)
   CALL cv_log_msg(cv_info,build2("event_cd - SetDouble(",ce.event_cd,": ",iret))
   SET iret = uar_srvsetdouble(hce,"catalog_cd",ce.catalog_cd)
   CALL cv_log_msg(cv_info,build2("catalog_cd - SetDouble(",ce.catalog_cd,": ",iret))
   SET iret = uar_srvsetdouble(hce,"order_id",ce.order_id)
   CALL cv_log_msg(cv_info,build2("order_id - SetDouble(",ce.order_id,": ",iret))
   SET iret = uar_srvsetstring(hce,"accession_nbr",nullterm(ce.accession_nbr))
   CALL cv_log_msg(cv_info,build2("accession_nbr - SetString(",nullterm(ce.accession_nbr),": ",iret))
   SET iret = uar_srvsetdouble(hce,"encntr_id",ce.encntr_id)
   CALL cv_log_msg(cv_info,build2("encntr_id - SetDouble(",ce.encntr_id,": ",iret))
   SET iret = uar_srvsetdouble(hce,"person_id",ce.person_id)
   CALL cv_log_msg(cv_info,build2("person_id - SetDouble(",ce.person_id,": ",iret))
   SET iret = uar_srvsetstring(hce,"event_tag",nullterm(seventtag))
   CALL cv_log_msg(cv_info,build2("event_tag - SetString(",nullterm(seventtag),": ",iret))
   SET iret = uar_srvsetshort(hce,"event_tag_set_flag",1)
   CALL cv_log_msg(cv_info,build2("event_tag_set_flag - SetShort(1): ",iret))
   SET iret = uar_srvsetdate(hce,"event_end_dt_tm",cnvtdatetime(request->event_end_dt_tm))
   CALL cv_log_msg(cv_info,build2("event_end_dt_tm - SetDate(",cnvtdatetime(request->event_end_dt_tm),
     "): ",iret))
   SET iret = uar_srvsetdate(hce,"event_start_dt_tm",cnvtdatetime(request->event_start_dt_tm))
   CALL cv_log_msg(cv_info,build2("event_start_dt_tm - SetDate(",cnvtdatetime(request->
      event_start_dt_tm),": ",iret))
   SET iret = uar_srvsetstring(hce,"reference_nbr",nullterm(ce.reference_nbr))
   CALL cv_log_msg(cv_info,build2("reference_nbr - SetString(",nullterm(ce.reference_nbr),"): ",iret)
    )
   SET iret = uar_srvsetdouble(hce,"inquire_security_cd",ce.inquire_security_cd)
   CALL cv_log_msg(cv_info,build2("inquire_security_cd - SetDouble(",ce.inquire_security_cd,"): ",
     iret))
   IF ((request->proc_status_cd=proc_stat_signed))
    SET hsignprsnlevent = uar_srvadditem(hce,"event_prsnl_list")
    IF (hsignprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hsignprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hsignprsnlevent,"action_type_cd",sign_cd)
    SET iret = uar_srvsetdate(hsignprsnlevent,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hsignprsnlevent,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hsignprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hsignprsnlevent,"action_status_cd",cv_action_status_completed)
    SET iret = uar_srvsetlong(hsignprsnlevent,"action_tz",request->action_tz)
   ENDIF
   IF ((request->proc_status_cd=proc_stat_signed)
    AND dresultstatuscd=res_stat_auth_cd)
    SET hverifyprsnlevent = uar_srvadditem(hce,"event_prsnl_list")
    IF (hverifyprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hverifyprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hverifyprsnlevent,"action_type_cd",verify_cd)
    SET iret = uar_srvsetdate(hverifyprsnlevent,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hverifyprsnlevent,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hverifyprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hverifyprsnlevent,"action_status_cd",cv_action_status_completed)
    SET iret = uar_srvsetlong(hverifyprsnlevent,"action_tz",request->action_tz)
   ENDIF
   IF ((request->proc_status_cd=proc_stat_signed)
    AND dresultstatuscd=res_stat_modified_cd)
    SET hamendprsnlevent = uar_srvadditem(hce,"event_prsnl_list")
    IF (hamendprsnlevent=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVGETSTRUCT",cnvtstring(hamendprsnlevent))
     RETURN(- (1))
    ENDIF
    SET iret = uar_srvsetdouble(hamendprsnlevent,"action_type_cd",modify_cd)
    SET iret = uar_srvsetdate(hamendprsnlevent,"action_dt_tm",cnvtdatetime(now))
    SET iret = uar_srvsetdouble(hamendprsnlevent,"action_prsnl_id",request->verified_prsnl_id)
    SET iret = uar_srvsetshort(hamendprsnlevent,"defeat_succn_ind",1)
    SET iret = uar_srvsetdouble(hamendprsnlevent,"action_status_cd",cv_action_status_completed)
    SET iret = uar_srvsetlong(hamendprsnlevent,"action_tz",request->action_tz)
   ENDIF
   SET hce = uar_srvadditem(hce,"string_result")
   IF (hce=0)
    CALL cv_log_stat(cv_error,"CALL","F","UAR_SRVADDITEM",cnvtstring(hce))
    RETURN(- (1))
   ENDIF
   SET iret = uar_srvsetdouble(hce,"string_result_format_cd",str_fmt_alpha_cd)
   CALL cv_log_msg(cv_info,build2("string_result_format_cd - SetDouble(",str_fmt_alpha_cd,": ",iret))
   SET iret = uar_srvsetstring(hce,"string_result_text",nullterm(seventtag))
   CALL cv_log_msg(cv_info,build2("string_result_text - SetString(",nullterm(seventtag),"): ",iret))
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (execceservercall(dummy=i2) =i4)
   CALL cv_log_msg(cv_info,"Beginning server calls")
   SET iret = uar_crmbeginapp(appid,happ)
   IF (iret != 0)
    CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMBEGINAPP",cnvtstring(iret))
    RETURN(- (1))
   ENDIF
   CALL cv_log_msg(cv_info,build2("Success on begin app: ",happ))
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret != 0)
    CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMBEGINTASK",cnvtstring(iret))
    RETURN(- (1))
   ENDIF
   CALL cv_log_msg(cv_info,build2("Success on begin task: ",htask))
   SET iret = uar_crmbeginreq(htask,0,reqid,hreq)
   IF (iret != 0)
    CALL cv_log_msg(cv_error,"CALL","F","UAR_CRMBEGINREQ",cnvtstring(iret))
    RETURN(- (1))
   ENDIF
   CALL cv_log_msg(cv_info,build2("Success on begin req: ",hreq))
   SET hcereqstruct = uar_crmgetrequest(hreq)
   IF (hcereqstruct=0)
    CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMGETREQUEST",build2("hCEReqStruct = ",hcereqstruct))
    RETURN(- (1))
   ENDIF
   SET iret = setparentrow(hcereqstruct)
   IF (iret != 0)
    CALL cv_log_stat(cv_error,"CALL","F","SETPARENTROW",cnvtstring(iret))
    GO TO exit_script
   ENDIF
   IF (validate(request->event_id,0.0) > 0.0)
    SELECT INTO "nl:"
     FROM clinical_event ce
     WHERE (ce.parent_event_id=request->event_id)
      AND ce.valid_until_dt_tm=cnvtdatetime(enddate)
      AND ce.event_reltn_cd=child_rltn_cd
      AND ce.event_class_cd=doc_class_cd
      AND ((ce.result_status_cd != res_stat_auth_cd) OR (sprocstatus=proc_status_meaning_signed))
      AND ce.entry_mode_cd != entry_mode_cardiology
     DETAIL
      iret = setchildrow(hcereqstruct)
     WITH nocounter
    ;end select
    IF (iret != 0)
     CALL cv_log_stat(cv_error,"CALL","F","SETCHILDROW",cnvtstring(iret))
     GO TO exit_script
    ENDIF
   ENDIF
   SET iret = uar_crmperform(hreq)
   IF (iret != 0)
    CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMPERFORM",cnvtstring(iret))
    SET hrepstruct = uar_crmgetreply(hreq)
    IF (hrepstruct=0)
     CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMGETREPLY",build2("hRepStruct = ",hrepstruct))
    ELSE
     CALL getsrvreply(hrepstruct)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET hrepstruct = uar_crmgetreply(hreq)
   IF (hrepstruct=0)
    CALL cv_log_stat(cv_error,"CALL","F","UAR_CRMGETREPLY",build2("hRepStruct = ",hrepstruct))
    RETURN(- (1))
   ENDIF
   SET iret = getsrvreply(hrepstruct)
   IF (iret != 0)
    CALL cv_log_stat(cv_error,"CALL","F","GETSRVREPLY",cnvtstring(iret))
    RETURN(- (1))
   ENDIF
   IF (size(clin_event_rep->rb_list,5) > 0)
    SET reply->event_id = clin_event_rep->rb_list[1].event_id
   ENDIF
   IF ((reply->event_id <= 0.0))
    CALL cv_log_stat(cv_error,"SELECT","F","CLINICAL_EVENT","EVENT_ID=0.0")
    RETURN(- (1))
   ENDIF
   SET reply->status_data.status = "S"
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (getsrvreply(hreply=i4) =i4)
   CALL cv_log_msg(cv_info,"Getting reply from server")
   SET hsb = uar_srvgetstruct(hreply,"sb")
   SET clin_event_rep->sb.severitycd = uar_srvgetlong(hsb,"severityCd")
   SET clin_event_rep->sb.statuscd = uar_srvgetlong(hsb,"statusCd")
   SET clin_event_rep->sb.statustext = uar_srvgetstringptr(hsb,"statusText")
   SET substatuslistcnt = uar_srvgetitemcount(hsb,"subStatusList")
   SET stat = alterlist(clin_event_rep->sb.substatuslist,substatuslistcnt)
   FOR (idx = 1 TO substatuslistcnt)
    SET hstatuslist = uar_srvgetitem(hsb,"subStatusList",(idx - 1))
    SET clin_event_rep->sb.substatuslist[idx].substatuscd = uar_srvgetlong(hstatuslist,"subStatusCd")
   ENDFOR
   SET rblistcnt = uar_srvgetitemcount(hreply,"rb_list")
   SET stat = alterlist(clin_event_rep->rb_list,rblistcnt)
   FOR (idx = 1 TO rblistcnt)
     SET hrblist = uar_srvgetitem(hreply,"rb_list",(idx - 1))
     SET clin_event_rep->rb_list[idx].event_id = uar_srvgetdouble(hrblist,"event_id")
     CALL uar_srvgetdate(hrblist,"valid_from_dt_tm",clin_event_rep->rb_list[idx].valid_from_dt_tm)
     SET clin_event_rep->rb_list[idx].event_cd = uar_srvgetdouble(hrblist,"event_cd")
     SET clin_event_rep->rb_list[idx].result_status_cd = uar_srvgetdouble(hrblist,"result_status_cd")
     SET clin_event_rep->rb_list[idx].contributor_system_cd = uar_srvgetdouble(hrblist,
      "contributor_system_cd")
     SET clin_event_rep->rb_list[idx].reference_nbr = uar_srvgetstringptr(hrblist,"reference_nbr")
     SET clin_event_rep->rb_list[idx].collating_seq = uar_srvgetstringptr(hrblist,"collating_seq")
     SET clin_event_rep->rb_list[idx].parent_event_id = uar_srvgetdouble(hrblist,"parent_event_id")
     SET clin_event_rep->rb_list[idx].clinical_event_id = uar_srvgetdouble(hrblist,
      "clinical_event_id")
     SET clin_event_rep->rb_list[idx].updt_cnt = uar_srvgetlong(hrblist,"updt_cnt")
     SET prsnllistcnt = uar_srvgetitemcount(hrblist,"prsnl_list")
     SET stat = alterlist(clin_event_rep->rb_list[idx].prsnl_list,prsnllistcnt)
     FOR (idx2 = 1 TO prsnllistcnt)
       SET hprsnllist = uar_srvgetitem(hrblist,"prsnl_list",(idx2 - 1))
       SET clin_event_rep->rb_list[idx].prsnl_list[idx2].event_prsnl_id = uar_srvgetdouble(hprsnllist,
        "event_prsnl_list")
       SET clin_event_rep->rb_list[idx].prsnl_list[idx2].action_prsnl_id = uar_srvgetdouble(
        hprsnllist,"action_prsnl_id")
       SET clin_event_rep->rb_list[idx].prsnl_list[idx2].action_type_cd = uar_srvgetdouble(hprsnllist,
        "action_type_cd")
       CALL uar_srvgetdate(hprsnllist,"action_dt_tm",clin_event_rep->rb_list[idx].prsnl_list[idx2].
        action_dt_tm)
       SET clin_event_rep->rb_list[idx].prsnl_list[idx2].action_dt_tm_ind = uar_srvgetshort(
        hprsnllist,"action_dt_tm_ind")
       SET clin_event_rep->rb_list[idx].prsnl_list[idx2].action_tz = uar_srvgetlong(hprsnllist,
        "action_tz")
       SET clin_event_rep->rb_list[idx].prsnl_list[idx2].updt_cnt = uar_srvgetlong(hprsnllist,
        "updt_cnt")
     ENDFOR
     SET ressetlinklistcnt = uar_srvgetitemcount(hrblist,"result_set_link_list")
     SET stat = alterlist(clin_event_rep->rb_list[idx].result_set_link_list,ressetlinklistcnt)
     FOR (idx2 = 1 TO ressetlinklistcnt)
       SET hreslist = uar_srvgetitem(hrblist,"result_set_link_list",(idx2 - 1))
       SET clin_event_rep->rb_list[idx].result_set_link_list[idx2].result_set_id = uar_srvgetdouble(
        hreslist,"result_set_id")
       SET clin_event_rep->rb_list[idx].result_set_link_list[idx2].entry_type_cd = uar_srvgetdouble(
        hreslist,"entry_type_cd")
       SET clin_event_rep->rb_list[idx].result_set_link_list[idx2].updt_cnt = uar_srvgetlong(hreslist,
        "updt_cnt")
     ENDFOR
   ENDFOR
   CALL cv_log_msg(cv_info,"Finished getting reply")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (getresultstatuscdforprocstatus(procstatus=vc,eventid=f8) =f8)
   CALL cv_log_msg(cv_info,build2("entering getResultStatusCdForProcStatus(",procstatus,", ",eventid,
     ")"))
   DECLARE resultstatuscd = f8 WITH noconstant(0.0)
   CASE (procstatus)
    OF proc_status_meaning_ordered:
     SET resultstatuscd = res_stat_inprogress_cd
    OF proc_status_meaning_scheduled:
     SET resultstatuscd = res_stat_inprogress_cd
    OF proc_status_meaning_arrived:
     SET resultstatuscd = res_stat_inprogress_cd
    OF proc_status_meaning_inprocess:
     SET resultstatuscd = res_stat_inprogress_cd
    OF proc_status_meaning_completed:
     SET resultstatuscd = res_stat_inprogress_cd
    OF proc_status_meaning_verified:
     SET resultstatuscd = res_stat_inprogress_cd
    OF proc_status_meaning_unsigned:
     SET resultstatuscd = res_stat_inprogress_cd
    OF proc_status_meaning_signed:
     SET resultstatuscd = res_stat_auth_cd
    OF proc_status_meaning_discontinued:
     RETURN(res_stat_inerror_cd)
    OF proc_status_meaning_cancelled:
     SET resultstatuscd = res_stat_cancelled_cd
    ELSE
     RETURN(0.0)
   ENDCASE
   IF (eventid=0.0)
    RETURN(resultstatuscd)
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.event_id=eventid
     AND ce.valid_until_dt_tm=cnvtdatetime("31-dec-2100")
     AND ce.result_status_cd IN (res_stat_auth_cd, res_stat_modified_cd, res_stat_altered_cd)
    DETAIL
     CASE (resultstatuscd)
      OF res_stat_cancelled_cd:
       resultstatuscd = res_stat_inerror_cd
      OF res_stat_inprogress_cd:
       resultstatuscd = res_stat_modified_cd
      OF res_stat_auth_cd:
       resultstatuscd = res_stat_modified_cd
     ENDCASE
    WITH nocounter
   ;end select
   CALL cv_log_msg(cv_info,build2("leaving getResultStatusCdForProcStatus with resultStatusCd--> ",
     resultstatuscd))
   RETURN(resultstatuscd)
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 IF (hreq > 0)
  CALL uar_crmendreq(hreq)
 ENDIF
 IF (htask > 0)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (happ > 0)
  CALL uar_crmendapp(happ)
 ENDIF
 IF ((reply->status_data.status="S"))
  CALL cv_log_msg(cv_info,"CV_UPD_ORDER_EVENT succeeded")
  SET reqinfo->commit_ind = 1
 ELSE
  CALL cv_log_msg(cv_error,"CV_UPD_ORDER_EVENT failed")
  CALL echorecord(clin_event_rep)
  CALL echorecord(reply)
  CALL echorecord(request)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL cv_log_msg_post("016 09/11/2020 AP067478")
END GO
