CREATE PROGRAM dm2_rdm_create_dm_txn_tracking:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm2_rdm_create_dm_txn_tracking..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE dtt_tablespace_name = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name="DM_TXN_TRACKING"
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select from USER_TABLES: ",errmsg)
  GO TO exit_script
 ELSEIF (curqual > 0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Table DM_TXN_TRACKING already exists.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name="DM_INFO"
  DETAIL
   dtt_tablespace_name = ut.tablespace_name
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select from USER_TABLES: ",errmsg)
  GO TO exit_script
 ENDIF
 CALL parser(concat("rdb CREATE TABLE dm_txn_tracking (","  owner_name varchar2(30),",
   "  table_name varchar2(30),","  txn_id_text varchar2(200),","  appl_context_nbr number,",
   "  row_scn number,","  del_ind number)","  ROWDEPENDENCIES","  TABLESPACE ",dtt_tablespace_name,
   " go"),1)
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to create table DM_TXN_TRACKING: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
