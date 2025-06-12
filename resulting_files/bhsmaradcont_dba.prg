CREATE PROGRAM bhsmaradcont:dba
 CALL echo("*****START OF ACCESSION SUBROUTINE *****")
 DECLARE formataccession(c2) = c11
 SUBROUTINE formataccession(acc_string)
   SET return_string = fillstring(25," ")
   SET return_string = uar_fmt_accession(acc_string,size(acc_string,1))
   RETURN(return_string)
 END ;Subroutine
 SET req_ndx = value( $1)
 SET sect_ndx = value( $2)
 SET print_sub = value( $3)
 DECLARE completedate = vc WITH noconstant(" ")
 DECLARE mednbr = vc WITH noconstant(" ")
 EXECUTE reportrtl
 CALL echo("*****START OF MODIFY SELECT*****")
 DECLARE modify_flag = i4 WITH public, noconstant(0)
 DECLARE modify_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",6003,"MODIFY"))
 SELECT INTO "nl: "
  oa.action_type_cd
  FROM order_action oa
  WHERE (oa.order_id=data->req[req_ndx].sections[sect_ndx].exam_data[1].for_this_page[1].order_id)
  ORDER BY oa.action_sequence DESC
  DETAIL
   IF (oa.action_type_cd=modify_type_cd)
    modify_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("****************START OF ADDRESS RECORD********************")
 FREE RECORD a_facility
 RECORD a_facility(
   1 facility_name = vc
   1 inst_name = vc
   1 sect_disp = vc
   1 dept_name = vc
   1 dept_desc = vc
   1 address = vc
   1 city = vc
   1 state = vc
   1 zip = vc
 )
 CALL echo("****************START OF EXAM RECORD********************")
 FREE RECORD a_exam
 RECORD a_exam(
   1 accession = c20
   1 bc_acc_nbr = c22
   1 exam_name_1 = vc
   1 order_date_1 = dq8
   1 order_time_1 = dq8
   1 rqst_date_1 = dq8
   1 rqst_time_1 = dq8
   1 start_date_1 = dq8
   1 start_time_1 = dq8
   1 exam_section_1 = vc
   1 reason_for_exam_1 = vc
   1 special_instr_1 = vc
   1 comments_1 = vc
   1 priority_1 = vc
   1 transport_mode_1 = vc
   1 order_by_id_1 = c20
   1 order_by_name_1 = vc
   1 order_by_user_name_1 = vc
   1 exam_room_1 = vc
   1 order_location_1 = vc
   1 order_loc_phone_1 = vc
   1 exam_name_2 = vc
   1 order_date_2 = dq8
   1 order_time_2 = dq8
   1 rqst_date_2 = dq8
   1 rqst_time_2 = dq8
   1 start_date_2 = dq8
   1 start_time_2 = dq8
   1 exam_section_2 = vc
   1 reason_for_exam_2 = vc
   1 special_instr_2 = vc
   1 priority_2 = vc
   1 transport_mode_2 = vc
   1 order_by_id_2 = c20
   1 order_by_name_2 = vc
   1 order_by_user_name_2 = vc
   1 exam_room_2 = vc
   1 order_location_2 = vc
   1 order_loc_phone_2 = vc
   1 exam_name_3 = vc
   1 order_date_3 = dq8
   1 order_time_3 = dq8
   1 rqst_date_3 = dq8
   1 rqst_time_3 = dq8
   1 start_date_3 = dq8
   1 start_time_3 = dq8
   1 exam_section_3 = vc
   1 reason_for_exam_3 = vc
   1 special_instr_3 = vc
   1 priority_3 = vc
   1 transport_mode_3 = vc
   1 order_by_id_3 = c20
   1 order_by_name_3 = vc
   1 order_by_user_name_3 = vc
   1 exam_room_3 = vc
   1 order_location_3 = vc
   1 order_loc_phone_3 = vc
   1 exam_name_4 = vc
   1 order_date_4 = dq8
   1 order_time_4 = dq8
   1 rqst_date_4 = dq8
   1 rqst_time_4 = dq8
   1 start_date_4 = dq8
   1 start_time_4 = dq8
   1 reason_for_exam_4 = vc
   1 special_instr_4 = vc
   1 exam_section_4 = vc
   1 priority_4 = vc
   1 transport_mode_4 = vc
   1 order_by_id_4 = c20
   1 order_by_name_4 = vc
   1 order_by_user_name_4 = vc
   1 exam_room_4 = vc
   1 order_location_4 = vc
   1 order_loc_phone_4 = vc
   1 exam_name_5 = vc
   1 order_date_5 = dq8
   1 order_time_5 = dq8
   1 rqst_date_5 = dq8
   1 rqst_time_5 = dq8
   1 start_date_5 = dq8
   1 start_time_5 = dq8
   1 exam_section_5 = vc
   1 reason_for_exam_5 = vc
   1 special_instr_5 = vc
   1 priority_5 = vc
   1 transport_mode_5 = vc
   1 order_by_id_5 = c20
   1 order_by_name_5 = vc
   1 order_by_user_name_5 = vc
   1 exam_room_5 = vc
   1 order_location_5 = vc
   1 order_loc_phone_5 = vc
   1 exam_name_6 = vc
   1 order_date_6 = dq8
   1 order_time_6 = dq8
   1 rqst_date_6 = dq8
   1 rqst_time_6 = dq8
   1 start_date_6 = dq8
   1 start_time_6 = dq8
   1 exam_section_6 = vc
   1 reason_for_exam_6 = vc
   1 special_instr_6 = vc
   1 priority_6 = vc
   1 transport_mode_6 = vc
   1 order_by_id_6 = c20
   1 order_by_name_6 = vc
   1 order_by_user_name_6 = vc
   1 exam_room_6 = vc
   1 order_location_6 = vc
   1 order_loc_phone_6 = vc
   1 exam_name_7 = vc
   1 order_date_7 = dq8
   1 order_time_7 = dq8
   1 rqst_date_7 = dq8
   1 rqst_time_7 = dq8
   1 start_date_7 = dq8
   1 start_time_7 = dq8
   1 exam_section_7 = vc
   1 reason_for_exam_7 = vc
   1 special_instr_7 = vc
   1 priority_7 = vc
   1 transport_mode_7 = vc
   1 order_by_id_7 = c20
   1 order_by_name_7 = vc
   1 order_by_user_name_7 = vc
   1 exam_room_7 = vc
   1 order_location_7 = vc
   1 order_loc_phone_7 = vc
   1 exam_name_8 = vc
   1 order_date_8 = dq8
   1 order_time_8 = dq8
   1 rqst_date_8 = dq8
   1 rqst_time_8 = dq8
   1 start_date_8 = dq8
   1 start_time_8 = dq8
   1 exam_section_8 = vc
   1 reason_for_exam_8 = vc
   1 special_instr_8 = vc
   1 priority_8 = vc
   1 transport_mode_8 = vc
   1 order_by_id_8 = c20
   1 order_by_name_8 = vc
   1 order_by_user_name_8 = vc
   1 exam_room_8 = vc
   1 order_location_8 = vc
   1 order_loc_phone_8 = vc
   1 exam_name_9 = vc
   1 order_date_9 = dq8
   1 order_time_9 = dq8
   1 rqst_date_9 = dq8
   1 rqst_time_9 = dq8
   1 start_date_9 = dq8
   1 start_time_9 = dq8
   1 exam_section_9 = vc
   1 reason_for_exam_9 = vc
   1 special_instr_9 = vc
   1 priority_9 = vc
   1 transport_mode_9 = vc
   1 order_by_id_9 = c20
   1 order_by_name_9 = vc
   1 order_by_user_name_9 = vc
   1 exam_room_9 = vc
   1 order_location_9 = vc
   1 order_loc_phone_9 = vc
   1 exam_name_10 = vc
   1 order_date_10 = dq8
   1 order_time_10 = dq8
   1 rqst_date_10 = dq8
   1 rqst_time_10 = dq8
   1 start_date_10 = dq8
   1 start_time_10 = dq8
   1 exam_section_10 = vc
   1 reason_for_exam_10 = vc
   1 special_instr_10 = vc
   1 priority_10 = vc
   1 transport_mode_10 = vc
   1 order_by_id_10 = c20
   1 order_by_name_10 = vc
   1 order_by_user_name_10 = vc
   1 exam_room_10 = vc
   1 order_location_10 = vc
   1 order_loc_phone_10 = vc
 )
 CALL echo("*****START OF MODIFY/REPRINT RECORD*****")
 FREE RECORD a_mod
 RECORD a_mod(
   1 status = c8
   1 reprint = c7
 )
 CALL echo("*****START OF PATIENT RECORD*****")
 FREE RECORD a_pat_data
 RECORD a_pat_data(
   1 person_id = f8
   1 full_name = vc
   1 last_name = vc
   1 first_name = vc
   1 mid_name = vc
   1 dob = dq8
   1 age = vc
   1 short_age = c10
   1 gender = vc
   1 short_gender = c10
   1 race = vc
   1 encounter_id = f8
   1 location = vc
   1 pat_type = vc
   1 arrival_date = dq8
   1 facility = vc
   1 building = vc
   1 nurse_unit = vc
   1 nurse_unit_phone = vc
   1 room = c10
   1 bed = c10
   1 admitting_diag = vc
   1 isolation = vc
   1 med_service = vc
   1 fin_class = vc
   1 client = vc
   1 ssn = vc
   1 cmrn = vc
   1 med_nbr = vc
   1 bc_med_nbr = vc
   1 fin_nbr = vc
   1 bc_fin_nbr = vc
   1 home_phone = vc
   1 work_phone = vc
   1 address = vc
   1 city = vc
   1 state = vc
   1 zip = c12
 )
 CALL echo("*****START OF PHYSICIAN RECORD*****")
 FREE RECORD a_doc
 RECORD a_doc(
   1 admit_doc_name = vc
   1 admit_doc_phone = vc
   1 admit_doc_pager = vc
   1 admit_doc_fax = vc
   1 refer_doc_name = vc
   1 refer_doc_phone = vc
   1 refer_doc_pager = vc
   1 refer_doc_fax = vc
   1 order_doc_name = vc
   1 order_doc_phone = vc
   1 order_doc_pager = vc
   1 order_doc_fax = vc
   1 attend_doc_name = vc
   1 attend_doc_phone = vc
   1 attend_doc_pager = vc
   1 attend_doc_fax = vc
   1 family_doc_name = vc
   1 family_doc_phone = vc
   1 family_doc_pager = vc
   1 family_doc_fax = vc
   1 consult_doc_name_1 = vc
   1 consult_doc_phone_1 = vc
   1 consult_doc_pager_1 = vc
   1 consult_doc_fax_1 = vc
   1 consult_doc_name_2 = vc
   1 consult_doc_phone_2 = vc
   1 consult_doc_pager_2 = vc
   1 consult_doc_fax_2 = vc
   1 consult_doc_name_3 = vc
   1 consult_doc_phone_3 = vc
   1 consult_doc_pager_3 = vc
   1 consult_doc_fax_3 = vc
   1 consult_doc_name_4 = vc
   1 consult_doc_phone_4 = vc
   1 consult_doc_pager_4 = vc
   1 consult_doc_fax_4 = vc
   1 consult_doc_name_5 = vc
   1 consult_doc_phone_5 = vc
   1 consult_doc_pager_5 = vc
   1 consult_doc_fax_5 = vc
   1 consult_doc_name_6 = vc
   1 consult_doc_phone_6 = vc
   1 consult_doc_pager_6 = vc
   1 consult_doc_fax_6 = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE layoutsection0(ncalc=i2) = f8 WITH protect
 DECLARE layoutsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _diotype = i2 WITH noconstant(16), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_zebra), protect
 DECLARE _default100 = i4 WITH noconstant(0), protect
 DECLARE _default10u0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE layoutsection0(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = layoutsection0abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE layoutsection0abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.920000), private
   DECLARE __a_pat_data_full_name = vc WITH noconstant(build2(a_pat_data->full_name,char(0))),
   protect
   DECLARE __a_pat_data_dob = vc WITH noconstant(build2(format(a_pat_data->dob,"@SHORTDATE"),char(0))
    ), protect
   DECLARE __a_exam_exam_name_1 = vc WITH noconstant(build2(a_exam->exam_name_1,char(0))), protect
   DECLARE __a_pat_data_gender = vc WITH noconstant(build2(a_pat_data->gender,char(0))), protect
   DECLARE __a_pat_data_facility = vc WITH noconstant(build2(a_pat_data->facility,char(0))), protect
   DECLARE __a_exam_order_by_user_name_1 = vc WITH noconstant(build2(a_doc->order_doc_name,char(0))),
   protect
   DECLARE __a_pat_data_fin_nbr = vc WITH noconstant(build2(a_pat_data->fin_nbr,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.150)
    SET rptsd->m_width = 2.323
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_default100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_full_name)
    SET rptsd->m_y = (offsety+ 0.167)
    SET rptsd->m_x = (offsetx+ 1.150)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_default10u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 0.167)
    SET rptsd->m_x = (offsetx+ 1.452)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_default100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_dob)
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.552)
    SET rptsd->m_x = (offsetx+ 0.202)
    SET rptsd->m_width = 3.625
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_exam_exam_name_1)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.317)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(completedate,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.167)
    SET rptsd->m_x = (offsetx+ 0.067)
    SET rptsd->m_width = 0.385
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_default10u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MR#:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.167)
    SET rptsd->m_x = (offsetx+ 0.452)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_default100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mednbr,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.900)
    SET rptsd->m_width = 0.823
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_gender)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.702)
    SET rptsd->m_width = 0.781
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_facility)
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.275)
    SET rptsd->m_width = 1.948
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_exam_order_by_user_name_1)
    SET rptsd->m_y = (offsety+ 0.167)
    SET rptsd->m_x = (offsetx+ 2.442)
    SET rptsd->m_width = 1.198
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_fin_nbr)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.525)
    SET rptsd->m_width = 0.302
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_default10u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sex:",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.067)
    SET rptsd->m_width = 1.323
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Exam Complete date:",char(0)))
    SET rptsd->m_y = (offsety+ 0.167)
    SET rptsd->m_x = (offsetx+ 2.150)
    SET rptsd->m_width = 0.333
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Fin#",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.067)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering Physician:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHSMARADCONT"
   SET rptreport->m_pagewidth = 4.00
   SET rptreport->m_pageheight = 3.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.10
   SET rptreport->m_marginright = 0.10
   SET rptreport->m_margintop = 0.10
   SET rptreport->m_marginbottom = 0.10
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _default100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET _default10u0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 FOR (x = 1 TO size(data->req[req_ndx].sections[sect_ndx].exam_data,5))
   SET order_id = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
    order_id)
   SET tempdir = "cer_temp:radcont"
   SET tempfile = concat(tempdir,"_",trim(cnvtstring(curtime3)),"_",trim(order_id),
    ".dat")
   SET completedate = " "
   CALL echo(value(tempfile))
   CALL initializereport(0)
   FOR (exam_ndx = 1 TO size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) BY
   data->req[req_ndx].sections[sect_ndx].nbr_of_exams_per_req)
    SELECT INTO "NL:"
     FROM order_radiology orad
     PLAN (orad
      WHERE (orad.order_id=data->req[req_ndx].sections[sect_ndx].exam_data[1].for_this_page[1].
      order_id))
     DETAIL
      completedate = format(orad.complete_dt_tm,"MM/DD/YY;;D")
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     DETAIL
      CALL echo("made it to detail"),
      CALL echo("****************START ADDRESS DATA********************")
      IF ((data->req[req_ndx].patient_data.facility_desc > " "))
       a_facility->facility_name = data->req[req_ndx].patient_data.facility_desc
      ELSE
       a_facility->facility_name = " "
      ENDIF
      IF ((data->req[req_ndx].sections[sect_ndx].inst_desc > " "))
       a_facility->inst_name = data->req[req_ndx].sections[sect_ndx].inst_desc
      ELSE
       a_facility->inst_name = " "
      ENDIF
      IF ((data->req[req_ndx].sections[sect_ndx].section_disp > " "))
       a_facility->sect_disp = data->req[req_ndx].sections[sect_ndx].section_disp
      ELSE
       a_facility->sect_disp = " "
      ENDIF
      IF ((data->req[req_ndx].sections[sect_ndx].dept_name > " "))
       a_facility->dept_name = data->req[req_ndx].sections[sect_ndx].dept_name
      ELSE
       a_facility->dept_name = " "
      ENDIF
      IF ((data->req[req_ndx].sections[sect_ndx].dept_desc > " "))
       a_facility->dept_desc = data->req[req_ndx].sections[sect_ndx].dept_desc
      ELSE
       a_facility->dept_desc = " "
      ENDIF
      IF ((data->req[req_ndx].patient_data.fac_addr > " "))
       a_facility->address = data->req[req_ndx].patient_data.fac_addr
      ELSE
       a_facility->address = " "
      ENDIF
      IF ((data->req[req_ndx].patient_data.fac_city > " "))
       a_facility->city = data->req[req_ndx].patient_data.fac_city
      ELSE
       a_facility->city = " "
      ENDIF
      IF ((data->req[req_ndx].patient_data.fac_state > " "))
       a_facility->state = data->req[req_ndx].patient_data.fac_state
      ELSE
       a_facility->state = " "
      ENDIF
      IF ((data->req[req_ndx].patient_data.fac_zip > " "))
       a_facility->zip = data->req[req_ndx].patient_data.fac_zip
      ELSE
       a_facility->zip = " "
      ENDIF
      CALL echo("****************START OF EXAM DATA********************")
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 0)
       a_exam->exam_name_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
       exam_ndx].exam_name, a_exam->order_date_1 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx]
        .exam_data[x].for_this_page[exam_ndx].order_dt_tm), a_exam->order_time_1 = cnvtdatetime(data
        ->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].order_dt_tm),
       a_exam->rqst_date_1 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].request_dt_tm), a_exam->rqst_time_1 = cnvtdatetime(data->req[req_ndx]
        .sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].request_dt_tm), a_exam->start_date_1
        = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        start_dt_tm),
       a_exam->start_time_1 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].activity_subtype_disp
       ELSE
        a_exam->exam_section_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].reason_for_exam
       ELSE
        a_exam->reason_for_exam_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         special_instructions)) > 0)
        a_exam->special_instr_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].special_instructions
       ELSE
        a_exam->special_instr_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         order_comment_chartable)) > 0)
        a_exam->comments_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].order_comment_chartable
       ELSE
        a_exam->comments_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         accession)) > 0)
        a_exam->accession = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx
        ].accession, a_exam->bc_acc_nbr = concat("*",trim(cnvtalphanum(a_exam->accession)),"*"),
        CALL echo(build("bc_accession:",a_exam->bc_acc_nbr))
       ELSE
        a_exam->accession = " ", a_exam->bc_acc_nbr = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         priority)) > 0)
        a_exam->priority_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].priority
       ELSE
        a_exam->priority_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         transport_mode)) > 0)
        a_exam->transport_mode_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].transport_mode
       ELSE
        a_exam->transport_mode_1 = " "
       ENDIF
       a_exam->order_by_id_1 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].order_by_prsnl_id,15,0,l), a_exam->order_by_name_1 = data->req[
       req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].order_by_prsnl_name, a_exam->
       order_by_user_name_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
       exam_ndx].order_by_prsnl_username
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         exam_room_disp)) > 0)
        a_exam->exam_room_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].exam_room_disp
       ELSE
        a_exam->exam_room_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         ord_loc_disp)) > 0)
        a_exam->order_location_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].ord_loc_disp
       ELSE
        a_exam->order_location_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_1 = " "
       ENDIF
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 1)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         exam_name)) > 0)
        a_exam->exam_name_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].exam_name
       ELSE
        a_exam->exam_name_2 = " "
       ENDIF
       a_exam->order_date_2 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 1)].order_dt_tm), a_exam->order_time_2 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].order_dt_tm), a_exam->
       rqst_date_2 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].request_dt_tm),
       a_exam->rqst_time_2 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 1)].request_dt_tm), a_exam->start_date_2 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].start_dt_tm), a_exam->
       start_time_2 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].activity_subtype_disp
       ELSE
        a_exam->exam_section_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 1)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         special_instructions)) > 0)
        a_exam->special_instr_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].special_instructions
       ELSE
        a_exam->special_instr_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         priority)) > 0)
        a_exam->priority_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].priority
       ELSE
        a_exam->priority_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         transport_mode)) > 0)
        a_exam->transport_mode_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].transport_mode
       ELSE
        a_exam->transport_mode_2 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_2 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 1)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_2 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_2 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 1)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         exam_room_disp)) > 0)
        a_exam->exam_room_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].exam_room_disp
       ELSE
        a_exam->exam_room_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         ord_loc_disp)) > 0)
        a_exam->order_location_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 1)].ord_loc_disp
       ELSE
        a_exam->order_location_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 1)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_2 = " "
       ENDIF
      ELSE
       a_exam->exam_name_2 = " ", a_exam->exam_section_2 = " ", a_exam->order_date_2 = null,
       a_exam->order_time_2 = null, a_exam->rqst_date_2 = null, a_exam->rqst_time_2 = null,
       a_exam->start_date_2 = null, a_exam->start_time_2 = null, a_exam->reason_for_exam_2 = " ",
       a_exam->special_instr_2 = " ", a_exam->priority_2 = " ", a_exam->transport_mode_2 = " ",
       a_exam->order_by_id_2 = " ", a_exam->order_by_name_2 = " ", a_exam->order_by_user_name_2 = " ",
       a_exam->exam_room_2 = " ", a_exam->order_location_2 = " ", a_exam->order_loc_phone_2 = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 2)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         exam_name)) > 0)
        a_exam->exam_name_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].exam_name
       ELSE
        a_exam->exam_name_3 = " "
       ENDIF
       a_exam->order_date_3 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 2)].order_dt_tm), a_exam->order_time_3 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].order_dt_tm), a_exam->
       rqst_date_3 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].request_dt_tm),
       a_exam->rqst_time_3 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 2)].request_dt_tm), a_exam->start_date_3 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].start_dt_tm), a_exam->
       start_time_3 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].activity_subtype_disp
       ELSE
        a_exam->exam_section_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 2)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         special_instructions)) > 0)
        a_exam->special_instr_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].special_instructions
       ELSE
        a_exam->special_instr_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         priority)) > 0)
        a_exam->priority_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].priority
       ELSE
        a_exam->priority_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         transport_mode)) > 0)
        a_exam->transport_mode_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].transport_mode
       ELSE
        a_exam->transport_mode_3 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_3 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 2)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_3 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_3 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 2)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         exam_room_disp)) > 0)
        a_exam->exam_room_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].exam_room_disp
       ELSE
        a_exam->exam_room_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         ord_loc_disp)) > 0)
        a_exam->order_location_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 2)].ord_loc_disp
       ELSE
        a_exam->order_location_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 2)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_3 = " "
       ENDIF
      ELSE
       a_exam->exam_name_3 = " ", a_exam->exam_section_3 = " ", a_exam->order_date_3 = null,
       a_exam->order_time_3 = null, a_exam->rqst_date_3 = null, a_exam->rqst_time_3 = null,
       a_exam->start_date_3 = null, a_exam->start_time_3 = null, a_exam->reason_for_exam_3 = " ",
       a_exam->special_instr_3 = " ", a_exam->priority_3 = " ", a_exam->transport_mode_3 = " ",
       a_exam->order_by_id_3 = " ", a_exam->order_by_user_name_3 = " ", a_exam->order_by_name_3 = " ",
       a_exam->exam_room_3 = " ", a_exam->order_location_3 = " ", a_exam->order_loc_phone_3 = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 3)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         exam_name)) > 0)
        a_exam->exam_name_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].exam_name
       ELSE
        a_exam->exam_name_4 = " "
       ENDIF
       a_exam->order_date_4 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 3)].order_dt_tm), a_exam->order_time_4 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].order_dt_tm), a_exam->
       rqst_date_4 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].request_dt_tm),
       a_exam->rqst_time_4 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 3)].request_dt_tm), a_exam->start_date_4 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].start_dt_tm), a_exam->
       start_time_4 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].activity_subtype_disp
       ELSE
        a_exam->exam_section_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 3)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         special_instructions)) > 0)
        a_exam->special_instr_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].special_instructions
       ELSE
        a_exam->special_instr_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         priority)) > 0)
        a_exam->priority_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].priority
       ELSE
        a_exam->priority_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         transport_mode)) > 0)
        a_exam->transport_mode_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].transport_mode
       ELSE
        a_exam->transport_mode_4 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_4 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 3)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_4 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_4 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 3)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         exam_room_disp)) > 0)
        a_exam->exam_room_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].exam_room_disp
       ELSE
        a_exam->exam_room_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         ord_loc_disp)) > 0)
        a_exam->order_location_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 3)].ord_loc_disp
       ELSE
        a_exam->order_location_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 3)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_4 = " "
       ENDIF
      ELSE
       a_exam->exam_name_4 = " ", a_exam->exam_section_4 = " ", a_exam->order_date_4 = null,
       a_exam->order_time_4 = null, a_exam->rqst_date_4 = null, a_exam->rqst_time_4 = null,
       a_exam->start_date_4 = null, a_exam->start_time_4 = null, a_exam->reason_for_exam_4 = " ",
       a_exam->special_instr_4 = " ", a_exam->priority_4 = " ", a_exam->transport_mode_4 = " ",
       a_exam->order_by_id_4 = " ", a_exam->order_by_user_name_4 = " ", a_exam->order_by_name_4 = " ",
       a_exam->exam_room_4 = " ", a_exam->order_location_4 = " ", a_exam->order_loc_phone_4 = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 4)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         exam_name)) > 0)
        a_exam->exam_name_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].exam_name
       ELSE
        a_exam->exam_name_5 = " "
       ENDIF
       a_exam->order_date_5 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 4)].order_dt_tm), a_exam->order_time_5 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].order_dt_tm), a_exam->
       rqst_date_5 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].request_dt_tm),
       a_exam->rqst_time_5 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 4)].request_dt_tm), a_exam->start_date_5 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].start_dt_tm), a_exam->
       start_time_5 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].activity_subtype_disp
       ELSE
        a_exam->exam_section_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 4)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         special_instructions)) > 0)
        a_exam->special_instr_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].special_instructions
       ELSE
        a_exam->special_instr_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         priority)) > 0)
        a_exam->priority_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].priority
       ELSE
        a_exam->priority_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         transport_mode)) > 0)
        a_exam->transport_mode_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].transport_mode
       ELSE
        a_exam->transport_mode_5 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_5 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 4)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_5 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_5 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 4)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         exam_room_disp)) > 0)
        a_exam->exam_room_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].exam_room_disp
       ELSE
        a_exam->exam_room_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         ord_loc_disp)) > 0)
        a_exam->order_location_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 4)].ord_loc_disp
       ELSE
        a_exam->order_location_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 4)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_5 = " "
       ENDIF
      ELSE
       a_exam->exam_name_5 = " ", a_exam->exam_section_5 = " ", a_exam->order_date_5 = null,
       a_exam->order_time_5 = null, a_exam->rqst_date_5 = null, a_exam->rqst_time_5 = null,
       a_exam->start_date_5 = null, a_exam->start_time_5 = null, a_exam->reason_for_exam_5 = " ",
       a_exam->special_instr_5 = " ", a_exam->priority_5 = " ", a_exam->transport_mode_5 = " ",
       a_exam->order_by_id_5 = " ", a_exam->order_by_name_5 = " ", a_exam->order_by_user_name_5 = " ",
       a_exam->exam_room_5 = " ", a_exam->order_location_5 = " ", a_exam->order_loc_phone_5 = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 5)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
         exam_name)) > 0)
        a_exam->exam_name_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].exam_name
       ELSE
        a_exam->exam_name_6 = " "
       ENDIF
       a_exam->order_date_6 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 5)].order_dt_tm), a_exam->order_time_6 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].order_dt_tm), a_exam->
       rqst_date_6 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].request_dt_tm),
       a_exam->rqst_time_6 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 5)].request_dt_tm), a_exam->start_date_6 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].start_dt_tm), a_exam->
       start_time_6 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].activity_subtype_disp
       ELSE
        a_exam->exam_section_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 5)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
         special_instructions)) > 0)
        a_exam->special_instr_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].special_instructions
       ELSE
        a_exam->special_instr_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
         priority)) > 0)
        a_exam->priority_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].priority
       ELSE
        a_exam->priority_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         transport_mode)) > 0)
        a_exam->transport_mode_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].transport_mode
       ELSE
        a_exam->transport_mode_6 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_6 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 5)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_6 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_6 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 5)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
         exam_room_disp)) > 0)
        a_exam->exam_room_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].exam_room_disp
       ELSE
        a_exam->exam_room_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
         ord_loc_disp)) > 0)
        a_exam->order_location_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 5)].ord_loc_disp
       ELSE
        a_exam->order_location_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 5)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_6 = " "
       ENDIF
      ELSE
       a_exam->exam_name_6 = " ", a_exam->exam_section_6 = " ", a_exam->order_date_6 = null,
       a_exam->order_time_6 = null, a_exam->rqst_date_6 = null, a_exam->rqst_time_6 = null,
       a_exam->start_date_6 = null, a_exam->start_time_6 = null, a_exam->reason_for_exam_6 = " ",
       a_exam->special_instr_6 = " ", a_exam->priority_6 = " ", a_exam->transport_mode_6 = " ",
       a_exam->order_by_id_6 = " ", a_exam->order_by_name_6 = " ", a_exam->order_by_user_name_6" ",
       a_exam->exam_room_6 = " ", a_exam->order_location_6 = " ", a_exam->order_loc_phone_6 = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 6)
       a_exam->exam_name_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
       exam_ndx+ 6)].exam_name, a_exam->order_date_7 = cnvtdatetime(data->req[req_ndx].sections[
        sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].order_dt_tm), a_exam->order_time_7 =
       cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
        order_dt_tm),
       a_exam->rqst_date_7 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 6)].request_dt_tm), a_exam->rqst_time_7 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].request_dt_tm), a_exam
       ->start_date_7 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 6)].start_dt_tm),
       a_exam->start_time_7 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 6)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 6)].activity_subtype_disp
       ELSE
        a_exam->exam_section_7 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 6)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_7 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         special_instructions)) > 0)
        a_exam->special_instr_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 6)].special_instructions
       ELSE
        a_exam->special_instr_7 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         priority)) > 0)
        a_exam->priority_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 6)].priority
       ELSE
        a_exam->priority_7 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         transport_mode)) > 0)
        a_exam->transport_mode_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 6)].transport_mode
       ELSE
        a_exam->transport_mode_7 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_7 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 6)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_7 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 6)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_7 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 6)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_7 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         exam_room_disp)) > 0)
        a_exam->exam_room_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 6)].exam_room_disp
       ELSE
        a_exam->exam_room_7 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         ord_loc_disp)) > 0)
        a_exam->order_location_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 6)].ord_loc_disp
       ELSE
        a_exam->order_location_7 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 6)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_7 = " "
       ENDIF
      ELSE
       a_exam->exam_name_7 = " ", a_exam->exam_section_7 = " ", a_exam->order_date_7 = null,
       a_exam->order_time_7 = null, a_exam->rqst_date_7 = null, a_exam->rqst_time_7 = null,
       a_exam->start_date_7 = null, a_exam->start_time_7 = null, a_exam->reason_for_exam_7 = " ",
       a_exam->special_instr_7 = " ", a_exam->priority_7 = " ", a_exam->transport_mode_7 = " ",
       a_exam->order_by_id_7 = " ", a_exam->order_by_name_7 = " ", a_exam->order_by_user_name_7 = " ",
       a_exam->exam_room_7 = " ", a_exam->order_location_7 = " ", a_exam->order_loc_phone_7 = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 7)
       a_exam->exam_name_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
       exam_ndx+ 7)].exam_name, a_exam->order_date_8 = cnvtdatetime(data->req[req_ndx].sections[
        sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].order_dt_tm), a_exam->order_time_8 =
       cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
        order_dt_tm),
       a_exam->rqst_date_8 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 7)].request_dt_tm), a_exam->rqst_time_8 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].request_dt_tm), a_exam
       ->start_date_8 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 7)].start_dt_tm),
       a_exam->start_time_8 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 7)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 7)].activity_subtype_disp
       ELSE
        a_exam->exam_section_8 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 7)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_8 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
         special_instructions)) > 0)
        a_exam->special_instr_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 7)].special_instructions
       ELSE
        a_exam->special_instr_8 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
         priority)) > 0)
        a_exam->priority_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 7)].priority
       ELSE
        a_exam->priority_8 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
         transport_mode)) > 0)
        a_exam->transport_mode_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 7)].transport_mode
       ELSE
        a_exam->transport_mode_8 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_8 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 7)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_8 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 7)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_8 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 7)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_8 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
         exam_room_disp)) > 0)
        a_exam->exam_room_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 7)].exam_room_disp
       ELSE
        a_exam->exam_room_8 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
         ord_loc_disp)) > 0)
        a_exam->order_location_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 7)].ord_loc_disp
       ELSE
        a_exam->order_location_8 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 7)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_8 = " "
       ENDIF
      ELSE
       a_exam->exam_name_8 = " ", a_exam->exam_section_8 = " ", a_exam->order_date_8 = null,
       a_exam->order_time_8 = null, a_exam->rqst_date_8 = null, a_exam->rqst_time_8 = null,
       a_exam->start_date_8 = null, a_exam->start_time_8 = null, a_exam->reason_for_exam_8 = " ",
       a_exam->special_instr_8 = " ", a_exam->priority_8 = " ", a_exam->transport_mode_8 = " ",
       a_exam->order_by_id_8 = " ", a_exam->order_by_name_8 = " ", a_exam->order_by_user_name_8 = " ",
       a_exam->exam_room_8 = " ", a_exam->order_location_8 = " ", a_exam->order_loc_phone_8 = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 8)
       a_exam->exam_name_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
       exam_ndx+ 8)].exam_name, a_exam->order_date_9 = cnvtdatetime(data->req[req_ndx].sections[
        sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].order_dt_tm), a_exam->order_time_9 =
       cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
        order_dt_tm),
       a_exam->rqst_date_9 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 8)].request_dt_tm), a_exam->rqst_time_9 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].request_dt_tm), a_exam
       ->start_date_9 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 8)].start_dt_tm),
       a_exam->start_time_9 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 8)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 8)].activity_subtype_disp
       ELSE
        a_exam->exam_section_9 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 8)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_9 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
         special_instructions)) > 0)
        a_exam->special_instr_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 8)].special_instructions
       ELSE
        a_exam->special_instr_9 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
         priority)) > 0)
        a_exam->priority_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 8)].priority
       ELSE
        a_exam->priority_9 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
         transport_mode)) > 0)
        a_exam->transport_mode_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 8)].transport_mode
       ELSE
        a_exam->transport_mode_9 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_9 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 8)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_9 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 8)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_9 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 8)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_9 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
         exam_room_disp)) > 0)
        a_exam->exam_room_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 8)].exam_room_disp
       ELSE
        a_exam->exam_room_9 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
         ord_loc_disp)) > 0)
        a_exam->order_location_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 8)].ord_loc_disp
       ELSE
        a_exam->order_location_9 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 8)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_9 = " "
       ENDIF
      ELSE
       a_exam->exam_name_9 = " ", a_exam->exam_section_9 = " ", a_exam->order_date_9 = null,
       a_exam->order_time_9 = null, a_exam->rqst_date_9 = null, a_exam->rqst_time_9 = null,
       a_exam->start_date_9 = null, a_exam->start_time_9 = null, a_exam->reason_for_exam_9 = " ",
       a_exam->special_instr_9 = " ", a_exam->priority_9 = " ", a_exam->transport_mode_9 = " ",
       a_exam->order_by_id_9 = " ", a_exam->order_by_name_9 = " ", a_exam->order_by_user_name_9 = " ",
       a_exam->exam_room_9 = " ", a_exam->order_location_9 = " ", a_exam->order_loc_phone_9 = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 9)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         exam_name)) > 0)
        a_exam->exam_name_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 9)].exam_name
       ELSE
        a_exam->exam_name_10 = " "
       ENDIF
       a_exam->order_date_10 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 9)].order_dt_tm), a_exam->order_time_10 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].order_dt_tm), a_exam->
       rqst_date_10 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 9)].request_dt_tm),
       a_exam->rqst_time_10 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 9)].request_dt_tm), a_exam->start_date_10 = cnvtdatetime(data->req[
        req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].start_dt_tm), a_exam->
       start_time_10 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 9)].start_dt_tm)
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         activity_subtype_disp)) > 0)
        a_exam->exam_section_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 9)].activity_subtype_disp
       ELSE
        a_exam->exam_section_10 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         reason_for_exam)) > 0)
        a_exam->reason_for_exam_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 9)].reason_for_exam
       ELSE
        a_exam->reason_for_exam_10 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         special_instructions)) > 0)
        a_exam->special_instr_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 9)].special_instructions
       ELSE
        a_exam->special_instr_10 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         priority)) > 0)
        a_exam->priority_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 9)].priority
       ELSE
        a_exam->priority_10 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         transport_mode)) > 0)
        a_exam->transport_mode_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 9)].transport_mode
       ELSE
        a_exam->transport_mode_10 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_id_10 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
         for_this_page[(exam_ndx+ 9)].order_by_prsnl_id,15,0,l)
       ELSE
        a_exam->order_by_id_10 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_name_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 9)].order_by_prsnl_name
       ELSE
        a_exam->order_by_name_10 = " "
       ENDIF
       IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
        order_by_prsnl_id) > 0)
        a_exam->order_by_user_name_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 9)].order_by_prsnl_username
       ELSE
        a_exam->order_by_user_name_10 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         exam_room_disp)) > 0)
        a_exam->exam_room_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
        exam_ndx+ 9)].exam_room_disp
       ELSE
        a_exam->exam_room_10 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         ord_loc_disp)) > 0)
        a_exam->order_location_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        (exam_ndx+ 9)].ord_loc_disp
       ELSE
        a_exam->order_location_10 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
         ord_loc_phone)) > 0)
        a_exam->order_loc_phone_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[(exam_ndx+ 9)].ord_loc_phone
       ELSE
        a_exam->order_loc_phone_10 = " "
       ENDIF
      ELSE
       a_exam->exam_name_10 = " ", a_exam->exam_section_10 = " ", a_exam->order_date_10 = null,
       a_exam->order_time_10 = null, a_exam->rqst_date_10 = null, a_exam->rqst_time_10 = null,
       a_exam->start_date_10 = null, a_exam->start_time_10 = null, a_exam->reason_for_exam_10 = " ",
       a_exam->special_instr_10 = " ", a_exam->priority_10 = " ", a_exam->transport_mode_10 = " ",
       a_exam->order_by_id_10 = " ", a_exam->order_by_name_10 = " ", a_exam->order_by_user_name_10 =
       " ",
       a_exam->exam_room_10 = " ", a_exam->order_location_10 = " ", a_exam->order_loc_phone_10 = " "
      ENDIF
      CALL echo("*****START OF MODIFY/REPRINT DATA*****")
      IF (modify_flag=1)
       a_mod->status = "MODIFIED"
      ENDIF
      IF ((working_array->reprint_flag="Y"))
       a_mod->reprint = "REPRINT"
      ENDIF
      CALL echo("*****START OF PATIENT DATA *****"), a_pat_data->person_id = data->req[req_ndx].
      patient_data.person_id, a_pat_data->full_name = data->req[req_ndx].patient_data.name,
      CALL echo(build("Patient Name ------->",a_pat_data->full_name)),
      CALL echo(build("From Get Info------->",data->req[req_ndx].patient_data.name)), a_pat_data->
      last_name = data->req[req_ndx].patient_data.name_last,
      a_pat_data->first_name = data->req[req_ndx].patient_data.name_first, a_pat_data->mid_name =
      data->req[req_ndx].patient_data.name_middle, a_pat_data->dob = data->req[req_ndx].patient_data.
      dob,
      a_pat_data->age = data->req[req_ndx].patient_data.age, a_pat_data->short_age = data->req[
      req_ndx].patient_data.short_age, a_pat_data->gender = data->req[req_ndx].patient_data.gender,
      a_pat_data->short_gender = data->req[req_ndx].patient_data.short_gender, a_pat_data->race =
      data->req[req_ndx].patient_data.race, a_pat_data->encounter_id = data->req[req_ndx].
      patient_data.encntr_id,
      a_pat_data->location = data->req[req_ndx].patient_data.location, a_pat_data->pat_type = data->
      req[req_ndx].patient_data.encntr_type_disp, a_pat_data->arrival_date = data->req[req_ndx].
      patient_data.date_of_arrival,
      a_pat_data->facility = data->req[req_ndx].patient_data.facility, a_pat_data->building = data->
      req[req_ndx].patient_data.building, a_pat_data->nurse_unit = data->req[req_ndx].patient_data.
      nurse_unit,
      a_pat_data->nurse_unit_phone = data->req[req_ndx].patient_data.nurse_unit_phone, a_pat_data->
      room = data->req[req_ndx].patient_data.room, a_pat_data->bed = data->req[req_ndx].patient_data.
      bed,
      a_pat_data->admitting_diag = data->req[req_ndx].patient_data.reason_for_visit, a_pat_data->
      isolation = data->req[req_ndx].patient_data.isolation, a_pat_data->med_service = data->req[
      req_ndx].patient_data.med_service,
      a_pat_data->fin_class = data->req[req_ndx].patient_data.financial_class, a_pat_data->client =
      data->req[req_ndx].patient_data.client, a_pat_data->ssn = data->req[req_ndx].patient_data.
      person_ssn,
      a_pat_data->cmrn = data->req[req_ndx].patient_data.community_med_nbr, a_pat_data->med_nbr =
      data->req[req_ndx].patient_data.person_alias
      IF (size(trim(data->req[req_ndx].patient_data.person_alias)) > 0)
       a_pat_data->bc_med_nbr = concat("*",trim(data->req[req_ndx].patient_data.person_alias),"*")
      ELSE
       a_pat_data->bc_med_nbr = " "
      ENDIF
      a_pat_data->fin_nbr = data->req[req_ndx].patient_data.fin_nbr_alias
      IF (size(data->req[req_ndx].patient_data.fin_nbr_alias) > 0)
       a_pat_data->bc_fin_nbr = concat("*",a_pat_data->fin_nbr,"*")
      ELSE
       a_pat_data->bc_fin_nbr = " "
      ENDIF
      a_pat_data->home_phone = data->req[req_ndx].patient_data.phone, a_pat_data->work_phone = data->
      req[req_ndx].patient_data.work_phone, a_pat_data->address = data->req[req_ndx].patient_data.
      address[1].street_addr,
      a_pat_data->city = data->req[req_ndx].patient_data.address[1].city, a_pat_data->state = data->
      req[req_ndx].patient_data.address[1].state, a_pat_data->zip = data->req[req_ndx].patient_data.
      address[1].zipcode,
      CALL echo("*****START OF PHYSICIAN DATA*****")
      IF (size(data->req[req_ndx].patient_data.admit_phy_name) > 0)
       a_doc->admit_doc_name = data->req[req_ndx].patient_data.admit_phy_name
      ELSE
       a_doc->admit_doc_name = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.admit_phy_phone) > 0)
       a_doc->admit_doc_phone = data->req[req_ndx].patient_data.admit_phy_phone
      ELSE
       a_doc->admit_doc_phone = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.admit_phy_fax) > 0)
       a_doc->admit_doc_fax = data->req[req_ndx].patient_data.admit_phy_fax
      ELSE
       a_doc->admit_doc_fax = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.admit_phy_pager) > 0)
       a_doc->admit_doc_pager = data->req[req_ndx].patient_data.admit_phy_pager
      ELSE
       a_doc->admit_doc_pager = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.refer_phy_name) > 0)
       a_doc->refer_doc_name = data->req[req_ndx].patient_data.refer_phy_name
      ELSE
       a_doc->refer_doc_name = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.refer_phy_phone) > 0)
       a_doc->refer_doc_phone = data->req[req_ndx].patient_data.refer_phy_phone
      ELSE
       a_doc->refer_doc_phone = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.refer_phy_fax) > 0)
       a_doc->refer_doc_fax = data->req[req_ndx].patient_data.refer_phy_fax
      ELSE
       a_doc->refer_doc_fax = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.refer_phy_pager) > 0)
       a_doc->refer_doc_pager = data->req[req_ndx].patient_data.refer_phy_pager
      ELSE
       a_doc->refer_doc_pager = " "
      ENDIF
      IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        order_physician)) > 0)
       a_doc->order_doc_name = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
       exam_ndx].order_physician
      ELSE
       a_doc->order_doc_name = " "
      ENDIF
      IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        order_phy_phone)) > 0)
       a_doc->order_doc_phone = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
       exam_ndx].order_phy_phone
      ELSE
       a_doc->order_doc_phone = " "
      ENDIF
      IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        order_phy_phone)) > 0)
       a_doc->order_doc_fax = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
       exam_ndx].order_phy_fax
      ELSE
       a_doc->order_doc_fax = " "
      ENDIF
      IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        order_phy_phone)) > 0)
       a_doc->order_doc_pager = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
       exam_ndx].order_phy_pager
      ELSE
       a_doc->order_doc_pager = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.attend_phy_name) > 0)
       a_doc->attend_doc_name = data->req[req_ndx].patient_data.attend_phy_name
      ELSE
       a_doc->attend_doc_name = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.attend_phy_phone) > 0)
       a_doc->attend_doc_phone = data->req[req_ndx].patient_data.attend_phy_phone
      ELSE
       a_doc->attend_doc_phone = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.attend_phy_fax) > 0)
       a_doc->attend_doc_fax = data->req[req_ndx].patient_data.attend_phy_fax
      ELSE
       a_doc->attend_doc_fax = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.attend_phy_pager) > 0)
       a_doc->attend_doc_pager = data->req[req_ndx].patient_data.attend_phy_pager
      ELSE
       a_doc->attend_doc_pager = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.family_phy_name) > 0)
       a_doc->family_doc_name = data->req[req_ndx].patient_data.family_phy_name
      ELSE
       a_doc->family_doc_name = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.family_phy_phone) > 0)
       a_doc->family_doc_phone = data->req[req_ndx].patient_data.family_phy_phone
      ELSE
       a_doc->family_doc_phone = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.family_phy_fax) > 0)
       a_doc->family_doc_fax = data->req[req_ndx].patient_data.family_phy_fax
      ELSE
       a_doc->family_doc_fax = " "
      ENDIF
      IF (size(data->req[req_ndx].patient_data.family_phy_pager) > 0)
       a_doc->family_doc_pager = data->req[req_ndx].patient_data.family_phy_pager
      ELSE
       a_doc->family_doc_pager = " "
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].consult_doc,
       5) > 0)
       IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        consult_doc[1].consult_phy_name) != " ")
        a_doc->consult_doc_name_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[1].consult_phy_name
       ELSE
        a_doc->consult_doc_name_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[1].consult_phy_phone)) > 0)
        a_doc->consult_doc_phone_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[1].consult_phy_phone
       ELSE
        a_doc->consult_doc_phone_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[1].consult_phy_pager)) > 0)
        a_doc->consult_doc_pager_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[1].consult_phy_pager
       ELSE
        a_doc->consult_doc_pager_1 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[1].consult_phy_fax)) > 0)
        a_doc->consult_doc_fax_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[1].consult_phy_fax
       ELSE
        a_doc->consult_doc_fax_1 = " "
       ENDIF
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].consult_doc,
       5) > 1)
       IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        consult_doc[2].consult_phy_name) != " ")
        a_doc->consult_doc_name_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[2].consult_phy_name
       ELSE
        a_doc->consult_doc_name_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[2].consult_phy_phone)) > 0)
        a_doc->consult_doc_phone_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[2].consult_phy_phone
       ELSE
        a_doc->consult_doc_phone_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[2].consult_phy_pager)) > 0)
        a_doc->consult_doc_pager_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[2].consult_phy_pager
       ELSE
        a_doc->consult_doc_pager_2 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[2].consult_phy_fax)) > 0)
        a_doc->consult_doc_fax_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[2].consult_phy_fax
       ELSE
        a_doc->consult_doc_fax_2 = " "
       ENDIF
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].consult_doc,
       5) > 2)
       IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        consult_doc[3].consult_phy_name) != " ")
        a_doc->consult_doc_name_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[3].consult_phy_name
       ELSE
        a_doc->consult_doc_name_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[3].consult_phy_phone)) > 0)
        a_doc->consult_doc_phone_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[3].consult_phy_phone
       ELSE
        a_doc->consult_doc_phone_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[3].consult_phy_pager)) > 0)
        a_doc->consult_doc_pager_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[3].consult_phy_pager
       ELSE
        a_doc->consult_doc_pager_3 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[3].consult_phy_fax)) > 0)
        a_doc->consult_doc_fax_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[3].consult_phy_fax
       ELSE
        a_doc->consult_doc_fax_3 = " "
       ENDIF
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].consult_doc,
       5) > 3)
       IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        consult_doc[4].consult_phy_name) != " ")
        a_doc->consult_doc_name_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[4].consult_phy_name
       ELSE
        a_doc->consult_doc_name_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[4].consult_phy_phone)) > 0)
        a_doc->consult_doc_phone_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[4].consult_phy_phone
       ELSE
        a_doc->consult_doc_phone_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[4].consult_phy_pager)) > 0)
        a_doc->consult_doc_pager_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[4].consult_phy_pager
       ELSE
        a_doc->consult_doc_pager_4 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[4].consult_phy_fax)) > 0)
        a_doc->consult_doc_fax_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[4].consult_phy_fax
       ELSE
        a_doc->consult_doc_fax_4 = " "
       ENDIF
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].consult_doc,
       5) > 4)
       IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        consult_doc[5].consult_phy_name) != " ")
        a_doc->consult_doc_name_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[5].consult_phy_name
       ELSE
        a_doc->consult_doc_name_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[5].consult_phy_phone)) > 0)
        a_doc->consult_doc_phone_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[5].consult_phy_phone
       ELSE
        a_doc->consult_doc_phone_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[5].consult_phy_pager)) > 0)
        a_doc->consult_doc_pager_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[5].consult_phy_pager
       ELSE
        a_doc->consult_doc_pager_5 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[5].consult_phy_fax)) > 0)
        a_doc->consult_doc_fax_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[5].consult_phy_fax
       ELSE
        a_doc->consult_doc_fax_5 = " "
       ENDIF
      ENDIF
      IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].consult_doc,
       5) > 5)
       IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
        consult_doc[6].consult_phy_name) != " ")
        a_doc->consult_doc_name_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[6].consult_phy_name
       ELSE
        a_doc->consult_doc_name_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[6].consult_phy_phone)) > 0)
        a_doc->consult_doc_phone_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[6].consult_phy_phone
       ELSE
        a_doc->consult_doc_phone_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[6].consult_phy_pager)) > 0)
        a_doc->consult_doc_pager_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
        for_this_page[exam_ndx].consult_doc[6].consult_phy_pager
       ELSE
        a_doc->consult_doc_pager_6 = " "
       ENDIF
       IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc[6].consult_phy_fax)) > 0)
        a_doc->consult_doc_fax_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
        exam_ndx].consult_doc[6].consult_phy_fax
       ELSE
        a_doc->consult_doc_fax_6 = " "
       ENDIF
      ENDIF
      mednbr = trim(a_pat_data->med_nbr,3), mednbr = build2(trim(
        IF (isnumeric(mednbr) > 0) cnvtstring(cnvtreal(mednbr))
        ELSE mednbr
        ENDIF
        ,3)), mednbr2 = replace(mednbr,"abcdefghijklmnopqrstuvwxyz1234567890",
       "abcdefghijklmnopqrstuvwxyz1234567890",3),
      CALL echo("at rest of reort"),
      CALL echo("inside for exam_ndx loop"), cont_cnt = data->req[req_ndx].sections[sect_ndx].
      exam_data[x].for_this_page[exam_ndx].content_label_cnt
      FOR (copies_cnt = 1 TO cont_cnt)
        dummy_val = layoutsection0(rpt_render),
        CALL echo(build("copies count: ",copies_cnt)),
        CALL echo(build("content count: ",cont_cnt))
        IF (copies_cnt < cont_cnt)
         row + 1, dummy_page = pagebreak(0), row + 1
        ENDIF
      ENDFOR
      IF (exam_ndx < size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5))
       row + 1, dummy_page = pagebreak(0), row + 1
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
   CALL finalizereport(tempfile)
   IF ((working_array->print_flag != "N"))
    IF ((working_array->debug_flag="Y"))
     SET spool value(trim(tempfile))  $4 WITH notify
    ELSE
     SET spool value(concat(trim(tempfile)))  $4 WITH deleted
    ENDIF
   ENDIF
 ENDFOR
END GO
