CREATE PROGRAM bhs_mp_ob_wklist_cust_print:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsondata
 FREE RECORD m_printdata
 RECORD m_printdata(
   1 s_person_printing_name = vc
   1 l_print_group_flag = i4
   1 patients[*]
     2 s_name_full = vc
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_encntr_type = vc
     2 d_reg_dt_tm = dq8
     2 d_preg_start_dt_tm = dq8
     2 d_preg_end_dt_tm = dq8
     2 s_preg_start_dt_tm = vc
     2 s_preg_end_dt_tm = vc
     2 s_birth_dt_tm = vc
     2 s_age = vc
     2 l_los = i4
     2 s_cmrn = vc
     2 s_sex = vc
     2 s_location = vc
     2 s_illness_sev = vc
     2 s_sit_aware_text = vc
     2 s_patient_summary = vc
     2 s_medications = vc
     2 s_comments = vc
     2 m_parity_found = i4
     2 diags[*]
       3 s_name_disp = vc
     2 actions[*]
       3 s_name_disp = vc
     2 pregoview[*]
       3 s_disp = vc
       3 s_result = vc
     2 plabs[*]
       3 s_disp = vc
       3 s_result = vc
     2 vitals[*]
       3 s_disp = vc
       3 s_lc = vc
       3 s_min = vc
       3 s_max = vc
     2 labs[*]
       3 s_disp = vc
       3 s_result = vc
     2 actorders[*]
       3 s_order = vc
       3 s_details = vc
     2 medorders[*]
       3 s_order = vc
       3 s_details = vc
     2 dt_tm_birth = vc
     2 obassess[*]
       3 s_label = vc
       3 obalst[*]
         4 s_label = vc
         4 s_result = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD m_mpageconfig
 RECORD m_mpageconfig(
   1 l_poknt = i4
   1 polst[*]
     2 f_code_value = f8
     2 c_display = c40
   1 l_plknt = i4
   1 pllst[*]
     2 f_code_value = f8
     2 c_display = c40
   1 l_vknt = i4
   1 vlst[*]
     2 f_code_value = f8
     2 c_display = c40
   1 l_lknt = i4
   1 llst[*]
     2 f_code_value = f8
     2 c_display = c40
   1 l_aoknt = i4
   1 aolst[*]
     2 f_catalog_cd = f8
   1 l_moknt = i4
   1 molst[*]
     2 f_catalog_cd = f8
 ) WITH protect
 DECLARE mf_mpagecomment = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14122,
   "MPAGESCOMMENT"))
 DECLARE mf_mpagespatientsummary = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14122,
   "MPAGESPATIENTSUMMARY"))
 DECLARE mf_ipasscomment = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4003147,"COMMENT"))
 DECLARE mf_weight_cd = f8 WITH protect, noconstant(0.00)
 DECLARE mf_bmi_cd = f8 WITH protect, noconstant(0.00)
 DECLARE mn_debug_ind = i2 WITH protect, noconstant(0)
 DECLARE gd_begin_date_time = dq8 WITH noconstant(cnvtdatetime(sysdate)), public
 DECLARE ms_json_blob_in = vc WITH protect, noconstant("")
 DECLARE md_prg_gd_begin_date_time = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE ml_run_cust_ccl_prg = i4 WITH protect, noconstant(0)
 DECLARE ms_log_program_name = vc WITH protect, noconstant("")
 DECLARE mn_log_override_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_log_level_error = i2 WITH protect, noconstant(0)
 DECLARE mn_log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE mn_log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE mn_log_level_info = i2 WITH protect, noconstant(3)
 DECLARE mn_log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE ml_hsys = i4 WITH protect, noconstant(0)
 DECLARE ml_sysstat = i4 WITH protect, noconstant(0)
 DECLARE mc_serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ml_ierrcode = i4 WITH protect, noconstant(error(mc_serrmsg,1))
 DECLARE ml_crsl_msg_default = w8 WITH protect, noconstant(0)
 DECLARE ml_crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET ml_crsl_msg_default = uar_msgdefhandle()
 SET ml_crsl_msg_level = uar_msggetlevel(ml_crsl_msg_default)
 DECLARE ml_lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE mn_icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE ml_lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE mn_icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE ms_scrsllogtext = vc WITH protect, noconstant("")
 DECLARE ms_scrsllogevent = vc WITH protect, noconstant("")
 DECLARE mn_icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE mn_icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE ml_lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE ms_crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE mc_crsl_logging_on = c1 WITH protect, constant("L")
 DECLARE getmpageconfig(null) = null
 DECLARE getpatientdata(null) = null
 DECLARE getpatientdxdata(null) = null
 DECLARE getpatientmpagecommentdata(null) = null
 DECLARE getpregoverviewdata(null) = null
 DECLARE getlabsdata(null) = null
 DECLARE getprenatallabsdata(null) = null
 DECLARE getvitalsdata(null) = null
 DECLARE getpatientactionsdata(null) = null
 DECLARE getobassessment(null) = null
 DECLARE getusername(null) = null
 SET jsonrec = cnvtrectojson(request)
 SET ms_log_program_name = curprog
 SET mn_log_override_ind = 0
 SET mn_debug_ind = 1
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",ms_log_program_name)) > " "
 )) )
  SET mn_log_override_ind = 1
 ENDIF
 CALL log_message(concat("Begin script: ",ms_log_program_name),mn_log_level_debug)
 SET m_printdata->status_data.status = "F"
 IF (validate(print_options)=0)
  IF (validate(request->blob_in,"") != "")
   SET ms_json_blob_in = trim(request->blob_in,3)
  ELSEIF (size(trim( $JSONDATA,3)) > 0)
   SET ms_json_blob_in = trim( $JSONDATA,3)
  ELSE
   CALL populate_subeventstatus_rec("PopulateRequest","F","MISSING_JSON_INPUT",
    "No JSON data provided to script.",m_printdata)
   GO TO exit_script
  ENDIF
  SET stat = cnvtjsontorec(ms_json_blob_in)
  IF (error_message(1)=1)
   CALL populate_subeventstatus_rec("PopulateRequest","F","CNVTJSONtorEC_ERRor",
    "Error encountered during cnvtjsontorec().",m_printdata)
   GO TO exit_script
  ENDIF
 ELSE
  SET ml_run_cust_ccl_prg = 1
 ENDIF
 IF (validate(print_options,"-999")="-999")
  CALL populate_subeventstatus_rec("ValidateRequest","F","MISSING_PRINT_OPTIONS_record",
   "Supplied JSON record not named 'PRINT_OPTIONS'.",m_printdata)
  GO TO exit_script
 ELSE
  IF (mn_debug_ind=1)
   CALL echorecord(print_options)
  ENDIF
 ENDIF
 CALL getmpageconfig(null)
 CALL getpatientdata(null)
 CALL getpatientdxdata(null)
 CALL getpregoverviewdata(null)
 CALL echorecord(m_printdata)
 CALL getlabsdata(null)
 CALL getprenatallabsdata(null)
 CALL getvitalsdata(null)
 CALL getpatientmpagecommentdata(null)
 CALL getpatientactionsdata(null)
 CALL getobassessment(null)
 CALL getusername(null)
 IF (ml_run_cust_ccl_prg > 0)
  CALL createprinttemplatelayout(null)
 ENDIF
 SUBROUTINE (putstringtofile(svalue=vc(val)) =null WITH protect)
   CALL log_message("In putStringtoFile()",mn_log_level_debug)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   IF (validate(_memory_reply_string)=1)
    SET _memory_reply_string = svalue
   ELSE
    FREE RECORD putrequest
    RECORD putrequest(
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line[*]
        2 linedata = vc
      1 overflowpage[*]
        2 ofr_qual[*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
    )
    SET putrequest->source_dir =  $OUTDEV
    SET putrequest->isblob = "1"
    SET putrequest->document = svalue
    SET putrequest->document_size = size(putrequest->document)
    EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
   ENDIF
   CALL log_message(build("Exit putStringtoFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE (putunboundedstringtofile(trec=vc(ref)) =null WITH protect)
   CALL log_message("In putUnboundedStringtoFile()",mn_log_level_debug)
   DECLARE ml_curstringlength = i4 WITH noconstant(textlen(trec->val))
   DECLARE ml_newmaxvarlen = i4 WITH noconstant(0)
   DECLARE ml_origcurmaxvarlen = i4 WITH noconstant(0)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   IF (ml_curstringlength > curmaxvarlen)
    SET ml_origcurmaxvarlen = curmaxvarlen
    SET ml_newmaxvarlen = (ml_curstringlength+ 10000)
    SET modify maxvarlen ml_newmaxvarlen
   ENDIF
   CALL putstringtofile(trec->val)
   IF (ml_newmaxvarlen > 0)
    SET modify maxvarlen ml_origcurmaxvarlen
   ENDIF
   CALL log_message(build("Exit putUnboundedStringtoFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null WITH protect)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In putJSONRecordtoFile()",mn_log_level_debug)
   RECORD _tempjson(
     1 val = gvc
   )
   SET _tempjson->val = cnvtrectojson(record_data)
   CALL putunboundedstringtofile(_tempjson)
   CALL log_message(build("Exit putJSONRecordtoFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET mn_icrslloglvloverrideind = 0
   SET ms_scrsllogtext = ""
   SET ms_scrsllogevent = ""
   SET ms_scrsllogtext = concat("{{Script::",value(ms_log_program_name),"}} ",logmsg)
   IF (mn_log_override_ind=0)
    SET mn_icrslholdloglevel = loglvl
   ELSE
    IF (ml_crsl_msg_level < loglvl)
     SET mn_icrslholdloglevel = ml_crsl_msg_level
     SET mn_icrslloglvloverrideind = 1
    ELSE
     SET mn_icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (mn_icrslloglvloverrideind=1)
    SET ms_scrsllogevent = "Script_Override"
   ELSE
    CASE (mn_icrslholdloglevel)
     OF mn_log_level_error:
      SET ms_scrsllogevent = "Script_Error"
     OF mn_log_level_warning:
      SET ms_scrsllogevent = "Script_Warning"
     OF mn_log_level_audit:
      SET ms_scrsllogevent = "Script_Audit"
     OF mn_log_level_info:
      SET ms_scrsllogevent = "Script_Info"
     OF mn_log_level_debug:
      SET ms_scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET ml_lcrsluarmsgwritestat = uar_msgwrite(ml_crsl_msg_default,0,nullterm(ms_scrsllogevent),
    mn_icrslholdloglevel,nullterm(ms_scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET mn_icrslerroroccured = 0
   SET ml_ierrcode = error(mc_serrmsg,0)
   WHILE (ml_ierrcode > 0)
     SET mn_icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(mc_serrmsg,mn_log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",mc_serrmsg)
      ENDIF
     ENDIF
     SET ml_ierrcode = error(mc_serrmsg,0)
   ENDWHILE
   RETURN(mn_icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (getdiagnosishtml(ml_data_index=i4) =vc)
   DECLARE ml_diag_index = i4 WITH protect, noconstant(0)
   DECLARE ml_numberofdiagnosis = i4 WITH protect, noconstant(size(m_printdata->patients[
     ml_data_index].diags,5))
   DECLARE ms_diagnosishtml = vc WITH protect, noconstant("")
   IF (ml_numberofdiagnosis > 0)
    SET ms_diagnosishtml = "<ul>"
    FOR (ml_diag_index = 1 TO ml_numberofdiagnosis)
      SET ms_diagnosishtml = build2(ms_diagnosishtml,"<li>",m_printdata->patients[ml_data_index].
       diags[ml_diag_index].s_name_disp,"</li>")
    ENDFOR
    SET ms_diagnosishtml = build2(ms_diagnosishtml,"</ul>")
   ENDIF
   RETURN(ms_diagnosishtml)
 END ;Subroutine
 SUBROUTINE (getprenatallabsvitalshtml(ml_data_index=i4) =vc)
   DECLARE ms_plabshtml = vc WITH protect, noconstant("")
   DECLARE ms_vitalshtml = vc WITH protect, noconstant("")
   DECLARE ms_plabsvitalshtml = vc WITH protect, noconstant("")
   DECLARE ml_plabsindex = i4 WITH protect, noconstant(0)
   DECLARE ml_numplabs = i4 WITH protect, constant(size(m_printdata->patients[ml_data_index].plabs,5)
    )
   DECLARE ml_vitalsindex = i4 WITH protect, noconstant(0)
   DECLARE ml_numvitals = i4 WITH protect, constant(size(m_printdata->patients[ml_data_index].vitals,
     5))
   IF (ml_numplabs > 0)
    SET ms_plabshtml = concat(ms_plabshtml,'<table border="0">','<tr class="header-row">',
     '<td align="center"; colspan="2">Prenatal Labs</td>',"</tr>")
    FOR (ml_plabsindex = 1 TO ml_numplabs)
      SET ms_plabshtml = build2(ms_plabshtml,"<tr>",'<td class="labssub">',m_printdata->patients[
       ml_data_index].plabs[ml_plabsindex].s_disp,": </td>",
       '<td class="labssub">',m_printdata->patients[ml_data_index].plabs[ml_plabsindex].s_result,
       "</td>","</tr>")
    ENDFOR
    SET ms_plabshtml = concat(ms_plabshtml,"</table>")
   ENDIF
   IF (ml_numvitals > 0)
    SET ms_vitalshtml = concat(ms_vitalshtml,'<table border="0">','<tr class="vitals-header">',
     "<th>Vital Sign</th>","<th>Last</th>",
     "<th>24hr Min</th>","<th>24hr Max</th>","</tr>")
    FOR (ml_vitalsindex = 1 TO ml_numvitals)
      SET ms_vitalshtml = build2(ms_vitalshtml,"<tr>",'<td class="labssub">',m_printdata->patients[
       ml_data_index].vitals[ml_vitalsindex].s_disp,": ",
       "</td>",'<td class="labssub">',m_printdata->patients[ml_data_index].vitals[ml_vitalsindex].
       s_lc,"</td>",'<td class="labssub">',
       m_printdata->patients[ml_data_index].vitals[ml_vitalsindex].s_min,"</td>",
       '<td class="labssub">',m_printdata->patients[ml_data_index].vitals[ml_vitalsindex].s_max,
       "</td>",
       "</tr>")
    ENDFOR
    SET ms_vitalshtml = concat(ms_vitalshtml,"</table>")
   ENDIF
   SET ms_plabsvitalshtml = concat(ms_plabshtml,ms_vitalshtml)
   RETURN(ms_plabsvitalshtml)
 END ;Subroutine
 SUBROUTINE (getpregoverviewhtml(ml_data_index=i4) =vc)
   DECLARE ms_pregoverviewhtml = vc WITH protect, noconstant("")
   DECLARE ml_pregoverviewindex = i4 WITH protect, noconstant(0)
   DECLARE ml_numpregoverview = i4 WITH protect, constant(size(m_printdata->patients[ml_data_index].
     pregoview,5))
   IF (ml_numpregoverview > 0)
    SET ms_pregoverviewhtml = concat(ms_pregoverviewhtml,'<table border="0">',"<tr>",
     '<td class="events">')
    FOR (ml_pregoverviewindex = 1 TO ml_numpregoverview)
      IF (ml_pregoverviewindex=1)
       IF ((m_printdata->patients[ml_data_index].m_parity_found=1))
        SET ms_pregoverviewhtml = build2(ms_pregoverviewhtml,m_printdata->patients[ml_data_index].
         pregoview[ml_pregoverviewindex].s_result)
       ELSE
        SET ms_pregoverviewhtml = build2(ms_pregoverviewhtml,m_printdata->patients[ml_data_index].
         pregoview[ml_pregoverviewindex].s_result,", P: 0")
       ENDIF
      ELSE
       SET ms_pregoverviewhtml = build2(ms_pregoverviewhtml,", ",m_printdata->patients[ml_data_index]
        .pregoview[ml_pregoverviewindex].s_result)
      ENDIF
    ENDFOR
    SET ms_pregoverviewhtml = concat(ms_pregoverviewhtml,"</td></tr></table>")
   ENDIF
   RETURN(ms_pregoverviewhtml)
 END ;Subroutine
 SUBROUTINE (getlabshtml(ml_data_index=i4) =vc)
   DECLARE ms_labshtml = vc WITH protect, noconstant("")
   DECLARE ml_labsindex = i4 WITH protect, noconstant(0)
   DECLARE ml_numlabs = i4 WITH protect, constant(size(m_printdata->patients[ml_data_index].labs,5))
   IF (ml_numlabs > 0)
    SET ms_labshtml = concat(ms_labshtml,'<table border="0";>')
    FOR (ml_labsindex = 1 TO ml_numlabs)
      SET ms_labshtml = build2(ms_labshtml,"<tr>",'<td class="labssub">',m_printdata->patients[
       ml_data_index].labs[ml_labsindex].s_disp,": </td>",
       '<td class="labssub">',m_printdata->patients[ml_data_index].labs[ml_labsindex].s_result,
       "</td>","</tr>")
    ENDFOR
    SET ms_labshtml = concat(ms_labshtml,"</table>")
   ENDIF
   RETURN(ms_labshtml)
 END ;Subroutine
 SUBROUTINE (getobassesshtml(ml_data_index=i4) =vc)
   DECLARE ms_obassesshtml = vc WITH protect, noconstant("")
   DECLARE ml_numobassess = i4 WITH protect, constant(size(m_printdata->patients[ml_data_index].
     obassess,5))
   IF ((m_printdata->patients[ml_data_index].dt_tm_birth > " "))
    SET ms_obassesshtml = concat('<table class="obassesssub"; border="0">',"<tr>",
     '<td class="obassesssub" >',"Date, Time of Birth:","</td>",
     '<td class="obassesssub" >',m_printdata->patients[ml_data_index].dt_tm_birth,"</td>","</tr>",
     "</table>")
   ELSEIF (ml_numobassess > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = ml_numobassess),
      (dummyt d2  WITH seq = 1)
     PLAN (d1
      WHERE maxrec(d2,size(m_printdata->patients[ml_data_index].obassess[d1.seq].obalst,5)))
      JOIN (d2)
     ORDER BY d1.seq, d2.seq
     HEAD REPORT
      ms_obassesshtml = concat(ms_obassesshtml,'<table class="obassesssub"; border="0">')
     HEAD d1.seq
      IF ((m_printdata->patients[ml_data_index].obassess[d1.seq].s_label > " "))
       ms_obassesshtml = build2(ms_obassesshtml,"<tr>",'<td class="obassesshead"; colspan="2"; >',
        m_printdata->patients[ml_data_index].obassess[d1.seq].s_label,"</td>",
        "</tr>")
      ENDIF
     HEAD d2.seq
      ms_obassesshtml = build2(ms_obassesshtml,"<tr>",'<td class="obassesssub">',m_printdata->
       patients[ml_data_index].obassess[d1.seq].obalst[d2.seq].s_label,": </td>",
       '<td class="obassesssub">',m_printdata->patients[ml_data_index].obassess[d1.seq].obalst[d2.seq
       ].s_result,"</td>","</tr>")
     FOOT REPORT
      ms_obassesshtml = concat(ms_obassesshtml,"</table>")
     WITH nocounter
    ;end select
   ENDIF
   RETURN(ms_obassesshtml)
 END ;Subroutine
 SUBROUTINE (getactionshtml(ml_data_index=i4) =vc)
   DECLARE ms_actionshtml = vc WITH protect, noconstant("")
   DECLARE ml_actionindex = i4 WITH protect, noconstant(0)
   DECLARE ml_numberofactions = i4 WITH protect, constant(size(m_printdata->patients[ml_data_index].
     actions,5))
   IF (ml_numberofactions > 0)
    SET ms_actionshtml = "<ul>"
    FOR (ml_actionindex = 1 TO ml_numberofactions)
      SET ms_actionshtml = build2(ms_actionshtml,"<li>",m_printdata->patients[ml_data_index].actions[
       ml_actionindex].s_name_disp,"</li>")
    ENDFOR
    SET ms_actionshtml = build2(ms_actionshtml,"</ul>")
   ENDIF
   RETURN(ms_actionshtml)
 END ;Subroutine
 SUBROUTINE createprinttemplatelayout(null)
   DECLARE ml_numberofpatients = i4 WITH protect, noconstant(size(m_printdata->patients,5))
   CALL echo(build("ml_numberofpatients = ",ml_numberofpatients))
   DECLARE ms_sfinalhtml = vc WITH noconstant("")
   DECLARE ml_index = i4 WITH protect, noconstant(0)
   DECLARE ms_patientshtml = vc WITH noconstant("")
   DECLARE ml_data_index = i4 WITH protect, noconstant(0)
   DECLARE ms_formatteddate = vc WITH protect, noconstant("")
   DECLARE md_current_date_time = dq8 WITH protect, constant(cnvtdatetime(sysdate))
   SET ms_formatteddate = format(md_current_date_time,cclfmt->shortdatetimenosec)
   IF (ml_numberofpatients > 0)
    SET ms_patientshtml = build2(ms_patientshtml,'<div class="table-container"><table>',"<thead>",
     '<tr class="header-row">',"<th>Location</th>",
     "<th>Patient Information</th>","<th>Pregnancy Overview</th>","<th>Patient Summary</th>",
     "<th>Diagnosis</th>","<th>Prenatal Labs & Vitals</th>",
     "<th>Labs</th>","<th>OB Assessment</th>","<th>Situational Awarness</th>","<th>Actions</th>",
     "</tr>",
     "</thead>")
   ENDIF
   FOR (ml_index = 1 TO ml_numberofpatients)
    SET ml_data_index = (mod(ml_index,2)+ 1)
    SET ms_patientshtml = build2(ms_patientshtml,'<tr class="table-row-1">','<td class="location">',
     '<div class="cell-content">',"<div>",
     m_printdata->patients[ml_index].s_location,"</div>","</div>","</td>",
     '<td class="patient-information">',
     '<div class="cell-content">',"<div>",m_printdata->patients[ml_index].s_name_full,"</div>",
     "<div>",
     "CMRN: ",m_printdata->patients[ml_index].s_cmrn,"</div>","<div>","Age: ",
     m_printdata->patients[ml_index].s_age,"</div>","<div>","DOB: ",m_printdata->patients[ml_index].
     s_birth_dt_tm,
     "</div>","<div>","LOS: ",build(m_printdata->patients[ml_index].l_los),"</div>",
     "</div>","</td>",'<td class="pregnancyoverview">','<div class="cell-content">',"<div>",
     getpregoverviewhtml(ml_index),"</div>","</div>","</td>",'<td class="patient-summary">',
     '<div class="cell-content">',"<div>",m_printdata->patients[ml_index].s_patient_summary,"</div>",
     "</div>",
     "</td>",'<td class="diagnosis">','<div class="cell-content">',getdiagnosishtml(ml_index),
     "</div>",
     "</td>",'<td class="prenatallabsvitals">','<div class="cell-content">',getprenatallabsvitalshtml
     (ml_index),"</div>",
     "</td>",'<td class="labs">','<div class="cell-content">',"<div>",getlabshtml(ml_index),
     "</div>","</div>","</td>",'<td class="obassessment">','<div class="cell-content">',
     "<div>",getobassesshtml(ml_index),"</div>","</div>","</td>",
     '<td class="sitaware">','<div class="cell-content">',trim(m_printdata->patients[ml_index].
      s_sit_aware_text),"</div>","</td>",
     '<td class="actions">','<div class="cell-content">',getactionshtml(ml_index),"</div>","</td>",
     "</tr>")
   ENDFOR
   IF (ml_numberofpatients > 0)
    SET ms_patientshtml = build2(ms_patientshtml,"</table></div>")
   ENDIF
   SET ms_sfinalhtml = build2("<!doctype html>","<html>","<head>",'<meta charset="utf-8">',
    '<meta name="description">',
    '<meta http-equiv="X-UA-Compatible" content="IE=Edge">',"<title>MPage Print</title>",
    '<style type="text/css">',"body {font-family: arial; font-size: 12px;}",
    ".table-container:nth-child(n+1) {page-break-after: always;}",
    "table {","  width: 100%;","  border-spacing:0 5px;","  }","tr {",
    "  border-collapse: separate;","  vertical-align: top;","  }","th {","  border: 1px solid black;",
    "  border-collapse: collapse;","  align: left; ","  vertical-align: bottom;",
    "  background-color:#BDBDBD;","  }",
    "td {","  vertical-align: top;","  border: 1px solid black;","  border-collapse: collapse;","  }",
    "ul {","  padding-left: 1.1em;","  margin: 0;","  }",".header-row {",
    "  border-bottom: 1px solid #b2b9c0;","  font-weight: bold; ","  align: center;",
    "  vertical-align: bottom;","  background-color:#BDBDBD;",
    "  }",".vitals-header {","  border-bottom: 1px solid #b2b9c0; ","  align: center;",
    "  vertical-align: bottom;",
    "  background-color:#BDBDBD;","  }",".events {","  border: 0px solid black;",
    "  border-collapse: collapse;",
    "  }",".patient-summary {width: 150px;}",".labs {width: 185px;}",".obassessment {width: 125px;}",
    ".pregnancyoverview {width:125px;}",
    ".ordermnem {font-weight: bold;}",".orderdet {font-weight: regular;}",".labssub {",
    "  border: 1px solid black;","  border-collapse: collapse;",
    "  }",".obassesshead {","  width:125px;","  font-weight: bold;","  border: 1px solid black;",
    "  border-collapse: collapse;","  }",".obassesssub {","  width:125px;",
    "  border: 1px solid black;",
    "  border-collapse: collapse;","  }",".sitaware {width:150px;}",".actions {width:150px;}",
    ".print-title {justify-content: center; font-style: bold; font-size: 24px;}",
    ".printed-date {justify-content: flex-end;}","</style>","</head>","<body>",
    '<div id = "print-container">',
    '<div class="print-header">','<div class="printed-by-user">',"<span>","Printed By: ","</span>",
    "<span>",m_printdata->s_person_printing_name,"</span>","</div>",'<div class="print-title">',
    "<span>","OB Physician Handoff","</span>","</div>",'<div class="printed-date">',
    "<span>",ms_formatteddate,"</span>","</div>","</div>",
    ms_patientshtml,"</div>","</body>","</html>")
   CALL putstringtofile(ms_sfinalhtml)
   IF (error_message(1)=1)
    CALL populate_subeventstatus_rec("PopulateRequest","F","CREATING_PRINT_TEMPLATE_HTML",
     "Error encountered during createPrintTemplateLayout().",m_printdata)
    GO TO exit_script
   ENDIF
   GO TO exit_program
 END ;Subroutine
 SUBROUTINE getmpageconfig(null)
   DECLARE ml_poknt = i4 WITH protect, noconstant(0)
   DECLARE ml_lknt = i4 WITH protect, noconstant(0)
   DECLARE ml_plknt = i4 WITH protect, noconstant(0)
   DECLARE ml_vknt = i4 WITH protect, noconstant(0)
   DECLARE ml_aoknt = i4 WITH protect, noconstant(0)
   DECLARE ml_moknt = i4 WITH protect, noconstant(0)
   DECLARE mc_type = c10 WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM br_datamart_category bdc,
     br_datamart_report bdr,
     br_datamart_report_filter_r bdfr,
     br_datamart_filter bdf,
     br_datamart_value bdv,
     br_datamart_report_filter_r bdfr2,
     br_datamart_filter bdf2,
     br_datamart_value bdv2,
     code_value cv
    PLAN (bdc
     WHERE bdc.category_mean="VB_POVOBPHYSICIANHANDOFF")
     JOIN (bdr
     WHERE bdr.br_datamart_category_id=bdc.br_datamart_category_id)
     JOIN (bdfr
     WHERE bdfr.br_datamart_report_id=bdr.br_datamart_report_id)
     JOIN (bdf
     WHERE bdf.br_datamart_filter_id=bdfr.br_datamart_filter_id
      AND bdf.filter_category_mean="MP_SECT_PARAMS")
     JOIN (bdv
     WHERE bdv.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdv.br_datamart_filter_id=bdf.br_datamart_filter_id
      AND bdv.mpage_param_value IN ("Pregnancy Overview", "Prenatal Labs & Vitals", "Labs",
     "Active Orders", "Active Med Orders"))
     JOIN (bdfr2
     WHERE bdfr2.br_datamart_report_id=bdfr.br_datamart_report_id)
     JOIN (bdf2
     WHERE bdf2.br_datamart_filter_id=bdfr2.br_datamart_filter_id
      AND bdf2.filter_category_mean IN ("ORDER", "EVENT_SEQ"))
     JOIN (bdv2
     WHERE bdv2.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdv2.br_datamart_filter_id=bdf2.br_datamart_filter_id)
     JOIN (cv
     WHERE cv.code_value=bdv2.parent_entity_id
      AND cv.code_value > 0.00
      AND cv.code_set IN (72, 200)
      AND cv.display_key != "SYSTOLICBLOODPRESSURE")
    ORDER BY bdv.mpage_param_value, bdv2.value_seq
    HEAD REPORT
     ml_poknt = 0, ml_lknt = 0, ml_plknt = 0,
     ml_vknt = 0, ml_aoknt = 0, ml_moknt = 0,
     mc_type = "Labs"
    HEAD bdv.mpage_param_value
     null
    DETAIL
     CASE (bdv.mpage_param_value)
      OF "Pregnancy Overview":
       ml_poknt += 1,m_mpageconfig->l_poknt = ml_poknt,e0 = alterlist(m_mpageconfig->polst,ml_poknt),
       m_mpageconfig->polst[ml_poknt].f_code_value = cv.code_value,m_mpageconfig->polst[ml_poknt].
       c_display = cv.display
      OF "Prenatal Labs & Vitals":
       IF (cv.display_key="DIASTOLICBLOODPRESSURE")
        mc_type = "Vitals"
       ENDIF
       ,
       IF (mc_type="Labs")
        ml_plknt += 1, m_mpageconfig->l_plknt = ml_plknt, e0 = alterlist(m_mpageconfig->pllst,
         ml_plknt),
        m_mpageconfig->pllst[ml_plknt].f_code_value = cv.code_value, m_mpageconfig->pllst[ml_plknt].
        c_display = cv.display
       ELSE
        IF (cv.display_key IN ("BODYMASSINDEX", "WEIGHT*"))
         CASE (cv.display_key)
          OF "BODYMASSINDEX":
           mf_bmi_cd = cv.code_value
          OF "WEIGHT*":
           mf_weight_cd = cv.code_value
         ENDCASE
        ELSE
         ml_vknt += 1, m_mpageconfig->l_vknt = ml_vknt, e0 = alterlist(m_mpageconfig->vlst,ml_vknt),
         m_mpageconfig->vlst[ml_vknt].f_code_value = cv.code_value, m_mpageconfig->vlst[ml_vknt].
         c_display = cv.display
        ENDIF
       ENDIF
      OF "Labs":
       ml_lknt += 1,m_mpageconfig->l_lknt = ml_lknt,e0 = alterlist(m_mpageconfig->llst,ml_lknt),
       m_mpageconfig->llst[ml_lknt].f_code_value = cv.code_value,m_mpageconfig->llst[ml_lknt].
       c_display = cv.display
      OF "Active Orders":
       ml_aoknt += 1,m_mpageconfig->l_aoknt = ml_aoknt,e0 = alterlist(m_mpageconfig->aolst,ml_aoknt),
       m_mpageconfig->aolst[ml_aoknt].f_catalog_cd = cv.code_value
      OF "Active Med Orders":
       ml_moknt += 1,m_mpageconfig->l_moknt = ml_moknt,e0 = alterlist(m_mpageconfig->molst,ml_moknt),
       m_mpageconfig->molst[ml_moknt].f_catalog_cd = cv.code_value
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpatientdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getPatientData()",mn_log_level_debug)
   DECLARE mf_cmrn = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_ecnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    loc = uar_get_code_display(e.loc_room_cd)
    FROM (dummyt d1  WITH seq = size(print_options->qual,5)),
     encounter e,
     person p,
     person_alias pa,
     pregnancy_instance pi,
     problem pr
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=print_options->qual[d1.seq].encntr_id))
     JOIN (p
     WHERE p.person_id=e.person_id)
     JOIN (pi
     WHERE pi.person_id=p.person_id
      AND pi.active_ind=1
      AND pi.historical_ind=0
      AND (pi.pregnancy_id=
     (SELECT
      max(pi2.pregnancy_id)
      FROM pregnancy_instance pi2
      WHERE pi2.person_id=pi.person_id
       AND pi2.historical_ind=0
       AND pi2.active_ind=1)))
     JOIN (pr
     WHERE (pr.problem_id= Outerjoin(pi.problem_id))
      AND (pr.active_ind= Outerjoin(1)) )
     JOIN (pa
     WHERE (pa.person_id= Outerjoin(p.person_id))
      AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn))
      AND (pa.active_ind= Outerjoin(1))
      AND (pa.end_effective_dt_tm> Outerjoin(cnvtdatetime(curdate,curtime))) )
    ORDER BY loc
    DETAIL
     ml_ecnt += 1, stat = alterlist(m_printdata->patients,ml_ecnt), m_printdata->patients[ml_ecnt].
     f_person_id = p.person_id,
     m_printdata->patients[ml_ecnt].f_encntr_id = e.encntr_id, m_printdata->patients[ml_ecnt].
     s_encntr_type = uar_get_code_display(e.encntr_type_cd), m_printdata->patients[ml_ecnt].
     d_reg_dt_tm = e.reg_dt_tm,
     m_printdata->patients[ml_ecnt].d_preg_start_dt_tm = pi.preg_start_dt_tm, m_printdata->patients[
     ml_ecnt].d_preg_end_dt_tm = pi.preg_end_dt_tm, m_printdata->patients[ml_ecnt].s_preg_start_dt_tm
      = trim(format(pi.preg_start_dt_tm,"MM/DD/YYYY;;Q"),3)
     IF (pi.preg_end_dt_tm >= sysdate)
      m_printdata->patients[ml_ecnt].s_preg_end_dt_tm = trim("No End Date",3)
     ELSE
      m_printdata->patients[ml_ecnt].s_preg_end_dt_tm = trim(format(pi.preg_end_dt_tm,"MM/DD/YYYY;;Q"
        ),3)
     ENDIF
     m_printdata->patients[ml_ecnt].s_name_full = trim(p.name_full_formatted), m_printdata->patients[
     ml_ecnt].s_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd), m_printdata->patients[ml_ecnt].s_sex =
     uar_get_code_display(p.sex_cd)
     IF (e.loc_room_cd > 0.00
      AND e.loc_room_cd > 0.00)
      m_printdata->patients[ml_ecnt].s_location = concat(build(uar_get_code_display(e.loc_room_cd)),
       "/",build(uar_get_code_display(e.loc_bed_cd)))
     ELSEIF (e.loc_room_cd > 0.00)
      m_printdata->patients[ml_ecnt].s_location = build(uar_get_code_display(e.loc_room_cd))
     ELSEIF (e.loc_room_cd > 0.00)
      m_printdata->patients[ml_ecnt].s_location = build(uar_get_code_display(e.loc_bed_cd))
     ENDIF
     m_printdata->patients[ml_ecnt].s_age = trim(cnvtage(p.birth_dt_tm),3), m_printdata->patients[
     ml_ecnt].s_birth_dt_tm = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;Q"),3), m_printdata->patients[
     ml_ecnt].l_los = round(datetimediff(cnvtdatetime(curdate,curtime),e.reg_dt_tm,1,0),0)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getPatientData(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getpatientdxdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getPatientDxData()",mn_log_level_debug)
   DECLARE mf_medicaldx = f8 WITH protect, constant(uar_get_code_by("MEANING",12033,"MEDICAL"))
   DECLARE mf_confirmeddx = f8 WITH protect, constant(uar_get_code_by("MEANING",12031,"CONFIRMED"))
   DECLARE ml_personcnt = i4 WITH protect, constant(size(m_printdata->patients,5))
   DECLARE ml_didx = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_dcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     diagnosis dx
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (dx
     WHERE dx.encntr_id=e.encntr_id
      AND dx.active_ind=1
      AND dx.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    ORDER BY e.encntr_id, dx.beg_effective_dt_tm DESC, dx.clinical_diag_priority
    HEAD e.encntr_id
     ml_dcnt = 0
    DETAIL
     ml_dcnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].diags,ml_dcnt), m_printdata->
     patients[d1.seq].diags[ml_dcnt].s_name_disp = trim(dx.diagnosis_display)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getPatientDxData(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getpregoverviewdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getPregOverviewData()",mn_log_level_debug)
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_poidx = i4 WITH protect, noconstant(0)
   DECLARE ml_pocnt = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_ecpos = i4 WITH protect, noconstant(0)
   DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
   DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
   DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
   DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
   DECLARE mf_cs72_egaatdelivery = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"EGAATDELIVERY")),
   protect
   DECLARE mf_cs72_egaatdocumented = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
     "EGAATDOCUMENTEDDATETIME")), protect
   DECLARE mf_cs72_parity = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PARITY")), protect
   DECLARE mf_cs72_gravida = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"GRAVIDA")), protect
   SELECT INTO "nl:"
    ec_sort = locateval(ml_ecpos,1,m_mpageconfig->l_poknt,ce.event_cd,m_mpageconfig->polst[ml_ecpos].
     f_code_value), cdr_ind = decode(cdr.event_id,1,0)
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     encounter e1,
     clinical_event ce,
     dummyt dd,
     ce_date_result cdr
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (e1
     WHERE e1.person_id=e.person_id
      AND e1.reg_dt_tm BETWEEN cnvtdatetime(m_printdata->patients[d1.seq].d_preg_start_dt_tm) AND
     cnvtdatetime(m_printdata->patients[d1.seq].d_preg_end_dt_tm))
     JOIN (ce
     WHERE ce.person_id=e1.person_id
      AND ((ce.event_cd IN (mf_cs72_gravida, mf_cs72_parity)) OR (ce.encntr_id=e1.encntr_id))
      AND expand(ml_poidx,1,m_mpageconfig->l_poknt,ce.event_cd,m_mpageconfig->polst[ml_poidx].
      f_code_value)
      AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
     mf_cs8_active)
      AND  NOT (ce.event_cd IN (mf_cs72_egaatdelivery, mf_cs72_egaatdocumented))
      AND ce.valid_until_dt_tm > sysdate)
     JOIN (dd)
     JOIN (cdr
     WHERE (cdr.event_id= Outerjoin(ce.event_id))
      AND (cdr.valid_until_dt_tm= Outerjoin(ce.valid_until_dt_tm)) )
    ORDER BY e.person_id, ec_sort, ce.event_cd,
     ce.event_end_dt_tm DESC
    HEAD e.person_id
     ml_pocnt = 0
    HEAD ec_sort
     null
    HEAD ce.event_cd
     ml_pocnt += 1,
     CALL echo(build("ml_pocnt = ",ml_pocnt)), d0 = alterlist(m_printdata->patients[d1.seq].pregoview,
      ml_pocnt),
     CALL echo(uar_get_code_display(ce.event_cd)), m_printdata->patients[d1.seq].pregoview[ml_pocnt].
     s_disp = trim(uar_get_code_display(ce.event_cd))
     IF (cdr_ind=1)
      m_printdata->patients[d1.seq].pregoview[ml_pocnt].s_result = concat(trim(uar_get_code_display(
         ce.event_cd)),": ",trim(format(cdr.result_dt_tm,"mm/dd/yyyy;;D")))
     ELSEIF (trim(uar_get_code_display(ce.event_cd)) IN ("Parity", "Gravida"))
      IF (trim(uar_get_code_display(ce.event_cd)) IN ("Gravida"))
       m_printdata->patients[d1.seq].pregoview[ml_pocnt].s_result = concat(substring(1,1,
         uar_get_code_display(ce.event_cd)),": ",trim(ce.result_val,3))
      ELSEIF (trim(uar_get_code_display(ce.event_cd)) IN ("Parity"))
       m_printdata->patients[d1.seq].pregoview[ml_pocnt].s_result = concat(substring(1,1,
         uar_get_code_display(ce.event_cd)),": ",trim(ce.result_val,3)), m_printdata->patients[d1.seq
       ].m_parity_found = 1
      ENDIF
     ELSE
      m_printdata->patients[d1.seq].pregoview[ml_pocnt].s_result = trim(ce.result_val,3)
     ENDIF
    FOOT REPORT
     ml_pocnt = 0
    WITH expand = 1, outerjoin = dd, nocounter
   ;end select
   SELECT INTO "nl:"
    ec_sort = locateval(ml_ecpos,1,m_mpageconfig->l_poknt,ce.event_cd,m_mpageconfig->polst[ml_ecpos].
     f_code_value)
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     encounter e1,
     clinical_event ce
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (e1
     WHERE e1.person_id=e.person_id
      AND e1.reg_dt_tm BETWEEN cnvtdatetime(m_printdata->patients[d1.seq].d_preg_start_dt_tm) AND
     cnvtdatetime(m_printdata->patients[d1.seq].d_preg_end_dt_tm))
     JOIN (ce
     WHERE ce.person_id=e1.person_id
      AND ce.encntr_id=e1.encntr_id
      AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
     mf_cs8_active)
      AND ce.event_cd IN (mf_cs72_egaatdelivery, mf_cs72_egaatdocumented)
      AND ce.valid_until_dt_tm > sysdate)
    ORDER BY d1.seq, e.person_id, ce.event_end_dt_tm DESC
    HEAD d1.seq
     ml_pocnt = size(m_printdata->patients[d1.seq].pregoview,5),
     CALL echo(build("ml_pocnt2a = ",ml_pocnt))
    HEAD e.person_id
     CALL echo(build("ml_pocnt2b = ",ml_pocnt)), ml_pocnt += 1, d0 = alterlist(m_printdata->patients[
      d1.seq].pregoview,ml_pocnt),
     m_printdata->patients[d1.seq].pregoview[ml_pocnt].s_result = trim(ce.result_val,3)
    FOOT REPORT
     ml_pocnt = 0
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getPregOverviewData(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getlabsdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getLabsData()",mn_log_level_debug)
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_lidx = i4 WITH protect, noconstant(0)
   DECLARE ml_lcnt = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_ecpos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    ec_sort = locateval(ml_ecpos,1,m_mpageconfig->l_lknt,ce.event_cd,m_mpageconfig->llst[ml_ecpos].
     f_code_value)
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     clinical_event ce
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (ce
     WHERE ce.person_id=e.person_id
      AND expand(ml_lidx,1,m_mpageconfig->l_lknt,ce.event_cd,m_mpageconfig->llst[ml_lidx].
      f_code_value)
      AND ce.event_end_dt_tm > e.reg_dt_tm
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
      AND ce.view_level=1
      AND ce.encntr_id=e.encntr_id)
    ORDER BY e.encntr_id, ec_sort, ce.event_cd,
     ce.event_end_dt_tm DESC
    HEAD e.encntr_id
     ml_lcnt = 0
    HEAD ec_sort
     null
    HEAD ce.event_cd
     ml_lcnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].labs,ml_lcnt), m_printdata->patients[
     d1.seq].labs[ml_lcnt].s_disp = trim(uar_get_code_display(ce.event_cd)),
     m_printdata->patients[d1.seq].labs[ml_lcnt].s_result = trim(ce.result_val)
    WITH expand = 1, nocounter
   ;end select
   CALL log_message(build("Exit getLabsData(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getprenatallabsdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getPrenatalLabsData()",mn_log_level_debug)
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_plidx = i4 WITH protect, noconstant(0)
   DECLARE ml_plcnt = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_ecpos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    ec_sort = locateval(ml_ecpos,1,m_mpageconfig->l_poknt,ce.event_cd,m_mpageconfig->pllst[ml_ecpos].
     f_code_value)
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     clinical_event ce
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (ce
     WHERE ce.person_id=e.person_id
      AND expand(ml_plidx,1,m_mpageconfig->l_plknt,ce.event_cd,m_mpageconfig->pllst[ml_plidx].
      f_code_value)
      AND ce.event_end_dt_tm > e.reg_dt_tm
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
      AND ce.encntr_id=e.encntr_id)
    ORDER BY e.encntr_id, ec_sort, ce.event_cd,
     ce.event_end_dt_tm DESC
    HEAD e.encntr_id
     ml_plcnt = 0
    HEAD ec_sort
     null
    HEAD ce.event_cd
     ml_plcnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].plabs,ml_plcnt), m_printdata->
     patients[d1.seq].plabs[ml_plcnt].s_disp = trim(uar_get_code_display(ce.event_cd)),
     m_printdata->patients[d1.seq].plabs[ml_plcnt].s_result = trim(ce.result_val)
    WITH expand = 1, nocounter
   ;end select
   CALL log_message(build("Exit getPrenatalLabsData(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getvitalsdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getVitalsData()",mn_log_level_debug)
   DECLARE mf_systolicbp = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
     "SYSTOLICBLOODPRESSURE"))
   DECLARE mf_diastolicbp = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
     "DIASTOLICBLOODPRESSURE"))
   DECLARE mf_max = f8 WITH protect, noconstant(0.00)
   DECLARE mf_min = f8 WITH protect, noconstant(0.00)
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_vidx = i4 WITH protect, noconstant(0)
   DECLARE ml_vcnt = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    lsort =
    IF (ce.event_cd=mf_diastolicbp) 1
    ELSEIF (trim(uar_get_code_display(ce.event_cd))="Heart Rate Monitored") 2
    ELSEIF (trim(uar_get_code_display(ce.event_cd))="Pulse Rate") 3
    ELSEIF (trim(uar_get_code_display(ce.event_cd))="Respiratory Rate") 4
    ELSEIF (trim(uar_get_code_display(ce.event_cd))="Temperature") 5
    ELSEIF (trim(uar_get_code_display(ce.event_cd))="Oxygen Saturation") 6
    ELSE 7
    ENDIF
    , resval = cnvtreal(ce.result_val)
    FROM (dummyt de  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     clinical_event ce,
     dummyt d1,
     clinical_event ce2
    PLAN (de)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[de.seq].f_encntr_id))
     JOIN (ce
     WHERE ce.person_id=e.person_id
      AND expand(ml_vidx,1,m_mpageconfig->l_vknt,ce.event_cd,m_mpageconfig->vlst[ml_vidx].
      f_code_value)
      AND ce.view_level=1
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
      AND ce.encntr_id=e.encntr_id)
     JOIN (d1)
     JOIN (ce2
     WHERE ce2.person_id=e.person_id
      AND ce2.event_cd=mf_systolicbp
      AND ce2.event_end_dt_tm=ce.event_end_dt_tm
      AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
      AND ce2.encntr_id=ce.encntr_id
      AND ce2.view_level=1
      AND ce.event_cd=mf_diastolicbp)
    ORDER BY e.encntr_id, lsort, ce.event_cd,
     ce.event_end_dt_tm DESC
    HEAD e.encntr_id
     ml_vcnt = 0
    HEAD ce.event_cd
     mf_max = 0.00, mf_min = 999999999.00, ml_vcnt += 1,
     d0 = alterlist(m_printdata->patients[de.seq].vitals,ml_vcnt)
     IF (ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
      mf_max = resval, mf_min = resval
     ENDIF
     IF (ce.event_cd=mf_diastolicbp)
      m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = "BP", m_printdata->patients[de.seq].
      vitals[ml_vcnt].s_lc = concat(trim(ce2.result_val),"/",trim(ce.result_val))
      IF (ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
       m_printdata->patients[de.seq].vitals[ml_vcnt].s_min = concat(trim(ce2.result_val),"/",trim(ce
         .result_val)), m_printdata->patients[de.seq].vitals[ml_vcnt].s_max = concat(trim(ce2
         .result_val),"/",trim(ce.result_val))
      ENDIF
     ELSE
      CASE (trim(uar_get_code_display(ce.event_cd)))
       OF "Temperature":
        m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = "T"
       OF "Respiratory Rate":
        m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = "RR"
       OF "Heart Rate Monitored":
        m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = "HR"
       OF "Pulse Rate":
        m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = "PR"
       OF "Oxygen Saturation":
        m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = "O2SAT"
       OF "Body Mass Index":
        m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = "BMI"
       OF "GBS PCR Result":
        m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = "GBS"
       ELSE
        m_printdata->patients[de.seq].vitals[ml_vcnt].s_disp = trim(uar_get_code_display(ce.event_cd)
         )
      ENDCASE
      m_printdata->patients[de.seq].vitals[ml_vcnt].s_lc = concat(trim(ce.result_val))
      IF (ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
       m_printdata->patients[de.seq].vitals[ml_vcnt].s_min = trim(ce.result_val), m_printdata->
       patients[de.seq].vitals[ml_vcnt].s_max = trim(ce.result_val)
      ENDIF
     ENDIF
    HEAD ce.event_end_dt_tm
     null
    DETAIL
     IF (ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
      IF (ce.event_cd=mf_diastolicbp)
       IF (resval < mf_min)
        mf_min = resval, m_printdata->patients[de.seq].vitals[ml_vcnt].s_min = concat(trim(ce2
          .result_val),"/",trim(ce.result_val))
       ENDIF
       IF (resval > mf_max)
        mf_max = resval, m_printdata->patients[de.seq].vitals[ml_vcnt].s_max = concat(trim(ce2
          .result_val),"/",trim(ce.result_val))
       ENDIF
      ELSE
       IF (resval < mf_min)
        mf_min = resval, m_printdata->patients[de.seq].vitals[ml_vcnt].s_min = trim(ce.result_val)
       ENDIF
       IF (resval > mf_max)
        mf_max = resval, m_printdata->patients[de.seq].vitals[ml_vcnt].s_max = trim(ce.result_val)
       ENDIF
      ENDIF
     ENDIF
    WITH expand = 1, outerjoin = d1, nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     clinical_event ce
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (ce
     WHERE ce.person_id=e.person_id
      AND ce.event_cd IN (mf_weight_cd, mf_bmi_cd)
      AND ce.event_end_dt_tm >= e.reg_dt_tm
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
      AND ce.encntr_id=e.encntr_id)
    ORDER BY e.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
    HEAD e.encntr_id
     ml_vcnt = size(m_printdata->patients[d1.seq].vitals,5)
    HEAD ce.event_cd
     ml_vcnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].vitals,ml_vcnt)
     IF (ce.event_cd=mf_weight_cd)
      m_printdata->patients[d1.seq].vitals[ml_vcnt].s_disp = "WT"
     ENDIF
     IF (ce.event_cd=mf_bmi_cd)
      m_printdata->patients[d1.seq].vitals[ml_vcnt].s_disp = "BMI"
     ENDIF
     m_printdata->patients[d1.seq].vitals[ml_vcnt].s_lc = trim(ce.result_val)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getVitalsData(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getpatientmpagecommentdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getPatientMPageCommentData()",mn_log_level_debug)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     pct_ipass pi,
     sticky_note sn
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (pi
     WHERE pi.encntr_id=e.encntr_id
      AND pi.active_ind=1
      AND pi.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
     JOIN (sn
     WHERE sn.sticky_note_id=pi.parent_entity_id
      AND sn.sticky_note_type_cd IN (mf_mpagecomment, mf_mpagespatientsummary)
      AND sn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    ORDER BY e.encntr_id, sn.sticky_note_type_cd, sn.beg_effective_dt_tm DESC
    HEAD e.encntr_id
     m_printdata->patients[d1.seq].s_sit_aware_text = " ", m_printdata->patients[d1.seq].
     s_patient_summary = " "
    HEAD sn.sticky_note_type_cd
     null
    HEAD sn.beg_effective_dt_tm
     null
    DETAIL
     CASE (sn.sticky_note_type_cd)
      OF mf_mpagespatientsummary:
       IF ((m_printdata->patients[d1.seq].s_patient_summary=" "))
        m_printdata->patients[d1.seq].s_patient_summary = trim(sn.sticky_note_text)
       ENDIF
      OF mf_mpagecomment:
       IF ((m_printdata->patients[d1.seq].s_sit_aware_text=" "))
        m_printdata->patients[d1.seq].s_sit_aware_text = trim(sn.sticky_note_text)
       ELSE
        m_printdata->patients[d1.seq].s_sit_aware_text = concat(m_printdata->patients[d1.seq].
         s_sit_aware_text,"<br>",trim(sn.sticky_note_text))
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getPatientMPageCommentData(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getpatientactionsdata(null)
   DECLARE mf_task_complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"COMPLETE"))
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getPatientActionsData()",mn_log_level_debug)
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_acnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     pct_ipass pi,
     task_activity ta,
     long_text lt
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (pi
     WHERE pi.encntr_id=e.encntr_id
      AND pi.active_ind=1
      AND pi.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
     JOIN (ta
     WHERE ta.task_id=pi.parent_entity_id
      AND  NOT (ta.task_status_cd IN (mf_task_complete_cd))
      AND ta.active_ind=1)
     JOIN (lt
     WHERE lt.long_text_id=ta.msg_text_id
      AND lt.active_ind=1)
    ORDER BY e.encntr_id, pi.pct_seq
    HEAD e.encntr_id
     ml_acnt = 0
    DETAIL
     ml_acnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].actions,ml_acnt), m_printdata->
     patients[d1.seq].actions[ml_acnt].s_name_disp = trim(lt.long_text)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getPatientActionsData(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getobassessment(ml_data_index)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getOBAssessment()",mn_log_level_debug)
   DECLARE mf_datetimeofbirth = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
     "DATETIMEOFBIRTH"))
   DECLARE mf_ordered = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_oidx = i4 WITH protect, noconstant(0)
   DECLARE ml_ocnt = i4 WITH protect, noconstant(0)
   DECLARE ml_cecnt = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_obaidx = i4 WITH protect, noconstant(0)
   DECLARE ml_obapos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     clinical_event ce,
     ce_date_result cdr
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (ce
     WHERE ce.encntr_id=e.encntr_id
      AND ce.event_cd=mf_datetimeofbirth
      AND ce.ce_dynamic_label_id > 0.00
      AND ce.event_end_dt_tm >= e.reg_dt_tm
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (cdr
     WHERE (cdr.event_id= Outerjoin(ce.event_id))
      AND (cdr.valid_until_dt_tm= Outerjoin(ce.valid_until_dt_tm)) )
    ORDER BY d1.seq, ce.event_cd, ce.performed_dt_tm DESC
    HEAD d1.seq
     null
    HEAD ce.event_cd
     m_printdata->patients[d1.seq].dt_tm_birth = format(cdr.result_dt_tm,"mm/dd/yy hh:mm;;D")
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     clinical_event ce,
     code_value cv,
     ce_date_result cdr
    PLAN (d1
     WHERE (m_printdata->patients[d1.seq].dt_tm_birth=null))
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (ce
     WHERE ce.encntr_id=e.encntr_id
      AND ce.event_end_dt_tm >= e.reg_dt_tm
      AND ce.view_level=1
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (cv
     WHERE ce.event_cd=cv.code_value
      AND cv.display IN ("Cervical Dilatation", "Cervical Effacement", "Fetal Station"))
     JOIN (cdr
     WHERE (cdr.event_id= Outerjoin(ce.event_id))
      AND (cdr.valid_until_dt_tm= Outerjoin(ce.valid_until_dt_tm)) )
    ORDER BY ce.encntr_id, ce.event_cd, ce.performed_dt_tm DESC
    HEAD ce.encntr_id
     ml_ocnt = 0, ml_ocnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].obassess,ml_ocnt),
     m_printdata->patients[d1.seq].obassess[ml_ocnt].s_label = " ", ml_cecnt = 0
    HEAD ce.event_cd
     ml_cecnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].obassess[ml_ocnt].obalst,ml_cecnt),
     m_printdata->patients[d1.seq].obassess[ml_ocnt].obalst[ml_cecnt].s_label = trim(cv.display),
     m_printdata->patients[d1.seq].obassess[ml_ocnt].obalst[ml_cecnt].s_result = trim(ce.result_val)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(m_printdata->patients,5)),
     encounter e,
     clinical_event ce,
     code_value cv,
     ce_dynamic_label cedl,
     ce_date_result cdr
    PLAN (d1
     WHERE (m_printdata->patients[d1.seq].dt_tm_birth=null))
     JOIN (e
     WHERE (e.encntr_id=m_printdata->patients[d1.seq].f_encntr_id))
     JOIN (ce
     WHERE ce.encntr_id=e.encntr_id
      AND ce.ce_dynamic_label_id > 0.00
      AND ce.event_end_dt_tm >= e.reg_dt_tm
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (cv
     WHERE cv.code_value=ce.event_cd
      AND cv.display IN ("Membrane Status:", "ROM Date, Time:", "Amniotic Fluid Color/Description:",
     "Fetal Position:", "Fetal Presentation:",
     "Estimated Fetal Weight:"))
     JOIN (cedl
     WHERE ce.ce_dynamic_label_id=cedl.ce_dynamic_label_id)
     JOIN (cdr
     WHERE (cdr.event_id= Outerjoin(ce.event_id))
      AND (cdr.valid_until_dt_tm= Outerjoin(ce.valid_until_dt_tm)) )
    ORDER BY ce.encntr_id, cedl.label_name, cedl.ce_dynamic_label_id,
     ce.event_cd, ce.performed_dt_tm DESC
    HEAD ce.encntr_id
     IF (size(m_printdata->patients[d1.seq].obassess,5) > 0)
      ml_ocnt = size(m_printdata->patients[d1.seq].obassess,5)
     ELSE
      ml_ocnt = 0
     ENDIF
    HEAD cedl.label_name
     null
    HEAD cedl.ce_dynamic_label_id
     ml_ocnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].obassess,ml_ocnt), m_printdata->
     patients[d1.seq].obassess[ml_ocnt].s_label = trim(cedl.label_name),
     ml_cecnt = 0
    HEAD ce.event_cd
     CALL echo(cv.display), ml_cecnt += 1, d0 = alterlist(m_printdata->patients[d1.seq].obassess[
      ml_ocnt].obalst,ml_cecnt),
     m_printdata->patients[d1.seq].obassess[ml_ocnt].obalst[ml_cecnt].s_label = trim(cv.display)
     CASE (cv.display)
      OF "ROM Date, Time:":
       m_printdata->patients[d1.seq].obassess[ml_ocnt].obalst[ml_cecnt].s_result = trim(format(cdr
         .result_dt_tm,"mm/dd/yyyy HH:mm;;D"))
      ELSE
       m_printdata->patients[d1.seq].obassess[ml_ocnt].obalst[ml_cecnt].s_result = trim(ce.result_val
        )
     ENDCASE
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getOBAssessment(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getusername(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getUserName()",mn_log_level_debug)
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE (p.person_id=print_options->user_context.user_id))
    DETAIL
     m_printdata->s_person_printing_name = trim(p.name_full_formatted)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getUserName(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET ml_lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET ml_lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[ml_lcrslsubeventcnt].
      operationname))
    SET ml_lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[ml_lcrslsubeventcnt]
      .operationstatus))
    SET ml_lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[ml_lcrslsubeventcnt]
      .targetobjectname))
    SET ml_lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[ml_lcrslsubeventcnt]
      .targetobjectvalue))
    IF (ml_lcrslsubeventsize > 0)
     SET ml_lcrslsubeventcnt += 1
     SET mn_icrslloggingstat = alter(recorddata->status_data.subeventstatus,ml_lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[ml_lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[ml_lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[ml_lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[ml_lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
#exit_script
 IF (size(m_printdata->patients,5) > 0)
  SET m_printdata->status_data.status = "S"
 ENDIF
 CALL putjsonrecordtofile(m_printdata)
#exit_program
 IF (mn_debug_ind=1)
  CALL echorecord(m_printdata)
  CALL echorecord(m_mpageconfig)
 ENDIF
 CALL log_message(concat("Exiting script: ",ms_log_program_name),mn_log_level_debug)
END GO
