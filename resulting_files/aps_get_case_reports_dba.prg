CREATE PROGRAM aps_get_case_reports:dba
 RECORD reply(
   1 rpt_qual[1]
     2 report_id = f8
     2 report_sequence = i4
     2 report_comment = vc
     2 comments_long_text_id = f8
     2 report_comment_updt_cnt = i4
     2 catalog_cd = f8
     2 short_description = c50
     2 responsible_pathologist_id = f8
     2 responsible_pathologist_name = c100
     2 responsible_resident_id = f8
     2 responsible_resident_name = c100
     2 processing_location_cd = f8
     2 processing_location_disp = c40
     2 request_priority_cd = f8
     2 request_priority_disp = c40
     2 request_dt_tm = dq8
     2 status_cd = f8
     2 status_disp = c40
     2 status_desc = vc
     2 status_mean = c12
     2 status_dt_tm = dq8
     2 hold_cd = f8
     2 hold_disp = c40
     2 hold_comment = vc
     2 hold_comment_long_text_id = f8
     2 hold_comment_updt_cnt = i4
     2 cancel_cd = f8
     2 cancel_disp = c40
     2 cancel_prsnl_name = c100
     2 cancel_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 last_edit_dt_tm = dq8
     2 order_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET rpt_cnt = 0
 SELECT INTO "nl:"
  cr.report_id, rt_exists = decode(rt.seq,1,0), p1.name_full_formatted,
  p2.name_full_formatted, sd.short_description
  FROM report_task rt,
   (dummyt d  WITH seq = 1),
   case_report cr,
   service_directory sd,
   prsnl p1,
   prsnl p2,
   prsnl p3
  PLAN (cr
   WHERE (request->case_id=cr.case_id))
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (p3
   WHERE cr.cancel_prsnl_id=p3.person_id)
   JOIN (d
   WHERE 1=d.seq)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   JOIN (p1
   WHERE rt.responsible_pathologist_id=p1.person_id)
   JOIN (p2
   WHERE rt.responsible_resident_id=p2.person_id)
  HEAD REPORT
   rpt_cnt = 0
  DETAIL
   rpt_cnt = (rpt_cnt+ 1)
   IF (rpt_cnt > 1)
    stat = alter(reply->rpt_qual,rpt_cnt)
   ENDIF
   reply->rpt_qual[rpt_cnt].report_id = cr.report_id, reply->rpt_qual[rpt_cnt].report_sequence = cr
   .report_sequence, reply->rpt_qual[rpt_cnt].catalog_cd = cr.catalog_cd,
   reply->rpt_qual[rpt_cnt].request_dt_tm = cnvtdatetime(cr.request_dt_tm), reply->rpt_qual[rpt_cnt].
   status_cd = cr.status_cd, reply->rpt_qual[rpt_cnt].status_dt_tm = cnvtdatetime(cr.status_dt_tm),
   reply->rpt_qual[rpt_cnt].cancel_cd = cr.cancel_cd, reply->rpt_qual[rpt_cnt].cancel_prsnl_name = p3
   .name_full_formatted, reply->rpt_qual[rpt_cnt].cancel_dt_tm = cnvtdatetime(cr.cancel_dt_tm),
   reply->rpt_qual[rpt_cnt].short_description = sd.short_description
   IF (rt_exists=1)
    reply->rpt_qual[rpt_cnt].comments_long_text_id = rt.comments_long_text_id, reply->rpt_qual[
    rpt_cnt].responsible_pathologist_id = rt.responsible_pathologist_id, reply->rpt_qual[rpt_cnt].
    responsible_pathologist_name = p1.name_full_formatted,
    reply->rpt_qual[rpt_cnt].responsible_resident_id = rt.responsible_resident_id, reply->rpt_qual[
    rpt_cnt].responsible_resident_name = p2.name_full_formatted, reply->rpt_qual[rpt_cnt].
    processing_location_cd = rt.service_resource_cd,
    reply->rpt_qual[rpt_cnt].request_priority_cd = rt.priority_cd, reply->rpt_qual[rpt_cnt].hold_cd
     = rt.hold_cd, reply->rpt_qual[rpt_cnt].hold_comment_long_text_id = rt.hold_comment_long_text_id,
    reply->rpt_qual[rpt_cnt].updt_dt_tm = cnvtdatetime(rt.updt_dt_tm), reply->rpt_qual[rpt_cnt].
    last_edit_dt_tm = cnvtdatetime(rt.last_edit_dt_tm), reply->rpt_qual[rpt_cnt].order_id = rt
    .order_id
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_TASK"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(rpt_cnt))
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].comments_long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->rpt_qual[d1.seq].comments_long_text_id))
  DETAIL
   reply->rpt_qual[d1.seq].report_comment = lt.long_text, reply->rpt_qual[d1.seq].
   report_comment_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(rpt_cnt))
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].hold_comment_long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->rpt_qual[d1.seq].hold_comment_long_text_id))
  DETAIL
   reply->rpt_qual[d1.seq].hold_comment = lt.long_text, reply->rpt_qual[d1.seq].hold_comment_updt_cnt
    = lt.updt_cnt
  WITH nocounter
 ;end select
END GO
