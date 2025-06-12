CREATE PROGRAM cps_readme_code_value:dba
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
 FREE SET values
 RECORD values(
   1 qual_cnt = i2
   1 qual[*]
     2 code_value = f8
 )
 SET error_level = 0
 SET readme_data->message = concat("CPS_README_CODE_VALUE BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16189
   AND cv.cdf_meaning="PTLIST"
   AND cv.active_ind=1
  ORDER BY cv.code_value DESC
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(values->qual,(cnt+ 10))
   ENDIF
   values->qual[cnt].code_value = cv.code_value
  FOOT REPORT
   values->qual_cnt = cnt, stat = alterlist(values->qual,cnt)
  WITH nocounter
 ;end select
 IF ((values->qual_cnt < 1))
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred getting the code value"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ELSE
   SET readme_data->message = "Info :: There is no data to update in code_value table"
   EXECUTE dm_readme_status
   GO TO exit_script
  ENDIF
 ELSEIF ((values->qual_cnt > 0))
  IF ((values->qual_cnt=1))
   SET readme_data->message =
   "Info :: There's only 1 exist in code_value table. No need to do update"
   EXECUTE dm_readme_status
  ELSE
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM code_value cv
    SET active_ind = 0
    WHERE cv.code_set=16189
     AND (cv.code_value=values->qual[1].code_value)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET readme_data->message = build("ERROR :: Updating code_value :",values->qual[1].code_value,
     " to inactive")
    EXECUTE dm_readme_status
    SET readme_data->message = trim(serrmsg)
    EXECUTE dm_readme_status
    SET error_level = 1
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (error_level=1)
  ROLLBACK
  SET status_msg = "FAILURE"
  SET readme_data->status = "F"
 ELSE
  COMMIT
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_README_CODE_VALUE  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
END GO
