CREATE PROGRAM dl_prsnl_group
 PROMPT
  "printer " = "mine"
 SELECT INTO  $1
  p.name_full_formatted, pg.prsnl_group_name
  FROM prsnl p,
   prsnl_group_reltn pgr,
   prsnl_group pg
  PLAN (p
   WHERE p.physician_ind=1)
   JOIN (pgr
   WHERE p.person_id=pgr.person_id)
   JOIN (pg
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id)
  ORDER BY p.name_full_formatted, pg.prsnl_group_name
  DETAIL
   p.name_full_formatted, col 40, pg.prsnl_group_name,
   row + 1
  WITH maxcol = 1300
 ;end select
END GO
