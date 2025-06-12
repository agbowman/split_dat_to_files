CREATE PROGRAM bed_aud_marsum_bld_rec:dba
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
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
 SET rcnt = 1
 SET stat = alterlist(reply->statlist,rcnt)
 SET stat = alterlist(reply->rowlist,rcnt)
 FOR (rcnt = 1 TO 1)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,2)
 ENDFOR
 SET reply->run_status_flag = 1
 SET reply->rowlist[1].celllist[1].string_value = concat(
  "The 'MAR Summary default hours back' preference is set with"," a value of <= 48.")
 SET reply->rowlist[1].celllist[2].string_value = "Pass"
 SET reply->statlist[1].statistic_meaning = "MARSUMBRDEFAULTHRSBACK"
 SET reply->statlist[1].total_items = 0
 SET reply->statlist[1].qualifying_items = 0
 SET reply->statlist[1].status_flag = 1
 SELECT INTO "nl:"
  hrs_back = cnvtint(trim(nvp.pvc_value))
  FROM name_value_prefs nvp,
   detail_prefs dp
  PLAN (nvp
   WHERE nvp.pvc_name="MAR_SUMMARY_DEFAULT_HRS_BACK"
    AND nvp.active_ind=1)
   JOIN (dp
   WHERE dp.detail_prefs_id=nvp.parent_entity_id
    AND dp.prsnl_id=0
    AND dp.position_cd=0
    AND dp.active_ind=1)
  DETAIL
   IF (hrs_back > 48)
    reply->run_status_flag = 3, reply->statlist[1].status_flag = 3, reply->rowlist[1].celllist[2].
    string_value = "Fail"
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->statlist[1].status_flag=1))
  SELECT INTO "nl:"
   hrs_back = cnvtint(trim(nvp.pvc_value))
   FROM name_value_prefs nvp,
    detail_prefs dp,
    prsnl p
   PLAN (nvp
    WHERE nvp.pvc_name="MAR_SUMMARY_DEFAULT_HRS_BACK"
     AND nvp.active_ind=1)
    JOIN (dp
    WHERE dp.detail_prefs_id=nvp.parent_entity_id
     AND dp.prsnl_id > 0
     AND dp.active_ind=1)
    JOIN (p
    WHERE p.person_id=dp.prsnl_id
     AND p.active_ind=1)
   DETAIL
    IF (hrs_back > 48)
     reply->run_status_flag = 3, reply->statlist[1].status_flag = 3, reply->rowlist[1].celllist[2].
     string_value = "Fail"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->statlist[1].status_flag=1))
  SELECT INTO "nl:"
   hrs_back = cnvtint(trim(nvp.pvc_value))
   FROM name_value_prefs nvp,
    detail_prefs dp,
    code_value cv,
    prsnl p
   PLAN (nvp
    WHERE nvp.pvc_name="MAR_SUMMARY_DEFAULT_HRS_BACK"
     AND nvp.active_ind=1)
    JOIN (dp
    WHERE dp.detail_prefs_id=nvp.parent_entity_id
     AND dp.position_cd > 0
     AND dp.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=dp.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=dp.position_cd
     AND p.active_ind=1)
   DETAIL
    IF (hrs_back > 48)
     reply->run_status_flag = 3, reply->statlist[1].status_flag = 3, reply->rowlist[1].celllist[2].
     string_value = "Fail"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("marsummary_build_rec_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
