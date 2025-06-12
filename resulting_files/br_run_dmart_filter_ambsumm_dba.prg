CREATE PROGRAM br_run_dmart_filter_ambsumm:dba
 SET amb_clin_note_id = 0.0
 SET amb_clin_doc_id = 0.0
 SELECT INTO "nl:"
  FROM br_datamart_filter b
  WHERE b.filter_mean IN ("AMB_CLINIC_NOTE_ES", "AMB_CLIN_DOC_CONS_ES")
  DETAIL
   IF (b.filter_mean="AMB_CLINIC_NOTE_ES")
    amb_clin_note_id = b.br_datamart_filter_id
   ELSEIF (b.filter_mean="AMB_CLIN_DOC_CONS_ES")
    amb_clin_doc_id = b.br_datamart_filter_id
   ENDIF
  WITH nocounter
 ;end select
 IF (amb_clin_note_id > 0)
  DELETE  FROM br_datamart_filter b
   WHERE b.br_datamart_filter_id=amb_clin_note_id
   WITH nocounter
  ;end delete
  DELETE  FROM br_datamart_report_filter_r b
   WHERE b.br_datamart_filter_id=amb_clin_note_id
   WITH nocounter
  ;end delete
  DELETE  FROM br_long_text blt
   WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
    AND (blt.parent_entity_id=
   (SELECT
    b.br_datamart_text_id
    FROM br_datamart_text b
    WHERE b.br_datamart_filter_id=amb_clin_note_id))
   WITH nocounter
  ;end delete
  DELETE  FROM br_datamart_text b
   WHERE b.br_datamart_filter_id=amb_clin_note_id
   WITH nocounter
  ;end delete
 ENDIF
 IF (amb_clin_doc_id > 0)
  DELETE  FROM br_datamart_filter b
   WHERE b.br_datamart_filter_id=amb_clin_doc_id
   WITH nocounter
  ;end delete
  DELETE  FROM br_datamart_report_filter_r b
   WHERE b.br_datamart_filter_id=amb_clin_doc_id
   WITH nocounter
  ;end delete
  DELETE  FROM br_long_text blt
   WHERE blt.parent_entity_name="BR_DATAMART_TEXT"
    AND (blt.parent_entity_id=
   (SELECT
    b.br_datamart_text_id
    FROM br_datamart_text b
    WHERE b.br_datamart_filter_id=amb_clin_doc_id))
   WITH nocounter
  ;end delete
  DELETE  FROM br_datamart_text b
   WHERE b.br_datamart_filter_id=amb_clin_doc_id
   WITH nocounter
  ;end delete
 ENDIF
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_run_datamart_filter_amb> script"
 EXECUTE dm_dbimport "cer_install:datamart_filter_amb.csv", "br_datamart_filter_config", 5000
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
