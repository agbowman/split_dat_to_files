CREATE PROGRAM bed_aud_ap_specimen_list
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
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Specimen Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Specimen Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Specimen Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Prefix"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Active Indicator"
 SET reply->collist[5].data_type = 3
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Last Update By"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=1306)
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
 SELECT INTO "nl:"
  FROM code_value cv,
   specimen_grouping_r sgr,
   ap_prefix ap,
   code_value cv2,
   prsnl p,
   dummyt d
  PLAN (cv
   WHERE cv.code_set=1306)
   JOIN (p
   WHERE p.person_id=cv.updt_id)
   JOIN (d)
   JOIN (sgr
   WHERE sgr.source_cd=cv.code_value)
   JOIN (ap
   WHERE ap.specimen_grouping_cd=sgr.category_cd)
   JOIN (cv2
   WHERE cv2.code_value=ap.site_cd)
  ORDER BY cv.cdf_meaning DESC, cv.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,50)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=0)
    stat = alterlist(reply->rowlist,(50+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,6), reply->rowlist[cnt].celllist[1].string_value =
   cv.display, reply->rowlist[cnt].celllist[2].string_value = cv.description,
   reply->rowlist[cnt].celllist[3].string_value = cv.cdf_meaning, reply->rowlist[cnt].celllist[4].
   string_value = trim(concat(cv2.display,ap.prefix_name),4), reply->rowlist[cnt].celllist[5].
   nbr_value = cv.active_ind,
   reply->rowlist[cnt].celllist[6].string_value = p.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH noheading, nocounter, outerjoin = d
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pathnet_specimen_list.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
