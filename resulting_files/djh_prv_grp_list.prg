CREATE PROGRAM djh_prv_grp_list
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Provider Group:" = 0
  WITH outdev, prompt2
 SELECT INTO  $OUTDEV
  pr.active_status_cd, pr.physician_ind, pr.name_full_formatted,
  p.active_status_cd, pr.username, pr_position_disp = uar_get_code_display(pr.position_cd),
  p.person_id, p.prsnl_group_id, pr_prsnl_group_id = uar_get_code_display(p.prsnl_group_id),
  p.prsnl_group_reltn_id, p.beg_effective_dt_tm, p.end_effective_dt_tm
  FROM prsnl_group_reltn p,
   prsnl pr
  PLAN (p
   WHERE (p.prsnl_group_id= $PROMPT2))
   JOIN (pr
   WHERE pr.person_id=p.person_id)
  ORDER BY pr.active_status_cd, p.active_status_cd, p.active_ind,
   pr.name_full_formatted
  WITH nocounter, separator = " ", format
 ;end select
END GO
