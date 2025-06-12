CREATE PROGRAM bbt_get_blood_bank_comment:dba
 IF ((request->no_reply_ind != 1))
  RECORD reply(
    1 name_full_formatted = vc
    1 alias = c20
    1 qual[*]
      2 bb_comment_id = f8
      2 bb_comment = vc
      2 updt_cnt = i4
      2 long_text_id = f8
      2 long_text_updt_cnt = i4
      2 historical_ind = i2
      2 comment_dt_tm = dq8
      2 username = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  RECORD reply(
    1 bb_comment_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD reply_hd(
   1 name_full_formatted = vc
   1 alias = c20
   1 qual[*]
     2 bb_comment_id = f8
     2 bb_comment = vc
     2 updt_cnt = i4
     2 long_text_id = f8
     2 long_text_updt_cnt = i4
     2 historical_ind = i2
     2 comment_dt_tm = dq8
     2 username = vc
   1 bb_comment_ind = i2
 )
 SET reply->status_data.status = "F"
 SET note = 0
 SET count1 = 0
 DECLARE note_cnt = i2 WITH protect, noconstant(0)
 DECLARE active_note_count = i2 WITH protect, noconstant(0)
#begin_main
 SET reply->status_data.status = "I"
 SELECT INTO "nl:"
  per.name_full_formatted, bbc.bb_comment_id, bbc.updt_cnt,
  lt.long_text_id, lt.long_text, lt.updt_cnt,
  bbc.comment_dt_tm, p.username
  FROM person per,
   (dummyt d_bbc  WITH seq = 1),
   blood_bank_comment bbc,
   long_text lt,
   prsnl p
  PLAN (per
   WHERE (per.person_id=request->person_id))
   JOIN (d_bbc
   WHERE d_bbc.seq=1)
   JOIN (bbc
   WHERE bbc.person_id=per.person_id)
   JOIN (lt
   WHERE lt.long_text_id=bbc.long_text_id)
   JOIN (p
   WHERE (p.person_id= Outerjoin(bbc.comment_added_prsnl_id)) )
  ORDER BY bbc.comment_dt_tm DESC, bbc.bb_comment_id DESC
  HEAD REPORT
   note_cnt = 0, active_note_count = 0
   IF ((request->no_reply_ind != 1))
    reply_hd->name_full_formatted = per.name_full_formatted, reply_hd->alias = ""
   ENDIF
  DETAIL
   IF (bbc.seq > 0)
    IF (bbc.active_ind=1
     AND lt.active_ind=1)
     active_note_count += 1
     IF (active_note_count=1)
      IF ((request->no_reply_ind != 1))
       note_cnt += 1, stat = alterlist(reply_hd->qual,note_cnt), reply_hd->qual[note_cnt].
       bb_comment_id = bbc.bb_comment_id,
       reply_hd->qual[note_cnt].updt_cnt = bbc.updt_cnt, reply_hd->qual[note_cnt].long_text_id = lt
       .long_text_id, reply_hd->qual[note_cnt].bb_comment = lt.long_text,
       reply_hd->qual[note_cnt].long_text_updt_cnt = lt.updt_cnt, reply_hd->qual[note_cnt].
       historical_ind = 0, reply_hd->qual[note_cnt].comment_dt_tm = bbc.comment_dt_tm,
       reply_hd->qual[note_cnt].username = p.username
      ELSE
       IF (textlen(trim(lt.long_text)) > 0)
        reply_hd->bb_comment_ind = 1
       ENDIF
      ENDIF
     ELSE
      IF ((request->no_reply_ind=1))
       reply_hd->bb_comment_ind = 0
      ENDIF
     ENDIF
    ELSE
     IF ((request->historical_comment=1))
      note_cnt += 1, stat = alterlist(reply_hd->qual,note_cnt), reply_hd->qual[note_cnt].
      bb_comment_id = bbc.bb_comment_id,
      reply_hd->qual[note_cnt].updt_cnt = bbc.updt_cnt, reply_hd->qual[note_cnt].long_text_id = lt
      .long_text_id, reply_hd->qual[note_cnt].bb_comment = lt.long_text,
      reply_hd->qual[note_cnt].long_text_updt_cnt = lt.updt_cnt, reply_hd->qual[note_cnt].
      historical_ind = 1, reply_hd->qual[note_cnt].comment_dt_tm = bbc.comment_dt_tm,
      reply_hd->qual[note_cnt].username = p.username
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, outerjoin(d_bbc)
 ;end select
 IF ((request->no_reply_ind != 1))
  SET reply->name_full_formatted = reply_hd->name_full_formatted
  SET reply->alias = reply_hd->alias
  SET stat = alterlist(reply->qual,note_cnt)
  FOR (note = 1 TO note_cnt)
    SET reply->qual[note].bb_comment_id = reply_hd->qual[note].bb_comment_id
    SET reply->qual[note].bb_comment = reply_hd->qual[note].bb_comment
    SET reply->qual[note].updt_cnt = reply_hd->qual[note].updt_cnt
    SET reply->qual[note].long_text_id = reply_hd->qual[note].long_text_id
    SET reply->qual[note].long_text_updt_cnt = reply_hd->qual[note].long_text_updt_cnt
    SET reply->qual[note].historical_ind = reply_hd->qual[note].historical_ind
    SET reply->qual[note].comment_dt_tm = reply_hd->qual[note].comment_dt_tm
    SET reply->qual[note].username = reply_hd->qual[note].username
  ENDFOR
 ELSE
  SET reply->bb_comment_ind = reply_hd->bb_comment_ind
 ENDIF
 IF (curqual=0)
  SET count1 += 1
  IF (count1 > size(reply->status_data.subeventstatus,5))
   SET stat = alter(reply->status_data,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get blood_bank_comment"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_blood_bank_comment"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "no notes for person_id"
 ELSE
  IF (active_note_count > 1)
   SET count1 += 1
   IF (count1 > size(reply->status_data.subeventstatus,5))
    SET stat = alter(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "get blood_bank_comment row"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "multiple active blood_bank_comment rows exist for person_id"
  ENDIF
 ENDIF
 GO TO exit_script
#end_main
#exit_script
 IF ((reply->status_data.status != "F"))
  SET count1 += 1
  IF (count1 > size(reply->status_data.subeventstatus,5))
   SET stat = alter(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_blood_bank_comment"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = ""
  IF (active_note_count > 0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationname = "Success"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationname = "Zero"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "No blood_bank_comment rows for person_id"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
  ENDIF
 ENDIF
END GO
