CREATE PROGRAM djh_l_dea_nbrs
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
  pr.active_ind, pr.active_status_cd, pr_active_status_disp = uar_get_code_display(pr
   .active_status_cd),
  pr.username, pr.name_full_formatted, pr.person_id,
  pr.position_cd, pr_position_disp = uar_get_code_display(pr.position_cd), p.active_ind,
  p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd), p
  .active_status_dt_tm,
  p.active_status_prsnl_id, p.alias, p.alias_pool_cd,
  p_alias_pool_disp = uar_get_code_display(p.alias_pool_cd), p.beg_effective_dt_tm, p
  .end_effective_dt_tm,
  p.person_id, p.prsnl_alias_id, p.prsnl_alias_type_cd,
  p_prsnl_alias_type_disp = uar_get_code_display(p.prsnl_alias_type_cd)
  FROM prsnl pr,
   prsnl_alias p
  PLAN (pr
   WHERE pr.active_ind=1
    AND ((pr.position_cd=925825) OR (pr.position_cd=966300))
    AND pr.username != "DUM*")
   JOIN (p
   WHERE pr.person_id=p.person_id
    AND p.alias_pool_cd=674620
    AND p.active_ind=1)
  ORDER BY pr_position_disp, pr.name_full_formatted
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
