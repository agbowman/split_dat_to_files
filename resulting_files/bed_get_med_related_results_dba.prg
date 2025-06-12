CREATE PROGRAM bed_get_med_related_results:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assays[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 result_type_code_value = f8
      2 result_type_display = vc
      2 activity_type_code_value = f8
      2 activity_type_display = vc
      2 required_ind = i2
      2 document_ind = i2
      2 acknowledge_ind = i2
      2 view_only_ind = i2
      2 lookback_minutes = i4
      2 sequence = i4
      2 dgroup_label_ind = i2
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
 SET ackresultmin_offset_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002164
   AND cv.cdf_meaning="ACKRESULTMIN"
   AND cv.active_ind=1
  DETAIL
   ackresultmin_offset_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET acnt = 0
 SELECT INTO "nl:"
  FROM task_discrete_r t,
   discrete_task_assay dta,
   code_value cv1,
   code_value cv2,
   dta_offset_min d
  PLAN (t
   WHERE (t.reference_task_id=request->task_id)
    AND t.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=t.task_assay_cd
    AND dta.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=dta.default_result_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=dta.activity_type_cd
    AND cv2.active_ind=1)
   JOIN (d
   WHERE d.task_assay_cd=outerjoin(dta.task_assay_cd)
    AND d.offset_min_type_cd=outerjoin(ackresultmin_offset_type_cd)
    AND d.active_ind=outerjoin(1))
  ORDER BY t.sequence
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(reply->assays,acnt), reply->assays[acnt].code_value = dta
   .task_assay_cd,
   reply->assays[acnt].display = dta.mnemonic, reply->assays[acnt].description = dta.description,
   reply->assays[acnt].result_type_code_value = cv1.code_value,
   reply->assays[acnt].result_type_display = cv1.display, reply->assays[acnt].
   activity_type_code_value = cv2.code_value, reply->assays[acnt].activity_type_display = cv2.display,
   reply->assays[acnt].required_ind = t.required_ind, reply->assays[acnt].document_ind = t
   .document_ind, reply->assays[acnt].acknowledge_ind = t.acknowledge_ind,
   reply->assays[acnt].view_only_ind = t.view_only_ind, reply->assays[acnt].lookback_minutes = d
   .offset_min_nbr, reply->assays[acnt].sequence = t.sequence
  WITH nocounter
 ;end select
 FREE SET rep_groups
 RECORD rep_groups(
   1 assays[*]
     2 ta_code = f8
 )
 SET task_cnt = 0
 SELECT INTO "nl:"
  FROM doc_set_ref d1,
   doc_set_section_ref_r d2,
   doc_set_section_ref d3,
   doc_set_element_ref d4
  PLAN (d1
   WHERE d1.doc_set_description IN ("", " ", null)
    AND d1.active_ind=1
    AND d1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND d1.doc_set_ref_id=d1.prev_doc_set_ref_id)
   JOIN (d2
   WHERE d2.doc_set_ref_id=d1.doc_set_ref_id
    AND d2.active_ind=1
    AND d2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND d2.doc_set_section_ref_r_id=d2.prev_doc_set_section_ref_r_id)
   JOIN (d3
   WHERE d3.doc_set_section_ref_id=d2.doc_set_section_ref_id
    AND d3.active_ind=1
    AND d3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND d3.doc_set_section_ref_id=d3.prev_doc_set_section_ref_id)
   JOIN (d4
   WHERE d4.doc_set_section_ref_id=d3.doc_set_section_ref_id
    AND d4.active_ind=1
    AND d4.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND d4.doc_set_element_id=d4.prev_doc_set_element_id
    AND d4.task_assay_cd > 0)
  ORDER BY d4.task_assay_cd
  HEAD REPORT
   task_cnt = 0, task_tot_cnt = 0, stat = alterlist(rep_groups->assays,100)
  HEAD d4.task_assay_cd
   task_cnt = (task_cnt+ 1), task_tot_cnt = (task_tot_cnt+ 1)
   IF (task_tot_cnt > 100)
    stat = alterlist(rep_groups->assays,(task_cnt+ 100)), task_tot_cnt = 1
   ENDIF
   rep_groups->assays[task_cnt].ta_code = d4.task_assay_cd
  FOOT REPORT
   stat = alterlist(rep_groups->assays,task_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(rep_groups)
 FOR (a = 1 TO acnt)
   SET num = 0
   SET tindex = 0
   SET tindex = locatevalsort(num,1,task_cnt,reply->assays[a].code_value,rep_groups->assays[num].
    ta_code)
   IF (tindex > 0)
    SET reply->assays[a].dgroup_label_ind = 1
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
