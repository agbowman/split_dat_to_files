CREATE PROGRAM cv_utl_get_summary_data:dba
 PROMPT
  "Please enter cv_case_id for the case you want to view = " = " ",
  "View Detail Record Information(Y/N) [Y] = " = "Y"
 SET input_case_id = cnvtreal( $1)
 SET view_choice = cnvtupper( $2)
 SET failure = "F"
 SET cv_case = 0
 SET cv_case_abstr_data = 0
 SET cv_procedure = 0
 SET cv_proc_abstr_data = 0
 SET cv_lesion = 0
 SET cv_les_abstr_data = 0
 SET cv_case_dataset_r = 0
 SET cv_case_field = 0
 SET cv_case_file_row = 0
 SET long_text_data = 0
 SET long_text_error = 0
 SET cv_count_data = 0
 IF (view_choice="N")
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case
   WHERE cv_case_id=input_case_id
    AND cv_case_id > 0
   DETAIL
    cv_case = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_case_abstr_data ccad
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=ccad.cv_case_id
   DETAIL
    cv_case_abstr_data = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_procedure cp
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=cp.cv_case_id
   DETAIL
    cv_procedure = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_procedure cp,
    cv_proc_abstr_data cpad
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=cp.cv_case_id
    AND cp.procedure_id=cpad.procedure_id
   DETAIL
    cv_proc_abstr_data = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_procedure cp,
    cv_lesion cl
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=cp.cv_case_id
    AND cp.procedure_id=cl.procedure_id
   DETAIL
    cv_lesion = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_procedure cp,
    cv_lesion cl,
    cv_les_abstr_data clad
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=cp.cv_case_id
    AND cp.procedure_id=cl.procedure_id
    AND cl.lesion_id=clad.lesion_id
   DETAIL
    cv_les_abstr_data = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_case_dataset_r ccdr
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=ccdr.cv_case_id
   DETAIL
    cv_case_dataset_r = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_file_row ccfr
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id=ccdr.cv_case_id
    AND ccdr.case_dataset_r_id=ccfr.case_dataset_r_id
   DETAIL
    cv_case_file_row = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_field ccf
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id=ccdr.cv_case_id
    AND ccdr.case_dataset_r_id=ccf.case_dataset_r_id
   DETAIL
    cv_case_field = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_file_row ccfr,
    long_text lt
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id=ccdr.cv_case_id
    AND ccdr.case_dataset_r_id=ccfr.case_dataset_r_id
    AND lt.long_text_id=ccfr.long_text_id
   DETAIL
    long_text_data = table_count
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   table_count = count(*)
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_field ccf,
    long_text lt
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id=ccdr.cv_case_id
    AND ccdr.case_dataset_r_id=ccf.case_dataset_r_id
    AND lt.long_text_id=ccf.long_text_id
   DETAIL
    long_text_error = table_count
   WITH nocounter
  ;end select
  CALL echo("**********************************************************")
  CALL echo(build(cv_case," :records in cv_case with this case!"))
  CALL echo(build(cv_case_abstr_data," :records in CV_CASE_ABSTR_DATA with this case!"))
  CALL echo(build(cv_procedure," :records in CV_PROCEDURE with this case!"))
  CALL echo(build(cv_proc_abstr_data," :records in CV_PROC_ABSTR_DATA with this case!"))
  CALL echo(build(cv_lesion," :records in CV_LESION with this case!"))
  CALL echo(build(cv_les_abstr_data," :records in CV_LES_ABSTR_DATA with this case!"))
  CALL echo(build(cv_case_dataset_r," :records in CV_CASE_DATASET_R with this case!"))
  CALL echo(build(cv_case_file_row," :records in CV_CASE_FILE_ROW with this case!"))
  CALL echo(build(cv_case_field," :records in CV_CASE_FIELD with this case!"))
  CALL echo(build(long_text_data," :records in LONG_TEXT_DATA with this case!"))
  CALL echo(build(long_text_error," :records in LONG_TEXT_ERROR with this case!"))
  CALL echo("**********************************************************")
 ELSE
  SELECT
   *
   FROM cv_case cc
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
   WITH nocounter
  ;end select
  SELECT
   ccad.*
   FROM cv_case cc,
    cv_case_abstr_data ccad
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=ccad.cv_case_id
   WITH nocounter
  ;end select
  SELECT
   cp.*
   FROM cv_case cc,
    cv_procedure cp
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=cp.cv_case_id
   WITH nocounter
  ;end select
  SELECT
   cpad.*
   FROM cv_case cc,
    cv_procedure cp,
    cv_proc_abstr_data cpad
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=cp.cv_case_id
    AND cp.procedure_id=cpad.procedure_id
   WITH nocounter
  ;end select
  SELECT
   cl.*
   FROM cv_case cc,
    cv_procedure cp,
    cv_lesion cl
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=cp.cv_case_id
    AND cp.procedure_id=cl.procedure_id
   WITH nocounter
  ;end select
  SELECT
   clad.*
   FROM cv_case cc,
    cv_procedure cp,
    cv_lesion cl,
    cv_les_abstr_data clad
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=cp.cv_case_id
    AND cp.procedure_id=cl.procedure_id
    AND cl.lesion_id=clad.lesion_id
   WITH nocounter
  ;end select
  SELECT
   ccdr.*
   FROM cv_case cc,
    cv_case_dataset_r ccdr
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id > 0
    AND cc.cv_case_id=ccdr.cv_case_id
   WITH nocounter
  ;end select
  SELECT
   ccfr.*
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_file_row ccfr
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id=ccdr.cv_case_id
    AND ccdr.case_dataset_r_id=ccfr.case_dataset_r_id
   WITH nocounter
  ;end select
  SELECT
   ccf.*
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_field ccf
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id=ccdr.cv_case_id
    AND ccdr.case_dataset_r_id=ccf.case_dataset_r_id
   WITH nocounter
  ;end select
  SELECT
   lt.*
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_file_row ccfr,
    long_text lt
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id=ccdr.cv_case_id
    AND ccdr.case_dataset_r_id=ccfr.case_dataset_r_id
    AND lt.long_text_id=ccfr.long_text_id
    AND lt.parent_entity_name="CV_CASE_FILE_ROW"
   WITH nocounter
  ;end select
  SELECT
   lt.*
   FROM cv_case cc,
    cv_case_dataset_r ccdr,
    cv_case_field ccf,
    long_text lt
   WHERE cc.cv_case_id=input_case_id
    AND cc.cv_case_id=ccdr.cv_case_id
    AND ccdr.case_dataset_r_id=ccf.case_dataset_r_id
    AND lt.long_text_id=ccf.long_text_id
    AND lt.parent_entity_name="CV_CASE_FIELD"
   WITH nocounter
  ;end select
 ENDIF
END GO
