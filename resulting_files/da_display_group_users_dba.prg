CREATE PROGRAM da_display_group_users:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Group" = 0
  WITH outdev, groupcd
 SELECT INTO  $OUTDEV
  d_group_cdf = uar_get_code_meaning(d.group_cd), d_group_disp = uar_get_code_display(d.group_cd), p
  .name_full_formatted
  FROM da_group_user_reltn d,
   prsnl p
  PLAN (d
   WHERE (d.group_cd= $GROUPCD)
    AND d.prsnl_id > 0)
   JOIN (p
   WHERE d.prsnl_id=p.person_id)
  ORDER BY d_group_cdf, d_group_disp, p.name_full_formatted
  WITH nocounter, separator = " ", format
 ;end select
END GO
