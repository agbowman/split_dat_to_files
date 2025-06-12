CREATE PROGRAM bbd_get_org_mobile:dba
 RECORD reply(
   1 qual[*]
     2 mobile_pref_id = f8
     2 month_cd = f8
     2 month_cd_disp = vc
     2 week = i4
     2 sunday_ind = i2
     2 monday_ind = i2
     2 tuesday_ind = i2
     2 wednesday_ind = i2
     2 thursday_ind = i2
     2 friday_ind = i2
     2 saturday_ind = i2
     2 length_in_hours = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->qual,20)
 SET reply->status_data.status = "F"
 SET mobile_count = 0
 SELECT INTO "nl:"
  m.*
  FROM bbd_mobile_pref m
  PLAN (m
   WHERE (m.organization_id=request->organization_id)
    AND cnvtdatetime(curdate,curtime3) >= m.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= m.end_effective_dt_tm
    AND m.active_ind=1)
  DETAIL
   mobile_count = (mobile_count+ 1)
   IF (mod(mobile_count,20)=1
    AND mobile_count != 1)
    stat = alterlist(reply->qual,(mobile_count+ 20))
   ENDIF
   stat = alterlist(reply->qual,mobile_count), reply->qual[mobile_count].beg_effective_dt_tm = m
   .beg_effective_dt_tm, reply->qual[mobile_count].end_effective_dt_tm = m.end_effective_dt_tm,
   reply->qual[mobile_count].sunday_ind = m.sunday_ind, reply->qual[mobile_count].monday_ind = m
   .monday_ind, reply->qual[mobile_count].tuesday_ind = m.tuesday_ind,
   reply->qual[mobile_count].wednesday_ind = m.wednesday_ind, reply->qual[mobile_count].thursday_ind
    = m.thursday_ind, reply->qual[mobile_count].friday_ind = m.friday_ind,
   reply->qual[mobile_count].saturday_ind = m.saturday_ind, reply->qual[mobile_count].month_cd = m
   .month_cd, reply->qual[mobile_count].week = m.week,
   reply->qual[mobile_count].length_in_hours = m.length_in_hours, reply->qual[mobile_count].updt_cnt
    = m.updt_cnt, reply->qual[mobile_count].mobile_pref_id = m.mobile_pref_id,
   reply->qual[mobile_count].active_ind = m.active_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,mobile_count)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
