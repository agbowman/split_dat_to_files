CREATE PROGRAM bhs_athn_get_location_v2
 DECLARE where_params = vc WITH noconstant(" ")
 DECLARE where_params1 = vc WITH noconstant(" ")
 DECLARE active_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE facility_location_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,
   "FACILITY"))
 DECLARE fetch_facility_name = i2 WITH noconstant(0)
 IF (( $2=0))
  SET where_params = build("l.location_type_cd in ", $3)
  IF (( $4 != 2))
   SET where_params1 = build("l.patcare_node_ind = ", $4)
  ELSE
   SET where_params1 = build("1=1")
   SET fetch_facility_name = 1
  ENDIF
 ELSE
  SET where_params = build("l.organization_id = ", $2," and l.location_type_cd in ", $3)
  SET where_params1 = build("1=1")
 ENDIF
 IF (fetch_facility_name=0)
  SELECT INTO  $1
   l.location_cd, l_loc_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display
          (l.location_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3), l.location_type_cd,
   l_loc_type_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(l
           .location_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), l_loc_type_mean = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_meaning(l.location_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3)
   FROM location l
   PLAN (l
    WHERE l.active_ind=1
     AND l.data_status_cd=25
     AND l.active_status_cd=active_status_cd
     AND parser(where_params)
     AND parser(where_params1))
   ORDER BY uar_get_code_display(l.location_cd)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   HEAD l.location_cd
    col + 1, "<Location>", row + 1,
    v1 = build("<LocationCD>",cnvtint(l.location_cd),"</LocationCD>"), col + 1, v1,
    row + 1, v3 = build("<LocationDisplay>",l_loc_disp,"</LocationDisplay>"), col + 1,
    v3, row + 1, v4 = build("<LocationTypeCD>",cnvtint(l.location_type_cd),"</LocationTypeCD>"),
    col + 1, v4, row + 1,
    v5 = build("<LocationTypeDisplay>",l_loc_type_disp,"</LocationTypeDisplay>"), col + 1, v5,
    row + 1, v6 = build("<LocationTypeMeaning>",l_loc_type_mean,"</LocationTypeMeaning>"), col + 1,
    v6, row + 1, v7 = build("<OrganizationId>",cnvtstring(l.organization_id),"</OrganizationId>"),
    col + 1, v7, row + 1,
    v8 = build("<PatientCareIndicator>",l.patcare_node_ind,"</PatientCareIndicator>"), col + 1, v8,
    row + 1
   FOOT  l.location_cd
    col + 1, "</Location>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>"
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 30
  ;end select
 ELSE
  SELECT INTO  $1
   l.location_cd, l_loc_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display
          (l.location_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3), l.location_type_cd,
   l_loc_type_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(l
           .location_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), l_loc_type_mean = trim(replace(replace(replace(replace(replace(trim(
          uar_get_code_meaning(l.location_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), lf_loc_disp = trim(replace(replace(replace(replace(replace(trim
         (uar_get_code_display(lf.location_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3)
   FROM location l,
    location lf
   PLAN (l
    WHERE l.active_ind=1
     AND l.data_status_cd=25
     AND l.active_status_cd=active_status_cd
     AND parser(where_params)
     AND parser(where_params1))
    JOIN (lf
    WHERE lf.organization_id=l.organization_id
     AND lf.active_ind=1
     AND lf.data_status_cd=25
     AND lf.active_status_cd=active_status_cd
     AND lf.location_type_cd IN (facility_location_type_cd))
   ORDER BY uar_get_code_display(l.location_cd)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   HEAD l.location_cd
    col + 1, "<Location>", row + 1,
    v1 = build("<LocationCD>",cnvtint(l.location_cd),"</LocationCD>"), col + 1, v1,
    row + 1, v3 = build("<LocationDisplay>",l_loc_disp,"</LocationDisplay>"), col + 1,
    v3, row + 1, v4 = build("<LocationTypeCD>",cnvtint(l.location_type_cd),"</LocationTypeCD>"),
    col + 1, v4, row + 1,
    v5 = build("<LocationTypeDisplay>",l_loc_type_disp,"</LocationTypeDisplay>"), col + 1, v5,
    row + 1, v6 = build("<LocationTypeMeaning>",l_loc_type_mean,"</LocationTypeMeaning>"), col + 1,
    v6, row + 1, v7 = build("<OrganizationId>",cnvtstring(l.organization_id),"</OrganizationId>"),
    col + 1, v7, row + 1,
    v8 = build("<PatientCareIndicator>",l.patcare_node_ind,"</PatientCareIndicator>"), col + 1, v8,
    row + 1, v9 = build("<LocationFacilityId>",cnvtint(lf.location_cd),"</LocationFacilityId>"), col
     + 1,
    v9, row + 1, v10 = build("<LocationFacilityDisplay>",lf_loc_disp,"</LocationFacilityDisplay>"),
    col + 1, v10, row + 1
   FOOT  l.location_cd
    col + 1, "</Location>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>"
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 30
  ;end select
 ENDIF
END GO
