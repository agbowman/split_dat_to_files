CREATE PROGRAM bed_get_res_check_database:dba
 FREE SET reply
 RECORD reply(
   1 department_ind = i2
   1 appointment_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM br_sched_dept bsd,
   br_sched_dept_type bsdt
  PLAN (bsd
   WHERE bsd.location_cd > 0)
   JOIN (bsdt
   WHERE bsdt.dept_type_id=bsd.dept_type_id)
  DETAIL
   reply->department_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_sched_dept bsd,
   sch_appt_loc sal,
   sch_resource_list srl
  PLAN (bsd)
   JOIN (sal
   WHERE sal.location_cd=bsd.location_cd
    AND sal.active_ind=1
    AND sal.res_list_id > 0)
   JOIN (srl
   WHERE srl.res_list_id=sal.res_list_id
    AND srl.active_ind=1)
  DETAIL
   reply->appointment_ind = 1
  WITH nocounter
 ;end select
 IF ((reply->appointment_ind=0))
  SELECT INTO "nl:"
   FROM br_sched_dept bsd,
    sch_appt_loc sal,
    sch_order_appt soa,
    sch_order_role sor
   PLAN (bsd)
    JOIN (sal
    WHERE sal.location_cd=bsd.location_cd
     AND sal.active_ind=1)
    JOIN (soa
    WHERE soa.appt_type_cd=sal.appt_type_cd
     AND soa.active_ind=1)
    JOIN (sor
    WHERE sor.catalog_cd=soa.catalog_cd
     AND sor.location_cd=sal.location_cd
     AND sor.active_ind=1)
   DETAIL
    reply->appointment_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
