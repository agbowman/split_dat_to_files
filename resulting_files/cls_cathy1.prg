CREATE PROGRAM cls_cathy1
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  cv1.active_dt_tm, cv1.active_ind, cv1_active_type_disp = uar_get_code_display(cv1.active_type_cd),
  cv1.begin_effective_dt_tm, cv1.code_set, cv1.code_value,
  cv1.display, cv1.end_effective_dt_tm, cv1.inactive_dt_tm,
  cv1.updt_dt_tm, c.alias, c.code_set,
  c.code_value, c_contributor_source_disp = uar_get_code_display(c.contributor_source_cd), c
  .updt_dt_tm,
  cv.alias, cv.code_set, cv.code_value,
  cv_contributor_source_disp = uar_get_code_display(cv.contributor_source_cd), cv.updt_dt_tm
  FROM code_value cv1,
   code_value_alias c,
   code_value_outbound cv
  PLAN (cv1
   WHERE cv1.code_set=200)
   JOIN (c
   WHERE cv1.code_value=c.code_value
    AND c.contributor_source_cd=703454)
   JOIN (cv
   WHERE cv1.code_value=cv.code_value
    AND cv.contributor_source_cd=703454)
  WITH pcformat
 ;end select
END GO
