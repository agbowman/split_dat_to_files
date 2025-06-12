CREATE PROGRAM bhsmaradfold:dba
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
 EXECUTE reportrtl
 CALL echo("*****START OF FOLDER ADDRESSES RECORD*****")
 FREE RECORD a_fold
 RECORD a_fold(
   1 facility_name = vc
   1 facility_disp = vc
   1 fold_address = vc
   1 fold_city = vc
   1 fold_state = vc
   1 fold_zip = vc
 )
 CALL echo("*****START OF FOLDER DATA*****")
 FREE RECORD a_folder
 RECORD a_folder(
   1 file_nbr = vc
   1 lib_grp = vc
   1 image_class = vc
   1 volume = vc
   1 folder_type = vc
   1 folder_number = vc
   1 bc_fold_nbr = vc
 )
 CALL echo("*****START OF FOLDER PATIENT RECORD*****")
 FREE RECORD a_fold_patient
 RECORD a_fold_patient(
   1 person_id = f8
   1 full_name = vc
   1 last_name = vc
   1 first_name = vc
   1 dob = dq8
   1 age = vc
   1 short_age = c10
   1 gender = vc
   1 short_gender = c10
   1 comm_med_nbr = vc
   1 med_nbr = vc
   1 person_ssn = vc
   1 bc_med_num = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE subfolder(ncalc=i2) = f8 WITH protect
 DECLARE subfolderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE masterjacket(ncalc=i2) = f8 WITH protect
 DECLARE masterjacketabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _default160 = i4 WITH noconstant(0), protect
 DECLARE _default180 = i4 WITH noconstant(0), protect
 DECLARE _default140 = i4 WITH noconstant(0), protect
 DECLARE _default100 = i4 WITH noconstant(0), protect
 DECLARE _default480 = i4 WITH noconstant(0), protect
 DECLARE _default240 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE subfolder(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = subfolderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE subfolderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(5.790000), private
   DECLARE __a_folder_folder_number = vc WITH noconstant(build2(a_folder->folder_number,char(0))),
   protect
   DECLARE __a_fold_facility_name = vc WITH noconstant(build2(a_fold->facility_name,char(0))),
   protect
   DECLARE __a_fold_patient_last_name = vc WITH noconstant(build2(a_fold_patient->last_name,char(0))),
   protect
   DECLARE __a_fold_patient_first_name = vc WITH noconstant(build2(a_fold_patient->first_name,char(0)
     )), protect
   DECLARE __a_fold_patient_dob = vc WITH noconstant(build2(format(a_fold_patient->dob,
      "@SHORTDATETIME"),char(0))), protect
   DECLARE __a_fold_patient_gender = vc WITH noconstant(build2(a_fold_patient->gender,char(0))),
   protect
   DECLARE __a_fold_patient_med_nbr = vc WITH noconstant(build2(a_fold_patient->med_nbr,char(0))),
   protect
   DECLARE __a_folder_folder_type = vc WITH noconstant(build2(a_folder->folder_type,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 180
    SET rptsd->m_y = (offsety+ 4.875)
    SET rptsd->m_x = (offsetx+ 3.525)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_default140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_folder_folder_number)
    SET rptsd->m_y = (offsety+ 4.875)
    SET rptsd->m_x = (offsetx+ 4.473)
    SET rptsd->m_width = 0.823
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Folder #:",char(0)))
    SET rptsd->m_rotationangle = 90
    SET rptsd->m_y = (offsety+ 4.063)
    SET rptsd->m_x = (offsetx+ 1.213)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_facility_name)
    SET rptsd->m_y = (offsety+ 4.063)
    SET rptsd->m_x = (offsetx+ 2.838)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.438
    SET _dummyfont = uar_rptsetfont(_hreport,_default240)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_last_name)
    SET rptsd->m_y = (offsety+ 4.063)
    SET rptsd->m_x = (offsetx+ 3.338)
    SET rptsd->m_width = 3.313
    SET rptsd->m_height = 0.500
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_first_name)
    SET rptsd->m_y = (offsety+ 3.573)
    SET rptsd->m_x = (offsetx+ 3.962)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_default100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_dob)
    SET rptsd->m_y = (offsety+ 3.583)
    SET rptsd->m_x = (offsetx+ 4.213)
    SET rptsd->m_width = 1.833
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_gender)
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 1.838)
    SET rptsd->m_width = 3.750
    SET rptsd->m_height = 1.000
    SET _dummyfont = uar_rptsetfont(_hreport,_default480)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_med_nbr)
    SET rptsd->m_y = (offsety+ 4.021)
    SET rptsd->m_x = (offsetx+ 3.962)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_default100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 4.021)
    SET rptsd->m_x = (offsetx+ 4.213)
    SET rptsd->m_width = 0.333
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sex:",char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 4.338)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_folder_folder_type)
    SET rptsd->m_y = (offsety+ 4.521)
    SET rptsd->m_x = (offsetx+ 2.213)
    SET rptsd->m_width = 0.646
    SET rptsd->m_height = 0.323
    SET _dummyfont = uar_rptsetfont(_hreport,_default180)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MR#:",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code128,(offsetx+ 1.775),(offsety+ 5.000))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 2.75
    SET rptbce->m_height = 0.63
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 3
    SET rptbce->m_bprintinterp = 0
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(a_folder->bc_fold_nbr,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE masterjacket(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = masterjacketabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE masterjacketabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(5.770000), private
   DECLARE __a_fold_facility_name = vc WITH noconstant(build2(a_fold->facility_name,char(0))),
   protect
   DECLARE __a_folder_folder_number = vc WITH noconstant(build2(a_folder->folder_number,char(0))),
   protect
   DECLARE __a_fold_patient_last_name = vc WITH noconstant(build2(a_fold_patient->last_name,char(0))),
   protect
   DECLARE __a_fold_patient_first_name = vc WITH noconstant(build2(a_fold_patient->first_name,char(0)
     )), protect
   DECLARE __a_fold_patient_dob = vc WITH noconstant(build2(format(a_fold_patient->dob,
      "@SHORTDATETIME"),char(0))), protect
   DECLARE __a_fold_patient_gender = vc WITH noconstant(build2(a_fold_patient->gender,char(0))),
   protect
   DECLARE __a_fold_patient_med_nbr = vc WITH noconstant(build2(a_fold_patient->med_nbr,char(0))),
   protect
   DECLARE __a_folder_folder_type = vc WITH noconstant(build2(a_folder->folder_type,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code128,(offsetx+ 1.713),(offsety+ 4.875))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 2.75
    SET rptbce->m_height = 0.70
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 3
    SET rptbce->m_bprintinterp = 0
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(a_folder->bc_fold_nbr,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 90
    SET rptsd->m_y = (offsety+ 4.125)
    SET rptsd->m_x = (offsetx+ 1.213)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_default140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_facility_name)
    SET rptsd->m_rotationangle = 180
    SET rptsd->m_y = (offsety+ 4.823)
    SET rptsd->m_x = (offsetx+ 4.379)
    SET rptsd->m_width = 0.729
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Folder #:",char(0)))
    SET rptsd->m_y = (offsety+ 4.823)
    SET rptsd->m_x = (offsetx+ 3.463)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_folder_folder_number)
    SET rptsd->m_rotationangle = 90
    SET rptsd->m_y = (offsety+ 4.261)
    SET rptsd->m_x = (offsetx+ 2.838)
    SET rptsd->m_width = 3.198
    SET rptsd->m_height = 0.438
    SET _dummyfont = uar_rptsetfont(_hreport,_default240)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_last_name)
    SET rptsd->m_y = (offsety+ 4.251)
    SET rptsd->m_x = (offsetx+ 3.338)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.438
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_first_name)
    SET rptsd->m_y = (offsety+ 3.823)
    SET rptsd->m_x = (offsetx+ 3.962)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_default100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_dob)
    SET rptsd->m_y = (offsety+ 3.833)
    SET rptsd->m_x = (offsetx+ 4.213)
    SET rptsd->m_width = 1.208
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_gender)
    SET rptsd->m_y = (offsety+ 4.531)
    SET rptsd->m_x = (offsetx+ 2.338)
    SET rptsd->m_width = 0.531
    SET rptsd->m_height = 0.385
    SET _dummyfont = uar_rptsetfont(_hreport,_default160)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MR#:",char(0)))
    SET rptsd->m_y = (offsety+ 3.875)
    SET rptsd->m_x = (offsetx+ 1.963)
    SET rptsd->m_width = 3.875
    SET rptsd->m_height = 1.000
    SET _dummyfont = uar_rptsetfont(_hreport,_default480)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_fold_patient_med_nbr)
    SET rptsd->m_y = (offsety+ 4.261)
    SET rptsd->m_x = (offsetx+ 3.962)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_default100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 4.213)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sex:",char(0)))
    SET rptsd->m_y = (offsety+ 1.376)
    SET rptsd->m_x = (offsetx+ 4.338)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_folder_folder_type)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHSMARADFOLD"
   SET rptreport->m_pagewidth = 5.00
   SET rptreport->m_pageheight = 6.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.10
   SET rptreport->m_marginright = 0.10
   SET rptreport->m_margintop = 0.20
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
   SET rptfont->m_pointsize = 14
   SET _default140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 24
   SET _default240 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 48
   SET _default480 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 18
   SET _default180 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET _default160 = uar_rptcreatefont(_hreport,rptfont)
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
 IF (size(data->req[req_ndx].sections[sect_ndx].folder_info,5) > 0)
  SET seq_id = cnvtstring(data->req[req_ndx].sections[sect_ndx].folder_info[1].seq_object_id)
  SET tempdir = "cer_temp:radfold"
  IF (validate(_outfile,"1") != "1")
   SET tempfile = _outfile
  ELSE
   SET tempfile = concat(tempdir,"_",trim(cnvtstring(curtime3)),"_",trim(seq_id),
    ".dat")
  ENDIF
  CALL echo(value(tempfile))
  CALL initializereport(0)
  SELECT INTO "nl:"
   DETAIL
    CALL echo("*****START OF FOLDER PATIENT DATA*****"), a_fold_patient->person_id = data->req[
    req_ndx].patient_data.person_id, a_fold_patient->full_name = data->req[req_ndx].patient_data.name,
    a_fold_patient->last_name = data->req[req_ndx].patient_data.name_last, a_fold_patient->first_name
     = data->req[req_ndx].patient_data.name_first, a_fold_patient->dob = data->req[req_ndx].
    patient_data.dob,
    a_fold_patient->age = data->req[req_ndx].patient_data.age, a_fold_patient->short_age = data->req[
    req_ndx].patient_data.short_age, a_fold_patient->gender = data->req[req_ndx].patient_data.gender,
    a_fold_patient->short_gender = data->req[req_ndx].patient_data.short_gender, a_fold_patient->
    comm_med_nbr = data->req[req_ndx].patient_data.community_med_nbr, a_fold_patient->med_nbr = data
    ->req[req_ndx].patient_data.person_alias,
    a_fold_patient->person_ssn = data->req[req_ndx].patient_data.person_ssn
    IF (size(trim(data->req[req_ndx].patient_data.person_alias)) > 0)
     a_fold_patient->bc_med_num = concat("*",trim(data->req[req_ndx].patient_data.person_alias),"*")
    ELSE
     a_fold_patient->bc_med_num = " "
    ENDIF
    FOR (fold_ndx = 1 TO size(data->req[req_ndx].sections[sect_ndx].folder_info,5))
     FOR (label_nbr_cnt = 1 TO data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
     folder_label_cnt)
       CALL echo("*****START OF FOLDER DATA*****"), a_folder->file_nbr = data->req[req_ndx].sections[
       sect_ndx].folder_info[fold_ndx].filing_nbr, a_folder->lib_grp = data->req[req_ndx].sections[
       sect_ndx].folder_info[fold_ndx].image_lib_grp_display,
       a_folder_image_class = data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
       image_class_disp, a_folder->volume = cnvtstring(data->req[req_ndx].sections[sect_ndx].
        folder_info[fold_ndx].image_class_volume), a_folder->folder_type = data->req[req_ndx].
       sections[sect_ndx].folder_info[fold_ndx].image_class_desc,
       a_folder->folder_number = build(data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
        filing_nbr,"-",data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
        image_lib_grp_display,"-",data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
        image_class_disp,
        "-",cnvtstring(data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].image_class_volume
         ))
       IF ((data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].seq_object_id > 0))
        bc_string = trim(cnvtstring(data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
          seq_object_id)), bc_size = size(bc_string)
        IF (even(bc_size)=0)
         bc_string = build("0",trim(cnvtstring(data->req[req_ndx].sections[sect_ndx].folder_info[
            fold_ndx].seq_object_id)))
        ENDIF
        a_folder->bc_fold_nbr = build("$",bc_string,"%")
       ELSE
        a_folder->bc_fold_nbr = " "
       ENDIF
       CALL echo("****************START OF FOLDER ADDRESSES DATA********************")
       IF ((data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_fac_desc > " "))
        a_fold->facility_name = data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
        folder_fac_desc
       ELSE
        a_fold->facility_name = " "
       ENDIF
       IF ((data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_fac_disp > " "))
        a_fold->facility_disp = data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
        folder_fac_disp
       ELSE
        a_fold->facility_disp = " "
       ENDIF
       IF ((data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_addr > " "))
        a_fold->fold_address = data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
        folder_addr
       ELSE
        a_fold->fold_address = " "
       ENDIF
       IF ((data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_city > " "))
        a_fold->fold_city = data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_city
       ELSE
        a_fold->fold_city = " "
       ENDIF
       IF ((data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_state > " "))
        a_fold->fold_state = data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_state
       ELSE
        a_fold->fold_state = " "
       ENDIF
       IF ((data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_zip > " "))
        a_fold->fold_zip = data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].folder_zip
       ELSE
        a_fold->fold_zip = " "
       ENDIF
       IF ((data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].image_class_type_cd=data->
       req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].parent_image_class_type_cd))
        dummy_val = masterjacket(rpt_render)
       ELSE
        dummy_val = subfolder(rpt_render)
       ENDIF
       IF ((label_nbr_cnt < data->req[req_ndx].sections[sect_ndx].folder_info[fold_ndx].
       folder_label_cnt))
        CALL pagebreak(0), row + 1
       ENDIF
     ENDFOR
     ,
     IF (fold_ndx < size(data->req[req_ndx].sections[sect_ndx].folder_info,5))
      CALL pagebreak(0), row + 1
     ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  CALL finalizereport(tempfile)
  IF ((working_array->print_flag != "N"))
   IF ((working_array->debug_flag="Y"))
    SET spool value(trim(tempfile))  $4 WITH notify
   ELSE
    SET spool value(concat(trim(tempfile)))  $4 WITH deleted
   ENDIF
  ENDIF
 ENDIF
END GO
