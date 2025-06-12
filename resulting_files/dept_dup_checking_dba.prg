CREATE PROGRAM dept_dup_checking:dba
 IF ((validate(edcf_request,- (1))=- (1)))
  DECLARE edcf_request = i2 WITH constant(0), persist
  DECLARE edcf_database = i2 WITH constant(1), persist
  DECLARE edcf_requestdatabase = i2 WITH constant(2), persist
 ENDIF
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 person_id = f8
    1 encntr_id = f8
    1 dup_checking_flag = i2
    1 order_list[*]
      2 order_id = f8
      2 order_tag = i2
      2 catalog_cd = f8
      2 cs_order_id = f8
      2 cs_comp_cnt = i4
      2 current_start_dt_tm = dq8
      2 priority_cd = f8
      2 accession = c20
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 order_list[*]
      2 order_id = f8
      2 order_tag = i2
      2 cs_order_id = f8
      2 cs_comp_cnt = i4
      2 catalog_cd = f8
      2 cancel_flag = i2
      2 dup_order_id = f8
      2 dup_catalog_cd = f8
      2 dup_priority_cd = f8
      2 dup_quantity = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  SET stat = alterlist(reply->order_list,0)
  SET stat = alter(reply->status_data.subeventstatus,1)
  CALL subevent_add("","","","")
  SET stat = alter(reply->status_data.subeventstatus,1)
 ENDIF
 RECORD dup_check(
   1 dup_check_max = i4
   1 order_list[*]
     2 dup_check_cnt = i4
     2 dup_check_list[*]
       3 dup_catalog_cd = f8
       3 priority_cd = f8
       3 minutes_ahead = i4
       3 minutes_behind = i4
       3 ahead_dt_tm = dq8
       3 behind_dt_tm = dq8
       3 dup_quantity = i4
 )
 DECLARE loaddupchecking(no_param=i2(value)) = i2 WITH private
 DECLARE requestdupchecking(no_param=i2(value)) = i2 WITH private
 DECLARE databasedupchecking(no_param=i2(value)) = i2 WITH private
 DECLARE request_dups = i2 WITH noconstant(0), private
 DECLARE database_dups = i2 WITH noconstant(0), private
 DECLARE ol_sze = i2 WITH constant(size(request->order_list,5)), public
