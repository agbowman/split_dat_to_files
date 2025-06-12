CREATE PROGRAM djh_sample_2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT
  p.name_full_formatted, p_position_disp = uar_get_code_display(p.position_cd), p.active_ind,
  p.beg_effective_dt_tm, p.end_effective_dt_tm
  FROM prsnl p
  WHERE p.position_cd=686743.00
  WITH maxrec = 100, nocounter, separator = " ",
   format
 ;end select
END GO
