CREATE PROGRAM aps_get_wp_templates:dba
 RECORD reply(
   1 qual[10]
     2 template_id = f8
     2 short_desc = vc
     2 description = vc
     2 type_cd = f8
     2 activity_type_cd = f8
     2 person_id = f8
     2 user_name = vc
     2 active_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  t.template_id, p.person_id
  FROM wp_template t,
   prsnl p
  PLAN (t)
   JOIN (p
   WHERE t.person_id=p.person_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (t.template_id > 0)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alter(reply->qual,(cnt+ 10))
    ENDIF
    reply->qual[cnt].template_id = t.template_id, reply->qual[cnt].short_desc = trim(t.short_desc),
    reply->qual[cnt].description = trim(t.description),
    reply->qual[cnt].type_cd = t.template_type_cd, reply->qual[cnt].activity_type_cd = t
    .activity_type_cd, reply->qual[cnt].person_id = t.person_id,
    reply->qual[cnt].user_name = p.username, reply->qual[cnt].active_ind = t.active_ind, reply->qual[
    cnt].updt_cnt = t.updt_cnt
   ENDIF
  FOOT REPORT
   stat = alter(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "WP_TEMPLATE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
