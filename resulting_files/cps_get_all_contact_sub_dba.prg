CREATE PROGRAM cps_get_all_contact_sub:dba
 SET count = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM plan_contact p
  WHERE p.active_ind=1
   AND p.plan_contact_id > 0
   AND  $1
   AND  $2
   AND  $3
  HEAD REPORT
   count = 0
  DETAIL
   count += 1
   IF (mod(count,100)=1)
    stat = alterlist(reply->plan_contact,(count+ 100))
   ENDIF
   reply->plan_contact[count].plan_contact_id = p.plan_contact_id, reply->plan_contact[count].
   health_plan_id = p.health_plan_id, reply->plan_contact[count].carrier_id = p.carrier_id,
   reply->plan_contact[count].parent_contact_id = p.parent_contact_id, reply->plan_contact[count].
   person_id = p.person_id, reply->plan_contact[count].person_ind = p.person_ind,
   reply->plan_contact[count].name_last = p.name_last, reply->plan_contact[count].name_first = p
   .name_first, reply->plan_contact[count].name_middle = p.name_middle,
   reply->plan_contact[count].title = p.title, reply->plan_contact[count].display_order = p
   .display_order, reply->plan_contact[count].beg_effective_dt_tm = p.beg_effective_dt_tm,
   reply->plan_contact[count].end_effective_dt_tm = p.end_effective_dt_tm, reply->plan_contact[count]
   .updt_cnt = p.updt_cnt
  WITH nocounter
 ;end select
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->plan_contact,count)
 SET reply->plan_contact_qual = count
END GO
