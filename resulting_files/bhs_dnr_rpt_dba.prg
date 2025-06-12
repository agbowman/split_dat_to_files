CREATE PROGRAM bhs_dnr_rpt:dba
 FREE RECORD m_data
 RECORD m_data(
   1 s_name_last = vc
   1 s_name_first = vc
   1 s_name_middle = vc
   1 s_dob = vc
   1 s_sex = vc
   1 s_address = vc
   1 s_city = vc
   1 s_state = vc
   1 s_zip = vc
   1 s_ordering_md = vc
   1 s_order_date = vc
   1 f_nurse_unit_cd = f8
   1 s_print_queue = vc
 ) WITH protect
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = i4 WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"bhscust:ma_dph_seal.jpg")
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
 SUBROUTINE (head_personid_section(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = head_personid_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (head_personid_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 3.990
    SET rptsd->m_height = 0.365
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "MASSACHUSETTS DEPARTMENT OF PUBLIC HEALTH OFFICE OF EMERGENCY MEDICAL SERVICES",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.490
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      'COMFORT CARE / DO NOT RESUSCITATE ("DNR") ORDER VERIFICATION',char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CCFORM 9/2006",char(0)))
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 0.125),(offsety+ 0.500),1.010,
     1.000,1)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 1.750),3.938,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PATIENT'S LAST NAME",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 2.063),3.938,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 2.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PATIENT'S FIRST NAME",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.250),(offsety+ 2.063),3.250,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 2.063)
    SET rptsd->m_x = (offsetx+ 4.313)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PATIENT'S MIDDLE NAME OR INITIAL",
      char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 2.375),3.375,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 2.375)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DATE OF BIRTH (MM/DD/YYYY)",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 1.875),(offsety+ 2.375),0.302,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 2.375)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("GENDER",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 2.813),7.500,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 2.813)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.313
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("STREET OR RESIDENTIAL ADDRESS",char(0
       )))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 3.125),4.750,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.333
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CITY",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.750),(offsety+ 3.125),0.750,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("STATE",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.500),(offsety+ 3.125),2.000,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ZIP CODE (5 OR 9 DIGITS)",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 3.563),3.938,0.313,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 3.875),3.938,0.313,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.250),(offsety+ 3.875),3.250,0.313,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 3.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "LAST NAME OF GUARDIAN OR HEALTH CARE AGENT (If applicable)",char(0)))
    SET rptsd->m_y = (offsety+ 3.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "FIRST NAME OF GUARDIAN OR HEALTH CARE AGENT",char(0)))
    SET rptsd->m_y = (offsety+ 3.875)
    SET rptsd->m_x = (offsetx+ 4.313)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MIDDLE NAME OR INITIAL",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 4.375),7.500,1.375,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 4.375)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.313
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "PATIENT/GUARDIAN/HEALTH CARE AGENT STATEMENT (SIGNATURE AND DATE REQUIRED)",char(0)))
    SET rptsd->m_y = (offsety+ 4.625)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 6.500
    SET rptsd->m_height = 0.563
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "                    I ________________________________________________________________ (      patient        gu",
       "ardian       health care agent) verify that the above named patient has a current and valid Do Not Resuscitate o",
       'rder ("DNR order").  I understand that by signing this form, the DNR order, if current and valid, will be recogn',
       "ized in out-of-hospital settings and the COMFORT CARE / Do Not Resuscitate Order Verification Protocol will be f",
       "ollowed by emergency medical services personnel."),char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.438),(offsety+ 4.625),0.083,0.094,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.938),(offsety+ 4.625),0.083,0.094,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.500),(offsety+ 4.625),0.083,0.094,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 5.568),(offsetx+ 5.313),(offsety+
     5.568))
    SET rptsd->m_y = (offsety+ 5.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Signature of Patient/Guardian/Health Care Agent",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),(offsety+ 5.568),(offsetx+ 6.813),(offsety+
     5.568))
    SET rptsd->m_y = (offsety+ 5.563)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 0.250
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 5.750),7.500,0.125,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 5.875),7.500,3.625,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 5.938)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.313
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "PHYSICIAN / NURSE PRACTICIONER (NP) / PHYSICIAN ASSISTANT (PA) VERIFICATION (PHYSICIAN / NP / PA SIGNATURE AND ",
       "DATES ALWAYS REQUIRED)"),char(0)))
    SET rptsd->m_y = (offsety+ 6.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 6.250
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "I am an attending physician / NP / PA for the above named patient.  I verify that the above named patient has a",
       " current and valid Do Not Resuscitate order, issued on"),char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.750),(offsety+ 6.630),(offsetx+ 2.875),(offsety+
     6.630))
    SET rptsd->m_y = (offsety+ 6.813)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 6.250
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "This DNR order              does              does not     have an expiration date.  If there is an expiration ",
       "date, it is indicated below, and this verification form also expires on that date."),char(0))
     )
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.938),(offsety+ 6.750),0.146,0.156,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 1.563),(offsety+ 6.750),0.146,0.156,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 7.188)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 6.438
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "I hereby direct that all emergency medical services personnel comply with the Massechusetts Department of Publi",
       "c Health, Office of Emergency Medical Services' COMFORT CARE / Do Not Resuscitate Order Verification Protocol wi",
       "th regard to the above named patient."),char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 8.005),(offsetx+ 5.000),(offsety+
     8.005))
    SET rptsd->m_y = (offsety+ 8.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Signature of Physician / NP / PA",
      char(0)))
    SET rptsd->m_y = (offsety+ 8.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Print Name of Physician / NP / PA",
      char(0)))
    SET rptsd->m_y = (offsety+ 8.250)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Effective Date of CC / DNR Order Verification",char(0)))
    SET rptsd->m_y = (offsety+ 8.250)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Expiration Date (if any) of DNR Order and CC/DNR Order Verification",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 8.750),(offsetx+ 3.063),(offsety+
     8.750))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.313),(offsety+ 8.755),(offsetx+ 5.313),(offsety+
     8.755))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.563),(offsety+ 8.755),(offsetx+ 7.501),(offsety+
     8.755))
    SET rptsd->m_y = (offsety+ 8.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Address of Physician / NP / PA",char(
       0)))
    SET rptsd->m_y = (offsety+ 9.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Telephone Number of Physician / NP / PA",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 9.130),(offsetx+ 7.500),(offsety+
     9.130))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 9.500),7.500,0.125,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.875)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 3.625
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_name_last,char(0)))
    SET rptsd->m_y = (offsety+ 2.188)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_name_first,char(0)))
    SET rptsd->m_y = (offsety+ 2.188)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_name_middle,char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 0.198)
    SET rptsd->m_width = 1.479
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_dob,char(0)))
    SET rptsd->m_y = (offsety+ 2.938)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 7.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_address,char(0)))
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_city,char(0)))
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_state,char(0)))
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_zip,char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 2.313)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_sex,char(0)))
    SET rptsd->m_y = (offsety+ 8.500)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_ordering_md,char(0)))
    SET rptsd->m_y = (offsety+ 6.438)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_order_date,char(0)))
    SET rptsd->m_y = (offsety+ 8.563)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(m_data->s_order_date,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_DNR_RPT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SELECT INTO "NL:"
    p_printer_type_cdf = uar_get_code_meaning(p.printer_type_cd)
    FROM output_dest o,
     device d,
     printer p
    PLAN (o
     WHERE cnvtupper(o.name)=cnvtupper(trim(_sendto)))
     JOIN (d
     WHERE d.device_cd=o.device_cd)
     JOIN (p
     WHERE p.device_cd=d.device_cd)
    DETAIL
     CASE (cnvtint(p_printer_type_cdf))
      OF 8:
      OF 26:
      OF 29:
       _outputtype = rpt_postscript,_xdiv = 72,_ydiv = 72
      OF 16:
      OF 20:
      OF 24:
       _outputtype = rpt_zebra,_xdiv = 203,_ydiv = 203
      OF 32:
      OF 18:
      OF 19:
      OF 27:
      OF 31:
       _outputtype = rpt_intermec,_xdiv = 203,_ydiv = 203
      ELSE
       _xdiv = 1,_ydiv = 1
     ENDCASE
     _sendto = d.name
     IF (_xdiv > 1)
      rptreport->m_horzprintoffset = (cnvtreal(o.label_xpos)/ _xdiv)
     ENDIF
     IF (_xdiv > 1)
      rptreport->m_vertprintoffset = (cnvtreal(o.label_ypos)/ _ydiv)
     ENDIF
    WITH nocounter
   ;end select
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
   SET rptfont->m_bold = rpt_on
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
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
 DECLARE mf_dnrnocprbutoktointubate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DNRNOCPRBUTOKTOINTUBATE"))
 DECLARE mf_dnrdninocprnointubation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DNRDNINOCPRNOINTUBATION"))
 DECLARE ms_output = vc WITH protect, noconstant(" ")
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0)
 IF (validate(request->visit,"Z") != "Z")
  SET ms_output = request->output_device
  SET mf_encntr_id = request->visit[1].encntr_id
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ps_name_last = trim(p.name_last), p.person_id, p.name_last
  FROM encounter e,
   person p,
   address a,
   orders o,
   prsnl pr
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd IN (mf_dnrnocprbutoktointubate_cd, mf_dnrdninocprnointubation_cd))
   JOIN (pr
   WHERE pr.person_id=o.last_update_provider_id)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.active_ind=1
    AND a.end_effective_dt_tm > sysdate)
  ORDER BY o.orig_order_dt_tm DESC
  HEAD p.person_id
   m_data->s_name_last = trim(p.name_last), m_data->s_name_first = trim(p.name_first), m_data->
   s_name_middle = trim(p.name_middle),
   m_data->s_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d")), m_data->s_sex = trim(
    uar_get_code_display(p.sex_cd)), m_data->s_address = trim(a.street_addr),
   m_data->s_city = trim(a.city), m_data->s_state = trim(a.state), m_data->s_zip = trim(a.zipcode),
   m_data->s_ordering_md = trim(pr.name_full_formatted), m_data->s_order_date = trim(format(o
     .orig_order_dt_tm,"mm/dd/yyyy;;d")), m_data->f_nurse_unit_cd = e.loc_nurse_unit_cd,
   d0 = head_personid_section(rpt_render)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SET d0 = finalizereport(value(ms_output))
 CALL echorecord(m_data)
#exit_script
END GO
