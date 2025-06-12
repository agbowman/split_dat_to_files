CREATE PROGRAM bed_aud_rad_users
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
     2 person_id = f8
     2 name = vc
     2 initials = vc
     2 display_name = vc
     2 title = vc
     2 position = vc
     2 user_name = vc
     2 last_updated_by = vc
     2 groups[*]
       3 user_group = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM br_position_category bpc,
    br_position_cat_comp bpcc,
    code_value cv,
    prsnl p,
    prsnl p2,
    prsnl_group_reltn pgr
   PLAN (bpc
    WHERE bpc.step_cat_mean="RAD"
     AND bpc.active_ind=1)
    JOIN (bpcc
    WHERE bpcc.category_id=bpc.category_id)
    JOIN (cv
    WHERE cv.code_value=bpcc.position_cd)
    JOIN (p
    WHERE p.position_cd=bpcc.position_cd)
    JOIN (p2
    WHERE p2.person_id=p.updt_id
     AND p2.active_ind=1)
    JOIN (pgr
    WHERE pgr.person_id=outerjoin(p.person_id)
     AND pgr.active_ind=outerjoin(1))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(build("***** count = ",high_volume_cnt))
  IF (high_volume_cnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Full Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Initials"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Display Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Title or Credentials"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Position"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "User Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "User Group"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Update Person Name"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 DECLARE prsnl_cd = f8
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=213
   AND cv.cdf_meaning="PRSNL"
  DETAIL
   prsnl_cd = cv.code_value
  WITH nocounter, noheading
 ;end select
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM br_position_category bpc,
   br_position_cat_comp bpcc,
   code_value cv,
   prsnl p,
   person_name pn,
   prsnl p2
  PLAN (bpc
   WHERE bpc.step_cat_mean="RAD"
    AND bpc.active_ind=1)
   JOIN (bpcc
   WHERE bpcc.category_id=bpc.category_id)
   JOIN (cv
   WHERE cv.code_value=bpcc.position_cd)
   JOIN (p
   WHERE p.position_cd=cv.code_value)
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.name_type_cd=prsnl_cd
    AND pn.active_ind=1
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p2
   WHERE p2.person_id=p.updt_id
    AND p2.active_ind=1)
  ORDER BY p.name_full_formatted, pn.updt_dt_tm DESC, pn.person_id
  HEAD pn.person_id
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].person_id = p.person_id,
   temp->tqual[tcnt].name = p.name_full_formatted, temp->tqual[tcnt].initials = pn.name_initials
   IF (pn.name_middle != " ")
    temp->tqual[tcnt].display_name = concat(trim(pn.name_first)," ",trim(pn.name_middle)," ",trim(pn
      .name_last))
   ELSE
    temp->tqual[tcnt].display_name = concat(trim(pn.name_first)," ",trim(pn.name_last))
   ENDIF
   temp->tqual[tcnt].title = pn.name_title, temp->tqual[tcnt].position = cv.display, temp->tqual[tcnt
   ].user_name = p.username,
   temp->tqual[tcnt].last_updated_by = p2.name_full_formatted
  WITH nocounter
 ;end select
 SET gcnt = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   prsnl_group_reltn pgr,
   prsnl_group pg,
   code_value cv2
  PLAN (d)
   JOIN (pgr
   WHERE (pgr.person_id=temp->tqual[d.seq].person_id)
    AND pgr.active_ind=1)
   JOIN (pg
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND pg.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=pg.prsnl_group_type_cd)
  ORDER BY d.seq, pg.prsnl_group_name
  HEAD d.seq
   gcnt = 0
  DETAIL
   gcnt = (gcnt+ 1), stat = alterlist(temp->tqual[d.seq].groups,gcnt), temp->tqual[d.seq].groups[gcnt
   ].user_group = cv2.display
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,8)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].name
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].initials
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].display_name
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].title
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].position
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].user_name
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].last_updated_by
   SET gcnt = size(temp->tqual[x].groups,5)
   FOR (g = 1 TO gcnt)
    SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].groups[g].user_group
    IF (g < gcnt)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,8)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].name
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].initials
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].display_name
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].title
     SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].position
     SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].user_name
     SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].last_updated_by
    ENDIF
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_users_and_groups_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
