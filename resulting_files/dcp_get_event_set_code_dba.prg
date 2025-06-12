CREATE PROGRAM dcp_get_event_set_code:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 event_set_name = vc
     2 event_set_cd = f8
     2 event_set_cd_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE name_key = vc WITH public, noconstant(" ")
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->event_code_list,5))
 SET x = 0
 SELECT INTO "nl:"
  e.event_cd, e.event_set_name
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   v500_event_set_code es,
   dummyt d2,
   v500_event_code e
  PLAN (d)
   JOIN (e
   WHERE (e.event_cd=request->event_code_list[d.seq].event_cd))
   JOIN (d2
   WHERE assign(name_key,cnvtalphanum(cnvtupper(e.event_set_name))) != " ")
   JOIN (es
   WHERE es.event_set_name_key=name_key
    AND cnvtupper(es.event_set_name)=cnvtupper(e.event_set_name))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].event_cd = e.event_cd, reply->qual[count1].event_set_cd = es.event_set_cd,
   reply->qual[count1].event_set_cd_disp = es.event_set_cd_disp
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "V500_EVENT_CODE"
 ENDIF
END GO
