CREATE PROGRAM cps_fix_pco_display_14124:dba
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
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET error_level = 0
 FREE RECORD hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 code_value = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=14124
    AND cv.cdf_meaning="PROVIDE"
    AND cv.display_key="PROVIDE")
  HEAD REPORT
   knt = 0, stat = alterlist(hold->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(hold->qual,(knt+ 9))
   ENDIF
   hold->qual[knt].code_value = cv.code_value
  FOOT REPORT
   hold->qual_knt = knt, stat = alterlist(hold->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_level = 1
  SET readme_data->message = "FAILURE : Error loading CODE_VALUE list"
  GO TO exit_script
 ENDIF
 IF ((hold->qual_knt < 1))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM code_value cv,
   (dummyt d1  WITH seq = value(hold->qual_knt))
  SET cv.display = "PowerChart Office", cv.display_key = "POWERCHARTOFFICE", cv.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_cnt = (cv.updt_cnt+ 1),
   cv.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (cv
   WHERE (cv.code_value=hold->qual[d1.seq].code_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_level = 1
  SET readme_data->message = "FAILURE : Error updating CODE_VALUE list"
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_level > 0)
  ROLLBACK
  SET readme_data->status = "F"
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS : Code Values Updated"
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
 SET script_version = "001 08/22/03 SF3151"
END GO
