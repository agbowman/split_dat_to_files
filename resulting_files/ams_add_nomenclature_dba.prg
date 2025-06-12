CREATE PROGRAM ams_add_nomenclature:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = "",
  "File Name:" = ""
  WITH outdev, auditcommit, filename
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed_mess = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE term_axis = vc
 DECLARE scr_voc = vc
 DECLARE alias_term = vc
 DECLARE cont_sys = vc
 DECLARE prin_type = vc
 DECLARE ext_source = vc
 DECLARE string_stat = vc
 FOR (i = 1 TO value(size(file_content->qual,5)))
   FREE RECORD request_details
   RECORD request_details(
     1 nomenclature[1]
       2 dup_check_ind = i4
       2 upd_or_insert_ind = i4
       2 inactivate_identifiers = i2
       2 status = i2
       2 active_ind = i2
       2 action_ind = i2
       2 nomenclature_id = f8
       2 source_vocabulary_cd = f8
       2 principle_type_cd = f8
       2 source_identifier = vc
       2 concept_cki = vc
       2 status_msg = vc
       2 contributor_system_cd = f8
       2 language_cd = f8
       2 source_string = vc
       2 add_case_dup = i2
       2 dup_ind = i2
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 string_identifier = vc
       2 string_status_cd = f8
       2 term_id = f8
       2 mnemonic = c25
       2 string_source_cd = f8
       2 vocab_axis_cd = f8
       2 primary_cterm_ind = i4
       2 data_status_cd = f8
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 data_status_dt_tm = dq8
       2 data_status_prsnl_id = f8
       2 short_string = vc
   )
   SET request_details->nomenclature[1].nomenclature_id = 0.00
   IF (cnvtupper(file_content->qual[i].active_term)="YES")
    SET request_details->nomenclature[1].active_ind = 1
   ELSE
    SET request_details->nomenclature[1].active_ind = 0
   ENDIF
   SET request_details->nomenclature[1].beg_effective_dt_tm = curdate
   SET request_details->nomenclature[1].data_status_cd = 0.00
   SET request_details->nomenclature[1].end_effective_dt_tm = cnvtdatetime("12-Dec-2100 00:00:00")
   SET request_details->nomenclature[1].inactivate_identifiers = 0
   SET request_details->nomenclature[1].mnemonic = file_content->qual[i].mnemonic
   SET request_details->nomenclature[1].source_identifier = file_content->qual[i].short_identifier
   SET request_details->nomenclature[1].source_string = file_content->qual[i].term
   SET request_details->nomenclature[1].short_string = file_content->qual[i].short_string
   SET request_details->nomenclature[1].concept_cki = file_content->qual[i].concept_cki
   SET scr_voc = trim(file_content->qual[i].terminology)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=400
     AND cv.display=scr_voc
    DETAIL
     request_details->nomenclature[1].source_vocabulary_cd = cv.code_value
    WITH nocounter
   ;end select
   SET cont_sys = trim(file_content->qual[i].contributor_system)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=89
     AND cv.display=cont_sys
    DETAIL
     request_details->nomenclature[1].contributor_system_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=36
     AND cv.display=trim(file_content->qual[i].language)
    DETAIL
     request_details->nomenclature[1].language_cd = cv.code_value
    WITH nocounter
   ;end select
   SET prin_type = trim(file_content->qual[i].principle_type)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=401
     AND cv.display=prin_type
    DETAIL
     request_details->nomenclature[1].principle_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SET ext_source = trim(file_content->qual[i].external_source)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=12100
     AND cv.display=ext_source
    DETAIL
     request_details->nomenclature[1].string_source_cd = cv.code_value
    WITH nocounter
   ;end select
   SET string_stat = trim(file_content->qual[i].string_status)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=12103
     AND cv.display=string_stat
    DETAIL
     request_details->nomenclature[1].string_status_cd = cv.code_value
    WITH nocounter
   ;end select
   SET term_axis = trim(file_content->qual[i].terminology_axis)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=15849
     AND cv.display=term_axis
    DETAIL
     request_details->nomenclature[1].vocab_axis_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request_details->nomenclature[1].term_id = 0.00
   SET request_details->nomenclature[1].string_identifier = file_content->qual[i].string_identifier
   IF (cnvtupper(file_content->qual[i].primary_display_term)="YES")
    SET request_details->nomenclature[1].primary_cterm_ind = 1
   ELSE
    SET request_details->nomenclature[1].primary_cterm_ind = 0
   ENDIF
   SET request_details->nomenclature[1].status = 0
   SET request_details->nomenclature[1].status_msg = ""
   SET request_details->nomenclature[1].add_case_dup = 0
   SET request_details->nomenclature[1].dup_check_ind = 1
   SET request_details->nomenclature[1].dup_ind = 0
   SET request_details->nomenclature[1].upd_or_insert_ind = 1
   CALL echorecord(request_details)
   EXECUTE kia_ens_nomenclature  WITH replace("REQUEST",request_details)
 ENDFOR
#exit_script
 SET script_ver = " 000 05/01/15 SD0303079         Initial Release "
END GO
