CREATE PROGRAM edw_doc_input_ref:dba
 RECORD doc_input_ref_keys(
   1 qual[*]
     2 dcp_form_instance_id = f8
     2 dcp_forms_def_id = f8
     2 dcp_section_instance_id = f8
     2 dcp_input_ref_id = f8
 )
 RECORD temp(
   1 index_cnt = i4
   1 index_qual[*]
     2 form_inst_sk = f8
     2 form_description = vc
     2 section_inst_sk = f8
     2 section_description = vc
     2 doc_component_sk = vc
     2 doc_input_sk = vc
     2 form_ref_sk = f8
     2 form_def_sk = f8
     2 form_definition = vc
     2 form_beg_effective_dt_tm = dq8
     2 form_end_effective_dt_tm = dq8
     2 section_ref_sk = f8
     2 section_definition = vc
     2 section_sequence = i4
     2 section_beg_effective_dt_tm = dq8
     2 section_end_effective_dt_tm = dq8
     2 input_desc = vc
     2 input_sequence = i4
     2 input_type_flg = i4
     2 input_task_assay_sk = f8
     2 input_display = vc
     2 merge_id = f8
     2 grid_name = vc
     2 grid_column_task_assay_sk = f8
     2 grid_row_task_assay_sk = f8
     2 grid_column_seq = i4
     2 grid_row_seq = i4
     2 grid_intersect_event_ref = f8
     2 input_type = i2
     2 grid_ind = i2
     2 grid_flag = i2
     2 dcp_input_ref_id = f8
     2 input_ref_seq = i4
     2 src_active_ind = c1
     2 grid_cnt = i2
     2 label_flg = i2
     2 module = vc
     2 grid_qual[*]
       3 grid_doc_sk = vc
       3 grid_input_sk = vc
       3 input_desc = vc
       3 input_sequence = i4
       3 input_type_flg = i2
       3 input_task_assay_sk = f8
       3 input_display = vc
       3 grid_name = vc
       3 col_task_assay_sk = f8
       3 col_pvc_value = vc
       3 col_seq = i4
       3 col_merge_name = vc
       3 col_dta_mnemonic = vc
       3 col_dta_description = vc
       3 row_task_assay_sk = f8
       3 row_pvc_value = vc
       3 row_seq = i4
       3 row_merge_name = vc
       3 row_dta_mnemonic = vc
       3 row_dta_description = vc
       3 grid_intersect_event_ref = f8
       3 src_active_ind = c1
 )
 RECORD templabel(
   1 section_cnt = i4
   1 section_qual[*]
     2 dcp_section_instance_id = f8
     2 input_cnt = i4
     2 input_qual[*]
       3 dcp_input_ref_id = f8
       3 input_description = vc
       3 input_sequence = i4
       3 merge_id = f8
       3 pvc_value = vc
       3 input_type = i4
       3 attdta_ind = i2
       3 mnemonic = vc
       3 task_assay_cd = f8
 )
 RECORD label(
   1 cnt = i4
   1 qual[*]
     2 dcp_section_instance_id = f8
     2 dcp_input_ref_id = f8
     2 input_description = vc
     2 input_sequence = i4
     2 input_type = i2
     2 merge_id = f8
     2 pvc_value = vc
     2 mnemonic = vc
     2 task_assay_cd = f8
 )
 RECORD data(
   1 cnt = i4
   1 qual[*]
     2 form_inst_sk = f8
     2 section_inst_sk = f8
     2 doc_component_sk = vc
     2 doc_input_sk = vc
     2 form_ref_sk = f8
     2 form_description = vc
     2 form_definition = vc
     2 form_beg_effective_dt_tm = dq8
     2 form_end_effective_dt_tm = dq8
     2 section_ref_sk = f8
     2 section_description = vc
     2 section_definition = vc
     2 section_sequence = i4
     2 section_beg_effective_dt_tm = dq8
     2 section_end_effective_dt_tm = dq8
     2 input_desc = vc
     2 input_sequence = i4
     2 input_type_flg = i4
     2 input_task_assay_sk = f8
     2 input_display = vc
     2 grid_ind = i2
     2 grid_name = vc
     2 grid_column_task_assay_sk = f8
     2 grid_row_task_assay_sk = f8
     2 grid_column_seq = i4
     2 grid_row_seq = i4
     2 grid_intersect_event_ref = f8
     2 src_active_ind = c1
 )
 DECLARE cntx = i4 WITH protect, noconstant(0)
 DECLARE cnty = i4 WITH protect, noconstant(0)
 DECLARE cntz = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE key_cnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE nlines = i4 WITH protect, noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(900000)
 DECLARE outer_keys_start = i4 WITH noconstant(0)
 DECLARE outer_keys_end = i4 WITH noconstant(0)
 DECLARE outer_keys_batch = i4 WITH constant(900000)
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr
  PLAN (dfr
   WHERE dfr.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   JOIN (dfd
   WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
    AND dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id)
   JOIN (dsr
   WHERE dsr.dcp_section_instance_id > 0
    AND dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
    AND ((dsr.active_ind=1) OR (((dfr.beg_effective_dt_tm BETWEEN dsr.beg_effective_dt_tm AND dsr
   .end_effective_dt_tm) OR (dsr.beg_effective_dt_tm BETWEEN dfr.beg_effective_dt_tm AND dfr
   .end_effective_dt_tm)) )) )
  DETAIL
   key_cnt = (key_cnt+ 1)
   IF (mod(key_cnt,100)=1)
    stat = alterlist(doc_input_ref_keys->qual,(key_cnt+ 99))
   ENDIF
   doc_input_ref_keys->qual[key_cnt].dcp_form_instance_id = dfr.dcp_form_instance_id,
   doc_input_ref_keys->qual[key_cnt].dcp_forms_def_id = dfd.dcp_forms_def_id, doc_input_ref_keys->
   qual[key_cnt].dcp_section_instance_id = dsr.dcp_section_instance_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr
  PLAN (dsr
   WHERE dsr.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND dsr.dcp_section_instance_id > 0)
   JOIN (dfd
   WHERE dfd.dcp_section_ref_id=dsr.dcp_section_ref_id)
   JOIN (dfr
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dfr.dcp_forms_ref_id=dfd.dcp_forms_ref_id
    AND ((dfr.active_ind=1) OR (((dfr.beg_effective_dt_tm BETWEEN dsr.beg_effective_dt_tm AND dsr
   .end_effective_dt_tm) OR (dsr.beg_effective_dt_tm BETWEEN dfr.beg_effective_dt_tm AND dfr
   .end_effective_dt_tm)) )) )
  HEAD REPORT
   null
  DETAIL
   key_cnt = (key_cnt+ 1)
   IF (mod(key_cnt,100)=1)
    stat = alterlist(doc_input_ref_keys->qual,(key_cnt+ 99))
   ENDIF
   doc_input_ref_keys->qual[key_cnt].dcp_form_instance_id = dfr.dcp_form_instance_id,
   doc_input_ref_keys->qual[key_cnt].dcp_forms_def_id = dfd.dcp_forms_def_id, doc_input_ref_keys->
   qual[key_cnt].dcp_section_instance_id = dsr.dcp_section_instance_id
  FOOT REPORT
   stat = alterlist(doc_input_ref_keys->qual,key_cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  dcp_forms_def_id = doc_input_ref_keys->qual[d.seq].dcp_forms_def_id, dcp_form_instance_id =
  doc_input_ref_keys->qual[d.seq].dcp_form_instance_id, dcp_section_instance_id = doc_input_ref_keys
  ->qual[d.seq].dcp_section_instance_id
  FROM (dummyt d  WITH seq = value(key_cnt))
  PLAN (d
   WHERE key_cnt > 0)
  ORDER BY dcp_forms_def_id, dcp_form_instance_id, dcp_section_instance_id
  HEAD REPORT
   pos = 0
  DETAIL
   pos = (pos+ 1), doc_input_ref_keys->qual[pos].dcp_form_instance_id = dcp_form_instance_id,
   doc_input_ref_keys->qual[pos].dcp_forms_def_id = dcp_forms_def_id,
   doc_input_ref_keys->qual[pos].dcp_section_instance_id = dcp_section_instance_id
  FOOT REPORT
   key_cnt = pos, stat = alterlist(doc_input_ref_keys->qual,pos)
  WITH nocounter
 ;end select
 SET outer_keys_start = 1
 SET outer_keys_end = minval(((outer_keys_start+ outer_keys_batch) - 1),key_cnt)
 WHILE (outer_keys_start <= outer_keys_end)
   SET stat = alterlist(temp->index_qual,0)
   SET temp->index_cnt = 0
   IF (debug="Y")
    CALL echo(concat("Looping from outer_keys_start = ",build(outer_keys_start),
      " to outer_keys_end = ",build(outer_keys_end)))
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ((outer_keys_end - outer_keys_start)+ 1)),
     dcp_section_ref dsr,
     dcp_input_ref dir
    PLAN (d)
     JOIN (dsr
     WHERE (dsr.dcp_section_instance_id=doc_input_ref_keys->qual[((d.seq+ outer_keys_start) - 1)].
     dcp_section_instance_id))
     JOIN (dir
     WHERE dir.dcp_input_ref_id > 0
      AND dir.dcp_section_instance_id=dsr.dcp_section_instance_id)
    ORDER BY dsr.dcp_section_instance_id
    HEAD REPORT
     cntx = 0, cnty = 0, cntz = 0
    HEAD dsr.dcp_section_instance_id
     label_flg = 0, section_cnt = 0
    DETAIL
     cntx = (cntx+ 1), section_cnt = (section_cnt+ 1)
     IF (dir.dcp_input_ref_id > 0)
      temp->index_cnt = (temp->index_cnt+ 1), stat = alterlist(temp->index_qual,temp->index_cnt),
      temp->index_qual[temp->index_cnt].dcp_input_ref_id = dir.dcp_input_ref_id,
      temp->index_qual[temp->index_cnt].form_inst_sk = doc_input_ref_keys->qual[((d.seq+
      outer_keys_start) - 1)].dcp_form_instance_id, temp->index_qual[temp->index_cnt].form_def_sk =
      doc_input_ref_keys->qual[((d.seq+ outer_keys_start) - 1)].dcp_forms_def_id, temp->index_qual[
      temp->index_cnt].section_inst_sk = doc_input_ref_keys->qual[((d.seq+ outer_keys_start) - 1)].
      dcp_section_instance_id,
      temp->index_qual[temp->index_cnt].input_type = dir.input_type, temp->index_qual[temp->index_cnt
      ].input_ref_seq = dir.input_ref_seq, temp->index_qual[temp->index_cnt].input_desc = dir
      .description,
      temp->index_qual[temp->index_cnt].input_sequence = dir.input_ref_seq, temp->index_qual[temp->
      index_cnt].input_type_flg = dir.input_type, temp->index_qual[temp->index_cnt].module = dir
      .module
      IF (dir.input_type != 1)
       temp->index_qual[temp->index_cnt].section_ref_sk = dsr.dcp_section_ref_id, temp->index_qual[
       temp->index_cnt].section_description = dsr.description, temp->index_qual[temp->index_cnt].
       section_definition = dsr.definition,
       temp->index_qual[temp->index_cnt].section_beg_effective_dt_tm = dsr.beg_effective_dt_tm, temp
       ->index_qual[temp->index_cnt].section_end_effective_dt_tm = dsr.end_effective_dt_tm, temp->
       index_qual[temp->index_cnt].src_active_ind = evaluate(dsr.active_ind,0,"0","1")
      ELSE
       cnty = (cnty+ 1), cntz = (cntz+ 1), label_flg = 1
      ENDIF
     ENDIF
    FOOT  dsr.dcp_section_instance_id
     IF (label_flg=1)
      FOR (sec_nbr = 1 TO section_cnt)
        temp->index_qual[((temp->index_cnt - sec_nbr)+ 1)].label_flg = 1
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp->index_cnt),
     dcp_forms_def dfd
    PLAN (d)
     JOIN (dfd
     WHERE (dfd.dcp_forms_def_id=temp->index_qual[d.seq].form_def_sk))
    DETAIL
     temp->index_qual[d.seq].section_sequence = dfd.section_seq, temp->index_qual[d.seq].form_ref_sk
      = dfd.dcp_forms_ref_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp->index_cnt),
     dcp_forms_ref dfr
    PLAN (d)
     JOIN (dfr
     WHERE (dfr.dcp_form_instance_id=temp->index_qual[d.seq].form_inst_sk))
    DETAIL
     temp->index_qual[d.seq].form_description = dfr.description, temp->index_qual[d.seq].
     form_definition = dfr.definition, temp->index_qual[d.seq].form_beg_effective_dt_tm = dfr
     .beg_effective_dt_tm,
     temp->index_qual[d.seq].form_end_effective_dt_tm = dfr.end_effective_dt_tm, temp->index_qual[d
     .seq].src_active_ind = evaluate(dfr.active_ind,0,"0",temp->index_qual[d.seq].src_active_ind)
    WITH nocounter
   ;end select
   IF ((temp->index_cnt=0))
    IF (debug="Y")
     CALL echo(
      "NO matching record found from DCP_Forms_Ref, DCP_Forms_Def, DCP_Section_Ref and DCP_Input_Ref tables"
      )
    ENDIF
    GO TO endprogram
   ELSE
    IF (debug="Y")
     CALL echo(concat("Found ",build(temp->index_cnt),
       " records from DCP_Forms_Ref, DCP_Forms_Def, DCP_Section_Ref and DCP_Input_Ref tables",
       " matching specified time range "))
    ENDIF
   ENDIF
   SET cnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(temp->index_cnt)),
     name_value_prefs nvp,
     discrete_task_assay dta
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (nvp
     WHERE nvp.parent_entity_name="DCP_INPUT_REF"
      AND (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.pvc_name="discrete_task_assay"
      AND  NOT ((temp->index_qual[d1.seq].input_type IN (1, 19, 17, 5, 15,
     14, 21))))
     JOIN (dta
     WHERE dta.task_assay_cd=nvp.merge_id)
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_flag = 1, temp->index_qual[d1.seq].grid_ind = 0
     IF ((((temp->index_qual[d1.seq].input_type IN (2, 11))) OR (dta.event_cd=0)) )
      temp->index_qual[d1.seq].doc_component_sk = concat("d",trim(cnvtstring(temp->index_qual[d1.seq]
         .dcp_input_ref_id)))
     ELSE
      temp->index_qual[d1.seq].doc_component_sk = trim(cnvtstring(dta.event_cd))
     ENDIF
     temp->index_qual[d1.seq].doc_input_sk = concat(trim(cnvtstring(temp->index_qual[d1.seq].
        form_inst_sk,16)),"~",trim(cnvtstring(temp->index_qual[d1.seq].section_inst_sk,16)),"~",trim(
       temp->index_qual[d1.seq].doc_component_sk)), temp->index_qual[d1.seq].merge_id = nvp.merge_id,
     temp->index_qual[d1.seq].input_display = dta.mnemonic,
     temp->index_qual[d1.seq].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1.seq].
     src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(temp->index_qual[d1.seq].src_active_ind,
       "0","0","1"))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cnt)," records for component"))
   ENDIF
   SET cntx = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(temp->index_cnt)),
     name_value_prefs nvp,
     discrete_task_assay dta
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_flag=0)
      AND (temp->index_qual[d1.seq].input_type=2)
      AND (temp->index_qual[d1.seq].module="PVTRACKFORMS"))
     JOIN (nvp
     WHERE (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.parent_entity_name="DCP_INPUT_REF"
      AND nvp.merge_id > 0)
     JOIN (dta
     WHERE dta.task_assay_cd=outerjoin(nvp.merge_id)
      AND dta.event_cd > 0)
    HEAD d1.seq
     cntx = (cntx+ 1), cnt = 0, temp->index_qual[d1.seq].grid_ind = 1
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_cnt = cnt, stat = alterlist(temp->index_qual[d1
      .seq].grid_qual,temp->index_qual[d1.seq].grid_cnt),
     temp->index_qual[d1.seq].grid_qual[cnt].grid_doc_sk = build(cnvtstring(temp->index_qual[d1.seq].
       dcp_input_ref_id,16),"~",cnvtstring(dta.event_cd,16)), temp->index_qual[d1.seq].grid_qual[cnt]
     .grid_input_sk = build(cnvtstring(temp->index_qual[d1.seq].form_inst_sk,16),"~",cnvtstring(temp
       ->index_qual[d1.seq].section_inst_sk,16),"~",trim(temp->index_qual[d1.seq].grid_qual[cnt].
       grid_doc_sk)), temp->index_qual[d1.seq].grid_qual[cnt].grid_name = temp->index_qual[d1.seq].
     input_desc,
     temp->index_qual[d1.seq].grid_qual[cnt].input_desc = temp->index_qual[d1.seq].input_desc, temp->
     index_qual[d1.seq].grid_qual[cnt].input_sequence = temp->index_qual[d1.seq].input_ref_seq, temp
     ->index_qual[d1.seq].grid_qual[cnt].input_type_flg = temp->index_qual[d1.seq].input_type,
     temp->index_qual[d1.seq].grid_qual[cnt].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1
     .seq].grid_qual[cnt].input_display = dta.mnemonic, temp->index_qual[d1.seq].grid_qual[cnt].
     col_task_assay_sk = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].col_pvc_value = nvp.pvc_value, temp->index_qual[d1.seq].
     grid_qual[cnt].col_seq = nvp.sequence, temp->index_qual[d1.seq].grid_qual[cnt].col_merge_name =
     nvp.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].col_dta_mnemonic = dta.mnemonic, temp->index_qual[d1.seq
     ].grid_qual[cnt].col_dta_description = dta.description, temp->index_qual[d1.seq].grid_qual[cnt].
     grid_intersect_event_ref = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(
       temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind,"0","0","1"))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cntx)," records for Tracking Controls"))
   ENDIF
   SET cntx = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(temp->index_cnt)),
     name_value_prefs nvp,
     name_value_prefs nvp2,
     discrete_task_assay dta
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_flag=0)
      AND (temp->index_qual[d1.seq].input_type=14))
     JOIN (nvp
     WHERE nvp.parent_entity_name="DCP_INPUT_REF"
      AND (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.pvc_name="discrete_task_assay")
     JOIN (dta
     WHERE dta.task_assay_cd=outerjoin(nvp.merge_id)
      AND dta.event_cd > 0)
     JOIN (nvp2
     WHERE (nvp2.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp2.parent_entity_name="DCP_INPUT_REF"
      AND nvp2.pvc_name="grid_event_cd")
    HEAD d1.seq
     cntx = (cntx+ 1), cnt = 0, temp->index_qual[d1.seq].grid_ind = 1
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_cnt = cnt, stat = alterlist(temp->index_qual[d1
      .seq].grid_qual,temp->index_qual[d1.seq].grid_cnt),
     temp->index_qual[d1.seq].grid_qual[cnt].grid_doc_sk = build(cnvtstring(temp->index_qual[d1.seq].
       dcp_input_ref_id,16),"~",cnvtstring(dta.event_cd,16)), temp->index_qual[d1.seq].grid_qual[cnt]
     .grid_input_sk = build(cnvtstring(temp->index_qual[d1.seq].form_inst_sk,16),"~",cnvtstring(temp
       ->index_qual[d1.seq].section_inst_sk,16),"~",trim(temp->index_qual[d1.seq].grid_qual[cnt].
       grid_doc_sk)), temp->index_qual[d1.seq].grid_qual[cnt].grid_name = uar_get_code_display(nvp2
      .merge_id),
     temp->index_qual[d1.seq].grid_qual[cnt].input_desc = temp->index_qual[d1.seq].input_desc, temp->
     index_qual[d1.seq].grid_qual[cnt].input_sequence = temp->index_qual[d1.seq].input_ref_seq, temp
     ->index_qual[d1.seq].grid_qual[cnt].input_type_flg = temp->index_qual[d1.seq].input_type,
     temp->index_qual[d1.seq].grid_qual[cnt].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1
     .seq].grid_qual[cnt].input_display = dta.mnemonic, temp->index_qual[d1.seq].grid_qual[cnt].
     col_task_assay_sk = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].col_pvc_value = nvp.pvc_value, temp->index_qual[d1.seq].
     grid_qual[cnt].col_seq = nvp.sequence, temp->index_qual[d1.seq].grid_qual[cnt].col_merge_name =
     nvp.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].col_dta_mnemonic = dta.mnemonic, temp->index_qual[d1.seq
     ].grid_qual[cnt].col_dta_description = dta.description, temp->index_qual[d1.seq].grid_qual[cnt].
     grid_intersect_event_ref = nvp2.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(
       nvp2.active_ind,0,"0",evaluate(temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind,"0","0",
        "1")))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cntx)," records for discrete grid"))
   ENDIF
   SET cntx = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(temp->index_cnt)),
     name_value_prefs nvp,
     name_value_prefs nvp2,
     name_value_prefs nvp3,
     discrete_task_assay dta
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_flag=0)
      AND (temp->index_qual[d1.seq].input_type=17))
     JOIN (nvp
     WHERE nvp.parent_entity_name="DCP_INPUT_REF"
      AND (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.pvc_name="discrete_task_assay")
     JOIN (dta
     WHERE dta.task_assay_cd=nvp.merge_id)
     JOIN (nvp2
     WHERE (nvp2.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp2.parent_entity_name="DCP_INPUT_REF"
      AND nvp2.pvc_name="grid_event_cd")
     JOIN (nvp3
     WHERE (nvp3.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp3.parent_entity_name="DCP_INPUT_REF"
      AND nvp3.pvc_name="row_event_cd")
    HEAD d1.seq
     cntx = (cntx+ 1), cnt = 0, temp->index_qual[d1.seq].grid_ind = 1
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_cnt = cnt, stat = alterlist(temp->index_qual[d1
      .seq].grid_qual,temp->index_qual[d1.seq].grid_cnt),
     temp->index_qual[d1.seq].grid_qual[cnt].grid_doc_sk = build(cnvtstring(nvp2.merge_id,16),"~",
      cnvtstring(nvp3.merge_id,16),"~",cnvtstring(nvp.merge_id,16)), temp->index_qual[d1.seq].
     grid_qual[cnt].grid_input_sk = build(cnvtstring(temp->index_qual[d1.seq].form_inst_sk,16),"~",
      cnvtstring(temp->index_qual[d1.seq].section_inst_sk,16),"~",trim(temp->index_qual[d1.seq].
       grid_qual[cnt].grid_doc_sk)), temp->index_qual[d1.seq].grid_qual[cnt].grid_name =
     uar_get_code_display(nvp2.merge_id),
     temp->index_qual[d1.seq].grid_qual[cnt].input_desc = temp->index_qual[d1.seq].input_desc, temp->
     index_qual[d1.seq].grid_qual[cnt].input_sequence = temp->index_qual[d1.seq].input_ref_seq, temp
     ->index_qual[d1.seq].grid_qual[cnt].input_type_flg = temp->index_qual[d1.seq].input_type,
     temp->index_qual[d1.seq].grid_qual[cnt].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1
     .seq].grid_qual[cnt].input_display = dta.mnemonic, temp->index_qual[d1.seq].grid_qual[cnt].
     col_task_assay_sk = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].col_pvc_value = nvp.pvc_value, temp->index_qual[d1.seq].
     grid_qual[cnt].col_seq = nvp.sequence, temp->index_qual[d1.seq].grid_qual[cnt].col_merge_name =
     nvp.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].col_dta_mnemonic = dta.mnemonic, temp->index_qual[d1.seq
     ].grid_qual[cnt].col_dta_description = dta.description, temp->index_qual[d1.seq].grid_qual[cnt].
     grid_intersect_event_ref = nvp2.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(
       nvp2.active_ind,0,"0",evaluate(temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind,"0","0",
        "1")))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cntx)," records for power grid"))
   ENDIF
   SET cntx = 0
   SELECT INTO "nl:"
    temp_sk = temp->index_qual[d1.seq].section_inst_sk
    FROM name_value_prefs nvp,
     name_value_prefs nvp2,
     name_value_prefs nvp3,
     discrete_task_assay dta,
     discrete_task_assay dta2,
     (dummyt d1  WITH seq = value(temp->index_cnt))
    PLAN (d1
     WHERE d1.seq > 0
      AND (temp->index_qual[d1.seq].grid_flag=0)
      AND (temp->index_qual[d1.seq].input_type=19))
     JOIN (nvp
     WHERE nvp.pvc_name="discrete_task_assay2"
      AND (nvp.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp.parent_entity_name="DCP_INPUT_REF")
     JOIN (dta
     WHERE dta.task_assay_cd=nvp.merge_id)
     JOIN (nvp2
     WHERE (nvp2.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp2.parent_entity_name="DCP_INPUT_REF"
      AND nvp2.pvc_name="discrete_task_assay"
      AND nvp2.merge_id > 0)
     JOIN (dta2
     WHERE dta2.task_assay_cd=nvp2.merge_id)
     JOIN (nvp3
     WHERE (nvp3.parent_entity_id=temp->index_qual[d1.seq].dcp_input_ref_id)
      AND nvp3.parent_entity_name="DCP_INPUT_REF"
      AND nvp3.pvc_name="grid_event_cd")
    HEAD d1.seq
     cntx = (cntx+ 1), cnt = 0, temp->index_qual[d1.seq].grid_ind = 1,
     temp->index_qual[d1.seq].doc_component_sk = concat(trim(cnvtstring(temp->index_qual[d1.seq].
        input_ref_seq)),"~",trim(cnvtstring(nvp.sequence)),"~",trim(cnvtstring(nvp2.sequence)))
    DETAIL
     cnt = (cnt+ 1), temp->index_qual[d1.seq].grid_cnt = cnt, stat = alterlist(temp->index_qual[d1
      .seq].grid_qual,temp->index_qual[d1.seq].grid_cnt),
     temp->index_qual[d1.seq].grid_qual[cnt].grid_doc_sk = concat(trim(cnvtstring(nvp3.merge_id)),"~",
      trim(cnvtstring(dta.event_cd)),"~",trim(cnvtstring(nvp2.merge_id))), temp->index_qual[d1.seq].
     grid_qual[cnt].grid_input_sk = concat(trim(cnvtstring(temp->index_qual[d1.seq].form_inst_sk,16)),
      "~",trim(cnvtstring(temp->index_qual[d1.seq].section_inst_sk,16)),"~",trim(temp->index_qual[d1
       .seq].grid_qual[cnt].grid_doc_sk)), temp->index_qual[d1.seq].grid_qual[cnt].grid_name =
     uar_get_code_display(nvp3.merge_id),
     temp->index_qual[d1.seq].grid_qual[cnt].input_desc = temp->index_qual[d1.seq].input_desc, temp->
     index_qual[d1.seq].grid_qual[cnt].input_sequence = temp->index_qual[d1.seq].input_ref_seq, temp
     ->index_qual[d1.seq].grid_qual[cnt].input_type_flg = temp->index_qual[d1.seq].input_type,
     temp->index_qual[d1.seq].grid_qual[cnt].input_task_assay_sk = nvp.merge_id, temp->index_qual[d1
     .seq].grid_qual[cnt].input_display = dta.mnemonic, temp->index_qual[d1.seq].grid_qual[cnt].
     col_task_assay_sk = nvp.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].col_pvc_value = nvp.pvc_value, temp->index_qual[d1.seq].
     grid_qual[cnt].col_seq = nvp.sequence, temp->index_qual[d1.seq].grid_qual[cnt].col_merge_name =
     nvp.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].col_dta_mnemonic = dta.mnemonic, temp->index_qual[d1.seq
     ].grid_qual[cnt].col_dta_description = dta.description, temp->index_qual[d1.seq].grid_qual[cnt].
     row_task_assay_sk = nvp2.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].row_pvc_value = nvp2.pvc_value, temp->index_qual[d1.seq]
     .grid_qual[cnt].row_seq = nvp2.sequence, temp->index_qual[d1.seq].grid_qual[cnt].row_merge_name
      = nvp2.merge_name,
     temp->index_qual[d1.seq].grid_qual[cnt].row_dta_mnemonic = dta2.mnemonic, temp->index_qual[d1
     .seq].grid_qual[cnt].row_dta_description = dta2.description, temp->index_qual[d1.seq].grid_qual[
     cnt].grid_intersect_event_ref = nvp3.merge_id,
     temp->index_qual[d1.seq].grid_qual[cnt].src_active_ind = evaluate(nvp.active_ind,0,"0",evaluate(
       nvp2.active_ind,0,"0",evaluate(nvp3.active_ind,0,"0",evaluate(temp->index_qual[d1.seq].
         grid_qual[cnt].src_active_ind,"0","0","1"))))
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cntx)," records for ultra grid"))
   ENDIF
   SET cnt = 0
   SELECT INTO "nl:"
    FROM name_value_prefs nvp,
     name_value_prefs nvp2,
     discrete_task_assay dta,
     (dummyt d2  WITH seq = value(temp->index_cnt))
    PLAN (d2
     WHERE d2.seq > 0
      AND (temp->index_qual[d2.seq].grid_ind=0)
      AND (temp->index_qual[d2.seq].label_flg=1))
     JOIN (nvp
     WHERE cnvtlower(nvp.pvc_name) IN ("question_role", "reference_role")
      AND (nvp.parent_entity_id=temp->index_qual[d2.seq].dcp_input_ref_id)
      AND nvp.parent_entity_name="DCP_INPUT_REF")
     JOIN (nvp2
     WHERE cnvtlower(nvp2.pvc_name)="caption"
      AND (nvp2.parent_entity_id=temp->index_qual[d2.seq].dcp_input_ref_id)
      AND nvp2.parent_entity_name="DCP_INPUT_REF")
     JOIN (dta
     WHERE dta.mnemonic=nvp.pvc_value)
    DETAIL
     cnt = (cnt+ 1), label->cnt = cnt, stat = alterlist(label->qual,label->cnt),
     label->qual[cnt].dcp_section_instance_id = temp->index_qual[d2.seq].section_inst_sk, label->
     qual[cnt].dcp_input_ref_id = temp->index_qual[d2.seq].dcp_input_ref_id, label->qual[cnt].
     input_description = temp->index_qual[d2.seq].input_desc,
     label->qual[cnt].input_sequence = temp->index_qual[d2.seq].input_sequence, label->qual[cnt].
     input_type = temp->index_qual[d2.seq].input_type, label->qual[cnt].merge_id = nvp2.merge_id,
     label->qual[cnt].pvc_value = nvp.pvc_value, label->qual[cnt].mnemonic = dta.mnemonic, label->
     qual[cnt].task_assay_cd = dta.task_assay_cd
    WITH nocounter
   ;end select
   IF (debug="Y")
    CALL echo(concat("Found ",build(cnt)," records for label within DTA associated"))
   ENDIF
   FREE RECORD merge_id_disp
   RECORD merge_id_disp(
     1 qual[*]
       2 merge_id = f8
       2 disp = vc
   )
   FOR (i = 1 TO temp->index_cnt)
     IF ((temp->index_qual[i].grid_ind=0))
      SET pop_idx = locateval(num,1,size(merge_id_disp->qual,5),temp->index_qual[i].merge_id,
       merge_id_disp->qual[num].merge_id)
      IF (pop_idx > 0)
       SET temp->index_qual[i].input_display = merge_id_disp->qual[pop_idx].disp
      ELSE
       FOR (j = 1 TO label->cnt)
         IF ((temp->index_qual[i].merge_id=label->qual[j].task_assay_cd))
          SET temp->index_qual[i].input_display = label->qual[j].pvc_value
          SET j = (label->cnt+ 1)
          SET md_cnt = (size(merge_id_disp->qual,5)+ 1)
          SET stat = alterlist(merge_id_disp->qual,md_cnt)
          SET merge_id_disp->qual[md_cnt].merge_id = temp->index_qual[i].merge_id
          SET merge_id_disp->qual[md_cnt].disp = temp->index_qual[i].input_display
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(merge_id_disp->qual,0)
   SET keys_start = 1
   SET keys_end = minval(((keys_start+ keys_batch) - 1),temp->index_cnt)
   WHILE (keys_start <= keys_end)
     IF (debug="Y")
      CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(
         keys_end)))
     ENDIF
     SET data->cnt = 0
     FOR (i = keys_start TO keys_end)
       IF ((temp->index_qual[i].input_type_flg != 1))
        IF ((temp->index_qual[i].grid_cnt=0))
         SET data->cnt = (data->cnt+ 1)
         SET stat = alterlist(data->qual,data->cnt)
         SET data->qual[data->cnt].form_inst_sk = temp->index_qual[i].form_inst_sk
         SET data->qual[data->cnt].section_inst_sk = temp->index_qual[i].section_inst_sk
         SET data->qual[data->cnt].doc_component_sk = temp->index_qual[i].doc_component_sk
         SET data->qual[data->cnt].doc_input_sk = temp->index_qual[i].doc_input_sk
         SET data->qual[data->cnt].form_ref_sk = temp->index_qual[i].form_ref_sk
         SET data->qual[data->cnt].form_description = temp->index_qual[i].form_description
         SET data->qual[data->cnt].form_definition = temp->index_qual[i].form_definition
         SET data->qual[data->cnt].form_beg_effective_dt_tm = temp->index_qual[i].
         form_beg_effective_dt_tm
         SET data->qual[data->cnt].form_end_effective_dt_tm = temp->index_qual[i].
         form_end_effective_dt_tm
         SET data->qual[data->cnt].section_ref_sk = temp->index_qual[i].section_ref_sk
         SET data->qual[data->cnt].section_description = temp->index_qual[i].section_description
         SET data->qual[data->cnt].section_definition = temp->index_qual[i].section_definition
         SET data->qual[data->cnt].section_sequence = temp->index_qual[i].section_sequence
         SET data->qual[data->cnt].section_beg_effective_dt_tm = temp->index_qual[i].
         section_beg_effective_dt_tm
         SET data->qual[data->cnt].section_end_effective_dt_tm = temp->index_qual[i].
         section_end_effective_dt_tm
         SET data->qual[data->cnt].input_desc = temp->index_qual[i].input_desc
         SET data->qual[data->cnt].input_sequence = temp->index_qual[i].input_sequence
         SET data->qual[data->cnt].input_type_flg = temp->index_qual[i].input_type_flg
         SET data->qual[data->cnt].input_task_assay_sk = temp->index_qual[i].input_task_assay_sk
         SET data->qual[data->cnt].input_display = temp->index_qual[i].input_display
         SET data->qual[data->cnt].grid_ind = temp->index_qual[i].grid_ind
         SET data->qual[data->cnt].grid_name = temp->index_qual[i].grid_name
         SET data->qual[data->cnt].grid_column_task_assay_sk = temp->index_qual[i].
         grid_column_task_assay_sk
         SET data->qual[data->cnt].grid_row_task_assay_sk = temp->index_qual[i].
         grid_row_task_assay_sk
         SET data->qual[data->cnt].grid_column_seq = temp->index_qual[i].grid_column_seq
         SET data->qual[data->cnt].grid_intersect_event_ref = temp->index_qual[i].
         grid_intersect_event_ref
         SET data->qual[data->cnt].src_active_ind = temp->index_qual[i].src_active_ind
        ELSE
         FOR (j = 1 TO temp->index_qual[i].grid_cnt)
           SET data->cnt = (data->cnt+ 1)
           SET stat = alterlist(data->qual,data->cnt)
           SET data->qual[data->cnt].form_inst_sk = temp->index_qual[i].form_inst_sk
           SET data->qual[data->cnt].section_inst_sk = temp->index_qual[i].section_inst_sk
           SET data->qual[data->cnt].doc_component_sk = temp->index_qual[i].grid_qual[j].grid_doc_sk
           SET data->qual[data->cnt].doc_input_sk = temp->index_qual[i].grid_qual[j].grid_input_sk
           SET data->qual[data->cnt].form_ref_sk = temp->index_qual[i].form_ref_sk
           SET data->qual[data->cnt].form_description = temp->index_qual[i].form_description
           SET data->qual[data->cnt].form_definition = temp->index_qual[i].form_definition
           SET data->qual[data->cnt].form_beg_effective_dt_tm = temp->index_qual[i].
           form_beg_effective_dt_tm
           SET data->qual[data->cnt].form_end_effective_dt_tm = temp->index_qual[i].
           form_end_effective_dt_tm
           SET data->qual[data->cnt].section_ref_sk = temp->index_qual[i].section_ref_sk
           SET data->qual[data->cnt].section_description = temp->index_qual[i].section_description
           SET data->qual[data->cnt].section_definition = temp->index_qual[i].section_definition
           SET data->qual[data->cnt].section_sequence = temp->index_qual[i].section_sequence
           SET data->qual[data->cnt].section_beg_effective_dt_tm = temp->index_qual[i].
           section_beg_effective_dt_tm
           SET data->qual[data->cnt].section_end_effective_dt_tm = temp->index_qual[i].
           section_end_effective_dt_tm
           SET data->qual[data->cnt].input_desc = temp->index_qual[i].grid_qual[j].input_desc
           SET data->qual[data->cnt].input_sequence = temp->index_qual[i].grid_qual[j].input_sequence
           SET data->qual[data->cnt].input_type_flg = temp->index_qual[i].grid_qual[j].input_type_flg
           SET data->qual[data->cnt].input_task_assay_sk = temp->index_qual[i].grid_qual[j].
           input_task_assay_sk
           SET data->qual[data->cnt].input_display = temp->index_qual[i].grid_qual[j].input_display
           SET data->qual[data->cnt].grid_ind = temp->index_qual[i].grid_ind
           SET data->qual[data->cnt].grid_name = temp->index_qual[i].grid_qual[j].grid_name
           SET data->qual[data->cnt].grid_column_task_assay_sk = temp->index_qual[i].grid_qual[j].
           col_task_assay_sk
           SET data->qual[data->cnt].grid_row_task_assay_sk = temp->index_qual[i].grid_qual[j].
           row_task_assay_sk
           SET data->qual[data->cnt].grid_column_seq = temp->index_qual[i].grid_qual[j].col_seq
           SET data->qual[data->cnt].grid_row_seq = temp->index_qual[i].grid_qual[j].row_seq
           SET data->qual[data->cnt].grid_intersect_event_ref = temp->index_qual[i].grid_qual[j].
           grid_intersect_event_ref
           SET data->qual[data->cnt].src_active_ind = temp->index_qual[i].grid_qual[j].src_active_ind
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(data->cnt)),
       code_value_event_r cver
      PLAN (d1
       WHERE d1.seq > 0
        AND (data->qual[d1.seq].grid_ind=1))
       JOIN (cver
       WHERE (cver.parent_cd=data->qual[d1.seq].input_task_assay_sk)
        AND (cver.flex1_cd=data->qual[d1.seq].grid_row_task_assay_sk))
      DETAIL
       data->qual[d1.seq].grid_intersect_event_ref = cver.event_cd
      WITH nocounter
     ;end select
     SELECT INTO value(docinput_extractfile)
      doc_sk = substring(1,500,data->qual[d.seq].doc_input_sk)
      FROM (dummyt d  WITH seq = value(data->cnt))
      PLAN (d
       WHERE (data->qual[d.seq].doc_input_sk != null))
      ORDER BY doc_sk
      HEAD doc_sk
       col 0, health_system_source_id, v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].form_inst_sk,16),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].section_inst_sk,16),3)),
       v_bar,
       CALL print(trim(replace(data->qual[d.seq].doc_component_sk,str_find,str_replace,3),3)), v_bar,
       CALL print(trim(replace(data->qual[d.seq].doc_input_sk,str_find,str_replace,3),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].form_ref_sk,16),3)),
       v_bar,
       CALL print(trim(replace(data->qual[d.seq].form_description,str_find,str_replace,3),3)), v_bar,
       CALL print(trim(replace(data->qual[d.seq].form_definition,str_find,str_replace,3),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].section_ref_sk,16),3)),
       v_bar,
       CALL print(trim(replace(data->qual[d.seq].section_description,str_find,str_replace,3),3)),
       v_bar,
       CALL print(trim(replace(data->qual[d.seq].section_definition,str_find,str_replace,3),3)),
       v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].section_sequence),3)),
       v_bar,
       CALL print(trim(replace(data->qual[d.seq].input_desc,str_find,str_replace,3),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].input_sequence),3)), v_bar,
       CALL print(trim(evaluate(data->qual[d.seq].input_type_flg,0,blank_field,cnvtstring(data->qual[
          d.seq].input_type_flg)),3)),
       v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].input_task_assay_sk,16),3)), v_bar,
       CALL print(trim(replace(data->qual[d.seq].input_display,str_find,str_replace,3),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_ind),3)),
       v_bar,
       CALL print(trim(replace(data->qual[d.seq].grid_name,str_find,str_replace,3),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_column_task_assay_sk,16),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_row_task_assay_sk,16),3)),
       v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_column_seq),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_row_seq),3)), v_bar,
       CALL print(trim(cnvtstring(data->qual[d.seq].grid_intersect_event_ref,16),3)),
       v_bar, "3", v_bar,
       extract_dt_tm_fmt, v_bar,
       CALL print(trim(datetimezoneformat(evaluate(curutc,1,data->qual[d.seq].
          form_beg_effective_dt_tm,0,cnvtdatetimeutc(data->qual[d.seq].form_beg_effective_dt_tm,3)),
         utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
       v_bar,
       CALL print(build(curtimezonesys)), v_bar,
       CALL print(evaluate(datetimezoneformat(data->qual[d.seq].form_beg_effective_dt_tm,cnvtint(
          curtimezonesys),"HHmmsscc"),"00000000","0","        ","0",
        "1")), v_bar,
       CALL print(trim(datetimezoneformat(evaluate(curutc,1,data->qual[d.seq].
          form_end_effective_dt_tm,0,cnvtdatetimeutc(data->qual[d.seq].form_end_effective_dt_tm,3)),
         utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
       v_bar,
       CALL print(build(curtimezonesys)), v_bar,
       CALL print(evaluate(datetimezoneformat(data->qual[d.seq].form_end_effective_dt_tm,cnvtint(
          curtimezonesys),"HHmmsscc"),"00000000","0","        ","0",
        "1")), v_bar,
       CALL print(trim(datetimezoneformat(evaluate(curutc,1,data->qual[d.seq].
          section_beg_effective_dt_tm,0,cnvtdatetimeutc(data->qual[d.seq].section_beg_effective_dt_tm,
           3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
       v_bar,
       CALL print(build(curtimezonesys)), v_bar,
       CALL print(evaluate(datetimezoneformat(data->qual[d.seq].section_beg_effective_dt_tm,cnvtint(
          curtimezonesys),"HHmmsscc"),"00000000","0","        ","0",
        "1")), v_bar,
       CALL print(trim(datetimezoneformat(evaluate(curutc,1,data->qual[d.seq].
          section_end_effective_dt_tm,0,cnvtdatetimeutc(data->qual[d.seq].section_end_effective_dt_tm,
           3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
       v_bar,
       CALL print(build(curtimezonesys)), v_bar,
       CALL print(evaluate(datetimezoneformat(data->qual[d.seq].section_end_effective_dt_tm,cnvtint(
          curtimezonesys),"HHmmsscc"),"00000000","0","        ","0",
        "1")), v_bar,
       CALL print(trim(data->qual[d.seq].src_active_ind,3)),
       v_bar, row + 1, nlines = (nlines+ 1)
      WITH noheading, nocounter, format = lfstream,
       maxcol = 1999, maxrow = 1, append
     ;end select
     SET keys_start = (keys_end+ 1)
     SET keys_end = minval(((keys_start+ keys_batch) - 1),temp->index_cnt)
   ENDWHILE
   SET stat = alterlist(temp->index_qual,0)
   SET outer_keys_start = (outer_keys_end+ 1)
   SET outer_keys_end = minval(((outer_keys_start+ outer_keys_batch) - 1),key_cnt)
 ENDWHILE
#endprogram
 IF (nlines=0)
  SELECT INTO value(docinput_extractfile)
   FROM dummyt
   WHERE nlines > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD temp
 FREE RECORD templabel
 FREE RECORD label
 FREE RECORD data
 CALL edwupdatescriptstatus("DOCINPUT",nlines,"21","21")
 CALL echo(build("DOCINPUT Count = ",nlines))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "022 08/31/23 ap086433"
END GO
