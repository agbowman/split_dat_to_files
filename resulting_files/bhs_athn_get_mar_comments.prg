CREATE PROGRAM bhs_athn_get_mar_comments
 DECLARE ocf_comp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE notetype = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14,"RESULTCOMMENT"))
 DECLARE eventid = f8 WITH protect, constant( $2)
 SELECT INTO  $1
  blob_contents = substring(1,32000,l.long_blob), c.event_id, l.long_blob_id,
  res_type = trim(uar_get_code_display(c.note_type_cd),3), importance = trim(replace(replace(replace(
      replace(replace(substring(0,25,
         IF (c.importance_flag=1) "Low Importance"
         ELSEIF (c.importance_flag=2) "Medium Importance"
         ELSEIF (c.importance_flag=4) "High Importance"
         ENDIF
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), c
  .note_prsnl_id,
  notedatetime = datetimezoneformat(c.note_dt_tm,c.note_tz,"MM/dd/yyyy hh:mm ZZZ",curtimezonedef),
  noteperformedby = trim(replace(replace(replace(replace(replace(p.name_full_formatted,"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p.active_ind
  FROM long_blob l,
   clinical_event ce,
   ce_event_note c,
   prsnl p
  PLAN (ce
   WHERE ce.parent_event_id=eventid
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (c
   WHERE c.event_id=ce.event_id
    AND c.valid_from_dt_tm < sysdate
    AND c.valid_until_dt_tm > sysdate)
   JOIN (l
   WHERE l.parent_entity_id=c.ce_event_note_id
    AND l.parent_entity_name="CE_EVENT_NOTE")
   JOIN (p
   WHERE c.note_prsnl_id=p.person_id
    AND p.active_ind=1.00)
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   IF (c.note_type_cd=74.00)
    head_grp = build("<","ResultComment",">")
   ELSE
    head_grp = build("<","Reason",">")
   ENDIF
   col + 1, head_grp, row + 1,
   blob_out = fillstring(32000," "), blob_out1 = fillstring(32000," ")
   IF (c.compression_cd=ocf_comp_cd)
    blob_ret_len = 0,
    CALL uar_ocf_uncompress(blob_contents,32000,blob_out,32000,blob_ret_len), blob_out = trim(replace
     (replace(replace(replace(replace(trim(blob_out,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3)
   ELSE
    blob_out = trim(replace(replace(replace(replace(replace(l.long_blob,"&","&amp;",0),"<","&lt;",0),
        ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
   ENDIF
   bresult = build("<BlobResult>",trim(replace(trim(blob_out,3),"ocf_blob",""),3),"</BlobResult>"),
   col + 1, bresult,
   row + 1, resulttype = build("<ResultType>",res_type,"</ResultType>"), col + 1,
   resulttype, row + 1, v1 = build("<NoteDateTime>",notedatetime,"</NoteDateTime>"),
   col + 1, v1, row + 1,
   v2 = build("<NotePerformedBy>",noteperformedby,"</NotePerformedBy>"), col + 1, v2,
   row + 1, v3 = build("<ImportanceFlag>",importance,"</ImportanceFlag>"), col + 1,
   v3, row + 1
   IF (c.note_type_cd=74.00)
    foot_grp = build("</","ResultComment",">")
   ELSE
    foot_grp = build("</","Reason",">")
   ENDIF
   col + 1, foot_grp, row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 33000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
