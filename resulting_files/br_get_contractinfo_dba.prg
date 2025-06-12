CREATE PROGRAM br_get_contractinfo:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 item_type = vc
     2 item_mean = vc
     2 item_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM br_client_item_reltn bcir
  PLAN (bcir
   WHERE (bcir.br_client_id=request->br_client_id)
    AND bcir.item_type IN ("LICENSE", "SUBSCRT"))
  ORDER BY bcir.item_display
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->clist,cnt), reply->clist[cnt].item_type = bcir.item_type,
   reply->clist[cnt].item_mean = bcir.item_mean, reply->clist[cnt].item_disp = bcir.item_display
  WITH nocounter, skipbedrock = 1
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
