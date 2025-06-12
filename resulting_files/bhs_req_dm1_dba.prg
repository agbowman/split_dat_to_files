CREATE PROGRAM bhs_req_dm1:dba
 IF (validate(request->person_id)=0)
  RECORD request(
    1 person_id = f8
    1 print_prsnl_id = f8
    1 order_qual[*]
      2 order_id = f8
      2 encntr_id = f8
      2 conversation_id = f8
    1 printer_name = c50
  )
 ENDIF
 FREE RECORD rec_str
 RECORD rec_str(
   1 s_patient[*]
     2 s_patient_name = vc
     2 f_patient_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 s_date_of_birth = vc
     2 s_sex = vc
     2 s_pat_add_line_1 = vc
     2 s_pat_add_line_2 = vc
     2 s_pat_phone_home = vc
     2 s_pat_phone_cell = vc
     2 s_pat_phone = vc
     2 pat_phone[*]
       3 s_pat_ph_no = vc
     2 f_encntr_id = f8
     2 f_loc_building_cd = f8
     2 s_dept_add_line_1 = vc
     2 s_dept_add_line_2 = vc
     2 s_dept_ph_no = vc
     2 s_department_name = vc
     2 s_insurance_plan = vc
     2 s_insurance_group = vc
     2 s_insurance_id = vc
     2 s_insurance_subsc = vc
     2 f_order_id = f8
     2 s_order_item = vc
     2 s_order_diagnosis = vc
     2 s_order_laterality = vc
     2 s_order_lngth_need = vc
     2 s_order_refills = vc
     2 s_phy_ordered_by = vc
     2 f_phy_ordered_id = f8
     2 s_phy_npi = vc
     2 s_signature_dt = vc
 ) WITH protect
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
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
 DECLARE _times16bu0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = h WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"bhscust:bhs_logo_3.jpg")
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
   DECLARE sectionheight = f8 WITH noconstant(9.500000), private
   DECLARE __s_department_name = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_department_name,char(0))), protect
   DECLARE __s_dept_add_line_1 = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_dept_add_line_1,char(0))), protect
   DECLARE __s_dept_add_line_2 = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_dept_add_line_2,char(0))), protect
   DECLARE __s_dept_ph_no = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].s_dept_ph_no,
     char(0))), protect
   DECLARE __s_patient_name = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_patient_name,char(0))), protect
   DECLARE __s_pat_add_line_1 = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_pat_add_line_1,char(0))), protect
   DECLARE __s_pat_add_line_2 = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_pat_add_line_2,char(0))), protect
   DECLARE __s_mrn = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].s_mrn,char(0))),
   protect
   DECLARE __s_date_of_birth = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_date_of_birth,char(0))), protect
   DECLARE __s_sex = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].s_sex,char(0))),
   protect
   DECLARE __s_insurance_plan = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_insurance_plan,char(0))), protect
   DECLARE __s_insurance_group = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_insurance_group,char(0))), protect
   DECLARE __s_insurance_id = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_insurance_id,char(0))), protect
   DECLARE __s_insurance_subsc = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_insurance_subsc,char(0))), protect
   DECLARE __s_order_item = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].s_order_item,
     char(0))), protect
   DECLARE __s_order_diagnosis = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_order_diagnosis,char(0))), protect
   DECLARE __s_order_lngth_need = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_order_lngth_need,char(0))), protect
   DECLARE __s_order_refills = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_order_refills,char(0))), protect
   DECLARE __s_phy_ordered_by = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_phy_ordered_by,char(0))), protect
   DECLARE __s_signature_dt = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_signature_dt,char(0))), protect
   DECLARE __s_phy_npi = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].s_phy_npi,char(0)
     )), protect
   DECLARE __s_pat_phone_cell = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_pat_phone_cell,char(0))), protect
   DECLARE __s_pat_phone_home = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].
     s_pat_phone_home,char(0))), protect
   DECLARE __s_fin = vc WITH noconstant(build2(rec_str->s_patient[ml_order_cnt].s_fin,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_department_name)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_dept_add_line_1)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_dept_add_line_2)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_dept_ph_no)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Date: ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.188)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.001)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.188)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curtime,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.563)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _dummyfont = uar_rptsetfont(_hreport,_times16bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.876)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.313
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_patient_name)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.126)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.313
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_pat_add_line_1)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.376)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.438
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_pat_add_line_2)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.876)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.376)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB: ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.563)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sex: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.876)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_mrn)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.376)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_date_of_birth)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.563)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_sex)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.375)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _dummyfont = uar_rptsetfont(_hreport,_times16bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Insurance",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.688)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Plan: ",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.875)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Group# ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.063)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ID# ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.250)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Subscriber# ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.688)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_insurance_plan)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.875)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_insurance_group)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.063)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_insurance_id)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.250)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_insurance_subsc)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.813)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _dummyfont = uar_rptsetfont(_hreport,_times16bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Item: ",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.313)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diagnosis: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_order_item)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.313)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_order_diagnosis)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.813)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.313
    SET _dummyfont = uar_rptsetfont(_hreport,_times16bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Details",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.125)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Length Needed: ",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.313)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Refills: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.125)
    SET rptsd->m_x = (offsetx+ 1.626)
    SET rptsd->m_width = 5.875
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_order_lngth_need)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.313)
    SET rptsd->m_x = (offsetx+ 1.626)
    SET rptsd->m_width = 5.875
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_order_refills)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.751)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering Provider:",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Signature Date: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.751)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_phy_ordered_by)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.001)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_signature_dt)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.751)
    SET rptsd->m_x = (offsetx+ 4.063)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NPI: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.751)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 3.001
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_phy_npi)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.626)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Tel (Cell): ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.626)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 2.761
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_pat_phone_cell)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.876)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Tel (Home): ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.876)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 2.761
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_pat_phone_home)
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 2.063),(offsety+ 0.063),3.501,
     0.625,1)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.126)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FIN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.126)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_fin)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.501)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Electronically Signed By:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_REQ_DM1"
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
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET rptfont->m_underline = rpt_on
   SET _times16bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
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
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_fin_nbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"NPI"))
 DECLARE mf_specialinstructions_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SPECIALINSTRUCTIONS"))
 DECLARE mf_refill_quantity_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "REFILL QUANTITY"))
 DECLARE mf_diagnosisdme_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "DIAGNOSISDME"))
 DECLARE mf_cell_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"CELL"))
 DECLARE mf_home_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"HOME"))
 DECLARE mf_home_address_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",212,"HOME"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "DISCONTINUED"))
 DECLARE ml_order_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_phone_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(request->order_qual,5))),
   orders o,
   encounter e,
   person p,
   order_detail od,
   order_action oa,
   prsnl pr
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence
    AND ((cnvtlookbehind("30,s") <= oa.action_dt_tm
    AND oa.dept_status_cd IN (
   (SELECT DISTINCT
    cve.code_value
    FROM code_value_extension cve
    WHERE cve.code_set=14281
     AND cve.field_name="REQ_PRINT_FLG"
     AND substring(9,1,cve.field_value)="Y"))) OR (cnvtlookbehind("30,s") > oa.action_dt_tm
    AND oa.dept_status_cd > 0)) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (od
   WHERE od.order_id=o.order_id)
   JOIN (pr
   WHERE pr.person_id=o.last_update_provider_id)
  ORDER BY o.order_id, od.oe_field_id
  HEAD REPORT
   ml_order_cnt = 0
  HEAD o.order_id
   ml_order_cnt += 1, stat = alterlist(rec_str->s_patient,ml_order_cnt), rec_str->s_patient[
   ml_order_cnt].s_patient_name = p.name_full_formatted,
   rec_str->s_patient[ml_order_cnt].s_date_of_birth = format(p.birth_dt_tm,"MM/DD/YYYY;;q"), rec_str
   ->s_patient[ml_order_cnt].s_sex = uar_get_code_display(p.sex_cd), rec_str->s_patient[ml_order_cnt]
   .f_patient_id = p.person_id,
   rec_str->s_patient[ml_order_cnt].f_encntr_id = e.encntr_id, rec_str->s_patient[ml_order_cnt].
   f_loc_building_cd = e.loc_building_cd, rec_str->s_patient[ml_order_cnt].s_department_name =
   uar_get_code_description(e.loc_building_cd),
   rec_str->s_patient[ml_order_cnt].f_order_id = o.order_id, rec_str->s_patient[ml_order_cnt].
   s_order_item = uar_get_code_display(o.catalog_cd), rec_str->s_patient[ml_order_cnt].
   f_phy_ordered_id = pr.person_id,
   rec_str->s_patient[ml_order_cnt].s_phy_ordered_by = pr.name_full_formatted, rec_str->s_patient[
   ml_order_cnt].s_phy_npi = "-NA-", rec_str->s_patient[ml_order_cnt].s_signature_dt = format(o
    .orig_order_dt_tm,"MM/DD/YYYY ;;q")
  HEAD od.oe_field_id
   IF (od.oe_field_id=mf_specialinstructions_cd)
    rec_str->s_patient[ml_order_cnt].s_order_lngth_need = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_id=mf_refill_quantity_cd)
    rec_str->s_patient[ml_order_cnt].s_order_refills = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_id=mf_diagnosisdme_cd)
    rec_str->s_patient[ml_order_cnt].s_order_diagnosis = od.oe_field_display_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->s_patient,5))),
   encntr_alias ea
  PLAN (d1)
   JOIN (ea
   WHERE (ea.encntr_id=rec_str->s_patient[d1.seq].f_encntr_id)
    AND ea.encntr_alias_type_cd=mf_fin_nbr_cd)
  DETAIL
   rec_str->s_patient[d1.seq].s_fin = trim(ea.alias)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->s_patient,5))),
   encntr_alias ea
  PLAN (d1)
   JOIN (ea
   WHERE (ea.encntr_id=rec_str->s_patient[d1.seq].f_encntr_id)
    AND ea.encntr_alias_type_cd=mf_mrn_cd)
  DETAIL
   rec_str->s_patient[d1.seq].s_mrn = trim(ea.alias)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->s_patient,5))),
   address a
  PLAN (d1)
   JOIN (a
   WHERE (a.parent_entity_id=rec_str->s_patient[d1.seq].f_patient_id)
    AND a.address_type_cd=mf_home_address_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND a.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  DETAIL
   rec_str->s_patient[d1.seq].s_pat_add_line_1 = a.street_addr, rec_str->s_patient[d1.seq].
   s_pat_add_line_2 = build(a.city,",",a.state,",",a.zipcode)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  f_order_id = rec_str->s_patient[d1.seq].f_order_id
  FROM (dummyt d1  WITH seq = value(size(rec_str->s_patient,5))),
   phone p
  PLAN (d1)
   JOIN (p
   WHERE (p.parent_entity_id=rec_str->s_patient[d1.seq].f_patient_id)
    AND p.phone_type_cd IN (mf_cell_cd, mf_home_cd)
    AND p.parent_entity_name="PERSON"
    AND p.active_ind=1)
  HEAD f_order_id
   ml_phone_cnt = 0
  HEAD p.phone_id
   ml_phone_cnt += 1, stat = alterlist(rec_str->s_patient[d1.seq].pat_phone,ml_phone_cnt), rec_str->
   s_patient[d1.seq].pat_phone[ml_phone_cnt].s_pat_ph_no = concat(trim(uar_get_code_display(p
      .phone_type_cd)),": ",p.phone_num)
   IF (ml_phone_cnt=1)
    rec_str->s_patient[d1.seq].s_pat_phone = concat(rec_str->s_patient[d1.seq].s_pat_phone,rec_str->
     s_patient[d1.seq].pat_phone[ml_phone_cnt].s_pat_ph_no)
   ELSE
    rec_str->s_patient[d1.seq].s_pat_phone = concat(rec_str->s_patient[d1.seq].s_pat_phone,", ",
     rec_str->s_patient[d1.seq].pat_phone[ml_phone_cnt].s_pat_ph_no)
   ENDIF
   IF (p.phone_type_cd=mf_cell_cd)
    rec_str->s_patient[d1.seq].s_pat_phone_cell = trim(cnvtphone(p.phone_num,p.phone_format_cd))
   ELSEIF (p.phone_type_cd=mf_home_cd)
    rec_str->s_patient[d1.seq].s_pat_phone_home = trim(cnvtphone(p.phone_num,p.phone_format_cd))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->s_patient,5))),
   location l,
   address a
  PLAN (d1)
   JOIN (l
   WHERE (l.location_cd=rec_str->s_patient[d1.seq].f_loc_building_cd))
   JOIN (a
   WHERE a.parent_entity_id=l.organization_id
    AND a.parent_entity_name="ORGANIZATION"
    AND a.active_ind=1)
  DETAIL
   rec_str->s_patient[d1.seq].s_dept_add_line_1 = a.street_addr, rec_str->s_patient[d1.seq].
   s_dept_add_line_2 = build(a.city,",",a.state,",",a.zipcode)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->s_patient,5))),
   location l,
   phone p
  PLAN (d1)
   JOIN (l
   WHERE (l.location_cd=rec_str->s_patient[d1.seq].f_loc_building_cd))
   JOIN (p
   WHERE p.parent_entity_id=l.organization_id
    AND p.parent_entity_name="ORGANIZATION"
    AND p.active_ind=1)
  DETAIL
   rec_str->s_patient[d1.seq].s_dept_ph_no = concat("Phone: ",trim(cnvtphone(p.phone_num,p
      .phone_format_cd)))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->s_patient,5))),
   encntr_plan_reltn epr,
   health_plan hp,
   person p
  PLAN (d1)
   JOIN (epr
   WHERE (epr.encntr_id=rec_str->s_patient[d1.seq].f_encntr_id))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id)
   JOIN (p
   WHERE p.person_id=epr.person_id)
  DETAIL
   rec_str->s_patient[d1.seq].s_insurance_group = epr.group_nbr, rec_str->s_patient[d1.seq].
   s_insurance_id = epr.member_nbr, rec_str->s_patient[d1.seq].s_insurance_plan = build(hp.plan_name,
    " - ",uar_get_code_display(epr.plan_type_cd)),
   rec_str->s_patient[d1.seq].s_insurance_subsc = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->s_patient,5))),
   prsnl_alias pa
  PLAN (d1)
   JOIN (pa
   WHERE (pa.person_id=rec_str->s_patient[d1.seq].f_phy_ordered_id)
    AND pa.prsnl_alias_type_cd=mf_npi_cd
    AND pa.active_ind=1)
  DETAIL
   rec_str->s_patient[d1.seq].s_phy_npi = pa.alias
  WITH nocounter
 ;end select
 CALL echorecord(rec_str)
 SET ml_order_cnt = 0
 SET ml_phone_cnt = 0
 IF (size(rec_str->s_patient,5) > 0)
  FOR (ml_order_cnt = 1 TO size(rec_str->s_patient,5))
   SET d0 = detailsection(rpt_render)
   IF (ml_order_cnt < size(rec_str->s_patient,5))
    SET d0 = pagebreak(0)
   ENDIF
  ENDFOR
  SET d0 = finalizereport(request->printer_name)
 ENDIF
#exit_script
 FREE RECORD request
 FREE RECORD rec_str
END GO
