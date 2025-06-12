CREATE PROGRAM agc_test_event:dba
 SELECT
  alias = substring(1,20,cva.alias), event_cd_disp = substring(1,20,uar_get_code_display(ce.event_cd)
   ), event_cd_disp2 = substring(1,20,uar_get_code_display(ce2.event_cd)),
  result2 = substring(1,20,ce2.result_val)
  FROM clinical_event ce,
   code_value_alias cva,
   clinical_event ce2
  PLAN (ce
   WHERE ce.event_id=ce.parent_event_id)
   JOIN (cva
   WHERE cva.code_value=ce.event_cd
    AND cva.code_set=72)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce.event_id
    AND ce2.result_val > " ")
  ORDER BY ce.encntr_id, ce.parent_event_id, cva.updt_dt_tm DESC,
   ce2.event_id
  WITH maxcol = 1000, check
 ;end select
END GO
