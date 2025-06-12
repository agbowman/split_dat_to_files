CREATE PROGRAM dcp_get_result_chg_info:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 event_id = f8
     2 charge_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD charge(
   1 qual[*]
     2 order_id = f8
     2 event_id = f8
     2 charge_event_id = f8
     2 reconciled = i2
 )
 RECORD credit(
   1 qual[*]
     2 order_id = f8
     2 event_id = f8
     2 reconciled = i2
 )
 SET reply->status_data.status = "F"
 DECLARE last_mod = c3 WITH protect, noconstant("")
 DECLARE mod_date = c10 WITH protect, noconstant("")
 DECLARE reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE qual_cnt = i4 WITH protect, noconstant(cnvtint(size(request->qual,5)))
 DECLARE charge_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4032,"CHGONADMIN"))
 DECLARE credit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4032,"CRDTONADMIN"))
 DECLARE charge_cnt = i4 WITH protect, noconstant(0)
 DECLARE credit_cnt = i4 WITH protect, noconstant(0)
 DECLARE found = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(qual_cnt)),
   clinical_event ce,
   rx_pending_charge rp
  PLAN (d)
   JOIN (ce
   WHERE (ce.order_id=request->qual[d.seq].order_id)
    AND (((ce.parent_event_id=request->qual[d.seq].event_id)) OR ((ce.event_id=request->qual[d.seq].
   event_id))) )
   JOIN (rp
   WHERE rp.event_id=ce.event_id)
  ORDER BY d.seq, rp.event_id
  HEAD REPORT
   charge_cnt = 0, credit_cnt = 0
  HEAD d.seq
   CALL echo(build("d.seq=",d.seq))
  HEAD rp.rx_pending_charge_id
   CALL echo(build("rp.event_id=",rp.event_id))
   IF (rp.event_id > 0)
    charge_cnt = (charge_cnt+ 1), stat = alterlist(charge->qual,charge_cnt), charge->qual[charge_cnt]
    .event_id = request->qual[d.seq].event_id,
    charge->qual[charge_cnt].order_id = ce.order_id, charge->qual[charge_cnt].charge_event_id = rp
    .event_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(qual_cnt)),
   clinical_event ce,
   dispense_hx dh
  PLAN (d)
   JOIN (ce
   WHERE (ce.order_id=request->qual[d.seq].order_id)
    AND (((ce.parent_event_id=request->qual[d.seq].event_id)) OR ((ce.event_id=request->qual[d.seq].
   event_id))) )
   JOIN (dh
   WHERE dh.event_id=ce.event_id)
  ORDER BY d.seq, dh.event_id
  HEAD REPORT
   charge_cnt = size(charge->qual,5), credit_cnt = size(credit->qual,5)
  HEAD d.seq
   CALL echo(build("d.seq=",d.seq))
  HEAD dh.dispense_hx_id
   CALL echo(build("dh.event_id=",dh.event_id)),
   CALL echo(build("dh.disp_event_type_cd=",dh.disp_event_type_cd))
   IF (dh.event_id > 0)
    IF (dh.disp_event_type_cd=credit_cd)
     credit_cnt = (credit_cnt+ 1),
     CALL echo(build("credit_cnt=",credit_cnt)), stat = alterlist(credit->qual,credit_cnt),
     credit->qual[credit_cnt].event_id = request->qual[d.seq].event_id, credit->qual[credit_cnt].
     order_id = ce.order_id
    ELSEIF (dh.disp_event_type_cd=charge_cd)
     charge_cnt = (charge_cnt+ 1),
     CALL echo(build("charge_cnt=",charge_cnt)), stat = alterlist(charge->qual,charge_cnt),
     charge->qual[charge_cnt].event_id = request->qual[d.seq].event_id, charge->qual[charge_cnt].
     order_id = ce.order_id, charge->qual[charge_cnt].charge_event_id = dh.event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("BEFORE RECONCILE")
 CALL echorecord(charge)
 CALL echorecord(credit)
 FOR (i = 1 TO charge_cnt)
  CALL echo("1")
  FOR (y = 1 TO credit_cnt)
   CALL echo("2")
   IF ((credit->qual[y].event_id=charge->qual[i].event_id)
    AND (credit->qual[y].order_id=charge->qual[i].order_id)
    AND (credit->qual[y].reconciled=0))
    SET credit->qual[y].reconciled = 1
    SET charge->qual[i].reconciled = 1
    SET y = credit_cnt
    CALL echo("Reconciled")
   ENDIF
  ENDFOR
 ENDFOR
 CALL echo("AFTER RECONCILE")
 CALL echorecord(charge)
 CALL echorecord(credit)
 SET reply_cnt = 0
 FOR (x = 1 TO charge_cnt)
   IF ((charge->qual[x].reconciled=0))
    SET found = 0
    FOR (y = 1 TO reply_cnt)
      IF ((reply->qual[reply_cnt].order_id=charge->qual[x].order_id)
       AND (reply->qual[reply_cnt].event_id=charge->qual[x].event_id)
       AND (reply->qual[reply_cnt].charge_event_id=charge->qual[x].charge_event_id))
       SET y = reply_cnt
       SET found = 1
       CALL echo("Found")
      ENDIF
    ENDFOR
    IF (found=0)
     CALL echo("Not Found. Adding to Reply")
     SET reply_cnt = (reply_cnt+ 1)
     IF (mod(reply_cnt,10)=1)
      SET stat = alterlist(reply->qual,(reply_cnt+ 9))
     ENDIF
     SET reply->qual[reply_cnt].order_id = charge->qual[x].order_id
     SET reply->qual[reply_cnt].event_id = charge->qual[x].event_id
     SET reply->qual[reply_cnt].charge_event_id = charge->qual[x].charge_event_id
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->qual,reply_cnt)
 FREE RECORD charge
 FREE RECORD credit
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (reply_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
 SET last_mod = "002"
 SET mod_date = "02/11/2007"
 SET modify = nopredeclare
END GO
