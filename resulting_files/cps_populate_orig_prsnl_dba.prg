CREATE PROGRAM cps_populate_orig_prsnl:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
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
 SET max_upd = 1000
 SET readme_data->message = concat("CPS_POPULATE_ORIG_PRSNL  BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 WHILE (continue=true)
   UPDATE  FROM allergy a
    SET a.orig_prsnl_id = a.data_status_prsnl_id
    PLAN (a
     WHERE a.orig_prsnl_id < 1
      AND a.data_status_prsnl_id > 0)
    WITH nocounter, maxqual(a,value(max_upd))
   ;end update
   IF (curqual < max_upd)
    SET continue = false
   ENDIF
   COMMIT
 ENDWHILE
 SET continue = true
 WHILE (continue=true)
   UPDATE  FROM allergy a
    SET a.orig_prsnl_id = a.updt_id
    PLAN (a
     WHERE a.orig_prsnl_id < 1
      AND a.updt_id > 0)
    WITH nocounter, maxqual(a,value(max_upd))
   ;end update
   IF (curqual < max_upd)
    SET continue = false
   ENDIF
   COMMIT
 ENDWHILE
#exit_script
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: Readme FAILED"
  EXECUTE dm_readme_status
  SET readme_data->status = "F"
 ELSE
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = concat("CPS_POPULATE_ORIG_PRSNL  BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
END GO
