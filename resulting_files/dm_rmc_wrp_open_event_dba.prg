CREATE PROGRAM dm_rmc_wrp_open_event:dba
 DECLARE drwop_src_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE drwop_tgt_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE drwop_event_name = vc WITH protect, noconstant(" ")
 DECLARE drwop_refresh_ind = i2 WITH protect, noconstant(0)
 DECLARE drwop_dcl_ind = i2 WITH protect, noconstant(0)
 DECLARE drwop_background_ind = i2 WITH protect, noconstant(0)
 FREE RECORD dmda_drbb_request
 RECORD dmda_drbb_request(
   1 dgnb_com_batch = vc
   1 db_password = vc
   1 db_sid = vc
   1 cur_env_name = vc
   1 dmoe_num_proc = i4
   1 src_env_name = vc
   1 cbc_ind = i2
 )
 IF (check_logfile("dm_rmc_wrp_oe",".log","DM_RMC_WRP_OPEN_EVENT LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_wop
 ENDIF
 SET drwop_src_env_id =  $1
 SET drwop_tgt_env_id =  $2
 SET drwop_event_name =  $3
 SET drwop_refresh_ind =  $4
 SET drwop_dcl_ind =  $5
 SET drwop_background_ind =  $6
 SET dmda_drbb_request->cbc_ind =  $7
 SET dm_err->eproc = "Validating connection information was passed in"
 IF (((validate(drtw_dbun,"NOT_SET")="NOT_SET") OR (((validate(drtw_dbpw,"NOT_SET")="NOT_SET") OR (
 validate(drtw_dbcon,"NOT_SET")="NOT_SET")) )) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "Open event process cannot be started at this time since required information has not been gathered"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_wop
 ELSE
  SET dmda_drbb_request->db_password = drtw_dbpw
  SET dmda_drbb_request->db_sid = drtw_dbcon
 ENDIF
 SET dmda_drbb_request->dmoe_num_proc = 4
 SET dm_err->eproc = "Gathering source environment name"
 SELECT INTO "nl:"
  FROM dm_environment d
  WHERE d.environment_id=drwop_src_env_id
  DETAIL
   dmda_drbb_request->src_env_name = d.environment_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_wop
 ENDIF
 EXECUTE dm_rmc_bookmark_begin drwop_src_env_id, drwop_tgt_env_id, drwop_event_name,
 drwop_refresh_ind, drwop_dcl_ind, drwop_background_ind
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_wop
 ENDIF
#exit_wop
END GO
