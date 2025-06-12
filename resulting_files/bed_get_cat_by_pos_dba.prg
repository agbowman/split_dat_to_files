CREATE PROGRAM bed_get_cat_by_pos:dba
 FREE SET reply
 RECORD reply(
   1 plist[*]
     2 position_code_value = f8
     2 cat_list[*]
       3 category_id = f8
       3 description = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pcnt = size(request->poslist,5)
 SET stat = alterlist(reply->plist,pcnt)
 IF (pcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = pcnt),
    br_position_category bpc,
    br_position_cat_comp bpcc,
    dummyt d2
   PLAN (d)
    JOIN (d2)
    JOIN (bpcc
    WHERE (bpcc.position_cd=request->poslist[d.seq].position_code_value))
    JOIN (bpc
    WHERE bpc.active_ind=1
     AND bpc.category_id=bpcc.category_id)
   ORDER BY d.seq, bpc.description
   HEAD d.seq
    reply->plist[d.seq].position_code_value = request->poslist[d.seq].position_code_value, tot_count
     = 0, count = 0
   DETAIL
    IF (bpcc.category_id > 0)
     IF (tot_count=0)
      stat = alterlist(reply->plist[d.seq].cat_list,50)
     ENDIF
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 50)
      stat = alterlist(reply->plist[d.seq].cat_list,(tot_count+ 50)), count = 1
     ENDIF
     reply->plist[d.seq].cat_list[tot_count].category_id = bpcc.category_id, reply->plist[d.seq].
     cat_list[tot_count].description = bpc.description
    ENDIF
   FOOT  bpcc.position_cd
    IF (tot_count > 0)
     stat = alterlist(reply->plist[d.seq].cat_list,tot_count)
    ENDIF
   WITH outerjoin = d2, nocounter
  ;end select
 ENDIF
#enditnow
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
