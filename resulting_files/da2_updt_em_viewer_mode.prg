CREATE PROGRAM da2_updt_em_viewer_mode
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
 SET readme_data->message = "Error starting DA2_UPDT_EM_VIEWER_MODE"
 DECLARE reporttypecode = f8 WITH protect, noconstant(0.0)
 DECLARE ownergroupcode = f8 WITH protect, noconstant(0.0)
 DECLARE outputviewercode = f8 WITH protect, noconstant(0.0)
 DECLARE errormessage = vc WITH protect, noconstant("")
 DECLARE cclreporttypecki = vc WITH protect, noconstant("CKI.CODEVALUE!4101382194")
 DECLARE explorermenuownergrpcki = vc WITH protect, noconstant("CKI.CODEVALUE!4201428605")
 DECLARE outputviewercki = vc WITH protect, noconstant("CKI.CODEVALUE!4110840105")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki=cclreporttypecki
   AND cv.active_ind=1
  DETAIL
   reporttypecode = cv.code_value
  WITH nocounter
 ;end select
 IF (((error(errormessage,0) != 0) OR (curqual=0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("Lookup failed for CCL report type code: ",errormessage)
  GO TO exit_now
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki=explorermenuownergrpcki
   AND cv.active_ind=1
  DETAIL
   ownergroupcode = cv.code_value
  WITH nocounter
 ;end select
 IF (((error(errormessage,0) != 0) OR (curqual=0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("Lookup failed for Explorer Menu owner group code: ",errormessage
   )
  GO TO exit_now
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki=outputviewercki
   AND cv.active_ind=1
  DETAIL
   outputviewercode = cv.code_value
  WITH nocounter
 ;end select
 IF (((error(errormessage,0) != 0) OR (curqual=0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("Lookup failed for output viewer code: ",errormessage)
  GO TO exit_now
 ENDIF
 UPDATE  FROM da_report r
  SET r.viewer_mode_cd = outputviewercode, r.last_updt_dt_tm = cnvtdatetime(sysdate), r
   .last_updt_user_id = reqinfo->updt_id,
   r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(
    sysdate),
   r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task
  WHERE r.active_ind=1
   AND r.viewer_mode_cd != outputviewercode
   AND r.report_type_cd=reporttypecode
   AND r.owner_group_cd=ownergroupcode
   AND r.updt_cnt=0
  WITH nocounter
 ;end update
 IF (error(errormessage,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Could not update rows for DA_REPORT "," :",errormessage)
  GO TO exit_now
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = build(curqual,concat(
   " number of row(s) on DA_REPORT table were updated without error."))
 COMMIT
 GO TO exit_now
#exit_now
 IF ((readme_data->status != "S"))
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
