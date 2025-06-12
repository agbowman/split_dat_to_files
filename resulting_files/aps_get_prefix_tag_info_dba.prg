CREATE PROGRAM aps_get_prefix_tag_info:dba
 IF ((request->execute_ind=0))
  RECORD reply(
    1 tag_info_qual[*]
      2 tag_group_cnt = i2
      2 tag_group_qual[*]
        3 tag_type_flag = i2
        3 tag_separator = c1
        3 tag_group_cd = f8
        3 primary_ind = i2
        3 tag_cnt = i2
        3 tag_qual[*]
          4 tag_cd = f8
          4 tag_display = c7
          4 tag_sequence = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
#script
 SET current_time = curtime3
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET tag_defined = "F"
 SET tag_where = fillstring(500," ")
 IF ((request->tag_type_bitmap=0))
  SET tag_where = "0 = 0"
 ELSE
  SET tag_where = "tg.tag_type_flag IN ("
  IF (band(request->tag_type_bitmap,1)=1)
   SET tag_defined = "T"
   SET tag_where = concat(trim(tag_where),"1")
  ENDIF
  IF (band(request->tag_type_bitmap,2)=2)
   IF (tag_defined="F")
    SET tag_defined = "T"
    SET tag_where = concat(trim(tag_where),"2")
   ELSE
    SET tag_where = concat(trim(tag_where),",2")
   ENDIF
  ENDIF
  IF (band(request->tag_type_bitmap,4)=4)
   IF (tag_defined="F")
    SET tag_defined = "T"
    SET tag_where = concat(trim(tag_where),"3")
   ELSE
    SET tag_where = concat(trim(tag_where),",3")
   ENDIF
  ENDIF
  IF (tag_defined="F")
   SET tag_where = "0 = 0"
  ELSE
   SET tag_where = concat(trim(tag_where),")")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  tg.tag_group_id, tg.tag_type_flag, t.tag_id
  FROM ap_prefix_tag_group_r tg,
   ap_tag t
  PLAN (tg
   WHERE (request->prefix_cd=tg.prefix_id)
    AND parser(trim(tag_where)))
   JOIN (t
   WHERE tg.tag_group_id=t.tag_group_id
    AND t.active_ind=1)
  ORDER BY tg.tag_type_flag, tg.tag_group_id
  HEAD REPORT
   tag_group_cnt = 0, stat = alterlist(reply->tag_info_qual,1), stat = alterlist(reply->
    tag_info_qual[1].tag_group_qual,1)
  HEAD tg.tag_type_flag
   tag_group_cnt = tag_group_cnt
  HEAD tg.tag_group_id
   tag_cnt = 0, tag_group_cnt = (tag_group_cnt+ 1), reply->tag_info_qual[1].tag_group_cnt =
   tag_group_cnt
   IF (tag_group_cnt > 1)
    stat = alterlist(reply->tag_info_qual[1].tag_group_qual,tag_group_cnt)
   ENDIF
   reply->tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_group_cd = tg.tag_group_id, reply->
   tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_type_flag = tg.tag_type_flag, reply->
   tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_separator = tg.tag_separator,
   reply->tag_info_qual[1].tag_group_qual[tag_group_cnt].primary_ind = tg.primary_ind, reply->
   tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_cnt = 0, stat = alterlist(reply->tag_info_qual[
    1].tag_group_qual[tag_group_cnt].tag_qual,200)
  DETAIL
   tag_cnt = (tag_cnt+ 1)
   IF (mod(tag_cnt,200)=1
    AND tag_cnt != 1)
    stat = alterlist(reply->tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_qual,(tag_cnt+ 199))
   ENDIF
   reply->tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_qual[tag_cnt].tag_cd = t.tag_id, reply->
   tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_qual[tag_cnt].tag_display = t.tag_disp, reply->
   tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_qual[tag_cnt].tag_sequence = t.tag_sequence
  FOOT  tg.tag_group_id
   reply->tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_cnt = tag_cnt, stat = alterlist(reply->
    tag_info_qual[1].tag_group_qual[tag_group_cnt].tag_qual,tag_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET stat = alterlist(reply->tag_info_qual,0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
