CREATE PROGRAM ce_get_prsnl_reltns_for_rte:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SET stat = 0
 DECLARE batchsize = i4 WITH constant(10)
 DECLARE paddedlistsize = i4 WITH noconstant(0)
 DECLARE startindex = i4 WITH noconstant(1), protect
 DECLARE idx1 = i4 WITH noconstant(0)
 DECLARE ordprovsidscount = i4 WITH noconstant(0)
 DECLARE numresults = i4 WITH noconstant(0)
 DECLARE ordprovsidslistsize = i4 WITH constant(size(request->ordering_provs,5))
 DECLARE reltnprovsidslistsize = i4 WITH constant(size(request->reltn_provs,5))
 SET paddedlistsize = (ceil((cnvtreal(reltnprovsidslistsize)/ batchsize)) * batchsize)
 SET stat = alterlist(request->reltn_provs,paddedlistsize)
 FOR (idx1 = (reltnprovsidslistsize+ 1) TO paddedlistsize)
   SET request->reltn_provs[idx1].prsnl_id = request->reltn_provs[reltnprovsidslistsize].prsnl_id
 ENDFOR
 SELECT DISTINCT INTO "nl"
  orderingprovid = cea.action_prsnl_id, reltnprovid = crpr.action_prsnl_id
  FROM ce_event_action cea,
   ce_rte_prsnl_reltn crpr,
   (dummyt d2  WITH seq = value((1+ ((paddedlistsize - 1)/ batchsize))))
  PLAN (d2
   WHERE initarray(startindex,evaluate(d2.seq,1,1,(startindex+ batchsize))))
   JOIN (cea
   WHERE (cea.event_id=request->event_id)
    AND expand(ordprovsidscount,1,ordprovsidslistsize,cea.action_prsnl_id,request->ordering_provs[
    ordprovsidscount].prsnl_id))
   JOIN (crpr
   WHERE crpr.ce_event_action_id=cea.ce_event_action_id
    AND expand(idx1,startindex,((startindex+ batchsize) - 1),crpr.action_prsnl_id,request->
    reltn_provs[idx1].prsnl_id))
  HEAD REPORT
   numresults = 0
  DETAIL
   numresults += 1
   IF (numresults > size(reply->rep_items,5))
    stat = alterlist(reply->rep_items,(numresults+ 10))
   ENDIF
   reply->rep_items[numresults].ordering_prsnl_id = orderingprovid, reply->rep_items[numresults].
   reltn_prsnl_id = reltnprovid
  FOOT REPORT
   stat = alterlist(reply->rep_items,numresults)
  WITH nocounter
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
