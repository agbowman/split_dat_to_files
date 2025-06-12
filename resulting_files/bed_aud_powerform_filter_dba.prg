CREATE PROGRAM bed_aud_powerform_filter:dba
 IF ( NOT (validate(request,0)))
  FREE SET request
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 powerforms[*]
      2 powerform_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
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
   1 dtas[*]
     2 form_id = f8
     2 form_description = vc
     2 section_id = f8
     2 section_description = vc
     2 dta_id = f8
     2 dta_mnemonic = vc
     2 dta_result_type_display = vc
     2 dta_default_value = vc
     2 dta_offset_min_nbr = i4
     2 dta_single_select_ind = vc
     2 dta_required = vc
     2 dcp_input_ref_id = f8
 )
 DECLARE tot_col = i4 WITH protect, constant(8)
 SET stat = alterlist(reply->collist,tot_col)
 SET reply->collist[1].header_text = "PowerForm Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Section Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "DTA Mnemonic"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "DTA Result Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Default Value"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Look Back Minutes"
 SET reply->collist[6].data_type = 3
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "First Alpha Single Select"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Required Field"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET cnt = size(request->powerforms,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE dta_cnt = i4 WITH protect, noconstant(10)
 DECLARE total_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   dcp_forms_ref fr,
   dcp_forms_def fd,
   dcp_forms_ref fr2,
   dcp_section_ref r,
   dcp_input_ref i,
   name_value_prefs n,
   discrete_task_assay t
  PLAN (d)
   JOIN (fr
   WHERE (fr.dcp_forms_ref_id=request->powerforms[d.seq].powerform_id)
    AND fr.active_ind=1)
   JOIN (fd
   WHERE fd.dcp_forms_ref_id=fr.dcp_forms_ref_id
    AND fd.active_ind=1)
   JOIN (fr2
   WHERE fr2.dcp_form_instance_id=fd.dcp_form_instance_id
    AND fr2.active_ind=1)
   JOIN (r
   WHERE r.dcp_section_ref_id=fd.dcp_section_ref_id
    AND r.active_ind=1
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (i
   WHERE i.dcp_section_instance_id=r.dcp_section_instance_id
    AND i.dcp_section_ref_id=r.dcp_section_ref_id
    AND i.active_ind=1)
   JOIN (n
   WHERE n.parent_entity_id=i.dcp_input_ref_id
    AND n.parent_entity_name="DCP_INPUT_REF"
    AND n.pvc_name="discrete_task_assay"
    AND ((n.active_ind+ 0)=1))
   JOIN (t
   WHERE t.task_assay_cd=n.merge_id)
  ORDER BY cnvtupper(fr.description), fd.section_seq, i.input_ref_seq
  HEAD REPORT
   stat = alterlist(temp->dtas,dta_cnt)
  DETAIL
   total_cnt = (total_cnt+ 1)
   IF (total_cnt=dta_cnt)
    dta_cnt = (dta_cnt+ 10), stat = alterlist(temp->dtas,dta_cnt)
   ENDIF
   temp->dtas[total_cnt].form_id = fr.dcp_forms_ref_id, temp->dtas[total_cnt].form_description = fr
   .description, temp->dtas[total_cnt].section_id = r.dcp_section_ref_id,
   temp->dtas[total_cnt].section_description = r.description, temp->dtas[total_cnt].dta_id = t
   .task_assay_cd, temp->dtas[total_cnt].dta_mnemonic = t.mnemonic,
   temp->dtas[total_cnt].dta_result_type_display = uar_get_code_display(t.default_result_type_cd),
   temp->dtas[total_cnt].dcp_input_ref_id = i.dcp_input_ref_id, temp->dtas[total_cnt].
   dta_default_value = "No default value",
   temp->dtas[total_cnt].dta_single_select_ind = ""
  WITH nocounter
 ;end select
 IF (total_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(total_cnt)),
   dta_offset_min m
  PLAN (d)
   JOIN (m
   WHERE (m.task_assay_cd=temp->dtas[d.seq].dta_id))
  DETAIL
   temp->dtas[d.seq].dta_offset_min_nbr = m.offset_min_nbr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(total_cnt)),
   name_value_prefs n
  PLAN (d)
   JOIN (n
   WHERE n.parent_entity_name="DCP_INPUT_REF"
    AND (n.parent_entity_id=temp->dtas[d.seq].dcp_input_ref_id)
    AND trim(n.pvc_name)="required"
    AND ((n.active_ind+ 0)=1))
  DETAIL
   IF (n.pvc_value="true")
    temp->dtas[d.seq].dta_required = "Yes"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(total_cnt)),
   name_value_prefs n
  PLAN (d)
   JOIN (n
   WHERE n.parent_entity_name="DCP_INPUT_REF"
    AND (n.parent_entity_id=temp->dtas[d.seq].dcp_input_ref_id)
    AND trim(n.pvc_name) IN ("default", "date_time_default")
    AND ((n.active_ind+ 0)=1))
  DETAIL
   IF (n.pvc_name="date_time_default")
    CASE (n.pvc_value)
     OF "1":
      temp->dtas[d.seq].dta_default_value = "Default from last charted value - From Any Encounter"
     OF "2":
      temp->dtas[d.seq].dta_default_value = "Default to current date/time"
     OF "4":
      temp->dtas[d.seq].dta_default_value =
      "Default from last charted value - From Encounter Being Documented"
    ENDCASE
   ELSE
    CASE (n.pvc_value)
     OF "1":
      IF ((((temp->dtas[d.seq].dta_result_type_display="Freetext")) OR ((temp->dtas[d.seq].
      dta_result_type_display="Date"))) )
       temp->dtas[d.seq].dta_default_value = "Default from last charted value - From Any Encounter"
      ELSE
       temp->dtas[d.seq].dta_default_value = "Default from reference range"
      ENDIF
     OF "2":
      IF ((temp->dtas[d.seq].dta_result_type_display="Freetext"))
       temp->dtas[d.seq].dta_default_value = "Custom default value"
      ELSE
       IF ((temp->dtas[d.seq].dta_result_type_display="Date"))
        temp->dtas[d.seq].dta_default_value = "Default to current date/time"
       ELSE
        temp->dtas[d.seq].dta_default_value = "Default from last charted value - From Any Encounter"
       ENDIF
      ENDIF
     OF "3":
      IF ((temp->dtas[d.seq].dta_result_type_display="Freetext"))
       temp->dtas[d.seq].dta_default_value = "Default from template"
      ELSE
       temp->dtas[d.seq].dta_default_value = "User interpretation"
      ENDIF
     OF "4":
      temp->dtas[d.seq].dta_default_value =
      "Default from last charted value - From Encounter Being Documented"
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(total_cnt)),
   name_value_prefs n1,
   name_value_prefs n2
  PLAN (d)
   JOIN (n1
   WHERE n1.parent_entity_name="DCP_INPUT_REF"
    AND (n1.parent_entity_id=temp->dtas[d.seq].dcp_input_ref_id)
    AND trim(n1.pvc_name)="multi_select"
    AND n1.pvc_value="true"
    AND ((n1.active_ind+ 0)=1))
   JOIN (n2
   WHERE n2.parent_entity_name="DCP_INPUT_REF"
    AND (n2.parent_entity_id=temp->dtas[d.seq].dcp_input_ref_id)
    AND trim(n2.pvc_name)="exclude_first_ar"
    AND n2.pvc_value="true"
    AND ((n2.active_ind+ 0)=1))
  DETAIL
   temp->dtas[d.seq].dta_single_select_ind = "Yes"
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->rowlist,total_cnt)
 DECLARE index = i4 WITH protect, noconstant(0)
 FOR (index = 1 TO total_cnt)
   SET stat = alterlist(reply->rowlist[index].celllist,tot_col)
   SET reply->rowlist[index].celllist[1].string_value = temp->dtas[index].form_description
   SET reply->rowlist[index].celllist[2].string_value = temp->dtas[index].section_description
   SET reply->rowlist[index].celllist[3].string_value = temp->dtas[index].dta_mnemonic
   SET reply->rowlist[index].celllist[4].string_value = temp->dtas[index].dta_result_type_display
   SET reply->rowlist[index].celllist[5].string_value = temp->dtas[index].dta_default_value
   SET reply->rowlist[index].celllist[6].nbr_value = temp->dtas[index].dta_offset_min_nbr
   SET reply->rowlist[index].celllist[7].string_value = temp->dtas[index].dta_single_select_ind
   SET reply->rowlist[index].celllist[8].string_value = temp->dtas[index].dta_required
 ENDFOR
 IF ((request->skip_volume_check_ind=0))
  IF (total_cnt > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (total_cnt > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->run_status_flag = 1
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("powerform_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
