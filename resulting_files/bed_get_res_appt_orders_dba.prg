CREATE PROGRAM bed_get_res_appt_orders:dba
 FREE SET reply
 RECORD reply(
   1 appt_types[*]
     2 appt_type_code_value = f8
     2 orders[*]
       3 catalog_code_value = f8
       3 primary_mnemonic = vc
       3 description = vc
       3 order_role_ind = i2
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
 SET req_cnt = size(request->appt_types,5)
 IF (req_cnt > 0)
  SET stat = alterlist(reply->appt_types,req_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = req_cnt)
   PLAN (d)
   DETAIL
    reply->appt_types[d.seq].appt_type_code_value = request->appt_types[d.seq].appt_type_code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = req_cnt),
    sch_order_appt soa,
    sch_order_loc sol,
    order_catalog oc,
    order_catalog_synonym ocs,
    code_value cv
   PLAN (d)
    JOIN (soa
    WHERE (soa.appt_type_cd=request->appt_types[d.seq].appt_type_code_value)
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
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->appt_types[d.seq].orders,10)
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->appt_types[d.seq].orders,(tot_cnt+ 10)), cnt = 1
    ENDIF
    reply->appt_types[d.seq].orders[tot_cnt].catalog_code_value = oc.catalog_cd, reply->appt_types[d
    .seq].orders[tot_cnt].description = oc.description, reply->appt_types[d.seq].orders[tot_cnt].
    primary_mnemonic = ocs.mnemonic
   FOOT  d.seq
    stat = alterlist(reply->appt_types[d.seq].orders,tot_cnt)
   WITH nocounter
  ;end select
  FOR (x = 1 TO req_cnt)
   SET ord_size = size(reply->appt_types[x].orders,5)
   IF (ord_size > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ord_size),
      sch_order_role sor
     PLAN (d)
      JOIN (sor
      WHERE (sor.catalog_cd=reply->appt_types[x].orders[d.seq].catalog_code_value)
       AND (sor.location_cd=request->dept_code_value)
       AND sor.list_role_id > 0
       AND sor.active_ind=1)
     ORDER BY d.seq
     HEAD d.seq
      reply->appt_types[x].orders[d.seq].order_role_ind = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
