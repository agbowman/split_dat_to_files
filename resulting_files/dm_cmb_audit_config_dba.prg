CREATE PROGRAM dm_cmb_audit_config:dba
 DECLARE cmb_audit_parent = vc WITH protect, noconstant(cnvtupper( $1))
 DECLARE cmb_audit_log_level = i2 WITH protect, noconstant( $2)
 DECLARE cmb_audit_config_emsg = vc WITH protect, noconstant("")
 DECLARE cmb_audit_config_eind = i2 WITH protect, noconstant(0)
 DECLARE cmb_audit_ccl_emsg = vc WITH protect, noconstant("")
 CASE (cmb_audit_parent)
  OF "P":
   SET cmb_audit_parent = "PERSON"
  OF "E":
   SET cmb_audit_parent = "ENCOUNTER"
  OF "L":
   SET cmb_audit_parent = "LOCATION"
  OF "H":
   SET cmb_audit_parent = "HEALTH_PLAN"
  OF "O":
   SET cmb_audit_parent = "ORGANIZATION"
 ENDCASE
 IF ( NOT (cmb_audit_parent IN ("PERSON", "PRSNL", "ENCOUNTER", "LOCATION", "HEALTH_PLAN",
 "ORGANIZATION")))
  SET cmb_audit_config_eind = 1
  SET cmb_audit_config_emsg =
  'Invalid param: parent table must be "PERSON", "ENCOUNTER", "LOCATION", "HEALTH_PLAN", or "ORGANIZATION"'
  GO TO exit_script
 ENDIF
 IF (cmb_audit_parent="PRSNL")
  SET cmb_audit_parent = "PERSON"
 ENDIF
 IF ( NOT (cmb_audit_log_level IN (0, 1, 2)))
  SET cmb_audit_config_eind = 1
  SET cmb_audit_config_emsg = "Invalid param: log level must be 0, 1, or 2"
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_info di
  SET di.info_number = cmb_audit_log_level, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
   updt_task,
   di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (di.updt_cnt+ 1), di.updt_dt_tm =
   cnvtdatetime(sysdate)
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name=concat("COMBINE_AUDIT_LOG_LEVEL::",cmb_audit_parent)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "DATA MANAGEMENT", di.info_name = concat("COMBINE_AUDIT_LOG_LEVEL::",
     cmb_audit_parent), di.info_number = cmb_audit_log_level,
    di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->
    updt_applctx,
    di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(sysdate)
   WITH nocounter
  ;end insert
 ENDIF
 IF (error(cmb_audit_ccl_emsg,1) != 0)
  SET cmb_audit_config_eind = 1
  SET cmb_audit_config_emsg = concat("CCL ERROR:",cmb_audit_ccl_emsg)
 ENDIF
#exit_script
 IF (cmb_audit_config_eind=1)
  CALL echo(fillstring(90,"*"))
  CALL echo(concat("    ",cmb_audit_config_emsg))
  CALL echo(fillstring(90,"*"))
 ELSE
  COMMIT
  EXECUTE dm_cmb_audit_chk_config
 ENDIF
END GO
