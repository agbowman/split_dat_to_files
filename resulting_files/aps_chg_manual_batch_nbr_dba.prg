CREATE PROGRAM aps_chg_manual_batch_nbr:dba
 RECORD reply(
   1 ccnt = i4
   1 qual[*]
     2 case_id = f8
     2 accession_nbr = c21
     2 spec_ctr = i4
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 spec_descr = vc
       3 spec_tag = c7
       3 spec_seq = i4
       3 s_t_ctr = i4
       3 t_qual[*]
         4 t_task_assay_cd = f8
         4 t_task_assay_disp = vc
         4 t_task_assay_desc = vc
         4 t_request_dt_tm = dq8
         4 t_requestor_name = vc
         4 t_worklist_nbr = i4
         4 t_processing_task_id = f8
         4 t_service_resource_cd = f8
         4 t_service_resource_disp = c40
         4 t_service_resource_desc = vc
         4 t_updt_cnt = i4
       3 s_slide_ctr = i4
       3 slide_qual[*]
         4 sl_slide_id = f8
         4 sl_tag_cd = f8
         4 sl_tag = c7
         4 sl_seq = i4
         4 s_s_t_ctr = i4
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_task_assay_disp = vc
           5 t_task_assay_desc = vc
           5 t_request_dt_tm = dq8
           5 t_requestor_name = vc
           5 t_worklist_nbr = i4
           5 t_processing_task_id = f8
           5 t_service_resource_cd = f8
           5 t_service_resource_disp = c40
           5 t_service_resource_desc = vc
           5 t_updt_cnt = i4
       3 s_c_ctr = i4
       3 cass_qual[*]
         4 cass_id = f8
         4 cass_tag = c7
         4 cass_tag_cd = f8
         4 cass_seq = i4
         4 s_c_t_ctr = i4
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_task_assay_disp = vc
           5 t_task_assay_desc = vc
           5 t_request_dt_tm = dq8
           5 t_requestor_name = vc
           5 t_worklist_nbr = i4
           5 t_processing_task_id = f8
           5 t_service_resource_cd = f8
           5 t_service_resource_disp = c40
           5 t_service_resource_desc = vc
           5 t_updt_cnt = i4
         4 s_c_slide_ctr = i4
         4 slide_qual[*]
           5 s_slide_id = f8
           5 s_tag_cd = f8
           5 s_tag = c7
           5 s_seq = i4
           5 s_c_s_t_ctr = i4
           5 t_qual[*]
             6 t_task_assay_cd = f8
             6 t_task_assay_disp = vc
             6 t_task_assay_desc = vc
             6 t_request_dt_tm = dq8
             6 t_requestor_name = vc
             6 t_worklist_nbr = i4
             6 t_processing_task_id = f8
             6 t_service_resource_cd = f8
             6 t_service_resource_disp = c40
             6 t_service_resource_desc = vc
             6 t_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 get_tag_info = c1
     2 get_specimen_info = c1
     2 get_cassette_info = c1
     2 get_slide_info = c1
 )
