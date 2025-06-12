CREATE PROGRAM dac_cleanup_purge_compare_data:dba
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
 DECLARE sbr_get_purge_archi_version(null) = f8
 SUBROUTINE sbr_get_purge_archi_version(null)
   DECLARE sgpav_version = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    di.info_number
    FROM dm_info di
    WHERE di.info_domain="DM PURGE"
     AND di.info_name="PURGE ARCHITECTURE VERSION"
    DETAIL
     sgpav_version = di.info_number
    WITH nocounter
   ;end select
   RETURN(sgpav_version)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dac_cleanup_purge_compare_data..."
 DECLARE dcpcd_errmsg = vc WITH protect, noconstant("")
 DECLARE dcpcd_currentversion = f8 WITH protect, constant(sbr_get_purge_archi_version(null))
 DECLARE dcpcd_triggername = vc WITH protect, constant("DM_PRESERVE_PURGE_START_DT_TM")
 DECLARE dcpcd_statement = vc WITH protect, noconstant("")
 IF (dcpcd_currentversion >= 2.0)
  SELECT INTO "nl:"
   FROM user_triggers ut
   WHERE ut.trigger_name=dcpcd_triggername
   WITH nocounter
  ;end select
  IF (error(dcpcd_errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to check trigger existence: ",dcpcd_errmsg)
   GO TO exit_script
  ELSEIF (curqual > 0)
   SET dcpcd_statement = concat("rdb asis(^ drop trigger ",dcpcd_triggername," ^) go")
   CALL parser(dcpcd_statement)
   IF (error(dcpcd_errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to drop trigger: ",dcpcd_errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
