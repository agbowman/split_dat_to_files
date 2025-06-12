CREATE PROGRAM cp_chk_prsnl_reltn_view:dba
 SET errormsg = fillstring(255," ")
 SET error_check = error(errormsg,1)
 SET encntr_id = 0.0
 SELECT DISTINCT INTO "nl:"
  epr.encntr_id
  FROM encntr_prsnl_reltn epr,
   person p,
   encounter e
  PLAN (epr
   WHERE epr.active_ind=1
    AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ((epr.encntr_id+ 0) > 0))
   JOIN (e
   WHERE e.encntr_id=epr.encntr_id
    AND ((e.encntr_id+ 0) > 0))
   JOIN (p
   WHERE e.person_id=p.person_id
    AND ((p.person_id+ 0) > 0))
  ORDER BY epr.encntr_id DESC
  HEAD REPORT
   do_nothing = 0
  DETAIL
   encntr_id = epr.encntr_id
  WITH maxrec = 1
 ;end select
 CALL echo(encntr_id)
 SELECT INTO "nl:"
  *
  FROM chart_prsnl_reltn cpr
  WHERE cpr.encntr_id=encntr_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("failure")
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure adding chart_prsnl_reltn view"
 ELSEIF (curqual > 0)
  CALL echo("success")
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Successfully added chart_prsnl_reltn view"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
