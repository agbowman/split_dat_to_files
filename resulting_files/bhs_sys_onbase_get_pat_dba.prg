CREATE PROGRAM bhs_sys_onbase_get_pat:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "person_id" = 0,
  "encntr_id" = 0
  WITH outdev, person_id, encntr_id
 RECORD person(
   1 qual[1]
     2 personname = vc
     2 personid = f8
     2 fin = vc
     2 mrn = vc
     2 location = vc
     2 dob = vc
     2 curuser = vc
 )
 CALL echo(build2("person_id: ",trim(cnvtstring( $PERSON_ID))," encntr_id: ",trim(cnvtstring(
      $ENCNTR_ID))))
 SELECT INTO "nl:"
  FROM person p,
   encntr_alias ea,
   encntr_alias ea2,
   encounter e
  PLAN (e
   WHERE (e.encntr_id= $ENCNTR_ID))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=1077)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.encntr_alias_type_cd=1079)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  HEAD REPORT
   person->qual[1].personname = trim(p.name_full_formatted,3), person->qual[1].fin = trim(ea.alias,3),
   person->qual[1].mrn = trim(ea2.alias,3),
   person->qual[1].location = trim(build(uar_get_code_display(e.loc_facility_cd),"-",
     uar_get_code_display(e.loc_nurse_unit_cd),"-",uar_get_code_display(e.loc_bed_cd))), person->
   qual[1].dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.username
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
   AND p.active_ind=1
   AND p.end_effective_dt_tm > sysdate
  DETAIL
   person->qual[1].curuser = trim(p.username)
  WITH nocounter
 ;end select
 CALL echorecord(person)
 DECLARE jsonrec = vc WITH noconstant(" "), protect
 SET jsonrec = cnvtrectojson(person)
 CALL echo("json")
 CALL echo(jsonrec)
 CALL echo("jsonRec")
 CALL echojson(person)
 CALL echojson(person, $OUTDEV)
END GO
