CREATE PROGRAM dm2_log_eod_start_dt_tm:dba
 DECLARE reset_ind = i2 WITH protect, noconstant(0)
 DECLARE si_release_ident = f8 WITH protect, noconstant(0.0)
 DECLARE plan_id = i4 WITH protect, noconstant(0)
 DECLARE env_id = f8 WITH protect, noconstant(0.0)
 DECLARE project_name = vc WITH protect, noconstant("")
 DECLARE exists_ind = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE project_type = c11 WITH protect, constant("INSTALL LOG")
 SET reset_ind = cnvtint( $1)
 SET si_release_ident = cnvtreal( $2)
 SET plan_id = abs(cnvtint( $3))
 SET project_name = concat("CORE EOD SI ",build(cnvtstring(si_release_ident)),":",curnode)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   env_id = di.info_number
  WITH nocounter
 ;end select
 IF (env_id=0.0)
  CALL echo("*** Environment ID could not be found! ***")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_ocd_log dol
  WHERE dol.project_name=project_name
   AND dol.project_type=project_type
   AND dol.environment_id=env_id
   AND (dol.ocd=- (plan_id))
  DETAIL
   exists_ind = 1
  WITH nocounter
 ;end select
 IF (exists_ind=0)
  INSERT  FROM dm_ocd_log dol
   SET dol.project_name = project_name, dol.project_type = project_type, dol.environment_id = env_id,
    dol.ocd = - (plan_id), dol.status = "RUNNING", dol.start_dt_tm = cnvtdatetime(curdate,curtime3),
    dol.message = concat("Starting EOD SI instructions:  SI release ID ",cnvtstring(si_release_ident)
     ), dol.project_instance = 1, dol.batch_dt_tm = cnvtdatetime(curdate,curtime3),
    dol.active_ind = 1, dol.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   CALL echo("*** Failure creating DM_OCD_LOG row in dm2_log_eod_start_dt_tm: ***")
   CALL echo(errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ELSE
  UPDATE  FROM dm_ocd_log dol
   SET dol.start_dt_tm = evaluate(reset_ind,1,cnvtdatetime(curdate,curtime3),dol.start_dt_tm), dol
    .status = "RUNNING", dol.message = concat("Starting EOD SI instructions:  SI release ID ",
     cnvtstring(si_release_ident)),
    dol.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE dol.project_name=project_name
    AND dol.project_type=project_type
    AND dol.environment_id=env_id
    AND (dol.ocd=- (plan_id))
    AND dol.active_ind=1
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   CALL echo("*** Failure updating DM_OCD_LOG row in dm2_log_eod_start_dt_tm: ***")
   CALL echo(errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
#exit_script
END GO
