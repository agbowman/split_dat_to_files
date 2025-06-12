CREATE PROGRAM djh_l_99999999
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.updt_dt_tm,
  p.updt_id
  FROM prsnl p
  WHERE p.updt_id=99999999
  DETAIL
   col 1, p.active_ind, col + 1,
   p.active_status_cd, col + 1, p_active_status_disp,
   col + 1, p.username, col + 1,
   p.name_full_formatted, col + 1, p.updt_dt_tm,
   col + 1, p.updt_id, row + 1
  WITH maxrec = 1000, maxcol = 300, maxrow = 500,
   seperator = " ", format
 ;end select
END GO
