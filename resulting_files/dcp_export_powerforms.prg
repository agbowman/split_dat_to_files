CREATE PROGRAM dcp_export_powerforms
 RECORD internal(
   1 dcp_forms_ref_id = f8
   1 form_description = vc
   1 done_charting_ind = i2
   1 form_definition = vc
   1 form_width = i4
   1 form_height = i4
   1 enforce_required_ind = i2
   1 event_set_name = vc
   1 form_event_cd = f8
   1 form_event_cd_disp = vc
   1 form_flags = i4
   1 section_cnt = i2
   1 section_qual[*]
     2 dcp_section_ref_id = f8
     2 section_seq = i4
     2 section_flags = i4
     2 section_description = vc
     2 section_definition = vc
     2 section_width = i4
     2 section_height = i4
     2 input_cnt = i2
     2 input_qual[*]
       3 dcp_input_ref_id = f8
       3 input_description = vc
       3 input_ref_seq = i4
       3 input_type = i4
       3 module = vc
       3 pvc_name = vc
       3 pvc_value = vc
       3 merge_name = vc
       3 merge_id = f8
       3 sequence = i4
       3 dta_mnemonic = vc
       3 dta_description = vc
       3 dta_act_display = vc
       3 event_cd_display = vc
       3 cki = vc
       3 code_value_display = vc
       3 code_set = i4
       3 cond_sect_desc = vc
       3 cond_sect_defn = vc
       3 nomen_cnt = i2
       3 nomen_qual[*]
         4 source_string = vc
   1 line_qual[*]
     2 line = vc
     2 size = i4
   1 all_nomen_cnt = i4
   1 nomenclature_qual[*]
     2 nomenclature_id = f8
   1 all_dta_cnt = i4
   1 dta_qual[*]
     2 task_assay_cd = f8
 )
 RECORD blob(
   1 qual[*]
     2 line = vc
 )
 EXECUTE cclseclogin
 SET module_schema = 0
 SET section_cnt = 0
 SET input_cnt = 0
 SET line_cnt = 0
 SET newline_cnt = 0
 SET junk_ptr = 0
 SET nomen_cnt = 0
 SET internal->all_dta_cnt = 0
 SET internal->all_nomen_cnt = 0
 SET equation_ind = 0
 SET dcp_forms_ref_id = fillstring(50," ")
 SET tmp_form_description = fillstring(200," ")
 SET tmp_fomr_definition = fillstring(200," ")
 SET form_description = fillstring(200," ")
 SET done_charting_ind = fillstring(50," ")
 SET form_definition = fillstring(200," ")
 SET form_width = fillstring(50," ")
 SET form_height = fillstring(50," ")
 SET enforce_required_ind = fillstring(50," ")
 SET event_set_name = fillstring(100," ")
 SET form_event_cd = fillstring(50," ")
 SET form_flags = fillstring(50," ")
 SET dcp_section_ref_id = fillstring(50," ")
 SET section_seq = fillstring(50," ")
 SET section_flags = fillstring(50," ")
 SET tmp_section_description = fillstring(200," ")
 SET section_description = fillstring(200," ")
 SET tmp_section_definition = fillstring(200," ")
 SET section_definition = fillstring(200," ")
 SET section_width = fillstring(50," ")
 SET section_height = fillstring(50," ")
 SET dcp_input_ref_id = fillstring(50," ")
 SET tmp_dcp_input_ref_id = fillstring(50," ")
 SET input_description = fillstring(200," ")
 SET tmp_input_description = fillstring(200," ")
 SET input_ref_seq = fillstring(50," ")
 SET input_type = fillstring(50," ")
 SET module = fillstring(50," ")
 SET pvc_name = fillstring(32," ")
 SET pvc_value = fillstring(256," ")
 SET tmp_pvc_value = fillstring(256," ")
 SET merge_name = fillstring(100," ")
 SET merge_id = fillstring(50," ")
 SET sequence = fillstring(50," ")
 SET dta_mnemonic = fillstring(60," ")
 SET tmp_dta_mnemonic = fillstring(60," ")
 SET tmp_dta_description = fillstring(110," ")
 SET dta_description = fillstring(110," ")
 SET tmp_dta_act_type_display = fillstring(60," ")
 SET dta_act_type_display = fillstring(60,"")
 SET tmp_dta_description = fillstring(100," ")
 SET event_cd_display = fillstring(40," ")
 SET tmp_event_cd_display = fillstring(40," ")
 SET code_value_display = fillstring(40," ")
 SET tmp_code_value_display = fillstring(40," ")
 SET source_string = fillstring(256," ")
 SET tmp_source_string = fillstring(256," ")
 SET cond_sect_desc = fillstring(256," ")
 SET cond_sect_defn = fillstring(256," ")
 SET tmp_cond_sect_desc = fillstring(256," ")
 SET tmp_cond_sect_defn = fillstring(256," ")
 SET code_set1 = fillstring(50," ")
 SET form_event_cd_disp = fillstring(256," ")
 SET line = fillstring(700," ")
 SET junk_ptr = 0
 SELECT INTO "nl:"
  utc.table_name, utc.column_name
  FROM user_tab_columns utc
  WHERE utc.table_name="DCP_INPUT_REF"
   AND utc.column_name="MODULE"
  DETAIL
   module_schema = 1
  WITH nocounter
 ;end select
 IF (module_schema=0)
  GO TO no_module
 ENDIF
 CALL echo("domain contains module field on the dcp_input_ref table")
