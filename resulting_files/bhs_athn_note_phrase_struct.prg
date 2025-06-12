CREATE PROGRAM bhs_athn_note_phrase_struct
 DECLARE fkey_id = f8
 DECLARE fkey_name = vc
 DECLARE v4 = vc WITH noconstant("")
 SELECT INTO "nl:"
  np.fkey_id, np.fkey_name
  FROM note_phrase n,
   note_phrase_comp np
  PLAN (n
   WHERE (n.note_phrase_id= $2))
   JOIN (np
   WHERE np.note_phrase_id=n.note_phrase_id)
  HEAD REPORT
   fkey_id = np.fkey_id, fkey_name = trim(np.fkey_name,3)
  WITH nocounter, time = 30
 ;end select
 IF (fkey_name="LONG_BLOB_REFERENCE")
  SELECT INTO  $1
   abb = trim(replace(replace(replace(replace(replace(n.abbreviation,"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), desc = trim(replace(replace(replace(replace(
        replace(n.abb_description,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), n.note_phrase_id,
   ltext = trim(replace(replace(replace(replace(replace(l.long_blob,"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), np_format_disp = uar_get_code_display(np
    .format_cd)
   FROM note_phrase n,
    note_phrase_comp np,
    long_blob_reference l
   PLAN (n
    WHERE (n.note_phrase_id= $2))
    JOIN (np
    WHERE np.note_phrase_id=n.note_phrase_id)
    JOIN (l
    WHERE l.parent_entity_id=np.note_phrase_comp_id
     AND l.parent_entity_name="NOTE_PHRASE_COMP")
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   DETAIL
    col + 1, "<AutoTextPhrase>", row + 1,
    v1 = build("<NotePhraseId>",cnvtint(n.note_phrase_id),"</NotePhraseId>"), col + 1, v1,
    row + 1, v2 = build("<Abbrevation>",trim(abb,3),"</Abbrevation>"), col + 1,
    v2, row + 1, v3 = build("<Description>",trim(desc,3),"</Description>"),
    col + 1, v3, row + 1,
    v4 = build("<LongText>",trim(ltext,3),"</LongText>"), col + 1, v4,
    row + 1, v5 = build("<Format>",np_format_disp,"</Format>"), col + 1,
    v5, row + 1, col + 1,
    "</AutoTextPhrase>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 50000, format = variable, maxrow = 0,
    time = 30
  ;end select
 ENDIF
 IF (fkey_name="CODE_VALUE")
  DECLARE smart_template = vc
  SET modify maxvarlen 10000000
  SELECT INTO "NL:"
   cv.definition
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_value=fkey_id)
   HEAD REPORT
    smart_template = trim(cv.definition)
   WITH nocounter, time = 30
  ;end select
  FREE RECORD request
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[*]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
    1 print_pref = i2
  ) WITH protect
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
  SET request->output_device =  $1
  SET request->script_name = smart_template
  SET stat = alterlist(request->person,1)
  SET request->person_cnt = 1
  SET request->person[1].person_id =  $3
  SET request->visit_cnt = 1
  SET stat = alterlist(request->visit,1)
  SET request->visit[1].encntr_id =  $4
  SET request->prsnl_cnt = 1
  SET stat = alterlist(request->prsnl,1)
  SET request->prsnl[1].prsnl_id =  $6
  EXECUTE dcp_rpt_driver
  CALL echorecord(reply)
  SELECT INTO  $1
   txt = reply->text
   FROM dummyt d
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   DETAIL
    col + 1, "<AutoTextPhrase>", row + 1,
    v1 = build("<NotePhraseId></NotePhraseId>"), col + 1, v1,
    row + 1, v2 = build("<Abbrevation></Abbrevation>"), col + 1,
    v2, row + 1, v3 = build("<Description></Description>"),
    col + 1, v3, row + 1,
    v4 = build("<LongText>",trim(replace(replace(replace(replace(replace(txt,"&","&amp;",0),"<",
          "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</LongText>"), col + 1, v4,
    row + 1, v5 = build("<Format>","RTF","</Format>"), col + 1,
    v5, row + 1, col + 1,
    "</AutoTextPhrase>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 90
  ;end select
 ENDIF
 IF (fkey_name="CLINICAL_NOTE_TEMPLATE")
  SELECT INTO  $1
   blob_data = substring(1,30000,trim(l.long_blob,3))
   FROM long_blob l
   WHERE l.parent_entity_id=fkey_id
    AND l.parent_entity_name="CLINICAL_NOTE_TEMPLATE"
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   DETAIL
    col + 1, "<AutoTextPhrase>", row + 1,
    v1 = build("<NotePhraseId></NotePhraseId>"), col + 1, v1,
    row + 1, v2 = build("<Abbrevation></Abbrevation>"), col + 1,
    v2, row + 1, v3 = build("<Description></Description>"),
    col + 1, v3, row + 1,
    v4 = build("<LongText>",trim(replace(replace(replace(replace(replace(trim(blob_data,3),"&",
           "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</LongText>"),
    col + 1, v4,
    row + 1, v5 = build("<Format>","RTF","</Format>"), col + 1,
    v5, row + 1, col + 1,
    "</AutoTextPhrase>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 90
  ;end select
 ENDIF
END GO
