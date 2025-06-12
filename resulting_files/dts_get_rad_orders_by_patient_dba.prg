CREATE PROGRAM dts_get_rad_orders_by_patient:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[10]
      2 order_id = f8
      2 orig_order_dt_tm = dq8
      2 orig_order_tz = i4
      2 accession = c20
      2 catalog_cd = f8
      2 encntr_id = f8
      2 encntr_type_cd = f8
      2 encntr_type_disp = c40
      2 report_status_cd = f8
      2 report_status_disp = c40
      2 report_status_desc = c60
      2 report_status_mean = c12
      2 exam_status_cd = f8
      2 exam_status_disp = c40
      2 exam_status_desc = c60
      2 exam_status_mean = c12
      2 complete_dt_tm = dq8
      2 complete_tz = i4
      2 request_dt_tm = dq8
      2 requested_tz = i4
      2 reason_for_exam = vc
      2 order_physician_id = f8
      2 priority_cd = f8
      2 priority_disp = c40
      2 priority_desc = c60
      2 priority_mean = c12
      2 parent_order_id = f8
      2 group_reference_nbr = c40
      2 group_event_id = f8
      2 o_updt_cnt = i4
      2 mnemonic = vc
      2 activity_subtype_cd = f8
      2 activity_subtype_disp = c60
      2 activity_subtype_mean = c12
      2 rpt[*]
        3 rad_report_id = f8
        3 rad_rpt_reference_nbr = c40
        3 no_proxy_ind = i2
        3 report_event_id = f8
        3 sequence = i4
        3 rr_updt_cnt = i4
        3 prsnl[*]
          4 report_prsnl_id = f8
          4 report_prsnl_name = vc
          4 prsnl_relation_flag = i2
          4 queue_ind = i2
          4 action_dt_tm = dq8
          4 action_tz = i4
          4 proxied_for_id = f8
          4 rrp_updt_cnt = i4
        3 dtl[*]
          4 task_assay_cd = f8
          4 required_ind = i2
          4 template_id = f8
          4 section_sequence = i4
          4 acr_code_ind = i2
          4 detail_reference_nbr = c40
          4 detail_event_id = f8
          4 rad_section_type_cd = f8
          4 rad_section_type_disp = c40
          4 rad_section_type_desc = c60
          4 rad_section_type_mean = c12
          4 rrd_updt_cnt = i4
    1 qual_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 DECLARE cancel_cd = f8
 DECLARE primary_synonym_cd = f8
 SET cancel_cd = 0.0
 SET primary_synonym_cd = 0.0
 DECLARE code_value = f8
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 6011
 SET cdf_meaning = "PRIMARY"
 EXECUTE cpm_get_cd_for_cdf
 SET primary_synonym_cd = code_value
 SET code_set = 14202
 SET cdf_meaning = "CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_cd = code_value
 DECLARE event_id = f8
 SET event_id = 0
 SELECT INTO "NL:"
  o.order_id, o.parent_order_id, e.encntr_id,
  rr.rad_report_id, rrp.report_prsnl_id, rrd.task_assay_cd,
  path = decode(rrp.seq,"P",rrd.seq,"D","O")
  FROM order_radiology o,
   orders ords,
   order_catalog_synonym ocs,
   encounter e,
   (dummyt d1  WITH seq = 1),
   rad_report rr,
   (dummyt d2  WITH seq = 1),
   rad_report_prsnl rrp,
   person p2,
   rad_report_detail rrd,
   clinical_event ce,
   discrete_task_assay dta
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.report_status_cd != cancel_cd)
   JOIN (ords
   WHERE o.order_id=ords.order_id)
   JOIN (ocs
   WHERE ocs.catalog_cd=o.catalog_cd
    AND ocs.mnemonic_type_cd=primary_synonym_cd)
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
   JOIN (ce
   WHERE ce.person_id=o.person_id
    AND ((ce.encntr_id+ 0)=o.encntr_id)
    AND ce.order_id=o.order_id)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (rr
   WHERE rr.order_id=o.order_id
    AND o.parent_order_id=o.order_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (((rrp
   WHERE rrp.rad_report_id=rr.rad_report_id)
   JOIN (p2
   WHERE p2.person_id=rrp.report_prsnl_id)
   ) ORJOIN ((rrd
   WHERE rrd.rad_report_id=rr.rad_report_id)
   JOIN (dta
   WHERE dta.task_assay_cd=rrd.task_assay_cd)
   ))
  HEAD REPORT
   count1 = 0, event_id = 0
  HEAD o.order_id
   count2 = 0, count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   event_id = o.group_event_id
   IF (event_id=0.0
    AND ce.order_id=o.order_id)
    event_id = ce.event_id
   ENDIF
   reply->qual[count1].order_id = o.order_id, reply->qual[count1].accession = o.accession, reply->
   qual[count1].catalog_cd = o.catalog_cd,
   reply->qual[count1].encntr_id = e.encntr_id, reply->qual[count1].encntr_type_cd = e.encntr_type_cd,
   reply->qual[count1].report_status_cd = o.report_status_cd,
   reply->qual[count1].exam_status_cd = o.exam_status_cd, reply->qual[count1].complete_dt_tm = o
   .complete_dt_tm, reply->qual[count1].request_dt_tm = o.request_dt_tm,
   reply->qual[count1].complete_tz = o.complete_tz, reply->qual[count1].requested_tz = o.requested_tz,
   reply->qual[count1].reason_for_exam = o.reason_for_exam,
   reply->qual[count1].priority_cd = o.priority_cd, reply->qual[count1].parent_order_id = o
   .parent_order_id, reply->qual[count1].group_reference_nbr = o.group_reference_nbr,
   reply->qual[count1].group_event_id = event_id, reply->qual[count1].o_updt_cnt = o.updt_cnt, reply
   ->qual[count1].mnemonic = ocs.mnemonic,
   reply->qual[count1].activity_subtype_cd = ocs.activity_subtype_cd
  HEAD rr.rad_report_id
   count3 = 0, count4 = 0, count2 = (count2+ 1),
   stat = alterlist(reply->qual[count1].rpt,count2), reply->qual[count1].rpt[count2].rad_report_id =
   rr.rad_report_id, reply->qual[count1].rpt[count2].rad_rpt_reference_nbr = rr.rad_rpt_reference_nbr,
   reply->qual[count1].rpt[count2].report_event_id = rr.report_event_id, reply->qual[count1].rpt[
   count2].no_proxy_ind = rr.no_proxy_ind, reply->qual[count1].rpt[count2].sequence = rr.sequence,
   reply->qual[count1].rpt[count2].rr_updt_cnt = rr.updt_cnt
  DETAIL
   CASE (path)
    OF "P":
     count3 = (count3+ 1),stat = alterlist(reply->qual[count1].rpt[count2].prsnl,count3),reply->qual[
     count1].rpt[count2].prsnl[count3].report_prsnl_id = rrp.report_prsnl_id,
     reply->qual[count1].rpt[count2].prsnl[count3].report_prsnl_name = p2.name_full_formatted,reply->
     qual[count1].rpt[count2].prsnl[count3].prsnl_relation_flag = rrp.prsnl_relation_flag,reply->
     qual[count1].rpt[count2].prsnl[count3].queue_ind = rrp.queue_ind,
     reply->qual[count1].rpt[count2].prsnl[count3].action_dt_tm = rrp.action_dt_tm,reply->qual[count1
     ].rpt[count2].prsnl[count3].action_tz = rrp.action_tz,reply->qual[count1].rpt[count2].prsnl[
     count3].proxied_for_id = rrp.proxied_for_id,
     reply->qual[count1].rpt[count2].prsnl[count3].rrp_updt_cnt = rrp.updt_cnt
    OF "D":
     count4 = (count4+ 1),stat = alterlist(reply->qual[count1].rpt[count2].dtl,count4),reply->qual[
     count1].rpt[count2].dtl[count4].task_assay_cd = rrd.task_assay_cd,
     reply->qual[count1].rpt[count2].dtl[count4].required_ind = rrd.required_ind,reply->qual[count1].
     rpt[count2].dtl[count4].template_id = rrd.template_id,reply->qual[count1].rpt[count2].dtl[count4
     ].section_sequence = rrd.section_sequence,
     reply->qual[count1].rpt[count2].dtl[count4].acr_code_ind = rrd.acr_code_ind,reply->qual[count1].
     rpt[count2].dtl[count4].detail_reference_nbr = rrd.detail_reference_nbr,reply->qual[count1].rpt[
     count2].dtl[count4].detail_event_id = rrd.detail_event_id,
     reply->qual[count1].rpt[count2].dtl[count4].rad_section_type_cd = dta.rad_section_type_cd,reply
     ->qual[count1].rpt[count2].dtl[count4].rrd_updt_cnt = rrd.updt_cnt,reply->qual[count1].
     orig_order_dt_tm = ords.orig_order_dt_tm,
     reply->qual[count1].order_physician_id = o.order_physician_id,reply->qual[count1].orig_order_tz
      = ords.orig_order_tz
   ENDCASE
  WITH nocounter, outerjoin = d1, outerjoin = ce
 ;end select
 SET stat = alter(reply->qual,count1)
 SET reply->qual_cnt = count1
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
