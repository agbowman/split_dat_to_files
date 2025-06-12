CREATE PROGRAM dmd_prompts_sort_q
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Enter Order ID " = 10000
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  p.name_full_formatted, p.person_id, p.department_cd,
  department_disp = uar_get_code_display(p.department_cd), position_disp = uar_get_code_display(p
   .position_cd), p.updt_dt_tm"DD-MMM-YYYY  HH:MM:SS;;D",
  catalog_disp = uar_get_code_display(o.catalog_cd), o.dept_display_name, o.description,
  orde.person_id, orde.order_id, catalog_disp = uar_get_code_display(orde.catalog_cd),
  o.catalog_cd, expr1 = substring(1,50,p.name_full_formatted)
  FROM prsnl p,
   order_catalog o,
   orders orde
  PLAN (p)
   JOIN (orde
   WHERE orde.person_id=p.person_id
    AND (orde.order_id >  $2))
   JOIN (o
   WHERE o.catalog_cd=orde.catalog_cd)
  ORDER BY p.name_full_formatted DESC, orde.order_id DESC
  WITH format, maxrec = 100, maxcol = 500,
   time = value(maxsecs), landscape
 ;end select
END GO