#script
 SET reply->status_data.status = "F"
 SET current_time = curtime3
 SET code_value = 0.0
 SET ordered_cd = 0.0
 SET spec_ctr = 0
 SET s_slide_ctr = 0
 SET s_c_ctr = 0
 SET s_c_slide_ctr = 0
 SET ccnt = 0
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
 SET plan_where = fillstring(1000," ")
 SET plan_where = "(ordered_cd = pt.status_cd)"
 DECLARE ap_tag_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx3 = i4 WITH protect, noconstant(0)
 IF ((request->service_resource_cd > 0))
  SET cntr = 0
  SELECT INTO "nl:"
   rg.child_service_resource_cd
   FROM resource_group rg
   WHERE (request->service_resource_cd=rg.parent_service_resource_cd)
    AND rg.active_ind=1
    AND rg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND rg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   HEAD REPORT
    plan_where = build(trim(plan_where),"and (pt.service_resource_cd in (",request->
     service_resource_cd)
   DETAIL
    cntr = (cntr+ 1), plan_where = build(trim(plan_where),",",rg.child_service_resource_cd)
   FOOT REPORT
    plan_where = build(trim(plan_where),"))")
   WITH nocounter
  ;end select
  IF (cntr=0)
   SET plan_where = build(trim(plan_where),
    " and (request->service_resource_cd = pt.service_resource_cd)")
  ENDIF
 ENDIF
 IF ( NOT (validate(temp_ap_tag,0)))
  RECORD temp_ap_tag(
    1 qual[*]
      2 tag_group_id = f8
      2 tag_id = f8
      2 tag_sequence = i4
      2 tag_disp = c7
  )
 ENDIF
 DECLARE aps_get_tags(none) = i4
 SUBROUTINE aps_get_tags(none)
   DECLARE tag_cnt = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
   DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
   SELECT INTO "nl:"
    ap.tag_id
    FROM ap_tag ap
    WHERE ap.active_ind=1
    ORDER BY ap.tag_group_id, ap.tag_sequence
    HEAD REPORT
     tag_cnt = 0
    DETAIL
     tag_cnt = (tag_cnt+ 1)
     IF (tag_cnt > size(temp_ap_tag->qual,5))
      stat = alterlist(temp_ap_tag->qual,(tag_cnt+ 9))
     ENDIF
     temp_ap_tag->qual[tag_cnt].tag_group_id = ap.tag_group_id, temp_ap_tag->qual[tag_cnt].tag_id =
     ap.tag_id, temp_ap_tag->qual[tag_cnt].tag_sequence = ap.tag_sequence,
     temp_ap_tag->qual[tag_cnt].tag_disp = ap.tag_disp
    FOOT REPORT
     stat = alterlist(temp_ap_tag->qual,tag_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (((error_check != 0) OR (tag_cnt=0)) )
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
    SET reply->status_data.status = "Z"
    RETURN(0)
   ENDIF
   RETURN(tag_cnt)
 END ;Subroutine
 SET ap_tag_cnt = aps_get_tags(0)
 IF (ap_tag_cnt=0)
  GO TO exit_program
 ENDIF
 SET code_set = 1305
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 IF ((request->task_assay_cd > 0))
  SET plan_where = build(trim(plan_where)," and (request->task_assay_cd = pt.task_assay_cd)")
 ENDIF
 SELECT INTO "nl:"
  pt.case_id, p.name_full_formatted, pt.case_specimen_id,
  pt.case_specimen_tag_id, pt.cassette_id, pt.cassette_tag_id,
  pt.slide_id, pt.slide_tag_id, pt.status_cd,
  pt.request_prsnl_id, pt.task_assay_cd, pt.create_inventory_flag,
  ncreatespecimen = evaluate(pt.create_inventory_flag,4,1,0), ncreateblock = evaluate(pt
   .create_inventory_flag,1,1,2,0,
   3,1,4,0,0,
   0), ncreateslide = evaluate(pt.create_inventory_flag,1,0,2,1,
   3,1,4,0,0,
   0),
  ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1].
   tag_id), ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[idx2].
   tag_id), ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx3].
   tag_id)
  FROM processing_task pt,
   prsnl p,
   pathology_case pc
  PLAN (pc
   WHERE pc.accession_nbr BETWEEN request->beg_acc_nbr AND request->end_acc_nbr)
   JOIN (pt
   WHERE parser(trim(plan_where))
    AND pt.case_id=pc.case_id)
   JOIN (p
   WHERE pt.request_prsnl_id=p.person_id)
  ORDER BY pc.accession_nbr, ap_tag_spec_idx, ncreatespecimen DESC,
   ap_tag_cass_idx, pt.cassette_id, ncreateblock DESC,
   ap_tag_slide_idx, pt.slide_id, ncreateslide DESC,
   pt.request_dt_tm
  HEAD REPORT
   spec_ctr = 0, s_slide_ctr = 0, s_c_ctr = 0,
   s_c_slide_ctr = 0, ccnt = 0, s_t_ctr = 0,
   s_s_t_ctr = 0, s_c_t_ctr = 0, s_c_s_t_ctr = 0,
   max_spec_ctr = 0, max_s_slide_ctr = 0, max_s_c_ctr = 0,
   max_s_c_slide_ctr = 0, max_s_t_ctr = 0, max_s_s_t_ctr = 0,
   max_s_c_t_ctr = 0, max_s_c_s_t_ctr = 0
  HEAD pc.accession_nbr
   ccnt = (ccnt+ 1)
   IF (ccnt > 0)
    stat = alterlist(reply->qual,ccnt)
   ENDIF
   reply->qual[ccnt].case_id = pt.case_id, reply->ccnt = ccnt, reply->qual[ccnt].accession_nbr = pc
   .accession_nbr,
   spec_ctr = 0
  HEAD ap_tag_spec_idx
   spec_ctr = (spec_ctr+ 1)
   IF (spec_ctr > max_spec_ctr)
    max_spec_ctr = spec_ctr
   ENDIF
   IF (spec_ctr > 0)
    stat = alterlist(reply->qual[ccnt].spec_qual,spec_ctr)
   ENDIF
   reply->qual[ccnt].spec_ctr = spec_ctr, reply->qual[ccnt].spec_qual[spec_ctr].case_specimen_id = pt
   .case_specimen_id, reply->qual[ccnt].spec_qual[spec_ctr].case_specimen_tag_cd = pt
   .case_specimen_tag_id,
   s_c_ctr = 0
  HEAD pt.cassette_id
   IF (pt.cassette_id != 0.0)
    s_c_ctr = (s_c_ctr+ 1)
    IF (s_c_ctr > max_s_c_ctr)
     max_s_c_ctr = s_c_ctr
    ENDIF
    stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].cass_qual,s_c_ctr), reply->qual[ccnt].
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
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_slide_ctr = s_c_slide_ctr, stat =
     alterlist(reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,s_c_slide_ctr),
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_id = pt.cassette_id,
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_tag_cd = pt.cassette_tag_id, reply
     ->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].s_slide_id = pt
     .slide_id, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].
     s_tag_cd = pt.slide_tag_id
    ELSE
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_id = pt.cassette_id, reply->qual[
     ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_tag_cd = pt.cassette_tag_id
    ENDIF
   ELSE
    IF (pt.slide_id != 0.00)
     s_slide_ctr = (s_slide_ctr+ 1)
     IF (s_slide_ctr > max_s_slide_ctr)
      max_s_slide_ctr = s_slide_ctr
     ENDIF
     reply->qual[ccnt].spec_qual[spec_ctr].s_slide_ctr = s_slide_ctr, stat = alterlist(reply->qual[
      ccnt].spec_qual[spec_ctr].slide_qual,s_slide_ctr), reply->qual[ccnt].spec_qual[spec_ctr].
     slide_qual[s_slide_ctr].sl_slide_id = pt.slide_id,
     reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].sl_tag_cd = pt.slide_tag_id
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
     stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
      s_c_slide_ctr].t_qual,s_c_s_t_ctr), reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].
     slide_qual[s_c_slide_ctr].s_c_s_t_ctr = s_c_s_t_ctr, reply->qual[ccnt].spec_qual[spec_ctr].
     cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_task_assay_cd = pt
     .task_assay_cd,
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_request_dt_tm = pt.request_dt_tm, reply->qual[ccnt].spec_qual[spec_ctr].
     cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_requestor_name = p
     .name_full_formatted, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
     s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_processing_task_id = pt.processing_task_id, reply->qual[ccnt].spec_qual[spec_ctr]
     .cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_updt_cnt = pt.updt_cnt,
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_service_resource_cd = pt.service_resource_cd
    ELSE
     s_c_t_ctr = (s_c_t_ctr+ 1)
     IF (s_c_t_ctr > max_s_c_t_ctr)
      max_s_c_t_ctr = s_c_t_ctr
     ENDIF
     stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,s_c_t_ctr),
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_t_ctr = s_c_t_ctr, reply->qual[ccnt
     ].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_task_assay_cd = pt.task_assay_cd,
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_requestor_name = p
     .name_full_formatted, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr]
     .t_request_dt_tm = pt.request_dt_tm, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].
     t_qual[s_c_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_updt_cnt = pt
     .updt_cnt, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
     t_service_resource_cd = pt.service_resource_cd, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[
     s_c_ctr].t_qual[s_c_t_ctr].t_processing_task_id = pt.processing_task_id
    ENDIF
   ELSE
    IF (pt.slide_id > 0)
     s_s_t_ctr = (s_s_t_ctr+ 1)
     IF (s_s_t_ctr > max_s_s_t_ctr)
      max_s_s_t_ctr = s_s_t_ctr
     ENDIF
     stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,s_s_t_ctr),
     reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].s_s_t_ctr = s_s_t_ctr, reply->
     qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_task_assay_cd = pt
     .task_assay_cd,
     reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_requestor_name
      = p.name_full_formatted, reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[
     s_s_t_ctr].t_request_dt_tm = pt.request_dt_tm, reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[
     s_slide_ctr].t_qual[s_s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_updt_cnt = pt
     .updt_cnt, reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_service_resource_cd = pt.service_resource_cd, reply->qual[ccnt].spec_qual[spec_ctr].
     slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_processing_task_id = pt.processing_task_id
    ELSE
     s_t_ctr = (s_t_ctr+ 1)
     IF (s_t_ctr > max_s_t_ctr)
      max_s_t_ctr = s_t_ctr
     ENDIF
     stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].t_qual,s_t_ctr), reply->qual[ccnt].
     spec_qual[spec_ctr].s_t_ctr = s_t_ctr, reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].
     t_task_assay_cd = pt.task_assay_cd,
     reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_requestor_name = p.name_full_formatted,
     reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_request_dt_tm = pt.request_dt_tm, reply
     ->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_updt_cnt = pt.updt_cnt, reply->qual[ccnt
     ].spec_qual[spec_ctr].t_qual[s_t_ctr].t_service_resource_cd = pt.service_resource_cd, reply->
     qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_processing_task_id = pt.processing_task_id
    ENDIF
   ENDIF
  WITH nocounter
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
  cs.specimen_description
  FROM case_specimen cs,
   (dummyt d  WITH seq = value(reply->ccnt)),
   (dummyt d1  WITH seq = value(max_spec_ctr))
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
   JOIN (cs
   WHERE (reply->qual[d.seq].spec_qual[d1.seq].case_specimen_id=cs.case_specimen_id))
  DETAIL
   reply->qual[d.seq].spec_qual[d1.seq].spec_descr = cs.specimen_description, ap_tag_spec_idx =
   locateval(idx1,1,ap_tag_cnt,cs.specimen_tag_id,temp_ap_tag->qual[idx1].tag_id)
   IF (ap_tag_spec_idx > 0)
    reply->qual[d.seq].spec_qual[d1.seq].spec_tag = temp_ap_tag->qual[ap_tag_spec_idx].tag_disp,
    reply->qual[d.seq].spec_qual[d1.seq].spec_seq = temp_ap_tag->qual[ap_tag_spec_idx].tag_sequence
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
  SET reply->exception_data[1].get_specimen_info = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  c.pieces
  FROM cassette c,
   (dummyt d  WITH seq = value(reply->ccnt)),
   (dummyt d1  WITH seq = value(max_spec_ctr)),
   (dummyt d2  WITH seq = value(max_s_c_ctr))
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d.seq].spec_qual[d1.seq].s_c_ctr))
   JOIN (c
   WHERE (reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_id=c.cassette_id))
  DETAIL
   ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,c.cassette_tag_id,temp_ap_tag->qual[idx2].tag_id)
   IF (ap_tag_cass_idx > 0)
    reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_tag = temp_ap_tag->qual[
    ap_tag_cass_idx].tag_disp, reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_seq =
    temp_ap_tag->qual[ap_tag_cass_idx].tag_sequence
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASSETTE TAGS, AP_TAG"
  SET reply->exception_data[1].get_cassette_info = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  join_path = decode(s.seq,"S",s1.seq,"S1"," ")
  FROM slide s,
   slide s1,
   (dummyt d1  WITH seq = value(reply->ccnt)),
   (dummyt d2  WITH seq = value(max_spec_ctr)),
   (dummyt d3  WITH seq = value(max_s_slide_ctr)),
   (dummyt d4  WITH seq = value(max_s_c_ctr)),
   (dummyt d5  WITH seq = value(max_s_c_slide_ctr)),
   (dummyt d6  WITH seq = 1),
   (dummyt d7  WITH seq = 1)
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d1.seq].spec_ctr))
   JOIN (((d3
   WHERE (d3.seq <= reply->qual[d1.seq].spec_qual[d2.seq].s_slide_ctr))
   JOIN (d6)
   JOIN (s
   WHERE (reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_slide_id=s.slide_id))
   ) ORJOIN ((d4
   WHERE (d4.seq <= reply->qual[d1.seq].spec_qual[d2.seq].s_c_ctr))
   JOIN (d5
   WHERE (d5.seq <= reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].s_c_slide_ctr))
   JOIN (d7)
   JOIN (s1
   WHERE (reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].s_slide_id=s1
   .slide_id))
   ))
  DETAIL
   CASE (join_path)
    OF "S":
     ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,s.tag_id,temp_ap_tag->qual[idx3].tag_id),
     IF (ap_tag_slide_idx > 0)
      reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_tag = temp_ap_tag->qual[
      ap_tag_slide_idx].tag_disp, reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_seq =
      temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence
     ENDIF
    OF "S1":
     ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,s1.tag_id,temp_ap_tag->qual[idx3].tag_id),
     IF (ap_tag_slide_idx > 0)
      reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].s_tag = temp_ap_tag
      ->qual[ap_tag_slide_idx].tag_disp, reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].
      slide_qual[d5.seq].s_seq = temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence
     ENDIF
   ENDCASE
  WITH nocounter, outerjoin = d6, outerjoin = d7
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE TAGS, AP_TAG"
  SET reply->exception_data[1].get_slide_info = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
 IF ((reply->exception_data[1].get_tag_info="F")
  AND (reply->exception_data[1].get_specimen_info="F")
  AND (reply->exception_data[1].get_cassette_info="F")
  AND (reply->exception_data[1].get_slide_info="F"))
  SET reply->status_data.status = "F"
 ENDIF
 IF (validate(temp_ap_tag,0))
  FREE RECORD temp_ap_tag
 ENDIF
END GO
