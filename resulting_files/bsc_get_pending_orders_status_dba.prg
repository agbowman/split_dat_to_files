CREATE PROGRAM bsc_get_pending_orders_status:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 pending_orders_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE ordmatchcnt = i4 WITH protect, noconstant(0)
 DECLARE orderlistsize = i4 WITH protect, noconstant(0)
 DECLARE isupdated = i2 WITH protect, noconstant(0)
 DECLARE compareordersforencounter(null) = null
 IF (validate(request->debug_ind))
  SET debugind = request->debug_ind
 ENDIF
 SET orderlistsize = size(request->orders,5)
 CALL compareordersforencounter(null)
 SUBROUTINE compareordersforencounter(null)
   IF (debugind=1)
    CALL echo("*********Begin CompareOrdersForEncounter")
   ENDIF
   DECLARE ordposidx = i4 WITH protect, noconstant(0)
   DECLARE ordpos = i4 WITH protect, noconstant(0)
   DECLARE ordmatccnt = i4 WITH protect, noconstant(0)
   DECLARE incomplete_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "INCOMPLETE"))
   DECLARE inprocess_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"
     ))
   DECLARE med_student_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "MEDSTUDENT"))
   DECLARE future_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
   DECLARE pending_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
   DECLARE pending_rev_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "PENDING REV"))
   DECLARE unscheduled_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "UNSCHEDULED"))
   DECLARE canceled_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
   DECLARE discontinued_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "DISCONTINUED"))
   DECLARE voided_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
   DECLARE transfer_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
     "TRANS/CANCEL"))
   DECLARE suspended_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
   DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
   SELECT INTO "nl:"
    FROM order_supply_review ordsuprev,
     orders ord,
     order_action ordact
    PLAN (ordsuprev
     WHERE (ordsuprev.encntr_id=request->encntr_id)
      AND ordsuprev.location_exists_ind=1
      AND ordsuprev.pharmacy_review_ind >= 1
      AND ordsuprev.active_ind=1)
     JOIN (ord
     WHERE ord.order_id=ordsuprev.order_id
      AND  NOT (ord.order_status_cd IN (incomplete_status_cd, inprocess_status_cd,
     med_student_status_cd, future_status_cd, pending_status_cd,
     pending_rev_status_cd, unscheduled_status_cd)))
     JOIN (ordact
     WHERE ordact.order_id=ordsuprev.order_id
      AND ordact.action_sequence IN (
     (SELECT
      max(action_sequence)
      FROM order_action
      WHERE order_id=ord.order_id)))
    ORDER BY ordsuprev.order_id
    HEAD REPORT
     isupdated = 0
    HEAD ordsuprev.order_id
     IF (isupdated=0)
      ordpos = locateval(ordposidx,1,orderlistsize,ord.order_id,request->orders[ordposidx].order_id)
      IF (ordpos > 0)
       IF ((ordsuprev.order_supply_review_id != request->orders[ordpos].order_supply_review_id))
        isupdated = 1
       ENDIF
       IF ((ordact.action_sequence != request->orders[ordpos].action_sequence))
        isupdated = 1
       ENDIF
       ordmatchcnt = (ordmatchcnt+ 1)
      ELSE
       IF ( NOT (ord.order_status_cd IN (voided_status_cd, discontinued_status_cd, canceled_status_cd,
       transfer_cancelled_cd, suspended_cd,
       completed_cd)))
        isupdated = 1
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     IF (ordmatchcnt < orderlistsize)
      isupdated = 1
     ENDIF
     reply->pending_orders_exist_ind = isupdated
    WITH nocounter
   ;end select
   IF (debugind=1)
    CALL echo("*********End CompareOrdersForEncounter")
   ENDIF
 END ;Subroutine
#status_update
 SET errorcode = error(errormsg,1)
 IF (errorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",errormsg))
  CALL echo("*********************************")
  CALL fillsubeventstatus("ERROR","F","bsc_get_pending_orders_status",errormsg)
  SET reply->status_data.status = "F"
  SET reply->pending_orders_exist_ind = 1
 ELSEIF (failureind=1)
  SET reply->status_data.status = "F"
  SET reply->pending_orders_exist_ind = 1
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debugind=1)
  CALL echorecord(reply)
 ENDIF
 SET lastmod = "07/07/2016"
 SET modify = nopredeclare
END GO
