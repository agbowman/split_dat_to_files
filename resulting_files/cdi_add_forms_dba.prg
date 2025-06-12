CREATE PROGRAM cdi_add_forms:dba
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 forms[*]
      2 cdi_form_id = f8
      2 source_form_ident = vc
      2 fields[*]
        3 cdi_form_field_id = f8
        3 page_nbr = i4
        3 x_coord = i4
        3 y_coord = i4
        3 field_name = vc
      2 facilities[*]
        3 facility_cd = f8
        3 cdi_form_facility_reltn_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE inserted_rows = i4 WITH noconstant(0), protect
 DECLARE field_cnt = i4 WITH noconstant(0)
 DECLARE form_field_cnt = i4 WITH noconstant(0), protect
 DECLARE rep_idx = i4 WITH noconstant(0)
 DECLARE parent_field_id = f8 WITH noconstant(0.0), protect
 DECLARE facility_cnt = i4 WITH noconstant(0), protect
 DECLARE total_facility_cnt = i4 WITH noconstant(0), protect
 DECLARE added_facility_cnt = i4 WITH noconstant(0), protect
 DECLARE reply_form_cnt = i4 WITH noconstant(0), protect
 DECLARE variable_cnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_add_forms"
 SET req_size = value(size(request->forms,5))
 DECLARE current_logical_domain_id = f8 WITH noconstant(0.0), protect
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 RECORD acm_get_curr_logical_domain_req(
   1 concept = i4
 )
 RECORD acm_get_curr_logical_domain_rep(
   1 logical_domain_id = f8
   1 status_block
     2 status_ind = i2
     2 error_code = i4
 )
 SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
 EXECUTE acm_get_curr_logical_domain
 SET current_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 IF (req_size > 0)
  RECORD temp_forms(
    1 forms[*]
      2 cdi_form_id = f8
  )
  RECORD temp_facilities(
    1 facilities[*]
      2 form_id = f8
      2 facility_cd = f8
      2 cdi_form_facility_reltn_id = f8
  )
  RECORD temp_fields(
    1 fields[*]
      2 cdi_form_field_id = f8
      2 cdi_form_id = f8
      2 field_name = vc
      2 page_nbr = i4
      2 field_type_flag = i2
      2 x_coord = i4
      2 y_coord = i4
      2 field_width = i4
      2 field_height = i4
      2 value_format_text = vc
      2 field_description = vc
      2 parent_form_field_id = f8
      2 last_page_nbr = i4
      2 form_completion_flag = i2
      2 linked_variable_cd = f8
      2 linked_value_cd = f8
      2 linked_value_nbr = i4
      2 linked_value_text = vc
      2 required_ind = i2
      2 font_family_flag = i2
      2 font_size_nbr = i4
      2 text_color_nbr = i4
      2 field_rotation_value = f8
  )
  RECORD temp_var_reltn(
    1 vars[*]
      2 cdi_form_field_id = f8
      2 linked_variable_cd = f8
      2 linked_value_cd = f8
      2 linked_value_nbr = f8
      2 linked_value_text = vc
      2 field_status_flag = i2
  )
  SET stat = alterlist(reply->forms,req_size)
  SET stat = alterlist(temp_forms->forms,req_size)
  EXECUTE dm2_dar_get_bulk_seq "temp_forms->forms", req_size, "cdi_form_id",
  1, "CDI_SEQ"
  FOR (i = 1 TO req_size)
    SET reply->forms[i].cdi_form_id = temp_forms->forms[i].cdi_form_id
  ENDFOR
  FOR (i = 1 TO req_size)
    SET facility_cnt = size(request->forms[i].facilities,5)
    SET stat = alterlist(temp_facilities->facilities,(total_facility_cnt+ facility_cnt))
    SET added_facility_cnt = 0
    FOR (j = 1 TO facility_cnt)
      IF ((request->forms[i].facilities[j].facility_cd > 0.0)
       AND (temp_forms->forms[i].cdi_form_id > 0.0))
       SET added_facility_cnt += 1
       SET temp_facilities->facilities[(total_facility_cnt+ added_facility_cnt)].form_id = temp_forms
       ->forms[i].cdi_form_id
       SET temp_facilities->facilities[(total_facility_cnt+ added_facility_cnt)].facility_cd =
       request->forms[i].facilities[j].facility_cd
      ENDIF
    ENDFOR
    SET total_facility_cnt += added_facility_cnt
  ENDFOR
  IF (total_facility_cnt > 0)
   SET stat = alterlist(temp_facilities->facilities,total_facility_cnt)
   EXECUTE dm2_dar_get_bulk_seq "temp_facilities->facilities", total_facility_cnt,
   "cdi_form_facility_reltn_id",
   1, "CDI_SEQ"
  ENDIF
  FOR (i = 1 TO req_size)
    SET form_field_cnt = size(request->forms[i].fields,5)
    FOR (j = 1 TO size(request->forms[i].fields,5))
      SET form_field_cnt += size(request->forms[i].fields[j].linked_fields,5)
      SET variable_cnt += size(request->forms[i].fields[j].linked_variables,5)
      FOR (k = 1 TO size(request->forms[i].fields[j].linked_fields,5))
        SET variable_cnt += size(request->forms[i].fields[j].linked_fields[k].linked_variables,5)
      ENDFOR
    ENDFOR
    SET stat = alterlist(reply->forms[i].fields,form_field_cnt)
    SET field_cnt += form_field_cnt
  ENDFOR
  SET stat = alterlist(temp_fields->fields,field_cnt)
  IF (field_cnt > 0)
   EXECUTE dm2_dar_get_bulk_seq "temp_fields->fields", field_cnt, "cdi_form_field_id",
   1, "CDI_SEQ"
  ENDIF
  SET stat = alterlist(temp_var_reltn->vars,variable_cnt)
  SET variable_cnt = 0
  SET field_cnt = 0
  FOR (i = 1 TO req_size)
    SET reply->forms[i].source_form_ident = request->forms[i].source_form_ident
    SET rep_idx = 0
    FOR (j = 1 TO size(request->forms[i].fields,5))
      SET field_cnt += 1
      SET parent_field_id = temp_fields->fields[field_cnt].cdi_form_field_id
      SET temp_fields->fields[field_cnt].cdi_form_id = reply->forms[i].cdi_form_id
      IF (size(trim(request->forms[i].fields[j].field_name)) < 1)
       SET temp_fields->fields[field_cnt].field_name = build(format(cnvtdatetime(sysdate),";;Q"),"_",
        field_cnt)
      ELSE
       SET temp_fields->fields[field_cnt].field_name = request->forms[i].fields[j].field_name
      ENDIF
      SET temp_fields->fields[field_cnt].field_height = request->forms[i].fields[j].field_height
      SET temp_fields->fields[field_cnt].field_type_flag = request->forms[i].fields[j].
      field_type_flag
      SET temp_fields->fields[field_cnt].field_width = request->forms[i].fields[j].field_width
      SET temp_fields->fields[field_cnt].page_nbr = request->forms[i].fields[j].page_nbr
      SET temp_fields->fields[field_cnt].x_coord = request->forms[i].fields[j].x_coord
      SET temp_fields->fields[field_cnt].y_coord = request->forms[i].fields[j].y_coord
      SET temp_fields->fields[field_cnt].value_format_text = request->forms[i].fields[j].
      value_format_text
      SET temp_fields->fields[field_cnt].parent_form_field_id = 0.0
      SET temp_fields->fields[field_cnt].last_page_nbr = request->forms[i].fields[j].last_page_nbr
      SET temp_fields->fields[field_cnt].field_description = request->forms[i].fields[j].
      field_description
      SET temp_fields->fields[field_cnt].form_completion_flag = request->forms[i].fields[j].
      form_completion_flag
      SET temp_fields->fields[field_cnt].linked_variable_cd = request->forms[i].fields[j].
      linked_variable_cd
      SET temp_fields->fields[field_cnt].linked_value_cd = request->forms[i].fields[j].
      linked_value_cd
      SET temp_fields->fields[field_cnt].linked_value_nbr = request->forms[i].fields[j].
      linked_value_nbr
      SET temp_fields->fields[field_cnt].linked_value_text = request->forms[i].fields[j].
      linked_value_text
      SET temp_fields->fields[field_cnt].required_ind = request->forms[i].fields[j].required_ind
      SET temp_fields->fields[field_cnt].font_family_flag = request->forms[i].fields[j].
      font_family_flag
      SET temp_fields->fields[field_cnt].font_size_nbr = request->forms[i].fields[j].font_size_nbr
      SET temp_fields->fields[field_cnt].text_color_nbr = request->forms[i].fields[j].text_color_nbr
      SET temp_fields->fields[field_cnt].field_rotation_value = request->forms[i].fields[j].
      field_rotation_value
      FOR (k = 1 TO size(request->forms[i].fields[j].linked_variables,5))
        SET variable_cnt += 1
        SET temp_var_reltn->vars[variable_cnt].cdi_form_field_id = temp_fields->fields[field_cnt].
        cdi_form_field_id
        SET temp_var_reltn->vars[variable_cnt].field_status_flag = request->forms[i].fields[j].
        linked_variables[k].field_status_flag
        SET temp_var_reltn->vars[variable_cnt].linked_variable_cd = request->forms[i].fields[j].
        linked_variables[k].linked_variable_cd
        SET temp_var_reltn->vars[variable_cnt].linked_value_cd = request->forms[i].fields[j].
        linked_variables[k].linked_value_cd
        SET temp_var_reltn->vars[variable_cnt].linked_value_nbr = request->forms[i].fields[j].
        linked_variables[k].linked_value_nbr
        SET temp_var_reltn->vars[variable_cnt].linked_value_text = request->forms[i].fields[j].
        linked_variables[k].linked_value_text
        SET temp_var_reltn->vars[variable_cnt].field_status_flag = request->forms[i].fields[j].
        linked_variables[k].field_status_flag
      ENDFOR
      SET rep_idx += 1
      SET reply->forms[i].fields[rep_idx].cdi_form_field_id = temp_fields->fields[field_cnt].
      cdi_form_field_id
      SET reply->forms[i].fields[rep_idx].page_nbr = request->forms[i].fields[j].page_nbr
      SET reply->forms[i].fields[rep_idx].x_coord = request->forms[i].fields[j].x_coord
      SET reply->forms[i].fields[rep_idx].y_coord = request->forms[i].fields[j].y_coord
      SET reply->forms[i].fields[rep_idx].field_name = temp_fields->fields[field_cnt].field_name
      FOR (k = 1 TO size(request->forms[i].fields[j].linked_fields,5))
        SET field_cnt += 1
        SET temp_fields->fields[field_cnt].cdi_form_id = reply->forms[i].cdi_form_id
        IF (size(trim(request->forms[i].fields[j].linked_fields[k].field_name)) < 1)
         SET temp_fields->fields[field_cnt].field_name = build(format(cnvtdatetime(sysdate),";;Q"),
          "_",field_cnt)
        ELSE
         SET temp_fields->fields[field_cnt].field_name = request->forms[i].fields[j].linked_fields[k]
         .field_name
        ENDIF
        SET temp_fields->fields[field_cnt].field_height = request->forms[i].fields[j].linked_fields[k
        ].field_height
        SET temp_fields->fields[field_cnt].field_type_flag = request->forms[i].fields[j].
        linked_fields[k].field_type_flag
        SET temp_fields->fields[field_cnt].field_width = request->forms[i].fields[j].linked_fields[k]
        .field_width
        SET temp_fields->fields[field_cnt].page_nbr = request->forms[i].fields[j].page_nbr
        SET temp_fields->fields[field_cnt].last_page_nbr = request->forms[i].fields[j].last_page_nbr
        SET temp_fields->fields[field_cnt].x_coord = request->forms[i].fields[j].linked_fields[k].
        x_coord
        SET temp_fields->fields[field_cnt].y_coord = request->forms[i].fields[j].linked_fields[k].
        y_coord
        SET temp_fields->fields[field_cnt].value_format_text = request->forms[i].fields[j].
        linked_fields[k].value_format_text
        SET temp_fields->fields[field_cnt].field_description = request->forms[i].fields[j].
        linked_fields[k].field_description
        SET temp_fields->fields[field_cnt].parent_form_field_id = parent_field_id
        SET temp_fields->fields[field_cnt].form_completion_flag = request->forms[i].fields[j].
        linked_fields[k].form_completion_flag
        SET temp_fields->fields[field_cnt].linked_variable_cd = request->forms[i].fields[j].
        linked_fields[k].linked_variable_cd
        SET temp_fields->fields[field_cnt].linked_value_cd = request->forms[i].fields[j].
        linked_fields[k].linked_value_cd
        SET temp_fields->fields[field_cnt].linked_value_nbr = request->forms[i].fields[j].
        linked_fields[k].linked_value_nbr
        SET temp_fields->fields[field_cnt].linked_value_text = request->forms[i].fields[j].
        linked_fields[k].linked_value_text
        SET temp_fields->fields[field_cnt].required_ind = request->forms[i].fields[j].linked_fields[k
        ].required_ind
        SET temp_fields->fields[field_cnt].font_family_flag = request->forms[i].fields[j].
        linked_fields[k].font_family_flag
        SET temp_fields->fields[field_cnt].font_size_nbr = request->forms[i].fields[j].linked_fields[
        k].font_size_nbr
        SET temp_fields->fields[field_cnt].text_color_nbr = request->forms[i].fields[j].
        linked_fields[k].text_color_nbr
        SET temp_fields->fields[field_cnt].field_rotation_value = request->forms[i].fields[j].
        linked_fields[k].field_rotation_value
        FOR (v = 1 TO size(request->forms[i].fields[j].linked_fields[k].linked_variables,5))
          SET variable_cnt += 1
          SET temp_var_reltn->vars[variable_cnt].cdi_form_field_id = temp_fields->fields[field_cnt].
          cdi_form_field_id
          SET temp_var_reltn->vars[variable_cnt].field_status_flag = request->forms[i].fields[j].
          linked_fields[k].linked_variables[v].field_status_flag
          SET temp_var_reltn->vars[variable_cnt].linked_variable_cd = request->forms[i].fields[j].
          linked_fields[k].linked_variables[v].linked_variable_cd
          SET temp_var_reltn->vars[variable_cnt].linked_value_cd = request->forms[i].fields[j].
          linked_fields[k].linked_variables[v].linked_value_cd
          SET temp_var_reltn->vars[variable_cnt].linked_value_nbr = request->forms[i].fields[j].
          linked_fields[k].linked_variables[v].linked_value_nbr
          SET temp_var_reltn->vars[variable_cnt].linked_value_text = request->forms[i].fields[j].
          linked_fields[k].linked_variables[v].linked_value_text
          SET temp_var_reltn->vars[variable_cnt].field_status_flag = request->forms[i].fields[j].
          linked_fields[k].linked_variables[v].field_status_flag
        ENDFOR
        SET rep_idx += 1
        SET reply->forms[i].fields[rep_idx].cdi_form_field_id = temp_fields->fields[field_cnt].
        cdi_form_field_id
        SET reply->forms[i].fields[rep_idx].page_nbr = request->forms[i].fields[j].linked_fields[k].
        page_nbr
        SET reply->forms[i].fields[rep_idx].x_coord = request->forms[i].fields[j].linked_fields[k].
        x_coord
        SET reply->forms[i].fields[rep_idx].y_coord = request->forms[i].fields[j].linked_fields[k].
        y_coord
        SET reply->forms[i].fields[rep_idx].field_name = temp_fields->fields[field_cnt].field_name
      ENDFOR
    ENDFOR
  ENDFOR
  INSERT  FROM cdi_form f,
    (dummyt d  WITH seq = req_size)
   SET f.cdi_form_id = reply->forms[d.seq].cdi_form_id, f.form_name = request->forms[d.seq].form_name,
    f.event_cd = request->forms[d.seq].event_cd,
    f.event_code_set = request->forms[d.seq].event_code_set, f.cdi_document_subtype_id = request->
    forms[d.seq].cdi_document_subtype_id, f.source_form_ident = request->forms[d.seq].
    source_form_ident,
    f.signature_page_ind = request->forms[d.seq].signature_page_ind, f.logical_domain_id =
    current_logical_domain_id, f.updt_cnt = 0,
    f.updt_dt_tm = cnvtdatetime(sysdate), f.updt_task = reqinfo->updt_task, f.updt_id = reqinfo->
    updt_id,
    f.updt_applctx = reqinfo->updt_applctx, f.active_ind = 1, f.form_description = request->forms[d
    .seq].form_description,
    f.page_cnt = request->forms[d.seq].page_cnt, f.media_object_ident = request->forms[d.seq].
    media_object_ident, f.auto_print_ind = request->forms[d.seq].auto_print_ind,
    f.procedural_form_ind = request->forms[d.seq].procedural_form_ind
   PLAN (d)
    JOIN (f)
   WITH nocounter
  ;end insert
  SET inserted_rows = curqual
  IF (inserted_rows < req_size)
   SET ecode = 0
   SET emsg = fillstring(200," ")
   SET ecode = error(emsg,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   GO TO exit_script
  ENDIF
  IF (field_cnt > 0)
   INSERT  FROM cdi_form_field f,
     (dummyt d  WITH seq = field_cnt)
    SET f.cdi_form_id = temp_fields->fields[d.seq].cdi_form_id, f.cdi_form_field_id = temp_fields->
     fields[d.seq].cdi_form_field_id, f.field_name = temp_fields->fields[d.seq].field_name,
     f.field_height = temp_fields->fields[d.seq].field_height, f.field_width = temp_fields->fields[d
     .seq].field_width, f.field_type_flag = temp_fields->fields[d.seq].field_type_flag,
     f.page_nbr = temp_fields->fields[d.seq].page_nbr, f.last_page_nbr = temp_fields->fields[d.seq].
     last_page_nbr, f.x_coord = temp_fields->fields[d.seq].x_coord,
     f.y_coord = temp_fields->fields[d.seq].y_coord, f.value_format_text = temp_fields->fields[d.seq]
     .value_format_text, f.field_description = temp_fields->fields[d.seq].field_description,
     f.form_completion_flag = temp_fields->fields[d.seq].form_completion_flag, f.parent_form_field_id
      = temp_fields->fields[d.seq].parent_form_field_id, f.linked_variable_cd = temp_fields->fields[d
     .seq].linked_variable_cd,
     f.linked_value_cd = temp_fields->fields[d.seq].linked_value_cd, f.linked_value_nbr = temp_fields
     ->fields[d.seq].linked_value_nbr, f.linked_value_text = temp_fields->fields[d.seq].
     linked_value_text,
     f.required_ind = temp_fields->fields[d.seq].required_ind, f.font_family_flag = temp_fields->
     fields[d.seq].font_family_flag, f.font_size_nbr = temp_fields->fields[d.seq].font_size_nbr,
     f.text_color_nbr = temp_fields->fields[d.seq].text_color_nbr, f.field_rotation_value =
     temp_fields->fields[d.seq].field_rotation_value, f.updt_cnt = 0,
     f.updt_dt_tm = cnvtdatetime(sysdate), f.updt_task = reqinfo->updt_task, f.updt_id = reqinfo->
     updt_id,
     f.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (f)
    WITH nocounter
   ;end insert
   SET inserted_rows = curqual
   IF (inserted_rows < field_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_FIELD"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (variable_cnt > 0)
   INSERT  FROM cdi_form_field_var_reltn ffvr,
     (dummyt d  WITH seq = variable_cnt)
    SET ffvr.cdi_form_field_var_reltn_id = seq(cdi_seq,nextval), ffvr.cdi_form_field_id =
     temp_var_reltn->vars[d.seq].cdi_form_field_id, ffvr.field_status_flag = temp_var_reltn->vars[d
     .seq].field_status_flag,
     ffvr.linked_variable_cd = temp_var_reltn->vars[d.seq].linked_variable_cd, ffvr.linked_value_cd
      = temp_var_reltn->vars[d.seq].linked_value_cd, ffvr.linked_value_nbr = temp_var_reltn->vars[d
     .seq].linked_value_nbr,
     ffvr.linked_value_text = temp_var_reltn->vars[d.seq].linked_value_text, ffvr.field_status_flag
      = temp_var_reltn->vars[d.seq].field_status_flag, ffvr.updt_cnt = 0,
     ffvr.updt_dt_tm = cnvtdatetime(sysdate), ffvr.updt_task = reqinfo->updt_task, ffvr.updt_id =
     reqinfo->updt_id,
     ffvr.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (ffvr)
    WITH nocounter
   ;end insert
   SET inserted_rows = curqual
   IF (inserted_rows < variable_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_FIELD_VAR_RELTN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (total_facility_cnt > 0)
   INSERT  FROM cdi_form_facility_reltn ffr,
     (dummyt d  WITH seq = total_facility_cnt)
    SET ffr.cdi_form_facility_reltn_id = temp_facilities->facilities[d.seq].
     cdi_form_facility_reltn_id, ffr.cdi_form_id = temp_facilities->facilities[d.seq].form_id, ffr
     .facility_cd = temp_facilities->facilities[d.seq].facility_cd,
     ffr.updt_cnt = 0, ffr.updt_dt_tm = cnvtdatetime(sysdate), ffr.updt_task = reqinfo->updt_task,
     ffr.updt_id = reqinfo->updt_id, ffr.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (ffr)
    WITH nocounter
   ;end insert
   SET inserted_rows = curqual
   IF (inserted_rows < total_facility_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_FACILITY_RELTN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
   SET reply_form_cnt = size(reply->forms,5)
   SET facility_cnt = size(temp_facilities->facilities,5)
   FOR (i = 1 TO reply_form_cnt)
     SET reply_facility_cnt = 0
     FOR (j = 1 TO facility_cnt)
       IF ((reply->forms[i].cdi_form_id=temp_facilities->facilities[j].form_id))
        SET reply_facility_cnt += 1
        IF (mod(reply_facility_cnt,10)=1)
         SET stat = alterlist(reply->forms[i].facilities,(reply_facility_cnt+ 9))
        ENDIF
        SET reply->forms[i].facilities[reply_facility_cnt].cdi_form_facility_reltn_id =
        temp_facilities->facilities[j].cdi_form_facility_reltn_id
        SET reply->forms[i].facilities[reply_facility_cnt].facility_cd = temp_facilities->facilities[
        j].facility_cd
       ENDIF
     ENDFOR
     SET stat = alterlist(reply->forms[i].facilities,reply_facility_cnt)
   ENDFOR
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
