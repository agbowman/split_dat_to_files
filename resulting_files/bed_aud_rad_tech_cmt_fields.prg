CREATE PROGRAM bed_aud_rad_tech_cmt_fields
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
 SET stat = alterlist(reply->collist,3)
 SET reply->collist[1].header_text = "field_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Field Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Field Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM rad_tech_field rtf
   PLAN (rtf
    WHERE rtf.active_ind=1
     AND rtf.field_id > 0)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  field_name = cnvtupper(rtf.field_desc)
  FROM rad_tech_field rtf
  PLAN (rtf
   WHERE rtf.active_ind=1
    AND rtf.field_id > 0)
  ORDER BY field_name
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,3), reply->rowlist[cnt].celllist[1].double_value =
   rtf.field_id, reply->rowlist[cnt].celllist[2].string_value = rtf.field_desc
   CASE (rtf.field_type_flag)
    OF 0:
     reply->rowlist[cnt].celllist[3].string_value = "Header"
    OF 1:
     reply->rowlist[cnt].celllist[3].string_value = "Number"
    OF 2:
     reply->rowlist[cnt].celllist[3].string_value = "Free Text"
    OF 3:
     reply->rowlist[cnt].celllist[3].string_value = "Date"
    OF 4:
     reply->rowlist[cnt].celllist[3].string_value = "Single Choice"
    OF 5:
     reply->rowlist[cnt].celllist[3].string_value = "Multiple Choice"
   ENDCASE
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radiology_technical_comment_fields.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
