CREATE PROGRAM bhs_eks_case_mgt_demog
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Case Mgmt Update Clinical Event ID:" = 0.00
  WITH outdev, clineventid
 FREE RECORD work
 RECORD work(
   1 person_id = f8
   1 encntr_id = f8
   1 pat_name = vc
   1 mrn = vc
   1 dob = dq8
   1 unit = vc
   1 room = vc
   1 pat_addr = vc
   1 pat_city = vc
   1 pat_home = vc
   1 pat_cell = vc
   1 pat_work = vc
   1 prim_name = vc
   1 prim_addr = vc
   1 prim_city = vc
   1 prim_home = vc
   1 prim_cell = vc
   1 prim_work = vc
   1 prim_reltn = vc
   1 sec_name = vc
   1 sec_addr = vc
   1 sec_city = vc
   1 sec_home = vc
   1 sec_cell = vc
   1 sec_work = vc
   1 sec_reltn = vc
   1 prim_ins = vc
   1 prim_num = vc
   1 prim_sub = vc
   1 sec_ins = vc
   1 sec_num = vc
   1 sec_sub = vc
   1 comments = vc
 )
 DECLARE cs14003_pat_addr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PATIENTSTREETADDRCORRECTED"))
 DECLARE cs14003_pat_city_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PATIENTCITYSTATEZIPCORRECTED"))
 DECLARE cs14003_pat_home_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PATIENTPHONECORRECTED"))
 DECLARE cs14003_pat_cell_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PATIENTCELLPHONECORRECTED"))
 DECLARE cs14003_pat_work_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PATIENTWORKPHONECORRECTED"))
 DECLARE cs14003_prim_name_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "EMERGENCYCONTACTNAMECORRECTED"))
 DECLARE cs14003_prim_addr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "EMERGENCYCONTACTSTREETADDRCORRECTED"))
 DECLARE cs14003_prim_city_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "EMERGENCYCONTACTCITYSTZIPCORRECTED"))
 DECLARE cs14003_prim_home_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "EMERGENCYCONTACTPHONECORRECTED"))
 DECLARE cs14003_prim_cell_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PRIMARYCONTACTCELLPHONECORRECTED"))
 DECLARE cs14003_prim_work_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PRIMARYCONTACTWORKPHONECORRECTED"))
 DECLARE cs14003_prim_reltn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PRIMARYCONTACTRELATIONSHIPCORRECTED"))
 DECLARE cs14003_sec_name_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "NEXTOFKINNAMECORRECTED"))
 DECLARE cs14003_sec_addr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "NEXTOFKINSTREETADDRCORRECTED"))
 DECLARE cs14003_sec_city_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "NEXTOFKINCITYSTATEZIPCORRECTED"))
 DECLARE cs14003_sec_home_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "NEXTOFKINPHONECORRECTED"))
 DECLARE cs14003_sec_cell_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SECONDARYCONTACTCELLPHONECORRECTED"))
 DECLARE cs14003_sec_work_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SECONDARYCONTACTWORKPHONECORRECTED"))
 DECLARE cs14003_sec_reltn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SECONDARYCONTACTRELATIONSHIPCORRECTED"))
 DECLARE cs14003_prim_ins_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PRIMARYINSCARRIERCORRECTED"))
 DECLARE cs14003_prim_num_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PRIMARYINSPOLICYNUMBERCORRECTED"))
 DECLARE cs14003_prim_sub_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PRIMARYINSSUBSCRIBERCORRECTED"))
 DECLARE cs14003_sec_ins_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SECONDARYINSCARRIERCORRECTED"))
 DECLARE cs14003_sec_num_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SECONDARYINSPOLICYNUMBERCORRECTED"))
 DECLARE cs14003_sec_sub_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "SECONDARYINSSUBSCRIBERCORRECTED"))
 DECLARE cs14003_comments_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "CORRECTEDDATACOMMENTS"))
 DECLARE cs4_cmrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN"))
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   person p,
   person_alias pa,
   encounter e,
   clinical_event ce2
  PLAN (ce1
   WHERE (ce1.clinical_event_id= $CLINEVENTID))
   JOIN (p
   WHERE ce1.person_id=p.person_id)
   JOIN (pa
   WHERE ce1.person_id=pa.person_id
    AND pa.person_alias_type_cd=cs4_cmrn_cd
    AND pa.active_ind=1)
   JOIN (e
   WHERE ce1.encntr_id=e.encntr_id)
   JOIN (ce2
   WHERE ce1.parent_event_id=ce2.parent_event_id
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   work->person_id = p.person_id, work->encntr_id = e.encntr_id, work->pat_name = trim(p
    .name_full_formatted,3),
   work->mrn = trim(pa.alias), work->dob = p.birth_dt_tm, work->unit = trim(uar_get_code_display(e
     .loc_nurse_unit_cd),3),
   work->room = trim(uar_get_code_display(e.loc_room_cd),3)
  DETAIL
   CASE (ce2.task_assay_cd)
    OF cs14003_pat_addr_cd:
     work->pat_addr = trim(ce2.result_val)
    OF cs14003_pat_city_cd:
     work->pat_city = trim(ce2.result_val)
    OF cs14003_pat_home_cd:
     work->pat_home = trim(ce2.result_val)
    OF cs14003_pat_cell_cd:
     work->pat_cell = trim(ce2.result_val)
    OF cs14003_pat_work_cd:
     work->pat_work = trim(ce2.result_val)
    OF cs14003_prim_name_cd:
     work->prim_name = trim(ce2.result_val)
    OF cs14003_prim_addr_cd:
     work->prim_addr = trim(ce2.result_val)
    OF cs14003_prim_city_cd:
     work->prim_city = trim(ce2.result_val)
    OF cs14003_prim_home_cd:
     work->prim_home = trim(ce2.result_val)
    OF cs14003_prim_cell_cd:
     work->prim_cell = trim(ce2.result_val)
    OF cs14003_prim_work_cd:
     work->prim_work = trim(ce2.result_val)
    OF cs14003_prim_reltn_cd:
     work->prim_reltn = trim(ce2.result_val)
    OF cs14003_sec_name_cd:
     work->sec_name = trim(ce2.result_val)
    OF cs14003_sec_addr_cd:
     work->sec_addr = trim(ce2.result_val)
    OF cs14003_sec_city_cd:
     work->sec_city = trim(ce2.result_val)
    OF cs14003_sec_home_cd:
     work->sec_home = trim(ce2.result_val)
    OF cs14003_sec_cell_cd:
     work->sec_cell = trim(ce2.result_val)
    OF cs14003_sec_work_cd:
     work->sec_work = trim(ce2.result_val)
    OF cs14003_sec_reltn_cd:
     work->sec_reltn = trim(ce2.result_val)
    OF cs14003_prim_ins_cd:
     work->prim_ins = trim(ce2.result_val)
    OF cs14003_prim_num_cd:
     work->prim_num = trim(ce2.result_val)
    OF cs14003_prim_sub_cd:
     work->prim_sub = trim(ce2.result_val)
    OF cs14003_sec_ins_cd:
     work->sec_ins = trim(ce2.result_val)
    OF cs14003_sec_num_cd:
     work->sec_num = trim(ce2.result_val)
    OF cs14003_sec_sub_cd:
     work->sec_sub = trim(ce2.result_val)
    OF cs14003_comments_cd:
     work->comments = trim(ce2.result_val)
   ENDCASE
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE demog_section(ncalc=i2) = f8 WITH protect
 DECLARE demog_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _helvetica12bu0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE demog_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = demog_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE demog_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PATIENT NAME:",char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("UNIT:",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ROOM:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 5.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->pat_name,char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 5.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->mrn,char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 5.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(format(work->dob,"@LONGDATE"),3),
      char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 5.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->unit,char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 5.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->room,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.745),(offsetx+ 7.500),(offsety+
     1.745))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.875)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.490
    SET rptsd->m_height = 0.438
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(
       "Case management noted incorrect patient information.  Please verify insurance information and update ",
       work->pat_name,"'s record with the following."),char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 2.370),(offsetx+ 7.500),(offsety+
     2.370))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PATIENT INFORMATION:",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BAYSTATE MEDICAL CENTER",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(format(cnvtdatetime(curdate,
         curtime3),"@LONGDATETIME"),3),char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.719)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Address:",char(0)))
    SET rptsd->m_y = (offsety+ 2.917)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("City, State, Zip:",char(0)))
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Home Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 3.323)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Cell Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 3.521)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Work Phone:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.719)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->pat_addr,char(0)))
    SET rptsd->m_y = (offsety+ 2.917)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->pat_city,char(0)))
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->pat_home,char(0)))
    SET rptsd->m_y = (offsety+ 3.323)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->pat_cell,char(0)))
    SET rptsd->m_y = (offsety+ 3.521)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->pat_work,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.792)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PRIMARY CONTACT:",char(0)))
    SET rptsd->m_y = (offsety+ 4.021)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name:",char(0)))
    SET rptsd->m_y = (offsety+ 4.417)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("City, State, Zip:",char(0)))
    SET rptsd->m_y = (offsety+ 4.625)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Home Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 4.823)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Cell Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 5.021)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Work Phone:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 4.021)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_name,char(0)))
    SET rptsd->m_y = (offsety+ 4.417)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_city,char(0)))
    SET rptsd->m_y = (offsety+ 4.625)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_home,char(0)))
    SET rptsd->m_y = (offsety+ 4.823)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_cell,char(0)))
    SET rptsd->m_y = (offsety+ 5.021)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_work,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 4.219)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Address:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 4.219)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_addr,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 5.219)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Relationship:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 5.219)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_reltn,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 5.521)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("SECONDARY CONTACT:",char(0)))
    SET rptsd->m_y = (offsety+ 5.740)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name:",char(0)))
    SET rptsd->m_y = (offsety+ 6.146)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("City, State, Zip:",char(0)))
    SET rptsd->m_y = (offsety+ 6.344)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Home Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 6.542)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Cell Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 6.740)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Work Phone:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 5.740)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_name,char(0)))
    SET rptsd->m_y = (offsety+ 6.146)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_city,char(0)))
    SET rptsd->m_y = (offsety+ 6.344)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_home,char(0)))
    SET rptsd->m_y = (offsety+ 6.542)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_cell,char(0)))
    SET rptsd->m_y = (offsety+ 6.740)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_work,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 5.948)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Address:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 5.948)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_addr,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 6.948)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Relationship:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 6.948)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_reltn,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 7.240)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PRIMARY INSURANCE:",char(0)))
    SET rptsd->m_y = (offsety+ 7.448)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.604
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Insurance Company:",char(0)))
    SET rptsd->m_y = (offsety+ 7.844)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Subscriber:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 7.448)
    SET rptsd->m_x = (offsetx+ 1.823)
    SET rptsd->m_width = 5.677
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_ins,char(0)))
    SET rptsd->m_y = (offsety+ 7.844)
    SET rptsd->m_x = (offsetx+ 1.823)
    SET rptsd->m_width = 5.677
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_sub,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 7.646)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Policy Number:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 7.646)
    SET rptsd->m_x = (offsetx+ 1.823)
    SET rptsd->m_width = 5.677
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->prim_num,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 8.115)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.417
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("SECONDARY INSURANCE:",char(0)))
    SET rptsd->m_y = (offsety+ 8.323)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.604
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Insurance Company:",char(0)))
    SET rptsd->m_y = (offsety+ 8.719)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Subscriber:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 8.323)
    SET rptsd->m_x = (offsetx+ 1.823)
    SET rptsd->m_width = 5.677
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_ins,char(0)))
    SET rptsd->m_y = (offsety+ 8.719)
    SET rptsd->m_x = (offsetx+ 1.823)
    SET rptsd->m_width = 5.677
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_sub,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 8.521)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Policy Number:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 8.521)
    SET rptsd->m_x = (offsetx+ 1.823)
    SET rptsd->m_width = 5.677
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->sec_num,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 8.969)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.417
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COMMENTS:",char(0)))
    SET rptsd->m_flags = 12
    SET rptsd->m_y = (offsety+ 9.198)
    SET rptsd->m_x = (offsetx+ - (0.031))
    SET rptsd->m_width = 7.531
    SET rptsd->m_height = 0.802
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(work->comments,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_EKS_CASE_MGT_DEMOG"
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _helvetica12bu0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = demog_section(0)
 SET d0 = finalizereport( $OUTDEV)
 IF (validate(eksevent,"A") != "A")
  SET log_message = build2("Case Management printout for clinical event id ",trim(build2(
      $CLINEVENTID),3)," sent to ",trim( $OUTDEV,3))
  SET retval = 100
 ENDIF
END GO
