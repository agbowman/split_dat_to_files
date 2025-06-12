CREATE PROGRAM dm_ccb_code_value_wrapper:dba
 SET modify = predeclare
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
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
 DECLARE column_name_validator(filterlist_request=vc(ref)) = i2
 DECLARE table_name_validator(filterlist_request=vc(ref)) = i2
 DECLARE filterstring_builder(filterstring_build=vc,table_alias=vc,filterlist_request=vc(ref)) = vc
 DECLARE get_column_type(col_name=vc) = i2
 DECLARE get_key_ind(col_name=vc) = i2
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
 SUBROUTINE column_name_validator(filterlist_request)
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
 SUBROUTINE table_name_validator(filterlist_request)
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
 SUBROUTINE filterstring_builder(filterstring_build,table_alias,filterlist_request)
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
 SUBROUTINE get_column_type(col_name)
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
 SUBROUTINE get_key_ind(col_name)
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
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 cd_value_list[*]
      2 code_value = f8
      2 display = c40
      2 cdf_meaning = c12
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
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 IF (validate(request)=0)
  SET reply->message = "Request record does not exist."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->code_set < 1))
  SET reply->message = "Code set must be specified."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (size(request->filterlist,5) != 1)
  SET reply->message = "Must have exactly one search term."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (column_name_validator(request)=0)
  SET reply->message = "Invalid column name provided."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (table_name_validator(request)=0)
  SET reply->message = "Invalid table name provided."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (cnvtupper(request->filterlist[1].table_name)="CODE_VALUE")
  IF (cnvtupper(request->filterlist[1].column_name)="DISPLAY_KEY")
   IF (checkprg("DM_CCB_CVF_DISPLAYFILTER") > 0)
    EXECUTE dm_ccb_cvf_displayfilter
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_displayfilter does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSEIF (cnvtupper(request->filterlist[1].column_name)="DESCRIPTION")
   IF (checkprg("DM_CCB_CVF_DESCRIPTION_FILTER") > 0)
    EXECUTE dm_ccb_cvf_description_filter
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_description_filter does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSEIF (cnvtupper(request->filterlist[1].column_name)="CDF_MEANING")
   IF (checkprg("DM_CCB_CVF_CDF_MEANING_FILTER") > 0)
    EXECUTE dm_ccb_cvf_cdf_meaning_filter
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_cdf_meaning_filter does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSEIF (cnvtupper(request->filterlist[1].column_name)="CODE_VALUE")
   IF (checkprg("DM_CCB_CVF_CV_NUMBER") > 0)
    EXECUTE dm_ccb_cvf_cv_number
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_cv_number does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->message = "Invalid search column name."
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSEIF (cnvtupper(request->filterlist[1].table_name)="CODE_VALUE_ALIAS")
  IF (cnvtupper(request->filterlist[1].column_name)="ALIAS")
   IF (checkprg("DM_CCB_CVF_CVA_FILTER") > 0)
    EXECUTE dm_ccb_cvf_cva_filter
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_cva_filter does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSEIF (cnvtupper(request->filterlist[1].column_name)="CONTRIBUTOR_SOURCE_CD")
   IF (checkprg("DM_CCB_CVF_CVA_CNTRBTR_SRC") > 0)
    EXECUTE dm_ccb_cvf_cva_cntrbtr_src
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_cva_cntrbtr_src does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->message = "Invalid search column name."
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSEIF (cnvtupper(request->filterlist[1].table_name)="CODE_VALUE_OUTBOUND")
  IF (cnvtupper(request->filterlist[1].column_name)="ALIAS")
   IF (checkprg("DM_CCB_CVF_CVO_FILTER") > 0)
    EXECUTE dm_ccb_cvf_cvo_filter
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_cvo_filter does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSEIF (cnvtupper(request->filterlist[1].column_name)="CONTRIBUTOR_SOURCE_CD")
   IF (checkprg("DM_CCB_CVF_CVO_CNTRBTR_SRC") > 0)
    EXECUTE dm_ccb_cvf_cvo_cntrbtr_src
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_cvo_cntrbtr_src does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->message = "Invalid search column name."
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSEIF (cnvtupper(request->filterlist[1].table_name)="CODE_VALUE_EXTENSION")
  IF (cnvtupper(request->filterlist[1].column_name)="FIELD_VALUE")
   IF (checkprg("DM_CCB_CVF_CV_EXTENSION") > 0)
    EXECUTE dm_ccb_cvf_cv_extension
   ELSE
    SET reply->message = "Child script: dm_ccb_cvf_cv_extension does not exist."
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->message = "Invalid search column name."
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->message = "Unsupported table name."
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (error(errmsg,0) != 0)
  SET failed = "T"
  SET reply->message = errmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (((failed="T") OR ((reply->status_data.status="F"))) )
  SET reply->status_data.status = "F"
  CALL echo(build2("Error: ",reply->message))
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET modify = nopredeclare
END GO
