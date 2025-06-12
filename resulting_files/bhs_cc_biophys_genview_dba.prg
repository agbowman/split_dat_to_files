CREATE PROGRAM bhs_cc_biophys_genview:dba
 FREE RECORD pt_ed_req
 RECORD pt_ed_req(
   1 person[1]
     2 person_id = f8
   1 visit[1]
     2 encntr_id = f8
 )
 RECORD pt_ed_reply(
   1 text = vc
 )
 FREE RECORD work
 RECORD work(
   1 form_desc = vc
   1 dcp_forms_ref_id = f8
   1 s_cnt = i4
   1 sections[*]
     2 dcp_forms_act_id = f8
     2 dcp_section_ref_id = f8
     2 section_disp = vc
     2 result_dt_tm = vc
     2 new_entry = i2
 )
 RECORD reply(
   1 text = vc
 )
 DECLARE var_output = vc
 DECLARE cs8_inerror_cd = f8
 DECLARE cs53_grp_cd = f8
 DECLARE cs18189_clinicalevent_cd = f8
 DECLARE tmp_num = i4
 DECLARE get_data_string = vc
 DECLARE beg_doc = vc
 DECLARE end_doc = vc
 DECLARE newline = vc
 DECLARE beg_tbl_row = vc
 DECLARE cell_padding = vc
 DECLARE cell_margin = vc
 DECLARE left_align = vc
 DECLARE cell_1_size = vc
 DECLARE cell_2_size = vc
 DECLARE beg_tbl_text = vc
 DECLARE end_cell = vc
 DECLARE end_row = vc
 SET cs8_inerror_cd = uar_get_code_by("DISPLAYKEY",8,"INERROR")
 SET cs53_grp_cd = uar_get_code_by("MEANING",53,"GRP")
 SET cs18189_clinicalevent_cd = uar_get_code_by("MEANING",18189,"CLINCALEVENT")
 SET beg_doc = "{\rtf1\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Tahoma;}}"
 SET end_para = "\pard "
 SET end_doc = "}"
 SET newline = concat(char(10),char(13))
 SET beg_tbl_row = "\trowd "
 SET cell_padding = "\trgaph108 "
 SET cell_margin = "\trleft108 "
 SET left_align = "\ql "
 SET cell_1_size = "\cellx4000 "
 SET cell_2_size = "\cellx12000 "
 SET beg_tbl_text = "\intbl "
 SET end_cell = "\cell "
 SET end_row = "\row "
 IF (reflect(parameter(1,0)) > " ")
  SET var_output = trim(build( $1),3)
 ENDIF
 IF (reflect(parameter(2,0)) > " ")
  SET pt_ed_req->visit[1].encntr_id = cnvtreal( $2)
 ELSEIF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET pt_ed_req->visit[1].encntr_id = request->visit[1].encntr_id
 ELSE
  CALL echo("No ENCNTR_ID given. Exitting Script")
  GO TO exit_script
 ENDIF
 SET work->form_desc = "Biophysical Assessment"
 SELECT INTO "NL:"
  e.person_id
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=pt_ed_req->visit[1].encntr_id))
  DETAIL
   pt_ed_req->person[1].person_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM dcp_forms_activity dfa,
   dcp_forms_ref dfr,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   dcp_section_ref dsr,
   dcp_forms_def dfd
  PLAN (dfa
   WHERE (dfa.encntr_id=pt_ed_req->visit[1].encntr_id)
    AND (dfa.description=work->form_desc))
   JOIN (dfr
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.version_dt_tm BETWEEN dfr.beg_effective_dt_tm AND dfr.end_effective_dt_tm)
   JOIN (dfac
   WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id
    AND dfac.parent_entity_name="CLINICAL_EVENT"
    AND dfac.component_cd=cs18189_clinicalevent_cd)
   JOIN (ce
   WHERE dfac.parent_entity_id=ce.parent_event_id
    AND ce.event_class_cd=cs53_grp_cd
    AND dfac.parent_entity_id != ce.event_id
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime3))
   JOIN (dsr
   WHERE cnvtreal(ce.collating_seq)=dsr.dcp_section_ref_id
    AND ce.performed_dt_tm BETWEEN dsr.beg_effective_dt_tm AND dsr.end_effective_dt_tm)
   JOIN (dfd
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dsr.dcp_section_ref_id=dfd.dcp_section_ref_id)
  ORDER BY dfa.dcp_forms_activity_id, dfd.section_seq, ce.event_end_dt_tm DESC,
   ce.clinical_event_id
  HEAD REPORT
   found_ind = 0, s_cnt = 0
  HEAD ce.clinical_event_id
   work->dcp_forms_ref_id = dfa.dcp_forms_ref_id, found_ind = 0
   IF ((work->s_cnt > 0))
    FOR (s = 1 TO work->s_cnt)
      IF ((work->sections[s].dcp_forms_act_id=dfa.dcp_forms_activity_id)
       AND (work->sections[s].dcp_section_ref_id=dsr.dcp_section_ref_id))
       found_ind = 1
      ENDIF
    ENDFOR
   ENDIF
   IF (found_ind=0)
    s_cnt = (work->s_cnt+ 1), stat = alterlist(work->sections,s_cnt), work->s_cnt = s_cnt,
    work->sections[s_cnt].dcp_forms_act_id = dfa.dcp_forms_activity_id, work->sections[s_cnt].
    dcp_section_ref_id = dsr.dcp_section_ref_id, work->sections[s_cnt].section_disp = trim(ce
     .event_title_text,3),
    work->sections[s_cnt].result_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YYYY HH:MM;;D")
   ENDIF
  WITH nocounter
 ;end select
 IF ((work->s_cnt=0))
  SET reply->text = build2(beg_doc,"\fs20  No ",work->form_desc," information",end_doc)
  GO TO print_output
 ENDIF
 SET reply->text = build2(beg_doc,"\fs20\b\ul Biophysical Assessment\b0\ul0\par",newline)
 SET reply->text = build2(reply->text,beg_tbl_row,cell_padding,cell_margin)
 SET reply->text = build2(reply->text,cell_1_size,cell_2_size,end_para)
 FOR (s = 1 TO work->s_cnt)
  SET reply->text = build2(reply->text,beg_tbl_text,left_align," ",work->sections[s].section_disp,
   end_cell)
  SET reply->text = build2(reply->text,left_align," ",work->sections[s].result_dt_tm,end_cell,
   end_row)
 ENDFOR
 SET reply->text = build2(reply->text,end_para,newline)
 FOR (cnt_s = 1 TO work->s_cnt)
   EXECUTE bhs_rw_get_powerform_data work->dcp_forms_ref_id, work->sections[cnt_s].dcp_section_ref_id,
   0,
   pt_ed_req->person[1].person_id, pt_ed_req->visit[1].encntr_id, work->sections[cnt_s].
   dcp_forms_act_id WITH replace(request,pt_ed_req), replace(reply,pt_ed_reply)
   SET reply->text = build2(reply->text,pt_ed_reply->text,newline)
   SET pt_ed_reply->text = " "
 ENDFOR
 SET reply->text = build2(reply->text,end_doc)
#print_output
 IF (trim(var_output,3) > " ")
  SELECT INTO value(var_output)
   FROM dummyt d
   DETAIL
    reply->text
   WITH nocounter, maxcol = 32000, maxrow = 1,
    formfeed = none, format = variable
  ;end select
 ENDIF
#exit_script
END GO
