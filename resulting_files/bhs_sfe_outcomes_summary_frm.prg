CREATE PROGRAM bhs_sfe_outcomes_summary_frm
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE layoutsection0(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE layoutsection0abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
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
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontlayoutsection0 = i2 WITH noconstant(0), protect
 DECLARE _remfieldname33 = i2 WITH noconstant(1), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
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
 SUBROUTINE layoutsection0(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = layoutsection0abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE layoutsection0abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(8.480000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remfieldname33 = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.500)
   SET rptsd->m_x = (offsetx+ 0.342)
   SET rptsd->m_width = 2.092
   SET rptsd->m_height = 0.217
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Current Smoking Cessation Status",
      char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.500)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 2.400
   SET rptsd->m_height = 0.208
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->smokingcessationcnt,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.675)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.817
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Smoked in the last 12 months:",char(0
       )))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.675)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->smokedlast12months,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 5.625)
   SET rptsd->m_x = (offsetx+ 0.900)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Agreed to counseling:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 5.625)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patagreetocounseling,char(0))
     )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 2.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.058
   SET rptsd->m_height = 0.217
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "patient wants referal to quit smoking:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 2.000)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 3.442
   SET rptsd->m_height = 0.208
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2((sfeinfo->patreqestreferralyes+
      sfeinfo->patreqestreferralno),char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 3.375)
   SET rptsd->m_x = (offsetx+ 0.600)
   SET rptsd->m_width = 2.567
   SET rptsd->m_height = 0.200
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Wants NRT:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 3.500)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 3.625
   SET rptsd->m_height = 0.200
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patrequestnrtyes,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 3.175)
   SET rptsd->m_x = (offsetx+ 0.600)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Resource information NOT given (dta):",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 3.175)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patcresourceinfonotgiven,char
      (0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 3.050)
   SET rptsd->m_x = (offsetx+ 0.600)
   SET rptsd->m_width = 2.833
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Resource information given (dta):",
      char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 3.050)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patcresourceinfogiven,char(0)
      ))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.050)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.817
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Never smoked:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.050)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->hasneversmoked,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.875)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.817
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NOT smoked in the last 12 months:",
      char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.875)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->notsmokedlast12months,char(0)
      ))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 6.375)
   SET rptsd->m_x = (offsetx+ 0.375)
   SET rptsd->m_width = 1.067
   SET rptsd->m_height = 0.208
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Smoking Referals:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 6.925)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 1.525
   SET rptsd->m_height = 0.217
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("individualCounselingCnt ",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 6.925)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->individualcounselingcnt,char(
       0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 6.750)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 1.525
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FreedomFromSmokCnt ",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 6.750)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->freedomfromsmokcnt,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 7.125)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 1.525
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("pharmacotherapy ",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 7.125)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->pharmacotherapy,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 7.300)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 1.525
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("selfHelp",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 7.300)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->selfhelp,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 7.500)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 1.525
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("TelephoneCounseling ",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 7.500)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->telephonecounseling,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 7.675)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 1.525
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Other",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 7.675)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->other,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 6.550)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 1.525
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("QuitWorksCnt",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 6.550)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->quitworks,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 4.550)
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.175
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Wants Referral:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 4.550)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 2.442
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->bmcpatientwantsrefer,char(0))
     )
   ENDIF
   SET rptsd->m_y = (offsety+ 5.125)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 2.492
   SET rptsd->m_height = 0.175
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->mlhfmcpatientwantsrefer,char(
       0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.425)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.817
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Caregiver smoked in the last 12 months:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.425)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->cargiversmokedlast12,char(0))
     )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.625)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.817
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Caregiver NOT smoked in the last 12 months:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.625)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->caregivernosmoked,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.250)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.817
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Unable to consent NRT/Cessation:",
      char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.250)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->smokernoconsent,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.800)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Unable to obtain:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.800)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->unabletoobtain,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 6.375)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->referralcnt,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 5.250)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 2.442
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->mlhfmcpatientwantsrefercompl,
      char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 4.675)
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.175
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient referral compleated:",char(0)
      ))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 4.675)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 2.442
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->bmcpatientwantsrefercompl,
      char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 3.875)
   SET rptsd->m_x = (offsetx+ 0.600)
   SET rptsd->m_width = 3.067
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Patient who requested NRT recived NRT:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 3.875)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = 0.192
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patreqnrtgotnrt,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 3.192
   SET rptsd->m_height = 0.258
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(format(cnvtdatetime(
         beg_date_qual),"MM/DD/YY HH:MM;;q"),"-",format(cnvtdatetime(end_date_qual),
        "MM/DD/YY HH:MM;;q")),char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 2.500)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.875
   SET rptsd->m_height = 0.217
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Smoking Cessation Resources / Information:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 4.375)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.092
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BMC:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 4.875)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.092
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BFMC / BMLH:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 5.125)
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.175
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Wants Referral:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 5.250)
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.175
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Refer Compleated:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 4.250)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 2.092
   SET rptsd->m_height = 0.217
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Inpatient:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 0.925)
   SET rptsd->m_width = 2.067
   SET rptsd->m_height = 0.192
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->location,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 0.300)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.217
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 3.300)
   SET rptsd->m_width = 0.942
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time Range:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 4.000)
   SET rptsd->m_x = (offsetx+ 0.600)
   SET rptsd->m_width = 3.067
   SET rptsd->m_height = 0.217
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Patient who did not request NRT recived NRT:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 4.000)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = 0.192
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patnoreqnrtgotnrt,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 6.125)
   SET rptsd->m_x = (offsetx+ 0.900)
   SET rptsd->m_width = 2.550
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Clinical condition precludes counseling:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 6.125)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->clinicalcondition,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 5.925)
   SET rptsd->m_x = (offsetx+ 0.900)
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Refused counseling:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 5.925)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->refusedcounseling,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 5.800)
   SET rptsd->m_x = (offsetx+ 0.900)
   SET rptsd->m_width = 2.200
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Not ready to quit at this time:",char
      (0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 5.800)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 4.117
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->notreadytoquit,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 5.500)
   SET rptsd->m_x = (offsetx+ 0.650)
   SET rptsd->m_width = 2.650
   SET rptsd->m_height = 0.217
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Smoking Referral Outcome:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.300)
   SET rptsd->m_x = (offsetx+ 0.650)
   SET rptsd->m_width = 2.833
   SET rptsd->m_height = 0.217
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.150)
   SET rptsd->m_x = (offsetx+ 0.650)
   SET rptsd->m_width = 2.833
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 2.300)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 3.442
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patreqestreferralno,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.150)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 3.442
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patreqestreferralyes,char(0))
     )
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 3.625)
   SET rptsd->m_x = (offsetx+ 0.800)
   SET rptsd->m_width = 2.600
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 3.500)
   SET rptsd->m_x = (offsetx+ 0.800)
   SET rptsd->m_width = 2.650
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 3.625)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 3.625
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->patrequestnrtno,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 8.175)
   SET rptsd->m_x = (offsetx+ 6.425)
   SET rptsd->m_width = 0.333
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 8.175)
   SET rptsd->m_x = (offsetx+ 6.800)
   SET rptsd->m_width = 0.742
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reporttimeend,char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 8.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.100)
   SET rptsd->m_width = 4.300
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname33 = _remfieldname33
   IF (_remfieldname33 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname33,((size(
        inactiveforms) - _remfieldname33)+ 1),inactiveforms)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname33 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname33,((size(inactiveforms) -
       _remfieldname33)+ 1),inactiveforms)))))
     SET _remfieldname33 = (_remfieldname33+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname33 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname33)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremfieldname33 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname33,((size
       (inactiveforms) - _holdremfieldname33)+ 1),inactiveforms)))
   ELSE
    SET _remfieldname33 = _holdremfieldname33
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 2.683)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 3.442
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sfeinfo->pattaskresourceinfogiven,char
      (0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.808)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 3.442
   SET rptsd->m_height = 0.208
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(((sfeinfo->smokedlast12months+ sfeinfo
      ->cargiversmokedlast12) - sfeinfo->pattaskresourceinfogiven),char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 2.800)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.200
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Resource information NOT given (task):",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.675)
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 2.833
   SET rptsd->m_height = 0.217
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Resource information given (task):",
      char(0)))
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
   SET rptreport->m_reportname = "BHS_SFE_OUTCOMES_SUMMARY_FRM"
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
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 SET bfirsttime = 1
 WHILE (((_bcontlayoutsection0=1) OR (bfirsttime=1)) )
   SET _bholdcontinue = _bcontlayoutsection0
   SET _fdrawheight = layoutsection0(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
   IF (((_yoffset+ _fdrawheight) > _fenddetail))
    CALL pagebreak(0)
   ELSEIF (_bholdcontinue=1
    AND _bcontlayoutsection0=0)
    CALL pagebreak(0)
   ENDIF
   SET dummy_val = layoutsection0(rpt_render,(_fenddetail - _yoffset),_bcontlayoutsection0)
   SET bfirsttime = 0
 ENDWHILE
 CALL finalizereport(_sendto)
END GO
