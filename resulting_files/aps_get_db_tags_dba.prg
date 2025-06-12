CREATE PROGRAM aps_get_db_tags:dba
 RECORD reply(
   1 tag_qual[1]
     2 tag_cd = f8
     2 tag_display = c7
     2 tag_sequence = i4
     2 active_ind = i2
     2 updt_cnt = i2
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
 SET failed = "F"
 SET tag_cnt = 0
 SELECT INTO "nl:"
  t.tag_group_id, t.tag_disp, t.tag_sequence,
  t.updt_cnt
  FROM ap_tag t
  PLAN (t
   WHERE (request->tag_group_cd=t.tag_group_id)
    AND 1=t.active_ind)
  DETAIL
   tag_cnt = (tag_cnt+ 1)
   IF (tag_cnt > 1)
    stat = alter(reply->tag_qual,tag_cnt)
   ENDIF
   reply->tag_qual[tag_cnt].tag_cd = t.tag_id, reply->tag_qual[tag_cnt].tag_display = t.tag_disp,
   reply->tag_qual[tag_cnt].tag_sequence = t.tag_sequence,
   reply->tag_qual[tag_cnt].active_ind = t.active_ind, reply->tag_qual[tag_cnt].updt_cnt = t.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "TAG_FOUNDATION"
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
END GO
