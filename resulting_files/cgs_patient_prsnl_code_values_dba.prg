CREATE PROGRAM cgs_patient_prsnl_code_values:dba
 IF ((validate(false,- (1))=- (1)))
  DECLARE false = i2 WITH public, noconstant(0)
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  DECLARE true = i2 WITH public, noconstant(1)
 ENDIF
 DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
 DECLARE insert_error = i2 WITH public, noconstant(4)
 DECLARE update_error = i2 WITH public, noconstant(5)
 DECLARE delete_error = i2 WITH public, noconstant(6)
 DECLARE select_error = i2 WITH public, noconstant(7)
 DECLARE lock_error = i2 WITH public, noconstant(8)
 DECLARE input_error = i2 WITH public, noconstant(9)
 DECLARE exe_error = i2 WITH public, noconstant(10)
 DECLARE failed = i2 WITH public, noconstant(false)
 DECLARE chrdomain = i2 WITH public, noconstant(true)
 DECLARE table_name = c50 WITH public, noconstant(" ")
 DECLARE serrmsg = vc WITH public, noconstant(" ")
 DECLARE ierrcode = i2 WITH public, noconstant(0)
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
 SET readme_data->message = "Executing CGS_PATIENT_PRSNL_CODE_VALUES"
 DECLARE active_cd = f8 WITH protect
 DECLARE qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect
 FREE RECORD request
 RECORD request(
   1 qual[*]
     2 code_set = i4
     2 cdf_meaning = vc
     2 code_value = f8
     2 field_name = vc
     2 field_value = vc
     2 exists_ind = i2
 )
 FREE RECORD cv_rec
 RECORD cv_rec(
   1 qual_knt = i4
   1 qual[*]
     2 code_value = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "NL:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="RHIO DOMAIN"
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET serrmsg = "Failed when querying the dm_info row"
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET chrdomain = false
  GO TO exit_script
 ENDIF
 SET active_cd = 0.0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (((ierrcode > 0) OR (active_cd < 1)) )
  SET failed = select_error
  SET serrmsg = "Failed to find ACTIVE Code Value from Code Set 48"
  GO TO exit_script
 ENDIF
 SET qual_cnt = 19
 SET stat = alterlist(request->qual,qual_cnt)
 SET request->qual[1].cdf_meaning = "PCP"
 SET request->qual[1].code_set = 331
 SET request->qual[1].field_name = "DURATION"
 SET request->qual[1].field_value = "100"
 SET request->qual[2].cdf_meaning = "PCP"
 SET request->qual[2].code_set = 331
 SET request->qual[2].field_name = "DURATION_UNIT"
 SET request->qual[2].field_value = "1"
 SET request->qual[3].cdf_meaning = "REFPROVIDER"
 SET request->qual[3].code_set = 331
 SET request->qual[3].field_name = "DURATION"
 SET request->qual[3].field_value = "6"
 SET request->qual[4].cdf_meaning = "REFPROVIDER"
 SET request->qual[4].code_set = 331
 SET request->qual[4].field_name = "DURATION_UNIT"
 SET request->qual[4].field_value = "2"
 SET request->qual[5].cdf_meaning = "REFPROVIDER"
 SET request->qual[5].code_set = 331
 SET request->qual[5].field_name = "CHR_ACCESS"
 SET request->qual[5].field_value = "Referring Provider"
 SET request->qual[6].cdf_meaning = "TREATINGPROV"
 SET request->qual[6].code_set = 331
 SET request->qual[6].field_name = "DURATION"
 SET request->qual[6].field_value = "1"
 SET request->qual[7].cdf_meaning = "TREATINGPROV"
 SET request->qual[7].code_set = 331
 SET request->qual[7].field_name = "DURATION_UNIT"
 SET request->qual[7].field_value = "1"
 SET request->qual[8].cdf_meaning = "TREATINGPROV"
 SET request->qual[8].code_set = 331
 SET request->qual[8].field_name = "CHR_ACCESS"
 SET request->qual[8].field_value = "Treating Provider"
 SET request->qual[9].cdf_meaning = "PATREQPROV"
 SET request->qual[9].code_set = 331
 SET request->qual[9].field_name = "DURATION"
 SET request->qual[9].field_value = "1"
 SET request->qual[10].cdf_meaning = "PATREQPROV"
 SET request->qual[10].code_set = 331
 SET request->qual[10].field_name = "DURATION_UNIT"
 SET request->qual[10].field_value = "1"
 SET request->qual[11].cdf_meaning = "PATREQPROV"
 SET request->qual[11].code_set = 331
 SET request->qual[11].field_name = "CHR_ACCESS"
 SET request->qual[11].field_value = "Patient-Requested Provider"
 SET request->qual[12].cdf_meaning = "CASEMGMTPROV"
 SET request->qual[12].code_set = 331
 SET request->qual[12].field_name = "DURATION"
 SET request->qual[12].field_value = "1"
 SET request->qual[13].cdf_meaning = "CASEMGMTPROV"
 SET request->qual[13].code_set = 331
 SET request->qual[13].field_name = "DURATION_UNIT"
 SET request->qual[13].field_value = "1"
 SET request->qual[14].cdf_meaning = "CASEMGMTPROV"
 SET request->qual[14].code_set = 331
 SET request->qual[14].field_name = "CHR_ACCESS"
 SET request->qual[14].field_value = "Case Management Provider"
 SET request->qual[15].cdf_meaning = "CRTORDERPROV"
 SET request->qual[15].code_set = 331
 SET request->qual[15].field_name = "DURATION"
 SET request->qual[15].field_value = "6"
 SET request->qual[16].cdf_meaning = "CRTORDERPROV"
 SET request->qual[16].code_set = 331
 SET request->qual[16].field_name = "DURATION_UNIT"
 SET request->qual[16].field_value = "2"
 SET request->qual[17].cdf_meaning = "CRTORDERPROV"
 SET request->qual[17].code_set = 331
 SET request->qual[17].field_name = "CHR_ACCESS"
 SET request->qual[17].field_value = "Court Ordered Provider"
 SET request->qual[18].cdf_meaning = "EMRGCYACCESS"
 SET request->qual[18].code_set = 331
 SET request->qual[18].field_name = "DURATION"
 SET request->qual[18].field_value = "1"
 SET request->qual[19].cdf_meaning = "EMRGCYACCESS"
 SET request->qual[19].code_set = 331
 SET request->qual[19].field_name = "DURATION_UNIT"
 SET request->qual[19].field_value = "3"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(qual_cnt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (cv
   WHERE (cv.code_set=request->qual[d.seq].code_set)
    AND (cv.cdf_meaning=request->qual[d.seq].cdf_meaning))
  HEAD REPORT
   knt = 0, stat = alterlist(cv_rec->qual,10)
  HEAD cv.code_value
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(cv_rec->qual,(knt+ 9))
   ENDIF
   cv_rec->qual[knt].code_value = cv.code_value
  DETAIL
   request->qual[d.seq].code_value = cv.code_value
  FOOT REPORT
   cv_rec->qual_knt = knt, stat = alterlist(cv_rec->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (((ierrcode > 0) OR ((cv_rec->qual_knt < 1))) )
  SET failed = select_error
  SET serrmsg = "Failed to find Code Values for request list"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM code_value cv,
   (dummyt d  WITH seq = value(cv_rec->qual_knt))
  SET cv.active_ind = 1, cv.updt_task = reqinfo->updt_task, cv.active_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cv.active_type_cd = active_cd
  PLAN (d
   WHERE (cv_rec->qual[d.seq].code_value > 0))
   JOIN (cv
   WHERE (cv.code_value=cv_rec->qual[d.seq].code_value)
    AND cv.active_ind=0)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = update_error
  SET serrmsg = "Failed to Activate Code Values"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM code_value_extension cve,
   (dummyt d  WITH seq = value(qual_cnt))
  PLAN (d
   WHERE (request->qual[d.seq].code_value > 0))
   JOIN (cve
   WHERE (cve.code_value=request->qual[d.seq].code_value)
    AND (cve.field_name=request->qual[d.seq].field_name))
  DETAIL
   request->qual[d.seq].exists_ind = true
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET serrmsg = "Failed to check CVE existence"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM code_value_extension cve,
   (dummyt d  WITH seq = value(qual_cnt))
  SET cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->updt_applctx, cve.updt_id =
   reqinfo->updt_id,
   cve.updt_cnt = 0, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.field_value = request->
   qual[d.seq].field_value,
   cve.field_name = request->qual[d.seq].field_name, cve.code_set = request->qual[d.seq].code_set,
   cve.code_value = request->qual[d.seq].code_value,
   cve.field_type = 1
  PLAN (d
   WHERE (request->qual[d.seq].exists_ind=false)
    AND (request->qual[d.seq].code_value > 0))
   JOIN (cve
   WHERE 1=1)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET serrmsg = "Failed to insert new CVE values"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM code_value_extension cve,
   (dummyt d  WITH seq = value(qual_cnt))
  SET cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->updt_applctx, cve.updt_id =
   reqinfo->updt_id,
   cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.field_value
    = request->qual[d.seq].field_value
  PLAN (d
   WHERE (request->qual[d.seq].exists_ind=true))
   JOIN (cve
   WHERE (cve.code_value=request->qual[d.seq].code_value)
    AND (cve.field_name=request->qual[d.seq].field_name))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = update_error
  SET serrmsg = "Failed to update old CVE values"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = trim(serrmsg,3)
 ELSEIF (chrdomain=false)
  SET readme_data->status = "S"
  SET readme_data->message = "Non-CHR Environment."
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "CGS_PATIENT_PRSNL_CODE_VALUES completed successfully"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
