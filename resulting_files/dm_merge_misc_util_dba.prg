CREATE PROGRAM dm_merge_misc_util:dba
 SET width = 132
 SET c_mod = "DM_MERGE_MISC_UTIL 004"
 SET link_exist_flag = 0
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
  GO TO end_of_program
 ENDIF
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 CALL echo("Executing DM_TEMP_TABLES...")
 EXECUTE dm_temp_tables
 CALL echo("Finished executing DM_TEMP_TABLES.")
 SET debug_ind = 0
 IF ( NOT (validate(i_debug_ind,0)=0
  AND validate(i_debug_ind,1)=1))
  SET debug_ind = i_debug_ind
 ENDIF
 SET del_row_stat = 0
 SET del_row_r_stat = 0
 SET del_row_group_stat = 0
 SET del_row_cons_stat = 0
 SET add_seq_stat = 0
 DECLARE return_status_flag = i4
 SET return_status_flag = 0
 FREE RECORD rec_str
 RECORD rec_str(
   1 str = vc
 )
 SET add_seq_stat = sub_add_seq("DM_MERGE_SEQ")
 IF (add_seq_stat=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed!  Sequence was not added for table DM_MERGE_SEQ."
  GO TO end_of_program
 ENDIF
 SET del_row_cons_stat = sub_delete_rows("DM_SOFT_CONSTRAINTS")
 IF (del_row_cons_stat=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed!  Table DM_SOFT_CONSTRAINTS was not deleted."
  GO TO end_of_program
 ENDIF
 SELECT INTO "nl:"
  *
  FROM dba_db_links
  WHERE owner="PUBLIC"
   AND db_link="LOC_MRG_LINK*"
  DETAIL
   link_exist_flag = 1
  WITH nocounter
 ;end select
 IF (link_exist_flag=1)
  CALL echo("rdb drop public database link LOC_MRG_LINK go")
  CALL parser("rdb drop public database link LOC_MRG_LINK go",1)
  SET link_exist_flag = 0
  SELECT INTO "nl:"
   *
   FROM dba_db_links
   WHERE owner="PUBLIC"
    AND db_link="LOC_MRG_LINK*"
   DETAIL
    link_exist_flag = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (link_exist_flag=0)
  SET dmmu_db_name = fillstring(15," ")
  SELECT INTO "nl:"
   v.name
   FROM v$database v
   DETAIL
    dmmu_db_name = v.name
   WITH nocounter
  ;end select
  SET dmmu_pos1 = 0
  SET dmmu_pos2 = 0
  SET dmmu_user_name = fillstring(60,"")
  SET dmmu_pwd = fillstring(60,"")
  SET dmmu_env_id = 0
  SELECT INTO "nl:"
   d.info_number
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="DM_ENV_ID"
   DETAIL
    dmmu_env_id = d.info_number
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d.v500_connect_string
   FROM dm_environment d
   WHERE environment_id=dmmu_env_id
   DETAIL
    dmmu_pos1 = findstring("/",d.v500_connect_string), dmmu_user_name = cnvtlower(trim(substring(1,(
       dmmu_pos1 - 1),d.v500_connect_string))), dmmu_pos2 = findstring("@",d.v500_connect_string),
    dmmu_pwd = cnvtlower(trim(substring((dmmu_pos1+ 1),((dmmu_pos2 - dmmu_pos1) - 1),d
       .v500_connect_string)))
   WITH nocounter
  ;end select
  SET rec_str->str = concat("rdb create public database link LOC_MRG_LINK connect to ",trim(
    dmmu_user_name)," identified by ",trim(dmmu_pwd)," using '",
   trim(dmmu_db_name),"1' go")
  CALL echo(rec_str->str)
  CALL parser(rec_str->str,1)
  SELECT INTO "nl:"
   *
   FROM dba_db_links
   WHERE owner="PUBLIC"
    AND db_link="LOC_MRG_LINK*"
   WITH nocounter
  ;end select
  IF ( NOT (curqual))
   SET readme_data->status = "F"
   SET readme_data->message = "README FAILED.  Link 'LOC_MRG_LINK' can not be created."
   GO TO end_of_program
  ENDIF
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message =
  "README FAILED.  Could not drop 'LOC_MRG_LINK' link.  Please drop it manually."
  GO TO end_of_program
 ENDIF
 IF ( NOT (debug_ind))
  EXECUTE dm_readme_include_sql "cer_install:dm_merge_package.sql"
  EXECUTE dm_readme_include_sql_chk "dm_merge_package", "package"
  IF ((dm_sql_reply->status="F"))
   SET readme_data->status = "F"
   SET readme_data->message = "README FAILED.  DM_MERGE_PACKAGE.SQL FAILED."
   GO TO end_of_program
  ENDIF
 ENDIF
 IF (add_seq_stat=1
  AND del_row_cons_stat=1
  AND (dm_sql_reply->status="S"))
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Sucess!"
  GO TO end_of_program
 ENDIF
 SUBROUTINE sub_delete_rows(p_table_name1)
   SET return_status_flag = 0
   SET p_table_name = cnvtupper(p_table_name1)
   SET rec_str->str = concat("delete from ",p_table_name," where 1 = 1 go")
   CALL echo(concat("Parser: ",rec_str->str),1,0)
   IF ( NOT (debug_ind))
    CALL parser(rec_str->str)
    CALL parser("commit go")
   ENDIF
   SELECT INTO "nl:"
    p.*
    FROM (value(p_table_name) p)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET return_status_flag = 1
   ENDIF
   RETURN(return_status_flag)
 END ;Subroutine
 SUBROUTINE sub_drop_table(p_table_name2)
   SET p_table_name = p_table_name2
   SET p_table_name = cnvtupper(p_table_name)
   SET return_status_flag = 1
   SET rec_str->str = concat("RDB ASIS('drop table ",trim(p_table_name)," go')")
   CALL echo(concat("Parser: ",rec_str->str),1,0)
   IF ( NOT (debug_ind))
    CALL parser(rec_str->str)
   ENDIF
   RETURN(return_status_flag)
 END ;Subroutine
 SUBROUTINE sub_add_seq(p_seq_name)
   SET return_status_flag = 0
   DECLARE seq_ind = i2
   SET seq_ind = 0
   SELECT INTO "nl:"
    a.sequence_name
    FROM all_sequences a
    WHERE a.sequence_name=trim(p_seq_name)
    DETAIL
     seq_ind = 1
    WITH nocounter
   ;end select
   SET rec_str->str = concat("RDB ASIS('create sequence ",trim(p_seq_name)," go')")
   IF (seq_ind=0)
    IF ( NOT (debug_ind))
     CALL echo(concat("Parser: ",rec_str->str),1,0)
     CALL parser(rec_str->str)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    a.sequence_name
    FROM all_sequences a
    WHERE a.sequence_name=trim(p_seq_name)
    DETAIL
     return_status_flag = 1
    WITH nocounter
   ;end select
   RETURN(return_status_flag)
 END ;Subroutine
#end_of_program
 EXECUTE dm_readme_status
END GO
