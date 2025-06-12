CREATE PROGRAM bhs_prax_get_location
 DECLARE where_params = vc WITH noconstant(" ")
 SET where_params = build("l.organization_id = ", $2," and l.location_type_cd in ", $3)
 SELECT INTO  $1
  l.location_cd, l_loc_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(
          l.location_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), l.location_type_cd,
  l_loc_type_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(l
          .location_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), l_loc_type_mean = trim(replace(replace(replace(replace(replace(trim(
         uar_get_code_meaning(l.location_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3)
  FROM location l
  PLAN (l
   WHERE l.active_ind=1
    AND parser(where_params))
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
   v6, row + 1
  FOOT  l.location_cd
   col + 1, "</Location>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>"
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
