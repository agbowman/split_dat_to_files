CREATE PROGRAM bhs_mp_wklist_cust_print:dba
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
     2 s_birth_dt_tm = vc
     2 s_mrn = vc
     2 s_cmrn = vc
     2 s_sex = vc
     2 s_location = vc
     2 s_illness_sev = vc
     2 s_sit_aware_text = vc
     2 s_patient_summary = vc
     2 s_medications = vc
     2 s_comments = vc
     2 diags[*]
       3 s_name_disp = vc
     2 actions[*]
       3 s_name_disp = vc
     2 csorders[*]
       3 s_order = vc
       3 s_details = vc
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
   1 l_csoknt = i4
   1 csolst[*]
     2 f_catalog_cd = f8
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
 DECLARE ml_crsl_msg_default = i4 WITH protect, noconstant(0)
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
 DECLARE mn_lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE ms_crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE mc_crsl_logging_on = c1 WITH protect, constant("L")
 DECLARE mf_care_team_id = f8 WITH protect, noconstant(0.00)
 DECLARE getmpageconfig(null) = null
 DECLARE getpatientdata(null) = null
 DECLARE getpatientdxdata(null) = null
 DECLARE getpatientmpagecommentdata(null) = null
 DECLARE getcodestatusorders(null) = null
 DECLARE getpatientactionsdata(null) = null
 DECLARE getusername(null) = null
 SET jsonrec = cnvtrectojson(print_options)
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
  IF ((print_options->qual[1].care_team_id > 0.00))
   SET mf_care_team_id = print_options->qual[1].care_team_id
  ENDIF
  IF (mn_debug_ind=1)
   CALL echorecord(print_options,"print_options.txt")
  ENDIF
 ENDIF
 CALL getmpageconfig(null)
 CALL getpatientdata(null)
 CALL getpatientdxdata(null)
 CALL getcodestatusorders(null)
 CALL getpatientmpagecommentdata(null)
 CALL getpatientactionsdata(null)
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
 SUBROUTINE (getactionshtml(ml_dataindex=i4) =vc)
   DECLARE ms_actionshtml = vc WITH protect, noconstant("")
   DECLARE ml_actionindex = i4 WITH protect, noconstant(0)
   DECLARE ml_numberofactions = i4 WITH protect, constant(size(m_printdata->patients[ml_dataindex].
     actions,5))
   IF (ml_numberofactions > 0)
    SET ms_actionshtml = concat(ms_actionshtml,"<ul>")
    FOR (ml_actionindex = 1 TO ml_numberofactions)
      SET ms_actionshtml = build2(ms_actionshtml,"<li>",m_printdata->patients[ml_dataindex].actions[
       ml_actionindex].s_name_disp,"</li>")
    ENDFOR
    SET ms_actionshtml = build2(ms_actionshtml,"</ul>")
   ELSE
    SET ms_actionshtml = "<br><br><br><br><br>"
   ENDIF
   RETURN(ms_actionshtml)
 END ;Subroutine
 SUBROUTINE (getcsordershtml(ml_dataindex=i4) =vc)
   CALL echo("****** getCSOrdersHTML - begin ******")
   DECLARE ms_csordshtml = vc WITH protect, noconstant("")
   DECLARE ml_csordsindex = i4 WITH protect, noconstant(0)
   DECLARE ml_numcsords = i4 WITH protect, constant(size(m_printdata->patients[ml_dataindex].csorders,
     5))
   IF (ml_numcsords > 0)
    SET ms_csordshtml = ""
    FOR (ml_csordsindex = 1 TO ml_numcsords)
      SET ms_csordshtml = build2(ms_csordshtml,'<a class="ordermnem">',m_printdata->patients[
       ml_dataindex].csorders[ml_csordsindex].s_order,"</a>")
    ENDFOR
   ENDIF
   RETURN(ms_csordshtml)
   CALL echo("****** getCSOrdersHTML - end ******")
 END ;Subroutine
 SUBROUTINE createprinttemplatelayout(null)
   DECLARE ml_numberofpatients = i4 WITH protect, noconstant(size(m_printdata->patients,5))
   DECLARE ms_sfinalhtml = vc WITH noconstant("")
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE ms_patientshtml = vc WITH noconstant("")
   DECLARE ml_dataindex = i4 WITH protect, noconstant(0)
   DECLARE ms_formatteddate = vc WITH protect, noconstant("")
   DECLARE md_current_date_time = dq8 WITH protect, constant(cnvtdatetime(sysdate))
   SET ms_formatteddate = format(md_current_date_time,cclfmt->shortdatetimenosec)
   FOR (index = 1 TO ml_numberofpatients)
    SET ml_dataindex = (mod(index,2)+ 1)
    SET ms_patientshtml = build2(ms_patientshtml,'<div class="table-container"><table>',
     '<tr class="table-row-1">','<td class="patient-information">',
     '<div class="cell-header1"><u>Patient Information</u></div>',
     '<div class="patientname">',m_printdata->patients[index].s_name_full,"</div>","<a>",m_printdata
     ->patients[index].s_sex,
     "</a><br>","<a>","DOB:",m_printdata->patients[index].s_birth_dt_tm,"</a><br>",
     "<a>","CMRN:",m_printdata->patients[index].s_cmrn,"</a><br>","</td>",
     '<td class="loc">','<div class="cell-header1">',"<u>Location</u>","</div>",
     '<div class="cell-content">',
     '<div class="location">',m_printdata->patients[index].s_location,"</div>","<br>",
     '<div class="cell-header2">',
     "<u>Code Status</u>","</div>",'<div class="codestatus">',getcsordershtml(index),"</div>",
     "</div>","</td>",'<td class="patient-summary">','<div class="cell-header1">',
     "<u>Patient Summary</u>",
     "</div>",'<div class="cell-content">',m_printdata->patients[index].s_patient_summary,"</div>",
     "</td>",
     "</tr>",'<tr class="table-row-2">',"</td>",'<td class="actions">',
     '<div class="cell-header2"><u>Actions</u></div>',
     getactionshtml(index),"</td>",'<td class="sitawareness">',
     '<div class="cell-header2"><u>SA</u></div>','<div class="cell-content">',
     m_printdata->patients[index].s_sit_aware_text,"</div>","</td>",'<td class="comments">',
     '<div class="cell-header2"><u>Comments</u></div>',
     '<div class="cell-content">',"<div>",m_printdata->patients[index].s_comments,"</div>","</div>",
     "</tr>","</table></div>")
   ENDFOR
   SET ms_sfinalhtml = build2("<!doctype html>","<html>","<head>",'<meta charset="utf-8">',
    '<meta name="description">',
    '<meta http-equiv="X-UA-Compatible" content="IE=Edge">',"<title>MPage Print</title>",
    '<style type="text/css">',"body {font-family: arial; font-size: 12px;}","table {width: 100%;}",
    ".table-container { padding-top: 0em; padding-bottom: 0em;}",
    ".table-container:nth-child(4n+1) { page-break-after: always;}",
    "table, {border: 1px solid black;}","td { padding: 0px;}","td {vertical-align: top;}",
    ".table-row-1 {border-top: 5px black;}",".table-row-1 .patient-information {width: 20%}",
    ".table-row-1 .loc { width: 40%}",".table-row-1 .patient-summary {width: 40%}",
    ".cell-content {padding-left: 2px; padding-bottom: 0em;}",
    ".table-row-2 .sitawareness {width: 40%}",".table-row-2 .comments {width: 40%}",
    ".cell-header1 {","  border-top: 5px solid black;","  font-weight: bold;",
    "  }",".cell-header2 {","  font-weight: bold;","  }",".notes-content {min-height: 0em;}",
    ".print-header {display: flex;}",".print-header div{display: flex; flex: 1 1;}",
    ".print-title { justify-content: center; font-style: bold; font-size: 24px;}",
    ".printed-date { justify-content: flex-end;}",
    ".patientname {margin: 0; font-weight: 900; font-size: 16px;}",
    ".location {font-weight: 900; font-size: 13px;}",
    ".codestatus {font-weight: 900; font-size: 13px;}",
    ".patient-information .cell-content {padding-top: 0em;}","ul {padding-left: 1.1em; margin: 0;}",
    "</style>",
    "</head>","<body>",'<div id = "print-container">','<div class="print-header">',
    '<div class="printed-by-user">',
    "<span>","Printed By: ","</span>","<span>",m_printdata->s_person_printing_name,
    "</span>","</div>",'<div class="print-title">',"<span>","Physician Handoff",
    "</span>","</div>",'<div class="printed-date">',"<span>",ms_formatteddate,
    "</span>","</div>","</div>",ms_patientshtml,"</div>",
    "</body>","</html>")
   CALL putstringtofile(ms_sfinalhtml)
   IF (error_message(1)=1)
    CALL populate_subeventstatus_rec("PopulateRequest","F","CREATING_PRINT_TEMPLATE_HTML",
     "Error encountered during createPrintTemplateLayout().",m_printdata)
    GO TO exit_script
   ENDIF
   GO TO exit_program
 END ;Subroutine
 SUBROUTINE getmpageconfig(null)
   DECLARE ml_csoknt = i4 WITH protect, noconstant(0)
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
     WHERE bdc.category_mean="VB_POVPHYSICIANHANDOFFWORKLIST")
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
      AND bdv.mpage_param_value IN ("Resuscitation Order"))
     JOIN (bdfr2
     WHERE bdfr2.br_datamart_report_id=bdfr.br_datamart_report_id)
     JOIN (bdf2
     WHERE bdf2.br_datamart_filter_id=bdfr2.br_datamart_filter_id)
     JOIN (bdv2
     WHERE bdv2.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdv2.br_datamart_filter_id=bdf2.br_datamart_filter_id)
     JOIN (cv
     WHERE cv.code_value=bdv2.parent_entity_id
      AND cv.code_value > 0.00
      AND cv.code_set IN (72, 200)
      AND cv.display_key != "SYSTOLICBLOODPRESSURE")
    ORDER BY bdv2.value_seq
    HEAD REPORT
     ml_csoknt = 0, ml_lknt = 0, ml_plknt = 0,
     ml_vknt = 0, ml_aoknt = 0, ml_moknt = 0,
     mc_type = "Labs"
    DETAIL
     CASE (bdv.mpage_param_value)
      OF "Resuscitation Order":
       ml_csoknt += 1,m_mpageconfig->l_csoknt = ml_csoknt,e0 = alterlist(m_mpageconfig->csolst,
        ml_csoknt),
       m_mpageconfig->csolst[ml_csoknt].f_catalog_cd = cv.code_value,m_mpageconfig->csolst[ml_csoknt]
       .c_display = cv.display
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
        IF (cv.display_key IN ("BODYMASSINDEX", "WEIGHT"))
         CASE (cv.display_key)
          OF "BODYMASSINDEX":
           mf_weight_cd = cv.code_value
          OF "WEIGHT":
           mf_bmi_cd = cv.code_value
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
      OF "Orders":
       ml_moknt += 1,m_mpageconfig->l_moknt = ml_moknt,e0 = alterlist(m_mpageconfig->molst,ml_moknt),
       m_mpageconfig->molst[ml_moknt].f_catalog_cd = cv.code_value
     ENDCASE
    WITH nocounter
   ;end select
   CALL echorecord(m_mpageconfig)
 END ;Subroutine
 SUBROUTINE getpatientdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getPatientData()",mn_log_level_debug)
   DECLARE mf_cmrn = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_ecnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    loc = uar_get_code_display(e.loc_nurse_unit_cd)
    FROM encounter e,
     person p,
     person_alias pa
    PLAN (e
     WHERE expand(ml_eidx,1,size(print_options->qual,5),e.encntr_id,print_options->qual[ml_eidx].
      encntr_id))
     JOIN (p
     WHERE p.person_id=e.person_id)
     JOIN (pa
     WHERE (pa.person_id= Outerjoin(p.person_id))
      AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn))
      AND (pa.active_ind= Outerjoin(1))
      AND (pa.end_effective_dt_tm> Outerjoin(cnvtdatetime(curdate,curtime))) )
    ORDER BY loc
    DETAIL
     ml_ecnt += 1
     IF (size(m_printdata->patients,5) < ml_ecnt)
      stat = alterlist(m_printdata->patients,(ml_ecnt+ 5))
     ENDIF
     m_printdata->patients[ml_ecnt].f_person_id = p.person_id, m_printdata->patients[ml_ecnt].
     f_encntr_id = e.encntr_id, m_printdata->patients[ml_ecnt].s_encntr_type = uar_get_code_display(e
      .encntr_type_cd),
     m_printdata->patients[ml_ecnt].d_reg_dt_tm = e.reg_dt_tm, m_printdata->patients[ml_ecnt].
     s_name_full = trim(p.name_full_formatted), m_printdata->patients[ml_ecnt].s_sex =
     uar_get_code_display(p.sex_cd),
     m_printdata->patients[ml_ecnt].s_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
     IF (e.loc_room_cd > 0.00)
      m_printdata->patients[ml_ecnt].s_location = concat(trim(uar_get_code_display(e
         .loc_nurse_unit_cd)),"/",uar_get_code_display(e.loc_room_cd))
     ELSE
      m_printdata->patients[ml_ecnt].s_location = uar_get_code_display(e.loc_nurse_unit_cd)
     ENDIF
     m_printdata->patients[ml_ecnt].s_birth_dt_tm = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;Q"),3)
    FOOT REPORT
     stat = alterlist(m_printdata->patients,ml_ecnt)
    WITH expand = 1, nocounter
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
   DECLARE ml_epos = i4 WITH protect, noconstant(0)
   DECLARE ml_dcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM encounter e,
     diagnosis dx
    PLAN (e
     WHERE expand(ml_didx,1,size(m_printdata->patients,5),e.encntr_id,m_printdata->patients[ml_didx].
      f_encntr_id))
     JOIN (dx
     WHERE dx.encntr_id=e.encntr_id
      AND dx.active_ind=1
      AND dx.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    ORDER BY e.encntr_id, dx.clinical_diag_priority
    HEAD e.encntr_id
     ml_epos = locateval(ml_idx,1,size(m_printdata->patients,5),e.encntr_id,m_printdata->patients[
      ml_idx].f_encntr_id), ml_dcnt = 0
    DETAIL
     ml_dcnt += 1, d0 = alterlist(m_printdata->patients[ml_epos].diags,ml_dcnt), m_printdata->
     patients[ml_epos].diags[ml_dcnt].s_name_disp = trim(dx.diagnosis_display)
    WITH expand = 1, nocounter
   ;end select
   CALL log_message(build("Exit getPatientDxData(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getcodestatusorders(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getCodeStatusOrders()",mn_log_level_debug)
   DECLARE mf_ordered = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_csoidx = i4 WITH protect, noconstant(0)
   DECLARE ml_csoknt = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_epos = i4 WITH protect, noconstant(0)
   DECLARE ml_copos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    ord_sort = locateval(ml_copos,1,m_mpageconfig->l_csoknt,o.catalog_cd,m_mpageconfig->csolst[
     ml_copos].f_catalog_cd)
    FROM encounter e,
     orders o
    PLAN (e
     WHERE expand(ml_eidx,1,size(m_printdata->patients,5),e.encntr_id,m_printdata->patients[ml_eidx].
      f_encntr_id))
     JOIN (o
     WHERE o.encntr_id=e.encntr_id
      AND expand(ml_csoidx,1,m_mpageconfig->l_csoknt,o.catalog_cd,m_mpageconfig->csolst[ml_csoidx].
      f_catalog_cd)
      AND o.order_status_cd=mf_ordered
      AND o.active_ind=1
      AND o.template_order_flag IN (0, 1)
      AND o.order_id > 0.00)
    ORDER BY o.encntr_id, ord_sort
    HEAD o.encntr_id
     ml_epos = locateval(ml_idx,1,size(m_printdata->patients,5),e.encntr_id,m_printdata->patients[
      ml_idx].f_encntr_id), ml_csoknt = 0
    HEAD ord_sort
     null
    DETAIL
     ml_csoknt += 1, d0 = alterlist(m_printdata->patients[ml_epos].csorders,ml_csoknt), m_printdata->
     patients[ml_epos].csorders[ml_csoknt].s_order = trim(o.order_mnemonic),
     m_printdata->patients[ml_epos].csorders[ml_csoknt].s_details = trim(o.clinical_display_line)
    WITH expand = 1, nocounter
   ;end select
   CALL log_message(build("Exit getCodeStatusOrders(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),gd_begin_date_time,5)),mn_log_level_debug)
 END ;Subroutine
 SUBROUTINE getpatientmpagecommentdata(null)
   SET gd_begin_date_time = cnvtdatetime(sysdate)
   CALL log_message("In getPatientMPageCommentData()",mn_log_level_debug)
   DECLARE ml_eidx = i4 WITH protect, noconstant(0)
   DECLARE ml_idx = i4 WITH protect, noconstant(0)
   DECLARE ml_epos = i4 WITH protect, noconstant(0)
   DECLARE ml_pcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM encounter e,
     pct_ipass pi,
     sticky_note sn
    PLAN (e
     WHERE expand(ml_eidx,1,size(m_printdata->patients,5),e.encntr_id,m_printdata->patients[ml_eidx].
      f_encntr_id))
     JOIN (pi
     WHERE pi.encntr_id=e.encntr_id
      AND ((pi.pct_care_team_id=mf_care_team_id) OR (pi.global_ind=1))
      AND pi.active_ind=1
      AND pi.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
     JOIN (sn
     WHERE sn.sticky_note_id=pi.parent_entity_id
      AND sn.sticky_note_type_cd IN (mf_mpagecomment, mf_mpagespatientsummary)
      AND sn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    ORDER BY e.encntr_id, sn.sticky_note_type_cd, sn.beg_effective_dt_tm DESC
    HEAD e.encntr_id
     ml_epos = locateval(ml_idx,1,size(m_printdata->patients,5),e.encntr_id,m_printdata->patients[
      ml_idx].f_encntr_id), m_printdata->patients[ml_epos].s_sit_aware_text = " ", m_printdata->
     patients[ml_epos].s_patient_summary = " "
    HEAD sn.sticky_note_type_cd
     null
    HEAD sn.beg_effective_dt_tm
     null
    DETAIL
     CASE (sn.sticky_note_type_cd)
      OF mf_mpagespatientsummary:
       IF ((m_printdata->patients[ml_epos].s_patient_summary=" "))
        m_printdata->patients[ml_epos].s_patient_summary = trim(sn.sticky_note_text)
       ENDIF
      OF mf_mpagecomment:
       IF ((m_printdata->patients[ml_epos].s_sit_aware_text=" "))
        m_printdata->patients[ml_epos].s_sit_aware_text = trim(sn.sticky_note_text)
       ELSE
        m_printdata->patients[ml_epos].s_sit_aware_text = concat(m_printdata->patients[ml_epos].
         s_sit_aware_text,"<br>",trim(sn.sticky_note_text))
       ENDIF
     ENDCASE
    WITH expand = 1, nocounter
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
   DECLARE ml_epos = i4 WITH protect, noconstant(0)
   DECLARE ml_acnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM encounter e,
     pct_ipass pi,
     task_activity ta,
     long_text lt
    PLAN (e
     WHERE expand(ml_eidx,1,size(m_printdata->patients,5),e.encntr_id,m_printdata->patients[ml_eidx].
      f_encntr_id))
     JOIN (pi
     WHERE pi.encntr_id=e.encntr_id
      AND ((pi.pct_care_team_id=mf_care_team_id) OR (pi.global_ind=1))
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
     ml_epos = locateval(ml_idx,1,size(m_printdata->patients,5),e.encntr_id,m_printdata->patients[
      ml_idx].f_encntr_id), ml_acnt = 0
    DETAIL
     ml_acnt += 1, d0 = alterlist(m_printdata->patients[ml_epos].actions,ml_acnt), m_printdata->
     patients[ml_epos].actions[ml_acnt].s_name_disp = trim(lt.long_text)
    WITH expand = 1, nocounter
   ;end select
   CALL log_message(build("Exit getPatientActionsData(), Elapsed time in seconds:",datetimediff(
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
 ENDIF
 CALL echorecord(print_options)
 CALL log_message(concat("Exiting script: ",ms_log_program_name),mn_log_level_debug)
END GO
