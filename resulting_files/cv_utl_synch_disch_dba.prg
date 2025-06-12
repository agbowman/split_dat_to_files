CREATE PROGRAM cv_utl_synch_disch:dba
 PROMPT
  "Case_DATASET_R_ID:"
 RECORD test(
   1 disch_dt_tm = dq8
   1 cv_case_id = f8
 )
 SELECT INTO "NL:"
  FROM cv_case_dataset_r ccdr,
   cv_case cc,
   encounter e
  PLAN (ccdr
   WHERE (ccdr.case_dataset_r_id= $1))
   JOIN (cc
   WHERE cc.cv_case_id=ccdr.cv_case_id)
   JOIN (e
   WHERE e.encntr_id=cc.encntr_id)
  DETAIL
   test->disch_dt_tm = e.disch_dt_tm, test->cv_case_id = cc.cv_case_id
  WITH nocounter
 ;end select
 UPDATE  FROM cv_case
  SET pat_disch_dt_tm = cnvtdatetime(test->disch_dt_tm)
  WHERE (cv_case_id=test->cv_case_id)
  WITH nocounter
 ;end update
 CALL echorecord(test)
 EXECUTE cv_utl_harvest "mine", 0, 0,
  $1
END GO
