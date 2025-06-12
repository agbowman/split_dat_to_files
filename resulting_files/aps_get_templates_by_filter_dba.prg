CREATE PROGRAM aps_get_templates_by_filter:dba
 RECORD reply(
   1 qual[10]
     2 template_cd = f8
     2 short_desc = vc
     2 description = vc
     2 type_cd = f8
     2 activity_type_cd = f8
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
 SET activity_type_cd = 0.0
 SET template_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 106
 SET cdf_meaning = request->activity_type_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET activity_type_cd = code_value
 SET code_set = 1303
 SET cdf_meaning = request->template_type_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET template_type_cd = code_value
 SELECT INTO "nl:"
  t.template_id
  FROM wp_template t
  PLAN (t
   WHERE t.activity_type_cd=activity_type_cd
    AND t.template_type_cd=template_type_cd
    AND t.active_ind=1
    AND t.person_id IN (null, 0))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].template_cd = t.template_id, reply->qual[cnt].short_desc = trim(t.short_desc),
   reply->qual[cnt].description = trim(t.description),
   reply->qual[cnt].type_cd = t.template_type_cd, reply->qual[cnt].activity_type_cd = t
   .activity_type_cd, reply->qual[cnt].active_ind = t.active_ind,
   reply->qual[cnt].updt_cnt = t.updt_cnt
  FOOT REPORT
   stat = alter(reply->qual,cnt)
  WITH nocounter, outerjoin = d1
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
