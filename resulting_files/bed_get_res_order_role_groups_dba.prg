CREATE PROGRAM bed_get_res_order_role_groups:dba
 FREE SET reply
 RECORD reply(
   1 groups[*]
     2 group_id = f8
     2 meaning = vc
     2 name = vc
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
  FROM br_name_value b
  PLAN (b
   WHERE b.br_nv_key1="SCHRESGROUP")
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->groups,10)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->groups,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->groups[tot_cnt].group_id = b.br_name_value_id, reply->groups[tot_cnt].meaning = b.br_name,
   reply->groups[tot_cnt].name = b.br_value
  FOOT REPORT
   stat = alterlist(reply->groups,tot_cnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
