CREATE PROGRAM djh_c_psrnl_by_pos
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
 SELECT DISTINCT INTO  $OUTDEV
  p.name_full_formatted, p_position_disp = uar_get_code_display(p.position_cd), p.position_cd,
  p.active_ind, p.end_effective_dt_tm
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.username > " "
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  ORDER BY p_position_disp
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
