CREATE PROGRAM cnt_prsnl_actcd
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
  cntr = count(p.active_status_cd)"#####"
  FROM prsnl p
  WHERE p.active_status_cd != 0
  GROUP BY p.active_ind, p.active_status_cd
  ORDER BY p.active_ind, p.active_status_cd
  HEAD REPORT
   row 1, col 51, "Count PRSNL by Active CIS Position",
   row + 2
  DETAIL
   col 42, p.position_cd, row + 1
  WITH compress, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
