CREATE PROGRAM dcp_import_powerforms:dba
 SET call_postversion = 0
 SELECT INTO "nl:"
  utc.table_name, utc.column_name
  FROM user_tab_columns utc
  WHERE utc.table_name="DCP_FORMS_REF"
   AND utc.column_name="DCP_FORM_INSTANCE_ID"
  DETAIL
   call_postversion = 1
  WITH nocounter
 ;end select
 IF (call_postversion=1)
  EXECUTE dcp_import_pwrfrms_postvers
 ELSE
  EXECUTE dcp_import_pwrfrms_novers
 ENDIF
END GO
