CREATE PROGRAM cv_rdm_upd_old_future_ordr:dba
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
 SET readme_data->message = "Readme Failed: Starting script cv_rdm_upd_old_future_ordr.prg"
 DECLARE updateflag = i2 WITH public, noconstant(0)
 DECLARE catalog_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE readmesuccessflag = i2 WITH public, noconstant(0)
 DECLARE serrormessage = vc WITH protect, noconstant("")
 DECLARE rollbackind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="CARDIOVASCUL"
   AND cv.code_set=6000
   AND cv.active_ind=1
  DETAIL
   catalog_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(serrormessage,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to look up codevalue-6000codeset",serrormessage)
  SET rollbackind = 1
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="ONHOLD"
   AND cv.code_set=14281
   AND cv.active_ind=1
  DETAIL
   dept_status_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(serrormessage,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to look up codevalue-14281codeset",serrormessage)
  SET rollbackind = (rollbackind+ 1)
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM accession_setup a
  WHERE a.accession_setup_id=72696.00
   AND a.site_code_length > 0
  DETAIL
   updateflag = 1
  WITH nocounter
 ;end select
 IF (error(serrormessage,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to look up accession_setup table",serrormessage)
  SET rollbackind = (rollbackind+ 1)
  GO TO end_program
 ENDIF
 CALL updateaorprimaryflag(0)
 SUBROUTINE updateaorprimaryflag(dummy)
   SET serrormessage = ""
   UPDATE  FROM accession_order_r aor
    SET aor.primary_flag = updateflag, aor.primary_ind = 0, aor.updt_applctx = 4100700,
     aor.updt_task = 4100700, aor.updt_dt_tm = cnvtdatetime(curdate,curtime3), aor.updt_id = reqinfo
     ->updt_id,
     aor.updt_cnt = (updt_cnt+ 1)
    WHERE aor.accession_id > 0
     AND (aor.order_id=
    (SELECT
     o.order_id
     FROM orders o
     WHERE o.catalog_type_cd=catalog_type_cd
      AND o.dept_status_cd=dept_status_cd))
   ;end update
   IF (error(serrormessage,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme failed to update primary_flag",serrormessage)
    SET readmesuccessflag = 0
    ROLLBACK
   ELSE
    SET readmesuccessflag = 1
   ENDIF
 END ;Subroutine
 IF (readmesuccessflag=1)
  SET readme_data->status = "S"
  SET readme_data->message = "The readme ran successfully and updated the AOR table."
  COMMIT
 ENDIF
#end_program
 IF (rollbackind > 0)
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
