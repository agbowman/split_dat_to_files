CREATE PROGRAM bbd_chk_ques_answer:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET ques_cnt = 0
 SET donor_mod_cd = 0.0
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1660
   AND c.cdf_meaning="BB DONOR"
   AND c.active_ind=1
  DETAIL
   donor_mod_cd = c.code_value
  WITH nocounter
 ;end select
 IF (donor_mod_cd=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No donor rows found for codeset 1660"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  *
  FROM question q
  WHERE q.question_cd > 0
   AND q.module_cd=donor_mod_cd
  DETAIL
   ques_cnt = (ques_cnt+ 1)
  WITH nocounter
 ;end select
 IF (ques_cnt=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "No rows found on QUESTION table"
  GO TO exit_script
 ENDIF
 SET request->setup_proc[1].success_ind = 1
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
