CREATE PROGRAM discern_menu_dcp_report_driver
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Report Type" = "Person",
  "DCP Reports" = "",
  "Person Search:" = value(),
  "Visit" = value(),
  "Doc Type:" = 1
  WITH outdev, rpt_type, dcpreports,
  persons, enctr, doctype
 DECLARE _createfonts(dummy) = null WITH public
 DECLARE _createpens(dummy) = null WITH public
 DECLARE _pagebreak(dummy) = null WITH public
 DECLARE _finalizereport(dummy) = null WITH public
 DECLARE _initializereport(dummy) = null WITH public
 DECLARE _hreport = i4 WITH noconstant(0), public
 DECLARE times200 = i4 WITH noconstant(0), public
 DECLARE times10b0 = i4 WITH noconstant(0), public
 DECLARE times100 = i4 WITH noconstant(0), public
 DECLARE pen40s0c0 = i4 WITH noconstant(0), public
 DECLARE pen20s0c0 = i4 WITH noconstant(0), public
 DECLARE pen10s0c0 = i4 WITH noconstant(0), public
 DECLARE pen13s0c0 = i4 WITH noconstant(0), public
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 20
   SET rptfont->m_bold = rpt_off
   SET times200 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.013889
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = uar_rptencodecolor(0,0,0)
   SET pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.020000
   SET pen20s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.040000
   SET pen40s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.010000
   SET pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SUBROUTINE _pagebreak(dummy)
  SET _rptpage = uar_rptendpage(_hreport)
  SET _rptpage = uar_rptstartpage(_hreport)
 END ;Subroutine
 SUBROUTINE _finalizereport(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(value( $1)))
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (drawpagetitle(offsetx=f8,offsety=f8) =f8 WITH public)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 1.06)
   SET rptsd->m_x = (offsetx+ 4.50)
   SET rptsd->m_width = 0.38
   SET rptsd->m_height = 0.23
   SET _oldfont = uar_rptsetfont(_hreport,times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,pen20s0c0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Age :"))
   SET rptsd->m_x = (offsetx+ 4.88)
   SET rptsd->m_width = 1.19
   SET _dummyfont = uar_rptsetfont(_hreport,times100)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(cnvtage(qperson->birth_dt_tm)))
   SET rptsd->m_x = (offsetx+ 6.06)
   SET rptsd->m_width = 1.44
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(qperson->gender))
   SET rptsd->m_y = (offsety+ 1.03)
   SET rptsd->m_x = (offsetx+ 1.25)
   SET rptsd->m_width = 3.25
   SET rptsd->m_height = 0.26
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(qperson->name_full_formatted))
   SET rptsd->m_flags = 272
   SET rptsd->m_y = (offsety+ 0.13)
   SET rptsd->m_x = (offsetx+ 0.50)
   SET rptsd->m_width = 7.00
   SET rptsd->m_height = 0.50
   SET _dummyfont = uar_rptsetfont(_hreport,times200)
   SET _dummypen = uar_rptsetpen(_hreport,pen40s0c0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Results by Encounter"))
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.03)
   SET rptsd->m_width = 0.75
   SET rptsd->m_height = 0.26
   SET _dummyfont = uar_rptsetfont(_hreport,times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,pen20s0c0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Patient    :"))
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(1.290000)
 END ;Subroutine
 SUBROUTINE (drawenctitle(offsetx=f8,offsety=f8) =f8 WITH public)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.06)
   SET rptsd->m_x = (offsetx+ 0.50)
   SET rptsd->m_width = 1.25
   SET rptsd->m_height = 0.25
   SET _oldfont = uar_rptsetfont(_hreport,times10b0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Service Location: "))
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_x = (offsetx+ 1.75)
   SET rptsd->m_width = 1.75
   SET _dummyfont = uar_rptsetfont(_hreport,times100)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(qencounter->encounters[qencounter->
     cursor].location))
   SET rptsd->m_x = (offsetx+ 3.50)
   SET rptsd->m_width = 0.52
   SET _dummyfont = uar_rptsetfont(_hreport,times10b0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("From: "))
   SET rptsd->m_x = (offsetx+ 5.81)
   SET rptsd->m_width = 0.25
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("To:"))
   SET rptsd->m_x = (offsetx+ 6.06)
   SET rptsd->m_width = 1.44
   SET _dummyfont = uar_rptsetfont(_hreport,times100)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(format(qencounter->encounters[
      qencounter->cursor].end_effective_dt_tm,"mm/dd/yyyy hh:mm;;q")))
   SET rptsd->m_x = (offsetx+ 4.00)
   SET rptsd->m_width = 1.81
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(format(qencounter->encounters[
      qencounter->cursor].beg_effective_dt_tm,"mm/dd/yyyy hh:mm;;q")))
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   RETURN(0.380000)
 END ;Subroutine
 SUBROUTINE (draworder(offsetx=f8,offsety=f8) =f8 WITH public)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.13)
   SET rptsd->m_x = (offsetx+ 0.75)
   SET rptsd->m_width = 0.75
   SET rptsd->m_height = 0.26
   SET _oldfont = uar_rptsetfont(_hreport,times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,pen10s0c0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Order : "))
   SET rptsd->m_x = (offsetx+ 1.50)
   SET rptsd->m_width = 1.44
   SET _dummyfont = uar_rptsetfont(_hreport,times100)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(qorders->orders[qorders->cursor].
     mnemonic))
   SET rptsd->m_x = (offsetx+ 3.50)
   SET rptsd->m_width = 0.75
   SET _dummyfont = uar_rptsetfont(_hreport,times10b0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Order  Date:"))
   SET rptsd->m_x = (offsetx+ 4.50)
   SET rptsd->m_width = 1.38
   SET _dummyfont = uar_rptsetfont(_hreport,times100)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(format(qorders->orders[qorders->
      cursor].order_dt_tm,"mm/dd/yyyy hh:mm;;q")))
   SET rptsd->m_flags = 1040
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.56)
   SET rptsd->m_x = (offsetx+ 0.75)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.25
   SET _dummyfont = uar_rptsetfont(_hreport,times10b0)
   SET _dummypen = uar_rptsetpen(_hreport,pen13s0c0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Assay"))
   SET rptsd->m_y = (offsety+ 0.55)
   SET rptsd->m_x = (offsetx+ 2.50)
   SET rptsd->m_width = 1.25
   SET rptsd->m_height = 0.26
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Result"))
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.38)
   SET rptsd->m_x = (offsetx+ 4.44)
   SET rptsd->m_width = 1.00
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Normal Range"))
   SET rptsd->m_flags = 1040
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.50)
   SET rptsd->m_x = (offsetx+ 4.00)
   SET rptsd->m_height = 0.31
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Low"))
   SET rptsd->m_y = (offsety+ 0.55)
   SET rptsd->m_x = (offsetx+ 5.25)
   SET rptsd->m_width = 0.94
   SET rptsd->m_height = 0.26
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("High"))
   SET rptsd->m_x = (offsetx+ 6.75)
   SET rptsd->m_width = 0.75
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm("Flags"))
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(0.880000)
 END ;Subroutine
 SUBROUTINE (drawresult(offsetx=f8,offsety=f8) =f8 WITH public)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.06)
   SET rptsd->m_x = (offsetx+ 2.50)
   SET rptsd->m_width = 1.25
   SET rptsd->m_height = 0.19
   SET _oldfont = uar_rptsetfont(_hreport,times100)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(qclinicalevent->events[qclinicalevent
     ->cursor].result_val))
   SET rptsd->m_x = (offsetx+ 5.25)
   SET rptsd->m_width = 1.00
   SET rptsd->m_height = 0.20
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(qclinicalevent->events[qclinicalevent
     ->cursor].normal_high))
   SET rptsd->m_x = (offsetx+ 6.75)
   SET rptsd->m_width = 0.75
   SET _dummyfont = uar_rptsetfont(_hreport,times10b0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(qclinicalevent->events[qclinicalevent
     ->cursor].normalcy_disp))
   SET rptsd->m_x = (offsetx+ 4.00)
   SET rptsd->m_height = 0.19
   SET _dummyfont = uar_rptsetfont(_hreport,times100)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(format(qclinicalevent->events[
      qclinicalevent->cursor].normal_low,"########.##;R;")))
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   RETURN(0.320000)
 END ;Subroutine
 SUBROUTINE _initializereport(devid)
   SET rptreport->m_recsize = 84
   SET rptreport->m_pagewidth = 8.500000
   SET rptreport->m_pageheight = 11.000000
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.000000
   SET rptreport->m_marginright = 0.000000
   SET rptreport->m_margintop = 0.000000
   SET rptreport->m_marginbottom = 0.000000
   SET rptreport->m_reportname = "LVPTEST"
   SET _hreport = uar_rptcreatereport(rptreport,devid,rpt_inches)
   SET _stat = _createfonts(0)
   SET _stat = _createpens(0)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
 END ;Subroutine
 FREE RECORD request
 RECORD request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[*]
     2 encntr_id = f8
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
   1 large_text_qual[*]
     2 text_segment = vc
 )
 DECLARE hrtf = i4 WITH noconstant(0), protect
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE pg = i4 WITH noconstant(0), protect
 DECLARE cont = i4 WITH noconstant(0), protect
 DECLARE nstop = i4 WITH noconstant(0), protect
 DECLARE par = f8 WITH noconstant(1.0), protect
 DECLARE parnum = i4 WITH noconstant(0), protect
 DECLARE ctype = c20 WITH protect
 SET request->script_name =  $DCPREPORTS
 SET ctype = reflect(parameter(4,0))
 IF (substring(1,1,ctype)="L")
  SET nstop = cnvtint(substring(2,19,ctype))
 ELSE
  SET nstop = 1
 ENDIF
 WHILE (parnum < nstop)
   SET parnum += 1
   SET par = parameter(4,parnum)
   CALL echo(par)
   IF (par > 0.0)
    SET stat = alterlist(request->person,parnum)
    SET request->person[parnum].person_id = par
    SET request->person_cnt = parnum
   ENDIF
   CALL echo(reflect( $4))
 ENDWHILE
 SET parnum = 0
 WHILE (parnum < nstop)
   SET parnum += 1
   SET par = parameter(5,parnum)
   CALL echo(par)
   IF (par > 0.0)
    SET stat = alterlist(request->visit,parnum)
    SET request->visit[parnum].encntr_id = par
    SET request->visit_cnt = parnum
   ENDIF
   CALL echo(reflect( $5))
 ENDWHILE
 SET request->output_device =  $OUTDEV
 EXECUTE value( $DCPREPORTS)
 SET modify = nopredeclare
 CALL echorecord(reply)
 IF (textlen(reply->text) > 0)
  FREE RECORD request
  RECORD request(
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
  SET bfound = findstring("{\rtf1",reply->text)
  CALL echo(build("DOCTYPE = ", $DOCTYPE," Find = ",bfound))
  IF (bfound > 0
   AND ( $DOCTYPE > 0))
   CALL echo("passing here")
   CALL _initializereport( $DOCTYPE)
   SET hrtf = uar_rptcreatertf(_hreport,nullterm(reply->text),8.0)
   SET cont = 6
   SET pg = 0
   WHILE (cont=6)
     SET pg += 1
     SET cont = uar_rptrtfdraw(_hreport,hrtf,0.250,0.250,10.5)
     IF (cont=6)
      SET stat = uar_rptendpage(_hreport)
      SET stat = uar_rptstartpage(_hreport)
     ENDIF
   ENDWHILE
   SET stat = uar_rptdestroyrtf(_hreport,hrtf)
   CALL _finalizereport( $OUTDEV)
  ELSE
   SET request->document = reply->text
   IF (size(request->document) > 0)
    SET request->source_filename =  $OUTDEV
    SET request->isblob = "1"
    SET request->document_size = size(request->document)
    FREE RECORD reply
    RECORD reply(
      1 info_line[*]
        2 new_line = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    EXECUTE eks_put_source
   ENDIF
  ENDIF
 ENDIF
END GO
