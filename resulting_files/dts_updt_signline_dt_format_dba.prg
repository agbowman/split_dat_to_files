CREATE PROGRAM dts_updt_signline_dt_format:dba
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
 RECORD elements(
   1 qual[*]
     2 cdf_meaning = c12
     2 code_value = f8
     2 cdf_meaning1 = c12
     2 code_value1 = f8
     2 new_display = c40
 )
 SET readme_data->status = "F"
 SET elements_count = 10
 SET stat = 0
 SET cnt = 0
 SET code_value = 0.0
 SET code_set = 0.0
 SET time_format_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET time_format_cd = 0.0
 SET code_value = 0.0
 SET code_set = 22669.00
 SET cdf_meaning = "T"
 EXECUTE cpm_get_cd_for_cdf
 SET time_format_cd = code_value
 CALL echo(build("cdf_meaning=",cdf_meaning,"_code_value=",code_value))
 IF (code_value=0.0)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(elements->qual,elements_count)
 SET elements->qual[1].cdf_meaning = "CNSIGNTMN"
 SET elements->qual[1].cdf_meaning1 = "CNSIGNDTN"
 SET elements->qual[1].new_display = "CN Sign Date/Time(n)"
 SET elements->qual[2].cdf_meaning = "CNSIGNTM"
 SET elements->qual[2].cdf_meaning1 = "CNSIGNDT"
 SET elements->qual[2].new_display = "CN Sign Date/Time"
 SET elements->qual[3].cdf_meaning = "CNDICTTM"
 SET elements->qual[3].cdf_meaning1 = "CNDICTDT"
 SET elements->qual[3].new_display = "CN Dictate Date/Time"
 SET elements->qual[4].cdf_meaning = "CNTRANSTM"
 SET elements->qual[4].cdf_meaning1 = "CNTRANSDT"
 SET elements->qual[4].new_display = "CN Transcribed Date/Time"
 SET elements->qual[5].cdf_meaning = "CNTRANSTMN"
 SET elements->qual[5].cdf_meaning1 = "CNTRANSDTN"
 SET elements->qual[5].new_display = "CN Transcribed Date/Time(n)"
 SET elements->qual[6].cdf_meaning = "CNMODIFYTM"
 SET elements->qual[6].cdf_meaning1 = "CNMODIFYDT"
 SET elements->qual[6].new_display = "CN Modify Date/Time"
 SET elements->qual[7].cdf_meaning = "CNMODIFYTMN"
 SET elements->qual[7].cdf_meaning1 = "CNMODIFYDTN"
 SET elements->qual[7].new_display = "CN Modify Date/Time(n)"
 SET elements->qual[8].cdf_meaning = "CNCOSIGNTIM"
 SET elements->qual[8].cdf_meaning1 = "CNCOSIGNDT"
 SET elements->qual[8].new_display = "CN CoSignature Date/Time"
 SET elements->qual[9].cdf_meaning = "CNCOSIGNTIMN"
 SET elements->qual[9].cdf_meaning1 = "CNCOSIGNDTN"
 SET elements->qual[9].new_display = "CN CoSignature Date/Time(n)"
 SET elements->qual[10].cdf_meaning = "CNVERITIME"
 SET elements->qual[10].cdf_meaning1 = "CNVERIDATE"
 SET elements->qual[10].new_display = "CN Verify Date/Time"
 FOR (cnt = 1 TO elements_count)
   SET code_value = 0.0
   SET code_set = 14287.00
   SET cdf_meaning = elements->qual[cnt].cdf_meaning
   EXECUTE cpm_get_cd_for_cdf
   SET elements->qual[cnt].code_value = code_value
   CALL echo(build("cdf_meaning=",cdf_meaning,"_code_value=",code_value))
   SET code_value = 0.0
   SET code_set = 14287.00
   SET cdf_meaning = elements->qual[cnt].cdf_meaning1
   EXECUTE cpm_get_cd_for_cdf
   SET elements->qual[cnt].code_value1 = code_value
   CALL echo(build("cdf_meaning=",cdf_meaning,"_code_value=",code_value))
 ENDFOR
 UPDATE  FROM sign_line_format_detail slfd,
   (dummyt d  WITH seq = value(elements_count))
  SET slfd.data_element_format_cd = time_format_cd, slfd.data_element_cd = elements->qual[d.seq].
   code_value1, slfd.updt_cnt = (slfd.updt_cnt+ 1),
   slfd.updt_cnt = cnvtdatetime(curdate,curtime3), slfd.updt_id = reqinfo->updt_id, slfd.updt_task =
   reqinfo->updt_task,
   slfd.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (slfd
   WHERE slfd.data_element_format_cd=0
    AND (slfd.data_element_cd=elements->qual[d.seq].code_value))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET readme_data->status = "S"
 ELSE
  SET readme_data->status = "S"
 ENDIF
 SELECT INTO "nl:"
  d.seq
  FROM sign_line_format_detail slfd,
   (dummyt d  WITH seq = value(elements_count))
  PLAN (d)
   JOIN (slfd
   WHERE slfd.data_element_format_cd=0
    AND (slfd.data_element_cd=elements->qual[d.seq].code_value))
  DETAIL
   IF (slfd.data_element_format_cd=0)
    readme_data->status = "F"
   ENDIF
  WITH nocounter
 ;end select
 IF ((readme_data->status="S"))
  UPDATE  FROM code_value cv,
    (dummyt d  WITH seq = value(elements_count))
   SET cv.active_ind = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_cnt = cnvtdatetime(curdate,curtime3
     ),
    cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=14287
     AND (cv.code_value=elements->qual[d.seq].code_value))
   WITH nocounter
  ;end update
  UPDATE  FROM code_value cv,
    (dummyt d  WITH seq = value(elements_count))
   SET cv.display = elements->qual[d.seq].new_display, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_cnt =
    cnvtdatetime(curdate,curtime3),
    cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=14287
     AND (cv.code_value=elements->qual[d.seq].code_value1))
   WITH nocounter
  ;end update
 ENDIF
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "ERROR: Updates failed for sign_line_format_detail table..."
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SIGN_LINE_FORMAT_DETAIL table successfully updated..."
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
END GO
