CREATE PROGRAM bed_aud_assays_without_ranges:dba
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
   1 assays[*]
     2 task_assay_cd = f8
     2 display = vc
     2 rrf_exists_ind = i2
 )
 SET reply->run_status_flag = 1
 DECLARE glb_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="GLB"
    AND cv.active_ind=1)
  DETAIL
   glb_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE alpha_cd = f8 WITH public, noconstant(0.0)
 DECLARE numeric_cd = f8 WITH public, noconstant(0.0)
 DECLARE calc_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning IN ("2", "3", "8")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="2")
    alpha_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="3")
    numeric_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="8")
    calc_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SET total_assays = 0
  SELECT INTO "NL:"
   FROM discrete_task_assay dta,
    code_value cv
   PLAN (dta
    WHERE dta.activity_type_cd=glb_cd
     AND dta.default_result_type_cd IN (alpha_cd, numeric_cd, calc_cd)
     AND dta.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=dta.task_assay_cd
     AND cv.active_ind=1)
   DETAIL
    total_assays = (total_assays+ 1), stat = alterlist(temp->assays,total_assays), temp->assays[
    total_assays].task_assay_cd = dta.task_assay_cd,
    temp->assays[total_assays].display = cv.display
   WITH nocounter
  ;end select
  SET total_with_rrf = 0
  IF (total_assays > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = total_assays),
     reference_range_factor rrf
    PLAN (d)
     JOIN (rrf
     WHERE (rrf.task_assay_cd=temp->assays[d.seq].task_assay_cd)
      AND rrf.active_ind=1)
    DETAIL
     IF ((temp->assays[d.seq].rrf_exists_ind=0))
      temp->assays[d.seq].rrf_exists_ind = 1, total_with_rrf = (total_with_rrf+ 1)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SET high_volume_cnt = (total_assays - total_with_rrf)
  CALL echo(build("********** high_volume_cnt = ",high_volume_cnt))
  IF (high_volume_cnt > 60000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 30000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET total_assays = 0
 SELECT INTO "NL:"
  FROM discrete_task_assay dta,
   code_value cv
  PLAN (dta
   WHERE dta.activity_type_cd=glb_cd
    AND dta.default_result_type_cd IN (alpha_cd, numeric_cd, calc_cd)
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.task_assay_cd
    AND cv.active_ind=1)
  ORDER BY cv.display
  DETAIL
   total_assays = (total_assays+ 1), stat = alterlist(temp->assays,total_assays), temp->assays[
   total_assays].task_assay_cd = dta.task_assay_cd,
   temp->assays[total_assays].display = cv.display
  WITH nocounter
 ;end select
 SET total_with_rrf = 0
 IF (total_assays > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = total_assays),
    reference_range_factor rrf
   PLAN (d)
    JOIN (rrf
    WHERE (rrf.task_assay_cd=temp->assays[d.seq].task_assay_cd)
     AND rrf.active_ind=1)
   DETAIL
    IF ((temp->assays[d.seq].rrf_exists_ind=0))
     temp->assays[d.seq].rrf_exists_ind = 1, total_with_rrf = (total_with_rrf+ 1)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET total_without_rrf = (total_assays - total_with_rrf)
 SET stat = alterlist(reply->collist,1)
 SET reply->collist[1].header_text = "Assay"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET row_nbr = 0
 IF (total_without_rrf > 0)
  FOR (x = 1 TO total_assays)
    IF ((temp->assays[x].rrf_exists_ind=0))
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,1)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->assays[x].display
    ENDIF
  ENDFOR
 ENDIF
 IF (row_nbr > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "GLBASSAYWORANGES"
 SET reply->statlist[1].total_items = total_assays
 SET reply->statlist[1].qualifying_items = total_without_rrf
 IF (total_without_rrf > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("assays_without_reference_ranges.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
 CALL echo(build("********** total_assays = ",total_assays))
 CALL echo(build("********** total_without_rrf = ",total_without_rrf))
 CALL echorecord(reply)
END GO
