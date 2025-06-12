CREATE PROGRAM bed_aud_surgi_loc
 SET last_mod = "120024"
 CALL echo("**** BED_AUD_THR_LOC.PRG LAST MOD: 120024 ****")
 IF (validate(bed_error_subroutines) != 0)
  GO TO bed_error_subroutines_exit
 ENDIF
 DECLARE bed_error_subroutines = i2 WITH public, constant(1)
 DECLARE max_errors = i4 WITH public, constant(20)
 DECLARE failure = c1 WITH public, constant("F")
 DECLARE no_data = c1 WITH public, constant("Z")
 DECLARE warning = c1 WITH public, constant("W")
 FREE RECORD errors
 RECORD errors(
   1 error_ind = i2
   1 error_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE checkerror(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc) = i2
 DECLARE adderrormsg(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc,s_target_obj_value=
  vc) = null
 DECLARE showerrors(s_output=vc) = null
 DECLARE ms_err_msg = vc WITH private, noconstant("")
 SET stat = error(ms_err_msg,1)
 FREE SET ms_err_msg
 SUBROUTINE checkerror(s_status,s_op_name,s_op_status,s_target_obj_name)
   DECLARE s_err_msg = vc WITH private, noconstant("")
   DECLARE l_err_code = i4 WITH private, noconstant(0)
   DECLARE l_err_cnt = i4 WITH private, noconstant(0)
   SET l_err_code = error(s_err_msg,0)
   WHILE (l_err_code > 0
    AND l_err_cnt < max_errors)
     SET errors->error_ind = 1
     SET l_err_cnt = (l_err_cnt+ 1)
     CALL adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_err_msg)
     SET l_err_code = error(s_err_msg,0)
   ENDWHILE
   RETURN(errors->error_ind)
 END ;Subroutine
 SUBROUTINE adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_target_obj_value)
   SET errors->error_cnt = (errors->error_cnt+ 1)
   SET s_status = cnvtupper(trim(substring(1,1,s_status),3))
   SET s_op_status = cnvtupper(trim(substring(1,1,s_op_status),3))
   IF (textlen(s_status) > 0
    AND (errors->status_data.status != failure))
    SET errors->status_data.status = s_status
   ENDIF
   IF ((errors->status_data.status=failure))
    SET errors->error_ind = 1
   ENDIF
   IF (((s_status=failure) OR (s_op_status=failure)) )
    CALL echo(concat("SCRIPT FAILURE - ",trim(s_target_obj_value,3)))
   ENDIF
   IF (size(errors->status_data.subeventstatus,5) < max_errors)
    SET stat = alter(errors->status_data.subeventstatus,max_errors)
   ENDIF
   SET errors->status_data.subeventstatus[errors->error_cnt].operationname = trim(substring(1,25,
     s_op_name),3)
   SET errors->status_data.subeventstatus[errors->error_cnt].operationstatus = s_op_status
   SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectname = trim(substring(1,25,
     s_target_obj_name),3)
   SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue = trim(
    s_target_obj_value,3)
 END ;Subroutine
 SUBROUTINE showerrors(s_output)
  DECLARE s_output_dest = vc WITH protect, noconstant(cnvtupper(trim(s_output,3)))
  IF ((errors->error_cnt > 0))
   SET stat = alter(errors->status_data.subeventstatus,errors->error_cnt)
   IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
    SET s_output_dest = "NOFORMS"
   ENDIF
   IF (s_output_dest="NOFORMS")
    CALL echo("")
   ENDIF
   SELECT INTO value(s_output_dest)
    operation_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.subeventstatus[(d.seq - 1)].
     operationname), target_object_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.
     subeventstatus[(d.seq - 1)].targetobjectname), status = evaluate(d.seq,1,errors->status_data.
     status,errors->status_data.subeventstatus[(d.seq - 1)].operationstatus),
    error_message = trim(substring(1,100,evaluate(d.seq,1,concat("SCRIPT ERROR LOG FOR: ",trim(
         curprog,3)),errors->status_data.subeventstatus[(d.seq - 1)].targetobjectvalue)))
    FROM (dummyt d  WITH seq = value((errors->error_cnt+ 1)))
    PLAN (d)
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
 END ;Subroutine
