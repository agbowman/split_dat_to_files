CREATE PROGRAM cpm_get_cd_for_cdf:dba
 DECLARE code_set_2 = i4
 SET code_set_2 = 0
 SET code_value_2 = 0.0
 SET stat = 0
 SET upper_meaning = fillstring(12," ")
 SET code_set_2 = code_set
 SET upper_meaning = cnvtupper(cdf_meaning)
 IF ( NOT ((reqinfo->updt_app IN (13000)))
  AND validate(readme_data,"0")="0")
  SET stat = uar_get_meaning_by_codeset(code_set_2,upper_meaning,1,code_value_2)
 ELSE
  SET stat = 1
 ENDIF
 SET code_value = code_value_2
 IF (stat != 0)
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=code_set
    AND c.cdf_meaning=cnvtupper(cdf_meaning)
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   HEAD REPORT
    code_value = c.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET code_value = 0
  ENDIF
 ENDIF
END GO
