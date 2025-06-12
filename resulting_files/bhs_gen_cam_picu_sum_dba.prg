CREATE PROGRAM bhs_gen_cam_picu_sum:dba
 RECORD work(
   1 person_id = f8
   1 encntr_id = f8
   1 f_cnt = i4
   1 forms[*]
     2 dcp_forms_activity_id = f8
     2 reference_nbr = vc
     2 form_dt_tm = dq8
   1 e_cnt = i4
   1 entries[*]
     2 clinical_event_id = f8
     2 prsnl_name = vc
     2 entry_dt_tm = dq8
     2 entry_title = vc
     2 entry_text = vc
   1 reply_text = vc
   1 entries_used = i4
 )
 DECLARE var_output = vc
 IF (reflect(parameter(1,0)) > " ")
  SET var_output = trim(build( $1),3)
 ENDIF
 IF (reflect(parameter(2,0)) > " ")
  SET work->encntr_id = cnvtreal( $2)
 ELSEIF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET work->encntr_id = request->visit[1].encntr_id
 ELSE
  CALL echo("No encntr_id given. Exitting script")
  GO TO exit_script
 ENDIF
 RECORD reply(
   1 text = vc
 )
 DECLARE beg_doc = vc WITH constant(
  "{\rtf1\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 tahoma;}}\f0\fs20")
 DECLARE beg_bold = vc WITH constant("\b ")
 DECLARE end_bold = vc WITH constant("\b0 ")
 DECLARE end_line = vc WITH constant("\par ")
 DECLARE end_para = vc WITH constant("\pard ")
 DECLARE end_doc = vc WITH constant("}")
 DECLARE newline = vc WITH constant(concat(char(10),char(13)))
 DECLARE tmp_reply_text = vc
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs120_no_compression_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE cs120_ocf_compression_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE cs14003_cam_icu_summary_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,
   "PCAMICUSUMMARY"))
 DECLARE var_warning = vc WITH noconstant(build2(beg_bold,
   " The last beg_num out of end_num entries shown.",end_bold,end_line,newline,
   "Please use the flowsheet to view older ",trim(uar_get_code_display(cs14003_cam_icu_summary_cd)),
   " entries.",end_line,newline,
   end_line,newline))
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (work->encntr_id=e.encntr_id))
  DETAIL
   work->person_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa
  PLAN (dfa
   WHERE (work->person_id=dfa.person_id)
    AND dfa.description="Confusion Assessment Method for Pedi ICU"
    AND dfa.flags > 0
    AND dfa.form_status_cd IN (cs8_auth_cd, cs8_altered_cd, cs8_modified_cd))
  ORDER BY dfa.form_dt_tm DESC
  DETAIL
   work->f_cnt = (work->f_cnt+ 1), stat = alterlist(work->forms,work->f_cnt), work->forms[work->f_cnt
   ].dcp_forms_activity_id = dfa.dcp_forms_activity_id,
   work->forms[work->f_cnt].reference_nbr = trim(build2(dfa.dcp_forms_activity_id,"*"),3), work->
   forms[work->f_cnt].form_dt_tm = dfa.form_dt_tm
  WITH nocounter
 ;end select
 IF ((work->f_cnt > 0))
  DECLARE dseq = i4
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(work->f_cnt)),
    clinical_event ce,
    prsnl pr,
    ce_blob cb
   PLAN (d
    WHERE initarray(dseq,d.seq))
    JOIN (ce
    WHERE operator(ce.reference_nbr,"LIKE",patstring(work->forms[dseq].reference_nbr,1))
     AND ce.task_assay_cd=cs14003_cam_icu_summary_cd
     AND ce.view_level=1
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce.result_status_cd IN (cs8_auth_cd, cs8_altered_cd, cs8_modified_cd))
    JOIN (pr
    WHERE ce.performed_prsnl_id=pr.person_id)
    JOIN (cb
    WHERE ce.event_id=cb.event_id
     AND cb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ce.event_end_dt_tm DESC
   HEAD REPORT
    tmp_f = 0
   DETAIL
    tmp_f = 1, stat = locateval(tmp_f,1,work->f_cnt,cnvtreal(substring(1,(findstring("!",ce
        .reference_nbr) - 1),ce.reference_nbr)),work->forms[tmp_f].dcp_forms_activity_id)
    IF ((work->forms[tmp_f].dcp_forms_activity_id=cnvtreal(substring(1,(findstring("!",ce
       .reference_nbr) - 1),ce.reference_nbr))))
     blob_size = cnvtint(cb.blob_length), blob_in = fillstring(64000," "), blob_out = fillstring(
      64000," "),
     blob_rtf = fillstring(64000," "), blob_ret_len = 0, blob_in = cb.blob_contents
     IF (cb.compression_cd=cs120_ocf_compression_cd)
      CALL uar_ocf_uncompress(blob_in,blob_size,blob_out,64000,blob_ret_len),
      CALL uar_rtf2(blob_out,blob_ret_len,blob_rtf,64000,blob_ret_len,1)
     ELSE
      CALL uar_rtf2(blob_in,blob_size,blob_rtf,64000,blob_ret_len,1)
     ENDIF
     e_cnt = (work->e_cnt+ 1), stat = alterlist(work->entries,e_cnt), work->e_cnt = e_cnt,
     work->entries[e_cnt].clinical_event_id = ce.event_id, work->entries[e_cnt].prsnl_name = trim(pr
      .name_full_formatted), work->entries[e_cnt].entry_dt_tm = ce.event_end_dt_tm,
     work->entries[e_cnt].entry_title = trim(ce.event_title_text,3), work->entries[e_cnt].entry_text
      = trim(blob_rtf,3)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((work->e_cnt <= 0))
  SET work->reply_text = build2(work->reply_text,beg_bold," No previous entries found",end_bold)
 ELSE
  SET tmp_e = 1
  WHILE ((tmp_e <= work->e_cnt))
    SET tmp_reply_text = build2(work->reply_text,beg_bold," ",work->entries[tmp_e].prsnl_name," on ",
     format(work->entries[tmp_e].entry_dt_tm,"mm/dd/yyyy hh:mm;;d"),":",end_bold,end_line,newline,
     work->entries[tmp_e].entry_text,end_line,newline,end_line,newline)
    IF (size(build2(beg_doc,var_warning,tmp_reply_text,end_doc)) < 32000)
     SET work->entries_used = tmp_e
     SET work->reply_text = tmp_reply_text
    ELSE
     SET work->entries_used = (tmp_e - 1)
     SET tmp_e = (work->e_cnt+ 1)
    ENDIF
    SET tmp_e = (tmp_e+ 1)
  ENDWHILE
  FREE SET tmp_e
  IF ((work->entries_used < work->e_cnt))
   SET var_warning = replace(var_warning,"beg_num",trim(build(work->entries_used)))
   SET var_warning = replace(var_warning,"end_num",trim(build(work->e_cnt)))
   SET work->reply_text = build2(beg_doc,var_warning,work->reply_text,end_doc)
  ELSE
   SET work->reply_text = build2(beg_doc,work->reply_text,end_doc)
  ENDIF
 ENDIF
 SET reply->text = work->reply_text
#exit_script
 IF (var_output > " ")
  CALL echorecord(work)
  CALL echo(size(work->reply_text))
  CALL echo(work->reply_text)
 ENDIF
END GO
