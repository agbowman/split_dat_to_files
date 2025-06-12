CREATE PROGRAM bhs_rpt_phys_address
 PROMPT
  "Enter Last Name" = "*",
  "Output to File/Printer/MINE" = "MINE"
  WITH prompt2, outdev
 EXECUTE bhs_check_domain:dba
 SET lncnt = 0
 DECLARE ms_temp = vc WITH protect, nocounter(" ")
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp =
  IF (p.position_cd > 0) uar_get_code_display(p.position_cd)
  ELSE "No CIS Position Assigned"
  ENDIF
  , p.end_effective_dt_tm, p.updt_dt_tm,
  p.updt_id, a_address_type_disp = uar_get_code_display(a.address_type_cd), a.street_addr,
  a.city, loginid =
  IF (p.username > " ") p.username
  ELSE "No LogIn ID"
  ENDIF
  FROM prsnl p,
   address a
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_ind=1
    AND p.active_status_cd=188
    AND (cnvtupper(p.name_last)= $PROMPT2))
   JOIN (a
   WHERE p.person_id=a.parent_entity_id
    AND a.active_ind=1
    AND a.address_type_cd=754)
  ORDER BY p.name_full_formatted, p.username
  HEAD PAGE
   col 20, "Physician's Business Mailing Address", "{cpi/12}",
   row + 2, col 1,
   "---------+---------+---------+---------+---------+---------+---------+---------+---------+",
   row + 1
  DETAIL
   lncnt = (lncnt+ 1), col + 5, p.name_full_formatted"##############################",
   col + 5, p_position_disp"################################", row + 1,
   col + 5, a.street_addr"##############################", col + 5,
   loginid"###############", row + 1, col + 5,
   a.street_addr2"##############################", row + 1, col + 5,
   a.street_addr3"##############################", row + 1, col + 5,
   a.street_addr4"##############################", row + 1, col + 5,
   a.city"####################", col + 1, a.state"####################",
   col + 1, a.zipcode"##########", row + 1,
   col 05, "---------+---------+---------+---------+---------+---------+", row + 1
   IF (row > 61)
    BREAK
   ENDIF
  FOOT PAGE
   "{cpi/15}", row + 1, xcol = 72,
   ycol = 740,
   CALL print(calcpos((xcol+ 10),ycol)), curprog,
   CALL print(calcpos((xcol+ 134),ycol)), curdate,
   CALL print(calcpos((xcol+ 190),ycol)),
   curnode
   IF (gl_bhs_prod_flag=1)
    ms_temp = "PROD"
   ELSE
    CASE (curnode)
     OF "cisr":
      ms_temp = "READonly"
     OF "casdtest":
      ms_temp = "BUILD"
     OF "casbtest":
      ms_temp = "CERT"
     ELSE
      ms_temp = "domain?"
    ENDCASE
   ENDIF
   CALL print(calcpos((xcol+ 250),ycol)), ms_temp,
   CALL print(calcpos((xcol+ 320),ycol)),
   "Page:", curpage"{cpi/12}"
  WITH dio = postscript, landscape, maxrow = 70,
   maxcol = 300
 ;end select
END GO
