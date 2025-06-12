CREATE PROGRAM bed_aud_iview_assays_pforms:dba
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
     2 event_cd = f8
     2 iviews[*]
       3 event_code_disp = vc
       3 event_set_name = vc
       3 iview_disp = vc
       3 iview_section_disp = vc
       3 iview_section_name = vc
       3 iview_item_disp = vc
     2 pforms[*]
       3 form_desc = vc
       3 form_def = vc
       3 section_desc = vc
       3 section_def = vc
 )
 SET stat = alterlist(reply->collist,12)
 SET reply->collist[1].header_text = "Assay Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Form Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Form Definition"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Section Description"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Section Definition"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Event Code Display"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Event Set Name"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Interactive View"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Interactive View Section Display"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Interactive View Section Name"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Interactive View Item Display"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
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
   name_value_prefs nvp,
   discrete_task_assay dta
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
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
    AND nvp.parent_entity_name="DCP_INPUT_REF"
    AND nvp.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=nvp.merge_id
    AND dta.active_ind=1)
  ORDER BY cnvtupper(dta.mnemonic), dfr.description, dsr.description,
   dta.task_assay_cd, dfr.dcp_form_instance_id
  HEAD dta.task_assay_cd
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].task_assay_cd = dta
   .task_assay_cd,
   temp->tqual[tcnt].assay_display = dta.mnemonic, temp->tqual[tcnt].assay_desc = dta.description,
   temp->tqual[tcnt].event_cd = dta.event_cd,
   pcnt = 0
  HEAD dfr.dcp_form_instance_id
   pcnt = (pcnt+ 1), stat = alterlist(temp->tqual[tcnt].pforms,pcnt), temp->tqual[tcnt].pforms[pcnt].
   form_desc = dfr.description,
   temp->tqual[tcnt].pforms[pcnt].form_def = dfr.definition, temp->tqual[tcnt].pforms[pcnt].
   section_desc = dsr.description, temp->tqual[tcnt].pforms[pcnt].section_def = dsr.definition
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
   working_view wv,
   v500_event_set_code vesc
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
   JOIN (vesc
   WHERE cnvtupper(vesc.event_set_name)=outerjoin(cnvtupper(vec.event_set_name)))
  ORDER BY vec.event_cd_disp, wv.display_name
  HEAD d.seq
   icnt = 0
  DETAIL
   icnt = (icnt+ 1), stat = alterlist(temp->tqual[d.seq].iviews,icnt), temp->tqual[d.seq].iviews[icnt
   ].event_code_disp = vec.event_cd_disp,
   temp->tqual[d.seq].iviews[icnt].event_set_name = vec.event_set_name, temp->tqual[d.seq].iviews[
   icnt].iview_disp = wv.display_name, temp->tqual[d.seq].iviews[icnt].iview_section_disp = wvs
   .display_name,
   temp->tqual[d.seq].iviews[icnt].iview_section_name = wvs.event_set_name, temp->tqual[d.seq].
   iviews[icnt].iview_item_disp = vesc.event_set_cd_disp
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET iviewcnt = size(temp->tqual[x].iviews,5)
   SET pformcnt = size(temp->tqual[x].pforms,5)
   IF (iviewcnt > 0
    AND pformcnt > 0)
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,12)
    SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].assay_display
    SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].assay_desc
    SET i = 0
    IF (pformcnt > 0)
     FOR (p = 1 TO pformcnt)
       SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].pforms[p].form_desc
       SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].pforms[p].form_def
       SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].pforms[p].section_desc
       SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].pforms[p].section_def
       SET i = (i+ 1)
       IF (((i < iviewcnt) OR (i=iviewcnt)) )
        SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].iviews[i].
        event_code_disp
        SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].iviews[i].
        event_set_name
        SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].iviews[i].iview_disp
        SET reply->rowlist[row_nbr].celllist[10].string_value = temp->tqual[x].iviews[i].
        iview_section_disp
        SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].iviews[i].
        iview_section_name
        SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].iviews[i].
        iview_item_disp
       ENDIF
       IF (p < pformcnt)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,12)
       ENDIF
     ENDFOR
     IF (i < iviewcnt)
      SET i = (i+ 1)
      FOR (i = i TO iviewcnt)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,12)
        SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].iviews[i].
        event_code_disp
        SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].iviews[i].
        event_set_name
        SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].iviews[i].iview_disp
        SET reply->rowlist[row_nbr].celllist[10].string_value = temp->tqual[x].iviews[i].
        iview_section_disp
        SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].iviews[i].
        iview_section_name
        SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].iviews[i].
        iview_item_disp
      ENDFOR
     ENDIF
    ELSEIF (iviewcnt > 0)
     FOR (i = 1 TO iviewcnt)
       SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].iviews[i].
       event_code_disp
       SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].iviews[i].event_set_name
       SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].iviews[i].iview_disp
       SET reply->rowlist[row_nbr].celllist[10].string_value = temp->tqual[x].iviews[i].
       iview_section_disp
       SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].iviews[i].
       iview_section_name
       SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].iviews[i].
       iview_item_disp
       IF (i < iviewcnt)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,12)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("assays_both_powerforms_and_iviews.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
