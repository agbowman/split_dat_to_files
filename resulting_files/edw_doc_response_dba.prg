CREATE PROGRAM edw_doc_response:dba
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE i1 = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE maxcnt = i4 WITH protect, noconstant(0)
 DECLARE root_cd = f8 WITH protect, noconstant(0.0)
 DECLARE child_cd = f8 WITH protect, noconstant(0.0)
 DECLARE num_cd = f8 WITH protect, noconstant(0.0)
 DECLARE txt_cd = f8 WITH protect, noconstant(0.0)
 DECLARE date_cd = f8 WITH protect, noconstant(0.0)
 DECLARE grp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE srf_numeric = f8 WITH protect, noconstant(0.0)
 DECLARE srf_date = f8 WITH protect, noconstant(0.0)
 DECLARE srf_alpha = f8 WITH protect, noconstant(0.0)
 DECLARE inerror_cd = f8 WITH protect, noconstant(0.0)
 DECLARE in_error_cd = f8 WITH protect, noconstant(0.0)
 DECLARE parser_line = vc WITH constant(build("BUILD(",value(encounter_nk),")"))
 DECLARE doc_cnt = i4 WITH noconstant(0)
 DECLARE parent_cnt = i4 WITH noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE active_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 SET root_cd = uar_get_code_by("MEANING",24,"ROOT")
 SET child_cd = uar_get_code_by("MEANING",24,"CHILD")
 SET num_cd = uar_get_code_by("MEANING",53,"NUM")
 SET txt_cd = uar_get_code_by("MEANING",53,"TXT")
 SET date_cd = uar_get_code_by("MEANING",53,"DATE")
 SET grp_cd = uar_get_code_by("MEANING",53,"GRP")
 SET srf_numeric = uar_get_code_by("MEANING",14113,"NUMERIC")
 SET srf_date = uar_get_code_by("MEANING",14113,"DATE")
 SET srf_alpha = uar_get_code_by("MEANING",14113,"ALPHA")
 SET inerror_cd = uar_get_code_by("MEANING",8,"INERROR")
 SET in_error_cd = uar_get_code_by("MEANING",8,"IN ERROR")
 SET clinical_event_comp_cd = uar_get_code_by("MEANING",18189,"CLINCALEVENT")
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(medium_batch_size)
 SET ds_item_cnt = 0
 SELECT INTO "nl:"
  enc_nk = parser(parser_line)
  FROM dcp_forms_activity da,
   dcp_forms_activity_comp dac,
   clinical_event ce,
   dcp_forms_ref dfr,
   clinical_event ce1,
   dcp_section_ref dcr,
   encounter
  PLAN (da
   WHERE da.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   JOIN (dac
   WHERE dac.dcp_forms_activity_id=da.dcp_forms_activity_id
    AND dac.parent_entity_name="CLINICAL_EVENT"
    AND dac.component_cd=clinical_event_comp_cd)
   JOIN (ce
   WHERE ce.event_id=dac.parent_entity_id
    AND ce.record_status_cd=active_status_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=cnvtreal(trim(ce.collating_seq,3))
    AND da.version_dt_tm BETWEEN dfr.beg_effective_dt_tm AND dfr.end_effective_dt_tm)
   JOIN (ce1
   WHERE ce1.parent_event_id=dac.parent_entity_id
    AND ce1.event_reltn_cd=child_cd
    AND findstring(";",ce1.collating_seq)=0
    AND ce1.record_status_cd=active_status_cd
    AND ce1.valid_until_dt_tm > cnvtdatetime(curtime,curdate))
   JOIN (dcr
   WHERE dcr.dcp_section_ref_id=cnvtreal(trim(ce1.collating_seq,3))
    AND ce1.updt_dt_tm BETWEEN dcr.beg_effective_dt_tm AND dcr.end_effective_dt_tm)
   JOIN (encounter
   WHERE encounter.encntr_id=da.encntr_id)
  ORDER BY da.encntr_id, ce1.event_id, dfr.beg_effective_dt_tm DESC,
   dcr.beg_effective_dt_tm DESC
  HEAD da.encntr_id
   parent_cnt = (parent_cnt+ 1)
   IF (mod(parent_cnt,100)=1)
    stat = alterlist(doc_response_parents->qual,(parent_cnt+ 99))
   ENDIF
   doc_response_parents->qual[parent_cnt].encntr_id = da.encntr_id
  HEAD ce1.event_id
   ds_item_cnt = (ds_item_cnt+ 1)
   IF (mod(ds_item_cnt,100)=1)
    stat = alterlist(doc_response_keys->qual,(ds_item_cnt+ 99))
   ENDIF
   doc_response_keys->qual[ds_item_cnt].dcp_section_instance_id = dcr.dcp_section_instance_id,
   doc_response_keys->qual[ds_item_cnt].form_event_id = ce.event_id, doc_response_keys->qual[
   ds_item_cnt].encounter_nk = enc_nk,
   doc_response_keys->qual[ds_item_cnt].loc_facility_cd = encounter.loc_facility_cd,
   doc_response_keys->qual[ds_item_cnt].doc_activity_sk = da.dcp_forms_activity_id, doc_response_keys
   ->qual[ds_item_cnt].component_ref = dac.component_cd
   IF (ce.authentic_flag != 1
    AND ce.result_status_cd IN (inerror_cd, in_error_cd))
    doc_response_keys->qual[ds_item_cnt].active_ind = 0
   ELSE
    doc_response_keys->qual[ds_item_cnt].active_ind = 1
   ENDIF
   doc_response_keys->qual[ds_item_cnt].dcp_form_instance_id = dfr.dcp_form_instance_id,
   doc_response_keys->qual[ds_item_cnt].ce1_event_id = ce1.event_id
  FOOT REPORT
   stat = alterlist(doc_response_keys->qual,ds_item_cnt), stat = alterlist(doc_response_parents->qual,
    parent_cnt)
  WITH nocounter
 ;end select
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),ds_item_cnt)
 WHILE (keys_start <= keys_end)
   SET stat = alterlist(doc_response->qual,keys_batch)
   IF (debug="Y")
    CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(keys_end)
      ))
   ENDIF
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
     SET temp_indx = (temp_indx+ 1)
     SET doc_response->qual[temp_indx].dcp_section_instance_id = doc_response_keys->qual[i].
     dcp_section_instance_id
     SET doc_response->qual[temp_indx].form_event_id = doc_response_keys->qual[i].form_event_id
     SET doc_response->qual[temp_indx].encounter_nk = doc_response_keys->qual[i].encounter_nk
     SET doc_response->qual[temp_indx].loc_facility_cd = doc_response_keys->qual[i].loc_facility_cd
     SET doc_response->qual[temp_indx].doc_activity_sk = doc_response_keys->qual[i].doc_activity_sk
     SET doc_response->qual[temp_indx].component_ref = doc_response_keys->qual[i].component_ref
     SET doc_response->qual[temp_indx].active_ind = doc_response_keys->qual[i].active_ind
     SET doc_response->qual[temp_indx].dcp_form_instance_id = doc_response_keys->qual[i].
     dcp_form_instance_id
     SET doc_response->qual[temp_indx].ce1_event_id = doc_response_keys->qual[i].ce1_event_id
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
   ELSE
    SET cur_list_size = keys_batch
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     dcp_forms_activity da
    PLAN (d)
     JOIN (da
     WHERE (da.dcp_forms_activity_id=doc_response->qual[d.seq].doc_activity_sk))
    DETAIL
     doc_response->qual[d.seq].encounter_sk = da.encntr_id, doc_response->qual[d.seq].form_person_sk
      = da.person_id, doc_response->qual[d.seq].form_status_ref = da.form_status_cd,
     doc_response->qual[d.seq].form_dt_tm = da.form_dt_tm, doc_response->qual[d.seq].
     form_version_dt_tm = da.version_dt_tm, doc_response->qual[d.seq].first_documented_dt_tm = da
     .beg_activity_dt_tm,
     doc_response->qual[d.seq].last_documented_dt_tm = da.last_activity_dt_tm, doc_response->qual[d
     .seq].completion_flg = da.flags, doc_response->qual[d.seq].task_activity_sk = da.task_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     clinical_event ce2
    PLAN (d)
     JOIN (ce2
     WHERE (ce2.parent_event_id=doc_response->qual[d.seq].ce1_event_id)
      AND ce2.event_reltn_cd=child_cd
      AND ce2.record_status_cd=active_status_cd
      AND ce2.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
    HEAD ce2.event_id
     IF (ce2.event_class_cd != grp_cd)
      cnt = (cnt+ 1), doc_response->qual[d.seq].res_cnt = (doc_response->qual[d.seq].res_cnt+ 1), i1
       = doc_response->qual[d.seq].res_cnt,
      stat = alterlist(doc_response->qual[d.seq].results,i1)
      IF ((doc_response->qual[d.seq].active_ind=1)
       AND ce2.record_status_cd=active_status_cd
       AND ce2.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
       doc_response->qual[d.seq].results[i1].active_ind = 1
      ELSE
       doc_response->qual[d.seq].results[i1].active_ind = 0
      ENDIF
      doc_response->qual[d.seq].results[i1].ce2_event_id = ce2.event_id, doc_response->qual[d.seq].
      results[i1].event_sk = ce2.event_id, doc_response->qual[d.seq].results[i1].parent_event_sk =
      ce2.parent_event_id,
      doc_response->qual[d.seq].results[i1].event_class_cd = ce2.event_class_cd, doc_response->qual[d
      .seq].results[i1].section_event_sk = doc_response->qual[d.seq].ce1_event_id, doc_response->
      qual[d.seq].results[i1].doc_response_sk = concat(trim(cnvtstring(ce2.event_id,16),3),"~-3"),
      doc_response->qual[d.seq].results[i1].doc_input_sk = build(cnvtstring(doc_response->qual[d.seq]
        .dcp_form_instance_id,16),"~",cnvtstring(doc_response->qual[d.seq].dcp_section_instance_id,16
        ),"~",cnvtstring(ce2.event_cd,16))
     ELSE
      doc_response->qual[d.seq].grid_component_cnt = (doc_response->qual[d.seq].grid_component_cnt+ 1
      ), i2 = doc_response->qual[d.seq].grid_component_cnt, stat = alterlist(doc_response->qual[d.seq
       ].grid_components,i2),
      doc_response->qual[d.seq].grid_components[i2].event_id = ce2.event_id, doc_response->qual[d.seq
      ].grid_components[i2].ce2_event_cd = ce2.event_cd, doc_response->qual[d.seq].grid_components[i2
      ].ce2_collating_seq = ce2.collating_seq
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(cur_list_size)),
     (dummyt d2  WITH seq = 1),
     clinical_event ce3
    PLAN (d1
     WHERE maxrec(d2,doc_response->qual[d1.seq].grid_component_cnt))
     JOIN (d2)
     JOIN (ce3
     WHERE (ce3.parent_event_id=doc_response->qual[d1.seq].grid_components[d2.seq].event_id)
      AND ce3.event_reltn_cd=child_cd
      AND ce3.record_status_cd=active_status_cd
      AND ce3.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
    HEAD ce3.event_id
     IF (ce3.event_class_cd != grp_cd)
      cnt = (cnt+ 1), doc_response->qual[d1.seq].res_cnt = (doc_response->qual[d1.seq].res_cnt+ 1),
      i1 = doc_response->qual[d1.seq].res_cnt,
      stat = alterlist(doc_response->qual[d1.seq].results,i1), doc_response->qual[d1.seq].results[i1]
      .event_sk = ce3.event_id, doc_response->qual[d1.seq].results[i1].parent_event_sk = ce3
      .parent_event_id,
      doc_response->qual[d1.seq].results[i1].event_class_cd = ce3.event_class_cd, doc_response->qual[
      d1.seq].results[i1].section_event_sk = doc_response->qual[d1.seq].ce1_event_id, doc_response->
      qual[d1.seq].results[i1].grid_event_sk = doc_response->qual[d1.seq].grid_components[d2.seq].
      event_id,
      doc_response->qual[d1.seq].results[i1].row_event_sk = ce3.event_id, doc_response->qual[d1.seq].
      results[i1].doc_response_sk = concat(trim(cnvtstring(ce3.event_id,16),3),"~-3"), doc_response->
      qual[d1.seq].results[i1].doc_input_sk = build(trim(cnvtstring(doc_response->qual[d1.seq].
         dcp_form_instance_id,16),3),"~",trim(cnvtstring(doc_response->qual[d1.seq].
         dcp_section_instance_id,16),3),"~",trim(cnvtstring(doc_response->qual[d1.seq].
         grid_components[d2.seq].ce2_collating_seq),3),
       "~",cnvtstring(ce3.event_cd,16)),
      doc_response->qual[d1.seq].results[i1].ce3_event_id = ce3.event_id, doc_response->qual[d1.seq].
      results[i1].collating_seq_3 = ce3.collating_seq
     ELSE
      doc_response->qual[d1.seq].power_grid_component_cnt = (doc_response->qual[d1.seq].
      power_grid_component_cnt+ 1), i2 = doc_response->qual[d1.seq].power_grid_component_cnt, stat =
      alterlist(doc_response->qual[d1.seq].power_grid_components,i2),
      doc_response->qual[d1.seq].power_grid_components[i2].event_id = ce3.event_id, doc_response->
      qual[d1.seq].power_grid_components[i2].parent_event_id = doc_response->qual[d1.seq].
      grid_components[d2.seq].event_id, doc_response->qual[d1.seq].power_grid_components[i2].
      ce2_event_cd = doc_response->qual[d1.seq].grid_components[d2.seq].ce2_event_cd,
      doc_response->qual[d1.seq].power_grid_components[i2].ce3_event_cd = ce3.event_cd
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(cur_list_size)),
     (dummyt d2  WITH seq = 1),
     clinical_event ce4
    PLAN (d1
     WHERE maxrec(d2,doc_response->qual[d1.seq].power_grid_component_cnt))
     JOIN (d2)
     JOIN (ce4
     WHERE (ce4.parent_event_id=doc_response->qual[d1.seq].power_grid_components[d2.seq].event_id)
      AND ce4.event_reltn_cd=child_cd
      AND ce4.record_status_cd=active_status_cd
      AND ce4.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
    HEAD ce4.event_id
     IF (ce4.event_id > 0)
      cnt = (cnt+ 1), doc_response->qual[d1.seq].res_cnt = (doc_response->qual[d1.seq].res_cnt+ 1),
      i1 = doc_response->qual[d1.seq].res_cnt,
      stat = alterlist(doc_response->qual[d1.seq].results,i1), doc_response->qual[d1.seq].results[i1]
      .event_sk = ce4.event_id, doc_response->qual[d1.seq].results[i1].parent_event_sk = ce4
      .parent_event_id,
      doc_response->qual[d1.seq].results[i1].event_class_cd = ce4.event_class_cd, doc_response->qual[
      d1.seq].results[i1].section_event_sk = doc_response->qual[d1.seq].ce1_event_id, doc_response->
      qual[d1.seq].results[i1].grid_event_sk = doc_response->qual[d1.seq].power_grid_components[d2
      .seq].parent_event_id,
      doc_response->qual[d1.seq].results[i1].row_event_sk = doc_response->qual[d1.seq].
      power_grid_components[d2.seq].event_id, doc_response->qual[d1.seq].results[i1].column_event_sk
       = ce4.event_id, doc_response->qual[d1.seq].results[i1].doc_response_sk = concat(trim(
        cnvtstring(ce4.event_id,16),3),"~-3"),
      doc_response->qual[d1.seq].results[i1].doc_input_sk = build(cnvtstring(doc_response->qual[d1
        .seq].dcp_form_instance_id,16),"~",cnvtstring(doc_response->qual[d1.seq].
        dcp_section_instance_id,16),"~",cnvtstring(doc_response->qual[d1.seq].power_grid_components[
        d2.seq].ce2_event_cd),
       "~",cnvtstring(doc_response->qual[d1.seq].power_grid_components[d2.seq].ce3_event_cd),"~",
       cnvtstring(ce4.task_assay_cd))
     ENDIF
    WITH nocounter
   ;end select
   IF (cnt > 0)
    IF (debug="Y")
     CALL echo(concat("Found ",build(cur_list_size)," sections and ",build(cnt)," components."))
    ENDIF
   ELSE
    IF (debug="Y")
     CALL echo("No updated records found!")
    ENDIF
    GO TO endprogram
   ENDIF
   SELECT INTO "nl:"
    FROM ce_date_result cdr,
     (dummyt d1  WITH seq = value(cur_list_size)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(doc_response->qual[d1.seq].results,5)))
     JOIN (d2
     WHERE (doc_response->qual[d1.seq].results[d2.seq].event_class_cd=date_cd))
     JOIN (cdr
     WHERE (cdr.event_id=doc_response->qual[d1.seq].results[d2.seq].event_sk))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), doc_response->qual[d1.seq].results[d2.seq].date_time_response_dt_tm = cdr
     .result_dt_tm
     IF (cdr.result_tz > 0)
      doc_response->qual[d1.seq].results[d2.seq].date_time_response_tm_zn = cdr.result_tz
     ENDIF
     doc_response->qual[d1.seq].results[d2.seq].response_value = trim(format(cdr.result_dt_tm,
       "MM/DD/YYYY HH:MM;;D"),3), doc_response->qual[d1.seq].results[d2.seq].doc_response_sk = concat
     (trim(cnvtstring(cdr.event_id,16),3),"~-2"), doc_response->qual[d1.seq].results[d2.seq].
     doc_response_seq = "-2",
     doc_response->qual[d1.seq].results[d2.seq].set_ind = 1
     IF ((doc_response->qual[d1.seq].active_ind=1)
      AND cdr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
      doc_response->qual[d1.seq].results[d2.seq].active_ind = 1
     ELSE
      doc_response->qual[d1.seq].results[d2.seq].active_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cnt)," results in the CE_DATE_RESULT table."))
   ENDIF
   SELECT INTO "nl:"
    FROM ce_coded_result ccr,
     nomenclature n,
     (dummyt d1  WITH seq = value(cur_list_size)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(doc_response->qual[d1.seq].results,5)))
     JOIN (d2
     WHERE (doc_response->qual[d1.seq].results[d2.seq].event_class_cd != date_cd))
     JOIN (ccr
     WHERE (ccr.event_id=doc_response->qual[d1.seq].results[d2.seq].event_sk))
     JOIN (n
     WHERE n.nomenclature_id=ccr.nomenclature_id)
    ORDER BY ccr.event_id, ccr.sequence_nbr, ccr.valid_until_dt_tm DESC
    HEAD ccr.event_id
     cnt = 0
    HEAD ccr.sequence_nbr
     cnt = (cnt+ 1)
     IF (cnt=1)
      doc_response->qual[d1.seq].results[d2.seq].alpha_response_sk = trim(cnvtstring(n
        .nomenclature_id,16),3), doc_response->qual[d1.seq].results[d2.seq].response_value = evaluate
      (size(trim(n.source_string,3),1),0,uar_get_code_display(ccr.result_cd),trim(n.source_string,3)),
      doc_response->qual[d1.seq].results[d2.seq].doc_response_sk = concat(trim(cnvtstring(ccr
         .event_id,16),3),"~",trim(cnvtstring(ccr.sequence_nbr),3)),
      doc_response->qual[d1.seq].results[d2.seq].doc_response_seq = trim(cnvtstring(ccr.sequence_nbr),
       3), doc_response->qual[d1.seq].results[d2.seq].set_ind = 1, doc_response->qual[d1.seq].
      results[d2.seq].result_ref = ccr.result_cd
      IF ((doc_response->qual[d1.seq].active_ind=1)
       AND ccr.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100"))
       doc_response->qual[d1.seq].results[d2.seq].active_ind = 1
      ELSE
       doc_response->qual[d1.seq].results[d2.seq].active_ind = 0
      ENDIF
     ELSE
      doc_response->qual[d1.seq].res_cnt = (doc_response->qual[d1.seq].res_cnt+ 1), i1 = doc_response
      ->qual[d1.seq].res_cnt, stat = alterlist(doc_response->qual[d1.seq].results,i1),
      doc_response->qual[d1.seq].results[i1].alpha_response_sk = trim(cnvtstring(n.nomenclature_id,16
        ),3), doc_response->qual[d1.seq].results[i1].response_value = evaluate(size(trim(n
         .source_string,3),1),0,uar_get_code_display(ccr.result_cd),trim(n.source_string,3)),
      doc_response->qual[d1.seq].results[i1].doc_response_sk = concat(trim(cnvtstring(ccr.event_id,16
         ),3),"~",trim(cnvtstring(ccr.sequence_nbr),3)),
      doc_response->qual[d1.seq].results[i1].doc_response_seq = trim(cnvtstring(ccr.sequence_nbr),3),
      doc_response->qual[d1.seq].results[i1].set_ind = 1, doc_response->qual[d1.seq].results[i1].
      result_ref = ccr.result_cd
      IF ((doc_response->qual[d1.seq].active_ind=1)
       AND ccr.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100"))
       doc_response->qual[d1.seq].results[i1].active_ind = 1
      ELSE
       doc_response->qual[d1.seq].results[i1].active_ind = 0
      ENDIF
      doc_response->qual[d1.seq].results[i1].event_sk = doc_response->qual[d1.seq].results[d2.seq].
      event_sk, doc_response->qual[d1.seq].results[i1].parent_event_sk = doc_response->qual[d1.seq].
      results[d2.seq].parent_event_sk, doc_response->qual[d1.seq].results[i1].section_event_sk =
      doc_response->qual[d1.seq].results[d2.seq].section_event_sk,
      doc_response->qual[d1.seq].results[i1].grid_event_sk = doc_response->qual[d1.seq].results[d2
      .seq].grid_event_sk, doc_response->qual[d1.seq].results[i1].row_event_sk = doc_response->qual[
      d1.seq].results[d2.seq].row_event_sk, doc_response->qual[d1.seq].results[i1].column_event_sk =
      doc_response->qual[d1.seq].results[d2.seq].column_event_sk,
      doc_response->qual[d1.seq].results[i1].doc_input_sk = doc_response->qual[d1.seq].results[d2.seq
      ].doc_input_sk
     ENDIF
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cnt)," results in the CE_CODED_RESULT table."))
   ENDIF
   SELECT INTO "nl:"
    FROM ce_string_result csr,
     (dummyt d1  WITH seq = value(cur_list_size)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(doc_response->qual[d1.seq].results,5)))
     JOIN (d2
     WHERE (doc_response->qual[d1.seq].results[d2.seq].event_class_cd != date_cd))
     JOIN (csr
     WHERE (csr.event_id=doc_response->qual[d1.seq].results[d2.seq].event_sk))
    ORDER BY csr.event_id, d2.seq, csr.valid_until_dt_tm
    HEAD REPORT
     MACRO (check_set_ind)
      IF ((doc_response->qual[d1.seq].results[d2.seq].set_ind > 0))
       maxcnt = (maxcnt+ 1), cnt = maxcnt, stat = alterlist(doc_response->qual[d1.seq].results,cnt),
       doc_response->qual[d1.seq].results[cnt].event_sk = doc_response->qual[d1.seq].results[d2.seq].
       event_sk, doc_response->qual[d1.seq].results[cnt].parent_event_sk = doc_response->qual[d1.seq]
       .results[d2.seq].parent_event_sk, doc_response->qual[d1.seq].results[cnt].section_event_sk =
       doc_response->qual[d1.seq].results[d2.seq].section_event_sk,
       doc_response->qual[d1.seq].results[cnt].grid_event_sk = doc_response->qual[d1.seq].results[d2
       .seq].grid_event_sk, doc_response->qual[d1.seq].results[cnt].row_event_sk = doc_response->
       qual[d1.seq].results[d2.seq].row_event_sk, doc_response->qual[d1.seq].results[cnt].
       column_event_sk = doc_response->qual[d1.seq].results[d2.seq].column_event_sk,
       doc_response->qual[d1.seq].results[cnt].doc_input_sk = doc_response->qual[d1.seq].results[d2
       .seq].doc_input_sk
      ELSE
       cnt = d2.seq
      ENDIF
     ENDMACRO
     , cnt = 0
    HEAD csr.event_id
     maxcnt = size(doc_response->qual[d1.seq].results,5)
    FOOT  csr.event_id
     IF (csr.string_result_format_cd=srf_numeric)
      check_set_ind, doc_response->qual[d1.seq].results[cnt].numeric_response = trim(replace(csr
        .string_result_text,",",""),3), doc_response->qual[d1.seq].results[cnt].response_value = trim
      (csr.string_result_text,3),
      doc_response->qual[d1.seq].results[cnt].doc_response_sk = concat(trim(cnvtstring(csr.event_id,
         16),3),"~-1"), doc_response->qual[d1.seq].results[cnt].doc_response_seq = "-1", doc_response
      ->qual[d1.seq].results[cnt].set_ind = 1
     ELSEIF ( NOT (csr.string_result_format_cd IN (srf_numeric, srf_date)))
      check_set_ind, doc_response->qual[d1.seq].results[cnt].string_response = trim(csr
       .string_result_text,3), doc_response->qual[d1.seq].results[cnt].response_value = trim(csr
       .string_result_text,3),
      doc_response->qual[d1.seq].results[cnt].doc_response_sk = concat(trim(cnvtstring(csr.event_id,
         16),3),"~-1"), doc_response->qual[d1.seq].results[cnt].doc_response_seq = "-1", doc_response
      ->qual[d1.seq].results[cnt].set_ind = 1
     ENDIF
     IF ((doc_response->qual[d1.seq].active_ind=1)
      AND csr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
      doc_response->qual[d1.seq].results[cnt].active_ind = 1
     ELSE
      doc_response->qual[d1.seq].results[cnt].active_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cnt)," results in the CE_STRING_RESULT table."))
   ENDIF
   IF (size(doc_response->qual,5) > 0)
    FOR (i = 1 TO size(doc_response->qual,5))
      SET timezone = gettimezone(doc_response->qual[i].loc_facility_cd,doc_response->qual[i].
       encounter_sk)
      SET doc_response->qual[i].form_tm_zn = evaluate(doc_response->qual[i].form_tm_zn,0,cnvtint(
        timezone),doc_response->qual[i].form_tm_zn)
      SET doc_response->qual[i].form_version_tm_zn = evaluate(doc_response->qual[i].
       form_version_tm_zn,0,cnvtint(timezone),doc_response->qual[i].form_version_tm_zn)
      SET doc_response->qual[i].first_documented_tm_zn = evaluate(doc_response->qual[i].
       first_documented_tm_zn,0,cnvtint(timezone),doc_response->qual[i].first_documented_tm_zn)
      SET doc_response->qual[i].last_documented_tm_zn = evaluate(doc_response->qual[i].
       last_documented_tm_zn,0,cnvtint(timezone),doc_response->qual[i].last_documented_tm_zn)
      IF (size(doc_response->qual[i].results,5) > 0)
       FOR (j = 1 TO size(doc_response->qual[i].results,5))
         SET doc_response->qual[i].results[j].date_time_response_tm_zn = evaluate(doc_response->qual[
          i].results[j].date_time_response_tm_zn,0,cnvtint(timezone),doc_response->qual[i].results[j]
          .date_time_response_tm_zn)
       ENDFOR
      ENDIF
      IF (encounter_nk != default_encounter_nk)
       SET doc_response->qual[i].encounter_nk = get_encounter_nk(doc_response->qual[i].encounter_sk)
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO value(docresp_extractfile)
    FROM (dummyt d1  WITH seq = value(cur_list_size)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(doc_response->qual[d1.seq].results,5)))
     JOIN (d2
     WHERE (doc_response->qual[d1.seq].results[d2.seq].event_sk > 0))
    ORDER BY doc_response->qual[d1.seq].results[d2.seq].doc_response_sk
    DETAIL
     doc_cnt = (doc_cnt+ 1), col 0, health_system_id,
     v_bar, health_system_source_id, v_bar,
     doc_response->qual[d1.seq].results[d2.seq].doc_response_sk, v_bar,
     CALL print(trim(doc_response->qual[d1.seq].encounter_nk)),
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].encounter_sk,16),3)), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].event_sk,16),3)), v_bar,
     doc_response->qual[d1.seq].results[d2.seq].doc_response_seq,
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].doc_activity_sk,16),3)), v_bar,
     doc_response->qual[d1.seq].results[d2.seq].doc_input_sk, v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].form_person_sk,16),3)),
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].form_status_ref,16),3)), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,doc_response->qual[d1.seq].form_dt_tm,0,
        cnvtdatetimeutc(doc_response->qual[d1.seq].form_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].form_tm_zn))),
     v_bar,
     CALL print(evaluate(datetimezoneformat(doc_response->qual[d1.seq].form_dt_tm,cnvtint(
        doc_response->qual[d1.seq].form_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,doc_response->qual[d1.seq].
        form_version_dt_tm,0,cnvtdatetimeutc(doc_response->qual[d1.seq].form_version_dt_tm,3)),
       utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].form_version_tm_zn))),
     v_bar,
     CALL print(evaluate(datetimezoneformat(doc_response->qual[d1.seq].form_version_dt_tm,cnvtint(
        doc_response->qual[d1.seq].form_version_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,doc_response->qual[d1.seq].
        first_documented_dt_tm,0,cnvtdatetimeutc(doc_response->qual[d1.seq].first_documented_dt_tm,3)
        ),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].first_documented_tm_zn))),
     v_bar,
     CALL print(evaluate(datetimezoneformat(doc_response->qual[d1.seq].first_documented_dt_tm,cnvtint
       (doc_response->qual[d1.seq].first_documented_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,doc_response->qual[d1.seq].
        last_documented_dt_tm,0,cnvtdatetimeutc(doc_response->qual[d1.seq].last_documented_dt_tm,3)),
       utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].last_documented_tm_zn))),
     v_bar,
     CALL print(evaluate(datetimezoneformat(doc_response->qual[d1.seq].last_documented_dt_tm,cnvtint(
        doc_response->qual[d1.seq].last_documented_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].completion_flg,16),3)), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].component_ref,16),3)),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,doc_response->qual[d1.seq].results[d2.seq].
        date_time_response_dt_tm,0,cnvtdatetimeutc(doc_response->qual[d1.seq].results[d2.seq].
         date_time_response_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].date_time_response_tm_zn))
     ), v_bar,
     CALL print(evaluate(datetimezoneformat(doc_response->qual[d1.seq].results[d2.seq].
       date_time_response_dt_tm,cnvtint(doc_response->qual[d1.seq].results[d2.seq].
        date_time_response_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")),
     v_bar,
     CALL print(trim(replace(doc_response->qual[d1.seq].results[d2.seq].string_response,str_find,
       str_replace,3),3)), v_bar,
     CALL print(trim(replace(doc_response->qual[d1.seq].results[d2.seq].numeric_response,str_find,
       str_replace,3),3)), v_bar,
     CALL print(trim(doc_response->qual[d1.seq].results[d2.seq].alpha_response_sk)),
     v_bar,
     CALL print(trim(replace(doc_response->qual[d1.seq].results[d2.seq].response_value,str_find,
       str_replace,3))), v_bar,
     "3", v_bar, extract_dt_tm_fmt,
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].active_ind,16),3)), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].parent_event_sk,16),3)),
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].form_event_id,16),3)),
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].section_event_sk,16),3)),
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].grid_event_sk,16),3)),
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].column_event_sk,16),3)),
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].row_event_sk,16),3)),
     v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].results[d2.seq].result_ref,16),3)), v_bar,
     CALL print(trim(cnvtstring(doc_response->qual[d1.seq].task_activity_sk,16),3)),
     v_bar, row + 1
    WITH noheading, nocounter, format = lfstream,
     maxcol = 1999, maxrow = 1, append
   ;end select
   SET stat = initrec(doc_response)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),ds_item_cnt)
 ENDWHILE
#endprogram
 IF (ds_item_cnt=0)
  SELECT INTO value(docresp_extractfile)
   FROM dummyt
   WHERE ds_item_cnt > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD doc_response
 FREE RECORD doc_response_keys
 CALL edwupdatescriptstatus("DOCRESP",doc_cnt,"030","030")
 CALL echo(build("DOCRESP Count = ",doc_cnt))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "031 06/01/2021 AP086433"
END GO
