CREATE PROGRAM dcp_get_order_task_dta:dba
 RECORD reply(
   1 catalog_cnt = i2
   1 catalog[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_desc = c60
     2 catalog_type_mean = vc
     2 activity_type_cd = f8
     2 task_catalog_cd = f8
     2 cont_order_method_flag = i2
     2 primary_mnemonic = vc
     2 event_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 task_cnt = i2
     2 tasks[*]
       3 task_seq = f8
       3 task_type_flag = i2
       3 prim_task_ind = i2
       3 ref_task_id = f8
       3 task_description = vc
       3 task_description_key = vc
       3 task_type_cd = f8
       3 task_type_disp = c40
       3 task_type_desc = c60
       3 task_type_mean = vc
       3 assay_cnt = i2
       3 assay[*]
         4 task_assay_cd = f8
         4 sequence = i4
         4 pend_req_ind = i2
         4 mnemonic = vc
         4 mnemonic_key = vc
         4 activity_type_cd = f8
         4 event_cd = f8
         4 desc = vc
   1 order_cnt = i2
   1 orders[*]
     2 order_id = f8
     2 order_mnemonic = vc
     2 encntr_id = f8
     2 person_id = f8
     2 catalog_cd = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_desc = c60
     2 order_status_mean = vc
     2 last_action_sequence = i4
     2 template_core_action_sequence = i4
     2 display_line = vc
     2 last_update_provider_id = f8
     2 med_order_type_cd = f8
     2 constant_ind = i2
     2 prn_ind = i2
     2 freq_type_flag = i2
     2 order_comment_ind = i2
     2 comment_type_mask = i4
     2 order_comment_text = vc
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 stop_type_cd = f8
     2 ingredient_ind = i2
     2 template_order_flag = i2
     2 template_order_id = f8
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 orig_ord_as_flag = i2
     2 orderable_type_flag = i2
     2 need_rx_verify_ind = i2
     2 need_nurse_review_ind = i2
     2 need_renew_ind = i2
     2 hide_flag = i2
     2 quantity = f8
     2 str = f8
     2 str_unit_cd = f8
     2 str_unit_disp = vc
     2 vol = f8
     2 vol_unit_cd = f8
     2 vol_unit_disp = vc
     2 freetxtdose = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->catalog_cnt = 0
 SET reply->order_cnt = 0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET pharmacy_cd = 0.0
 SET hard_stop_cd = 0.0
 SET soft_stop_cd = 0.0
 SET med_types_cnt = cnvtint(size(request->med_type_list,5))
 SET encntr_cnt = cnvtint(size(request->encntr_list,5))
 SET zero_ind = 0
 SET renew_look_back = 24
 SET overdue_look_back = 10
 DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE order_comment_mask = i4 WITH constant(1)
 SET canceled_cd = 0.0
 SET completed_cd = 0.0
 SET deleted_cd = 0.0
 SET discontinued_cd = 0.0
 SET trans_cancel_cd = 0.0
 SET voidedwrslt_cd = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET code_set = 4009
 SET cdf_meaning = "HARD"
 EXECUTE cpm_get_cd_for_cdf
 SET hard_stop_cd = code_value
 SET code_set = 4009
 SET cdf_meaning = "SOFT"
 EXECUTE cpm_get_cd_for_cdf
 SET soft_stop_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "COMPLETED"
 EXECUTE cpm_get_cd_for_cdf
 SET completed_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "DISCONTINUED"
 EXECUTE cpm_get_cd_for_cdf
 SET discontinued_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "TRANS/CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET trans_cancel_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "VOIDEDWRSLT"
 EXECUTE cpm_get_cd_for_cdf
 SET voidedwrslt_cd = code_value
 SELECT INTO "nl:"
  FROM name_value_prefs n
  PLAN (n
   WHERE ((n.pvc_name="RENEW_LOOK_BACK_HOURS") OR (n.pvc_name="OVERDUE_LOOK_BACK_DAYS")) )
  DETAIL
   IF (n.pvc_name="RENEW_LOOK_BACK_HOURS")
    renew_look_back = cnvtint(n.pvc_value)
   ELSEIF (n.pvc_name="OVERDUE_LOOK_BACK_DAYS")
    overdue_look_back = cnvtint(n.pvc_value)
   ENDIF
  WITH nocounter
 ;end select
 SET current_dt_tm = cnvtdatetime(curdate,curtime)
 SET interval = build(renew_look_back,"h")
 SET renew_dt_tm = cnvtlookahead(interval,cnvtdatetime(current_dt_tm))
 SET begin_dt_tm = cnvtdatetime((curdate - overdue_look_back),curtime)
 IF (cnvtdatetime(begin_dt_tm) > cnvtdatetime(request->start_dt_tm))
  SET begin_dt_tm = cnvtdatetime(request->start_dt_tm)
 ENDIF
 IF ((request->person_id > 0))
  SET count1 = 0
  SET count2 = 0
  SET max_person_id = 0
  SET prsnl_id_high = 0
  SET prsnl_id_low = 0
 ELSE
  SET zero_ind = 1
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SET med_type_in_clause = fillstring(5000," ")
 IF (med_types_cnt > 0)
  SET med_type_in_clause = concat(" o.med_order_type_cd in (",trim(cnvtstring(request->med_type_list[
     1].med_order_type_cd,20,2)))
  FOR (cnt = 2 TO med_types_cnt)
    SET med_type_in_clause = concat(trim(med_type_in_clause),",",trim(cnvtstring(request->
       med_type_list[cnt].med_order_type_cd,20,2)))
  ENDFOR
  SET med_type_in_clause = concat(trim(med_type_in_clause),")")
 ELSEIF (med_types_cnt=0)
  SET med_type_in_clause = concat(trim(med_type_in_clause),"0=0")
 ENDIF
 SET encntr_in_clause = fillstring(5000," ")
 IF (encntr_cnt > 0)
  SET encntr_in_clause = concat(" o.encntr_id in (",trim(cnvtstring(request->encntr_list[1].encntr_id,
     20,2)))
  FOR (cnt = 2 TO encntr_cnt)
    SET encntr_in_clause = concat(trim(encntr_in_clause),",",trim(cnvtstring(request->encntr_list[cnt
       ].encntr_id,20,2)))
  ENDFOR
  SET encntr_in_clause = concat(trim(encntr_in_clause),")")
 ELSEIF (encntr_cnt=0)
  SET encntr_in_clause = concat(trim(encntr_in_clause),"0=0")
 ENDIF
 SELECT INTO "nl:"
  o.catalog_cd, o.order_id, oc.seq
  FROM orders o,
   orders ot,
   order_ingredient oi,
   order_catalog oc
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.projected_stop_dt_tm >= cnvtdatetime(begin_dt_tm)
    AND o.catalog_type_cd=pharmacy_cd
    AND ((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
   trans_cancel_cd,
   voidedwrslt_cd))
    AND ((o.template_order_flag+ 0) IN (0, 1, 4))
    AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
    AND parser(med_type_in_clause)
    AND parser(encntr_in_clause)
    AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm))
   JOIN (ot
   WHERE ot.order_id=o.template_order_id)
   JOIN (oi
   WHERE o.order_id=oi.order_id
    AND oi.action_sequence=1
    AND oi.comp_sequence=1)
   JOIN (oc
   WHERE oi.catalog_cd=oc.catalog_cd)
  ORDER BY o.catalog_cd
  HEAD REPORT
   count1 = 0, count2 = 0
  HEAD o.catalog_cd
   count1 = (count1+ 1)
   IF (count1 > size(reply->catalog,5))
    stat = alterlist(reply->catalog,(count1+ 20))
   ENDIF
   reply->catalog[count1].catalog_cd = o.catalog_cd, reply->catalog[count1].catalog_type_cd = o
   .catalog_type_cd, reply->catalog[count1].activity_type_cd = o.activity_type_cd,
   reply->catalog[count1].task_catalog_cd = oc.catalog_cd, reply->catalog[count1].
   cont_order_method_flag = oc.cont_order_method_flag, reply->catalog[count1].primary_mnemonic = oc
   .primary_mnemonic,
   reply->catalog[count1].ref_text_mask = oc.ref_text_mask, reply->catalog[count1].cki = oc.cki
  DETAIL
   IF (((o.template_order_flag IN (1, 0)
    AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
    start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) ) OR (o.template_order_flag=4
    AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((o.projected_stop_dt_tm=null) OR (o.projected_stop_dt_tm >= cnvtdatetime(request->
    start_dt_tm))) )) )
    count2 = (count2+ 1)
    IF (count2 > size(reply->orders,5))
     stat = alterlist(reply->orders,(count2+ 5))
    ENDIF
    reply->orders[count2].order_mnemonic = o.order_mnemonic, reply->orders[count2].hna_order_mnemonic
     = o.hna_order_mnemonic, reply->orders[count2].ordered_as_mnemonic = o.ordered_as_mnemonic,
    reply->orders[count2].orig_ord_as_flag = o.orig_ord_as_flag, reply->orders[count2].
    orderable_type_flag = o.orderable_type_flag, reply->orders[count2].order_id = o.order_id,
    reply->orders[count2].encntr_id = o.encntr_id, reply->orders[count2].person_id = o.person_id,
    reply->orders[count2].catalog_cd = o.catalog_cd,
    reply->orders[count2].order_status_cd = o.order_status_cd, reply->orders[count2].orig_order_dt_tm
     = o.orig_order_dt_tm, reply->orders[count2].orig_order_tz = o.orig_order_tz,
    reply->orders[count2].display_line = trim(o.clinical_display_line), reply->orders[count2].
    last_update_provider_id = o.last_update_provider_id, reply->orders[count2].last_action_sequence
     = o.last_action_sequence,
    reply->orders[count2].template_core_action_sequence = o.template_core_action_sequence, reply->
    orders[count2].med_order_type_cd = o.med_order_type_cd, reply->orders[count2].constant_ind = o
    .constant_ind,
    reply->orders[count2].prn_ind = o.prn_ind, reply->orders[count2].freq_type_flag = o
    .freq_type_flag, reply->orders[count2].order_comment_ind = o.order_comment_ind
    IF (o.template_order_id != 0)
     reply->orders[count2].comment_type_mask = bor(o.comment_type_mask,band(ot.comment_type_mask,128)
      ), reply->orders[count2].comment_type_mask = bor(reply->orders[count2].comment_type_mask,band(
       ot.comment_type_mask,2))
    ELSE
     reply->orders[count2].comment_type_mask = o.comment_type_mask
    ENDIF
    reply->orders[count2].current_start_dt_tm = o.current_start_dt_tm, reply->orders[count2].
    current_start_tz = o.current_start_tz, reply->orders[count2].projected_stop_dt_tm = o
    .projected_stop_dt_tm,
    reply->orders[count2].projected_stop_tz = o.projected_stop_tz, reply->orders[count2].stop_type_cd
     = o.stop_type_cd, reply->orders[count2].ingredient_ind = o.ingredient_ind,
    reply->orders[count2].template_order_flag = o.template_order_flag, reply->orders[count2].
    template_order_id = o.template_order_id, reply->orders[count2].need_rx_verify_ind = o
    .need_rx_verify_ind,
    reply->orders[count2].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[count2].
    hide_flag = o.hide_flag
    IF (o.stop_type_cd=hard_stop_cd
     AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
     reply->orders[count2].need_renew_ind = 2
    ELSEIF (o.stop_type_cd=soft_stop_cd
     AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
     reply->orders[count2].need_renew_ind = 1
    ELSE
     reply->orders[count2].need_renew_ind = 0
    ENDIF
   ENDIF
  FOOT REPORT
   reply->order_cnt = count2, stat = alterlist(reply->orders,count2), reply->catalog_cnt = count1,
   stat = alterlist(reply->catalog,count1)
  WITH check
 ;end select
 SELECT INTO "nl:"
  o.catalog_cd, o.order_id, oc.seq
  FROM orders o,
   orders ot,
   order_ingredient oi,
   order_catalog oc
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.catalog_type_cd=pharmacy_cd
    AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
   trans_cancel_cd,
   voidedwrslt_cd)))
    AND ((o.template_order_flag+ 0) IN (0, 1, 4))
    AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
    AND parser(med_type_in_clause)
    AND parser(encntr_in_clause)
    AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm))
   JOIN (ot
   WHERE ot.order_id=o.template_order_id)
   JOIN (oi
   WHERE o.order_id=oi.order_id
    AND oi.action_sequence=1
    AND oi.comp_sequence=1)
   JOIN (oc
   WHERE oi.catalog_cd=oc.catalog_cd)
  ORDER BY o.catalog_cd
  HEAD REPORT
   count1 = reply->catalog_cnt, count2 = reply->order_cnt
  HEAD o.catalog_cd
   isnewcat = 1
   FOR (x = 1 TO count1)
     IF ((o.catalog_cd=reply->catalog[x].catalog_cd))
      isnewcat = 0, BREAK
     ELSEIF ((o.catalog_cd < reply->catalog[x].catalog_cd))
      BREAK
     ENDIF
   ENDFOR
   IF (isnewcat=1)
    count1 = (count1+ 1)
    IF (count1 > size(reply->catalog,5))
     stat = alterlist(reply->catalog,(count1+ 20))
    ENDIF
    reply->catalog[count1].catalog_cd = o.catalog_cd, reply->catalog[count1].catalog_type_cd = o
    .catalog_type_cd, reply->catalog[count1].activity_type_cd = o.activity_type_cd,
    reply->catalog[count1].task_catalog_cd = oc.catalog_cd, reply->catalog[count1].
    cont_order_method_flag = oc.cont_order_method_flag, reply->catalog[count1].primary_mnemonic = oc
    .primary_mnemonic,
    reply->catalog[count1].ref_text_mask = oc.ref_text_mask, reply->catalog[count1].cki = oc.cki
   ENDIF
  DETAIL
   IF (((o.template_order_flag IN (1, 0)
    AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((o.projected_stop_dt_tm=null) OR (((o.projected_stop_dt_tm >= cnvtdatetime(request->
    start_dt_tm)) OR (o.stop_type_cd=soft_stop_cd)) )) ) OR (o.template_order_flag=4
    AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((o.projected_stop_dt_tm=null) OR (o.projected_stop_dt_tm >= cnvtdatetime(request->
    start_dt_tm))) )) )
    count2 = (count2+ 1)
    IF (count2 > size(reply->orders,5))
     stat = alterlist(reply->orders,(count2+ 5))
    ENDIF
    reply->orders[count2].order_mnemonic = o.order_mnemonic, reply->orders[count2].hna_order_mnemonic
     = o.hna_order_mnemonic, reply->orders[count2].ordered_as_mnemonic = o.ordered_as_mnemonic,
    reply->orders[count2].orig_ord_as_flag = o.orig_ord_as_flag, reply->orders[count2].
    orderable_type_flag = o.orderable_type_flag, reply->orders[count2].order_id = o.order_id,
    reply->orders[count2].encntr_id = o.encntr_id, reply->orders[count2].person_id = o.person_id,
    reply->orders[count2].catalog_cd = o.catalog_cd,
    reply->orders[count2].order_status_cd = o.order_status_cd, reply->orders[count2].orig_order_dt_tm
     = o.orig_order_dt_tm, reply->orders[count2].orig_order_tz = o.orig_order_tz,
    reply->orders[count2].display_line = trim(o.clinical_display_line), reply->orders[count2].
    last_update_provider_id = o.last_update_provider_id, reply->orders[count2].last_action_sequence
     = o.last_action_sequence,
    reply->orders[count2].template_core_action_sequence = o.template_core_action_sequence, reply->
    orders[count2].med_order_type_cd = o.med_order_type_cd, reply->orders[count2].constant_ind = o
    .constant_ind,
    reply->orders[count2].prn_ind = o.prn_ind, reply->orders[count2].freq_type_flag = o
    .freq_type_flag, reply->orders[count2].order_comment_ind = o.order_comment_ind
    IF (o.template_order_id != 0)
     reply->orders[count2].comment_type_mask = bor(o.comment_type_mask,band(ot.comment_type_mask,128)
      ), reply->orders[count2].comment_type_mask = bor(reply->orders[count2].comment_type_mask,band(
       ot.comment_type_mask,2))
    ELSE
     reply->orders[count2].comment_type_mask = o.comment_type_mask
    ENDIF
    reply->orders[count2].current_start_dt_tm = o.current_start_dt_tm, reply->orders[count2].
    current_start_tz = o.current_start_tz, reply->orders[count2].projected_stop_dt_tm = o
    .projected_stop_dt_tm,
    reply->orders[count2].projected_stop_tz = o.projected_stop_tz, reply->orders[count2].stop_type_cd
     = o.stop_type_cd, reply->orders[count2].ingredient_ind = o.ingredient_ind,
    reply->orders[count2].template_order_flag = o.template_order_flag, reply->orders[count2].
    template_order_id = o.template_order_id, reply->orders[count2].need_rx_verify_ind = o
    .need_rx_verify_ind,
    reply->orders[count2].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[count2].
    hide_flag = o.hide_flag
    IF (o.stop_type_cd=hard_stop_cd
     AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
     reply->orders[count2].need_renew_ind = 2
    ELSEIF (o.stop_type_cd=soft_stop_cd
     AND o.projected_stop_dt_tm < cnvtdatetime(renew_dt_tm))
     reply->orders[count2].need_renew_ind = 1
    ELSE
     reply->orders[count2].need_renew_ind = 0
    ENDIF
   ENDIF
  FOOT REPORT
   reply->order_cnt = count2, stat = alterlist(reply->orders,count2), reply->catalog_cnt = count1,
   stat = alterlist(reply->catalog,count1)
  WITH check
 ;end select
 IF (count2=0)
  SET zero_ind = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_event_r cver,
   (dummyt d  WITH seq = value(size(reply->catalog,5)))
  PLAN (d)
   JOIN (cver
   WHERE (cver.parent_cd=reply->catalog[d.seq].catalog_cd))
  DETAIL
   reply->catalog[d.seq].event_cd = cver.event_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
   order_comment oc,
   long_text lt
  PLAN (d
   WHERE band(reply->orders[d.seq].comment_type_mask,order_comment_mask)=order_comment_mask)
   JOIN (oc
   WHERE (oc.order_id=reply->orders[d.seq].order_id)
    AND oc.comment_type_cd=order_comment_cd
    AND (oc.action_sequence=
   (SELECT
    max(oc2.action_sequence)
    FROM order_comment oc2
    WHERE oc2.order_id=oc.order_id
     AND oc2.comment_type_cd=order_comment_cd)))
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
  DETAIL
   reply->orders[d.seq].order_comment_text = lt.long_text
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  od.order_id, d.seq, od.oe_field_id,
  od.action_sequence, od.oe_field_value, od.oe_field_meaning_id
  FROM (dummyt d  WITH seq = value(count2)),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=reply->orders[d.seq].order_id)
    AND od.oe_field_meaning_id IN (57, 2056, 2057, 2058, 2059,
   2063))
  ORDER BY d.seq, od.oe_field_id, od.action_sequence
  DETAIL
   IF (od.oe_field_meaning_id=57)
    reply->orders[d.seq].quantity = od.oe_field_value
   ENDIF
   IF (od.oe_field_meaning_id=2056)
    reply->orders[d.seq].str = od.oe_field_value
   ENDIF
   IF (od.oe_field_meaning_id=2057)
    reply->orders[d.seq].str_unit_cd = od.oe_field_value
   ENDIF
   IF (od.oe_field_meaning_id=2058)
    reply->orders[d.seq].vol = od.oe_field_value
   ENDIF
   IF (od.oe_field_meaning_id=2059)
    reply->orders[d.seq].vol_unit_cd = od.oe_field_value
   ENDIF
   IF (od.oe_field_meaning_id=2063)
    reply->orders[d.seq].freetxtdose = trim(od.oe_field_display_value)
   ENDIF
  WITH check, nocounter
 ;end select
 IF (count1=0)
  SET zero_ind = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  otx.catalog_cd, otx.order_task_seq, ot.task_type_cd
  FROM (dummyt d1  WITH seq = value(count1)),
   order_task_xref otx,
   order_task ot
  PLAN (d1)
   JOIN (otx
   WHERE (otx.catalog_cd=reply->catalog[d1.seq].task_catalog_cd))
   JOIN (ot
   WHERE ot.reference_task_id=otx.reference_task_id)
  ORDER BY otx.order_task_seq
  HEAD d1.seq
   count2 = 0
  DETAIL
   count2 = (count2+ 1)
   IF (count2 > size(reply->catalog[d1.seq].tasks,5))
    stat = alterlist(reply->catalog[d1.seq].tasks,(count2+ 5))
   ENDIF
   reply->catalog[d1.seq].tasks[count2].task_seq = otx.order_task_seq, reply->catalog[d1.seq].tasks[
   count2].task_type_flag = otx.order_task_type_flag, reply->catalog[d1.seq].tasks[count2].
   prim_task_ind = otx.primary_task_ind,
   reply->catalog[d1.seq].tasks[count2].ref_task_id = otx.reference_task_id, reply->catalog[d1.seq].
   tasks[count2].task_description = ot.task_description, reply->catalog[d1.seq].tasks[count2].
   task_description_key = ot.task_description_key,
   reply->catalog[d1.seq].tasks[count2].task_type_cd = ot.task_type_cd
  FOOT  d1.seq
   reply->catalog[d1.seq].task_cnt = count2, stat = alterlist(reply->catalog[d1.seq].tasks,count2)
  WITH nocounter
 ;end select
 SET max_task_cnt = 5
 IF ((reply->catalog_cnt=0))
  SET zero_ind = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ptr.sequence, dta.task_assay_cd
  FROM (dummyt d1  WITH seq = value(reply->catalog_cnt)),
   (dummyt d2  WITH seq = value(max_task_cnt)),
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->catalog[d1.seq].tasks,5)
    AND (reply->catalog[d1.seq].tasks[d2.seq].task_type_flag=0))
   JOIN (ptr
   WHERE (ptr.catalog_cd=reply->catalog[d1.seq].task_catalog_cd)
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
  ORDER BY ptr.sequence
  HEAD d1.seq
   count3 = 0
  DETAIL
   count3 = (count3+ 1)
   IF (count3 > size(reply->catalog[d1.seq].tasks[d2.seq].assay,5))
    stat = alterlist(reply->catalog[d1.seq].tasks[d2.seq].assay,(count3+ 5))
   ENDIF
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].pend_req_ind = ptr.pending_ind, reply->catalog[
   d1.seq].tasks[d2.seq].assay[count3].sequence = ptr.sequence, reply->catalog[d1.seq].tasks[d2.seq].
   assay[count3].task_assay_cd = dta.task_assay_cd,
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].mnemonic_key = dta.mnemonic_key_cap, reply->
   catalog[d1.seq].tasks[d2.seq].assay[count3].mnemonic = dta.mnemonic, reply->catalog[d1.seq].tasks[
   d2.seq].assay[count3].activity_type_cd = dta.activity_type_cd,
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].desc = dta.description, reply->catalog[d1.seq].
   tasks[d2.seq].assay[count3].event_cd = dta.event_cd
  FOOT  d1.seq
   reply->catalog[d1.seq].tasks[d2.seq].assay_cnt = count3, stat = alterlist(reply->catalog[d1.seq].
    tasks[d2.seq].assay,count3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ptr.sequence, dta.task_assay_cd
  FROM (dummyt d1  WITH seq = value(reply->catalog_cnt)),
   (dummyt d2  WITH seq = value(max_task_cnt)),
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->catalog[d1.seq].tasks,5)
    AND (reply->catalog[d1.seq].tasks[d2.seq].task_type_flag=1))
   JOIN (ptr
   WHERE (ptr.reference_task_id=reply->catalog[d1.seq].tasks[d2.seq].ref_task_id)
    AND (ptr.catalog_cd=reply->catalog[d1.seq].task_catalog_cd)
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
  ORDER BY ptr.sequence
  HEAD d1.seq
   count3 = 0
  DETAIL
   count3 = (count3+ 1)
   IF (count3 > size(reply->catalog[d1.seq].tasks[d2.seq].assay,5))
    stat = alterlist(reply->catalog[d1.seq].tasks[d2.seq].assay,(count3+ 5))
   ENDIF
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].pend_req_ind = ptr.pending_ind, reply->catalog[
   d1.seq].tasks[d2.seq].assay[count3].sequence = ptr.sequence, reply->catalog[d1.seq].tasks[d2.seq].
   assay[count3].task_assay_cd = dta.task_assay_cd,
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].mnemonic_key = dta.mnemonic_key_cap, reply->
   catalog[d1.seq].tasks[d2.seq].assay[count3].mnemonic = dta.mnemonic, reply->catalog[d1.seq].tasks[
   d2.seq].assay[count3].activity_type_cd = dta.activity_type_cd,
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].desc = dta.description, reply->catalog[d1.seq].
   tasks[d2.seq].assay[count3].event_cd = dta.event_cd
  FOOT  d1.seq
   reply->catalog[d1.seq].tasks[d2.seq].assay_cnt = count3, stat = alterlist(reply->catalog[d1.seq].
    tasks[d2.seq].assay,count3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tdr.sequence, dta.task_assay_cd
  FROM (dummyt d1  WITH seq = value(reply->catalog_cnt)),
   (dummyt d2  WITH seq = value(max_task_cnt)),
   task_discrete_r tdr,
   discrete_task_assay dta
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->catalog[d1.seq].tasks,5)
    AND (reply->catalog[d1.seq].tasks[d2.seq].task_type_flag=2))
   JOIN (tdr
   WHERE (tdr.reference_task_id=reply->catalog[d1.seq].tasks[d2.seq].ref_task_id)
    AND tdr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=tdr.task_assay_cd
    AND dta.active_ind=1)
  ORDER BY tdr.sequence
  HEAD d1.seq
   count3 = 0
  DETAIL
   count3 = (count3+ 1)
   IF (count3 > size(reply->catalog[d1.seq].tasks[d2.seq].assay,5))
    stat = alterlist(reply->catalog[d1.seq].tasks[d2.seq].assay,(count3+ 5))
   ENDIF
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].pend_req_ind = tdr.required_ind, reply->
   catalog[d1.seq].tasks[d2.seq].assay[count3].sequence = tdr.sequence, reply->catalog[d1.seq].tasks[
   d2.seq].assay[count3].task_assay_cd = dta.task_assay_cd,
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].mnemonic_key = dta.mnemonic_key_cap, reply->
   catalog[d1.seq].tasks[d2.seq].assay[count3].mnemonic = dta.mnemonic, reply->catalog[d1.seq].tasks[
   d2.seq].assay[count3].activity_type_cd = dta.activity_type_cd,
   reply->catalog[d1.seq].tasks[d2.seq].assay[count3].desc = dta.description, reply->catalog[d1.seq].
   tasks[d2.seq].assay[count3].event_cd = dta.event_cd
  FOOT  d1.seq
   reply->catalog[d1.seq].tasks[d2.seq].assay_cnt = count3, stat = alterlist(reply->catalog[d1.seq].
    tasks[d2.seq].assay,count3)
  WITH nocounter
 ;end select
#exit_script
 IF (((curqual=0) OR (zero_ind=1)) )
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
