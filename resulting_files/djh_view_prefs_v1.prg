CREATE PROGRAM djh_view_prefs_v1
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  v.active_ind, v.application_number, position = uar_get_code_display(v.position_cd),
  n.pvc_name
  FROM view_prefs v,
   name_value_prefs n
  PLAN (v
   WHERE v.active_ind=1
    AND v.position_cd > 0
    AND v.frame_type="CHART"
    AND v.view_name="CHARTSUMM")
   JOIN (n
   WHERE n.active_ind=1
    AND v.view_prefs_id=n.parent_entity_id
    AND n.parent_entity_name="VIEW_PREFS"
    AND n.pvc_name="VIEW_CAPTION"
    AND n.pvc_value="Med*Rec*")
  ORDER BY v.application_number
  HEAD PAGE
   col 50, "Med Rec tab descriptions", row + 1,
   col 1, " ln", row + 1,
   col 1, " nbr", col 18,
   "Position", col 44, "Tab Description",
   row + 1, col 1, "---------+---------+---------+---------+---------+---------+---------+---------+",
   col + 0, "---------+---------+---------+---------+---------+---------+---------+---------+", row
    + 1
  DETAIL
   lncnt = (lncnt+ 1), col 1, lncnt"####",
   col + 1, v.application_number, col + 1,
   position"#########################", col + 1, n.pvc_value"#########################",
   col + 1, v.frame_type"#####", col + 1,
   v.view_name"#####", col + 1, n.pvc_name"######",
   col + 1, v.position_cd"##########", col + 1,
   row + 1
   IF (row > 60)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 90,
   curnode
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casbtest")
    ms_domain = "CERT"
   ELSEIF (curnode="casetest")
    ms_domain = "TEST"
   ELSE
    ms_domain = "domain?"
   ENDIF
   col 100, ms_domain, col 130,
   "Page:", curpage
  WITH maxrec = 200, maxcol = 162, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
