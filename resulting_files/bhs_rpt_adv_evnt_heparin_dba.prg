CREATE PROGRAM bhs_rpt_adv_evnt_heparin:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Select Facility" = 0
  WITH outdev, s_beg_dt, s_end_dt,
  f_fname
 FREE RECORD m_rec
 RECORD m_rec(
   1 hep[*]
     2 f_code_value = f8
     2 f_disp_key = vc
     2 f_mnem_key = vc
   1 nurs[*]
     2 f_nurse_unit_cd = f8
     2 s_disp = vc
   1 pat[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 n_orders = i2
     2 n_incl = i2
     2 dx[*]
       3 f_dx_id = f8
       3 s_source_str = vc
     2 ord[*]
       3 f_order_id = f8
       3 s_mnemonic = vc
       3 s_start_dt_tm = vc
       3 s_stop_dt_tm = vc
       3 s_route = vc
       3 s_freq = vc
       3 f_catalog_cd = f8
 ) WITH protect
 FREE RECORD d_rec
 RECORD d_rec(
   1 ml_cnt = i4
   1 med[*]
     2 mf_code_value = f8
     2 ms_disp_key = vc
     2 ms_mnem_key = vc
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat( $S_BEG_DT," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat( $S_END_DT," 23:59:59"))
 DECLARE mf_facility = f8 WITH protect, constant( $F_FNAME)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_route_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE mf_freq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_inr = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"INR"))
 DECLARE mf_altered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_person_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc2 = i4 WITH protect, noconstant(0)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_head(ncalc=i2) = f8 WITH protect
 DECLARE sec_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_line(ncalc=i2) = f8 WITH protect
 DECLARE sec_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_dashline(ncalc=i2) = f8 WITH protect
 DECLARE sec_dashlineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_name(ncalc=i2) = f8 WITH protect
 DECLARE sec_nameabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_dx_head(ncalc=i2) = f8 WITH protect
 DECLARE sec_dx_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_dx_det(ncalc=i2) = f8 WITH protect
 DECLARE sec_dx_detabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_drug_head(ncalc=i2) = f8 WITH protect
 DECLARE sec_drug_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_drug_title(ncalc=i2) = f8 WITH protect
 DECLARE sec_drug_titleabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_drug_det(ncalc=i2) = f8 WITH protect
 DECLARE sec_drug_detabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_foot(ncalc=i2) = f8 WITH protect
 DECLARE sec_footabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _pen14s1c0 = i4 WITH noconstant(0), protect
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
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
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
 SUBROUTINE sec_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Adverse Event Heparin Order Overlap Report",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_line(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_lineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.070000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.041),(offsetx+ 7.500),(offsety+
     0.041))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_dashline(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_dashlineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_dashlineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.070000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s1c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),(offsety+ 0.041),(offsetx+ 7.500),(offsety+
     0.041))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_name(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_nameabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_nameabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __pat_name = vc WITH noconstant(build2(m_rec->pat[ml_cnt].s_pat_name,char(0))), protect
   DECLARE __acct = vc WITH noconstant(build2(m_rec->pat[ml_cnt].s_fin,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(m_rec->pat[ml_cnt].s_mrn,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_name)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.188)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acct)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_dx_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_dx_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_dx_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DX:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_dx_det(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_dx_detabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_dx_detabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __diag = vc WITH noconstant(build2(m_rec->pat[ml_cnt].dx[ml_cnt2].s_source_str,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__diag)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_drug_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_drug_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_drug_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Drug Overlap:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_drug_title(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_drug_titleabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_drug_titleabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Mnemonic:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Start Dt Tm:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Stop Dt Tm:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_drug_det(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_drug_detabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_drug_detabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE __mnemonic1 = vc WITH noconstant(build2(m_rec->pat[ml_cnt].ord[ml_cnt2].s_mnemonic,char(0)
     )), protect
   DECLARE __end_dt1 = vc WITH noconstant(build2(m_rec->pat[ml_cnt].ord[ml_cnt2].s_stop_dt_tm,char(0)
     )), protect
   DECLARE __beg_dt1 = vc WITH noconstant(build2(m_rec->pat[ml_cnt].ord[ml_cnt2].s_start_dt_tm,char(0
      ))), protect
   DECLARE __mnemonic2 = vc WITH noconstant(build2(m_rec->pat[ml_cnt].ord[ml_cnt3].s_mnemonic,char(0)
     )), protect
   DECLARE __end_dt2 = vc WITH noconstant(build2(m_rec->pat[ml_cnt].ord[ml_cnt3].s_stop_dt_tm,char(0)
     )), protect
   DECLARE __beg_dt2 = vc WITH noconstant(build2(m_rec->pat[ml_cnt].ord[ml_cnt3].s_start_dt_tm,char(0
      ))), protect
   DECLARE __route_freq_1 = vc WITH noconstant(build2(concat(m_rec->pat[ml_cnt].ord[ml_cnt2].s_route,
      " ",m_rec->pat[ml_cnt].ord[ml_cnt2].s_freq),char(0))), protect
   DECLARE __route_freq_2 = vc WITH noconstant(build2(concat(m_rec->pat[ml_cnt].ord[ml_cnt3].s_route,
      " ",m_rec->pat[ml_cnt].ord[ml_cnt3].s_freq),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mnemonic1)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__end_dt1)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__beg_dt1)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mnemonic2)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__end_dt2)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__beg_dt2)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 5.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__route_freq_1)
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 5.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__route_freq_2)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_foot(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_footabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.979
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_ADV_EVNT_HEPARIN"
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
   SET rptfont->m_pointsize = 14
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 1
   SET _pen14s1c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 CALL echo(build2("beg: ",ms_beg_dt_tm))
 CALL echo(build2("end: ",ms_end_dt_tm))
 CALL echo(build2("facility: ",mf_facility))
 CALL echo(build2("inpt cd: ",mf_inpt_cd))
 SELECT INTO "nl:"
  lg2.child_loc_cd, ps_disp = uar_get_code_display(lg2.child_loc_cd)
  FROM location_group lg1,
   location_group lg2,
   code_value cv
  PLAN (lg1
   WHERE lg1.parent_loc_cd=mf_facility
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND cv.cdf_meaning="NURSEUNIT"
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  ORDER BY ps_disp
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->nurs,pl_cnt), m_rec->nurs[pl_cnt].f_nurse_unit_cd =
   cv.code_value,
   m_rec->nurs[pl_cnt].s_disp = trim(cv.display)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   code_value cv
  PLAN (ocs
   WHERE ocs.mnemonic_key_cap IN ("HEPARIN", "HEPARIN 25,000 UNITS IN 250 ML D5W",
   "HEPARIN 25,000 UNITS IN NACL 0.9% 250 ML", "HEPARIN 25,000 UNITS/250 ML D5%W",
   "HEPARIN 25,000 UNITS/250 ML D5W",
   "HEPARIN 25000 UNITS IN NACL 0.9% 250ML (PEDI STANDARD DOSE",
   "HEPARIN 25000 UNITS IN NACL 0.9% 250ML (PEDI STANDARD DOSING",
   "HEPARIN 5000 U/ML INJECTABLE SOLUTION", "HEPARIN 1,000 UNITS IN NACL 0.9% 500 ML",
   "HEPARIN 10,000 UNITS IN 500ML NACL",
   "HEPARIN 10,000 UNITS IN NACL 0.9% 500 ML", "HEPARIN 250 UNITS IN NACL 0.9% 250 ML",
   "HEPARIN 4000 UNITS IN 0.9 NACL 1000 ML", "HEPARIN 500 UNITS IN NACL 0.9% 500 ML",
   "HEPARIN 5000 UNITS IN D5%W 50 ML",
   "ENOXAPARIN", "ENOXAPARIN 100 MG/ML SUBCUTANEOUS SOLUTION",
   "ENOXAPARIN 120 MG/0.8 ML SUBCUTANEOUS SOLUTION", "ENOXAPARIN 150 MG/ML SUBCUTANEOUS SOLUTION",
   "ENOXAPARIN 20MG/ML INJ (PEDI)",
   "ENOXAPARIN 30 MG/0.3 ML SUBCUTANEOUS SOLUTION", "ENOXAPARIN 40 MG/0.4 ML SUBCUTANEOUS SOLUTION",
   "ENOXAPARIN 60 MG/0.6 ML SUBCUTANEOUS SOLUTION", "ENOXAPARIN 80 MG/0.8 ML SUBCUTANEOUS SOLUTION",
   "DABIGATRAN",
   "DABIGATRAN 150 MG ORAL CAPSULE", "DABIGATRAN 75 MG ORAL CAPSULE", "RIVAROXABAN",
   "RIVAROXABAN 10 MG ORAL TABLET", "RIVAROXABAN 15 MG ORAL TABLET",
   "RIVAROXABAN 20 MG ORAL TABLET", "ACTIVASE 100 MG INTRAVENOUS INJECTION",
   "ACTIVASE 50 MG INTRAVENOUS INJECTION", "ACTIVASE CONT IV", "ALTEPLASE",
   "ALTEPLASE 1 MG/ML SYRINGE INJECTION", "ALTEPLASE 10 MG IN NACL 0.9% 1000 ML",
   "ALTEPLASE 10 MG IN NACL 0.9% 500 ML", "ALTEPLASE 100 MG INTRAVENOUS INJECTION",
   "ALTEPLASE 100MG IN 100ML NACL",
   "ALTEPLASE 50 MG INTRAVENOUS INJECTION", "ALTEPLASE BOLUS INJ", "ALTEPLASE CONT IV",
   "ALTEPLASE IVPB", "T-PA (ALTEPLASE) __ MG IN NACL 0.9% __ ML",
   "WARFARIN")
    AND ocs.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=ocs.catalog_cd
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  HEAD REPORT
   pl_cnt = 0, d_rec->ml_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->hep,pl_cnt), m_rec->hep[pl_cnt].f_code_value = ocs
   .catalog_cd,
   m_rec->hep[pl_cnt].f_disp_key = trim(cv.display_key), m_rec->hep[pl_cnt].f_mnem_key = trim(ocs
    .mnemonic_key_cap)
   IF (ocs.mnemonic_key_cap IN ("WARFARIN"))
    d_rec->ml_cnt = (d_rec->ml_cnt+ 1), sta = alterlist(d_rec->med,d_rec->ml_cnt), d_rec->med[d_rec->
    ml_cnt].mf_code_value = ocs.catalog_cd,
    d_rec->med[d_rec->ml_cnt].ms_disp_key = trim(cv.display_key), d_rec->med[d_rec->ml_cnt].
    ms_mnem_key = trim(ocs.mnemonic_key_cap)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea1,
   encntr_alias ea2,
   encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (ed
   WHERE ((ed.loc_facility_cd+ 0)=mf_facility)
    AND expand(ml_cnt,1,size(m_rec->nurs,5),ed.loc_nurse_unit_cd,m_rec->nurs[ml_cnt].f_nurse_unit_cd)
    AND ((ed.active_ind+ 0)=1)
    AND ed.beg_effective_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ed.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd=mf_inpt_cd
    AND e.disch_dt_tm=null
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND ((elh.active_ind+ 0)=1)
    AND ((elh.loc_nurse_unit_cd+ 0)=ed.loc_nurse_unit_cd)
    AND elh.beg_effective_dt_tm <= cnvtdatetime(ms_end_dt_tm))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_fin_cd))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
  ORDER BY ed.loc_nurse_unit_cd, p.name_last_key
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->pat,5))
    stat = alterlist(m_rec->pat,(pl_cnt+ 10))
   ENDIF
   m_rec->pat[pl_cnt].f_person_id = p.person_id, m_rec->pat[pl_cnt].s_pat_name = trim(p
    .name_full_formatted), m_rec->pat[pl_cnt].f_encntr_id = e.encntr_id,
   m_rec->pat[pl_cnt].s_fin = trim(ea1.alias), m_rec->pat[pl_cnt].s_mrn = trim(ea2.alias)
  FOOT REPORT
   stat = alterlist(m_rec->pat,pl_cnt)
  WITH nocounter, orahintcbo("LEADING(ED,E,P,EA1,EA2,ELH)","INDEX(ED XIE1ENCNTR_DOMAIN)",
    "INDEX(E XPKENCOUNTER)","INDEX(P XPKPERSON)","INDEX(EA1 XIE2ENCNTR_ALIAS)",
    "INDEX(EA2 XIE2ENCNTR_ALIAS)","INDEX(ELH XIE1ENCNTR_LOC_HIST)","USE_NL(E)","USE_NL(P)",
    "USE_NL(EA1)",
    "USE_NL(EA2)","USE_NL(ELH)")
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  o.encntr_id, o.current_start_dt_tm
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   orders o,
   order_detail od1,
   order_detail od2
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=m_rec->pat[d.seq].f_person_id)
    AND expand(ml_cnt,1,size(m_rec->hep,5),o.catalog_cd,m_rec->hep[ml_cnt].f_code_value)
    AND (o.encntr_id=m_rec->pat[d.seq].f_encntr_id)
    AND ((o.active_ind+ 0)=1)
    AND ((o.template_order_id+ 0)=0)
    AND o.orig_ord_as_flag=0
    AND o.current_start_dt_tm <= cnvtdatetime(ms_end_dt_tm)
    AND cnvtdatetime(ms_beg_dt_tm) < o.projected_stop_dt_tm
    AND ((o.order_status_cd - 0)=mf_ordered_cd))
   JOIN (od1
   WHERE od1.order_id=o.order_id
    AND od1.oe_field_id=mf_route_cd)
   JOIN (od2
   WHERE od2.order_id=outerjoin(o.order_id)
    AND od2.oe_field_id=outerjoin(mf_freq_cd))
  ORDER BY o.encntr_id, o.current_start_dt_tm
  HEAD REPORT
   pl_cnt = 0
  HEAD o.encntr_id
   pl_cnt = 0
  HEAD o.order_id
   IF ( NOT (cnvtupper(concat(trim(od1.oe_field_display_value)," ",trim(od2.oe_field_display_value)))
   ="IV PUSH EVERY 6 HOURS"
    AND cnvtupper(o.order_mnemonic)="*HEPARIN*"))
    IF ( NOT (cnvtupper(trim(od1.oe_field_display_value))="IV CATHETER CLEARANCE"
     AND cnvtupper(o.order_mnemonic)="*ALTEPLASE*"))
     m_rec->pat[d.seq].n_orders = 1, pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pat[d.seq].ord,
      pl_cnt),
     m_rec->pat[d.seq].ord[pl_cnt].f_order_id = o.order_id, m_rec->pat[d.seq].ord[pl_cnt].
     s_start_dt_tm = trim(format(o.current_start_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_rec->pat[d.seq].
     ord[pl_cnt].s_stop_dt_tm = trim(format(o.projected_stop_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
     m_rec->pat[d.seq].ord[pl_cnt].s_mnemonic = trim(o.order_mnemonic), m_rec->pat[d.seq].ord[pl_cnt]
     .s_route = trim(od1.oe_field_display_value), m_rec->pat[d.seq].ord[pl_cnt].s_freq = trim(od2
      .oe_field_display_value),
     m_rec->pat[d.seq].ord[pl_cnt].f_catalog_cd = o.catalog_cd
    ENDIF
   ENDIF
  WITH nocounter, orahintcbo("LEADING(O,OD1,OD2)","INDEX(O XIE7ORDERS)","USE_NL(OD1)","USE_NL(OD2)"),
   orahint("LEADING(O,OD1,OD2)","INDEX(O XIE7ORDERS)","USE_NL(OD1)","USE_NL(OD2)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=m_rec->pat[d.seq].f_person_id)
    AND ((ce.encntr_id+ 0)=m_rec->pat[d.seq].f_encntr_id)
    AND ce.event_cd=mf_inr
    AND ce.result_status_cd IN (mf_altered, mf_modified, mf_auth)
    AND ce.publish_flag=1
    AND ce.view_level=1
    AND ce.performed_dt_tm > cnvtdatetime(ms_beg_dt_tm)
    AND ce.performed_dt_tm < cnvtdatetime(ms_end_dt_tm))
  ORDER BY ce.person_id, ce.performed_dt_tm DESC
  HEAD ce.person_id
   ml_person_pos = locateval(ml_idx1,1,size(m_rec->pat,5),ce.person_id,m_rec->pat[ml_idx1].
    f_person_id), pl_cnt = 0
   IF (isnumeric(ce.result_val) > 0)
    IF (cnvtreal(ce.result_val) >= 2.5)
     pl_cnt = size(m_rec->pat[ml_person_pos].ord,5), pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->
      pat[ml_person_pos].ord,pl_cnt),
     m_rec->pat[ml_person_pos].n_orders = 1, m_rec->pat[ml_person_pos].ord[pl_cnt].f_order_id = ce
     .order_id, m_rec->pat[ml_person_pos].ord[pl_cnt].s_start_dt_tm = trim(format(ce.performed_dt_tm,
       "dd-mmm-yyyy hh:mm;;d")),
     m_rec->pat[ml_person_pos].ord[pl_cnt].s_stop_dt_tm = trim(format(ce.valid_until_dt_tm,
       "dd-mmm-yyyy hh:mm;;d")), m_rec->pat[ml_person_pos].ord[pl_cnt].s_mnemonic = "INR", m_rec->
     pat[ml_person_pos].ord[pl_cnt].s_route = ce.result_val
    ENDIF
   ENDIF
  WITH nocounter, orahintcbo("INDEX(CE XIE24CLINICAL_EVENT)")
 ;end select
 SELECT DISTINCT INTO "nl:"
  dx.encntr_id, n.source_string
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   diagnosis dx,
   nomenclature n
  PLAN (d
   WHERE (m_rec->pat[d.seq].n_orders=1))
   JOIN (dx
   WHERE (dx.encntr_id=m_rec->pat[d.seq].f_encntr_id)
    AND dx.active_ind=1
    AND dx.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.nomenclature_id=dx.nomenclature_id
    AND n.active_ind=1)
  HEAD REPORT
   pl_cnt = 0
  HEAD dx.encntr_id
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pat[d.seq].dx,pl_cnt), m_rec->pat[d.seq].dx[pl_cnt].
   f_dx_id = dx.diagnosis_id,
   m_rec->pat[d.seq].dx[pl_cnt].s_source_str = trim(n.source_string)
  WITH nocounter
 ;end select
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt3 = i4 WITH protect, noconstant(0)
 DECLARE ms_start = vc WITH protect, noconstant(" ")
 DECLARE ms_stop = vc WITH protect, noconstant(" ")
 DECLARE ms_mnem = vc WITH protect, noconstant(" ")
 DECLARE ml_done = i2 WITH protect, noconstant(0)
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 SET d0 = sec_head(rpt_render)
 SET d0 = sec_line(rpt_render)
 FOR (ml_cnt = 1 TO size(m_rec->pat,5))
   IF ((m_rec->pat[ml_cnt].n_orders=1))
    FOR (ml_cnt2 = 1 TO size(m_rec->pat[ml_cnt].ord,5))
      SET ml_loc1 = 0
      SET ml_loc2 = 0
      SET ms_start = m_rec->pat[ml_cnt].ord[ml_cnt2].s_start_dt_tm
      SET ms_stop = m_rec->pat[ml_cnt].ord[ml_cnt2].s_stop_dt_tm
      SET ms_mnem = m_rec->pat[ml_cnt].ord[ml_cnt2].s_mnemonic
      SET ml_loc1 = locateval(ml_loc2,1,d_rec->ml_cnt,m_rec->pat[ml_cnt].ord[ml_cnt2].f_catalog_cd,
       d_rec->med[ml_loc2].mf_code_value)
      CALL echo(build2("mlcnt2: ",ml_cnt2," size:",size(m_rec->pat[ml_cnt].ord,5)))
      IF (ml_cnt2 < size(m_rec->pat[ml_cnt].ord,5))
       FOR (ml_cnt3 = (ml_cnt2+ 1) TO size(m_rec->pat[ml_cnt].ord,5))
         IF (ml_loc1 > 0)
          IF ((m_rec->pat[ml_cnt].ord[ml_cnt2].f_catalog_cd=m_rec->pat[ml_cnt].ord[ml_cnt3].
          f_catalog_cd))
           CALL echo("duplicate found, include")
           SET m_rec->pat[ml_cnt].n_incl = 1
          ENDIF
         ELSE
          IF (cnvtdatetime(m_rec->pat[ml_cnt].ord[ml_cnt3].s_start_dt_tm) <= cnvtdatetime(ms_stop)
           AND cnvtdatetime(m_rec->pat[ml_cnt].ord[ml_cnt3].s_stop_dt_tm) >= cnvtdatetime(ms_start))
           IF (locateval(ml_loc2,1,d_rec->ml_cnt,m_rec->pat[ml_cnt].ord[ml_cnt3].f_catalog_cd,d_rec->
            med[ml_loc2].mf_code_value)=0)
            CALL echo("overlap found, include")
            SET m_rec->pat[ml_cnt].n_incl = 1
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
    IF ((m_rec->pat[ml_cnt].n_incl=1))
     SET mf_rem_space = (mf_page_size - (_yoffset+ 1.0))
     IF (mf_rem_space <= 0.25)
      SET d0 = pagebreak(0)
     ENDIF
     SET d0 = sec_name(rpt_render)
     IF (size(m_rec->pat[ml_cnt].dx,5) > 0)
      SET d0 = sec_dx_head(rpt_render)
      FOR (ml_cnt2 = 1 TO size(m_rec->pat[ml_cnt].dx,5))
        SET mf_rem_space = (mf_page_size - (_yoffset+ sec_dx_det(rpt_calcheight)))
        IF (mf_rem_space <= 0.25)
         SET d0 = pagebreak(0)
         SET d0 = sec_name(rpt_render)
         SET d0 = sec_dx_head(rpt_render)
        ENDIF
        SET d0 = sec_dx_det(rpt_render)
      ENDFOR
     ENDIF
     SET ml_done = 0
     FOR (ml_cnt2 = 1 TO size(m_rec->pat[ml_cnt].ord,5))
       SET ms_start = m_rec->pat[ml_cnt].ord[ml_cnt2].s_start_dt_tm
       SET ms_stop = m_rec->pat[ml_cnt].ord[ml_cnt2].s_stop_dt_tm
       SET ms_mnem = m_rec->pat[ml_cnt].ord[ml_cnt2].s_mnemonic
       SET ml_loc1 = 0
       SET ml_loc1 = locateval(ml_loc2,1,d_rec->ml_cnt,m_rec->pat[ml_cnt].ord[ml_cnt2].f_catalog_cd,
        d_rec->med[ml_loc2].mf_code_value)
       IF (ml_cnt2 < size(m_rec->pat[ml_cnt].ord,5))
        FOR (ml_cnt3 = (ml_cnt2+ 1) TO size(m_rec->pat[ml_cnt].ord,5))
          SET ml_loc2 = 0
          SET ml_loc2 = locateval(ml_loc2,1,d_rec->ml_cnt,m_rec->pat[ml_cnt].ord[ml_cnt3].
           f_catalog_cd,d_rec->med[ml_loc2].mf_code_value)
          IF (((cnvtdatetime(m_rec->pat[ml_cnt].ord[ml_cnt3].s_start_dt_tm) <= cnvtdatetime(ms_stop)
           AND cnvtdatetime(m_rec->pat[ml_cnt].ord[ml_cnt3].s_stop_dt_tm) >= cnvtdatetime(ms_start)
           AND ml_loc1=0
           AND ml_loc2=0) OR (ml_loc1 > 0
           AND ml_loc2 > 0
           AND (m_rec->pat[ml_cnt].ord[ml_cnt2].f_catalog_cd=m_rec->pat[ml_cnt].ord[ml_cnt3].
          f_catalog_cd))) )
           IF (ml_done=0)
            SET mf_rem_space = (mf_page_size - ((((_yoffset+ sec_drug_head(rpt_calcheight))+
            sec_drug_title(rpt_calcheight))+ sec_dashline(rpt_calcheight))+ sec_drug_det(
             rpt_calcheight)))
            IF (mf_rem_space <= 0.25)
             SET _yoffset = 10.18
             SET d0 = sec_foot(rpt_render)
             SET d0 = pagebreak(0)
             SET d0 = sec_name(rpt_render)
            ENDIF
            SET d0 = sec_drug_head(rpt_render)
            SET d0 = sec_drug_title(rpt_render)
            SET d0 = sec_dashline(rpt_render)
            SET ml_done = 1
           ENDIF
           SET mf_rem_space = (mf_page_size - ((((_yoffset+ sec_drug_head(rpt_calcheight))+
           sec_drug_title(rpt_calcheight))+ sec_dashline(rpt_calcheight))+ sec_drug_det(
            rpt_calcheight)))
           IF (mf_rem_space <= 0.25)
            SET _yoffset = 10.18
            SET d0 = sec_foot(rpt_render)
            SET d0 = pagebreak(0)
            SET d0 = sec_name(rpt_render)
            SET d0 = sec_drug_head(rpt_render)
            SET d0 = sec_drug_title(rpt_render)
            SET d0 = sec_dashline(rpt_render)
           ENDIF
           SET d0 = sec_drug_det(rpt_render)
           SET d0 = sec_dashline(rpt_render)
           CALL echo(build("overlap: ",ml_cnt2,":",ml_cnt3))
           CALL echo(build2(ms_start," ",ms_stop," ",ms_mnem))
           CALL echo(build2(m_rec->pat[ml_cnt].ord[ml_cnt3].s_start_dt_tm," ",m_rec->pat[ml_cnt].ord[
             ml_cnt3].s_stop_dt_tm," ",m_rec->pat[ml_cnt].ord[ml_cnt3].s_mnemonic))
           CALL echo(" ")
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
     SET d0 = sec_line(rpt_render)
    ENDIF
   ENDIF
 ENDFOR
 SET _yoffset = 10.18
 SET d0 = sec_foot(rpt_render)
 SET d0 = finalizereport(value( $OUTDEV))
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
