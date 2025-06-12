CREATE PROGRAM bsc_ce_event_query_order:dba
 RECORD reply(
   1 error_code = f8
   1 error_msg = vc
   1 event_list[*]
     2 event_id = f8
     2 parent_event_id = f8
     2 catalog_cd = f8
     2 event_cd = f8
     2 collating_seq = vc
     2 order_id = f8
     2 template_order_id = f8
     2 event_title_text = vc
     2 clinical_event_id = f8
     2 med_result_list[*]
       3 admin_start_dt_tm = dq8
       3 dosage_unit_cd = f8
       3 initial_volume = f8
       3 initial_dosage = f8
       3 infused_volume_unit_cd = f8
       3 iv_event_cd = f8
       3 updt_dt_tm = dq8
       3 substance_lot_number = vc
       3 infusion_rate = f8
       3 infusion_unit_cd = f8
       3 admin_site_cd = f8
       3 admin_dosage = f8
       3 admin_start_tz = i4
     2 order_action_sequence = i4
     2 encntr_id = f8
     2 event_start_dt_tm = dq8
     2 event_end_dt_tm = dq8
     2 event_end_tz = i4
     2 result_status_cd = f8
     2 event_class_cd = f8
     2 child_event_list[*]
       3 event_cd = f8
       3 parent_event_id = f8
       3 event_id = f8
       3 catalog_cd = f8
       3 collating_seq = vc
       3 comp_sequence = i4
       3 order_id = f8
       3 template_order_id = f8
       3 event_title_text = vc
       3 clinical_event_id = f8
       3 result_status_cd = f8
       3 event_class_cd = f8
       3 med_result_list[*]
         4 synonym_id = f8
         4 initial_volume = f8
         4 infused_volume_unit_cd = f8
         4 infusion_rate = f8
         4 infusion_unit_cd = f8
         4 initial_dosage = f8
         4 dosage_unit_cd = f8
         4 admin_start_dt_tm = dq8
         4 admin_start_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD childrenevents
 RECORD childrenevents(
   1 event_list[*]
     2 event_id = f8
     2 parent_event_id = f8
     2 catalog_cd = f8
     2 event_cd = f8
     2 collating_seq = vc
     2 comp_sequence = i4
     2 order_id = f8
     2 template_order_id = f8
     2 event_title_text = vc
     2 clinical_event_id = f8
     2 result_status_cd = f8
     2 event_class_cd = f8
     2 med_result_list[*]
       3 synonym_id = f8
       3 initial_volume = f8
       3 infused_volume_unit_cd = f8
       3 infusion_rate = f8
       3 infusion_unit_cd = f8
       3 initial_dosage = f8
       3 dosage_unit_cd = f8
       3 admin_start_dt_tm = dq8
       3 admin_start_tz = i4
 )
 DECLARE initialize(null) = null
 DECLARE loadevents(null) = null
 DECLARE loadcompseq(null) = null
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 DECLARE event_class_placeholder = f8 WITH noconstant(0.0)
 DECLARE list_nsize = i2 WITH constant(25)
 DECLARE order_size = i4 WITH constant(size(request->order_id_list,5))
 DECLARE iv_size = i4 WITH constant(size(request->iv_event_cd_list,5))
 DECLARE status_size = i4 WITH constant(size(request->status_cd_exclude_list,5))
 DECLARE encntr_size = i4 WITH protect, noconstant(size(request->encntr_list,5))
 DECLARE encntr_ndx = i4 WITH protect, noconstant(1)
 DECLARE status_ndx = i4 WITH protect, noconstant(1)
 DECLARE order_ndx = i4 WITH protect, noconstant(1)
 DECLARE order_nstart = i4 WITH protect, noconstant(1)
 DECLARE encntr_nstart = i4 WITH protect, noconstant(1)
 DECLARE status_nstart = i4 WITH protect, noconstant(1)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE loop_count = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH protect, noconstant(0)
 DECLARE iv_cnt = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant(" ")
 DECLARE error_code = i4 WITH protect, noconstant(0)
 DECLARE max_child_events = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c12 WITH protect, noconstant(fillstring(12," "))
 IF (order_size > 0)
  CALL initialize(null)
  CALL loadevents(null)
  IF ((request->children_flag=1)
   AND (request->pop_seq_flag=1))
   CALL loadcompseq(null)
  ENDIF
 ENDIF
 SUBROUTINE initialize(null)
   CALL echo("********bsc_ce_event_query_order: Initialize********")
   SET loop_count = ceil((cnvtreal(order_size)/ list_nsize))
   SET new_size = (loop_count * list_nsize)
   SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
   SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,event_class_placeholder)
   IF (new_size > order_size)
    SET stat = alterlist(request->order_id_list,new_size)
    FOR (i = (order_size+ 1) TO new_size)
      SET request->order_id_list[i].order_id = request->order_id_list[order_size].order_id
    ENDFOR
   ENDIF
   IF (encntr_size > 0)
    SET stat = alterlist(request->encntr_list,(encntr_size+ 1))
    SET request->encntr_list[(encntr_size+ 1)].encntr_id = 0.0
    SET encntr_size += 1
   ENDIF
   SET encntr_loop_count = ceil((cnvtreal(encntr_size)/ list_nsize))
   SET encntr_new_size = (encntr_loop_count * list_nsize)
   IF (encntr_new_size > encntr_size)
    SET stat = alterlist(request->encntr_list,encntr_new_size)
    FOR (i = (encntr_size+ 1) TO encntr_new_size)
      SET request->encntr_list[i].encntr_id = request->encntr_list[encntr_size].encntr_id
    ENDFOR
   ENDIF
   IF (validate(request->use_ord_start_dt_tm_ind))
    IF ((request->use_ord_start_dt_tm_ind=1))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = order_size),
       orders o
      PLAN (d)
       JOIN (o
       WHERE (o.order_id=request->order_id_list[d.seq].order_id))
      HEAD REPORT
       request->search_begin_dt_tm = o.current_start_dt_tm
      DETAIL
       IF ((request->search_begin_dt_tm > o.current_start_dt_tm))
        request->search_begin_dt_tm = o.current_start_dt_tm
       ENDIF
      WITH nocounter
     ;end select
     SET request->search_begin_dt_tm = datetimeadd(request->search_begin_dt_tm,- (1))
     SET request->search_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE loadevents(null)
   CALL echo("********bsc_ce_event_query_order: LoadEvents********")
   SET order_ndx = 1
   SET order_nstart = 1
   SELECT
    IF (encntr_size > 0)
     FROM ce_event_order_link ol,
      clinical_event ce,
      ce_med_result cm,
      (dummyt d1  WITH seq = iv_size),
      (dummyt d2  WITH seq = value(loop_count))
     PLAN (d1)
      JOIN (d2
      WHERE assign(order_nstart,evaluate(d2.seq,1,1,(order_nstart+ list_nsize))))
      JOIN (ol
      WHERE expand(order_ndx,order_nstart,((order_nstart+ list_nsize) - 1),ol.order_id,request->
       order_id_list[order_ndx].order_id)
       AND ol.event_end_dt_tm <= cnvtdatetimeutc(request->search_end_dt_tm)
       AND ol.event_end_dt_tm >= cnvtdatetimeutc(request->search_begin_dt_tm)
       AND ol.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
      JOIN (ce
      WHERE (ce.event_id=(ol.event_id+ 0))
       AND ce.record_status_cd != record_status_deleted
       AND ce.event_class_cd != event_class_placeholder
       AND ce.view_level > 0
       AND ce.publish_flag=1
       AND ((ce.person_id+ 0)=request->person_id)
       AND ce.event_end_dt_tm <= cnvtdatetimeutc(request->search_end_dt_tm)
       AND ce.event_end_dt_tm >= cnvtdatetimeutc(request->search_begin_dt_tm)
       AND ce.valid_until_dt_tm=ol.valid_until_dt_tm
       AND expand(encntr_ndx,encntr_nstart,encntr_size,(ce.encntr_id+ 0),request->encntr_list[
       encntr_ndx].encntr_id)
       AND  NOT (expand(status_ndx,status_nstart,status_size,ce.result_status_cd,request->
       status_cd_exclude_list[status_ndx].result_status_cd)))
      JOIN (cm
      WHERE (cm.event_id=(ce.event_id+ 0))
       AND cm.valid_until_dt_tm=ol.valid_until_dt_tm
       AND (cm.iv_event_cd=request->iv_event_cd_list[d1.seq].iv_event_cd))
    ELSEIF (validate(request->multi_patient_ind))
     FROM ce_event_order_link ol,
      clinical_event ce,
      ce_med_result cm,
      (dummyt d1  WITH seq = iv_size),
      (dummyt d2  WITH seq = value(loop_count))
     PLAN (d1)
      JOIN (d2
      WHERE assign(order_nstart,evaluate(d2.seq,1,1,(order_nstart+ list_nsize))))
      JOIN (ol
      WHERE expand(order_ndx,order_nstart,((order_nstart+ list_nsize) - 1),ol.order_id,request->
       order_id_list[order_ndx].order_id)
       AND ol.event_end_dt_tm <= cnvtdatetimeutc(request->search_end_dt_tm)
       AND ol.event_end_dt_tm >= cnvtdatetimeutc(request->search_begin_dt_tm)
       AND ol.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
      JOIN (ce
      WHERE (ce.event_id=(ol.event_id+ 0))
       AND ce.record_status_cd != record_status_deleted
       AND ce.event_class_cd != event_class_placeholder
       AND ce.view_level > 0
       AND ce.publish_flag=1
       AND ce.event_end_dt_tm <= cnvtdatetimeutc(request->search_end_dt_tm)
       AND ce.event_end_dt_tm >= cnvtdatetimeutc(request->search_begin_dt_tm)
       AND ce.valid_until_dt_tm=ol.valid_until_dt_tm
       AND  NOT (expand(status_ndx,status_nstart,status_size,ce.result_status_cd,request->
       status_cd_exclude_list[status_ndx].result_status_cd)))
      JOIN (cm
      WHERE (cm.event_id=(ce.event_id+ 0))
       AND cm.valid_until_dt_tm=ol.valid_until_dt_tm
       AND (cm.iv_event_cd=request->iv_event_cd_list[d1.seq].iv_event_cd))
    ELSE
     FROM ce_event_order_link ol,
      clinical_event ce,
      ce_med_result cm,
      (dummyt d1  WITH seq = iv_size),
      (dummyt d2  WITH seq = value(loop_count))
     PLAN (d1)
      JOIN (d2
      WHERE assign(order_nstart,evaluate(d2.seq,1,1,(order_nstart+ list_nsize))))
      JOIN (ol
      WHERE expand(order_ndx,order_nstart,((order_nstart+ list_nsize) - 1),ol.order_id,request->
       order_id_list[order_ndx].order_id)
       AND ol.event_end_dt_tm <= cnvtdatetimeutc(request->search_end_dt_tm)
       AND ol.event_end_dt_tm >= cnvtdatetimeutc(request->search_begin_dt_tm)
       AND ol.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
      JOIN (ce
      WHERE (ce.event_id=(ol.event_id+ 0))
       AND ce.record_status_cd != record_status_deleted
       AND ce.event_class_cd != event_class_placeholder
       AND ce.view_level > 0
       AND ce.publish_flag=1
       AND ((ce.person_id+ 0)=request->person_id)
       AND ce.event_end_dt_tm <= cnvtdatetimeutc(request->search_end_dt_tm)
       AND ce.event_end_dt_tm >= cnvtdatetimeutc(request->search_begin_dt_tm)
       AND ce.valid_until_dt_tm=ol.valid_until_dt_tm
       AND  NOT (expand(status_ndx,status_nstart,status_size,ce.result_status_cd,request->
       status_cd_exclude_list[status_ndx].result_status_cd)))
      JOIN (cm
      WHERE (cm.event_id=(ce.event_id+ 0))
       AND cm.valid_until_dt_tm=ol.valid_until_dt_tm
       AND (cm.iv_event_cd=request->iv_event_cd_list[d1.seq].iv_event_cd))
    ENDIF
    INTO "nl:"
    ce.event_id, ce.parent_event_id, ce.catalog_cd,
    ce.event_cd, ce.collating_seq, ce.order_id,
    ce.event_title_text, ce.clinical_event_id, ce.event_end_tz,
    cm.admin_start_dt_tm, cm.dosage_unit_cd, cm.initial_volume,
    cm.initial_dosage, cm.iv_event_cd, cm.infused_volume_unit_cd
    ORDER BY ce.event_end_dt_tm DESC, ce.event_id, cm.admin_start_dt_tm DESC
    HEAD REPORT
     cnt = 0, child_cnt = 0, children_cnt = 0
    HEAD ce.event_id
     iv_cnt = 1
     IF ((((request->children_flag=0)) OR ((request->children_flag=1)
      AND ce.event_id=ce.parent_event_id)) )
      cnt += 1
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->event_list,(cnt+ 9))
      ENDIF
      reply->event_list[cnt].event_id = ce.event_id, reply->event_list[cnt].parent_event_id = ce
      .parent_event_id, reply->event_list[cnt].catalog_cd = ce.catalog_cd,
      reply->event_list[cnt].event_cd = ce.event_cd, reply->event_list[cnt].collating_seq = ce
      .collating_seq, reply->event_list[cnt].order_id = ce.order_id,
      reply->event_list[cnt].event_title_text = ce.event_title_text, reply->event_list[cnt].
      clinical_event_id = ce.clinical_event_id, reply->event_list[cnt].order_action_sequence = ce
      .order_action_sequence,
      reply->event_list[cnt].encntr_id = ce.encntr_id, reply->event_list[cnt].event_start_dt_tm = ce
      .event_start_dt_tm, reply->event_list[cnt].event_end_dt_tm = ce.event_end_dt_tm,
      reply->event_list[cnt].event_end_tz = ce.event_end_tz, stat = assign(validate(reply->
        event_list[cnt].event_class_cd),ce.event_class_cd), stat = assign(validate(reply->event_list[
        cnt].result_status_cd),ce.result_status_cd)
      IF (ol.parent_order_ident=ol.order_id)
       stat = assign(validate(reply->event_list[cnt].template_order_id),0.00)
      ELSE
       stat = assign(validate(reply->event_list[cnt].template_order_id),ol.parent_order_ident)
      ENDIF
     ELSE
      child_cnt += 1
      IF (mod(child_cnt,10)=1)
       stat = alterlist(childrenevents->event_list,(child_cnt+ 9))
      ENDIF
      childrenevents->event_list[child_cnt].event_id = ce.event_id, childrenevents->event_list[
      child_cnt].event_cd = ce.event_cd, childrenevents->event_list[child_cnt].catalog_cd = ce
      .catalog_cd,
      childrenevents->event_list[child_cnt].parent_event_id = ce.parent_event_id, childrenevents->
      event_list[child_cnt].collating_seq = ce.collating_seq, childrenevents->event_list[child_cnt].
      order_id = ce.order_id,
      childrenevents->event_list[child_cnt].event_title_text = ce.event_title_text, childrenevents->
      event_list[child_cnt].clinical_event_id = ce.clinical_event_id, stat = assign(validate(
        childrenevents->event_list[child_cnt].event_class_cd),ce.event_class_cd),
      stat = assign(validate(childrenevents->event_list[child_cnt].result_status_cd),ce
       .result_status_cd)
      IF (ol.parent_order_ident=ol.order_id)
       stat = assign(validate(childrenevents->event_list[child_cnt].template_order_id),0.00)
      ELSE
       stat = assign(validate(childrenevents->event_list[child_cnt].template_order_id),ol
        .parent_order_ident)
      ENDIF
     ENDIF
    HEAD cm.admin_start_dt_tm
     IF (iv_cnt=1)
      IF ((((request->children_flag=0)) OR ((request->children_flag=1)
       AND ce.event_id=ce.parent_event_id)) )
       stat = alterlist(reply->event_list[cnt].med_result_list,1), reply->event_list[cnt].
       med_result_list[iv_cnt].admin_start_dt_tm = cm.admin_start_dt_tm, reply->event_list[cnt].
       med_result_list[iv_cnt].dosage_unit_cd = cm.dosage_unit_cd,
       reply->event_list[cnt].med_result_list[iv_cnt].initial_volume = cm.initial_volume, reply->
       event_list[cnt].med_result_list[iv_cnt].initial_dosage = cm.initial_dosage, reply->event_list[
       cnt].med_result_list[iv_cnt].infused_volume_unit_cd = cm.infused_volume_unit_cd,
       reply->event_list[cnt].med_result_list[iv_cnt].iv_event_cd = cm.iv_event_cd, reply->
       event_list[cnt].med_result_list[iv_cnt].updt_dt_tm = cm.updt_dt_tm, reply->event_list[cnt].
       med_result_list[iv_cnt].substance_lot_number = cm.substance_lot_number,
       reply->event_list[cnt].med_result_list[iv_cnt].infusion_rate = cm.infusion_rate, reply->
       event_list[cnt].med_result_list[iv_cnt].infusion_unit_cd = cm.infusion_unit_cd, reply->
       event_list[cnt].med_result_list[iv_cnt].admin_site_cd = cm.admin_site_cd,
       reply->event_list[cnt].med_result_list[iv_cnt].admin_dosage = cm.admin_dosage, stat = assign(
        validate(reply->event_list[cnt].med_result_list[iv_cnt].admin_start_tz),cm.admin_start_tz)
      ELSE
       stat = alterlist(childrenevents->event_list[child_cnt].med_result_list,1), childrenevents->
       event_list[child_cnt].med_result_list[iv_cnt].synonym_id = cm.synonym_id, childrenevents->
       event_list[child_cnt].med_result_list[iv_cnt].initial_volume = cm.initial_volume,
       childrenevents->event_list[child_cnt].med_result_list[iv_cnt].infused_volume_unit_cd = cm
       .infused_volume_unit_cd, childrenevents->event_list[child_cnt].med_result_list[iv_cnt].
       infusion_rate = cm.infusion_rate, childrenevents->event_list[child_cnt].med_result_list[iv_cnt
       ].infusion_unit_cd = cm.infusion_unit_cd,
       childrenevents->event_list[child_cnt].med_result_list[iv_cnt].initial_dosage = cm
       .initial_dosage, childrenevents->event_list[child_cnt].med_result_list[iv_cnt].dosage_unit_cd
        = cm.dosage_unit_cd, childrenevents->event_list[child_cnt].med_result_list[iv_cnt].
       admin_start_dt_tm = cm.admin_start_dt_tm,
       stat = assign(validate(childrenevents->event_list[child_cnt].med_result_list[iv_cnt].
         admin_start_tz),cm.admin_start_tz)
      ENDIF
      iv_cnt += 1
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->event_list,cnt), stat = alterlist(childrenevents->event_list,child_cnt)
     IF ((request->children_flag=1))
      FOR (i = 1 TO cnt BY 1)
       children = 0,
       FOR (j = 1 TO child_cnt BY 1)
         IF ((reply->event_list[i].parent_event_id=childrenevents->event_list[j].parent_event_id))
          children += 1
          IF (children > max_child_events)
           max_child_events = children
          ENDIF
          stat = alterlist(reply->event_list[i].child_event_list,children), reply->event_list[i].
          child_event_list[children].catalog_cd = childrenevents->event_list[j].catalog_cd, reply->
          event_list[i].child_event_list[children].event_cd = childrenevents->event_list[j].event_cd,
          reply->event_list[i].child_event_list[children].event_id = childrenevents->event_list[j].
          event_id, reply->event_list[i].child_event_list[children].parent_event_id = childrenevents
          ->event_list[j].parent_event_id, reply->event_list[i].child_event_list[children].
          collating_seq = childrenevents->event_list[j].collating_seq,
          reply->event_list[i].child_event_list[children].order_id = childrenevents->event_list[j].
          order_id, reply->event_list[i].child_event_list[children].event_title_text = childrenevents
          ->event_list[j].event_title_text, reply->event_list[i].child_event_list[children].
          clinical_event_id = childrenevents->event_list[j].clinical_event_id,
          stat = assign(validate(reply->event_list[i].child_event_list[children].event_class_cd),
           validate(childrenevents->event_list[j].event_class_cd,0.00)), stat = assign(validate(reply
            ->event_list[i].child_event_list[children].result_status_cd),validate(childrenevents->
            event_list[j].result_status_cd,0.00)), stat = assign(validate(reply->event_list[i].
            child_event_list[children].template_order_id),validate(childrenevents->event_list[j].
            template_order_id,0.00)),
          stat = alterlist(reply->event_list[i].child_event_list[children].med_result_list,1), reply
          ->event_list[i].child_event_list[children].med_result_list[1].dosage_unit_cd =
          childrenevents->event_list[j].med_result_list[1].dosage_unit_cd, reply->event_list[i].
          child_event_list[children].med_result_list[1].infused_volume_unit_cd = childrenevents->
          event_list[j].med_result_list[1].infused_volume_unit_cd,
          reply->event_list[i].child_event_list[children].med_result_list[1].infusion_rate =
          childrenevents->event_list[j].med_result_list[1].infusion_rate, reply->event_list[i].
          child_event_list[children].med_result_list[1].infusion_unit_cd = childrenevents->
          event_list[j].med_result_list[1].infusion_unit_cd, reply->event_list[i].child_event_list[
          children].med_result_list[1].initial_dosage = childrenevents->event_list[j].
          med_result_list[1].initial_dosage,
          reply->event_list[i].child_event_list[children].med_result_list[1].initial_volume =
          childrenevents->event_list[j].med_result_list[1].initial_volume, reply->event_list[i].
          child_event_list[children].med_result_list[1].synonym_id = childrenevents->event_list[j].
          med_result_list[1].synonym_id, reply->event_list[i].child_event_list[children].
          med_result_list[1].admin_start_dt_tm = childrenevents->event_list[j].med_result_list[1].
          admin_start_dt_tm,
          stat = assign(validate(reply->event_list[i].child_event_list[children].med_result_list[1].
            admin_start_tz),validate(childrenevents->event_list[j].med_result_list[1].admin_start_tz,
            0.00))
         ENDIF
       ENDFOR
      ENDFOR
     ENDIF
    WITH memsort
   ;end select
 END ;Subroutine
 SUBROUTINE loadcompseq(null)
   CALL echo("********bsc_ce_event_query_order: LoadCompSeq********")
   DECLARE dummy_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM order_ingredient oi,
     (dummyt devents  WITH seq = value(size(reply->event_list,5))),
     (dummyt dchildevents  WITH seq = value(max_child_events))
    PLAN (devents)
     JOIN (dchildevents
     WHERE dchildevents.seq <= cnvtint(size(reply->event_list[devents.seq].child_event_list,5)))
     JOIN (oi
     WHERE (oi.order_id=reply->event_list[devents.seq].order_id)
      AND (oi.action_sequence=reply->event_list[devents.seq].order_action_sequence)
      AND (oi.catalog_cd=reply->event_list[devents.seq].child_event_list[dchildevents.seq].catalog_cd
     ))
    DETAIL
     reply->event_list[devents.seq].child_event_list[dchildevents.seq].comp_sequence = oi
     .comp_sequence
    WITH nocounter
   ;end select
 END ;Subroutine
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 IF (error_code=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 SET last_mod = "004 01/10/23"
 FREE RECORD childrenevents
END GO
