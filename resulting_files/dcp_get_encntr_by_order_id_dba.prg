CREATE PROGRAM dcp_get_encntr_by_order_id:dba
 RECORD reply(
   1 info_cnt = i2
   1 info_list[*]
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i4 WITH noconstant(0)
 FOR (i = 1 TO request->order_cnt)
   IF ((request->order_list[i].order_id=0))
    GO TO exit_script
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  o.order_id, o.encntr_id, o.person_id
  FROM (dummyt d  WITH seq = value(request->order_cnt)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->order_list[d.seq].order_id))
  HEAD REPORT
   stat = alterlist(reply->info_list,10)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->info_list,(count+ 9))
   ENDIF
   reply->info_list[d.seq].order_id = o.order_id, reply->info_list[d.seq].encntr_id = o.encntr_id,
   reply->info_list[d.seq].person_id = o.person_id
  FOOT REPORT
   stat = alterlist(reply->info_list,count)
  WITH nocounter
 ;end select
 CALL echo(build("count = ",count))
 CALL echo(build("request->order_cnt = ",request->order_cnt))
 IF ((count=request->order_cnt)
  AND count != 0)
  SET reply->info_cnt = count
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
