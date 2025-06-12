CREATE PROGRAM bhs_athn_smart_temp_exist_v2
 DECLARE prsnlid = f8 WITH protect, constant( $2)
 DECLARE cnt = i2 WITH noconstant(0)
 FREE RECORD out_rec
 RECORD out_rec(
   1 smart_templates[*]
     2 template_id = vc
     2 template_name = vc
     2 definition = vc
     2 description = vc
     2 smart_template_ind = vc
     2 template_cki = vc
 )
 SELECT DISTINCT INTO "NL:"
  template_name = trim(replace(replace(replace(replace(replace(replace(c.template_name,"–","-",0),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), definition =
  trim(replace(replace(replace(replace(replace(replace(cv.definition,"–","-",0),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), description = trim(replace(replace
    (replace(replace(replace(replace(cv.description,"–","-",0),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  template_cki = trim(replace(replace(replace(replace(replace(replace(cv.cki,"–","-",0),"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), template_id = cnvtstring(c
   .template_id), smart_standard =
  IF (c.smart_template_ind=1) "SMART"
  ELSE "STANDARD"
  ENDIF
  FROM clinical_note_template c,
   code_value cv
  PLAN (c
   WHERE c.template_active_ind=1)
   JOIN (cv
   WHERE cv.code_value=outerjoin(c.smart_template_cd))
  ORDER BY c.template_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(out_rec->smart_templates,cnt), out_rec->smart_templates[cnt].
   template_id = template_id,
   out_rec->smart_templates[cnt].template_name = template_name, out_rec->smart_templates[cnt].
   definition = definition, out_rec->smart_templates[cnt].description = description,
   out_rec->smart_templates[cnt].smart_template_ind = smart_standard, out_rec->smart_templates[cnt].
   template_cki = template_cki
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 32000, format = variable, maxrow = 0,
   time = 30
 ;end select
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
END GO
