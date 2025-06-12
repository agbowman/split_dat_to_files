CREATE PROGRAM dm_rcm_upd_mcg_acct:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rcm_upd_mcg_acct..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 IF ((validate(debugme,- (9))=- (9)))
  DECLARE debugme = i2 WITH noconstant(false)
 ENDIF
 DECLARE third_party_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE attribute_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE active_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE rcm_third_party_acct_attribute_id = f8 WITH public, noconstant(0.0)
 DECLARE long_text_id = f8 WITH public, noconstant(0.0)
 SET environment = cnvtupper(logical("ENVIRONMENT"))
 FREE RECORD rcmthirdpartyacctattributes
 RECORD rcmthirdpartyacctattributes(
   1 rcm_third_party_account_list[*]
     2 rcm_third_party_account_id = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="MILLIMAN"
   AND cv.code_set=4002851
   AND cv.active_ind=1
  DETAIL
   third_party_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Failed to retrieve MILLIMAN code value: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (third_party_type_cd < 1)
  SET readme_data->status = "S"
  SET readme_data->message = "Could not retrieve MILLIMAN code value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="AUTHORITY"
   AND cv.code_set=4002852
   AND cv.active_ind=1
  DETAIL
   attribute_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Failed to retrieve AUTHORITY code value: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (attribute_type_cd < 1)
  SET readme_data->status = "S"
  SET readme_data->message = "Could not retrieve AUTHORITY code value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="ACTIVE"
   AND cv.code_set=48
   AND cv.active_ind=1
  DETAIL
   active_status_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Failed to retrieve ACTIVE code value: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (active_status_cd < 1)
  SET readme_data->status = "S"
  SET readme_data->message = "Could not retrieve ACTIVE code value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rcm_third_party_account rcm
  WHERE rcm.third_party_type_cd=third_party_type_cd
   AND  NOT (rcm.rcm_third_party_account_id IN (
  (SELECT
   rcmt.rcm_third_party_account_id
   FROM rcm_third_party_acct_attr rcmt
   WHERE rcmt.attribute_type_cd=attribute_type_cd)))
  HEAD REPORT
   count = 0
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    stat = alterlist(rcmthirdpartyacctattributes->rcm_third_party_account_list,(count+ 9))
   ENDIF
   rcmthirdpartyacctattributes->rcm_third_party_account_list[count].rcm_third_party_account_id = rcm
   .rcm_third_party_account_id
  FOOT REPORT
   IF (mod(count,10) != 0)
    stat = alterlist(rcmthirdpartyacctattributes->rcm_third_party_account_list,count)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to retrieve rcm_third_party_account rows: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (debugme)
  CALL echorecord(rcmthirdpartyacctattributes)
 ENDIF
 IF (size(rcmthirdpartyacctattributes->rcm_third_party_account_list,5) > 0)
  FOR (i = 1 TO size(rcmthirdpartyacctattributes->rcm_third_party_account_list,5))
    SET rcm_third_party_acct_attribute_id = 0.0
    SELECT INTO "nl:"
     num = seq(encounter_seq,nextval)
     FROM dual
     DETAIL
      rcm_third_party_acct_attribute_id = cnvtreal(num)
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to retrieve ENCOUNTER_SEQ: ",errmsg)
     GO TO exit_script
    ENDIF
    SET long_text_id = 0.0
    SELECT INTO "nl:"
     num = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = cnvtreal(num)
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to retrieve LONG_DATA_SEQ: ",errmsg)
     GO TO exit_script
    ENDIF
    INSERT  FROM long_text_reference ltr
     SET ltr.long_text_id = long_text_id, ltr.updt_cnt = 0, ltr.updt_dt_tm = cnvtdatetime(sysdate),
      ltr.updt_id = reqinfo->updt_id, ltr.updt_task = reqinfo->updt_task, ltr.updt_applctx = reqinfo
      ->updt_applctx,
      ltr.active_ind = 1, ltr.active_status_cd = active_status_cd, ltr.active_status_dt_tm =
      cnvtdatetime(sysdate),
      ltr.active_status_prsnl_id = reqinfo->updt_id, ltr.parent_entity_name =
      "RCM_THIRD_PARTY_ACCT_ATTR", ltr.parent_entity_id = rcm_third_party_acct_attribute_id,
      ltr.long_text = environment
     WITH nocounter
    ;end insert
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to add long text reference: ",errmsg)
     GO TO exit_script
    ENDIF
    INSERT  FROM rcm_third_party_acct_attr taa
     SET taa.rcm_third_party_acct_attr_id = rcm_third_party_acct_attribute_id, taa
      .rcm_third_party_account_id = rcmthirdpartyacctattributes->rcm_third_party_account_list[i].
      rcm_third_party_account_id, taa.long_text_id = long_text_id,
      taa.attribute_type_cd = attribute_type_cd, taa.updt_applctx = reqinfo->updt_applctx, taa
      .updt_cnt = 0,
      taa.updt_dt_tm = cnvtdatetime(sysdate), taa.updt_id = reqinfo->updt_id, taa.updt_task = reqinfo
      ->updt_task
     WITH nocounter
    ;end insert
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to add third party account attributes: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
