CREATE PROGRAM bsc_get_active_iv_orders:dba
 SET modify = predeclare
 RECORD reply(
   1 order_list[*]
     2 current_order_id = f8
     2 active_order_id = f8
     2 sequence_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sequence_order_list
 RECORD sequence_order_list(
   1 sequence_list[*]
     2 active_order_id = f8
     2 order_list[*]
       3 order_id = f8
 )
 FREE RECORD temp_request
 RECORD temp_request(
   1 order_list[*]
     2 order_id = f8
     2 isvisited = i2
 )
 DECLARE completed_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")), protect
 DECLARE canceled_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED")), protect
 DECLARE discontinued_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED")),
 protect
 DECLARE voided_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED")), protect
 DECLARE voided_with_results_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT")),
 protect
 DECLARE transfer_cancelled = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL")),
 protect
 DECLARE ivsequence_cd = f8 WITH constant(uar_get_code_by("MEANING",30183,"IVSEQUENCE")), protect
 DECLARE slastmod = c3 WITH private, noconstant("")
 DECLARE smoddate = c10 WITH private, noconstant("")
 DECLARE iorderlistsize = i4 WITH protect, noconstant(size(request->order_list,5))
 DECLARE iordercnt = i4 WITH protect, noconstant(0)
 DECLARE iseqcnt = i4 WITH protect, noconstant(0)
 DECLARE iseqlistcnt = i4 WITH protect, noconstant(0)
 DECLARE iorderlistcnt = i4 WITH protect, noconstant(0)
 DECLARE ipos = i4 WITH protect, noconstant(0)
 DECLARE inum = i4 WITH protect, noconstant(0)
 DECLARE temporderstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE iperformdetail = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE isactiveorder(temporderstatuscd=f8) = i2 WITH protect
 DECLARE createtemprequestrecord(null) = null
 IF (iorderlistsize <= 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "No data submitted"
  GO TO exit_script
 ENDIF
 IF ((request->debug_ind=1))
  CALL echo(build("iOrderListSize ",iorderlistsize))
 ENDIF
 SET stat = alterlist(reply->order_list,iorderlistsize)
 CALL createtemprequestrecord(null)
 SELECT INTO "n1:"
  FROM (dummyt d  WITH seq = value(size(temp_request->order_list,5))),
   orders o,
   orders o2,
   act_pw_comp apc1,
   act_pw_comp apc2,
   pathway pw,
   pathway pw2
  PLAN (d)
   JOIN (o
   WHERE o.order_id > 0.0
    AND (o.order_id=temp_request->order_list[d.seq].order_id))
   JOIN (apc1
   WHERE apc1.encntr_id=o.encntr_id
    AND apc1.parent_entity_id=o.order_id)
   JOIN (pw
   WHERE apc1.pathway_id=pw.pathway_id
    AND pw.pathway_type_cd=ivsequence_cd)
   JOIN (pw2
   WHERE pw.pw_group_nbr=pw2.pw_group_nbr)
   JOIN (apc2
   WHERE apc2.pathway_id=pw2.pathway_id)
   JOIN (o2
   WHERE o2.order_id=apc2.parent_entity_id)
  ORDER BY d.seq, pw2.pathway_id, apc2.sequence
  HEAD REPORT
   iseqlistcnt = 0, stat = alterlist(sequence_order_list->sequence_list,10)
  HEAD d.seq
   iperformdetail = 0
   IF ((temp_request->order_list[d.seq].isvisited=0))
    iseqlistcnt = (iseqlistcnt+ 1)
    IF (mod(iseqlistcnt,10)=1)
     stat = alterlist(sequence_order_list->sequence_list,(iseqlistcnt+ 9))
    ENDIF
    iordercnt = 0, stat = alterlist(sequence_order_list->sequence_list[iseqlistcnt].order_list,10),
    iperformdetail = 1
   ENDIF
  DETAIL
   IF (iperformdetail=1)
    iordercnt = (iordercnt+ 1)
    IF (mod(iordercnt,5)=1)
     stat = alterlist(sequence_order_list->sequence_list[iseqlistcnt].order_list,(iordercnt+ 4))
    ENDIF
    IF (isactiveorder(o2.order_status_cd)=1
     AND (sequence_order_list->sequence_list[iseqlistcnt].active_order_id=0.0))
     sequence_order_list->sequence_list[iseqlistcnt].active_order_id = o2.order_id
    ENDIF
    sequence_order_list->sequence_list[iseqlistcnt].order_list[iordercnt].order_id = o2.order_id,
    ipos = locateval(inum,1,iorderlistsize,o2.order_id,temp_request->order_list[inum].order_id)
    IF (ipos > 0)
     temp_request->order_list[ipos].isvisited = 1
    ENDIF
   ENDIF
  FOOT  d.seq
   stat = alterlist(sequence_order_list->sequence_list[iseqlistcnt].order_list,iordercnt)
  FOOT REPORT
   stat = alterlist(sequence_order_list->sequence_list,iseqlistcnt)
  WITH nocounter
 ;end select
 IF ((request->debug_ind=1)
  AND size(sequence_order_list,5) > 0)
  CALL echorecord(temp_request)
  CALL echorecord(sequence_order_list)
 ENDIF
 FOR (iseqcnt = 1 TO iseqlistcnt)
  SET iorderlistcnt = size(sequence_order_list->sequence_list[iseqcnt].order_list,5)
  FOR (iordercnt = 1 TO iorderlistcnt)
   SET ipos = locateval(inum,1,iorderlistsize,sequence_order_list->sequence_list[iseqcnt].order_list[
    iordercnt].order_id,request->order_list[inum].order_id)
   IF (ipos > 0)
    IF ((request->debug_ind=1))
     CALL echo(build("position ",ipos))
     CALL echo(build("iOrderCnt ",iordercnt))
    ENDIF
    SET reply->order_list[ipos].current_order_id = sequence_order_list->sequence_list[iseqcnt].
    order_list[iordercnt].order_id
    SET reply->order_list[ipos].active_order_id = sequence_order_list->sequence_list[iseqcnt].
    active_order_id
    SET reply->order_list[ipos].sequence_ind = 1
   ENDIF
  ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
 ENDIF
 SUBROUTINE createtemprequestrecord(null)
  SET stat = alterlist(temp_request->order_list,iorderlistsize)
  FOR (iordercnt = 1 TO iorderlistsize)
   SET temp_request->order_list[iordercnt].order_id = request->order_list[iordercnt].order_id
   SET temp_request->order_list[iordercnt].isvisited = 0
  ENDFOR
 END ;Subroutine
 SUBROUTINE isactiveorder(temporderstatuscd)
   IF (((temporderstatuscd=completed_status_cd) OR (((temporderstatuscd=canceled_status_cd) OR (((
   temporderstatuscd=discontinued_status_cd) OR (((temporderstatuscd=voided_status_cd) OR (((
   temporderstatuscd=voided_with_results_cd) OR (temporderstatuscd=transfer_cancelled)) )) )) )) )) )
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
#exit_script
 SET slastmod = "001"
 SET smoddate = "09/11/2014"
END GO
