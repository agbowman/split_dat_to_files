CREATE PROGRAM djh_l_phys_ids
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  IF (validate(_separator)=0)
   IF (validate(_separator)=0)
    IF (validate(_separator)=0)
     SET _separator = " "
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.username, p.name_full_formatted, pa.alias,
  pa_alias_pool_disp = uar_get_code_display(pa.alias_pool_cd), pa.active_ind, pa.beg_effective_dt_tm,
  pa.end_effective_dt_tm, p.person_id, p.physician_ind,
  p.position_cd, p_position_disp = uar_get_code_display(p.position_cd), pa.person_id,
  pa.alias_pool_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd), p
  .active_status_cd
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE p.active_ind=1
    AND p.physician_ind=1
    AND p.active_status_cd=188
    AND p.position_cd != 966300
    AND p.position_cd != 65699687
    AND p.position_cd != 966301
    AND p.position_cd != 719555
    AND p.position_cd != 922119
    AND p.position_cd != 909836
    AND p.position_cd != 441
    AND p.username > " "
    AND p.username != "SPND*"
    AND p.username != "TERM*"
    AND p.username != "TRMMSO*"
    AND p.username != "SUS*"
    AND p.username != "FROST*"
    AND p.username != "GRACIE*"
    AND p.username != "DUM*"
    AND p.username != "SI09757*")
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.active_ind=1
    AND pa.alias_pool_cd=719676)
  ORDER BY p_position_disp, p.username, p.name_full_formatted
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
