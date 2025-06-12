CREATE PROGRAM djh_view_prefs_v2
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 SET lncnt = 0
 SELECT DISTINCT INTO  $OUTDEV
  v.application_number, v_position_disp = uar_get_code_display(vc.position_cd), vc.view_seq,
  vc.comp_seq
  FROM view_prefs v,
   view_comp_prefs vc
  PLAN (v
   WHERE v.active_ind=1
    AND v.position_cd > 0
    AND v.position_cd=227466524)
   JOIN (vc
   WHERE vc.active_ind=1
    AND v.position_cd=vc.position_cd
    AND vc.view_name="CHARTSUMM")
  ORDER BY v.application_number, v_position_disp, vc.view_seq,
   vc.comp_seq
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
   v_position_disp"#########################", col + 1, vc.position_cd"############",
   col + 1, v.frame_type"#####", col + 1,
   v.view_name"#####", col + 1, vc.view_comp_prefs_id"############",
   col + 1, vc.view_name"############", col + 1,
   vc.comp_name, col + 1, vc.view_seq,
   col + 1, vc.comp_seq, col + 1,
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
  WITH maxrec = 2000, maxcol = 162, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
