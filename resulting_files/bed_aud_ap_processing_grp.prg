CREATE PROGRAM bed_aud_ap_processing_grp
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
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Processing Group Task Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Processing Group Task Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Processing Group Active"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Task Display"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Block Sequence"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Slide Sequence"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "No Charge"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Last Update By"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM ap_processing_grp_r a
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
  cv.display, cv.description, cv_dta.display,
  a.begin_level, a.begin_section, p.name_full_formatted
  FROM ap_processing_grp_r a,
   code_value cv,
   code_value cv_dta,
   prsnl p
  PLAN (a)
   JOIN (cv
   WHERE cv.code_value=a.parent_entity_id)
   JOIN (cv_dta
   WHERE cv_dta.code_value=a.task_assay_cd)
   JOIN (p
   WHERE p.person_id=a.updt_id)
  ORDER BY cv.display, a.begin_section, a.begin_level,
   cv_dta.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(reply->rowlist,(10+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,8), reply->rowlist[cnt].celllist[1].string_value =
   cv.display, reply->rowlist[cnt].celllist[2].string_value = cv.description
   IF (cv.active_ind=1)
    reply->rowlist[cnt].celllist[3].string_value = "active"
   ELSE
    reply->rowlist[cnt].celllist[3].string_value = "inactive"
   ENDIF
   reply->rowlist[cnt].celllist[4].string_value = cv_dta.display
   CASE (a.begin_section)
    OF - (1):
     reply->rowlist[cnt].celllist[5].string_value = "Order Entry"
    ELSE
     reply->rowlist[cnt].celllist[5].string_value = cnvtstring(a.begin_section)
   ENDCASE
   reply->rowlist[cnt].celllist[6].string_value = cnvtstring(a.begin_level)
   IF (a.no_charge_ind=1)
    reply->rowlist[cnt].celllist[7].string_value = "Yes"
   ELSE
    reply->rowlist[cnt].celllist[7].string_value = "No"
   ENDIF
   reply->rowlist[cnt].celllist[8].string_value = p.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH noheading, nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pathnet_ap_processing_group.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