#begin_script
 SET reqinfo->commit_ind = 0
 SET reply->status_data.status = "F"
 IF (ol_sze=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("REQUEST",reply->status_data.status,"REQUEST","No orders passed in request")
  GO TO exit_script
 ENDIF
 IF (((ol_sze > 1) OR ((request->dup_checking_flag=edcf_requestdatabase))) )
  IF (loaddupchecking(0)=0)
   GO TO exit_script
  ENDIF
  IF ((((request->dup_checking_flag=edcf_request)) OR ((request->dup_checking_flag=
  edcf_requestdatabase))) )
   SET request_dups = requestdupchecking(0)
  ENDIF
 ENDIF
 IF (request_dups=0
  AND database_dups=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SUBROUTINE loaddupchecking(no_param)
   SET stat = alterlist(reply->order_list,ol_sze)
   FOR (i = 1 TO size(reply->order_list,5))
     SET reply->order_list[i].order_id = request->order_list[i].order_id
     SET reply->order_list[i].cs_order_id = request->order_list[i].cs_order_id
     SET reply->order_list[i].cs_comp_cnt = request->order_list[i].cs_comp_cnt
     SET reply->order_list[i].catalog_cd = request->order_list[i].catalog_cd
     SET reply->order_list[i].order_tag = request->order_list[i].order_tag
   ENDFOR
   SELECT INTO "nl:"
    ddc.catalog_cd, ddc.dup_catalog_cd, ddc.priority_cd,
    ddc.minutes_ahead, ddc.minutes_behind, ddc.dup_quantity
    FROM (dummyt d1  WITH seq = value(ol_sze)),
     dept_dup_check ddc
    PLAN (d1)
     JOIN (ddc
     WHERE (ddc.catalog_cd=request->order_list[d1.seq].catalog_cd)
      AND ddc.priority_cd IN (0.0, request->order_list[d1.seq].priority_cd)
      AND ddc.active_ind=1
      AND ddc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ddc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY d1.seq, ddc.priority_cd DESC, ddc.dup_quantity
    HEAD REPORT
     stat = alterlist(dup_check->order_list,ol_sze)
    HEAD d1.seq
     dcl_cnt = 0
    DETAIL
     dcl_cnt = (dcl_cnt+ 1)
     IF (dcl_cnt > size(dup_check->order_list[d1.seq].dup_check_list,5))
      stat = alterlist(dup_check->order_list[d1.seq].dup_check_list,(dcl_cnt+ 10))
     ENDIF
     dup_check->order_list[d1.seq].dup_check_list[dcl_cnt].dup_catalog_cd = ddc.dup_catalog_cd,
     dup_check->order_list[d1.seq].dup_check_list[dcl_cnt].ahead_dt_tm = datetimeadd(request->
      order_list[d1.seq].current_start_dt_tm,(ddc.minutes_ahead/ 1440.0)), dup_check->order_list[d1
     .seq].dup_check_list[dcl_cnt].behind_dt_tm = datetimeadd(request->order_list[d1.seq].
      current_start_dt_tm,- ((ddc.minutes_behind/ 1440.0)))
    FOOT  d1.seq
     stat = alterlist(dup_check->order_list[d1.seq].dup_check_list,dcl_cnt), dup_check->order_list[d1
     .seq].dup_check_cnt = dcl_cnt
     IF ((dup_check->order_list[d1.seq].dup_check_cnt > dup_check->dup_check_max))
      dup_check->dup_check_max = dup_check->order_list[d1.seq].dup_check_cnt
     ENDIF
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   IF (size(dup_check->order_list,5)=0)
    SET reply->status_data.status = "Z"
    SET stat = subevent_add("SELECT",reply->status_data.status,"DEPT_DUP_CHECKING",
     "Duplicate checking not defined for orders in the request")
    RETURN(0)
   ENDIF
   IF ((((request->dup_checking_flag=edcf_request)) OR ((request->dup_checking_flag=
   edcf_requestdatabase))) )
    SELECT INTO "nl:"
     d1.seq, o.order_id, o.cs_order_id
     FROM (dummyt d1  WITH seq = value(ol_sze)),
      orders o
     PLAN (d1
      WHERE (reply->order_list[d1.seq].cs_order_id > 0)
       AND (reply->order_list[d1.seq].cs_comp_cnt=0))
      JOIN (o
      WHERE (o.cs_order_id=reply->order_list[d1.seq].cs_order_id))
     DETAIL
      reply->order_list[d1.seq].cs_comp_cnt = (reply->order_list[d1.seq].cs_comp_cnt+ 1)
     WITH nocounter
    ;end select
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE requestdupchecking(no_param)
   DECLARE tot_dup_cnt = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    d1.seq, d2.seq, d3.seq,
    priority_cd = request->order_list[d3.seq].priority_cd
    FROM (dummyt d1  WITH seq = value(ol_sze)),
     (dummyt d2  WITH seq = value(dup_check->dup_check_max)),
     (dummyt d3  WITH seq = value(ol_sze))
    PLAN (d1
     WHERE (dup_check->order_list[d1.seq].dup_check_cnt > 0))
     JOIN (d2
     WHERE (d2.seq <= dup_check->order_list[d1.seq].dup_check_cnt))
     JOIN (d3
     WHERE d1.seq != d3.seq
      AND cnvtdatetime(request->order_list[d3.seq].current_start_dt_tm) BETWEEN cnvtdatetime(
      dup_check->order_list[d1.seq].dup_check_list[d2.seq].behind_dt_tm) AND cnvtdatetime(dup_check->
      order_list[d1.seq].dup_check_list[d2.seq].ahead_dt_tm)
      AND (request->order_list[d3.seq].catalog_cd=dup_check->order_list[d1.seq].dup_check_list[d2.seq
     ].dup_catalog_cd))
    ORDER BY request->order_list[d1.seq].accession DESC, d1.seq DESC, d2.seq,
     priority_cd DESC
    HEAD d1.seq
     row + 0
    HEAD d2.seq
     row + 0
    HEAD priority_cd
     dup_cnt = 0
    DETAIL
     IF ((reply->order_list[d1.seq].cancel_flag=0)
      AND (reply->order_list[d3.seq].cancel_flag=0)
      AND (dup_check->order_list[d1.seq].dup_check_list[d2.seq].priority_cd IN (0.0, priority_cd)))
      IF ((reply->order_list[d1.seq].catalog_cd=reply->order_list[d3.seq].catalog_cd))
       IF ((reply->order_list[d1.seq].cs_comp_cnt <= reply->order_list[d3.seq].cs_comp_cnt))
        dup_cnt = (dup_cnt+ 1)
       ENDIF
      ELSE
       dup_cnt = (dup_cnt+ 1)
      ENDIF
     ENDIF
    FOOT  priority_cd
     IF ((dup_cnt > dup_check->order_list[d1.seq].dup_check_list[d2.seq].dup_quantity))
      reply->order_list[d1.seq].cancel_flag = 1, reply->order_list[d1.seq].dup_order_id = request->
      order_list[d3.seq].order_id, reply->order_list[d1.seq].dup_catalog_cd = request->order_list[d3
      .seq].catalog_cd,
      reply->order_list[d1.seq].dup_priority_cd = dup_check->order_list[d1.seq].dup_check_list[d2.seq
      ].priority_cd, reply->order_list[d1.seq].dup_quantity = dup_cnt, tot_dup_cnt = (tot_dup_cnt+ 1)
     ENDIF
    FOOT  d1.seq
     row + 0
    FOOT  d2.seq
     row + 0
    WITH nocounter
   ;end select
   RETURN(tot_dup_cnt)
 END ;Subroutine
 SUBROUTINE databasedupchecking(no_param)
   DECLARE tot_dup_cnt = i2 WITH noconstant(0), protect
   DECLARE ordered_cd = f8 WITH noconstant(0.0), protect
   DECLARE inprocess_cd = f8 WITH noconstant(0.0), protect
   DECLARE completed_cd = f8 WITH noconstant(0.0), protect
   SET stat = uar_get_meaning_by_codeset(6004,"ORDERED",1,ordered_cd)
   SET stat = uar_get_meaning_by_codeset(6004,"INPROCESS",1,inprocess_cd)
   SET stat = uar_get_meaning_by_codeset(6004,"COMPLETED",1,completed_cd)
   SELECT INTO "nl:"
    d1.seq, d2.seq, o.order_id,
    o.catalog_cd, o.current_start_dt_tm, ol.collection_priority_cd
    FROM (dummyt d1  WITH seq = value(ol_sze)),
     (dummyt d2  WITH seq = value(dup_check->dup_check_max)),
     orders o,
     order_laboratory ol
    PLAN (d1
     WHERE (reply->order_list[d1.seq].cancel_flag=0)
      AND (dup_check->order_list[d1.seq].dup_check_cnt > 0))
     JOIN (d2
     WHERE (d2.seq <= dup_check->order_list[d1.seq].dup_check_cnt))
     JOIN (o
     WHERE (o.person_id=request->person_id)
      AND ((o.encntr_id+ 0)=request->encntr_id)
      AND ((o.hide_flag+ 0)=0)
      AND o.current_start_dt_tm BETWEEN cnvtdatetime(dup_check->order_list[d1.seq].dup_check_list[d2
      .seq].behind_dt_tm) AND cnvtdatetime(dup_check->order_list[d1.seq].dup_check_list[d2.seq].
      ahead_dt_tm)
      AND ((o.catalog_cd+ 0)=dup_check->order_list[d1.seq].dup_check_list[d2.seq].dup_catalog_cd)
      AND ((o.order_status_cd+ 0) IN (ordered_cd, inprocess_cd, completed_cd)))
     JOIN (ol
     WHERE ol.order_id=o.order_id)
    ORDER BY d1.seq, d2.seq, ol.collection_priority_cd DESC
    HEAD d1.seq
     row + 0
    HEAD d2.seq
     row + 0
    HEAD ol.collection_priority_cd
     dup_cnt = 0
    DETAIL
     IF ((reply->order_list[d1.seq].cancel_flag=0)
      AND (o.order_id != reply->order_list[d1.seq].order_id)
      AND (dup_check->order_list[d1.seq].dup_check_list[d2.seq].priority_cd IN (0.0, ol
     .collection_priority_cd)))
      dup_cnt = (dup_cnt+ 1)
     ENDIF
    FOOT  ol.collection_priority_cd
     IF ((dup_cnt > dup_check->order_list[d1.seq].dup_check_list[d2.seq].dup_quantity))
      reply->order_list[d1.seq].cancel_flag = 2, reply->order_list[d1.seq].dup_order_id = o.order_id,
      reply->order_list[d1.seq].dup_catalog_cd = o.catalog_cd,
      reply->order_list[d1.seq].dup_priority_cd = dup_check->order_list[d1.seq].dup_check_list[d2.seq
      ].priority_cd, reply->order_list[d1.seq].dup_quantity = dup_cnt, tot_dup_cnt = (tot_dup_cnt+ 1)
     ENDIF
    FOOT  d2.seq
     row + 0
    FOOT  d1.seq
     row + 0
    WITH nocounter
   ;end select
   RETURN(tot_dup_cnt)
 END ;Subroutine
END GO
