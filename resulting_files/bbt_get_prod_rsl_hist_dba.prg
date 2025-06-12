CREATE PROGRAM bbt_get_prod_rsl_hist:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 service_resource_cd = f8
     2 task_assay_cd = f8
     2 task_assay_mnemonic = vc
     2 bb_result_processing_cd = f8
     2 bb_result_processing_disp = vc
     2 bb_result_processing_mean = c12
     2 results[*]
       3 perform_result_id = f8
       3 result_id = f8
       3 bb_result_id = f8
       3 bb_control_cell_cd = f8
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 result_status_mean = c12
       3 result_type_cd = f8
       3 result_type_disp = vc
       3 result_type_mean = c12
       3 nomenclature_id = f8
       3 short_string = vc
       3 result_value_mean = c12
       3 result_value_numeric = f8
       3 numeric_raw_value = f8
       3 result_value_alpha = vc
       3 result_value_dt_tm = dq8
       3 long_text_id = f8
       3 rtf_text = vc
       3 ascii_text = vc
       3 result_comment_ind = i2
       3 perform_personnel_id = f8
       3 perform_personnel_name = vc
       3 perform_dt_tm = dq8
       3 result_code_set_cd = f8
       3 result_code_set_disp = c40
       3 delta_cd = f8
       3 delta_disp = vc
       3 delta_mean = c12
       3 normal_cd = f8
       3 normal_disp = vc
       3 normal_mean = c12
       3 critical_cd = f8
       3 critical_disp = vc
       3 critical_mean = c12
       3 review_cd = f8
       3 review_disp = vc
       3 review_mean = c12
       3 event_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET data_map_type_flag = 0
 SET nbr_of_assays = size(request->assays,5)
 DECLARE a_cnt = i4
 DECLARE r_cnt = i4
 DECLARE idx = i4
 DECLARE max_r_cnt = i4
 DECLARE skip_result_ind = i2
 SET retrieve_results_yn = "N"
 SET reply->status_data.status = "F"
 SET in_progress_cd = 0.0
 SET crossmatch_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "16"
 SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,in_progress_cd)
 IF (stat=1)
  GO TO resize_reply
 ENDIF
 SET cdf_meaning = "3"
 SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,crossmatch_cd)
 IF (stat=1)
  GO TO resize_reply
 ENDIF
 SELECT INTO "nl:"
  d.seq, o.seq, o.order_id,
  dta.seq, dta.task_assay_cd, apr.seq,
  d2.seq, r.seq, pr.seq,
  lt.seq, result_comment_yn = decode(rc.seq,"Y",o.seq,"N","Z"), rc.seq,
  re.event_dt_tm, prs.username
  FROM (dummyt d  WITH seq = value(nbr_of_assays)),
   orders o,
   discrete_task_assay dta,
   assay_processing_r apr,
   dummyt d2,
   result r,
   perform_result pr,
   nomenclature n,
   long_text lt,
   result_comment rc,
   result_event re,
   prsnl prs
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->assays[d.seq].order_id))
   JOIN (dta
   WHERE (dta.task_assay_cd=request->assays[d.seq].task_assay_cd))
   JOIN (apr
   WHERE (apr.service_resource_cd=request->assays[d.seq].service_resource_cd)
    AND apr.task_assay_cd=dta.task_assay_cd)
   JOIN (r
   WHERE (r.order_id=request->assays[d.seq].order_id)
    AND (r.task_assay_cd=request->assays[d.seq].task_assay_cd))
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (re
   WHERE pr.perform_result_id=re.perform_result_id
    AND pr.result_id=re.result_id)
   JOIN (prs
   WHERE re.event_personnel_id=prs.person_id)
   JOIN (lt
   WHERE lt.long_text_id=pr.long_text_id)
   JOIN (n
   WHERE n.nomenclature_id=pr.nomenclature_id)
   JOIN (d2)
   JOIN (rc
   WHERE rc.result_id=pr.result_id)
  ORDER BY o.order_id, dta.task_assay_cd
  HEAD REPORT
   a_cnt = 0, r_cnt = 0, max_r_cnt = 0
  HEAD o.order_id
   r_cnt = 0, max_r_cnt = 0
  HEAD dta.task_assay_cd
   r_cnt = 0, a_cnt += 1, stat = alterlist(reply->qual,a_cnt),
   stat = alterlist(reply->qual[a_cnt].results,r_cnt), reply->qual[a_cnt].task_assay_cd = dta
   .task_assay_cd, reply->qual[a_cnt].task_assay_mnemonic = dta.mnemonic,
   reply->qual[a_cnt].order_id = o.order_id, reply->qual[a_cnt].service_resource_cd = request->
   assays[d.seq].service_resource_cd, reply->qual[a_cnt].bb_result_processing_cd = dta
   .bb_result_processing_cd
  DETAIL
   r_cnt += 1, stat = alterlist(reply->qual[a_cnt].results,r_cnt)
   IF (r_cnt > max_r_cnt)
    max_r_cnt = r_cnt
   ENDIF
   reply->qual[a_cnt].results[r_cnt].delta_cd = pr.delta_cd, reply->qual[a_cnt].results[r_cnt].
   normal_cd = pr.normal_cd, reply->qual[a_cnt].results[r_cnt].critical_cd = pr.critical_cd,
   reply->qual[a_cnt].results[r_cnt].review_cd = pr.review_cd, reply->qual[a_cnt].results[r_cnt].
   perform_result_id = pr.perform_result_id, reply->qual[a_cnt].results[r_cnt].result_id = r
   .result_id,
   reply->qual[a_cnt].results[r_cnt].bb_result_id = r.bb_result_id, reply->qual[a_cnt].results[r_cnt]
   .bb_control_cell_cd = r.bb_control_cell_cd, reply->qual[a_cnt].results[r_cnt].result_status_cd =
   re.event_type_cd,
   reply->qual[a_cnt].results[r_cnt].event_sequence = re.event_sequence, reply->qual[a_cnt].results[
   r_cnt].result_type_cd = pr.result_type_cd
   IF (pr.nomenclature_id > 0)
    reply->qual[a_cnt].results[r_cnt].nomenclature_id = pr.nomenclature_id, reply->qual[a_cnt].
    results[r_cnt].short_string = n.short_string
   ENDIF
   reply->qual[a_cnt].results[r_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[
   a_cnt].results[r_cnt].numeric_raw_value = pr.numeric_raw_value, reply->qual[a_cnt].results[r_cnt].
   result_value_alpha = pr.result_value_alpha,
   reply->qual[a_cnt].results[r_cnt].result_value_dt_tm = pr.result_value_dt_tm, reply->qual[a_cnt].
   results[r_cnt].long_text_id = pr.long_text_id
   IF (lt.long_text_id > 0.0)
    reply->qual[a_cnt].results[r_cnt].rtf_text = lt.long_text
   ENDIF
   reply->qual[a_cnt].results[r_cnt].ascii_text = pr.ascii_text, reply->qual[a_cnt].results[r_cnt].
   perform_personnel_id = prs.person_id, reply->qual[a_cnt].results[r_cnt].perform_personnel_name =
   prs.username,
   reply->qual[a_cnt].results[r_cnt].perform_dt_tm = re.event_dt_tm, reply->qual[a_cnt].results[r_cnt
   ].result_code_set_cd = pr.result_code_set_cd
   IF (result_comment_yn="Y")
    reply->qual[a_cnt].results[r_cnt].result_comment_ind = 1
   ELSE
    reply->qual[a_cnt].results[r_cnt].result_comment_ind = 0
   ENDIF
  FOOT  o.order_id
   row + 0
  FOOT  dta.task_assay_cd
   row + 0
  WITH nocounter, outerjoin = d2, dontcare = rc,
   maxqual(rc,1), memsort
 ;end select
#resize_reply
 IF (a_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET a_cnt = 1
  SET max_r_cnt = 1
 ENDIF
END GO
