CREATE PROGRAM bed_aud_sch_instructions
 DECLARE high_volume_cnt = i2 WITH protect
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
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Prep or Post"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Text"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Last Updated By"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM sch_template s
   PLAN (s
    WHERE ((s.text_type_meaning="PREAPPT") OR (s.text_type_meaning="POSTAPPT"
     AND s.active_ind=1)) )
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE formatted_instructions = vc
 SELECT INTO "nl:"
  FROM sch_template s,
   long_text_reference l,
   prsnl p
  PLAN (s
   WHERE ((s.text_type_meaning="PREAPPT") OR (s.text_type_meaning="POSTAPPT"))
    AND s.active_ind=1)
   JOIN (l
   WHERE s.text_id=l.long_text_id
    AND l.active_ind=1)
   JOIN (p
   WHERE p.person_id=l.updt_id)
  ORDER BY s.text_type_meaning, s.mnemonic
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,15)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,15)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,4), reply->rowlist[cnt].celllist[1].string_value = s
   .mnemonic
   CASE (s.text_type_meaning)
    OF "PREAPPT":
     reply->rowlist[cnt].celllist[2].string_value = "Prep"
    OF "POSTAPPT":
     reply->rowlist[cnt].celllist[2].string_value = "Post"
   ENDCASE
   formatted_instructions = replace(l.long_text,char(13),""), formatted_instructions = replace(
    formatted_instructions,char(10),""), reply->rowlist[cnt].celllist[3].string_value =
   formatted_instructions,
   reply->rowlist[cnt].celllist[4].string_value = p.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH noheading, nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("sch_instructions.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
