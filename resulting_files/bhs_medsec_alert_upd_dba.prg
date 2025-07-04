CREATE PROGRAM bhs_medsec_alert_upd:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Alert type:" = 2,
  "Select Patient:" = 0,
  "***INACTIVATE CARE PLAN***:" = 0,
  "Effective Date of Alert:" = "SYSDATE",
  "Due for Review:" = "SYSDATE",
  "Reason for Alert:" = "",
  "Enter Reason text:" = "",
  "Clinical Contact:" = "",
  "Enter Clinical Contact text:" = "",
  "Select Physician:" = "",
  "Select PCP:" = "",
  "Interventions:" = "",
  "Location of Incident:" = "",
  "Enter Location text:" = ""
  WITH outdev, l_pat_type_ind, f_behav_id,
  n_inactivate, s_alert_effective_dt_tm, s_review_due_dt_tm,
  s_alert_reason, s_alert_reason_ft, s_clin_contact,
  s_clin_contact_ft, s_phys_name, s_pcp_name,
  s_interventions, s_location, s_location_ft
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_head(ncalc=i2) = f8 WITH protect
 DECLARE sec_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_intro(ncalc=i2) = f8 WITH protect
 DECLARE sec_introabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_inactivate(ncalc=i2) = f8 WITH protect
 DECLARE sec_inactivateabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sec_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
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
 DECLARE _rems_detail = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsec_detail = i2 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
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
   DECLARE sectionheight = f8 WITH noconstant(0.570000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.505),(offsetx+ 7.500),(offsety+
     0.505))
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_pat_name,char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_mrn,char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.125)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_alrt_title,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_intro(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_introabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_introabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 5.625
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("The Alert is as follows:",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.875)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_alrt_title,char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("This patient has a",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.188)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(" currently in place.",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_inactivate(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_inactivateabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_inactivateabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "The following Alert has been inactivated.",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_s_detail = f8 WITH noconstant(0.0), private
   DECLARE __s_detail = vc WITH noconstant(build2(ms_detail,char(0))), protect
   IF (bcontinue=0)
    SET _rems_detail = 1
   ENDIF
   SET rptsd->m_flags = 37
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
   SET rptsd->m_x = (offsetx+ 3.063)
   SET rptsd->m_width = 4.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrems_detail = _rems_detail
   IF (_rems_detail > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rems_detail,((size(
        __s_detail) - _rems_detail)+ 1),__s_detail)))
    SET drawheight_s_detail = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rems_detail = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rems_detail,((size(__s_detail) -
       _rems_detail)+ 1),__s_detail)))))
     SET _rems_detail = (_rems_detail+ rptsd->m_drawlength)
    ELSE
     SET _rems_detail = 0
    ENDIF
    SET growsum = (growsum+ _rems_detail)
   ENDIF
   SET rptsd->m_flags = 32
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_label,char(0)))
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.063)
   SET rptsd->m_width = 4.438
   SET rptsd->m_height = drawheight_s_detail
   IF (ncalc=rpt_render
    AND _holdrems_detail > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrems_detail,((size(
        __s_detail) - _holdrems_detail)+ 1),__s_detail)))
   ELSE
    SET _rems_detail = _holdrems_detail
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "bhs_medsec_alert_upd"
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
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 f_person_id = f8
   1 s_location = vc
   1 s_beg_dt_tm = vc
   1 s_clin_contact = vc
   1 s_end_dt_tm = vc
   1 s_intervention = vc
   1 s_reason = vc
   1 s_review_dt_tm = vc
 ) WITH protect
 DECLARE mn_reason_param = i2 WITH protect, constant(7)
 DECLARE mn_clin_param = i2 WITH protect, constant(9)
 DECLARE mn_location_param = i2 WITH protect, constant(14)
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ml_pat_type = i4 WITH protect, constant( $L_PAT_TYPE_IND)
 DECLARE ms_mrn = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_pat_name = vc WITH protect, noconstant(" ")
 DECLARE ms_phys_name = vc WITH protect, noconstant(" ")
 DECLARE ms_pcp_name = vc WITH protect, noconstant(" ")
 DECLARE mn_update = i2 WITH protect, noconstant(0)
 DECLARE ms_alrt_title = vc WITH protect, noconstant(" ")
 DECLARE sbr_printline(ps_label=vc,ps_detail=vc) = null
 IF (ml_pat_type=2)
  SET ms_alrt_title = "Security Alert"
 ELSEIF (ml_pat_type=3)
  SET ms_alrt_title = "Medical Alert"
 ENDIF
 IF (( $N_INACTIVATE=0))
  SET m_rec->s_beg_dt_tm = trim( $S_ALERT_EFFECTIVE_DT_TM)
  SET m_rec->s_review_dt_tm = trim(replace( $S_REVIEW_DUE_DT_TM,char(160)," ",0))
  SET m_rec->s_end_dt_tm = "31-DEC-2100 00:00"
  SET ms_data_type = build(reflect(parameter(mn_reason_param,0)))
  IF (substring(1,1,ms_data_type)="C")
   IF (findstring("OTHER", $S_ALERT_REASON)=0)
    SET m_rec->s_reason = trim(replace( $S_ALERT_REASON,char(160)," ",0))
   ENDIF
  ELSEIF (substring(1,1,ms_data_type)="L")
   FOR (ml_cnt = 1 TO cnvtint(substring(2,(textlen(ms_data_type) - 1),ms_data_type)))
     SET ms_tmp = parameter(mn_reason_param,ml_cnt)
     SET ms_tmp = trim(ms_tmp)
     IF (findstring("OTHER",ms_tmp)=0)
      IF (trim(m_rec->s_reason) <= " ")
       SET m_rec->s_reason = trim(ms_tmp)
      ELSE
       SET m_rec->s_reason = concat(m_rec->s_reason,"|",trim(ms_tmp))
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
  IF (trim(replace( $S_ALERT_REASON_FT,char(160)," ",0)) > " ")
   IF (trim(m_rec->s_reason) > " ")
    SET m_rec->s_reason = concat(m_rec->s_reason,"|OTHER-",trim(replace(replace( $S_ALERT_REASON_FT,
        ":","-",0),char(160)," ",0)))
   ELSE
    SET m_rec->s_reason = concat(m_rec->s_reason,"OTHER-",trim(replace(replace( $S_ALERT_REASON_FT,
        ":","-",0),char(160)," ",0)))
   ENDIF
  ENDIF
  SET m_rec->s_intervention = trim(replace(replace( $S_INTERVENTIONS,":","-",0),char(160)," ",0))
  SET ms_phys_name = trim( $S_PHYS_NAME)
  SET ms_pcp_name = trim( $S_PCP_NAME)
  SET ms_data_type = build(reflect(parameter(mn_clin_param,0)))
  IF (substring(1,1,ms_data_type)="C")
   IF (findstring( $S_CLIN_CONTACT,"OTHER")=0)
    SET m_rec->s_clin_contact = trim( $S_CLIN_CONTACT)
    IF (trim(ms_phys_name) > " ")
     SET m_rec->s_clin_contact = concat(m_rec->s_clin_contact,"-",ms_phys_name)
    ELSEIF (trim(ms_pcp_name) > " ")
     SET m_rec->s_clin_contact = concat(m_rec->s_clin_contact,"-",ms_pcp_name)
    ENDIF
   ENDIF
  ELSEIF (substring(1,1,ms_data_type)="L")
   FOR (ml_cnt = 1 TO cnvtint(substring(2,(textlen(ms_data_type) - 1),ms_data_type)))
     SET ms_tmp = parameter(mn_clin_param,ml_cnt)
     SET ms_tmp = trim(ms_tmp)
     IF (findstring("OTHER",cnvtupper(ms_tmp))=0)
      IF (findstring("PHYSICIAN",cnvtupper(ms_tmp))
       AND trim( $S_PHYS_NAME) > " ")
       SET ms_tmp = concat(ms_tmp,"-",ms_phys_name)
      ELSEIF (findstring("PCP",cnvtupper(ms_tmp))
       AND trim( $S_PCP_NAME) > " ")
       SET ms_tmp = concat(ms_tmp,"-",ms_pcp_name)
      ENDIF
      IF (trim(m_rec->s_clin_contact) <= " ")
       SET m_rec->s_clin_contact = trim(ms_tmp)
      ELSE
       SET m_rec->s_clin_contact = concat(m_rec->s_clin_contact,"|",trim(ms_tmp))
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
  IF (trim(replace( $S_CLIN_CONTACT_FT,char(160)," ",0)) > " ")
   IF (trim(m_rec->s_clin_contact) > " ")
    SET m_rec->s_clin_contact = concat(m_rec->s_clin_contact,"|OTHER-",trim(replace(replace(
         $S_CLIN_CONTACT_FT,":","-",0),char(160)," ",0)))
   ELSE
    SET m_rec->s_clin_contact = concat(m_rec->s_clin_contact,"OTHER-",trim(replace(replace(
         $S_CLIN_CONTACT_FT,":","-",0),char(160)," ",0)))
   ENDIF
  ENDIF
  SET ms_data_type = build(reflect(parameter(mn_location_param,0)))
  IF (substring(1,1,ms_data_type)="C")
   IF (findstring("OTHER", $S_LOCATION)=0)
    SET m_rec->s_location = trim(replace( $S_LOCATION,char(160)," ",0))
   ENDIF
  ELSEIF (substring(1,1,ms_data_type)="L")
   FOR (ml_cnt = 1 TO cnvtint(substring(2,(textlen(ms_data_type) - 1),ms_data_type)))
     SET ms_tmp = parameter(mn_location_param,ml_cnt)
     SET ms_tmp = trim(ms_tmp)
     IF (findstring("OTHER",ms_tmp)=0)
      IF (trim(m_rec->s_location) <= " ")
       SET m_rec->s_location = trim(ms_tmp)
      ELSE
       SET m_rec->s_location = concat(m_rec->s_location,"|",trim(ms_tmp))
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
  IF (trim(replace( $S_LOCATION_FT,char(160)," ",0)) > " ")
   IF (trim(m_rec->s_location) > " ")
    SET m_rec->s_location = concat(m_rec->s_location,"|OTHER-",trim(replace(replace( $S_LOCATION_FT,
        ":","-",0),char(160)," ",0)))
   ELSE
    SET m_rec->s_location = concat(m_rec->s_location,"OTHER-",trim(replace(replace( $S_LOCATION_FT,
        ":","-",0),char(160)," ",0)))
   ENDIF
  ENDIF
 ELSE
  CALL echo("inactivating record")
  SET mn_update = 1
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_pat_behav_ident b
  PLAN (b
   WHERE (b.bhs_pat_behav_ident_id= $F_BEHAV_ID)
    AND b.pat_type_flag=ml_pat_type)
  HEAD REPORT
   IF (((cnvtdatetime(m_rec->s_beg_dt_tm) != b.beg_effective_dt_tm) OR (((cnvtdatetime(m_rec->
    s_review_dt_tm) != b.review_dt_tm) OR (((trim(m_rec->s_reason) != trim(b.reason)) OR (((trim(
    m_rec->s_clin_contact) != trim(b.clinical_contact)) OR (((trim(m_rec->s_location) != trim(b
    .location)) OR (trim(m_rec->s_intervention) != trim(b.intervention))) )) )) )) )) )
    CALL echo("changes exist"), mn_update = 1, m_rec->f_person_id = b.person_id
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_update=1)
  UPDATE  FROM bhs_pat_behav_ident b
   SET b.active_ind = 0, b.end_effective_dt_tm = sysdate, b.updt_cnt = (b.updt_cnt+ 1),
    b.updt_dt_tm = sysdate, b.updt_person_id = reqinfo->updt_id
   PLAN (b
    WHERE (b.bhs_pat_behav_ident_id= $F_BEHAV_ID)
     AND b.pat_type_flag=ml_pat_type)
   WITH nocounter
  ;end update
  COMMIT
  IF (( $N_INACTIVATE=0))
   CALL echo("insert")
   INSERT  FROM bhs_pat_behav_ident b
    SET b.active_ind = 1, b.location = trim(m_rec->s_location), b.beg_effective_dt_tm = cnvtdatetime(
      m_rec->s_beg_dt_tm),
     b.bhs_pat_behav_ident_id = seq(bhs_eks_seq,nextval), b.clinical_contact = trim(m_rec->
      s_clin_contact), b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     b.intervention = m_rec->s_intervention, b.person_id = m_rec->f_person_id, b.reason = trim(m_rec
      ->s_reason),
     b.review_dt_tm = cnvtdatetime(m_rec->s_review_dt_tm), b.updt_cnt = 0, b.updt_dt_tm = sysdate,
     b.updt_person_id = reqinfo->updt_id, b.pat_type_flag = ml_pat_type
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
 ELSE
  SELECT INTO value( $OUTDEV)
   HEAD REPORT
    col 0, "No Updates made"
   WITH nocounter
  ;end select
  SET ms_log = "SUCCESS"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   encntr_alias ea
  PLAN (p
   WHERE (p.person_id=m_rec->f_person_id)
    AND p.active_ind=1)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
  ORDER BY e.encntr_id, ea.end_effective_dt_tm
  DETAIL
   ms_pat_name = trim(p.name_full_formatted), ms_mrn = trim(ea.alias)
  WITH nocounter
 ;end select
 SET d0 = sec_head(rpt_render)
 IF (( $N_INACTIVATE=0))
  SET d0 = sec_intro(rpt_render)
 ELSE
  SET d0 = sec_inactivate(rpt_render)
 ENDIF
 CALL sbr_printline("Effective Date of Alert-",m_rec->s_beg_dt_tm)
 CALL sbr_printline("Due for Review-",m_rec->s_review_dt_tm)
 SET ml_pos = 0
 SET ml_start = 1
 IF (findstring("|",m_rec->s_reason))
  CALL sbr_printline("Reason for Alert-","")
  WHILE (findstring("|",m_rec->s_reason,ml_start) > 0)
    SET ml_pos = findstring("|",m_rec->s_reason,ml_start)
    SET ms_tmp = substring(ml_start,(ml_pos - ml_start),m_rec->s_reason)
    SET ml_start = (ml_pos+ 1)
    CALL sbr_printline("",ms_tmp)
  ENDWHILE
  SET ms_tmp = substring(ml_start,((textlen(m_rec->s_reason) - ml_start)+ 1),m_rec->s_reason)
  CALL sbr_printline("",ms_tmp)
 ELSE
  CALL sbr_printline("",m_rec->s_reason)
 ENDIF
 SET ml_pos = 0
 SET ml_start = 1
 IF (findstring("|",m_rec->s_clin_contact))
  CALL sbr_printline("Clinical contact-","")
  WHILE (findstring("|",m_rec->s_clin_contact,ml_start) > 0)
    SET ml_pos = findstring("|",m_rec->s_clin_contact,ml_start)
    SET ms_tmp = substring(ml_start,(ml_pos - ml_start),m_rec->s_clin_contact)
    SET ml_start = (ml_pos+ 1)
    CALL sbr_printline("",ms_tmp)
  ENDWHILE
  SET ms_tmp = substring(ml_start,((textlen(m_rec->s_clin_contact) - ml_start)+ 1),m_rec->
   s_clin_contact)
  CALL sbr_printline("",ms_tmp)
 ELSE
  CALL sbr_printline("",m_rec->s_clin_contact)
 ENDIF
 CALL sbr_printline("Interventions- ","")
 CALL sbr_printline("",m_rec->s_intervention)
 SET ml_pos = 0
 SET ml_start = 1
 IF (findstring("|",m_rec->s_location))
  CALL sbr_printline("Location-","")
  WHILE (findstring("|",m_rec->s_location,ml_start) > 0)
    SET ml_pos = findstring("|",m_rec->s_location,ml_start)
    SET ms_tmp = substring(ml_start,(ml_pos - ml_start),m_rec->s_location)
    SET ml_start = (ml_pos+ 1)
    CALL sbr_printline("",ms_tmp)
  ENDWHILE
  SET ms_tmp = substring(ml_start,((textlen(m_rec->s_location) - ml_start)+ 1),m_rec->s_location)
  CALL sbr_printline("",ms_tmp)
 ELSE
  CALL sbr_printline("",m_rec->s_location)
 ENDIF
 SET d0 = finalizereport(value( $OUTDEV))
 SET ms_log = "SUCCESS"
 SUBROUTINE sbr_printline(ps_label,ps_detail)
   DECLARE ps_cont = i2 WITH noconstant(0)
   SET ms_label = ps_label
   SET ms_detail = ps_detail
   SET d0 = sec_detail(rpt_render,8.5,ps_cont)
 END ;Subroutine
#exit_script
 CALL echo(ms_log)
 IF (ms_log != "SUCCESS")
  SELECT INTO value( $OUTDEV)
   DETAIL
    col 0, row + 1, ms_log
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
