CREATE PROGRAM bhs_rpt_post_acute_care_disch:dba
 CALL echorecord(request)
 FREE RECORD m_rec
 RECORD m_rec(
   1 f_person_id = f8
   1 f_encntr_id = f8
   1 s_reg_dt_tm = vc
   1 s_pat_name = vc
   1 s_mrn = vc
   1 s_fin = vc
   1 s_dob = vc
   1 s_age = vc
   1 s_home_addr = vc
   1 s_religion = vc
   1 s_prov_attending = vc
   1 s_prov_pcp = vc
   1 s_admit_dt_tm = vc
   1 s_admit_reason = vc
   1 s_disch_loc = vc
   1 s_ins_prim_type = vc
   1 s_ins_prim_name = vc
   1 s_ins_prim_subscriber = vc
   1 s_ins_prim_grp_num = vc
   1 s_ins_prim_member_num = vc
   1 s_ins_secon_type = vc
   1 s_ins_secon_name = vc
   1 s_ins_secon_subscriber = vc
   1 s_ins_secon_grp_num = vc
   1 s_ins_secon_member_num = vc
   1 s_ins_contacts = vc
   1 s_ins_reltn_emer_contact = vc
   1 s_ins_reltn = vc
   1 s_ins_home_phone = vc
   1 s_ins_bus_phone = vc
   1 forms[*]
     2 f_dfr_id = f8
     2 s_title = vc
     2 s_date = vc
     2 l_form_sort = i4
     2 section[*]
       3 s_title = vc
       3 l_sec_sort = i4
       3 dta[*]
         4 f_event_cd = f8
         4 s_disp = vc
         4 s_val = vc
         4 l_dta_sort = i4
   1 consult[*]
     2 f_event_cd = f8
     2 f_event_id = f8
     2 s_event_end_dt_tm = vc
     2 s_disp = vc
   1 advdir[*]
     2 f_event_cd = f8
     2 f_event_id = f8
     2 s_event_end_dt_tm = vc
     2 s_disp = vc
   1 raddta[*]
     2 f_event_cd = f8
     2 s_disp = vc
   1 radres[*]
     2 f_event_cd = f8
     2 f_event_id = f8
     2 s_event_end_dt_tm = vc
     2 s_disp = vc
   1 labres[*]
     2 f_activity_type_cd = f8
     2 f_event_cd = f8
     2 f_event_id = f8
     2 s_event_end_dt_tm = vc
     2 s_disp = vc
     2 s_result = vc
 ) WITH protect
 EXECUTE bhs_hlp_ccl
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE _creatertf(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
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
 DECLARE _remdet_value_noindent = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsec_det_noindent = i2 WITH noconstant(0), protect
 DECLARE _remdet_value_indent = i4 WITH noconstant(1), protect
 DECLARE _bcontsec_det_indent = i2 WITH noconstant(0), protect
 DECLARE _remfieldname0 = i4 WITH noconstant(1), protect
 DECLARE _bcontsec_note_rtf = i2 WITH noconstant(0), protect
 DECLARE _hrtf_fieldname0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = i4 WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"bhscust:baystate_logo_bw.jpg")
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
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
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
 SUBROUTINE (sec_head_rpt(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_head_rptabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_head_rptabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.440000), private
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 0.000),(offsety+ 0.000),1.750,
     0.500,1)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.010)
    SET rptsd->m_width = 3.490
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("POST-ACUTE DISCHARGE SUMMARY",char(0)
      ))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.490
    SET rptsd->m_height = 0.625
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "This document is an extraction of key elements of the patient's electronic record for this hospitalization.  If",
       " a more complete medical record is needed, please contact Health Information Management:"),
      char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.490
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "BMC 794-4203, BFMC 773-2353, BMLH 967-2143, BWH HIM (413)-284-5391",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_demog(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_demogabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_demogabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(3.020000), private
   DECLARE __fieldname12 = vc WITH noconstant(build2(m_rec->s_pat_name,char(0))), protect
   DECLARE __fieldname13 = vc WITH noconstant(build2(m_rec->s_admit_reason,char(0))), protect
   DECLARE __fieldname14 = vc WITH noconstant(build2(m_rec->s_admit_dt_tm,char(0))), protect
   DECLARE __fieldname15 = vc WITH noconstant(build2(m_rec->s_prov_pcp,char(0))), protect
   DECLARE __fieldname16 = vc WITH noconstant(build2(m_rec->s_prov_attending,char(0))), protect
   DECLARE __fieldname17 = vc WITH noconstant(build2(m_rec->s_religion,char(0))), protect
   DECLARE __fieldname18 = vc WITH noconstant(build2(m_rec->s_home_addr,char(0))), protect
   DECLARE __fieldname19 = vc WITH noconstant(build2(m_rec->s_age,char(0))), protect
   DECLARE __fieldname20 = vc WITH noconstant(build2(m_rec->s_dob,char(0))), protect
   DECLARE __fieldname21 = vc WITH noconstant(build2(m_rec->s_fin,char(0))), protect
   DECLARE __fieldname22 = vc WITH noconstant(build2(m_rec->s_mrn,char(0))), protect
   DECLARE __fieldname23 = vc WITH noconstant(build2(m_rec->s_disch_loc,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Account Number/FIN:",char(0)))
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Home Address:",char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Religion:",char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending Provider:",char(0)))
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Primary Care Provider:",char(0)))
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Discharging Location:",char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Reason:",char(0)))
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname12)
    SET rptsd->m_y = (offsety+ 2.490)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname13)
    SET rptsd->m_y = (offsety+ 2.240)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname14)
    SET rptsd->m_y = (offsety+ 1.990)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname15)
    SET rptsd->m_y = (offsety+ 1.740)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname16)
    SET rptsd->m_y = (offsety+ 1.490)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname17)
    SET rptsd->m_y = (offsety+ 1.240)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname18)
    SET rptsd->m_y = (offsety+ 0.990)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname19)
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname20)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname21)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname22)
    SET rptsd->m_y = (offsety+ 2.760)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname23)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_ins(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_insabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_insabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(4.000000), private
   DECLARE __fieldname24 = vc WITH noconstant(build2(m_rec->s_ins_prim_type,char(0))), protect
   DECLARE __fieldname17 = vc WITH noconstant(build2(m_rec->s_ins_bus_phone,char(0))), protect
   DECLARE __fieldname18 = vc WITH noconstant(build2(m_rec->s_ins_home_phone,char(0))), protect
   DECLARE __fieldname19 = vc WITH noconstant(build2(m_rec->s_ins_reltn,char(0))), protect
   DECLARE __fieldname20 = vc WITH noconstant(build2(m_rec->s_ins_reltn_emer_contact,char(0))),
   protect
   DECLARE __fieldname21 = vc WITH noconstant(build2(m_rec->s_ins_contacts,char(0))), protect
   DECLARE __fieldname22 = vc WITH noconstant(build2(m_rec->s_ins_secon_member_num,char(0))), protect
   DECLARE __fieldname23 = vc WITH noconstant(build2(m_rec->s_ins_secon_grp_num,char(0))), protect
   DECLARE __fieldname25 = vc WITH noconstant(build2(m_rec->s_ins_secon_subscriber,char(0))), protect
   DECLARE __fieldname26 = vc WITH noconstant(build2(m_rec->s_ins_secon_name,char(0))), protect
   DECLARE __fieldname27 = vc WITH noconstant(build2(m_rec->s_ins_secon_type,char(0))), protect
   DECLARE __fieldname28 = vc WITH noconstant(build2(m_rec->s_ins_prim_member_num,char(0))), protect
   DECLARE __fieldname29 = vc WITH noconstant(build2(m_rec->s_ins_prim_grp_num,char(0))), protect
   DECLARE __fieldname30 = vc WITH noconstant(build2(m_rec->s_ins_prim_subscriber,char(0))), protect
   DECLARE __fieldname31 = vc WITH noconstant(build2(m_rec->s_ins_prim_name,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Insurance Information",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname24)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Business Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 3.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Home Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name:",char(0)))
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Relation: Emergency Contact",char(0))
     )
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Contacts:	",char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Member Number:",char(0)))
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Group Number:",char(0)))
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Subscriber:",char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name",char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type: Secondary",char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Member Number:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Group Number:",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Subscriber:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname17)
    SET rptsd->m_y = (offsety+ 3.500)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname18)
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname19)
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname20)
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname21)
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname22)
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname23)
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname25)
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname26)
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname27)
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname28)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname29)
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname30)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname31)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type: Primary",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_head_title,char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_head_date,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_subhead(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_subheadabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_subheadabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_subhead_title,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_det_noindent(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_det_noindentabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_det_noindentabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_det_value_noindent = f8 WITH noconstant(0.0), private
   DECLARE __det_value_noindent = vc WITH noconstant(build2(ms_det_val,char(0))), protect
   IF (bcontinue=0)
    SET _remdet_value_noindent = 1
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
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdet_value_noindent = _remdet_value_noindent
   IF (_remdet_value_noindent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdet_value_noindent,((
       size(__det_value_noindent) - _remdet_value_noindent)+ 1),__det_value_noindent)))
    SET drawheight_det_value_noindent = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdet_value_noindent = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdet_value_noindent,((size(
        __det_value_noindent) - _remdet_value_noindent)+ 1),__det_value_noindent)))))
     SET _remdet_value_noindent += rptsd->m_drawlength
    ELSE
     SET _remdet_value_noindent = 0
    ENDIF
    SET growsum += _remdet_value_noindent
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.250
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_det_disp,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = drawheight_det_value_noindent
   IF (ncalc=rpt_render
    AND _holdremdet_value_noindent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdet_value_noindent,
       ((size(__det_value_noindent) - _holdremdet_value_noindent)+ 1),__det_value_noindent)))
   ELSE
    SET _remdet_value_noindent = _holdremdet_value_noindent
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 1.271
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_det_date,char(0)))
   ENDIF
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
 SUBROUTINE (sec_det_indent(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_det_indentabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_det_indentabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_det_value_indent = f8 WITH noconstant(0.0), private
   DECLARE __det_value_indent = vc WITH noconstant(build2(ms_det_val,char(0))), protect
   IF (bcontinue=0)
    SET _remdet_value_indent = 1
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
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdet_value_indent = _remdet_value_indent
   IF (_remdet_value_indent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdet_value_indent,((
       size(__det_value_indent) - _remdet_value_indent)+ 1),__det_value_indent)))
    SET drawheight_det_value_indent = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdet_value_indent = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdet_value_indent,((size(
        __det_value_indent) - _remdet_value_indent)+ 1),__det_value_indent)))))
     SET _remdet_value_indent += rptsd->m_drawlength
    ELSE
     SET _remdet_value_indent = 0
    ENDIF
    SET growsum += _remdet_value_indent
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_det_disp,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = drawheight_det_value_indent
   IF (ncalc=rpt_render
    AND _holdremdet_value_indent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdet_value_indent,(
       (size(__det_value_indent) - _holdremdet_value_indent)+ 1),__det_value_indent)))
   ELSE
    SET _remdet_value_indent = _holdremdet_value_indent
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_det_date,char(0)))
   ENDIF
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
 SUBROUTINE (sec_note_rtf(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_note_rtfabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_note_rtfabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname0 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(ms_note_rtf,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname0 = 1
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
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (substring(1,5,__fieldname0) != "{\rtf")
    SET _holdremfieldname0 = _remfieldname0
    IF (_remfieldname0 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname0,((size(
         __fieldname0) - _remfieldname0)+ 1),__fieldname0)))
     SET drawheight_fieldname0 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname0 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname0,((size(__fieldname0) -
        _remfieldname0)+ 1),__fieldname0)))))
      SET _remfieldname0 += rptsd->m_drawlength
     ELSE
      SET _remfieldname0 = 0
     ENDIF
     SET growsum += _remfieldname0
    ENDIF
   ENDIF
   IF (substring(1,5,__fieldname0)="{\rtf")
    IF (ncalc=rpt_render
     AND _remfieldname0 > 0)
     IF (_hrtf_fieldname0=0)
      SET _hrtf_fieldname0 = uar_rptcreatertf(_hreport,__fieldname0,7.500)
     ENDIF
     IF (_hrtf_fieldname0 != 0)
      SET _fdrawheight = maxheight
      SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_fieldname0,(offsetx+ 0.000),(offsety+ 0.000),
       _fdrawheight)
     ENDIF
     IF ((_fdrawheight > (sectionheight - 0.000)))
      SET sectionheight = (0.000+ _fdrawheight)
     ENDIF
     IF (_rptstat != rpt_continue)
      SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_fieldname0)
      SET _hrtf_fieldname0 = 0
      SET _remfieldname0 = 0
     ENDIF
    ENDIF
    SET growsum += _remfieldname0
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_fieldname0
   IF (substring(1,5,__fieldname0) != "{\rtf")
    IF (ncalc=rpt_render
     AND _holdremfieldname0 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname0,((size
        (__fieldname0) - _holdremfieldname0)+ 1),__fieldname0)))
    ELSE
     SET _remfieldname0 = _holdremfieldname0
    ENDIF
   ENDIF
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
 SUBROUTINE (sec_foot(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_footabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __patient_name = vc WITH noconstant(build2(m_rec->s_pat_name,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(m_rec->s_mrn,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.813)
    SET rptsd->m_width = 1.708
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_foot_rpt(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_foot_rptabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_foot_rptabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("END OF REPORT",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_POST_ACUTE_CARE_DISCH"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _stat = _loadimages(0)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 52
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_attend_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"PCP"))
 DECLARE mf_emer_cont_r_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",351,
   "EMERGENCYCONTACT"))
 DECLARE mf_dnrnocprbutoktointubate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DNRNOCPRBUTOKTOINTUBATE"))
 DECLARE mf_dnrdninocprnointubation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DNRDNINOCPRNOINTUBATION"))
 DECLARE mf_fullcodeconfirmed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FULLCODECONFIRMED"))
 DECLARE mf_fullcodepresumed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FULLCODEPRESUMED"))
 DECLARE mf_lim_resus_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LIMITEDRESUSCITATION"))
 DECLARE mf_isolation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ISOLATION"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"HOME"))
 DECLARE mf_phone_bus_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS"))
 DECLARE mf_adv_dir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ADVANCEDIRECTIVE"
   ))
 DECLARE mf_adv_dir_typ_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADVANCEDIRECTIVETYPE"))
 DECLARE mf_proxy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PROXY"))
 DECLARE mf_proxy_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CONTACTPROXYPHONENUMBER"))
 DECLARE mf_copy_on_chrt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COPYPLACEDONCHART"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mn_indent = i2 WITH protect, constant(1)
 DECLARE mn_noindent = i2 WITH protect, constant(0)
 DECLARE mn_pagebreak = i2 WITH protect, constant(1)
 DECLARE mn_nopagebreak = i2 WITH protect, constant(0)
 DECLARE mf_primary_event_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",18189,
   "PRIMARYEVENTID"))
 DECLARE mf_inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_notdone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_consultnotes_eventset_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "CONSULTNOTES"))
 DECLARE mf_adv_dir_eventset_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "ADVANCEDDIRECTIVERELATEDDOCUMENTS"))
 DECLARE mf_sacrament_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSACRAMENTALRESOURCES"))
 DECLARE mf_mattress_device_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MATTRESSDEVICECHG"))
 DECLARE mf_wound_loc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "WOUNDVACLOCATION"))
 DECLARE mf_wound_dress_intact_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DRESSINGINTACTWOUND"))
 DECLARE mf_sound_suction_set_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SUCTIONSETTINGWOUND"))
 DECLARE mf_wound_last_dress_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFLASTDRESSINGCHANGEWND"))
 DECLARE mf_wound_comment_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "WOUNDVACCOMMENTS"))
 DECLARE mf_mdoc_event_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE mf_doc_event_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mf_lab_cat_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "LABORATORY"))
 DECLARE mf_genlab_act_ty_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "GENERALLAB"))
 DECLARE mf_micro_act_ty_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE mf_ct_act_subtype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",5801,
   "COMPUTERIZEDTOMOGRAPHY"))
 DECLARE mf_mri_act_subtype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",5801,
   "MAGNETICRESONANCEIMAGING"))
 DECLARE mf_diag_act_subtype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",5801,
   "GENERALDIAGNOSTIC"))
 CALL echo(build2("mf_ADDR_HOME_CD: ",mf_addr_home_cd))
 CALL echo(build2("mf_ATTEND_CD: ",mf_attend_cd))
 CALL echo(build2("mf_PCP_CD: ",mf_pcp_cd))
 CALL echo(build2("mf_EMER_CONT_R_CD: ",mf_emer_cont_r_cd))
 CALL echo(build2("mf_LIM_RESUS_CD: ",mf_lim_resus_cd))
 CALL echo(build2("mf_ISOLATION_CD: ",mf_isolation_cd))
 CALL echo(build2("mf_ORDERED_CD: ",mf_ordered_cd))
 CALL echo(build2("mf_ADV_DIR_CD: ",mf_adv_dir_cd))
 CALL echo(build2("mf_ADV_DIR_TYP_CD: ",mf_adv_dir_typ_cd))
 CALL echo(build2("mf_PROXY_CD: ",mf_proxy_cd))
 CALL echo(build2("mf_PROXY_PHONE_CD: ",mf_proxy_phone_cd))
 CALL echo(build2("mf_COPY_ON_CHRT_CD: ",mf_copy_on_chrt_cd))
 CALL echo(build2("mf_AUTH_CD: ",mf_auth_cd))
 CALL echo(build2("mf_MODIFIED_CD: ",mf_modified_cd))
 CALL echo(build2("mf_ALTERED_CD: ",mf_altered_cd))
 CALL echo(build2("mf_PRIMARY_EVENT_CD: ",mf_primary_event_cd))
 CALL echo(build2("mf_INERROR_CD: ",mf_inerror_cd))
 CALL echo(build2("mf_NOTDONE_CD: ",mf_notdone_cd))
 CALL echo(build2("mf_CONSULTNOTES_EVENTSET_CD: ",mf_consultnotes_eventset_cd))
 CALL echo(build2("mf_ADV_DIR_EVENTSET_CD: ",mf_adv_dir_eventset_cd))
 CALL echo(build2("mf_SACRAMENT_CD: ",mf_sacrament_cd))
 CALL echo(build2("mf_MATTRESS_DEVICE_CD: ",mf_mattress_device_cd))
 CALL echo(build2("mf_WOUND_LOC_CD: ",mf_wound_loc_cd))
 CALL echo(build2("mf_WOUND_DRESS_INTACT_CD: ",mf_wound_dress_intact_cd))
 CALL echo(build2("mf_SOUND_SUCTION_SET_CD: ",mf_sound_suction_set_cd))
 CALL echo(build2("mf_WOUND_LAST_DRESS_CD: ",mf_wound_last_dress_cd))
 CALL echo(build2("mf_WOUND_COMMENT_CD: ",mf_wound_comment_cd))
 CALL echo(build2("mf_MDOC_EVENT_CLS_CD: ",mf_mdoc_event_cls_cd))
 CALL echo(build2("mf_LAB_CAT_TYPE_CD: ",mf_lab_cat_type_cd))
 CALL echo(build2("mf_GENLAB_ACT_TY_CD: ",mf_genlab_act_ty_cd))
 CALL echo(build2("mf_MICRO_ACT_TY_CD: ",mf_micro_act_ty_cd))
 CALL echo(build2("mf_CT_ACT_SUBTYPE_CD: ",mf_ct_act_subtype_cd))
 CALL echo(build2("mf_MRI_ACT_SUBTYPE_CD: ",mf_mri_act_subtype_cd))
 CALL echo(build2("mf_DIAG_ACT_SUBTYPE_CD: ",mf_diag_act_subtype_cd))
 CALL echo(build2("mf_DNRNOCPRBUTOKTOINTUBATE_CD: ",mf_dnrnocprbutoktointubate_cd))
 CALL echo(build2("mf_DNRDNINOCPRNOINTUBATION_CD: ",mf_dnrdninocprnointubation_cd))
 CALL echo(build2("mf_FULLCODECONFIRMED_CD: ",mf_fullcodeconfirmed_cd))
 CALL echo(build2("mf_FULLCODEPRESUMED_CD: ",mf_fullcodepresumed_cd))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_head_title = vc WITH protect, noconstant(" ")
 DECLARE ms_head_date = vc WITH protect, noconstant(" ")
 DECLARE ms_subhead_title = vc WITH protect, noconstant(" ")
 DECLARE ms_det_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_det_val = vc WITH protect, noconstant(" ")
 DECLARE ms_det_date = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 DECLARE becont = i2 WITH protect, noconstant(0)
 DECLARE ml_exp = i2 WITH protect, noconstant(0)
 CALL echo("get patient demog info")
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2,
   encntr_prsnl_reltn epr1,
   prsnl pr1,
   encntr_prsnl_reltn epr2,
   prsnl pr2,
   address a
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
   JOIN (epr1
   WHERE (epr1.encntr_id= Outerjoin(e.encntr_id))
    AND (epr1.active_ind= Outerjoin(1))
    AND (epr1.encntr_prsnl_r_cd= Outerjoin(mf_attend_cd)) )
   JOIN (pr1
   WHERE (pr1.person_id= Outerjoin(epr1.prsnl_person_id))
    AND (pr1.active_ind= Outerjoin(1))
    AND (pr1.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (epr2
   WHERE (epr2.encntr_id= Outerjoin(e.encntr_id))
    AND (epr2.active_ind= Outerjoin(1))
    AND (epr2.encntr_prsnl_r_cd= Outerjoin(mf_pcp_cd)) )
   JOIN (pr2
   WHERE (pr2.person_id= Outerjoin(epr2.prsnl_person_id))
    AND (pr2.active_ind= Outerjoin(1))
    AND (pr2.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(e.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.active_ind= Outerjoin(1))
    AND (a.address_type_cd= Outerjoin(mf_addr_home_cd)) )
  HEAD e.encntr_id
   m_rec->f_encntr_id = e.encntr_id, m_rec->s_reg_dt_tm = trim(format(e.reg_dt_tm,
     "dd-mmm-yyyy hh:mm:ss;;d"),3), m_rec->f_person_id = e.person_id,
   m_rec->s_pat_name = trim(p.name_full_formatted), m_rec->s_fin = trim(ea1.alias,3), m_rec->s_mrn =
   trim(ea2.alias,3),
   m_rec->s_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy hh:mm;;d"),3), m_rec->s_age = cnvtage(p
    .birth_dt_tm)
   IF (textlen(trim(a.street_addr,3)) > 0)
    ms_tmp = trim(a.street_addr,3)
   ENDIF
   IF (textlen(trim(a.street_addr2,3)) > 0)
    ms_tmp = concat(ms_tmp," ",trim(a.street_addr2,3))
   ENDIF
   IF (textlen(trim(a.street_addr3,3)) > 0)
    ms_tmp = concat(ms_tmp," ",trim(a.street_addr3,3))
   ENDIF
   IF (textlen(trim(a.street_addr4,3)) > 0)
    ms_tmp = concat(ms_tmp," ",trim(a.street_addr4,3))
   ENDIF
   IF (textlen(trim(a.city,3)) > 0)
    ms_tmp = concat(ms_tmp," ",trim(a.city,3))
   ENDIF
   IF (textlen(trim(a.state,3)) > 0)
    ms_tmp = concat(ms_tmp," ",trim(a.state,3))
   ENDIF
   IF (textlen(trim(a.zipcode,3)) > 0)
    ms_tmp = concat(ms_tmp," ",trim(a.zipcode,3))
   ENDIF
   m_rec->s_home_addr = ms_tmp, m_rec->s_religion = trim(uar_get_code_display(p.religion_cd),3),
   m_rec->s_prov_attending = trim(pr1.name_full_formatted,3),
   m_rec->s_prov_pcp = trim(pr2.name_full_formatted,3), m_rec->s_admit_dt_tm = trim(format(e
     .reg_dt_tm,"mm/dd/yyyy hh:mm;;d")), m_rec->s_admit_reason = trim(e.reason_for_visit,3),
   m_rec->s_disch_loc = trim(uar_get_code_display(e.disch_to_loctn_cd),3)
  WITH nocounter
 ;end select
 CALL echo("get insurance info")
 SELECT INTO "nl:"
  FROM encntr_plan_reltn epr,
   person p1,
   person_alias pa,
   health_plan hp,
   organization org,
   person_person_reltn ppr,
   person p2,
   phone ph1,
   phone ph2
  PLAN (epr
   WHERE (epr.encntr_id=request->visit[1].encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (p1
   WHERE p1.person_id=epr.person_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(epr.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(18))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.active_ind=1)
   JOIN (org
   WHERE (org.organization_id= Outerjoin(epr.organization_id)) )
   JOIN (ppr
   WHERE (ppr.person_id= Outerjoin(p1.person_id))
    AND (ppr.active_ind= Outerjoin(1))
    AND (ppr.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ppr.person_reltn_type_cd= Outerjoin(mf_emer_cont_r_cd)) )
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(ppr.related_person_id))
    AND (p2.active_ind= Outerjoin(1))
    AND (p2.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (ph1
   WHERE (ph1.parent_entity_id= Outerjoin(p2.person_id))
    AND (ph1.parent_entity_name= Outerjoin("PERSON"))
    AND (ph1.active_ind= Outerjoin(1))
    AND (ph1.phone_type_cd= Outerjoin(mf_phone_home_cd)) )
   JOIN (ph2
   WHERE (ph2.parent_entity_id= Outerjoin(p2.person_id))
    AND (ph2.parent_entity_name= Outerjoin("PERSON"))
    AND (ph2.active_ind= Outerjoin(1))
    AND (ph2.phone_type_cd= Outerjoin(mf_phone_bus_cd)) )
  ORDER BY epr.priority_seq
  HEAD REPORT
   pn_ins_cnt = 0
  HEAD epr.priority_seq
   IF (epr.priority_seq=1)
    s_ins_prim_type = trim(uar_get_code_display(hp.plan_type_cd),3), s_ins_prim_name = trim(org
     .org_name,3), s_ins_prim_subscriber = trim(epr.insured_card_name,3),
    s_ins_prim_grp_num = trim(epr.group_nbr,3), s_ins_prim_member_num = trim(epr.member_nbr,3)
   ELSEIF (epr.priority_seq=2)
    s_ins_secon_type = trim(uar_get_code_display(hp.plan_type_cd),3), s_ins_secon_name = trim(org
     .org_name,3), s_ins_secon_subscriber = trim(epr.insured_card_name,3),
    s_ins_secon_grp_num = trim(epr.group_nbr,3), s_ins_secon_member_num = trim(epr.member_nbr,3)
   ENDIF
   m_rec->s_ins_reltn_emer_contact = trim(uar_get_code_display(ppr.person_reltn_cd),3), m_rec->
   s_ins_reltn = trim(p2.name_full_formatted,3), m_rec->s_ins_home_phone = trim(ph1.phone_num,3),
   m_rec->s_ins_bus_phone = trim(ph2.phone_num,3)
  WITH nocounter
 ;end select
 SET d0 = sec_head_rpt(rpt_render)
 CALL sbr_print_sec("","","Patient Name:",m_rec->s_pat_name,"",
  mn_noindent)
 CALL sbr_print_sec("","","MRN:",m_rec->s_mrn,"",
  mn_noindent)
 CALL sbr_print_sec("","","Account Number/FIN:",m_rec->s_fin,"",
  mn_noindent)
 CALL sbr_print_sec("","","Date of Birth:",m_rec->s_dob,"",
  mn_noindent)
 CALL sbr_print_sec("","","Age:",m_rec->s_age,"",
  mn_noindent)
 CALL sbr_print_sec("","","Home Address:",m_rec->s_home_addr,"",
  mn_noindent)
 CALL sbr_print_sec("","","Religion:",m_rec->s_religion,"",
  mn_noindent)
 CALL sbr_print_sec("","","Attending Provider:",m_rec->s_prov_attending,"",
  mn_noindent)
 CALL sbr_print_sec("","","Primary Care Provider:",m_rec->s_prov_pcp,"",
  mn_noindent)
 CALL sbr_print_sec("","","Admit Date:",m_rec->s_admit_dt_tm,"",
  mn_noindent)
 CALL sbr_print_sec("","","Admit Reason:",m_rec->s_admit_reason,"",
  mn_noindent)
 CALL sbr_print_sec("","","Discharging Location:",m_rec->s_disch_loc,"",
  mn_noindent)
 CALL sbr_print_sec("Insurance Information","","","","",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Type: Primary",m_rec->s_ins_prim_type,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Name",m_rec->s_ins_prim_name,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Subscriber",m_rec->s_ins_prim_subscriber,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Group Number",m_rec->s_ins_prim_grp_num,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Member Number",m_rec->s_ins_prim_member_num,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Type: Secondary",m_rec->s_ins_secon_type,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Name",m_rec->s_ins_secon_name,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Subscriber",m_rec->s_ins_secon_subscriber,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Group Number",m_rec->s_ins_secon_grp_num,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Member Number",m_rec->s_ins_secon_member_num,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Contacts",m_rec->s_ins_contacts,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Relation: Emergency Contact",m_rec->
  s_ins_reltn_emer_contact,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Name",m_rec->s_ins_reltn,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Home Phone",m_rec->s_ins_home_phone,"",
  mn_indent)
 CALL sbr_print_sec("Insurance Information","","Business Phone",m_rec->s_ins_bus_phone,"",
  mn_indent)
 CALL echo("get code status")
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.person_id=m_rec->f_person_id)
   AND (o.encntr_id=m_rec->f_encntr_id)
   AND o.catalog_cd IN (mf_dnrnocprbutoktointubate_cd, mf_dnrdninocprnointubation_cd,
  mf_fullcodeconfirmed_cd, mf_lim_resus_cd, mf_fullcodepresumed_cd)
   AND o.active_ind=1
   AND o.order_status_cd=mf_ordered_cd
  ORDER BY o.catalog_cd, o.orig_order_dt_tm DESC
  HEAD REPORT
   CALL sbr_print_sec("Code Status","","","","",mn_noindent)
  HEAD o.catalog_cd
   CALL sbr_print_sec("Code Status","",trim(uar_get_code_display(o.catalog_cd),3),trim(format(o
     .orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d"),3),"",mn_indent)
  WITH nocounter
 ;end select
 CALL echo("get adv dir")
 SELECT INTO "nl:"
  pl_sort =
  IF (ce.event_cd=mf_adv_dir_cd) 1
  ELSEIF (ce.event_cd=mf_proxy_cd) 2
  ELSEIF (ce.event_cd=mf_proxy_phone_cd) 3
  ELSEIF (ce.event_cd=mf_adv_dir_typ_cd) 4
  ELSEIF (ce.event_cd=mf_copy_on_chrt_cd) 5
  ENDIF
  FROM clinical_event ce
  WHERE (ce.encntr_id=request->visit[1].encntr_id)
   AND ce.event_cd IN (mf_adv_dir_cd, mf_adv_dir_typ_cd, mf_proxy_cd, mf_proxy_phone_cd,
  mf_copy_on_chrt_cd)
   AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
  ORDER BY pl_sort, ce.event_end_dt_tm DESC
  HEAD REPORT
   CALL sbr_print_sec("Advance Directive","","","","",mn_noindent)
  HEAD pl_sort
   ms_tmp = trim(ce.result_val)
   CASE (ce.event_cd)
    OF mf_adv_dir_cd:
     CALL sbr_print_sec("Advance Directive","","Proxy",ms_tmp,"",mn_indent)
    OF mf_proxy_cd:
     CALL sbr_print_sec("Advance Directive","","Proxy Name",ms_tmp,"",mn_indent)
    OF mf_proxy_phone_cd:
     CALL sbr_print_sec("Advance Directive","","Proxy Phone",ms_tmp,"",mn_indent)
    OF mf_adv_dir_typ_cd:
     CALL sbr_print_sec("Advance Directive","","Type",ms_tmp,"",mn_indent)
    OF mf_copy_on_chrt_cd:
     CALL sbr_print_sec("Advance Directive","","Copy on Chart",ms_tmp,"",mn_indent)
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo("get allergies")
 SELECT INTO "nl:"
  FROM allergy a,
   nomenclature n1,
   reaction r,
   nomenclature n2
  PLAN (a
   WHERE (a.person_id=m_rec->f_person_id)
    AND a.active_ind=1
    AND a.end_effective_dt_tm > sysdate)
   JOIN (n1
   WHERE n1.nomenclature_id=a.substance_nom_id
    AND n1.active_ind=1)
   JOIN (r
   WHERE (r.allergy_id= Outerjoin(a.allergy_id))
    AND r.active_ind=1)
   JOIN (n2
   WHERE (n2.nomenclature_id= Outerjoin(r.reaction_nom_id)) )
  HEAD REPORT
   CALL sbr_print_sec("Allergies","","","","",mn_noindent)
  DETAIL
   IF (textlen(trim(r.reaction_ftdesc,3)) > 0)
    ms_tmp = trim(r.reaction_ftdesc,3)
   ELSE
    ms_tmp = trim(n2.source_string,3)
   ENDIF
   CALL sbr_print_sec("Allergies","",trim(n1.source_string,3),ms_tmp,"",mn_indent)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  CALL sbr_print_sec("Allergies","","No Known Allergies","","",
   mn_indent)
 ENDIF
 CALL sbr_print_powerform("Case Management Readmission Patient Interview - BHS",mn_pagebreak)
 CALL sbr_print_powerform("Medical Necessity for Ambulance - BHS",mn_pagebreak)
 CALL sbr_print_powernote("Physician Discharge Summary",mn_pagebreak)
 CALL sbr_print_powernote("Hospitalist Discharge Summary - Update",mn_pagebreak)
 CALL sbr_print_powernote("Observation Exit Summary",mn_pagebreak)
 CALL sbr_print_powernote("BHS Surgical Discharge Summary",mn_pagebreak)
 CALL sbr_print_powernote("Physician Psychiatry Discharge Summary",mn_pagebreak)
 CALL sbr_print_powernote("Surgery Pedi Discharge Note",mn_pagebreak)
 CALL sbr_print_powernote("ICU Admit Note",mn_pagebreak)
 CALL sbr_print_powernote("BHS PICU Admission Note",mn_pagebreak)
 CALL sbr_print_powernote("Surgery Pedi Admit Note",mn_pagebreak)
 CALL sbr_print_powernote("BHS Gyn Admission Note",mn_pagebreak)
 CALL sbr_print_powernote("BHS Cardiac H & P",mn_pagebreak)
 CALL sbr_print_powernote("Medical H & P",mn_pagebreak)
 CALL sbr_print_powernote("Pediatric Surgery H & P",mn_pagebreak)
 CALL sbr_print_powernote("Psychiatric H & P",mn_pagebreak)
 CALL sbr_print_powernote("Surgical H & P",mn_pagebreak)
 CALL sbr_print_powernote("BHS Trauma H & P",mn_pagebreak)
 CALL sbr_print_powernote("BHS Surgical Directed H & P",mn_pagebreak)
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.event_cd IN (
  (SELECT
   vese.event_cd
   FROM v500_event_set_explode vese
   WHERE vese.event_set_cd=mf_consultnotes_eventset_cd))
   AND (ce.encntr_id=m_rec->f_encntr_id)
   AND (ce.person_id=m_rec->f_person_id)
   AND ce.event_end_dt_tm >= cnvtdatetime(m_rec->s_reg_dt_tm)
   AND ce.valid_until_dt_tm > sysdate
   AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
   AND ce.event_class_cd=224
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->consult,pl_cnt), m_rec->consult[pl_cnt].f_event_cd = ce.event_cd,
   m_rec->consult[pl_cnt].s_disp = trim(uar_get_code_display(ce.event_cd)), m_rec->consult[pl_cnt].
   f_event_id = ce.event_id, m_rec->consult[pl_cnt].s_event_end_dt_tm = trim(format(ce
     .event_end_dt_tm,"dd-mmm-yyyy hh:mm;;d"),3)
  WITH nocounter
 ;end select
 IF (size(m_rec->consult,5))
  FOR (ml_loop = 1 TO size(m_rec->consult,5))
    SET ms_head_title = m_rec->consult[ml_loop].s_disp
    SET ms_head_date = m_rec->consult[ml_loop].s_event_end_dt_tm
    CALL sbr_print_blob(m_rec->consult[ml_loop].f_event_id,mn_pagebreak)
  ENDFOR
 ENDIF
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.event_cd IN (
  (SELECT
   vese.event_cd
   FROM v500_event_set_explode vese
   WHERE vese.event_set_cd=mf_adv_dir_eventset_cd))
   AND (ce.encntr_id=m_rec->f_encntr_id)
   AND (ce.person_id=m_rec->f_person_id)
   AND ce.event_end_dt_tm >= cnvtdatetime(m_rec->s_reg_dt_tm)
   AND ce.valid_until_dt_tm > sysdate
   AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
   AND ce.event_class_cd=224
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->advdir,pl_cnt), m_rec->advdir[pl_cnt].f_event_cd = ce.event_cd,
   m_rec->advdir[pl_cnt].s_disp = trim(uar_get_code_display(ce.event_cd)), m_rec->advdir[pl_cnt].
   f_event_id = ce.event_id, m_rec->advdir[pl_cnt].s_event_end_dt_tm = trim(format(ce.event_end_dt_tm,
     "dd-mmm-yyyy hh:mm;;d"),3)
  WITH nocounter
 ;end select
 IF (size(m_rec->advdir,5))
  CALL echo("print advdir")
  FOR (ml_loop = 1 TO size(m_rec->advdir,5))
    SET ms_head_title = m_rec->advdir[ml_loop].s_disp
    SET ms_head_date = m_rec->advdir[ml_loop].s_event_end_dt_tm
    CALL sbr_print_blob(m_rec->advdir[ml_loop].f_event_id,mn_pagebreak)
  ENDFOR
 ENDIF
 CALL sbr_print_powerform("Nutrition Discharge Status - BHS",mn_pagebreak)
 CALL sbr_print_powernote("BHS Case Management Discharge Plan",mn_pagebreak)
 CALL sbr_print_powernote("BHS Psychiatric Discharge Plan",mn_pagebreak)
 CALL echo("get immunizations")
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.event_cd IN (
   (SELECT
    b.event_cd
    FROM bhs_event_cd_list b
    WHERE b.listkey="VACCINES"
     AND b.grouper IN ("FLU", "PNEUMO")
     AND b.active_ind=1))
    AND (ce.encntr_id=m_rec->f_encntr_id)
    AND (ce.person_id=m_rec->f_person_id)
    AND ce.event_end_dt_tm >= cnvtdatetime(m_rec->s_reg_dt_tm)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   CALL echo("here"),
   CALL sbr_break_page(0),
   CALL sbr_print_sec("Immunizations Received During Hospitalization","","","","",mn_noindent),
   CALL sbr_print_sec("Immunizations Received During Hospitalization","",trim(uar_get_code_display(ce
     .event_cd),3),trim(format(ce.performed_dt_tm,"dd-mmm-yyyy hh:mm;;d"),3),"",mn_indent)
  WITH nocounter
 ;end select
 CALL echo("get isolation orders")
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.person_id=m_rec->f_person_id)
   AND (o.encntr_id=m_rec->f_encntr_id)
   AND o.catalog_cd=mf_isolation_cd
   AND o.active_ind=1
   AND o.order_status_cd=mf_ordered_cd
  ORDER BY o.catalog_cd, o.orig_order_dt_tm DESC
  HEAD REPORT
   CALL sbr_print_sec("Infection Control","","","","",mn_noindent)
  HEAD o.catalog_cd
   CALL sbr_print_sec("Infection Control","",trim(uar_get_code_display(o.catalog_cd),3),trim(format(o
     .orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d"),3),"",mn_indent)
  WITH nocounter
 ;end select
 CALL echo("get sacraments of sick/anointing")
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.event_cd=mf_sacrament_cd
   AND (ce.encntr_id=m_rec->f_encntr_id)
   AND (ce.person_id=m_rec->f_person_id)
   AND ce.event_end_dt_tm >= cnvtdatetime(m_rec->s_reg_dt_tm)
   AND ce.valid_until_dt_tm > sysdate
   AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
   AND trim(ce.result_val,3)="Sacrament of the Sick/Anointing"
  HEAD REPORT
   CALL sbr_print_sec("Sacraments of the Sick/Anointing",trim(format(ce.event_end_dt_tm,
     "dd-mmm-yyyy hh:mm;;d"),3),"","","",mn_noindent),
   CALL sbr_print_sec("Sacraments of the Sick/Anointing","",trim(uar_get_code_display(ce.event_cd),3),
   trim(ce.result_val,3),"",mn_indent)
  WITH nocounter
 ;end select
 CALL echo("get special information")
 SELECT INTO "nl:"
  pl_sort =
  IF (ce.event_cd=mf_mattress_device_cd) 1
  ELSEIF (ce.event_cd=mf_wound_loc_cd) 2
  ELSEIF (ce.event_cd=mf_wound_dress_intact_cd) 3
  ELSEIF (ce.event_cd=mf_sound_suction_set_cd) 4
  ELSEIF (ce.event_cd=mf_wound_last_dress_cd) 5
  ELSEIF (ce.event_cd=mf_wound_comment_cd) 6
  ENDIF
  FROM clinical_event ce
  WHERE ce.event_cd IN (mf_mattress_device_cd, mf_wound_loc_cd, mf_wound_dress_intact_cd,
  mf_sound_suction_set_cd, mf_wound_last_dress_cd,
  mf_wound_comment_cd)
   AND (ce.encntr_id=m_rec->f_encntr_id)
   AND (ce.person_id=m_rec->f_person_id)
   AND ce.event_end_dt_tm >= cnvtdatetime(m_rec->s_reg_dt_tm)
   AND ce.valid_until_dt_tm > sysdate
   AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
  ORDER BY pl_sort, ce.event_end_dt_tm DESC
  HEAD REPORT
   ms_tmp = " ", ps_year = fillstring(4," "), ps_month = fillstring(2," "),
   ps_day = fillstring(2," "), ps_hour = fillstring(2," "), ps_min = fillstring(2," "),
   CALL sbr_print_sec("Special Information","","","","",mn_noindent)
  HEAD pl_sort
   ms_tmp = trim(ce.result_val,3)
   IF (ce.event_cd=mf_wound_last_dress_cd)
    ms_tmp = substring(3,16,ms_tmp), ps_year = substring(1,4,ms_tmp), ps_month = substring(5,2,ms_tmp
     ),
    ps_day = substring(7,2,ms_tmp), ps_hour = substring(9,2,ms_tmp), ps_min = substring(11,2,ms_tmp),
    ms_tmp = concat(ps_month,"/",ps_day,"/",ps_year,
     " ",ps_hour,":",ps_min)
   ENDIF
   CALL sbr_print_sec("Special Information","",trim(uar_get_code_display(ce.event_cd),3),ms_tmp,trim(
    format(ce.performed_dt_tm,"dd-mmm-yyyy hh:mm;;d"),3),mn_indent)
  WITH nocounter
 ;end select
 CALL echo("get labs")
 SELECT INTO "nl:"
  pn_sort =
  IF (o.activity_type_cd=mf_genlab_act_ty_cd) 1
  ELSEIF (o.activity_type_cd=mf_micro_act_ty_cd) 2
  ENDIF
  FROM clinical_event ce,
   orders o
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND ce.event_end_dt_tm > cnvtlookbehind("48,H",sysdate)
    AND ce.order_id > 0.0
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_lab_cat_type_cd
    AND o.activity_type_cd IN (mf_genlab_act_ty_cd, mf_micro_act_ty_cd))
  ORDER BY pn_sort, o.order_mnemonic, ce.event_end_dt_tm
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   IF (((o.activity_type_cd=mf_genlab_act_ty_cd) OR (o.activity_type_cd=mf_micro_act_ty_cd
    AND ce.event_class_cd=mf_doc_event_cls_cd)) )
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->labres,5))
     CALL alterlist(m_rec->labres,(pl_cnt+ 10))
    ENDIF
    m_rec->labres[pl_cnt].f_activity_type_cd = o.activity_type_cd, m_rec->labres[pl_cnt].f_event_cd
     = ce.event_cd, m_rec->labres[pl_cnt].f_event_id = ce.event_id,
    m_rec->labres[pl_cnt].s_disp = trim(uar_get_code_display(ce.event_cd)), m_rec->labres[pl_cnt].
    s_event_end_dt_tm = trim(format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm;;d"),3), m_rec->labres[
    pl_cnt].s_result = concat(trim(ce.result_val,3)," ",trim(uar_get_code_display(ce.result_units_cd),
      3))
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->labres,pl_cnt)
  WITH nocounter
 ;end select
 IF (size(m_rec->labres,5) > 0)
  CALL sbr_print_sec("Lab Results","","","","",
   mn_noindent)
  FOR (ml_loop = 1 TO size(m_rec->labres,5))
    IF ((m_rec->labres[ml_loop].f_activity_type_cd=mf_genlab_act_ty_cd))
     CALL echo(concat("print sec: ",m_rec->labres[ml_loop].s_disp," ",m_rec->labres[ml_loop].s_result,
       " ",
       m_rec->labres[ml_loop].s_event_end_dt_tm))
     CALL sbr_print_sec("","",concat(m_rec->labres[ml_loop].s_disp,":"),m_rec->labres[ml_loop].
      s_result,m_rec->labres[ml_loop].s_event_end_dt_tm,
      mn_indent)
    ELSEIF ((m_rec->labres[ml_loop].f_activity_type_cd=mf_micro_act_ty_cd))
     SET ms_head_title = m_rec->labres[ml_loop].s_disp
     SET ms_head_date = m_rec->labres[ml_loop].s_event_end_dt_tm
     CALL sbr_print_blob(m_rec->labres[ml_loop].f_event_id,mn_pagebreak)
    ENDIF
  ENDFOR
 ENDIF
 SET mf_rem_space = (mf_page_size - ((_yoffset+ sec_foot(rpt_calcheight))+ sec_foot_rpt(
  rpt_calcheight)))
 CALL echo(build2("remaining space at end: ",mf_rem_space," yoffset: ",_yoffset))
 IF ((mf_rem_space < (sec_foot(rpt_calcheight)+ sec_foot_rpt(rpt_calcheight))))
  CALL sbr_break_page(0)
 ENDIF
 SET d0 = sec_foot_rpt(rpt_render)
 SET _yoffset = 10.25
 SET d0 = sec_foot(rpt_render)
 SET d0 = finalizereport(request->output_device)
 SUBROUTINE (sbr_break_page(var=i2) =null)
   SET _yoffset = 10.25
   SET d0 = sec_foot(rpt_render)
   SET d0 = pagebreak(0)
 END ;Subroutine
 SUBROUTINE (sbr_print_sec(s_head_title=vc,s_head_date=vc,s_det_disp=vc,s_det_val=vc,s_det_date=vc,
  n_indent=i2) =null WITH protect)
   SET mf_rem_space = (mf_page_size - (_yoffset+ sec_foot(rpt_calcheight)))
   SET ms_head_title = trim(s_head_title,3)
   SET ms_head_date = trim(s_head_date,3)
   SET ms_det_disp = trim(s_det_disp,3)
   SET ms_det_val = trim(s_det_val,3)
   SET ms_det_date = trim(s_det_date,3)
   IF (textlen(trim(ms_head_title,3)) > 0
    AND textlen(trim(ms_det_disp,3))=0)
    IF (mf_rem_space < sec_head(rpt_calcheight))
     CALL echo("break1")
     CALL sbr_break_page(0)
    ENDIF
    SET d0 = sec_head(rpt_render)
   ELSEIF (textlen(trim(ms_det_disp,3)) > 0
    AND textlen(trim(ms_det_val,3)) > 0)
    SET becont = 0
    IF (mf_rem_space < sec_det_indent(rpt_calcheight,10.25,becont))
     CALL echo(build2("break2: ",mf_rem_space))
     CALL sbr_break_page(0)
     IF (textlen(ms_head_title) > 0)
      SET d0 = sec_head(rpt_render)
     ENDIF
    ENDIF
    IF (n_indent=mn_indent)
     SET becont = 0
     SET d0 = sec_det_indent(rpt_render,10.25,becont)
     WHILE (becont=1)
       CALL echo(build2("break3: ",mf_rem_space))
       CALL sbr_page_break(0)
       SET d0 = sec_det_indent(rpt_render,10.25,becont)
     ENDWHILE
    ELSEIF (n_indent=mn_noindent)
     SET becont = 0
     SET d0 = sec_det_noindent(rpt_render,10.25,becont)
     WHILE (becont=1)
       CALL echo(build2("break4: ",mf_rem_space))
       CALL sbr_page_break(0)
       SET d0 = sec_det_noindent(rpt_render,10.25,becont)
     ENDWHILE
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (sbr_print_powerform(s_definition=vc,n_pagebreak=i2) =null WITH protect)
   SET ms_head_title = " "
   SET ms_head_date = " "
   SET ms_det_disp = " "
   SET ms_det_val = " "
   SET ms_det_date = " "
   SELECT INTO "nl:"
    ps_form = uar_get_code_display(ce1.event_cd), ps_section = uar_get_code_display(ce2.event_cd),
    ps_dta = uar_get_code_display(ce3.event_cd),
    ccr.sequence_nbr
    FROM dcp_forms_ref dfr,
     dcp_forms_activity dfa,
     dcp_forms_activity_comp dfac,
     clinical_event ce1,
     clinical_event ce2,
     clinical_event ce3,
     ce_coded_result ccr
    PLAN (dfr
     WHERE dfr.definition=s_definition
      AND dfr.active_ind=1)
     JOIN (dfa
     WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
      AND (dfa.encntr_id=m_rec->f_encntr_id)
      AND (dfa.person_id=m_rec->f_person_id)
      AND dfa.active_ind=1)
     JOIN (dfac
     WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
      AND dfac.component_cd=mf_primary_event_cd
      AND dfac.parent_entity_name="CLINICAL_EVENT")
     JOIN (ce1
     WHERE ce1.parent_event_id=dfac.parent_entity_id
      AND ce1.view_level=1
      AND ce1.publish_flag=1
      AND  NOT (ce1.result_status_cd IN (mf_inerror_cd, mf_notdone_cd)))
     JOIN (ce2
     WHERE ce2.parent_event_id=ce1.event_id
      AND ce2.view_level=0
      AND ce2.publish_flag=1)
     JOIN (ce3
     WHERE ce3.parent_event_id=ce2.event_id
      AND ce3.view_level=1
      AND ce3.publish_flag=1
      AND  NOT (ce3.result_status_cd IN (mf_inerror_cd, mf_notdone_cd)))
     JOIN (ccr
     WHERE (ccr.event_id= Outerjoin(ce3.event_id)) )
    ORDER BY dfa.form_dt_tm DESC, ps_form, ps_section,
     ps_dta, ccr.sequence_nbr
    HEAD REPORT
     pn_coded_res = 0, ms_head_title = "", ms_subhead_title = "",
     ms_det_disp = "", ms_det_val = ""
     IF (n_pagebreak=1)
      CALL echo("pagebreak form"),
      CALL sbr_break_page(0)
     ENDIF
    HEAD ps_form
     ms_head_title = trim(uar_get_code_display(ce1.event_cd),3), ms_head_date = trim(format(dfa
       .form_dt_tm,"dd-mmm-yyyy hh:mm;;d"),3), d0 = sec_head(rpt_render)
    HEAD ps_section
     ms_subhead_title = trim(uar_get_code_display(ce2.event_cd),3)
     IF (ms_subhead_title != "DCP GENERIC CODE")
      d0 = sec_subhead(rpt_render)
     ENDIF
    HEAD ps_dta
     CALL echo("start dta"), ps_coded_res = 0, ms_det_disp = trim(uar_get_code_display(ce3.event_cd),
      3),
     ms_det_val = trim(ce3.result_val,3)
     IF (ccr.event_id > 0.0)
      CALL echo("ce_coded_result found"), ms_det_val = "", ps_coded_res = 1
     ELSE
      CALL echo("not found")
     ENDIF
    HEAD ccr.sequence_nbr
     IF (ps_coded_res=1)
      CALL echo(build2("event_id: ",ce3.event_id," seq: ",ccr.sequence_nbr)),
      CALL echo(build2("ccr.disp: ",ccr.descriptor))
      IF (textlen(trim(ms_det_val,3)) > 0)
       ms_det_val = concat(ms_det_val,",")
      ENDIF
      ms_det_val = concat(trim(ms_det_val,3),trim(ccr.descriptor,3))
     ENDIF
    FOOT  ps_dta
     CALL echo(ms_det_val), mf_rem_space = (mf_page_size - ((_yoffset+ sec_det_indent(rpt_calcheight,
      10.5,becont))+ sec_foot(rpt_calcheight)))
     IF (mf_rem_space < sec_det_indent(rpt_calcheight,10.5,becont))
      CALL sbr_break_page(0)
     ENDIF
     becont = 0, d0 = sec_det_indent(rpt_render,10.5,becont)
     WHILE (becont=1)
      CALL sbr_break_page(0),d0 = sec_det_indent(rpt_render,10.5,becont)
     ENDWHILE
     CALL echo("end dta"),
     CALL echo("...")
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (sbr_print_powernote(s_definition=vc,n_pagebreak=i2) =null WITH protect)
   DECLARE mf_event_id = f8 WITH protect, noconstant(0.0)
   SET mf_event_id = 0.0
   SET ms_head_title = " "
   SET ms_head_date = " "
   SELECT INTO "nl:"
    FROM scr_pattern sp,
     scd_story_pattern ssp,
     scd_story ss,
     clinical_event ce
    PLAN (sp
     WHERE sp.definition=s_definition
      AND sp.active_ind=1)
     JOIN (ssp
     WHERE ssp.scr_pattern_id=sp.scr_pattern_id)
     JOIN (ss
     WHERE ss.scd_story_id=ssp.scd_story_id
      AND ss.active_ind=1
      AND (ss.encounter_id=m_rec->f_encntr_id)
      AND (ss.person_id=m_rec->f_person_id))
     JOIN (ce
     WHERE ce.event_id=ss.event_id
      AND ce.valid_until_dt_tm > sysdate
      AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd))
    ORDER BY ce.event_end_dt_tm DESC
    HEAD REPORT
     mf_event_id = ce.event_id, ms_head_title = sp.display, ms_head_date = trim(format(ce
       .event_end_dt_tm,"dd-mmm-yyyy hh:mm;;d"),3)
    WITH nocounter
   ;end select
   IF (mf_event_id > 0.0)
    CALL sbr_print_blob(mf_event_id,n_pagebreak)
   ENDIF
 END ;Subroutine
 SUBROUTINE (sbr_print_blob(f_event_id=f8,n_pagebreak=i2) =null WITH protect)
   DECLARE ms_note_rtf = vc WITH protect, noconstant(" ")
   DECLARE ml_beg = i4 WITH protect, noconstant(0)
   DECLARE ml_end = i4 WITH protect, noconstant(0)
   DECLARE ml_obrac = i4 WITH protect, noconstant(0)
   SET ms_note_rtf = bhs_sbr_get_blob(f_event_id,0)
   SET ml_beg = 0
   SET ml_end = 0
   SET ml_obrac = 0
   SET ml_beg = findstring("{\deleted\",ms_note_rtf)
   SET x = 0
   WHILE (ml_beg > 0)
     SET ml_obrac_cnt = 0
     SET ml_obrac = findstring("{",ms_note_rtf,(ml_beg+ 1))
     SET ml_end = findstring("}",ms_note_rtf,ml_beg)
     WHILE (ml_obrac < ml_end
      AND ml_obrac > 0)
       SET ml_obrac = findstring("{",ms_note_rtf,(ml_obrac+ 1))
       SET ml_obrac_cnt += 1
       IF (ml_obrac_cnt=1000)
        SET ml_obrac = 0
       ENDIF
     ENDWHILE
     FOR (pl_loop = 1 TO ml_obrac_cnt)
       SET ml_end = findstring("}",ms_note_rtf,(ml_end+ 1))
     ENDFOR
     SET ms_tmp = substring(ml_beg,((ml_end - ml_beg)+ 1),ms_note_rtf)
     CALL echo("******* delete *******")
     CALL echo(ms_tmp)
     CALL echo("******* delete *******")
     SET ms_note_rtf = replace(ms_note_rtf,ms_tmp,"",0)
     SET ml_beg = findstring("{\deleted\",ms_note_rtf,ml_beg)
     SET x += 1
     IF (x=1000)
      SET ml_beg = 0
     ENDIF
   ENDWHILE
   SET ms_blob_rtf = trim(ms_note_rtf,3)
   IF (textlen(trim(ms_blob_rtf,3)) > 0)
    IF (n_pagebreak=1)
     CALL echo(concat("pagebreak note: ",ms_head_title))
     CALL sbr_break_page(0)
    ENDIF
    SET d0 = sec_head(rpt_render)
    SET becont = 0
    SET d0 = sec_note_rtf(rpt_render,9.5,becont)
    WHILE (becont=1)
     CALL sbr_break_page(0)
     SET d0 = sec_note_rtf(rpt_render,9.5,becont)
    ENDWHILE
   ENDIF
 END ;Subroutine
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
