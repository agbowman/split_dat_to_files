CREATE PROGRAM bhs_athn_get_tagged_text
 RECORD out_rec(
   1 tags[*]
     2 pdoc_tag_entity_id = vc
     2 tag_dt_tm = vc
     2 tag_entity_name = vc
     2 tag_entity_id = vc
     2 event_dt_tm = vc
     2 tagged_text = vc
 )
 DECLARE t_cnt = i4
 SELECT INTO "nl:"
  FROM pdoc_tag pt,
   pdoc_tag_text ptt,
   long_blob lb,
   clinical_event ce
  PLAN (pt
   WHERE (pt.encntr_id= $2)
    AND (pt.tag_user_id= $3)
    AND pt.tag_entity_name="PDOC_TAG_TEXT")
   JOIN (ptt
   WHERE ptt.pdoc_tag_text_id=pt.tag_entity_id)
   JOIN (lb
   WHERE lb.long_blob_id=ptt.long_blob_id)
   JOIN (ce
   WHERE (ce.event_id= Outerjoin(ptt.tag_entity_id))
    AND (ce.valid_until_dt_tm> Outerjoin(sysdate)) )
  ORDER BY pt.tag_dt_tm, pt.pdoc_tag_id
  HEAD pt.pdoc_tag_id
   t_cnt += 1
   IF (mod(t_cnt,100)=1)
    stat = alterlist(out_rec->tags,(t_cnt+ 99))
   ENDIF
   out_rec->tags[t_cnt].pdoc_tag_entity_id = cnvtstring(pt.tag_entity_id), out_rec->tags[t_cnt].
   tag_dt_tm = datetimezoneformat(pt.tag_dt_tm,curtimezonedef,"MM/dd/yyyy HH:mm:ss",curtimezonedef),
   out_rec->tags[t_cnt].tag_entity_name = ptt.tag_entity_name,
   out_rec->tags[t_cnt].tag_entity_id = cnvtstring(ptt.tag_entity_id), out_rec->tags[t_cnt].
   event_dt_tm = datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,"MM/dd/yyyy HH:mm:ss",
    curtimezonedef), out_rec->tags[t_cnt].tagged_text = lb.long_blob
  FOOT REPORT
   stat = alterlist(out_rec->tags,t_cnt)
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
