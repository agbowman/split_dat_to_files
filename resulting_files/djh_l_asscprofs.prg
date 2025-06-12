CREATE PROGRAM djh_l_asscprofs
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
  pr.active_ind, pr.name_full_formatted, pr.username,
  pr.position_cd, pr_position_disp = uar_get_code_display(pr.position_cd), p.alias,
  p_prsnl_alias_type_disp = uar_get_code_display(p.prsnl_alias_type_cd), p.active_ind, pr
  .active_status_cd,
  pr_active_status_disp = uar_get_code_display(pr.active_status_cd), p.active_status_cd"####",
  p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.active_status_dt_tm, p.active_status_prsnl_id, p.alias_pool_cd,
  p_alias_pool_disp = uar_get_code_display(p.alias_pool_cd), p.end_effective_dt_tm, p.person_id,
  p.prsnl_alias_id, pr.person_id, p.prsnl_alias_type_cd
  FROM prsnl pr,
   prsnl_alias p
  PLAN (pr
   WHERE ((pr.position_cd=966300) OR (pr.position_cd=65699687))
    AND pr.active_status_cd != 189)
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND p.active_status_cd != 189
    AND p.active_status_cd != 192
    AND ((p.prsnl_alias_type_cd=1088) OR (((p.prsnl_alias_type_cd=1085) OR (((p.prsnl_alias_type_cd=
   1084) OR (((p.prsnl_alias_type_cd=1087) OR (p.prsnl_alias_type_cd=1086)) )) )) )) )
  ORDER BY pr.name_full_formatted, p.prsnl_alias_type_cd
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
