CREATE PROGRAM bed_aud_emar_bld_rec:dba
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
 RECORD temp(
   1 vlist[*]
     2 view_name = vc
     2 prim_event_cnt = f8
 )
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Recommendation"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Grade"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET rcnt = 3
 SET stat = alterlist(reply->statlist,rcnt)
 SET stat = alterlist(reply->rowlist,rcnt)
 FOR (rcnt = 1 TO 3)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,2)
 ENDFOR
 SET reply->run_status_flag = 1
 SET reply->rowlist[1].celllist[1].string_value = concat(
  "The 'med_dosage_precision' preference is set with a value"," that is >= 3.")
 SET reply->rowlist[1].celllist[2].string_value = "Pass"
 SET reply->statlist[1].statistic_meaning = "EMARBRMEDDOSEPREC"
 SET reply->statlist[1].total_items = 0
 SET reply->statlist[1].qualifying_items = 0
 SET reply->statlist[1].status_flag = 1
 SELECT INTO "nl:"
  dose_prec = cnvtint(nvp.pvc_value)
  FROM name_value_prefs nvp
  PLAN (nvp
   WHERE nvp.pvc_name="MED_DOSAGE_PRECISION")
  DETAIL
   IF (dose_prec < 3)
    reply->rowlist[1].celllist[2].string_value = "Fail", reply->statlist[1].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[2].celllist[1].string_value = concat(
  "The 'mar_task_prev_admin_lookback' preference is set to a"," value between 1 and 5 days.")
 SET reply->rowlist[2].celllist[2].string_value = "Pass"
 SET reply->statlist[2].statistic_meaning = "EMARBRTSKPREVADMLOOKBACK"
 SET reply->statlist[2].total_items = 0
 SET reply->statlist[2].qualifying_items = 0
 SET reply->statlist[2].status_flag = 1
 SELECT INTO "nl:"
  prev_admin_lookback = cnvtint(nvp.pvc_value)
  FROM name_value_prefs nvp
  PLAN (nvp
   WHERE nvp.pvc_name="MAR_TASK_PREV_ADMIN_LOOKBACK")
  DETAIL
   IF (((prev_admin_lookback < 1) OR (prev_admin_lookback > 5)) )
    reply->rowlist[2].celllist[2].string_value = "Fail", reply->statlist[2].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[3].celllist[1].string_value = concat(
  "The 'refresh_after_form_charting' preference is not"," turned on.")
 SET reply->rowlist[3].celllist[2].string_value = "Pass"
 SET reply->statlist[3].statistic_meaning = "EMARBRREFRESHAFTCHART"
 SET reply->statlist[3].total_items = 0
 SET reply->statlist[3].qualifying_items = 0
 SET reply->statlist[3].status_flag = 1
 SELECT INTO "nl:"
  refresh_after = cnvtint(nvp.pvc_value)
  FROM name_value_prefs nvp
  PLAN (nvp
   WHERE nvp.pvc_name="REFRESH_AFTER_FORM_CHARTING")
  DETAIL
   IF (refresh_after > 0)
    reply->rowlist[3].celllist[2].string_value = "Fail", reply->statlist[3].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("emar_build_rec_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
