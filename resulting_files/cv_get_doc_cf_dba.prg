CREATE PROGRAM cv_get_doc_cf:dba
 SET lvl_error = 0
 SET lvl_warning = 1
 SET lvl_audit = 2
 SET lvl_info = 3
 SET lvl_debug = 4
 SET log_to_reply = 1
 SET log_to_screen = 0
 SET log_msg = fillstring(100," ")
 DECLARE sn_log_message(log_level,log_reply,log_event,log_mesg) = null WITH protected
 SUBROUTINE sn_log_message(log_level,log_reply,log_event,log_mesg)
   DECLARE sn_log_num = i4 WITH protected, noconstant(0)
   SET sn_log_level = evaluate(log_level,lvl_error,"E",lvl_warning,"W",
    lvl_audit,"A",lvl_info,"I",lvl_debug,
    "D","U")
   IF (log_reply=log_to_reply)
    SET sn_log_num = size(reply->status_data.subeventstatus,5)
    IF (sn_log_num=1)
     IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
      SET sn_log_num += 1
     ENDIF
    ELSE
     SET sn_log_num += 1
    ENDIF
    SET stat = alter(reply->status_data.subeventstatus,sn_log_num)
    SET reply->status_data.subeventstatus[sn_log_num].operationname = log_event
    SET reply->status_data.subeventstatus[sn_log_num].operationstatus = sn_log_level
    SET reply->status_data.subeventstatus[sn_log_num].targetobjectname = curprog
    SET reply->status_data.subeventstatus[sn_log_num].targetobjectvalue = log_mesg
   ELSE
    CALL echo("-----------------")
    CALL echo(build("Event           :",log_event))
    CALL echo(build("Status          :",sn_log_level))
    CALL echo(build("Current Program :",curprog))
    CALL echo(build("Message         :",log_mesg))
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(sysdate),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt += 1
 ENDIF
 SUBROUTINE (cv_log_createhandle(dummy=i2) =null)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 SUBROUTINE (cv_log_current_default(dummy=i2) =null)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 SUBROUTINE (cv_echo(string=vc) =null)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_message(log_message_param=vc) =null)
   SET cv_log_err_num += 1
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_message_status(object_name_param=vc,operation_status_param=c1,
  operation_name_param=vc,target_object_value_param=vc) =null)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event += 1
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event += 1
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_check_err(opname=vc,opstatus=c1,targetname=vc) =null)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 person_id = f8
    1 doc_id = f8
    1 mnemonic = c2
    1 print_ind = i2
    1 foreign_ind = i2
    1 forms[*]
      2 input_form_cd = f8
      2 event_cd = f8
      2 input_form_version_nbr = i4
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD internal_idx(
    1 ids[*]
      2 event_id = f8
      2 form_idx = i2
      2 entry_idx = i2
      2 grp_idx = i2
      2 cntrl_idx = i2
      2 result_type_meaning = vc
      2 result_units_cd = f8
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD internal(
    1 specialties[*]
      2 event_id = f8
  )
 ENDIF
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE logging_failure = vc WITH constant(uar_i18ngetmessage(i18nhandle,"key1",
   "Failed in select clinical event table"))
 DECLARE m_s_order_catalog_type = vc WITH protected, constant("15")
 DECLARE m_s_yes_no_type = vc WITH protected, constant("18")
 DECLARE m_s_provider_type = vc WITH protected, constant("14")
 DECLARE m_s_date_type = vc WITH protected, constant("6")
 DECLARE m_s_time_type = vc WITH protected, constant("10")
 DECLARE m_s_date_time_type = vc WITH protected, constant("11")
 DECLARE m_s_inventory_item_type = vc WITH protected, constant("16")
 DECLARE m_s_coded_result_type = vc WITH protected, constant("2")
 DECLARE m_s_numeric_type = vc WITH protected, constant("3")
 DECLARE m_s_free_text_type = vc WITH protected, constant("7")
 DECLARE get_inventory = c1 WITH public, noconstant("F")
 DECLARE get_coded_results = c1 WITH public, noconstant("F")
 DECLARE get_string_results = c1 WITH public, noconstant("F")
 DECLARE get_dates = c1 WITH public, noconstant("F")
 DECLARE get_prsnl = c1 WITH public, noconstant("F")
 DECLARE get_specialties = c1 WITH public, noconstant("F")
 DECLARE cerner_contributor_cd = f8 WITH protected, noconstant(0.0)
 SET cerner_contributor_cd = uar_get_code_by("MEANING",89,"POWERCHART")
 DECLARE character_true = c1 WITH protected, constant("T")
 DECLARE contributing_system = c12 WITH protected, noconstant("")
 DECLARE index_cnt = i4 WITH protected, noconstant(0)
 DECLARE failure = c1 WITH private, noconstant("F")
 DECLARE foreign_cf_ind = i2 WITH protected, noconstant(0)
 DECLARE maxsegment = i2 WITH private, noconstant(0)
 DECLARE maxentry = i2 WITH private, noconstant(0)
 DECLARE maxgroup = i2 WITH private, noconstant(0)
 DECLARE maxcontrol = i2 WITH private, noconstant(0)
 SET maxsegment = size(reply->segment_results,5)
 FOR (i = 1 TO maxsegment)
  IF (maxentry < size(reply->segment_results[i].entries,5))
   SET maxentry = size(reply->segment_results[i].entries,5)
  ENDIF
  FOR (j = 1 TO size(reply->segment_results[i].entries,5))
   IF (maxgroup < size(reply->segment_results[i].entries[j].groups,5))
    SET maxgroup = size(reply->segment_results[i].entries[j].groups,5)
   ENDIF
   FOR (k = 1 TO size(reply->segment_results[i].entries[j].groups,5))
     IF (maxcontrol < size(reply->segment_results[i].entries[j].groups[k].controls,5))
      SET maxcontrol = size(reply->segment_results[i].entries[j].groups[k].controls,5)
     ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
 SET foreign_cf_ind = 0
 SELECT INTO "nl:"
  sn.pref_value
  FROM sn_name_value_prefs sn,
   sn_doc_ref sd,
   perioperative_document p
  PLAN (sd)
   JOIN (sn
   WHERE sn.parent_entity_id=sd.doc_ref_id
    AND sn.pref_name="FOREIGN_CF_IND")
   JOIN (p
   WHERE p.doc_type_cd=sd.doc_type_cd
    AND p.surg_area_cd=sd.area_cd
    AND (p.periop_doc_id=request->doc_id))
  DETAIL
   foreign_cf_ind = cnvtreal(sn.pref_value)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_cd, ce.event_end_dt_tm
  FROM clinical_event ce,
   reference_range_factor rrf,
   (dummyt d1  WITH seq = value(maxsegment)),
   (dummyt d2  WITH seq = value(maxentry)),
   (dummyt d3  WITH seq = value(maxgroup)),
   (dummyt d4  WITH seq = value(maxcontrol))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->segment_results[d1.seq].entries,5))
   JOIN (d3
   WHERE d3.seq <= size(reply->segment_results[d1.seq].entries[d2.seq].groups,5))
   JOIN (d4
   WHERE d4.seq <= size(reply->segment_results[d1.seq].entries[d2.seq].groups[d3.seq].controls,5))
   JOIN (rrf
   WHERE (rrf.task_assay_cd=reply->segment_results[d1.seq].entries[d2.seq].groups[d3.seq].controls[d4
   .seq].task_assay_cd)
    AND rrf.active_ind=1
    AND rrf.mins_back != 0)
   JOIN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND (reply->segment_results[d1.seq].entries[d2.seq].groups[d3.seq].controls[d4.seq].event_cd=ce
   .event_cd)
    AND ce.task_assay_cd=rrf.task_assay_cd
    AND ((foreign_cf_ind=1) OR (ce.contributor_system_cd=cerner_contributor_cd)) )
  ORDER BY ce.event_cd, cnvtdatetime(ce.event_end_dt_tm) DESC, ce.clinical_event_id DESC
  HEAD REPORT
   index_cnt = 0, dt_diff = 0
  HEAD ce.event_cd
   dt_diff = datetimediff(cnvtdatetime(sysdate),cnvtdatetime(ce.event_end_dt_tm),4)
   IF (dt_diff <= rrf.mins_back)
    index_cnt += 1
    IF (index_cnt > size(internal_idx->ids,5))
     stat = alterlist(internal_idx->ids,(index_cnt+ 9))
    ENDIF
    internal_idx->ids[index_cnt].event_id = ce.event_id, internal_idx->ids[index_cnt].form_idx = d1
    .seq, internal_idx->ids[index_cnt].entry_idx = d2.seq,
    internal_idx->ids[index_cnt].grp_idx = d3.seq, internal_idx->ids[index_cnt].cntrl_idx = d4.seq,
    internal_idx->ids[index_cnt].result_units_cd = ce.result_units_cd,
    internal_idx->ids[index_cnt].result_type_meaning = reply->segment_results[d1.seq].entries[d2.seq]
    .groups[d3.seq].controls[d4.seq].result_type_meaning
   ENDIF
  DETAIL
   IF (trim(reply->segment_results[d1.seq].entries[d2.seq].groups[d3.seq].controls[d4.seq].
    task_assay_mean) IN ("CVXXXXXXXXXXXXXXXX"))
    get_prsnl = character_true
   ELSEIF (trim(reply->segment_results[d1.seq].entries[d2.seq].groups[d3.seq].controls[d4.seq].
    task_assay_mean) IN ("CVXXXXXXXXXXXXXXXX"))
    get_specialties = character_true
   ELSE
    CASE (trim(internal_idx->ids[index_cnt].result_type_meaning))
     OF m_s_provider_type:
      get_prsnl = character_true
     OF m_s_date_type:
     OF m_s_time_type:
     OF m_s_date_time_type:
      get_dates = character_true
     OF m_s_inventory_item_type:
      get_inventory = character_true,get_string_results = character_true
     OF m_s_coded_result_type:
      get_coded_results = character_true
     OF m_s_numeric_type:
     OF m_s_free_text_type:
      get_string_results = character_true
    ENDCASE
   ENDIF
  FOOT REPORT
   stat = alterlist(internal_idx->ids,index_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in select clinical event table!!!")
  SET failure = character_true
 ELSE
  CALL cv_log_message("fb_get_clinical_event is executed!")
  SET format_only = character_true
  EXECUTE fb_get_clinical_events
 ENDIF
 CALL cv_log_message(build("get_prsnl: ",get_prsnl))
 CALL cv_log_message(build("get_dates: ",get_dates))
 CALL cv_log_message(build("get_inventory: ",get_inventory))
 CALL cv_log_message(build("get_string_results: ",get_string_results))
 CALL cv_log_message(build("get_coded_result: ",get_coded_results))
 EXECUTE cv_log_struct  WITH replace(request,internal_idx)
#exit_script
 IF (failure != character_true)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE (cv_log_destroyhandle(dummy=i2) =null)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt -= 1
   ENDIF
 END ;Subroutine
END GO
