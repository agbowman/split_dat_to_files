CREATE PROGRAM djh_l_assocprofs
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
  p.active_ind, p.active_status_cd"####", p_active_status_disp = uar_get_code_display(p
   .active_status_cd),
  p.active_status_dt_tm, p.active_status_prsnl_id, p.alias,
  p.alias_pool_cd, p_alias_pool_disp = uar_get_code_display(p.alias_pool_cd), p.end_effective_dt_tm,
  p.person_id, p.prsnl_alias_id, p.prsnl_alias_type_cd,
  p_prsnl_alias_type_disp = uar_get_code_display(p.prsnl_alias_type_cd), pr.person_id, pr.username,
  pr.name_full_formatted, pr.position_cd, pr_position_disp = uar_get_code_display(pr.position_cd)
  FROM prsnl_alias p,
   prsnl pr
  PLAN (p
   WHERE p.alias_pool_cd=719676
    AND p.prsnl_alias_type_cd=1088)
   JOIN (pr
   WHERE p.person_id=pr.person_id)
  ORDER BY p.alias
  WITH maxrec = 5, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
