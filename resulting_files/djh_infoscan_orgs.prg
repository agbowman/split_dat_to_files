CREATE PROGRAM djh_infoscan_orgs
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  interface_alias = substring(1,5,hpa2.alias)
  FROM health_plan_alias hpa,
   health_plan hp,
   health_plan_alias hpa2
  PLAN (hpa
   WHERE hpa.alias_pool_cd=99494459
    AND hpa.active_ind=1)
   JOIN (hp
   WHERE hpa.health_plan_id=hp.health_plan_id)
   JOIN (hpa2
   WHERE hpa2.health_plan_id=hp.health_plan_id
    AND hpa2.alias_pool_cd=674680)
  ORDER BY hp.plan_name
  HEAD PAGE
   col 1, "ln", col 8,
   "InterFace", col 19, "InfoScan",
   col 33, "Health", col 75,
   " Plan", col 87, "Active Status",
   row + 1, col 1, "nbr",
   col 8, "  Code", col 19,
   "  Code", col 33, "Plan ID",
   col 43, "Health Plan Name", col 75,
   "Status", col 87, " Date / Time",
   row + 1, col 1, "---------+---------+---------+---------+---------+---------+---------+---------+",
   col + 0, "---------+---------+---------+---------+", row + 1
  DETAIL
   lncnt = (lncnt+ 1), actstat = uar_get_code_display(hpa.active_status_cd), col 1,
   lncnt"##", col 10, hpa2.alias"####",
   col 21, hpa.alias"######", col 28,
   hp.health_plan_id"###########", col 43, hp.plan_name"##############################",
   col 75, actstat"#########", col 85,
   hpa.active_status_dt_tm"mm-dd-yyyy hh:mm;;d", row + 1
   IF (row > 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 120,
   "Page:", curpage
  WITH format = variable, formfeed = none, maxcol = 140,
   maxrec = 100, nocounter, separator = " "
 ;end select
END GO