#module
 SET version_field = 0
 SELECT INTO "nl:"
  utc.table_name, utc.column_name
  FROM user_tab_columns utc
  WHERE utc.table_name="DCP_FORMS_REF"
   AND utc.column_name="DCP_FORM_INSTANCE_ID"
  DETAIL
   version_field = 1
  WITH nocounter
 ;end select
 SET form_where_clause = fillstring(1000," ")
 SET form2_where_clause = fillstring(1000," ")
 SET section_where_clause = fillstring(1000," ")
 SET input_where_clause = fillstring(1000," ")
 SET end_dt_tm = cnvtdatetime("31-Dec-2100")
 SET form_ref_id =  $1
 IF (version_field=1)
  SET form_where_clause = concat(trim(form_where_clause),"dfr.dcp_forms_ref_id = ")
  SET form_where_clause = concat(trim(form_where_clause),cnvtstring(form_ref_id,20,2))
  SET form_where_clause = concat(trim(form_where_clause)," and dfr.active_ind = ")
  SET form_where_clause = concat(trim(form_where_clause),cnvtstring(1))
  SET form_where_clause = concat(trim(form_where_clause)," and dfr.dcp_form_instance_id > ")
  SET form_where_clause = concat(trim(form_where_clause),cnvtstring(0))
  SET form_where_clause = concat(trim(form_where_clause),
   " and dfr.end_effective_dt_tm = cnvtdatetime(end_dt_tm)")
  CALL echo(build("form_where_clause:",form_where_clause))
  SET section_where_clause = concat(trim(section_where_clause),
   "dsr.dcp_section_ref_id = dfd.dcp_section_ref_id")
  SET section_where_clause = concat(trim(section_where_clause)," and dsr.active_ind = ")
  SET section_where_clause = concat(trim(section_where_clause),cnvtstring(1))
  SET section_where_clause = concat(trim(section_where_clause)," and dsr.dcp_section_instance_id > ")
  SET section_where_clause = concat(trim(section_where_clause),cnvtstring(0))
  SET section_where_clause = concat(trim(section_where_clause),
   " and dsr.end_effective_dt_tm = cnvtdatetime(end_dt_tm)")
  CALL echo(build("section_where_clause:",section_where_clause))
  SET form2_where_clause = concat(trim(form2_where_clause),
   "dfd.dcp_forms_ref_id = dfr.dcp_forms_ref_id")
  SET form2_where_clause = concat(trim(form2_where_clause),
   " and dfd.dcp_form_instance_id = dfr.dcp_form_instance_id")
  SET input_where_clause = concat(trim(input_where_clause),
   "dir.dcp_section_ref_id = dsr.dcp_section_ref_id")
  SET input_where_clause = concat(trim(input_where_clause),
   " and dir.dcp_section_instance_id = dsr.dcp_section_instance_id")
  CALL echo(build("section_where_clause:",input_where_clause))
 ELSE
  SET form_where_clause = concat(trim(form_where_clause),"dfr.dcp_forms_ref_id = ")
  SET form_where_clause = concat(trim(form_where_clause),cnvtstring(form_ref_id,20,2))
  SET form_where_clause = concat(trim(form_where_clause)," and dfr.active_ind = ")
  SET form_where_clause = concat(trim(form_where_clause),cnvtstring(1))
  SET section_where_clause = concat(trim(section_where_clause),
   "dsr.dcp_section_ref_id = dfd.dcp_section_ref_id")
  SET section_where_clause = concat(trim(section_where_clause)," and dsr.active_ind = ")
  SET section_where_clause = concat(trim(section_where_clause),cnvtstring(1))
  SET form2_where_clause = concat(trim(form2_where_clause),
   "dfd.dcp_forms_ref_id = dfr.dcp_forms_ref_id")
  SET input_where_clause = concat(trim(input_where_clause),
   "dir.dcp_section_ref_id = dsr.dcp_section_ref_id")
 ENDIF
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id, dfr.description, dfr.done_charting_ind,
  dfr.definition, dfr.width, dfr.height,
  dfr.enforce_required_ind, dfr.event_set_name, dfr.flags,
  dfd.dcp_forms_ref_id, dfd.dcp_section_ref_id, dfd.section_seq,
  dfd.flags, dsr.dcp_section_ref_id, dsr.description,
  dsr.definition, dsr.width, dsr.height,
  dir.dcp_input_ref_id, dir.description, dir.input_ref_seq,
  dir.input_type, dir.module, nvp.pvc_name,
  nvp.pvc_value, nvp.merge_name, nvp.merge_id
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp
  PLAN (dfr
   WHERE parser(form_where_clause))
   JOIN (dfd
   WHERE parser(form2_where_clause))
   JOIN (dsr
   WHERE parser(section_where_clause))
   JOIN (dir
   WHERE parser(input_where_clause))
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id)
  ORDER BY dfd.section_seq, dir.input_ref_seq, nvp.pvc_name,
   nvp.sequence
  HEAD REPORT
   section_cnt = 0, input_cnt = 0
  HEAD dfr.dcp_forms_ref_id
   internal->dcp_forms_ref_id = dfr.dcp_forms_ref_id, internal->form_description = dfr.description,
   internal->done_charting_ind = dfr.done_charting_ind,
   internal->form_definition = dfr.definition, internal->form_width = dfr.width, internal->
   form_height = dfr.height,
   internal->enforce_required_ind = dfr.enforce_required_ind, internal->event_set_name = dfr
   .event_set_name, internal->form_flags = dfr.flags,
   internal->form_event_cd = dfr.event_cd
   IF (dfr.event_cd != 0)
    internal->form_event_cd_disp = uar_get_code_display(dfr.event_cd)
   ENDIF
   section_cnt = 0
  HEAD dsr.dcp_section_ref_id
   section_cnt = (section_cnt+ 1)
   IF (section_cnt > size(internal->section_qual,5))
    stat = alterlist(internal->section_qual,(section_cnt+ 5))
   ENDIF
   internal->section_qual[section_cnt].dcp_section_ref_id = dfd.dcp_section_ref_id, internal->
   section_qual[section_cnt].section_seq = dfd.section_seq, internal->section_qual[section_cnt].
   section_flags = dfd.flags,
   internal->section_qual[section_cnt].section_description = dsr.description, internal->section_qual[
   section_cnt].section_definition = dsr.definition, internal->section_qual[section_cnt].
   section_width = dsr.width,
   internal->section_qual[section_cnt].section_height = dsr.height, input_cnt = 0
  DETAIL
   input_cnt = (input_cnt+ 1)
   IF (input_cnt > size(internal->section_qual[section_cnt].input_qual,5))
    stat = alterlist(internal->section_qual[section_cnt].input_qual,(input_cnt+ 5))
   ENDIF
   internal->section_qual[section_cnt].input_qual[input_cnt].dcp_input_ref_id = dir.dcp_input_ref_id,
   internal->section_qual[section_cnt].input_qual[input_cnt].input_description = dir.description,
   internal->section_qual[section_cnt].input_qual[input_cnt].input_ref_seq = dir.input_ref_seq,
   internal->section_qual[section_cnt].input_qual[input_cnt].input_type = dir.input_type, internal->
   section_qual[section_cnt].input_qual[input_cnt].module = dir.module, internal->section_qual[
   section_cnt].input_qual[input_cnt].pvc_name = nvp.pvc_name,
   internal->section_qual[section_cnt].input_qual[input_cnt].pvc_value = nvp.pvc_value, internal->
   section_qual[section_cnt].input_qual[input_cnt].merge_name = nvp.merge_name, internal->
   section_qual[section_cnt].input_qual[input_cnt].merge_id = nvp.merge_id,
   internal->section_qual[section_cnt].input_qual[input_cnt].sequence = nvp.sequence
  FOOT  dsr.dcp_section_ref_id
   stat = alterlist(internal->section_qual[section_cnt].input_qual,input_cnt), internal->
   section_qual[section_cnt].input_cnt = input_cnt
  FOOT  dfr.dcp_forms_ref_id
   stat = alterlist(internal->section_qual,section_cnt), internal->section_cnt = section_cnt
  WITH nocounter
 ;end select
 GO TO continue_with_export
#no_module
 CALL echo("domain doesn't contain module field on the dcp_input_ref table")
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id, dfr.description, dfr.done_charting_ind,
  dfr.definition, dfr.width, dfr.height,
  dfr.enforce_required_ind, dfr.event_set_name, dfr.flags,
  dfd.dcp_forms_ref_id, dfd.dcp_section_ref_id, dfd.section_seq,
  dfd.flags, dsr.dcp_section_ref_id, dsr.description,
  dsr.definition, dsr.width, dsr.height,
  dir.dcp_input_ref_id, dir.description, dir.input_ref_seq,
  dir.input_type, nvp.pvc_name, nvp.pvc_value,
  nvp.merge_name, nvp.merge_id
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp
  PLAN (dfr
   WHERE (dfr.dcp_forms_ref_id= $1)
    AND dfr.active_ind=1)
   JOIN (dfd
   WHERE dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id)
   JOIN (dsr
   WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dir.dcp_section_ref_id=dsr.dcp_section_ref_id)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id)
  ORDER BY dfd.section_seq, dir.input_ref_seq, nvp.pvc_name,
   nvp.sequence
  HEAD REPORT
   section_cnt = 0, input_cnt = 0
  HEAD dfr.dcp_forms_ref_id
   internal->dcp_forms_ref_id = dfr.dcp_forms_ref_id, internal->form_description = dfr.description,
   internal->done_charting_ind = dfr.done_charting_ind,
   internal->form_definition = dfr.definition, internal->form_width = dfr.width, internal->
   form_height = dfr.height,
   internal->enforce_required_ind = dfr.enforce_required_ind, internal->event_set_name = dfr
   .event_set_name, internal->form_flags = dfr.flags,
   internal->form_event_cd = dfr.event_cd
   IF (dfr.event_cd != 0)
    internal->form_event_cd_disp = uar_get_code_display(dfr.event_cd)
   ENDIF
   section_cnt = 0
  HEAD dsr.dcp_section_ref_id
   section_cnt = (section_cnt+ 1)
   IF (section_cnt > size(internal->section_qual,5))
    stat = alterlist(internal->section_qual,(section_cnt+ 5))
   ENDIF
   internal->section_qual[section_cnt].dcp_section_ref_id = dfd.dcp_section_ref_id, internal->
   section_qual[section_cnt].section_seq = dfd.section_seq, internal->section_qual[section_cnt].
   section_flags = dfd.flags,
   internal->section_qual[section_cnt].section_description = dsr.description, internal->section_qual[
   section_cnt].section_definition = dsr.definition, internal->section_qual[section_cnt].
   section_width = dsr.width,
   internal->section_qual[section_cnt].section_height = dsr.height, input_cnt = 0
  DETAIL
   input_cnt = (input_cnt+ 1)
   IF (input_cnt > size(internal->section_qual[section_cnt].input_qual,5))
    stat = alterlist(internal->section_qual[section_cnt].input_qual,(input_cnt+ 5))
   ENDIF
   internal->section_qual[section_cnt].input_qual[input_cnt].dcp_input_ref_id = dir.dcp_input_ref_id,
   internal->section_qual[section_cnt].input_qual[input_cnt].input_description = dir.description,
   internal->section_qual[section_cnt].input_qual[input_cnt].input_ref_seq = dir.input_ref_seq,
   internal->section_qual[section_cnt].input_qual[input_cnt].input_type = dir.input_type, internal->
   section_qual[section_cnt].input_qual[input_cnt].module = " ", internal->section_qual[section_cnt].
   input_qual[input_cnt].pvc_name = nvp.pvc_name,
   internal->section_qual[section_cnt].input_qual[input_cnt].pvc_value = nvp.pvc_value, internal->
   section_qual[section_cnt].input_qual[input_cnt].merge_name = nvp.merge_name, internal->
   section_qual[section_cnt].input_qual[input_cnt].merge_id = nvp.merge_id,
   internal->section_qual[section_cnt].input_qual[input_cnt].sequence = nvp.sequence
  FOOT  dsr.dcp_section_ref_id
   stat = alterlist(internal->section_qual[section_cnt].input_qual,input_cnt), internal->
   section_qual[section_cnt].input_cnt = input_cnt
  FOOT  dfr.dcp_forms_ref_id
   stat = alterlist(internal->section_qual,section_cnt), internal->section_cnt = section_cnt
  WITH nocounter
 ;end select
