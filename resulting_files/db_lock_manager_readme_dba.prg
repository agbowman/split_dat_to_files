CREATE PROGRAM db_lock_manager_readme:dba
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
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: Starting db_lock_manager_readme script"
 CALL compile_sql("db_lock_manager_constants.sql","DB_LOCK_MANAGER_CONSTANTS","PACKAGE",
  "db_lock_manager_constants_package_spec_version")
 CALL compile_sql("db_lock_manager_package_spec.sql","DB_LOCK_MANAGER","PACKAGE",
  "db_lock_manager_package_spec_version")
 CALL compile_sql("db_lock_manager_package_body.sql","DB_LOCK_MANAGER","PACKAGE BODY",
  "db_lock_manager_package_body_version")
 SUBROUTINE (compile_sql(file_name=vc,object_name=vc,object_type=vc,version_text=vc) =null)
   SET current_version = get_current_version(object_name,object_type,version_text)
   SET new_version = get_new_version(file_name,version_text)
   IF (new_version > current_version)
    CALL echo(concat("Compiling ",file_name))
    IF ((validate(skip_rdb_reader,- (1))=- (1)))
     SET rdb_reader_ind = 1
    ENDIF
    EXECUTE dm_readme_include_sql concat("cer_install:",file_name)
    IF ((dm_sql_reply->status="F"))
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to compile ",file_name,". ",dm_sql_reply->msg)
     GO TO exit_script
    ENDIF
    CALL echo(concat("Checking compilation of ",object_name," ",object_type))
    IF ((validate(skip_rdb_reader,- (1))=- (1)))
     SET rdb_reader_ind = 1
    ENDIF
    EXECUTE dm_readme_include_sql_chk object_name, object_type
    IF ((dm_sql_reply->status="F"))
     SET readme_data->status = "F"
     SET readme_data->message = concat("Verification of ",object_name," ",object_type," failed. ",
      dm_sql_reply->msg)
     GO TO exit_script
    ENDIF
   ELSE
    CALL echo(build("Not compiling ",file_name,". Version attempted to compile: ",new_version,
      ", Current version: ",
      current_version))
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_new_version(file_name=vc,version_text=vc) =f8)
   FREE DEFINE rtl
   DEFINE rtl concat("cer_install:",file_name)
   DECLARE version_str = vc WITH protect, noconstant("")
   DECLARE found_version_text = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM rtlt r
    DETAIL
     IF (found_version_text=0)
      IF (findstring(version_text,r.line) > 0)
       version_str = trim(r.line), found_version_text = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (version_str="")
    SET readme_data->status = "F"
    SET readme_data->message = concat("Unable to find version_text: ",version_text," in file: ",
     file_name)
    GO TO exit_script
   ENDIF
   RETURN(get_version_from_str(version_str))
 END ;Subroutine
 SUBROUTINE (get_current_version(object_name=vc,object_type=vc,version_text=vc) =f8)
   DECLARE version_str = vc WITH protect, noconstant("")
   DECLARE version = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    text_str = ds.text
    FROM dba_source ds
    WHERE ds.owner="V500"
     AND ds.name=object_name
     AND ds.type=object_type
     AND ds.text=patstring(concat("*",version_text,"*"))
    DETAIL
     version_str = trim(text_str)
    WITH nocounter
   ;end select
   RETURN(get_version_from_str(version_str))
 END ;Subroutine
 SUBROUTINE (get_version_from_str(version_str=vc) =f8)
   DECLARE version = f8 WITH protect, noconstant(0.0)
   IF (version_str > "")
    SET start_index = (findstring("=",version_str)+ 1)
    SET end_index = ((textlen(version_str) - start_index)+ 1)
    SET version = cnvtreal(substring(start_index,end_index,version_str))
    IF (version=0.0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Invalid version string in the package ",object_name)
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(version)
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
 GO TO exit_script
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
