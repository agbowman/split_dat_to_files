CREATE PROGRAM dcp_get_order_info:dba
 SET junk_ptr = 0
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->order_list,5))
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0
 SET code_set = 6025
 SET cdf_meaning = "CONT"
 EXECUTE cpm_get_cd_for_cdf
 SET continuous_task_class_cd = code_value
 SET code_set = 6025
 SET cdf_meaning = "PRN"
 EXECUTE cpm_get_cd_for_cdf
 SET prn_task_class_cd = code_value
 SET code_set = 79
 SET cdf_meaning = "COMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET complete_task_status_cd = code_value
 SET code_set = 14024
 SET cdf_meaning = "DCP_NOTDONE"
 EXECUTE cpm_get_cd_for_cdf
 SET task_not_done_cd = code_value
 SET e_ce_med_result = 4
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   o.order_id, o.hna_order_mnemonic, o.ordered_as_mnemonic,
   o.order_mnemonic
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    orders o
   PLAN (d)
    JOIN (o
    WHERE (o.order_id=request->order_list[d.seq].order_id)
     AND o.active_ind=1)
   ORDER BY o.order_id
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].order_id = o.order_id, reply->get_list[count1].hna_mnemonic = o
    .hna_order_mnemonic, reply->get_list[count1].order_mnemonic = o.order_mnemonic,
    reply->get_list[count1].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->get_list[count1].
    order_detail_display_line =
    IF (trim(o.clinical_display_line) > " ") o.clinical_display_line
    ELSE o.order_detail_display_line
    ENDIF
    , reply->get_list[count1].order_comment_ind = o.order_comment_ind,
    reply->get_list[count1].order_status_cd = o.order_status_cd, reply->get_list[count1].
    template_order_id = o.template_order_id, reply->get_list[count1].admin_dosage = 0.0,
    reply->get_list[count1].dosage_unit_cd = 0.0, reply->get_list[count1].stop_type_cd = o
    .stop_type_cd, reply->get_list[count1].projected_stop_dt_tm = o.projected_stop_dt_tm,
    reply->get_list[count1].comment_type_mask = o.comment_type_mask
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exipt
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET test_count1 = 0
 SET test_count2 = 0
 IF ((request->need_last_done_dt=1))
  IF (count1 > 0)
   SELECT INTO "nl:"
    ta.order_id
    FROM (dummyt d  WITH seq = value(count1)),
     task_activity ta,
     clinical_event ce,
     dummyt d2,
     ce_med_result cmr
    PLAN (d)
     JOIN (ta
     WHERE (ta.order_id=reply->get_list[d.seq].order_id)
      AND ta.active_ind=1
      AND ((ta.task_class_cd=continuous_task_class_cd) OR (ta.task_class_cd=prn_task_class_cd))
      AND ta.task_status_cd=complete_task_status_cd
      AND ta.task_status_reason_cd != task_not_done_cd)
     JOIN (ce
     WHERE ce.parent_event_id=ta.event_id)
     JOIN (d2)
     JOIN (cmr
     WHERE cmr.event_id=ce.event_id)
    ORDER BY ta.order_id
    HEAD ta.order_id
     junk_ptr = junk_ptr, test_count1 += 1
    DETAIL
     IF (ce.event_id=ta.event_id)
      IF ((reply->get_list[d.seq].last_done_dt_tm < ce.event_end_dt_tm))
       reply->get_list[d.seq].last_done_dt_tm = cnvtdatetime(ce.event_end_dt_tm)
      ENDIF
      test_count2 += 1
     ENDIF
     IF (band(ce.subtable_bit_map,e_ce_med_result))
      IF ((reply->get_list[d.seq].last_dose_given_dt_tm < ce.event_end_dt_tm))
       reply->get_list[d.seq].last_dose_given_dt_tm = cnvtdatetime(ce.event_end_dt_tm), reply->
       get_list[d.seq].admin_dosage = cmr.admin_dosage, reply->get_list[d.seq].dosage_unit_cd = cmr
       .dosage_unit_cd
      ENDIF
      test_count2 += 1
     ENDIF
    FOOT  ta.order_id
     junk_ptr = junk_ptr
    WITH outerjoin = d2
   ;end select
  ENDIF
 ENDIF
#exipt
END GO
