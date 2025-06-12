CREATE PROGRAM bed_aud_rad_default_recall
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
 DECLARE study = f8
 DECLARE g_mamm_lett_cd = f8
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM mammo_letter ml
   PLAN (ml
    WHERE ml.recommendation_id > 0)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 2000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Follow-Up Procedure"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Begin Age"
 SET reply->collist[2].data_type = 3
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "End Age"
 SET reply->collist[3].data_type = 3
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Interval (Months)"
 SET reply->collist[4].data_type = 3
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Updated By"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Updated Date"
 SET reply->collist[6].data_type = 4
 SET reply->collist[6].hide_ind = 0
 SELECT INTO "nl:"
  oc.primary_mnemonic, ffr.beginning_age_range, ffr.ending_age_range,
  ffr.recall_interval, p.name_full_formatted, ffr.updt_dt_tm
  FROM rad_follow_up_recall ffr,
   order_catalog oc,
   prsnl p
  PLAN (ffr
   WHERE ffr.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ffr.catalog_cd
    AND oc.active_ind=1)
   JOIN (p
   WHERE p.person_id=outerjoin(ffr.updt_id)
    AND p.active_ind=outerjoin(1))
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(cnt+ 25))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,6), reply->rowlist[cnt].celllist[1].string_value =
   oc.primary_mnemonic, reply->rowlist[cnt].celllist[2].nbr_value = ffr.beginning_age_range,
   reply->rowlist[cnt].celllist[3].nbr_value = ffr.ending_age_range, reply->rowlist[cnt].celllist[4].
   nbr_value = ffr.recall_interval, reply->rowlist[cnt].celllist[5].string_value = p
   .name_full_formatted,
   reply->rowlist[cnt].celllist[6].date_value = ffr.updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_note_letter_r.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
