CREATE PROGRAM dm_land_early_removal_wrap:dba
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
 SET readme_data->message = "Readme Failure: Starting dm_land_early_removal_wrap.prg script."
 DECLARE inhouseflag = i2
 SET inhouseflag = 0
 SET errcode = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  DETAIL
   inhouseflag = 1
  WITH nocounter
 ;end select
 IF (inhouseflag=1)
  CALL parser(concat("RDB ASIS (^BEGIN DM_DBARC_CONTEXT@RVADM1('","DBARC_DOC_UPDT","','","ALLOW",
    "'); END; ^) go"),1)
 ENDIF
 EXECUTE dm_dbimport "cer_install:land_early_removal_list.csv", "dm_land_early_removal", 500
 EXECUTE dm_dbimport "cer_install:land_early_addin_list.csv", "dm_land_early_addin", 500
 IF (inhouseflag=1)
  CALL parser(concat("RDB ASIS (^BEGIN DM_DBARC_CONTEXT@RVADM1('","DBARC_DOC_UPDT","','","REJECT",
    "'); END; ^) go"),1)
 ENDIF
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build(errmsg,"- Readme Failed.")
  ROLLBACK
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Unnecessary Land Early Component Removal has completed successfully..."
  COMMIT
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
