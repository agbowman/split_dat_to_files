CREATE PROGRAM cp_chk_prsnl_reltn:dba
 SET cpr_ok = 0
 SET cpr2_ok = 0
 SET opr_ok = 0
 SELECT INTO "nl:"
  d.object_name, d.object_type
  FROM dprotect d
  WHERE d.object_name IN ("CHART_PRSNL_RELTN", "CHART_PRSNL_RELTN2", "ORDER_PRSNL_RELTN")
   AND d.object="T"
  HEAD REPORT
   do_nothing = 0
  DETAIL
   IF (d.object_name="CHART_PRSNL_RELTN")
    cpr_ok = 1
   ELSEIF (d.object_name="CHART_PRSNL_RELTN2")
    cpr2_ok = 1
   ELSEIF (d.object_name="ORDER_PRSNL_RELTN")
    opr_ok = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("cpr_ok = ",cpr_ok))
 CALL echo(build("cpr2_ok = ",cpr2_ok))
 CALL echo(build("opr_ok = ",opr_ok))
 IF (cpr_ok=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure on chart_prsnl_reltn"
 ELSEIF (cpr2_ok=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure on chart_prsnl_reltn2"
 ELSEIF (opr_ok=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Failure on order_prsnl_reltn"
 ELSEIF (cpr_ok=1
  AND cpr2_ok=1
  AND opr_ok=1)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Successfully added all 3 views"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
