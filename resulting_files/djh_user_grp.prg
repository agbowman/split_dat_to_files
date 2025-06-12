CREATE PROGRAM djh_user_grp
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  IF (validate(_separator)=0)
   SET _separator = " "
  ENDIF
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.active_ind, p_active_status_disp = uar_get_code_display(p.active_status_cd), p
  .end_effective_dt_tm,
  p_prsnl_group_class_disp = uar_get_code_display(p.prsnl_group_class_cd), p.prsnl_group_class_cd, p
  .prsnl_group_desc,
  p.prsnl_group_id, p.prsnl_group_name
  FROM prsnl_group p
  WHERE p.active_ind=1
   AND p.prsnl_group_class_cd=647082.00
  ORDER BY p.prsnl_group_desc
  WITH maxrec = 1000, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
