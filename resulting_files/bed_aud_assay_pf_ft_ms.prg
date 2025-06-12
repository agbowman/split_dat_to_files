CREATE PROGRAM bed_aud_assay_pf_ft_ms
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE alpha = f8 WITH constant(uar_get_code_by("DISPLAYKEY",289,"ALPHA")), protect
 DECLARE multi = f8 WITH constant(uar_get_code_by("DISPLAYKEY",289,"MULTI")), protect
 DECLARE aaft = f8 WITH constant(uar_get_code_by("DISPLAYKEY",289,"ALPHAANDFREETEXT")), protect
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[1].header_text = "Assay Display Name (Mnemonic)"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay Code Value"
 SET reply->collist[3].data_type = 3
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assay Result Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Free Text on PowerForm"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Multiple Select on PowerForm"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "PowerForm Display"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "PowerForm Name (Description)"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "PowerForm Section Display"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "PowerForm Section Name (Description)"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET row_tot_cnt = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM dcp_forms_def d,
   dcp_forms_ref f,
   dcp_section_ref s,
   dcp_input_ref i,
   name_value_prefs prf,
   name_value_prefs prf2,
   discrete_task_assay dta,
   code_value cv
  PLAN (f
   WHERE f.active_ind=1)
   JOIN (d
   WHERE f.dcp_form_instance_id=d.dcp_form_instance_id
    AND d.active_ind=1)
   JOIN (s
   WHERE s.dcp_section_ref_id=d.dcp_section_ref_id
    AND s.active_ind=1)
   JOIN (i
   WHERE i.dcp_section_instance_id=s.dcp_section_instance_id
    AND i.active_ind=1
    AND i.input_type > 1)
   JOIN (prf
   WHERE i.dcp_input_ref_id=prf.parent_entity_id
    AND cnvtupper(prf.parent_entity_name)="DCP_INPUT_REF"
    AND prf.active_ind=1
    AND prf.pvc_name="discrete_task_assay")
   JOIN (prf2
   WHERE i.dcp_input_ref_id=prf2.parent_entity_id
    AND cnvtupper(prf2.parent_entity_name)="DCP_INPUT_REF"
    AND prf2.active_ind=1
    AND prf2.pvc_name IN ("freetext", "multi_select")
    AND prf2.pvc_value="true")
   JOIN (dta
   WHERE prf.merge_id=dta.task_assay_cd
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.default_result_type_cd
    AND cv.active_ind=1)
  ORDER BY cnvtupper(dta.mnemonic), f.description, s.description
  HEAD dta.mnemonic
   tmp = 0
  HEAD f.description
   tmp1 = 0
  HEAD s.description
   f = 0, freetext = 0, multiselect = 0
  DETAIL
   IF (prf2.pvc_name="freetext")
    freetext = 1
    IF (((dta.default_result_type_cd=alpha) OR (dta.default_result_type_cd=multi)) )
     f = 1
    ENDIF
   ENDIF
   IF (prf2.pvc_name="multi_select")
    multiselect = 1
    IF (((dta.default_result_type_cd=alpha) OR (dta.default_result_type_cd=aaft)) )
     f = 1
    ENDIF
   ENDIF
  FOOT  s.description
   IF (f > 0)
    row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat =
    alterlist(reply->rowlist[row_tot_cnt].celllist,10),
    reply->rowlist[row_tot_cnt].celllist[1].string_value = dta.mnemonic, reply->rowlist[row_tot_cnt].
    celllist[2].string_value = dta.description, reply->rowlist[row_tot_cnt].celllist[3].nbr_value =
    dta.task_assay_cd,
    reply->rowlist[row_tot_cnt].celllist[4].string_value = cv.display
    IF (freetext=1)
     reply->rowlist[row_tot_cnt].celllist[5].string_value = "X"
    ELSE
     reply->rowlist[row_tot_cnt].celllist[5].string_value = " "
    ENDIF
    IF (multiselect=1)
     reply->rowlist[row_tot_cnt].celllist[6].string_value = "X"
    ELSE
     reply->rowlist[row_tot_cnt].celllist[6].string_value = " "
    ENDIF
    reply->rowlist[row_tot_cnt].celllist[7].string_value = f.description, reply->rowlist[row_tot_cnt]
    .celllist[8].string_value = f.definition, reply->rowlist[row_tot_cnt].celllist[9].string_value =
    s.description,
    reply->rowlist[row_tot_cnt].celllist[10].string_value = s.definition
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("rowcnt",row_tot_cnt))
 IF ((request->skip_volume_check_ind=0))
  IF (tcnt > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->collist,0)
   SET stat = alterlist(reply->rowlist,0)
   SET reply->output_filename = build("assay_pf_ft_ms.csv")
  ENDIF
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
