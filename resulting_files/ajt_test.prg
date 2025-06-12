CREATE PROGRAM ajt_test
 SELECT
  pm.n_fin_nbr, pm.n_name_formatted, hp.plan_name,
  epr.member_nbr
  FROM pm_transaction pm,
   encntr_plan_reltn epr,
   health_plan hp
  PLAN (pm
   WHERE pm.activity_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
    235959))
   JOIN (epr
   WHERE epr.encntr_id=pm.n_encntr_id
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id)
  ORDER BY pm.n_encntr_id, epr.priority_seq
  HEAD pm.n_encntr_id
   row + 0
  HEAD hp.health_plan_id
   col 1, pm.n_fin_nbr, col + 2,
   pm.n_name_formatted, col + 2, hp.plan_name,
   col + 2, epr.member_nbr, col + 2,
   epr.priority_seq, row + 1
  WITH maxcol = 350
 ;end select
END GO