#continue_with_export
 FOR (x = 1 TO internal->section_cnt)
   FOR (y = 1 TO internal->section_qual[x].input_cnt)
    SET nomen_cnt = 0
    IF (trim(internal->section_qual[x].input_qual[y].merge_name)="DISCRETE_TASK_ASSAY"
     AND (internal->section_qual[x].input_qual[y].merge_id > 0.00))
     IF ((internal->section_qual[x].input_qual[y].merge_id > 0))
      CALL checkandadddta(internal->section_qual[x].input_qual[y].merge_id)
     ENDIF
     SELECT INTO "nl:"
      dta.mnemonic, dta.description, dta.task_assay_cd,
      cv.code_value, n.nomenclature_id
      FROM discrete_task_assay dta,
       (dummyt d5  WITH seq = 1),
       code_value cv,
       (dummyt d1  WITH seq = 1),
       reference_range_factor rr,
       (dummyt d2  WITH seq = 1),
       alpha_responses ar,
       nomenclature n
      PLAN (dta
       WHERE (dta.task_assay_cd=internal->section_qual[x].input_qual[y].merge_id))
       JOIN (d5)
       JOIN (cv
       WHERE cv.code_value=dta.task_assay_cd
        AND cv.code_set=14003)
       JOIN (d1)
       JOIN (rr
       WHERE rr.task_assay_cd=dta.task_assay_cd
        AND rr.active_ind=1)
       JOIN (d2)
       JOIN (ar
       WHERE ar.reference_range_factor_id=rr.reference_range_factor_id
        AND ar.active_ind=1)
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.active_ind=1)
      ORDER BY rr.reference_range_factor_id, ar.sequence
      HEAD dta.task_assay_cd
       internal->section_qual[x].input_qual[y].dta_mnemonic = dta.mnemonic, internal->section_qual[x]
       .input_qual[y].dta_description = dta.description, internal->section_qual[x].input_qual[y].
       dta_act_display = uar_get_code_display(dta.activity_type_cd)
      HEAD cv.code_value
       internal->section_qual[x].input_qual[y].cki = cv.cki
      HEAD n.nomenclature_id
       internal->all_nomen_cnt = (internal->all_nomen_cnt+ 1)
       IF ((internal->all_nomen_cnt > size(internal->nomenclature_qual,5)))
        stat = alterlist(internal->nomenclature_qual,(internal->all_nomen_cnt+ 1))
       ENDIF
       internal->nomenclature_qual[internal->all_nomen_cnt].nomenclature_id = n.nomenclature_id
       IF ((internal->nomenclature_qual[internal->all_nomen_cnt].nomenclature_id=0))
        internal->all_nomen_cnt = (internal->all_nomen_cnt - 1)
       ENDIF
      WITH nocounter, check, outerjoin = d5
     ;end select
     SET internal->section_qual[x].input_qual[y].event_cd_display = " "
     SET internal->section_qual[x].input_qual[y].code_value_display = " "
     SET internal->section_qual[x].input_qual[y].code_set = 0
     SET stat = alterlist(internal->dta_qual,internal->all_dta_cnt)
    ELSEIF (trim(internal->section_qual[x].input_qual[y].merge_name)="V500_EVENT_CODE")
     SELECT INTO "nl:"
      v5.event_cd
      FROM v500_event_code v5
      WHERE (v5.event_cd=internal->section_qual[x].input_qual[y].merge_id)
      DETAIL
       internal->section_qual[x].input_qual[y].event_cd_display = v5.event_cd_disp
      WITH nocounter
     ;end select
     SET internal->section_qual[x].input_qual[y].dta_mnemonic = " "
     SET internal->section_qual[x].input_qual[y].dta_description = " "
     SET internal->section_qual[x].input_qual[y].code_value_display = " "
     SET internal->section_qual[x].input_qual[y].code_set = 0
    ELSEIF (trim(internal->section_qual[x].input_qual[y].merge_name)="CODE_VALUE")
     SELECT INTO "nl:"
      cv.display
      FROM code_value cv
      WHERE (cv.code_value=internal->section_qual[x].input_qual[y].merge_id)
      DETAIL
       internal->section_qual[x].input_qual[y].code_value_display = cv.display, internal->
       section_qual[x].input_qual[y].code_set = cv.code_set
      WITH nocounter
     ;end select
     SET internal->section_qual[x].input_qual[y].dta_mnemonic = " "
     SET internal->section_qual[x].input_qual[y].dta_description = " "
     SET internal->section_qual[x].input_qual[y].event_cd_display = " "
    ELSEIF (trim(internal->section_qual[x].input_qual[y].merge_name)="DCP_SECTION_REF")
     SELECT INTO "nl:"
      s.description
      FROM dcp_section_ref s
      WHERE (s.dcp_section_ref_id=internal->section_qual[x].input_qual[y].merge_id)
       AND s.active_ind=1
      DETAIL
       internal->section_qual[x].input_qual[y].cond_sect_desc = s.description, internal->
       section_qual[x].input_qual[y].cond_sect_defn = s.definition
      WITH nocounter
     ;end select
     SET internal->section_qual[x].input_qual[y].dta_mnemonic = " "
     SET internal->section_qual[x].input_qual[y].dta_description = " "
     SET internal->section_qual[x].input_qual[y].event_cd_display = " "
     SET internal->section_qual[x].input_qual[y].code_set = 0
    ELSE
     SET internal->section_qual[x].input_qual[y].dta_mnemonic = " "
     SET internal->section_qual[x].input_qual[y].dta_description = " "
     SET internal->section_qual[x].input_qual[y].event_cd_display = " "
     SET internal->section_qual[x].input_qual[y].code_value_display = " "
     SET internal->section_qual[x].input_qual[y].code_set = 0
    ENDIF
   ENDFOR
 ENDFOR
 CALL echo("Building lines")
 SET line = fillstring(700," ")
 SET dcp_forms_ref_id = build(internal->dcp_forms_ref_id,",")
 SET tmp_form_description = concat('"',trim(internal->form_description),'"')
 SET form_description = build(tmp_form_description,",")
 SET done_charting_ind = build(internal->done_charting_ind,",")
 SET tmp_form_definition = concat('"',trim(internal->form_definition),'"')
 SET form_definition = build(tmp_form_definition,",")
 SET form_width = build(internal->form_width,",")
 SET form_height = build(internal->form_height,",")
 SET enforce_required_ind = build(internal->enforce_required_ind,",")
 SET event_set_name = build(trim(internal->event_set_name),",")
 SET form_event_cd = build(internal->form_event_cd,",")
 SET form_event_cd_disp = concat('"',trim(internal->form_event_cd_disp),'"')
 SET form_event_cd_disp = build(form_event_cd_disp,",")
 SET form_flags = build(internal->form_flags,",")
 FOR (x = 1 TO internal->section_cnt)
   SET dcp_section_ref_id = build(internal->section_qual[x].dcp_section_ref_id,",")
   SET section_seq = build(internal->section_qual[x].section_seq,",")
   SET section_flags = build(internal->section_qual[x].section_flags,",")
   SET tmp_section_description = concat('"',trim(internal->section_qual[x].section_description),'"')
   SET section_description = build(tmp_section_description,",")
   SET tmp_section_definition = concat('"',trim(internal->section_qual[x].section_definition),'"')
   SET section_definition = build(tmp_section_definition,",")
   SET section_width = build(internal->section_qual[x].section_width,",")
   SET section_height = build(internal->section_qual[x].section_height,",")
   FOR (y = 1 TO internal->section_qual[x].input_cnt)
     SET dcp_input_ref_id = build(internal->section_qual[x].input_qual[y].dcp_input_ref_id,",")
     IF (tmp_dcp_input_ref_id=dcp_input_ref_id)
      SET input_description = " ,"
      SET input_ref_seq = " ,"
      SET input_type = " ,"
      SET module = " ,"
     ELSE
      SET tmp_dcp_input_ref_id = dcp_input_ref_id
      SET tmp_input_description = concat('"',trim(internal->section_qual[x].input_qual[y].
        input_description),'"')
      SET input_description = build(trim(tmp_input_description),",")
      CALL echo(build("input description: ",input_description))
      SET input_ref_seq = build(internal->section_qual[x].input_qual[y].input_ref_seq,",")
      SET input_type = build(internal->section_qual[x].input_qual[y].input_type,",")
      SET module = build(trim(internal->section_qual[x].input_qual[y].module),",")
     ENDIF
     SET pvc_name = build(trim(internal->section_qual[x].input_qual[y].pvc_name),",")
     SET pvc_value = build(internal->section_qual[x].input_qual[y].pvc_value,",")
     SET merge_name = build(trim(internal->section_qual[x].input_qual[y].merge_name),",")
     SET merge_id = build(internal->section_qual[x].input_qual[y].merge_id,",")
     SET sequence = build(internal->section_qual[x].input_qual[y].sequence,",")
     SET tmp_dta_mnemonic = concat('"',trim(internal->section_qual[x].input_qual[y].dta_mnemonic),'"'
      )
     SET dta_mnemonic = build(trim(tmp_dta_mnemonic),",")
     SET tmp_dta_description = concat('"',trim(internal->section_qual[x].input_qual[y].
       dta_description),'"')
     SET dta_description = build(tmp_dta_description,",")
     SET tmp_dta_act_type_display = concat('"',trim(internal->section_qual[x].input_qual[y].
       dta_act_display),'"')
     SET dta_act_type_display = build(tmp_dta_act_type_display,",")
     SET event_cd_display = build(trim(internal->section_qual[x].input_qual[y].event_cd_display),",")
     SET code_value_display = build(trim(internal->section_qual[x].input_qual[y].code_value_display),
      ",")
     SET code_set1 = build(internal->section_qual[x].input_qual[y].code_set,",")
     SET cond_sect_desc = build(trim(internal->section_qual[x].input_qual[y].cond_sect_desc),",")
     SET cond_sect_defn = build(trim(internal->section_qual[x].input_qual[y].cond_sect_defn),",")
     IF ((internal->section_qual[x].input_qual[y].merge_name="DISCRETE_TASK_ASSAY"))
      SET tmp_dta_mnemonic = concat('"',trim(internal->section_qual[x].input_qual[y].dta_mnemonic),
       '"')
      SET dta_mnemonic = build(trim(tmp_dta_mnemonic),",")
      SET tmp_dta_description = concat('"',trim(internal->section_qual[x].input_qual[y].
        dta_description),'"')
      SET dta_description = build(trim(tmp_dta_description),",")
     ENDIF
     IF ((internal->section_qual[x].input_qual[y].merge_name="V500_EVENT_CODE"))
      SET tmp_event_cd_display = concat('"',trim(internal->section_qual[x].input_qual[y].
        event_cd_display),'"')
      SET event_cd_display = build(trim(tmp_event_cd_display),",")
     ENDIF
     IF ((internal->section_qual[x].input_qual[y].merge_name="CODE_VALUE"))
      SET tmp_code_value_display = concat('"',trim(internal->section_qual[x].input_qual[y].
        code_value_display),'"')
      SET code_value_display = build(trim(tmp_code_value_display),",")
     ENDIF
     IF ((internal->section_qual[x].input_qual[y].merge_name="DCP_SECTION_REF"))
      SET tmp_cond_sect_desc = concat('"',trim(internal->section_qual[x].input_qual[y].cond_sect_desc
        ),'"')
      SET cond_sect_desc = build(trim(tmp_cond_sect_desc),",")
      SET tmp_cond_sect_defn = concat('"',trim(internal->section_qual[x].input_qual[y].cond_sect_defn
        ),'"')
      SET cond_sect_defn = build(trim(tmp_cond_sect_defn),",")
     ENDIF
     SET tmp_pvc_value = concat('"',trim(internal->section_qual[x].input_qual[y].pvc_value),'"')
     SET pvc_value = tmp_pvc_value
     SET tmp_text2 = fillstring(256," ")
     SET tmp_text3 = fillstring(256," ")
     SET lf = concat(char(13),char(10))
     SET newline_cnt = 0
     SET length = textlen(pvc_value)
     SET cr = findstring(lf,pvc_value)
     WHILE (cr > 0)
       SET tmp_text2 = substring(1,(cr - 1),pvc_value)
       SET tmp_text3 = substring((cr+ 2),(length - (cr+ 2)),pvc_value)
       SET nl = movestring("*/~",1,tmp_text2,cr,3)
       SET newline_cnt = (newline_cnt+ 1)
       SET stat = alterlist(blob->qual,newline_cnt)
       SET blob->qual[newline_cnt].line = tmp_text2
       SET pvc_value = tmp_text3
       SET length = textlen(pvc_value)
       SET cr = findstring(lf,pvc_value)
     ENDWHILE
     IF (newline_cnt > 0)
      SET tmp_text2 = substring((cr+ 1),(length - (cr+ 2)),pvc_value)
      SET newline_cnt = (newline_cnt+ 1)
      SET stat = alterlist(blob->qual,newline_cnt)
      SET blob->qual[newline_cnt].line = tmp_text2
      SET tmp_text2 = fillstring(700," ")
      SET tmp_text2 = blob->qual[1].line
      FOR (zz = 2 TO newline_cnt)
        SET tmp_text2 = concat(trim(tmp_text2),trim(blob->qual[zz].line))
      ENDFOR
      SET pvc_value = build(tmp_text2,",")
     ELSE
      SET pvc_value = build(tmp_pvc_value,",")
     ENDIF
     SET line_cnt = (line_cnt+ 1)
     IF (line_cnt > size(internal->line_qual,5))
      SET stat = alterlist(internal->line_qual,(line_cnt+ 1))
     ENDIF
     SET line = fillstring(700," ")
     SET line = concat(trim(dcp_forms_ref_id),trim(form_description),trim(done_charting_ind),trim(
       form_definition))
     SET line = concat(trim(line),trim(form_width),trim(form_height),trim(enforce_required_ind))
     SET line = concat(trim(line),trim(event_set_name),trim(form_event_cd),trim(form_event_cd_disp))
     SET line = concat(trim(line),trim(form_flags),trim(section_description),trim(section_definition)
      )
     SET line = concat(trim(line),trim(dcp_section_ref_id),trim(section_seq),trim(section_flags))
     SET line = concat(trim(line),trim(section_width),trim(section_height),trim(dcp_input_ref_id),
      trim(input_description))
     SET line = concat(trim(line),trim(input_ref_seq),trim(input_type),trim(module),trim(pvc_name),
      trim(pvc_value))
     SET line = concat(trim(line),trim(merge_name),trim(merge_id),trim(sequence),trim(dta_mnemonic),
      trim(dta_description))
     SET line = concat(trim(line),trim(dta_act_type_display),trim(event_cd_display))
     SET line = concat(trim(line),trim(code_set1),trim(code_value_display))
     SET line = concat(trim(line),trim(cond_sect_desc),trim(cond_sect_defn))
     SET internal->line_qual[line_cnt].line = line
     SET form_event_cd_disp = " ,"
     SET dcp_forms_ref_id = " ,"
     SET form_description = " ,"
     SET done_charting_ind = " ,"
     SET form_definition = " ,"
     SET form_width = " ,"
     SET form_height = " ,"
     SET enforce_required_ind = " ,"
     SET event_set_name = " ,"
     SET form_event_cd = " ,"
     SET form_flags = " ,"
     SET section_seq = " ,"
     SET section_flags = " ,"
     SET section_description = " ,"
     SET section_definition = " ,"
     SET section_width = " ,"
     SET section_height = " ,"
   ENDFOR
 ENDFOR
 CALL echo("Build pf csv")
 SET filename = concat("dcp_",trim(cnvtstring( $1)),"_pf.csv")
 SELECT INTO value(filename)
  FROM (dummyt d1  WITH seq = value(line_cnt))
  HEAD REPORT
   row 0,
   "DCP_FORMS_REFS_ID, Form_Description,Done_Charting_Ind, Form_Definition, Form_Width, Form_Height, Enforce_Required_Ind,",
   "Event_Set_Name, Form_Event_Cd, Form_event_cd_disp, Form_Flags, Section_Description, Section_Definition, DCP_SECTION_REF_ID,",
   "Section_Seq,Section_Flags,Section_Width, Section_Height, DCP_INPUT_REF_ID, Input_Description,",
   "Input_Ref_Seq, Input_Type, Module, PVC_Name, PVC_Value, Merge_Name, Merge_ID, Sequence, DTA_Mnemonic, DTA_Description,",
   "Dta_Act_Type_Display, Event_Cd_Display, Code_set, Code_Value_Display, Cond_Sect_Desc, Cond_Sect_Defn"
  DETAIL
   line = fillstring(700," "), line = internal->line_qual[d1.seq].line, row + 1,
   line
  WITH maxcol = 800, maxrow = 3000, nocounter,
   nullreport
 ;end select
 IF ((internal->all_dta_cnt=0))
  GO TO exit_program
 ENDIF
 IF ((internal->all_nomen_cnt=0))
  GO TO build_dta_csv
 ENDIF
