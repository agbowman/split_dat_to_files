CREATE PROGRAM dcp_srv_sort_by_encntr:dba
 RECORD reply(
   1 encntrlist[*]
     2 personid = f8
     2 orderlocncd = f8
     2 personnelid = f8
     2 osind = i2
     2 osprintername = vc
     2 osprintercd = f8
     2 consformind = i2
     2 reqind = i2
     2 orderlist[*]
       3 orderid = f8
       3 encntrid = f8
       3 conversationid = f8
       3 actiontypecd = f8
       3 catalogcd = f8
       3 activitytypecd = f8
       3 activitysubtypecd = f8
       3 catalogtypecd = f8
       3 consformind = i2
       3 consformformatcd = f8
       3 consformroutingcd = f8
       3 reqind = i2
       3 reqformatcd = f8
       3 reqroutingcd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE reqordcnt = i4
 SET reqordcnt = 0
 DECLARE encntrcnt = i4
 SET encntrcnt = 0
 DECLARE ordercnt = i4
 SET ordercnt = 0
 DECLARE encntrid = f8
 SET encntrid = 0.0
 DECLARE personid = f8
 SET personid = 0.0
 DECLARE encntrexistsind = i2
 SET encntrexistsind = 0
 DECLARE breakind = i2
 SET breakind = 0
 DECLARE encntrarrnbr = i4
 SET encntrarrnbr = 0
 SET reqordcnt = size(request->orderlist,5)
 CALL echo(build("Number of Orders to process:",reqordcnt))
 FOR (o = 1 TO reqordcnt)
   CALL echo(build("Order Processing:",o))
   CALL echo(build("OrderId:",request->orderlist[o].orderid))
   SELECT INTO "nl:"
    o.person_id, o.encntr_id
    FROM orders o
    WHERE (o.order_id=request->orderlist[o].orderid)
    DETAIL
     encntrid = o.encntr_id, personid = o.person_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    GO TO exit_script
   ENDIF
   CALL echo(build("Current encntrId:",encntrid))
   CALL echo(build("Current personId:",personid))
   FOR (e = 1 TO encntrcnt)
     IF ((encntrid=reply->encntrlist[e].orderlist[1].encntrid))
      SET encntrexistsind = 1
      SET encntrarrnum = e
     ENDIF
   ENDFOR
   CALL echo(build("encntrExistsInd:",encntrexistsind))
   IF (encntrexistsind=0)
    SET encntrcnt = (encntrcnt+ 1)
    SET stat = alterlist(reply->encntrlist,encntrcnt)
    SET reply->encntrlist[encntrcnt].personid = personid
    SET reply->encntrlist[encntrcnt].orderlocncd = request->orderlocncd
    SET reply->encntrlist[encntrcnt].personnelid = request->personnelid
    SET reply->encntrlist[encntrcnt].osind = request->osind
    SET reply->encntrlist[encntrcnt].osprintername = request->osprintername
    SET reply->encntrlist[encntrcnt].osprintercd = request->osprintercd
    SET reply->encntrlist[encntrcnt].consformind = request->consformind
    SET reply->encntrlist[encntrcnt].reqind = request->reqind
    SET ordercnt = size(reply->encntrlist[encntrcnt].orderlist,5)
    SET ordercnt = (ordercnt+ 1)
    SET stat = alterlist(reply->encntrlist[encntrcnt].orderlist,ordercnt)
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].orderid = request->orderlist[o].orderid
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].encntrid = encntrid
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].conversationid = request->orderlist[o].
    conversationid
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].actiontypecd = request->orderlist[o].
    actiontypecd
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].catalogcd = request->orderlist[o].catalogcd
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].activitytypecd = request->orderlist[o].
    activitytypecd
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].activitysubtypecd = request->orderlist[o].
    activitysubtypecd
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].catalogtypecd = request->orderlist[o].
    catalogtypecd
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].consformind = request->orderlist[o].
    consformind
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].consformformatcd = request->orderlist[o].
    consformformatcd
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].consformroutingcd = request->orderlist[o].
    consformroutingcd
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].reqind = request->orderlist[o].reqind
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].reqformatcd = request->orderlist[o].
    reqformatcd
    SET reply->encntrlist[encntrcnt].orderlist[ordercnt].reqroutingcd = request->orderlist[o].
    reqroutingcd
   ELSE
    SET ordercnt = size(reply->encntrlist[encntrarrnbr].orderlist,5)
    SET ordercnt = (ordercnt+ 1)
    CALL echo(build("EncntrId exists in reply--adding order to list",ordercnt))
    SET stat = alterlist(reply->encntrlist[encntrarrnbr].orderlist,ordercnt)
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].orderid = request->orderlist[o].orderid
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].encntrid = encntrid
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].conversationid = request->orderlist[o].
    conversationid
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].actiontypecd = request->orderlist[o].
    actiontypecd
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].catalogcd = request->orderlist[o].
    catalogcd
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].activitytypecd = request->orderlist[o].
    activitytypecd
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].activitysubtypecd = request->orderlist[o]
    .activitysubtypecd
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].catalogtypecd = request->orderlist[o].
    catalogtypecd
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].consformind = request->orderlist[o].
    consformind
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].consformformatcd = request->orderlist[o].
    consformformatcd
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].consformroutingcd = request->orderlist[o]
    .consformroutingcd
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].reqind = request->orderlist[o].reqind
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].reqformatcd = request->orderlist[o].
    reqformatcd
    SET reply->encntrlist[encntrarrnbr].orderlist[ordercnt].reqroutingcd = request->orderlist[o].
    reqroutingcd
    SET encntrexistsind = 0
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
END GO
