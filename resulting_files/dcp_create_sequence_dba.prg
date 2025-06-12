CREATE PROGRAM dcp_create_sequence:dba
 SELECT INTO "NL:"
  FROM user_sequences
  WHERE sequence_name="ENTITY_RELTN_SEQ"
 ;end select
 IF (curqual=0)
  CALL parser("RDB CREATE SEQUENCE ENTITY_RELTN_SEQ go")
 ENDIF
 SELECT INTO "NL:"
  FROM user_sequences
  WHERE sequence_name="DCP_ERROR_SEQ"
 ;end select
 IF (curqual=0)
  CALL parser("RDB CREATE SEQUENCE DCP_ERROR_SEQ MAXVALUE 10000 CYCLE GO")
 ELSE
  DELETE  FROM dcp_error_log
   WHERE dcp_error_log_id > 0
  ;end delete
  COMMIT
  CALL parser("RDB DROP SEQUENCE DCP_ERROR_SEQ GO")
  CALL parser("RDB CREATE SEQUENCE DCP_ERROR_SEQ MAXVALUE 10000 CYCLE GO")
 ENDIF
 SELECT INTO "NL:"
  FROM user_sequences
  WHERE sequence_name="RAD_PACS_SEQ"
 ;end select
 IF (curqual=0)
  CALL parser("RDB CREATE SEQUENCE RAD_PACS_SEQ GO")
 ENDIF
 DELETE  FROM oe_field_meaning
  WHERE oe_field_meaning_id > 0
   AND oe_field_meaning_id < 9002
 ;end delete
 COMMIT
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
END GO
