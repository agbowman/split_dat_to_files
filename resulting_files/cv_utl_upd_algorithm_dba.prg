CREATE PROGRAM cv_utl_upd_algorithm:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET st02predvent_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST02PREDVENT",1,st02predvent_cd)
 IF (st02predvent_cd <= 0)
  CALL echo("There is no cdf_meaning - ST02PREDVENT under code_set 14003 in the database")
 ENDIF
 SET st02predstro_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST02PREDSTRO",1,st02predstro_cd)
 IF (st02predstro_cd <= 0)
  CALL echo("There is no cdf_meaning - ST02PREDSTRO under code_set 14003 in the database")
 ENDIF
 SET st02predreop_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST02PREDREOP",1,st02predreop_cd)
 IF (st02predreop_cd <= 0)
  CALL echo("There is no cdf_meaning - ST02PREDREOP under code_set 14003 in the database")
 ENDIF
 SET st02predrenf_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST02PREDRENF",1,st02predrenf_cd)
 IF (st02predrenf_cd <= 0)
  CALL echo("There is no cdf_meaning - ST02PREDRENF under code_set 14003 in the database")
 ENDIF
 SET st01predmort_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST01PREDMORT",1,st01predmort_cd)
 IF (st01predmort_cd <= 0)
  CALL echo("There is no cdf_meaning - ST01PREDMORT under code_set 14003 in the database")
 ENDIF
 SET st02predmm_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST02PREDMM",1,st02predmm_cd)
 IF (st02predmm_cd <= 0)
  CALL echo("There is no cdf_meaning - ST02PREDMM under code_set 14003 in the database")
 ENDIF
 SET st02preddeep_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST02PREDDEEP",1,st02preddeep_cd)
 IF (st02preddeep_cd <= 0)
  CALL echo("There is no cdf_meaning - ST02PREDDEEP under code_set 14003 in the database")
 ENDIF
 SET st02pred6d_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST02PRED6D",1,st02pred6d_cd)
 IF (st02pred6d_cd <= 0)
  CALL echo("There is no cdf_meaning - ST02PRED6D under code_set 14003 in the database")
 ENDIF
 SET st02pred14d_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(14003,"ST02PRED14D",1,st02pred14d_cd)
 IF (st02pred14d_cd <= 0)
  CALL echo("There is no cdf_meaning - ST02PRED14D under code_set 14003 in the database")
 ENDIF
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st02predvent_cd
  WHERE description="CABG PREDVENT"
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st02predstro_cd
  WHERE description="CABG PREDSTRO"
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st02predreop_cd
  WHERE description="CABG PREDREOP"
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st02predrenf_cd
  WHERE description="CABG PREDRENF"
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st01predmort_cd
  WHERE description IN ("CABG PREDMORT", "AVR OR MVR PREDMORT", "AVR+CABG or MVR+CABG PREDMORT")
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st02predmm_cd
  WHERE description="CABG PREDMM"
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st02preddeep_cd
  WHERE description="CABG PREDDEEP"
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st02pred6d_cd
  WHERE description="CABG PRED6D"
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st02pred14d_cd
  WHERE description="CABG PRED14D"
 ;end update
 UPDATE  FROM cv_algorithm
  SET result_dta_cd = st01predmort_cd
  WHERE description IN ("CABG", "AVR or MVR", "AVR+CABG or MVR+CABG")
 ;end update
 UPDATE  FROM cv_algorithm
  SET updt_cnt = (updt_cnt+ 1)
  WHERE algorithm_id > 0
 ;end update
#exit_script
 SET reply->status_data.status = "S"
 COMMIT
 CALL echo("**************************************")
 CALL echo("Update successful and action commited!")
 CALL echo("**************************************")
END GO
