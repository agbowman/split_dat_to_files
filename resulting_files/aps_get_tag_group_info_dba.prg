CREATE PROGRAM aps_get_tag_group_info:dba
 RECORD reply(
   1 pre_tag_qual[*]
     2 tag_type_flag = i2
     2 tag_group_cd = f8
     2 first_tag_disp = c1
     2 tag_separator = c1
     2 updt_cnt = i4
   1 tag_grp_qual[*]
     2 tag_group_cd = f8
     2 tag_desc = vc
     2 updt_cnt = i4
     2 first_tag_disp = c1
     2 tag_cd = f8
     2 active_ind = i2
     2 t_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET pre_tag_cnt = 0
 SET tag_grp_cnt = 0
 SET stat = alterlist(reply->pre_tag_qual,1)
 SET stat = alterlist(reply->tag_grp_qual,1)
 SELECT INTO "nl:"
  tg.prefix_id
  FROM ap_prefix_tag_group_r tg,
   ap_tag t
  PLAN (tg
   WHERE (request->prefix_cd=tg.prefix_id))
   JOIN (t
   WHERE tg.tag_group_id=t.tag_group_id
    AND 1=t.tag_sequence
    AND 1=t.active_ind)
  DETAIL
   pre_tag_cnt = (pre_tag_cnt+ 1), stat = alterlist(reply->pre_tag_qual,pre_tag_cnt), reply->
   pre_tag_qual[pre_tag_cnt].tag_type_flag = tg.tag_type_flag,
   reply->pre_tag_qual[pre_tag_cnt].tag_group_cd = tg.tag_group_id, reply->pre_tag_qual[pre_tag_cnt].
   tag_separator = tg.tag_separator, reply->pre_tag_qual[pre_tag_cnt].first_tag_disp = t.tag_disp,
   reply->pre_tag_qual[pre_tag_cnt].updt_cnt = tg.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->pre_tag_qual,pre_tag_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX_TAG_GROUP_R"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  tg.tag_group_id
  FROM ap_tag_group tg,
   ap_tag t
  PLAN (tg)
   JOIN (t
   WHERE tg.tag_group_id=t.tag_group_id
    AND 1=t.tag_sequence
    AND 1=t.active_ind)
  DETAIL
   tag_grp_cnt = (tag_grp_cnt+ 1), stat = alterlist(reply->tag_grp_qual,tag_grp_cnt), reply->
   tag_grp_qual[tag_grp_cnt].tag_group_cd = tg.tag_group_id,
   reply->tag_grp_qual[tag_grp_cnt].tag_desc = tg.tag_desc, reply->tag_grp_qual[tag_grp_cnt].updt_cnt
    = tg.updt_cnt, reply->tag_grp_qual[tag_grp_cnt].first_tag_disp = t.tag_disp,
   reply->tag_grp_qual[tag_grp_cnt].tag_cd = t.tag_id, reply->tag_grp_qual[tag_grp_cnt].active_ind =
   t.active_ind, reply->tag_grp_qual[tag_grp_cnt].t_updt_cnt = t.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->tag_grp_qual,tag_grp_cnt)
 IF (curqual=0)
  IF ((reply->status_data.status != "S"))
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG_GROUP"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
