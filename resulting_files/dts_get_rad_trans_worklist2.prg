CREATE PROGRAM dts_get_rad_trans_worklist2
 SET oraclause = concat("INDEX(RE XIE1RAD_EXAM) INDEX(RG1 XIE1resource_group) ",
  "INDEX(RG2 XIE1resource_group) INDEX(RG4 XIE1resource_group) ",
  "INDEX(RR XIE1RAD_REPORT) INDEX(RRP XPKRAD_REPORT_PRSNL)")
 SELECT INTO "nl:"
  rord.order_id, rord.request_dt_tm, rord.updt_cnt,
  ocs.updt_cnt, e.encntr_type_cd, rr.sequence,
  ce.event_id, med = decode(ea.seq,cnvtalias(ea.alias,ea.alias_pool_cd)," "), fin = decode(ea2.seq,
   cnvtalias(ea2.alias,ea2.alias_pool_cd)," ")
  FROM order_radiology rord,
   order_catalog_synonym ocs,
   rad_report rr,
   rad_exam re,
   rad_report_prsnl rrp,
   prsnl pr,
   resource_group rg1,
   resource_group rg2,
   resource_group rg4,
   person p,
   encounter e,
   encntr_alias ea,
   encntr_alias ea2,
   clinical_event ce,
   (dummyt d2  WITH seq = 1),
   dummyt d3,
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1),
   (dummyt d6  WITH seq = 1)
  PLAN (rord
   WHERE ((rord.report_status_cd=new_stat_cd) OR (((rord.report_status_cd=hold_stat_cd) OR (((rord
   .report_status_cd=reject_stat_cd) OR (rord.report_status_cd=dictated_stat_cd)) )) ))
    AND rord.request_dt_tm >= cnvtdatetime(request->low_time_const)
    AND rord.request_dt_tm < cnvtdatetime(request->up_time_const)
    AND rord.order_id > 0)
   JOIN (ce
   WHERE ce.order_id=rord.order_id)
   JOIN (d4)
   JOIN (ea
   WHERE ea.encntr_id=rord.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d5)
   JOIN (ea2
   WHERE ea2.encntr_id=rord.encntr_id
    AND ea2.encntr_alias_type_cd=fin_alias_cd
    AND ea.active_ind=1
    AND ea2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ea2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d6)
   JOIN (re
   WHERE re.order_id=rord.order_id
    AND re.exam_sequence=1)
   JOIN (rg4
   WHERE  $3
    AND rg4.child_service_resource_cd=re.service_resource_cd
    AND rg4.resource_group_type_cd=subsect_type_cd
    AND rg4.root_service_resource_cd=0
    AND rg4.active_ind=1
    AND rg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND rg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (rg1
   WHERE  $2
    AND rg1.child_service_resource_cd=rg4.parent_service_resource_cd
    AND rg1.resource_group_type_cd=sect_type_cd
    AND rg1.root_service_resource_cd=0
    AND rg1.active_ind=1
    AND rg1.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND rg1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (rg2
   WHERE  $1
    AND rg2.child_service_resource_cd=rg1.parent_service_resource_cd
    AND rg2.resource_group_type_cd=dept_type_cd
    AND rg2.root_service_resource_cd=0
    AND rg2.active_ind=1
    AND rg2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND rg2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (e
   WHERE e.encntr_id=rord.encntr_id)
   JOIN (ocs
   WHERE rord.catalog_cd=ocs.catalog_cd
    AND ocs.mnemonic_type_cd=primary_synonym_cd)
   JOIN (p
   WHERE p.person_id=rord.person_id)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (rr
   WHERE rr.order_id=rord.parent_order_id
    AND rr.order_id > 0)
   JOIN (rrp
   WHERE rrp.rad_report_id=rr.rad_report_id)
   JOIN (pr
   WHERE pr.person_id=rrp.report_prsnl_id)
  ORDER BY rord.order_id, rr.sequence DESC
  HEAD REPORT
   count1 = 0, event_id = 0
  HEAD rord.order_id
   count1 = (count1+ 1)
   IF (mod(count1,5)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 4))
   ENDIF
   reply->qual[count1].order_id = rord.order_id, reply->qual[count1].accession_id = rord.accession_id,
   reply->qual[count1].accession = rord.accession,
   reply->qual[count1].catalog_cd = rord.catalog_cd, reply->qual[count1].catalog_syn = ocs.mnemonic,
   reply->qual[count1].person_id = rord.person_id,
   reply->qual[count1].encntr_id = rord.encntr_id, reply->qual[count1].med_rec_num = med, reply->
   qual[count1].fin_num = fin,
   reply->qual[count1].comments = rord.comments, reply->qual[count1].report_status_cd = rord
   .report_status_cd, reply->qual[count1].exam_status_cd = rord.exam_status_cd,
   reply->qual[count1].packet_routing_cd = rord.packet_routing_cd, reply->qual[count1].ord_loc_cd =
   rord.ord_loc_cd, reply->qual[count1].refer_loc_cd = rord.refer_loc_cd,
   reply->qual[count1].cancel_dt_tm = rord.cancel_dt_tm, reply->qual[count1].cancel_tz = rord
   .cancel_tz, reply->qual[count1].cancel_by_id = rord.cancel_by_id,
   reply->qual[count1].request_dt_tm = rord.request_dt_tm, reply->qual[count1].requested_tz = rord
   .requested_tz, reply->qual[count1].seq_exam_id = rord.seq_exam_id,
   reply->qual[count1].removed_dt_tm = rord.removed_dt_tm, reply->qual[count1].removed_by_id = rord
   .removed_by_id, reply->qual[count1].removed_cd = rord.removed_cd,
   reply->qual[count1].pull_list_id = rord.pull_list_id, reply->qual[count1].start_dt_tm = rord
   .start_dt_tm, reply->qual[count1].start_tz = rord.start_tz,
   reply->qual[count1].complete_dt_tm = rord.complete_dt_tm, reply->qual[count1].complete_tz = rord
   .complete_tz, reply->qual[count1].reason_for_exam = rord.reason_for_exam,
   reply->qual[count1].order_physician_id = rord.order_physician_id, reply->qual[count1].priority_cd
    = rord.priority_cd, reply->qual[count1].trans_workgroup_cd = rord.trans_workgroup_cd,
   reply->qual[count1].parent_order_id = rord.parent_order_id, reply->qual[count1].
   group_reference_nbr = rord.group_reference_nbr, event_id = rord.group_event_id
   IF (event_id=0.0)
    event_id = ce.event_id
   ENDIF
   reply->qual[count1].group_event_id = event_id, reply->qual[count1].updt_cnt = rord.updt_cnt, reply
   ->qual[count1].person_name = p.name_full_formatted,
   reply->qual[count1].encntr_type_cd = e.encntr_type_cd, reply->qual[count1].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd, count_for_seq = 0,
   flag = 1, dcnt = 0
  HEAD rr.sequence
   count_for_seq = (count_for_seq+ 1)
   IF (count_for_seq > 1)
    flag = 0
   ELSE
    reply->qual[count1].report_id = rr.rad_report_id, reply->qual[count1].orig_trans_dt_tm = rr
    .original_trans_dt_tm, reply->qual[count1].original_trans_tz = rr.original_trans_tz,
    reply->qual[count1].dict_dt_tm = rr.dictated_dt_tm, reply->qual[count1].dictated_tz = rr
    .dictated_tz, reply->qual[count1].final_dt_tm = rr.final_dt_tm,
    reply->qual[count1].final_tz = rr.final_tz
   ENDIF
  DETAIL
   IF (flag=1
    AND rrp.rad_report_id > 0)
    dcnt = (dcnt+ 1), stat = alterlist(reply->qual[count1].trans_prsnl,dcnt), reply->qual[count1].
    trans_prsnl[dcnt].rad_report_id = rrp.rad_report_id,
    reply->qual[count1].trans_prsnl[dcnt].report_prsnl_id = rrp.report_prsnl_id, reply->qual[count1].
    trans_prsnl[dcnt].report_prsnl_name = pr.name_full_formatted, reply->qual[count1].trans_prsnl[
    dcnt].prsnl_relation_flag = rrp.prsnl_relation_flag,
    reply->qual[count1].trans_prsnl[dcnt].proxied_for_id = rrp.proxied_for_id
   ENDIF
  WITH nocounter, outerjoin = d2, outerjoin = d3,
   orahint(value(oraclause)), dontcare = ea, dontcare = ea2
 ;end select
 SET stat = alter(reply->qual,count1)
 SET reply->qual_cnt = count1
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
