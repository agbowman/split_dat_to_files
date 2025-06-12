CREATE PROGRAM dm_get_pa_codes:dba
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=18249
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND c.cdf_meaning IN ("AENCCOMPLETE", "CPARENTARCH")
  DETAIL
   IF (c.cdf_meaning="AENCCOMPLETE")
    dm_pa_codes->crit_type[1].aenccomplete_cd = c.code_value
   ELSEIF (c.cdf_meaning="CPARENTARCH")
    dm_pa_codes->crit_type[1].archparent_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET next_seq = 0
 SELECT INTO "nl:"
  action_order = cnvtint(cve.field_value)
  FROM code_value c,
   code_value_extension cve
  WHERE c.code_set=18869
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND c.cdf_meaning="ARCHDATESET"
   AND c.code_value=cve.code_value
   AND cve.field_name="SEQ"
  DETAIL
   dm_pa_codes->action[1].set_arch_dt_tm_cd = c.code_value, next_seq = (action_order+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  action_order = cnvtint(cve.field_value)
  FROM code_value c,
   code_value_extension cve
  WHERE c.code_set=18869
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND c.code_value=cve.code_value
   AND cve.field_name="SEQ"
  DETAIL
   IF (action_order=next_seq)
    dm_pa_codes->action[1].next_action_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=18869
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND c.cdf_meaning="FARCHDATESET"
  DETAIL
   dm_pa_codes->action[1].failed_set_arch_dt_tm_cd = c.code_value
  WITH nocounter
 ;end select
END GO
