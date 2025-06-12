CREATE PROGRAM bb_rme_question_chk:dba
 DECLARE nrecordexists = i2
 DECLARE dbbtmodulecd = f8
 DECLARE dbbdmodulecd = f8
 SET nrecordexists = 0
 SET dbbtmodulecd = 0
 SET dbbdmodulecd = 0
 SET request->setup_proc[1].success_ind = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1660
   AND c.cdf_meaning="BB TRANSF"
   AND c.active_ind=1
  DETAIL
   dbbtmodulecd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1660
   AND c.cdf_meaning="BB DONOR"
   AND c.active_ind=1
  DETAIL
   dbbdmodulecd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1661
   AND c.active_ind=1
  DETAIL
   nrecordexists = 1
  WITH nocounter
 ;end select
 IF (nrecordexists=1)
  SET nrecordexists = 0
  SELECT INTO "nl:"
   q.question_cd
   FROM question q
   WHERE q.module_cd=dbbtmodulecd
   DETAIL
    nrecordexists = 1
   WITH nocounter
  ;end select
  IF (nrecordexists=1)
   SET nrecordexists = 0
   SELECT INTO "nl:"
    q.question_cd
    FROM question q
    WHERE q.module_cd=dbbdmodulecd
    DETAIL
     nrecordexists = 1
    WITH nocounter
   ;end select
   IF (nrecordexists=1)
    SET request->setup_proc[1].success_ind = 1
   ELSE
    SET request->setup_proc[1].error_msg = "No records found on QUESTION for Blood Bank Donor"
   ENDIF
  ELSE
   SET request->setup_proc[1].error_msg = "No records found on QUESTION for Blood Bank Transfusion"
  ENDIF
 ELSE
  SET request->setup_proc[1].error_msg = "No records found for codeset 1661"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
