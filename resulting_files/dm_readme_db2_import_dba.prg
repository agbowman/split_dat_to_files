CREATE PROGRAM dm_readme_db2_import:dba
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
 DECLARE find_connect_string(null) = i4
 RECORD db_connect(
   1 connect_string = vc
   1 username = vc
   1 password = vc
   1 db_name = vc
 )
 SUBROUTINE find_connect_string(null)
   SELECT INTO "nl:"
    e.v500_connect_string
    FROM dm_info i,
     dm_environment e
    PLAN (i
     WHERE i.info_domain="DATA MANAGEMENT"
      AND i.info_name="DM_ENV_ID"
      AND i.info_number > 0.0)
     JOIN (e
     WHERE e.environment_id=i.info_number
      AND e.v500_connect_string > " ")
    DETAIL
     db_connect->connect_string = trim(e.v500_connect_string,3)
    WITH nocounter
   ;end select
   IF ( NOT (curqual))
    CALL echo("ERROR: No database connect string found.")
    RETURN(0)
   ENDIF
   IF (currdb="DB2UDB")
    SET connect_string_len = textlen(db_connect->connect_string)
    SET end_pos = findstring("/",db_connect->connect_string)
    IF (end_pos > 0)
     SET db_connect->username = cnvtlower(trim(substring(1,(end_pos - 1),db_connect->connect_string),
       3))
     SET start_pos = (end_pos+ 1)
     SET db_connect->password = cnvtlower(trim(substring(start_pos,(connect_string_len - end_pos),
        db_connect->connect_string),3))
     SET db_connect->db_name = cnvtlower(currdblink)
    ELSE
     CALL echo("ERROR:No username and password found.")
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE db2_tmp_file = vc WITH protect, noconstant(" ")
 DECLARE db2_tmp_name = vc WITH protect, noconstant(" ")
 DECLARE db2_tab_name = vc WITH protect, noconstant(" ")
 DECLARE db2_commit = i4 WITH protect, noconstant(0)
 DECLARE db2_ixf_file = vc WITH protect, noconstant(" ")
 DECLARE dcl_comm = vc WITH protect, noconstant(" ")
 DECLARE dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE dm2_mod = vc WITH private, constant("000")
 SET db2_tmp_file = trim( $1,3)
 SET db2_tmp_name =  $2
 SET db2_commit =  $3
 SELECT INTO "nl:"
  FROM dm_tables_doc td
  WHERE td.table_name=db2_tmp_name
  DETAIL
   db2_tab_name = cnvtupper(trim(td.suffixed_table_name,3))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(db2_tmp_name," table row was not found in dm_tables_doc.")
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 SET db2_ixf_file = build(substring(1,findstring(".",db2_tmp_file,1),db2_tmp_file),"ixf")
 SELECT INTO "nl:"
  FROM dm2_user_tables t
  WHERE t.table_name=db2_tab_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(db2_tab_name," table does not exist.")
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dprotect d
  WHERE d.object="T"
   AND d.object_name=db2_tab_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(db2_tab_name," table's CCL definition does not exist.")
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 IF ( NOT (rr_file(db2_ixf_file)))
  SET readme_data->status = "F"
  SET readme_data->message = concat(db2_ixf_file," not found in cer_install.")
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 IF ( NOT (find_connect_string(null)))
  SET readme_data->status = "F"
  SET readme_data->message = "Database signon not found."
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 SET dcl_comm = concat("db2 connect to ",db_connect->db_name," user ",db_connect->username," using ",
  db_connect->password)
 CALL dcl(dcl_comm,size(dcl_comm),dcl_stat)
 IF (dcl_stat=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error connecting to DB2 database: ",dcl_comm)
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 SET dcl_comm = concat("db2 import from $cer_install/",db2_ixf_file," of ixf commitcount ",trim(
   cnvtstring(db2_commit),3)," insert into ",
  db2_tab_name)
 CALL dcl(dcl_comm,size(dcl_comm),dcl_stat)
 IF (dcl_stat=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("IMPORT failed executing: ",dcl_comm)
  EXECUTE dm_readme_status
 ENDIF
 SET dcl_comm = "db2 connect reset"
 CALL dcl(dcl_comm,size(dcl_comm),dcl_stat)
#exit_script
 FREE RECORD db_connect
END GO
