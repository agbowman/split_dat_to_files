CREATE PROGRAM bed_aud_ap_cyto_user_limits:dba
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
   1 tcnt = i2
   1 tqual[*]
     2 personnel = vc
     2 position = vc
     2 lab_dept = vc
     2 max_slides = i4
     2 max_hours = i4
     2 ver_level = i4
     2 normal_percent = i4
     2 normal_requeue = vc
     2 normal_serv_res = vc
     2 normal_rank = i4
     2 atypical_percent = i4
     2 atypical_requeue = vc
     2 atypical_serv_res = vc
     2 atypical_rank = i4
     2 abnormal_percent = i4
     2 abnormal_requeue = vc
     2 abnormal_serv_res = vc
     2 abnormal_rank = i4
     2 chr_percent = i4
     2 chr_requeue = vc
     2 chr_serv_res = vc
     2 chr_rank = i4
     2 unsat_percent = i4
     2 unsat_requeue = vc
     2 unsat_serv_res = vc
 )
 DECLARE cytotech = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning="CYTOTECH"
    AND cv.active_ind=1)
  DETAIL
   cytotech = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM prsnl_group pg,
    prsnl_group_reltn pgr,
    prsnl p
   PLAN (pg
    WHERE pg.prsnl_group_type_cd=cytotech
     AND pg.active_ind=1)
    JOIN (pgr
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id
     AND pgr.active_ind=1)
    JOIN (p
    WHERE p.person_id=pgr.person_id
     AND p.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   code_value cv1,
   code_value cv2,
   cyto_screening_limits csl,
   cyto_screening_security css,
   code_value cv3,
   code_value cv4,
   code_value cv5,
   code_value cv6,
   code_value cv7
  PLAN (pg
   WHERE pg.prsnl_group_type_cd=cytotech
    AND pg.active_ind=1)
   JOIN (pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pgr.person_id
    AND p.active_ind=1)
   JOIN (csl
   WHERE csl.prsnl_id=p.person_id
    AND csl.active_ind=1)
   JOIN (css
   WHERE css.prsnl_id=csl.prsnl_id
    AND css.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(p.position_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(p.prim_assign_loc_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(css.normal_service_resource_cd)
    AND cv3.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(css.atypical_service_resource_cd)
    AND cv4.active_ind=outerjoin(1))
   JOIN (cv5
   WHERE cv5.code_value=outerjoin(css.abnormal_service_resource_cd)
    AND cv5.active_ind=outerjoin(1))
   JOIN (cv6
   WHERE cv6.code_value=outerjoin(css.chr_service_resource_cd)
    AND cv6.active_ind=outerjoin(1))
   JOIN (cv7
   WHERE cv7.code_value=outerjoin(css.unsat_service_resource_cd)
    AND cv7.active_ind=outerjoin(1))
  ORDER BY p.name_full_formatted
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].personnel = p.name_full_formatted, temp->tqual[tcnt].position = cv1.description,
   temp->tqual[tcnt].lab_dept = cv2.description,
   temp->tqual[tcnt].max_slides = csl.slide_limit, temp->tqual[tcnt].max_hours = csl.screening_hours,
   temp->tqual[tcnt].ver_level = css.verify_level,
   temp->tqual[tcnt].normal_percent = css.normal_percentage
   IF (css.normal_requeue_flag=2)
    temp->tqual[tcnt].normal_requeue = "Automatic"
   ELSEIF (css.normal_requeue_flag=1)
    temp->tqual[tcnt].normal_requeue = "Manual"
   ELSEIF (css.normal_requeue_flag=0)
    temp->tqual[tcnt].normal_requeue = "None"
   ENDIF
   temp->tqual[tcnt].normal_serv_res = cv3.display, temp->tqual[tcnt].normal_rank = css
   .normal_requeue_rank, temp->tqual[tcnt].atypical_percent = css.atypical_percentage
   IF (css.atypical_requeue_flag=2)
    temp->tqual[tcnt].atypical_requeue = "Automatic"
   ELSEIF (css.atypical_requeue_flag=1)
    temp->tqual[tcnt].atypical_requeue = "Manual"
   ELSEIF (css.atypical_requeue_flag=0)
    temp->tqual[tcnt].atypical_requeue = "None"
   ENDIF
   temp->tqual[tcnt].atypical_serv_res = cv4.display, temp->tqual[tcnt].atypical_rank = css
   .atypical_requeue_rank, temp->tqual[tcnt].abnormal_percent = css.abnormal_percentage
   IF (css.abnormal_requeue_flag=2)
    temp->tqual[tcnt].abnormal_requeue = "Automatic"
   ELSEIF (css.abnormal_requeue_flag=1)
    temp->tqual[tcnt].abnormal_requeue = "Manual"
   ELSEIF (css.abnormal_requeue_flag=0)
    temp->tqual[tcnt].abnormal_requeue = "None"
   ENDIF
   temp->tqual[tcnt].abnormal_serv_res = cv5.display, temp->tqual[tcnt].abnormal_rank = css
   .abnormal_requeue_rank, temp->tqual[tcnt].chr_percent = css.chr_percentage
   IF (css.chr_requeue_flag=2)
    temp->tqual[tcnt].chr_requeue = "Automatic"
   ELSEIF (css.chr_requeue_flag=1)
    temp->tqual[tcnt].chr_requeue = "Manual"
   ELSEIF (css.chr_requeue_flag=0)
    temp->tqual[tcnt].chr_requeue = "None"
   ENDIF
   temp->tqual[tcnt].chr_serv_res = cv6.display, temp->tqual[tcnt].chr_rank = css.chr_requeue_rank,
   temp->tqual[tcnt].unsat_percent = css.unsat_percentage
   IF (css.unsat_requeue_flag=2)
    temp->tqual[tcnt].unsat_requeue = "Automatic"
   ELSEIF (css.unsat_requeue_flag=1)
    temp->tqual[tcnt].unsat_requeue = "Manual"
   ELSEIF (css.unsat_requeue_flag=0)
    temp->tqual[tcnt].unsat_requeue = "None"
   ENDIF
   temp->tqual[tcnt].unsat_serv_res = cv7.display
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,25)
 SET reply->collist[1].header_text = "Personnel"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Position"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Laboratory Department"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Maximum Slides Allowed to Screen"
 SET reply->collist[4].data_type = 3
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Maximum Hours Allowed to Screen"
 SET reply->collist[5].data_type = 3
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Verification Level"
 SET reply->collist[6].data_type = 3
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Previous Normal/No History Requeue %"
 SET reply->collist[7].data_type = 3
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Normal Requeue"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Normal Requeue Service Resource"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Normal Requeue Rank"
 SET reply->collist[10].data_type = 3
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Previous Atypical History Requeue %"
 SET reply->collist[11].data_type = 3
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Atypical Requeue"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Atypical Requeue Service Resource"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Atypical Requeue Rank"
 SET reply->collist[14].data_type = 3
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Previous Abnormal History Requeue %"
 SET reply->collist[15].data_type = 3
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Abnormal Requeue"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Abnormal Requeue Service Resource"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Abnormal Requeue Rank"
 SET reply->collist[18].data_type = 3
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Current CHR Indicator Requeue %"
 SET reply->collist[19].data_type = 3
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "CHR Requeue"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "CHR Requeue Service Resource"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "CHR Requeue Rank"
 SET reply->collist[22].data_type = 3
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Unsatisfactory Requeue %"
 SET reply->collist[23].data_type = 3
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Unsatisfactory Requeue"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Unsatisfactory Requeue Service Resource"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,25)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].personnel
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].position
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].lab_dept
   SET reply->rowlist[row_nbr].celllist[4].nbr_value = temp->tqual[x].max_slides
   SET reply->rowlist[row_nbr].celllist[5].nbr_value = temp->tqual[x].max_hours
   SET reply->rowlist[row_nbr].celllist[6].nbr_value = temp->tqual[x].ver_level
   SET reply->rowlist[row_nbr].celllist[7].nbr_value = temp->tqual[x].normal_percent
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].normal_requeue
   SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].normal_serv_res
   SET reply->rowlist[row_nbr].celllist[10].nbr_value = temp->tqual[x].normal_rank
   SET reply->rowlist[row_nbr].celllist[11].nbr_value = temp->tqual[x].atypical_percent
   SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].atypical_requeue
   SET reply->rowlist[row_nbr].celllist[13].string_value = temp->tqual[x].atypical_serv_res
   SET reply->rowlist[row_nbr].celllist[14].nbr_value = temp->tqual[x].atypical_rank
   SET reply->rowlist[row_nbr].celllist[15].nbr_value = temp->tqual[x].abnormal_percent
   SET reply->rowlist[row_nbr].celllist[16].string_value = temp->tqual[x].abnormal_requeue
   SET reply->rowlist[row_nbr].celllist[17].string_value = temp->tqual[x].abnormal_serv_res
   SET reply->rowlist[row_nbr].celllist[18].nbr_value = temp->tqual[x].abnormal_rank
   SET reply->rowlist[row_nbr].celllist[19].nbr_value = temp->tqual[x].chr_percent
   SET reply->rowlist[row_nbr].celllist[20].string_value = temp->tqual[x].chr_requeue
   SET reply->rowlist[row_nbr].celllist[21].string_value = temp->tqual[x].chr_serv_res
   SET reply->rowlist[row_nbr].celllist[22].nbr_value = temp->tqual[x].chr_rank
   SET reply->rowlist[row_nbr].celllist[23].nbr_value = temp->tqual[x].unsat_percent
   SET reply->rowlist[row_nbr].celllist[24].string_value = temp->tqual[x].unsat_requeue
   SET reply->rowlist[row_nbr].celllist[25].string_value = temp->tqual[x].unsat_serv_res
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_cyto_user_limits.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
