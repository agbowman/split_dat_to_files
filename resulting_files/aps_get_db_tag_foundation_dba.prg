CREATE PROGRAM aps_get_db_tag_foundation:dba
 RECORD reply(
   1 tag_group_cnt = i2
   1 tag_group_qual[1]
     2 tag_group_cd = f8
     2 tag_desc = vc
     2 updt_cnt = i2
     2 tag_pass_cnt = i4
     2 tag_total_cnt = i4
     2 tag_qual[1]
       3 tag_cd = f8
       3 tag_display = c7
       3 tag_sequence = i4
       3 updt_cnt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationstatus = c1
       3 operationname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET tag_group_cnt = 0
 SET tag_pass_cnt = 0
 SET tag_total_cnt = 0
 SELECT INTO "nl:"
  tg.tag_group_id, tg.description, tg.updt_cnt,
  t.tag_group_id, t.tag_display, t.tag_sequence,
  t.updt_cnt
  FROM tag_group_foundation tg,
   tag_foundation t
  PLAN (tg)
   JOIN (t
   WHERE tg.tag_group_id=t.tag_group_id)
  ORDER BY tg.tag_group_id, t.tag_sequence
  HEAD REPORT
   tag_group_cnt = 0, max_tag_cnt = 0
  HEAD tg.tag_group_id
   tag_pass_cnt = 0, tag_total_cnt = 0, tag_group_cnt = (tag_group_cnt+ 1)
   IF (tag_group_cnt > 1)
    stat = alter(reply->tag_group_qual,tag_group_cnt)
   ENDIF
   reply->tag_group_qual[tag_group_cnt].tag_group_cd = tg.tag_group_id, reply->tag_group_qual[
   tag_group_cnt].tag_desc = tg.description, reply->tag_group_qual[tag_group_cnt].updt_cnt = tg
   .updt_cnt,
   reply->tag_group_cnt = tag_group_cnt
  DETAIL
   tag_total_cnt = (tag_total_cnt+ 1), tag_pass_cnt = (tag_pass_cnt+ 1)
   IF (tag_pass_cnt > max_tag_cnt)
    stat = alter(reply->tag_group_qual.tag_qual,tag_pass_cnt), max_tag_cnt = tag_pass_cnt
   ENDIF
   reply->tag_group_qual[tag_group_cnt].tag_qual[tag_pass_cnt].tag_display = t.tag_display, reply->
   tag_group_qual[tag_group_cnt].tag_qual[tag_pass_cnt].tag_sequence = t.tag_sequence, reply->
   tag_group_qual[tag_group_cnt].tag_qual[tag_pass_cnt].updt_cnt = t.updt_cnt,
   reply->tag_group_qual[tag_group_cnt].tag_pass_cnt = tag_pass_cnt, reply->tag_group_qual[
   tag_group_cnt].tag_total_cnt = tag_total_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "TAG_FOUNDATION"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
