CREATE PROGRAM bsc_get_modified_orders:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 order_endstate_ind = i2
     2 supply_location_valid_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temporderdata
 RECORD temporderdata(
   1 qual[*]
     2 order_id = f8
     2 order_endstate_ind = i2
     2 supply_location_valid_ind = i2
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE failureind = i2 WITH protect, noconstant(0)
 DECLARE debugind = i2 WITH protect, noconstant(0)
 DECLARE errormsg = vc WITH protect, noconstant("")
 DECLARE errorcode = i2 WITH protect, noconstant(0)
 DECLARE lastmod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE ordercnt = i4 WITH protect, noconstant(0)
 DECLARE replycnt = i4 WITH protect, noconstant(0)
 DECLARE orderlistsize = i4 WITH protect, noconstant(0)
 DECLARE getlatestorderdetails(null) = null
 DECLARE populatereply(null) = null
 DECLARE updatetempstructure(order_iterator=i4,order_id=f8,action_seq=i4,order_iterator=i4,active_ind
  =i2,
  endstate_ind=i2) = i4 WITH protect
 DECLARE checksupplylocationvalid(supply_review_id=f8,order_iterator=i4) = i2 WITH protect
 IF (validate(request->debug_ind))
  SET debugind = request->debug_ind
 ENDIF
 SET orderlistsize = size(request->orders,5)
 IF (orderlistsize=0)
  CALL fillsubeventstatus("bsc_get_modified_orders","F","REQUEST","Encountered an empty request.")
  SET failureind = 1
  GO TO status_update
 ENDIF
 CALL getlatestorderdetails(null)
 CALL populatereply(null)
 IF (ordercnt=0)
  SET replycnt = 0
  GO TO status_update
 ENDIF
 SUBROUTINE getlatestorderdetails(null)
   IF (debugind=1)
    CALL echo("*********Begin GetLatestOrderDetails*********")
   ENDIF
   DECLARE orditerator = i4 WITH protect, noconstant(1)
   DECLARE ordidx = i4 WITH protect, noconstant(0)
   DECLARE ordlistcnt = i4 WITH protect, noconstant(0)
   DECLARE isupdated = i2 WITH protect, noconstant(0)
   DECLARE isendstated = i2 WITH protect, noconstant(0)
   DECLARE issupplylocvalid = i2 WITH protect, noconstant(0)
   DECLARE canceled_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
   DECLARE discontinued_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "DISCONTINUED"))
   DECLARE voided_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
   DECLARE transfer_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "TRANS/CANCEL"))
   DECLARE suspended_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
   DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
   SET ordlistcnt = size(request->orders,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ordlistcnt)),
     order_action ordact,
     order_supply_review ordsupp,
     order_supply_location ordsupploc
    PLAN (d)
     JOIN (ordact
     WHERE (ordact.order_id=request->orders[d.seq].order_id)
      AND (ordact.action_sequence=
     (SELECT
      max(ordact2.action_sequence)
      FROM order_action ordact2
      WHERE ordact2.order_id=ordact.order_id
       AND (ordact2.action_sequence >= request->orders[d.seq].action_seq))))
     JOIN (ordsupp
     WHERE (ordsupp.order_id=request->orders[d.seq].order_id)
      AND (ordsupp.encntr_id=request->orders[d.seq].encntr_id)
      AND ordsupp.active_ind=1
      AND ordsupp.pharmacy_review_ind >= 1)
     JOIN (ordsupploc
     WHERE ordsupploc.order_supply_review_id=outerjoin(ordsupp.order_supply_review_id))
    HEAD d.seq
     IF (mod(orditerator,10)=1)
      stat = alterlist(temporderdata->qual,(orditerator+ 9))
     ENDIF
     IF (((canceled_status_cd=ordact.order_status_cd) OR (((discontinued_status_cd=ordact
     .order_status_cd) OR (((voided_status_cd=ordact.order_status_cd) OR (((transfer_cancelled_cd=
     ordact.order_status_cd) OR (((suspended_cd=ordact.order_status_cd) OR (completed_cd=ordact
     .order_status_cd)) )) )) )) )) )
      isendstated = 1
     ENDIF
     IF ((ordsupp.order_supply_review_id=request->orders[d.seq].order_supply_review_id))
      issupplylocvalid = 1
     ENDIF
    DETAIL
     IF (issupplylocvalid=0)
      IF ((ordsupploc.pharmacy_supply_location_cd=request->orders[d.seq].pharm_supply_loc_cd))
       issupplylocvalid = 1
      ENDIF
     ENDIF
    FOOT  d.seq
     isupdated = updatetempstructure(d.seq,ordact.order_id,ordact.action_sequence,orditerator,
      issupplylocvalid,
      isendstated)
     IF (isupdated=1)
      orditerator = (orditerator+ 1), issupplylocvalid = 0, isendstated = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(temporderdata->qual,(orditerator - 1))
    WITH nocounter
   ;end select
   SET ordercnt = size(temporderdata->qual,5)
   IF (debugind=1)
    CALL echo("*********End GetLatestOrderDetails*********")
   ENDIF
 END ;Subroutine
 SUBROUTINE updatetempstructure(req_iterator,order_id,action_seq,order_iterator,active_ind,
  endstate_ind)
   IF (debugind=1)
    CALL echo("*********Begin UpdateTempStructure*********")
   ENDIF
   DECLARE success = i2 WITH protect, noconstant(0)
   IF (((active_ind != 1) OR ((request->orders[req_iterator].order_id=order_id)
    AND (request->orders[req_iterator].action_seq != action_seq))) )
    SET temporderdata->qual[order_iterator].order_id = order_id
    SET temporderdata->qual[order_iterator].order_endstate_ind = endstate_ind
    SET temporderdata->qual[order_iterator].supply_location_valid_ind = active_ind
    SET success = 1
   ENDIF
   IF (debugind=1)
    CALL echo("*********End UpdateTempStructure*********")
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE populatereply(null)
   IF (debugind=1)
    CALL echo("*********Begin PopulateReply*********")
   ENDIF
   DECLARE orderdatacntrep = i4 WITH protect, noconstant(size(temporderdata->qual,5))
   DECLARE orderdataidx = i4 WITH protect, noconstant(0)
   DECLARE pharmreviewordercnt = i4 WITH protect, noconstant(0)
   FOR (orderdataidx = 1 TO orderdatacntrep)
     SET pharmreviewordercnt = (pharmreviewordercnt+ 1)
     SET stat = alterlist(reply->orders,pharmreviewordercnt)
     SET reply->orders[orderdataidx].order_id = temporderdata->qual[orderdataidx].order_id
     SET reply->orders[orderdataidx].order_endstate_ind = temporderdata->qual[orderdataidx].
     order_endstate_ind
     SET reply->orders[orderdataidx].supply_location_valid_ind = temporderdata->qual[orderdataidx].
     supply_location_valid_ind
   ENDFOR
   IF (pharmreviewordercnt > 0)
    SET replycnt = 1
   ENDIF
   IF (debugind=1)
    CALL echo("*********End PopulateReply*********")
   ENDIF
 END ;Subroutine
#status_update
 SET errorcode = error(errormsg,1)
 IF (errorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",errormsg))
  CALL echo("*********************************")
  CALL fillsubeventstatus("ERROR","F","bsc_get_modified_orders",errormsg)
  SET reply->status_data.status = "F"
 ELSEIF (failureind=1)
  SET reply->status_data.status = "F"
 ELSEIF (replycnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debugind=1)
  CALL echorecord(reply)
  CALL echorecord(temporderdata)
 ENDIF
 SET lastmod = "06/16/2014"
 SET modify = nopredeclare
END GO
