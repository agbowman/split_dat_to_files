CREATE PROGRAM cdi_import_forms:dba
 RECORD reply(
   1 forms[*]
     2 cdi_form_id = f8
     2 source_form_ident = vc
     2 form_name = vc
     2 status = c1
     2 substatus[*]
       3 error_flag = i4
       3 error_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cdi_invalid_form_name = i4 WITH constant(1), protect
 DECLARE cdi_invalid_form_ident = i4 WITH constant(2), protect
 DECLARE cdi_invalid_event_set = i4 WITH constant(3), protect
 DECLARE cdi_invalid_event_cd = i4 WITH constant(4), protect
 DECLARE cdi_invalid_field_name = i4 WITH constant(5), protect
 DECLARE cdi_invalid_field_type_flag = i4 WITH constant(6), protect
 DECLARE cdi_invalid_field_text = i4 WITH constant(7), protect
 DECLARE cdi_invalid_field_parent = i4 WITH constant(8), protect
 DECLARE cdi_invalid_event_cd_alias = i4 WITH constant(9), protect
 DECLARE cdi_invalid_rule_req_ind = i4 WITH constant(10), protect
 DECLARE cdi_invalid_rule_var_cd = i4 WITH constant(11), protect
 DECLARE cdi_invalid_rule_val_cd = i4 WITH constant(12), protect
 DECLARE cdi_invalid_rule_cmp_flag = i4 WITH constant(13), protect
 DECLARE cdi_invalid_rule_val_text = i4 WITH constant(14), protect
 DECLARE cdi_invalid_field_description = i4 WITH constant(15), protect
 DECLARE cdi_invalid_facility_display_name = i4 WITH constant(16), protect
 DECLARE cdi_invalid_form_comp_flag = i4 WITH constant(17), protect
 DECLARE cdi_invalid_form_description = i4 WITH constant(18), protect
 DECLARE cdi_invalid_field_linked_var = i4 WITH constant(19), protect
 DECLARE cdi_invalid_field_linked_val = i4 WITH constant(20), protect
 DECLARE cdi_invalid_field_alt_linked_val = i4 WITH constant(21), protect
 DECLARE cdi_invalid_form_sig_page_ind = i4 WITH constant(22), protect
 DECLARE cdi_invalid_form_auto_print_ind = i4 WITH constant(23), protect
 DECLARE cdi_invalid_form_procedural_form_ind = i4 WITH constant(24), protect
 SET modify = predeclare
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE emsg = vc WITH noconstant(""), protect
 DECLARE ecode = i4 WITH noconstant(0), protect
 DECLARE debug_messages = i2 WITH constant(1), protect
 IF (debug_messages=1)
  CALL echo("*** WARNING: *** cdi_import_forms debug messages are enabled.")
  CALL echo("* Parsing XML input:")
  CALL echo(request->form_xml)
 ENDIF
 FREE RECORD cdi_forms
 SET stat = cnvtxmltorec(request->form_xml)
 IF (debug_messages=1)
  CALL echo("* XML input:")
  IF (validate(cdi_forms)=1)
   CALL echorecord(cdi_forms)
  ELSE
   CALL echo("  (Failed to parse XML.)")
  ENDIF
 ENDIF
 IF (validate(cdi_forms)=0)
  SET reply->status_data.status = "F"
  SET emsg = fillstring(132," ")
  SET ecode = error(emsg,1)
  SET reply->status_data.subeventstatus[1].operationname = "CNVTXMLTOREC"
  SET reply->status_data.subeventstatus[1].targetobjectname = "form_xml"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
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
 SET modify = nopredeclare
 EXECUTE acm_get_curr_logical_domain
 SET modify = predeclare
 SET current_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 IF (debug_messages=1)
  CALL echo(build2("* Current logical domain = ",current_logical_domain_id))
 ENDIF
 SUBROUTINE (cdi_get_codeval_by_disp(codeset=i4,dispname=vc) =f8)
   DECLARE code_val = f8 WITH protect, noconstant(0.0)
   DECLARE disp_key = vc WITH protect, noconstant("")
   DECLARE temp = vc WITH protect, noconstant(dispname)
   DECLARE q = i2 WITH protect, noconstant(0)
   FOR (q = 0 TO 47)
    SET disp_key = replace(temp,char(q),"",0)
    SET temp = disp_key
   ENDFOR
   FOR (q = 58 TO 64)
    SET disp_key = replace(temp,char(q),"",0)
    SET temp = disp_key
   ENDFOR
   FOR (q = 91 TO 96)
    SET disp_key = replace(temp,char(q),"",0)
    SET temp = disp_key
   ENDFOR
   FOR (q = 123 TO 191)
    SET disp_key = replace(temp,char(q),"",0)
    SET temp = disp_key
   ENDFOR
   SET disp_key = cnvtupper(temp)
   IF (debug_messages=1)
    CALL echo(build2("* Searching for code value display key ",disp_key,", code set ",codeset))
   ENDIF
   IF (codeset=220)
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=220
      AND cv.display_key=disp_key
      AND cv.cdf_meaning="FACILITY"
      AND cv.active_ind=1
     DETAIL
      code_val = cv.code_value
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=codeset
      AND cv.display_key=disp_key
      AND cv.active_ind=1
     DETAIL
      code_val = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   RETURN(code_val)
 END ;Subroutine
 SUBROUTINE (cdi_log_invalid_data(arg_form=i4,error_idx=i4,error_flag=i4,error_value=vc,
  fail_if_invalid_flag=i2) =i2)
   IF (fail_if_invalid_flag=true)
    SET reply->forms[arg_form].status = "F"
    CALL echo(build2("* FAILURE MESSAGE = ",error_value))
   ENDIF
   IF (mod(error_idx,10)=1)
    SET stat = alterlist(reply->forms[arg_form].substatus,(error_idx+ 9))
   ENDIF
   SET reply->forms[arg_form].substatus[error_idx].error_flag = error_flag
   SET reply->forms[arg_form].substatus[error_idx].error_value = error_value
   RETURN(0)
 END ;Subroutine
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE xml_form_cnt = i4 WITH noconstant(0)
 DECLARE upd_form_cnt = i4 WITH noconstant(0)
 DECLARE add_form_cnt = i4 WITH noconstant(0)
 DECLARE form_err_cnt = i4 WITH noconstant(0)
 DECLARE xml_field_cnt = i4 WITH noconstant(0)
 DECLARE upd_field_cnt = i4 WITH noconstant(0)
 DECLARE xml_facility_cnt = i4 WITH noconstant(0)
 DECLARE upd_facility_cnt = i4 WITH noconstant(0)
 DECLARE facility_cd = f8 WITH noconstant(0.0)
 DECLARE facility_name = vc WITH noconstant("")
 DECLARE facility_code_set = i4 WITH constant(220)
 DECLARE xml_rule_cnt = i4 WITH noconstant(0)
 DECLARE upd_rule_cnt = i4 WITH noconstant(0)
 DECLARE upd_crit_cnt = i4 WITH noconstant(0)
 DECLARE xml_criteria_cnt = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE k = i4 WITH noconstant(0)
 DECLARE n = i4 WITH noconstant(0)
 DECLARE form_idx = i4 WITH noconstant(0)
 DECLARE field_idx = i4 WITH noconstant(0)
 DECLARE rule_idx = i4 WITH noconstant(0)
 DECLARE found = i2 WITH noconstant(0)
 DECLARE alias_cnt = i4 WITH noconstant(0)
 DECLARE crit_type_cnt = i4 WITH noconstant(0)
 DECLARE tmp_rule_cnt = i4 WITH noconstant(0)
 DECLARE upd_var_cnt = i4 WITH noconstant(0)
 DECLARE lnk_var_cnt = i4 WITH noconstant(0)
 DECLARE max_field_type_flag = i4 WITH constant(5)
 DECLARE min_font_size = i4 WITH constant(12)
 RECORD updformsreq(
   1 forms[*]
     2 cdi_form_id = f8
     2 event_cd = f8
     2 event_code_set = i4
     2 cdi_document_subtype_id = f8
     2 form_name = vc
     2 source_form_ident = vc
     2 fields[*]
       3 cdi_form_field_id = f8
       3 page_nbr = i4
       3 field_type_flag = i2
       3 x_coord = i4
       3 y_coord = i4
       3 field_width = i4
       3 field_height = i4
       3 delete_ind = i2
       3 value_format_text = vc
       3 field_description = vc
       3 linked_fields[*]
         4 cdi_form_field_id = f8
         4 page_nbr = i4
         4 x_coord = i4
         4 y_coord = i4
         4 field_width = i4
         4 field_height = i4
         4 value_format_text = vc
         4 delete_ind = i2
         4 field_type_flag = i2
         4 field_name = vc
         4 field_description = vc
         4 form_completion_flag = i2
         4 linked_variable_cd = f8
         4 linked_value_cd = f8
         4 linked_value_nbr = i4
         4 linked_value_text = vc
         4 required_ind = i2
         4 linked_variables[*]
           5 linked_variable_cd = f8
           5 linked_value_cd = f8
           5 linked_value_nbr = f8
           5 linked_value_text = vc
           5 field_status_flag = i2
         4 font_family_flag = i2
         4 font_size_nbr = i4
         4 text_color_nbr = i4
         4 field_rotation_value = f8
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
       3 cd_form_facility_reltn_id = f8
       3 delete_ind = i2
     2 form_description = vc
     2 signature_page_ind = i2
     2 page_cnt = i4
     2 media_object_ident = vc
     2 auto_print_ind = i2
     2 procedural_form_ind = i2
   1 update_linked_variables_ind = i2
 )
 RECORD updformsreply(
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
 RECORD updrulesreq(
   1 forms[*]
     2 cdi_form_id = f8
     2 rules[*]
       3 cdi_form_rule_id = f8
       3 required_ind = i2
       3 delete_ind = i2
       3 rule_name = vc
       3 criteria[*]
         4 cdi_form_criteria_id = f8
         4 variable_cd = f8
         4 comparison_flag = i2
         4 value_type_flag = i2
         4 value_cd = f8
         4 value_nbr = f8
         4 value_dt_tm = dq8
         4 value_text = vc
         4 delete_ind = i2
 )
 RECORD ref_data(
   1 doc_subtype[*]
     2 cdi_document_subtype_id = f8
     2 event_code_set = i4
     2 event_cd = f8
     2 document_type_alias = vc
   1 criteria_var[*]
     2 variable_cd = f8
     2 value_type_flag = i2
     2 code_set = i4
 )
 SET xml_form_cnt = size(cdi_forms->cdi_form,5)
 SET updformsreq->update_linked_variables_ind = 1
 IF (debug_messages=1)
  CALL echo(build2("* Validating ",xml_form_cnt," forms."))
 ENDIF
 SELECT INTO "nl:"
  st.cdi_document_subtype_id, dt.code_set, dt.event_cd,
  st.document_type_alias
  FROM cdi_document_type dt,
   cdi_document_subtype st
  PLAN (st
   WHERE st.cdi_document_type_id > 0.0
    AND expand(idx,1,xml_form_cnt,st.document_type_alias,cdi_forms->cdi_form[idx].event_code_alias))
   JOIN (dt
   WHERE st.cdi_document_type_id=dt.cdi_document_type_id)
  ORDER BY st.document_type_alias
  HEAD REPORT
   alias_cnt = 0
  DETAIL
   alias_cnt += 1
   IF (mod(alias_cnt,10)=1)
    stat = alterlist(ref_data->doc_subtype,(alias_cnt+ 9))
   ENDIF
   ref_data->doc_subtype[alias_cnt].cdi_document_subtype_id = st.cdi_document_subtype_id, ref_data->
   doc_subtype[alias_cnt].event_code_set = dt.code_set, ref_data->doc_subtype[alias_cnt].event_cd =
   dt.event_cd,
   ref_data->doc_subtype[alias_cnt].document_type_alias = st.document_type_alias
  WITH nocounter
 ;end select
 SET stat = alterlist(ref_data->doc_subtype,alias_cnt)
 SELECT INTO "nl:"
  cve.code_value, cve.field_value, cve.field_name
  FROM code_value_extension cve
  WHERE cve.code_set=4002599
   AND ((cve.field_name="VAR_TYPE_FLAG") OR (cve.field_name="SOURCE_CODESET"))
  ORDER BY cve.code_value
  HEAD REPORT
   crit_type_cnt = 0
  HEAD cve.code_value
   crit_type_cnt += 1
   IF (mod(crit_type_cnt,10)=1)
    stat = alterlist(ref_data->criteria_var,(crit_type_cnt+ 9))
   ENDIF
   ref_data->criteria_var[crit_type_cnt].variable_cd = cve.code_value
  DETAIL
   n = cnvtint(cve.field_value)
   IF (cve.field_name="VAR_TYPE_FLAG")
    IF (n > 0)
     ref_data->criteria_var[crit_type_cnt].value_type_flag = n
    ELSE
     ref_data->criteria_var[crit_type_cnt].value_type_flag = 0
    ENDIF
   ENDIF
   IF (cve.field_name="SOURCE_CODESET")
    ref_data->criteria_var[crit_type_cnt].code_set = n
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(ref_data->criteria_var,crit_type_cnt)
 IF (debug_messages=1)
  CALL echo(build2("* Loaded ",alias_cnt," doc type aliases and ",crit_type_cnt," criteria types."))
 ENDIF
 SET stat = alterlist(reply->forms,xml_form_cnt)
 SET stat = alterlist(updformsreq->forms,xml_form_cnt)
 SET stat = alterlist(updrulesreq->forms,xml_form_cnt)
 FOR (i = 1 TO xml_form_cnt)
   SET reply->forms[i].source_form_ident = cdi_forms->cdi_form[i].source_form_ident
   SET reply->forms[i].form_name = cdi_forms->cdi_form[i].form_name
   SET reply->forms[i].status = "S"
   CALL echo(build2("* reply->forms[i]->status AT BEGINING OF FOR LOOP = ",reply->forms[i].status))
   SET upd_form_cnt += 1
   SET form_err_cnt = 0
   SET n = size(trim(cdi_forms->cdi_form[i].form_name),1)
   IF (((n < 1) OR (n > 255)) )
    SET form_err_cnt += 1
    SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_form_name,cdi_forms->cdi_form[i].
     form_name,true)
   ELSE
    SET updformsreq->forms[upd_form_cnt].form_name = cdi_forms->cdi_form[i].form_name
   ENDIF
   SET n = size(trim(cdi_forms->cdi_form[i].form_description),1)
   IF (((n < 0) OR (n > 500)) )
    SET form_err_cnt += 1
    SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_form_description,cdi_forms->cdi_form[i
     ].form_description,true)
   ELSE
    SET updformsreq->forms[upd_form_cnt].form_description = cdi_forms->cdi_form[i].form_description
   ENDIF
   IF ((((cdi_forms->cdi_form[i].signature_page_ind < 0)) OR ((cdi_forms->cdi_form[i].
   signature_page_ind > 1))) )
    SET form_err_cnt += 1
    SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_form_sig_page_ind,cnvtstring(cdi_forms
      ->cdi_form[i].signature_page_ind),true)
   ELSE
    SET updformsreq->forms[upd_form_cnt].signature_page_ind = cdi_forms->cdi_form[i].
    signature_page_ind
   ENDIF
   IF ((((cdi_forms->cdi_form[i].auto_print_ind < 0)) OR ((cdi_forms->cdi_form[i].auto_print_ind > 1)
   )) )
    SET form_err_cnt += 1
    SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_form_auto_print_ind,cnvtstring(
      cdi_forms->cdi_form[i].auto_print_ind),true)
   ELSE
    SET updformsreq->forms[upd_form_cnt].auto_print_ind = cdi_forms->cdi_form[i].auto_print_ind
   ENDIF
   IF ((((cdi_forms->cdi_form[i].procedural_form_ind < 0)) OR ((cdi_forms->cdi_form[i].
   procedural_form_ind > 1))) )
    SET form_err_cnt += 1
    SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_form_procedural_form_ind,cnvtstring(
      cdi_forms->cdi_form[i].procedural_form_ind),true)
   ELSE
    SET updformsreq->forms[upd_form_cnt].procedural_form_ind = cdi_forms->cdi_form[i].
    procedural_form_ind
   ENDIF
   SET n = size(trim(cdi_forms->cdi_form[i].source_form_ident),1)
   IF (((n < 1) OR (n > 255)) )
    SET form_err_cnt += 1
    SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_form_ident,cdi_forms->cdi_form[i].
     source_form_ident,true)
   ELSE
    SET updformsreq->forms[upd_form_cnt].source_form_ident = cdi_forms->cdi_form[i].source_form_ident
   ENDIF
   SET updformsreq->forms[upd_form_cnt].page_cnt = cdi_forms->cdi_form[i].page_cnt
   IF (size(trim(cdi_forms->cdi_form[i].event_code_display),1) > 0)
    SET updformsreq->forms[upd_form_cnt].event_code_set = cdi_forms->cdi_form[i].event_code_set
    IF ((updformsreq->forms[upd_form_cnt].event_code_set != 72)
     AND (updformsreq->forms[upd_form_cnt].event_code_set != 26820))
     SET form_err_cnt += 1
     SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_event_set,cnvtstring(cdi_forms->
       cdi_form[i].event_code_set),true)
    ENDIF
    SET updformsreq->forms[upd_form_cnt].event_cd = cdi_get_codeval_by_disp(cdi_forms->cdi_form[i].
     event_code_set,cdi_forms->cdi_form[i].event_code_display)
    IF ((updformsreq->forms[upd_form_cnt].event_cd != 0))
     IF (size(trim(cdi_forms->cdi_form[i].event_code_alias),1) > 0)
      SET found = 0
      FOR (j = 1 TO alias_cnt)
        IF ((ref_data->doc_subtype[j].event_code_set=cdi_forms->cdi_form[i].event_code_set)
         AND (ref_data->doc_subtype[j].event_cd=updformsreq->forms[upd_form_cnt].event_cd)
         AND (ref_data->doc_subtype[j].document_type_alias=cdi_forms->cdi_form[i].event_code_alias))
         SET found = 1
         SET updformsreq->forms[upd_form_cnt].cdi_document_subtype_id = ref_data->doc_subtype[j].
         cdi_document_subtype_id
        ENDIF
      ENDFOR
      IF (found=0)
       SET form_err_cnt += 1
       SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_event_cd_alias,cdi_forms->cdi_form[
        i].event_code_alias,true)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET upd_facility_cnt = 0
   IF (validate(cdi_forms->cdi_form[i].facilities)=1)
    SET xml_facility_cnt = size(cdi_forms->cdi_form[i].facilities,5)
    FOR (j = 1 TO xml_facility_cnt)
     SET facility_name = trim(cdi_forms->cdi_form[i].facilities[j].facility_display_name)
     IF (size(facility_name,1) > 0)
      SET facility_cd = cdi_get_codeval_by_disp(facility_code_set,facility_name)
      IF (facility_cd > 0.0)
       SET upd_facility_cnt += 1
       IF (mod(upd_facility_cnt,10)=1)
        SET stat = alterlist(updformsreq->forms[upd_form_cnt].facilities,(upd_facility_cnt+ 9))
       ENDIF
       SET updformsreq->forms[upd_form_cnt].facilities[upd_facility_cnt].facility_cd = facility_cd
       SET updformsreq->forms[upd_form_cnt].facilities[upd_facility_cnt].cd_form_facility_reltn_id =
       0.0
       SET updformsreq->forms[upd_form_cnt].facilities[upd_facility_cnt].delete_ind = 0
      ELSE
       SET form_err_cnt += 1
       SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_facility_display_name,facility_name,
        false)
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   SET stat = alterlist(updformsreq->forms[upd_form_cnt].facilities,upd_facility_cnt)
   SET xml_field_cnt = size(cdi_forms->cdi_form[i].cdi_form_field,5)
   SET upd_field_cnt = 0
   FOR (j = 1 TO xml_field_cnt)
     IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].field_name),1) > 0)
      IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].parent_field_name),1) < 1)
       SET upd_field_cnt += 1
       IF (mod(upd_field_cnt,10)=1)
        SET stat = alterlist(updformsreq->forms[upd_form_cnt].fields,(upd_field_cnt+ 9))
       ENDIF
       IF (size(cdi_forms->cdi_form[i].cdi_form_field[j].field_name,1) > 40)
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_name,cdi_forms->cdi_form[i].
         cdi_form_field[j].field_name,true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].field_name = cdi_forms->cdi_form[i
        ].cdi_form_field[j].field_name
       ENDIF
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].page_nbr = cdi_forms->cdi_form[i].
       cdi_form_field[j].page_nbr
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].last_page_nbr = cdi_forms->
       cdi_form[i].cdi_form_field[j].last_page_nbr
       IF ((((cdi_forms->cdi_form[i].cdi_form_field[j].field_type_flag < 0)) OR ((cdi_forms->
       cdi_form[i].cdi_form_field[j].field_type_flag > max_field_type_flag))) )
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_type_flag,cnvtstring(
          cdi_forms->cdi_form[i].cdi_form_field[j].field_type_flag),true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].field_type_flag = cdi_forms->
        cdi_form[i].cdi_form_field[j].field_type_flag
       ENDIF
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].x_coord = cdi_forms->cdi_form[i].
       cdi_form_field[j].x_coord
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].y_coord = cdi_forms->cdi_form[i].
       cdi_form_field[j].y_coord
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].field_width = cdi_forms->cdi_form[i
       ].cdi_form_field[j].field_width
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].field_height = cdi_forms->cdi_form[
       i].cdi_form_field[j].field_height
       IF (size(cdi_forms->cdi_form[i].cdi_form_field[j].value_format_text,1) > 150)
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_text,cdi_forms->cdi_form[i].
         cdi_form_field[j].value_format_text,true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].value_format_text = cdi_forms->
        cdi_form[i].cdi_form_field[j].value_format_text
       ENDIF
       IF (size(cdi_forms->cdi_form[i].cdi_form_field[j].field_description,1) > 500)
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_description,cdi_forms->
         cdi_form[i].cdi_form_field[j].field_description,true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].field_description = cdi_forms->
        cdi_form[i].cdi_form_field[j].field_description
       ENDIF
       IF ((((cdi_forms->cdi_form[i].cdi_form_field[j].form_completion_flag < 0)) OR ((cdi_forms->
       cdi_form[i].cdi_form_field[j].form_completion_flag > 2))) )
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_form_comp_flag,cnvtstring(
          cdi_forms->cdi_form[i].cdi_form_field[j].form_completion_flag),true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].form_completion_flag = cdi_forms->
        cdi_form[i].cdi_form_field[j].form_completion_flag
       ENDIF
       IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].linked_variable_display),1) > 0)
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variable_cd =
        cdi_get_codeval_by_disp(4002599,cdi_forms->cdi_form[i].cdi_form_field[j].
         linked_variable_display)
        IF ((updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variable_cd <= 0))
         SET form_err_cnt += 1
         SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_linked_var,cdi_forms->
          cdi_form[i].cdi_form_field[j].linked_variable_display,false)
        ENDIF
       ENDIF
       IF ((updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variable_cd > 0))
        IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].linked_value_display),1) > 0)
         SET q = locateval(idx,1,crit_type_cnt,updformsreq->forms[upd_form_cnt].fields[upd_field_cnt]
          .linked_variable_cd,ref_data->criteria_var[idx].variable_cd)
         SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_value_cd =
         cdi_get_codeval_by_disp(ref_data->criteria_var[q].code_set,cdi_forms->cdi_form[i].
          cdi_form_field[j].linked_value_display)
         IF ((updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_value_cd <= 0))
          SET form_err_cnt += 1
          SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_linked_val,cdi_forms->
           cdi_form[i].cdi_form_field[j].linked_value_display,false)
         ENDIF
        ENDIF
       ENDIF
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_value_nbr = cdi_forms->
       cdi_form[i].cdi_form_field[j].linked_value_nbr
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_value_text = cdi_forms->
       cdi_form[i].cdi_form_field[j].linked_value_text
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].required_ind = cdi_forms->cdi_form[
       i].cdi_form_field[j].required_ind
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].font_family_flag = cdi_forms->
       cdi_form[i].cdi_form_field[j].font_family_flag
       IF ((cdi_forms->cdi_form[i].cdi_form_field[j].font_size_nbr > 0))
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].font_size_nbr = cdi_forms->
        cdi_form[i].cdi_form_field[j].font_size_nbr
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].font_size_nbr = min_font_size
       ENDIF
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].text_color_nbr = cdi_forms->
       cdi_form[i].cdi_form_field[j].text_color_nbr
       SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].field_rotation_value = cdi_forms->
       cdi_form[i].cdi_form_field[j].field_rotation_value
       SET lnk_var_cnt = size(cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables,5)
       CALL echo(build2("* LINK VARIABLE COUNT Parent = ",lnk_var_cnt))
       SET upd_var_cnt = 0
       FOR (r = 1 TO lnk_var_cnt)
         IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r].
           linked_variable_display),1) > 0)
          SET upd_var_cnt += 1
          IF (mod(upd_var_cnt,10)=1)
           SET stat = alterlist(updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].
            linked_variables,(upd_var_cnt+ 9))
          ENDIF
          SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables[upd_var_cnt].
          linked_variable_cd = cdi_get_codeval_by_disp(4002599,cdi_forms->cdi_form[i].cdi_form_field[
           j].linked_variables[r].linked_variable_display)
          CALL echo(build2("* LINK VARIABLE CD = ",updformsreq->forms[upd_form_cnt].fields[
            upd_field_cnt].linked_variables[upd_var_cnt].linked_variable_cd))
          IF ((updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables[upd_var_cnt].
          linked_variable_cd <= 0))
           SET form_err_cnt += 1
           SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_linked_var,cdi_forms->
            cdi_form[i].cdi_form_field[j].linked_variables[r].linked_variable_display,false)
          ENDIF
          IF ((updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables[upd_var_cnt].
          linked_variable_cd > 0))
           IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r].
             linked_value_display),1) > 0)
            SET q = locateval(idx,1,crit_type_cnt,updformsreq->forms[upd_form_cnt].fields[
             upd_field_cnt].linked_variables[upd_var_cnt].linked_variable_cd,ref_data->criteria_var[
             idx].variable_cd)
            SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables[upd_var_cnt].
            linked_value_cd = cdi_get_codeval_by_disp(ref_data->criteria_var[q].code_set,cdi_forms->
             cdi_form[i].cdi_form_field[j].linked_variables[r].linked_value_display)
            IF ((updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables[upd_var_cnt]
            .linked_value_cd <= 0))
             SET form_err_cnt += 1
             SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_linked_val,cdi_forms->
              cdi_form[i].cdi_form_field[j].linked_variables[r].linked_value_display,false)
            ENDIF
           ENDIF
          ENDIF
          SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables[upd_var_cnt].
          linked_value_nbr = cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r].
          linked_value_nbr
          SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables[upd_var_cnt].
          linked_value_text = cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r].
          linked_value_text
          SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables[upd_var_cnt].
          field_status_flag = cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r].
          field_status_flag
         ENDIF
       ENDFOR
       SET stat = alterlist(updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].linked_variables,
        upd_var_cnt)
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(updformsreq->forms[upd_form_cnt].fields,upd_field_cnt)
   FOR (j = 1 TO xml_field_cnt)
     IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].parent_field_name),1) > 0)
      SET n = locateval(idx,1,upd_field_cnt,cdi_forms->cdi_form[i].cdi_form_field[j].
       parent_field_name,updformsreq->forms[upd_form_cnt].fields[idx].field_name)
      IF (n < 1)
       SET form_err_cnt += 1
       SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_parent,cdi_forms->cdi_form[i]
        .cdi_form_field[j].parent_field_name,true)
      ELSE
       SET k = (size(updformsreq->forms[upd_form_cnt].fields[n].linked_fields,5)+ 1)
       SET stat = alterlist(updformsreq->forms[upd_form_cnt].fields[n].linked_fields,k)
       IF (size(cdi_forms->cdi_form[i].cdi_form_field[j].field_name,1) > 40)
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_name,cdi_forms->cdi_form[i].
         cdi_form_field[j].field_name,true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].field_name = cdi_forms->
        cdi_form[i].cdi_form_field[j].field_name
       ENDIF
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].page_nbr = cdi_forms->
       cdi_form[i].cdi_form_field[j].page_nbr
       IF ((((cdi_forms->cdi_form[i].cdi_form_field[j].field_type_flag < 0)) OR ((cdi_forms->
       cdi_form[i].cdi_form_field[j].field_type_flag > max_field_type_flag))) )
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_type_flag,cnvtstring(
          cdi_forms->cdi_form[i].cdi_form_field[j].field_type_flag),true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].field_type_flag = cdi_forms->
        cdi_form[i].cdi_form_field[j].field_type_flag
       ENDIF
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].x_coord = cdi_forms->cdi_form[
       i].cdi_form_field[j].x_coord
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].y_coord = cdi_forms->cdi_form[
       i].cdi_form_field[j].y_coord
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].field_width = cdi_forms->
       cdi_form[i].cdi_form_field[j].field_width
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].field_height = cdi_forms->
       cdi_form[i].cdi_form_field[j].field_height
       IF (size(cdi_forms->cdi_form[i].cdi_form_field[j].value_format_text,1) > 150)
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_text,cdi_forms->cdi_form[i].
         cdi_form_field[j].value_format_text,true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].value_format_text = cdi_forms
        ->cdi_form[i].cdi_form_field[j].value_format_text
       ENDIF
       IF (size(cdi_forms->cdi_form[i].cdi_form_field[j].field_description,1) > 500)
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_description,cdi_forms->
         cdi_form[i].cdi_form_field[j].field_description,true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[upd_field_cnt].field_description = cdi_forms->
        cdi_form[i].cdi_form_field[j].field_description
       ENDIF
       IF ((((cdi_forms->cdi_form[i].cdi_form_field[j].form_completion_flag < 0)) OR ((cdi_forms->
       cdi_form[i].cdi_form_field[j].form_completion_flag > 2))) )
        SET form_err_cnt += 1
        SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_form_comp_flag,cnvtstring(
          cdi_forms->cdi_form[i].cdi_form_field[j].form_completion_flag),true)
       ELSE
        SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].form_completion_flag =
        cdi_forms->cdi_form[i].cdi_form_field[j].form_completion_flag
       ENDIF
       IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].linked_variable_display),1) > 0)
        SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variable_cd =
        cdi_get_codeval_by_disp(4002599,cdi_forms->cdi_form[i].cdi_form_field[j].
         linked_variable_display)
        IF ((updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variable_cd <= 0))
         SET form_err_cnt += 1
         SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_linked_var,cdi_forms->
          cdi_form[i].cdi_form_field[j].linked_variable_display,false)
        ENDIF
       ENDIF
       IF ((updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variable_cd > 0))
        IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].linked_value_display),1) > 0)
         SET m = locateval(idx,1,crit_type_cnt,updformsreq->forms[upd_form_cnt].fields[n].
          linked_fields[k].linked_variable_cd,ref_data->criteria_var[idx].variable_cd)
         SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_value_cd =
         cdi_get_codeval_by_disp(ref_data->criteria_var[m].code_set,cdi_forms->cdi_form[i].
          cdi_form_field[j].linked_value_display)
         IF ((updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_value_cd <= 0))
          SET form_err_cnt += 1
          SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_linked_val,cdi_forms->
           cdi_form[i].cdi_form_field[j].linked_value_display,false)
         ENDIF
        ENDIF
       ENDIF
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_value_nbr = cdi_forms->
       cdi_form[i].cdi_form_field[j].linked_value_nbr
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_value_text = cdi_forms
       ->cdi_form[i].cdi_form_field[j].linked_value_text
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].required_ind = cdi_forms->
       cdi_form[i].cdi_form_field[j].required_ind
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].font_family_flag = cdi_forms->
       cdi_form[i].cdi_form_field[j].font_family_flag
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].font_size_nbr = cdi_forms->
       cdi_form[i].cdi_form_field[j].font_size_nbr
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].text_color_nbr = cdi_forms->
       cdi_form[i].cdi_form_field[j].text_color_nbr
       SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].field_rotation_value =
       cdi_forms->cdi_form[i].cdi_form_field[j].field_rotation_value
       SET upd_var_cnt = 0
       SET lnk_var_cnt = size(cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables,5)
       CALL echo(build2("* LINK VARIABLE COUNT Cild = ",lnk_var_cnt))
       FOR (r = 1 TO lnk_var_cnt)
         IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r].
           linked_variable_display),1) > 0)
          SET upd_var_cnt += 1
          IF (mod(upd_var_cnt,10)=1)
           SET stat = alterlist(updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].
            linked_variables,(upd_var_cnt+ 9))
          ENDIF
          SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variables[
          upd_var_cnt].linked_variable_cd = cdi_get_codeval_by_disp(4002599,cdi_forms->cdi_form[i].
           cdi_form_field[j].linked_variables[r].linked_variable_display)
          IF ((updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variables[
          upd_var_cnt].linked_variable_cd <= 0))
           SET form_err_cnt += 1
           SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_linked_var,cdi_forms->
            cdi_form[i].cdi_form_field[j].linked_variables[r].linked_variable_display,false)
          ENDIF
          IF ((updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variables[
          upd_var_cnt].linked_variable_cd > 0))
           IF (size(trim(cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r].
             linked_value_display),1) > 0)
            SET q = locateval(idx,1,crit_type_cnt,updformsreq->forms[upd_form_cnt].fields[n].
             linked_fields[k].linked_variables[upd_var_cnt].linked_variable_cd,ref_data->
             criteria_var[idx].variable_cd)
            SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variables[
            upd_var_cnt].linked_value_cd = cdi_get_codeval_by_disp(ref_data->criteria_var[q].code_set,
             cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r].linked_value_display)
            IF ((updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variables[
            upd_var_cnt].linked_value_cd <= 0))
             SET form_err_cnt += 1
             SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_field_linked_val,cdi_forms->
              cdi_form[i].cdi_form_field[j].linked_variables[r].linked_value_display,false)
            ENDIF
           ENDIF
          ENDIF
          SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variables[
          upd_var_cnt].linked_value_nbr = cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[r
          ].linked_value_nbr
          SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variables[
          upd_var_cnt].linked_value_text = cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[
          r].linked_value_text
          SET updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].linked_variables[
          upd_var_cnt].field_status_flag = cdi_forms->cdi_form[i].cdi_form_field[j].linked_variables[
          r].field_status_flag
         ENDIF
       ENDFOR
       SET stat = alterlist(updformsreq->forms[upd_form_cnt].fields[n].linked_fields[k].
        linked_variables,upd_var_cnt)
      ENDIF
     ENDIF
   ENDFOR
   SET xml_rule_cnt = size(cdi_forms->cdi_form[i].cdi_form_rule,5)
   SET upd_rule_cnt = 0
   SET stat = alterlist(updrulesreq->forms[upd_form_cnt].rules,xml_rule_cnt)
   FOR (j = 1 TO xml_rule_cnt)
     IF (size(trim(cdi_forms->cdi_form[i].cdi_form_rule[j].rule_name),1) > 0)
      SET upd_rule_cnt += 1
      SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].rule_name = cdi_forms->cdi_form[i].
      cdi_form_rule[j].rule_name
      IF ((((cdi_forms->cdi_form[i].cdi_form_rule[j].required_ind < 0)) OR ((cdi_forms->cdi_form[i].
      cdi_form_rule[j].required_ind > 1))) )
       SET form_err_cnt += 1
       SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_rule_req_ind,cnvtstring(cdi_forms->
         cdi_form[i].cdi_form_rule[j].required_ind),true)
      ELSE
       SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].required_ind = cdi_forms->cdi_form[i]
       .cdi_form_rule[j].required_ind
      ENDIF
      SET xml_criteria_cnt = size(cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria,5)
      SET stat = alterlist(updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria,
       xml_criteria_cnt)
      SET upd_crit_cnt = 0
      FOR (k = 1 TO xml_criteria_cnt)
        IF (size(trim(cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].
          variable_code_display),1) > 0)
         SET upd_crit_cnt += 1
         IF ((((cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].comparison_flag < 0))
          OR ((cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].comparison_flag > 5))) )
          SET form_err_cnt += 1
          SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_rule_cmp_flag,cnvtstring(
            cdi_forms->cdi_form[i].cdi_form_rule[j].required_ind),true)
         ELSE
          SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].
          comparison_flag = cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].
          comparison_flag
         ENDIF
         SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].variable_cd
          = cdi_get_codeval_by_disp(4002599,cdi_forms->cdi_form[i].cdi_form_rule[j].
          cdi_form_criteria[k].variable_code_display)
         IF ((updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].variable_cd
          < 1))
          SET form_err_cnt += 1
          SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_rule_var_cd,cdi_forms->cdi_form[
           i].cdi_form_rule[j].cdi_form_criteria[k].variable_code_display,true)
         ELSE
          SET n = locateval(idx,1,crit_type_cnt,updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].
           criteria[upd_crit_cnt].variable_cd,ref_data->criteria_var[idx].variable_cd)
          IF (n > 0)
           SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].
           value_type_flag = ref_data->criteria_var[n].value_type_flag
          ENDIF
         ENDIF
         IF ((cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].value_code_set > 0))
          SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].value_cd =
          cdi_get_codeval_by_disp(cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].
           value_code_set,cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].
           value_code_display)
          IF ((updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].value_cd
           < 1))
           SET form_err_cnt += 1
           SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_rule_val_cd,cdi_forms->
            cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].value_code_display,true)
          ENDIF
         ENDIF
         SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].value_dt_tm
          = cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].value_dt_tm
         SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].value_nbr =
         cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].value_nbr
         IF (size(trim(cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].value_text)) > 30
         )
          SET form_err_cnt += 1
          SET stat = cdi_log_invalid_data(i,form_err_cnt,cdi_invalid_rule_val_text,cdi_forms->
           cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].value_text,true)
         ELSE
          SET updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria[upd_crit_cnt].value_text
           = cdi_forms->cdi_form[i].cdi_form_rule[j].cdi_form_criteria[k].value_text
         ENDIF
        ENDIF
      ENDFOR
      SET stat = alterlist(updrulesreq->forms[upd_form_cnt].rules[upd_rule_cnt].criteria,upd_crit_cnt
       )
     ENDIF
   ENDFOR
   SET stat = alterlist(updrulesreq->forms[upd_form_cnt].rules,upd_rule_cnt)
   IF (debug_messages=1)
    CALL echo(build2("* error count++ LOOP = ",form_err_cnt))
    CALL echo("* Print out the update form request record:")
    CALL echorecord(updformsreq)
   ENDIF
   SET stat = alterlist(reply->forms[i].substatus,form_err_cnt)
   CALL echo(build2("* reply->forms[i]->status AT END OF FOR LOOP B = ",reply->forms[i].status))
   IF ((reply->forms[i].status != "S"))
    SET stat = alterlist(updformsreq->forms[upd_form_cnt].fields,0)
    SET stat = alterlist(updrulesreq->forms[upd_form_cnt].rules,0)
    SET upd_form_cnt -= 1
    SET reply->status_data.status = "P"
   ENDIF
 ENDFOR
 IF (debug_messages=1)
  CALL echo(build2("* END OF PROCESSING REPLY STATUS = ",reply->status_data.status))
 ENDIF
 SET stat = alterlist(updformsreq->forms,upd_form_cnt)
 SET stat = alterlist(updrulesreq->forms,upd_form_cnt)
 IF (debug_messages=1)
  CALL echo(build2("* Found ",upd_form_cnt," forms with valid data."))
 ENDIF
 IF (upd_form_cnt < 1)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  SET reply->status_data.subeventstatus[1].targetobjectname = "form_xml"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid form data to import."
  GO TO exit_script
 ENDIF
 IF (debug_messages=1)
  CALL echo("* Checking for existing forms and fields.")
 ENDIF
 SELECT INTO "nl:"
  frm.cdi_form_id, frm.source_form_ident, fld.cdi_form_field_id,
  fld.field_name
  FROM cdi_form frm,
   cdi_form_field fld
  PLAN (frm
   WHERE frm.logical_domain_id=current_logical_domain_id
    AND expand(idx,1,xml_form_cnt,frm.source_form_ident,cdi_forms->cdi_form[idx].source_form_ident)
    AND frm.cdi_form_id > 0
    AND frm.active_ind=1)
   JOIN (fld
   WHERE (fld.cdi_form_id= Outerjoin(frm.cdi_form_id)) )
  ORDER BY frm.cdi_form_id, fld.cdi_form_field_id
  HEAD REPORT
   form_idx = 0
  HEAD frm.cdi_form_id
   IF (debug_messages=1)
    CALL echo(build2("* Found existing form ",frm.source_form_ident))
   ENDIF
   form_idx = locateval(idx,1,xml_form_cnt,frm.source_form_ident,reply->forms[idx].source_form_ident)
   IF (form_idx > 0)
    reply->forms[form_idx].cdi_form_id = frm.cdi_form_id
    IF ((request->update_existing_ind=0))
     IF ((reply->forms[form_idx].status != "F"))
      reply->forms[form_idx].status = "E", reply->status_data.status = "E"
     ENDIF
     form_idx = 0
    ELSE
     form_idx = locateval(idx,1,upd_form_cnt,frm.source_form_ident,updformsreq->forms[idx].
      source_form_ident)
     IF (form_idx > 0)
      updformsreq->forms[form_idx].cdi_form_id = frm.cdi_form_id, updrulesreq->forms[form_idx].
      cdi_form_id = frm.cdi_form_id
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (form_idx > 0
    AND size(trim(fld.field_name),1) > 0)
    IF (debug_messages=1)
     CALL echo(build2("* Checking existing field ",fld.field_name))
    ENDIF
    found = 0, upd_field_cnt = size(updformsreq->forms[form_idx].fields,5), field_idx = locateval(idx,
     1,upd_field_cnt,fld.field_name,updformsreq->forms[form_idx].fields[idx].field_name)
    IF (field_idx > 0)
     updformsreq->forms[form_idx].fields[field_idx].cdi_form_field_id = fld.cdi_form_field_id, found
      = 1
    ELSE
     FOR (i = 1 TO upd_field_cnt)
       n = size(updformsreq->forms[form_idx].fields[i].linked_fields,5), field_idx = locateval(idx,1,
        n,fld.field_name,updformsreq->forms[form_idx].fields[i].linked_fields[idx].field_name)
       IF (field_idx > 0)
        updformsreq->forms[form_idx].fields[i].linked_fields[field_idx].cdi_form_field_id = fld
        .cdi_form_field_id, found = 1
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (debug_messages=1)
  CALL echo("* Checking for existing rules and criteria.")
 ENDIF
 SELECT INTO "nl:"
  r.cdi_form_id, r.rule_name, r.cdi_form_rule_id,
  c.cdi_form_criteria_id, c.variable_cd, c.comparison_flag
  FROM cdi_form_rule r,
   cdi_form_criteria c
  PLAN (r
   WHERE r.cdi_form_id > 0.0
    AND expand(idx,1,upd_form_cnt,r.cdi_form_id,updrulesreq->forms[idx].cdi_form_id))
   JOIN (c
   WHERE r.cdi_form_rule_id=c.cdi_form_rule_id)
  ORDER BY r.cdi_form_id, r.cdi_form_rule_id
  HEAD REPORT
   form_idx = 0
  HEAD r.cdi_form_id
   form_idx = 0, form_idx = locateval(idx,1,upd_form_cnt,r.cdi_form_id,updrulesreq->forms[idx].
    cdi_form_id)
  HEAD r.cdi_form_rule_id
   rule_idx = 0
   IF (debug_messages=1)
    CALL echo(build2("* Found existing rule ",r.rule_name))
   ENDIF
   IF (form_idx > 0
    AND r.cdi_form_rule_id != 0.0
    AND size(trim(r.rule_name),1) > 0)
    n = size(updrulesreq->forms[form_idx].rules,5), rule_idx = locateval(idx,1,n,r.rule_name,
     updrulesreq->forms[form_idx].rules[idx].rule_name)
    IF (rule_idx > 0)
     updrulesreq->forms[form_idx].rules[rule_idx].cdi_form_rule_id = r.cdi_form_rule_id
    ELSE
     n += 1, stat = alterlist(updrulesreq->forms[form_idx].rules,n), updrulesreq->forms[form_idx].
     rules[n].cdi_form_rule_id = r.cdi_form_rule_id,
     updrulesreq->forms[form_idx].rules[n].delete_ind = 1
    ENDIF
   ENDIF
  DETAIL
   IF (debug_messages=1)
    CALL echo(build2("* Found existing criteria ",c.cdi_form_criteria_id))
   ENDIF
   IF (rule_idx > 0
    AND c.cdi_form_criteria_id != 0.0)
    found = 0, n = size(updrulesreq->forms[form_idx].rules[rule_idx].criteria,5)
    FOR (i = 1 TO n)
      IF ((updrulesreq->forms[form_idx].rules[rule_idx].criteria[i].variable_cd=c.variable_cd)
       AND (updrulesreq->forms[form_idx].rules[rule_idx].criteria[i].comparison_flag=c
      .comparison_flag))
       updrulesreq->forms[form_idx].rules[rule_idx].criteria[i].cdi_form_criteria_id = c
       .cdi_form_criteria_id, found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     n += 1, stat = alterlist(updrulesreq->forms[form_idx].rules[rule_idx].criteria,n), updrulesreq->
     forms[form_idx].rules[rule_idx].criteria[n].cdi_form_criteria_id = c.cdi_form_criteria_id,
     updrulesreq->forms[form_idx].rules[rule_idx].criteria[n].delete_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->status_data.status != "S")
  AND (reply->status_data.status != "P"))
  GO TO exit_script
 ENDIF
 IF (debug_messages=1)
  CALL echo("* Adding any new forms.")
 ENDIF
 RECORD addformsreq(
   1 forms[*]
     2 event_cd = f8
     2 event_code_set = i4
     2 cdi_document_subtype_id = f8
     2 form_name = vc
     2 source_form_ident = vc
     2 fields[*]
       3 page_nbr = i4
       3 field_type_flag = i2
       3 x_coord = i4
       3 y_coord = i4
       3 field_width = i4
       3 field_height = i4
       3 value_format_text = vc
       3 linked_fields[*]
         4 page_nbr = i4
         4 x_coord = i4
         4 y_coord = i4
         4 field_width = i4
         4 field_height = i4
         4 value_format_text = vc
         4 field_type_flag = i2
         4 field_name = vc
         4 field_description = vc
         4 form_completion_flag = i2
         4 linked_variable_cd = f8
         4 linked_value_cd = f8
         4 linked_value_nbr = i4
         4 linked_value_text = vc
         4 required_ind = i2
         4 linked_variables[*]
           5 linked_variable_cd = f8
           5 linked_value_cd = f8
           5 linked_value_nbr = f8
           5 linked_value_text = vc
           5 field_status_flag = i2
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
     2 facilities[*]
       3 facility_cd = f8
       3 cdi_form_facility_reltn_id = f8
     2 form_description = vc
     2 signature_page_ind = i2
     2 page_cnt = i4
     2 media_object_ident = vc
     2 auto_print_ind = i2
     2 procedural_form_ind = i2
 )
 RECORD addformsreply(
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
       3 cd_form_facility_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET add_form_cnt = 0
 FOR (i = 1 TO upd_form_cnt)
   IF ((updformsreq->forms[i].cdi_form_id=0.0))
    SET add_form_cnt += 1
    IF (mod(add_form_cnt,10)=1)
     SET stat = alterlist(addformsreq->forms,(add_form_cnt+ 9))
    ENDIF
    SET addformsreq->forms[add_form_cnt].event_cd = updformsreq->forms[i].event_cd
    SET addformsreq->forms[add_form_cnt].event_code_set = updformsreq->forms[i].event_code_set
    SET addformsreq->forms[add_form_cnt].cdi_document_subtype_id = updformsreq->forms[i].
    cdi_document_subtype_id
    SET addformsreq->forms[add_form_cnt].form_name = updformsreq->forms[i].form_name
    SET addformsreq->forms[add_form_cnt].source_form_ident = updformsreq->forms[i].source_form_ident
    SET addformsreq->forms[add_form_cnt].form_description = updformsreq->forms[i].form_description
    SET addformsreq->forms[add_form_cnt].signature_page_ind = updformsreq->forms[i].
    signature_page_ind
    SET addformsreq->forms[add_form_cnt].page_cnt = updformsreq->forms[i].page_cnt
    SET addformsreq->forms[add_form_cnt].auto_print_ind = updformsreq->forms[i].auto_print_ind
    SET addformsreq->forms[add_form_cnt].procedural_form_ind = updformsreq->forms[i].
    procedural_form_ind
   ENDIF
 ENDFOR
 SET stat = alterlist(addformsreq->forms,add_form_cnt)
 IF (add_form_cnt > 0)
  IF (debug_messages=1)
   CALL echorecord(addformsreq)
  ENDIF
  SET modify = nopredeclare
  EXECUTE cdi_add_forms  WITH replace("REQUEST",addformsreq), replace("REPLY",addformsreply)
  SET modify = predeclare
  IF (debug_messages=1)
   CALL echo(build2("* cdi_add_forms reply status = ",addformsreply->status_data.status))
   CALL echorecord(addformsreply)
  ENDIF
  IF ((addformsreply->status_data.status != "S"))
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "CDI_ADD_FORMS"
   SET reply->status_data.subeventstatus[1].targetobjectname = addformsreply->status_data.
   subeventstatus[1].targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = addformsreply->status_data.
   subeventstatus[1].targetobjectvalue
   GO TO exit_script
  ENDIF
  SET n = size(addformsreply->forms,5)
  FOR (i = 1 TO n)
    SET j = locateval(idx,1,size(reply->forms,5),addformsreply->forms[i].source_form_ident,reply->
     forms[idx].source_form_ident)
    IF (j > 0)
     SET reply->forms[j].cdi_form_id = addformsreply->forms[i].cdi_form_id
    ENDIF
    SET j = locateval(idx,1,size(updformsreq->forms,5),addformsreply->forms[i].source_form_ident,
     updformsreq->forms[idx].source_form_ident)
    IF (j > 0)
     SET updformsreq->forms[j].cdi_form_id = addformsreply->forms[i].cdi_form_id
     SET updrulesreq->forms[j].cdi_form_id = addformsreply->forms[i].cdi_form_id
    ENDIF
  ENDFOR
 ENDIF
 IF (debug_messages=1)
  CALL echorecord(updformsreq)
 ENDIF
 SET modify = nopredeclare
 EXECUTE cdi_upd_forms  WITH replace("REQUEST",updformsreq), replace("REPLY",updformsreply)
 SET modify = predeclare
 IF (debug_messages=1)
  CALL echo(build2("* cdi_upd_forms reply status = ",updformsreply->status_data.status))
 ENDIF
 IF ((updformsreply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "CDI_UPD_FORMS"
  SET reply->status_data.subeventstatus[1].targetobjectname = updformsreply->status_data.
  subeventstatus[1].targetobjectname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = updformsreply->status_data.
  subeventstatus[1].targetobjectvalue
  GO TO exit_script
 ENDIF
 SET n = size(updformsreply->forms,5)
 FOR (i = 1 TO n)
   SET j = locateval(idx,1,size(reply->forms,5),updformsreply->forms[i].source_form_ident,reply->
    forms[idx].source_form_ident)
   IF (j > 0)
    SET reply->forms[j].cdi_form_id = updformsreply->forms[i].cdi_form_id
   ENDIF
   SET j = locateval(idx,1,size(updformsreq->forms,5),updformsreply->forms[i].source_form_ident,
    updformsreq->forms[idx].source_form_ident)
   IF (j > 0)
    SET updrulesreq->forms[j].cdi_form_id = updformsreply->forms[i].cdi_form_id
   ENDIF
 ENDFOR
 RECORD tmprulesreq(
   1 cdi_form_id = f8
   1 rules[*]
     2 cdi_form_rule_id = f8
     2 required_ind = i2
     2 delete_ind = i2
     2 criteria[*]
       3 cdi_form_criteria_id = f8
       3 variable_cd = f8
       3 comparison_flag = i2
       3 value_type_flag = i2
       3 value_cd = f8
       3 value_nbr = f8
       3 value_dt_tm = dq8
       3 value_text = vc
       3 delete_ind = i2
     2 rule_name = vc
 )
 RECORD tmprulesreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (debug_messages=1)
  CALL echorecord(updrulesreq)
 ENDIF
 SET upd_form_cnt = size(updrulesreq->forms,5)
 FOR (i = 1 TO upd_form_cnt)
  SET tmp_rule_cnt = size(updrulesreq->forms[i].rules,5)
  IF (tmp_rule_cnt > 0)
   SET tmprulesreq->cdi_form_id = updrulesreq->forms[i].cdi_form_id
   SET stat = alterlist(tmprulesreq->rules,tmp_rule_cnt)
   FOR (j = 1 TO tmp_rule_cnt)
     SET tmprulesreq->rules[j].cdi_form_rule_id = updrulesreq->forms[i].rules[j].cdi_form_rule_id
     SET tmprulesreq->rules[j].required_ind = updrulesreq->forms[i].rules[j].required_ind
     SET tmprulesreq->rules[j].delete_ind = updrulesreq->forms[i].rules[j].delete_ind
     SET tmprulesreq->rules[j].rule_name = updrulesreq->forms[i].rules[j].rule_name
     SET n = size(updrulesreq->forms[i].rules[j].criteria,5)
     SET stat = alterlist(tmprulesreq->rules[j].criteria,n)
     FOR (k = 1 TO n)
       SET tmprulesreq->rules[j].criteria[k].cdi_form_criteria_id = updrulesreq->forms[i].rules[j].
       criteria[k].cdi_form_criteria_id
       SET tmprulesreq->rules[j].criteria[k].variable_cd = updrulesreq->forms[i].rules[j].criteria[k]
       .variable_cd
       SET tmprulesreq->rules[j].criteria[k].comparison_flag = updrulesreq->forms[i].rules[j].
       criteria[k].comparison_flag
       SET tmprulesreq->rules[j].criteria[k].value_type_flag = updrulesreq->forms[i].rules[j].
       criteria[k].value_type_flag
       SET tmprulesreq->rules[j].criteria[k].value_cd = updrulesreq->forms[i].rules[j].criteria[k].
       value_cd
       SET tmprulesreq->rules[j].criteria[k].value_nbr = updrulesreq->forms[i].rules[j].criteria[k].
       value_nbr
       SET tmprulesreq->rules[j].criteria[k].value_dt_tm = updrulesreq->forms[i].rules[j].criteria[k]
       .value_dt_tm
       SET tmprulesreq->rules[j].criteria[k].value_text = updrulesreq->forms[i].rules[j].criteria[k].
       value_text
       SET tmprulesreq->rules[j].criteria[k].delete_ind = updrulesreq->forms[i].rules[j].criteria[k].
       delete_ind
     ENDFOR
   ENDFOR
   SET modify = nopredeclare
   EXECUTE cdi_upd_form_rules  WITH replace("REQUEST",tmprulesreq), replace("REPLY",tmprulesreply)
   SET modify = predeclare
   IF ((tmprulesreply->status_data.status != "S"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "CDI_UPD_FORM_RULES"
    SET reply->status_data.subeventstatus[1].targetobjectname = tmprulesreply->status_data.
    subeventstatus[1].targetobjectname
    SET reply->status_data.subeventstatus[1].targetobjectvalue = tmprulesreply->status_data.
    subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (debug_messages=1)
  CALL echo(build2("* cdi_import_forms reply status = ",reply->status_data.status))
 ENDIF
 IF ((((reply->status_data.status="S")) OR ((reply->status_data.status="P"))) )
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
