CREATE PROGRAM ct_eso_mfn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo(concat("*** CT_ESO_MFN START CTRL_ID1 = ",concat("Q:",trim(cnvtstring(get_reqinfo_double(
       "queue_id")))," T:",trim(cnvtstring(get_reqinfo_double("trigger_id"))))))
 CALL echo("<===== ESO_HL7_FORMATTING.INC  START =====>")
 CALL echo("MOD:053")
 CALL echo("<===== ESO_COMMON_ROUTINES.INC  START =====>")
 CALL echo("MOD:026")
 CALL echo("MOD:025")
 CALL echo("<===== ESO_GET_CODE.INC Begin =====>")
 CALL echo("MOD:008")
 DECLARE eso_get_code_meaning(code) = c12
 DECLARE eso_get_code_display(code) = c40
 DECLARE eso_get_meaning_by_codeset(x_code_set,x_meaning) = f8
 DECLARE eso_get_code_set(code) = i4
 DECLARE eso_get_alias_or_display(code,contrib_src_cd) = vc
 SUBROUTINE eso_get_code_meaning(code)
   CALL echo("Entering eso_get_code_meaning subroutine")
   CALL echo(build("    code=",code))
   FREE SET t_meaning
   DECLARE t_meaning = c12
   SET t_meaning = fillstring(12," ")
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("    A Readme is calling this script")
     CALL echo("    selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_meaning = cv.cdf_meaning
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_meaning = uar_get_code_meaning(cnvtreal(code))
     IF (trim(t_meaning)="")
      CALL echo("    uar_get_code_meaning failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_meaning = cv.cdf_meaning
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_meaning=",t_meaning))
   CALL echo("Exiting eso_get_code_meaning subroutine")
   RETURN(trim(t_meaning,3))
 END ;Subroutine
 SUBROUTINE eso_get_code_display(code)
   CALL echo("Entering eso_get_code_display subroutine")
   CALL echo(build("    code=",code))
   FREE SET t_display
   DECLARE t_display = c40
   SET t_display = fillstring(40," ")
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_display = cv.display
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_display = uar_get_code_display(cnvtreal(code))
     IF (trim(t_display)="")
      CALL echo("    uar_get_code_display failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_display = cv.display
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_display=",t_display))
   CALL echo("Exiting eso_get_code_display subroutine")
   RETURN(trim(t_display,3))
 END ;Subroutine
 SUBROUTINE eso_get_meaning_by_codeset(x_code_set,x_meaning)
   CALL echo("Entering eso_get_meaning_by_codeset subroutine")
   CALL echo(build("    code_set=",x_code_set))
   CALL echo(build("    meaning=",x_meaning))
   FREE SET t_code
   DECLARE t_code = f8
   SET t_code = 0.0
   IF (x_code_set > 0
    AND trim(x_meaning) > "")
    FREE SET t_meaning
    DECLARE t_meaning = c12
    SET t_meaning = fillstring(12," ")
    SET t_meaning = x_meaning
    FREE SET t_rc
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_set=x_code_set
       AND cv.cdf_meaning=trim(x_meaning)
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_code = cv.code_value
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_rc = uar_get_meaning_by_codeset(cnvtint(x_code_set),nullterm(t_meaning),1,t_code)
     IF (t_code <= 0)
      CALL echo("    uar_get_meaning_by_codeset failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_set=x_code_set
        AND cv.cdf_meaning=trim(x_meaning)
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_code = cv.code_value
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_code=",t_code))
   CALL echo("Exiting eso_get_meaning_by_codeset subroutine")
   RETURN(t_code)
 END ;Subroutine
 SUBROUTINE eso_get_code_set(code)
   CALL echo("Entering eso_get_code_set subroutine")
   CALL echo(build("    code=",code))
   DECLARE icode_set = i4 WITH private, noconstant(0)
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rowS from code_value table")
     SELECT INTO "nl:"
      cv.code_set
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       icode_set = cv.code_set
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET icode_set = uar_get_code_set(cnvtreal(code))
     IF ( NOT (icode_set > 0))
      CALL echo("    uar_get_code_set failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.code_set
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        icode_set = cv.code_set
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    Code_set=",icode_set))
   CALL echo("Exiting eso_get_code_set subroutine")
   RETURN(icode_set)
 END ;Subroutine
 SUBROUTINE eso_get_alias_or_display(code,contrib_src_cd)
   CALL echo("Entering eso_get_alias_or_display")
   CALL echo(build("   code            = ",code))
   CALL echo(build("   contrib_src_cd = ",contrib_src_cd))
   FREE SET t_alias_or_display
   DECLARE t_alias_or_display = vc
   SET t_alias_or_display = " "
   IF ( NOT (code > 0.0))
    RETURN(t_alias_or_display)
   ENDIF
   IF (contrib_src_cd > 0.0)
    SELECT INTO "nl:"
     cvo.alias
     FROM code_value_outbound cvo
     WHERE cvo.code_value=code
      AND cvo.contributor_source_cd=contrib_src_cd
     DETAIL
      IF (cvo.alias > "")
       t_alias_or_display = cvo.alias
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (size(trim(t_alias_or_display))=0)
    CALL echo("Alias not found, checking code value display")
    SET t_alias_or_display = eso_get_code_display(code)
   ENDIF
   CALL echo("Exiting eso_get_alias_or_display")
   RETURN(t_alias_or_display)
 END ;Subroutine
 CALL echo("<===== ESO_GET_CODE.INC End =====>")
 DECLARE get_esoinfo_long_index(sea_name) = i4
 DECLARE get_esoinfo_long(sea_name) = i4
 DECLARE set_esoinfo_long(sea_name,lvalue) = i4
 DECLARE get_esoinfo_string_index(sea_name) = i4
 DECLARE get_esoinfo_string(sea_name) = c200
 DECLARE set_esoinfo_string(sea_name,svalue) = i4
 DECLARE get_esoinfo_double_index(sea_name) = i4
 DECLARE get_esoinfo_double(sea_name) = f8
 DECLARE set_esoinfo_double(sea_name,dvalue) = i4
 DECLARE get_request_long_index(sea_name) = i4
 DECLARE get_request_long(sea_name) = i4
 DECLARE set_request_long(sea_name,lvalue) = i4
 DECLARE get_reqinfo_double_index(sea_name) = i4
 DECLARE get_reqinfo_double(sea_name) = f8
 DECLARE set_reqinfo_double(sea_name,dvalue) = i4
 DECLARE get_reqinfo_string_index(sea_name) = i4
 DECLARE get_reqinfo_string(sea_name) = c200
 DECLARE set_reqinfo_string(sea_name,svalue) = i4
 DECLARE eso_trim_zeros(number) = c20
 DECLARE eso_trim_zeros_pos(number,pos) = c20
 DECLARE eso_remove_decimal(snumber) = vc
 DECLARE parse_formatting_string(f_string,arg) = vc
 DECLARE eso_column_exists(tablename,columnname) = i4
 DECLARE eso_pharm_decimal(decimal_val) = vc
 DECLARE get_routine_arg_value(name) = vc
 DECLARE cache_dm_flag_data(null) = null
 DECLARE search_forward = i4 WITH protect, constant(1)
 DECLARE search_backward = i4 WITH protect, constant(- (1))
 DECLARE uar_rtf2(p1=vc(ref),p2=i4(ref),p3=vc(ref),p4=i4(ref),p5=i4(ref),
  p6=i4(ref)) = i4
 FREE RECORD loc_record
 RECORD loc_record(
   1 location_cd = f8
   1 organization_id = f8
   1 location_type_cd = f8
   1 loc_facility_cd = f8
   1 loc_building_cd = f8
   1 loc_nurse_unit_cd = f8
   1 loc_room_cd = f8
   1 loc_bed_cd = f8
 )
 SUBROUTINE get_esoinfo_long_index(sea_name)
   SET list_size = 0
   SET list_size = size(context->cerner.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_esoinfo_long(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(context->cerner.longlist[eso_idx].lval)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE set_esoinfo_long(sea_name,lvalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET context->cerner.longlist[eso_idx].lval = lvalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(context->cerner.longlist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(context->cerner.longlist,eso_idx)
    SET context->cerner.longlist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET context->cerner.longlist[eso_idx].lval = lvalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_esoinfo_string_index(sea_name)
   SET list_size = 0
   SET list_size = size(context->cerner.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_esoinfo_string(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(context->cerner.stringlist[eso_idx].strval)
   ENDIF
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE set_esoinfo_string(sea_name,svalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET context->cerner.stringlist[eso_idx].strval = svalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(context->cerner.stringlist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(context->cerner.stringlist,eso_idx)
    SET context->cerner.stringlist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET context->cerner.stringlist[eso_idx].strval = svalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_esoinfo_double_index(sea_name)
   SET list_size = 0
   SET list_size = size(context->cerner.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_esoinfo_double(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(context->cerner.doublelist[eso_idx].dval)
   ENDIF
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE set_esoinfo_double(sea_name,dvalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET context->cerner.doublelist[eso_idx].dval = dvalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(context->cerner.doublelist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(context->cerner.doublelist,eso_idx)
    SET context->cerner.doublelist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET context->cerner.doublelist[eso_idx].dval = dvalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_request_long_index(sea_name)
   SET list_size = 0
   SET list_size = size(request->esoinfo.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_request_long(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(request->esoinfo.longlist[eso_idx].lval)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE set_request_long(sea_name,lvalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET request->esoinfo.longlist[eso_idx].lval = lvalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(request->esoinfo.longlist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(request->esoinfo.longlist,eso_idx)
    SET request->esoinfo.longlist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET request->esoinfo.longlist[eso_idx].lval = lvalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_reqinfo_double_index(sea_name)
   SET list_size = 0
   SET list_size = size(request->esoinfo.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_reqinfo_double(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(request->esoinfo.doublelist[eso_idx].dval)
   ENDIF
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE set_reqinfo_double(sea_name,dvalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET request->esoinfo.doublelist[eso_idx].dval = dvalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(request->esoinfo.doublelist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(request->esoinfo.doublelist,eso_idx)
    SET request->esoinfo.doublelist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET request->esoinfo.doublelist[eso_idx].dval = dvalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_reqinfo_string_index(sea_name)
   SET list_size = 0
   SET list_size = size(request->esoinfo.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_reqinfo_string(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(request->esoinfo.stringlist[eso_idx].strval)
   ENDIF
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE set_reqinfo_string(sea_name,svalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET request->esoinfo.stringlist[eso_idx].strval = svalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(request->esoinfo.stringlist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(request->esoinfo.stringlist,eso_idx)
    SET request->esoinfo.stringlist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET request->esoinfo.stringlist[eso_idx].strval = svalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_trim_zeros(number)
   CALL echo("Entering eso_trim_zeros subroutine")
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_final
   FREE SET t_i
   SET t_initial = build(number)
   SET t_length = size(t_initial)
   SET t_decimal = findstring(".",t_initial,1)
   SET t_final = trim(t_initial,3)
   CALL echo(build("    number=",number))
   CALL echo(build("    t_initial=",t_initial))
   IF (t_decimal > 0)
    SET t_last_sig = (t_decimal - 1)
    SET t_i = 0
    FOR (t_i = (t_decimal+ 1) TO t_length)
      IF (substring(t_i,1,t_initial) > "0")
       SET t_last_sig = t_i
      ENDIF
    ENDFOR
    SET t_final = trim(substring(1,t_last_sig,t_initial),3)
   ENDIF
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_i
   CALL echo(build("    t_final=",t_final))
   CALL echo("Exiting eso_trim_zeros subroutine")
   RETURN(t_final)
 END ;Subroutine
 SUBROUTINE eso_trim_zeros_pos(number,pos)
   CALL echo("Entering eso_trim_zeros_pos subroutine")
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_final
   FREE SET t_i
   SET t_initial = build(number)
   SET t_length = size(t_initial)
   SET t_decimal = findstring(".",t_initial,1)
   SET t_final = trim(t_initial)
   IF (t_decimal > 0)
    SET t_decimal += pos
    SET t_last_sig = t_decimal
    SET t_i = 0
    FOR (t_i = (t_decimal+ 1) TO t_length)
      IF (substring(t_i,1,t_initial) > "0")
       SET t_last_sig = t_i
      ENDIF
    ENDFOR
    SET t_final = trim(substring(1,t_last_sig,t_initial))
   ENDIF
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_i
   CALL echo(build("    t_final=",t_final))
   CALL echo("Exiting eso_trim_zeros_pos subroutine")
   RETURN(t_final)
 END ;Subroutine
 SUBROUTINE (eso_trim_zeros_sig_dig(number=f8,sig_dig=i4) =c20)
   CALL echo("Entering eso_trim_zeros_sig_dig subroutine")
   DECLARE strzeros = vc WITH private, noconstant("")
   SET strzeros = eso_trim_zeros(trim(cnvtstring(number,20,value(sig_dig))))
   CALL echo("Exiting eso_trim_zeros_sig_dig subroutine")
   RETURN(strzeros)
 END ;Subroutine
 SUBROUTINE parse_formatting_string(f_string,arg)
   CALL echo("Entering parse_formatting_string() subroutine")
   DECLARE p_pos = i2 WITH private, noconstant(0)
   DECLARE c_pos = i2 WITH private, noconstant(0)
   DECLARE argument = vc WITH private, noconstant("")
   DECLARE f_string_len = i4 WITH private, noconstant(0)
   SET f_string = trim(f_string,3)
   SET f_string_len = size(f_string,1)
   CALL echo(build("arg      =",arg))
   CALL echo(build("f_string =",f_string))
   IF (f_string_len)
    IF (arg)
     SET p_pos = 0
     FOR (x_i = 1 TO arg)
       SET c_pos = findstring(",",f_string,(p_pos+ 1))
       IF (x_i=arg)
        IF (p_pos > 0
         AND c_pos=0)
         SET argument = substring((p_pos+ 1),(f_string_len - p_pos),f_string)
        ELSE
         SET argument = substring((p_pos+ 1),(c_pos - (p_pos+ 1)),f_string)
        ENDIF
       ENDIF
       SET p_pos = c_pos
     ENDFOR
    ELSE
     CALL echo("ERROR!! a valid argument number was not passed in")
    ENDIF
   ELSE
    CALL echo("ERROR!! a valid formatting string was not passed in")
   ENDIF
   CALL echo("Exiting parse_formatting_string() subroutine")
   RETURN(argument)
 END ;Subroutine
 SUBROUTINE eso_remove_decimal(number)
   CALL echo("Entering eso_remove_decimal() subroutine")
   DECLARE t_pos = i4 WITH private, noconstant(0)
   DECLARE t_number = vc WITH private, noconstant("")
   SET t_number = build(number)
   CALL echo(build("t_number = ",t_number))
   SET t_pos = findstring(".",t_number)
   IF (t_pos)
    SET t_number = substring(1,(t_pos+ 2),t_number)
    CALL echo(build("t_number = ",t_number))
    SET t_number = trim(replace(t_number,".","",1),3)
    CALL echo(build("t_number = ",t_number))
   ENDIF
   CALL echo("Exiting eso_remove_decimal() subroutine")
   RETURN(t_number)
 END ;Subroutine
 SUBROUTINE (get_int_routine_arg(arg=vc,args=vc) =i4)
   CALL echo("Entering get_int_routine_arg() subroutine")
   DECLARE pos = i4 WITH private, noconstant(0)
   DECLARE b_pos = i4 WITH private, noconstant(0)
   DECLARE value = i4 WITH private, noconstant(0)
   DECLARE stop = i2 WITH private, noconstant(0)
   IF (args <= "")
    IF (validate(request->esoinfo,"!") != "!")
     SET args = request->esoinfo.scriptcontrolargs
    ELSE
     CALL echo("No incoming request->esoinfo structure detected")
    ENDIF
   ENDIF
   SET pos = findstring(arg,args)
   IF (pos)
    SET pos += 10
    SET b_pos = pos
    SET stop = 0
    WHILE ( NOT (stop))
      IF (isnumeric(substring(pos,1,args)))
       SET value = cnvtint(substring(b_pos,((pos+ 1) - b_pos),args))
       SET pos += 1
      ELSE
       SET stop = 1
      ENDIF
    ENDWHILE
   ELSE
    CALL echo(concat("arg=",arg," not found in routine args=",args))
   ENDIF
   CALL echo(build("value=",value))
   CALL echo("Exiting get_int_routine_arg() subroutine")
   RETURN(value)
 END ;Subroutine
 SUBROUTINE eso_column_exists(tablename,columnname)
   CALL echo("Entering eso_column_exists subroutine")
   DECLARE ce_flag = i4
   SET ce_flag = 0
   DECLARE ce_temp = vc WITH noconstant("")
   SET stable = cnvtupper(tablename)
   SET scolumn = cnvtupper(columnname)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
   ENDIF
   CALL echo("Exiting eso_column_exists subroutine")
   RETURN(ce_flag)
 END ;Subroutine
 SUBROUTINE eso_pharm_decimal(decimal_val)
   CALL echo("Entering eso_pharm_decimal...")
   DECLARE strdecimal = vc WITH noconstant(" ")
   SET strdecimal = cnvtstring(decimal_val,20,6)
   SET idecimalidx = findstring(".",strdecimal)
   IF (idecimalidx > 0)
    SET iend = size(strdecimal,1)
    WHILE (substring(iend,1,strdecimal)="0")
      SET iend -= 1
    ENDWHILE
    SET strdecimal = substring(1,iend,strdecimal)
    CALL echo(build2("removed zeros - ",strdecimal))
    IF (substring(size(strdecimal,1),1,strdecimal)=".")
     SET strdecimal = substring(1,(size(strdecimal,1) - 1),strdecimal)
     CALL echo(build2("removed decimal - ",strdecimal))
    ENDIF
    IF (idecimalidx=1)
     SET strdecimal = ("0"+ strdecimal)
     CALL echo(build2("added leading zero - ",strdecimal))
    ENDIF
   ENDIF
   CALL echo("Exiting eso_pharm_decimal...")
   RETURN(strdecimal)
 END ;Subroutine
 SUBROUTINE get_routine_arg_value(name)
   CALL echo("Entering get_routine_arg_value...")
   SET routine_args = trim(request->esoinfo.scriptcontrolargs)
   DECLARE strvalue = vc WITH public, noconstant(" ")
   SET iindex = findstring(name,routine_args)
   IF (iindex)
    SET iequalidx = findstring("=",routine_args,(iindex+ size(name)))
    IF (iequalidx > 0)
     SET isemiidx = findstring(";",routine_args,(iequalidx+ 1))
     IF (isemiidx > 0)
      SET strvalue = trim(substring((iequalidx+ 1),((isemiidx - iequalidx) - 1),routine_args),3)
     ELSE
      SET strvalue = trim(substring((iequalidx+ 1),(size(routine_args) - iequalidx),routine_args),3)
     ENDIF
    ENDIF
   ENDIF
   RETURN(strvalue)
   CALL echo("Exiting get_routine_arg_value...")
 END ;Subroutine
 SUBROUTINE (routine_arg_exists(name=vc) =i2)
   IF (validate(request->esoinfo.scriptcontrolargs,0))
    DECLARE routine_args = vc WITH private, noconstant(trim(request->esoinfo.scriptcontrolargs))
   ELSE
    DECLARE routine_args = vc WITH private, noconstant(trim(get_esoinfo_string("routine_args")))
   ENDIF
   DECLARE routine_args_size = i4 WITH private, constant(size(routine_args))
   DECLARE name_start = i4 WITH private, noconstant(0)
   DECLARE next_char_idx = i4 WITH private, noconstant(0)
   DECLARE trailing_char_exists = i2 WITH private, noconstant(0)
   DECLARE leading_char_exists = i2 WITH private, noconstant(0)
   IF (size(trim(name))=0)
    CALL echo("Invalid Empty Routine Arg")
    RETURN(0)
   ENDIF
   SET name_start = findstring(name,routine_args,1)
   WHILE (name_start > 0)
     SET next_char_idx = (name_start+ size(name))
     SET trailing_char_exists = additional_character_exists(routine_args,routine_args_size,
      next_char_idx,search_forward)
     IF (trailing_char_exists=0)
      SET leading_char_exists = additional_character_exists(routine_args,routine_args_size,(
       name_start - 1),search_backward)
     ENDIF
     IF (leading_char_exists=0
      AND trailing_char_exists=0)
      CALL echo(build("Routine Arg- ",name," is enabled."))
      RETURN(1)
     ELSE
      SET name_start = findstring(name,routine_args,next_char_idx)
     ENDIF
   ENDWHILE
   CALL echo(build("Routine Arg- ",name," is NOT enabled."))
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (additional_character_exists(arg_string=vc,arg_string_size=i4,start_idx=i4,
  search_increment=i4) =i2)
   DECLARE end_of_token_found = i4 WITH private, noconstant(0)
   DECLARE char_exists = i2 WITH private, noconstant(0)
   DECLARE check_idx = i4 WITH private, noconstant(start_idx)
   DECLARE check_char = c1 WITH private, noconstant(" ")
   WHILE ( NOT (end_of_token_found))
     IF (((check_idx < 1) OR (check_idx > arg_string_size)) )
      SET end_of_token_found = 1
     ELSE
      SET check_char = substring(check_idx,1,arg_string)
      IF (check_char=";")
       SET end_of_token_found = 1
      ELSEIF ( NOT (check_char=" "))
       SET char_exists = 1
       SET end_of_token_found = 1
      ELSE
       SET check_idx += search_increment
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(char_exists)
 END ;Subroutine
 SUBROUTINE (get_synoptic_nomen_config(name=vc) =vc)
   CALL echo("Entering get_synoptic_nomen_config...")
   SET routine_args = trim(get_esoinfo_string("routine_args"),3)
   DECLARE strvalue = vc WITH public, noconstant(" ")
   SET iindex = findstring(name,routine_args)
   IF (iindex)
    SET iequalidx = findstring("=",routine_args,(iindex+ size(name)))
    IF (iequalidx > 0)
     SET isemiidx = findstring(";",routine_args,(iequalidx+ 1))
     IF (isemiidx > 0)
      SET strvalue = trim(substring((iequalidx+ 1),((isemiidx - iequalidx) - 1),routine_args),3)
     ELSE
      SET strvalue = trim(substring((iequalidx+ 1),(size(routine_args) - iequalidx),routine_args),3)
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("strValue:",strvalue))
   RETURN(strvalue)
   CALL echo("Exiting get_synoptic_nomen_config...")
 END ;Subroutine
 SUBROUTINE (rtfformatingremove(srtfstring=vc) =vc)
   CALL echo("Entering rtfFormat")
   CALL echo(build("sRtfString = ",srtfstring))
   IF ( NOT (validate(g_strreplacetext)))
    DECLARE dpicttextcd = f8 WITH private, noconstant(0.0)
    SET dpicttextcd = eso_get_meaning_by_codeset(40700,"PICT_TEXT")
    DECLARE strdisplayvalue = vc WITH private, noconstant(" ")
    SET strdisplayvalue = eso_get_code_display(dpicttextcd)
    DECLARE g_strreplacetext = vc WITH private, noconstant(" ")
    SET g_strreplacetext = concat(" ",trim(strdisplayvalue,3)," {\pict")
   ENDIF
   DECLARE srtftxt = vc WITH private, noconstant(" ")
   SET srtftxt = trim(replace(srtfstring,"{\pict",g_strreplacetext,0),3)
   DECLARE irtftextsize = i4 WITH private, noconstant(textlen(srtftxt))
   CALL echo(build("iRtfTextSize =",irtftextsize))
   DECLARE sasciitext = vc WITH private, noconstant(concat(srtftxt,"0123456789"))
   DECLARE iacsiilength = i4 WITH private, noconstant(0)
   DECLARE s_irtfflag = i4 WITH private, noconstant(1)
   SET iretvalue = uar_rtf2(srtftxt,irtftextsize,sasciitext,irtftextsize,iacsiilength,
    s_irtfflag)
   CALL echo(build("iRetValue=",iretvalue))
   FREE SET srtftxt
   SET sasciitext = trim(substring(1,iacsiilength,sasciitext))
   CALL echo(build("sAsciiText=",sasciitext))
   CALL echo("Exiting rtfFormat")
   RETURN(sasciitext)
 END ;Subroutine
 SUBROUTINE (get_parent_loc(child_loc=f8,loc_type=vc) =f8)
   DECLARE parent_loc = f8 WITH public, noconstant(0.0)
   SELECT INTO "nl:"
    lg.parent_loc_cd
    FROM location_group lg
    WHERE lg.child_loc_cd=child_loc
     AND lg.location_group_type_cd=loc_type
     AND ((lg.root_loc_cd+ 0)=0)
     AND lg.active_ind=1
    DETAIL
     parent_loc = lg.parent_loc_cd
    WITH nocounter
   ;end select
   RETURN(parent_loc)
 END ;Subroutine
 SUBROUTINE (fill_loc_tree(location_cd=f8) =i4)
   DECLARE val = i4 WITH noconstant(1)
   IF (location_cd > 0)
    SELECT INTO "nl:"
     a.location_type_cd, a.organization_id, meaning = uar_get_code_meaning(a.location_type_cd)
     FROM location a
     PLAN (a
      WHERE a.location_cd=location_cd)
     DETAIL
      IF (a.location_type_cd > 0)
       CASE (meaning)
        OF "BED":
         loc_record->loc_bed_cd = location_cd
        OF "ROOM":
         loc_record->loc_room_cd = location_cd
        OF "NURSEUNIT":
         loc_record->loc_nurse_unit_cd = location_cd
        OF "BUILDING":
         loc_record->loc_building_cd = location_cd
        OF "FACILITY":
         loc_record->loc_facility_cd = location_cd
        ELSE
         val = 0
       ENDCASE
      ENDIF
      loc_record->organization_id = a.organization_id, loc_record->location_type_cd = a
      .location_type_cd
     WITH nocounter
    ;end select
    IF ((loc_record->loc_bed_cd > 0)
     AND (loc_record->loc_room_cd <= 0))
     SET loc_record->loc_room_cd = get_parent_loc(loc_record->loc_bed_cd,eso_get_meaning_by_codeset(
       222,"ROOM"))
    ENDIF
    IF ((loc_record->loc_room_cd > 0)
     AND (loc_record->loc_nurse_unit_cd <= 0))
     SET loc_record->loc_nurse_unit_cd = get_parent_loc(loc_record->loc_room_cd,
      eso_get_meaning_by_codeset(222,"NURSEUNIT"))
    ENDIF
    IF ((loc_record->loc_nurse_unit_cd > 0)
     AND (loc_record->loc_building_cd <= 0))
     SET loc_record->loc_building_cd = get_parent_loc(loc_record->loc_nurse_unit_cd,
      eso_get_meaning_by_codeset(222,"BUILDING"))
    ENDIF
    IF ((loc_record->loc_building_cd > 0)
     AND (loc_record->loc_facility_cd <= 0))
     SET loc_record->loc_facility_cd = get_parent_loc(loc_record->loc_building_cd,
      eso_get_meaning_by_codeset(222,"FACILITY"))
    ENDIF
   ENDIF
   RETURN(val)
 END ;Subroutine
 SUBROUTINE cache_dm_flag_data(null)
  RECORD dm_flag(
    1 qual[*]
      2 flag_value = i2
      2 description = vc
      2 column_name = vc
  ) WITH persist
  SELECT DISTINCT INTO "nl:"
   dmf.description
   FROM dm_flags dmf
   WHERE dmf.table_name="ORDERS"
    AND dmf.column_name IN ("CS_FLAG", "TEMPLATE_ORDER_FLAG", "ORDERABLE_TYPE_FLAG")
   ORDER BY dmf.column_name
   HEAD REPORT
    i = 0
   DETAIL
    i += 1, stat = alterlist(dm_flag->qual,i), dm_flag->qual[i].description = dmf.description,
    dm_flag->qual[i].flag_value = dmf.flag_value, dm_flag->qual[i].column_name = dmf.column_name
   WITH nocounter
  ;end select
 END ;Subroutine
 CALL echo("<===== ESO_COMMON_ROUTINES.INC End =====>")
 DECLARE eso_format_dttm(input_dt_tm,hl7_format,time_zone) = c60
 DECLARE hl7_format_date(input_dt_tm,method) = c60
 DECLARE hl7_format_time(input_dt_tm,method) = c60
 DECLARE hl7_format_datetime(input_dt_tm,method) = c60
 DECLARE eso_format_nomen(n_field1,n_field2,n_field3,n_value1,n_value2) = c200
 DECLARE eso_format_item(identifier,value,item,index) = c200
 DECLARE eso_format_item_with_method(identifier,value,item,index,data_type,
  field_name) = c200
 DECLARE eso_format_code(fvalue) = c40
 DECLARE eso_format_code_with_method(fvalue,data_type,field_name) = c40
 DECLARE eso_format_code_blank(fvalue) = c40
 DECLARE eso_format_code_ctx(fvalue) = c40
 DECLARE eso_format_code_blank_ctx(fvalue) = c40
 DECLARE eso_format_code_aliases(fvalue1,fvalue2) = c40
 DECLARE eso_format_alias(field1,field2,type,subtype,pool,
  alias) = c200
 DECLARE eso_format_alias_ctx(field1,field2,type,subtype,pool,
  alias) = c200
 DECLARE eso_format_dbnull(dummy) = c40
 DECLARE eso_format_dbnull_ctx(dummy) = c40
 DECLARE eso_format_org(field_name,msg_format,datatype,org_alias_type_cd,repeat_ind,
  future,future2,assign_auth_org_id,fed_tax_id,org_name,
  org_id) = c200
 DECLARE eso_format_hlthplan(field_name,msg_format,datatype,hlthplan_alias_type_cd,repeat_ind,
  future,future2,assign_auth_org_id,hlthplan_plan_name,hlthplan_id,
  ins_org_id) = c200
 DECLARE eso_encode_timing(value,unit) = c20
 DECLARE eso_encode_range(low,high) = c45
 DECLARE eso_encode_timing_noround(value,unit) = c20
 DECLARE eso_format_previous_result(strverifydttm,struser,strresultval,strresultunitcd,strnormalcycd,
  strusername,strtype) = vc
 DECLARE encode_delimiter(original_string,search_string,replace_string) = vc
 DECLARE eso_format_short_result(strverifydttm,struser,strusername,strtype) = vc
 DECLARE eso_format_code_for_cs(fvalue,strcodingsys,straliastypmeaning) = vc
 DECLARE eso_format_multum_identifiers(catalog_cd,synonym_id,item_id,field_type,format_string) = vc
 DECLARE eso_format_attachment(strattachmentname,dstoragecd,strblobhandle,dformatcd,strcommentind) =
 vc
 DECLARE eso_format_phone_cd(dphonetypecd,dcontactmethodcd) = vc
 SET hl7_date_year = 1
 SET hl7_date_mon = 2
 SET hl7_date_day = 3
 SET hl7_dt_tm_hour = 4
 SET hl7_dt_tm_min = 5
 SET hl7_dt_tm_sec = 6
 SET hl7_dt_tm_hsec = 7
 SET hl7_time_hour = 8
 SET hl7_time_min = 9
 SET hl7_time_sec = 10
 SET hl7_time_hsec = 11
 SET hl7_date = 3
 SET hl7_dt_tm = 6
 SET hl7_time = 10
 SUBROUTINE (format_dttm_custom(s_dtinputdttm=dq8,s_strformat=vc,s_strtzformat=vc) =vc)
   DECLARE strdttmcustformatstring = vc WITH noconstant(" ")
   IF (s_dtinputdttm > 0
    AND textlen(trim(s_strformat,3)) > 0)
    DECLARE strtzformatstring = vc WITH noconstant(", ,")
    IF (textlen(trim(s_strtzformat,3)) > 0)
     SET strtzformatstring = build2(",",s_strtzformat,",")
    ENDIF
    IF (curutc=0)
     SET strdttmcustformatstring = build2("##DTTMCUST##,",s_strformat,strtzformatstring,format(
       s_dtinputdttm,"YYYYMMDD;;D"),",",
      format(s_dtinputdttm,"HHmmss.cc;3;M"),",")
    ELSE
     SET strdttmcustformatstring = build2("##DTTMCUST##,",s_strformat,strtzformatstring,format(
       s_dtinputdttm,"YYYYMMDD;;D"),",",
      format(s_dtinputdttm,"HHmmss.cc;3;M"),", ,",datetimezoneformat(s_dtinputdttm,datetimezonebyname
       ("UTC"),"yyyyMMddHHmmsscc"))
    ENDIF
   ENDIF
   RETURN(strdttmcustformatstring)
 END ;Subroutine
 SUBROUTINE (format_date_of_record_custom(s_dtinputdttm=dq8,s_strformat=vc,s_strtzformat=vc,s_idatetz
  =i4) =vc)
   DECLARE strdttmcustformatstring = vc WITH noconstant(" ")
   IF (s_dtinputdttm > 0
    AND textlen(trim(s_strformat,3)) > 0)
    DECLARE strtzformatstring = vc WITH noconstant(", ,")
    DECLARE strdatetz = vc WITH noconstant(notrim(", "))
    IF (textlen(trim(s_strtzformat,3)) > 0)
     SET strtzformatstring = build2(",",s_strtzformat,",")
    ENDIF
    IF (s_idatetz > 0)
     SET strdatetz = build2(",",cnvtstring(s_idatetz))
    ELSEIF (curutc=0)
     SET strdatetz = build2(",",cnvtstring(curtimezonesys))
    ENDIF
    IF (curutc=0)
     SET strdttmcustformatstring = build2("##DTTMCUST##,",s_strformat,strtzformatstring,format(
       s_dtinputdttm,"YYYYMMDD;;D"),",",
      format(s_dtinputdttm,"HHmmss.cc;3;M"),strdatetz)
    ELSE
     SET strdttmcustformatstring = build2("##DTTMCUST##,",s_strformat,strtzformatstring,format(
       s_dtinputdttm,"YYYYMMDD;;D"),",",
      format(s_dtinputdttm,"HHmmss.cc;3;M"),strdatetz,",",datetimezoneformat(s_dtinputdttm,
       datetimezonebyname("UTC"),"yyyyMMddHHmmsscc"))
    ENDIF
   ENDIF
   RETURN(strdttmcustformatstring)
 END ;Subroutine
 SUBROUTINE eso_format_dttm(input_dt_tm,hl7_format,time_zone)
  DECLARE strtimezonestring = vc WITH noconstant(", ,")
  IF (input_dt_tm > 0)
   FREE SET t_dt
   FREE SET t_dt_format
   FREE SET t_tm
   FREE SET t_tm_format
   SET t_dt = format(input_dt_tm,"YYYYMMDD;;D")
   SET t_tm = format(input_dt_tm,"HHmmss.cc;3;M")
   CASE (hl7_format)
    OF hl7_date_year:
     SET t_dt_format = "YYYY"
     SET t_tm_format = " "
    OF hl7_date_mon:
     SET t_dt_format = "YYYYMM"
     SET t_tm_format = " "
    OF hl7_date_day:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = " "
    OF hl7_date:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = " "
    OF hl7_dt_tm_hour:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HH"
    OF hl7_dt_tm_min:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMM"
    OF hl7_dt_tm_sec:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMMSS"
    OF hl7_dt_tm:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMMSS"
    OF hl7_dt_tm_hsec:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMMSS.CC"
    OF hl7_time_hour:
     SET t_dt_format = " "
     SET t_tm_format = "HH"
    OF hl7_time_min:
     SET t_dt_format = " "
     SET t_tm_format = "HHMM"
    OF hl7_time_sec:
     SET t_dt_format = " "
     SET t_tm_format = "HHMMSS"
    OF hl7_time:
     SET t_dt_format = " "
     SET t_tm_format = "HHMMSS"
    OF hl7_time_hsec:
     SET t_dt_format = " "
     SET t_tm_format = "HHMMSS.CC"
    ELSE
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMMSS"
   ENDCASE
   IF (textlen(trim(time_zone,3)) > 0)
    SET strtimezonestring = build2(",",trim(time_zone,3),",")
   ENDIF
   IF (curutc=0)
    RETURN(concat("##DTTM##",",",t_dt_format,",",t_tm_format,
     ",",t_dt,",",t_tm,strtimezonestring))
   ELSE
    RETURN(concat("##DTTM##",",",t_dt_format,",",t_tm_format,
     ",",t_dt,",",t_tm,strtimezonestring,
     datetimezoneformat(input_dt_tm,datetimezonebyname("UTC"),"yyyyMMddHHmmsscc")))
   ENDIF
  ELSE
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE hl7_format_datetime(input_dt_tm,method)
   RETURN(eso_format_dttm(input_dt_tm,method,""))
 END ;Subroutine
 SUBROUTINE hl7_format_date(input_dt_tm,method)
   RETURN(eso_format_dttm(input_dt_tm,method,""))
 END ;Subroutine
 SUBROUTINE hl7_format_time(input_dt_tm,method)
   RETURN(eso_format_dttm(input_dt_tm,method,""))
 END ;Subroutine
 SUBROUTINE (eso_birth_date_format_specifier(birth_prec_flag=i2) =i4)
   DECLARE precision = i4 WITH noconstant(0)
   CASE (birth_prec_flag)
    OF 0:
     SET precision = hl7_date
    OF 1:
     SET precision = hl7_dt_tm
    OF 2:
     SET precision = hl7_date_mon
    OF 3:
     SET precision = hl7_date_year
    ELSE
     SET precision = hl7_dt_tm
   ENDCASE
   RETURN(precision)
 END ;Subroutine
 SUBROUTINE (eso_death_date_format_specifier(death_prec_flag=i2) =i4)
   DECLARE precision = i4 WITH noconstant(0)
   CASE (death_prec_flag)
    OF 0:
     SET precision = hl7_dt_tm
    OF 1:
     SET precision = hl7_dt_tm
    OF 2:
     SET precision = hl7_date_mon
    OF 3:
     SET precision = hl7_date_year
    OF 4:
     SET precision = hl7_date_day
    ELSE
     SET precision = hl7_dt_tm
   ENDCASE
   RETURN(precision)
 END ;Subroutine
 SUBROUTINE (not_a_maxdate(end_effect_dttm=dq8) =i2)
  DECLARE blankenddate = dq8 WITH protected, constant(cnvtdatetime("31-DEC-2100 23:59:59.00"))
  IF (datetimecmp(cnvtdatetime(end_effect_dttm),blankenddate))
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_nomen(n_field1,n_field2,n_field3,n_value1,n_value2)
   IF (n_value1
    AND n_value2)
    RETURN(substring(1,200,concat("##NOMEN##",",",trim(n_field1,3),",",trim(n_field2,3),
      ",",trim(n_field3,3),",",trim(cnvtstring(n_value1),3),",",
      trim(cnvtstring(n_value2),3))))
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_item(identifier,value,item,index)
   IF (item > 0)
    RETURN(substring(1,200,concat("##ITEM##",",",trim(identifier),",",trim(value),
      ",",trim(cnvtstring(item)),",",trim(cnvtstring(index)))))
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_item_with_method(identifier,value,item,index,data_type,field_name)
   IF (item > 0)
    RETURN(substring(1,200,concat("##ITEM##",",",trim(identifier),",",trim(value),
      ",",trim(cnvtstring(item)),",",trim(cnvtstring(index)),",",
      trim(data_type),",",trim(field_name))))
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code(fvalue)
   IF (fvalue > 0)
    RETURN(substring(1,40,concat("##CVA##",",",trim(cnvtstring(fvalue)))))
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code_with_method(fvalue,data_type,field_name)
   IF (fvalue > 0)
    IF (trim(data_type)="ALIAS_TYPE_MEANING")
     RETURN(substring(1,40,concat("##CVA##",",",trim(cnvtstring(fvalue)),",",trim(field_name))))
    ELSE
     RETURN(substring(1,40,concat("##CVA##",",",trim(cnvtstring(fvalue)),",",trim(data_type),
       ",",trim(field_name))))
    ENDIF
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code_blank(fvalue)
   IF (fvalue > 0)
    RETURN(substring(1,40,concat("##CVA##",",",trim(cnvtstring(fvalue)))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code_aliases(fvalue1,fvalue2)
   IF (fvalue1 > 0
    AND fvalue2 > 0)
    RETURN(substring(1,40,concat("##CVAS##",",",trim(cnvtstring(fvalue1)),",",trim(cnvtstring(fvalue2
        )))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code_ctx(fvalue)
   RETURN(eso_format_code(fvalue))
 END ;Subroutine
 SUBROUTINE eso_format_code_blank_ctx(fvalue)
   RETURN(eso_format_code_blank(fvalue))
 END ;Subroutine
 SUBROUTINE eso_format_alias(field1,field2,type,subtype,pool,alias)
  CALL echo(concat("alias type ",cnvtstring(type)))
  IF (type > 0)
   CALL echo("alias type > 0 ")
   IF (trim(alias)="")
    CALL echo('alias <= ""')
    RETURN(substring(1,200,concat("##ALIAS##",",",trim(field1),",",trim(field2),
      ",",trim(cnvtstring(type)),",",trim(cnvtstring(subtype)),",",
      trim(cnvtstring(pool)),","," ",","," ",
      ","," ")))
   ELSE
    CALL echo('alias > ""')
    RETURN(substring(1,200,concat("##ALIAS##",",",trim(field1),",",trim(field2),
      ",",trim(cnvtstring(type)),",",trim(cnvtstring(subtype)),",",
      trim(cnvtstring(pool)),","," ",","," ",
      ",",trim(alias))))
   ENDIF
  ELSE
   CALL echo("alias type <= 0 ")
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_alias_ctx(field1,field2,type,subtype,pool,alias)
  CALL echo(concat("alias type ",cnvtstring(type)))
  IF (type > 0)
   CALL echo("alias type > 0 ")
   IF (trim(alias)="")
    CALL echo('alias <= ""')
    RETURN(substring(1,200,concat("##ALIAS##",",",trim(field1),",",trim(field2),
      ",",trim(cnvtstring(type)),",",trim(cnvtstring(subtype)),",",
      trim(cnvtstring(pool)),","," ",","," ",
      ","," ")))
   ELSE
    CALL echo('alias > ""')
    RETURN(substring(1,200,concat("##ALIAS##",",",trim(field1),",",trim(field2),
      ",",trim(cnvtstring(type)),",",trim(cnvtstring(subtype)),",",
      trim(cnvtstring(pool)),","," ",","," ",
      ",",trim(alias))))
   ENDIF
  ELSE
   CALL echo("alias type <= 0 ")
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_dbnull(dummy)
   RETURN(substring(1,40,"##NULL##"))
 END ;Subroutine
 SUBROUTINE eso_format_dbnull_ctx(dummy)
   RETURN(substring(1,40,"##NULL##"))
 END ;Subroutine
 SUBROUTINE eso_format_org(msg_format,field_name,datatype,org_id,org_alias_type_cd,repeat_ind,
  assign_auth_org_id,fed_tax_id,org_name,future,future2)
  CALL echo(concat("org_id = ",cnvtstring(org_id)))
  IF (org_id > 0)
   CALL echo("org_id > 0 ")
   RETURN(substring(1,200,concat("##ORG##",",",trim(msg_format),",",trim(field_name),
     ",",trim(datatype),",",trim(cnvtstring(org_id)),",",
     trim(cnvtstring(org_alias_type_cd)),",",trim(cnvtstring(repeat_ind)),",",trim(cnvtstring(
       assign_auth_org_id)),
     ",",trim(cnvtstring(fed_tax_id)),",",trim(org_name),",",
     ",",",")))
  ELSE
   CALL echo("org_id <= 0 ")
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_hlthplan(field_name,msg_format,datatype,hlthplan_alias_type_cd,repeat_ind,
  future,future2,assign_auth_org_id,hlthplan_plan_name,hlthplan_id,ins_org_id)
  CALL echo(concat("hlthplan_id =",cnvtstring(hlthplan_id)))
  IF (hlthplan_id > 0)
   CALL echo("hlthplan_id > 0 ")
   RETURN(substring(1,200,concat("##HLTHPLAN##",",",trim(field_name),",",trim(msg_format),
     ",",trim(datatype),",",trim(cnvtstring(hlthplan_alias_type_cd)),",",
     trim(cnvtstring(repeat_ind)),",",",",",",trim(cnvtstring(assign_auth_org_id)),
     ",",trim(hlthplan_plan_name),",",trim(cnvtstring(hlthplan_id)),",",
     trim(cnvtstring(ins_org_id)))))
  ELSE
   CALL echo("hlthplan_id <= 0 ")
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_encode_timing(value,unit)
   CALL echo("Entering eso_encode_timing subroutine")
   CALL echo(build("    value=",value))
   CALL echo(build("    unit=",unit))
   FREE SET t_timing
   FREE SET t_meaning
   IF (unit > 0)
    SET t_meaning = trim(uar_get_code_meaning(unit))
    CALL echo(build("    t_meaning=",t_meaning))
    IF (t_meaning="DOSES")
     SET t_timing = trim(build("X",cnvtstring(value)))
    ELSEIF (t_meaning="SECONDS")
     SET t_timing = trim(build("S",cnvtstring(value)))
    ELSEIF (t_meaning="MINUTES")
     SET t_timing = trim(build("M",cnvtstring(value)))
    ELSEIF (t_meaning="HOURS")
     SET t_timing = trim(build("H",cnvtstring(value)))
    ELSEIF (t_meaning="DAYS")
     SET t_timing = trim(build("D",cnvtstring(value)))
    ELSEIF (t_meaning="WEEKS")
     SET t_timing = trim(build("W",cnvtstring(value)))
    ELSEIF (t_meaning="MONTHS")
     SET t_timing = trim(build("L",cnvtstring(value)))
    ELSE
     SET t_timing = ""
    ENDIF
   ELSE
    SET t_timing = ""
   ENDIF
   CALL echo(build("    t_timing=",t_timing))
   CALL echo("Exiting eso_encode_timing subroutine")
   RETURN(t_timing)
 END ;Subroutine
 SUBROUTINE eso_encode_range(low,high)
   CALL echo("Entering eso_encode_range subroutine(low, high)")
   CALL echo(build("    low=",low))
   CALL echo(build("    high=",high))
   FREE SET t_range
   SET t_range = eso_encode_range_txt(cnvtstring(low),cnvtstring(high),"")
   CALL echo(build("t_range",t_range))
   CALL echo("Exiting eso_encode_range subroutine(low, high)")
   RETURN(t_range)
 END ;Subroutine
 SUBROUTINE (eso_encode_range_txt(low=vc,high=vc,text=vc) =vc)
   CALL echo("Entering eso_encode_range_txt subroutine(low, high, text)")
   CALL echo(build("    low=",low))
   CALL echo(build("    high=",high))
   CALL echo(build("    text=",text))
   IF (trim(text) > "")
    RETURN(text)
   ELSE
    IF (trim(high) > "")
     IF (trim(low) > "")
      RETURN(concat(low,"-",high))
     ELSE
      IF (isnumeric(high))
       RETURN(concat("<",high))
      ELSE
       RETURN(high)
      ENDIF
     ENDIF
    ELSE
     IF (trim(low) > "")
      IF (isnumeric(low))
       RETURN(concat(">",low))
      ELSE
       RETURN(low)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo("Exiting eso_encode_range_txt subroutine( low, high, text )")
   RETURN("")
 END ;Subroutine
 SUBROUTINE eso_encode_timing_noround(value,unit)
   CALL echo("Entering eso_encode_timing_noround subroutine")
   CALL echo(build("    value=",value))
   CALL echo(build("    unit=",unit))
   FREE SET t_timing
   FREE SET t_meaning
   IF (unit > 0)
    SET t_meaning = trim(uar_get_code_meaning(unit))
    CALL echo(build("    t_meaning=",t_meaning))
    IF (t_meaning="DOSES")
     SET t_timing = trim(build("X",value))
    ELSEIF (t_meaning="SECONDS")
     SET t_timing = trim(build("S",value))
    ELSEIF (t_meaning="MINUTES")
     SET t_timing = trim(build("M",value))
    ELSEIF (t_meaning="HOURS")
     SET t_timing = trim(build("H",value))
    ELSEIF (t_meaning="DAYS")
     SET t_timing = trim(build("D",value))
    ELSEIF (t_meaning="WEEKS")
     SET t_timing = trim(build("W",value))
    ELSEIF (t_meaning="MONTHS")
     SET t_timing = trim(build("L",value))
    ELSE
     SET t_timing = ""
    ENDIF
   ELSE
    SET t_timing = ""
   ENDIF
   CALL echo(build("    t_timing=",t_timing))
   CALL echo("Exiting eso_encode_timing_noround subroutine")
   RETURN(t_timing)
 END ;Subroutine
 SUBROUTINE (eso_format_frequency(freq_qual=i4) =c45)
   CALL echo("Entering eso_format_frequency subroutine")
   CALL echo(build("freq_qual = ",freq_qual))
   IF (freq_qual > 0)
    RETURN(substring(1,200,concat("##TIMEINTSTR##",",",build(freq_qual))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE (eso_format_pharm_timing(encoded=vc,noround=vc,type_meaning=vc) =c200)
   CALL echo("Entering eso_format_pharm_timing subroutine")
   CALL echo(build("encoded = ",encoded))
   CALL echo(build("noround = ",noround))
   CALL echo(build("type_meaning = ",type_meaning))
   IF (type_meaning > " ")
    RETURN(substring(1,200,concat("##PHARMTIMING##",",",trim(encoded),",",trim(noround),
      ",",trim(type_meaning))))
   ELSE
    CALL echo("Invalid Type")
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE encode_delimiter(original_string,search_string,replace_string)
   CALL echo("Entering encode_delimiter subroutine")
   DECLARE str_replace_string = vc
   SET str_replace_string = replace(original_string,search_string,replace_string,0)
   RETURN(str_replace_string)
 END ;Subroutine
 SUBROUTINE eso_format_previous_result(strverifydttm,struser,strresultval,strresultunitcd,
  strnormalcycd,strusername,strtype)
   CALL echo("Entering eso_format_previous_result subroutine")
   SET strresultval1 = encode_delimiter(strresultval,";","\SC\")
   RETURN(concat("##CORRECTRESULT##",";",trim(strverifydttm),";",trim(struser),
    ";",trim(strresultval1),";",trim(strresultunitcd),";",
    trim(strnormalcycd),";",trim(strusername),";",trim(strtype)))
 END ;Subroutine
 SUBROUTINE eso_format_short_result(strverifydttm,struser,strusername,strtype)
  CALL echo("Entering eso_format_short_result subroutine")
  RETURN(concat("##CORRECTRESULT##",";",trim(strverifydttm),";",trim(struser),
   ";",trim(strusername),";",trim(strtype)))
 END ;Subroutine
 SUBROUTINE eso_format_code_for_cs(fvalue,strcodingsys,straliastypmeaning)
   IF (fvalue > 0)
    RETURN(trim(concat("##CVA_W_CS##",",",trim(cnvtstring(fvalue)),",",trim(strcodingsys),
      ",",trim(straliastypmeaning))))
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_multum_identifiers(catalog_cd,synonym_id,item_id,field_type,format_string)
   RETURN(concat("##SEND_MULTUM_IDENT##",";",trim(cnvtstring(catalog_cd)),";",trim(cnvtstring(
      synonym_id)),
    ";",trim(cnvtstring(item_id)),";",trim(field_type),";",
    trim(format_string),";"))
 END ;Subroutine
 SUBROUTINE eso_format_attachment(strattachmentname,dstoragecd,strblobhandle,dformatcd,strcommentind)
   RETURN(concat("##ATTACHMENT##",",",trim(strattachmentname),",",trim(cnvtstring(dstoragecd)),
    ",",trim(strblobhandle),",",trim(cnvtstring(dformatcd)),",",
    trim(strcommentind)))
 END ;Subroutine
 SUBROUTINE (eso_format_code_with_event_id(deventcd=f8,deventid=f8,dentitycd=f8,strsegmentname=vc,
  strfieldtype=vc) =vc)
   RETURN(eso_format_code_with_event_id_and_vocab_type(deventcd,deventid,dentitycd,strsegmentname,
    strfieldtype,
    "TEST"))
 END ;Subroutine
 SUBROUTINE (eso_format_code_with_event_id_and_vocab_type(deventcd=f8,deventid=f8,dentitycd=f8,
  strsegmentname=vc,strfieldtype=vc,strvocabularytype=vc) =vc)
   RETURN(trim(concat("##CVA##",",",trim(cnvtstring(deventcd)),","," ,",
     " ,",trim(cnvtstring(deventid)),",",trim(cnvtstring(dentitycd)),",",
     trim(strsegmentname),",",trim(strfieldtype),", ,",trim(strvocabularytype))))
 END ;Subroutine
 SUBROUTINE (eso_format_code_with_event_id_suscep_seq_nbr(deventcd=f8,deventid=f8,dentitycd=f8,
  strsegmentname=vc,strfieldtype=vc,isuscepseqnbr=i4,strvocabularytype=vc) =vc)
   RETURN(trim(concat("##CVA##",",",trim(cnvtstring(deventcd)),","," ,",
     " ,",trim(cnvtstring(deventid)),",",trim(cnvtstring(dentitycd)),",",
     trim(strsegmentname),",",trim(strfieldtype),",",trim(cnvtstring(isuscepseqnbr)),
     ",",trim(strvocabularytype))))
 END ;Subroutine
 SUBROUTINE (eso_format_code_with_event_id_micro_seq_nbr(deventcd=f8,deventid=f8,dentitycd=f8,
  strsegmentname=vc,strfieldtype=vc,imicroseqnbr=i4,strvocabularytype=vc) =vc)
   RETURN(trim(concat("##CVA##",",",trim(cnvtstring(deventcd)),","," ,",
     " ,",trim(cnvtstring(deventid)),",",trim(cnvtstring(dentitycd)),",",
     trim(strsegmentname),",",trim(strfieldtype),",",trim(cnvtstring(imicroseqnbr)),
     ",",trim(strvocabularytype))))
 END ;Subroutine
 SUBROUTINE (eso_format_nomen_or_string(strvalue=vc,deventid=f8,dentitycd=f8,strsegmentname=vc,
  strfieldtype=vc,imicroseqnbr=i4) =vc)
   RETURN(trim(concat("##NOS##",",",trim(strvalue),",",trim(cnvtstring(deventid)),
     ",",trim(cnvtstring(dentitycd)),",",trim(strsegmentname),",",
     trim(strfieldtype),",",trim(cnvtstring(imicroseqnbr)))))
 END ;Subroutine
 SUBROUTINE (eso_nomen_concept(dnomenid=f8) =i4)
   DECLARE icnt = i4 WITH protect, noconstant(1)
   DECLARE inomenidx = i4 WITH protect, noconstant(0)
   DECLARE inomensize = i4 WITH protect, noconstant(size(result_struct->nomenclatures,5))
   SET inomenidx = locateval(icnt,1,inomensize,dnomenid,result_struct->nomenclatures[icnt].nomen_id)
   IF (inomenidx=0)
    SELECT INTO "nl:"
     n.source_string, n.source_vocabulary_cd, cmt.concept_identifier,
     cmt.concept_name
     FROM cmt_concept cmt,
      nomenclature n
     PLAN (n
      WHERE n.nomenclature_id=dnomenid)
      JOIN (cmt
      WHERE cmt.concept_cki=n.concept_cki
       AND cmt.active_ind=1)
     DETAIL
      IF (size(trim(n.concept_cki)) > 0)
       inomenidx = (inomensize+ 1), stat = alterlist(result_struct->nomenclatures,inomenidx),
       result_struct->nomenclatures[inomenidx].nomen_id = dnomenid,
       result_struct->nomenclatures[inomenidx].concept_ident = cmt.concept_identifier, result_struct
       ->nomenclatures[inomenidx].concept_name = cmt.concept_name, result_struct->nomenclatures[
       inomenidx].source_string = n.source_string,
       result_struct->nomenclatures[inomenidx].source_vocab_cd = n.source_vocabulary_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   RETURN(inomenidx)
 END ;Subroutine
 SUBROUTINE (populate_order_diagnoses(dorderid=f8,iobridx=i4) =i4)
   DECLARE idiagsize = i4 WITH protect, noconstant(0)
   DECLARE idiagidx = i4 WITH protect, noconstant(0)
   DECLARE inomidx = i4 WITH protect, noconstant(0)
   DECLARE dorderdiagcd = f8 WITH protect, constant(eso_get_meaning_by_codeset(23549,"ORDERDIAG"))
   DECLARE dordericd9cd = f8 WITH protect, constant(eso_get_meaning_by_codeset(23549,"ORDERICD9"))
   FREE RECORD diaglist
   RECORD diaglist(
     1 item[*]
       2 nomen_id = f8
       2 ft_desc = vc
   )
   SELECT INTO "nl:"
    table_ind = decode(n.seq,"n",d.seq,"d","x"), n.nomenclature_id, d.diag_ftdesc
    FROM nomen_entity_reltn er,
     nomenclature n,
     diagnosis d,
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1)
    PLAN (er
     WHERE er.active_ind > 0
      AND er.parent_entity_name="ORDERS"
      AND er.parent_entity_id=dorderid
      AND ((er.reltn_type_cd=dorderdiagcd) OR (er.reltn_type_cd=dordericd9cd)) )
     JOIN (d1)
     JOIN (((n
     WHERE er.nomenclature_id > 0.0
      AND n.nomenclature_id=er.nomenclature_id)
     ) ORJOIN ((d2)
     JOIN (d
     WHERE er.nomenclature_id <= 0.0
      AND er.child_entity_name="DIAGNOSIS"
      AND d.diagnosis_id=er.child_entity_id)
     ))
    HEAD REPORT
     i = 0
    DETAIL
     CASE (table_ind)
      OF "n":
       i += 1,stat = alterlist(diaglist->item,i),diaglist->item[i].nomen_id = n.nomenclature_id
      OF "d":
       i += 1,stat = alterlist(diaglist->item,i),diaglist->item[i].ft_desc = trim(d.diag_ftdesc,3)
      OF "x":
       CALL echo(build(
        "WARNING!! Did NOT join to either NOMENCLATURE or DIAGNOSIS tables for ORDER_ID = ",dorderid)
       )
     ENDCASE
    WITH nocounter, outerjoin = d1
   ;end select
   SET idiagsize = size(diaglist->item,5)
   FOR (idiagidx = 1 TO idiagsize)
     IF ((diaglist->item[idiagidx].nomen_id > 0.0))
      SET ifoundidx = eso_nomen_concept(diaglist->item[idiagidx].nomen_id)
      IF (ifoundidx)
       SET irealidx = (size(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,
        5)+ 1)
       SET stat = alterlist(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,
        irealidx)
       SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].
       identifier = result_struct->nomenclatures[ifoundidx].concept_ident
       SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].text
        = result_struct->nomenclatures[ifoundidx].concept_name
       SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].
       coding_system = eso_format_code(result_struct->nomenclatures[ifoundidx].source_vocab_cd)
       SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].
       original_text = result_struct->nomenclatures[ifoundidx].source_string
      ENDIF
     ELSEIF (size(trim(diaglist->item[idiagidx].ft_desc)) > 0)
      SET irealidx = (size(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,
       5)+ 1)
      SET stat = alterlist(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,
       irealidx)
      SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].text =
      trim(diaglist->item[idiagidx].ft_desc)
     ENDIF
   ENDFOR
   RETURN(size(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,5))
 END ;Subroutine
 SUBROUTINE eso_format_phone_cd(dphonetypecd,dcontactmethodcd)
   IF ((validate(g_dpvdphtpalternate,- (1))=- (1)))
    DECLARE g_dpvdphtpalternate = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "ALTERNATE"))
   ENDIF
   IF ((validate(g_dpvdphtpbilling,- (1))=- (1)))
    DECLARE g_dpvdphtpbilling = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "BILLING"))
   ENDIF
   IF ((validate(g_dpvdphtpbusiness,- (1))=- (1)))
    DECLARE g_dpvdphtpbusiness = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "BUSINESS"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxalt,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxalt = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX ALT"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxbill,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxbill = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX BILL"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxbus,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxbus = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX BUS"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxpers,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxpers = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX PERS"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxtemp,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxtemp = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX TEMP"))
   ENDIF
   IF ((validate(g_dpvdphtphome,- (1))=- (1)))
    DECLARE g_dpvdphtphome = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,"HOME"))
   ENDIF
   IF ((validate(g_dpvdphtpmobile,- (1))=- (1)))
    DECLARE g_dpvdphtpmobile = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "MOBILE"))
   ENDIF
   IF ((validate(g_dpvdphtposafterhour,- (1))=- (1)))
    DECLARE g_dpvdphtposafterhour = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "OS AFTERHOUR"))
   ENDIF
   IF ((validate(g_dpvdphtposphone,- (1))=- (1)))
    DECLARE g_dpvdphtposphone = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "OS PHONE"))
   ENDIF
   IF ((validate(g_dpvdphtpospager,- (1))=- (1)))
    DECLARE g_dpvdphtpospager = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "OS PAGER"))
   ENDIF
   IF ((validate(g_dpvdphtposbkoffice,- (1))=- (1)))
    DECLARE g_dpvdphtposbkoffice = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "OS BK OFFICE"))
   ENDIF
   IF ((validate(g_dpvdphtppageralt,- (1))=- (1)))
    DECLARE g_dpvdphtppageralt = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER ALT"))
   ENDIF
   IF ((validate(g_dpvdphtppagerbill,- (1))=- (1)))
    DECLARE g_dpvdphtppagerbill = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER BILL"))
   ENDIF
   IF ((validate(g_dpvdphtppagerbus,- (1))=- (1)))
    DECLARE g_dpvdphtppagerbus = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER BUS"))
   ENDIF
   IF ((validate(g_dpvdphtppagertemp,- (1))=- (1)))
    DECLARE g_dpvdphtppagertemp = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER TEMP"))
   ENDIF
   IF ((validate(g_dpvdphtppagerpers,- (1))=- (1)))
    DECLARE g_dpvdphtppagerpers = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER PERS"))
   ENDIF
   IF ((validate(g_dpvdphtppaging,- (1))=- (1)))
    DECLARE g_dpvdphtppaging = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGING"))
   ENDIF
   IF ((validate(g_dpvdphtpportbus,- (1))=- (1)))
    DECLARE g_dpvdphtpportbus = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PORT BUS"))
   ENDIF
   IF ((validate(g_dpvdphtpporttemp,- (1))=- (1)))
    DECLARE g_dpvdphtpporttemp = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PORT TEMP"))
   ENDIF
   IF ((validate(g_dpvdphtpsecbusiness,- (1))=- (1)))
    DECLARE g_dpvdphtpsecbusiness = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "SECBUSINESS"))
   ENDIF
   IF ((validate(g_dpvdphtptechnical,- (1))=- (1)))
    DECLARE g_dpvdphtptechnical = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "TECHNICAL"))
   ENDIF
   IF ((validate(g_dpvdphtpverify,- (1))=- (1)))
    DECLARE g_dpvdphtpverify = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "VERIFY"))
   ENDIF
   IF ((validate(g_deprescphone,- (1))=- (1)))
    DECLARE g_deprescphone = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PHONEEPRESCR"))
   ENDIF
   IF ((validate(g_deprescfax,- (1))=- (1)))
    DECLARE g_deprescfax = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAXEPRESCR"))
   ENDIF
   IF ((validate(g_dpvdphfmtfax,- (1))=- (1)))
    DECLARE g_dpvdphfmtfax = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(23056,"FAX"
      ))
   ENDIF
   IF ((validate(g_dpvdphfmttel,- (1))=- (1)))
    DECLARE g_dpvdphfmttel = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(23056,"TEL"
      ))
   ENDIF
   IF ((validate(g_dpvdphfmtemail,- (1))=- (1)))
    DECLARE g_dpvdphfmtemail = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(23056,
      "MAILTO"))
   ENDIF
   IF (((dcontactmethodcd=0) OR (dcontactmethodcd=g_dpvdphfmttel)) )
    IF (dphonetypecd IN (g_dpvdphtpalternate, g_dpvdphtpbilling, g_dpvdphtpbusiness, g_dpvdphtpfaxalt,
    g_dpvdphtpfaxbill,
    g_dpvdphtpfaxbus, g_dpvdphtpfaxpers, g_dpvdphtpfaxtemp, g_dpvdphtphome, g_dpvdphtpmobile,
    g_dpvdphtposafterhour, g_dpvdphtposphone, g_dpvdphtpospager, g_dpvdphtposbkoffice,
    g_dpvdphtppageralt,
    g_dpvdphtppagerbill, g_dpvdphtppagerbus, g_dpvdphtppagertemp, g_dpvdphtppagerpers,
    g_dpvdphtppaging,
    g_dpvdphtpportbus, g_dpvdphtpporttemp, g_dpvdphtpsecbusiness, g_dpvdphtptechnical,
    g_dpvdphtpverify,
    g_deprescphone, g_deprescfax))
     RETURN(eso_format_code(dphonetypecd))
    ELSE
     RETURN(" ")
    ENDIF
   ELSE
    RETURN(eso_format_code(dcontactmethodcd))
   ENDIF
 END ;Subroutine
 CALL echo("<===== ESO_HL7_FORMATTING.INC End =====>")
 CALL echo("<===== ESO_EFFECTIVE_TIME_ADJUST.INC  START =====>")
 CALL echo("MOD:000")
 IF ( NOT (validate(g_desoefftmadj)))
  DECLARE desoefftmadjtmp = f8 WITH protect, noconstant(0.0)
  DECLARE desoeffectivetimeadjustcd = f8 WITH protect, constant(eso_get_meaning_by_codeset(14874,
    "ESOEFFTMADJ"))
  DECLARE desocontribdefault = f8 WITH protect, constant(eso_get_meaning_by_codeset(89,"ESODEFAULT"))
  SELECT INTO "nl:"
   op.contributor_system_cd, op.process_type_cd, op.null_string
   FROM outbound_field_processing op
   WHERE op.contributor_system_cd=desocontribdefault
    AND op.process_type_cd=desoeffectivetimeadjustcd
   DETAIL
    desoefftmadjtmp = (100 * cnvtreal(op.null_string))
   WITH nocounter
  ;end select
  DECLARE g_desoefftmadj = f8 WITH persist, constant(desoefftmadjtmp)
 ENDIF
 DECLARE get_encntr_prsnl_info_idx(encntr_id1,reln_type_cdf1) = i4
 DECLARE fetch_encntr_prsnl_info(encntr_id2,reln_type_cdf2,mode2) = i4
 DECLARE fetch_encntr_prsnl_from_db(encntr_id3,reln_type_cdf3,mode3,eidx3) = i4
 DECLARE get_prsnl_info_idx(person_id4) = i4
 DECLARE fetch_prsnl_info(person_id5,mode5) = i4
 DECLARE fetch_prsnl_from_db(person_id6,mode6,pidx6) = i4
 DECLARE get_person_info_idx(person_id7,encntr_id7,mode7) = i4
 DECLARE fetch_person_info(person_id8,encntr_id8,mode8) = i4
 DECLARE fetch_person_from_db(person_id9,encntr_id9,mode9,pidx9) = i4
 DECLARE eso_format_prsnl_enctr(field1,field2,encntr_id,reln_type_cdf,mode,
  hl7_struct,repeat_ind) = c100
 DECLARE eso_format_prsnl_enctr_ctx(field1,field2,encntr_id,reln_type_cdf,mode,
  hl7_struct,repeat_ind) = c100
 DECLARE get_encntr_prsnl_id_info_idx(encntr_id10,reln_type_cdf10,person_id10) = i4
 DECLARE fetch_encntr_prsnl_id_info(encntr_id11,reln_type_cdf11,person_id11,mode11) = i4
 DECLARE fetch_encntr_prsnl_id_from_db(encntr_id12,reln_type_cdf12,mode12,eidx12,person_id12) = i4
 DECLARE eso_format_prsnl_id_enctr(field1,field2,encntr_id,reln_type_cdf,person_id,
  mode,hl7_struct,repeat_ind) = c100
 DECLARE eso_format_prsnl_id_enctr_ctx(field1,field2,encntr_id,reln_type_cdf,person_id,
  mode,hl7_struct,repeat_ind) = c100
 DECLARE eso_format_prsnl_id(field_cdf,group_cdf,xx_name,xx_id,xx_cdf,
  x_person_id,ui_struct,instance) = c100
 SUBROUTINE get_encntr_prsnl_info_idx(encntr_id1,reln_type_cdf1)
   SET list_size = 0
   SET list_size = size(context->cerner.encntr_prsnl_info.encntr,5)
   IF (list_size > 0
    AND encntr_id1 > 0)
    SET ieso1 = 1
    FOR (ieso1 = ieso1 TO list_size)
      IF ((context->cerner.encntr_prsnl_info.encntr[ieso1].encntr_id=encntr_id1))
       IF (trim(reln_type_cdf1) > "")
        IF ((context->cerner.encntr_prsnl_info.encntr[ieso1].reln_type_cdf=reln_type_cdf1))
         RETURN(ieso1)
        ENDIF
       ELSE
        RETURN(ieso1)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE fetch_encntr_prsnl_info(encntr_id2,reln_type_cdf2,mode2)
   IF (encntr_id2=0)
    RETURN(0)
   ENDIF
   SET eidx = 0
   SET eidx = get_encntr_prsnl_info_idx(encntr_id2,reln_type_cdf2)
   IF (eidx > 0)
    RETURN(eidx)
   ENDIF
   SET eidx = (size(context->cerner.encntr_prsnl_info.encntr,5)+ 1)
   SET stat = 0
   SET stat = alterlist(context->cerner.encntr_prsnl_info.encntr,eidx)
   SET context->cerner.encntr_prsnl_info.encntr_count = eidx
   SET context->cerner.encntr_prsnl_info.encntr[eidx].encntr_id = encntr_id2
   SET context->cerner.encntr_prsnl_info.encntr[eidx].reln_type_cdf = reln_type_cdf2
   SET context->cerner.encntr_prsnl_info.encntr[eidx].prsnl_r_count = 0
   SET stat = 0
   SET stat = fetch_encntr_prsnl_from_db(encntr_id2,reln_type_cdf2,mode2,eidx)
   IF (stat=0)
    SET stat = alterlist(context->cerner.encntr_prsnl_info.encntr,(eidx - 1))
    SET context->cerner.encntr_prsnl_info.encntr_count = (eidx - 1)
    RETURN(0)
   ENDIF
   RETURN(stat)
 END ;Subroutine
 SUBROUTINE fetch_encntr_prsnl_from_db(encntr_id3,reln_type_cdf3,mode3,eidx3)
   SET reln_type_cd = 0
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    WHERE c.code_set=333
     AND c.cdf_meaning=trim(reln_type_cdf3)
     AND c.active_ind=1
     AND c.begin_effective_dt_tm < cnvtdatetime(sysdate)
     AND ((c.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (c.end_effective_dt_tm=null))
    DETAIL
     reln_type_cd = c.code_value
    WITH nocounter
   ;end select
   SET count = 0
   SELECT INTO "nl:"
    e.prsnl_person_id, e.ft_prsnl_name, e.free_text_cd,
    e.encntr_prsnl_r_cd
    FROM encntr_prsnl_reltn e
    WHERE e.encntr_id=encntr_id3
     AND e.encntr_id > 0
     AND e.encntr_prsnl_r_cd=reln_type_cd
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
     AND ((e.end_effective_dt_tm > cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))) OR (e
    .end_effective_dt_tm=null))
    DETAIL
     count += 1, stat = alterlist(context->cerner.encntr_prsnl_info.encntr[eidx3].prsnl_r,count),
     context->cerner.encntr_prsnl_info.encntr[eidx3].prsnl_r[count].prsnl_person_id = e
     .prsnl_person_id,
     context->cerner.encntr_prsnl_info.encntr[eidx3].prsnl_r[count].ft_prsnl_name = trim(e
      .ft_prsnl_name,3), context->cerner.encntr_prsnl_info.encntr[eidx3].prsnl_r[count].free_text_cd
      = e.free_text_cd, context->cerner.encntr_prsnl_info.encntr[eidx3].prsnl_r[count].
     encntr_prsnl_r_cd = e.encntr_prsnl_r_cd
    WITH nocounter
   ;end select
   SET context->cerner.encntr_prsnl_info.encntr[eidx3].prsnl_r_count = count
   IF (curqual > 0)
    SET ieso3 = 1
    FOR (ieso3 = ieso3 TO count)
      SET context->cerner.encntr_prsnl_info.encntr[eidx3].prsnl_r[ieso3].idx = fetch_prsnl_info(
       context->cerner.encntr_prsnl_info.encntr[eidx3].prsnl_r[ieso3].prsnl_person_id,mode3)
    ENDFOR
   ELSE
    RETURN(0)
   ENDIF
   RETURN(eidx3)
 END ;Subroutine
 SUBROUTINE get_encntr_prsnl_id_info_idx(encntr_id10,reln_type_cdf10,person_id10)
   SET list_size = 0
   SET list_size = size(context->cerner.encntr_prsnl_info.encntr,5)
   SET p_size = 0
   IF (list_size > 0
    AND encntr_id10 > 0
    AND person_id10 > 0)
    SET ieso10 = 1
    FOR (ieso10 = ieso10 TO list_size)
      IF ((context->cerner.encntr_prsnl_info.encntr[ieso10].encntr_id=encntr_id10))
       IF (trim(reln_type_cdf10) > "")
        IF ((context->cerner.encntr_prsnl_info.encntr[ieso10].reln_type_cdf=reln_type_cdf10))
         SET p_size = size(context->cerner.encntr_prsnl_info.encntr[ieso10].prsnl_r,5)
         IF (p_size > 0)
          SET jeso10 = 1
          FOR (jeso10 = jeso10 TO p_size)
            IF ((context->cerner.encntr_prsnl_info.encntr[ieso10].prsnl_r[jeso10].prsnl_person_id=
            person_id10))
             RETURN(ieso10)
            ENDIF
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        SET p_size = size(context->cerner.encntr_prsnl_info.encntr[ieso10].prsnl_r,5)
        IF (p_size > 0)
         SET jeso10 = 1
         FOR (jeso10 = jeso10 TO p_size)
           IF ((context->cerner.encntr_prsnl_info.encntr[ieso10].prsnl_r[jeso10].prsnl_person_id=
           person_id10))
            RETURN(ieso10)
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE fetch_encntr_prsnl_id_info(encntr_id11,reln_type_cdf11,person_id11,mode11)
   SET stat = 0
   IF (((encntr_id11=0) OR (person_id11=0)) )
    RETURN(0)
   ENDIF
   SET eidx = 0
   SET eidx = get_encntr_prsnl_id_info_idx(encntr_id11,reln_type_cdf11,person_id11)
   IF (eidx > 0)
    RETURN(eidx)
   ENDIF
   SET eidx = get_encntr_prsnl_info_idx(encntr_id11,reln_type_cdf11)
   IF (eidx > 0)
    SET stat = fetch_encntr_prsnl_id_from_db(encntr_id11,reln_type_cdf11,mode11,eidx,person_id11)
    RETURN(stat)
   ENDIF
   SET eidx = (size(context->cerner.encntr_prsnl_info.encntr,5)+ 1)
   SET stat = 0
   SET stat = alterlist(context->cerner.encntr_prsnl_info.encntr,eidx)
   SET context->cerner.encntr_prsnl_info.encntr_count = eidx
   SET context->cerner.encntr_prsnl_info.encntr[eidx].encntr_id = encntr_id11
   SET context->cerner.encntr_prsnl_info.encntr[eidx].reln_type_cdf = reln_type_cdf11
   SET context->cerner.encntr_prsnl_info.encntr[eidx].prsnl_r_count = 0
   SET stat = fetch_encntr_prsnl_id_from_db(encntr_id11,reln_type_cdf11,mode11,eidx,person_id11)
   IF (stat=0)
    SET stat = alterlist(context->cerner.encntr_prsnl_info.encntr,(eidx - 1))
    SET context->cerner.encntr_prsnl_info.encntr_count = (eidx - 1)
    RETURN(0)
   ENDIF
   RETURN(stat)
 END ;Subroutine
 SUBROUTINE fetch_encntr_prsnl_id_from_db(encntr_id12,reln_type_cdf12,mode12,eidx12,person_id12)
   IF (person_id12=0)
    RETURN(0)
   ENDIF
   SET stat = 0
   SET count = (size(context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r,5)+ 1)
   SET stat = alterlist(context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r,count)
   SET context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r[count].prsnl_person_id = person_id12
   SET context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r[count].ft_prsnl_name = ""
   SET context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r[count].free_text_cd = 0
   SET context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r[count].encntr_prsnl_r_cd = 0
   SET context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r_count = count
   SET ieso12 = 1
   FOR (ieso12 = ieso12 TO count)
     SET context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r[ieso12].idx = fetch_prsnl_info(
      context->cerner.encntr_prsnl_info.encntr[eidx12].prsnl_r[ieso12].prsnl_person_id,mode12)
   ENDFOR
   RETURN(eidx12)
 END ;Subroutine
 SUBROUTINE get_prsnl_info_idx(person_id4)
   SET list_size = 0
   SET list_size = size(context->cerner.prsnl_info.prsnl,5)
   IF (list_size > 0
    AND person_id4 > 0)
    SET ieso4 = 1
    FOR (ieso4 = ieso4 TO list_size)
      IF ((context->cerner.prsnl_info.prsnl[ieso4].person_id=person_id4))
       RETURN(ieso4)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE fetch_prsnl_info(person_id5,mode5)
   IF (person_id5=0)
    RETURN(0)
   ENDIF
   SET pidx = 0
   SET pidx = get_prsnl_info_idx(person_id5)
   IF (pidx > 0)
    RETURN(pidx)
   ENDIF
   SET pidx = (size(context->cerner.prsnl_info.prsnl,5)+ 1)
   SET stat = 0
   SET stat = alterlist(context->cerner.prsnl_info.prsnl,pidx)
   SET context->cerner.prsnl_info.prsnl_count = pidx
   SET context->cerner.prsnl_info.prsnl[pidx].person_id = person_id5
   SET context->cerner.prsnl_info.prsnl[pidx].alias_count = 0
   SET context->cerner.prsnl_info.prsnl[pidx].name_count = 0
   SET stat = fetch_prsnl_from_db(person_id5,mode5,pidx)
   IF (stat=0)
    SET stat = alterlist(context->cerner.prsnl_info.prsnl,(pidx - 1))
   ENDIF
   RETURN(stat)
 END ;Subroutine
 SUBROUTINE fetch_prsnl_from_db(person_id6,mode6,pidx6)
   SET aidx = 0
   SET nidx = 0
   SET stat = 0
   SET prsnl_name_cd = 0
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    WHERE c.code_set=213
     AND c.cdf_meaning="PRSNL"
     AND c.active_ind=1
     AND c.begin_effective_dt_tm < cnvtdatetime(sysdate)
     AND ((c.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (c.end_effective_dt_tm=null))
    DETAIL
     prsnl_name_cd = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    p.name_last, p.name_first, p.name_middle,
    p.name_suffix, p.name_prefix, p.name_degree,
    p.name_full, p.name_type_cd, p.name_title
    FROM person_name p
    WHERE p.person_id=person_id6
     AND p.person_id > 0
     AND p.name_type_cd=prsnl_name_cd
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
     AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))) OR (p
    .end_effective_dt_tm=null))
    DETAIL
     nidx += 1, stat = alterlist(context->cerner.prsnl_info.prsnl[pidx6].name,nidx), context->cerner.
     prsnl_info.prsnl[pidx6].name[nidx].name_last = trim(p.name_last,3),
     context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_first = trim(p.name_first,3), context->
     cerner.prsnl_info.prsnl[pidx6].name[nidx].name_middle = trim(p.name_middle,3), context->cerner.
     prsnl_info.prsnl[pidx6].name[nidx].name_suffix = trim(p.name_suffix,3)
     IF (size(trim(p.name_prefix,3)) > 0)
      context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_prefix = trim(p.name_prefix,3)
     ELSE
      context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_prefix = trim(p.name_title,3)
     ENDIF
     context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_degree = trim(p.name_degree,3), context
     ->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full = trim(p.name_full,3), context->cerner.
     prsnl_info.prsnl[pidx6].name[nidx].name_type_cd = p.name_type_cd
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SELECT INTO "nl:"
     p.name_last_key, p.name_first_key, p.name_full_formatted,
     p.name_last, p.name_first
     FROM prsnl p
     WHERE p.person_id=person_id6
      AND p.person_id > 0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
      AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))) OR (p
     .end_effective_dt_tm=null))
     DETAIL
      nidx += 1, stat = alterlist(context->cerner.prsnl_info.prsnl[pidx6].name,nidx), context->cerner
      .prsnl_info.prsnl[pidx6].name[nidx].name_last = trim(p.name_last,3),
      context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_first = trim(p.name_first,3), context->
      cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full = trim(p.name_full_formatted,3)
      IF (trim(context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_last)="")
       IF (trim(context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full) > "")
        nlen = 0, nlen = size(context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full), lpos = 0,
        llen = 0, lpos = findstring(" -",context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full
         )
        IF (lpos > 0)
         lpos += 2
        ELSE
         lpos = 1
        ENDIF
        fpos = 0, flen = 0, mpos = 0,
        mlen = 0, fpos = findstring(", ",context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full,
         lpos)
        IF (fpos > 0)
         llen = (fpos - lpos), fpos += 2, mpos = findstring(" ",context->cerner.prsnl_info.prsnl[
          pidx6].name[nidx].name_full,fpos)
         IF (mpos > 0)
          flen = (mpos - fpos), mpos += 1, mlen = ((nlen - mpos)+ 1)
         ELSE
          flen = ((nlen - fpos)+ 1)
         ENDIF
        ELSE
         llen = ((nlen - fpos)+ 1)
        ENDIF
        IF (llen > 0)
         context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_last = substring(lpos,llen,context->
          cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full)
        ENDIF
        IF (flen > 0)
         context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_first = substring(fpos,flen,context
          ->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full)
        ENDIF
        IF (mlen > 0)
         context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_middle = substring(mpos,mlen,context
          ->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_full)
        ENDIF
       ELSE
        context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_last = trim(p.name_last_key,3),
        context->cerner.prsnl_info.prsnl[pidx6].name[nidx].name_first = trim(p.name_first_key,3)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SET context->cerner.prsnl_info.prsnl[pidx6].name_count = nidx
   SELECT INTO "nl:"
    p.alias, p.prsnl_alias_type_cd, p.prsnl_alias_sub_type_cd,
    p.alias_pool_cd, p.check_digit, p.check_digit_method_cd,
    p.contributor_system_cd
    FROM prsnl_alias p
    WHERE p.person_id=person_id6
     AND p.person_id > 0
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
     AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))) OR (p
    .end_effective_dt_tm=null))
    DETAIL
     aidx += 1, stat = alterlist(context->cerner.prsnl_info.prsnl[pidx6].alias,aidx), context->cerner
     .prsnl_info.prsnl[pidx6].alias[aidx].alias = trim(p.alias,3),
     context->cerner.prsnl_info.prsnl[pidx6].alias[aidx].alias_type_cd = p.prsnl_alias_type_cd,
     context->cerner.prsnl_info.prsnl[pidx6].alias[aidx].alias_subtype_cd = p.prsnl_alias_sub_type_cd,
     context->cerner.prsnl_info.prsnl[pidx6].alias[aidx].alias_pool_cd = p.alias_pool_cd,
     context->cerner.prsnl_info.prsnl[pidx6].alias[aidx].check_digit = p.check_digit, context->cerner
     .prsnl_info.prsnl[pidx6].alias[aidx].check_digit_method_cd = p.check_digit_method_cd, context->
     cerner.prsnl_info.prsnl[pidx6].alias[aidx].contributor_system_cd = p.contributor_system_cd
    WITH nocounter
   ;end select
   SET context->cerner.prsnl_info.prsnl[pidx6].alias_count = aidx
   RETURN(pidx6)
 END ;Subroutine
 SUBROUTINE get_person_info_idx(person_id7,encntr_id7)
   SET list_size = 0
   SET list_size = size(context->cerner.person_info.person,5)
   IF (list_size > 0
    AND person_id7 > 0)
    SET ieso7 = 1
    FOR (ieso7 = ieso7 TO list_size)
      IF ((context->cerner.person_info.person[ieso7].person_id=person_id7))
       IF (encntr_id7 > 0)
        IF ((context->cerner.person_info.person[ieso7].encntr_id=encntr_id7))
         RETURN(ieso7)
        ENDIF
       ELSE
        RETURN(ieso7)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE fetch_person_info(person_id8,encntr_id8,mode8)
   IF (person_id8=0)
    RETURN(0)
   ENDIF
   SET pidx = 0
   SET pidx = get_person_info_idx(person_id8,encntr_id8)
   IF (pidx > 0)
    RETURN(pidx)
   ENDIF
   SET pidx = (size(context->cerner.person_info.person,5)+ 1)
   SET stat = 0
   SET stat = alterlist(context->cerner.person_info.person,pidx)
   SET context->cerner.person_info.person_count = pidx
   SET context->cerner.person_info.person[pidx].person_id = person_id8
   SET context->cerner.person_info.person[pidx].encntr_id = encntr_id8
   SET context->cerner.person_info.person[pidx].alias_count = 0
   SET context->cerner.person_info.person[pidx].encntr_count = 0
   SET context->cerner.person_info.person[pidx].name_count = 0
   SET stat = fetch_person_from_db(person_id8,encntr_id8,mode8,pidx)
   IF (stat=0)
    SET stat = alterlist(context->cerner.person_info.person,(pidx - 1))
   ENDIF
   RETURN(stat)
 END ;Subroutine
 SUBROUTINE fetch_person_from_db(person_id9,encntr_id9,mode9,pidx9)
   SET aidx = 0
   SET nidx = 0
   SET current_name_cd = 0
   SET stat = 0
   SELECT INTO "nl:"
    p.name_last, p.name_first, p.name_middle,
    p.name_suffix, p.name_prefix, p.name_degree,
    p.name_full, p.name_type_cd
    FROM person_name p
    WHERE p.person_id=person_id9
     AND p.person_id > 0
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
     AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))) OR (p
    .end_effective_dt_tm=null))
    DETAIL
     nidx += 1, stat = alterlist(context->cerner.person_info.person[pidx9].name,nidx), context->
     cerner.person_info.person[pidx9].name[nidx].name_last = trim(p.name_last,3),
     context->cerner.person_info.person[pidx9].name[nidx].name_first = trim(p.name_first,3), context
     ->cerner.person_info.person[pidx9].name[nidx].name_middle = trim(p.name_middle,3), context->
     cerner.person_info.person[pidx9].name[nidx].name_suffix = trim(p.name_suffix,3),
     context->cerner.person_info.person[pidx9].name[nidx].name_prefix = trim(p.name_prefix,3),
     context->cerner.person_info.person[pidx9].name[nidx].name_degree = trim(p.name_degree,3),
     context->cerner.person_info.person[pidx9].name[nidx].name_full = trim(p.name_full,3),
     context->cerner.person_info.person[pidx9].name[nidx].name_type_cd = p.name_type_cd
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SELECT INTO "nl:"
     p.name_last_key, p.name_first_key, p.name_full_formatted,
     p.name_last, p.name_first, p.name_middle
     FROM person p
     WHERE p.person_id=person_id9
      AND p.person_id > 0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
      AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))) OR (p
     .end_effective_dt_tm=null))
     DETAIL
      nidx += 1, stat = alterlist(context->cerner.person_info.person[pidx9].name,nidx), context->
      cerner.person_info.person[pidx9].name[nidx].name_last = trim(p.name_last,3),
      context->cerner.person_info.person[pidx9].name[nidx].name_first = trim(p.name_first,3), context
      ->cerner.person_info.person[pidx9].name[nidx].name_middle = trim(p.name_middle,3), context->
      cerner.person_info.person[pidx9].name[nidx].name_full = trim(p.name_full_formatted,3)
      IF (trim(context->cerner.person_info.person[pidx9].name[nidx].name_last)="")
       context->cerner.person_info.person[pidx9].name[nidx].name_last = trim(p.name_last_key,3),
       context->cerner.person_info.person[pidx9].name[nidx].name_first = trim(p.name_first_key,3)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SET context->cerner.person_info.person[pidx9].name_count = nidx
   SELECT INTO "nl:"
    p.alias, p.person_alias_type_cd, p.person_alias_sub_type_cd,
    p.alias_pool_cd, p.check_digit, p.check_digit_method_cd,
    p.contributor_system_cd
    FROM person_alias p
    WHERE p.person_id=person_id9
     AND p.person_id > 0
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
     AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))) OR (p
    .end_effective_dt_tm=null))
    DETAIL
     aidx += 1, stat = alterlist(context->cerner.person_info.person[pidx9].alias,aidx), context->
     cerner.person_info.person[pidx9].alias[aidx].alias = trim(p.alias,3),
     context->cerner.person_info.person[pidx9].alias[aidx].alias_type_cd = p.person_alias_type_cd,
     context->cerner.person_info.person[pidx9].alias[aidx].alias_subtype_cd = p
     .person_alias_sub_type_cd, context->cerner.person_info.person[pidx9].alias[aidx].alias_pool_cd
      = p.alias_pool_cd,
     context->cerner.person_info.person[pidx9].alias[aidx].check_digit = p.check_digit, context->
     cerner.person_info.person[pidx9].alias[aidx].check_digit_method_cd = p.check_digit_method_cd,
     context->cerner.person_info.person[pidx9].alias[aidx].contributor_system_cd = p
     .contributor_system_cd,
     context->cerner.person_info.person[pidx9].alias[aidx].encntr_ind = 0, context->cerner.
     person_info.person[pidx9].alias[aidx].org_id = 0
    WITH nocounter
   ;end select
   IF (encntr_id9 > 0)
    SELECT INTO "nl:"
     e.organization_id, ea.alias, ea.encntr_alias_type_cd,
     ea.encntr_alias_sub_type_cd, ea.alias_pool_cd, ea.check_digit,
     ea.check_digit_method_cd, ea.contributor_system_cd
     FROM encounter e,
      encntr_alias ea
     PLAN (e
      WHERE e.encntr_id=encntr_id9
       AND e.encntr_id > 0)
      JOIN (ea
      WHERE e.encntr_id=ea.encntr_id
       AND ea.active_ind=1
       AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
       AND ((ea.end_effective_dt_tm > cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))) OR (ea
      .end_effective_dt_tm=null)) )
     DETAIL
      aidx += 1, stat = alterlist(context->cerner.person_info.person[pidx9].alias,aidx), context->
      cerner.person_info.person[pidx9].alias[aidx].alias = trim(ea.alias,3),
      context->cerner.person_info.person[pidx9].alias[aidx].alias_type_cd = ea.encntr_alias_type_cd,
      context->cerner.person_info.person[pidx9].alias[aidx].alias_subtype_cd = ea
      .encntr_alias_sub_type_cd, context->cerner.person_info.person[pidx9].alias[aidx].alias_pool_cd
       = ea.alias_pool_cd,
      context->cerner.person_info.person[pidx9].alias[aidx].check_digit = ea.check_digit, context->
      cerner.person_info.person[pidx9].alias[aidx].check_digit_method_cd = ea.check_digit_method_cd,
      context->cerner.person_info.person[pidx9].alias[aidx].contributor_system_cd = ea
      .contributor_system_cd,
      context->cerner.person_info.person[pidx9].alias[aidx].encntr_ind = 1, context->cerner.
      person_info.person[pidx9].alias[aidx].org_id = e.organization_id
     WITH nocounter
    ;end select
   ENDIF
   SET context->cerner.person_info.person[pidx9].alias_count = aidx
   RETURN(pidx9)
 END ;Subroutine
 SUBROUTINE eso_format_prsnl_enctr(field1,field2,encntr_id,reln_type_cdf,mode,hl7_struct,repeat_ind)
   IF (encntr_id > 0
    AND trim(reln_type_cdf) > "")
    SET t_encntr_id = encntr_id
    SET t_reln_type_cdf = reln_type_cdf
    SET t_mode = mode
    RETURN(substring(1,100,concat(trim(request->esoinfo.eprsnlprefix),",",trim(field1),",",trim(
       field2),
      ",",trim(cnvtstring(fetch_encntr_prsnl_info(t_encntr_id,t_reln_type_cdf,t_mode))),",",trim(
       hl7_struct),",",
      trim(cnvtstring(repeat_ind)),",",trim(cnvtstring(encntr_id)),",",trim(reln_type_cdf))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_prsnl_enctr_ctx(field1,field2,encntr_id,reln_type_cdf,mode,hl7_struct,
  repeat_ind)
   IF (encntr_id > 0
    AND trim(reln_type_cdf) > "")
    SET t_encntr_id = encntr_id
    SET t_reln_type_cdf = reln_type_cdf
    SET t_mode = mode
    RETURN(substring(1,100,concat(trim(get_esoinfo_string("eprsnlprefix")),",",trim(field1),",",trim(
       field2),
      ",",trim(cnvtstring(fetch_encntr_prsnl_info(t_encntr_id,t_reln_type_cdf,t_mode))),",",trim(
       hl7_struct),",",
      trim(cnvtstring(repeat_ind)),",",trim(cnvtstring(encntr_id)),",",trim(reln_type_cdf))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_prsnl_id_enctr(field1,field2,encntr_id,reln_type_cdf,person_id,mode,hl7_struct,
  repeat_ind)
   IF (encntr_id > 0
    AND trim(reln_type_cdf) > ""
    AND person_id > 0)
    SET t_encntr_id = encntr_id
    SET t_reln_type_cdf = reln_type_cdf
    SET t_mode = mode
    SET t_person_id = person_id
    RETURN(substring(1,100,concat(trim(request->esoinfo.eprsnlprefix),",",trim(field1),",",trim(
       field2),
      ",",trim(cnvtstring(fetch_encntr_prsnl_id_info(t_encntr_id,t_reln_type_cdf,t_person_id,t_mode))
       ),",",trim(hl7_struct),",",
      trim(cnvtstring(repeat_ind)),",",trim(cnvtstring(encntr_id)),",",trim(reln_type_cdf))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_prsnl_id_enctr_ctx(field1,field2,encntr_id,reln_type_cdf,person_id,mode,
  hl7_struct,repeat_ind)
   IF (encntr_id > 0
    AND trim(reln_type_cdf) > ""
    AND person_id > 0)
    SET t_encntr_id = encntr_id
    SET t_reln_type_cdf = reln_type_cdf
    SET t_mode = mode
    SET t_person_id = person_id
    RETURN(substring(1,100,concat(trim(get_esoinfo_string("eprsnlprefix")),",",trim(field1),",",trim(
       field2),
      ",",trim(cnvtstring(fetch_encntr_prsnl_id_info(t_encntr_id,t_reln_type_cdf,t_person_id,t_mode))
       ),",",trim(hl7_struct),",",
      trim(cnvtstring(repeat_ind)),",",trim(cnvtstring(encntr_id)),",",trim(reln_type_cdf))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_prsnl_id(field_cdf,group_cdf,xx_name,xx_id,xx_cdf,x_person_id,ui_struct,
  instance)
  CALL echo("Calling eso_format_prsnl_id()")
  RETURN(eso_format_prsnl_id_enctr_ctx(field_cdf,"ALL_PRSNL",xx_id,trim(concat(trim(xx_cdf,3),"_",
     trim(instance,3)),3),x_person_id,
   0,ui_struct,1))
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET stat = 0
 RECORD localdata(
   1 date_time = dq8
 )
 SET localdata->date_time = cnvtdatetime(sysdate)
 CALL echo("script starts here")
 SET amendment_id = request->triginfo.amendment_id
 SET amd_idstr = cnvtstring(amendment_id)
 CALL echo(build("amendment_id is ",amendment_id))
 SET stat = alterlist(context->mfi_group,1)
 SET stat = alterlist(context->mfi_group[1].mfe_group,1)
 SET stat = alterlist(context->mfi_group[1].mfe_group[1].cm0_group,1)
 SET stat = alterlist(context->mfi_group[1].mfe_group[1].cm0_group.zcm,1)
 SET _person_id = 0.0
 SET prot_master_id = 0.0
 SET i = 0
 RECORD date(
   1 amendment_date = dq8
   1 performed_date[*]
     2 date = dq8
 )
 RECORD list(
   1 zcm[*]
     2 person_id = f8
   1 cm0[*]
     2 person_id = f8
   1 alias_pool[*]
     2 code_value = f8
   1 activity_cd[*]
     2 code = f8
 )
 SET prot_title = fillstring(255," ")
 SET targeted_accrual = 0
 SET anticipated_prot_duration = 0
 SET amendment_nbr = 0
 SET anticipated_prot_dur_uom_cd = 0.0
 SELECT INTO "nl:"
  FROM prot_amendment pa
  WHERE pa.prot_amendment_id=amendment_id
  DETAIL
   amendment_nbr = pa.amendment_nbr, prot_master_id = pa.prot_master_id, prot_title = pa.prot_title,
   targeted_accrual = pa.targeted_accrual, anticipated_prot_duration = pa.anticipated_prot_duration,
   anticipated_prot_dur_uom_cd = pa.anticipated_prot_dur_uom_cd,
   date->amendment_date = pa.amendment_dt_tm
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET context->mfi_group[1].mfe_group[1].cm0_group.cm0.study_title = prot_title
  SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].target_study_population = cnvtstring(
   targeted_accrual)
  SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].amendment_number = cnvtstring(amendment_nbr
   )
  SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].accrual_duration = cnvtstring(
   anticipated_prot_duration)
  SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].accrual_duration_unit.identifier =
  eso_format_code(anticipated_prot_dur_uom_cd)
 ENDIF
 CALL echo(build("targeted accrual = ",targeted_accrual))
 CALL echo(build("groupwide from context ",context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].
   target_study_population))
 CALL echo(build("study title is ",context->mfi_group[1].mfe_group[1].cm0_group.cm0.study_title))
 CALL echo("After Select on prot_amendment")
 SET primary_mnemonic = fillstring(255,"")
 SET prot_status_cd = 0.0
 SET prot_phase_cd = 0.0
 SET prot_type_cd = 0.0
 SET initiating_service_cd = 0.0
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE pm.prot_master_id=prot_master_id
  DETAIL
   primary_mnemonic = pm.primary_mnemonic, prot_status_cd = pm.prot_status_cd, prot_phase_cd = pm
   .prot_phase_cd,
   prot_type_cd = pm.prot_type_cd, initiating_service_cd = pm.initiating_service_cd
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET context->mfi_group[1].mfe_group[1].cm0_group.cm0.sponsor_study_id.entity_id = primary_mnemonic
  SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].study_status.identifier = eso_format_code(
   prot_status_cd)
  SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].study_phase.identifier = eso_format_code(
   prot_phase_cd)
  SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].initiating_service.identifier =
  eso_format_code(initiating_service_cd)
  SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].therapeutic_ind.identifier =
  eso_format_code(prot_type_cd)
 ENDIF
 CALL echo("After Select on prot_master ")
 SET counter = 0
 SELECT INTO "nl:"
  prot_alias_id
  FROM prot_alias pa
  WHERE pa.prot_master_id=prot_master_id
  DETAIL
   counter += 1, stat = alterlist(context->mfi_group[1].mfe_group[1].cm0_group.cm0.alternate_study_id,
    counter), stat = alterlist(list->alias_pool,counter),
   list->alias_pool[counter].code_value = pa.alias_pool_cd,
   CALL echo(build("list->alias in detail is ",list->alias_pool[counter].code_value))
  WITH nocounter
 ;end select
 CALL echo(build("the value of counter after detail is ",counter))
 IF (counter > 0)
  FOR (i = 1 TO counter)
    SET context->mfi_group[1].mfe_group[1].cm0_group.cm0.alternate_study_id[i].name_id =
    eso_format_code(list->alias_pool[i].code_value)
    CALL echo(build("value of i is ",i))
    CALL echo(build("list->alias is ",list->alias_pool[i].code_value))
  ENDFOR
  SET context->mfi_group[1].mfe_group[1].cm0_group.cm0.sponsor_study_id.entity_id = primary_mnemonic
  CALL echo("sponsor study id was set successfully")
 ENDIF
 CALL echo("After Select on prot_alias")
 SET _study_chairman = concat("AMD",amd_idstr)
 SET context->mfi_group[1].mfe_group[1].cm0_group.cm0.study_chairman.id_nbr = _study_chairman
 SET activatedby = 0.0
 SET closed = 0.0
 SET completed = 0.0
 SET approved = 0.0
 SET review = 0.0
 SET irb = 0.0
 SET committee_id = 0.0
 SET stat = uar_get_meaning_by_codeset(17876,"ACTIVATEDBY",1,activatedby)
 SET stat = uar_get_meaning_by_codeset(17876,"CLOSED",1,closed)
 SET stat = uar_get_meaning_by_codeset(17876,"COMPLETED",1,completed)
 SET stat = uar_get_meaning_by_codeset(17876,"APPROVED",1,approved)
 SET stat = uar_get_meaning_by_codeset(17876,"REVIEW",1,review)
 SET stat = uar_get_meaning_by_codeset(22209,"IRB",1,irb)
 CALL echo(build("the value of IRB is ",irb))
 SET committee_id = 0.0
 SELECT INTO "nl:"
  FROM committee com,
   ct_milestones cm
  PLAN (cm
   WHERE cm.prot_amendment_id=amendment_id)
   JOIN (com
   WHERE com.committee_id=cm.committee_id
    AND com.committee_type_cd=irb)
  HEAD com.committee_id
   committee_id = com.committee_id,
   CALL echo(build("The committee id is ",committee_id))
  WITH nocounter
 ;end select
 SET prt_master_id = 0.0
 SET amd_nbr = 0
 SELECT INTO "nl:"
  FROM prot_amendment pa
  WHERE pa.prot_amendment_id=amendment_id
  DETAIL
   prt_master_id = pa.prot_master_id, amd_nbr = pa.amendment_nbr,
   CALL echo(build("prot master id is ",prt_master_id)),
   CALL echo(build("amd number is ",amd_nbr))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cm.*
  FROM prot_amendment pa,
   ct_milestones cm
  PLAN (pa
   WHERE pa.prot_master_id=prt_master_id
    AND ((pa.amendment_nbr=amd_nbr) OR (pa.amendment_nbr=0)) )
   JOIN (cm
   WHERE cm.prot_amendment_id=pa.prot_amendment_id
    AND cm.performed_dt_tm != cnvtdatetime("31-dec-2100 00:00:00.00"))
  ORDER BY cm.activity_cd, pa.amendment_nbr DESC, cm.performed_dt_tm DESC
  HEAD cm.activity_cd
   stat = 0
  HEAD pa.amendment_nbr
   IF (pa.amendment_nbr=amd_nbr)
    IF (cm.activity_cd=closed)
     context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].study_deactivation_dt_tm =
     hl7_format_datetime(cm.performed_dt_tm,hl7_dt_tm),
     CALL echo("filled out study deactivation date")
    ELSEIF (cm.activity_cd=completed)
     context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].study_completed_dt_tm = hl7_format_datetime(
      cm.performed_dt_tm,hl7_dt_tm),
     CALL echo("filled out study completed date")
    ENDIF
   ENDIF
  DETAIL
   IF (pa.amendment_nbr=amd_nbr)
    IF (cm.activity_cd=approved
     AND cm.committee_id=committee_id)
     context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].irb_approval_dt_tm = hl7_format_datetime(cm
      .performed_dt_tm,hl7_dt_tm),
     CALL echo("filled out irb approval date")
    ELSEIF (cm.activity_cd=review
     AND cm.committee_id=committee_id)
     context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].irb_review_dt_tm = hl7_format_datetime(cm
      .performed_dt_tm,hl7_dt_tm),
     CALL echo("filled out irb review date")
    ENDIF
   ENDIF
  FOOT  pa.amendment_nbr
   IF (pa.amendment_nbr=0)
    IF (cm.activity_cd=activatedby)
     context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].study_activation_dt_tm = hl7_format_datetime
     (cm.performed_dt_tm,hl7_dt_tm),
     CALL echo("filled out study activation date")
    ELSEIF (cm.activity_cd=approved)
     context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].study_approved_dt_tm = hl7_format_datetime(
      cm.performed_dt_tm,hl7_dt_tm),
     CALL echo("filled out study approved date")
    ENDIF
   ENDIF
   IF (pa.amendment_nbr=amd_nbr)
    IF (cm.activity_cd=activatedby)
     context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].amd_activation_dt_tm = hl7_format_datetime(
      cm.performed_dt_tm,hl7_dt_tm),
     CALL echo("filled out amd activation date")
    ENDIF
   ENDIF
  FOOT  cm.activity_cd
   stat = 0
  WITH nocounter
 ;end select
 CALL echo("After Select on ct_milestones")
 SET counter = 0
 SET counter1 = 0
 SET primary = 0.0
 SET copi = 0.0
 SET coinvest = 0.0
 SET stat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,primary)
 SET stat = uar_get_meaning_by_codeset(17441,"COPI",1,copi)
 SET stat = uar_get_meaning_by_codeset(17441,"COINVEST",1,coinvest)
 SELECT INTO "nl:"
  prot_role_id
  FROM prot_role pr
  WHERE pr.prot_amendment_id=amendment_id
   AND pr.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
  DETAIL
   IF (pr.prot_role_cd IN (primary, copi))
    counter += 1, stat = alterlist(list->cm0,counter), list->cm0[counter].person_id = pr.person_id,
    stat = alterlist(context->mfi_group[1].mfe_group[1].cm0_group.cm0.study_contact,counter)
   ELSEIF (pr.prot_role_cd=coinvest)
    counter1 += 1, stat = alterlist(list->zcm,counter1), list->zcm[counter1].person_id = pr.person_id,
    stat = alterlist(context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].co_investigator,counter1)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("the value of counter after primary is ",counter))
 CALL echo(build("the value of curqual is ",curqual))
 SET i = 1
 IF (counter > 0)
  FOR (i = 1 TO counter)
   CALL echo(build("entered study contact number ",i))
   SET context->mfi_group[1].mfe_group[1].cm0_group.cm0.study_contact[i].id_nbr =
   eso_format_prsnl_id_enctr_ctx("STUDY_CONTACT","ALL_PRSNL",1,"STUDY_CONTACT",list->cm0[i].person_id,
    0,"XCN",1)
  ENDFOR
 ENDIF
 SET i = 1
 IF (counter1 > 0)
  FOR (i = 1 TO counter1)
    CALL echo(build("entered to fill co_investigator number",i))
    CALL echo(build("Person id is",list->zcm[i].person_id))
    SET context->mfi_group[1].mfe_group[1].cm0_group.zcm[1].co_investigator[i].id_nbr =
    eso_format_prsnl_id_enctr_ctx("CO_INVEST","ALL_PRSNL",1,"CO_INVEST",list->zcm[i].person_id,
     0,"XCN",1)
  ENDFOR
 ENDIF
 CALL echo("After Select on prot_role")
 SET reply->status_data.status = "S"
#exit_script
 CALL echo(concat("*** CT_ESO_MFN END CTRL_ID1 = ",concat("Q:",trim(cnvtstring(get_reqinfo_double(
       "queue_id")))," T:",trim(cnvtstring(get_reqinfo_double("trigger_id"))))))
END GO
