CREATE PROGRAM dcp_get_pred_graph_ivorders:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 order_mnemonic = vc
     2 hna_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 med_order_type_cd = f8
     2 iv_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE count = i2 WITH noconstant(0)
 DECLARE arrsize = i2 WITH constant(cnvtint(size(request->encntr_list,5)))
 DECLARE index = i2 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE stat = i4
 SET ntotal2 = size(request->encntr_list,5)
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat = alterlist(request->encntr_list,ntotal)
 SET nstart = 1
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->encntr_list[idx].encntr_id = request->encntr_list[ntotal2].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  c.person_id, c.event_end_dt_tm, o.order_id,
  o.order_mnemonic, o.ordered_as_mnemonic, o.hna_order_mnemonic,
  o.med_order_type_cd, o.iv_ind
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   clinical_event c,
   orders o,
   ce_med_result cm
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (c
   WHERE (c.person_id=request->person_id)
    AND c.event_end_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((arrsize=0) OR (expand(index,nstart,(nstart+ (nsize - 1)),c.encntr_id,request->encntr_list[
    index].encntr_id))) )
   JOIN (cm
   WHERE cm.event_id=c.event_id
    AND cm.iv_event_cd > 0)
   JOIN (o
   WHERE o.order_id=c.order_id
    AND o.order_id > 0)
  ORDER BY o.order_id
  HEAD o.order_id
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].order_id = o.order_id, reply->qual[count].order_mnemonic = o.order_mnemonic,
   reply->qual[count].hna_mnemonic = o.hna_order_mnemonic,
   reply->qual[count].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->qual[count].
   med_order_type_cd = o.med_order_type_cd, reply->qual[count].iv_ind = o.iv_ind
  FOOT REPORT
   IF (count > 0)
    stat = alterlist(reply->qual,count)
   ENDIF
  WITH nocounter
 ;end select
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
