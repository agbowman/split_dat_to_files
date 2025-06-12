CREATE PROGRAM dcp_get_sticky_notes:dba
 RECORD reply(
   1 qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 sticky_note_type_cd = f8
     2 sticky_notelist[*]
       3 sticky_note_id = f8
       3 sticky_note_text = vc
       3 updt_id = f8
       3 updt_name = vc
       3 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET qual_cnt = size(request->qual,5)
 SET qual_cnt1 = 0
 SET note_cnt = 0
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  sn.sticky_note_id
  FROM (dummyt d  WITH seq = value(qual_cnt)),
   sticky_note sn,
   (dummyt d1  WITH seq = 1),
   long_text lt,
   prsnl p
  PLAN (d)
   JOIN (sn
   WHERE (sn.sticky_note_type_cd=request->qual[d.seq].sticky_note_type_cd)
    AND (sn.parent_entity_id=request->qual[d.seq].parent_entity_id)
    AND sn.beg_effective_dt_tm <= cnvtdatetime(request->end_effective_dt_tm)
    AND sn.end_effective_dt_tm > cnvtdatetime(request->beg_effective_dt_tm)
    AND sn.parent_entity_id != 0)
   JOIN (d1)
   JOIN (lt
   WHERE lt.long_text_id=sn.long_text_id)
   JOIN (p
   WHERE p.person_id=sn.updt_id)
  ORDER BY sn.parent_entity_id
  HEAD sn.parent_entity_id
   qual_cnt1 = (qual_cnt1+ 1)
   IF (qual_cnt1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(qual_cnt1+ 5))
   ENDIF
   reply->qual[qual_cnt1].parent_entity_id = sn.parent_entity_id, reply->qual[qual_cnt1].
   parent_entity_name = sn.parent_entity_name, reply->qual[qual_cnt1].sticky_note_type_cd = sn
   .sticky_note_type_cd,
   note_cnt = 0
  DETAIL
   note_cnt = (note_cnt+ 1)
   IF (note_cnt > size(reply->qual[qual_cnt1].sticky_notelist,5))
    stat = alterlist(reply->qual[qual_cnt1].sticky_notelist,(note_cnt+ 5))
   ENDIF
   IF (sn.long_text_id > 0)
    reply->qual[qual_cnt1].sticky_notelist[note_cnt].sticky_note_text = lt.long_text
   ELSE
    reply->qual[qual_cnt1].sticky_notelist[note_cnt].sticky_note_text = sn.sticky_note_text
   ENDIF
   CALL echo(build("long text:",sn.sticky_note_text)), reply->qual[qual_cnt1].sticky_notelist[
   note_cnt].updt_id = sn.updt_id, reply->qual[qual_cnt1].sticky_notelist[note_cnt].updt_name = p
   .name_full_formatted,
   reply->qual[qual_cnt1].sticky_notelist[note_cnt].updt_dt_tm = sn.updt_dt_tm, reply->qual[qual_cnt1
   ].sticky_notelist[note_cnt].sticky_note_id = sn.sticky_note_id
  FOOT  sn.parent_entity_id
   stat = alterlist(reply->qual[qual_cnt1].sticky_notelist,note_cnt)
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ENDIF
 SET stat = alterlist(reply->qual,qual_cnt1)
 CALL echorecord(reply)
END GO
