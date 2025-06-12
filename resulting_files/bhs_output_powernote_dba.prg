CREATE PROGRAM bhs_output_powernote:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET outputdev =  $OUTDEV
 DECLARE altered = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH")), protect
 DECLARE inerror_cd = f8 WITH constant(validatecodevalue("MEANING",8,"INERROR")), protect
 DECLARE ocfcomp = f8 WITH constant(validatecodevalue("MEANING",120,"OCFCOMP")), protect
 DECLARE powernotetitle = vc WITH noconstant(" ")
 FREE RECORD info
 RECORD info(
   1 powernote[*]
     2 sortseq = i4
     2 title = vc
     2 rtfblob = vc
 )
 SET encntr_id = 51906841
 CALL echo("Load PowerNotes")
 FREE RECORD powernotes
 RECORD powernote(
   1 qual[*]
     2 display_key = vc
     2 sortseq = i4
 )
 SET stat = alterlist(powernote->qual,2)
 SET powernote->qual[1].display_key = "PHYSICIANDISCHARGESUMMARY*"
 SET powernote->qual[1].sortseq = 1
 SET powernote->qual[2].display_key = "PATIENTINSTRUCTIONSFOR*"
 SET powernote->qual[2].sortseq = 2
 SELECT INTO "NL:"
  sort = powernote->qual[d.seq].sortseq, srp.scr_pattern_id, ce.event_end_dt_tm
  FROM scd_story s,
   scd_story_pattern ssp,
   scr_pattern srp,
   clinical_event ce,
   ce_blob cb,
   (dummyt d  WITH seq = size(powernote->qual,5))
  PLAN (d)
   JOIN (srp
   WHERE operator(srp.display_key,"like",patstring(powernote->qual[d.seq].display_key,1)))
   JOIN (ssp
   WHERE ssp.scr_pattern_id=srp.scr_pattern_id)
   JOIN (s
   WHERE s.scd_story_id=ssp.scd_story_id
    AND s.story_completion_status_cd=10396.00
    AND s.encounter_id=encntr_id)
   JOIN (ce
   WHERE ce.event_id=s.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (altered, modified, auth))
   JOIN (cb
   WHERE cb.event_id=ce.event_id
    AND cb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY sort, srp.scr_pattern_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD sort
   stat = 0
  HEAD srp.scr_pattern_id
   CALL echo("getting blob")
   IF (cb.compression_cd=ocfcomp)
    blob_compressed_trimmed = fillstring(64000," "), blob_uncompressed = fillstring(64000," "),
    blob_return_len = 0,
    blob_out = fillstring(64000," "), blob_compressed_trimmed = cb.blob_contents,
    CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
    size(blob_uncompressed),blob_return_len),
    blob_out = replace(blob_uncompressed,"ocf_blob","",0)
   ELSE
    blob_out = blob_compressed_trimmed
   ENDIF
   cnt = (cnt+ 1), stat = alterlist(info->powernote,cnt)
   IF (trim(srp.display_key) IN (value("PHYSICIANDISCHARGESUMMARY*")))
    info->powernote[cnt].title = "Physician Discharge Summary", info->powernote[cnt].sortseq = 1
   ELSEIF (trim(srp.display_key) IN (value("PATIENTINSTRUCTIONSFOR*")))
    info->powernote[cnt].title = "Patient Instructions for Discharge", info->powernote[cnt].sortseq
     = 2
   ENDIF
   blob_out = replace(blob_out,"fs2","fs3"), blob_out = replace(blob_out,"fs1","fs2"), info->
   powernote[cnt].rtfblob = blob_out,
   CALL echorecord(info)
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE _creatertf(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headsection(ncalc=i2) = f8 WITH protect
 DECLARE headsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE powernotetitlesec(ncalc=i2) = f8 WITH protect
 DECLARE powernotetitlesecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE powernotesec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE powernotesecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footsection(ncalc=i2) = f8 WITH protect
 DECLARE footsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remphydischsumlbl = i2 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontpowernotesec = i2 WITH noconstant(0), protect
 DECLARE _hrtf_phydischsumlbl = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE headsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE __dttmfld = vc WITH noconstant(build2(build(format(cnvtdatetime(curdate,curtime3),
       "MM/DD/YY HH:MM;;q")),char(0))), protect
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
    SET rptsd->m_height = 0.271
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printing PowerNote",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dttmfld)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE powernotetitlesec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = powernotetitlesecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE powernotetitlesecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.625
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(powernotetitle,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE powernotesec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = powernotesecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE powernotesecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_phydischsumlbl = f8 WITH noconstant(0.0), private
   DECLARE __phydischsumlbl = vc WITH noconstant(build2(trim(info->powernote[x].rtfblob,3),char(0))),
   protect
   IF (bcontinue=0)
    SET _remphydischsumlbl = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _remphydischsumlbl > 0)
    IF (_hrtf_phydischsumlbl=0)
     SET _hrtf_phydischsumlbl = uar_rptcreatertf(_hreport,__phydischsumlbl,5.750)
    ENDIF
    SET _fdrawheight = maxheight
    SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_phydischsumlbl,(offsetx+ 0.000),(offsety+ 0.000),
     _fdrawheight)
    IF ((_fdrawheight > (sectionheight - 0.000)))
     SET sectionheight = (0.000+ _fdrawheight)
    ENDIF
    IF (_rptstat != rpt_continue)
     SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_phydischsumlbl)
     SET _hrtf_phydischsumlbl = 0
     SET _remphydischsumlbl = 0
    ENDIF
   ENDIF
   SET growsum = (growsum+ _remphydischsumlbl)
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
 SUBROUTINE footsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.667)
    SET rptsd->m_width = 1.833
    SET rptsd->m_height = 0.302
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_OUTPUT_POWERNOTE"
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
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = headsection(rpt_render)
 IF (size(info->powernote,5) > 0)
  FOR (x = 1 TO size(info->powernote,5))
    SET becont = 0
    CALL echo("print powerNotes")
    FOR (y = 1 TO 100)
      IF (y=1)
       SET powernotetitle = info->powernote[x].title
      ELSE
       SET powernotetitle = concat(info->powernote[x].title," (continued)")
      ENDIF
      SET d0 = powernotetitlesec(rpt_render)
      SET d0 = powernotesec(rpt_render,7.75,becont)
      IF (becont <= 0)
       SET y = 100
      ELSE
       SET d0 = pgbreak(1)
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 SUBROUTINE pgbreak(dummy)
   CALL echo("Page break")
   SET d0 = footsection(rpt_render)
   SET d0 = pagebreak(dummy)
   SET d0 = headsection(rpt_render)
 END ;Subroutine
 SET d0 = finalizereport( $OUTDEV)
END GO
