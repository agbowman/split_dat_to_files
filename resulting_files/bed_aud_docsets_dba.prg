CREATE PROGRAM bed_aud_docsets:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 docsets[*]
      2 id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 docsets[*]
     2 id = f8
     2 name = vc
     2 sections[*]
       3 name = vc
       3 elements[*]
         4 name = vc
     2 task_list = vc
 )
 SET reply->status_data.status = "F"
 SET dcnt = 0
 SET scnt = 0
 SET ecnt = 0
 SET total_elements = 0
 SET rcnt = size(request->docsets,5)
 IF (rcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rcnt)),
    doc_set_ref ds,
    doc_set_section_ref_r r,
    doc_set_section_ref s,
    doc_set_element_ref e,
    code_value cv
   PLAN (d)
    JOIN (ds
    WHERE (ds.doc_set_ref_id=request->docsets[d.seq].id))
    JOIN (r
    WHERE r.doc_set_ref_id=ds.doc_set_ref_id
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND r.prev_doc_set_section_ref_r_id=r.doc_set_section_ref_r_id
     AND r.active_ind=1)
    JOIN (s
    WHERE s.doc_set_section_ref_id=r.doc_set_section_ref_id
     AND s.doc_set_section_description > " "
     AND s.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND s.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND s.prev_doc_set_section_ref_id=s.doc_set_section_ref_id
     AND s.active_ind=1)
    JOIN (e
    WHERE e.doc_set_section_ref_id=r.doc_set_section_ref_id
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND e.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=e.task_assay_cd
     AND cv.active_ind=1)
   ORDER BY cnvtupper(ds.doc_set_name), r.doc_set_section_sequence, e.doc_set_elem_sequence,
    ds.doc_set_ref_id, r.doc_set_section_ref_r_id
   HEAD ds.doc_set_ref_id
    dcnt = (dcnt+ 1), stat = alterlist(temp->docsets,dcnt), temp->docsets[dcnt].id = ds
    .doc_set_ref_id,
    temp->docsets[dcnt].name = ds.doc_set_name, scnt = 0
   HEAD r.doc_set_section_ref_r_id
    scnt = (scnt+ 1), stat = alterlist(temp->docsets[dcnt].sections,scnt), temp->docsets[dcnt].
    sections[scnt].name = s.doc_set_section_name,
    ecnt = 0
   DETAIL
    total_elements = (total_elements+ 1), ecnt = (ecnt+ 1), stat = alterlist(temp->docsets[dcnt].
     sections[scnt].elements,ecnt),
    temp->docsets[dcnt].sections[scnt].elements[ecnt].name = cv.display
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM doc_set_ref ds,
    doc_set_section_ref_r r,
    doc_set_section_ref s,
    doc_set_element_ref e,
    code_value cv
   PLAN (ds
    WHERE ds.active_ind=1
     AND ds.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ds.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ds.prev_doc_set_ref_id=ds.doc_set_ref_id
     AND ds.doc_set_description > " ")
    JOIN (r
    WHERE r.doc_set_ref_id=ds.doc_set_ref_id
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND r.prev_doc_set_section_ref_r_id=r.doc_set_section_ref_r_id
     AND r.active_ind=1)
    JOIN (s
    WHERE s.doc_set_section_ref_id=r.doc_set_section_ref_id
     AND s.doc_set_section_description > " "
     AND s.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND s.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND s.prev_doc_set_section_ref_id=s.doc_set_section_ref_id
     AND s.active_ind=1)
    JOIN (e
    WHERE e.doc_set_section_ref_id=r.doc_set_section_ref_id
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND e.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=e.task_assay_cd
     AND cv.active_ind=1)
   ORDER BY cnvtupper(ds.doc_set_name), r.doc_set_section_sequence, e.doc_set_elem_sequence,
    ds.doc_set_ref_id, r.doc_set_section_ref_r_id
   HEAD ds.doc_set_ref_id
    dcnt = (dcnt+ 1), stat = alterlist(temp->docsets,dcnt), temp->docsets[dcnt].id = ds
    .doc_set_ref_id,
    temp->docsets[dcnt].name = ds.doc_set_name, scnt = 0
   HEAD r.doc_set_section_ref_r_id
    scnt = (scnt+ 1), stat = alterlist(temp->docsets[dcnt].sections,scnt), temp->docsets[dcnt].
    sections[scnt].name = s.doc_set_section_name,
    ecnt = 0
   DETAIL
    total_elements = (total_elements+ 1), ecnt = (ecnt+ 1), stat = alterlist(temp->docsets[dcnt].
     sections[scnt].elements,ecnt),
    temp->docsets[dcnt].sections[scnt].elements[ecnt].name = cv.display
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (total_elements > 60000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (total_elements > 30000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dcnt > 0)
  SET tcnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(dcnt)),
    task_charting_agent_r r,
    order_task o
   PLAN (d)
    JOIN (r
    WHERE (r.charting_agent_entity_id=temp->docsets[d.seq].id)
     AND r.charting_agent_entity_name="DOC_SET_REF")
    JOIN (o
    WHERE o.reference_task_id=r.reference_task_id
     AND o.active_ind=1
     AND o.quick_chart_done_ind IN (0, null)
     AND o.quick_chart_ind IN (0, null))
   ORDER BY d.seq, o.reference_task_id
   HEAD d.seq
    tcnt = 0
   HEAD o.reference_task_id
    tcnt = (tcnt+ 1)
    IF (tcnt=1)
     temp->docsets[d.seq].task_list = o.task_description
    ELSE
     temp->docsets[d.seq].task_list = build2(temp->docsets[d.seq].task_list,", ",o.task_description)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "DocSet Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Section Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay Display Name (Mnemonic)"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Task Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 IF (dcnt > 0)
  SET row_nbr = 0
  FOR (d = 1 TO dcnt)
   SET scnt = size(temp->docsets[d].sections,5)
   FOR (s = 1 TO scnt)
    SET ecnt = size(temp->docsets[d].sections[s].elements,5)
    FOR (e = 1 TO ecnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->docsets[d].name
      SET reply->rowlist[row_nbr].celllist[2].string_value = temp->docsets[d].sections[s].name
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->docsets[d].sections[s].elements[e]
      .name
      SET reply->rowlist[row_nbr].celllist[4].string_value = temp->docsets[d].task_list
    ENDFOR
   ENDFOR
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("docsets.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
