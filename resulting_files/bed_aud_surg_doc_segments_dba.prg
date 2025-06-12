CREATE PROGRAM bed_aud_surg_doc_segments:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 staging_areas[*]
      2 code_value = f8
    1 include_inactive_segments_ind = i2
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
     2 seg_cd = f8
     2 surgical_area = vc
     2 staging_area = vc
     2 segment_name = vc
     2 active_ind = i2
     2 required_ind = i2
     2 allow_defaults_ind = i2
     2 elec_sig_ind = i2
     2 display_seq = i4
     2 print_seq = i4
     2 associated_form = vc
     2 input_form_cd = f8
     2 multi_entry_form_ind = i2
     2 execution[*]
       3 exec_seq = i4
 )
 DECLARE sr_parse = vc
 IF ((request->include_inactive_segments_ind=1))
  SET sr_parse = "sr.active_ind in (1,0)"
 ELSE
  SET sr_parse = "sr.active_ind = 1"
 ENDIF
 DECLARE sdr_parse = vc
 SET sdr_parse = "sdr.area_cd = sr.surg_area_cd and sdr.doc_type_cd = sr.doc_type_cd"
 SET scnt = size(request->staging_areas,5)
 IF (scnt > 0)
  SET sdr_parse = build2(sdr_parse," and sdr.stage_cd in (")
  FOR (s = 1 TO scnt)
    IF (s=1)
     SET sdr_parse = build2(sdr_parse,cnvtstring(request->staging_areas[s].code_value))
    ELSE
     SET sdr_parse = build2(sdr_parse,",",cnvtstring(request->staging_areas[s].code_value))
    ENDIF
  ENDFOR
  SET sdr_parse = build2(sdr_parse,")")
 ENDIF
 DECLARE cv3_parse = vc
 IF ((request->include_inactive_segments_ind=1))
  SET cv3_parse = "cv3.active_ind in (1,0)"
 ELSE
  SET cv3_parse = "cv3.active_ind = 1"
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "NL:"
   FROM segment_reference sr,
    sn_doc_ref sdr,
    code_value cv1,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (sr
    WHERE parser(sr_parse))
    JOIN (sdr
    WHERE parser(sdr_parse))
    JOIN (cv1
    WHERE cv1.code_value=sr.surg_area_cd
     AND cv1.active_ind=1)
    JOIN (cv3
    WHERE cv3.code_value=sr.seg_cd
     AND parser(cv3_parse))
    JOIN (cv4
    WHERE cv4.code_value=sr.input_form_cd
     AND cv4.active_ind=1)
    JOIN (cv5
    WHERE cv5.code_value=sdr.stage_cd
     AND cv5.active_ind=1)
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1)
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM segment_reference sr,
   sn_doc_ref sdr,
   code_value cv1,
   code_value cv3,
   code_value cv4,
   code_value cv5
  PLAN (sr
   WHERE parser(sr_parse))
   JOIN (sdr
   WHERE parser(sdr_parse))
   JOIN (cv1
   WHERE cv1.code_value=sr.surg_area_cd
    AND cv1.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=sr.seg_cd
    AND parser(cv3_parse))
   JOIN (cv4
   WHERE cv4.code_value=sr.input_form_cd
    AND cv4.active_ind=1)
   JOIN (cv5
   WHERE cv5.code_value=sdr.stage_cd
    AND cv5.active_ind=1)
  ORDER BY cv1.display, sr.seg_grp_cd, sr.seg_seq
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].seg_cd = sr.seg_cd,
   temp->tqual[tcnt].surgical_area = cv1.display, temp->tqual[tcnt].staging_area = cv5.display, temp
   ->tqual[tcnt].segment_name = cv3.display,
   temp->tqual[tcnt].active_ind = sr.active_ind, temp->tqual[tcnt].required_ind = sr.seg_req_flag,
   temp->tqual[tcnt].allow_defaults_ind = sr.pref_card_defaults_ind,
   temp->tqual[tcnt].elec_sig_ind = sr.signature_flag, temp->tqual[tcnt].display_seq = sr.seg_seq,
   temp->tqual[tcnt].print_seq = sr.print_seq,
   temp->tqual[tcnt].associated_form = cv4.display, temp->tqual[tcnt].input_form_cd = sr
   .input_form_cd
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   seg_grp_seq_r sg
  PLAN (d)
   JOIN (sg
   WHERE (sg.seg_cd=temp->tqual[d.seq].seg_cd))
  HEAD d.seq
   ecnt = 0
  DETAIL
   ecnt = (ecnt+ 1), stat = alterlist(temp->tqual[d.seq].execution,ecnt), temp->tqual[d.seq].
   execution[ecnt].exec_seq = sg.execute_seq
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   input_form_reference ifr
  PLAN (d)
   JOIN (ifr
   WHERE (ifr.input_form_cd=temp->tqual[d.seq].input_form_cd)
    AND ifr.active_ind=1)
  DETAIL
   IF (ifr.repeat_ind=1)
    temp->tqual[d.seq].multi_entry_form_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,12)
 SET reply->collist[1].header_text = "Surgical Area"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Staging Area"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Segment Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Active"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Required"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Allow Defaults"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Electronic Signature"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Display Sequence"
 SET reply->collist[8].data_type = 3
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Execution Sequence"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Print Sequence"
 SET reply->collist[10].data_type = 3
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Associated Form"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Multi-Entry Form"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE exec_string = vc
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,12)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].surgical_area
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].staging_area
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].segment_name
   IF ((temp->tqual[x].active_ind=1))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "Yes"
   ELSE
    SET reply->rowlist[row_nbr].celllist[4].string_value = "No"
   ENDIF
   IF ((temp->tqual[x].required_ind=2))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "Yes"
   ELSE
    SET reply->rowlist[row_nbr].celllist[5].string_value = "No"
   ENDIF
   IF ((temp->tqual[x].allow_defaults_ind=1))
    SET reply->rowlist[row_nbr].celllist[6].string_value = "Yes"
   ELSE
    SET reply->rowlist[row_nbr].celllist[6].string_value = "No"
   ENDIF
   IF ((temp->tqual[x].elec_sig_ind=1))
    SET reply->rowlist[row_nbr].celllist[7].string_value = "Allowed"
   ELSEIF ((temp->tqual[x].elec_sig_ind=2))
    SET reply->rowlist[row_nbr].celllist[7].string_value = "Required"
   ELSE
    SET reply->rowlist[row_nbr].celllist[7].string_value = "None"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[8].nbr_value = temp->tqual[x].display_seq
   SET exec_string = " "
   SET ecnt = size(temp->tqual[x].execution,5)
   FOR (e = 1 TO ecnt)
     IF (e=1)
      SET exec_string = trim(cnvtstring(temp->tqual[x].execution[e].exec_seq))
     ELSE
      SET exec_string = build2(exec_string," ,",trim(cnvtstring(temp->tqual[x].execution[e].exec_seq)
        ))
     ENDIF
   ENDFOR
   SET reply->rowlist[row_nbr].celllist[9].string_value = exec_string
   SET reply->rowlist[row_nbr].celllist[10].nbr_value = temp->tqual[x].print_seq
   SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].associated_form
   IF ((temp->tqual[x].multi_entry_form_ind=1))
    SET reply->rowlist[row_nbr].celllist[12].string_value = "Yes"
   ELSE
    SET reply->rowlist[row_nbr].celllist[12].string_value = "No"
   ENDIF
 ENDFOR
#exit_script
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("surg_doc_segments.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
