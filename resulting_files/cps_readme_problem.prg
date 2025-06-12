CREATE PROGRAM cps_readme_problem
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
 FREE SET hold
 RECORD hold(
   1 person_knt = i4
   1 person[*]
     2 problem_id = f8
 )
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
 SET dvar = 0
 SET error_level = 0
 SET readme_data->message = concat("CPS_readme_problem BEG : ",format(cnvtdatetime(curdate,curtime3),
   "dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 SET table_exists = "F"
 SELECT INTO "NL:"
  FROM user_tab_columns utc
  PLAN (utc
   WHERE utc.table_name="PROBLEM")
  DETAIL
   table_exists = "T"
  WITH nocounter
 ;end select
 IF (table_exists="F")
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  occur = count(p.problem_instance_id), p.problem_id
  FROM problem p
  PLAN (p
   WHERE p.problem_id > 0
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p.problem_instance_id > 1)
  GROUP BY p.problem_id
  HAVING count(p.problem_instance_id) > 1
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(hold->person,(knt+ 10))
   ENDIF
   hold->person[knt].problem_id = p.problem_id
  FOOT REPORT
   hold->person_knt = knt, stat = alterlist(hold->person,knt)
  WITH nocounter
 ;end select
 IF ((hold->person_knt < 1))
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "ERROR :: A script error occurred getting the problem name"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ELSE
   SET readme_data->message = "Info :: There is no data to update in problem table"
   EXECUTE dm_readme_status
   GO TO exit_script
  ENDIF
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  FREE RECORD problem
  RECORD problem(
    1 qual_cnt = f8
    1 qual[*]
      2 prob_id = f8
      2 prob_cnt = f8
      2 prob[*]
        3 prob_ins_id = f8
  )
  SET prob_cnt = size(hold->person,5)
  SELECT INTO "nl"
   FROM problem p,
    (dummyt d  WITH seq = value(prob_cnt))
   PLAN (d)
    JOIN (p
    WHERE (p.problem_id=hold->person[d.seq].problem_id)
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.problem_id, p.beg_effective_dt_tm
   HEAD REPORT
    cnt = 0, stat = alterlist(problem->qual,10)
   HEAD p.problem_id
    knt = 0, stat = alterlist(problem->qual[cnt].prob,10), cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(problem->qual,(cnt+ 9))
    ENDIF
    problem->qual[cnt].prob_id = p.problem_id
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1)
     stat = alterlist(problem->qual[cnt].prob,(knt+ 9))
    ENDIF
    problem->qual[cnt].prob[knt].prob_ins_id = p.problem_instance_id
   FOOT  p.problem_id
    problem->qual[cnt].prob_cnt = knt, stat = alterlist(problem->qual[cnt].prob,knt)
   FOOT REPORT
    problem->qual_cnt = cnt, stat = alterlist(problem->qual,cnt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET readme_data->message = "Error :: Getting instance ids for duplicates"
   EXECUTE dm_readme_status
   SET readme_data->message = trim(serrmsg)
   EXECUTE dm_readme_status
   SET error_level = 1
   GO TO exit_script
  ENDIF
  SET list1 = size(problem->qual,5)
  SET i = 0
  SET prob_cnt = 0
  FOR (i = 1 TO list1)
    IF ((problem->qual[i].prob_cnt > 1))
     SET prob_cnt = (problem->qual[i].prob_cnt - 1)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM problem p,
       (dummyt d  WITH seq = value(prob_cnt))
      SET p.active_ind = 0, p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p
       .updt_cnt+ 1),
       p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      PLAN (d)
       JOIN (p
       WHERE (p.problem_instance_id=problem->qual[i].prob[d.seq].prob_ins_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET readme_data->message = build("ERROR :: A script error occurred when update problem_id :",
       problem->qual[i].prob[d.seq].prob_ins_id)
      EXECUTE dm_readme_status
      SET readme_data->message = trim(serrmsg)
      EXECUTE dm_readme_status
      SET error_level = 1
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
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
 SET readme_data->message = concat("CPS_readme_problem  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 COMMIT
 SET script_info = "001 09/19/03 SF3151"
END GO
