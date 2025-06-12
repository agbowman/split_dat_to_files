CREATE PROGRAM dac_load_purge_arch_version:dba
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
 IF (validate(dpavc_version_domain,"Z")="Z")
  DECLARE dpavc_version_domain = vc WITH protect, constant("DM PURGE")
 ENDIF
 IF (validate(dpavc_version_name,"Z")="Z")
  DECLARE dpavc_version_name = vc WITH protect, constant("PURGE ARCHITECTURE VERSION")
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dac_load_purge_arch_version..."
 DECLARE dlpav_errmsg = vc WITH protect, noconstant("")
 DECLARE dlpav_finalversion = f8 WITH protect, constant(2.0)
 DECLARE dlpav_currentversion = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain=dpavc_version_domain
   AND di.info_name=dpavc_version_name
  DETAIL
   dlpav_currentversion = di.info_number
  WITH nocounter
 ;end select
 IF (error(dlpav_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to find current version: ",dlpav_errmsg)
  GO TO exit_script
 ELSEIF (curqual > 0)
  IF (dlpav_finalversion > dlpav_currentversion)
   UPDATE  FROM dm_info di
    SET di.info_number = dlpav_finalversion, di.updt_id = reqinfo->updt_id, di.updt_cnt = (di
     .updt_cnt+ 1),
     di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
     .updt_task = reqinfo->updt_task
    WHERE di.info_domain=dpavc_version_domain
     AND di.info_name=dpavc_version_name
    WITH nocounter
   ;end update
   IF (error(dlpav_errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update existing version from ",trim(cnvtstring(
       dlpav_currentversion),3)," to ",trim(cnvtstring(dlpav_finalversion),3),": ",
     dlpav_errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ELSE
  INSERT  FROM dm_info di
   SET di.info_domain = dpavc_version_domain, di.info_name = dpavc_version_name, di.info_number =
    dlpav_finalversion,
    di.updt_cnt = 0, di.updt_task = reqinfo->updt_task, di.updt_dt_tm = cnvtdatetime(curdate,curtime3
     ),
    di.updt_applctx = reqinfo->updt_applctx, di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (error(dlpav_errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed create version row: ",dlpav_errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
