CREATE PROGRAM bhs_prax_get_sticky_note_list
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE per_id = f8 WITH protect, constant(request->person[1].person_id)
 DECLARE enc_id = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE per_name = vc WITH noconstant(" ")
 DECLARE where_params = vc WITH noconstant(" ")
 DECLARE v2 = vc WITH noconstant(" ")
 SET where_params = build(" (S.PARENT_ENTITY_NAME = 'PERSON' AND S.PARENT_ENTITY_ID = ",per_id,")")
 IF (enc_id != 0)
  SET where_params = build(" (S.PARENT_ENTITY_NAME = 'ENCOUNTER' AND S.PARENT_ENTITY_ID = ",enc_id,
   ") OR ",where_params)
 ENDIF
 SELECT INTO "NL:"
  p.name_full_formatted
  FROM person p
  WHERE p.person_id=per_id
  HEAD REPORT
   per_name = p.name_full_formatted
  WITH time = 10
 ;end select
 SELECT INTO value(moutputdevice)
  s.sticky_note_id, s.long_text_id, s.parent_entity_id,
  s.parent_entity_name, s_sticky_note_text = trim(replace(replace(replace(replace(replace(s
        .sticky_note_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), l.long_text_id,
  l_long_text = substring(1,2000,trim(replace(replace(replace(replace(replace(l.long_text,"&","&amp;",
         0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)), s_public_ind =
  IF (s.public_ind=1) "true"
  ELSE "false"
  ENDIF
  , s_sticky_note_type_disp = uar_get_code_display(s.sticky_note_type_cd),
  s_sticky_note_status_disp = uar_get_code_display(s.sticky_note_status_cd), s.updt_id, prsnl_name =
  trim(replace(replace(replace(replace(replace(p.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  s_updt_dt_tm = format(s.updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), s.updt_task, s.updt_applctx,
  s.end_effective_dt_tm
  FROM sticky_note s,
   long_text l,
   prsnl p
  PLAN (s
   WHERE parser(where_params))
   JOIN (l
   WHERE l.long_text_id=s.long_text_id)
   JOIN (p
   WHERE p.person_id=s.updt_id)
  ORDER BY s.updt_dt_tm DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, perid = build("<PersonId>",cnvtint(per_id),"</PersonId>"), col + 1,
   perid, row + 1, pername = build("<PersonName>",per_name,"</PersonName>"),
   col + 1, pername, row + 1,
   encid = build("<EncounterId>",cnvtint(enc_id),"</EncounterId>"), col + 1, encid,
   row + 1, col + 1, "<StickyNotes>",
   row + 1
  HEAD s.sticky_note_id
   col + 1, "<StickyNote>", row + 1,
   v1 = build("<StickyNoteId>",cnvtint(s.sticky_note_id),"</StickyNoteId>"), col + 1, v1,
   row + 1, v21 = build("<LongTextId>",cnvtint(l.long_text_id),"</LongTextId>"), col + 1,
   v21, row + 1
   IF (l.long_text_id=0)
    v2 = build("<Text>",s_sticky_note_text,"</Text>")
   ELSE
    v21 = build("<LongTextId>",cnvtint(l.long_text_id),"</LongTextId>"), col + 1, v21,
    row + 1, v2 = build("<Text>",l_long_text,"</Text>")
   ENDIF
   col + 1, v2, row + 1,
   v3 = build("<PublicNote>",s_public_ind,"</PublicNote>"), col + 1, v3,
   row + 1, v4 = build("<Type>",s_sticky_note_type_disp,"</Type>"), col + 1,
   v4, row + 1, v5 = build("<Status>",s_sticky_note_status_disp,"</Status>"),
   col + 1, v5, row + 1,
   v6 = build("<UpdatedByPrsnlId>",cnvtint(s.updt_id),"</UpdatedByPrsnlId>"), col + 1, v6,
   row + 1, v7 = build("<UpdatedByPrsnlName>",prsnl_name,"</UpdatedByPrsnlName>"), col + 1,
   v7, row + 1, v8 = build("<UpdatedDateTime>",s_updt_dt_tm,"</UpdatedDateTime>"),
   col + 1, v8, row + 1,
   col + 1, "</StickyNote>", row + 1
  FOOT REPORT
   col + 1, "</StickyNotes>", row + 1,
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, formfeed = none, format = variable,
   nullreport, maxcol = 32000, maxrow = 0,
   time = 60
 ;end select
END GO
