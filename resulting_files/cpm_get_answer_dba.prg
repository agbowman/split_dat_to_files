CREATE PROGRAM cpm_get_answer:dba
 SET program_modification = "September 002 1999"
 CALL echo(program_modification)
 SET code_set = 1661
 SET code_value = 0.0
 SET wanswer = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SELECT INTO "nl:"
  FROM answer a
  WHERE code_value=a.question_cd
   AND a.active_ind=1
   AND (a.active_dt_tm=
  (SELECT
   max(av.active_dt_tm)
   FROM answer av
   WHERE av.question_cd=code_value
    AND av.active_ind=1))
  DETAIL
   wanswer = cnvtreal(trim(a.answer))
  WITH nocounter
 ;end select
 SET answer = wanswer
END GO
