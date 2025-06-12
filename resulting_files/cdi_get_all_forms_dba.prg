CREATE PROGRAM cdi_get_all_forms:dba
 RECORD reply(
   1 forms[*]
     2 cdi_form_id = f8
     2 event_cd = f8
     2 event_code_set = i4
     2 cdi_document_subtype_id = f8
     2 form_name = vc
     2 source_form_ident = vc
     2 doc_type_display = vc
     2 default_subject = vc
     2 fields[*]
       3 cdi_form_field_id = f8
       3 page_nbr = i4
       3 field_type_flag = i2
       3 x_coord = i4
       3 y_coord = i4
       3 field_width = i4
       3 field_height = i4
       3 value_format_text = vc
       3 parent_form_field_id = f8
       3 field_description = vc
       3 field_name = vc
       3 last_page_nbr = i4
       3 form_completion_flag = i2
       3 linked_variable_cd = f8
       3 linked_value_cd = f8
       3 linked_value_nbr = i4
       3 linked_value_text = vc
       3 required_ind = i2
       3 linked_variables[*]
         4 linked_variable_cd = f8
         4 linked_value_cd = f8
         4 linked_value_nbr = f8
         4 linked_value_text = vc
         4 field_status_flag = i2
       3 font_family_flag = i2
       3 font_size_nbr = i4
       3 text_color_nbr = i4
       3 field_rotation_value = f8
     2 facilities[*]
       3 facility_cd = f8
       3 cdi_form_facility_reltn_id = f8
     2 form_description = vc
     2 signature_page_ind = i2
     2 page_cnt = i4
     2 media_object_ident = vc
     2 auto_print_ind = i2
     2 procedural_form_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE form_cnt = i4 WITH noconstant(0)
 DECLARE field_cnt = i4 WITH noconstant(0)
 DECLARE facility_cnt = i4 WITH noconstant(0)
 DECLARE fields_flag = i2 WITH noconstant(false)
 DECLARE variable_cnt = i4 WITH noconstant(0)
 DECLARE default_font_size = i4 WITH noconstant(0)
 DECLARE req_formids = i4 WITH noconstant(value(size(request->forms,5))), protect
 DECLARE req_facilitycds = i4 WITH noconstant(value(size(request->facilities,5))), protect
 DECLARE n = i4 WITH noconstant(0), protect
 IF (((req_formids) OR ((request->omit_fields_ind=0))) )
  SELECT
   IF (req_formids > 0)
    PLAN (frm
     WHERE frm.cdi_form_id > 0
      AND frm.logical_domain_id=current_logical_domain_id
      AND expand(n,1,req_formids,frm.cdi_form_id,request->forms[n].cdi_form_id))
     JOIN (ffr
     WHERE (ffr.cdi_form_id= Outerjoin(frm.cdi_form_id)) )
     JOIN (fld
     WHERE (fld.cdi_form_id= Outerjoin(frm.cdi_form_id)) )
     JOIN (dst
     WHERE (dst.cdi_document_subtype_id= Outerjoin(frm.cdi_document_subtype_id)) )
     JOIN (ffvr
     WHERE (ffvr.cdi_form_field_id= Outerjoin(fld.cdi_form_field_id)) )
    ORDER BY frm.cdi_form_id, ffr.facility_cd, fld.page_nbr,
     fld.y_coord, fld.x_coord, fld.cdi_form_field_id
   ELSE
    PLAN (frm
     WHERE frm.cdi_form_id > 0
      AND frm.logical_domain_id=current_logical_domain_id
      AND frm.active_ind=1)
     JOIN (ffr
     WHERE (ffr.cdi_form_id= Outerjoin(frm.cdi_form_id)) )
     JOIN (fld
     WHERE (fld.cdi_form_id= Outerjoin(frm.cdi_form_id)) )
     JOIN (dst
     WHERE (dst.cdi_document_subtype_id= Outerjoin(frm.cdi_document_subtype_id)) )
     JOIN (ffvr
     WHERE (ffvr.cdi_form_field_id= Outerjoin(fld.cdi_form_field_id)) )
    ORDER BY frm.cdi_form_id, ffr.facility_cd, fld.page_nbr,
     fld.y_coord, fld.x_coord, fld.cdi_form_field_id
   ENDIF
   INTO "nl:"
   frm.cdi_form_id, frm.event_code_set, frm.event_cd,
   frm.cdi_document_subtype_id, frm.form_name, frm.source_form_ident,
   frm.signature_page_ind, frm.auto_print_ind, frm.procedural_form_ind,
   frm.page_cnt, frm.media_object_ident, fld.cdi_form_field_id,
   fld.page_nbr, fld.field_type_flag, fld.x_coord,
   fld.y_coord, fld.field_width, fld.field_height,
   fld.value_format_text, fld.field_description, fld.parent_form_field_id,
   fld.field_name, fld.last_page_nbr, fld.form_completion_flag,
   frm.form_description, fld.linked_variable_cd, fld.linked_value_cd,
   fld.linked_value_nbr, fld.linked_value_text, fld.required_ind,
   fld.font_family_flag, fld.font_size_nbr, fld.text_color_nbr,
   fld.field_rotation_value, ffvr.cdi_form_field_var_reltn_id, ffvr.cdi_form_field_id,
   ffvr.linked_variable_cd, ffvr.linked_value_nbr, ffvr.linked_value_text,
   ffvr.linked_value_cd, ffvr.field_status_flag, ffr.facility_cd
   FROM cdi_form frm,
    cdi_form_field fld,
    cdi_document_subtype dst,
    cdi_form_facility_reltn ffr,
    cdi_form_field_var_reltn ffvr
   HEAD REPORT
    form_cnt = 0
   HEAD frm.cdi_form_id
    field_cnt = 0, facility_cnt = 0, fields_flag = false,
    default_font_size = 12, form_cnt += 1
    IF (mod(form_cnt,10)=1)
     stat = alterlist(reply->forms,(form_cnt+ 9))
    ENDIF
    reply->forms[form_cnt].cdi_form_id = frm.cdi_form_id, reply->forms[form_cnt].event_cd = frm
    .event_cd, reply->forms[form_cnt].event_code_set = frm.event_code_set,
    reply->forms[form_cnt].cdi_document_subtype_id = frm.cdi_document_subtype_id, reply->forms[
    form_cnt].form_name = frm.form_name, reply->forms[form_cnt].form_description = frm
    .form_description,
    reply->forms[form_cnt].source_form_ident = frm.source_form_ident, reply->forms[form_cnt].
    doc_type_display = uar_get_code_display(frm.event_cd)
    IF (frm.cdi_document_subtype_id=0.0)
     reply->forms[form_cnt].default_subject = uar_get_code_display(frm.event_cd)
    ELSE
     IF (size(trim(dst.subject)) > 0)
      reply->forms[form_cnt].default_subject = dst.subject
     ELSE
      reply->forms[form_cnt].default_subject = uar_get_code_display(frm.event_cd)
     ENDIF
    ENDIF
    reply->forms[form_cnt].signature_page_ind = frm.signature_page_ind, reply->forms[form_cnt].
    auto_print_ind = frm.auto_print_ind, reply->forms[form_cnt].procedural_form_ind = frm
    .procedural_form_ind,
    reply->forms[form_cnt].page_cnt = frm.page_cnt, reply->forms[form_cnt].media_object_ident = frm
    .media_object_ident
   HEAD ffr.facility_cd
    IF (ffr.facility_cd > 0.0
     AND ffr.cdi_form_facility_reltn_id > 0.0)
     facility_cnt += 1
     IF (mod(facility_cnt,10)=1)
      stat = alterlist(reply->forms[form_cnt].facilities,(facility_cnt+ 9))
     ENDIF
     reply->forms[form_cnt].facilities[facility_cnt].facility_cd = ffr.facility_cd, reply->forms[
     form_cnt].facilities[facility_cnt].cdi_form_facility_reltn_id = ffr.cdi_form_facility_reltn_id
    ENDIF
   HEAD fld.cdi_form_field_id
    IF (fld.cdi_form_field_id != 0.0
     AND fields_flag=false)
     field_cnt += 1
     IF (mod(field_cnt,10)=1)
      stat = alterlist(reply->forms[form_cnt].fields,(field_cnt+ 9))
     ENDIF
     reply->forms[form_cnt].fields[field_cnt].cdi_form_field_id = fld.cdi_form_field_id, reply->
     forms[form_cnt].fields[field_cnt].field_height = fld.field_height, reply->forms[form_cnt].
     fields[field_cnt].field_type_flag = fld.field_type_flag,
     reply->forms[form_cnt].fields[field_cnt].field_width = fld.field_width, reply->forms[form_cnt].
     fields[field_cnt].page_nbr = fld.page_nbr, reply->forms[form_cnt].fields[field_cnt].x_coord =
     fld.x_coord,
     reply->forms[form_cnt].fields[field_cnt].y_coord = fld.y_coord, reply->forms[form_cnt].fields[
     field_cnt].value_format_text = fld.value_format_text, reply->forms[form_cnt].fields[field_cnt].
     field_description = fld.field_description,
     reply->forms[form_cnt].fields[field_cnt].parent_form_field_id = fld.parent_form_field_id, reply
     ->forms[form_cnt].fields[field_cnt].field_name = fld.field_name
     IF (fld.last_page_nbr=0)
      reply->forms[form_cnt].fields[field_cnt].last_page_nbr = fld.page_nbr
     ELSE
      reply->forms[form_cnt].fields[field_cnt].last_page_nbr = fld.last_page_nbr
     ENDIF
     reply->forms[form_cnt].fields[field_cnt].form_completion_flag = fld.form_completion_flag, reply
     ->forms[form_cnt].fields[field_cnt].linked_variable_cd = fld.linked_variable_cd, reply->forms[
     form_cnt].fields[field_cnt].linked_value_cd = fld.linked_value_cd,
     reply->forms[form_cnt].fields[field_cnt].linked_value_nbr = fld.linked_value_nbr, reply->forms[
     form_cnt].fields[field_cnt].linked_value_text = fld.linked_value_text, reply->forms[form_cnt].
     fields[field_cnt].required_ind = fld.required_ind,
     reply->forms[form_cnt].fields[field_cnt].font_family_flag = fld.font_family_flag
     IF (fld.font_size_nbr < 1)
      reply->forms[form_cnt].fields[field_cnt].font_size_nbr = default_font_size
     ELSE
      reply->forms[form_cnt].fields[field_cnt].font_size_nbr = fld.font_size_nbr
     ENDIF
     reply->forms[form_cnt].fields[field_cnt].text_color_nbr = fld.text_color_nbr, reply->forms[
     form_cnt].fields[field_cnt].field_rotation_value = fld.field_rotation_value, variable_cnt = 0
     IF (fld.linked_variable_cd != 0.0)
      variable_cnt += 1
      IF (mod(variable_cnt,10)=1)
       stat = alterlist(reply->forms[form_cnt].fields[field_cnt].linked_variables,(variable_cnt+ 9))
      ENDIF
      reply->forms[form_cnt].fields[field_cnt].linked_variables[variable_cnt].linked_variable_cd =
      fld.linked_variable_cd, reply->forms[form_cnt].fields[field_cnt].linked_variables[variable_cnt]
      .linked_value_cd = fld.linked_value_cd, reply->forms[form_cnt].fields[field_cnt].
      linked_variables[variable_cnt].linked_value_nbr = fld.linked_value_nbr,
      reply->forms[form_cnt].fields[field_cnt].linked_variables[variable_cnt].linked_value_text = fld
      .linked_value_text, reply->forms[form_cnt].fields[field_cnt].linked_variables[variable_cnt].
      field_status_flag = 1
     ENDIF
    ENDIF
   DETAIL
    IF (ffvr.cdi_form_field_var_reltn_id != 0.0
     AND fields_flag=false)
     variable_cnt += 1
     IF (mod(variable_cnt,10)=1)
      stat = alterlist(reply->forms[form_cnt].fields[field_cnt].linked_variables,(variable_cnt+ 9))
     ENDIF
     reply->forms[form_cnt].fields[field_cnt].linked_variables[variable_cnt].linked_variable_cd =
     ffvr.linked_variable_cd, reply->forms[form_cnt].fields[field_cnt].linked_variables[variable_cnt]
     .linked_value_cd = ffvr.linked_value_cd, reply->forms[form_cnt].fields[field_cnt].
     linked_variables[variable_cnt].linked_value_nbr = ffvr.linked_value_nbr,
     reply->forms[form_cnt].fields[field_cnt].linked_variables[variable_cnt].linked_value_text = ffvr
     .linked_value_text, reply->forms[form_cnt].fields[field_cnt].linked_variables[variable_cnt].
     field_status_flag = ffvr.field_status_flag
    ENDIF
   FOOT  fld.cdi_form_field_id
    IF (field_cnt > 0)
     stat = alterlist(reply->forms[form_cnt].fields[field_cnt].linked_variables,variable_cnt)
    ENDIF
   FOOT  frm.cdi_form_id
    stat = alterlist(reply->forms[form_cnt].fields,field_cnt), stat = alterlist(reply->forms[form_cnt
     ].facilities,facility_cnt)
   FOOT  ffr.facility_cd
    fields_flag = true
   FOOT REPORT
    stat = alterlist(reply->forms,form_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT
   IF (req_facilitycds > 0)
    PLAN (frm
     WHERE frm.cdi_form_id > 0
      AND frm.logical_domain_id=current_logical_domain_id
      AND frm.active_ind=1)
     JOIN (ffr
     WHERE (ffr.cdi_form_id= Outerjoin(frm.cdi_form_id))
      AND ((ffr.cdi_form_facility_reltn_id = null) OR (expand(n,1,req_facilitycds,ffr.facility_cd,
      request->facilities[n].facility_cd))) )
     JOIN (dst
     WHERE (dst.cdi_document_subtype_id= Outerjoin(frm.cdi_document_subtype_id)) )
    ORDER BY frm.cdi_form_id, ffr.facility_cd
   ELSE
    PLAN (frm
     WHERE frm.cdi_form_id > 0
      AND frm.logical_domain_id=current_logical_domain_id
      AND frm.active_ind=1)
     JOIN (ffr
     WHERE (ffr.cdi_form_id= Outerjoin(frm.cdi_form_id)) )
     JOIN (dst
     WHERE (dst.cdi_document_subtype_id= Outerjoin(frm.cdi_document_subtype_id)) )
    ORDER BY frm.cdi_form_id, ffr.facility_cd
   ENDIF
   INTO "nl:"
   frm.cdi_form_id, frm.event_code_set, frm.event_cd,
   frm.cdi_document_subtype_id, frm.form_name, frm.source_form_ident,
   frm.signature_page_ind, frm.auto_print_ind, frm.procedural_form_ind,
   frm.page_cnt, frm.media_object_ident, frm.form_description,
   ffr.facility_cd
   FROM cdi_form frm,
    cdi_document_subtype dst,
    cdi_form_facility_reltn ffr
   HEAD REPORT
    form_cnt = 0
   HEAD frm.cdi_form_id
    field_cnt = 0, facility_cnt = 0, fields_flag = false,
    default_font_size = 12, form_cnt += 1
    IF (mod(form_cnt,10)=1)
     stat = alterlist(reply->forms,(form_cnt+ 9))
    ENDIF
    reply->forms[form_cnt].cdi_form_id = frm.cdi_form_id, reply->forms[form_cnt].event_cd = frm
    .event_cd, reply->forms[form_cnt].event_code_set = frm.event_code_set,
    reply->forms[form_cnt].cdi_document_subtype_id = frm.cdi_document_subtype_id, reply->forms[
    form_cnt].form_name = frm.form_name, reply->forms[form_cnt].form_description = frm
    .form_description,
    reply->forms[form_cnt].source_form_ident = frm.source_form_ident, reply->forms[form_cnt].
    doc_type_display = uar_get_code_display(frm.event_cd)
    IF (frm.cdi_document_subtype_id=0.0)
     reply->forms[form_cnt].default_subject = uar_get_code_display(frm.event_cd)
    ELSE
     IF (size(trim(dst.subject)) > 0)
      reply->forms[form_cnt].default_subject = dst.subject
     ELSE
      reply->forms[form_cnt].default_subject = uar_get_code_display(frm.event_cd)
     ENDIF
    ENDIF
    reply->forms[form_cnt].signature_page_ind = frm.signature_page_ind, reply->forms[form_cnt].
    auto_print_ind = frm.auto_print_ind, reply->forms[form_cnt].procedural_form_ind = frm
    .procedural_form_ind,
    reply->forms[form_cnt].page_cnt = frm.page_cnt, reply->forms[form_cnt].media_object_ident = frm
    .media_object_ident
   DETAIL
    IF (ffr.facility_cd > 0.0
     AND ffr.cdi_form_facility_reltn_id > 0.0)
     facility_cnt += 1
     IF (mod(facility_cnt,10)=1)
      stat = alterlist(reply->forms[form_cnt].facilities,(facility_cnt+ 9))
     ENDIF
     reply->forms[form_cnt].facilities[facility_cnt].facility_cd = ffr.facility_cd, reply->forms[
     form_cnt].facilities[facility_cnt].cdi_form_facility_reltn_id = ffr.cdi_form_facility_reltn_id
    ENDIF
   FOOT  frm.cdi_form_id
    stat = alterlist(reply->forms[form_cnt].fields,field_cnt), stat = alterlist(reply->forms[form_cnt
     ].facilities,facility_cnt)
   FOOT REPORT
    stat = alterlist(reply->forms,form_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
