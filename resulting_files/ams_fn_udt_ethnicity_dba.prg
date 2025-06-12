CREATE PROGRAM ams_fn_udt_ethnicity:dba
 DECLARE cstext = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id))
  DETAIL
   cstext = uar_get_code_display(p.ethnic_grp_cd)
  WITH nocounter
 ;end select
 SET reply->text = trim(cstext,3)
 SET reply->format = 1
END GO
