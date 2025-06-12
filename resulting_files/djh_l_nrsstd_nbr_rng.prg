CREATE PROGRAM djh_l_nrsstd_nbr_rng
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd)
  FROM prsnl p
  WHERE p.username >= "SN50000*"
   AND p.username <= "SN51999*"
  ORDER BY p.username
  DETAIL
   p_active_status_disp1 = substring(1,8,p_active_status_disp), username1 = substring(1,15,p.username
    ), name_full_formatted1 = substring(1,35,p.name_full_formatted),
   col 2, p.active_ind, col 5,
   p.active_status_cd, col 9, p_active_status_disp1,
   col 18, username1, col 34,
   name_full_formatted1, row + 1
  WITH maxcol = 300, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
