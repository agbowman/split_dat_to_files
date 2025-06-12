CREATE PROGRAM afc_get_charge_point_scheds:dba
 RECORD reply(
   1 sched_qual = i4
   1 sched[*]
     2 sched_disp = vc
     2 sched_desc = vc
     2 sched_mean = vc
     2 sched_id = f8
   1 charge_point_qual = i4
   1 charge_point[*]
     2 charge_point_disp = vc
     2 charge_point_desc = vc
     2 charge_point_mean = vc
     2 charge_point_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->sched,(count1+ 10))
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.cdf_meaning="CHARGE POINT"
   AND cv.code_set=14002
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->sched,(count1+ 10))
   ENDIF
   reply->sched[count1].sched_disp = cv.display, reply->sched[count1].sched_desc = cv.description,
   reply->sched[count1].sched_mean = cv.cdf_meaning,
   reply->sched[count1].sched_id = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->sched,count1)
 SET reply->sched_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET count1 = 0
 SET stat = alterlist(reply->charge_point,(count1+ 10))
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=13029
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->charge_point,(count1+ 10))
   ENDIF
   reply->charge_point[count1].charge_point_disp = cv.display, reply->charge_point[count1].
   charge_point_desc = cv.description, reply->charge_point[count1].charge_point_mean = cv.cdf_meaning,
   reply->charge_point[count1].charge_point_id = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->charge_point,count1)
 SET reply->charge_point_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
