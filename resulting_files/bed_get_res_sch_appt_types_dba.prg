CREATE PROGRAM bed_get_res_sch_appt_types:dba
 FREE SET reply
 RECORD reply(
   1 appointment_types[*]
     2 code_value = f8
     2 display = vc
     2 ord_role_ind = i2
     2 res_list_ind = i2
     2 orders_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM sch_appt_loc sal,
   code_value cv
  PLAN (sal
   WHERE (sal.location_cd=request->dept_code_value)
    AND sal.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sal.appt_type_cd
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->appointment_types,10)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->appointment_types,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->appointment_types[tot_cnt].code_value = cv.code_value, reply->appointment_types[tot_cnt].
   display = cv.display
  FOOT REPORT
   stat = alterlist(reply->appointment_types,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    sch_appt_loc sal,
    sch_resource_list srl
   PLAN (d)
    JOIN (sal
    WHERE (sal.appt_type_cd=reply->appointment_types[d.seq].code_value)
     AND (sal.location_cd=request->dept_code_value)
     AND sal.res_list_id > 0
     AND sal.active_ind=1)
    JOIN (srl
    WHERE srl.res_list_id=sal.res_list_id
     AND srl.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->appointment_types[d.seq].res_list_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    sch_order_appt soa,
    sch_order_role sor
   PLAN (d)
    JOIN (soa
    WHERE (soa.appt_type_cd=reply->appointment_types[d.seq].code_value)
     AND soa.active_ind=1)
    JOIN (sor
    WHERE sor.catalog_cd=soa.catalog_cd
     AND (sor.location_cd=request->dept_code_value)
     AND sor.list_role_id > 0
     AND sor.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->appointment_types[d.seq].ord_role_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    sch_order_appt soa,
    sch_order_loc sol,
    order_catalog oc,
    order_catalog_synonym ocs,
    code_value cv
   PLAN (d)
    JOIN (soa
    WHERE (soa.appt_type_cd=reply->appointment_types[d.seq].code_value)
     AND soa.active_ind=1)
    JOIN (sol
    WHERE sol.catalog_cd=soa.catalog_cd
     AND (sol.location_cd=request->dept_code_value)
     AND sol.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=sol.catalog_cd
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=sol.catalog_cd
     AND ocs.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.code_set=6011
     AND cv.cdf_meaning="PRIMARY"
     AND cv.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->appointment_types[d.seq].orders_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
