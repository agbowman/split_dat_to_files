CREATE PROGRAM cv_utl_get_form_id:dba
 PROMPT
  "Output:" = mine,
  "Last Name(*)" = "*",
  "First Name(*)" = "*",
  "Form Name(STS)" = "STS c*",
  "Number of Forms(5):" = 5,
  "After(01-jan-2000):" = "01-jan-2000"
 DECLARE var1 = vc
 DECLARE var2 = vc
 DECLARE var3 = vc
 SET var1 = build("*",cnvtupper( $2),"*")
 SET var2 = build("*",cnvtupper( $3),"*")
 SET var3 = build("*",cnvtupper( $4),"*")
 SELECT INTO  $1
  parentid = dfac.parent_entity_id, chartdate = dfa.form_dt_tm, fullname = p.name_full_formatted,
  desc = dfr.description
  FROM person p,
   dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac
  PLAN (p
   WHERE p.name_last_key=patstring(var1)
    AND p.name_first_key=patstring(var2))
   JOIN (dfr
   WHERE trim(cnvtupper(dfr.description))=patstring(var3)
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE dfa.person_id=p.person_id
    AND dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.form_dt_tm > cnvtdatetime( $6))
   JOIN (dfac
   WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id)
  WITH maxrec = value( $5), nocounter, maxcol = 10000,
   format = variable, maxrow = 1, noformfeed
 ;end select
END GO
