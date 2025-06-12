CREATE PROGRAM cps_upd_problem_life_cycle:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
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
 SET continue = true
 SET max_qual = 1000
 SET readme_data->message = concat("CPS_UPD_PROBLEM_LIFE_CYCLE  BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 WHILE (continue=true)
   UPDATE  FROM problem a
    SET a.life_cycle_dt_tm = null
    WHERE a.life_cycle_dt_tm=cnvtdatetime("30-dec-1899 00:00:00")
    WITH nocounter, maxqual(a,value(max_qual))
   ;end update
   IF (curqual < max_qual)
    SET continue = false
   ENDIF
   COMMIT
 ENDWHILE
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET readme_data->message = "ERROR :: Updating the LIFE_CYCLE_DT_TM"
  EXECUTE dm_readme_status
  SET readme_data->message = trim(serrmsg)
  EXECUTE dm_readme_status
  SET readme_data->status = "F"
 ELSE
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_UPD_PROBLEM_LIFE_CYCLE  END : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
END GO
