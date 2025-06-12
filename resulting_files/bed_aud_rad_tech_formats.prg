CREATE PROGRAM bed_aud_rad_tech_formats
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
 DECLARE radiology_type_cd = f8
 DECLARE bill_only_cd = f8
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "format_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Format Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "field_id"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Fields"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Field Chartable"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Required Field"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Number Range"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM rad_tech_format rtf
   PLAN (rtf
    WHERE rtf.active_ind=1
     AND rtf.format_id > 0)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  rtf.format_id, rtf.format_desc, rtfield.field_id,
  rtfield.field_desc, rtffr.chartable_ind, rtffr.chartable_ind,
  rtffr.max_nbr, rtffr.min_nbr
  FROM rad_tech_format rtf,
   rad_tech_fld_fmt_r rtffr,
   rad_tech_field rtfield
  PLAN (rtf
   WHERE rtf.active_ind=1
    AND rtf.format_id > 0)
   JOIN (rtffr
   WHERE rtffr.format_id=rtf.format_id
    AND rtffr.active_ind=1)
   JOIN (rtfield
   WHERE rtfield.field_id=rtffr.field_id
    AND rtfield.active_ind=1)
  ORDER BY rtf.format_desc, rtffr.sequence
  HEAD REPORT
   cnt = 0, end_cnt = 0, stat = alterlist(reply->rowlist,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(reply->rowlist,(10+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,7), reply->rowlist[cnt].celllist[1].double_value =
   rtf.format_id, reply->rowlist[cnt].celllist[2].string_value = rtf.format_desc,
   reply->rowlist[cnt].celllist[3].double_value = rtfield.field_id, reply->rowlist[cnt].celllist[4].
   string_value = rtfield.field_desc
   CASE (rtffr.chartable_ind)
    OF 0:
     reply->rowlist[cnt].celllist[5].string_value = "N"
    OF 1:
     reply->rowlist[cnt].celllist[5].string_value = "Y"
   ENDCASE
   CASE (rtffr.required_ind)
    OF 0:
     reply->rowlist[cnt].celllist[6].string_value = "N"
    OF 1:
     reply->rowlist[cnt].celllist[6].string_value = "Y"
   ENDCASE
   IF ((rtffr.min_nbr != - (999))
    AND (rtffr.max_nbr != - (999))
    AND rtffr.max_nbr != 0)
    reply->rowlist[cnt].celllist[7].string_value = build(cnvtint(rtffr.min_nbr),"-",cnvtint(rtffr
      .max_nbr))
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radiology_tech_formats.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
