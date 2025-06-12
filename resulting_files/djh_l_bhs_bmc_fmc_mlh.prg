CREATE PROGRAM djh_l_bhs_bmc_fmc_mlh
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
  p.name_full_formatted, p.name_last, p.active_status_cd,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.position_cd, p_position_disp =
  uar_get_code_display(p.position_cd),
  p.name_last_key, p.beg_effective_dt_tm, p.create_dt_tm
  FROM prsnl p
  WHERE ((p.name_last_key="BHS*") OR (((p.name_last_key="BMC*") OR (((p.name_last_key="FMC*") OR (((p
  .name_last_key="MLH*") OR (p.name_last_key="PONOFF*")) )) )) ))
  ORDER BY p_position_disp
  WITH maxrec = 200, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
