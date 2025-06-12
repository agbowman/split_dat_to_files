CREATE PROGRAM aps_get_case_outstanding_tasks:dba
 RECORD reply(
   1 case_cnt = i4
   1 qual[*]
     2 case_id = f8
     2 prefix_cd = f8
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 tag_qual[2]
       3 tag_type_flag = i2
       3 tag_separator = c1
     2 spec_ctr = i4
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 spec_descr = c100
       3 spec_tag = c7
       3 spec_seq = i4
       3 spec_fixative_cd = f8
       3 spec_fixative_disp = c40
       3 spec_status_cd = f8
       3 spec_updt_cnt = i4
       3 s_t_ctr = i4
       3 t_qual[*]
         4 t_task_assay_cd = f8
         4 t_task_assay_disp = vc
         4 t_task_assay_desc = vc
         4 t_comment = vc
         4 t_status_cd = f8
         4 t_status_disp = c40
         4 t_request_dt_tm = dq8
         4 t_create_inv_flag = i2
         4 t_hold_cd = f8
         4 t_hold_disp = c40
         4 t_hold_comment = vc
         4 t_updt_dt_tm = dq8
         4 t_status_dt_tm = dq8
         4 t_status_prsnl_name = vc
         4 t_quantity = i4
       3 s_slide_ctr = i4
       3 slide_qual[*]
         4 sl_task_assay_cd = f8
         4 sl_tag = c7
         4 sl_seq = i4
         4 sl_updt_cnt = i4
         4 s_s_t_ctr = i4
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_task_assay_disp = vc
           5 t_task_assay_desc = vc
           5 t_comment = vc
           5 t_status_cd = f8
           5 t_status_disp = c40
           5 t_request_dt_tm = dq8
           5 t_create_inv_flag = i2
           5 t_hold_cd = f8
           5 t_hold_disp = c40
           5 t_hold_comment = vc
           5 t_updt_dt_tm = dq8
           5 t_status_dt_tm = dq8
           5 t_status_prsnl_name = vc
           5 t_quantity = i4
       3 s_c_ctr = i4
       3 cass_qual[*]
         4 cass_id = f8
         4 cass_tag = c7
         4 cass_seq = i4
         4 cass_pieces = c3
         4 cass_fixative_cd = f8
         4 cass_fixative_disp = c40
         4 cass_updt_cnt = i4
         4 s_c_t_ctr = i4
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_task_assay_disp = vc
           5 t_task_assay_desc = vc
           5 t_comment = vc
           5 t_status_cd = f8
           5 t_status_disp = c40
           5 t_request_dt_tm = dq8
           5 t_create_inv_flag = i2
           5 t_hold_cd = f8
           5 t_hold_disp = c40
           5 t_hold_comment = vc
           5 t_updt_dt_tm = dq8
           5 t_status_dt_tm = dq8
           5 t_status_prsnl_name = vc
           5 t_quantity = i4
         4 s_c_slide_ctr = i4
         4 slide_qual[*]
           5 s_task_assay_cd = f8
           5 s_tag = c7
           5 s_seq = i4
           5 s_updt_cnt = i4
           5 s_c_s_t_ctr = i4
           5 t_qual[*]
             6 t_task_assay_cd = f8
             6 t_task_assay_disp = vc
             6 t_task_assay_desc = vc
             6 t_comment = vc
             6 t_status_cd = f8
             6 t_status_disp = c40
             6 t_request_dt_tm = dq8
             6 t_create_inv_flag = i2
             6 t_hold_cd = f8
             6 t_hold_disp = c40
             6 t_hold_comment = vc
             6 t_updt_dt_tm = dq8
             6 t_status_dt_tm = dq8
             6 t_status_prsnl_name = vc
             6 t_quantity = i4
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
 SET current_time = curtime3
 SET code_value = 0.0
 SET ordered_cd = 0.0
 SET cancelled_cd = 0.0
 SET spec_ctr = 0
 SET s_slide_ctr = 0
 SET s_c_ctr = 0
 SET s_c_slide_ctr = 0
 SET case_cnt = 0
 SET s_t_ctr = 0
 SET s_s_t_ctr = 0
 SET s_c_t_ctr = 0
 SET s_c_s_t_ctr = 0
 SET max_spec_ctr = 0
 SET max_s_slide_ctr = 0
 SET max_s_c_ctr = 0
 SET max_s_c_slide_ctr = 0
 SET max_s_t_ctr = 0
 SET max_s_s_t_ctr = 0
 SET max_s_c_t_ctr = 0
 SET max_s_c_s_t_ctr = 0
 SELECT INTO "nl:"
  pt.case_id, pt.processing_task_id, pt.status_prsnl_id,
  p.username, pt.case_specimen_id, pt.cassette_id,
  pt.slide_id, pt.status_cd, pt.request_prsnl_id,
  pt.task_assay_cd
  FROM processing_task pt,
   (dummyt d  WITH seq = value(reply->case_cnt)),
   prsnl p,
   dummyt d1
  PLAN (d)
   JOIN (pt
   WHERE (request->case_id=pt.case_id))
   JOIN (d1)
   JOIN (p
   WHERE pt.status_prsnl_id=p.person_id)
  ORDER BY pt.case_specimen_id, pt.cassette_id, pt.slide_id
  HEAD REPORT
   spec_ctr = 0, s_slide_ctr = 0, s_c_ctr = 0,
   s_c_slide_ctr = 0, case_cnt = 0, s_t_ctr = 0,
   s_s_t_ctr = 0, s_c_t_ctr = 0, s_c_s_t_ctr = 0,
   max_spec_ctr = 0, max_s_slide_ctr = 0, max_s_c_ctr = 0,
   max_s_c_slide_ctr = 0, max_s_t_ctr = 0, max_s_s_t_ctr = 0,
   max_s_c_t_ctr = 0, max_s_c_s_t_ctr = 0
  HEAD pt.case_id
   IF (d.seq > 0)
    stat = alterlist(reply->qual,d.seq)
   ENDIF
   reply->qual[d.seq].case_id = pt.case_id, case_cnt = d.seq, reply->case_cnt = case_cnt,
   reply->qual[d.seq].service_resource_cd = pt.service_resource_cd
  HEAD pt.case_specimen_id
   spec_ctr = (spec_ctr+ 1)
   IF (spec_ctr > max_spec_ctr)
    max_spec_ctr = spec_ctr
   ENDIF
   IF (spec_ctr > 0)
    stat = alterlist(reply->qual[d.seq].spec_qual,spec_ctr)
   ENDIF
   reply->qual[d.seq].spec_ctr = spec_ctr, reply->qual[d.seq].spec_qual[spec_ctr].case_specimen_id =
   pt.case_specimen_id, s_c_ctr = 0
  HEAD pt.cassette_id
   IF (pt.cassette_id != 0.0)
    s_c_ctr = (s_c_ctr+ 1)
    IF (s_c_ctr > max_s_c_ctr)
     max_s_c_ctr = s_c_ctr
    ENDIF
    stat = alterlist(reply->qual[d.seq].spec_qual[spec_ctr].cass_qual,s_c_ctr), reply->qual[d.seq].
    spec_qual[spec_ctr].s_c_ctr = s_c_ctr
   ENDIF
   s_c_slide_ctr = 0, s_slide_ctr = 0
  HEAD pt.slide_id
   IF (pt.cassette_id != 0.00)
    IF (pt.slide_id != 0.00)
     s_c_slide_ctr = (s_c_slide_ctr+ 1)
     IF (s_c_slide_ctr > max_s_c_slide_ctr)
      max_s_c_slide_ctr = s_c_slide_ctr
     ENDIF
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_slide_ctr = s_c_slide_ctr, stat =
     alterlist(reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,s_c_slide_ctr),
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_id = pt.cassette_id,
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].
     s_task_assay_cd = pt.slide_id
    ELSE
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_id = pt.cassette_id
    ENDIF
   ELSE
    IF (pt.slide_id != 0.00)
     s_slide_ctr = (s_slide_ctr+ 1)
     IF (s_slide_ctr > max_s_slide_ctr)
      max_s_slide_ctr = s_slide_ctr
     ENDIF
     reply->qual[d.seq].spec_qual[spec_ctr].s_slide_ctr = s_slide_ctr, stat = alterlist(reply->qual[d
      .seq].spec_qual[spec_ctr].slide_qual,s_slide_ctr), reply->qual[d.seq].spec_qual[spec_ctr].
     slide_qual[s_slide_ctr].sl_task_assay_cd = pt.slide_id
    ENDIF
   ENDIF
   s_c_s_t_ctr = 0, s_c_t_ctr = 0, s_s_t_ctr = 0,
   s_t_ctr = 0
  DETAIL
   IF (pt.cassette_id > 0)
    IF (pt.slide_id > 0)
     s_c_s_t_ctr = (s_c_s_t_ctr+ 1)
     IF (s_c_s_t_ctr > max_s_c_s_t_ctr)
      max_s_c_s_t_ctr = s_c_s_t_ctr
     ENDIF
     stat = alterlist(reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
      s_c_slide_ctr].t_qual,s_c_s_t_ctr), reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].
     slide_qual[s_c_slide_ctr].s_c_s_t_ctr = s_c_s_t_ctr, reply->qual[d.seq].spec_qual[spec_ctr].
     cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_task_assay_cd = pt
     .task_assay_cd
     IF (textlen(pt.comments) > 0)
      reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
      s_c_s_t_ctr].t_comment = pt.comments
     ENDIF
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_status_cd = pt.status_cd, reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[
     s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_request_dt_tm = pt.request_dt_tm, reply
     ->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_status_prsnl_name = p.username,
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_hold_cd = pt.hold_cd, reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].
     slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_updt_dt_tm = pt.updt_dt_tm, reply->qual[d.seq].
     spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_quantity
      = pt.quantity
    ELSE
     s_c_t_ctr = (s_c_t_ctr+ 1)
     IF (s_c_t_ctr > max_s_c_t_ctr)
      max_s_c_t_ctr = s_c_t_ctr
     ENDIF
     stat = alterlist(reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,s_c_t_ctr),
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_t_ctr = s_c_t_ctr, reply->qual[d
     .seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_task_assay_cd = pt
     .task_assay_cd
     IF (textlen(pt.comments) > 0)
      reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_comment = pt
      .comments
     ENDIF
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_status_cd = pt
     .status_cd, reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
     t_status_prsnl_name = p.username, reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].
     t_qual[s_c_t_ctr].t_request_dt_tm = pt.request_dt_tm,
     reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_hold_cd = pt
     .hold_cd, reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
     t_updt_dt_tm = pt.updt_dt_tm, reply->qual[d.seq].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[
     s_c_t_ctr].t_quantity = pt.quantity
    ENDIF
   ELSE
    IF (pt.slide_id > 0)
     s_s_t_ctr = (s_s_t_ctr+ 1)
     IF (s_s_t_ctr > max_s_s_t_ctr)
      max_s_s_t_ctr = s_s_t_ctr
     ENDIF
     stat = alterlist(reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,s_s_t_ctr
      ), reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].s_s_t_ctr = s_s_t_ctr, reply
     ->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_task_assay_cd = pt
     .task_assay_cd
     IF (textlen(pt.comments) > 0)
      reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_comment = pt
      .comments
     ENDIF
     reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_status_cd =
     pt.status_cd, reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_status_prsnl_name = p.username, reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr]
     .t_qual[s_s_t_ctr].t_request_dt_tm = pt.request_dt_tm,
     reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_hold_cd = pt
     .hold_cd, reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_updt_dt_tm = pt.updt_dt_tm, reply->qual[d.seq].spec_qual[spec_ctr].slide_qual[s_slide_ctr].
     t_qual[s_s_t_ctr].t_quantity = pt.quantity
    ELSE
     s_t_ctr = (s_t_ctr+ 1)
     IF (s_t_ctr > max_s_t_ctr)
      max_s_t_ctr = s_t_ctr
     ENDIF
     stat = alterlist(reply->qual[d.seq].spec_qual[spec_ctr].t_qual,s_t_ctr), reply->qual[d.seq].
     spec_qual[spec_ctr].s_t_ctr = s_t_ctr, reply->qual[d.seq].spec_qual[spec_ctr].t_qual[s_t_ctr].
     t_task_assay_cd = pt.task_assay_cd
     IF (textlen(pt.comments) > 0)
      reply->qual[d.seq].spec_qual[spec_ctr].t_qual[s_t_ctr].t_comment = trim(pt.comments)
     ENDIF
     reply->qual[d.seq].spec_qual[spec_ctr].t_qual[s_t_ctr].t_status_cd = pt.status_cd, reply->qual[d
     .seq].spec_qual[spec_ctr].t_qual[s_t_ctr].t_status_prsnl_name = p.username, reply->qual[d.seq].
     spec_qual[spec_ctr].t_qual[s_t_ctr].t_request_dt_tm = pt.request_dt_tm,
     reply->qual[d.seq].spec_qual[spec_ctr].t_qual[s_t_ctr].t_hold_cd = pt.hold_cd, reply->qual[d.seq
     ].spec_qual[spec_ctr].t_qual[s_t_ctr].t_updt_dt_tm = pt.updt_dt_tm, reply->qual[d.seq].
     spec_qual[spec_ctr].t_qual[s_t_ctr].t_quantity = pt.quantity
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  pc.prefix_cd, aptg_r.tag_type_flag, aptg_r.tag_separator,
  pr.name_full_formatted
  FROM pathology_case pc,
   (dummyt d  WITH seq = value(reply->case_cnt)),
   ap_prefix_tag_group_r aptg_r,
   person pr
  PLAN (d)
   JOIN (pc
   WHERE (reply->qual[d.seq].case_id=pc.case_id))
   JOIN (pr
   WHERE pc.person_id=pr.person_id)
   JOIN (aptg_r
   WHERE pc.prefix_cd=aptg_r.prefix_cd
    AND aptg_r.tag_type_flag > 1)
  HEAD REPORT
   tag_ctr = 0
  HEAD pc.prefix_cd
   reply->qual[d.seq].prefix_cd = pc.prefix_cd
  DETAIL
   tag_ctr = (tag_ctr+ 1), reply->qual[d.seq].tag_qual[tag_ctr].tag_type_flag = aptg_r.tag_type_flag,
   reply->qual[d.seq].tag_qual[tag_ctr].tag_separator = aptg_r.tag_separator
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "prefix_tag_group_r"
  SET reply->status_data.status = "F"
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  cs.specimen_description, apt.tag_disp
  FROM case_specimen cs,
   case_specimen_addl_info csai,
   ap_tag apt,
   (dummyt d  WITH seq = value(reply->case_cnt)),
   (dummyt d1  WITH seq = value(max_spec_ctr))
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
   JOIN (cs
   WHERE (reply->qual[d.seq].spec_qual[d1.seq].case_specimen_id=cs.case_specimen_id))
   JOIN (csai
   WHERE cs.case_specimen_id=csai.case_specimen_id)
   JOIN (apt
   WHERE cs.specimen_tag_cd=apt.tag_cd)
  DETAIL
   reply->qual[d.seq].spec_qual[d1.seq].spec_descr = cs.specimen_description, reply->qual[d.seq].
   spec_qual[d1.seq].spec_tag = apt.tag_disp, reply->qual[d.seq].spec_qual[d1.seq].spec_seq = apt
   .tag_sequence,
   reply->qual[d.seq].spec_qual[d1.seq].spec_fixative_cd = cs.received_fixative_cd, reply->qual[d.seq
   ].spec_qual[d1.seq].spec_status_cd = csai.status_cd, reply->qual[d.seq].spec_qual[d1.seq].
   spec_updt_cnt = csai.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
  SET reply->status_data.status = "F"
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  ct.tag_disp, c.pieces
  FROM cassette c,
   ap_tag ct,
   (dummyt d  WITH seq = value(reply->case_cnt)),
   (dummyt d1  WITH seq = value(max_spec_ctr)),
   (dummyt d2  WITH seq = value(max_s_c_ctr))
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d.seq].spec_qual[d1.seq].s_c_ctr))
   JOIN (c
   WHERE (reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_id=c.cassette_id))
   JOIN (ct
   WHERE c.cassette_tag_cd=ct.tag_cd)
  DETAIL
   reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_tag = ct.tag_disp, reply->qual[d.seq].
   spec_qual[d1.seq].cass_qual[d2.seq].cass_seq = ct.tag_sequence, reply->qual[d.seq].spec_qual[d1
   .seq].cass_qual[d2.seq].cass_pieces = c.pieces,
   reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_fixative_cd = c.fixative_cd, reply->
   qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_updt_cnt = c.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASSETTE TAGS, AP_TAG"
  SET reply->status_data.status = "F"
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  join_path = decode(s.seq,"S",s1.seq,"S1"," "), ct_tag_disp = ct.tag_disp, ct1_tag_disp = ct1
  .tag_disp
  FROM slide s,
   slide s1,
   ap_tag ct,
   ap_tag ct1,
   (dummyt d1  WITH seq = value(reply->case_cnt)),
   (dummyt d2  WITH seq = value(max_spec_ctr)),
   (dummyt d3  WITH seq = value(max_s_slide_ctr)),
   (dummyt d4  WITH seq = value(max_s_c_ctr)),
   (dummyt d5  WITH seq = value(max_s_c_slide_ctr))
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d1.seq].spec_ctr))
   JOIN (((d3
   WHERE (d3.seq <= reply->qual[d1.seq].spec_qual[d2.seq].s_slide_ctr))
   JOIN (s
   WHERE (reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_task_assay_cd=s.slide_id))
   JOIN (ct
   WHERE s.tag_cd=ct.tag_cd)
   ) ORJOIN ((d4
   WHERE (d4.seq <= reply->qual[d1.seq].spec_qual[d2.seq].s_c_ctr))
   JOIN (d5
   WHERE (d5.seq <= reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].s_c_slide_ctr))
   JOIN (s1
   WHERE (reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].s_task_assay_cd=
   s1.slide_id))
   JOIN (ct1
   WHERE s1.tag_cd=ct1.tag_cd)
   ))
  DETAIL
   CASE (join_path)
    OF "S":
     reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_tag = ct.tag_disp,reply->qual[d1.seq
     ].spec_qual[d2.seq].slide_qual[d3.seq].sl_seq = ct.tag_sequence,reply->qual[d1.seq].spec_qual[d2
     .seq].slide_qual[d3.seq].sl_updt_cnt = s.updt_cnt
    OF "S1":
     reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].s_tag = ct1.tag_disp,
     reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].s_seq = ct1
     .tag_sequence,reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].
     s_updt_cnt = ct1.updt_cnt
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE TAGS, AP_TAG"
  SET reply->status_data.status = "F"
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
END GO
