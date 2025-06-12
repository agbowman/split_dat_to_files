CREATE PROGRAM bed_aud_surgi_appt_books
 SET last_mod = "120023"
 CALL echo("**** BED_AUD_THEATRE_APPT_BOOKS.PRG LAST MOD: 120023 ****")
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
 RECORD temp(
   1 tqual[*]
     2 bookshelf = vc
     2 book = vc
     2 seq_nbr = i4
     2 surgical_area = vc
     2 person_id = f8
     2 item_id = f8
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 resource_type = vc
     2 surgical_resource_ind = i2
 )
 DECLARE serviceresourcetype_surgop = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"SURGOP")), protected
 DECLARE resourcegrouptype_surgstage = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"SURGSTAGE")), protected
 DECLARE resourcegrouptype_surgarea = f8 WITH constant(getcodevalueby(223,
   codevalue_matchfield_cdfmeaning,"SURGAREA")), protected
 DECLARE currentdatetime = q8 WITH constant(cnvtdatetime(curdate,curtime3)), protected
 DECLARE column_01_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_01_Header_Text","Bookshelf")), protected
 DECLARE column_02_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_02_Header_Text","Book")), protected
 DECLARE column_03_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_03_Header_Text","Surgical Area")), protected
 DECLARE column_04_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_04_Header_Text","Resource")), protected
 DECLARE column_05_header_text = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "Column_05_Header_Text","Resource Type")), protected
 SET stat = addcolumn(column_01_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_02_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_03_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_04_header_text,column_datatype_string,column_hide_no)
 SET stat = addcolumn(column_05_header_text,column_datatype_string,column_hide_no)
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM sch_resource schr,
   resource_group rg_ss,
   resource_group rg_sa,
   sch_book_list sbl_a,
   sch_appt_book sab_a,
   sch_book_list sbl_b,
   sch_appt_book sab_b,
   code_value cv_sa,
   code_value cv_sr
  PLAN (schr
   WHERE schr.beg_effective_dt_tm <= cnvtdatetime(currentdatetime)
    AND schr.end_effective_dt_tm >= cnvtdatetime(currentdatetime)
    AND schr.active_ind=1)
   JOIN (sbl_a
   WHERE sbl_a.resource_cd=schr.resource_cd
    AND sbl_a.active_ind=1)
   JOIN (sab_a
   WHERE sab_a.appt_book_id=sbl_a.appt_book_id
    AND sab_a.active_ind=1)
   JOIN (sbl_b
   WHERE sbl_b.child_appt_book_id=outerjoin(sbl_a.appt_book_id)
    AND sbl_b.active_ind=outerjoin(1))
   JOIN (sab_b
   WHERE sab_b.appt_book_id=outerjoin(sbl_b.appt_book_id))
   JOIN (rg_ss
   WHERE rg_ss.child_service_resource_cd=outerjoin(schr.service_resource_cd)
    AND rg_ss.resource_group_type_cd=outerjoin(resourcegrouptype_surgstage)
    AND rg_ss.active_ind=outerjoin(1))
   JOIN (rg_sa
   WHERE rg_sa.child_service_resource_cd=outerjoin(rg_ss.parent_service_resource_cd)
    AND rg_sa.resource_group_type_cd=outerjoin(resourcegrouptype_surgarea)
    AND rg_sa.active_ind=outerjoin(1))
   JOIN (cv_sa
   WHERE cv_sa.code_value=outerjoin(rg_sa.parent_service_resource_cd)
    AND cv_sa.active_ind=outerjoin(1))
   JOIN (cv_sr
   WHERE cv_sr.code_value=outerjoin(schr.service_resource_cd)
    AND cv_sr.active_ind=outerjoin(1))
  ORDER BY sab_b.mnemonic, sab_a.mnemonic, sbl_a.seq_nbr,
   cv_sr.display
  DETAIL
   IF (sab_b.mnemonic > " "
    AND sab_b.active_ind=0)
    tcnt = tcnt
   ELSE
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt)
    IF (sab_b.mnemonic > " ")
     temp->tqual[tcnt].bookshelf = sab_b.mnemonic
    ELSE
     temp->tqual[tcnt].bookshelf = sab_a.mnemonic
    ENDIF
    temp->tqual[tcnt].book = sab_a.mnemonic, temp->tqual[tcnt].seq_nbr = sbl_a.seq_nbr, temp->tqual[
    tcnt].surgical_area = cv_sa.display,
    temp->tqual[tcnt].person_id = schr.person_id, temp->tqual[tcnt].item_id = schr.item_id, temp->
    tqual[tcnt].service_resource_cd = schr.service_resource_cd,
    temp->tqual[tcnt].service_resource_disp = schr.mnemonic
    IF (schr.res_type_flag=1)
     temp->tqual[tcnt].resource_type = "General"
    ELSEIF (schr.res_type_flag=2)
     temp->tqual[tcnt].resource_type = "Personnel"
    ELSEIF (schr.res_type_flag=3)
     temp->tqual[tcnt].resource_type = "Service Resource"
    ELSEIF (schr.res_type_flag=4)
     temp->tqual[tcnt].resource_type = "Equipment"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (t = 1 TO tcnt)
   IF ((temp->tqual[t].service_resource_cd > 0))
    SELECT INTO "NL:"
     FROM service_resource sr
     WHERE (sr.service_resource_cd=temp->tqual[t].service_resource_cd)
      AND sr.service_resource_type_cd=serviceresourcetype_surgop
      AND sr.active_ind=1
     DETAIL
      temp->tqual[t].surgical_resource_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((temp->tqual[t].surgical_resource_ind=0)
    AND (temp->tqual[t].person_id > 0))
    SELECT INTO "NL:"
     FROM prsnl_group_reltn pgr,
      prsnl_group pg,
      code_value cv
     PLAN (pgr
      WHERE (pgr.person_id=temp->tqual[t].person_id)
       AND pgr.active_ind=1)
      JOIN (pg
      WHERE pg.prsnl_group_id=pgr.prsnl_group_id
       AND pg.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=pg.prsnl_group_type_cd
       AND cv.code_set=357
       AND cv.cdf_meaning="SURGSPEC"
       AND cv.active_ind=1)
     DETAIL
      temp->tqual[t].surgical_resource_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((temp->tqual[t].surgical_resource_ind=0)
    AND (temp->tqual[t].item_id > 0))
    SELECT INTO "NL:"
     FROM pref_card_pick_list p
     WHERE (p.item_id=temp->tqual[t].item_id)
      AND p.active_ind=1
     DETAIL
      temp->tqual[t].surgical_resource_ind = 1
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET row_nbr = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt)
  PLAN (d)
  ORDER BY temp->tqual[d.seq].bookshelf, temp->tqual[d.seq].book, temp->tqual[d.seq].seq_nbr
  DETAIL
   IF ((temp->tqual[d.seq].surgical_resource_ind=1))
    row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
     rowlist[row_nbr].celllist,5),
    reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[d.seq].bookshelf, reply->rowlist[
    row_nbr].celllist[2].string_value = temp->tqual[d.seq].book, reply->rowlist[row_nbr].celllist[3].
    string_value = temp->tqual[d.seq].surgical_area,
    reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[d.seq].service_resource_disp,
    reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[d.seq].resource_type
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
END GO
