CREATE PROGRAM dm_auto_success_readme:dba
 DECLARE env_id = f8 WITH noconstant(0.0)
 DECLARE exists_on_dol = i2 WITH noconstant(0)
 DECLARE exists_in_env = i2 WITH noconstant(0)
 DECLARE existing_status = vc WITH noconstant("")
 DECLARE err_msg = vc WITH noconstant("")
 DECLARE dasr_readme = f8 WITH noconstant(0.0)
 DECLARE dasr_readme_str = vc WITH noconstant("")
 DECLARE dasr_instance = i2 WITH noconstant(0)
 DECLARE dasr_ocd = i4 WITH noconstant(0)
 DECLARE dasr_reason = vc WITH noconstant("")
 DECLARE dasr_run_once_ind = i2 WITH noconstant(1)
 DECLARE dasr_max_instance = i2 WITH noconstant(0)
 DECLARE dol_update(null) = null
 SUBROUTINE dol_update(null)
  UPDATE  FROM dm_ocd_log dol
   SET dol.status = "SUCCESS", dol.start_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), dol
    .end_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
    dol.message = concat("Auto-Success: ",dasr_reason), dol.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime
     (curdate,curtime3))
   WHERE dol.environment_id=env_id
    AND dol.project_type="README"
    AND dol.project_name=dasr_readme_str
    AND dol.project_instance=dasr_instance
   WITH nocounter
  ;end update
  IF (error(err_msg,0) > 0)
   ROLLBACK
   CALL echo(concat("*****Error:",err_msg))
   GO TO exit_script
  ENDIF
 END ;Subroutine
 DECLARE dol_insert(null) = null
 SUBROUTINE dol_insert(null)
  INSERT  FROM dm_ocd_log dol
   SET dol.status = "SUCCESS", dol.start_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), dol
    .end_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
    dol.message = concat("Readme Skipped: ",dasr_reason), dol.updt_dt_tm = cnvtdatetimeutc(
     cnvtdatetime(curdate,curtime3)), dol.project_type = "README",
    dol.project_name = dasr_readme_str, dol.project_instance = dasr_instance, dol.environment_id =
    env_id,
    dol.active_ind = 1, dol.ocd = dasr_ocd, dol.batch_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,
      curtime3))
   WITH nocounter
  ;end insert
  IF (error(err_msg,0) > 0)
   ROLLBACK
   CALL echo(concat("*****Error:",err_msg))
   GO TO exit_script
  ENDIF
 END ;Subroutine
 DECLARE dolh_insert(dolh_status=vc) = null
 SUBROUTINE dolh_insert(dolh_status)
  INSERT  FROM dm_ocd_log_hist dolh
   SET dolh.environment_id = env_id, dolh.project_type = "README", dolh.project_name =
    dasr_readme_str,
    dolh.project_instance = dasr_instance, dolh.status = dolh_status, dolh.start_dt_tm =
    cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
    dolh.end_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), dolh.batch_dt_tm =
    cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), dolh.estimated_time = 0.0,
    dolh.message = dasr_reason, dolh.active_ind = 1, dolh.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(
      curdate,curtime3)),
    dolh.ocd = dasr_ocd
   WITH nocounter
  ;end insert
  IF (error(err_msg,0) > 0)
   ROLLBACK
   CALL echo(concat("*****Error:",err_msg))
   GO TO exit_script
  ENDIF
 END ;Subroutine
 IF (reflect(parameter(1,0)) > " "
  AND reflect(parameter(2,0)) > " "
  AND reflect(parameter(3,0)) > " ")
  SET dasr_readme = cnvtreal(parameter(1,0))
  SET dasr_instance = cnvtint(parameter(2,0))
  SET dasr_reason = parameter(3,0)
  SET dasr_reason = trim(dasr_reason,3)
 ELSE
  SET message = window
  SET width = 132
  CALL clear(1,1)
  CALL box(1,1,8,130)
  CALL line(3,1,130,xhor)
  CALL clear(2,2,128)
  CALL text(2,35,"Auto-Success Readme")
  CALL text(4,3,"Readme ID:")
  CALL accept(4,14,"99999;9",0)
  SET dasr_readme = curaccept
  CALL text(5,3,"Instance:")
  CALL accept(5,14,"999;9",0)
  SET dasr_instance = curaccept
  CALL text(6,3,"Reason:")
  CALL accept(6,14,"X(255);C","")
  SET dasr_reason = trim(curaccept,3)
  SET message = nowindow
 ENDIF
 IF (dasr_readme < 1.0)
  CALL echo("*****Readme ID must be a number greater than zero")
  GO TO exit_script
 ENDIF
 IF (dasr_instance < 1)
  CALL echo("*****Instance must be a number greater than zero")
  GO TO exit_script
 ENDIF
 IF (dasr_reason="")
  CALL echo("*****Reason was not provided")
  GO TO exit_script
 ENDIF
 SET dasr_readme_str = cnvtstring(dasr_readme)
 SELECT INTO "nl:"
  FROM dm_ocd_log dol
  WHERE dol.project_type="README"
   AND dol.project_name=dasr_readme_str
  DETAIL
   exists_on_dol = 1
   IF (dol.project_instance=dasr_instance)
    dasr_ocd = dol.ocd
   ENDIF
  WITH nocounter
 ;end select
 IF (error(err_msg,0) > 0)
  CALL echo(concat("*****Error:",err_msg))
  GO TO exit_script
 ENDIF
 IF (exists_on_dol=0)
  CALL echo(concat("Readme ",dasr_readme_str," has never run at this client"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   env_id = di.info_number
  WITH nocounter
 ;end select
 IF (error(err_msg,0) > 0)
  CALL echo(concat("*****Error:",err_msg))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_ocd_log dol
  WHERE dol.environment_id=env_id
   AND dol.project_type="README"
   AND dol.project_name=dasr_readme_str
   AND dol.project_instance=dasr_instance
  DETAIL
   exists_in_env = 1, existing_status = dol.status
  WITH nocounter
 ;end select
 IF (error(err_msg,0) > 0)
  CALL echo(concat("*****Error:",err_msg))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  max_val = max(dol.project_instance)
  FROM dm_ocd_log dol
  WHERE dol.environment_id=env_id
   AND dol.project_type="README"
   AND dol.project_name=dasr_readme_str
  DETAIL
   dasr_max_instance = max_val
  WITH nocounter
 ;end select
 IF (error(err_msg,0) > 0)
  CALL echo(concat("*****Error:",err_msg))
  GO TO exit_script
 ENDIF
 IF (dasr_instance < dasr_max_instance)
  CALL echo(concat("Readme ",dasr_readme_str," instance ",trim(cnvtstring(dasr_instance),3),
    " is not valid for this environment"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_readme dr
  WHERE dr.readme_id=dasr_readme
   AND (dr.instance=
  (SELECT
   max(dr2.instance)
   FROM dm_readme dr2
   WHERE dr2.readme_id=dr.readme_id))
  DETAIL
   dasr_run_once_ind = dr.run_once_ind
  WITH nocounter
 ;end select
 IF (error(err_msg,0) > 0)
  CALL echo(concat("*****Error:",err_msg))
  GO TO exit_script
 ENDIF
 IF (dasr_run_once_ind=1)
  IF (exists_in_env=1)
   IF (existing_status="SUCCESS")
    CALL echo(concat("Readme ",dasr_readme_str," instance ",trim(cnvtstring(dasr_instance),3),
      " is already successful in this environment"))
   ELSEIF (existing_status="FAILED")
    CALL dol_update(null)
    CALL dolh_insert("AUTOSUCCESS")
    COMMIT
    CALL echo(concat("Readme ",dasr_readme_str," instance ",trim(cnvtstring(dasr_instance),3),
      " is set to SUCCESS"))
   ELSE
    CALL echo(concat("Readme ",dasr_readme_str," instance ",trim(cnvtstring(dasr_instance),3),
      " is not in a status that can be changed."))
   ENDIF
  ELSE
   CALL dol_insert(null)
   CALL dolh_insert("SKIPRUNONCE")
   COMMIT
   CALL echo(concat("Readme ",dasr_readme_str," instance ",trim(cnvtstring(dasr_instance),3),
     " is set to be skipped"))
  ENDIF
 ELSE
  SET dasr_instance = (dasr_instance+ 1)
  CALL dol_insert(null)
  CALL dolh_insert("SKIPRUNMANY")
  COMMIT
  CALL echo(concat("Readme ",dasr_readme_str," is set to be skipped"))
 ENDIF
#exit_script
 CALL echo("*****Exiting...")
END GO
