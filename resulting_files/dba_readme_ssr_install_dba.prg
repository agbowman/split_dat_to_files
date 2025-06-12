CREATE PROGRAM dba_readme_ssr_install:dba
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
 IF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success on DB2 sites"
  GO TO end_program
 ENDIF
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 SET sql_string = fillstring(200," ")
 SET sql_string = "rdb grant execute any procedure to v500 go"
 CALL parser(sql_string)
 FREE SET sql_string
 SELECT INTO "nl:"
  privilege
  FROM dba_sys_privs
  WHERE grantee="V500"
   AND privilege="EXECUTE ANY PROCEDURE"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = "grant execute any procedure to v500 failed!"
  GO TO exit_script
 ENDIF
 SET sql_string = fillstring(200," ")
 SET sql_string = "rdb grant select any table to v500 go"
 CALL parser(sql_string)
 FREE SET sql_string
 SELECT INTO "nl:"
  privilege
  FROM dba_sys_privs
  WHERE grantee="V500"
   AND privilege="SELECT ANY TABLE"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = "grant select any table to v500 failed!"
  GO TO exit_script
 ENDIF
 SET sql_string = fillstring(200," ")
 SET sql_string = "rdb grant analyze any to v500 go"
 CALL parser(sql_string)
 FREE SET sql_string
 SELECT INTO "nl:"
  privilege
  FROM dba_sys_privs
  WHERE grantee="V500"
   AND privilege="ANALYZE ANY"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = "grant analyze any to v500 failed!"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dba_sequences ds
  WHERE ds.sequence_name="REPORT_SEQUENCE"
  WITH nocounter
 ;end select
 IF (curqual)
  SET sql_string = fillstring(200," ")
  SET sql_string = concat("rdb drop sequence REPORT_SEQUENCE go")
  CALL parser(sql_string)
  FREE SET sql_string
  SELECT INTO "nl:"
   FROM dba_sequences ds
   WHERE ds.sequence_name="REPORT_SEQUENCE"
   WITH nocounter
  ;end select
  IF (curqual)
   SET dm_sql_reply->status = "F"
   SET dm_sql_reply->msg = "Drop Sequence: REPORT_SEQUENCE failed!"
   GO TO exit_script
  ENDIF
 ENDIF
 SET tg_db_link_name = fillstring(10,"")
 SET tg_syn_exist = 0
 SELECT INTO "nl:"
  FROM dba_synonyms das
  WHERE das.synonym_name IN ("DM_ENVIRONMENT", "REPORT_SEQUENCE")
   AND das.owner="PUBLIC"
  DETAIL
   IF (das.synonym_name="DM_ENVIRONMENT")
    tg_db_link_name = substring(1,(findstring(".",das.db_link) - 1),das.db_link)
   ENDIF
   IF (das.synonym_name="REPORT_SEQUENCE")
    tg_syn_exist = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual)
  IF (tg_syn_exist)
   SET sql_string = fillstring(200," ")
   SET sql_string = "rdb drop PUBLIC synonym REPORT_SEQUENCE go"
   CALL parser(sql_string)
   FREE SET sql_string
   SET tg_syn_exist = 0
  ENDIF
  SET sql_string = fillstring(200," ")
  SET sql_string = concat("rdb create PUBLIC synonym REPORT_SEQUENCE for REPORT_SEQUENCE@",
   tg_db_link_name," go")
  CALL parser(sql_string)
  FREE SET sql_string
  SELECT INTO "nl:"
   FROM dba_synonyms das
   WHERE das.synonym_name="REPORT_SEQUENCE"
    AND das.owner="PUBLIC"
    AND findstring(tg_db_link_name,das.db_link) > 0
   WITH nocounter
  ;end select
  IF ( NOT (curqual))
   SET dm_sql_reply->status = "F"
   SET dm_sql_reply->msg = "Create Public Synonym: REPORT_SEQUENCE failed!"
   GO TO exit_script
  ENDIF
 ENDIF
 EXECUTE dm_readme_include_sql "cer_install:pkg_dba_utility.sql"
 EXECUTE dm_readme_include_sql "cer_install:pkg_utility.sql"
 EXECUTE dm_readme_include_sql "cer_install:pkg_space.sql"
 EXECUTE dm_readme_include_sql "cer_install:pkg_reports_control.sql"
 EXECUTE dm_readme_include_sql_chk "cerner_dba_utility", "package"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "cerner_dba_utility", "package body"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dba_pkg_reports_control", "package"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dba_pkg_reports_control", "package body"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dba_utility", "package"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dba_utility", "package body"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dba_pkg_space_summary", "package"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dba_pkg_space_summary", "package body"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
 ELSE
  SET readme_data->message = "All objects exist in database."
 ENDIF
#end_program
 EXECUTE dm_readme_status
END GO
