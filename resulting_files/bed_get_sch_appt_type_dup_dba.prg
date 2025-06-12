CREATE PROGRAM bed_get_sch_appt_type_dup:dba
 FREE SET reply
 RECORD reply(
   1 exists_ind = i2
   1 appt_type_code_value = f8
   1 orders[*]
     2 catalog_code_value = f8
     2 primary_mnemonic = vc
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
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14230
    AND cnvtupper(c.display)=cnvtupper(request->appt_type_display)
    AND c.active_ind=1)
  DETAIL
   reply->exists_ind = 1, reply->appt_type_code_value = c.code_value
  WITH nocounter
 ;end select
 IF ((reply->appt_type_code_value > 0))
  SELECT INTO "nl:"
   FROM sch_order_appt s,
    code_value c
   PLAN (s
    WHERE (s.appt_type_cd=reply->appt_type_code_value)
     AND s.active_ind=1)
    JOIN (c
    WHERE c.code_value=s.catalog_cd
     AND c.active_ind=1)
   ORDER BY s.display_seq_nbr
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->orders,cnt), reply->orders[cnt].catalog_code_value = s
    .catalog_cd,
    reply->orders[cnt].primary_mnemonic = c.display
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