#bed_error_subroutines_exit
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
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE function_fail = i2 WITH constant(0), protected
 DECLARE function_success = i2 WITH constant(1), protected
 DECLARE column_datatype_date = i2 WITH constant(4), protected
 DECLARE column_datatype_number = i2 WITH constant(3), protected
 DECLARE column_datatype_double = i2 WITH constant(2), protected
 DECLARE column_datatype_string = i2 WITH constant(1), protected
 DECLARE column_hide_no = i2 WITH constant(0), protected
 DECLARE column_hide_yes = i2 WITH constant(1), protected
 DECLARE cell_display_regular = i2 WITH constant(0), protected
 DECLARE cell_display_bold = i2 WITH constant(1), protected
 DECLARE codevalue_matchfield_display = i2 WITH constant(0), protected
 DECLARE codevalue_matchfield_displaykey = i2 WITH constant(1), protected
 DECLARE codevalue_matchfield_cdfmeaning = i2 WITH constant(2), protected
 DECLARE codevalue_matchfield_description = i2 WITH constant(3), protected
 DECLARE column_count = i4 WITH noconstant(0), protected
 DECLARE row_count = i4 WITH noconstant(0), protected
 DECLARE resultstring = vc WITH noconstant(" "), protected
 IF (validate(reply)=0)
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE addcolumn(headertext=vc,datatype=i2,hideind=i2) = i2
 DECLARE addrows(numrows=i4) = i2
 DECLARE deleterows(numrows=i4) = i2
 DECLARE setcellvalue(columnindex=i4,rowindex=i4,column_datatype=i2,datevalue=q8,numbervalue=i4,
  doublevalue=f8,stringvalue=vc,displayflag=i2) = i2
 DECLARE getcolumncount() = i4
 DECLARE getrowcount() = i4
 DECLARE getcodevalueby(codeset=i4,matchfield=i2,matchstring=vc) = f8
 DECLARE getcodedisplay(codevalue=f8) = vc
 DECLARE getcodedescription(codevalue=f8) = vc
 DECLARE getcodecdfmeaning(codevalue=f8) = vc
 SUBROUTINE addcolumn(headertext,datatype,hideind)
   SET column_count = (column_count+ 1)
   SET stat = alterlist(reply->collist,column_count)
   SET reply->collist[column_count].header_text = headertext
   CASE (datatype)
    OF column_datatype_date:
    OF column_datatype_number:
    OF column_datatype_double:
    OF column_datatype_string:
     SET reply->collist[column_count].data_type = datatype
    ELSE
     CALL adderrormsg(failure,"AddColumn",warning,"Invalid_Parameter_Value",
      "Value specified for 'DataType' parameter is invalid")
     RETURN(function_fail)
   ENDCASE
   CASE (hideind)
    OF column_hide_no:
    OF column_hide_yes:
     SET reply->collist[column_count].hide_ind = hideind
    ELSE
     CALL adderrormsg(failure,"AddColumn",warning,"Invalid_Parameter_Value",
      "Value specified for 'HindInd' parameter is invalid")
     RETURN(function_fail)
   ENDCASE
   RETURN(function_success)
 END ;Subroutine
 SUBROUTINE addrows(numrows)
   IF (numrows > 0)
    SET totalrows = (row_count+ numrows)
    SET stat = alterlist(reply->rowlist,totalrows)
    FOR (rowlistcnt = row_count TO totalrows)
      SET stat = alterlist(reply->rowlist[rowlistcnt].celllist,column_count)
    ENDFOR
    SET row_count = totalrows
    RETURN(function_success)
   ENDIF
   CALL adderrormsg(failure,"AddRows",warning,"Invalid_Parameter_Value",
    "Value specified for 'NumRows' parameter must be > 0")
   RETURN(function_fail)
 END ;Subroutine
 SUBROUTINE deleterows(rowindex)
   IF (rowindex > 0)
    IF (rowindex > row_count)
     SET row_count = 0
    ELSE
     SET row_count = rowindex
    ENDIF
    SET stat = alterlist(reply->rowlist,row_count)
    RETURN(function_success)
   ENDIF
   CALL adderrormsg(failure,"DeleteRows",warning,"Invalid_Parameter_Value",
    "Value specified for 'RowIndex' parameter must be > 0")
   RETURN(function_fail)
 END ;Subroutine
 SUBROUTINE setcellvalue(columnindex,rowindex,column_datatype,datevalue,numbervalue,doublevalue,
  stringvalue,displayflag)
  IF (columnindex > 0
   AND columnindex <= column_count)
   IF (rowindex > 0
    AND rowindex <= row_count)
    IF ((reply->collist[columnindex].data_type=column_datatype))
     CASE (column_datatype)
      OF column_datatype_date:
       SET reply->rowlist[rowindex].celllist[columnindex].date_value = datevalue
      OF column_datatype_number:
       SET reply->rowlist[rowindex].celllist[columnindex].nbr_value = numbervalue
      OF column_datatype_double:
       SET reply->rowlist[rowindex].celllist[columnindex].double_value = doublevalue
      OF column_datatype_string:
       SET reply->rowlist[rowindex].celllist[columnindex].string_value = stringvalue
     ENDCASE
     CASE (displayflag)
      OF cell_display_regular:
      OF cell_display_bold:
       SET reply->rowlist[rowindex].celllist[columnindex].display_flag = displayflag
      ELSE
       CALL adderrormsg(failure,"SetCellValue",warning,"Invalid_Parameter_Value",
        "Value specified for 'DisplayFlag' parameter is invalid")
       RETURN(function_fail)
     ENDCASE
     RETURN(function_success)
    ELSE
     CALL adderrormsg(failure,"SetCellValue",warning,"Invalid_Parameter_Value",
      "Value specified for 'Column_DataType' does not match the datetype of the cell")
    ENDIF
   ELSE
    CALL adderrormsg(failure,"SetCellValue",warning,"Invalid_Parameter_Value",
     "Value specified for 'RowIndex' parameter must be > 0 and <= Total Rows")
   ENDIF
  ELSE
   CALL adderrormsg(failure,"SetCellValue",warning,"Invalid_Parameter_Value",
    "Value specified for 'ColumnIndex' parameter must be > 0 and <= Total Columns")
  ENDIF
  RETURN(function_fail)
 END ;Subroutine
 SUBROUTINE getcolumncount(null)
   RETURN(column_count)
 END ;Subroutine
 SUBROUTINE getrowcount(null)
   RETURN(row_count)
 END ;Subroutine
 SUBROUTINE getcodevalueby(codeset,matchfield,matchstring)
   SET codevalue = 0.0
   SET codevaluecnt = 0
   IF (codeset > 0)
    IF (textlen(trim(matchstring)) > 0)
     CASE (matchfield)
      OF codevalue_matchfield_display:
       SELECT INTO "nl:"
        FROM code_value cv
        WHERE cv.code_set=codeset
         AND cv.display=matchstring
         AND cv.active_ind=1
        DETAIL
         codevaluecnt = (codevaluecnt+ 1), codevalue = cv.code_value
        WITH nocounter
       ;end select
      OF codevalue_matchfield_displaykey:
       SELECT INTO "nl:"
        FROM code_value cv
        WHERE cv.code_set=codeset
         AND cv.display_key=matchstring
         AND cv.active_ind=1
        DETAIL
         codevaluecnt = (codevaluecnt+ 1), codevalue = cv.code_value
        WITH nocounter
       ;end select
      OF codevalue_matchfield_cdfmeaning:
       SELECT INTO "nl:"
        FROM code_value cv
        WHERE cv.code_set=codeset
         AND cv.cdf_meaning=matchstring
         AND cv.active_ind=1
        DETAIL
         codevaluecnt = (codevaluecnt+ 1), codevalue = cv.code_value
        WITH nocounter
       ;end select
      OF codevalue_matchfield_description:
       SELECT INTO "nl:"
        FROM code_value cv
        WHERE cv.code_set=codeset
         AND cv.description=matchstring
         AND cv.active_ind=1
        DETAIL
         codevaluecnt = (codevaluecnt+ 1), codevalue = cv.code_value
        WITH nocounter
       ;end select
      ELSE
       CALL adderrormsg(failure,"GetCodeValueBy",warning,"Invalid_Parameter_Value",
        "Value specified for 'MatchField' parameter is invalid")
       RETURN(function_fail)
     ENDCASE
     IF (codevaluecnt=0)
      CALL adderrormsg(failure,"GetCodeValueBy",no_data,"Zero_Results",
       "No code value was found for specified 'CodeSet'/'MatchField'/'MatchString' combination")
     ELSE
      IF (codevaluecnt > 1)
       CALL adderrormsg(failure,"GetCodeValueBy",warning,"Too_Many_Results",
        "More than 1 code value was found for specified 'CodeSet'/'MatchField'/'MatchString' combination"
        )
       RETURN(function_fail)
      ENDIF
     ENDIF
     RETURN(codevalue)
    ELSE
     CALL adderrormsg(failure,"GetCodeValueBy",warning,"Invalid_Parameter_Value",
      "Value specified for 'MatchString' parameter cannot be null")
    ENDIF
   ELSE
    CALL adderrormsg(failure,"GetCodeValueBy",warning,"Invalid_Parameter_Value",
     "Value specified for 'CodeSet' parameter must be > 0")
   ENDIF
   RETURN(function_fail)
 END ;Subroutine
 SUBROUTINE getcodedisplay(codevalue)
   SET resultstring = ""
   IF (codevalue > 0.0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_value=codevalue
      AND cv.active_ind=1
     DETAIL
      resultstring = cv.display
     WITH nocounter
    ;end select
    SET resultstring = trim(resultstring,3)
    IF (textlen(resultstring)=0)
     CALL adderrormsg(failure,"GetCodeDisplay",no_data,"Zero_Results",
      "No display value was found for specified code value")
    ENDIF
   ELSE
    CALL adderrormsg(failure,"GetCodeDisplay",warning,"Invalid_Parameter_Value",
     "Value specified for 'CodeValue' parameter must be > 0")
   ENDIF
   RETURN(resultstring)
 END ;Subroutine
 SUBROUTINE getcodedescription(codevalue)
   SET resultstring = ""
   IF (codevalue > 0.0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_value=codevalue
      AND cv.active_ind=1
     DETAIL
      resultstring = cv.description
     WITH nocounter
    ;end select
    SET resultstring = trim(resultstring,3)
    IF (textlen(resultstring)=0)
     CALL adderrormsg(failure,"GetCodeDescription",no_data,"Zero_Results",
      "No description value was found for specified code value")
    ENDIF
   ELSE
    CALL adderrormsg(failure,"GetCodeDescription",warning,"Invalid_Parameter_Value",
     "Value specified for 'CodeValue' parameter must be > 0")
   ENDIF
   RETURN(resultstring)
 END ;Subroutine
 SUBROUTINE getcodecdfmeaning(codevalue)
   SET resultstring = ""
   IF (codevalue > 0.0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_value=codevalue
      AND cv.active_ind=1
     DETAIL
      resultstring = cv.cdf_meaning
     WITH nocounter
    ;end select
    SET resultstring = trim(resultstring,3)
    IF (textlen(resultstring)=0)
     CALL adderrormsg(failure,"GetCodeCDFMeaning",no_data,"Zero_Results",
      "No cdf_meaning value was found for specified code value")
    ENDIF
   ELSE
    CALL adderrormsg(failure,"GetCodeCDFMeaning",warning,"Invalid_Parameter_Value",
     "Value specified for 'CodeValue' parameter must be > 0")
   ENDIF
   RETURN(resultstring)
 END ;Subroutine
 DECLARE resourcegrouptype_institution = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"INSTITUTION")), protected
 DECLARE resourcegrouptype_department = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"DEPARTMENT")), protected
 DECLARE resourcegrouptype_surgarea = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"SURGAREA")), protected
 DECLARE resourcegrouptype_surgstage = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"SURGSTAGE")), protected
 DECLARE serviceresourcetype_surgop = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"SURGOP")), protected
 DECLARE serviceresourcetype_surgarea = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"SURGAREA")), protected
 DECLARE column_01_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_01_Header_Text","Facility Display")), protected
 DECLARE column_02_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_02_Header_Text","Facility Description")), protected
 DECLARE column_03_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_03_Header_Text","Department Display")), protected
 DECLARE column_04_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_04_Header_Text","Department Description")), protected
 DECLARE column_05_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_05_Header_Text","Surgical Area Display")), protected
 DECLARE column_06_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_06_Header_Text","Surgical Area Description")), protected
 DECLARE column_07_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_07_Header_Text","Surgical Case Number Prefix")), protected
 DECLARE column_08_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_08_Header_Text","Staging Area Display")), protected
 DECLARE column_09_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_09_Header_Text","Staging Area Description")), protected
 DECLARE column_10_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_10_Header_Text","Surgical Operating Room Display")), protected
 DECLARE column_11_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_11_Header_Text","Surgical Operating Room Description")), protected
 SET stat = addcolumn(column_01_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_02_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_03_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_04_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_05_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_06_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_07_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_08_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_09_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_10_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_11_header_text,column_datatype_string,column_hide_no)
 SELECT INTO "nl:"
  FROM resource_group rg_in,
   resource_group rg_dp,
   resource_group rg_sa,
   resource_group rg_ss,
   service_resource sr_op,
   service_resource sr_pf,
   code_value cv_in,
   code_value cv_dp,
   code_value cv_sa,
   code_value cv_ss,
   code_value cv_op
  PLAN (rg_in
   WHERE rg_in.resource_group_type_cd=resourcegrouptype_institution
    AND rg_in.active_ind=1)
   JOIN (cv_in
   WHERE cv_in.code_value=rg_in.parent_service_resource_cd
    AND cv_in.active_ind=1)
   JOIN (rg_dp
   WHERE rg_dp.parent_service_resource_cd=rg_in.child_service_resource_cd
    AND rg_dp.resource_group_type_cd=resourcegrouptype_department
    AND rg_dp.active_ind=1)
   JOIN (cv_dp
   WHERE cv_dp.code_value=rg_dp.parent_service_resource_cd
    AND cv_dp.active_ind=1)
   JOIN (cv_sa
   WHERE cv_sa.code_value=rg_dp.child_service_resource_cd
    AND cv_sa.active_ind=1
    AND cv_sa.cdf_meaning="SURGAREA")
   JOIN (rg_sa
   WHERE rg_sa.parent_service_resource_cd=rg_dp.child_service_resource_cd
    AND rg_sa.resource_group_type_cd=resourcegrouptype_surgarea
    AND rg_sa.active_ind=1)
   JOIN (cv_ss
   WHERE cv_ss.code_value=rg_sa.child_service_resource_cd
    AND cv_ss.active_ind=rg_sa.active_ind)
   JOIN (rg_ss
   WHERE rg_ss.parent_service_resource_cd=outerjoin(rg_sa.child_service_resource_cd)
    AND rg_ss.resource_group_type_cd=outerjoin(resourcegrouptype_surgstage)
    AND rg_ss.active_ind=outerjoin(1))
   JOIN (cv_op
   WHERE cv_op.code_value=outerjoin(rg_ss.child_service_resource_cd)
    AND cv_op.active_ind=outerjoin(rg_ss.active_ind))
   JOIN (sr_op
   WHERE sr_op.service_resource_cd=outerjoin(rg_ss.child_service_resource_cd)
    AND sr_op.service_resource_type_cd=outerjoin(serviceresourcetype_surgop)
    AND sr_op.active_ind=outerjoin(rg_ss.active_ind))
   JOIN (sr_pf
   WHERE sr_pf.service_resource_cd=outerjoin(rg_dp.child_service_resource_cd)
    AND sr_pf.service_resource_type_cd=outerjoin(serviceresourcetype_surgarea)
    AND sr_pf.active_ind=outerjoin(1))
  ORDER BY cv_in.display, cv_dp.display, cv_sa.display,
   cv_ss.display, cv_op.display
  HEAD REPORT
   rowindex = 0
  DETAIL
   CALL echo(build("cvssind-",cv_ss.active_ind)),
   CALL echo(build("cv_ss.display",cv_ss.display)),
   CALL echo(build("rgssind-",rg_ss.active_ind)),
   CALL echo(build("rg_ss.parent_service_resource_cd",rg_ss.parent_service_resource_cd)),
   CALL echo(build("rg_sa.child_service_resource_cd",rg_sa.child_service_resource_cd)), rowindex = (
   rowindex+ 1)
   IF (mod(rowindex,100)=1)
    stat = addrows(100)
   ENDIF
   stat = setcellvalue(1,rowindex,column_datatype_string,null,0,
    0.0,cv_in.display,cell_display_regular), stat = setcellvalue(2,rowindex,column_datatype_string,
    null,0,
    0.0,cv_in.description,cell_display_regular), stat = setcellvalue(3,rowindex,
    column_datatype_string,null,0,
    0.0,cv_dp.display,cell_display_regular),
   stat = setcellvalue(4,rowindex,column_datatype_string,null,0,
    0.0,cv_dp.description,cell_display_regular), stat = setcellvalue(5,rowindex,
    column_datatype_string,null,0,
    0.0,cv_sa.display,cell_display_regular), stat = setcellvalue(6,rowindex,column_datatype_string,
    null,0,
    0.0,cv_sa.description,cell_display_regular),
   stat = setcellvalue(7,rowindex,column_datatype_string,null,0,
    0.0,sr_pf.accn_site_prefix,cell_display_regular), stat = setcellvalue(8,rowindex,
    column_datatype_string,null,0,
    0.0,cv_ss.display,cell_display_regular), stat = setcellvalue(9,rowindex,column_datatype_string,
    null,0,
    0.0,cv_ss.description,cell_display_regular),
   stat = setcellvalue(10,rowindex,column_datatype_string,null,0,
    0.0,cv_op.display,cell_display_regular), stat = setcellvalue(11,rowindex,column_datatype_string,
    null,0,
    0.0,cv_op.description,cell_display_regular)
  FOOT REPORT
   stat = deleterows(rowindex)
  WITH nocounter
 ;end select
END GO
