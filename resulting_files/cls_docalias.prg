CREATE PROGRAM cls_docalias
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  p_prsnl_alias_type_disp = uar_get_code_display(p.prsnl_alias_type_cd), p.active_ind, p.alias,
  p.beg_effective_dt_tm, p.end_effective_dt_tm, pr.name_full_formatted
  FROM prsnl_alias p,
   prsnl pr
  PLAN (p
   WHERE p.prsnl_alias_type_cd=1088)
   JOIN (pr
   WHERE pr.person_id=p.person_id)
  ORDER BY p.alias
 ;end select
END GO
