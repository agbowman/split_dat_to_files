CREATE PROGRAM djh_phys_alias_list
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
  p.active_ind, p.username, p.name_full_formatted,
  p_position_disp = uar_get_code_display(p.position_cd), pa.alias, pa_alias_pool_disp =
  uar_get_code_display(pa.alias_pool_cd),
  pa.active_ind, pa.beg_effective_dt_tm, pa.end_effective_dt_tm,
  p.person_id, p.physician_ind, p.position_cd,
  pa.person_id, pa.alias_pool_cd
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE p.active_ind >= 0
    AND p.physician_ind=1)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.active_ind >= 0
    AND pa.alias_pool_cd=719676)
  ORDER BY p.name_full_formatted, p.username
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
