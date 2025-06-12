CREATE PROGRAM bed_aud_unauth_physicians:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 contributor_systems[*]
      2 contrib_sys_code_value = f8
    1 date_range
      2 from_date = dq8
      2 to_date = dq8
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
     2 name = vc
     2 contr_source = vc
     2 free_text_physician = i2
     2 created_by = vc
     2 date_added = dq8
 )
 SET ccnt = size(request->contributor_systems,5)
 DECLARE p_parse = vc
 SET p_parse = "p.active_ind = 1"
 IF (ccnt > 0)
  FOR (c = 1 TO ccnt)
    IF (c=1)
     SET p_parse = build2(p_parse," and p.contributor_system_cd in (")
     SET p_parse = build2(p_parse,request->contributor_systems[c].contrib_sys_code_value)
    ELSE
     SET p_parse = build2(p_parse,",",request->contributor_systems[c].contrib_sys_code_value)
    ENDIF
  ENDFOR
  SET p_parse = build2(p_parse,")")
 ENDIF
 DECLARE unauth = f8 WITH public, noconstant(0.0)
 SET unauth = uar_get_code_by("MEANING",8,"UNAUTH")
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM prsnl p
   WHERE p.physician_ind=1
    AND p.data_status_cd=unauth
    AND parser(p_parse)
    AND ((p.create_dt_tm BETWEEN cnvtdatetime(request->date_range.from_date) AND cnvtdatetime(request
    ->date_range.to_date)) OR ((request->date_range.from_date=0)
    AND (request->date_range.to_date=0)))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   SET reply->status_data.status = "S"
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SET total_cnt = 0
 SELECT INTO "NL:"
  FROM prsnl p,
   prsnl p2,
   code_value cv
  PLAN (p
   WHERE p.physician_ind=1
    AND parser(p_parse)
    AND ((p.create_dt_tm BETWEEN cnvtdatetime(request->date_range.from_date) AND cnvtdatetime(request
    ->date_range.to_date)) OR ((request->date_range.from_date=0)
    AND (request->date_range.to_date=0))) )
   JOIN (cv
   WHERE cv.code_value=outerjoin(p.contributor_system_cd)
    AND cv.active_ind=outerjoin(1))
   JOIN (p2
   WHERE p2.person_id=outerjoin(p.create_prsnl_id))
  ORDER BY p.name_full_formatted, cv.display
  DETAIL
   total_cnt = (total_cnt+ 1)
   IF (p.data_status_cd=unauth)
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].name = p
    .name_full_formatted
    IF (cv.code_value=0)
     temp->tqual[tcnt].contr_source = " "
    ELSE
     temp->tqual[tcnt].contr_source = cv.display
    ENDIF
    temp->tqual[tcnt].free_text_physician = p.free_text_ind, temp->tqual[tcnt].created_by = p2
    .name_full_formatted, temp->tqual[tcnt].date_added = cnvtdatetime(p.create_dt_tm)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Physician Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Free Text Physician"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Created By"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Contributor System"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Date Added"
 SET reply->collist[5].data_type = 4
 SET reply->collist[5].hide_ind = 0
 IF (tcnt=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,5)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].name
   IF ((temp->tqual[x].free_text_physician=0))
    SET reply->rowlist[row_nbr].celllist[2].string_value = "N"
   ELSE
    SET reply->rowlist[row_nbr].celllist[2].string_value = "Y"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].created_by
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].contr_source
   SET reply->rowlist[row_nbr].celllist[5].date_value = temp->tqual[x].date_added
 ENDFOR
 IF (total_cnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "UNAUTHPHYSICIANS"
 SET reply->statlist[1].total_items = total_cnt
 SET reply->statlist[1].qualifying_items = tcnt
 IF (tcnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("unauthenticated_physicians.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
