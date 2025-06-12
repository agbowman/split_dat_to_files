CREATE PROGRAM bed_aud_reg_pmlocator
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv,
    code_value_extension cve
   PLAN (cve
    WHERE cve.field_name="LOCATOR_DAYS"
     AND cve.code_set=69)
    JOIN (cv
    WHERE cv.code_value=cve.code_value
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
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
  )
 ENDIF
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Encounter Type Class (Patient Class)"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Encounter Type (Patient Type)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Number of days patient class remains on patient locator"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Last Updated By"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Last Update Date and Time"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SELECT INTO "nl:"
  cv.display_key, cv2.display, cve.field_value,
  p.name_full_formatted, cve.updt_dt_tm
  FROM code_value cv,
   code_value_extension cve,
   code_value_group cvg,
   code_value cv2,
   person p
  PLAN (cve
   WHERE cve.field_name="LOCATOR_DAYS"
    AND cve.code_set=69)
   JOIN (cv
   WHERE cv.code_value=cve.code_value
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cvg
   WHERE cvg.parent_code_value=cv.code_value)
   JOIN (cv2
   WHERE cv2.code_value=cvg.child_code_value
    AND cv2.code_set=71
    AND cv2.active_ind=1)
   JOIN (p
   WHERE p.person_id=outerjoin(cve.updt_id))
  ORDER BY cv.display_key
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,50)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=0)
    stat = alterlist(reply->rowlist,(50+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,5), reply->rowlist[cnt].celllist[1].string_value =
   cv.display, reply->rowlist[cnt].celllist[2].string_value = cv2.display,
   reply->rowlist[cnt].celllist[3].string_value = cve.field_value, reply->rowlist[cnt].celllist[4].
   string_value = p.name_full_formatted, reply->rowlist[cnt].celllist[5].string_value = format(cve
    .updt_dt_tm,";;Q")
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("erm_pmlocator.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
