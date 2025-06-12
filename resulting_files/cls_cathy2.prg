CREATE PROGRAM cls_cathy2
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
  cv1.updt_dt_tm, inbound_alias = c.alias, c.code_set,
  c.code_value, c_contributor_source_disp = uar_get_code_display(c.contributor_source_cd), c
  .updt_dt_tm
  FROM code_value cv1,
   code_value_alias c
  PLAN (cv1
   WHERE cv1.code_set=72)
   JOIN (c
   WHERE cv1.code_value=c.code_value
    AND c.contributor_source_cd=703454)
 ;end select
END GO
