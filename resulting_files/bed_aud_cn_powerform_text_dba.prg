CREATE PROGRAM bed_aud_cn_powerform_text:dba
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
   1 tcnt = i2
   1 tqual[*]
     2 powerform_desc = vc
     2 powerform_event_cd = f8
     2 note_type = vc
     2 text_event_cd = f8
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM dcp_forms_ref dfr
   PLAN (dfr
    WHERE dfr.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
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
  FROM dcp_forms_ref dfr,
   code_value cv1
  PLAN (dfr
   WHERE dfr.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(dfr.text_rendition_event_cd)
    AND cv1.active_ind=outerjoin(1))
  ORDER BY dfr.description
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].powerform_desc = dfr.description, temp->tqual[tcnt].powerform_event_cd = dfr
   .event_cd
   IF (cv1.display > " ")
    temp->tqual[tcnt].note_type = cv1.display
   ELSE
    temp->tqual[tcnt].note_type = "<none>"
   ENDIF
   temp->tqual[tcnt].text_event_cd = dfr.text_rendition_event_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "PowerForm Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "PowerForm Event Code"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Note Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Textual Rendition Event Code"
 SET reply->collist[4].data_type = 2
 SET reply->collist[4].hide_ind = 1
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].powerform_desc
   SET reply->rowlist[row_nbr].celllist[2].double_value = temp->tqual[x].powerform_event_cd
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].note_type
   SET reply->rowlist[row_nbr].celllist[4].double_value = temp->tqual[x].text_event_cd
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_powerform_textual_rendition.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