#build_nomen_csv
 CALL echo("build nomen csv")
 SET filename = concat("dcp_",trim(cnvtstring( $1)),"_nomen.csv")
 SET principle_type_mean = fillstring(60," ")
 SET active_status_mean = fillstring(60," ")
 SET contributor_system_mean = fillstring(60," ")
 SET source_string = fillstring(265," ")
 SET source_identifier = fillstring(60," ")
 SET string_identifier = fillstring(60," ")
 SET string_status_mean = fillstring(60," ")
 SET term_identifier = fillstring(60," ")
 SET term_source_mean = fillstring(60," ")
 SET language_mean = fillstring(60," ")
 SET source_vocabulary_mean = fillstring(60," ")
 SET data_status_mean = fillstring(60," ")
 SET short_string = fillstring(110," ")
 SET mnemonic = fillstring(60," ")
 SET concept_identifier = fillstring(60," ")
 SET concept_source_mean = fillstring(60," ")
 SET string_source_mean = fillstring(60," ")
 SET version = fillstring(60," ")
 SET vocab_axis_mean = fillstring(60," ")
 SET primary_vterm_ind = fillstring(60," ")
 SET beg_effective_dt_tm = fillstring(60," ")
 SET tmp_source_string = fillstring(265," ")
 SET tmp_mnemonic = fillstring(255," ")
 SET tmp_short_string = fillstring(265," ")
 SELECT INTO value(filename)
  n.source_string, n.source_identifier, n.string_identifier,
  t.term_identifier, n.short_string, n.mnemonic,
  n.concept_identifier
  FROM (dummyt d1  WITH seq = value(internal->all_nomen_cnt)),
   nomenclature n,
   term t
  PLAN (d1)
   JOIN (n
   WHERE (n.nomenclature_id=internal->nomenclature_qual[d1.seq].nomenclature_id)
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (t
   WHERE n.term_id=t.term_id)
  ORDER BY n.nomenclature_id
  HEAD REPORT
   row 0, "PRINCIPLE_TYPE_MEAN, CONTRIBUTOR_SYSTEM_MEAN, SOURCE_STRING, SOURCE_IDENTIFIER,",
   "STRING_IDENTIFIER, STRING_STATUS_MEAN, TERM_IDENTIFIER, TERM_SOURCE_MEAN, LANGUAGE_MEAN,",
   "SOURCE_VOCABULARY_MEAN, DATA_STATUS_MEAN, SHORT_STRING, MNEMONIC, CONCEPT_IDENTIFIER,",
   "CONCEPT_SOURCE_MEAN, STRING_SOURCE_MEAN, VERSION, VOCAB_AXIS_MEAN, PRIMARY_VTERM_IND, BEG_EFFECTIVE_DT_TM"
  HEAD n.nomenclature_id
   line = fillstring(255," "),
   CALL echo(build(n.language_cd)), principle_type_mean = build(trim(uar_get_code_meaning(n
      .principle_type_cd)),","),
   active_status_mean = build(trim(uar_get_code_meaning(n.active_status_cd)),","),
   contributor_system_mean = build(trim(uar_get_code_meaning(n.contributor_system_cd)),","),
   tmp_source_string = concat('"',trim(n.source_string),'"'),
   source_string = build(tmp_source_string,","), source_identifier = build(trim(n.source_identifier),
    ","), string_identifier = build(trim(n.string_identifier),","),
   string_status_mean = build(trim(uar_get_code_meaning(n.string_status_cd)),","), term_identifier =
   build(t.term_id,","), term_source_mean = build(trim(uar_get_code_meaning(t.term_source_cd)),","),
   language_mean = build(trim(uar_get_code_meaning(n.language_cd)),","), source_vocabulary_mean =
   build(trim(uar_get_code_meaning(n.source_vocabulary_cd)),","), data_status_mean = build(trim(
     uar_get_code_meaning(n.data_status_cd)),","),
   tmp_short_string = concat('"',trim(n.short_string),'"'), short_string = build(tmp_short_string,","
    ), tmp_mnemonic = concat('"',trim(n.mnemonic),'"'),
   mnemonic = build(tmp_mnemonic,","), concept_identifier = build(trim(n.concept_identifier),","),
   concept_source_mean = build(trim(uar_get_code_meaning(n.concept_source_cd)),","),
   string_source_mean = build(trim(uar_get_code_meaning(n.string_source_cd)),","), version = build(
    "1999",","), vocab_axis_mean = build(trim(uar_get_code_meaning(n.vocab_axis_cd)),","),
   primary_vterm_ind = build(n.primary_vterm_ind,","), beg_effective_dt_tm = build(" ",","), line =
   concat(trim(principle_type_mean),trim(contributor_system_mean)),
   line = concat(trim(line),trim(source_string),trim(source_identifier),trim(string_identifier)),
   line = concat(trim(line),trim(string_status_mean),trim(term_identifier),trim(term_source_mean),
    trim(language_mean)), line = concat(trim(line),trim(source_vocabulary_mean),trim(data_status_mean
     ),trim(short_string)),
   line = concat(trim(line),trim(mnemonic),trim(concept_identifier),trim(concept_source_mean)), line
    = concat(trim(line),trim(string_source_mean),trim(version),trim(vocab_axis_mean)), line = concat(
    trim(line),trim(primary_vterm_ind),trim(beg_effective_dt_tm)),
   row + 1, line
  WITH maxcol = 800, maxrow = 600, nocounter,
   nullreport, outerjoin = d1
 ;end select
 IF ((internal->all_dta_cnt=0))
  GO TO exit_program
 ENDIF
#build_dta_csv
 CALL echo("build dta csv")
 SET filename = concat("dcp_",trim(cnvtstring( $1)),"_dta.csv")
 SET cnt = 0
 SET mnemonic = fillstring(60," ")
 SET tmp_mnemonic = fillstring(60," ")
 SET desc = fillstring(100," ")
 SET tmp_desc = fillstring(100," ")
 SET activity_type = fillstring(60," ")
 SET default_result_type = fillstring(60," ")
 SET dta_code_set = fillstring(60," ")
 SET bb_result_processing = fillstring(60," ")
 SET rad_section_type = fillstring(60," ")
 SET event_disp = fillstring(40," ")
 SET event_descr = fillstring(60," ")
 SET event_defn = fillstring(100," ")
 SET event_cd = fillstring(60," ")
 SET min_digits = fillstring(60," ")
 SET max_digits = fillstring(60," ")
 SET min_dec_places = fillstring(60," ")
 SET sex = fillstring(60," ")
 SET age_from_minutes = fillstring(60," ")
 SET age_from_units = fillstring(60," ")
 SET age_to_minutes = fillstring(60," ")
 SET age_to_units = fillstring(60," ")
 SET gestational = fillstring(60," ")
 SET specimen_type = fillstring(60," ")
 SET service_resource = fillstring(60," ")
 SET species = fillstring(60," ")
 SET encntr_type = fillstring(60," ")
 SET normal_low = fillstring(60," ")
 SET normal_high = fillstring(60," ")
 SET critical_high = fillstring(60," ")
 SET critical_low = fillstring(60," ")
 SET sensitive_low = fillstring(60," ")
 SET sensitive_high = fillstring(60," ")
 SET linear_low = fillstring(60," ")
 SET linear_high = fillstring(60," ")
 SET feasible_low = fillstring(60," ")
 SET feasible_high = fillstring(60," ")
 SET units = fillstring(50," ")
 SET tmp_nomen_mnemonic = fillstring(60," ")
 SET nomen_mnemonic = fillstring(60," ")
 SET default_ind = fillstring(50," ")
 SET use_units_ind = fillstring(50," ")
 SET result_process = fillstring(50," ")
 SET reference_ind = fillstring(50," ")
 SET mins_back = fillstring(50," ")
 SET lookback_units = fillstring(50," ")
 SET cki = fillstring(255," ")
 SET result_value = fillstring(50," ")
 SET multi_alpha_sort_order = fillstring(50," ")
 SET temp_event = fillstring(100," ")
 SET source_string = fillstring(300," ")
 SET tmp_source_string = fillstring(300," ")
 SET source_iden = fillstring(100," ")
 SET tmp_source_idec = fillstring(100," ")
 SET min_digits = build(" ,")
 SET max_digits = build(" ,")
 SET min_dec_places = build(" ,")
 SET line_cnt = 0
 SET stat = alterlist(internal->line_qual,line_cnt)
 SET line2 = fillstring(800," ")
 SET alpha_type_cd = 0.0
 SET multi_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 289
 SET cdf_meaning = cnvtupper("2")
 SET s = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),1,code_value)
 SET alpha_type_cd = code_value
 SET code_value = 0.0
 SET code_set = 289
 SET cdf_meaning = cnvtupper("5")
 SET s = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),1,code_value)
 SET multi_type_cd = code_value
 SET data_map_cnt = 0
 CALL echo(build("dta_cnt",value(internal->all_dta_cnt)))
 SELECT INTO value(filename)
  dta.mnemonic, dta.description, dta.event_cd,
  cv.cki, v5.event_cd, dm.min_digits,
  dm.max_digits, dm.min_decimal_places, rrf.age_from_minutes,
  rrf.age_to_minutes, rrf.normal_low, rrf.normal_high,
  rrf.critical_low, ar.reference_range_factor_id, n.source_string
  FROM (dummyt d  WITH seq = value(internal->all_dta_cnt)),
   discrete_task_assay dta,
   code_value cv,
   v500_event_code v5,
   reference_range_factor rrf,
   data_map dm,
   (dummyt d5  WITH seq = 1),
   (dummyt d6  WITH seq = 1),
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   alpha_responses ar,
   nomenclature n
  PLAN (d)
   JOIN (dta
   WHERE (dta.task_assay_cd=internal->dta_qual[d.seq].task_assay_cd)
    AND dta.active_ind=1)
   JOIN (d5
   WHERE d5.seq=1)
   JOIN (cv
   WHERE cv.code_value=dta.task_assay_cd
    AND cv.code_set=14003)
   JOIN (d6
   WHERE d6.seq=1)
   JOIN (v5
   WHERE v5.event_cd=dta.event_cd)
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (dm
   WHERE dm.task_assay_cd=dta.task_assay_cd
    AND dm.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (rrf
   WHERE rrf.task_assay_cd=dta.task_assay_cd
    AND rrf.active_ind=1)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (ar
   WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id
    AND ((dta.default_result_type_cd=alpha_type_cd) OR (dta.default_result_type_cd=multi_type_cd))
    AND ar.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=ar.nomenclature_id
    AND n.active_ind=1
    AND ((n.beg_effective_dt_tm=null) OR (n.beg_effective_dt_tm != null
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((n.end_effective_dt_tm=null) OR (n.end_effective_dt_tm != null
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
  ORDER BY dta.task_assay_cd, dm.task_assay_cd, rrf.reference_range_factor_id,
   ar.sequence, ar.nomenclature_id
  HEAD REPORT
   row 0, "dta_mnemonic, description, activity_type_cd, default_result_type_cd, code_set,",
   "bb_result_processing_cd, rad_section_type_cd, event_cd, cki, min_digits, max_digits,",
   "min_decimal_places, sex_cd, age_from_minutes, age_from_units_cd, age_to_minutes,",
   "age_to_units_cd, gestational_ind, specimen_type_cd, service_resource_cd,",
   "species_cd, encntr_type_cd, normal_low, normal_high, critical_low, critical_high,",
   "sensitive_low, sensitive_high, linear_low, linear_high, feasible_low, feasible_high,",
   "units_cd, mnemonic, default_ind, use_units_ind, result_process_cd, reference_ind,",
   "result_value, multi_alpha_sort_order, mins_back, lookback_units, source_string, source_identifier"
  HEAD dm.task_assay_cd
   min_digits = build(dm.min_digits,","), max_digits = build(dm.max_digits,","), min_dec_places =
   build(dm.min_decimal_places,","),
   data_map_cnt = 0
  HEAD rrf.reference_range_factor_id
   data_map_cnt = 0, dta_code_set = build(dta.code_set,","), bb_result_processing = build(
    cnvtalphanum(cnvtupper(trim(uar_get_code_display(dta.bb_result_processing_cd)))),","),
   rad_section_type = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(dta.rad_section_type_cd)
       ))),","), temp_event = concat('"',trim(v5.event_cd_disp),'"'), event = build(temp_event,","),
   cki = build(cv.cki,","), sex = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(rrf.sex_cd))
      )),","), age_from = cnvtalphanum(cnvtupper(trim(uar_get_code_display(rrf.age_from_units_cd)))),
   age_from_units = build(trim(age_from),",")
   IF (age_from="MINUTE*")
    age_from_minutes = build(rrf.age_from_minutes,",")
   ELSEIF (age_from="HOUR*")
    age_from_minutes = build((rrf.age_from_minutes/ 60.0),",")
   ELSEIF (age_from="DAY*")
    age_from_minutes = build(((rrf.age_from_minutes/ 60.0)/ 24.0),",")
   ELSEIF (age_from="WEEK*")
    age_from_minutes = build((((rrf.age_from_minutes/ 60.0)/ 24.0)/ 7.0),",")
   ELSEIF (age_from="MON*")
    age_from_minutes = build((((rrf.age_from_minutes/ 60.0)/ 24.0)/ 30.0),",")
   ELSEIF (age_from="YEAR*")
    age_from_minutes = build((((rrf.age_from_minutes/ 60.0)/ 24.0)/ 365),",")
   ELSE
    age_from_minutes = "0,"
   ENDIF
   age_to = cnvtalphanum(cnvtupper(trim(uar_get_code_display(rrf.age_to_units_cd)))), age_to_units =
   build(trim(age_to),",")
   IF (age_to="MINUTE*")
    age_to_minutes = build(rrf.age_to_minutes,",")
   ELSEIF (age_to="HOUR*")
    age_to_minutes = build((rrf.age_to_minutes/ 60.0),",")
   ELSEIF (age_to="DAY*")
    age_to_minutes = build(((rrf.age_to_minutes/ 60.0)/ 24.0),",")
   ELSEIF (age_to="WEEK*")
    age_to_minutes = build((((rrf.age_to_minutes/ 60.0)/ 24.0)/ 7.0),",")
   ELSEIF (age_to="MON*")
    age_to_minutes = build((((rrf.age_to_minutes/ 60.0)/ 24.0)/ 30.0),",")
   ELSEIF (age_to="YEAR*")
    age_to_minutes = build((((rrf.age_to_minutes/ 60.0)/ 24.0)/ 365),",")
   ELSE
    age_to_minutes = "0,"
   ENDIF
   IF (rrf.gestational_ind=1)
    gestational = build("Y",",")
   ELSE
    gestational = build(" ",",")
   ENDIF
   specimen_type = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(rrf.specimen_type_cd)))),
    ","), service_resource = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(rrf
        .service_resource_cd)))),","), species = build(cnvtalphanum(cnvtupper(trim(
       uar_get_code_display(rrf.species_cd)))),","),
   encntr_type = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(rrf.encntr_type_cd)))),","),
   normal_low = build(rrf.normal_low,","), normal_high = build(rrf.normal_high,",")
   IF (rrf.critical_low=0)
    critical_low = "0,"
   ELSE
    critical_low = build(rrf.critical_low,",")
   ENDIF
   critical_high = build(rrf.critical_high,","), sensitive_low = build(rrf.sensitive_low,","),
   sensitive_high = build(rrf.sensitive_high,","),
   linear_low = build(rrf.linear_low,","), linear_high = build(rrf.linear_high,","), feasible_low =
   build(rrf.feasible_low,","),
   feasible_high = build(rrf.feasible_high,","), units = build(cnvtalphanum(cnvtupper(trim(
       uar_get_code_display(rrf.units_cd)))),","), mins_back = build(rrf.mins_back,","),
   lookback_units = build("MINUTE",","), nomen_mnemonic = " ,", default_ind = " ,",
   use_units_ind = " ,", reference_ind = " ,", result_value = " ,",
   multi_alpha_sort_order = " ,", source_string = " ,", source_iden = " ,"
  HEAD ar.nomenclature_id
   data_map_cnt = 0, tmp_mnemonic = concat('"',trim(dta.mnemonic,3),'"'), mnemonic = build(
    tmp_mnemonic,","),
   tmp_desc = concat('"',trim(dta.description,3),'"'), desc = build(tmp_desc,","), activity_type =
   build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(dta.activity_type_cd)))),","),
   default_result_type = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(dta
        .default_result_type_cd)))),",")
   IF (ar.nomenclature_id > 0)
    tmp_nomen_mnemonic = concat('"',trim(n.mnemonic),'"'), nomen_mnemonic = build(tmp_nomen_mnemonic,
     ",")
    IF (ar.default_ind=1)
     default_ind = build("Y",",")
    ELSE
     default_ind = build(" ",",")
    ENDIF
    IF (ar.use_units_ind=1)
     use_units_ind = build("Y",",")
    ELSE
     use_units_ind = build(" ",",")
    ENDIF
    result_process = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(ar.result_process_cd)))),
     ",")
    IF (ar.reference_ind=1)
     reference_ind = build("Y",",")
    ELSE
     reference_ind = build(" ",",")
    ENDIF
    result_value = build(ar.result_value,","), multi_alpha_sort_order = build(ar
     .multi_alpha_sort_order,","), tmp_source_string = concat('"',trim(n.source_string),'"'),
    source_string = build(tmp_source_string,","), tmp_source_iden = concat('"',trim(n
      .source_identifier),'"'), source_iden = build(tmp_source_iden,",")
   ENDIF
  DETAIL
   IF (data_map_cnt=0)
    data_map_cnt = (data_map_cnt+ 1), line2 = concat(trim(mnemonic),trim(desc),trim(activity_type)),
    line2 = concat(trim(line2),trim(default_result_type),trim(dta_code_set),trim(bb_result_processing
      )),
    line2 = concat(trim(line2),trim(rad_section_type),trim(event),trim(cki),trim(min_digits),
     trim(max_digits)), line2 = concat(trim(line2),trim(min_dec_places),trim(sex),trim(
      age_from_minutes),trim(age_from_units)), line2 = concat(trim(line2),trim(age_to_minutes),trim(
      age_to_units),trim(gestational),trim(specimen_type)),
    line2 = concat(trim(line2),trim(service_resource),trim(species),trim(encntr_type),trim(normal_low
      )), line2 = concat(trim(line2),trim(normal_high),trim(critical_low),trim(critical_high),trim(
      sensitive_low)), line2 = concat(trim(line2),trim(sensitive_high),trim(linear_low),trim(
      linear_high),trim(feasible_low)),
    line2 = concat(trim(line2),trim(feasible_high),trim(units),trim(nomen_mnemonic),trim(default_ind)
     ), line2 = concat(trim(line2),trim(use_units_ind),trim(result_process),trim(reference_ind)),
    line2 = concat(trim(line2),trim(result_value),trim(multi_alpha_sort_order)),
    line2 = concat(trim(line2),trim(mins_back),trim(lookback_units)), line2 = concat(trim(line2),trim
     (source_string),trim(source_iden)), row + 1,
    line2
   ENDIF
   mnemonic = " ,", desc = " ,", activity_type = " ,",
   default_result_type = " ,", dta_code_set = " ,", bb_result_processing = " ,",
   rad_section_type = " ,", event = " ,", cki = " ,",
   min_digits = " ,", max_digits = " ,", min_dec_places = " ,",
   sex = " ,", age_from_units = " ,", age_from_minutes = " ,",
   age_to_units = " ,", age_to_minutes = " ,", gestational_ind = " ,",
   specimen_type = " ,", service_resource = " ,", species = " ,",
   encntr_type = " ,", normal_low = " ,", normal_high = " ,",
   critical_low = " ,", critical_high = " ,", sensitive_low = " ,",
   sensitive_high = " ,", linear_low = " ,", linear_high = " ,",
   feasible_low = " ,", feasible_high = " ,", units = " ,",
   mins_back = " ,", lookback_units = " ,", source_iden = " ,",
   source_string = " ,", nomen_mnemonic = " ,", result_value = " ,",
   multi_alpha_sort_order = " ,"
  WITH maxcol = 1000, maxrow = 600, nocounter,
   nullreport, outerjoin = d, outerjoin = d5,
   outerjoin = d6, outerjoin = d1, outerjoin = d2,
   outerjoin = d4, dontcare = rrf, dontcare = ar,
   dontcare = dm
 ;end select
 CALL echo(build("dta equation tool"))
 SET filename = concat("dcp_",trim(cnvtstring( $1)),"_eqn.csv")
 SET cnt = 0
 SET task_assay_cd = fillstring(50," ")
 SET equation_id = fillstring(50," ")
 SET tmp_dta_mnemonic = fillstring(50," ")
 SET dta_mnemonic = fillstring(50," ")
 SET tmp_dta_descr = fillstring(100," ")
 SET dta_descr = fillstring(100," ")
 SET act_type_meaning = fillstring(50," ")
 SET serv_code_set = fillstring(50," ")
 SET serv_cd_disp = fillstring(50," ")
 SET species_code_set = fillstring(50," ")
 SET species_cd_disp = fillstring(50," ")
 SET age_unit_codeset = fillstring(50," ")
 SET age_from_units_disp = fillstring(50," ")
 SET age_from_minutes = fillstring(50," ")
 SET age_to_unit_disp = fillstring(50," ")
 SET age_to_minutes = fillstring(50," ")
 SET sex_code_set = fillstring(50," ")
 SET sex_code_disp = fillstring(50," ")
 SET equation_desc = fillstring(200," ")
 SET script = fillstring(50," ")
 SET gestational_age_ind = fillstring(50," ")
 SET equation_postfix = fillstring(200," ")
 SET unknown_age_ind = fillstring(50," ")
 SET age_ind = fillstring(50," ")
 SET component_flag = fillstring(50," ")
 SET constant_value = fillstring(50," ")
 SET cross_drawn_dt_tm_ind = fillstring(50," ")
 SET tmp_comp_mnemonic = fillstring(50," ")
 SET comp_mnemonic = fillstring(50," ")
 SET tmp_comp_desc = fillstring(100," ")
 SET comp_desc = fillstring(100," ")
 SET name = fillstring(50," ")
 SET octal_value = fillstring(50," ")
 SET race_ind = fillstring(50," ")
 SET result_req_flag = fillstring(50," ")
 SET result_status_cd = fillstring(50," ")
 SET sequence = fillstring(50," ")
 SET sex_ind = fillstring(50," ")
 SET variable_prompt = fillstring(50," ")
 SET time_window_minutes = fillstring(50," ")
 SET time_window_back_minutes = fillstring(50," ")
 SET units_code_set = fillstring(50," ")
 SET units_cd_disp = fillstring(50," ")
 SET default_ind = fillstring(50," ")
 SET comp_act_type_meaning = fillstring(50," ")
 SELECT INTO value(filename)
  dta.task_assay_cd, dta.description, dta.mnemonic,
  eqn.equation_id, dta1.task_assay_cd
  FROM (dummyt d  WITH seq = value(internal->all_dta_cnt)),
   discrete_task_assay dta,
   equation eqn,
   equation_component ec,
   (dummyt d1  WITH seq = 1),
   discrete_task_assay dta1
  PLAN (d)
   JOIN (dta
   WHERE (dta.task_assay_cd=internal->dta_qual[d.seq].task_assay_cd))
   JOIN (eqn
   WHERE eqn.task_assay_cd=dta.task_assay_cd
    AND eqn.active_ind=1)
   JOIN (ec
   WHERE ec.equation_id=eqn.equation_id)
   JOIN (d1)
   JOIN (dta1
   WHERE dta1.task_assay_cd=ec.included_assay_cd)
  HEAD REPORT
   row 0,
   "task_assay_cd,dta_mnemonic, dta_desc, act_type_display,serv_code_set,serv_cd_disp, species_code_set, species_cd_disp,",
   "equation_id, age_units_codeset, age_from_units_disp, age_from_minutes, age_to_units_disp, age_to_minutes,",
   "sex_code_set, sex_code_disp, equation_desc,default_ind, script,gestational_age_ind, equation_postfix,",
   "unknown_age_ind, age_ind, component_flag, constant_value,  cross_drawn_dt_tm_ind,",
   "comp_mnemonic, comp_desc, comp_act_type_display, name, octal_value, race_ind, result_req_flag, result_status_cs,",
   "result_status_disp, sequence, sex_ind, variable_prompt, time_window_minutes, time_window_back_minutes,",
   "units_cd_cs, units_cd_disp"
  DETAIL
   line3 = fillstring(800," "), cnt = (cnt+ 1), task_assay_cd = build(dta.task_assay_cd,","),
   equation_id = build(eqn.equation_id,","), tmp_dta_mnemonic = concat('"',trim(dta.mnemonic),'"'),
   dta_mnemonic = build(tmp_dta_mnemonic,","),
   tmp_dta_descr = concat('"',trim(dta.description),'"'), dta_descr = build(tmp_dta_descr,","),
   act_type_meaning = build(uar_get_code_display(dta.activity_type_cd),","),
   serv_code_set = build(220,","), serv_cd_disp = build(cnvtalphanum(cnvtupper(trim(
       uar_get_code_display(eqn.service_resource_cd)))),","), species_code_set = build(226,","),
   species_cd_disp = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(eqn.species_cd)))),","),
   age_unit_codeset = build(340,","), age_from_units_disp = build(cnvtalphanum(cnvtupper(trim(
       uar_get_code_display(eqn.age_from_units_cd)))),","),
   age_from_minutes = build(eqn.age_from_minutes,","), age_to_units_disp = build(cnvtalphanum(
     cnvtupper(trim(uar_get_code_display(eqn.age_to_units_cd)))),","), age_to_minutes = build(eqn
    .age_to_minutes,","),
   sex_code_set = build(57,","), sex_code_disp = build(cnvtalphanum(cnvtupper(trim(
       uar_get_code_display(eqn.sex_cd)))),","), equation_desc = build(trim(eqn.equation_description),
    ","),
   default_ind = build(eqn.default_ind,","), script = build(trim(eqn.script),","),
   gestational_age_ind = build(eqn.gestational_age_ind,","),
   equation_postfix = build(trim(eqn.equation_postfix),","), unknown_age_ind = build(eqn
    .unknown_age_ind,","), age_ind = build(ec.age_ind,","),
   component_flag = build(ec.component_flag,","), constant_value = build(ec.constant_value,","),
   cross_drawn_dt_tm_ind = build(ec.cross_drawn_dt_tm_ind,","),
   tmp_comp_mnemonic = concat('"',trim(dta1.mnemonic),'"'), comp_mnemonic = build(tmp_comp_mnemonic,
    ","), tmp_comp_desc = concat('"',trim(dta1.description),'"'),
   comp_desc = build(tmp_comp_desc,","), comp_act_type_meaning = build(uar_get_code_display(dta1
     .activity_type_cd),","), name = build(trim(ec.name),","),
   octal_value = build(ec.octal_value,","), race_ind = build(ec.race_ind,","), result_req_flag =
   build(ec.result_req_flag,","),
   result_status_cs = build(1901,","), result_status_disp = build(cnvtalphanum(cnvtupper(trim(
       uar_get_code_display(ec.result_status_cd)))),","), sequence = build(ec.sequence,","),
   sex_ind = build(ec.sex_ind,","), variable_prompt = build(trim(ec.variable_prompt),","),
   time_window_minutes = build(ec.time_window_minutes,","),
   time_window_back_minutes = build(ec.time_window_back_minutes,","), units_code_set = build(54,","),
   units_cd_disp = build(cnvtalphanum(cnvtupper(trim(uar_get_code_display(ec.units_cd)))),","),
   line3 = concat(trim(task_assay_cd),trim(dta_mnemonic)), line3 = concat(trim(line3),trim(dta_descr),
    trim(act_type_meaning),trim(serv_code_set),trim(serv_cd_disp)), line3 = concat(trim(line3),trim(
     species_code_set),trim(species_cd_disp)),
   line3 = concat(trim(line3),trim(equation_id),trim(age_unit_codeset),trim(age_from_units_disp)),
   line3 = concat(trim(line3),trim(age_from_minutes),trim(age_to_units_disp),trim(age_to_minutes)),
   line3 = concat(trim(line3),trim(sex_code_set),trim(sex_code_disp)),
   line3 = concat(trim(line3),trim(equation_desc),trim(default_ind),trim(script)), line3 = concat(
    trim(line3),trim(gestational_age_ind),trim(equation_postfix)), line3 = concat(trim(line3),trim(
     unknown_age_ind),trim(age_ind)),
   line3 = concat(trim(line3),trim(component_flag),trim(constant_value)), line3 = concat(trim(line3),
    trim(cross_drawn_dt_tm_ind)), line3 = concat(trim(line3),trim(comp_mnemonic),trim(comp_desc),trim
    (comp_act_type_meaning)),
   line3 = concat(trim(line3),trim(name),trim(octal_value)), line3 = concat(trim(line3),trim(race_ind
     ),trim(result_req_flag)), line3 = concat(trim(line3),trim(result_status_cs),trim(
     result_status_disp)),
   line3 = concat(trim(line3),trim(sequence),trim(sex_ind)), line3 = concat(trim(line3),trim(
     variable_prompt),trim(time_window_minutes)), line3 = concat(trim(line3),trim(
     time_window_back_minutes),trim(units_code_set)),
   line3 = concat(trim(line3),trim(units_cd_disp)), row + 1, line3
  WITH maxcol = 1000, maxrow = 600, outerjoin = d1,
   nocounter
 ;end select
 SUBROUTINE checkandadddta(task_assay_cd)
   SET sub_status = 0
   SET v = 1
   FOR (v = 1 TO internal->all_dta_cnt)
     IF ((internal->dta_qual[v].task_assay_cd=task_assay_cd))
      SET sub_status = 1
      SET v = internal->all_dta_cnt
     ENDIF
   ENDFOR
   IF (sub_status=0)
    SET internal->all_dta_cnt = (internal->all_dta_cnt+ 1)
    IF ((internal->all_dta_cnt > size(internal->dta_qual,5)))
     SET stat = alterlist(internal->dta_qual,(internal->all_dta_cnt+ 1))
    ENDIF
    SET internal->dta_qual[internal->all_dta_cnt].task_assay_cd = task_assay_cd
   ENDIF
 END ;Subroutine
#exit_program
END GO
