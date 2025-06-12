CREATE PROGRAM bhs_eks_cancel_order:dba
 DECLARE log_message = vc WITH noconstant(" "), public
 DECLARE log_misc = vc WITH noconstant(" "), public
 DECLARE tcurindex = i4 WITH noconstant(3), protect
 DECLARE cnt = i4 WITH noconstant(1), protect
 SET retval = 0
 SET eksdata->tqual[tcurindex].qual[curindex].encntr_id = request->qual[cnt].encntr_id
 SET eksdata->tqual[tcurindex].qual[curindex].person_id = request->qual[cnt].person_id
 SET eksdata->tqual[tcurindex].qual[curindex].order_id = request->qual[cnt].order_id
 SET stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,2)
 SET eksdata->tqual[tcurindex].qual[curindex].data[1].misc = "<ORDER_ID>"
 SET eksdata->tqual[tcurindex].qual[curindex].data[2].misc = concat(trim(cnvtstring(request->qual[cnt
    ].order_id,25,1)))
 SET log_message = build(log_message," tCurIndex:",tcurindex)
 SET log_message = build(log_message," CurIndex:",curindex)
 SET log_message = build(log_message," tqual:",size(eksdata->tqual,5))
 SET log_message = build(log_message," qual: ",size(eksdata->tqual[tcurindex].qual,5))
 SET log_message = build(log_message," data: ",size(eksdata->tqual[tcurindex].qual[curindex].data,5))
 SET log_message = build(log_message," misc1: ",eksdata->tqual[tcurindex].qual[curindex].data[1].misc
  )
 SET log_message = build(log_message," misc2: ",eksdata->tqual[tcurindex].qual[curindex].data[2].misc
  )
 SET log_message = build(log_message,"orderid: ",request->qual[1].order_id,"]]]")
 CALL echo(concat("log_message:",log_message))
 CALL echorecord(request)
 CALL echorecord(eksdata)
 CALL echorecord(request)
 SET retval = 100
END GO
