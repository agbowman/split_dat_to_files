CREATE PROGRAM br_run_qch_security:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_run_qch_security.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errorcheck(failmsg=vc) = i2
 SUBROUTINE errorcheck(failmsg)
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(failmsg,":",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cs8_auth_cd,0)))
  DECLARE cs8_auth_cd = f8 WITH protect
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH"
   DETAIL
    cs8_auth_cd = cv.code_value
   WITH noconstant
  ;end select
  CALL errorcheck("Error1:Select statement failure")
 ENDIF
 IF ( NOT (validate(cs48_active_cd,0)))
  DECLARE cs48_active_cd = f8 WITH protect
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
   DETAIL
    cs48_active_cd = cv.code_value
   WITH noconstant
  ;end select
  CALL errorcheck("Error2:Select statement failure")
 ENDIF
 DECLARE cs_19189_new_value = f8 WITH protect, noconstant(0.0)
 DECLARE cs_357_new_value = f8 WITH protect, noconstant(0.0)
 DECLARE new_prsnl_group_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=19189
   AND cv.cdf_meaning="QCH"
  DETAIL
   cs_19189_new_value = cv.code_value
  WITH nocounter
 ;end select
 CALL errorcheck("Error3:Select statement failure")
 IF (curqual=0)
  SELECT INTO "nl:"
   z = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    cs_19189_new_value = cnvtreal(z)
   WITH nocounter
  ;end select
  CALL errorcheck("Error4:ID generation failure")
  INSERT  FROM code_value cv
   SET cv.code_value = cs_19189_new_value, cv.code_set = 19189, cv.display = "Quality Clearinghouse",
    cv.display_key = "QUALITYCLEARINGHOUSE", cv.description = "Quality Clearinghouse", cv.cdf_meaning
     = "QCH",
    cv.definition = "Quality Clearinghouse", cv.active_ind = 1, cv.active_type_cd = cs48_active_cd,
    cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.data_status_cd = cs8_auth_cd, cv
    .updt_applctx = reqinfo->updt_applctx,
    cv.updt_cnt = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
    cv.updt_task = 15301, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), cv
    .end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   WITH nocounter
  ;end insert
  CALL errorcheck("Error5:Insert failure")
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=357
   AND cv.cdf_meaning="QCHUSER"
  DETAIL
   cs_357_new_value = cv.code_value
  WITH nocounter
 ;end select
 CALL errorcheck("Error6:Select statement failure")
 IF (curqual=0)
  SELECT INTO "nl:"
   z = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    cs_357_new_value = cnvtreal(z)
   WITH nocounter
  ;end select
  CALL errorcheck("Error7:ID generation failure")
  INSERT  FROM code_value cv
   SET cv.code_value = cs_357_new_value, cv.code_set = 357, cv.display = "Quality Clearinghouse User",
    cv.display_key = "QUALITYCLEARINGHOUSEUSER", cv.description = "Quality Clearinghouse User", cv
    .cdf_meaning = "QCHUSER",
    cv.definition = "Quality Clearinghouse User", cv.active_ind = 1, cv.active_type_cd =
    cs48_active_cd,
    cv.data_status_cd = cs8_auth_cd, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv
    .updt_applctx = reqinfo->updt_applctx,
    cv.updt_cnt = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
    cv.updt_task = 15301, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), cv
    .end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   WITH nocounter
  ;end insert
  CALL errorcheck("Error8:Insert failure")
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_group p
  WHERE p.prsnl_group_class_cd=cs_19189_new_value
   AND p.prsnl_group_type_cd=cs_357_new_value
  WITH nocounter
 ;end select
 CALL errorcheck("Error9:Select statement failure")
 IF (curqual=0)
  SELECT INTO "nl:"
   z = seq(prsnl_seq,nextval)
   FROM dual
   DETAIL
    new_prsnl_group_id = cnvtreal(z)
   WITH nocounter
  ;end select
  CALL errorcheck("Error10:ID generation failure")
  INSERT  FROM prsnl_group p
   SET p.prsnl_group_id = new_prsnl_group_id, p.active_ind = 1, p.beg_effective_dt_tm = cnvtdatetime(
     curdate,curtime3),
    p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), p.prsnl_group_class_cd = cs_19189_new_value,
    p.prsnl_group_type_cd = cs_357_new_value,
    p.prsnl_group_name = "Quality Clearinghouse Users", p.prsnl_group_name_key =
    "QUALITY CLEARINGHOUSE USERS", p.active_status_cd = cs48_active_cd,
    p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
    updt_id, p.data_status_cd = cs8_auth_cd,
    p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->updt_id,
    p.updt_applctx = reqinfo->updt_applctx,
    p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
    p.updt_task = 15301
   WITH nocounter
  ;end insert
  CALL errorcheck("Error11:Insert failure")
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
