CREATE PROGRAM core_get_outbnd_alias_by_fltrs:dba
 SET modify = predeclare
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 last_index = i4
    1 alias_list[*]
      2 alias = vc
      2 alias_type_meaning = c12
      2 code_value = f8
      2 code_value_disp = c40
      2 cdf_meaning = c12
      2 active_ind = i2
      2 contributor_source_cd = f8
      2 contributor_source_disp = c40
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 message = vc
  )
 ENDIF
 SUBROUTINE (daf_is_blank(dib_str=vc) =i2)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE (daf_is_not_blank(dinb_str=vc) =i2)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 FREE RECORD kia_trusted_cols
 RECORD kia_trusted_cols(
   1 trusted_cols_list[*]
     2 column_name = vc
     2 column_type = i2
     2 key_ind = i2
 )
 FREE RECORD trusted_tables
 RECORD trusted_tables(
   1 trusted_tables_list[*]
     2 table_name = vc
     2 table_alias = vc
 )
 DECLARE get_table_alias(table_name=vc) = vc
 DECLARE string_type = i2 WITH protect, constant(0)
 DECLARE numeric_type = i2 WITH protect, constant(1)
 DECLARE filterlist_size = i4 WITH protect, noconstant(0)
 DECLARE trusted_cols_list_size = i4 WITH protect, noconstant(0)
 DECLARE trusted_tables_list_size = i4 WITH protect, noconstant(0)
 SET stat = alterlist(kia_trusted_cols->trusted_cols_list,12)
 SET kia_trusted_cols->trusted_cols_list[1].column_name = "CODE_VALUE"
 SET kia_trusted_cols->trusted_cols_list[1].column_type = numeric_type
 SET kia_trusted_cols->trusted_cols_list[1].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[2].column_name = "CODE_SET"
 SET kia_trusted_cols->trusted_cols_list[2].column_type = numeric_type
 SET kia_trusted_cols->trusted_cols_list[2].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[3].column_name = "CDF_MEANING"
 SET kia_trusted_cols->trusted_cols_list[3].column_type = string_type
 SET kia_trusted_cols->trusted_cols_list[3].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[4].column_name = "DISPLAY"
 SET kia_trusted_cols->trusted_cols_list[4].column_type = string_type
 SET kia_trusted_cols->trusted_cols_list[4].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[5].column_name = "DISPLAY_KEY"
 SET kia_trusted_cols->trusted_cols_list[5].column_type = string_type
 SET kia_trusted_cols->trusted_cols_list[5].key_ind = 1
 SET kia_trusted_cols->trusted_cols_list[6].column_name = "DESCRIPTION"
 SET kia_trusted_cols->trusted_cols_list[6].column_type = string_type
 SET kia_trusted_cols->trusted_cols_list[6].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[7].column_name = "DEFINITION"
 SET kia_trusted_cols->trusted_cols_list[7].column_type = string_type
 SET kia_trusted_cols->trusted_cols_list[7].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[8].column_name = "ACTIVE_IND"
 SET kia_trusted_cols->trusted_cols_list[8].column_type = numeric_type
 SET kia_trusted_cols->trusted_cols_list[8].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[9].column_name = "DATA_STATUS_CD"
 SET kia_trusted_cols->trusted_cols_list[9].column_type = numeric_type
 SET kia_trusted_cols->trusted_cols_list[9].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[10].column_name = "ALIAS"
 SET kia_trusted_cols->trusted_cols_list[10].column_type = string_type
 SET kia_trusted_cols->trusted_cols_list[10].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[11].column_name = "FIELD_VALUE"
 SET kia_trusted_cols->trusted_cols_list[11].column_type = string_type
 SET kia_trusted_cols->trusted_cols_list[11].key_ind = 0
 SET kia_trusted_cols->trusted_cols_list[12].column_name = "CONTRIBUTOR_SOURCE_CD"
 SET kia_trusted_cols->trusted_cols_list[12].column_type = string_type
 SET kia_trusted_cols->trusted_cols_list[12].key_ind = 0
 SET trusted_cols_list_size = size(kia_trusted_cols->trusted_cols_list,5)
 SET stat = alterlist(trusted_tables->trusted_tables_list,5)
 SET trusted_tables->trusted_tables_list[1].table_name = "CODE_VALUE_SET"
 SET trusted_tables->trusted_tables_list[2].table_name = "CODE_VALUE"
 SET trusted_tables->trusted_tables_list[3].table_name = "CODE_VALUE_EXTENSION"
 SET trusted_tables->trusted_tables_list[4].table_name = "CODE_VALUE_ALIAS"
 SET trusted_tables->trusted_tables_list[5].table_name = "CODE_VALUE_OUTBOUND"
 SET trusted_tables_list_size = size(trusted_tables->trusted_tables_list,5)
 SUBROUTINE (column_name_validator(filterlist_request=vc(ref)) =i2)
   SET filterlist_size = size(filterlist_request->filterlist,5)
   DECLARE filterlist_iter = i4 WITH protect, noconstant(0)
   DECLARE column_validator_index = i4 WITH protect, noconstant(0)
   DECLARE current_col_valid = i2 WITH protect, noconstant(0)
   FOR (filterlist_iter = 1 TO filterlist_size)
     IF (locateval(column_validator_index,1,trusted_cols_list_size,cnvtupper(filterlist_request->
       filterlist[filterlist_iter].column_name),kia_trusted_cols->trusted_cols_list[
      column_validator_index].column_name)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (table_name_validator(filterlist_request=vc(ref)) =i2)
   SET filterlist_size = size(filterlist_request->filterlist,5)
   DECLARE filterlist_iter = i4 WITH protect, noconstant(0)
   DECLARE table_validator_index = i4 WITH protect, noconstant(0)
   DECLARE current_table_valid = i2 WITH protect, noconstant(0)
   FOR (filterlist_iter = 1 TO filterlist_size)
     IF (locateval(table_validator_index,1,trusted_tables_list_size,cnvtupper(filterlist_request->
       filterlist[filterlist_iter].table_name),trusted_tables->trusted_tables_list[
      table_validator_index].table_name)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (filterstring_builder(filterstring_build=vc,table_alias=vc,filterlist_request=vc(ref)) =
  vc)
   SET filterlist_size = size(filterlist_request->filterlist,5)
   DECLARE filterlist_iter = i4 WITH protect, noconstant(0)
   IF (filterlist_size >= 1)
    IF (daf_is_blank(filterstring_build))
     SET filterstring_build = " "
    ELSE
     SET filterstring_build = notrim(build2(filterstring_build," and "))
    ENDIF
    FOR (filterlist_iter = 1 TO filterlist_size)
     IF (get_column_type(filterlist_request->filterlist[filterlist_iter].column_name)=string_type)
      IF (get_key_ind(filterlist_request->filterlist[filterlist_iter].column_name)=1)
       SET filterstring_build = build2(filterstring_build,table_alias,".",filterlist_request->
        filterlist[filterlist_iter].column_name," = ",
        "'",trim(cnvtalphanum(cnvtupper(filterlist_request->filterlist[filterlist_iter].column_value)
          )),"*' ")
      ELSE
       SET filterstring_build = build2(filterstring_build,"cnvtupper(",table_alias,".",
        filterlist_request->filterlist[filterlist_iter].column_name,
        ")"," = ","'",cnvtupper(filterlist_request->filterlist[filterlist_iter].column_value),"*' ")
      ENDIF
     ELSE
      SET filterstring_build = build2(filterstring_build,table_alias,".",filterlist_request->
       filterlist[filterlist_iter].column_name," = ",
       filterlist_request->filterlist[filterlist_iter].column_value," ")
     ENDIF
     IF (filterlist_iter < filterlist_size)
      SET filterstring_build = notrim(build2(filterstring_build," and "))
     ENDIF
    ENDFOR
   ELSE
    SET filterstring_build = " 1 = 1 "
   ENDIF
   RETURN(filterstring_build)
 END ;Subroutine
 SUBROUTINE (get_column_type(col_name=vc) =i2)
   DECLARE filterlist_iter = i4 WITH protect, noconstant(0)
   DECLARE upper_col_name = vc WITH protect, noconstant(" ")
   DECLARE col_match_index = i2 WITH protect, noconstant(0)
   SET upper_col_name = cnvtupper(col_name)
   SET col_match_index = locateval(filterlist_iter,1,trusted_cols_list_size,upper_col_name,
    kia_trusted_cols->trusted_cols_list[filterlist_iter].column_name)
   IF (col_match_index != 0)
    RETURN(kia_trusted_cols->trusted_cols_list[col_match_index].column_type)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (get_key_ind(col_name=vc) =i2)
   DECLARE filterlist_iter = i4 WITH protect, noconstant(0)
   DECLARE upper_col_name = vc WITH protect, noconstant(" ")
   DECLARE col_match_index = i2 WITH protect, noconstant(0)
   SET upper_col_name = cnvtupper(col_name)
   SET col_match_index = locateval(filterlist_iter,1,trusted_cols_list_size,upper_col_name,
    kia_trusted_cols->trusted_cols_list[filterlist_iter].column_name)
   IF (col_match_index != 0)
    RETURN(kia_trusted_cols->trusted_cols_list[col_match_index].key_ind)
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE cont_src_disp = vc WITH public, noconstant(" ")
 DECLARE cd_value_disp = vc WITH public, noconstant(" ")
 DECLARE cd_value_mean = vc WITH public, noconstant(" ")
 DECLARE active_ind = i2 WITH public, noconstant(0)
 DECLARE cgoabf_filterstring = vc WITH public, noconstant(" ")
 DECLARE cgoabf_alias = vc WITH protect, noconstant("tbl_alias")
 DECLARE cgoabf_list_size = i4 WITH protect, constant(size(request->filterlist,5))
 DECLARE cgoabf_err_msg = vc WITH protect, noconstant(" ")
 DECLARE cgoabf_table_name = vc WITH protect, noconstant(" ")
 DECLARE cgoabf_column_name = vc WITH protect, noconstant(" ")
 DECLARE detail_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->code_set <= 0.0))
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (column_name_validator(request)=false)
  SET failed = "T"
  SET cgoabf_err_msg = "Invalid column name provided."
  GO TO exit_script
 ENDIF
 IF (table_name_validator(request)=false)
  SET failed = "T"
  SET cgoabf_err_msg = "Invalid table name provided."
  GO TO exit_script
 ENDIF
 IF (cgoabf_list_size > 0)
  IF (cgoabf_list_size > 1)
   SET failed = "T"
   GO TO exit_script
   SET cgoabf_err_msg = "Too many search terms."
  ENDIF
  SET cgoabf_table_name = cnvtupper(request->filterlist[1].table_name)
  SET cgoabf_column_name = cnvtupper(request->filterlist[1].column_name)
  SET cgoabf_filterstring = filterstring_builder(cgoabf_filterstring,cgoabf_alias,request)
  IF (cgoabf_table_name="CODE_VALUE")
   SET cgoabf_filterstring = replace(cgoabf_filterstring,cgoabf_alias,"cv")
  ELSEIF (cgoabf_table_name="CODE_VALUE_EXTENSION"
   AND cgoabf_column_name="FIELD_VALUE")
   SET cgoabf_filterstring = replace(cgoabf_filterstring,cgoabf_alias,"cve")
  ELSEIF (cgoabf_table_name="CODE_VALUE_ALIAS"
   AND cgoabf_column_name="ALIAS")
   SET cgoabf_filterstring = replace(cgoabf_filterstring,cgoabf_alias,"cva")
  ELSEIF (cgoabf_table_name="CODE_VALUE_ALIAS"
   AND cgoabf_column_name="CONTRIBUTOR_SOURCE_CD")
   SET cgoabf_filterstring = build2("cs73.DISPLAY_KEY = '",trim(cnvtalphanum(cnvtupper(request->
       filterlist[1].column_value))),"*'")
  ELSEIF (cgoabf_table_name="CODE_VALUE_OUTBOUND"
   AND cgoabf_column_name="ALIAS")
   SET cgoabf_filterstring = replace(cgoabf_filterstring,cgoabf_alias,"cvo")
  ELSEIF (cgoabf_table_name="CODE_VALUE_OUTBOUND"
   AND cgoabf_column_name="CONTRIBUTOR_SOURCE_CD")
   SET cgoabf_filterstring = build2("cs73.DISPLAY_KEY = '",trim(cnvtalphanum(cnvtupper(request->
       filterlist[1].column_value))),"*'")
  ELSE
   SET cgoabf_filterstring = "1 = 1"
  ENDIF
 ELSE
  SET cgoabf_filterstring = "1 = 1"
 ENDIF
 IF ((request->contributor_source_cd > 0.0))
  SET cont_src_disp = uar_get_code_display(request->contributor_source_cd)
  SELECT
   IF (cgoabf_table_name="CODE_VALUE")
    FROM code_value cv,
     code_value_outbound cvo
    PLAN (cv
     WHERE parser(cgoabf_filterstring)
      AND (cv.code_set=request->code_set))
     JOIN (cvo
     WHERE (cvo.code_value= Outerjoin(cv.code_value))
      AND (cvo.contributor_source_cd= Outerjoin(request->contributor_source_cd)) )
   ELSEIF (cgoabf_table_name="CODE_VALUE_OUTBOUND"
    AND cgoabf_column_name="ALIAS")
    FROM code_value cv,
     code_value_outbound cvo
    PLAN (cvo
     WHERE parser(cgoabf_filterstring)
      AND (cvo.contributor_source_cd= Outerjoin(request->contributor_source_cd)) )
     JOIN (cv
     WHERE (cv.code_set=request->code_set)
      AND (cvo.code_value= Outerjoin(cv.code_value)) )
   ELSEIF (cgoabf_table_name="CODE_VALUE_ALIAS"
    AND cgoabf_column_name="ALIAS")
    FROM code_value_outbound cvo,
     code_value cv,
     code_value_alias cva
    PLAN (cva
     WHERE parser(cgoabf_filterstring)
      AND (cva.code_set=request->code_set))
     JOIN (cv
     WHERE (cv.code_set=request->code_set)
      AND cv.code_value=cva.code_value)
     JOIN (cvo
     WHERE (cvo.code_value= Outerjoin(cv.code_value))
      AND (cvo.contributor_source_cd= Outerjoin(request->contributor_source_cd)) )
   ELSEIF (cgoabf_table_name="CODE_VALUE_OUTBOUND"
    AND cgoabf_column_name="CONTRIBUTOR_SOURCE_CD")
    FROM code_value cv,
     code_value_outbound cvo
    PLAN (cvo
     WHERE (cvo.contributor_source_cd= Outerjoin(request->contributor_source_cd))
      AND  EXISTS (
     (SELECT
      "x"
      FROM code_value cs73
      WHERE parser(cgoabf_filterstring)
       AND cs73.code_set=73
       AND cs73.code_value=cvo.contributor_source_cd)))
     JOIN (cv
     WHERE (cv.code_set=request->code_set)
      AND (cvo.code_value= Outerjoin(cv.code_value)) )
   ELSEIF (cgoabf_table_name="CODE_VALUE_ALIAS"
    AND cgoabf_column_name="CONTRIBUTOR_SOURCE_CD")
    FROM code_value_outbound cvo,
     code_value cv,
     code_value_alias cva
    PLAN (cva
     WHERE (cva.code_set=request->code_set)
      AND  EXISTS (
     (SELECT
      "x"
      FROM code_value cs73
      WHERE parser(cgoabf_filterstring)
       AND cs73.code_set=73
       AND cs73.code_value=cva.contributor_source_cd)))
     JOIN (cv
     WHERE (cv.code_set=request->code_set)
      AND cv.code_value=cva.code_value)
     JOIN (cvo
     WHERE (cvo.code_value= Outerjoin(cv.code_value))
      AND (cvo.contributor_source_cd= Outerjoin(request->contributor_source_cd)) )
   ELSEIF (cgoabf_table_name="CODE_VALUE_EXTENSION"
    AND cgoabf_column_name="FIELD_VALUE")
    FROM code_value_extension cve,
     code_value cv,
     code_value_outbound cvo
    PLAN (cve
     WHERE (cve.code_set=request->code_set)
      AND parser(cgoabf_filterstring))
     JOIN (cv
     WHERE (cv.code_set=request->code_set)
      AND cv.code_value=cve.code_value)
     JOIN (cvo
     WHERE (cvo.code_value= Outerjoin(cv.code_value))
      AND (cvo.contributor_source_cd= Outerjoin(request->contributor_source_cd)) )
   ELSE
    FROM code_value cv,
     code_value_outbound cvo
    PLAN (cv
     WHERE parser(cgoabf_filterstring)
      AND (cv.code_set=request->code_set))
     JOIN (cvo
     WHERE (cvo.code_value= Outerjoin(cv.code_value))
      AND (cvo.contributor_source_cd= Outerjoin(request->contributor_source_cd)) )
   ENDIF
   INTO "nl:"
   cvo_ind = nullind(cvo.alias), cvo.alias, cvo.alias_type_meaning,
   cvo.code_set, cvo.code_value, cvo.contributor_source_cd,
   cv.display, cv.display_key
   ORDER BY cv.code_value
   HEAD REPORT
    a_cnt = 0, stat = alterlist(reply->alias_list,request->block_size)
   DETAIL
    detail_cnt += 1
    IF ((a_cnt < request->block_size)
     AND (detail_cnt > request->start_index))
     a_cnt += 1
     IF (cvo.alias=" "
      AND cvo_ind=0)
      reply->alias_list[a_cnt].alias = "<sp>"
     ELSE
      reply->alias_list[a_cnt].alias = cvo.alias
     ENDIF
     reply->alias_list[a_cnt].alias_type_meaning = cvo.alias_type_meaning, reply->alias_list[a_cnt].
     code_value = cv.code_value, reply->alias_list[a_cnt].code_value_disp = cv.display,
     reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning, reply->alias_list[a_cnt].active_ind = cv
     .active_ind, reply->alias_list[a_cnt].contributor_source_cd = request->contributor_source_cd,
     reply->alias_list[a_cnt].contributor_source_disp = cont_src_disp
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->alias_list,a_cnt)
    IF ((a_cnt=request->block_size))
     reply->last_index = (request->start_index+ a_cnt)
    ELSE
     reply->last_index = 0
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET cd_value_disp = uar_get_code_display(request->code_value)
  SET cd_value_mean = uar_get_code_meaning(request->code_value)
  SELECT INTO "nl:"
   cv.active_ind
   FROM code_value cv
   WHERE (cv.code_value=request->code_value)
   DETAIL
    active_ind = cv.active_ind
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo_ind = nullind(cvo.alias), cvo.alias, cvo.alias_type_meaning,
   cvo.code_set, cvo.code_value, cvo.contributor_source_cd,
   cv.display, cv.display_key
   FROM code_value cv,
    code_value_outbound cvo
   PLAN (cv
    WHERE cv.code_set=73)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd= Outerjoin(cv.code_value))
     AND (cvo.code_set= Outerjoin(request->code_set))
     AND (cvo.code_value= Outerjoin(request->code_value)) )
   ORDER BY cv.code_value
   HEAD REPORT
    a_cnt = 0, stat = alterlist(reply->alias_list,request->block_size)
   DETAIL
    detail_cnt += 1
    IF ((a_cnt < request->block_size)
     AND (detail_cnt > request->start_index))
     a_cnt += 1
     IF (cvo.alias=" "
      AND cvo_ind=0)
      reply->alias_list[a_cnt].alias = "<sp>"
     ELSE
      reply->alias_list[a_cnt].alias = cvo.alias
     ENDIF
     reply->alias_list[a_cnt].alias_type_meaning = cvo.alias_type_meaning, reply->alias_list[a_cnt].
     code_value = request->code_value, reply->alias_list[a_cnt].code_value_disp = cd_value_disp,
     reply->alias_list[a_cnt].cdf_meaning = cd_value_mean, reply->alias_list[a_cnt].active_ind =
     active_ind, reply->alias_list[a_cnt].contributor_source_cd = cv.code_value,
     reply->alias_list[a_cnt].contributor_source_disp = cv.display
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->alias_list,a_cnt)
    IF ((a_cnt=request->block_size))
     reply->last_index = (request->start_index+ a_cnt)
    ELSE
     reply->last_index = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "001 10/16/03 JF8275"
END GO
