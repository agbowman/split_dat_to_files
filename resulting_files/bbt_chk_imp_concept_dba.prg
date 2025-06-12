CREATE PROGRAM bbt_chk_imp_concept:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET concept_cnt = 0
 SET concept_source_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=12100
   AND c.cdf_meaning="CERNER"
  DETAIL
   concept_source_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.concept_identifier, c.concept_source_cd
  FROM concept c
  PLAN (c
   WHERE c.concept_source_cd=concept_source_cd)
  DETAIL
   IF (((trim(c.concept_identifier)="00176115") OR (trim(c.concept_identifier)="00176094")) )
    concept_cnt = (concept_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (concept_cnt=2)
  SET request->setup_proc[1].success_ind = 1
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = build("concept_cnt = ",concept_cnt," concept_source_cd=",
   concept_source_cd)
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
