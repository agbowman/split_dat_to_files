CREATE PROGRAM djh_handover_test
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE test_vc = vc WITH noconstant(""), protect
 SET lncnt = 0
 SELECT INTO  $OUTDEV
  v.active_ind, v.application_number, v.frame_type,
  v_position_disp = uar_get_code_display(v.position_cd), v.view_name, n.parent_entity_name,
  n.pvc_name, n.pvc_value, v.position_cd,
  v.prsnl_id, v.updt_applctx, v.updt_cnt,
  v.updt_dt_tm, v.updt_id, v.updt_task,
  v.view_prefs_id, v.view_seq, n.active_ind,
  n.merge_id, n.merge_name, n.name_value_prefs_id,
  n.parent_entity_id, n.sequence, n.updt_applctx,
  n.updt_cnt, n.updt_dt_tm, n.updt_id,
  n.updt_task
  FROM view_prefs v,
   name_value_prefs n
  PLAN (v
   WHERE v.active_ind=1
    AND v.application_number=600005
    AND v.position_cd > 0)
   JOIN (n
   WHERE n.active_ind=1
    AND v.view_prefs_id=n.parent_entity_id
    AND n.parent_entity_name="VIEW_PREFS"
    AND n.pvc_name="VIEW_CAPTION"
    AND ((n.pvc_value="Clinical Notes") OR (n.pvc_value="MICRO")) )
  ORDER BY v.position_cd, v_position_disp, n.pvc_value
  HEAD PAGE
   col 1, " ln", col 8,
   "Act", col 12, "Stat",
   col 20, "LogIn", col 67,
   "Person", col 111, "  END Eff",
   col 148, "Change", row + 1,
   col 1, " nbr", col 8,
   "ID", col 12, "Code",
   col 20, " ID", col 34,
   "User Name", col 67, "  ID",
   col 75, "Position Description", col 111,
   "Date / Time", col 129, "Update / Time",
   col 148, "  ID", row + 1,
   col 1, "---------+---------+---------+---------+---------+---------+---------+---------+", col + 0,
   "---------+---------+---------+---------+---------+---------+---------+-------", row + 1
  DETAIL
   lncnt = (lncnt+ 1), col 1, lncnt"####",
   col + 1, v.position_cd, col + 1,
   v_position_disp"##########################", col + 1, n.pvc_name"#################",
   col + 1, n.pvc_value"#################", row + 1
   IF (row > 60)
    BREAK
   ENDIF
   IF (curnode="casDtest")
    xdomain = "BUILD"
   ENDIF
   IF (curnode="casbtest")
    xdomain = "CERT"
   ENDIF
   IF (((curnode="cis1") OR (((curnode="cis3") OR (curnode="cis5")) )) )
    xdomain = "PROD"
   ENDIF
   IF (curnode="cismock1")
    xdomain = "MOCK"
   ENDIF
  FOOT PAGE
   row + 1, col 1, curprog,
   col 70, curdate, col 90,
   curnode, col 100, xdomain,
   col 130, "Page:", curpage
  WITH maxrec = 500, maxcol = 160, maxrow = 66,
   seperator = " ", format
 ;end select
END GO
