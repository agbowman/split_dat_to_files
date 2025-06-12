CREATE PROGRAM cdi_export_forms:dba
 RECORD reply(
   1 form_xml = gvc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cdi_form_ids(
   1 cdi_form[*]
     2 cdi_form_id = f8
 )
 RECORD cdi_forms(
   1 cdi_form[*]
     2 source_form_ident = vc
     2 form_name = vc
     2 event_code_set = i4
     2 event_code_display = vc
     2 event_code_alias = vc
     2 cdi_form_field[*]
       3 field_name = vc
       3 field_type_flag = i2
       3 page_nbr = i4
       3 last_page_nbr = i4
       3 x_coord = i4
       3 y_coord = i4
       3 field_width = i4
       3 field_height = i4
       3 value_format_text = vc
       3 parent_field_name = vc
       3 field_description = vc
       3 form_completion_flag = i2
       3 required_ind = i2
       3 linked_variables[*]
         4 linked_variable_display = vc
         4 linked_value_display = vc
         4 linked_value_nbr = f8
         4 linked_value_text = vc
         4 field_status_flag = i2
       3 font_family_flag = i2
       3 font_size_nbr = i4
       3 text_color_nbr = i4
       3 field_rotation_value = f8
     2 cdi_form_rule[*]
       3 rule_name = vc
       3 required_ind = i2
       3 cdi_form_criteria[*]
         4 comparison_flag = i2
         4 variable_code_display = vc
         4 value_code_set = i4
         4 value_code_display = vc
         4 value_dt_tm = dq8
         4 value_nbr = i4
         4 value_text = vc
     2 facilities[*]
       3 facility_display_name = vc
     2 form_description = vc
     2 signature_page_ind = i2
     2 page_cnt = i4
     2 auto_print_ind = i2
     2 media_object_ident = vc
     2 procedural_form_ind = i2
 )
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
 DECLARE form_idx = i4 WITH noconstant(0)
 DECLARE field_cnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE req_size = i4 WITH noconstant(0)
 DECLARE form_count = i4 WITH noconstant(0)
 DECLARE fac_count = i4 WITH noconstant(0)
 DECLARE fields_flag = i2 WITH noconstant(false)
 DECLARE facility_name = vc WITH noconstant("")
 DECLARE variable_cnt = i4 WITH noconstant(0)
 SET req_size = size(request->forms,5)
 SELECT INTO "nl:"
  frm.cdi_form_id, frm.event_code_set, frm.event_cd,
  frm.cdi_document_subtype_id, frm.form_name, frm.source_form_ident,
  frm.signature_page_ind, frm.page_cnt, frm.auto_print_ind,
  frm.procedural_form_ind, fld.cdi_form_field_id, fld.page_nbr,
  fld.field_type_flag, fld.x_coord, fld.y_coord,
  fld.field_width, fld.field_height, fld.value_format_text,
  fld.parent_form_field_id, fld.field_name, fld.last_page_nbr,
  fld.field_description, fld.form_completion_flag, frm.form_description,
  fld.linked_variable_cd, fld.linked_value_cd, fld.linked_value_nbr,
  fld.linked_value_text, fld.required_ind, fld.font_family_flag,
  fld.font_size_nbr, fld.text_color_nbr, fld.field_rotation_value,
  ffvr.cdi_form_field_var_reltn_id, ffvr.cdi_form_field_id, ffvr.linked_variable_cd,
  ffvr.linked_value_nbr, ffvr.linked_value_text, ffvr.linked_value_cd,
  ffvr.field_status_flag
  FROM cdi_form frm,
   cdi_form_facility_reltn ffr,
   cdi_form_field fld,
   cdi_form_field pfld,
   cdi_document_subtype dst,
   cdi_form_field_var_reltn ffvr
  PLAN (frm
   WHERE frm.cdi_form_id > 0
    AND frm.active_ind=1
    AND expand(idx,1,req_size,frm.cdi_form_id,request->forms[idx].cdi_form_id)
    AND frm.logical_domain_id=current_logical_domain_id)
   JOIN (ffr
   WHERE (ffr.cdi_form_id= Outerjoin(frm.cdi_form_id)) )
   JOIN (fld
   WHERE (fld.cdi_form_id= Outerjoin(frm.cdi_form_id)) )
   JOIN (pfld
   WHERE (pfld.cdi_form_field_id= Outerjoin(fld.parent_form_field_id)) )
   JOIN (dst
   WHERE (dst.cdi_document_subtype_id= Outerjoin(frm.cdi_document_subtype_id)) )
   JOIN (ffvr
   WHERE (ffvr.cdi_form_field_id= Outerjoin(fld.cdi_form_field_id)) )
  ORDER BY frm.cdi_form_id, ffr.facility_cd, fld.page_nbr,
   fld.y_coord, fld.x_coord, fld.cdi_form_field_id
  HEAD REPORT
   form_idx = 0
  HEAD frm.cdi_form_id
   field_cnt = 0, fac_count = 0, fields_flag = false,
   form_idx += 1
   IF (mod(form_idx,10)=1)
    stat = alterlist(cdi_forms->cdi_form,(form_idx+ 9)), stat = alterlist(cdi_form_ids->cdi_form,(
     form_idx+ 9))
   ENDIF
   cdi_form_ids->cdi_form[form_idx].cdi_form_id = frm.cdi_form_id, cdi_forms->cdi_form[form_idx].
   source_form_ident = frm.source_form_ident, cdi_forms->cdi_form[form_idx].form_name = frm.form_name,
   cdi_forms->cdi_form[form_idx].form_description = frm.form_description, cdi_forms->cdi_form[
   form_idx].event_code_set = frm.event_code_set, cdi_forms->cdi_form[form_idx].event_code_display =
   uar_get_code_display(frm.event_cd),
   cdi_forms->cdi_form[form_idx].event_code_alias = dst.document_type_alias, cdi_forms->cdi_form[
   form_idx].signature_page_ind = frm.signature_page_ind, cdi_forms->cdi_form[form_idx].page_cnt =
   frm.page_cnt,
   cdi_forms->cdi_form[form_idx].auto_print_ind = frm.auto_print_ind, cdi_forms->cdi_form[form_idx].
   procedural_form_ind = frm.procedural_form_ind, stat = alterlist(cdi_forms->cdi_form[form_idx].
    cdi_form_field,1),
   stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_rule,1), stat = alterlist(cdi_forms->
    cdi_form[form_idx].cdi_form_rule[1].cdi_form_criteria,1)
  HEAD ffr.facility_cd
   facility_name = trim(uar_get_code_display(ffr.facility_cd))
   IF (size(facility_name) > 0)
    fac_count += 1
    IF (mod(fac_count,10)=1)
     stat = alterlist(cdi_forms->cdi_form[form_idx].facilities,(fac_count+ 9))
    ENDIF
    cdi_forms->cdi_form[form_idx].facilities[fac_count].facility_display_name = facility_name
   ENDIF
  HEAD fld.cdi_form_field_id
   IF (fields_flag=false)
    field_cnt += 1
    IF (mod(field_cnt,10)=1)
     stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_field,(field_cnt+ 9))
    ENDIF
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].field_name = fld.field_name, cdi_forms->
    cdi_form[form_idx].cdi_form_field[field_cnt].field_type_flag = fld.field_type_flag, cdi_forms->
    cdi_form[form_idx].cdi_form_field[field_cnt].page_nbr = fld.page_nbr,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].last_page_nbr = fld.last_page_nbr,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].x_coord = fld.x_coord, cdi_forms->
    cdi_form[form_idx].cdi_form_field[field_cnt].y_coord = fld.y_coord,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].field_width = fld.field_width, cdi_forms
    ->cdi_form[form_idx].cdi_form_field[field_cnt].field_height = fld.field_height, cdi_forms->
    cdi_form[form_idx].cdi_form_field[field_cnt].value_format_text = fld.value_format_text,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].parent_field_name = pfld.field_name,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].field_description = fld.field_description,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].form_completion_flag = fld
    .form_completion_flag,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].required_ind = fld.required_ind,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].font_family_flag = fld.font_family_flag,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].font_size_nbr = fld.font_size_nbr,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].text_color_nbr = fld.text_color_nbr,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].field_rotation_value = fld
    .field_rotation_value, variable_cnt = 0
    IF (fld.linked_variable_cd != 0.0)
     variable_cnt += 1
     IF (mod(variable_cnt,10)=1)
      stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].linked_variables,(
       variable_cnt+ 9))
     ENDIF
     cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].linked_variables[variable_cnt].
     linked_variable_display = uar_get_code_display(fld.linked_variable_cd), cdi_forms->cdi_form[
     form_idx].cdi_form_field[field_cnt].linked_variables[variable_cnt].linked_value_display =
     uar_get_code_display(fld.linked_value_cd), cdi_forms->cdi_form[form_idx].cdi_form_field[
     field_cnt].linked_variables[variable_cnt].linked_value_nbr = fld.linked_value_nbr,
     cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].linked_variables[variable_cnt].
     linked_value_text = fld.linked_value_text, cdi_forms->cdi_form[form_idx].cdi_form_field[
     field_cnt].linked_variables[variable_cnt].field_status_flag = 1
    ENDIF
   ENDIF
  DETAIL
   IF (ffvr.cdi_form_field_var_reltn_id != 0.0
    AND fields_flag=false)
    variable_cnt += 1
    IF (mod(variable_cnt,10)=1)
     stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].linked_variables,(
      variable_cnt+ 9))
    ENDIF
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].linked_variables[variable_cnt].
    linked_variable_display = uar_get_code_display(ffvr.linked_variable_cd), cdi_forms->cdi_form[
    form_idx].cdi_form_field[field_cnt].linked_variables[variable_cnt].linked_value_display =
    uar_get_code_display(ffvr.linked_value_cd), cdi_forms->cdi_form[form_idx].cdi_form_field[
    field_cnt].linked_variables[variable_cnt].linked_value_nbr = ffvr.linked_value_nbr,
    cdi_forms->cdi_form[form_idx].cdi_form_field[field_cnt].linked_variables[variable_cnt].
    linked_value_text = ffvr.linked_value_text, cdi_forms->cdi_form[form_idx].cdi_form_field[
    field_cnt].linked_variables[variable_cnt].field_status_flag = ffvr.field_status_flag
   ENDIF
  FOOT  ffr.facility_cd
   fields_flag = true
  FOOT  frm.cdi_form_id
   stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_field,field_cnt)
   IF (fac_count=0)
    fac_count = 1
   ENDIF
   stat = alterlist(cdi_forms->cdi_form[form_idx].facilities,fac_count)
  FOOT REPORT
   stat = alterlist(cdi_forms->cdi_form,form_idx)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET form_count = form_idx
 SELECT INTO "nl:"
  r.cdi_form_rule_id, r.rule_name, r.required_ind,
  c.cdi_form_criteria_id, c.variable_cd, c.comparison_flag,
  c.value_cd, c.value_nbr, c.value_dt_tm,
  c.value_text, cv.code_set, cv.display
  FROM cdi_form_rule r,
   cdi_form_criteria c,
   code_value cv
  PLAN (r
   WHERE r.cdi_form_id > 0
    AND expand(idx,1,req_size,r.cdi_form_id,request->forms[idx].cdi_form_id))
   JOIN (c
   WHERE (c.cdi_form_rule_id= Outerjoin(r.cdi_form_rule_id)) )
   JOIN (cv
   WHERE (cv.code_value= Outerjoin(c.value_cd)) )
  ORDER BY r.cdi_form_id, r.cdi_form_rule_id, c.cdi_form_criteria_id
  HEAD REPORT
   form_idx = 0
  HEAD r.cdi_form_id
   rule_cnt = 0, form_idx = locateval(idx,1,form_count,r.cdi_form_id,cdi_form_ids->cdi_form[idx].
    cdi_form_id)
  HEAD r.cdi_form_rule_id
   criteria_cnt = 0
   IF (form_idx > 0)
    rule_cnt += 1
    IF (mod(rule_cnt,10)=1)
     stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_rule,(rule_cnt+ 9))
    ENDIF
    cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].rule_name = r.rule_name, cdi_forms->
    cdi_form[form_idx].cdi_form_rule[rule_cnt].required_ind = r.required_ind
   ENDIF
  DETAIL
   IF (form_idx > 0)
    criteria_cnt += 1
    IF (mod(criteria_cnt,10)=1)
     stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].cdi_form_criteria,(
      criteria_cnt+ 9))
    ENDIF
    cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].cdi_form_criteria[criteria_cnt].
    comparison_flag = c.comparison_flag, cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].
    cdi_form_criteria[criteria_cnt].variable_code_display = uar_get_code_display(c.variable_cd),
    cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].cdi_form_criteria[criteria_cnt].
    value_code_set = cv.code_set,
    cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].cdi_form_criteria[criteria_cnt].
    value_code_display = cv.display, cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].
    cdi_form_criteria[criteria_cnt].value_nbr = c.value_nbr, cdi_forms->cdi_form[form_idx].
    cdi_form_rule[rule_cnt].cdi_form_criteria[criteria_cnt].value_dt_tm = c.value_dt_tm,
    cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].cdi_form_criteria[criteria_cnt].value_text
     = c.value_text
   ENDIF
  FOOT  r.cdi_form_rule_id
   stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_rule[rule_cnt].cdi_form_criteria,
    criteria_cnt)
  FOOT  r.cdi_form_id
   stat = alterlist(cdi_forms->cdi_form[form_idx].cdi_form_rule,rule_cnt)
 ;end select
 SET reply->form_xml = cnvtrectoxml(cdi_forms)
#exit_script
END GO
