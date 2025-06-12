CREATE PROGRAM bhs_sch_appt_cnfm_rad_layout
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query1(dummy) = null WITH protect
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
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
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
 DECLARE _times110 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times11b0 = i4 WITH noconstant(0), protect
 DECLARE _pen100s0c15261367 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = h WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_bmp,"bhscust:bhs_logo_cnfm_letter_3a.bmp")
 END ;Subroutine
 SUBROUTINE query1(dummy)
   SELECT
    pat_name = m_rec->qual[d1.seq].s_name, addr1 = m_rec->qual[d1.seq].s_addr_line1, addr2 = m_rec->
    qual[d1.seq].s_addr_line2,
    appt_dt = m_rec->qual[d1.seq].s_dt, appt_type = m_rec->qual[d1.seq].s_appt_type, appt_addr =
    m_rec->qual[d1.seq].s_appt_addr
    FROM (dummyt d1  WITH seq = value(m_rec->l_cnt))
    PLAN (d1)
    HEAD REPORT
     _d0 = pat_name, _d1 = addr1, _d2 = addr2,
     _d3 = appt_dt, _d4 = appt_type, _d5 = appt_addr,
     _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    WITH nocounter, separator = " ", format
   ;end select
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
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   DECLARE __patdear = vc WITH noconstant(build2(concat("Dear ",pat_name,","),char(0))), protect
   IF (ncalc=rpt_render)
    SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_bmp,"bhscust:bhs_logo_cnfm_letter_3a.bmp")
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 1.375),(offsety+ 0.063),4.500,
     0.500,1)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.188
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times110)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(addr1,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.876
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(addr2,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.001)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.365
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patdear)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.188)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.438
    SET rptsd->m_height = 0.750
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "It is our privilege to care for you and we deeply appreciate your partnership and trust as we take all necessar",
       "y steps to ensure safety though out your healthcare experience. For details about our commitments to safety - th",
       "e actions we're taking and what we're asking you to do  - visit BaystateHealth.org. Thank you for scheduling you",
       "r appointment with Baystate Radiology."),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.188)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.209
    SET _dummyfont = uar_rptsetfont(_hreport,_times11b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appointment Date & Time:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.938)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reason for Appointment:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.188)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 2.032
    SET rptsd->m_height = 0.209
    SET _dummyfont = uar_rptsetfont(_hreport,_times110)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(appt_dt,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.938)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 2.032
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(appt_type,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.813)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.438
    SET rptsd->m_height = 0.563
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Please arrive 15 minutes prior to your in-person appointment and come prepared with your photo ID and insurance",
       " cards. Co-payment is due at the time of your appointment.  If you will be late or cannot keep your appointment,",
       " please contact your provider's office.  If needed, we will happily reschedule your appointment to a more conven",
       "ient time.",_crlf,
       _crlf,
       "Visitor exceptions are limited to ONE accompanying parent/guardian for  patients who are 18 years old or younger",
       " or ONE accompanying caregiver for patients with physical and/or cognitive disabilities, and these visitors will",
       " be asked to show a photo ID and will be entered into the visitor log.  Upon appointment arrival, all patients a",
       "nd permitted accompanying parent/guardian/caregiver must wear a mask, complete a temperature screening and sanit",
       "ize hands.  A mask will be provided if needed. ",_crlf,_crlf,
       "If you will be late or cannot keep your appointment, please contact your provider's office.  If needed, we will ",
       "happily reschedule your appointment to a more convenient time."),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.876)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.438
    SET rptsd->m_height = 1.063
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat("Sincerely,",_crlf,
       "Your Baystate Health Team",_crlf,_crlf,
       "Please use your MyBaystate portal account to manage and access your health information and to communicate online",
       " with your providers.  To sign up for MyBaystate, please visit BaystateHealth.org  or download the app to your ",
       "mobile device."),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen100s0c15261367)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.615),(offsety+ 6.063),(offsetx+ 3.615),(offsety+
     8.813))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.501
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("What We Are Doing",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 3.751
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("What We Ask You To Do",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.188
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Cleaning",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.188
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.500
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Rigorously and continuously cleaning our facilities using disinfecting solutions to eliminate the spread of COV",
       "ID-19.",_crlf,"Maintaining our strict hand hygiene protocols."),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.563)
    SET rptsd->m_x = (offsetx+ 3.667)
    SET rptsd->m_width = 3.803
    SET rptsd->m_height = 0.376
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
"Follow hand hygiene guidelines, including using the convenient hand sanitizing stations we provide throughout our faciliti\
es.\
",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Screening",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.063)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.188
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.501
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Screening all patients and staff upon entry to our facilities.",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.250)
    SET rptsd->m_x = (offsetx+ 3.667)
    SET rptsd->m_width = 3.803
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Call your provider before coming to an appointment or procedure if you are feeling sick.",char
      (0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Masks",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.563)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.188
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Requiring masks for our providers and patients.",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.750)
    SET rptsd->m_x = (offsetx+ 3.667)
    SET rptsd->m_width = 3.803
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Wear a mask. We will give you a mask when you arrive or you can bring your own. ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Social Distancing ",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.063)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.188
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.251)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.313
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Redesigned waiting and care areas in support of social distancing.",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.251)
    SET rptsd->m_x = (offsetx+ 3.667)
    SET rptsd->m_width = 3.803
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Adhere to our notices and signs for safe distancing.",_crlf,"Comply with our visitor policy."
       ),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.563)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.188
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(183,222,232))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.188
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times110)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pat_name,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.438)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.209
    SET _dummyfont = uar_rptsetfont(_hreport,_times11b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appointment Location:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.438)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.376
    SET _dummyfont = uar_rptsetfont(_hreport,_times110)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(appt_addr,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.438
    SET rptsd->m_height = 0.938
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Visitor exceptions are limited to ONE accompanying parent/guardian for  patients who are 18 years old or younge",
       "r or ONE accompanying caregiver for patients with physical and/or cognitive disabilities, and these visitors wil",
       "l be asked to show a photo ID and will be entered into the visitor log.  Upon appointment arrival, all patients ",
       "and permitted accompanying parent/guardian/caregiver must wear a mask, complete a temperature screening and sani",
       "tize hands.  A mask will be provided if needed. ",
       _crlf,_crlf,
       "If you will be late or cannot keep your appointment, please contact your provider's office.  If needed, we will ",
       "happily reschedule your appointment to a more convenient time."),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.438)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.438
    SET rptsd->m_height = 0.376
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "If you will be late or cannot keep your appointment, please call 413-794-2222. If needed, we will happily resch",
       "edule your appointment to a more convenient time."),char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_SCH_APPT_CNFM_RAD_LAYOUT"
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
   SET rptfont->m_pointsize = 11
   SET _times110 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times11b0 = uar_rptcreatefont(_hreport,rptfont)
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
   SET rptpen->m_penwidth = 0.100
   SET rptpen->m_rgbcolor = uar_rptencodecolor(183,222,232)
   SET _pen100s0c15261367 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET _sendto = request->file_name
 DECLARE mf_name_format = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs213_current_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"CURRENT"))
 DECLARE mf_cs212_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_name = vc
     2 s_dt = vc
     2 s_addr_line1 = vc
     2 s_addr_line2 = vc
     2 s_appt_type = vc
     2 s_appt_addr = vc
 ) WITH protect
 FREE SET t_record
 RECORD t_record(
   1 t_ind = i4
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 person_id = f8
 )
 SET t_record->t_ind = (findstring(" = ", $4,1)+ 3)
 SET t_record->person_id = cnvtreal(substring(t_record->t_ind,((size(trim( $4)) - t_record->t_ind)+ 1
   ), $4))
 SET t_record->t_ind = (findstring(char(34), $3,1)+ 1)
 SET t_record->beg_dt_tm = cnvtdatetime(substring(t_record->t_ind,23, $3))
 SET t_record->t_ind = (findstring(char(34), $2,1)+ 1)
 SET t_record->end_dt_tm = cnvtdatetime(substring(t_record->t_ind,23, $2))
 SELECT INTO "nl:"
  sp.pref_value
  FROM sch_pref sp
  WHERE sp.pref_type_meaning="SHNMFULLFRMT"
   AND sp.active_ind=1
   AND sp.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND sp.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   mf_name_format = sp.pref_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person r,
   sch_appt a,
   sch_event se,
   person_name pn,
   code_value cv,
   address ad,
   address ad2
  PLAN (r
   WHERE (r.person_id=t_record->person_id))
   JOIN (a
   WHERE cnvtdatetime(t_record->end_dt_tm) > a.beg_dt_tm
    AND cnvtdatetime(t_record->beg_dt_tm) < a.end_dt_tm
    AND a.person_id=r.person_id
    AND a.state_meaning="CONFIRMED"
    AND a.role_meaning="PATIENT"
    AND a.active_ind=1
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pn
   WHERE pn.person_id=r.person_id
    AND pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pn.active_ind=1
    AND pn.name_type_cd=mf_cs213_current_cd
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (se
   WHERE se.sch_event_id=a.sch_event_id
    AND se.active_ind=1)
   JOIN (cv
   WHERE (cv.code_value= Outerjoin(a.appt_location_cd)) )
   JOIN (ad
   WHERE (ad.parent_entity_name= Outerjoin("LOCATION"))
    AND (ad.parent_entity_id= Outerjoin(cv.code_value))
    AND (ad.active_ind= Outerjoin(1)) )
   JOIN (ad2
   WHERE (ad2.parent_entity_name= Outerjoin("PERSON"))
    AND (ad2.parent_entity_id= Outerjoin(r.person_id))
    AND (ad2.address_type_cd= Outerjoin(mf_cs212_home_cd))
    AND (ad2.active_ind= Outerjoin(1))
    AND (ad2.address_type_seq= Outerjoin(1)) )
  ORDER BY cnvtdatetime(a.beg_dt_tm)
  DETAIL
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt)
   IF (mf_name_format > 0.0)
    m_rec->qual[m_rec->l_cnt].s_name = trim(r.name_full_formatted,3)
   ELSE
    m_rec->qual[m_rec->l_cnt].s_name = trim(pn.name_prefix,3)
    IF (trim(r.name_first,3) > "")
     IF (trim(pn.name_prefix,3) > "")
      m_rec->qual[m_rec->l_cnt].s_name = concat(m_rec->qual[m_rec->l_cnt].s_name," ",trim(r
        .name_first,3))
     ELSE
      m_rec->qual[m_rec->l_cnt].s_name = concat(m_rec->qual[m_rec->l_cnt].s_name,trim(r.name_first,3)
       )
     ENDIF
    ENDIF
    IF (trim(r.name_last,3) > "")
     m_rec->qual[m_rec->l_cnt].s_name = concat(m_rec->qual[m_rec->l_cnt].s_name," ",trim(r.name_last,
       3))
    ENDIF
    IF (trim(pn.name_suffix,3) > "")
     m_rec->qual[m_rec->l_cnt].s_name = concat(trim(m_rec->qual[m_rec->l_cnt].s_name,3)," ",trim(pn
       .name_suffix,3))
    ENDIF
    IF (trim(pn.name_title,3) > "")
     m_rec->qual[m_rec->l_cnt].s_name = concat(trim(m_rec->qual[m_rec->l_cnt].s_name,3)," ",trim(pn
       .name_title,3))
    ENDIF
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_dt = concat(trim(format(a.beg_dt_tm,"@WEEKDAYNAME"),3)," ",trim(format
     (a.beg_dt_tm,"MM/DD/YYYY;;d"),2),"  ",cnvtupper(format(a.beg_dt_tm,"hh:mm;;s"))), m_rec->qual[
   m_rec->l_cnt].s_addr_line1 = trim(ad2.street_addr,3), m_rec->qual[m_rec->l_cnt].s_addr_line2 =
   concat(trim(ad2.city,3),", ",trim(ad2.state,3)," ",trim(ad2.zipcode,3)),
   m_rec->qual[m_rec->l_cnt].s_appt_type = trim(uar_get_code_display(se.appt_type_cd),3)
   IF (size(trim(ad.street_addr,3)) > 0)
    m_rec->qual[m_rec->l_cnt].s_appt_addr = trim(ad.street_addr,3)
   ENDIF
   IF (size(trim(ad.street_addr2,3)) > 0)
    m_rec->qual[m_rec->l_cnt].s_appt_addr = concat(m_rec->qual[m_rec->l_cnt].s_appt_addr,", ",trim(ad
      .street_addr2,3))
   ENDIF
   IF (size(trim(ad.street_addr3,3)) > 0)
    m_rec->qual[m_rec->l_cnt].s_appt_addr = concat(m_rec->qual[m_rec->l_cnt].s_appt_addr,", ",trim(ad
      .street_addr3,3))
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_appt_addr = concat(m_rec->qual[m_rec->l_cnt].s_appt_addr,", ",trim(ad
     .city,3),", ",trim(ad.state,3),
    " ",trim(ad.zipcode,3))
  WITH nocounter
 ;end select
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 IF ((m_rec->l_cnt=0))
  GO TO exit_script
 ENDIF
 SET _fholdenddetail = _fenddetail
 CALL query1(0)
 SET _fenddetail = _fholdenddetail
#exit_script
 CALL finalizereport(_sendto)
END GO
