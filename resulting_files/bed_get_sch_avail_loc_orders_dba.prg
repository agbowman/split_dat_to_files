CREATE PROGRAM bed_get_sch_avail_loc_orders:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 code_value = f8
     2 display = vc
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
  FROM sch_appt_loc l,
   sch_order_appt a,
   order_catalog c
  PLAN (l
   WHERE (l.location_cd=request->dept_code_value))
   JOIN (a
   WHERE a.appt_type_cd=l.appt_type_cd)
   JOIN (c
   WHERE c.catalog_cd=a.catalog_cd
    AND c.active_ind=1)
  ORDER BY c.primary_mnemonic
  HEAD c.primary_mnemonic
   cnt = (cnt+ 1), stat = alterlist(reply->orders,cnt), reply->orders[cnt].code_value = c.catalog_cd,
   reply->orders[cnt].display = c.primary_mnemonic
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
