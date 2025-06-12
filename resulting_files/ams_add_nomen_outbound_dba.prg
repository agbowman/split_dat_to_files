CREATE PROGRAM ams_add_nomen_outbound:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "File Name" = "",
  "Select Audit/Commit" = ""
  WITH outdev, filename, auditcommit
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
 FOR (i = 1 TO value(size(file_content->qual,5)))
   FREE RECORD request_details
   RECORD request_details(
     1 nomenclature_id = f8
     1 source_vocabulary_cd = f8
     1 principle_type_cd = f8
     1 source_string = vc
     1 contributor_system_cd = f8
     1 language_cd = f8
     1 vocab_axis_cd = f8
     1 alias_terminology = f8
     1 alias = vc
     1 alias_type_meaning = vc
     1 action_ind = i2
   )
   SET request_details->action_ind = 1
   SET alias_term = trim(file_content->qual[i].alias_terminology)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=400
     AND cv.display=alias_term
    DETAIL
     request_details->alias_terminology = cv.code_value
    WITH nocounter
   ;end select
   SET request_details->alias = file_content->qual[i].alias
   SET request_details->alias_type_meaning = file_content->qual[i].alias_type_meaning
   SET request_details->source_string = file_content->qual[i].term
   SET scr_voc = trim(file_content->qual[i].terminology)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=400
     AND cv.display=scr_voc
    DETAIL
     request_details->source_vocabulary_cd = cv.code_value
    WITH nocounter
   ;end select
   SET cont_sys = trim(file_content->qual[i].contributor_system)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=89
     AND cv.display=cont_sys
    DETAIL
     request_details->contributor_system_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=36
     AND cv.display=trim(file_content->qual[i].language)
    DETAIL
     request_details->language_cd = cv.code_value
    WITH nocounter
   ;end select
   SET prin_type = trim(file_content->qual[i].principle_type)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=401
     AND cv.display=prin_type
    DETAIL
     request_details->principle_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SET term_axis = trim(file_content->qual[i].terminology_axis)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=15849
     AND cv.display=term_axis
    DETAIL
     request_details->vocab_axis_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE (n.source_string=request_details->source_string)
     AND (n.source_vocabulary_cd=request_details->source_vocabulary_cd)
     AND (n.principle_type_cd=request_details->principle_type_cd)
     AND (n.contributor_system_cd=request_details->contributor_system_cd)
     AND (n.vocab_axis_cd=request_details->vocab_axis_cd)
     AND n.active_ind=1
    DETAIL
     request_details->nomenclature_id = n.nomenclature_id
    WITH maxrec = 1, nocounter
   ;end select
   CALL echorecord(request_details)
   SET request_details->source_vocabulary_cd = request_details->alias_terminology
   EXECUTE kia_add_nomen_outbound  WITH replace("REQUEST",request_details)
 ENDFOR
#exit_script
 SET script_ver = " 000 05/01/15 SD0303079         Initial Release "
END GO
