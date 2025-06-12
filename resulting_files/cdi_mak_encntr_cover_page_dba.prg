CREATE PROGRAM cdi_mak_encntr_cover_page:dba
 DECLARE _createfonts(dummy) = null WITH public
 DECLARE _createpens(dummy) = null WITH public
 DECLARE _pagebreak(dummy) = null WITH public
 DECLARE _headreport(dummy) = f8 WITH public
 DECLARE _headpage(dummy) = f8 WITH public
 DECLARE _footpage(dummy) = f8 WITH public
 DECLARE _footreport(dummy) = f8 WITH public
 DECLARE _finalizereport(ssendreport=vc) = null WITH public
 DECLARE pageheadsection(nrender=i2) = f8 WITH public
 DECLARE pageheadsectionabs(nrender=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE printfield(nrender=i2,nname=i2) = f8 WITH public
 DECLARE printfieldabs(nrender=i2,offsetx=f8,offsety=f8,nname=i2) = f8 WITH public
 DECLARE printfield_def(nrender=i2,nname=i2) = f8 WITH public
 DECLARE printfield_defabs(nrender=i2,offsetx=f8,offsety=f8,nname=i2) = f8 WITH public
 DECLARE printfield_large(nrender=i2,nname=i2) = f8 WITH public
 DECLARE printfield_largeabs(nrender=i2,offsetx=f8,offsety=f8,nname=i2) = f8 WITH public
 DECLARE printfield_landscape(nrender=i2,nname=i2) = f8 WITH public
 DECLARE printfield_landscapeabs(nrender=i2,offsetx=f8,offsety=f8,nname=i2) = f8 WITH public
 DECLARE _initializereport(dummy=i2) = null WITH public
 DECLARE _hreport = i4 WITH noconstant(0), public
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE titlefont = i4 WITH noconstant(0), public
 DECLARE fieldfont = i4 WITH noconstant(0), public
 DECLARE _oldfont = i4 WITH noconstant(0), public
 DECLARE pen10s0c0 = i4 WITH noconstant(0), public
 DECLARE pen13s0c0 = i4 WITH noconstant(0), public
 DECLARE fheight = f8 WITH noconstant(0.0), protect
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = sfontname
   SET rptfont->m_pointsize = nfontsize
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = uar_rptencodecolor(0,0,0)
   SET fieldfont = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 11
   SET titlefont = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.013889
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = uar_rptencodecolor(0,0,0)
   SET pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.010000
   SET pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SUBROUTINE _pagebreak(dummy)
   SET _fheight = _footpage(0)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = 0.500
   SET _xoffset = 0.50
   SET _fheight = _headpage(0)
 END ;Subroutine
 SUBROUTINE _headreport(dummy)
  SET _fheight = 0.0
  RETURN(_fheight)
 END ;Subroutine
 SUBROUTINE _headpage(dummy)
  SET _fheight = 0.0
  RETURN(_fheight)
 END ;Subroutine
 SUBROUTINE _footpage(dummy)
  SET _fheight = 0.0
  RETURN(_fheight)
 END ;Subroutine
 SUBROUTINE _footreport(dummy)
  SET _fheight = 0.0
  RETURN(_fheight)
 END ;Subroutine
 SUBROUTINE _finalizereport(ssendreport)
   SET _fheight = _footreport(0)
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
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE pageheadsection(nrender)
  DECLARE a1 = i2 WITH noconstant(0), private
  RETURN(pageheadsectionabs(nrender,_xoffset,_yoffset))
 END ;Subroutine
 SUBROUTINE pageheadsectionabs(nrender,offsetx,offsety)
   DECLARE fwidth = f8 WITH noconstant(1.0), private
   IF (norientation=0)
    SET fheight = 1.00
    SET fwidth = 8.50
   ELSE
    SET fheight = 0.75
    SET fwidth = 11.00
   ENDIF
   IF (nrender=0)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.32)
    SET rptsd->m_x = (offsetx+ - (0.20))
    SET rptsd->m_width = fwidth
    SET rptsd->m_height = 0.22
    SET _oldfont = uar_rptsetfont(_hreport,titlefont)
    SET _oldpen = uar_rptsetpen(_hreport,pen10s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(trim(i18ntitle,3)))
    SET rptsd->m_y = (offsety+ 0.16)
    SET _dummypen = uar_rptsetpen(_hreport,pen13s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(trim(i18ncdi,3)))
    SET rptsd->m_y = (offsety+ 0.00)
    SET _dummypen = uar_rptsetpen(_hreport,pen10s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(trim(orgname,3)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (_yoffset+ fheight)
   ENDIF
   RETURN(fheight)
 END ;Subroutine
 SUBROUTINE printfield(nrender,nname)
  DECLARE a1 = i2 WITH noconstant(0), private
  RETURN(printfieldabs(nrender,_xoffset,_yoffset,nname))
 END ;Subroutine
 SUBROUTINE printfieldabs(nrender,offsetx,offsety,nname)
  IF (nname=1)
   IF (_xoffset > 0.50)
    SET _yoffset = (_yoffset+ fheight)
   ENDIF
   SET _xoffset = 0.50
   IF (norientation=0)
    IF (ecp_name_col="2")
     SET _xoffset = 2.69
    ELSEIF (ecp_name_col="3")
     SET _xoffset = 5.38
    ENDIF
   ELSE
    IF (ecp_name_col="2")
     SET _xoffset = 3.75
    ELSEIF (ecp_name_col="3")
     SET _xoffset = 7.30
    ENDIF
   ENDIF
  ENDIF
  IF (norientation=1)
   RETURN(printfield_landscapeabs(nrender,_xoffset,_yoffset,nname))
  ELSEIF (nfontsize > 12)
   RETURN(printfield_largeabs(nrender,_xoffset,_yoffset,nname))
  ELSE
   RETURN(printfield_defabs(nrender,_xoffset,_yoffset,nname))
  ENDIF
 END ;Subroutine
 SUBROUTINE printfield_def(nrender,nname)
  DECLARE a1 = i2 WITH noconstant(0), private
  RETURN(printfield_defabs(nrender,_xoffset,_yoffset,nname))
 END ;Subroutine
 SUBROUTINE printfield_defabs(nrender,offsetx,offsety,nname)
   DECLARE fwidth = f8 WITH noconstant(0.0), private
   DECLARE fbcwidth = f8 WITH noconstant(0.0), private
   IF (nname=1)
    SET fheight = 1.12
    SET fwidth = 2.75
   ELSE
    SET fheight = 1.25
    SET fwidth = 3.75
   ENDIF
   SET fbcwidth = fwidth
   IF (nrender=0)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.00)
    SET rptsd->m_x = (offsetx+ 0.00)
    SET rptsd->m_width = fwidth
    SET rptsd->m_height = 0.22
    SET _oldfont = uar_rptsetfont(_hreport,fieldfont)
    SET _oldpen = uar_rptsetpen(_hreport,pen10s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(fieldname))
    SET _dummypen = uar_rptsetpen(_hreport,pen13s0c0)
    IF (barcodevalue != null)
     IF (size(barcodevalue,1) < 18)
      SET fbcwidth = 0.0
     ENDIF
     SET _rptstat = uar_rptbarcode(_hreport,nbarcodetype,nullterm(barcodevalue),(offsetx+ 0.00),(
      offsety+ 0.52),
      fbcwidth,0.31)
    ENDIF
    SET rptsd->m_flags = 12
    SET rptsd->m_y = (offsety+ 0.17)
    SET rptsd->m_height = 0.40
    SET _dummypen = uar_rptsetpen(_hreport,pen10s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(textvalue))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    IF (_xoffset=0.50
     AND nname=0)
     SET _xoffset = 4.45
    ELSE
     SET _yoffset = (_yoffset+ fheight)
     SET _xoffset = 0.50
    ENDIF
   ENDIF
   RETURN(fheight)
 END ;Subroutine
 SUBROUTINE printfield_large(nrender,nname)
  DECLARE a1 = i2 WITH noconstant(0), private
  RETURN(printfield_largeabs(nrender,_xoffset,_yoffset,nname))
 END ;Subroutine
 SUBROUTINE printfield_largeabs(nrender,offsetx,offsety,nname)
   DECLARE fwidth = f8 WITH noconstant(0.0), private
   DECLARE fbcwidth = f8 WITH noconstant(0.0), private
   SET fheight = 1.50
   IF (nname=1)
    SET fwidth = 2.75
   ELSE
    SET fwidth = 3.75
   ENDIF
   SET fbcwidth = fwidth
   IF (nrender=0)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.00)
    SET rptsd->m_x = (offsetx+ 0.00)
    SET rptsd->m_width = fwidth
    SET rptsd->m_height = 0.41
    SET _oldfont = uar_rptsetfont(_hreport,fieldfont)
    SET _oldpen = uar_rptsetpen(_hreport,pen10s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(fieldname))
    SET _dummypen = uar_rptsetpen(_hreport,pen13s0c0)
    IF (barcodevalue != null)
     IF (size(barcodevalue,1) < 18)
      SET fbcwidth = 0.0
     ENDIF
     SET _rptstat = uar_rptbarcode(_hreport,nbarcodetype,nullterm(barcodevalue),(offsetx+ 0.00),(
      offsety+ 0.93),
      fbcwidth,0.31)
    ENDIF
    SET rptsd->m_flags = 12
    SET rptsd->m_y = (offsety+ 0.30)
    SET rptsd->m_height = 0.68
    SET _dummypen = uar_rptsetpen(_hreport,pen10s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(textvalue))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    IF (_xoffset=0.50
     AND nname=0)
     SET _xoffset = 4.45
    ELSE
     SET _yoffset = (_yoffset+ fheight)
     SET _xoffset = 0.50
    ENDIF
   ENDIF
   RETURN(fheight)
 END ;Subroutine
 SUBROUTINE printfield_landscape(nrender,nname)
  DECLARE a1 = i2 WITH noconstant(0), private
  RETURN(printfield_landscapeabs(nrender,_xoffset,_yoffset,nname))
 END ;Subroutine
 SUBROUTINE printfield_landscapeabs(nrender,offsetx,offsety,nname)
   DECLARE fwidth = f8 WITH noconstant(0.0), private
   DECLARE fbcwidth = f8 WITH noconstant(0.0), private
   SET fheight = 1.12
   IF (nname=1)
    SET fwidth = 3.50
   ELSE
    SET fwidth = 5.00
   ENDIF
   SET fbcwidth = fwidth
   IF (nrender=0)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.00)
    SET rptsd->m_x = (offsetx+ 0.00)
    SET rptsd->m_width = fwidth
    SET rptsd->m_height = 0.28
    SET _oldfont = uar_rptsetfont(_hreport,fieldfont)
    SET _oldpen = uar_rptsetpen(_hreport,pen10s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(fieldname))
    SET rptsd->m_flags = 12
    SET rptsd->m_y = (offsety+ 0.21)
    SET rptsd->m_height = 0.54
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(textvalue))
    SET _dummypen = uar_rptsetpen(_hreport,pen13s0c0)
    IF (barcodevalue != null)
     IF (size(barcodevalue,1) < 23)
      SET fbcwidth = 0.0
     ENDIF
     SET _rptstat = uar_rptbarcode(_hreport,nbarcodetype,nullterm(barcodevalue),(offsetx+ 0.00),(
      offsety+ 0.71),
      fbcwidth,0.31)
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    IF (_xoffset=0.50
     AND nname=0)
     SET _xoffset = 5.70
    ELSE
     SET _yoffset = (_yoffset+ fheight)
     SET _xoffset = 0.50
    ENDIF
   ENDIF
   RETURN(fheight)
 END ;Subroutine
 SUBROUTINE _initializereport(dummy)
   SET rptreport->m_recsize = 84
   IF (norientation=0)
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
   ELSE
    SET rptreport->m_pagewidth = 11.00
    SET rptreport->m_pageheight = 8.50
   ENDIF
   SET rptreport->m_orientation = norientation
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_reportname = "LVPTEST"
   SET _yoffset = 0.500
   SET _xoffset = 0.500
   SET _hreport = uar_rptcreatereport(rptreport,rpt_postscript,rpt_inches)
   SET _stat = _createfonts(0)
   SET _stat = _createpens(0)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _fheight = _headreport(0)
   SET _fheight = _headpage(0)
 END ;Subroutine
 DECLARE printfiletodestcd(outputdestcd=f8,filename=vc) = i4 WITH public
 DECLARE printfiletoqueue(queuename=vc,filename=vc) = i4 WITH public
 SUBROUTINE printfiletodestcd(outputdestcd,filename)
   RECORD cdi_print_request(
     1 output_dest_cd = f8
     1 file_name = vc
     1 copies = i4
     1 output_handle_id = f8
     1 number_of_pages = i4
     1 transmit_dt_tm = dq8
     1 priority_value = i4
     1 report_title = vc
     1 server = vc
     1 country_code = c3
     1 area_code = c10
     1 exchange = c10
     1 suffix = c50
   )
   RECORD cdi_print_reply(
     1 sts = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetojbectname = c15
         3 targetobjectvalue = c100
   )
   SET cdi_print_request->output_dest_cd = outputdestcd
   SET cdi_print_request->file_name = filename
   EXECUTE sys_outputdest_print  WITH replace(request,cdi_print_request), replace(reply,
    cdi_print_reply)
   RETURN(cdi_print_reply->sts)
 END ;Subroutine
 SUBROUTINE printfiletoqueue(queuename,filename)
   DECLARE app = i4 WITH noconstant(2204), private
   DECLARE task = i4 WITH noconstant(2400), private
   DECLARE req = i4 WITH noconstant(2201), private
   DECLARE happ = i4 WITH noconstant(0), private
   DECLARE htask = i4 WITH noconstant(0), private
   DECLARE hstep = i4 WITH noconstant(0), private
   DECLARE hreq = i4 WITH noconstant(0), private
   DECLARE hrep = i4 WITH noconstant(0), private
   DECLARE crmstatus = i4 WITH noconstant(0), private
   DECLARE srvstatus = i4 WITH noconstant(0), private
   DECLARE sts = i4 WITH noconstant(0), private
   SET crmstatus = uar_crmbeginapp(app,happ)
   IF (crmstatus)
    RETURN(sts)
   ENDIF
   SET crmstatus = uar_crmbegintask(happ,task,htask)
   IF (crmstatus)
    CALL uar_crmendapp(happ)
    RETURN(sts)
   ENDIF
   SET crmstatus = uar_crmbeginreq(htask,0,req,hstep)
   IF (crmstatus)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(sts)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   SET srvstatus = uar_srvsetstring(hreq,"queue_name",nullterm(queuename))
   SET srvstatus = uar_srvsetstring(hreq,"file_name",nullterm(filename))
   SET crmstatus = uar_crmperform(hstep)
   IF (crmstatus)
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(sts)
   ENDIF
   SET hrep = uar_crmgetreply(hstep)
   SET sts = uar_srvgetlong(hrep,"sts")
   CALL uar_crmendreq(hstep)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN(sts)
 END ;Subroutine
 DECLARE pc_request = i2 WITH public, noconstant(0)
 DECLARE parseorder = vc WITH noconstant(" "), protect
 DECLARE sparsestring1 = vc WITH public, noconstant("d.seq")
 DECLARE sparsestring2 = vc WITH public, noconstant("d.seq")
 DECLARE sparsestring3 = vc WITH public, noconstant("d.seq")
 DECLARE getparsestring(s1=vc,sparsestring=vc(ref)) = null WITH protect
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 equal[*]
      2 person_id = vc
      2 encounter_id = vc
      2 patient_name = vc
      2 mrn = c20
      2 fin = c20
      2 facility = vc
      2 reg_date = vc
      2 disch_date = vc
      2 patient_location = vc
      2 i18nreg = vc
      2 i18ndisch = vc
      2 name_full_formatted = vc
      2 pqual[*]
        3 display_value_ind = vc
        3 display_barcode_ind = vc
        3 cdf_mean = vc
        3 field_name = vc
        3 display_value = vc
        3 horizontal_pos = vc
        3 vertical_pos = vc
      2 org_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  IF (validate(reply->text,"-1") != "-1")
   SET pc_request = 1
  ENDIF
 ENDIF
 FREE SET temp
 RECORD temp(
   1 infoqual[*]
     2 field_name = vc
     2 display_value = vc
     2 display_value_ind = vc
     2 display_barcode_ind = vc
     2 cdf_mean = vc
     2 horizontal_pos = vc
     2 vertical_pos = vc
 )
 FREE SET copyreply
 RECORD copyreply(
   1 oqual[*]
     2 person_id = vc
     2 encounter_id = vc
     2 patient_name = vc
     2 mrn = c20
     2 fin = c20
     2 facility = vc
     2 reg_date = vc
     2 disch_date = vc
     2 patient_location = vc
     2 i18nreg = vc
     2 i18ndisch = vc
     2 name_full_formatted = vc
     2 orderqual[*]
       3 display_value_ind = vc
       3 display_barcode_ind = vc
       3 cdf_mean = vc
       3 field_name = vc
       3 display_value = vc
       3 display_barcode_value = vc
       3 horizontal_pos = vc
       3 vertical_pos = vc
     2 org_name = vc
 )
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(insert_duplicate,- (1)) != 14)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant(" ")
 ELSE
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(error_value,"ZZZ")="ZZZ")
  DECLARE error_value = vc WITH protect, noconstant(fillstring(150," "))
 ENDIF
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 EXECUTE prefrtl
 DECLARE cdi_get_pref(group_name=vc,pref_name=vc) = vc
 SUBROUTINE cdi_get_pref(arg_group,arg_pref)
   DECLARE group_name = c255 WITH private, noconstant(" ")
   DECLARE pref_name = c255 WITH private, noconstant(" ")
   DECLARE pref_val = c255 WITH private, noconstant(" ")
   DECLARE entry_idx = i4 WITH private, noconstant(0)
   DECLARE entry_cnt = i4 WITH private, noconstant(0)
   DECLARE entry_name = c255 WITH private, noconstant(" ")
   DECLARE attr_cnt = i4 WITH private, noconstant(0)
   DECLARE h_pref = i4 WITH private, noconstant(0)
   DECLARE h_group = i4 WITH private, noconstant(0)
   DECLARE h_section = i4 WITH private, noconstant(0)
   DECLARE h_repgroup = i4 WITH private, noconstant(0)
   DECLARE h_entry = i4 WITH private, noconstant(0)
   DECLARE h_attr = i4 WITH private, noconstant(0)
   SET group_name = arg_group
   SET pref_name = arg_pref
   SET h_pref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(h_pref,"default","system")
   SET stat = uar_prefsetsection(h_pref,"component")
   SET h_group = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(h_group,group_name)
   SET stat = uar_prefaddgroup(h_pref,h_group)
   SET stat = uar_prefperform(h_pref)
   SET h_section = uar_prefgetsectionbyname(h_pref,"component")
   SET h_repgroup = uar_prefgetgroupbyname(h_section,group_name)
   SET entry_cnt = 0
   SET stat = uar_prefgetgroupentrycount(h_repgroup,entry_cnt)
   FOR (entry_idx = 0 TO (entry_cnt - 1))
     SET h_entry = uar_prefgetgroupentry(h_repgroup,entry_idx)
     SET len = 255
     SET entry_name = " "
     SET stat = uar_prefgetentryname(h_entry,entry_name,len)
     IF (trim(entry_name)=pref_name)
      SET attr_cnt = 0
      SET stat = uar_prefgetentryattrcount(h_entry,attr_cnt)
      IF (attr_cnt=1)
       SET h_attr = uar_prefgetentryattr(h_entry,0)
       SET stat = uar_prefgetattrval(h_attr,pref_val,len,0)
       SET stat = uar_prefdestroyattr(h_attr)
      ENDIF
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(h_section)
   CALL uar_prefdestroygroup(h_group)
   CALL uar_prefdestroyinstance(h_pref)
   RETURN(pref_val)
 END ;Subroutine
 DECLARE isimplecoverpage = i4
 DECLARE stemp = vc
 SET stemp = cdi_get_pref("cdi_globals","simplifiedcoverpage")
 SET isimplecoverpage = cnvtint(trim(stemp,3))
 SET failed = false
 IF (isimplecoverpage > 0)
  EXECUTE cdi_rpt_cover_page
  GO TO exit_script
 ENDIF
 SET i18nhandle = 0
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE fin_cd = f8 WITH public, noconstant(0.0)
 DECLARE visitid_cd = f8 WITH public, noconstant(0.0)
 DECLARE nhin_cd = f8 WITH public, noconstant(0.0)
 DECLARE cmrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE cover_page_cd = f8 WITH public, noconstant(0.0)
 DECLARE pcount = i4 WITH public, noconstant(0)
 DECLARE ecount = i4 WITH public, noconstant(0)
 DECLARE pos_cnt = i4 WITH public, noconstant(0)
 DECLARE req_size = i2 WITH public, noconstant(0)
 DECLARE allowed_num_fields = i2 WITH public, noconstant(0)
 DECLARE barcode = vc WITH public, noconstant(" ")
 DECLARE buildbar = vc WITH public, noconstant(" ")
 DECLARE datevalue = vc WITH public, noconstant(" ")
 DECLARE cover_page_name = vc WITH public, noconstant(" ")
 DECLARE output_dist = vc WITH public, noconstant("")
 DECLARE orgname = c100
 DECLARE i18ncdi = c100
 DECLARE i18ntitle = c100
 DECLARE i18nmult = c100
 DECLARE i18nmore = c100
 DECLARE output_dest_cd = f8 WITH public, noconstant(0.0)
 DECLARE nbarcodetype = i2 WITH public, noconstant(0)
 DECLARE sfontname = vc WITH public, noconstant("")
 DECLARE nfontsize = i4 WITH public, noconstant(0)
 DECLARE norientation = i2 WITH public, noconstant(0)
 DECLARE fieldname = vc WITH public, noconstant("")
 DECLARE textvalue = vc WITH public, noconstant("")
 DECLARE barcodevalue = vc WITH public, noconstant("")
 DECLARE ecp_name_col = vc WITH public, noconstant("")
 DECLARE ecp_filename = vc WITH public, noconstant("")
 DECLARE nprefcnt = i2 WITH public, noconstant(0)
 DECLARE ifieldprinted = i2 WITH public, noconstant(0)
 DECLARE curnhin = vc WITH public, noconstant("")
 DECLARE curcmrn = vc WITH public, noconstant("")
 DECLARE curvisitid = vc WITH public, noconstant("")
 DECLARE cmrncnt = i4 WITH public, noconstant(0)
 DECLARE nhincnt = i4 WITH public, noconstant(0)
 DECLARE visitidcnt = i4 WITH public, noconstant(0)
 DECLARE stempsort = vc WITH public, noconstant("")
 DECLARE istringsize = i4 WITH public, noconstant(size(request->batch_selection))
 SET d = findstring("^",request->batch_selection)
 SET d = findstring("^",request->batch_selection,(d+ 1))
 SET d = findstring("^",request->batch_selection,(d+ 1))
 IF (d > 0
  AND istringsize > d)
  SET e = findstring("^",request->batch_selection,(d+ 1))
  IF (e > 0
   AND istringsize > e)
   SET stempsort = substring((d+ 1),(e - (d+ 1)),request->batch_selection)
   CALL getparsestring(stempsort,sparsestring1)
   SET f = findstring("^",request->batch_selection,(e+ 1))
   IF (f > 0
    AND istringsize > f)
    SET stempsort = substring((e+ 1),(f - (e+ 1)),request->batch_selection)
    CALL getparsestring(stempsort,sparsestring2)
    SET g = findstring("^",request->batch_selection,(f+ 1))
    IF (g > 0)
     SET stempsort = substring((f+ 1),(g - (f+ 1)),request->batch_selection)
     CALL getparsestring(stempsort,sparsestring3)
    ELSE
     IF (istringsize > f)
      SET stempsort = substring((f+ 1),(istringsize - f),request->batch_selection)
      CALL getparsestring(stempsort,sparsestring3)
     ENDIF
    ENDIF
   ELSE
    SET stempsort = substring((e+ 1),(istringsize - e),request->batch_selection)
    CALL getparsestring(stempsort,sparsestring2)
    SET sparsestring3 = "d.seq"
   ENDIF
  ELSE
   SET stempsort = substring((d+ 1),(istringsize - d),request->batch_selection)
   CALL getparsestring(stempsort,sparsestring1)
  ENDIF
 ENDIF
 IF (pc_request=0)
  SET req_size = size(request->encntr_qual,5)
 ELSE
  SET req_size = size(request->visit,5)
 ENDIF
 SET ecount = 0
 SET pcount = 0
 SET allowed_num_fields = 9
 SET mrn_cd = 0.0
 SET fin_cd = 0.0
 SET visitid_cd = 0.0
 SET nhin_cd = 0.0
 SET cmrn_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 SET stat = uar_get_meaning_by_codeset(319,"VISITID",1,visitid_cd)
 SET stat = uar_get_meaning_by_codeset(4,"NHIN",1,nhin_cd)
 SET stat = uar_get_meaning_by_codeset(4,"CMRN",1,cmrn_cd)
 SET i18ncdi = uar_i18ngetmessage(i18nhandle,"key1","Cerner ProVision Document Imaging")
 SET i18ntitle = uar_i18ngetmessage(i18nhandle,"key2","Encounter Cover Page")
 SET i18nmult = uar_i18ngetmessage(i18nhandle,"key3","Multiples exist")
 SET i18nmore = uar_i18ngetmessage(i18nhandle,"key4","More")
 SET table_name = "(VARIOUS)"
 IF (req_size=0)
  SET failed = none_found
  SET error_value = "No encounters passed in."
  GO TO exit_script
 ENDIF
 IF (pc_request=0)
  SET output_dist = request->output_dist
 ELSE
  SET output_dist = request->output_device
 ENDIF
 IF (validate(request->output_dest_cd,0.0) > 0.0)
  SET output_dest_cd = request->output_dest_cd
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="IMAGING DOCUMENT"
  DETAIL
   CASE (di.info_name)
    OF "ECP BARCODE TYPE":
     nbarcodetype = cnvtint(di.info_number),nprefcnt = (nprefcnt+ 1)
    OF "ECP FONT TYPE":
     sfontname = di.info_char,nprefcnt = (nprefcnt+ 1)
    OF "ECP FONT SIZE":
     nfontsize = cnvtint(di.info_number),nprefcnt = (nprefcnt+ 1)
    OF "ECP PAGE ORIENT":
     norientation = cnvtint(di.info_number),nprefcnt = (nprefcnt+ 1)
   ENDCASE
  WITH nocounter
 ;end select
 IF (nprefcnt < 4)
  SET failed = true
  SET error_value = "Failed to load cover page preferences."
  GO TO exit_script
 ENDIF
 IF (norientation=1)
  IF (nfontsize > 16)
   SET nfontsize = 16
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c,
   code_value_extension cve,
   code_value_extension cve1,
   code_value_extension cve2,
   code_value_extension cve3
  PLAN (c
   WHERE c.code_set=28360
    AND c.active_ind=1)
   JOIN (cve
   WHERE cve.code_value=c.code_value
    AND cve.field_name="DISPLAY_VALUE_IND")
   JOIN (cve1
   WHERE cve1.code_value=c.code_value
    AND cve1.field_name="DISPLAY_BARCODE_IND")
   JOIN (cve2
   WHERE cve2.code_value=c.code_value
    AND cve2.field_name="HORIZONTAL_POS")
   JOIN (cve3
   WHERE cve3.code_value=c.code_value
    AND cve3.field_name="VERTICAL_POS")
  DETAIL
   pcount = (pcount+ 1)
   IF (pcount > size(temp->infoqual,5))
    stat = alterlist(temp->infoqual,(pcount+ 9))
   ENDIF
   temp->infoqual[pcount].field_name = c.display, temp->infoqual[pcount].cdf_mean = c.cdf_meaning,
   temp->infoqual[pcount].display_value_ind = cve.field_value,
   temp->infoqual[pcount].display_barcode_ind = cve1.field_value, temp->infoqual[pcount].
   horizontal_pos = cve2.field_value, temp->infoqual[pcount].vertical_pos = cve3.field_value
  FOOT REPORT
   stat = alterlist(temp->infoqual,pcount)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = select_error
  SET error_value = "Error retrieving code value extensions from codeset 28360"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  page_name = description
  FROM code_value c
  WHERE c.code_set=28360
   AND c.cdf_meaning="DOC_NAME"
  DETAIL
   cover_page_name = page_name
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = select_error
  SET error_value = "Error retrieving Cover Page Name description from codeset 28360"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(copyreply->oqual,req_size)
 IF (pc_request=0)
  SET encntr_join = "E.Encntr_Id = Request->Encntr_Qual[d.seq].Encntr_Id"
 ELSE
  SET encntr_join = "E.Encntr_Id = Request->visit[d.seq].Encntr_Id"
 ENDIF
 SELECT
  IF (((size(sparsestring1) > 0) OR (((size(sparsestring2) > 0) OR (size(sparsestring3) > 0)) )) )
   ORDER BY parser(sparsestring1), parser(sparsestring2), parser(sparsestring3),
    d.seq
  ELSE
   ORDER BY d.seq
  ENDIF
  INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), patloc = uar_get_code_display(e
   .loc_nurse_unit_cd), mrn_nbr = cnvtalias(ea1.alias,ea1.alias_pool_cd),
  fin_nbr = cnvtalias(ea2.alias,ea2.alias_pool_cd), nhin_nbr = cnvtalias(pa1.alias,pa1.alias_pool_cd),
  cmrn_nbr = cnvtalias(pa2.alias,pa2.alias_pool_cd),
  visitid_nbr = cnvtalias(ea3.alias,ea3.alias_pool_cd), p.person_id, p.name_full_formatted,
  e.reg_dt_tm, e.encntr_id, e.disch_dt_tm,
  d.seq
  FROM (dummyt d  WITH seq = value(req_size)),
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2,
   encntr_alias ea3,
   person_alias pa1,
   person_alias pa2,
   organization o
  PLAN (d)
   JOIN (e
   WHERE parser(encntr_join))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (o
   WHERE e.organization_id=o.organization_id)
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(mrn_cd)
    AND ea1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea1.active_ind=outerjoin(1))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.encntr_alias_type_cd=outerjoin(fin_cd)
    AND ea2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea2.active_ind=outerjoin(1))
   JOIN (ea3
   WHERE ea3.encntr_id=outerjoin(e.encntr_id)
    AND ea3.encntr_alias_type_cd=outerjoin(visitid_cd)
    AND ea3.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea3.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea3.active_ind=outerjoin(1))
   JOIN (pa1
   WHERE pa1.person_id=outerjoin(p.person_id)
    AND pa1.person_alias_type_cd=outerjoin(nhin_cd)
    AND pa1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa1.active_ind=outerjoin(1))
   JOIN (pa2
   WHERE pa2.person_id=outerjoin(p.person_id)
    AND pa2.person_alias_type_cd=outerjoin(cmrn_cd)
    AND pa2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa2.active_ind=outerjoin(1))
  HEAD d.seq
   ecount = (ecount+ 1), tempcnt = 0, curnhin = "",
   curcmrn = "", curvisitid = "", nhincnt = 0,
   cmrncnt = 0, visitidcnt = 0, copyreply->oqual[ecount].org_name = o.org_name,
   copyreply->oqual[ecount].person_id = cnvtstring(p.person_id), copyreply->oqual[ecount].
   encounter_id = cnvtstring(e.encntr_id), copyreply->oqual[ecount].patient_name = concat(trim(p
     .name_last_key,3)," ",trim(p.name_first_key,3)),
   copyreply->oqual[ecount].mrn = mrn_nbr, copyreply->oqual[ecount].fin = fin_nbr, copyreply->oqual[
   ecount].facility = facility,
   copyreply->oqual[ecount].reg_date = format(e.reg_dt_tm,"MM/DD/YY"), copyreply->oqual[ecount].
   disch_date = format(e.disch_dt_tm,"MM/DD/YY"), copyreply->oqual[ecount].name_full_formatted = p
   .name_full_formatted,
   copyreply->oqual[ecount].patient_location = patloc, copyreply->oqual[ecount].i18nreg = trim(format
    (e.reg_dt_tm,"@LONGDATETIME;;Q"),3), copyreply->oqual[ecount].i18ndisch = trim(format(e
     .disch_dt_tm,"@LONGDATETIME;;Q"),3),
   stat = alterlist(copyreply->oqual[ecount].orderqual,pcount)
  DETAIL
   tempcnt = (tempcnt+ 1)
   FOR (y = 1 TO pcount)
    CASE (temp->infoqual[y].cdf_mean)
     OF "ENCOUNTER_ID":
      pos_cnt = 1,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = cnvtstring(e.encntr_id), copyreply
       ->oqual[ecount].orderqual[pos_cnt].display_barcode_value = cnvtupper(cnvtstring(e.encntr_id))
      ENDIF
     OF "MRN":
      pos_cnt = 2,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = mrn_nbr, copyreply->oqual[ecount].
       orderqual[pos_cnt].display_barcode_value = cnvtupper(cnvtalphanum(ea1.alias))
      ENDIF
     OF "FACILITY":
      pos_cnt = 3,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = facility, copyreply->oqual[ecount]
       .orderqual[pos_cnt].display_barcode_value = cnvtupper(facility)
      ENDIF
     OF "PATIENT NAME":
      pos_cnt = 4,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = p.name_full_formatted, copyreply->
       oqual[ecount].orderqual[pos_cnt].display_barcode_value = concat(trim(p.name_last_key,3)," ",
        trim(p.name_first_key,3))
      ENDIF
     OF "PERSON_ID":
      pos_cnt = 5,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = cnvtstring(p.person_id), copyreply
       ->oqual[ecount].orderqual[pos_cnt].display_barcode_value = cnvtupper(cnvtstring(p.person_id))
      ENDIF
     OF "FIN":
      pos_cnt = 6,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = fin_nbr, copyreply->oqual[ecount].
       orderqual[pos_cnt].display_barcode_value = cnvtupper(cnvtalphanum(ea2.alias))
      ENDIF
     OF "ADMIT DATE":
      pos_cnt = 7,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = trim(format(e.reg_dt_tm,
         "@LONGDATETIME;;Q"),3), copyreply->oqual[ecount].orderqual[pos_cnt].display_barcode_value =
       format(e.reg_dt_tm,"MM/DD/YY")
      ENDIF
     OF "DISCH DATE":
      pos_cnt = 8,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = trim(format(e.disch_dt_tm,
         "@LONGDATETIME;;Q"),3), copyreply->oqual[ecount].orderqual[pos_cnt].display_barcode_value =
       format(e.disch_dt_tm,"MM/DD/YY")
      ENDIF
     OF "PATIENT LOC":
      pos_cnt = 9,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = patloc, copyreply->oqual[ecount].
       orderqual[pos_cnt].display_barcode_value = cnvtupper(patloc)
      ENDIF
     OF "DOC_NAME":
      pos_cnt = 10,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[10].horizontal_pos = temp->infoqual[y].horizontal_pos,
       copyreply->oqual[ecount].orderqual[10].vertical_pos = temp->infoqual[y].vertical_pos
      ENDIF
     OF "NHIN":
      pos_cnt = 11,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = nhin_nbr, copyreply->oqual[ecount]
       .orderqual[pos_cnt].display_barcode_value = cnvtupper(cnvtalphanum(pa1.alias)), curnhin =
       nhin_nbr,
       nhincnt = (nhincnt+ 1)
      ELSE
       IF (trim(curnhin,3) != trim(nhin_nbr,3))
        IF (nhincnt=1)
         copyreply->oqual[ecount].orderqual[pos_cnt].display_value = concat(copyreply->oqual[ecount].
          orderqual[pos_cnt].display_value," (",trim(i18nmult,3),": ",trim(nhin_nbr,1),
          ")"), curnhin = nhin_nbr, nhincnt = (nhincnt+ 1)
        ELSEIF (nhincnt=2)
         copyreply->oqual[ecount].orderqual[pos_cnt].display_value = concat(substring(1,(size(
            copyreply->oqual[ecount].orderqual[pos_cnt].display_value) - 1),copyreply->oqual[ecount].
           orderqual[pos_cnt].display_value),", ",trim(i18nmore,3),"...)"), nhincnt = (nhincnt+ 1)
        ENDIF
       ENDIF
      ENDIF
     OF "CMRN":
      pos_cnt = 12,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = cmrn_nbr, copyreply->oqual[ecount]
       .orderqual[pos_cnt].display_barcode_value = cnvtupper(cnvtalphanum(pa2.alias)), curcmrn =
       cmrn_nbr,
       cmrncnt = (cmrncnt+ 1)
      ELSE
       IF (trim(curcmrn,3) != trim(cmrn_nbr,3))
        IF (cmrncnt=1)
         copyreply->oqual[ecount].orderqual[pos_cnt].display_value = concat(copyreply->oqual[ecount].
          orderqual[pos_cnt].display_value," (",trim(i18nmult,3),": ",trim(cmrn_nbr,1),
          ")"), curcmrn = cmrn_nbr, cmrncnt = (cmrncnt+ 1)
        ELSEIF (cmrncnt=2)
         copyreply->oqual[ecount].orderqual[pos_cnt].display_value = concat(substring(1,(size(
            copyreply->oqual[ecount].orderqual[pos_cnt].display_value) - 1),copyreply->oqual[ecount].
           orderqual[pos_cnt].display_value),", ",trim(i18nmore,3),"...)"), cmrncnt = (cmrncnt+ 1)
        ENDIF
       ENDIF
      ENDIF
     OF "VISITID":
      pos_cnt = 13,
      IF (size(copyreply->oqual[ecount].orderqual[pos_cnt].display_value,1) <= 0)
       copyreply->oqual[ecount].orderqual[pos_cnt].display_value = visitid_nbr, copyreply->oqual[
       ecount].orderqual[pos_cnt].display_barcode_value = cnvtupper(cnvtalphanum(ea3.alias)),
       curvisitid = visitid_nbr,
       visitidcnt = (visitidcnt+ 1)
      ELSE
       IF (visitidcnt=1)
        copyreply->oqual[ecount].orderqual[pos_cnt].display_value = concat(copyreply->oqual[ecount].
         orderqual[pos_cnt].display_value," (",trim(i18nmult,3),": ",trim(visitid_nbr,1),
         ")"), curvisitid = visitid_nbr, visitidcnt = (visitidcnt+ 1)
       ELSEIF (visitidcnt=2)
        copyreply->oqual[ecount].orderqual[pos_cnt].display_value = concat(substring(1,(size(
           copyreply->oqual[ecount].orderqual[pos_cnt].display_value) - 1),copyreply->oqual[ecount].
          orderqual[pos_cnt].display_value),", ",trim(i18nmore,3),"...)"), visitidcnt = (visitidcnt+
        1)
       ENDIF
      ENDIF
     ELSE
      pos_cnt = 0
    ENDCASE
    ,
    IF (pos_cnt > 0)
     copyreply->oqual[ecount].orderqual[pos_cnt].field_name = temp->infoqual[y].field_name, copyreply
     ->oqual[ecount].orderqual[pos_cnt].cdf_mean = temp->infoqual[y].cdf_mean, copyreply->oqual[
     ecount].orderqual[pos_cnt].display_value_ind = temp->infoqual[y].display_value_ind,
     copyreply->oqual[ecount].orderqual[pos_cnt].display_barcode_ind = temp->infoqual[y].
     display_barcode_ind
    ENDIF
   ENDFOR
  FOOT REPORT
   stat = alterlist(copyreply->oqual,ecount)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = none_found
  SET error_value = "No encounters qualified in select"
  GO TO exit_script
 ENDIF
 IF (pc_request=0)
  SET stat = alterlist(reply->equal,size(copyreply->oqual,5))
  FOR (i = 1 TO size(copyreply->oqual,5))
    SET reply->equal[i].person_id = copyreply->oqual[i].person_id
    SET reply->equal[i].encounter_id = copyreply->oqual[i].encounter_id
    SET reply->equal[i].patient_name = copyreply->oqual[i].patient_name
    SET reply->equal[i].mrn = copyreply->oqual[i].mrn
    SET reply->equal[i].fin = copyreply->oqual[i].fin
    SET reply->equal[i].facility = copyreply->oqual[i].facility
    SET reply->equal[i].reg_date = copyreply->oqual[i].reg_date
    SET reply->equal[i].disch_date = copyreply->oqual[i].disch_date
    SET reply->equal[i].patient_location = copyreply->oqual[i].patient_location
    SET reply->equal[i].i18nreg = copyreply->oqual[i].i18nreg
    SET reply->equal[i].i18ndisch = copyreply->oqual[i].i18ndisch
    SET reply->equal[i].name_full_formatted = copyreply->oqual[i].name_full_formatted
    SET reply->equal[i].org_name = copyreply->oqual[i].org_name
    SET stat = alterlist(reply->equal[i].pqual,size(copyreply->oqual[i].orderqual,5))
    FOR (j = 1 TO size(copyreply->oqual[i].orderqual,5))
      SET reply->equal[i].pqual[j].display_value_ind = copyreply->oqual[i].orderqual[j].
      display_value_ind
      SET reply->equal[i].pqual[j].display_barcode_ind = copyreply->oqual[i].orderqual[j].
      display_barcode_ind
      SET reply->equal[i].pqual[j].cdf_mean = copyreply->oqual[i].orderqual[j].cdf_mean
      SET reply->equal[i].pqual[j].field_name = copyreply->oqual[i].orderqual[j].field_name
      SET reply->equal[i].pqual[j].display_value = copyreply->oqual[i].orderqual[j].display_value
      SET reply->equal[i].pqual[j].horizontal_pos = copyreply->oqual[i].orderqual[j].horizontal_pos
      SET reply->equal[i].pqual[j].vertical_pos = copyreply->oqual[i].orderqual[j].vertical_pos
    ENDFOR
  ENDFOR
 ENDIF
 EXECUTE reportrtl
 CALL _initializereport(0)
 FOR (ecount = 1 TO req_size)
   SET ifieldprinted = 0
   SET orgname = copyreply->oqual[ecount].org_name
   CALL pageheadsection(0)
   SET fieldname = ""
   SET textvalue = ""
   SET barcodevalue = ""
   IF ((copyreply->oqual[ecount].orderqual[10].vertical_pos="1")
    AND (((copyreply->oqual[ecount].orderqual[10].display_value_ind="1")) OR ((copyreply->oqual[
   ecount].orderqual[10].display_barcode_ind="1"))) )
    SET fieldname = copyreply->oqual[ecount].orderqual[10].field_name
    SET ecp_name_col = copyreply->oqual[ecount].orderqual[10].horizontal_pos
    IF ((copyreply->oqual[ecount].orderqual[10].display_value_ind="1"))
     SET textvalue = cover_page_name
    ENDIF
    IF ((copyreply->oqual[ecount].orderqual[10].display_barcode_ind="1"))
     SET barcode = cnvtupper(cover_page_name)
     IF (barcode != null)
      SET barcodevalue = build("*",barcode,"*")
     ENDIF
    ENDIF
    CALL printfield(0,1)
   ELSEIF (nfontsize <= 12
    AND norientation=0)
    CALL printfield(0,1)
   ENDIF
   SET fieldcnt = size(copyreply->oqual[ecount].orderqual,5)
   FOR (i = 1 TO fieldcnt)
     SET fieldname = ""
     SET textvalue = ""
     SET barcodevalue = ""
     IF ((copyreply->oqual[ecount].orderqual[i].cdf_mean != "DOC_NAME"))
      IF ((((copyreply->oqual[ecount].orderqual[i].display_value_ind="1")) OR ((copyreply->oqual[
      ecount].orderqual[i].display_barcode_ind="1"))) )
       SET fieldname = copyreply->oqual[ecount].orderqual[i].field_name
       IF ((copyreply->oqual[ecount].orderqual[i].display_value_ind="1"))
        SET textvalue = copyreply->oqual[ecount].orderqual[i].display_value
       ENDIF
       IF ((copyreply->oqual[ecount].orderqual[i].display_barcode_ind="1"))
        SET barcode = cnvtupper(copyreply->oqual[ecount].orderqual[i].display_barcode_value)
        IF (barcode != null)
         SET barcodevalue = build("*",barcode,"*")
        ENDIF
       ENDIF
      ENDIF
      IF ((((copyreply->oqual[ecount].orderqual[i].cdf_mean="NHIN")) OR ((((copyreply->oqual[ecount].
      orderqual[i].cdf_mean="CMRN")) OR ((copyreply->oqual[ecount].orderqual[i].cdf_mean="VISITID")
      )) )) )
       IF ((((copyreply->oqual[ecount].orderqual[i].display_value_ind="1")) OR ((copyreply->oqual[
       ecount].orderqual[i].display_barcode_ind="1"))) )
        IF (ifieldprinted=0)
         CALL printfield(0,0)
         SET ifieldprinted = 1
        ENDIF
       ENDIF
      ELSE
       CALL printfield(0,0)
      ENDIF
     ENDIF
   ENDFOR
   IF ((copyreply->oqual[ecount].orderqual[10].vertical_pos="2")
    AND (((copyreply->oqual[ecount].orderqual[10].display_value_ind="1")) OR ((copyreply->oqual[
   ecount].orderqual[10].display_barcode_ind="1"))) )
    SET fieldname = copyreply->oqual[ecount].orderqual[10].field_name
    SET ecp_name_col = copyreply->oqual[ecount].orderqual[10].horizontal_pos
    IF ((copyreply->oqual[ecount].orderqual[10].display_value_ind="1"))
     SET textvalue = cover_page_name
    ENDIF
    IF ((copyreply->oqual[ecount].orderqual[10].display_barcode_ind="1"))
     SET barcode = cnvtupper(cover_page_name)
     IF (barcode != null)
      SET barcodevalue = build("*",barcode,"*")
     ENDIF
    ENDIF
    CALL printfield(0,1)
   ENDIF
   IF (ecount != req_size)
    CALL _pagebreak(0)
   ENDIF
 ENDFOR
 SET ecp_filename = concat("CER_PRINT:CDI_ECP",trim(cnvtstring(curtime3)),".DAT")
 CALL _finalizereport(ecp_filename)
 IF (output_dest_cd > 0.0)
  SET sts = printfiletodestcd(output_dest_cd,ecp_filename)
  IF (sts != 1)
   SET failed = true
   SET error_value = build(trim("Failed to print file (Error #"),cnvtstring(sts),trim(")"))
  ENDIF
 ELSE
  SET sts = printfiletoqueue(output_dist,ecp_filename)
  IF (sts != 1)
   SET failed = true
   SET error_value = build(trim("Failed to print file (Error #"),cnvtstring(sts),trim(")"))
  ENDIF
 ENDIF
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF none_found:
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = error_value
   OF select_error:
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reqinfo->commit_ind = false
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = table_name
    SET reply->status_data.subeventstatus[1].targetobjectvalue = error_value
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = error_value
  ENDCASE
 ENDIF
 SUBROUTINE getparsestring(s1,sparsestring)
  CASE (trim(s1))
   OF "ADMIT DATE":
    SET sparsestring = "e.reg_dt_tm"
   OF "CMRN":
    SET sparsestring = "CMRN_Nbr"
   OF "DISCHARGE DATE":
    SET sparsestring = "e.disch_dt_tm"
   OF "ENCOUNTER_ID":
    SET sparsestring = "e.encntr_id"
   OF "FACILITY":
    SET sparsestring = "Facility"
   OF "FIN":
    SET sparsestring = "Fin_Nbr"
   OF "MRN":
    SET sparsestring = "Mrn_Nbr"
   OF "NHIN":
    SET sparsestring = "NHIN_Nbr"
   OF "PATIENT LOC":
    SET sparsestring = "PatLoc"
   OF "PATIENT NAME":
    SET sparsestring = " P.name_full_formatted"
   OF "PERSON_ID":
    SET sparsestring = "P.Person_Id"
   OF "VISITID":
    SET sparsestring = "VisitID_Nbr"
   ELSE
    SET sparsestring = "d.seq"
  ENDCASE
  RETURN
 END ;Subroutine
END GO
