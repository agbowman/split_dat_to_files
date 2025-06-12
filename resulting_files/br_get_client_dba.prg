CREATE PROGRAM br_get_client:dba
 RECORD reply(
   1 item_list[*]
     2 active_ind = i2
     2 br_client_name = vc
     2 br_client_id = f8
     2 client_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 DECLARE count1 = i4
 SET count1 = 0
 DECLARE br_client_name = vc
 DECLARE active_ind1 = i2
 DECLARE maxrecs = i4
 IF ((request->max_reply < 1))
  SET maxrecs = 1000000
 ELSE
  SET maxrecs = request->max_reply
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 IF ((request->search_flag=0))
  SET br_client_name = concat(cnvtupper(request->br_client_name),"*")
 ELSE
  IF ((request->search_flag=1))
   SET br_client_name = concat("*",cnvtupper(request->br_client_name),"*")
  ENDIF
 ENDIF
 IF (br_client_name < "")
  SET reply->status_data.subeventstatus[1].operationname = "request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BR_CLIENT_NAME"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Field required"
  GO TO exit_script
 ENDIF
 SET active_ind1 = 1
 IF ((request->include_inactive_ind=1))
  SET active_ind1 = 0
 ENDIF
 CALL echo(build("maxrecs:",maxrecs))
 SELECT
  IF ((request->search_flag=2))
   WHERE cnvtupper(b.br_client_name)=cnvtupper(request->br_client_name)
    AND b.active_ind IN (1, active_ind1)
  ELSE
   WHERE operator(cnvtupper(b.br_client_name),"LIKE",patstring(br_client_name))
    AND b.active_ind IN (1, active_ind1)
  ENDIF
  INTO "nl:"
  FROM br_client b
  ORDER BY b.br_client_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->item_list,(count1+ 9))
   ENDIF
   reply->item_list[count1].active_ind = b.active_ind, reply->item_list[count1].br_client_name = b
   .br_client_name, reply->item_list[count1].br_client_id = b.br_client_id,
   reply->item_list[count1].client_mnemonic = b.client_mnemonic
  FOOT REPORT
   stat = alterlist(reply->item_list,count1)
  WITH nocounter, maxqual(b,value((maxrecs+ 1))), skipbedrock = 1
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BR_CLIENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NONE Found"
 ELSEIF (count1 > maxrecs)
  SET stat = alterlist(reply->item_list,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
