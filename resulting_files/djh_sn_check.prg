CREATE PROGRAM djh_sn_check
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
  p.active_ind, p.username, p.name_full_formatted,
  p.position_cd, p_position_disp = uar_get_code_display(p.position_cd), p.create_prsnl_id,
  p.create_dt_tm, p.updt_id, p.updt_dt_tm,
  p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd), p
  .active_status_dt_tm,
  p.active_status_prsnl_id, p.beg_effective_dt_tm, p.end_effective_dt_tm,
  p.person_id, p.physician_ind, p.physician_status_cd,
  p_physician_status_disp = uar_get_code_display(p.physician_status_cd), p.prsnl_type_cd,
  p_prsnl_type_disp = uar_get_code_display(p.prsnl_type_cd),
  p.updt_cnt, p.updt_task
  FROM prsnl p
  WHERE p.active_ind=1
   AND p.active_status_cd=188
   AND p.username="SN*"
   AND p.position_cd != 777650
   AND p.position_cd != 457
   AND p.position_cd != 1447374
   AND p.position_cd != 722943
   AND p.position_cd != 2399309
   AND p.position_cd != 1571561
   AND p.position_cd != 2399308
   AND p.position_cd != 121891492
   AND p.position_cd != 1447376
   AND p.position_cd != 1447377
  ORDER BY p_position_disp
  WITH maxrec = 1000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
