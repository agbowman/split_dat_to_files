CREATE PROGRAM dcp_get_orders_future_ind:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 template_order_id = f8
     2 protocol_order_id = f8
     2 med_order_type_cd = f8
     2 future_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 order_id = f8
     2 template_order_id = f8
     2 protocol_order_id = f8
     2 med_order_type_cd = f8
     2 task_dt_tm = dq8
     2 prn_ind = i2
 )
 FREE RECORD future_check
 RECORD future_check(
   1 qual[*]
     2 template_order_id = f8
     2 next_due_ord_id = f8
     2 next_due_dt_tm = dq8
 )
 FREE RECORD protocol_check
 RECORD protocol_check(
   1 qual[*]
     2 protocol_order_id = f8
     2 next_due_ord_id = f8
     2 next_due_dt_tm = dq8
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE inum = i4 WITH protect, noconstant(0)
 DECLARE ipos = i2 WITH protect, noconstant(0)
 DECLARE count_seq = i4 WITH noconstant(0)
 DECLARE protocolordidcnt = i4 WITH noconstant(0)
 DECLARE templateordidcnt = i4 WITH noconstant(0)
 DECLARE lastaddedtemplateordid = f8 WITH noconstant(0)
 DECLARE lastaddedprotocolordid = f8 WITH noconstant(0)
 DECLARE req_order_cnt = i4 WITH protect, constant(size(request->orders_list,5))
 DECLARE med_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE int_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE getnextdueorderids(null) = null
 DECLARE getnextdueprotocolids(null) = null
 SET reply->status_data.status = "F"
 IF (req_order_cnt <= 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   task_activity ta
  PLAN (o
   WHERE expand(lidx,1,req_order_cnt,o.order_id,request->orders_list[lidx].order_id)
    AND o.order_id > 0
    AND o.med_order_type_cd IN (med_type_cd, int_type_cd)
    AND o.prn_ind=0)
   JOIN (ta
   WHERE ta.order_id=o.order_id
    AND ta.task_class_cd=sched_cd
    AND ta.task_status_cd=pending_cd
    AND ta.task_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY o.order_id
  HEAD REPORT
   order_cnt = 0
  HEAD o.order_id
   order_cnt = (order_cnt+ 1)
   IF (order_cnt > size(reply->qual,5))
    stat = alterlist(temp->qual,(order_cnt+ 9)), stat = alterlist(protocol_check->qual,(order_cnt+ 9)
     ), stat = alterlist(future_check->qual,(order_cnt+ 9))
   ENDIF
   temp->qual[order_cnt].order_id = o.order_id, temp->qual[order_cnt].template_order_id = o
   .template_order_id, temp->qual[order_cnt].protocol_order_id = o.protocol_order_id,
   temp->qual[order_cnt].med_order_type_cd = o.med_order_type_cd, temp->qual[order_cnt].prn_ind = o
   .prn_ind, temp->qual[order_cnt].task_dt_tm = ta.task_dt_tm
   IF (o.template_order_id=0
    AND o.protocol_order_id > 0)
    IF (lastaddedprotocolordid != o.protocol_order_id)
     ipos = locateval(inum,1,size(protocol_check->qual,5),o.protocol_order_id,protocol_check->qual[
      inum].protocol_order_id)
     IF (ipos <= 0)
      protocolordidcnt = (protocolordidcnt+ 1), protocol_check->qual[protocolordidcnt].
      protocol_order_id = o.protocol_order_id, lastaddedprotocolordid = o.protocol_order_id
     ENDIF
    ENDIF
   ELSEIF (o.template_order_id > 0)
    IF (lastaddedtemplateordid != o.template_order_id)
     ipos = locateval(inum,1,size(future_check->qual,5),o.template_order_id,future_check->qual[inum].
      template_order_id)
     IF (ipos <= 0)
      templateordidcnt = (templateordidcnt+ 1), future_check->qual[templateordidcnt].
      template_order_id = o.template_order_id, lastaddedtemplateordid = o.template_order_id
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->qual,order_cnt), stat = alterlist(protocol_check->qual,protocolordidcnt),
   stat = alterlist(future_check->qual,templateordidcnt),
   stat = alterlist(reply->qual,order_cnt)
  WITH nocounter, expand = 1
 ;end select
 IF (templateordidcnt > 0)
  CALL getnextdueorderids(null)
  SET stat = alterlist(future_check->qual,templateordidcnt)
 ENDIF
 IF (protocolordidcnt > 0)
  CALL getnextdueprotocolids(null)
  SET stat = alterlist(protocol_check->qual,protocolordidcnt)
 ENDIF
 FOR (count_seq = 1 TO value(size(temp->qual,5)) BY 1)
   SET reply->qual[count_seq].order_id = temp->qual[count_seq].order_id
   SET reply->qual[count_seq].template_order_id = temp->qual[count_seq].template_order_id
   SET reply->qual[count_seq].protocol_order_id = temp->qual[count_seq].protocol_order_id
   SET reply->qual[count_seq].med_order_type_cd = temp->qual[count_seq].med_order_type_cd
   IF (((templateordidcnt > 0) OR (protocolordidcnt > 0)) )
    IF ((reply->qual[count_seq].med_order_type_cd IN (med_type_cd, int_type_cd))
     AND (temp->qual[count_seq].prn_ind=0))
     IF ((temp->qual[count_seq].task_dt_tm > cnvtdatetime(curdate,curtime3)))
      IF ((reply->qual[count_seq].template_order_id > 0))
       SET ipos = locateval(inum,1,size(future_check->qual,5),reply->qual[count_seq].order_id,
        future_check->qual[inum].next_due_ord_id)
       IF (ipos <= 0)
        SET reply->qual[count_seq].future_ind = 1
       ENDIF
      ELSEIF ((reply->qual[count_seq].protocol_order_id > 0))
       SET ipos = locateval(inum,1,size(protocol_check->qual,5),reply->qual[count_seq].order_id,
        protocol_check->qual[inum].next_due_ord_id)
       IF (ipos <= 0)
        SET reply->qual[count_seq].future_ind = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE getnextdueorderids(null)
   DECLARE ordercount = i4 WITH protect, noconstant(0)
   DECLARE idxnum = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta
    PLAN (o
     WHERE expand(idxnum,1,size(future_check->qual,5),o.template_order_id,future_check->qual[idxnum].
      template_order_id)
      AND o.template_order_id > 0
      AND o.med_order_type_cd IN (med_type_cd, int_type_cd))
     JOIN (ta
     WHERE ta.order_id=o.order_id
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=pending_cd
      AND ta.task_dt_tm BETWEEN cnvtdatetime(curdate,curtime3) AND cnvtdatetime(
      "31-DEC-2100 00:00:00.00"))
    ORDER BY o.template_order_id, ta.task_dt_tm
    HEAD o.template_order_id
     ordercount = (ordercount+ 1), future_check->qual[ordercount].next_due_ord_id = o.order_id,
     future_check->qual[ordercount].next_due_dt_tm = ta.task_dt_tm
    FOOT REPORT
     stat = alterlist(future_check->qual,ordercount)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getnextdueprotocolids(null)
   DECLARE idxnum = i4 WITH protect, noconstant(0)
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta
    PLAN (o
     WHERE expand(idxnum,1,size(protocol_check->qual,5),o.protocol_order_id,protocol_check->qual[
      idxnum].protocol_order_id)
      AND o.protocol_order_id > 0
      AND o.med_order_type_cd IN (med_type_cd, int_type_cd))
     JOIN (ta
     WHERE ta.order_id=o.order_id
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=pending_cd
      AND ta.task_dt_tm BETWEEN cnvtdatetime(curdate,curtime3) AND cnvtdatetime(
      "31-DEC-2100 00:00:00.00"))
    ORDER BY o.protocol_order_id, ta.task_dt_tm
    HEAD o.protocol_order_id
     rowcnt = (rowcnt+ 1), protocol_check->qual[rowcnt].next_due_ord_id = o.order_id, protocol_check
     ->qual[rowcnt].next_due_dt_tm = ta.task_dt_tm
    FOOT REPORT
     stat = alterlist(protocol_check->qual,rowcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "00"
 SET mod_date = "10/01/2015"
 SET modify = nopredeclare
END GO
