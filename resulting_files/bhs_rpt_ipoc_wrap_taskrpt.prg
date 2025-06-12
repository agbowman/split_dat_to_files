CREATE PROGRAM bhs_rpt_ipoc_wrap_taskrpt
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE ms_acct_num = vc WITH protect
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE (ea.encntr_id=request->visit[1].encntr_id)
    AND ea.encntr_alias_type_cd=mf_finnbr)
  ORDER BY ea.alias
  HEAD ea.encntr_id
   ms_acct_num = ea.alias
  WITH nocounter
 ;end select
 EXECUTE bhs_rpt_ipoc_task_report request->output_device, ms_acct_num
END GO
