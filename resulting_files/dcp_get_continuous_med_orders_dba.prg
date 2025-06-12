CREATE PROGRAM dcp_get_continuous_med_orders:dba
 RECORD reply(
   1 person_list[*]
     2 person_id = f8
     2 order_list[*]
       3 encntr_id = f8
       3 order_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 notify_display_line = vc
       3 order_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 med_order_type_cd = f8
       3 need_rx_verify_ind = i2
       3 need_nurse_review_ind = i2
       3 need_doctor_cosign_ind = i2
       3 order_status_cd = f8
       3 iv_ind = i2
       3 constant_ind = i2
       3 order_comment_ind = i2
       3 comment_type_mask = i4
       3 order_comment_text = vc
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 detail_list[*]
         4 oe_field_id = f8
         4 oe_field_value = f8
         4 oe_field_meaning = vc
         4 oe_field_meaning_id = f8
         4 oe_field_dt_tm_value = dq8
         4 oe_field_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 order_list[*]
     2 order_id = f8
     2 person_index = i4
     2 order_index = i4
   1 comment_list[*]
     2 order_index = i4
 )
 RECORD temp_request(
   1 person_list[*]
     2 person_id = f8
 )
 RECORD temp_orderdetail(
   1 order_list[*]
     2 order_id = f8
 )
 RECORD temp_ordercomments(
   1 comment_list[*]
     2 order_index = i4
 )
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE ordercnt = i4 WITH noconstant(0)
 DECLARE commentcnt = i4 WITH noconstant(0)
 DECLARE failure_ind = i2 WITH protect, noconstant(0)
 DECLARE patientcnt = i4 WITH public, noconstant(size(request->person_list,5))
 IF (patientcnt=0)
  SET failure_ind = 1
  GO TO failure
 ENDIF
 DECLARE loadorders(null) = null
 DECLARE loadorderdetails(null) = null
 DECLARE loadordercomments(null) = null
 DECLARE findorder(ord_id=f8) = i4
 IF (patientcnt > 0)
  CALL loadorders(null)
  IF (ordercnt > 0)
   CALL loadorderdetails(null)
   IF (commentcnt > 0)
    CALL loadordercomments(null)
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE loadorders(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(50)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   IF (patientcnt=0)
    SET failure_ind = 1
    GO TO failure
   ENDIF
   SET expand_total = (ceil((cnvtreal(patientcnt)/ expand_size)) * expand_size)
   DECLARE pharmacy_cd = f8 WITH noconstant(uar_get_code_by("MEANING",6000,"PHARMACY"))
   DECLARE ordered_cd = f8 WITH noconstant(uar_get_code_by("MEANING",6004,"ORDERED"))
   DECLARE med_order_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",18309,"IV"))
   DECLARE order_comment_mask = i4 WITH constant(1)
   SET stat = alterlist(reply->person_list,patientcnt)
   SET stat = alterlist(temp_request->person_list,expand_total)
   FOR (idx = 1 TO expand_total)
     IF (idx <= patientcnt)
      SET temp_request->person_list[idx].person_id = request->person_list[idx].person_id
     ELSE
      SET temp_request->person_list[idx].person_id = request->person_list[patientcnt].person_id
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM orders o,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (o
     WHERE expand(num,expand_start,expand_stop,o.person_id,temp_request->person_list[num].person_id)
      AND o.order_status_cd=ordered_cd
      AND o.catalog_type_cd=pharmacy_cd
      AND ((o.template_order_id+ 0)=0)
      AND o.template_order_flag IN (0, 1, 4)
      AND o.orderable_type_flag IN (0, 1, 8, 10, 11)
      AND o.med_order_type_cd=med_order_type_cd
      AND o.iv_ind=1
      AND o.orig_ord_as_flag IN (0, 5))
    ORDER BY o.person_id
    HEAD REPORT
     patient_cnt = 0
    HEAD o.person_id
     patient_cnt = (patient_cnt+ 1), patient_order_cnt = 0
    DETAIL
     patient_order_cnt = (patient_order_cnt+ 1)
     IF (mod(patient_order_cnt,10)=1)
      stat = alterlist(reply->person_list[patient_cnt].order_list,(patient_order_cnt+ 9))
     ENDIF
     reply->person_list[patient_cnt].person_id = o.person_id, reply->person_list[patient_cnt].
     order_list[patient_order_cnt].encntr_id = o.encntr_id, reply->person_list[patient_cnt].
     order_list[patient_order_cnt].order_id = o.order_id,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].catalog_cd = o.catalog_cd, reply->
     person_list[patient_cnt].order_list[patient_order_cnt].catalog_type_cd = o.catalog_type_cd,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].activity_type_cd = o
     .activity_type_cd,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].med_order_type_cd = o
     .med_order_type_cd, reply->person_list[patient_cnt].order_list[patient_order_cnt].
     need_rx_verify_ind = o.need_rx_verify_ind, reply->person_list[patient_cnt].order_list[
     patient_order_cnt].need_nurse_review_ind = o.need_nurse_review_ind,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].need_doctor_cosign_ind = o
     .need_doctor_cosign_ind, reply->person_list[patient_cnt].order_list[patient_order_cnt].
     order_status_cd = o.order_status_cd, reply->person_list[patient_cnt].order_list[
     patient_order_cnt].updt_id = o.updt_id,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].updt_dt_tm = cnvtdatetime(o
      .updt_dt_tm), reply->person_list[patient_cnt].order_list[patient_order_cnt].notify_display_line
      =
     IF (trim(o.clinical_display_line) > " ") o.clinical_display_line
     ELSE o.order_detail_display_line
     ENDIF
     , reply->person_list[patient_cnt].order_list[patient_order_cnt].hna_order_mnemonic = o
     .hna_order_mnemonic,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].order_mnemonic = o.order_mnemonic,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].ordered_as_mnemonic = o
     .ordered_as_mnemonic, reply->person_list[patient_cnt].order_list[patient_order_cnt].iv_ind = o
     .iv_ind,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].constant_ind = o.constant_ind,
     reply->person_list[patient_cnt].order_list[patient_order_cnt].order_comment_ind = o
     .order_comment_ind, reply->person_list[patient_cnt].order_list[patient_order_cnt].
     comment_type_mask = o.comment_type_mask,
     ordercnt = (ordercnt+ 1)
     IF (mod(ordercnt,100)=1)
      stat = alterlist(temp->order_list,(ordercnt+ 99))
     ENDIF
     temp->order_list[ordercnt].order_id = o.order_id, temp->order_list[ordercnt].person_index =
     patient_cnt, temp->order_list[ordercnt].order_index = patient_order_cnt
     IF (band(o.comment_type_mask,order_comment_mask)=order_comment_mask)
      commentcnt = (commentcnt+ 1)
      IF (mod(commentcnt,10)=1)
       stat = alterlist(temp->comment_list,(commentcnt+ 9))
      ENDIF
      temp->comment_list[commentcnt].order_index = ordercnt
     ENDIF
    FOOT  o.person_id
     stat = alterlist(reply->person_list[patient_cnt].order_list,patient_order_cnt)
    FOOT REPORT
     stat = alterlist(reply->person_list,patient_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadorderdetails(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(50)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE ordelistcnt = i4 WITH constant(size(temp->order_list,5))
   IF (ordelistcnt=0)
    SET failure_ind = 1
    GO TO failure
   ENDIF
   SET expand_total = (ceil((cnvtreal(ordelistcnt)/ expand_size)) * expand_size)
   SET stat = alterlist(temp_orderdetail->order_list,expand_total)
   FOR (idx = 1 TO expand_total)
     IF (idx <= ordelistcnt)
      SET temp_orderdetail->order_list[idx].order_id = temp->order_list[idx].order_id
     ELSE
      SET temp_orderdetail->order_list[idx].order_id = temp->order_list[ordelistcnt].order_id
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM order_detail od,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (od
     WHERE expand(num,expand_start,expand_stop,od.order_id,temp_orderdetail->order_list[num].order_id
      )
      AND od.oe_field_meaning_id IN (127, 43))
    ORDER BY od.order_id, od.action_sequence
    HEAD od.order_id
     detailcnt = 0, idx = findorder(od.order_id), pidx = temp->order_list[idx].person_index,
     oidx = temp->order_list[idx].order_index
    HEAD od.action_sequence
     detailcnt = 0
    DETAIL
     detailcnt = (detailcnt+ 1), stat = alterlist(reply->person_list[pidx].order_list[oidx].
      detail_list,detailcnt), reply->person_list[pidx].order_list[oidx].detail_list[detailcnt].
     oe_field_id = od.oe_field_id,
     reply->person_list[pidx].order_list[oidx].detail_list[detailcnt].oe_field_value = od
     .oe_field_value, reply->person_list[pidx].order_list[oidx].detail_list[detailcnt].
     oe_field_meaning = od.oe_field_meaning, reply->person_list[pidx].order_list[oidx].detail_list[
     detailcnt].oe_field_meaning_id = od.oe_field_meaning_id,
     reply->person_list[pidx].order_list[oidx].detail_list[detailcnt].oe_field_dt_tm_value = od
     .oe_field_dt_tm_value, reply->person_list[pidx].order_list[oidx].detail_list[detailcnt].
     oe_field_tz = od.oe_field_tz
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadordercomments(null)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE expand_size = i4 WITH protect, constant(50)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE expand_stop = i4 WITH protect, noconstant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
   DECLARE order_comment_mask = i4 WITH constant(1)
   DECLARE ordercomments = i4 WITH constant(size(temp->comment_list,5))
   IF (ordercomments=0)
    SET failure_ind = 1
    GO TO failure
   ENDIF
   SET expand_total = (ceil((cnvtreal(ordercomments)/ expand_size)) * expand_size)
   SET stat = alterlist(temp_ordercomments->comment_list,expand_total)
   FOR (idx = 1 TO expand_total)
     IF (idx <= ordercomments)
      SET temp_ordercomments->comment_list[idx].order_index = temp->comment_list[idx].order_index
     ELSE
      SET temp_ordercomments->comment_list[idx].order_index = temp->comment_list[ordercomments].
      order_index
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM order_comment oc,
     long_text lt,
     (dummyt d  WITH seq = value((expand_total/ expand_size)))
    PLAN (d
     WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
      AND assign(expand_stop,(expand_start+ (expand_size - 1))))
     JOIN (oc
     WHERE expand(num,expand_start,expand_stop,oc.order_id,temp->order_list[temp_ordercomments->
      comment_list[num].order_index].order_id)
      AND oc.comment_type_cd=order_comment_cd)
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    ORDER BY oc.order_id, oc.action_sequence
    FOOT  oc.order_id
     IF (lt.long_text_id > 0)
      idx = findorder(oc.order_id), pidx = temp->order_list[idx].person_index, oidx = temp->
      order_list[idx].order_index,
      reply->person_list[pidx].order_list[oidx].order_comment_text = lt.long_text
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE findorder(ord_id)
   DECLARE f = i4 WITH noconstant(0)
   FOR (f = 1 TO ordercnt)
     IF ((temp->order_list[f].order_id=ord_id))
      RETURN(f)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 IF (ordercnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#failure
 IF (failure_ind=1)
  SET reply->status_data.status = "F"
 ENDIF
 FREE SET temp
 FREE SET temp_request
 FREE SET temp_orderdetail
 FREE SET temp_ordercomments
END GO
