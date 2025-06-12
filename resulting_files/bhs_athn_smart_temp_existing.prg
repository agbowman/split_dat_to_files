CREATE PROGRAM bhs_athn_smart_temp_existing
 SET file_name = request->output_device
 DECLARE pid = f8 WITH protect, constant(request->person[1].person_id)
 SELECT DISTINCT INTO value(file_name)
  template_name = trim(replace(replace(replace(replace(replace(c.template_name,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), definition = trim(replace(replace(
     replace(replace(replace(cv.definition,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3), description = trim(replace(replace(replace(replace(replace(cv.description,"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  template_cki = trim(replace(replace(replace(replace(replace(cv.cki,"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), template_id = cnvtint(c.template_id),
  smart_standard =
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
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   col 1, "<SmartTemplates>", row + 1,
   v1 = build("<TemplateId>",template_id,"</TemplateId>"), col + 1, v1,
   row + 1, v2 = build("<TemplateName>",template_name,"</TemplateName>"), col + 1,
   v2, row + 1, v3 = build("<Definition>",definition,"</Definition>"),
   col + 1, v3, row + 1,
   v4 = build("<Description>",description,"</Description>"), col + 1, v4,
   row + 1, v5 = build("<Smart_Standard>",smart_standard,"</Smart_Standard>"), col + 1,
   v5, row + 1, v6 = build("<TemplateCKI>",template_cki,"</TemplateCKI>"),
   col + 1, v6, row + 1,
   col 1, "</SmartTemplates>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 32000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
