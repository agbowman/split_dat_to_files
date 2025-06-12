CREATE PROGRAM da_display_grp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Last Name" = "A",
  "Person Last Name" = 0
  WITH outdev, searchstring, pname
 RECORD temprpt(
   1 person_id = f8
   1 name_full_formatted = vc
   1 hassec = f8
   1 possecd = vc
   1 negsecd = vc
   1 possec_cd = f8
   1 negsec_cd = f8
   1 rowcnt = f8
   1 sec_typ = vc
   1 item_name = vc
 )
 SET person_id =  $PNAME
 SELECT INTO  $OUTDEV
  p.name_full_formatted, gur.prsnl_id, code_value = gur.group_cd,
  cdf_meaning = uar_get_code_meaning(gur.group_cd), code_display = uar_get_code_display(gur.group_cd)
  FROM da_group_user_reltn gur,
   person p
  PLAN (gur
   WHERE gur.prsnl_id=person_id)
   JOIN (p
   WHERE p.person_id=gur.prsnl_id)
  ORDER BY cdf_meaning, code_display
  WITH nocounter, separator = " ", format
 ;end select
END GO
