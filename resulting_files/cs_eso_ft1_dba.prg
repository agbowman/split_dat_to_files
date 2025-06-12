CREATE PROGRAM cs_eso_ft1:dba
 CALL echo("<===== CS_ESO_FT1 BEGIN =====>")
 CALL echo("MOD:027")
#1000_initialize
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
 IF (validate(reply->status_data.status,"!")="!")
  RECORD reply(
    1 accession = vc
    1 admit_type_cd = f8
    1 alias_count = i4
    1 bill_code1 = vc
    1 bill_code2 = vc
    1 bill_code3 = vc
    1 bill_code1_desc = vc
    1 bill_code2_desc = vc
    1 bill_code3_desc = vc
    1 catalog_cd = f8
    1 cdm_sched_cd = f8
    1 charge_event_act_id = f8
    1 charge_event_id = f8
    1 cost_center_disp = vc
    1 code_modifier1_cd = f8
    1 code_modifier2_cd = f8
    1 code_modifier3_cd = f8
    1 cpt_sched_cd = f8
    1 department_disp = vc
    1 description = vc
    1 encntr_id = f8
    1 facility_cd = f8
    1 file_name = vc
    1 fin_nbr = vc
    1 fin_nbr_type_flg = i4
    1 manual_ind = i2
    1 mult_bill_code_sched_cd = f8
    1 order_id = f8
    1 ord_phys_id = f8
    1 order_mnemonic = vc
    1 override_desc = vc
    1 perf_phys_id = f8
    1 prim_cdm = vc
    1 prim_cpt = vc
    1 prim_icd9_proc = vc
    1 prim_cdm_desc = vc
    1 prim_cpt_desc = vc
    1 prim_icd9_proc_desc = vc
    1 perf_loc_cd = f8
    1 perf_loc_disp = vc
    1 rsrc_cd = f8
    1 rsrc_sys_disp = vc
    1 rsrc_alt_cd = f8
    1 rsrc_alt_sys_disp = vc
    1 abn_status_cd = f8
    1 ndc_ident = vc
    1 diag[*]
      2 identifier = vc
      2 text = vc
    1 pr1[*]
      2 code_meth = vc
      2 identifier = vc
      2 identifier_text = vc
      2 priority = i4
    1 order_alias[*]
      2 alias = vc
      2 alias_type_cd = f8
      2 alias_pool_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD auc_record
 RECORD auc_record(
   1 auc_score = vc
   1 auc_abnormal_flag = vc
   1 auc_abnormal_modifiers = vc
   1 abnormal_flag_ind = i2
   1 auc_producer_id = vc
   1 auc_producer_text = vc
   1 auc_analysis_dt_tm = dq8
   1 auc_comment_text[*]
     2 auc_comment = vc
   1 auc_exception_id = vc
   1 auc_exception_text = vc
   1 consult_flag = i2
   1 comment_flag = i2
   1 exception_flag = i2
   1 score_flag = i2
 )
 SET ft1_13_ind = 0
 SET pos = 0
 SET no_pr1_ind = 0
 SET sigdig_price_ind = 0
 DECLARE ft1_13_rsrc = f8 WITH public, noconstant(0.0)
 DECLARE ft1_13_alt_rsrc = f8 WITH public, noconstant(0.0)
 DECLARE no_ft1_25_fields = i4 WITH public, noconstant(0)
 DECLARE proc_cd_cnt = i4 WITH public, noconstant(0)
 DECLARE strsourceidentifier = vc WITH public, noconstant("")
 DECLARE dsourcevocabularycd = f8 WITH public, noconstant(0.0)
 DECLARE icddiaginfosize = i4 WITH public, noconstant(0)
 IF (validate(enable_auc,999)=999)
  DECLARE enable_auc = i2 WITH constant(routine_arg_exists("AUC")), persist
 ENDIF
 DECLARE radiology_cd = f8 WITH constant(eso_get_meaning_by_codeset(6000,"RADIOLOGY"))
 DECLARE cardiology_cd = f8 WITH constant(eso_get_meaning_by_codeset(6000,"CARDIOLOGY"))
 DECLARE catalog_type_cd = f8 WITH noconstant(0)
 DECLARE auc_loinc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4652007,
   "REQUESTEDPROCEDUREISAPPROPRIATE"))
 DECLARE auc_msh_profile_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4652006,
   "AUCINFORMATIONCOMPONENT"))
 DECLARE loinc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",400,"LOINC"))
 DECLARE processaucdetails(null) = null
 DECLARE populatemshdataforauc(null) = null
 SUBROUTINE (lookup_nomenclature(dnomenid=f8) =null)
   SET strsourceidentifier = ""
   SET dsourcevocabularycd = 0.0
   SELECT INTO "nl:"
    n.source_identifier, n.source_vocabulary_cd
    FROM nomenclature n
    WHERE n.nomenclature_id=dnomenid
    DETAIL
     strsourceidentifier = n.source_identifier, dsourcevocabularycd = n.source_vocabulary_cd
    WITH nocounter
   ;end select
   RETURN
 END ;Subroutine
 CALL echo(build("args = ",request->esoinfo.scriptcontrolargs))
 IF (routine_arg_exists("FT1_13"))
  SET ft1_13_ind = 1
 ENDIF
 CALL echo(build("FT1_13_IND=",ft1_13_ind))
 IF (routine_arg_exists("FT1-13_RSRC"))
  SET ft1_13_rsrc = 1
 ENDIF
 CALL echo(build("FT1_13_RSRC=",ft1_13_rsrc))
 IF (routine_arg_exists("FT1-13_ALT_RSRC"))
  SET ft1_13_alt_rsrc = 1
 ENDIF
 CALL echo(build("FT1_13_ALT_RSRC=",ft1_13_alt_rsrc))
 IF (routine_arg_exists("NO_FT1_25_FIELDS"))
  SET no_ft1_25_fields = 1
 ENDIF
 CALL echo(build("NO_FT1_25_FIELDS=",no_ft1_25_fields))
 IF (routine_arg_exists("NO_PR1"))
  SET no_pr1_ind = 1
 ENDIF
 CALL echo(build("NO_PR1_IND=",no_pr1_ind))
 IF (routine_arg_exists("SIGDIG_PRICE"))
  SET sigdig_price_ind = 1
 ENDIF
 CALL echo(build("SIGDIG_PRICE_IND=",sigdig_price_ind))
 SET stat = alterlist(context->person_group,1)
 SET stat = alterlist(context->person_group[1].fin_group,1)
 SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group,size(request->triginfo.
   charge_info,5))
 SET reply->status_data.status = "F"
