CREATE PROGRAM bbt_chk_imp_concept_def:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET concept_cnt = 0
 SET source_vocab_cd = 0.0
 SET concept_source_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(400,"BLOOD BANK",1,source_vocab_cd)
 SET stat = uar_get_meaning_by_codeset(12100,"CERNER",1,concept_source_cd)
 SELECT INTO "nl:"
  cd.concept_identifier, cd.concept_source_cd, cd.source_vocabulary_cd
  FROM concept_definition cd
  PLAN (cd
   WHERE cd.source_vocabulary_cd=source_vocab_cd
    AND cd.concept_source_cd=concept_source_cd
    AND cd.concept_identifier IN ("00176115", "00176094"))
  HEAD REPORT
   concept_cnt = 0
  DETAIL
   concept_cnt = (concept_cnt+ 1)
  WITH nocounter
 ;end select
 IF (concept_cnt=2)
  SET request->setup_proc[1].success_ind = 1
 ELSE
  SET request->setup_proc[1].success_ind = 0
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
