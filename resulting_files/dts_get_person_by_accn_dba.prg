CREATE PROGRAM dts_get_person_by_accn:dba
 RECORD reply(
   1 qual[10]
     2 person_id = f8
     2 order_id = f8
     2 contributor_system_cd = f8
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = c60
     2 activity_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  o.person_id, o.order_id, o.contributor_system_cd,
  a.activity_type_cd
  FROM accession_order_r a,
   orders o
  PLAN (a
   WHERE (a.accession=request->accession))
   JOIN (o
   WHERE o.order_id=a.order_id)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].person_id = o.person_id, reply->qual[cnt].order_id = o.order_id, reply->qual[cnt]
   .contributor_system_cd = o.contributor_system_cd,
   reply->qual[cnt].activity_type_cd = a.activity_type_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ACCESION_ORDER_R"
 ENDIF
 SET stat = alter(reply->qual,cnt)
END GO
