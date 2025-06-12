CREATE PROGRAM cls_ibalias_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter the Start Date (MMDDYYYY): " = "08012004",
  "Enter the End Date (MMDDYYYY) :" = "08112004"
  WITH outdev, startdt, enddt
 SET printer =  $1
 SET startdate = cnvtdate( $2)
 SET enddate = cnvtdate( $3)
 SELECT INTO  $OUTDEV
  p.person_id, name = substring(1,20,p.name_full_formatted), moddate = format(c.updt_dt_tm,
   "MM/DD/YYYY HH:MM;;D"),
  c.code_set, c.code_value, c_contributor_source_disp = uar_get_code_display(c.contributor_source_cd),
  ibalias = substring(1,60,c.alias), cv1.display
  FROM code_value_alias c,
   prsnl p,
   code_value cv1
  PLAN (c
   WHERE c.updt_dt_tm BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(enddate,2359))
   JOIN (p
   WHERE c.updt_id=p.person_id
    AND p.active_ind=1)
   JOIN (cv1
   WHERE c.code_value=cv1.code_value
    AND cv1.active_ind=1)
  ORDER BY moddate, c.code_set, cv1.display,
   name
  HEAD REPORT
   col 5, "Person ID", col 18,
   "Name", col 41, "Mod Date/Tm",
   col 63, "Code Set", col 75,
   "Code Value", col 88, "Contributor Source",
   col 130, "Inbound Alias", col 194,
   "Display", row + 1
  DETAIL
   col 1, p.person_id, col 18,
   name, col 41, moddate,
   col 60, c.code_set, col 72,
   c.code_value, col 88, c_contributor_source_disp,
   col 130, ibalias, col 194,
   cv1.display, row + 1
  FOOT REPORT
   col + 0
  WITH maxcol = 300, maxrow = 5000
 ;end select
END GO
