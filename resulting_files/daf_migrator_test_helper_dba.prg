CREATE PROGRAM daf_migrator_test_helper:dba
 IF (validate(request->test_step,"ZZZZ")="ZZZZ")
  GO TO exit_script
 ENDIF
 RECORD reply(
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dmth_cidb_delete = vc WITH public, constant("DM_INFO CIDB Delete")
 DECLARE dmth_apptier_delete = vc WITH public, constant("DM_INFO App-Tier Delete")
 DECLARE dmth_apptier_alter = vc WITH public, constant("DM_INFO Alter App-Tier")
 DECLARE dmth_create_scripts = vc WITH public, constant("Create Test Scripts")
 DECLARE dmth_create_scripts2 = vc WITH public, constant("Create Target Scripts")
 DECLARE dmth_delete_scripts = vc WITH public, constant("Delete Test Scripts")
 DECLARE dmth_purge_staged = vc WITH public, constant("Purge Stage Tables")
 DECLARE dmth_prep_at_source = vc WITH public, constant("Prep AppTier Source")
 DECLARE dmth_prep_at_target = vc WITH public, constant("Prep AppTier Target")
 DECLARE dmth_prep_td_source = vc WITH public, constant("Prep TwoDomain Source")
 DECLARE dmth_prep_td_target = vc WITH public, constant("Prep TwoDomain Target")
 DECLARE errmsg = vc WITH public, noconstant(" ")
 DECLARE errcode = i2 WITH public, noconstant(0)
 DECLARE dmth_delete_cso(null) = i2
 DECLARE dmth_delete_dacso(null) = i2
 DECLARE dmth_delete_dacsi(null) = i2
 DECLARE dmth_delete_dsms(null) = i2
 DECLARE dmth_delete_cidb(null) = i2
 DECLARE dmth_delete_apptier(null) = i2
 DECLARE dmth_alter_apptier(null) = i2
 DECLARE dmth_create_source(null) = i2
 DECLARE dmth_create_target(null) = i2
 DECLARE dmth_delete_scripts(null) = i2
 SUBROUTINE dmth_delete_cso(null)
   DELETE  FROM ccl_synch_objects cso
    WHERE cso.ccl_synch_objects_id > 0.0
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to purge from CCL_SYNCH_OBJECTS: ",errmsg)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_delete_dacso(null)
   DELETE  FROM dm_adm_ccl_synch_objects dacso
    WHERE (dacso.environment_id=
    (SELECT
     di.info_number
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"))
     AND dacso.dm_adm_ccl_synch_objects_id > 0.0
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to purge from DM_ADM_CCL_SYNCH_OBJECTS: ",errmsg)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_delete_dacsi(null)
   DELETE  FROM dm_adm_csm_script_info dacsi
    WHERE (dacsi.environment_id=
    (SELECT
     di.info_number
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"))
     AND dacsi.dm_adm_csm_script_info_id > 0.0
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to purge from DM_CSM_SCRIPT_INFO: ",errmsg)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_delete_dsms(null)
   DELETE  FROM dm_script_migration_stage dsms
    WHERE dsms.dm_script_migration_stage_id > 0.0
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to purge from DM_SCRIPT_MIGRATION_STAGE: ",errmsg)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_delete_cidb(null)
   DELETE  FROM dm_info di
    WHERE di.info_domain="Script Migrator"
     AND di.info_name="com.cerner.dbarch.daf.rdds.cidb"
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to delete CIDB row:",errmsg)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_delete_apptier(null)
   DELETE  FROM dm2_admin_dm_info dadi
    WHERE dadi.info_domain="Script Migrator"
     AND (dadi.info_long_id=
    (SELECT
     di.info_number
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"))
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to delete App-Tier row:",errmsg)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_alter_apptier(null)
   DECLARE newos = i4 WITH public, noconstant(0)
   IF (cursys2="AIX")
    SET newos = 3
   ELSE
    SET newos = 2
   ENDIF
   UPDATE  FROM dm2_admin_dm_info dadi
    SET dadi.info_char = concat(trim(dadi.info_char,3)," [Altered for Test]"), dadi.info_number =
     newos
    WHERE dadi.info_domain="Script Migrator"
     AND (dadi.info_long_id=
    (SELECT
     di.info_number
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"))
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to alter App-Tier row:",errmsg)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to alter App-Tier row: No row found")
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_create_source(null)
   CALL echo("Creating dm_csm_test_script1:dba...")
   CALL parser("drop program dm_csm_test_script1:dba go")
   CALL parser("create program dm_csm_test_script1:dba ")
   CALL parser("  call echo('This is test script1') ")
   CALL parser("end go")
   CALL echo("Creating dm_csm_test_script2:group1...")
   CALL parser("drop program dm_csm_test_script2:group1 go")
   CALL parser("create program dm_csm_test_script2:group1 ")
   CALL parser("  call echo('This is test script2:group1') ")
   CALL parser("  call echo('This is test script2:group1') ")
   CALL parser("end go")
   CALL echo("Creating dm_csm_test_script2:dba...")
   CALL parser("drop program dm_csm_test_script2:dba go")
   CALL parser("create program dm_csm_test_script2:dba ")
   CALL parser("  call echo('This is test script2:dba') ")
   CALL parser("  call echo('This is test script2:dba') ")
   CALL parser("end go")
   CALL echo("Creating dm_csm_test_script3:group99...")
   CALL parser("drop program dm_csm_test_script3:group99 go")
   CALL parser("create program dm_csm_test_script3:group99 ")
   CALL parser("  call echo('This is test script3:group99') ")
   CALL parser("  call echo('This is test script3:group99') ")
   CALL parser("  call echo('This is test script3:group99') ")
   CALL parser("end go")
   CALL echo("Creating dm_csm_test_script4:dba...")
   CALL parser("drop program dm_csm_test_script4:dba go")
   CALL parser("create program dm_csm_test_script4:dba ")
   CALL parser("  call echo('This is test script4') ")
   CALL parser("  call echo('This is test script4') ")
   CALL parser("  call echo('This is test script4') ")
   CALL parser("  call echo('This is test script4') ")
   CALL parser("end go")
   CALL echo("Creating dm_csm_test_script5:group2...")
   CALL parser("drop program dm_csm_test_script5:group2 go")
   CALL parser("create program dm_csm_test_script5:group2 ")
   CALL parser("  call echo('This is test script5:group2') ")
   CALL parser("  call echo('This is test script5:group2') ")
   CALL parser("  call echo('This is test script5:group2') ")
   CALL parser("  call echo('This is test script5:group2') ")
   CALL parser("  call echo('This is test script5:group2') ")
   CALL parser("end go")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_create_target(null)
   CALL echo("Creating dm_csm_test_script2:group1...")
   CALL parser("drop program dm_csm_test_script2:group1 go")
   CALL parser("create program dm_csm_test_script2:group1 ")
   CALL parser("  call echo('This is the target version of test script2:group1') ")
   CALL parser("  call echo('This is the target version of test script2:group1') ")
   CALL parser("end go")
   CALL echo("Creating dm_csm_test_script2:dba...")
   CALL parser("drop program dm_csm_test_script2:dba go")
   CALL parser("create program dm_csm_test_script2:dba ")
   CALL parser("  call echo('This is the target version of test script2:dba') ")
   CALL parser("  call echo('This is the target version of test script2:dba') ")
   CALL parser("end go")
   CALL echo("Creating dm_csm_test_script5:group2...")
   CALL parser("drop program dm_csm_test_script5:group2 go")
   CALL parser("create program dm_csm_test_script5:group2 ")
   CALL parser("  call echo('This is the target version of test script5:group2') ")
   CALL parser("  call echo('This is the target version of test script5:group2') ")
   CALL parser("  call echo('This is the target version of test script5:group2') ")
   CALL parser("  call echo('This is the target version of test script5:group2') ")
   CALL parser("  call echo('This is the target version of test script5:group2') ")
   CALL parser("end go")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmth_delete_scripts(null)
   CALL parser("drop program dm_csm_test_script1:dba go")
   CALL parser("drop program dm_csm_test_script2:dba go")
   CALL parser("drop program dm_csm_test_script2:group1 go")
   CALL parser("drop program dm_csm_test_script3:group99 go")
   CALL parser("drop program dm_csm_test_script4:dba go")
   CALL parser("drop program dm_csm_test_script5:group2 go")
   RETURN(1)
 END ;Subroutine
 IF ((request->test_step=dmth_cidb_delete))
  IF (dmth_delete_cidb(null)=1)
   SET reply->status_data.status = "S"
   SET reply->message = "CIDB Row Deleted Successfully."
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->test_step=dmth_apptier_delete))
  IF (dmth_delete_apptier(null)=1)
   SET reply->status_data.status = "S"
   SET reply->message = "App-Tier Row Deleted Successfully."
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->test_step=dmth_apptier_alter))
  IF (dmth_delete_apptier(null)=1)
   SET reply->status_data.status = "S"
   SET reply->message = "App-Tier Row Altered Successfully."
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->test_step=dmth_create_scripts))
  IF (dmth_create_source(null)=1)
   SET reply->status_data.status = "S"
   SET reply->message = "Custom Scripts Successfully Created."
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->test_step=dmth_create_scripts2))
  IF (dmth_create_target(null)=1)
   SET reply->status_data.status = "S"
   SET reply->message = "Custom Scripts Successfully Created."
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->test_step=dmth_delete_scripts))
  IF (dmth_delete_scripts(null)=1)
   SET reply->status_data.status = "S"
   SET reply->message = "Custom Scripts Successfully Deleted."
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->test_step=dmth_purge_staged))
  IF (dmth_delete_cso(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_dacso(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_dacsi(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_dsms(null) != 1)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->message = "Staging Tables purged successfully."
 ENDIF
 IF ((request->test_step=dmth_prep_at_source))
  IF (dmth_delete_cso(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_dacso(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_dacsi(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_dsms(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_apptier(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_scripts(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_create_source(null) != 1)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->message = "App-Tier Source Work Staged Successfully."
 ENDIF
 IF ((request->test_step=dmth_prep_at_target))
  IF (dmth_delete_cso(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_alter_apptier(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_scripts(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_create_target(null) != 1)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->message = "App-Tier Target Work Staged Successfully."
 ENDIF
 IF ((request->test_step=dmth_prep_td_source))
  IF (dmth_delete_cso(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_dsms(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_scripts(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_create_source(null) != 1)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->message = "Two Domain Source Work Staged Successfully."
 ENDIF
 IF ((request->test_step=dmth_prep_td_target))
  IF (dmth_delete_cso(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_dsms(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_delete_scripts(null) != 1)
   GO TO exit_script
  ENDIF
  IF (dmth_create_target(null) != 1)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->message = "Two Domain Target Work Staged Successfully."
 ENDIF
#exit_script
END GO
