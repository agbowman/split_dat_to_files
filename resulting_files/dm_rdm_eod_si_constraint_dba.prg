CREATE PROGRAM dm_rdm_eod_si_constraint:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_eod_si_constraint.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE index_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE cur_tblspace = vc WITH protect, noconstant("")
 DECLARE target_tblspace = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  di.tablespace_name
  FROM dba_indexes di
  WHERE di.index_name="XIE1DM_CORE_EOD_SI"
  DETAIL
   index_exists_ind = 1, cur_tblspace = di.tablespace_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dt.tablespace_name
  FROM dba_tables dt
  WHERE dt.table_name="DM_CORE_EOD_SI"
  DETAIL
   target_tblspace = dt.tablespace_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Could not find the DM_CORE_EOD_SI table in DBA_TABLES!"
  GO TO exit_script
 ENDIF
 IF (index_exists_ind=1)
  IF (cur_tblspace="MISC")
   CALL parser(concat("rdb asis(^ALTER INDEX XIE1DM_CORE_EOD_SI REBUILD TABLESPACE ",target_tblspace,
     "^) go"))
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to move XIE1DM_CORE_EOD_SI to '",target_tblspace,"': ",
     errmsg)
    GO TO exit_script
   ELSE
    SET readme_data->status = "S"
    SET readme_data->message = concat("XIE1DM_CORE_EOD_SI successfully moved to '",target_tblspace,
     "'")
    GO TO exit_script
   ENDIF
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "The index has already been correctly created."
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_core_eod_si si
  PLAN (si
   WHERE 1=1)
  GROUP BY si.os_version_name, si.si_release_ident, si.version_number,
   si.line_number
  HAVING count(*) > 1
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: dm_core_eod_si has unique constraint violations."
  GO TO exit_script
 ENDIF
 CALL parser("rdb asis(^ create unique index XIE1DM_CORE_EOD_SI ^)")
 CALL parser("asis(^ on DM_CORE_EOD_SI( ^)")
 CALL parser("asis(^	os_version_name, ^)")
 CALL parser("asis(^	si_release_ident, ^)")
 CALL parser("asis(^	version_number, ^)")
 CALL parser("asis(^	line_number) ^)")
 CALL parser(concat("asis(^TABLESPACE ",target_tblspace,"^) go"))
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error creating index on DM_CORE_EOD_SI: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Unique index created for DM_CORE_EOD_SI."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
