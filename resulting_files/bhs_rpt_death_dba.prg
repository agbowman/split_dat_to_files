CREATE PROGRAM bhs_rpt_death:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 s_pat_name = vc
   1 s_mrn = vc
   1 s_dob = vc
   1 s_death_dt_tm = vc
   1 s_called_op_switch = vc
   1 s_called_admit = vc
   1 s_admit_call_dt_tm = vc
   1 s_admit_staff = vc
   1 s_called_circle = vc
   1 s_circle_call_dt_tm = vc
   1 s_circle_staff = vc
   1 s_pronounced_by = vc
   1 s_cert_signed_by = vc
   1 s_med_exam_case = vc
   1 s_kin_notified_ind = vc
   1 s_kin_notified_by = vc
   1 s_emp_contact_phone_ext = vc
   1 s_kin_name = vc
   1 s_kin_relationship = vc
   1 s_reason_not_notified = vc
   1 s_fetal_death_ind = vc
   1 s_restrained_ind = vc
   1 s_restraint_type = vc
   1 s_med_exam_notified_ind = vc
   1 s_person_notifying_med_exam = vc
   1 s_jurisdiction_accepted = vc
   1 s_bhs_autopsy_ind = vc
   1 s_funeral_director = vc
   1 s_funeral_home = vc
   1 s_funeral_addr = vc
   1 s_death_form_comp_by = vc
   1 s_death_form_comp_dt_tm = vc
   1 s_kin_phone = vc
   1 s_kin_notify_data = vc
   1 s_who_body_diposition = vc
   1 s_resp_person_phone = vc
   1 s_resp_person_reltn = vc
   1 s_dispose_valuables = vc
   1 s_funeralhome_phone = vc
   1 s_neds_dt_tm = vc
   1 s_neds_ref_num = vc
   1 s_neds_staff = vc
 ) WITH protect
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = h WITH noconstant(0), protect
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
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times90 = i4 WITH noconstant(0), protect
 DECLARE _times12bi0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times12i0 = i4 WITH noconstant(0), protect
 DECLARE _pen100s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = h WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"bhscust:death_rpt_header_img.jpg")
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
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
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   DECLARE __neds_dt = vc WITH noconstant(build2(substring(1,30,m_info->s_neds_dt_tm),char(0))),
   protect
   DECLARE __date_of_death = vc WITH noconstant(build2(
     IF (cnvtint(substring(12,2,m_info->s_death_dt_tm)) > 11) concat(m_info->s_death_dt_tm," PM")
     ELSE concat(m_info->s_death_dt_tm," AM")
     ENDIF
     ,char(0))), protect
   DECLARE __call_circle = vc WITH noconstant(build2(m_info->s_called_circle,char(0))), protect
   DECLARE __call_circle_time = vc WITH noconstant(build2(substring(12,5,m_info->s_circle_call_dt_tm),
     char(0))), protect
   DECLARE __admit_staff = vc WITH noconstant(build2(m_info->s_circle_staff,char(0))), protect
   DECLARE __fetus_death = vc WITH noconstant(build2(m_info->s_fetal_death_ind,char(0))), protect
   DECLARE __pronounced_by = vc WITH noconstant(build2(m_info->s_pronounced_by,char(0))), protect
   DECLARE __cert_signed_by = vc WITH noconstant(build2(m_info->s_cert_signed_by,char(0))), protect
   DECLARE __kin_notified = vc WITH noconstant(build2(m_info->s_kin_notified_ind,char(0))), protect
   DECLARE __kin_notified_by = vc WITH noconstant(build2(m_info->s_kin_notified_by,char(0))), protect
   DECLARE __kin_name = vc WITH noconstant(build2(m_info->s_kin_name,char(0))), protect
   DECLARE __kin_relationship = vc WITH noconstant(build2(m_info->s_kin_relationship,char(0))),
   protect
   DECLARE __kin_not_notified = vc WITH noconstant(build2(m_info->s_reason_not_notified,char(0))),
   protect
   DECLARE __me_exam = vc WITH noconstant(build2(m_info->s_med_exam_case,char(0))), protect
   DECLARE __restraint = vc WITH noconstant(build2(m_info->s_restrained_ind,char(0))), protect
   DECLARE __me_notified = vc WITH noconstant(build2(m_info->s_med_exam_notified_ind,char(0))),
   protect
   DECLARE __me_notified_by = vc WITH noconstant(build2(m_info->s_person_notifying_med_exam,char(0))),
   protect
   DECLARE __jurisdiction_yes = vc WITH noconstant(build2(m_info->s_jurisdiction_accepted,char(0))),
   protect
   DECLARE __bh_autopsy = vc WITH noconstant(build2(m_info->s_bhs_autopsy_ind,char(0))), protect
   DECLARE __neds_ref_num = vc WITH noconstant(build2(m_info->s_neds_ref_num,char(0))), protect
   DECLARE __completed_by = vc WITH noconstant(build2(m_info->s_death_form_comp_by,char(0))), protect
   DECLARE __funeral_city_st = vc WITH noconstant(build2(m_info->s_funeral_addr,char(0))), protect
   DECLARE __funeral_home = vc WITH noconstant(build2(m_info->s_funeral_home,char(0))), protect
   DECLARE __completed_tm = vc WITH noconstant(build2(substring(12,5,m_info->s_death_form_comp_dt_tm),
     char(0))), protect
   DECLARE __completed_dt = vc WITH noconstant(build2(substring(1,10,m_info->s_death_form_comp_dt_tm),
     char(0))), protect
   DECLARE __name = vc WITH noconstant(build2(m_info->s_pat_name,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(m_info->s_mrn,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(m_info->s_dob,char(0))), protect
   DECLARE __emp_extension = vc WITH noconstant(build2(m_info->s_emp_contact_phone_ext,char(0))),
   protect
   DECLARE __kin_phone = vc WITH noconstant(build2(m_info->s_kin_phone,char(0))), protect
   DECLARE __who_body_diposition = vc WITH noconstant(build2(m_info->s_who_body_diposition,char(0))),
   protect
   DECLARE __resp_person_phone = vc WITH noconstant(build2(m_info->s_resp_person_phone,char(0))),
   protect
   DECLARE __resp_person_reltn = vc WITH noconstant(build2(m_info->s_resp_person_reltn,char(0))),
   protect
   DECLARE __neds_staff = vc WITH noconstant(build2(m_info->s_neds_staff,char(0))), protect
   DECLARE __funeralhome_phone = vc WITH noconstant(build2(m_info->s_funeralhome_phone,char(0))),
   protect
   DECLARE __dispose_valuables = vc WITH noconstant(build2(m_info->s_dispose_valuables,char(0))),
   protect
   DECLARE __restrainttype = vc WITH noconstant(build2(m_info->s_restraint_type,char(0))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 5.438),7.500,0.875,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 5.500)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__neds_dt)
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 1.000),(offsety+ 0.000),5.500,
     0.750,1)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 2.376)
    SET rptsd->m_width = 3.251
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Death Form/Funeral Director Release",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.823
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Deliver to:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12bi0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BMC:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admitting Wesson Grd",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 3.126)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12bi0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BFMC:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pathology Dept",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 1.573),2.376,0.625,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/Time Pronouncement of Death:",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.886)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date_of_death)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.376),(offsety+ 1.573),5.125,0.625,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Called Circle of Life:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__call_circle)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.792)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.761
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__call_circle_time)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.959)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__admit_staff)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.792)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.959)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Circle Of Life staff :",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 2.198),2.376,1.375,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.376),(offsety+ 2.198),3.126,1.365,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.500),(offsety+ 2.198),2.001,1.365,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.323)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient pronounced by:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Next of kin notified:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.511)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Notifed by:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.751)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Extension:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.948)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Next of Kin Name:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.323)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Relationship to patient:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reason Next of Kin Not Notified:",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.740)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Death Certificate signed by:",char(0)
      ))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.188)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medical Examiners Case:",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 3.563),7.500,0.260,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.636)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 6.500
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Was this a death of a fetus after being delivered with signs of life, regardless of gestational growth or weight?",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.636)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fetus_death)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.490)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pronounced_by)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.938)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cert_signed_by)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.323)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 0.823
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kin_notified)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.511)
    SET rptsd->m_x = (offsetx+ 3.188)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kin_notified_by)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.948)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kin_name)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.323)
    SET rptsd->m_x = (offsetx+ 3.938)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kin_relationship)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.698)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.875
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kin_not_notified)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.313)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.823
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__me_exam)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 4.313),7.500,0.448,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.938
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CMS RESTRAINT/SECLUSION REQUIREMENT",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.490)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.438
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Was patient behaviorally restrained within 7 days of death?",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.500)
    SET rptsd->m_x = (offsetx+ 3.438)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__restraint)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 4.760),2.438,0.448,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medical Examiner Notified:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.011)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__me_notified)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.438),(offsety+ 4.760),2.938,0.448,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.813)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Person notifying Medical Examiner:",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.000)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__me_notified_by)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.375),(offsety+ 4.760),2.126,0.448,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.813)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Jurisdiction Accepted by M E",char(0)
      ))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__jurisdiction_yes)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 5.198),7.500,0.250,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.261)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.376
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BHS Autopsy Requested?",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.261)
    SET rptsd->m_x = (offsetx+ 3.563)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bh_autopsy)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NEDS Notified Date/Time :",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.688)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NEDS Referral Number:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.688)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 5.438
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__neds_ref_num)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 6.313),3.501,0.438,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.500),(offsety+ 6.313),4.000,0.438,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Funeral Home:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.313)
    SET rptsd->m_x = (offsetx+ 3.563)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("City/State:",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 6.750),4.188,0.625,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.125)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time completed:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.844)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Form completed by:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date completed:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),(offsety+ 7.068),(offsetx+ 3.314),(offsety+
     7.068))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.000),(offsety+ 7.281),(offsetx+ 2.001),(offsety+
     7.281))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.188),(offsety+ 7.281),(offsetx+ 4.189),(offsety+
     7.281))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.844)
    SET rptsd->m_x = (offsetx+ 1.271)
    SET rptsd->m_width = 3.251
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__completed_by)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.313)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 3.126
    SET rptsd->m_height = 0.376
    SET _dummyfont = uar_rptsetfont(_hreport,_times90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__funeral_city_st)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.313)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__funeral_home)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.094)
    SET rptsd->m_x = (offsetx+ 3.251)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__completed_tm)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.094)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 0.823
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__completed_dt)
    SET _dummypen = uar_rptsetpen(_hreport,_pen100s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 7.411),(offsetx+ 7.501),(offsety+
     7.411))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 7.438),7.500,0.260,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.469)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FUNERAL DIRECTOR'S RELEASE",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 7.688),7.500,0.438,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 8.063),7.500,0.500,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.376)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.126)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.719)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.313
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "This certifies that they have received from     BMC         BFMC          BWH          BNH",
      char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.105),(offsety+ 7.740),0.136,0.125,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.500),(offsety+ 7.740),0.136,0.125,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.813),(offsety+ 7.740),0.136,0.125,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.188)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 0.323
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("AM",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.188)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PM",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.001),(offsety+ 8.188),0.136,0.125,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.626),(offsety+ 8.188),0.136,0.125,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 8.688),3.626,0.250,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.625),(offsety+ 8.688),3.876,0.250,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.688)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Funeral Director Signature:",char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.688)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Mass. License Number:",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 8.938),3.626,0.250,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.625),(offsety+ 8.938),3.876,0.250,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.938)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Employee #:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.938)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Released by:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.751)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__emp_extension)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.136)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Next of Kin Phone:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.126)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.573
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kin_phone)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 3.813),7.500,0.500,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.876)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Person Responsible Disposition of  body:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Responsible Person Phone #:",char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.063)
    SET rptsd->m_x = (offsetx+ 3.188)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Relationship :",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.876)
    SET rptsd->m_x = (offsetx+ 2.938)
    SET rptsd->m_width = 4.625
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__who_body_diposition)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.063)
    SET rptsd->m_x = (offsetx+ 1.938)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__resp_person_phone)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.063)
    SET rptsd->m_x = (offsetx+ 4.188)
    SET rptsd->m_width = 3.251
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__resp_person_reltn)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NEDS Staff Determination:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 5.625
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__neds_staff)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.553)
    SET rptsd->m_x = (offsetx+ 0.073)
    SET rptsd->m_width = 1.365
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Funeral Home Phone:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.500)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 1.636
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__funeralhome_phone)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.188),(offsety+ 6.760),3.313,0.615,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.834)
    SET rptsd->m_x = (offsetx+ 4.261)
    SET rptsd->m_width = 3.178
    SET rptsd->m_height = 0.230
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Disposition of Valuables/Belongings:",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.063)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dispose_valuables)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.500)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.261
    IF ((m_info->s_restrained_ind="Yes"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Restraint Type",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.500)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__restrainttype)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.626)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12bi0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BWH:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.626)
    SET rptsd->m_x = (offsetx+ 1.521)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nursing Supervisor or Security",char(
       0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.886)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.813
    SET rptsd->m_height = 0.219
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "                                                                             the remains of:",
      char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.125),(offsety+ 7.740),0.136,0.125,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12bi0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BNH:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 5.313)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nursing Sup.",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_DEATH"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
   SET rptreport->m_needsnotonaskharabic = 0
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _stat = _loadimages(0)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 62
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_italic = rpt_on
   SET _times12bi0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times12i0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_italic = rpt_off
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_off
   SET _times90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.100
   SET _pen100s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 DECLARE mf_death_dt_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFPRONOUNCEMENTOFDEATH"))
 DECLARE mf_called_op_swtch_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CALLEDOPERATORSWITCHBOARD"))
 DECLARE mf_called_admit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CALLEDADMITTINGOFFICE"))
 DECLARE mf_admit_staff_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADMITTINGOFFICESTAFFNAME"))
 DECLARE mf_admit_call_dt_tm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TIMEADMITTINGOFFICECALLED"))
 DECLARE mf_pat_pronounced_by_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTPRONOUNCEDBY"))
 DECLARE mf_cert_signed_by_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DEATHCERTIFICATESIGNEDBY"))
 DECLARE mf_med_exam_case_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALEXAMINERSCASE"))
 DECLARE mf_kin_notified_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEXTOFKINNOTIFIED"))
 DECLARE mf_kin_notified_by_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEXTOFKINNOTIFIEDBY"))
 DECLARE mf_emp_contact_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EMPLOYEECONTACTINFOPHONEEXTENSION"))
 DECLARE mf_kin_name_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"NAMEOFNEXTOFKIN"
   ))
 DECLARE mf_relation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELATIONSHIPTOPATIENT"))
 DECLARE mf_kin_phone = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"NEXTOFKINPHONE"))
 DECLARE mf_kin_notify_data = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEXTOFKINNOTIFICATIONDATA"))
 DECLARE mf_who_body_diposition = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERSONRESPONSIBLEDISPOSITIONOFBODY"))
 DECLARE mf_resp_person_phone = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPONSIBLEPERSONPHONE"))
 DECLARE mf_resp_person_reltn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RESPONSIBLEPERSONRELATIONSHIPTOPT"))
 DECLARE mf_dispose_valuables = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISPOSITIONOFVALUABLESBELONGINGS"))
 DECLARE mf_funeralhome_phone = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FUNERALHOMEPHONENUMBER"))
 DECLARE mf_rsn_not_notify_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONNEXTOFKINNOTNOTIFIED"))
 DECLARE mf_fetal_death_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"FETALDEATH"))
 DECLARE mf_restrain_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BEHAVIORALLYRESTRAINED7DAYSPRIOR"))
 DECLARE mf_restrainttype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PRIORRESTRAINTTYPE"))
 DECLARE mf_med_exam_notify_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICALEXAMINERNOTIFIED"))
 DECLARE mf_who_notify_exam_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERSONNOTIFYINGMEDICALEXAMINER"))
 DECLARE mf_jurisdiction_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "JURISDICTIONACCEPTEDBYME"))
 DECLARE mf_bhs_autopsy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BHSAUTOPSYREQUESTED"))
 DECLARE mf_funeral_dir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FUNERALDIRECTOR"))
 DECLARE mf_funeral_home_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"FUNERALHOME"
   ))
 DECLARE mf_funeral_addr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FUNERALHOMEADDRESSCITYSATE"))
 DECLARE mf_form_comp_by_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DEATHFORMCOMPLETEDBY"))
 DECLARE mf_form_comp_at_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DEATHFORMCOMPLETEDAT"))
 DECLARE mf_cs72_timecalledcircleoflife = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TIMECALLEDCIRCLEOFLIFE")), protect
 DECLARE mf_cs72_circleoflifestaffname = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "CIRCLEOFLIFESTAFFNAME")), protect
 DECLARE mf_cs72_calledcircleoflife = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "CALLEDCIRCLEOFLIFE")), protect
 DECLARE mf_cs72_neds_dt_tm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEDSNOTIFIEDDATETIME"))
 DECLARE mf_cs72_neds_ref_num = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEDSREFERRALNUMBER"))
 DECLARE mf_cs72_neds_staff = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NEDSSTAFFDETERMINATION"))
 CALL echo(build2("mf_CS72_NEDS_DT_TM: ",mf_cs72_neds_dt_tm))
 CALL echo(build2("mf_CS72_NEDS_REF_NUM: ",mf_cs72_neds_ref_num))
 CALL echo(build2("mf_CS72_NEDS_STAFF: ",mf_cs72_neds_staff))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ms_output = vc WITH protect, noconstant(" ")
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_dcp_forms_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_form_ref_nbr = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 IF (validate(request->visit,"Z") != "Z")
  CALL echo("called from task->reports")
  SET ms_output = request->output_device
  SET mf_encntr_id = request->visit[1].encntr_id
 ELSE
  IF (cnvtreal( $F_ENCNTR_ID) > 0.0)
   CALL echo("called from explorermenu")
   SET mf_encntr_id = cnvtreal( $F_ENCNTR_ID)
   SET ms_output = value( $OUTDEV)
  ELSE
   SET ms_log = "encounter id = 0 - exit"
   CALL echo(ms_log)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(build2("mf_encntr_id: ",mf_encntr_id))
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.description="Death Form - BHS"
   AND dfr.active_ind=1
  DETAIL
   mf_dcp_forms_ref_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "no dcp_forms_ref_id found - exit"
  CALL echo(ms_log)
  GO TO exit_script
 ELSE
  CALL echo(build2("dcp_forms_ref_id: ",mf_dcp_forms_ref_id))
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   dcp_forms_ref dfr,
   code_value cv
  PLAN (dfa
   WHERE dfa.dcp_forms_ref_id=mf_dcp_forms_ref_id
    AND dfa.encntr_id=mf_encntr_id
    AND dfa.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dfa.form_status_cd
    AND  NOT (cv.display_key IN ("INERROR", "NOTDONE", "CANCELED")))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=mf_dcp_forms_ref_id
    AND dfr.beg_effective_dt_tm <= dfa.version_dt_tm
    AND dfr.end_effective_dt_tm > dfa.version_dt_tm)
  ORDER BY dfa.dcp_forms_activity_id DESC
  HEAD REPORT
   pn_cnt = 0
  HEAD dfa.dcp_forms_activity_id
   pn_cnt += 1
   IF (pn_cnt=1)
    ms_form_ref_nbr = concat(trim(cnvtstring(dfa.dcp_forms_activity_id)),"*")
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "no form activity found - exit"
  CALL echo(ms_log)
  GO TO exit_script
 ELSE
  CALL echo(build2("form reference nbr: ",ms_form_ref_nbr))
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encntr_alias ea,
   prsnl pr,
   person p
  PLAN (ce
   WHERE operator(ce.reference_nbr,"LIKE",patstring(value(ms_form_ref_nbr),1))
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND ce.event_cd IN (mf_death_dt_tm_cd, mf_cs72_timecalledcircleoflife,
   mf_cs72_circleoflifestaffname, mf_cs72_calledcircleoflife, mf_pat_pronounced_by_cd,
   mf_cert_signed_by_cd, mf_med_exam_case_cd, mf_kin_notified_cd, mf_kin_notified_by_cd,
   mf_emp_contact_phone_cd,
   mf_kin_name_cd, mf_relation_cd, mf_rsn_not_notify_cd, mf_fetal_death_cd, mf_restrain_cd,
   mf_restrainttype_cd, mf_med_exam_notify_cd, mf_who_notify_exam_cd, mf_jurisdiction_cd,
   mf_bhs_autopsy_cd,
   mf_funeral_dir_cd, mf_funeral_addr_cd, mf_funeral_home_cd, mf_form_comp_by_cd, mf_form_comp_at_cd,
   mf_kin_phone, mf_kin_notify_data, mf_who_body_diposition, mf_resp_person_phone,
   mf_resp_person_reltn,
   mf_dispose_valuables, mf_funeralhome_phone, mf_cs72_neds_dt_tm, mf_cs72_neds_ref_num,
   mf_cs72_neds_staff))
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(mf_encntr_id))
    AND ea.encntr_alias_type_cd=mf_mrn_cd)
  ORDER BY ce.encntr_id, ce.parent_event_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   m_info->s_pat_name = trim(p.name_full_formatted), m_info->s_dob = trim(format(p.birth_dt_tm,
     "mm/dd/yyyy;;d")), m_info->s_mrn = trim(ea.alias)
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF mf_death_dt_tm_cd:
     ms_tmp = trim(substring(3,16,ce.result_val)),ms_tmp = concat(substring(5,2,ms_tmp),"/",substring
      (7,2,ms_tmp),"/",substring(1,4,ms_tmp),
      " ",substring(9,2,ms_tmp),":",substring(11,2,ms_tmp)),m_info->s_death_dt_tm = ms_tmp
    OF mf_cs72_calledcircleoflife:
     m_info->s_called_circle = trim(ce.result_val)
    OF mf_cs72_circleoflifestaffname:
     m_info->s_circle_staff = trim(ce.result_val)
    OF mf_cs72_timecalledcircleoflife:
     ms_tmp = trim(substring(3,16,ce.result_val)),ms_tmp = concat(substring(5,2,ms_tmp),"/",substring
      (7,2,ms_tmp),"/",substring(1,4,ms_tmp),
      " ",substring(9,2,ms_tmp),":",substring(11,2,ms_tmp)),m_info->s_circle_call_dt_tm = ms_tmp
    OF mf_pat_pronounced_by_cd:
     m_info->s_pronounced_by = trim(ce.result_val)
    OF mf_cert_signed_by_cd:
     m_info->s_cert_signed_by = trim(ce.result_val)
    OF mf_med_exam_case_cd:
     m_info->s_med_exam_case = trim(ce.result_val)
    OF mf_kin_notified_cd:
     m_info->s_kin_notified_ind = trim(ce.result_val)
    OF mf_kin_notified_by_cd:
     m_info->s_kin_notified_by = trim(ce.result_val)
    OF mf_emp_contact_phone_cd:
     m_info->s_emp_contact_phone_ext = trim(ce.result_val)
    OF mf_kin_name_cd:
     m_info->s_kin_name = trim(ce.result_val)
    OF mf_relation_cd:
     m_info->s_kin_relationship = trim(ce.result_val)
    OF mf_rsn_not_notify_cd:
     m_info->s_reason_not_notified = trim(ce.result_val)
    OF mf_fetal_death_cd:
     m_info->s_fetal_death_ind = trim(ce.result_val)
    OF mf_restrain_cd:
     m_info->s_restrained_ind = trim(ce.result_val)
    OF mf_restrainttype_cd:
     m_info->s_restraint_type = trim(ce.result_val)
    OF mf_med_exam_notify_cd:
     m_info->s_med_exam_notified_ind = trim(ce.result_val)
    OF mf_who_notify_exam_cd:
     m_info->s_person_notifying_med_exam = trim(ce.result_val)
    OF mf_jurisdiction_cd:
     m_info->s_jurisdiction_accepted = trim(ce.result_val)
    OF mf_bhs_autopsy_cd:
     m_info->s_bhs_autopsy_ind = trim(ce.result_val)
    OF mf_funeral_dir_cd:
     m_info->s_funeral_director = trim(ce.result_val)
    OF mf_funeral_addr_cd:
     m_info->s_funeral_addr = trim(ce.result_val)
    OF mf_funeral_home_cd:
     m_info->s_funeral_home = trim(ce.result_val)
    OF mf_form_comp_by_cd:
     m_info->s_death_form_comp_by = trim(ce.result_val)
    OF mf_form_comp_at_cd:
     ms_tmp = trim(substring(3,16,ce.result_val)),ms_tmp = concat(substring(5,2,ms_tmp),"/",substring
      (7,2,ms_tmp),"/",substring(1,4,ms_tmp),
      " ",substring(9,2,ms_tmp),":",substring(11,2,ms_tmp)),m_info->s_death_form_comp_dt_tm = ms_tmp
    OF mf_kin_phone:
     m_info->s_kin_phone = trim(ce.result_val)
    OF mf_kin_notify_data:
     m_info->s_kin_notify_data = trim(ce.result_val)
    OF mf_who_body_diposition:
     m_info->s_who_body_diposition = trim(ce.result_val)
    OF mf_resp_person_phone:
     m_info->s_resp_person_phone = trim(ce.result_val)
    OF mf_resp_person_reltn:
     m_info->s_resp_person_reltn = trim(ce.result_val)
    OF mf_dispose_valuables:
     m_info->s_dispose_valuables = trim(ce.result_val)
    OF mf_funeralhome_phone:
     m_info->s_funeralhome_phone = trim(ce.result_val)
    OF mf_cs72_neds_staff:
     m_info->s_neds_staff = trim(ce.result_val)
    OF mf_cs72_neds_dt_tm:
     m_info->s_neds_dt_tm = trim(ce.result_val)
    OF mf_cs72_neds_ref_num:
     m_info->s_neds_ref_num = trim(ce.result_val)
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET ms_log = concat("no DTA data found for encntr_id: ",trim(cnvtstring(mf_encntr_id)))
  CALL echo(ms_log)
  GO TO exit_script
 ENDIF
 SET d0 = detailsection(rpt_render)
 SET d0 = finalizereport(value(ms_output))
#exit_script
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
