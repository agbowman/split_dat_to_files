CREATE PROGRAM bhs_athn_get_dur_units
 DECLARE where_params = vc WITH noconstant("")
 SET where_params = build("ce.field_value in ", $3)
 SELECT INTO  $1
  code_set = cnvtint(c.code_set), code_value = c.code_value, display = trim(replace(replace(replace(
      replace(replace(c.display,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3),
  display_key = trim(replace(replace(replace(replace(replace(c.display_key,"&","&amp;",0),"<","&lt;",
       0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM code_value c,
   code_value_extension ce
  PLAN (c
   WHERE c.code_set=cnvtint( $2)
    AND c.active_ind=1
    AND c.end_effective_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.code_value=c.code_value
    AND parser(where_params))
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, col + 1, "<DurationUnits>",
   row + 1
  DETAIL
   v4 = build("<","Code",">"), col + 1, v4,
   row + 1, v1 = build("<CodeValue>",cnvtstring(c.code_value),"</CodeValue>"), col + 1,
   v1, row + 1, v2 = build("<Display>",display,"</Display>"),
   col + 1, v2, row + 1,
   v3 = build("<DisplayKey>",display_key,"</DisplayKey>"), col + 1, v3,
   row + 1, v5 = build("</","Code",">"), col + 1,
   v5, row + 1
  FOOT REPORT
   col + 1, "</DurationUnits>", row + 1,
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
