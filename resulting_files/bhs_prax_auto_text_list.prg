CREATE PROGRAM bhs_prax_auto_text_list
 DECLARE mprsnlid = f8 WITH protect, constant(request->prsnl[1].prsnl_id)
 SET file_name = request->output_device
 SELECT INTO value(file_name)
  n_abbreviation = trim(replace(replace(replace(replace(replace(trim(n.abbreviation,3),"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n_abb_description = trim(
   replace(replace(replace(replace(replace(trim(n.abb_description,3),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n.note_phrase_id,
  n.prsnl_id, np.fkey_id, np_fkey_name = trim(replace(replace(replace(replace(replace(trim(np
         .fkey_name,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  cv_definition = trim(replace(replace(replace(replace(replace(trim(cv.definition,3),"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), format_disp =
  uar_get_code_display(np.format_cd)
  FROM note_phrase n,
   note_phrase_comp np,
   code_value cv
  PLAN (n
   WHERE n.note_phrase_id != 0.0
    AND ((n.prsnl_id=0) OR (n.prsnl_id=mprsnlid)) )
   JOIN (np
   WHERE np.note_phrase_id=n.note_phrase_id)
   JOIN (cv
   WHERE cv.code_value=outerjoin(np.fkey_id))
  ORDER BY n.note_phrase_id, np.format_cd
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD n.note_phrase_id
   col 1, "<AutoText>", row + 1,
   v1 = build("<NOTE_PHRASE_ID>",cnvtint(n.note_phrase_id),"</NOTE_PHRASE_ID>"), col + 1, v1,
   row + 1, v2 = build("<PRSNL_ID>",cnvtint(n.prsnl_id),"</PRSNL_ID>"), col + 1,
   v2, row + 1, v3 = build("<ABBREVIATION>",n_abbreviation,"</ABBREVIATION>"),
   col + 1, v3, row + 1,
   v4 = build("<DESCRIPTION>",n_abb_description,"</DESCRIPTION>"), col + 1, v4,
   row + 1, v5 = build("<FKEY_ID>",cnvtint(np.fkey_id),"</FKEY_ID>"), col + 1,
   v5, row + 1, v51 = build("<FKEY_NAME>",np_fkey_name,"</FKEY_NAME>"),
   col + 1, v51, row + 1,
   v6 = build("<SMART_TEMPLATE>",cv_definition,"</SMART_TEMPLATE>"), col + 1, v6,
   row + 1, v7 = build("<FORMAT>",format_disp,"</FORMAT>"), col + 1,
   v7, row + 1, col 1,
   "</AutoText>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 32000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
