CREATE PROGRAM bed_get_sch_sel_appt_orders:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 code_value = f8
     2 display = vc
     2 sequence = i4
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
  FROM sch_order_appt s,
   code_value c
  PLAN (s
   WHERE (s.appt_type_cd=request->appt_type_code_value)
    AND s.active_ind=1)
   JOIN (c
   WHERE c.code_value=s.catalog_cd
    AND c.active_ind=1)
  ORDER BY s.display_seq_nbr
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->orders,cnt), reply->orders[cnt].code_value = s.catalog_cd,
   reply->orders[cnt].display = c.display, reply->orders[cnt].sequence = s.display_seq_nbr
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
