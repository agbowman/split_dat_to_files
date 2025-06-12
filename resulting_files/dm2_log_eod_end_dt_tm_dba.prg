CREATE PROGRAM dm2_log_eod_end_dt_tm:dba
 DECLARE log_file = vc WITH protect, noconstant("")
 DECLARE error_ind = i2 WITH protect, noconstant(0)
 DECLARE si_release_ident = f8 WITH protect, noconstant(0.0)
 DECLARE plan_id = i4 WITH protect, noconstant(0)
 DECLARE env_id = f8 WITH protect, noconstant(0.0)
 DECLARE project_name = vc WITH protect, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE project_type = c11 WITH protect, constant("INSTALL LOG")
 SET si_release_ident = cnvtreal( $1)
 SET plan_id = abs(cnvtint( $2))
 SET log_file = build( $3)
 SET error_ind = cnvtint( $4)
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
 UPDATE  FROM dm_ocd_log dol
  SET dol.message = evaluate(error_ind,1,concat("Error encountered.  More details can be found in ",
     log_file),concat("Finished EOD special instructions:  SI release ID ",cnvtstring(
      si_release_ident))), dol.status = evaluate(error_ind,1,"FAILED","COMPLETE"), dol.end_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dol.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE dol.project_name=project_name
   AND dol.project_type=project_type
   AND (dol.ocd=- (plan_id))
   AND dol.environment_id=env_id
   AND dol.active_ind=1
 ;end update
 IF (error(errmsg,0) > 0)
  CALL echo("*** Error updating EOD SI DM_OCD_LOG status: ***")
  CALL echo(errmsg)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
