CREATE PROGRAM ce_cvp_update_script:dba
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
 FREE RECORD recordstatus
 RECORD recordstatus(
   1 rdm_current_status = c1
 )
 EXECUTE ce_cvp_update "CE_APPARATUS", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "APPARATUS_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "APPARATUS_SERIAL_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "APPARATUS_SIZE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "BODY_SITE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "INSERTION_PT_LOC_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "INSERTION_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "REMOVAL_PT_LOC_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_APPARATUS", "REMOVAL_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_ASSISTANT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_ASSISTANT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_ASSISTANT", "SEQUENCE_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_ASSISTANT", "ASSISTANT_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_ASSISTANT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_ASSISTANT", "ASSISTANT_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_BLOB", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB", "BLOB_SEQ_NUM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB", "BLOB_LENGTH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB", "COMPRESSION_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB", "BLOB_CONTENTS" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "MAX_SEQUENCE_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "CHECKSUM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "SUCCESSION_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "SUB_SERIES_REF_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "STORAGE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "FORMAT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "BLOB_HANDLE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "BLOB_ATTRIBUTES" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_RESULT", "VERSION_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "CE_BLOB_SUMMARY_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "BLOB_SUMMARY_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "BLOB_LENGTH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "FORMAT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "COMPRESSION_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOB_SUMMARY", "CHECKSUM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSE_START_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSE_NOTE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSE_END_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSE_ROUTE_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSE_SITE_CD" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSE_PT_LOC_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "INITIAL_VOLUME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TOTAL_INTAKE_VOLUME" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSION_RATE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSION_UNIT_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_BLOOD_TRANSFUSE", "TRANSFUSION_TIME_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_CHARGES", "CE_CHARGES_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "ENCNTR_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "PERSON_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "ORDER_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "CDM_NUMBER_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "QUANTITY" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "SERVICE_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "POSTED_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "UNIT_AMOUNT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "EXTENDED_AMOUNT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "ENCNTR_FINANCIAL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "DEPARTMENT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CHARGES", "UNIT_MEASURE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "SEQUENCE_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "NOMENCLATURE_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "ACR_CODE_STR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "GROUP_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "DESCRIPTOR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "RESULT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CODED_RESULT", "RESULT_SET" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_CONFIG", "SERVER_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONFIG", "STORAGE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONFIG", "FIELD_NAME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONFIG", "FIELD_TYPE_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONFIG", "FIELD_VALUE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_DATE_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_DATE_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_DATE_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_DATE_RESULT", "RESULT_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_DATE_RESULT", "RESULT_DT_TM_OS" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_DATE_RESULT", "DATE_TYPE_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_DATE_RESULT", "RESULT_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_EVENT_EXTENSION", "SEQUENCE_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_EXTENSION", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_EXTENSION", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_EXTENSION", "EXT_NAME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_EXTENSION", "EXT_VALUE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "MODIFIER_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "MODIFIER_VALUE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "MODIFIER_VAL_FT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "MODIFIER_VALUE_FT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "GROUP_SEQUENCE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_MODIFIER", "ITEM_SEQUENCE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "CE_EVENT_NOTE_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "EVENT_NOTE_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "NOTE_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "NOTE_FORMAT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "ENTRY_METHOD_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "NOTE_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "NOTE_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "RECORD_STATUS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "COMPRESSION_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "CHECKSUM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_NOTE", "NOTE_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "CE_EVENT_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "EVENT_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "PERSON_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "REQUEST_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "REQUEST_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "REQUEST_PRSNL_FT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "REQUEST_COMMENT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_PRSNL_FT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "PROXY_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "PROXY_PRSNL_FT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_STATUS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_COMMENT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "CHANGE_SINCE_ACTION_FLAG" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "LINKED_EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "REQUEST_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "DIGITAL_SIGNATURE_IDENT" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_PRSNL_GROUP_ID" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "REQUEST_PRSNL_GROUP_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_ORGANIZATION_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_PRSNL", "ACTION_ORGANIZATION_FT" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_EXAM_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EXAM_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EXAM_RESULT", "PRODUCT_UNIT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "ITEM_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "ITEM_SIZE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "HARVEST_SITE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "CULTURE_IND" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "TISSUE_GRAFT_TYPE_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "EXPLANT_REASON_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "EXPLANT_DISPOSITION_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "REFERENCE_ENTITY_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "REFERENCE_ENTITY_NAME" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "MANUFACTURER_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "MANUFACTURER_FT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "MODEL_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "LOT_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "OTHER_IDENTIFIER" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "EXPIRATION_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "ECRI_CODE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "BATCH_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IMPLANT_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_INTERP_COMP", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTERP_COMP", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTERP_COMP", "COMP_IDX" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTERP_COMP", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTERP_COMP", "COMP_EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTERP_COMP", "COMP_NAME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_CONTRIBUTOR_LINK", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONTRIBUTOR_LINK", "CONTRIBUTOR_EVENT_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONTRIBUTOR_LINK", "CE_VALID_FROM_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONTRIBUTOR_LINK", "TYPE_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONTRIBUTOR_LINK", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CONTRIBUTOR_LINK", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "ITEM_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "SERIAL_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "SERIAL_MNEMONIC" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "DESCRIPTION" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "ITEM_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "QUANTITY" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "BODY_SITE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "REFERENCE_ENTITY_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "REFERENCE_ENTITY_NAME" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INVENTORY_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_INV_TIME_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INV_TIME_RESULT", "ITEM_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INV_TIME_RESULT", "START_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INV_TIME_RESULT", "END_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INV_TIME_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INV_TIME_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_IO_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "IO_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "GROUP_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "VOLUME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "AUTHENTIC_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "RECORD_STATUS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "IO_COMMENT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "SYSTEM_NOTE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "CE_IO_RESULT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_RESULT", "PERSON_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "LINKED_EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "ORDER_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "ENCNTR_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "ACCESSION_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "CONTRIBUTOR_SYSTEM_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "REFERENCE_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "EVENT_CLASS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "SERIES_REF_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "SUB_SERIES_REF_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_LINKED_RESULT", "SUCCESSION_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_MED_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_START_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_NOTE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_PROV_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_END_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_ROUTE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_SITE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_METHOD_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_PT_LOC_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "INITIAL_DOSAGE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_DOSAGE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "DOSAGE_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "INITIAL_VOLUME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "TOTAL_INTAKE_VOLUME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "DILUENT_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "PH_DISPENSE_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "INFUSION_RATE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "INFUSION_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "INFUSION_TIME_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "MEDICATION_FORM_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "REASON_REQUIRED_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "RESPONSE_REQUIRED_FLAG" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_STRENGTH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_STRENGTH_UNIT_CD" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "SUBSTANCE_LOT_NUMBER" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "SUBSTANCE_EXP_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "SUBSTANCE_MANUFACTURER_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "REFUSAL_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "SYSTEM_ENTRY_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "SYNONYM_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "IMMUNIZATION_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_END_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "ADMIN_START_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "WEIGHT_VALUE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "WEIGHT_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MED_RESULT", "BOLUS_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "MICRO_SEQ_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "ORGANISM_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "ORGANISM_OCCURRENCE_NBR" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "ORGANISM_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "OBSERVATION_PRSNL_ID" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "BIOTYPE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "PROBABILITY" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY", "POSITIVE_IND" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY_R", "LINKED_EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY_R", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY_R", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY_R", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_MICROBIOLOGY_R", "MICRO_SEQ_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_PRODUCT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_STATUS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "ABO_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "RH_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_VOLUME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_VOLUME_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_QUANTITY" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_QUANTITY_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_STRENGTH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT", "PRODUCT_STRENGTH_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_PRODUCT_ANTIGEN", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT_ANTIGEN", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT_ANTIGEN", "PROD_ANT_SEQ_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT_ANTIGEN", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT_ANTIGEN", "ANTIGEN_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_PRODUCT_ANTIGEN", "ATTRIBUTE_IND" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_RECENT_RESULTS", "PERSON_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RECENT_RESULTS", "EVENT_SET_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RECENT_RESULTS", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RECENT_RESULTS", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RECENT_RESULTS", "EVENT_END_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RECENT_RESULTS", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "SPECIMEN_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "CONTAINER_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "CONTAINER_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "SPECIMEN_STATUS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "COLLECT_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "COLLECT_METHOD_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "COLLECT_LOC_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "COLLECT_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "COLLECT_VOLUME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "COLLECT_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "COLLECT_PRIORITY_CD" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "SOURCE_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "SOURCE_TEXT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "BODY_SITE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "DANGER_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "POSITIVE_IND" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_COLL", "COLLECT_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "SEQUENCE_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "TRANSFER_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "TRANSFER_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "TRANSFER_LOC_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "RECEIVE_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "RECEIVE_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SPECIMEN_TRANS", "RECEIVE_LOC_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "STRING_RESULT_TEXT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "STRING_RESULT_FORMAT_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "EQUATION_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "LAST_NORM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "UNIT_OF_MEASURE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "FEASIBLE_IND" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "INACCURATE_IND" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "MODIFY_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "NORMAL_LOW" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "NORMAL_HIGH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "CRITICAL_LOW" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "CRITICAL_HIGH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "CALCULATION_EQUATION" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_STRING_RESULT", "STRING_LONG_TEXT_ID" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_CALCULATION_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CALCULATION_RESULT", "EQUATION" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CALCULATION_RESULT", "CALCULATION_RESULT" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CALCULATION_RESULT", "CALCULATION_RESULT_FRMT_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CALCULATION_RESULT", "LAST_NORM_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CALCULATION_RESULT", "UNIT_OF_MEASURE_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CALCULATION_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_CALCULATION_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_RESULT_SET_LINK", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RESULT_SET_LINK", "RESULT_SET_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RESULT_SET_LINK", "ENTRY_TYPE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RESULT_SET_LINK", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_RESULT_SET_LINK", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_EVENT_ORDER_LINK", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ORDER_LINK", "ORDER_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ORDER_LINK", "ORDER_ACTION_SEQUENCE" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ORDER_LINK", "EVENT_END_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ORDER_LINK", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ORDER_LINK", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "MICRO_SEQ_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "SUSCEP_SEQ_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "SUSCEPTIBILITY_TEST_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "DETAIL_SUSCEPTIBILITY_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "PANEL_ANTIBIOTIC_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "ANTIBIOTIC_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "DILUENT_VOLUME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "RESULT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "RESULT_TEXT_VALUE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "RESULT_NUMERIC_VALUE" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "RESULT_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "RESULT_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "RESULT_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "SUSCEPTIBILITY_STATUS_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "ABNORMAL_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "CHARTABLE_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "NOMENCLATURE_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "ANTIBIOTIC_NOTE" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEPTIBILITY", "RESULT_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "CE_SUSCEP_FOOTNOTE_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "SUSCEP_FOOTNOTE_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "CHECKSUM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "COMPRESSION_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "FORMAT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "CONTRIBUTOR_SYSTEM_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "BLOB_LENGTH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE", "REFERENCE_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE_R", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE_R", "MICRO_SEQ_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE_R", "SUSCEP_SEQ_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE_R", "SUSCEP_FOOTNOTE_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE_R", "VALID_FROM_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_SUSCEP_FOOTNOTE_R", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_VERSION_PARMS", "ENTITY_NAME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_VERSION_PARMS", "FIELD_NAME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "NORMAL_HIGH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "CRITICAL_LOW" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "CRITICAL_HIGH" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EXPIRATION_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "CLINICAL_EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "ENCNTR_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "PERSON_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_START_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "ENCNTR_FINANCIAL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_TITLE_TEXT" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "VIEW_LEVEL" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "ORDER_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "CATALOG_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "SERIES_REF_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "ACCESSION_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "CONTRIBUTOR_SYSTEM_CD" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "REFERENCE_NBR" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "PARENT_EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_RELTN_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_CLASS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_TAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_END_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_END_DT_TM_OS" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "RESULT_VAL" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "RESULT_UNITS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "RESULT_TIME_UNITS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "TASK_ASSAY_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "RECORD_STATUS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "RESULT_STATUS_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "AUTHENTIC_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "PUBLISH_FLAG" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "QC_REVIEW_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "NORMALCY_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "NORMALCY_METHOD_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "INQUIRE_SECURITY_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "RESOURCE_GROUP_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "RESOURCE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "SUBTABLE_BIT_MAP" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "COLLATING_SEQ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "VERIFIED_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "VERIFIED_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "PERFORMED_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "PERFORMED_PRSNL_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "NORMAL_LOW" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "ORDER_ACTION_SEQUENCE" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "ENTRY_MODE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "SOURCE_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "CLINICAL_SEQ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_END_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "EVENT_START_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "PERFORMED_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "VERIFIED_TZ" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "TASK_ASSAY_VERSION_NBR" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CLINICAL_EVENT", "MODIFIER_LONG_TEXT_ID" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_EVENT_ACTION_MODIFIER", "CE_EVENT_ACTION_MODIFIER_ID" WITH replace(
  fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ACTION_MODIFIER", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ACTION_MODIFIER", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ACTION_MODIFIER", "EVENT_PRSNL_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ACTION_MODIFIER", "EVENT_ACTION_MODIFIER_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ACTION_MODIFIER", "VALID_FROM_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_EVENT_ACTION_MODIFIER", "ACTION_TYPE_MODIFIER_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "CE_IO_RESULT_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "IO_RESULT_ID" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "PERSON_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "ENCNTR_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "IO_START_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "IO_END_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "IO_TYPE_FLAG" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "IO_VOLUME" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "IO_STATUS_CD" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "REFERENCE_EVENT_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "REFERENCE_EVENT_CD" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_INTAKE_OUTPUT_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "CE_IO_TOTAL_RESULT_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "IO_TOTAL_DEFINITION_ID" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "EVENT_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "ENCNTR_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "ENCNTR_FOCUSED_IND" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "PERSON_ID" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "IO_TOTAL_START_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "IO_TOTAL_END_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "IO_TOTAL_RESULT_VAL" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "IO_TOTAL_UNIT_CD" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "LAST_IO_RESULT_CLINSIG_DT_TM" WITH replace(fillrecord,
  recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "VALID_FROM_DT_TM" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "CE_IO_TOTAL_RESULT", "VALID_UNTIL_DT_TM" WITH replace(fillrecord,recordstatus
  )
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
 EXECUTE ce_cvp_update "D", "O" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "PL", "SQL" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 EXECUTE ce_cvp_update "W", "P" WITH replace(fillrecord,recordstatus)
 IF ((recordstatus->rdm_current_status="F"))
  EXECUTE goto failure
 ENDIF
 COMMIT
#failure
 IF ((recordstatus->rdm_current_status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = "CE_VERSION_PARMS did not update successfully:"
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Successfully updated the CE_VERSION_PARMS table."
 ENDIF
 EXECUTE dm_readme_status
END GO
