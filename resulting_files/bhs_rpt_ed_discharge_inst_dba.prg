CREATE PROGRAM bhs_rpt_ed_discharge_inst:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 s_patient_name = vc
   1 f_person_id = f8
   1 s_visit_date = vc
   1 f_event_id = f8
   1 s_dob = vc
   1 s_fin_nbr = vc
   1 s_disch_phys = vc
   1 s_disch_nurse = vc
   1 prescriptions[*]
     2 s_text = vc
   1 s_note_text = vc
   1 create_dt_tm = dq8
   1 scd_story_id = f8
   1 event_id = f8
   1 s_treated_for = vc
   1 vu_cnt = i4
   1 vr_unsorted[*]
     2 f_blob_id = f8
     2 event_id = f8
     2 s_text = vc
     2 n_normalcy_ind = i2
     2 d_event_dt_tm = dq8
     2 s_event_desc = vc
     2 s_event_tag = vc
     2 n_result_type = i2
     2 s_result_type = vc
     2 n_ignore_ind = i2
   1 vr_cnt = i4
   1 visit_results[*]
     2 normalcy_ind = i2
     2 event_dt_tm = vc
     2 event_desc = vc
     2 event_tag = vc
     2 n_result_type = i2
     2 s_result_type = vc
   1 s_procedures = vc
   1 ipt_cnt = i4
   1 ip_treatments[*]
     2 f_blob_id = f8
     2 s_text = vc
   1 ez_cnt = i4
   1 easyscripts[*]
     2 s_text = vc
   1 scripts_given = vc
   1 cont_med_ind = i2
   1 s_discontinue = vc
   1 s_drowsiness = vc
   1 med_info_other = vc
   1 s_micromedex = vc
   1 work_note_ind = i2
   1 n_excuse_note_ind = i2
   1 p_cnt = i4
   1 precautions[*]
     2 f_blob_id = f8
     2 s_text = vc
   1 f1_cnt = i4
   1 md_follow_ups[*]
     2 name = vc
     2 phone = vc
     2 time = vc
     2 s_text = vc
   1 f2_cnt = i4
   1 clinic_follow_ups[*]
     2 name = vc
     2 time = vc
     2 s_text = vc
   1 f3_cnt = i4
   1 add_follow_ups[*]
     2 name = vc
     2 time = vc
     2 s_text = vc
   1 s_ni_home_phone = vc
   1 ni_cnt = i4
   1 ni_follow_ups[*]
     2 f_blob_id = f8
     2 s_text = vc
   1 b_cnt = i4
   1 blobs[*]
     2 blob_parent = vc
     2 blob_slot = i4
     2 f_blob_id = f8
   1 a_cnt = i4
   1 addendums[*]
     2 s_title = vc
     2 s_text = vc
 ) WITH protect
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE report_head(ncalc=i2) = f8 WITH protect
 DECLARE report_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patient_data(ncalc=i2) = f8 WITH protect
 DECLARE patient_dataabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE report_divider(ncalc=i2) = f8 WITH protect
 DECLARE report_dividerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_space(ncalc=i2) = f8 WITH protect
 DECLARE section_spaceabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE provider_info(ncalc=i2) = f8 WITH protect
 DECLARE provider_infoabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE disch_nurse(ncalc=i2) = f8 WITH protect
 DECLARE disch_nurseabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_treated_for(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_treated_forabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE section_results_head(ncalc=i2) = f8 WITH protect
 DECLARE section_results_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE result_type_head(ncalc=i2) = f8 WITH protect
 DECLARE result_type_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_results_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_results_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
 f8 WITH protect
 DECLARE ed_meds_header(ncalc=i2) = f8 WITH protect
 DECLARE ed_meds_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE ed_meds_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE ed_meds_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE section_procedures(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_proceduresabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE section_treatments_head(ncalc=i2) = f8 WITH protect
 DECLARE section_treatments_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_treatments_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_treatments_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref))
  = f8 WITH protect
 DECLARE section_cont_meds(ncalc=i2) = f8 WITH protect
 DECLARE section_cont_medsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_discontinue(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_discontinueabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE section_drowsiness(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_drowsinessabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE section_scripts_given(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_scripts_givenabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
  WITH protect
 DECLARE section_meds_included(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_meds_includedabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
  WITH protect
 DECLARE section_med_other(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_med_otherabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE section_micromedex(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_micromedexabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE section_precautions_head(ncalc=i2) = f8 WITH protect
 DECLARE section_precautions_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_precautions_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_precautions_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref))
  = f8 WITH protect
 DECLARE prescriptions_header(ncalc=i2) = f8 WITH protect
 DECLARE prescriptions_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE prescriptions_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE prescriptions_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE rx_med_profile_header(ncalc=i2) = f8 WITH protect
 DECLARE rx_med_profile_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE rx_med_profile_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE rx_med_profile_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
  WITH protect
 DECLARE note_given_head(ncalc=i2) = f8 WITH protect
 DECLARE note_given_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE work_note_detail(ncalc=i2) = f8 WITH protect
 DECLARE work_note_detailabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE excuse_note_detail(ncalc=i2) = f8 WITH protect
 DECLARE excuse_note_detailabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_followup_head(ncalc=i2) = f8 WITH protect
 DECLARE section_followup_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_md_followup(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_md_followupabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE section_clinic_followup(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_clinic_followupabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
 f8 WITH protect
 DECLARE section_addtl_followup(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_addtl_followupabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
 f8 WITH protect
 DECLARE section_other_followup_head(ncalc=i2) = f8 WITH protect
 DECLARE section_other_followup_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_ni_followup(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_ni_followupabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE section_contact_numbers(ncalc=i2) = f8 WITH protect
 DECLARE section_contact_numbersabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_followup_phone(ncalc=i2) = f8 WITH protect
 DECLARE section_followup_phoneabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_addendums_head(ncalc=i2) = f8 WITH protect
 DECLARE section_addendums_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_addendums_title(ncalc=i2) = f8 WITH protect
 DECLARE section_addendums_titleabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_addendums_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_addendums_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref))
  = f8 WITH protect
 DECLARE section_disclaimers(ncalc=i2) = f8 WITH protect
 DECLARE section_disclaimersabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patient_info_disclaimer(ncalc=i2) = f8 WITH protect
 DECLARE patient_info_disclaimerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_hosp_signatures(ncalc=i2) = f8 WITH protect
 DECLARE section_hosp_signaturesabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE page_foot(ncalc=i2) = f8 WITH protect
 DECLARE page_footabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remtreated_for = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsection_treated_for = i2 WITH noconstant(0), protect
 DECLARE _remevent_desc = i4 WITH noconstant(1), protect
 DECLARE _remevent_tag = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_results_detail = i2 WITH noconstant(0), protect
 DECLARE _remed_meds_orders = i4 WITH noconstant(1), protect
 DECLARE _bconted_meds_detail = i2 WITH noconstant(0), protect
 DECLARE _remprocedures = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_procedures = i2 WITH noconstant(0), protect
 DECLARE _remtreatments = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_treatments_detail = i2 WITH noconstant(0), protect
 DECLARE _remdiscontinue_taking = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_discontinue = i2 WITH noconstant(0), protect
 DECLARE _remdrowsiness = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_drowsiness = i2 WITH noconstant(0), protect
 DECLARE _remscripts_given = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_scripts_given = i2 WITH noconstant(0), protect
 DECLARE _remmeds_included = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_meds_included = i2 WITH noconstant(0), protect
 DECLARE _remmed_other = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_med_other = i2 WITH noconstant(0), protect
 DECLARE _remmicromedex = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_micromedex = i2 WITH noconstant(0), protect
 DECLARE _remprecautions = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_precautions_detail = i2 WITH noconstant(0), protect
 DECLARE _remprescriptions = i4 WITH noconstant(1), protect
 DECLARE _bcontprescriptions_detail = i2 WITH noconstant(0), protect
 DECLARE _remprescriptions = i4 WITH noconstant(1), protect
 DECLARE _bcontrx_med_profile_detail = i2 WITH noconstant(0), protect
 DECLARE _remmd_followup = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_md_followup = i2 WITH noconstant(0), protect
 DECLARE _remclinic_followup = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_clinic_followup = i2 WITH noconstant(0), protect
 DECLARE _remaddtl_followup = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_addtl_followup = i2 WITH noconstant(0), protect
 DECLARE _remni_followup = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_ni_followup = i2 WITH noconstant(0), protect
 DECLARE _remaddendum_text = i4 WITH noconstant(1), protect
 DECLARE _bcontsection_addendums_detail = i2 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12bu0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica18b0 = i4 WITH noconstant(0), protect
 DECLARE _pen21s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE report_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE report_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.354
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica18b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_copy_desc_text,char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.396)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Emergency Department Discharge Instructions",char(0)))
    SET rptsd->m_y = (offsety+ 0.698)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Medical Center",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "759 Chestnut Street Springfield, MA 01199",char(0)))
    SET rptsd->m_y = (offsety+ 1.073)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("413-794-0000",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patient_data(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_dataabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patient_dataabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE __visit_date = vc WITH noconstant(build2(m_info->s_visit_date,char(0))), protect
   DECLARE __patient_name = vc WITH noconstant(build2(m_info->s_patient_name,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(m_info->s_dob,char(0))), protect
   DECLARE __acct_num = vc WITH noconstant(build2(m_info->s_fin_nbr,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__visit_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ED Account Number:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acct_num)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.240)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Visit:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE report_divider(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_dividerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE report_dividerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen21s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.094),(offsetx+ 7.500),(offsety+
     0.094))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_space(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_spaceabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_spaceabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE provider_info(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = provider_infoabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE provider_infoabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __md_name = vc WITH noconstant(build2(m_info->s_disch_phys,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.906
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Discharging Physician:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 5.635
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__md_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE disch_nurse(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = disch_nurseabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE disch_nurseabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __nurse_name = vc WITH noconstant(build2(m_info->s_disch_nurse,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.906
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Discharging Nurse:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 5.635
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nurse_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_treated_for(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_treated_forabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_treated_forabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_treated_for = f8 WITH noconstant(0.0), private
   DECLARE __treated_for = vc WITH noconstant(build2(m_info->s_treated_for,char(0))), protect
   IF (bcontinue=0)
    SET _remtreated_for = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.198)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtreated_for = _remtreated_for
   IF (_remtreated_for > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtreated_for,((size(
        __treated_for) - _remtreated_for)+ 1),__treated_for)))
    SET drawheight_treated_for = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtreated_for = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtreated_for,((size(__treated_for) -
       _remtreated_for)+ 1),__treated_for)))))
     SET _remtreated_for = (_remtreated_for+ rptsd->m_drawlength)
    ELSE
     SET _remtreated_for = 0
    ENDIF
    SET growsum = (growsum+ _remtreated_for)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.802
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("You Were Treated For",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.198)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_treated_for
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
   IF (ncalc=rpt_render
    AND _holdremtreated_for > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtreated_for,((size
       (__treated_for) - _holdremtreated_for)+ 1),__treated_for)))
   ELSE
    SET _remtreated_for = _holdremtreated_for
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.771)
   SET rptsd->m_width = 1.010
   SET rptsd->m_height = 0.229
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (becont=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Continued)",char(0)))
    ENDIF
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_results_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_results_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_results_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ED Treatment and Results",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.125)
    SET rptsd->m_width = 1.010
    SET rptsd->m_height = 0.229
    IF (becont=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Continued)",char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE result_type_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = result_type_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE result_type_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __result_type = vc WITH noconstant(build2(m_info->visit_results[vr].s_result_type,char(0))
    ), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__result_type)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_results_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_results_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_results_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_event_desc = f8 WITH noconstant(0.0), private
   DECLARE drawheight_event_tag = f8 WITH noconstant(0.0), private
   DECLARE __event_dt_tm = vc WITH noconstant(build2(m_info->visit_results[vr].event_dt_tm,char(0))),
   protect
   DECLARE __event_desc = vc WITH noconstant(build2(m_info->visit_results[vr].event_desc,char(0))),
   protect
   DECLARE __event_tag = vc WITH noconstant(build2(trim(m_info->visit_results[vr].event_tag,3),char(0
      ))), protect
   IF (bcontinue=0)
    SET _remevent_desc = 1
    SET _remevent_tag = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF ((m_info->visit_results[vr].normalcy_ind=1))
    SET _fntcond = _helvetica12b0
   ELSE
    SET _fntcond = _helvetica120
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_fntcond)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremevent_desc = _remevent_desc
   IF (_remevent_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remevent_desc,((size(
        __event_desc) - _remevent_desc)+ 1),__event_desc)))
    SET drawheight_event_desc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remevent_desc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remevent_desc,((size(__event_desc) -
       _remevent_desc)+ 1),__event_desc)))))
     SET _remevent_desc = (_remevent_desc+ rptsd->m_drawlength)
    ELSE
     SET _remevent_desc = 0
    ENDIF
    SET growsum = (growsum+ _remevent_desc)
   ENDIF
   SET rptsd->m_flags = 5
   IF ((m_info->visit_results[vr].normalcy_ind=1))
    SET _fntcond = _helvetica12b0
   ELSE
    SET _fntcond = _helvetica120
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _holdremevent_tag = _remevent_tag
   IF (_remevent_tag > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remevent_tag,((size(
        __event_tag) - _remevent_tag)+ 1),__event_tag)))
    SET drawheight_event_tag = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remevent_tag = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remevent_tag,((size(__event_tag) -
       _remevent_tag)+ 1),__event_tag)))))
     SET _remevent_tag = (_remevent_tag+ rptsd->m_drawlength)
    ELSE
     SET _remevent_tag = 0
    ENDIF
    SET growsum = (growsum+ _remevent_tag)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.208
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__event_dt_tm)
   ENDIF
   SET rptsd->m_flags = 4
   IF ((m_info->visit_results[vr].normalcy_ind=1))
    SET _fntcond = _helvetica12b0
   ELSE
    SET _fntcond = _helvetica120
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = drawheight_event_desc
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   IF (ncalc=rpt_render
    AND _holdremevent_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremevent_desc,((size(
        __event_desc) - _holdremevent_desc)+ 1),__event_desc)))
   ELSE
    SET _remevent_desc = _holdremevent_desc
   ENDIF
   SET rptsd->m_flags = 4
   IF ((m_info->visit_results[vr].normalcy_ind=1))
    SET _fntcond = _helvetica12b0
   ELSE
    SET _fntcond = _helvetica120
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = drawheight_event_tag
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   IF (ncalc=rpt_render
    AND _holdremevent_tag > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremevent_tag,((size(
        __event_tag) - _holdremevent_tag)+ 1),__event_tag)))
   ELSE
    SET _remevent_tag = _holdremevent_tag
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ed_meds_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ed_meds_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE ed_meds_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ED Meds List",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ed_meds_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ed_meds_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE ed_meds_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_ed_meds_orders = f8 WITH noconstant(0.0), private
   DECLARE __ed_meds_orders = vc WITH noconstant(build2(m_info->ord_grps[ml_loop_cnt1].orders[
     ml_loop_cnt2].disp,char(0))), protect
   IF (bcontinue=0)
    SET _remed_meds_orders = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremed_meds_orders = _remed_meds_orders
   IF (_remed_meds_orders > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remed_meds_orders,((size(
        __ed_meds_orders) - _remed_meds_orders)+ 1),__ed_meds_orders)))
    SET drawheight_ed_meds_orders = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remed_meds_orders = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remed_meds_orders,((size(__ed_meds_orders
        ) - _remed_meds_orders)+ 1),__ed_meds_orders)))))
     SET _remed_meds_orders = (_remed_meds_orders+ rptsd->m_drawlength)
    ELSE
     SET _remed_meds_orders = 0
    ENDIF
    SET growsum = (growsum+ _remed_meds_orders)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_ed_meds_orders
   IF (ncalc=rpt_render
    AND _holdremed_meds_orders > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremed_meds_orders,((
       size(__ed_meds_orders) - _holdremed_meds_orders)+ 1),__ed_meds_orders)))
   ELSE
    SET _remed_meds_orders = _holdremed_meds_orders
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_procedures(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_proceduresabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_proceduresabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_procedures = f8 WITH noconstant(0.0), private
   DECLARE __procedures = vc WITH noconstant(build2(m_info->s_procedures,char(0))), protect
   IF (bcontinue=0)
    SET _remprocedures = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.219)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprocedures = _remprocedures
   IF (_remprocedures > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprocedures,((size(
        __procedures) - _remprocedures)+ 1),__procedures)))
    SET drawheight_procedures = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprocedures = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprocedures,((size(__procedures) -
       _remprocedures)+ 1),__procedures)))))
     SET _remprocedures = (_remprocedures+ rptsd->m_drawlength)
    ELSE
     SET _remprocedures = 0
    ENDIF
    SET growsum = (growsum+ _remprocedures)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.479
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedures Done",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.219)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_procedures
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
   IF (ncalc=rpt_render
    AND _holdremprocedures > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprocedures,((size(
        __procedures) - _holdremprocedures)+ 1),__procedures)))
   ELSE
    SET _remprocedures = _holdremprocedures
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.448)
   SET rptsd->m_width = 1.010
   SET rptsd->m_height = 0.229
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (becont=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Continued)",char(0)))
    ENDIF
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_treatments_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_treatments_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_treatments_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Your Treatment Plan and Precautions",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.375)
    SET rptsd->m_width = 1.010
    SET rptsd->m_height = 0.229
    IF (becont=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Continued)",char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_treatments_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_treatments_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_treatments_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_treatments = f8 WITH noconstant(0.0), private
   DECLARE __treatments = vc WITH noconstant(build2(m_info->ip_treatments[ip].s_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remtreatments = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtreatments = _remtreatments
   IF (_remtreatments > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtreatments,((size(
        __treatments) - _remtreatments)+ 1),__treatments)))
    SET drawheight_treatments = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtreatments = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtreatments,((size(__treatments) -
       _remtreatments)+ 1),__treatments)))))
     SET _remtreatments = (_remtreatments+ rptsd->m_drawlength)
    ELSE
     SET _remtreatments = 0
    ENDIF
    SET growsum = (growsum+ _remtreatments)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_treatments
   IF (ncalc=rpt_render
    AND _holdremtreatments > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtreatments,((size(
        __treatments) - _holdremtreatments)+ 1),__treatments)))
   ELSE
    SET _remtreatments = _holdremtreatments
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_cont_meds(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_cont_medsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_cont_medsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.250
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Continue your regular medications",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_discontinue(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_discontinueabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_discontinueabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_discontinue_taking = f8 WITH noconstant(0.0), private
   DECLARE __discontinue_taking = vc WITH noconstant(build2(m_info->s_discontinue,char(0))), protect
   IF (bcontinue=0)
    SET _remdiscontinue_taking = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdiscontinue_taking = _remdiscontinue_taking
   IF (_remdiscontinue_taking > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdiscontinue_taking,((
       size(__discontinue_taking) - _remdiscontinue_taking)+ 1),__discontinue_taking)))
    SET drawheight_discontinue_taking = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdiscontinue_taking = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdiscontinue_taking,((size(
        __discontinue_taking) - _remdiscontinue_taking)+ 1),__discontinue_taking)))))
     SET _remdiscontinue_taking = (_remdiscontinue_taking+ rptsd->m_drawlength)
    ELSE
     SET _remdiscontinue_taking = 0
    ENDIF
    SET growsum = (growsum+ _remdiscontinue_taking)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_discontinue_taking
   IF (ncalc=rpt_render
    AND _holdremdiscontinue_taking > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdiscontinue_taking,
       ((size(__discontinue_taking) - _holdremdiscontinue_taking)+ 1),__discontinue_taking)))
   ELSE
    SET _remdiscontinue_taking = _holdremdiscontinue_taking
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_drowsiness(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_drowsinessabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_drowsinessabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_drowsiness = f8 WITH noconstant(0.0), private
   DECLARE __drowsiness = vc WITH noconstant(build2(m_info->s_drowsiness,char(0))), protect
   IF (bcontinue=0)
    SET _remdrowsiness = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdrowsiness = _remdrowsiness
   IF (_remdrowsiness > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdrowsiness,((size(
        __drowsiness) - _remdrowsiness)+ 1),__drowsiness)))
    SET drawheight_drowsiness = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdrowsiness = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdrowsiness,((size(__drowsiness) -
       _remdrowsiness)+ 1),__drowsiness)))))
     SET _remdrowsiness = (_remdrowsiness+ rptsd->m_drawlength)
    ELSE
     SET _remdrowsiness = 0
    ENDIF
    SET growsum = (growsum+ _remdrowsiness)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_drowsiness
   IF (ncalc=rpt_render
    AND _holdremdrowsiness > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdrowsiness,((size(
        __drowsiness) - _holdremdrowsiness)+ 1),__drowsiness)))
   ELSE
    SET _remdrowsiness = _holdremdrowsiness
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_scripts_given(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_scripts_givenabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_scripts_givenabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_scripts_given = f8 WITH noconstant(0.0), private
   DECLARE __scripts_given = vc WITH noconstant(build2(m_info->s_scripts_given,char(0))), protect
   IF (bcontinue=0)
    SET _remscripts_given = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremscripts_given = _remscripts_given
   IF (_remscripts_given > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remscripts_given,((size(
        __scripts_given) - _remscripts_given)+ 1),__scripts_given)))
    SET drawheight_scripts_given = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remscripts_given = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remscripts_given,((size(__scripts_given)
        - _remscripts_given)+ 1),__scripts_given)))))
     SET _remscripts_given = (_remscripts_given+ rptsd->m_drawlength)
    ELSE
     SET _remscripts_given = 0
    ENDIF
    SET growsum = (growsum+ _remscripts_given)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_scripts_given
   IF (ncalc=rpt_render
    AND _holdremscripts_given > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremscripts_given,((
       size(__scripts_given) - _holdremscripts_given)+ 1),__scripts_given)))
   ELSE
    SET _remscripts_given = _holdremscripts_given
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_meds_included(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_meds_includedabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_meds_includedabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_meds_included = f8 WITH noconstant(0.0), private
   DECLARE __meds_included = vc WITH noconstant(build2(m_info->easyscripts[e].s_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remmeds_included = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmeds_included = _remmeds_included
   IF (_remmeds_included > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmeds_included,((size(
        __meds_included) - _remmeds_included)+ 1),__meds_included)))
    SET drawheight_meds_included = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmeds_included = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmeds_included,((size(__meds_included)
        - _remmeds_included)+ 1),__meds_included)))))
     SET _remmeds_included = (_remmeds_included+ rptsd->m_drawlength)
    ELSE
     SET _remmeds_included = 0
    ENDIF
    SET growsum = (growsum+ _remmeds_included)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_meds_included
   IF (ncalc=rpt_render
    AND _holdremmeds_included > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmeds_included,((
       size(__meds_included) - _holdremmeds_included)+ 1),__meds_included)))
   ELSE
    SET _remmeds_included = _holdremmeds_included
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_med_other(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_med_otherabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_med_otherabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_med_other = f8 WITH noconstant(0.0), private
   DECLARE __med_other = vc WITH noconstant(build2(m_info->s_med_info_other,char(0))), protect
   IF (bcontinue=0)
    SET _remmed_other = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmed_other = _remmed_other
   IF (_remmed_other > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmed_other,((size(
        __med_other) - _remmed_other)+ 1),__med_other)))
    SET drawheight_med_other = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmed_other = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmed_other,((size(__med_other) -
       _remmed_other)+ 1),__med_other)))))
     SET _remmed_other = (_remmed_other+ rptsd->m_drawlength)
    ELSE
     SET _remmed_other = 0
    ENDIF
    SET growsum = (growsum+ _remmed_other)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_med_other
   IF (ncalc=rpt_render
    AND _holdremmed_other > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmed_other,((size(
        __med_other) - _holdremmed_other)+ 1),__med_other)))
   ELSE
    SET _remmed_other = _holdremmed_other
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_micromedex(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_micromedexabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_micromedexabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_micromedex = f8 WITH noconstant(0.0), private
   DECLARE __micromedex = vc WITH noconstant(build2(m_info->s_micromedex,char(0))), protect
   IF (bcontinue=0)
    SET _remmicromedex = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 5.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmicromedex = _remmicromedex
   IF (_remmicromedex > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmicromedex,((size(
        __micromedex) - _remmicromedex)+ 1),__micromedex)))
    SET drawheight_micromedex = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmicromedex = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmicromedex,((size(__micromedex) -
       _remmicromedex)+ 1),__micromedex)))))
     SET _remmicromedex = (_remmicromedex+ rptsd->m_drawlength)
    ELSE
     SET _remmicromedex = 0
    ENDIF
    SET growsum = (growsum+ _remmicromedex)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 5.063
   SET rptsd->m_height = drawheight_micromedex
   IF (ncalc=rpt_render
    AND _holdremmicromedex > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmicromedex,((size(
        __micromedex) - _holdremmicromedex)+ 1),__micromedex)))
   ELSE
    SET _remmicromedex = _holdremmicromedex
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.063)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CareNotes given to you for:",char(0))
     )
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_precautions_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_precautions_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_precautions_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.677
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("What You Should Watch Out For",char(0
       )))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 1.010
    SET rptsd->m_height = 0.229
    IF (becont=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Continued)",char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_precautions_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_precautions_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_precautions_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_precautions = f8 WITH noconstant(0.0), private
   DECLARE __precautions = vc WITH noconstant(build2(m_info->precautions[p].s_text,char(0))), protect
   IF (bcontinue=0)
    SET _remprecautions = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprecautions = _remprecautions
   IF (_remprecautions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprecautions,((size(
        __precautions) - _remprecautions)+ 1),__precautions)))
    SET drawheight_precautions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprecautions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprecautions,((size(__precautions) -
       _remprecautions)+ 1),__precautions)))))
     SET _remprecautions = (_remprecautions+ rptsd->m_drawlength)
    ELSE
     SET _remprecautions = 0
    ENDIF
    SET growsum = (growsum+ _remprecautions)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_precautions
   IF (ncalc=rpt_render
    AND _holdremprecautions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprecautions,((size
       (__precautions) - _holdremprecautions)+ 1),__precautions)))
   ELSE
    SET _remprecautions = _holdremprecautions
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE prescriptions_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = prescriptions_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE prescriptions_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.677
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medications / Prescriptions",char(0))
     )
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE prescriptions_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = prescriptions_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE prescriptions_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_prescriptions = f8 WITH noconstant(0.0), private
   DECLARE __prescriptions = vc WITH noconstant(build2(m_info->prescriptions[p].s_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remprescriptions = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprescriptions = _remprescriptions
   IF (_remprescriptions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprescriptions,((size(
        __prescriptions) - _remprescriptions)+ 1),__prescriptions)))
    SET drawheight_prescriptions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprescriptions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprescriptions,((size(__prescriptions)
        - _remprescriptions)+ 1),__prescriptions)))))
     SET _remprescriptions = (_remprescriptions+ rptsd->m_drawlength)
    ELSE
     SET _remprescriptions = 0
    ENDIF
    SET growsum = (growsum+ _remprescriptions)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_prescriptions
   IF (ncalc=rpt_render
    AND _holdremprescriptions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprescriptions,((
       size(__prescriptions) - _holdremprescriptions)+ 1),__prescriptions)))
   ELSE
    SET _remprescriptions = _holdremprescriptions
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE rx_med_profile_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = rx_med_profile_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE rx_med_profile_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.677
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Include Rx from Med Profile",char(0))
     )
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE rx_med_profile_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = rx_med_profile_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE rx_med_profile_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_prescriptions = f8 WITH noconstant(0.0), private
   DECLARE __prescriptions = vc WITH noconstant(build2(m_info->prescriptions[p].s_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remprescriptions = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprescriptions = _remprescriptions
   IF (_remprescriptions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprescriptions,((size(
        __prescriptions) - _remprescriptions)+ 1),__prescriptions)))
    SET drawheight_prescriptions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprescriptions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprescriptions,((size(__prescriptions)
        - _remprescriptions)+ 1),__prescriptions)))))
     SET _remprescriptions = (_remprescriptions+ rptsd->m_drawlength)
    ELSE
     SET _remprescriptions = 0
    ENDIF
    SET growsum = (growsum+ _remprescriptions)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_prescriptions
   IF (ncalc=rpt_render
    AND _holdremprescriptions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprescriptions,((
       size(__prescriptions) - _holdremprescriptions)+ 1),__prescriptions)))
   ELSE
    SET _remprescriptions = _holdremprescriptions
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE note_given_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = note_given_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE note_given_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Work and/or Medical Excuse Note(s)",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE work_note_detail(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = work_note_detailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE work_note_detailabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.250
    SET rptsd->m_height = 0.406
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "A work note has been given to you.  Please see any additional instructions and follow-up that may be recommended.",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE excuse_note_detail(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = excuse_note_detailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE excuse_note_detailabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.250
    SET rptsd->m_height = 0.406
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "A Medical Excuse note has been given to you.  Please see any additional instructions and follow-up that may be recommended."
,
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_followup_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_followup_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_followup_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Recommended Follow-up",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 2.115)
    SET rptsd->m_width = 1.010
    SET rptsd->m_height = 0.229
    IF (becont=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Continued)",char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_md_followup(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_md_followupabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_md_followupabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_md_followup = f8 WITH noconstant(0.0), private
   DECLARE __md_followup = vc WITH noconstant(build2(m_info->md_follow_ups[f1].s_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remmd_followup = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmd_followup = _remmd_followup
   IF (_remmd_followup > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmd_followup,((size(
        __md_followup) - _remmd_followup)+ 1),__md_followup)))
    SET drawheight_md_followup = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmd_followup = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmd_followup,((size(__md_followup) -
       _remmd_followup)+ 1),__md_followup)))))
     SET _remmd_followup = (_remmd_followup+ rptsd->m_drawlength)
    ELSE
     SET _remmd_followup = 0
    ENDIF
    SET growsum = (growsum+ _remmd_followup)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_md_followup
   IF (ncalc=rpt_render
    AND _holdremmd_followup > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmd_followup,((size
       (__md_followup) - _holdremmd_followup)+ 1),__md_followup)))
   ELSE
    SET _remmd_followup = _holdremmd_followup
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_clinic_followup(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_clinic_followupabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_clinic_followupabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_clinic_followup = f8 WITH noconstant(0.0), private
   DECLARE __clinic_followup = vc WITH noconstant(build2(m_info->clinic_follow_ups[f2].s_text,char(0)
     )), protect
   IF (bcontinue=0)
    SET _remclinic_followup = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremclinic_followup = _remclinic_followup
   IF (_remclinic_followup > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remclinic_followup,((size
       (__clinic_followup) - _remclinic_followup)+ 1),__clinic_followup)))
    SET drawheight_clinic_followup = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remclinic_followup = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remclinic_followup,((size(
        __clinic_followup) - _remclinic_followup)+ 1),__clinic_followup)))))
     SET _remclinic_followup = (_remclinic_followup+ rptsd->m_drawlength)
    ELSE
     SET _remclinic_followup = 0
    ENDIF
    SET growsum = (growsum+ _remclinic_followup)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_clinic_followup
   IF (ncalc=rpt_render
    AND _holdremclinic_followup > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremclinic_followup,((
       size(__clinic_followup) - _holdremclinic_followup)+ 1),__clinic_followup)))
   ELSE
    SET _remclinic_followup = _holdremclinic_followup
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_addtl_followup(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_addtl_followupabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_addtl_followupabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_addtl_followup = f8 WITH noconstant(0.0), private
   DECLARE __addtl_followup = vc WITH noconstant(build2(m_info->add_follow_ups[f3].s_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remaddtl_followup = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremaddtl_followup = _remaddtl_followup
   IF (_remaddtl_followup > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remaddtl_followup,((size(
        __addtl_followup) - _remaddtl_followup)+ 1),__addtl_followup)))
    SET drawheight_addtl_followup = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remaddtl_followup = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remaddtl_followup,((size(__addtl_followup
        ) - _remaddtl_followup)+ 1),__addtl_followup)))))
     SET _remaddtl_followup = (_remaddtl_followup+ rptsd->m_drawlength)
    ELSE
     SET _remaddtl_followup = 0
    ENDIF
    SET growsum = (growsum+ _remaddtl_followup)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_addtl_followup
   IF (ncalc=rpt_render
    AND _holdremaddtl_followup > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremaddtl_followup,((
       size(__addtl_followup) - _holdremaddtl_followup)+ 1),__addtl_followup)))
   ELSE
    SET _remaddtl_followup = _holdremaddtl_followup
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_other_followup_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_other_followup_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_other_followup_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Other Follow-up Instructions",char(0)
      ))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 2.688)
    SET rptsd->m_width = 1.010
    SET rptsd->m_height = 0.229
    IF (becont=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Continued)",char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_ni_followup(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_ni_followupabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_ni_followupabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_ni_followup = f8 WITH noconstant(0.0), private
   DECLARE __ni_followup = vc WITH noconstant(build2(m_info->ni_follow_ups[ni].s_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _remni_followup = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremni_followup = _remni_followup
   IF (_remni_followup > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remni_followup,((size(
        __ni_followup) - _remni_followup)+ 1),__ni_followup)))
    SET drawheight_ni_followup = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remni_followup = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remni_followup,((size(__ni_followup) -
       _remni_followup)+ 1),__ni_followup)))))
     SET _remni_followup = (_remni_followup+ rptsd->m_drawlength)
    ELSE
     SET _remni_followup = 0
    ENDIF
    SET growsum = (growsum+ _remni_followup)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_ni_followup
   IF (ncalc=rpt_render
    AND _holdremni_followup > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremni_followup,((size
       (__ni_followup) - _holdremni_followup)+ 1),__ni_followup)))
   ELSE
    SET _remni_followup = _holdremni_followup
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_contact_numbers(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_contact_numbersabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_contact_numbersabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "If you need to find a doctor, you can call Baystate Health Link for a referral at 413-794-2255.",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_followup_phone(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_followup_phoneabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_followup_phoneabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE __ni_home_phone = vc WITH noconstant(build2(m_info->s_ni_home_phone,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "The following phone number will be used if we need to get back in touch with you:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ni_home_phone)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_addendums_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_addendums_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_addendums_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.042)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Additional Information",char(0)))
    SET rptsd->m_y = (offsety+ 0.042)
    SET rptsd->m_x = (offsetx+ 2.969)
    SET rptsd->m_width = 1.010
    SET rptsd->m_height = 0.229
    IF (becont=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Continued)",char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_addendums_title(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_addendums_titleabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_addendums_titleabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __addendum_title = vc WITH noconstant(build2(m_info->addendums[a].s_title,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.250
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__addendum_title)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_addendums_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_addendums_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_addendums_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_addendum_text = f8 WITH noconstant(0.0), private
   DECLARE __addendum_text = vc WITH noconstant(build2(m_info->addendums[a].s_text,char(0))), protect
   IF (bcontinue=0)
    SET _remaddendum_text = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremaddendum_text = _remaddendum_text
   IF (_remaddendum_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remaddendum_text,((size(
        __addendum_text) - _remaddendum_text)+ 1),__addendum_text)))
    SET drawheight_addendum_text = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remaddendum_text = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remaddendum_text,((size(__addendum_text)
        - _remaddendum_text)+ 1),__addendum_text)))))
     SET _remaddendum_text = (_remaddendum_text+ rptsd->m_drawlength)
    ELSE
     SET _remaddendum_text = 0
    ENDIF
    SET growsum = (growsum+ _remaddendum_text)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_addendum_text
   IF (ncalc=rpt_render
    AND _holdremaddendum_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremaddendum_text,((
       size(__addendum_text) - _holdremaddendum_text)+ 1),__addendum_text)))
   ELSE
    SET _remaddendum_text = _holdremaddendum_text
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_disclaimers(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_disclaimersabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_disclaimersabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(4.110000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.323
    SET rptsd->m_height = 0.604
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "The treatment you were given was based on information available while you were in the ED.  If further treatment",
       " with your primary care physician or another doctor is recommended, it is important for you to keep the appointm",
       "ent."),char(0)))
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.323
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Remember to show this form to the doctor you follow-up with!",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.479
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Call your doctor or return to the Emergency Department immediately if your condition worsens, fails to improve,",
       " or new symptoms develop."),char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "If you need to find a doctor, you can call Baystate Health Link for a referral at 413-794-2255.",
      char(0)))
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.948
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "You have the right to receive a written discharge plan and meet with the Emergency Department physician and nur",
       "se/discharge planner if you disagree with the written discharge plan.  If you have any questions regarding these",
       " instructions after you leave, please call us and we will be happy to assist you:"),char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.479
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "X-ray readings are preliminary.  A radiology specialist will review your films.  If you need copies of your X-r",
       "ays, please call the Film Library at 413-794-4625."),char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 3.688)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.427
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "This form may not contain all patient information.  Please refer to the electronic and written chart.",
      char(0)))
    SET rptsd->m_y = (offsety+ 2.625)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Daily 9:00 am - 4:00 pm call: 413-794-4774",char(0)))
    SET rptsd->m_y = (offsety+ 2.875)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "From 4:00 pm - 9:00 am call: 413-794-3233",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patient_info_disclaimer(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_info_disclaimerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patient_info_disclaimerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.427
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "This form may not contain all patient information.  Please refer to the electronic and written chart.",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_hosp_signatures(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_hosp_signaturesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_hosp_signaturesabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.948
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "SIGNATURE OF PATIENT OR REPRESENTATIVE",char(0)))
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 6.542)
    SET rptsd->m_width = 0.979
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DATE",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen21s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.698),(offsetx+ 4.750),(offsety+
     0.698))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.521),(offsety+ 0.698),(offsetx+ 7.500),(offsety+
     0.698))
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 4.750
    SET rptsd->m_height = 0.448
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "INSTRUCTIONS GIVEN TO PATIENT OR REPRESENTATIVE AND WITNESSED BY",char(0)))
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 0.979
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DATE",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen21s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.511),(offsetx+ 4.750),(offsety+
     1.511))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.521),(offsety+ 1.511),(offsetx+ 7.500),(offsety+
     1.511))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.375),(offsety+ 0.198),(offsetx+ 7.500),(offsety+
     0.198))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.938
    SET rptsd->m_height = 0.250
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "If you need to contact me, please call me at this telephone number:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE page_foot(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE page_footabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.470000), private
   DECLARE __page_num = vc WITH noconstant(build2(build2("PAGE ",trim(build2(cur_page),3)),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (curendreport=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("--- END OF REPORT ---",char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__page_num)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_ED_DISCHARGE_INST"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.00
   SET rptreport->m_marginbottom = 0.25
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 18
   SET rptfont->m_bold = rpt_on
   SET _helvetica18b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_off
   SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _helvetica12bu0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.021
   SET _pen21s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 DECLARE mf_signed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15750,"SIGNED"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_data_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15752,"DATA"))
 DECLARE mf_cell_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"MOBILE"))
 DECLARE mf_home_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_work_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_printer_name = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_string = vc WITH protect, noconstant(" ")
 DECLARE ml_beg_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_copy_desc_text = vc WITH protect, noconstant(" ")
 DECLARE becont = i4 WITH protect, noconstant(0)
 DECLARE mn_header_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_other_rx_ind = i2 WITH protect, noconstant(0)
 DECLARE sbr_process_blob(s_blob_in=vc,f_comp_cd=f8) = vc
 IF (validate(request->visit,"Z") != "Z")
  SET printer_name = request->output_device
  SET mf_encntr_id = request->visit[1].encntr_id
 ELSEIF (cnvtreal( $F_ENCNTR_ID) > 0.0)
  SET printer_name =  $OUTDEV
  SET mf_encntr_id = cnvtreal( $F_ENCNTR_ID)
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_event_prsnl cep,
   encntr_alias ea,
   encounter e,
   person p,
   prsnl pr,
   scr_pattern sp,
   scd_story ss,
   scd_story_pattern ssp
  PLAN (ss
   WHERE ss.encounter_id=mf_encntr_id
    AND ss.story_completion_status_cd=mf_signed_cd)
   JOIN (ssp
   WHERE ssp.scd_story_id=ss.scd_story_id)
   JOIN (sp
   WHERE sp.scr_pattern_id=ssp.scr_pattern_id
    AND sp.cki_source="BHS_MA"
    AND sp.cki_identifier="EP BH ED DISCHARGE INSTRUCTIONS")
   JOIN (e
   WHERE e.encntr_id=ss.encounter_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ce
   WHERE ce.event_id=ss.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd))
   JOIN (cep
   WHERE cep.event_id=ce.event_id
    AND cep.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ((cep.action_type_cd+ 0)=mf_sign_cd)
    AND ((cep.action_status_cd+ 0)=mf_completed_cd))
   JOIN (pr
   WHERE pr.person_id=cep.action_prsnl_id)
  ORDER BY ss.active_status_dt_tm DESC, ss.scd_story_id, cep.action_dt_tm DESC,
   pr.person_id
  HEAD ss.scd_story_id
   IF ((m_info->scd_story_id <= 0.00))
    CALL echo(build2("***** date: ",trim(format(ss.active_status_dt_tm,"dd-mmm-yyyy hh:mm;;d")))),
    m_info->s_fin_nbr = trim(ea.alias,4), m_info->s_patient_name = trim(p.name_full_formatted,3),
    m_info->f_person_id = p.person_id, m_info->s_dob = trim(format(p.birth_dt_tm,"mm-dd-yyyy;;d")),
    m_info->create_dt_tm = ss.active_status_dt_tm,
    m_info->s_visit_date = trim(format(e.active_status_dt_tm,"mm-dd-yyyy;;d")), m_info->scd_story_id
     = ss.scd_story_id, m_info->event_id = ss.event_id
    IF (trim(m_info->s_disch_phys,3) <= " "
     AND pr.physician_ind=1)
     m_info->s_disch_phys = trim(pr.name_full_formatted,3)
    ENDIF
    IF (trim(m_info->s_disch_nurse,3) <= " "
     AND pr.physician_ind=0)
     m_info->s_disch_nurse = trim(pr.name_full_formatted,3)
    ENDIF
   ELSEIF ((ss.scd_story_id=m_info->scd_story_id))
    IF (trim(m_info->s_disch_phys,3) <= " "
     AND pr.physician_ind=1)
     m_info->s_disch_phys = trim(pr.name_full_formatted,3)
    ENDIF
   ENDIF
  DETAIL
   CALL echo(build2("***** STORY ID: ",m_info->scd_story_id))
   IF ((ss.scd_story_id=m_info->scd_story_id)
    AND trim(m_info->s_disch_phys) <= " "
    AND pr.physician_ind=1)
    m_info->s_disch_phys = trim(pr.name_full_formatted,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM scd_paragraph sp,
   scr_paragraph_type spt,
   scd_sentence ss,
   scd_term st1,
   scr_term_text stt1,
   scd_term_data std1,
   scd_term st2,
   scr_term_text stt2,
   scd_term_data std2,
   scd_term st3,
   scr_term_text stt3,
   scd_term_data std3
  PLAN (sp
   WHERE (sp.scd_story_id=m_info->scd_story_id))
   JOIN (spt
   WHERE spt.scr_paragraph_type_id=sp.scr_paragraph_type_id)
   JOIN (ss
   WHERE ss.scd_story_id=sp.scd_story_id
    AND ss.scd_paragraph_id=sp.scd_paragraph_id
    AND ss.active_ind=1)
   JOIN (st1
   WHERE st1.scd_story_id=sp.scd_story_id
    AND st1.scd_sentence_id=ss.scd_sentence_id
    AND ((((st1.parent_scd_term_id+ 0)=0.00)) OR (((st1.parent_scd_term_id+ 0)=(st1.scd_term_id+ 0))
   )) )
   JOIN (stt1
   WHERE st1.scr_term_id=stt1.scr_term_id)
   JOIN (std1
   WHERE std1.scd_term_data_id=outerjoin(st1.scd_term_data_id))
   JOIN (st2
   WHERE st2.parent_scd_term_id=outerjoin(st1.scd_term_id))
   JOIN (stt2
   WHERE stt2.scr_term_id=outerjoin(st2.scr_term_id))
   JOIN (std2
   WHERE std2.scd_term_data_id=outerjoin(st2.scd_term_data_id))
   JOIN (st3
   WHERE st3.parent_scd_term_id=outerjoin(st2.scd_term_id))
   JOIN (stt3
   WHERE stt3.scr_term_id=outerjoin(st3.scr_term_id))
   JOIN (std3
   WHERE std3.scd_term_data_id=outerjoin(st3.scd_term_data_id))
  ORDER BY sp.sequence_number, ss.sequence_number, st1.sequence_number,
   st2.sequence_number, st3.sequence_number
  DETAIL
   IF (spt.display="Visit Information")
    CALL echo("visit information")
    IF (stt1.text_representation="Patient treated for")
     CALL echo("patient treated for")
     IF (st3.scd_term_id > 0.00
      AND std3.scd_term_data_id=0)
      CALL echo("treated for 1")
      IF (trim(m_info->s_treated_for,3) <= " ")
       m_info->s_treated_for = trim(stt3.text_representation,3)
      ELSE
       m_info->s_treated_for = build2(m_info->s_treated_for,", ",trim(stt3.text_representation,3))
      ENDIF
     ELSEIF (st2.scd_term_id > 0.00
      AND std2.fkey_entity_name="SCD_BLOB"
      AND std2.scd_term_data_key="RTF")
      CALL echo("treated for 2"), m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,
       m_info->b_cnt),
      m_info->blobs[m_info->b_cnt].blob_parent = "treated_for", m_info->blobs[m_info->b_cnt].
      blob_slot = 0, m_info->blobs[m_info->b_cnt].f_blob_id = std2.fkey_id
     ELSEIF (std2.scd_term_data_id > 0.00
      AND std2.scd_term_data_type_cd=mf_data_cd
      AND trim(std2.value_text) > " ")
      CALL echo("treated for 3")
      IF (trim(m_info->s_treated_for,3) <= " ")
       m_info->s_treated_for = trim(std2.value_text,3)
      ELSE
       m_info->s_treated_for = build2(m_info->s_treated_for,", ",trim(std2.value_text,3))
      ENDIF
     ELSEIF (trim(stt2.text_representation)="FREETEXT"
      AND std2.scd_term_data_id > 0.00
      AND trim(std2.fkey_entity_name)="SCD_BLOB"
      AND std2.scd_term_data_type_cd=mf_data_cd)
      CALL echo("treated for 5 FREETEXT"), m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(
       m_info->blobs,m_info->b_cnt),
      m_info->blobs[m_info->b_cnt].blob_parent = "treated_for", m_info->blobs[m_info->b_cnt].
      blob_slot = 0, m_info->blobs[m_info->b_cnt].f_blob_id = std2.fkey_id
     ELSEIF (st3.scd_term_id > 0.00
      AND std3.fkey_entity_name="SCD_BLOB"
      AND std3.scd_term_data_key="RTF")
      CALL echo("treated for 6"), m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,
       m_info->b_cnt),
      m_info->blobs[m_info->b_cnt].blob_parent = "treated_for", m_info->blobs[m_info->b_cnt].
      blob_slot = 0, m_info->blobs[m_info->b_cnt].f_blob_id = std3.fkey_id
     ENDIF
    ELSEIF (stt1.text_representation="Free Text Sentence"
     AND st1.scd_term_id > 0.00
     AND st1.scd_term_data_id > 0.00
     AND std1.fkey_entity_name="SCD_BLOB"
     AND std1.scd_term_data_key="RTF")
     CALL echo("treated for 4"), m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,
      m_info->b_cnt),
     m_info->blobs[m_info->b_cnt].blob_parent = "treated_for", m_info->blobs[m_info->b_cnt].blob_slot
      = 0, m_info->blobs[m_info->b_cnt].f_blob_id = std1.fkey_id
    ENDIF
   ELSEIF (spt.display="Results Review")
    CALL echo("RESULTS REVIEW")
    IF (stt1.display="BMC Results last 24 hours"
     AND std2.fkey_entity_name="CLINICAL_EVENT")
     CALL echo("BMC RESULTS LAST 24 HOURS - CLINICAL_EVENTS"), m_info->vu_cnt = (m_info->vu_cnt+ 1),
     stat = alterlist(m_info->vr_unsorted,m_info->vu_cnt),
     m_info->vr_unsorted[m_info->vu_cnt].event_id = std2.fkey_id
     CASE (trim(cnvtupper(stt2.display)))
      OF "LABORATORY RESULTS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 1,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Laboratory"
      OF "BLOOD COUNT":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 2,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Blood Count\Diff"
      OF "CHEMISTRY":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 3,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Chemistry"
      OF "CARDIAC LABS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 4,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Cardiac Labs"
      OF "URINALYSIS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 5,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Urinalysis"
      OF "BACTERIOLOGY":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 6,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Bacteriology"
      OF "RADIOLOGY RESULTS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 7,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Radiology"
      OF "MEDICATIONS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 8,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Medications"
      OF "IV":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 9,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "IV"
      OF "IMMUNIZATIONS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 10,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Immunizations"
      OF "FREETEXT":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 11,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Other"
      ELSE
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 12,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Other"
     ENDCASE
    ELSEIF (stt1.display="BMC Results last 24 hours"
     AND stt3.display="OTHER"
     AND std3.scd_term_data_id > 0.00
     AND std3.scd_term_data_type_cd=mf_data_cd)
     m_info->vu_cnt = (m_info->vu_cnt+ 1), stat = alterlist(m_info->vr_unsorted,m_info->vu_cnt),
     m_info->vr_unsorted[m_info->vu_cnt].s_text = trim(std3.value_text,3),
     m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 7
    ELSEIF (stt1.display="BMC Results last 24 hours"
     AND std2.fkey_entity_name="SCD_BLOB"
     AND 1=3)
     m_info->vu_cnt = (m_info->vu_cnt+ 1), stat = alterlist(m_info->vr_unsorted,m_info->vu_cnt),
     m_info->vr_unsorted[m_info->vu_cnt].f_blob_id = std2.fkey_id
     CASE (trim(cnvtupper(stt2.display)))
      OF "LABORATORY RESULTS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 1,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Laboratory"
      OF "BLOOD COUNT":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 2,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Blood Count\Diff"
      OF "CHEMISTRY":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 3,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Chemistry"
      OF "CARDIAC LABS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 4,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Cardiac Labs"
      OF "URINALYSIS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 5,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Urinalysis"
      OF "BACTERIOLOGY":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 6,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Bacteriology"
      OF "RADIOLOGY RESULTS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 7,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Radiology"
      OF "MEDICATIONS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 8,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Medications"
      OF "IV":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 9,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "IV"
      OF "IMMUNIZATIONS":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 10,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Immunizations"
      OF "FREETEXT":
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 11,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Other"
      ELSE
       m_info->vr_unsorted[m_info->vu_cnt].n_result_type = 12,m_info->vr_unsorted[m_info->vu_cnt].
       s_result_type = "Other"
     ENDCASE
     m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->
     blobs[m_info->b_cnt].blob_parent = "cur_visit_results",
     m_info->blobs[m_info->b_cnt].blob_slot = m_info->vu_cnt, m_info->blobs[m_info->b_cnt].f_blob_id
      = std3.fkey_id
    ELSEIF (trim(cnvtupper(stt1.display))="ADDITIONAL TEST INFORMATION =="
     AND std1.scd_term_data_id > 0.00
     AND std1.fkey_entity_name="SCD_BLOB"
     AND std1.scd_term_data_type_cd=mf_data_cd)
     m_info->vu_cnt = (m_info->vu_cnt+ 1), stat = alterlist(m_info->vr_unsorted,m_info->vu_cnt),
     m_info->vr_unsorted[m_info->vu_cnt].f_blob_id = std1.fkey_id,
     m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->
     blobs[m_info->b_cnt].blob_parent = "cur_visit_results",
     m_info->blobs[m_info->b_cnt].blob_slot = m_info->vu_cnt, m_info->blobs[m_info->b_cnt].f_blob_id
      = std1.fkey_id
    ENDIF
   ELSEIF (trim(spt.display)="")
    IF (cnvtupper(stt2.display)="PROCEDURES")
     IF (st3.scd_term_id > 0.00
      AND st3.scd_term_data_id <= 0.00)
      IF (trim(m_info->s_procedures,3) <= " ")
       m_info->s_procedures = trim(stt3.text_representation,3)
      ELSE
       m_info->s_procedures = build2(m_info->s_procedures,", ",trim(stt3.text_representation,3))
      ENDIF
     ELSEIF (std3.scd_term_data_id > 0.00
      AND std3.scd_term_data_type_cd=mf_data_cd)
      IF (cnvtupper(stt3.text_representation)="RETURN IN == DAYS FOR SUTURE/STAPLE REMOVAL")
       IF (trim(m_info->s_procedures) <= " ")
        m_info->s_procedures = build2("return in ",trim(std3.value_text),
         " days for suture/staple removal")
       ELSE
        m_info->s_procedures = build2(m_info->s_procedures,", return in ",trim(std3.value_text),
         " days for suture/staple removal")
       ENDIF
      ELSEIF (cnvtupper(stt3.text_representation)="== SUTURES/STAPLES TO REMOVE")
       CALL echo("sutures/staples to remove")
       IF (trim(m_info->s_procedures) <= " ")
        CALL echo("suture 1"), m_info->s_procedures = build2(trim(std3.value_text),
         " sutures/staples to remove")
       ELSE
        CALL echo("suture 2"), m_info->s_procedures = build2(m_info->s_procedures,", ",trim(std3
          .value_text)," sutures/staples to remove")
       ENDIF
      ELSEIF (trim(m_info->s_procedures) <= " ")
       m_info->s_procedures = trim(std3.value_text,3)
      ELSE
       m_info->s_procedures = build2(m_info->s_procedures,", ",trim(std3.value_text,3))
      ENDIF
     ELSEIF (std3.fkey_entity_name="SCD_BLOB")
      m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->
      blobs[m_info->b_cnt].blob_parent = "procedures",
      m_info->blobs[m_info->b_cnt].blob_slot = 0, m_info->blobs[m_info->b_cnt].f_blob_id = std3
      .fkey_id
     ENDIF
    ELSEIF (stt1.display="TREATMENT PLAN AND PRECAUTIONS"
     AND std1.fkey_entity_name="SCD_BLOB"
     AND std1.scd_term_data_type_cd=mf_data_cd)
     m_info->ipt_cnt = (m_info->ipt_cnt+ 1), stat = alterlist(m_info->ip_treatments,m_info->ipt_cnt),
     m_info->ip_treatments[m_info->ipt_cnt].f_blob_id = std1.fkey_id,
     m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->
     blobs[m_info->b_cnt].blob_parent = "ip_treatments",
     m_info->blobs[m_info->b_cnt].blob_slot = m_info->ipt_cnt, m_info->blobs[m_info->b_cnt].f_blob_id
      = std1.fkey_id
    ELSEIF (stt1.display="INCLUDE Rx FROM MED PROFILE"
     AND std1.fkey_entity_name="SCD_BLOB")
     stat = alterlist(m_info->prescriptions,(size(m_info->prescriptions,5)+ 1)), m_info->b_cnt = (
     m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt),
     m_info->blobs[m_info->b_cnt].blob_parent = "prescriptions", m_info->blobs[m_info->b_cnt].
     blob_slot = size(m_info->prescriptions,5), m_info->blobs[m_info->b_cnt].f_blob_id = std1.fkey_id
    ELSEIF (stt2.display="EASYSCRIPT"
     AND std2.fkey_entity_name="ORDERS")
     ms_tmp_string = trim(replace(std2.value_text,")(",") ("),3)
     WHILE (findstring("  ",ms_tmp_string) > 0)
       ms_tmp_string = trim(replace(ms_tmp_string,"  "," ",0),3)
     ENDWHILE
     m_info->ez_cnt = (m_info->ez_cnt+ 1), stat = alterlist(m_info->easyscripts,m_info->ez_cnt),
     m_info->easyscripts[m_info->ez_cnt].s_text = ms_tmp_string
    ELSEIF (cnvtupper(stt1.display)="WRITE NEW PRESCRIPTIONS"
     AND std1.scd_term_data_id > 0.00
     AND std1.scd_term_data_key="ORDERRTF")
     stat = alterlist(m_info->prescriptions,(size(m_info->prescriptions,5)+ 1)), m_info->b_cnt = (
     m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt),
     m_info->blobs[m_info->b_cnt].blob_parent = "prescriptions", m_info->blobs[m_info->b_cnt].
     blob_slot = size(m_info->prescriptions,5), m_info->blobs[m_info->b_cnt].f_blob_id = std1.fkey_id
    ELSEIF (cnvtupper(stt1.display)="INCLUDE OTHER PRESCRIPTIONS"
     AND std1.scd_term_data_id > 0.00
     AND std1.fkey_entity_name="SCD_BLOB"
     AND cnvtupper(std1.scd_term_data_key) IN ("INCLUDED", "MEDSRTF"))
     stat = alterlist(m_info->prescriptions,(size(m_info->prescriptions,5)+ 1)), m_info->b_cnt = (
     m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt),
     m_info->blobs[m_info->b_cnt].blob_parent = "prescriptions", m_info->blobs[m_info->b_cnt].
     blob_slot = size(m_info->prescriptions,5), m_info->blobs[m_info->b_cnt].f_blob_id = std1.fkey_id
    ELSEIF (stt1.display="OTHER PRESCRIPTION INFO =="
     AND std1.scd_term_data_type_cd=mf_data_cd
     AND std1.scd_term_data_id > 0.00
     AND std1.fkey_entity_name="SCD_BLOB")
     stat = alterlist(m_info->prescriptions,(size(m_info->prescriptions,5)+ 1)), m_info->b_cnt = (
     m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt),
     m_info->blobs[m_info->b_cnt].blob_parent = "otherprescriptions", m_info->blobs[m_info->b_cnt].
     blob_slot = size(m_info->prescriptions,5), m_info->blobs[m_info->b_cnt].f_blob_id = std1.fkey_id
    ELSEIF (trim(cnvtupper(stt2.display))="MEDICATION INFORMATION")
     CALL echo("MEDICATION INFORMATION")
     IF (stt1.display="PRESCRIPTIONS"
      AND std1.scd_term_data_key="ORDERRTF")
      CALL echo("PRESCRIPTIONS, ORDERRTF"), stat = alterlist(m_info->prescriptions,(size(m_info->
        prescriptions,5)+ 1)), m_info->b_cnt = (m_info->b_cnt+ 1),
      stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->blobs[m_info->b_cnt].blob_parent =
      "prescriptions", m_info->blobs[m_info->b_cnt].blob_slot = size(m_info->prescriptions,5),
      m_info->blobs[m_info->b_cnt].f_blob_id = std1.fkey_id
     ELSEIF (stt3.display="OTHER"
      AND std3.fkey_entity_name="SCD_BLOB"
      AND std3.scd_term_data_key="RTF")
      CALL echo("OTHER, SCD_BLOB"), stat = alterlist(m_info->prescriptions,(size(m_info->
        prescriptions,5)+ 1)), m_info->b_cnt = (m_info->b_cnt+ 1),
      stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->blobs[m_info->b_cnt].blob_parent =
      "prescriptions", m_info->blobs[m_info->b_cnt].blob_slot = size(m_info->prescriptions,5),
      m_info->blobs[m_info->b_cnt].f_blob_id = std3.fkey_id
     ENDIF
     IF (trim(cnvtupper(stt3.display))="CONTINUE YOUR REGULAR MEDICATIONS")
      CALL echo("CONTINUE YOUR REGULAR MEDICATIONS"), m_info->cont_med_ind = 1
     ELSEIF (trim(cnvtupper(stt3.display)) IN ("DISCONTINUE TAKING ===",
     "DISCONTINUE TAKING (FREE TEXT) ==", "DISCONTINUE TAKING ==")
      AND std3.scd_term_data_id > 0.00
      AND std3.scd_term_data_type_cd=mf_data_cd)
      CALL echo("discontinue taking")
      IF (trim(m_info->s_discontinue) <= " ")
       m_info->s_discontinue = build2("Discontinue taking ",trim(std3.value_text,3))
      ELSE
       m_info->s_discontinue = build2(m_info->s_discontinue,", ",trim(std3.value_text,3))
      ENDIF
     ELSEIF (((stt3.display="=== may cause drowsiness") OR (stt3.display=
     "== causes drowsiness (freetext)"))
      AND std3.scd_term_data_id > 0.00
      AND std3.scd_term_data_type_cd=mf_data_cd)
      IF (trim(m_info->s_drowsiness,3) <= " ")
       m_info->s_drowsiness = trim(std3.value_text,3)
      ELSE
       m_info->s_drowsiness = build2(m_info->s_drowsiness,", ",trim(std3.value_text,3))
      ENDIF
     ELSEIF (stt3.display="OTHER"
      AND std3.scd_term_data_id > 0.00
      AND std3.scd_term_data_type_cd=mf_data_cd)
      IF (trim(m_info->med_info_other,3) <= " ")
       m_info->med_info_other = trim(std3.value_text,3)
      ELSE
       m_info->med_info_other = build2(m_info->med_info_other,", ",trim(std3.value_text,3))
      ENDIF
     ENDIF
    ELSEIF (stt1.display="Micromedex*"
     AND std1.scd_term_data_id > 0.00)
     IF (trim(m_info->s_micromedex,3) <= " ")
      m_info->s_micromedex = trim(std1.value_text,3)
     ELSE
      m_info->s_micromedex = build2(m_info->s_micromedex,", ",trim(std1.value_text,3))
     ENDIF
    ELSEIF (cnvtupper(stt1.display)="NOTES GIVEN TO PATIENT")
     IF (cnvtupper(stt3.display)="WORK NOTE")
      m_info->work_note_ind = 1
     ELSEIF (cnvtupper(stt3.display)="MEDICAL EXCUSE NOTE")
      m_info->n_excuse_note_ind = 1
     ENDIF
    ELSEIF (stt1.display="PRECAUTIONS"
     AND std1.fkey_entity_name="SCD_BLOB"
     AND std1.scd_term_data_type_cd=mf_data_cd)
     m_info->p_cnt = (m_info->p_cnt+ 1), stat = alterlist(m_info->precautions,m_info->p_cnt), m_info
     ->precautions[m_info->p_cnt].f_blob_id = std1.fkey_id,
     m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->
     blobs[m_info->b_cnt].blob_parent = "precautions",
     m_info->blobs[m_info->b_cnt].blob_slot = m_info->p_cnt, m_info->blobs[m_info->b_cnt].f_blob_id
      = std1.fkey_id
    ELSEIF (cnvtupper(stt1.display)="FOLLOW-UP")
     IF (cnvtupper(stt3.display)="SELECT PHYSICIAN"
      AND std3.scd_term_data_id > 0.00)
      CALL echo("here1 select physician")
      IF ((((m_info->f1_cnt=0)) OR (trim(m_info->md_follow_ups[m_info->f1_cnt].name) > " "
       AND trim(m_info->md_follow_ups[m_info->f1_cnt].time) > " ")) )
       m_info->f1_cnt = (m_info->f1_cnt+ 1), stat = alterlist(m_info->md_follow_ups,m_info->f1_cnt)
      ENDIF
      m_info->md_follow_ups[m_info->f1_cnt].name = trim(std3.value_text,3),
      CALL echo(std3.value_text)
      IF (stt3.display="phone number ==="
       AND std3.scd_term_data_id > 0.00)
       CALL echo("here1a phone number ==="), m_info->md_follow_ups[m_info->f1_cnt].phone = trim(std3
        .value_text,3)
      ENDIF
     ELSEIF (cnvtupper(stt2.display) IN ("WITH", "SEE YOUR DOCTOR")
      AND std2.scd_term_data_id <= 0)
      CALL echo("here2 with, see your doctor")
      IF ((((m_info->f1_cnt=0)) OR (trim(m_info->md_follow_ups[m_info->f1_cnt].name) > " "
       AND trim(m_info->md_follow_ups[m_info->f1_cnt].time) > " ")) )
       m_info->f1_cnt = (m_info->f1_cnt+ 1), stat = alterlist(m_info->md_follow_ups,m_info->f1_cnt)
       IF (trim(cnvtupper(stt3.display))="YOUR DOCTOR")
        m_info->md_follow_ups[m_info->f1_cnt].name = "your doctor"
       ENDIF
      ENDIF
      IF (stt3.display="phone number ==="
       AND std3.scd_term_data_id > 0.00)
       CALL echo("here2a phone number ==="), m_info->md_follow_ups[m_info->f1_cnt].phone = trim(std3
        .value_text,3)
      ELSEIF (stt3.display="OTHER"
       AND std3.fkey_entity_name="SCD_BLOB")
       CALL echo("here2c OTHER"), m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,
        m_info->b_cnt),
       m_info->blobs[m_info->b_cnt].blob_parent = "md_follow_ups", m_info->blobs[m_info->b_cnt].
       blob_slot = m_info->f1_cnt, m_info->blobs[m_info->b_cnt].f_blob_id = std3.fkey_id
      ENDIF
     ELSEIF (trim(cnvtupper(stt2.display)) IN ("PHONE NUMBER", "PHONE NUMBER =="))
      CALL echo("here3 phone number")
      IF (trim(std3.value_text) > " ")
       m_info->md_follow_ups[m_info->f1_cnt].phone = trim(std3.value_text),
       CALL echo(std3.value_text)
      ELSEIF (trim(std2.value_text) > " ")
       m_info->md_follow_ups[m_info->f1_cnt].phone = trim(std2.value_text),
       CALL echo(std2.value_text)
      ENDIF
     ELSEIF (cnvtupper(stt2.display) IN ("WHEN", "RECOMMENDED FOLLOW-UP TIME"))
      CALL echo("here4")
      IF (cnvtupper(stt3.display)="IN === DAYS"
       AND std3.scd_term_data_id > 0.00)
       CALL echo("here5")
       IF ((((m_info->f1_cnt=0)) OR (trim(m_info->md_follow_ups[m_info->f1_cnt].time) > " ")) )
        m_info->f1_cnt = (m_info->f1_cnt+ 1), stat = alterlist(m_info->md_follow_ups,m_info->f1_cnt)
       ENDIF
       m_info->md_follow_ups[m_info->f1_cnt].time = build2("in ",trim(std3.value_text,3)," days"),
       CALL echo(build2("time: ",m_info->md_follow_ups[m_info->f1_cnt].time))
      ELSEIF (cnvtupper(stt3.display)="OTHER"
       AND std3.scd_term_data_id > 0.00
       AND std3.scd_term_data_type_cd=mf_data_cd
       AND std3.fkey_entity_name != "SCD_BLOB")
       CALL echo("here6")
       IF ((((m_info->f1_cnt=0)) OR (trim(m_info->md_follow_ups[m_info->f1_cnt].time) > " ")) )
        m_info->f1_cnt = (m_info->f1_cnt+ 1), stat = alterlist(m_info->md_follow_ups,m_info->f1_cnt)
       ENDIF
       m_info->md_follow_ups[m_info->f1_cnt].time = trim(std3.value_text,3)
      ELSEIF (cnvtupper(stt3.display)="OTHER"
       AND std3.scd_term_data_id > 0.00
       AND std3.fkey_entity_name="SCD_BLOB"
       AND std3.scd_term_data_type_cd=mf_data_cd)
       CALL echo("here 6a")
       IF ((((m_info->f1_cnt=0)) OR (trim(m_info->md_follow_ups[m_info->f1_cnt].time) > " ")) )
        m_info->f1_cnt = (m_info->f1_cnt+ 1), stat = alterlist(m_info->md_follow_ups,m_info->f1_cnt)
       ENDIF
       m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->
       blobs[m_info->b_cnt].blob_parent = "md_follow_ups",
       m_info->blobs[m_info->b_cnt].blob_slot = m_info->f1_cnt, m_info->blobs[m_info->b_cnt].
       f_blob_id = std3.fkey_id
      ELSEIF (std3.scd_term_data_id <= 0.00)
       CALL echo("here7"), m_info->md_follow_ups[m_info->f1_cnt].time = trim(stt3.text_representation,
        3),
       CALL echo(stt3.text_representation)
      ENDIF
     ENDIF
    ELSEIF (cnvtupper(stt1.display)="CLINIC FOLLOW-UP")
     CALL echo("here8 CLINIC FU")
     IF (cnvtupper(stt2.display)="CLINICS"
      AND std3.scd_term_data_key != "BlockedTextData1")
      CALL echo("here9 CLINICS")
      IF (st3.scd_term_id > 0.00)
       CALL echo("here10 3.term_id > 0"), m_info->f2_cnt = (m_info->f2_cnt+ 1), stat = alterlist(
        m_info->clinic_follow_ups,m_info->f2_cnt)
       IF (std3.fkey_entity_name="SCD_BLOB"
        AND stt3.display="OTHER")
        CALL echo("here10a blob and OTHER"), m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(
         m_info->blobs,m_info->b_cnt),
        m_info->blobs[m_info->b_cnt].blob_parent = "clinic_follow_ups", m_info->blobs[m_info->b_cnt].
        blob_slot = m_info->f2_cnt, m_info->blobs[m_info->b_cnt].f_blob_id = std3.fkey_id
       ELSEIF (std3.scd_term_data_id <= 0.00)
        CALL echo("here11 name = text"), m_info->clinic_follow_ups[m_info->f2_cnt].name = trim(stt3
         .text_representation,3)
       ELSE
        CALL echo("here12 name = value_text"), m_info->clinic_follow_ups[m_info->f2_cnt].name = trim(
         std3.value_text,3)
       ENDIF
      ELSEIF (st2.scd_term_id > 0.00)
       CALL echo("here13"), m_info->f2_cnt = (m_info->f2_cnt+ 1), stat = alterlist(m_info->
        clinic_follow_ups,m_info->f2_cnt)
       IF (std2.scd_term_data_id <= 0.00)
        CALL echo("here14"), m_info->clinic_follow_ups[m_info->f2_cnt].name = trim(stt2
         .text_representation,3),
        CALL echo(stt2.text_representation)
       ELSE
        CALL echo("here15"), m_info->clinic_follow_ups[m_info->f2_cnt].name = trim(std2.value_text,3)
       ENDIF
      ENDIF
     ELSEIF (cnvtupper(stt2.display) IN ("WHEN", "RECOMMENDED FOLLOW-UP TIME"))
      CALL echo("here16 WHEN"),
      CALL echo(build2("stt3.display: ",trim(stt3.display),"; std3.scd_term_data_id: ",trim(
        cnvtstring(std3.scd_term_data_id)),"; std3.scd_term_data_type_cd: ",
       trim(uar_get_code_display(std3.scd_term_data_type_cd)),"; std3.scd_term_data_key: ",trim(std3
        .scd_term_data_key)))
      IF (cnvtupper(stt3.display)="IN === DAYS"
       AND std3.scd_term_data_id > 0.00)
       CALL echo("here17"), m_info->clinic_follow_ups[m_info->f2_cnt].time = build2("in ",trim(std3
         .value_text,3)," days")
      ELSEIF (stt3.display="OTHER"
       AND std3.scd_term_data_id > 0.00
       AND std3.scd_term_data_type_cd=mf_data_cd)
       CALL echo("here18 time = value_text"), m_info->clinic_follow_ups[m_info->f2_cnt].time = trim(
        std3.value_text,3)
      ELSEIF (stt3.display="OTHER"
       AND std3.scd_term_data_id > 0.00
       AND std3.scd_term_data_key="RTF")
       CALL echo("here18a OTHER RTF")
       IF ((((m_info->f2_cnt=0)) OR (trim(m_info->clinic_follow_ups[m_info->f2_cnt].time) > " ")) )
        m_info->f2_cnt = (m_info->f2_cnt+ 1), stat = alterlist(m_info->clinic_follow_ups,m_info->
         f2_cnt)
       ENDIF
       m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->
       blobs[m_info->b_cnt].blob_parent = "clinic_follow_ups_time",
       m_info->blobs[m_info->b_cnt].blob_slot = m_info->f2_cnt, m_info->blobs[m_info->b_cnt].
       f_blob_id = std3.fkey_id
      ELSEIF (std3.scd_term_data_key != "BlockedTextData1")
       CALL echo("here19 time = text_rep"), m_info->clinic_follow_ups[m_info->f2_cnt].time = trim(
        stt3.text_representation,3),
       CALL echo(stt3.text_representation)
      ENDIF
     ENDIF
    ELSEIF (cnvtupper(stt1.display)="ADDITIONAL FOLLOW-UP")
     CALL echo("here20 ADDITIONAL FOLLOWUP")
     IF (cnvtupper(stt2.display) IN ("WHEN", "ADDITIONAL CLINICS")
      AND st3.scd_term_id > 0.00)
      CALL echo("here21 when, additional clinics")
      IF (std3.scd_term_data_key != "BlockedTextData1"
       AND std3.fkey_entity_name != "SCD_BLOB")
       CALL echo("here22")
       IF (cnvtupper(stt2.display)="ADDITIONAL CLINICS")
        CALL echo("ADDITIONAL CLINICS"),
        CALL echo(stt3.display), m_info->f3_cnt = (m_info->f3_cnt+ 1),
        stat = alterlist(m_info->add_follow_ups,m_info->f3_cnt)
        IF (std3.scd_term_data_id <= 0.00
         AND stt3.display="OTHER")
         CALL echo("here24"), m_info->add_follow_ups[m_info->f3_cnt].name = trim(stt3
          .text_representation,3)
        ELSEIF (stt3.display="OTHER")
         CALL echo("here25"), m_info->add_follow_ups[m_info->f3_cnt].name = trim(std3.value_text,3)
        ELSEIF (trim(stt3.display) > " ")
         CALL echo("here 26a"), m_info->add_follow_ups[m_info->f3_cnt].name = trim(stt3
          .text_representation)
        ENDIF
       ELSEIF (cnvtupper(stt2.display)="WHEN")
        IF (cnvtupper(stt3.display)="IN === DAYS"
         AND std3.scd_term_data_id > 0.00)
         CALL echo("here26"), m_info->add_follow_ups[m_info->f3_cnt].time = build2("in ",trim(std3
           .value_text,3)," days"), m_info->add_follow_ups[m_info->f3_cnt].time = replace(m_info->
          add_follow_ups[m_info->f3_cnt].time,"days days","days")
        ELSEIF (trim(stt3.display) > " ")
         CALL echo("here 26b"), m_info->add_follow_ups[m_info->f3_cnt].time = stt3
         .text_representation
        ENDIF
       ENDIF
      ELSEIF (std3.fkey_entity_name="SCD_BLOB"
       AND stt3.display="OTHER"
       AND std3.scd_term_data_type_cd=mf_data_cd)
       CALL echo("here27 scd_blob, other")
       IF (cnvtupper(stt2.display)="ADDITIONAL CLINICS")
        m_info->f3_cnt = (m_info->f3_cnt+ 1), stat = alterlist(m_info->add_follow_ups,m_info->f3_cnt)
       ENDIF
       m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt)
       IF (cnvtupper(stt2.display)="WHEN")
        m_info->blobs[m_info->b_cnt].blob_parent = "add_follow_ups_time"
       ELSE
        m_info->blobs[m_info->b_cnt].blob_parent = "add_follow_ups"
       ENDIF
       m_info->blobs[m_info->b_cnt].blob_slot = m_info->f3_cnt, m_info->blobs[m_info->b_cnt].
       f_blob_id = std3.fkey_id
      ENDIF
     ELSEIF (cnvtupper(stt2.display) IN ("WHEN", "RECOMMENDED FOLLOW-UP TIME"))
      CALL echo("here28")
      IF (cnvtupper(stt3.display)="IN === DAYS"
       AND std3.scd_term_data_id > 0.00)
       CALL echo("here29"), m_info->add_follow_ups[m_info->f3_cnt].time = build2("in ",trim(std3
         .value_text,3)," days")
      ELSEIF (stt3.display="OTHER"
       AND std3.scd_term_data_id > 0.00
       AND std3.scd_term_data_type_cd=mf_data_cd)
       CALL echo("here30"), m_info->add_follow_ups[m_info->f3_cnt].time = trim(std3.value_text,3)
      ELSE
       CALL echo("here31"), m_info->add_follow_ups[m_info->f3_cnt].time = trim(stt3
        .text_representation,3)
      ENDIF
     ENDIF
    ELSEIF (cnvtupper(stt1.display)="OTHER FOLLOW-UP INSTRUCTIONS"
     AND std1.scd_term_data_id > 0.00
     AND std1.scd_term_data_type_cd=mf_data_cd)
     CALL echo("here32"), m_info->ni_cnt = (m_info->ni_cnt+ 1), stat = alterlist(m_info->
      ni_follow_ups,m_info->ni_cnt),
     m_info->ni_follow_ups[m_info->ni_cnt].f_blob_id = std1.fkey_id, m_info->b_cnt = (m_info->b_cnt+
     1), stat = alterlist(m_info->blobs,m_info->b_cnt),
     m_info->blobs[m_info->b_cnt].blob_parent = "ni_follow_ups", m_info->blobs[m_info->b_cnt].
     blob_slot = m_info->ni_cnt, m_info->blobs[m_info->b_cnt].f_blob_id = std1.fkey_id
    ELSEIF (trim(stt1.display)="If MD doing discharge, pt contact# ==")
     m_info->s_ni_home_phone = trim(std1.value_text)
    ELSEIF (trim(cnvtupper(stt1.display))="FREE TEXT SENTENCE"
     AND st1.scd_term_id > 0.00
     AND std1.fkey_entity_name="SCD_BLOB"
     AND std1.scd_term_data_key="RTF")
     CALL echo("treated for free text sentence"), m_info->b_cnt = (m_info->b_cnt+ 1), stat =
     alterlist(m_info->blobs,m_info->b_cnt),
     m_info->blobs[m_info->b_cnt].blob_parent = "treated_for", m_info->blobs[m_info->b_cnt].blob_slot
      = 0, m_info->blobs[m_info->b_cnt].f_blob_id = std1.fkey_id
    ENDIF
   ELSEIF (spt.display="Nursing Intervention")
    IF (stt1.display="Home phone number ==="
     AND std1.scd_term_data_id > 0.00)
     m_info->s_ni_home_phone = trim(std1.value_text,3)
    ELSEIF (stt1.display="OTHER Follow-up"
     AND std1.scd_term_data_id > 0.00
     AND std1.scd_term_data_type_cd=mf_data_cd)
     m_info->ni_cnt = (m_info->ni_cnt+ 1), stat = alterlist(m_info->ni_follow_ups,m_info->ni_cnt),
     m_info->ni_follow_ups[m_info->ni_cnt].f_blob_id = std1.fkey_id,
     m_info->b_cnt = (m_info->b_cnt+ 1), stat = alterlist(m_info->blobs,m_info->b_cnt), m_info->
     blobs[m_info->b_cnt].blob_parent = "ni_follow_ups",
     m_info->blobs[m_info->b_cnt].blob_slot = m_info->ni_cnt, m_info->blobs[m_info->b_cnt].f_blob_id
      = std1.fkey_id
    ENDIF
   ENDIF
  FOOT REPORT
   IF (trim(m_info->s_drowsiness,3) > " ")
    m_info->s_drowsiness = build2(m_info->s_drowsiness,
     " may cause drowsiness; DO NOT operate a car, machinery, or drink alcohol")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_blob cb
  PLAN (ce
   WHERE (ce.parent_event_id=m_info->event_id)
    AND ce.parent_event_id != ce.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cb
   WHERE cb.event_id=ce.event_id
    AND cb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY ce.event_end_dt_tm
  HEAD REPORT
   tmp_blob_out = fillstring(64000," ")
  DETAIL
   m_info->a_cnt = (m_info->a_cnt+ 1),
   CALL echo(build2("a_cnt in detail getting addendums: ",m_info->a_cnt)), stat = alterlist(m_info->
    addendums,m_info->a_cnt),
   m_info->addendums[m_info->a_cnt].s_title = trim(ce.event_title_text,3), m_info->addendums[m_info->
   a_cnt].s_text = sbr_process_blob(cb.blob_contents,cb.compression_cd)
  WITH nocounter
 ;end select
 IF ((m_info->b_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(m_info->b_cnt)),
    long_blob lb
   PLAN (d)
    JOIN (lb
    WHERE (lb.parent_entity_id=m_info->blobs[d.seq].f_blob_id)
     AND lb.parent_entity_name="SCD_BLOB")
   DETAIL
    CASE (m_info->blobs[d.seq].blob_parent)
     OF "ip_treatments":
      m_info->ip_treatments[m_info->blobs[d.seq].blob_slot].s_text = sbr_process_blob(lb.long_blob,lb
       .compression_cd)
     OF "precautions":
      m_info->precautions[m_info->blobs[d.seq].blob_slot].s_text = sbr_process_blob(lb.long_blob,lb
       .compression_cd)
     OF "ni_follow_ups":
      m_info->ni_follow_ups[m_info->blobs[d.seq].blob_slot].s_text = sbr_process_blob(lb.long_blob,lb
       .compression_cd)
     OF "clinic_follow_ups":
      m_info->clinic_follow_ups[m_info->blobs[d.seq].blob_slot].name = sbr_process_blob(lb.long_blob,
       lb.compression_cd)
     OF "clinic_follow_ups_time":
      m_info->clinic_follow_ups[m_info->blobs[d.seq].blob_slot].time = sbr_process_blob(lb.long_blob,
       lb.compression_cd)
     OF "md_follow_ups":
      IF (trim(m_info->md_follow_ups[m_info->blobs[d.seq].blob_slot].name) <= " ")
       m_info->md_follow_ups[m_info->blobs[d.seq].blob_slot].name = sbr_process_blob(lb.long_blob,lb
        .compression_cd)
      ELSE
       m_info->md_follow_ups[m_info->blobs[d.seq].blob_slot].name = concat(m_info->md_follow_ups[
        m_info->blobs[d.seq].blob_slot].name," ",sbr_process_blob(lb.long_blob,lb.compression_cd))
      ENDIF
     OF "add_follow_ups":
      m_info->add_follow_ups[m_info->blobs[d.seq].blob_slot].name = sbr_process_blob(lb.long_blob,lb
       .compression_cd)
     OF "add_follow_ups_time":
      m_info->add_follow_ups[m_info->blobs[d.seq].blob_slot].time = sbr_process_blob(lb.long_blob,lb
       .compression_cd)
     OF "prescriptions":
      ms_tmp_string = sbr_process_blob(lb.long_blob,lb.compression_cd),ml_beg_pos = findstring(
       "Pharmacy:",ms_tmp_string),
      IF (ml_beg_pos > 0)
       ms_tmp_string = trim(substring(10,(textlen(ms_tmp_string) - 9),ms_tmp_string),3)
       IF (substring(1,1,ms_tmp_string) IN (char(10), char(13)))
        ms_tmp_string = substring(2,(textlen(ms_tmp_string) - 1),ms_tmp_string)
       ENDIF
      ENDIF
      ,
      IF (findstring(concat("Medication Orders (selected)",char(10)),ms_tmp_string) > 0)
       ms_tmp_string = replace(ms_tmp_string,concat("Medication Orders (selected)",char(10)),"",0)
      ENDIF
      ,
      IF (findstring(concat("Prescriptions and Home Medications (selected)",char(10)),ms_tmp_string)
       > 0)
       ms_tmp_string = replace(ms_tmp_string,concat("Prescriptions and Home Medications (selected)",
         char(10)),"",0)
      ENDIF
      ,m_info->prescriptions[m_info->blobs[d.seq].blob_slot].s_text = ms_tmp_string
     OF "otherprescriptions":
      ms_tmp_string = trim(sbr_process_blob(lb.long_blob,lb.compression_cd)),
      IF (mn_other_rx_ind=0
       AND (m_info->blobs[d.seq].blob_slot > 1))
       ms_tmp_string = concat(char(10),ms_tmp_string)
      ENDIF
      ,m_info->prescriptions[m_info->blobs[d.seq].blob_slot].s_text = ms_tmp_string,mn_other_rx_ind
       = 1
     OF "treated_for":
      IF (trim(m_info->s_treated_for) > " ")
       m_info->s_treated_for = concat(m_info->s_treated_for,char(10),sbr_process_blob(lb.long_blob,lb
         .compression_cd))
      ELSE
       m_info->s_treated_for = sbr_process_blob(lb.long_blob,lb.compression_cd)
      ENDIF
     OF "cur_visit_results":
      m_info->vr_unsorted[m_info->blobs[d.seq].blob_slot].s_text = sbr_process_blob(lb.long_blob,lb
       .compression_cd)
     OF "procedures":
      IF (trim(m_info->s_procedures) > " ")
       m_info->s_procedures = concat(m_info->s_procedures,", ",sbr_process_blob(lb.long_blob,lb
         .compression_cd))
      ELSE
       m_info->s_procedures = sbr_process_blob(lb.long_blob,lb.compression_cd)
      ENDIF
    ENDCASE
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build2("get info vu_cnt = ",m_info->vu_cnt,"; ",size(m_info->vr_unsorted,5)))
 IF ((m_info->vu_cnt > 0))
  SELECT INTO "nl:"
   pn_sort_by = m_info->vr_unsorted[d.seq].n_result_type
   FROM (dummyt d  WITH seq = value(size(m_info->vr_unsorted,5))),
    clinical_event ce
   PLAN (d
    WHERE (m_info->vr_unsorted[d.seq].event_id > 0.00))
    JOIN (ce
    WHERE (ce.event_id=m_info->vr_unsorted[d.seq].event_id))
   ORDER BY pn_sort_by, ce.event_id, ce.event_end_dt_tm DESC
   HEAD ce.event_id
    pn_done = 0
   DETAIL
    IF (pn_done=0)
     m_info->vr_unsorted[d.seq].d_event_dt_tm = ce.event_end_dt_tm, m_info->vr_unsorted[d.seq].
     s_event_desc = trim(uar_get_code_display(ce.event_cd),3), m_info->vr_unsorted[d.seq].s_event_tag
      = trim(ce.event_tag),
     m_info->vr_unsorted[d.seq].n_result_type = m_info->vr_unsorted[d.seq].n_result_type, m_info->
     vr_unsorted[d.seq].s_result_type = m_info->vr_unsorted[d.seq].s_result_type
     IF (trim(uar_get_code_meaning(ce.normalcy_cd),3) IN ("ABNORMAL", "VABNORMAL", "CRITICAL", "HIGH",
     "EXTREMEHIGH",
     "PANICHIGH", "LOW", "EXTREMELOW", "PANICLOW"))
      m_info->vr_unsorted[d.seq].n_normalcy_ind = 1
     ENDIF
     pn_done = 1
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build2("copying vu_cnt = ",m_info->vu_cnt,"; ",size(m_info->vr_unsorted,5)))
  SELECT INTO "nl:"
   pn_sort_by = m_info->vr_unsorted[d.seq].n_result_type, pd_event_date = m_info->vr_unsorted[d.seq].
   d_event_dt_tm
   FROM (dummyt d  WITH seq = value(size(m_info->vr_unsorted,5)))
   PLAN (d)
   ORDER BY pn_sort_by, pd_event_date DESC
   DETAIL
    m_info->vr_cnt = (m_info->vr_cnt+ 1), stat = alterlist(m_info->visit_results,m_info->vr_cnt),
    m_info->visit_results[m_info->vr_cnt].event_dt_tm = trim(format(m_info->vr_unsorted[d.seq].
      d_event_dt_tm,"mm/dd/yyyy hh:mm;;d")),
    m_info->visit_results[m_info->vr_cnt].event_desc = m_info->vr_unsorted[d.seq].s_event_desc,
    m_info->visit_results[m_info->vr_cnt].event_tag = m_info->vr_unsorted[d.seq].s_event_tag, m_info
    ->visit_results[m_info->vr_cnt].n_result_type = m_info->vr_unsorted[d.seq].n_result_type,
    m_info->visit_results[m_info->vr_cnt].s_result_type = m_info->vr_unsorted[d.seq].s_result_type,
    m_info->visit_results[m_info->vr_cnt].normalcy_ind = m_info->vr_unsorted[d.seq].n_normalcy_ind
   WITH nocounter
  ;end select
  CALL echo(build2("vr_cnt: ",m_info->vr_cnt,"; vu_cnt: ",m_info->vu_cnt))
  IF ((m_info->vu_cnt > m_info->vr_cnt))
   SET stat = alterlist(m_info->visit_results,m_info->vu_cnt)
   SET m_info->vr_cnt = (m_info->vr_cnt+ 1)
   FOR (x = m_info->vr_cnt TO m_info->vu_cnt)
     SET m_info->visit_results[x].event_dt_tm = m_info->s_visit_date
     SET m_info->visit_results[x].event_desc = "OTHER"
     SET m_info->visit_results[x].event_tag = m_info->vr_unsorted[x].s_text
     SET m_info->visit_results[x].n_result_type = m_info->vr_unsorted[x].n_result_type
     SET m_info->visit_results[x].s_result_type = m_info->vr_unsorted[x].s_result_type
   ENDFOR
   SET m_info->vr_cnt = m_info->vu_cnt
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dummyt d
  HEAD REPORT
   pn_ind = 0, cur_page = 0, printout_cnt = 2,
   tmp_work_room = 0.00, tmp_height = 0.00, y_page_head = 0.5,
   y_page_foot = 10, page_foot_buffer = 0.25, y_end_of_page = (y_page_foot - page_foot_buffer),
   _yoffset = y_page_head,
   MACRO (macro_break_page)
    macro_foot_page, d0 = pagebreak(0), _yoffset = y_page_head
    IF (pn_ind=0)
     d0 = patient_data(rpt_render)
    ENDIF
   ENDMACRO
   ,
   MACRO (macro_new_copy)
    pn_ind = 1, macro_break_page, pn_ind = 0,
    cur_page = 0
    IF (((printout - 1) < printout_cnt))
     _yoffset = y_page_head
    ENDIF
   ENDMACRO
   ,
   MACRO (macro_get_work_room)
    tmp_work_room = (y_end_of_page - _yoffset)
    IF (tmp_work_room < 0)
     macro_break_page, tmp_work_room = (y_end_of_page - y_page_head)
    ENDIF
   ENDMACRO
   ,
   MACRO (macro_foot_page)
    cur_page = (cur_page+ 1), _yoffset = y_page_foot, d0 = page_foot(rpt_render)
   ENDMACRO
  DETAIL
   FOR (printout = 1 TO printout_cnt)
     IF (printout > 1)
      macro_new_copy
     ENDIF
     IF (printout < printout_cnt)
      ms_copy_desc_text = "PATIENT COPY"
     ELSE
      ms_copy_desc_text = "HOSPITAL COPY"
     ENDIF
     d0 = report_head(rpt_render), d0 = patient_data(rpt_render), d0 = report_divider(rpt_render)
     IF (trim(m_info->s_disch_phys) > " ")
      d0 = provider_info(rpt_render)
     ENDIF
     IF (trim(m_info->s_disch_nurse) > " ")
      d0 = disch_nurse(rpt_render)
     ENDIF
     IF (trim(m_info->s_treated_for) > " ")
      d0 = section_space(rpt_render), macro_get_work_room, d0 = section_treated_for(rpt_render,
       tmp_work_room,becont)
      WHILE (becont=1)
        macro_break_page, macro_get_work_room, d0 = section_treated_for(rpt_render,tmp_work_room,
         becont)
      ENDWHILE
     ENDIF
     mn_header_ind = 0
     IF ((((m_info->ipt_cnt > 0)) OR ((((m_info->ez_cnt > 0)) OR (trim(m_info->med_info_other) > " "
     )) )) )
      d0 = report_divider(rpt_render), d0 = section_treatments_head(rpt_render), mn_header_ind = 1
     ENDIF
     FOR (ip = 1 TO m_info->ipt_cnt)
       macro_get_work_room, d0 = section_treatments_detail(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         macro_break_page, macro_get_work_room, d0 = section_treatments_detail(rpt_render,
          tmp_work_room,becont)
       ENDWHILE
       IF ((ip < m_info->ipt_cnt))
        d0 = section_space(rpt_render)
       ENDIF
     ENDFOR
     FOR (e = 1 TO m_info->ez_cnt)
       macro_get_work_room
       IF (0.32 > tmp_work_room)
        macro_break_page
       ENDIF
       d0 = section_meds_included(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         macro_break_page, macro_get_work_room, d0 = section_meds_included(rpt_render,tmp_work_room,
          becont)
       ENDWHILE
     ENDFOR
     IF (trim(m_info->med_info_other,3) > " ")
      macro_get_work_room
      IF (0.32 > tmp_work_room)
       macro_break_page
      ENDIF
      d0 = section_med_other(rpt_render,tmp_work_room,becont)
      WHILE (becont=1)
        macro_break_page, macro_get_work_room, d0 = section_med_other(rpt_render,tmp_work_room,becont
         )
      ENDWHILE
     ENDIF
     IF (trim(m_info->s_micromedex,3) > " ")
      d0 = report_divider(rpt_render), macro_get_work_room
      IF (0.38 > tmp_work_room)
       macro_break_page
      ENDIF
      d0 = section_micromedex(rpt_render,tmp_work_room,becont)
      WHILE (becont=1)
        macro_break_page, macro_get_work_room, d0 = section_micromedex(rpt_render,tmp_work_room,
         becont)
      ENDWHILE
     ENDIF
     IF (size(m_info->prescriptions,5) > 0)
      macro_get_work_room
      IF (((prescriptions_header(rpt_calcheight)+ 0.25) > tmp_work_room))
       macro_break_page
      ENDIF
      d0 = report_divider(rpt_render), d0 = prescriptions_header(rpt_render)
      IF (trim(m_info->s_discontinue,3) > " ")
       macro_get_work_room
       IF (0.32 > tmp_work_room)
        macro_break_page, d0 = prescriptions_header(rpt_render)
       ENDIF
       d0 = section_discontinue(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         macro_break_page, macro_get_work_room, d0 = prescriptions_header(rpt_render),
         d0 = section_discontinue(rpt_render,tmp_work_room,becont)
       ENDWHILE
      ENDIF
      IF (trim(m_info->s_drowsiness,3) > " ")
       macro_get_work_room
       IF (0.32 > tmp_work_room)
        macro_break_page, d0 = prescriptions_header(rpt_render)
       ENDIF
       d0 = section_drowsiness(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         macro_break_page, macro_get_work_room, d0 = prescriptions_header(rpt_render),
         d0 = section_drowsiness(rpt_render,tmp_work_room,becont)
       ENDWHILE
      ENDIF
      IF ((m_info->cont_med_ind=1))
       macro_get_work_room
       IF (0.32 > tmp_work_room)
        macro_break_page, d0 = prescriptions_header(rpt_render)
       ENDIF
       d0 = section_cont_meds(rpt_render)
      ENDIF
      FOR (p = 1 TO size(m_info->prescriptions,5))
        macro_get_work_room
        IF (0.32 > tmp_work_room)
         macro_break_page, d0 = prescriptions_header(rpt_render)
        ENDIF
        macro_get_work_room, d0 = prescriptions_detail(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          macro_break_page, macro_get_work_room, d0 = prescriptions_header(rpt_render),
          d0 = prescriptions_detail(rpt_render,tmp_work_room,becont)
        ENDWHILE
      ENDFOR
     ENDIF
     IF (size(m_info->prescriptions,5) <= 0)
      mn_header_ind = 0
      IF (trim(m_info->s_discontinue,3) > " ")
       macro_get_work_room
       IF (((prescriptions_header(rpt_calcheight)+ 0.32) > tmp_work_room))
        macro_break_page
       ENDIF
       d0 = report_divider(rpt_render), d0 = prescriptions_header(rpt_render), d0 =
       section_discontinue(rpt_render,tmp_work_room,becont),
       mn_header_ind = 1
       WHILE (becont=1)
         macro_break_page, macro_get_work_room, d0 = prescriptions_header(rpt_render),
         d0 = section_discontinue(rpt_render,tmp_work_room,becont)
       ENDWHILE
      ENDIF
      IF (trim(m_info->s_drowsiness) > " ")
       macro_get_work_room
       IF (mn_header_ind=0)
        IF ((tmp_work_room < (prescriptions_header(rpt_calcheight)+ 0.32)))
         macro_break_page, d0 = prescriptions_header(rpt_render)
        ELSE
         d0 = report_divider(rpt_render), d0 = prescriptions_header(rpt_render)
        ENDIF
       ELSE
        IF (tmp_work_room < 0.32)
         macro_break_page, d0 = prescriptions_header(rpt_render)
        ENDIF
       ENDIF
       d0 = section_drowsiness(rpt_render,tmp_work_room,becont), mn_header_ind = 1
       WHILE (becont=1)
         macro_break_page, macro_get_work_room, d0 = prescriptions_header(rpt_render),
         d0 = section_drowsiness(rpt_render,tmp_work_room,becont)
       ENDWHILE
      ENDIF
      IF ((m_info->cont_med_ind=1))
       macro_get_work_room
       IF (mn_header_ind=0)
        IF ((((prescriptions_header(rpt_calcheight)+ section_cont_meds(rpt_calcheight))+ 0.25) >
        tmp_work_room))
         macro_break_page, d0 = prescriptions_header(rpt_render)
        ELSE
         d0 = report_divider(rpt_render), d0 = prescriptions_header(rpt_render)
        ENDIF
       ELSE
        IF (((prescriptions_header(rpt_calcheight)+ 0.25) > tmp_work_room))
         macro_break_page, d0 = prescriptions_header(rpt_render)
        ENDIF
       ENDIF
       d0 = section_cont_meds(rpt_render)
      ENDIF
     ENDIF
     IF ((((m_info->work_note_ind=1)) OR ((m_info->n_excuse_note_ind=1))) )
      macro_get_work_room
      IF (tmp_work_room < 0.25)
       macro_break_page
      ENDIF
      d0 = report_divider(rpt_render), d0 = note_given_head(rpt_render)
      IF ((m_info->work_note_ind=1))
       d0 = work_note_detail(rpt_render)
      ENDIF
      IF ((m_info->n_excuse_note_ind=1))
       d0 = excuse_note_detail(rpt_render)
      ENDIF
     ENDIF
     IF ((((m_info->f1_cnt+ m_info->f2_cnt)+ m_info->f3_cnt) > 0))
      macro_get_work_room
      IF (((section_followup_head(rpt_calcheight)+ 0.25) > tmp_work_room))
       macro_break_page
      ENDIF
      d0 = report_divider(rpt_render), d0 = section_followup_head(rpt_render)
     ENDIF
     FOR (f1 = 1 TO m_info->f1_cnt)
       m_info->md_follow_ups[f1].s_text = build2("Please follow up with  ",trim(m_info->
         md_follow_ups[f1].name,3))
       IF (trim(m_info->md_follow_ups[f1].time,3) > " ")
        m_info->md_follow_ups[f1].s_text = build2(m_info->md_follow_ups[f1].s_text," ",trim(m_info->
          md_follow_ups[f1].time,3))
       ENDIF
       IF (trim(m_info->md_follow_ups[f1].phone,3) > " ")
        m_info->md_follow_ups[f1].s_text = build2(m_info->md_follow_ups[f1].s_text," (phone number: ",
         trim(m_info->md_follow_ups[f1].phone,3),")")
       ENDIF
       macro_get_work_room, d0 = section_md_followup(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         macro_break_page, d0 = section_followup_head(rpt_render), macro_get_work_room,
         d0 = section_md_followup(rpt_render,tmp_work_room,becont)
       ENDWHILE
     ENDFOR
     FOR (f2 = 1 TO m_info->f2_cnt)
       m_info->clinic_follow_ups[f2].s_text = build2("Please follow up with ",trim(m_info->
         clinic_follow_ups[f2].name,3))
       IF (trim(m_info->clinic_follow_ups[f2].time,3) > " ")
        m_info->clinic_follow_ups[f2].s_text = build2(m_info->clinic_follow_ups[f2].s_text," ",trim(
          m_info->clinic_follow_ups[f2].time,3))
       ENDIF
       macro_get_work_room, d0 = section_clinic_followup(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         macro_break_page, d0 = section_followup_head(rpt_render), macro_get_work_room,
         d0 = section_clinic_followup(rpt_render,tmp_work_room,becont)
       ENDWHILE
     ENDFOR
     FOR (f3 = 1 TO m_info->f3_cnt)
       m_info->add_follow_ups[f3].s_text = build2("Please follow up with ",trim(m_info->
         add_follow_ups[f3].name,3))
       IF (trim(m_info->add_follow_ups[f3].time,3) > " ")
        m_info->add_follow_ups[f3].s_text = build2(m_info->add_follow_ups[f3].s_text," ",trim(m_info
          ->add_follow_ups[f3].time,3))
       ENDIF
       macro_get_work_room, d0 = section_addtl_followup(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         macro_break_page, d0 = section_followup_head(rpt_render), macro_get_work_room,
         d0 = section_addtl_followup(rpt_render,tmp_work_room,becont)
       ENDWHILE
     ENDFOR
     IF ((m_info->ni_cnt > 0))
      macro_get_work_room
      IF (((section_other_followup_head(rpt_calcheight)+ 0.22) > tmp_work_room))
       macro_break_page
      ENDIF
      d0 = section_other_followup_head(rpt_render)
      FOR (ni = 1 TO m_info->ni_cnt)
        macro_get_work_room, d0 = section_ni_followup(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          macro_break_page, d0 = section_other_followup_head(rpt_render), macro_get_work_room,
          d0 = section_ni_followup(rpt_render,tmp_work_room,becont)
        ENDWHILE
      ENDFOR
     ENDIF
     macro_get_work_room
     IF ((tmp_work_room < (report_divider(rpt_calcheight)+ section_contact_numbers(rpt_calcheight))))
      macro_break_page
     ENDIF
     IF (size(m_info->addendums,5) > 0)
      macro_get_work_room, a = 1
      IF ((((section_addendums_head(rpt_calcheight)+ section_addendums_title(rpt_calcheight))+ 0.22)
       > tmp_work_room))
       macro_break_page
      ENDIF
      d0 = report_divider(rpt_render), d0 = section_addendums_head(rpt_render)
      FOR (a = 1 TO size(m_info->addendums,5))
        macro_get_work_room, d0 = section_addendums_title(rpt_render), d0 = section_addendums_detail(
         rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          CALL echo("in while"), macro_break_page, d0 = section_addendums_head(rpt_render),
          d0 = section_addendums_title(rpt_render), macro_get_work_room, d0 =
          section_addendums_detail(rpt_render,tmp_work_room,becont)
        ENDWHILE
      ENDFOR
     ENDIF
     IF (trim(m_info->s_procedures,3) > " ")
      macro_get_work_room
      IF (0.45 > tmp_work_room)
       macro_break_page, macro_get_work_room
      ENDIF
      d0 = section_procedures(rpt_render,tmp_work_room,becont)
      WHILE (becont=1)
        macro_break_page, macro_get_work_room, d0 = section_procedures(rpt_render,tmp_work_room,
         becont)
      ENDWHILE
     ENDIF
     macro_get_work_room
     IF ((m_info->vr_cnt > 0))
      macro_get_work_room
      IF (((section_results_head(rpt_calcheight)+ 0.22) >= tmp_work_room))
       macro_break_page
      ENDIF
      d0 = report_divider(rpt_render), d0 = section_space(rpt_render), d0 = section_results_head(
       rpt_render),
      vr = 1, d0 = result_type_head(rpt_render)
      FOR (vr = 1 TO m_info->vr_cnt)
        macro_get_work_room
        IF (0.22 > tmp_work_room)
         macro_break_page, d0 = section_results_head(rpt_render), d0 = result_type_head(rpt_render)
        ELSE
         IF ((m_info->visit_results[vr].n_result_type != m_info->visit_results[(vr - 1)].
         n_result_type))
          d0 = result_type_head(rpt_render)
         ENDIF
        ENDIF
        d0 = section_results_detail(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          macro_break_page, d0 = section_results_head(rpt_render), macro_get_work_room,
          d0 = section_results_detail(rpt_render,tmp_work_room,becont)
        ENDWHILE
      ENDFOR
     ENDIF
     macro_get_work_room
     IF (section_disclaimers(rpt_calcheight) > tmp_work_room)
      macro_break_page
     ENDIF
     d0 = report_divider(rpt_render), d0 = section_disclaimers(rpt_render)
     IF (printout < printout_cnt)
      null
     ELSE
      macro_get_work_room
      IF (section_hosp_signatures(rpt_calcheight) > tmp_work_room)
       macro_break_page
      ENDIF
      d0 = report_divider(rpt_render), d0 = section_space(rpt_render), d0 = section_hosp_signatures(
       rpt_render)
     ENDIF
   ENDFOR
  FOOT PAGE
   IF (curendreport=1
    AND (_yoffset > (y_end_of_page+ page_foot_buffer)))
    macro_break_page
   ENDIF
   macro_foot_page
  WITH nocounter
 ;end select
 SET d0 = finalizereport(printer_name)
 SUBROUTINE sbr_process_blob(s_blob_in,f_comp_cd)
   DECLARE ml_blob_ret_len = i4 WITH protect, noconstant(0)
   DECLARE ml_blob_ret_len2 = i4 WITH protect, noconstant(0)
   DECLARE ms_blob_ret = vc WITH protect, noconstant(" ")
   SET ms_blob_comp_trimmed = fillstring(64000," ")
   SET ms_blob_uncomp = fillstring(64000," ")
   SET ms_blob_rtf = fillstring(64000," ")
   SET ms_blob_out = fillstring(64000," ")
   SET ms_blob_comp_trimmed = trim(s_blob_in)
   IF (((f_comp_cd=mf_comp_cd) OR (f_comp_cd=1)) )
    CALL uar_ocf_uncompress(ms_blob_comp_trimmed,size(ms_blob_comp_trimmed),ms_blob_uncomp,size(
      ms_blob_uncomp),ml_blob_ret_len)
    CALL uar_rtf2(ms_blob_uncomp,ml_blob_ret_len,ms_blob_rtf,size(ms_blob_rtf),ml_blob_ret_len2,
     1)
    SET ms_blob_out = trim(ms_blob_rtf,3)
   ELSEIF (((f_comp_cd=mf_no_comp_cd) OR (f_comp_cd=0)) )
    SET ms_blob_out = trim(s_blob_in)
    IF (findstring("rtf",ms_blob_out) > 0)
     CALL uar_rtf2(ms_blob_out,textlen(ms_blob_out),ms_blob_rtf,size(ms_blob_rtf),ml_blob_ret_len2,
      1)
     SET ms_blob_out = trim(ms_blob_rtf,3)
    ENDIF
    IF (findstring("ocf_blob",ms_blob_out) > 0)
     SET ms_blob_out = trim(substring(1,(findstring("ocf_blob",ms_blob_out) - 1),ms_blob_out))
    ENDIF
   ENDIF
   SET ms_blob_ret = trim(ms_blob_out,3)
   RETURN(ms_blob_ret)
 END ;Subroutine
#exit_script
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
