CREATE PROGRAM bhs_rpt_pdc_orders_lyt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD m_rec(
   1 l_pcnt = i4
   1 plist[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 c_name = c100
     2 c_fin = c25
     2 c_cmrn = c25
     2 c_dob = c25
     2 c_room = c25
     2 l_ocnt = i4
     2 c_admit_diagnosis = c255
     2 olist[*]
       3 f_order_id = f8
       3 f_encntr_id = f8
       3 c_order_mnemonic = c100
       3 c_start_dt_tm = c35
 ) WITH protect
 RECORD g_request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 ) WITH public, persist
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH public
 ENDIF
 DECLARE mf_orderaction_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE mf_orderedstatus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_inpatenctypeclass_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",69,"INPATIENT"
   ))
 DECLARE mf_bmcfacility_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ml_pcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ocnt = i4 WITH protect, noconstant(0)
 DECLARE mc_rpt_title = c255 WITH protect, noconstant(" ")
 DECLARE mc_rpt_date = c50 WITH protect, noconstant(" ")
 DECLARE mf_end_detail = f8 WITH protect, noconstant(7.60)
 DECLARE mf_footer_offset = f8 WITH protect, noconstant(7.80)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
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
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (headpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 2.494
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Patient Name",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.508)
   SET rptsd->m_width = 0.743
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Room",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.258)
   SET rptsd->m_width = 1.931
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Test Name",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.195)
   SET rptsd->m_width = 2.244
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Primary Diagnosis",char(0)))
   ENDIF
   SET rptsd->m_flags = 1028
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.445)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Time",char(0)))
   ENDIF
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.945)
   SET rptsd->m_width = 0.743
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Acct/FIN",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 8.695)
   SET rptsd->m_width = 0.743
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DOB",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 9.445)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("CMRN",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.188),offsety,(offsetx+ 5.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.438),offsety,(offsetx+ 7.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.938),offsety,(offsetx+ 7.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.688),offsety,(offsetx+ 8.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.438),offsety,(offsetx+ 9.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.001),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.001),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __mc_rpt_title = vc WITH noconstant(build2(build(mc_rpt_title),char(0))), protect
   DECLARE __mc_rpt_date = vc WITH noconstant(build2(build(mc_rpt_date),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.011)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 8.501
    SET rptsd->m_height = 0.303
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mc_rpt_title)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 8.501
    SET rptsd->m_height = 0.303
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mc_rpt_date)
    SET _yoffset = (offsety+ 0.750)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.750)
     SET holdheight = 0
     SET holdheight += tablerow(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.375000), private
   DECLARE __patient_name = vc WITH noconstant(build(m_rec->plist[ml_pcnt].c_name,char(0))), protect
   DECLARE __rm_number = vc WITH noconstant(build(m_rec->plist[ml_pcnt].c_room,char(0))), protect
   DECLARE __test_name = vc WITH noconstant(build(m_rec->plist[ml_pcnt].olist[ml_ocnt].
     c_order_mnemonic,char(0))), protect
   DECLARE __primary_diagnosis = vc WITH noconstant(build(m_rec->plist[ml_pcnt].c_admit_diagnosis,
     char(0))), protect
   DECLARE __scheduled_time = vc WITH noconstant(build(m_rec->plist[ml_pcnt].olist[ml_ocnt].
     c_start_dt_tm,char(0))), protect
   DECLARE __acct_fin = vc WITH noconstant(build(m_rec->plist[ml_pcnt].c_fin,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build(m_rec->plist[ml_pcnt].c_dob,char(0))), protect
   DECLARE __cmrn = vc WITH noconstant(build(m_rec->plist[ml_pcnt].c_cmrn,char(0))), protect
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 2.494
   SET rptsd->m_height = 0.368
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.508)
   SET rptsd->m_width = 0.743
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rm_number)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.258)
   SET rptsd->m_width = 1.931
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__test_name)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.195)
   SET rptsd->m_width = 2.244
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primary_diagnosis)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.445)
   SET rptsd->m_width = 0.493
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__scheduled_time)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.945)
   SET rptsd->m_width = 0.743
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acct_fin)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 8.695)
   SET rptsd->m_width = 0.743
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 9.445)
   SET rptsd->m_width = 0.556
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cmrn)
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.500),offsety,(offsetx+ 2.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.188),offsety,(offsetx+ 5.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.438),offsety,(offsetx+ 7.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.938),offsety,(offsetx+ 7.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.688),offsety,(offsetx+ 8.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.438),offsety,(offsetx+ 9.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.001),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.001),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight += tablerow1(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (noorderssection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = noorderssectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (noorderssectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 5.813
    SET rptsd->m_height = 0.376
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No Orders Scheduled for Today",char(0
       )))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 8.501)
    SET rptsd->m_width = 1.490
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.011)
    SET rptsd->m_width = 1.553
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curprog,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_PDC_ORDERS_LYT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
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
   SET rptfont->m_pointsize = 10
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
 SELECT INTO "nl:"
  FROM order_action oa,
   orders o,
   order_catalog oc,
   encounter e,
   person p,
   encntr_alias fin,
   person_alias cmrn,
   order_detail od,
   order_detail oddx
  PLAN (oa
   WHERE oa.action_dt_tm >= cnvtdatetime((curdate - 180),0)
    AND oa.action_dt_tm < cnvtdatetime(curdate,0)
    AND oa.action_type_cd=mf_orderaction_cd)
   JOIN (o
   WHERE o.template_order_id=oa.order_id
    AND o.template_order_flag=2
    AND o.order_status_cd=mf_orderedstatus_cd)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.primary_mnemonic="PDC*"
    AND oc.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=mf_bmcfacility_cd
    AND e.disch_dt_tm=null
    AND e.encntr_type_class_cd=mf_inpatenctypeclass_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_fin_cd
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (cmrn
   WHERE cmrn.person_id=p.person_id
    AND cmrn.person_alias_type_cd=mf_cmrn_cd
    AND cmrn.active_ind=1
    AND cmrn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="REQSTARTDTTM"
    AND od.oe_field_dt_tm_value >= cnvtdatetime(curdate,0)
    AND od.oe_field_dt_tm_value < cnvtdatetime((curdate+ 1),0))
   JOIN (oddx
   WHERE (oddx.order_id= Outerjoin(o.order_id))
    AND (oddx.oe_field_meaning= Outerjoin("ICD9")) )
  ORDER BY o.person_id, o.order_id, od.action_sequence DESC,
   oddx.action_sequence DESC
  HEAD REPORT
   ml_pcnt = 0, mc_rpt_title = "Daily Scheduled Inpatient Ultrasounds", mc_rpt_date = format(
    cnvtdatetime(curdate,curtime),"mm/dd/yyyy;;D"),
   CALL headpagesection(rpt_render), mc_rpt_title =
   "Daily Scheduled Inpatient Ultrasounds - continued"
  HEAD o.person_id
   ml_pcnt += 1, m_rec->l_pcnt = ml_pcnt, stat = alterlist(m_rec->plist,ml_pcnt),
   m_rec->plist[ml_pcnt].f_person_id = o.person_id, m_rec->plist[ml_pcnt].f_encntr_id = o.encntr_id,
   m_rec->plist[ml_pcnt].c_name = trim(p.name_full_formatted,3),
   m_rec->plist[ml_pcnt].c_fin = trim(fin.alias,3), m_rec->plist[ml_pcnt].c_cmrn = trim(cmrn.alias,3),
   m_rec->plist[ml_pcnt].c_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;D")
   IF (e.loc_nurse_unit_cd > 0.00
    AND e.loc_room_cd > 0.00)
    m_rec->plist[ml_pcnt].c_room = build(uar_get_code_display(e.loc_nurse_unit_cd),"/",
     uar_get_code_display(e.loc_room_cd))
   ELSEIF (e.loc_nurse_unit_cd > 0.00
    AND e.loc_room_cd <= 0.00)
    m_rec->plist[ml_pcnt].c_room = build(uar_get_code_display(e.loc_nurse_unit_cd))
   ELSEIF (e.loc_nurse_unit_cd <= 0.00
    AND e.loc_room_cd > 0.00)
    m_rec->plist[ml_pcnt].c_room = build(uar_get_code_display(e.loc_room_cd))
   ENDIF
   ml_ocnt = 0
  HEAD o.order_id
   ml_ocnt += 1, m_rec->plist[ml_pcnt].l_ocnt = ml_ocnt, stat = alterlist(m_rec->plist[ml_pcnt].olist,
    ml_ocnt),
   m_rec->plist[ml_pcnt].olist[ml_ocnt].f_encntr_id = o.encntr_id, m_rec->plist[ml_pcnt].olist[
   ml_ocnt].f_order_id = o.order_id, m_rec->plist[ml_pcnt].olist[ml_ocnt].c_order_mnemonic = o
   .order_mnemonic,
   m_rec->plist[ml_pcnt].olist[ml_ocnt].c_start_dt_tm = format(od.oe_field_dt_tm_value,"HH:mm;;D")
   IF (oddx.oe_field_display_value > " ")
    m_rec->plist[ml_pcnt].c_admit_diagnosis = concat(trim(oddx.oe_field_display_value,3),"/",trim(e
      .reason_for_visit,3))
   ELSE
    m_rec->plist[ml_pcnt].c_admit_diagnosis = trim(e.reason_for_visit,3)
   ENDIF
   IF (_yoffset > mf_end_detail)
    _yoffset = mf_footer_offset,
    CALL footpagesection(rpt_render),
    CALL pagebreak(rpt_render),
    CALL headpagesection(rpt_render)
   ENDIF
   CALL detailsection(rpt_render)
  FOOT REPORT
   IF (ml_pcnt=0)
    _yoffset += 0.50,
    CALL noorderssection(rpt_render)
   ENDIF
   _yoffset = mf_footer_offset,
   CALL footpagesection(rpt_render)
  WITH nullreport, nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 CALL finalizereport(value( $OUTDEV))
#exit_script
 SET reply->status_data.status = "S"
END GO