#2000_main
 CALL echo(concat("charge_info size = ",cnvtstring(size(request->triginfo.charge_info,5))))
 SET ft1_x = 0
 FOR (ft1_x = 1 TO size(request->triginfo.charge_info,5))
   SELECT INTO "nl:"
    c.charge_event_act_id, c.charge_event_id, c.order_id
    FROM charge c
    WHERE (c.charge_item_id=request->triginfo.charge_info[ft1_x].charge_item_id)
    DETAIL
     reply->charge_event_act_id = c.charge_event_act_id, reply->charge_event_id = c.charge_event_id,
     reply->order_id = c.order_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ce.accession
    FROM charge_event ce
    WHERE (ce.charge_event_id=reply->charge_event_id)
    DETAIL
     reply->accession = ce.accession
    WITH nocounter
   ;end select
   SET reply->catalog_cd = 0
   SET reply->order_mnemonic = ""
   IF (reply->order_id)
    SELECT INTO "nl:"
     o.catalog_cd, o.order_mnemonic
     FROM orders o
     WHERE (o.order_id=reply->order_id)
     DETAIL
      reply->catalog_cd = o.catalog_cd, reply->order_mnemonic = o.order_mnemonic, catalog_type_cd = o
      .catalog_type_cd
     WITH nocounter
    ;end select
   ENDIF
   SET reply->cost_center_disp = fillstring(100," ")
   SET reply->department_disp = fillstring(100," ")
   SET reply->perf_loc_disp = fillstring(100," ")
   SELECT INTO "nl:"
    i_f.cdm_sched_cd, i_f.cpt_sched_cd, i_f.mult_bill_code_sched_cd,
    i_f.file_name, i_f.description
    FROM interface_file i_f
    WHERE (i_f.interface_file_id=request->triginfo.charge_info[ft1_x].interface_file_id)
     AND i_f.active_ind=1
    DETAIL
     reply->cdm_sched_cd = i_f.cdm_sched_cd, reply->cpt_sched_cd = i_f.cpt_sched_cd, reply->
     mult_bill_code_sched_cd = i_f.mult_bill_code_sched_cd,
     reply->file_name = i_f.file_name, reply->description = i_f.description
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ic.perf_phys_id, ic.ord_phys_id, ic.encntr_id,
    ic.facility_cd, ic.admit_type_cd, ic.manual_ind,
    ic.prim_cdm, ic.prim_cpt, ic.prim_icd9_proc,
    ic.prim_cdm_desc, ic.prim_cpt_desc, ic.prim_icd9_proc_desc,
    ic.override_desc, ic.bill_code1, ic.bill_code2,
    ic.bill_code3, ic.bill_code1_desc, ic.bill_code2_desc,
    ic.bill_code3_desc, ic.code_modifier1_cd, ic.code_modifier2_cd,
    ic.code_modifier3_cd, ic.fin_nbr, ic.fin_nbr_type_flg,
    ic.abn_status_cd, ic.ndc_ident, ic.perf_loc_cd
    FROM interface_charge ic
    WHERE (ic.interface_charge_id=request->triginfo.charge_info[ft1_x].interface_charge_id)
     AND ic.active_ind=1
    DETAIL
     reply->perf_phys_id = ic.perf_phys_id, reply->ord_phys_id = ic.ord_phys_id, reply->encntr_id =
     ic.encntr_id,
     reply->facility_cd = ic.facility_cd, reply->admit_type_cd = ic.admit_type_cd, reply->manual_ind
      = ic.manual_ind,
     reply->prim_cdm = ic.prim_cdm, reply->prim_cpt = ic.prim_cpt, reply->prim_icd9_proc = ic
     .prim_icd9_proc,
     reply->prim_cdm_desc = ic.prim_cdm_desc, reply->prim_cpt_desc = ic.prim_cpt_desc, reply->
     prim_icd9_proc_desc = ic.prim_icd9_proc_desc,
     reply->override_desc = ic.override_desc, reply->bill_code1 = ic.bill_code1, reply->bill_code2 =
     ic.bill_code2,
     reply->bill_code3 = ic.bill_code3, reply->bill_code1_desc = ic.bill_code1_desc, reply->
     bill_code2_desc = ic.bill_code2_desc,
     reply->bill_code3_desc = ic.bill_code3_desc, reply->code_modifier1_cd = ic.code_modifier1_cd,
     reply->code_modifier2_cd = ic.code_modifier2_cd,
     reply->code_modifier3_cd = ic.code_modifier3_cd, reply->fin_nbr = ic.fin_nbr, reply->
     fin_nbr_type_flg = ic.fin_nbr_type_flg,
     reply->abn_status_cd = ic.abn_status_cd, reply->ndc_ident = ic.ndc_ident, reply->perf_loc_cd =
     ic.perf_loc_cd
    WITH nocounter
   ;end select
   SET reply->cost_center_disp = trim(eso_get_code_display(request->triginfo.charge_info[ft1_x].
     cost_center_cd),3)
   SET reply->department_disp = trim(eso_get_code_display(request->triginfo.charge_info[ft1_x].
     department_cd),3)
   SET reply->perf_loc_disp = trim(eso_get_code_display(reply->perf_loc_cd),3)
   IF (ft1_x=1)
    SET stat = set_esoinfo_double("Interface file id",request->triginfo.charge_info[ft1_x].
     interface_file_id)
    SET stat = set_esoinfo_string("Interface file name",reply->file_name)
    SET stat = set_esoinfo_string("Interface file description",reply->description)
   ENDIF
   CASE (reply->fin_nbr_type_flg)
    OF 2:
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.id = trim(reply->fin_nbr)
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.check_digit = ""
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.check_digit_scheme = ""
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.assign_auth.name_id = ""
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.type_cd = "I"
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.assign_fac_id.name_id = ""
    OF 3:
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.id = trim(reply->fin_nbr)
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.check_digit = ""
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.check_digit_scheme = ""
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.assign_auth.name_id = ""
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.type_cd = "R"
     SET context->person_group[1].pat_group[1].pid[1].patient_account_nbr.assign_fac_id.name_id = ""
   ENDCASE
   CALL echo("ft1;1")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.set_id = cnvtstring(ft1_x)
   CALL echo("ft1;2")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_id = trim(cnvtstring(request
     ->triginfo.charge_info[ft1_x].interface_charge_id,20))
   CALL echo("ft1;3")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_batch_id = cnvtstring(request
    ->triginfo.charge_info[ft1_x].batch_num)
   CALL echo("ft1;4")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_dt = hl7_format_datetime(
    request->triginfo.charge_info[ft1_x].service_dt_tm,hl7_dt_tm)
   CALL echo("ft1;5")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_post_dt = hl7_format_datetime
   (request->triginfo.charge_info[ft1_x].beg_effective_dt_tm,hl7_dt_tm)
   CALL echo("ft1;6")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_type = eso_format_code(
    request->triginfo.charge_info[ft1_x].charge_type_cd)
   CALL echo("ft1;7")
   SET cdm_in_ft1 = 0
   SET cpt_in_ft1 = 0
   SET icd9_in_ft1 = 0
   IF (trim(reply->prim_cdm) > " ")
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.identifier = reply->
    prim_cdm
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.text = reply->
    prim_cdm_desc
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.coding_system = "L"
    SET cdm_in_ft1 = 1
   ELSEIF (trim(reply->prim_cpt) > " ")
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.identifier = reply->
    prim_cpt
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.text = reply->
    prim_cpt_desc
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.coding_system = "C4"
    SET cpt_in_ft1 = 1
   ELSEIF ((request->triginfo.charge_info[ft1_x].prim_icd9_proc_nomen_id > 0.0))
    CALL lookup_nomenclature(request->triginfo.charge_info[ft1_x].prim_icd9_proc_nomen_id)
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.identifier =
    strsourceidentifier
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.text = reply->
    prim_icd9_proc_desc
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.coding_system =
    eso_format_code_blank(dsourcevocabularycd)
    SET icd9_in_ft1 = 1
   ELSEIF (trim(reply->prim_icd9_proc) > " ")
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.identifier = reply->
    prim_icd9_proc
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.text = reply->
    prim_icd9_proc_desc
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.coding_system = ""
    SET icd9_in_ft1 = 1
   ENDIF
   IF ((reply->manual_ind=1))
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.alt_identifier = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.alt_text = reply->
    override_desc
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_code.alt_coding_system =
    "FT"
   ENDIF
   CALL echo("ft1;8")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_descrip = ""
   CALL echo("ft1;9")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_descrip_alt = ""
   CALL echo("ft1;10")
   IF ((request->triginfo.charge_info[ft1_x].quantity=0))
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_quantity = "1"
   ELSE
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_quantity = eso_trim_zeros(
     request->triginfo.charge_info[ft1_x].quantity)
   ENDIF
   CALL echo("ft1;11")
   IF (sigdig_price_ind)
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.price.quantity =
    eso_trim_zeros_pos(round(request->triginfo.charge_info[ft1_x].net_ext_price,6),2)
   ELSE
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.price.quantity =
    format(request->triginfo.charge_info[ft1_x].net_ext_price,"###########.##;L")
   ENDIF
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.price.denomination
    = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.price_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.from_value = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.to_value = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.range_units.
   identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.range_units.text
    = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.range_units.
   coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.range_units.
   alt_identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.range_units.
   alt_text = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.range_units.
   alt_coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_ext.range_type = ""
   CALL echo("ft1;12")
   IF (sigdig_price_ind)
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.price.quantity
     = eso_trim_zeros_pos(round(request->triginfo.charge_info[ft1_x].price,6),2)
   ELSE
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.price.quantity
     = format(request->triginfo.charge_info[ft1_x].price,"###########.##;L")
   ENDIF
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.price.
   denomination = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.price_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.from_value = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.to_value = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.range_units.
   identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.range_units.text
    = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.range_units.
   coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.range_units.
   alt_identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.range_units.
   alt_text = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.range_units.
   alt_coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.trans_amount_unit.range_type = ""
   CALL echo("ft1;13")
   IF ((request->triginfo.charge_info[ft1_x].level5_cd > 0))
    SET reply->rsrc_cd = request->triginfo.charge_info[ft1_x].level5_cd
    SET reply->rsrc_sys_disp = "HNAM_LVL5"
   ELSEIF ((request->triginfo.charge_info[ft1_x].subsection_cd > 0))
    SET reply->rsrc_cd = request->triginfo.charge_info[ft1_x].subsection_cd
    SET reply->rsrc_sys_disp = "HNAM_SUBSECT"
   ELSEIF ((request->triginfo.charge_info[ft1_x].section_cd > 0))
    SET reply->rsrc_cd = request->triginfo.charge_info[ft1_x].section_cd
    SET reply->rsrc_sys_disp = "HNAM_SECT"
   ELSEIF ((request->triginfo.charge_info[ft1_x].department_cd > 0))
    SET reply->rsrc_cd = request->triginfo.charge_info[ft1_x].department_cd
    SET reply->rsrc_sys_disp = "HNAM_DEPT"
   ELSEIF ((request->triginfo.charge_info[ft1_x].institution_cd > 0))
    SET reply->rsrc_cd = request->triginfo.charge_info[ft1_x].institution_cd
    SET reply->rsrc_sys_disp = "HNAM_INST"
   ELSE
    SET reply->rsrc_cd = 0.0
    SET reply->rsrc_sys_disp = ""
   ENDIF
   SET reply->rsrc_alt_cd = reply->rsrc_cd
   SET reply->rsrc_alt_sys_disp = reply->rsrc_sys_disp
   CALL echo(build("RSRC_CD = ",cnvtstring(reply->rsrc_cd)))
   CALL echo(build("RSRC_SYS_DISP = ",reply->rsrc_sys_disp))
   IF (ft1_13_rsrc)
    IF ((reply->rsrc_cd > 0))
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.identifier =
     eso_format_code(reply->rsrc_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.text = trim(
      eso_get_code_display(reply->rsrc_cd),3)
    ENDIF
   ELSE
    IF ((request->triginfo.charge_info[ft1_x].cost_center_cd > 0))
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.identifier =
     eso_format_code(request->triginfo.charge_info[ft1_x].cost_center_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.text = trim(reply->
      cost_center_disp,3)
     SET reply->rsrc_cd = request->triginfo.charge_info[ft1_x].cost_center_cd
     SET reply->rsrc_sys_disp = "HNAM_COST"
    ELSE
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.identifier =
     eso_format_code(request->triginfo.charge_info[ft1_x].department_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.text = trim(reply->
      department_disp,3)
     SET reply->rsrc_cd = request->triginfo.charge_info[ft1_x].department_cd
     SET reply->rsrc_sys_disp = "HNAM_DEPT"
    ENDIF
   ENDIF
   IF (ft1_13_ind=0)
    IF ((reply->rsrc_cd > 0))
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.coding_system = reply->
     rsrc_sys_disp
    ENDIF
    IF (ft1_13_alt_rsrc=0)
     IF ((reply->perf_loc_cd > 0))
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_identifier =
      eso_format_code(reply->perf_loc_cd)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_text = trim(reply
       ->perf_loc_disp,3)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_coding_system =
      "HNAM_PERFLOC"
     ELSEIF ((request->triginfo.charge_info[ft1_x].cost_center_cd=0))
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_identifier =
      eso_format_code(request->triginfo.charge_info[ft1_x].department_cd)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_text = trim(reply
       ->department_disp,3)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_coding_system =
      "HNAM_DEPT"
     ENDIF
    ENDIF
   ENDIF
   IF (ft1_13_alt_rsrc)
    IF ((reply->rsrc_alt_cd > 0))
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_identifier =
     eso_format_code(reply->rsrc_alt_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_text = trim(
      eso_get_code_display(reply->rsrc_alt_cd),3)
    ENDIF
    IF (ft1_13_ind=0)
     IF ((reply->rsrc_alt_cd > 0))
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.alt_coding_system =
      reply->rsrc_alt_sys_disp
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("13.1 = ",context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.
     identifier))
   CALL echo(build("13.2 = ",context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.
     text))
   CALL echo(build("13.3 = ",context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.
     coding_system))
   CALL echo(build("13.4 = ",context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.
     alt_identifier))
   CALL echo(build("13.5 = ",context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.
     alt_text))
   CALL echo(build("13.6 = ",context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.dept_code.
     alt_coding_system))
   CALL echo("ft1;14")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_plan_id.identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_plan_id.text = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_plan_id.coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_plan_id.alt_identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_plan_id.alt_text = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_plan_id.alt_coding_system = ""
   CALL echo("ft1;15")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.price.quantity = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.price.denomination = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.price_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.from_value = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.to_value = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.range_units.identifier
    = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.range_units.text = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.range_units.
   coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.range_units.
   alt_identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.range_units.alt_text =
   ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.range_units.
   alt_coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ins_amount.range_type = ""
   CALL echo("ft1;16")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.nurse_unit =
   eso_format_code(request->triginfo.charge_info[ft1_x].nurse_unit_cd)
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.room =
   eso_format_code(request->triginfo.charge_info[ft1_x].room_cd)
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.bed =
   eso_format_code(request->triginfo.charge_info[ft1_x].bed_cd)
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.facility_id.
   name_id = eso_format_code(reply->facility_cd)
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.facility_id.
   univ_id = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.facility_id.
   univ_id_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.bed_status = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.location_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.building =
   eso_format_code(request->triginfo.charge_info[ft1_x].building_cd)
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.floor = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.assigned_pat_loc.description = ""
   CALL echo("ft1;17")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.fee_schedule = reply->description
   CALL echo("ft1;18")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.pat_type = eso_format_code(reply->
    admit_type_cd)
   CALL echo("ft1;19")
   SET icddiaginfosize = size(request->triginfo.charge_info[ft1_x].icd_diag_info,5)
   IF (icddiaginfosize < 1)
    SET diag_count = 0
    IF (trim(request->triginfo.charge_info[ft1_x].diag_code1) > " ")
     SET diag_count += 1
     SET stat = alterlist(reply->diag,diag_count)
     SET reply->diag[diag_count].identifier = request->triginfo.charge_info[ft1_x].diag_code1
    ENDIF
    IF (trim(request->triginfo.charge_info[ft1_x].diag_code2) > " ")
     SET diag_count += 1
     SET stat = alterlist(reply->diag,diag_count)
     SET reply->diag[diag_count].identifier = request->triginfo.charge_info[ft1_x].diag_code2
    ENDIF
    IF (trim(request->triginfo.charge_info[ft1_x].diag_code3) > " ")
     SET diag_count += 1
     SET stat = alterlist(reply->diag,diag_count)
     SET reply->diag[diag_count].identifier = request->triginfo.charge_info[ft1_x].diag_code3
    ENDIF
    IF (diag_count > 0)
     SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code,
      diag_count)
     FOR (diag_idx = 1 TO diag_count)
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code[diag_idx].identifier
        = reply->diag[diag_idx].identifier
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code[diag_idx].text = ""
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code[diag_idx].
       coding_system = "I9"
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code[diag_idx].
       alt_identifier = ""
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code[diag_idx].alt_text =
       ""
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code[diag_idx].
       alt_coding_system = ""
     ENDFOR
    ENDIF
   ELSE
    SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code,
     icddiaginfosize)
    FOR (icd_diag_info_index = 1 TO icddiaginfosize)
      CALL lookup_nomenclature(request->triginfo.charge_info[ft1_x].icd_diag_info[icd_diag_info_index
       ].nomen_id)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code[icd_diag_info_index].
      identifier = strsourceidentifier
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.diag_code[icd_diag_info_index].
      coding_system = eso_format_code_blank(dsourcevocabularycd)
    ENDFOR
   ENDIF
   CALL echo("ft1;20")
   IF ((reply->perf_phys_id > 0))
    SET temp_str = fillstring(20," ")
    SET temp_str = trim(concat("FT1_20_",trim(cnvtstring(ft1_x))))
    SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.perform_by_code,1
     )
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.perform_by_code[1].id_nbr =
    eso_format_prsnl_id_enctr_ctx("FT1_PERFORM","ALL_PRSNL",reply->encntr_id,temp_str,reply->
     perf_phys_id,
     0,"XCN",1)
   ENDIF
   CALL echo("ft1;21")
   IF ((reply->ord_phys_id > 0))
    SET temp_str = fillstring(20," ")
    SET temp_str = trim(concat("FT1_21_",trim(cnvtstring(ft1_x))))
    SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ordered_by_code,1
     )
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ordered_by_code[1].id_nbr =
    eso_format_prsnl_id_enctr_ctx("FT1_PROVIDER","ALL_PRSNL",reply->encntr_id,temp_str,reply->
     ord_phys_id,
     0,"XCN",1)
   ENDIF
   CALL echo("ft1;22")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.price.quantity = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.price.denomination = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.price_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.from_value = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.to_value = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.range_units.identifier =
   ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.range_units.text = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.range_units.coding_system
    = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.range_units.
   alt_identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.range_units.alt_text = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.range_units.
   alt_coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.unit_cost.range_type = ""
   CALL echo("ft1;23")
   SET idx = 0
   IF (trim(reply->accession) > "")
    SET idx += 1
    SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr,idx)
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].entity_id = reply
    ->accession
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].name_id =
    "HNA_ACCN"
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].univ_id = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].univ_id_type = ""
   ENDIF
   IF ((reply->order_id > 0))
    SET idx += 1
    SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr,idx)
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].entity_id =
    cnvtstring(reply->order_id)
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].name_id =
    "HNAM_ORDERID"
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].univ_id = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].univ_id_type = ""
    SET count = 0
    SELECT INTO "nl:"
     oa.alias, oa.alias_pool_cd, oa.order_alias_type_cd
     FROM order_alias oa
     WHERE (oa.order_id=reply->order_id)
      AND oa.order_id > 0
      AND oa.active_ind=1
     DETAIL
      count += 1, stat = alterlist(reply->order_alias,count), reply->order_alias[count].alias = oa
      .alias,
      reply->order_alias[count].alias_type_cd = oa.order_alias_type_cd, reply->order_alias[count].
      alias_pool_cd = oa.alias_pool_cd
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET tmp_idx = 1
     FOR (tmp_idx = tmp_idx TO count)
       SET idx += 1
       SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr,idx
        )
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].entity_id =
       reply->order_alias[tmp_idx].alias
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].name_id =
       eso_format_code(reply->order_alias[tmp_idx].alias_pool_cd)
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].univ_id = ""
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.filler_nbr[idx].univ_id_type =
       ""
     ENDFOR
    ENDIF
   ENDIF
   CALL echo("ft1;24")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.id_nbr = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.last_name = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.first_name = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.middle_name = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.suffix = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.prefix = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.degree = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.source = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.assign_auth.name_id
    = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.assign_auth.univ_id
    = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.assign_auth.
   univ_id_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.name_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.check_digit = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.check_digit_scheme
    = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.id_type = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.assign_fac_id.
   name_id = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.assign_fac_id.
   univ_id = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.entered_by_code.assign_fac_id.
   univ_id_type = ""
   CALL echo("ft1;25")
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code.identifier = request->
   triginfo.charge_info[ft1_x].prim_cpt
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code.text = reply->
   order_mnemonic
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code.coding_system = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code.alt_identifier = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code.alt_text = ""
   SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code.alt_coding_system = ""
   IF (no_ft1_25_fields=0)
    CALL echo("ft1;26")
    SET proc_cd_cnt = 0
    IF ((reply->code_modifier1_cd > 0))
     SET proc_cd_cnt += 1
     SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.
      proc_code_modifier,proc_cd_cnt)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     identifier = eso_format_code(reply->code_modifier1_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     text = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     coding_system = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_identifier = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_text = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_coding_system = ""
    ENDIF
    IF ((reply->code_modifier2_cd > 0))
     SET proc_cd_cnt += 1
     SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.
      proc_code_modifier,proc_cd_cnt)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     identifier = eso_format_code(reply->code_modifier2_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     text = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     coding_system = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_identifier = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_text = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_coding_system = ""
    ENDIF
    IF ((reply->code_modifier3_cd > 0))
     SET proc_cd_cnt += 1
     SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.
      proc_code_modifier,proc_cd_cnt)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     identifier = eso_format_code(reply->code_modifier3_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     text = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     coding_system = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_identifier = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_text = ""
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.proc_code_modifier[proc_cd_cnt].
     alt_coding_system = ""
    ENDIF
    CALL echo("ft1;27")
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.abn_status_code.identifier =
    eso_format_code(reply->abn_status_cd)
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.abn_status_code.text = trim(
     eso_get_code_display(reply->abn_status_cd),3)
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.abn_status_code.coding_system = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.abn_status_code.alt_identifier =
    ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.abn_status_code.alt_text = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.abn_status_code.alt_coding_system
     = ""
    CALL echo("ft1;29")
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.identifier = reply->
    ndc_ident
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.text = reply->ndc_ident
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.coding_system = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.alt_identifier = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.alt_text = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.alt_coding_system = ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.coding_system_version =
    ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.alt_coding_system_ver =
    ""
    SET context->person_group[1].fin_group[1].ft1_group[ft1_x].ft1.ndc_ident.original_text = ""
   ENDIF
   IF (enable_auc)
    CALL echo("AUC")
    CALL processaucdetails(null)
    IF ((auc_record->auc_abnormal_modifiers IN ("MA", "MB", "MC", "MD", "MH",
    "QQ")))
     SELECT INTO "nl:"
      FROM code_value cv,
       code_value_extension cve
      PLAN (cv
       WHERE cv.code_set=17769
        AND cv.cdf_meaning="CPTMOD"
        AND (cv.display=auc_record->auc_abnormal_modifiers))
       JOIN (cve
       WHERE cve.code_value=cv.code_value
        AND cve.field_name="ACCEPTANCE_IND"
        AND cve.field_value="0")
      DETAIL
       auc_record->exception_flag = 1
      WITH nocounter
     ;end select
    ENDIF
    IF (auc_record->abnormal_flag_ind)
     CALL echo("setting MSH;21 for AUC")
     CALL populatemshdataforauc(null)
     CALL echo("obx;1")
     SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].obx,1)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx[1].set_id = trim(cnvtstring(ft1_x,
       20,0))
     CALL echo("obx;3")
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx[1].observation_id.identifier =
     eso_format_code(auc_loinc_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx[1].observation_id.text =
     uar_get_code_display(auc_loinc_cd)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx[1].observation_id.coding_system
      = eso_format_code(loinc_cd)
     CALL echo("obx;11")
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx[1].observation_res_status = "O"
     CALL echo("obx;29")
     SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].obx[1].
      observation_type,1)
     SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx[1].observation_type[1].
     observation_type = "SCI"
     IF (auc_record->exception_flag)
      CALL echo("obx;32")
      SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.
       observation_value_absent_reason,1)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.observation_value_absent_reason[
      1].identifier = auc_record->auc_abnormal_flag
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.observation_value_absent_reason[
      1].text = auc_record->auc_abnormal_modifiers
     ELSE
      CALL echo("obx;2")
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.value_type = "ST"
      SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.
       observation_value,1)
      CALL echo("obx;5")
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.observation_value[1].value_1 =
      auc_record->auc_score
      SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.abnormal_flag,1
       )
      CALL echo("obx;8")
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.abnormal_flag[1].abnormal_flag
       = auc_record->auc_abnormal_flag
      CALL echo("obx;15")
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.producers_id.identifier =
      auc_record->auc_producer_id
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.producers_id.text = auc_record->
      auc_producer_text
      CALL echo("obx;19")
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].obx.analysis_dt_tm = eso_format_dttm
      (auc_record->auc_analysis_dt_tm,hl7_dt_tm,"")
     ENDIF
     IF (auc_record->comment_flag)
      SET nte_idx = size(auc_record->auc_comment_text,5)
      SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].nte,nte_idx)
      FOR (n_idx = 1 TO nte_idx)
        CALL echo("nte;1")
        SET context->person_group[1].fin_group[1].ft1_group[ft1_x].nte[n_idx].set_id = trim(
         cnvtstring(n_idx,20,0))
        CALL echo("nte;2")
        SET context->person_group[1].fin_group[1].ft1_group[ft1_x].nte[n_idx].src_of_comment = "O"
        SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].nte[n_idx].
         comment,1)
        CALL echo("nte;3")
        SET context->person_group[1].fin_group[1].ft1_group[ft1_x].nte[n_idx].comment[1].comment =
        auc_record->auc_comment_text[n_idx].auc_comment
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   CALL echo("pr1")
   SET pr1_idx = 0
   SET pr1_count = 0
   IF (trim(reply->prim_cpt) > " "
    AND cpt_in_ft1=0)
    SET pr1_count += 1
    SET stat = alterlist(reply->pr1,pr1_count)
    SET reply->pr1[pr1_count].identifier = request->triginfo.charge_info[ft1_x].prim_cpt
    SET reply->pr1[pr1_count].identifier_text = reply->prim_cpt_desc
    SET reply->pr1[pr1_count].priority = 1
    IF ((reply->cpt_sched_cd > 0))
     SET reply->pr1[pr1_count].code_meth = eso_format_code(reply->cpt_sched_cd)
    ELSE
     SET reply->pr1[pr1_count].code_meth = "C4"
    ENDIF
   ENDIF
   IF (trim(reply->prim_icd9_proc) > " "
    AND icd9_in_ft1=0)
    SET pr1_count += 1
    SET stat = alterlist(reply->pr1,pr1_count)
    SET reply->pr1[pr1_count].identifier = reply->prim_icd9_proc
    SET reply->pr1[pr1_count].identifier_text = reply->prim_icd9_proc_desc
    SET reply->pr1[pr1_count].priority = 1
    IF ((request->triginfo.charge_info[ft1_x].prim_icd9_proc_nomen_id > 0.0))
     CALL lookup_nomenclature(request->triginfo.charge_info[ft1_x].prim_icd9_proc_nomen_id)
     SET reply->pr1[pr1_count].code_meth = eso_format_code_blank(dsourcevocabularycd)
    ELSE
     SET reply->pr1[pr1_count].code_meth = "I9"
    ENDIF
   ENDIF
   IF (trim(reply->bill_code1) > " ")
    SET pr1_count += 1
    SET stat = alterlist(reply->pr1,pr1_count)
    SET reply->pr1[pr1_count].identifier = request->triginfo.charge_info[ft1_x].bill_code1
    SET reply->pr1[pr1_count].identifier_text = request->triginfo.charge_info[ft1_x].bill_code1_desc
    SET reply->pr1[pr1_count].priority = 2
    IF ((request->triginfo.charge_info[ft1_x].bill_code1_nomen_id > 0.0))
     CALL lookup_nomenclature(request->triginfo.charge_info[ft1_x].bill_code1_nomen_id)
     SET reply->pr1[pr1_count].code_meth = eso_format_code_blank(dsourcevocabularycd)
    ELSE
     SET reply->pr1[pr1_count].code_meth = "I9"
    ENDIF
    IF ((reply->mult_bill_code_sched_cd > 0))
     SET reply->pr1[pr1_count].code_meth = eso_format_code(reply->mult_bill_code_sched_cd)
    ELSE
     SET reply->pr1[pr1_count].code_meth = "I9"
    ENDIF
   ENDIF
   IF (trim(reply->bill_code2) > " ")
    SET pr1_count += 1
    SET stat = alterlist(reply->pr1,pr1_count)
    SET reply->pr1[pr1_count].identifier = request->triginfo.charge_info[ft1_x].bill_code2
    SET reply->pr1[pr1_count].identifier_text = request->triginfo.charge_info[ft1_x].bill_code2_desc
    SET reply->pr1[pr1_count].priority = 3
    IF ((request->triginfo.charge_info[ft1_x].bill_code2_nomen_id > 0.0))
     CALL lookup_nomenclature(request->triginfo.charge_info[ft1_x].bill_code2_nomen_id)
     SET reply->pr1[pr1_count].code_meth = eso_format_code_blank(dsourcevocabularycd)
    ELSE
     SET reply->pr1[pr1_count].code_meth = "I9"
    ENDIF
    IF ((reply->mult_bill_code_sched_cd > 0))
     SET reply->pr1[pr1_count].code_meth = eso_format_code(reply->mult_bill_code_sched_cd)
    ELSE
     SET reply->pr1[pr1_count].code_meth = "I9"
    ENDIF
   ENDIF
   IF (trim(reply->bill_code3) > " ")
    SET pr1_count += 1
    SET stat = alterlist(reply->pr1,pr1_count)
    SET reply->pr1[pr1_count].identifier = request->triginfo.charge_info[ft1_x].bill_code3
    SET reply->pr1[pr1_count].identifier_text = request->triginfo.charge_info[ft1_x].bill_code3_desc
    SET reply->pr1[pr1_count].priority = 4
    IF ((request->triginfo.charge_info[ft1_x].bill_code3_nomen_id > 0.0))
     CALL lookup_nomenclature(request->triginfo.charge_info[ft1_x].bill_code3_nomen_id)
     SET reply->pr1[pr1_count].code_meth = eso_format_code_blank(dsourcevocabularycd)
    ELSE
     SET reply->pr1[pr1_count].code_meth = "I9"
    ENDIF
    IF ((reply->mult_bill_code_sched_cd > 0))
     SET reply->pr1[pr1_count].code_meth = eso_format_code(reply->mult_bill_code_sched_cd)
    ELSE
     SET reply->pr1[pr1_count].code_meth = "I9"
    ENDIF
   ENDIF
   IF ((reply->code_modifier1_cd > 0))
    SET pr1_count += 1
    SET stat = alterlist(reply->pr1,pr1_count)
    SET reply->pr1[pr1_count].identifier = eso_format_code(reply->code_modifier1_cd)
    SET reply->pr1[pr1_count].identifier_text = ""
    SET reply->pr1[pr1_count].priority = 5
    SET reply->pr1[pr1_count].code_meth = "C4"
   ENDIF
   IF ((reply->code_modifier2_cd > 0))
    SET pr1_count += 1
    SET stat = alterlist(reply->pr1,pr1_count)
    SET reply->pr1[pr1_count].identifier = eso_format_code(reply->code_modifier2_cd)
    SET reply->pr1[pr1_count].identifier_text = ""
    SET reply->pr1[pr1_count].priority = 5
    SET reply->pr1[pr1_count].code_meth = "C4"
   ENDIF
   IF ((reply->code_modifier3_cd > 0))
    SET pr1_count += 1
    SET stat = alterlist(reply->pr1,pr1_count)
    SET reply->pr1[pr1_count].identifier = eso_format_code(reply->code_modifier3_cd)
    SET reply->pr1[pr1_count].identifier_text = ""
    SET reply->pr1[pr1_count].priority = 5
    SET reply->pr1[pr1_count].code_meth = "C4"
   ENDIF
   IF (pr1_count > 0
    AND no_pr1_ind=0)
    SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group,pr1_count)
    FOR (pr1_idx = 1 TO pr1_count)
      CALL echo("pr1;1")
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.set_id =
      cnvtstring(pr1_idx)
      CALL echo("pr1;2")
      SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].
       pr1.coding_method,1)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.
      coding_method[1].coding_method = reply->pr1[pr1_idx].code_meth
      CALL echo("pr1;3")
      SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].
       pr1.proc_code,1)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_code[1].
      identifier = reply->pr1[pr1_idx].identifier
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_code[1].
      text = reply->pr1[pr1_idx].identifier_text
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_code[1].
      coding_system = ""
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_code[1].
      alt_identifier = ""
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_code[1].
      alt_text = ""
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_code[1].
      alt_coding_system = ""
      CALL echo("pr1;5")
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.date_time =
      hl7_format_datetime(request->triginfo.charge_info[ft1_x].service_dt_tm,hl7_dt_tm)
      CALL echo("pr1;6")
      IF ((reply->pr1[pr1_idx].priority=1))
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_type =
       "P"
      ELSE
       IF ((reply->pr1[pr1_idx].priority=5))
        SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_type
         = "M"
       ELSE
        SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.proc_type
         = "S"
       ENDIF
      ENDIF
      CALL echo("pr1;12.1")
      SET pr1_temp_str = fillstring(20," ")
      SET pr1_temp_str = trim(concat("PR1_12.1_",trim(cnvtstring(pr1_idx))))
      SET stat = alterlist(context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].
       pr1.practitioner,1)
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.practitioner[
      1].id_nbr = eso_format_prsnl_id_enctr_ctx("PR1_PROVIDER","ALL_PRSNL",reply->encntr_id,
       pr1_temp_str,reply->perf_phys_id,
       0,"XCN",1)
      CALL echo("pr1;13")
      SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.consent_cd =
      ""
      CALL echo("pr1;14")
      IF ((reply->pr1[pr1_idx].priority != 5))
       SET context->person_group[1].fin_group[1].ft1_group[ft1_x].pr1_group[pr1_idx].pr1.priority =
       cnvtstring(reply->pr1[pr1_idx].priority)
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#2000_end
#9999_end
 SUBROUTINE processaucdetails(null)
   IF (enable_auc > 0)
    IF (catalog_type_cd IN (radiology_cd, cardiology_cd))
     SELECT INTO "nl:"
      od.oe_field_display_value, od.oe_field_dt_tm_value, od.oe_field_id,
      od.oe_field_meaning, od.oe_field_meaning_id, od.oe_field_value,
      oef.field_type_flag
      FROM order_detail od,
       order_entry_fields oef
      PLAN (od
       WHERE (od.order_id=reply->order_id)
        AND od.order_id > 0)
       JOIN (oef
       WHERE od.oe_field_id=oef.oe_field_id)
      DETAIL
       CASE (od.oe_field_meaning)
        OF "QCDSMUTILIZED":
         auc_record->consult_flag = 1,auc_record->auc_producer_id = eso_format_code(od.oe_field_value
          ),auc_record->auc_producer_text = uar_get_code_display(od.oe_field_value)
        OF "AUCCONSULTCOMMENT":
         auc_record->comment_flag = 1,comment_idx = size(auc_record->auc_comment_text,5),comment_idx
          += 1,
         stat = alterlist(auc_record->auc_comment_text,comment_idx),auc_record->auc_comment_text[
         comment_idx].auc_comment = od.oe_field_display_value
        OF "AUCORDERADHERENCE":
         auc_record->abnormal_flag_ind = 1,auc_record->auc_abnormal_flag = eso_format_code(od
          .oe_field_value),auc_record->auc_abnormal_modifiers = uar_get_code_display(od
          .oe_field_value)
        OF "AUCSCORE":
         auc_record->score_flag = 1,auc_record->auc_score = od.oe_field_display_value
        OF "AUCCONSULTDTTM":
         auc_record->auc_analysis_dt_tm = od.oe_field_dt_tm_value
       ENDCASE
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populatemshdataforauc(null)
   SET stat = alterlist(context->control_group[1].msh[1].message_profile_id,1)
   CALL echo("msh;21.1")
   SET context->control_group[1].msh[1].message_profile_id[1].entity_id = eso_format_code(
    auc_msh_profile_cd)
   CALL echo("msh;21.3")
   SET context->control_group[1].msh[1].message_profile_id[1].univ_id =
   "1.3.6.1.4.1.19376.1.1.1.39.2"
   CALL echo("msh;21.3")
   SET context->control_group[1].msh[1].message_profile_id[1].univ_id_type = "ISO"
 END ;Subroutine
 SET reply->status_data.status = "S"
 CALL echo("<===== CS_ESO_FT1 END =====>")
END GO
