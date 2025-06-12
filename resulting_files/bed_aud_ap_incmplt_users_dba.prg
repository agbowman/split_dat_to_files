CREATE PROGRAM bed_aud_ap_incmplt_users:dba
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
   1 tqual[*]
     2 last_name = vc
     2 first_name = vc
     2 user_name = vc
     2 no_limits_ind = vc
     2 no_title_ind = vc
     2 no_display_ind = vc
     2 no_initials_ind = vc
 )
 SET reply->run_status_flag = 1
 DECLARE pathologist_cd = f8 WITH public, noconstant(0.0)
 DECLARE cytotech_cd = f8 WITH public, noconstant(0.0)
 DECLARE resident_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning IN ("PATHOLOGIST", "CYTOTECH", "PATHRESIDENT")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="PATHOLOGIST")
    pathologist_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CYTOTECH")
    cytotech_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PATHRESIDENT")
    resident_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE current_name_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=213
    AND cv.cdf_meaning="CURRENT"
    AND cv.active_ind=1)
  DETAIL
   current_name_cd = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   FROM prsnl_group pg,
    prsnl_group_reltn pgr,
    prsnl p,
    person_name pn,
    cyto_screening_limits csl,
    cyto_screening_security css
   PLAN (pg
    WHERE pg.prsnl_group_type_cd IN (pathologist_cd, cytotech_cd, resident_cd)
     AND pg.active_ind=1)
    JOIN (pgr
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id
     AND pgr.active_ind=1)
    JOIN (p
    WHERE p.person_id=pgr.person_id
     AND p.active_ind=1)
    JOIN (pn
    WHERE pn.person_id=p.person_id
     AND pn.name_type_cd=current_name_cd
     AND pn.active_ind=1
     AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (csl
    WHERE csl.prsnl_id=outerjoin(p.person_id)
     AND csl.active_ind=outerjoin(1))
    JOIN (css
    WHERE css.prsnl_id=outerjoin(p.person_id)
     AND css.active_ind=outerjoin(1))
   DETAIL
    IF (((pg.prsnl_group_type_cd=cytotech_cd
     AND ((csl.prsnl_id=0) OR (css.prsnl_id=0)) ) OR (((pn.name_title=" ") OR (((p
    .name_full_formatted=" ") OR (pn.name_initials=" ")) )) )) )
     high_volume_cnt = (high_volume_cnt+ 1)
    ENDIF
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
 SET total_cnt = 0
 SET no_limits_cnt = 0
 SET no_title_cnt = 0
 SET no_display_cnt = 0
 SET no_initials_cnt = 0
 SET tcnt = 0
 SELECT DISTINCT INTO "NL:"
  pn.person_id
  FROM prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   person_name pn,
   cyto_screening_limits csl,
   cyto_screening_security css
  PLAN (pg
   WHERE pg.prsnl_group_type_cd IN (pathologist_cd, cytotech_cd, resident_cd)
    AND pg.active_ind=1)
   JOIN (pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pgr.person_id
    AND p.active_ind=1)
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.name_type_cd=current_name_cd
    AND pn.active_ind=1
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (csl
   WHERE csl.prsnl_id=outerjoin(pn.person_id)
    AND csl.active_ind=outerjoin(1))
   JOIN (css
   WHERE css.prsnl_id=outerjoin(pn.person_id)
    AND css.active_ind=outerjoin(1))
  ORDER BY p.name_last, p.name_first, pn.updt_dt_tm DESC,
   pn.person_id
  HEAD pn.person_id
   total_cnt = (total_cnt+ 1)
   IF (((pg.prsnl_group_type_cd=cytotech_cd
    AND ((csl.prsnl_id=0) OR (css.prsnl_id=0)) ) OR (((pn.name_title=" ") OR (((p.name_full_formatted
   =" ") OR (pn.name_initials=" ")) )) )) )
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].last_name = p.name_last,
    temp->tqual[tcnt].first_name = p.name_first, temp->tqual[tcnt].user_name = p.username
    IF (pg.prsnl_group_type_cd=cytotech_cd
     AND ((csl.prsnl_id=0) OR (css.prsnl_id=0)) )
     no_limits_cnt = (no_limits_cnt+ 1), temp->tqual[tcnt].no_limits_ind = "X"
    ENDIF
    IF (pn.name_title=" ")
     no_title_cnt = (no_limits_cnt+ 1), temp->tqual[tcnt].no_title_ind = "X"
    ENDIF
    IF (p.name_full_formatted=" ")
     no_display_cnt = (no_limits_cnt+ 1), temp->tqual[tcnt].no_display_ind = "X"
    ENDIF
    IF (pn.name_initials=" ")
     no_initials_cnt = (no_limits_cnt+ 1), temp->tqual[tcnt].no_initials_ind = "X"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Last Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "First Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "User Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "No Cytology User Limits"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "No User Title"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "No Display Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "No Initials"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].last_name
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].first_name
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].user_name
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].no_limits_ind
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].no_title_ind
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].no_display_ind
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].no_initials_ind
 ENDFOR
 IF (row_nbr > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,4)
 SET reply->statlist[1].statistic_meaning = "APNOCYTOUSERLIMITS"
 SET reply->statlist[1].total_items = total_cnt
 SET reply->statlist[1].qualifying_items = no_limits_cnt
 IF (no_limits_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].statistic_meaning = "APNOTITLE"
 SET reply->statlist[2].total_items = total_cnt
 SET reply->statlist[2].qualifying_items = no_title_cnt
 IF (no_title_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].statistic_meaning = "APNODISPLAYNAME"
 SET reply->statlist[3].total_items = total_cnt
 SET reply->statlist[3].qualifying_items = no_display_cnt
 IF (no_display_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->statlist[4].statistic_meaning = "APNOINITIALS"
 SET reply->statlist[4].total_items = total_cnt
 SET reply->statlist[4].qualifying_items = no_initials_cnt
 IF (no_initials_cnt > 0)
  SET reply->statlist[4].status_flag = 3
 ELSE
  SET reply->statlist[4].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_incomplete_users.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
