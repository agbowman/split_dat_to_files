CREATE PROGRAM bed_aud_iview_last_charted:dba
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 task_assay_cd = f8
     2 assay_display = vc
     2 assay_desc = vc
     2 assay_act_type_disp = vc
     2 assay_default_type = i2
     2 event_cd = f8
     2 iview_ind = i2
     2 pforms[*]
       3 form_desc = vc
       3 form_def = vc
       3 section_desc = vc
       3 section_def = vc
       3 default_type = vc
 )
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "Assay Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay Activity Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assay Default Type for Interactive Views"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Form Description"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Form Definition"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Section Description"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Section Definition"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Assay Default Type for PowerForms"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 IF ((request->skip_volume_check_ind=0))
  SET reply->high_volume_flag = 1
  GO TO exit_script
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp1,
   name_value_prefs nvp2,
   discrete_task_assay dta,
   code_value cv
  PLAN (dfr
   WHERE dfr.active_ind=1)
   JOIN (dfd
   WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
    AND dfd.active_ind=1)
   JOIN (dsr
   WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
    AND dir.active_ind=1)
   JOIN (nvp1
   WHERE nvp1.parent_entity_id=dir.dcp_input_ref_id
    AND nvp1.parent_entity_name="DCP_INPUT_REF"
    AND nvp1.active_ind=1)
   JOIN (nvp2
   WHERE nvp2.parent_entity_id=nvp1.parent_entity_id
    AND nvp2.active_ind=1
    AND nvp2.pvc_name="default"
    AND nvp2.pvc_value IN ("2", "4"))
   JOIN (dta
   WHERE dta.task_assay_cd=nvp1.merge_id
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=outerjoin(dta.activity_type_cd)
    AND cv.active_ind=outerjoin(1))
  ORDER BY dta.mnemonic, dfr.description, dsr.description,
   dta.task_assay_cd, dfr.dcp_form_instance_id
  HEAD dta.task_assay_cd
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].task_assay_cd = dta
   .task_assay_cd,
   temp->tqual[tcnt].assay_display = dta.mnemonic, temp->tqual[tcnt].assay_desc = dta.description,
   temp->tqual[tcnt].assay_act_type_disp = cv.display,
   temp->tqual[tcnt].assay_default_type = dta.default_type_flag, temp->tqual[tcnt].event_cd = dta
   .event_cd, temp->tqual[tcnt].iview_ind = 0,
   pcnt = 0
  HEAD dfr.dcp_form_instance_id
   pcnt = (pcnt+ 1), stat = alterlist(temp->tqual[tcnt].pforms,pcnt), temp->tqual[tcnt].pforms[pcnt].
   form_desc = dfr.description,
   temp->tqual[tcnt].pforms[pcnt].form_def = dfr.definition, temp->tqual[tcnt].pforms[pcnt].
   section_desc = dsr.description, temp->tqual[tcnt].pforms[pcnt].section_def = dsr.definition,
   temp->tqual[tcnt].pforms[pcnt].default_type = nvp2.pvc_value
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   v500_event_code vec,
   working_view_item wvi,
   working_view_section wvs,
   working_view wv
  PLAN (d)
   JOIN (vec
   WHERE (vec.event_cd=temp->tqual[d.seq].event_cd))
   JOIN (wvi
   WHERE cnvtupper(wvi.primitive_event_set_name)=cnvtupper(vec.event_set_name))
   JOIN (wvs
   WHERE wvs.working_view_section_id=wvi.working_view_section_id)
   JOIN (wv
   WHERE wv.working_view_id=wvs.working_view_id
    AND wv.active_ind=1)
  DETAIL
   temp->tqual[d.seq].iview_ind = 1
  WITH nocounter
 ;end select
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   IF ((temp->tqual[x].iview_ind=1))
    SET pformcnt = size(temp->tqual[x].pforms,5)
    IF (pformcnt > 0)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].assay_display
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].assay_desc
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].assay_act_type_disp
     IF ((temp->tqual[x].assay_default_type=0))
      SET reply->rowlist[row_nbr].celllist[4].string_value = "No defaults"
     ELSEIF ((temp->tqual[x].assay_default_type=1))
      SET reply->rowlist[row_nbr].celllist[4].string_value = "Default from the reference range"
     ELSEIF ((temp->tqual[x].assay_default_type=2))
      SET reply->rowlist[row_nbr].celllist[4].string_value = "Default from the last charted value"
     ENDIF
     FOR (p = 1 TO pformcnt)
       SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].pforms[p].form_desc
       SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].pforms[p].form_def
       SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].pforms[p].section_desc
       SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].pforms[p].section_def
       IF ((temp->tqual[x].pforms[p].default_type="2"))
        SET reply->rowlist[row_nbr].celllist[9].string_value =
        "Default from last charted value - from any encounter"
       ELSEIF ((temp->tqual[x].pforms[p].default_type="4"))
        SET reply->rowlist[row_nbr].celllist[9].string_value =
        "Default from last charted value - from encounter being documented"
       ENDIF
       IF (p < pformcnt)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("assays_marked_as_default_last_charted.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
