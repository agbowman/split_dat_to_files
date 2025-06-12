CREATE PROGRAM bed_aud_unauth_code_values:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 contributor_sources[*]
      2 code_value = f8
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
     2 code_set = i4
     2 code_value = f8
     2 display = vc
     2 desc = vc
     2 cont_source = vc
     2 create_date = dq8
 )
 DECLARE unauth = f8 WITH public, noconstant(0.0)
 SET unauth = uar_get_code_by("MEANING",8,"UNAUTH")
 SET ccnt = size(request->contributor_sources,5)
 DECLARE cv2_parse = vc
 SET cv2_parse = "cv2.active_ind = outerjoin(1)"
 IF (ccnt > 0)
  FOR (c = 1 TO ccnt)
    IF (c=1)
     SET cv2_parse = build2(cv2_parse," and ca.contributor_source_cd in (")
     SET cv2_parse = build2(cv2_parse,request->contributor_sources[c].code_value)
    ELSE
     SET cv2_parse = build2(cv2_parse,",",request->contributor_sources[c].code_value)
    ENDIF
  ENDFOR
  SET cv2_parse = build2(cv2_parse,")")
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv,
    code_value_alias ca,
    code_value cv2
   PLAN (cv
    WHERE cv.data_status_cd=unauth
     AND cv.active_ind=1
     AND ((cv.begin_effective_dt_tm BETWEEN cnvtdatetime(request->date_range.from_date) AND
    cnvtdatetime(request->date_range.to_date)) OR ((request->date_range.from_date=0)
     AND (request->date_range.to_date=0))) )
    JOIN (ca
    WHERE ca.code_value=outerjoin(cv.code_value))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(ca.contributor_source_cd)
     AND parser(cv2_parse))
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
 SET total_cnt = 0
 SELECT INTO "NL:"
  FROM code_value cv,
   code_value_alias ca,
   code_value cv2
  PLAN (cv
   WHERE cv.active_ind=1
    AND ((cv.begin_effective_dt_tm BETWEEN cnvtdatetime(request->date_range.from_date) AND
   cnvtdatetime(request->date_range.to_date)) OR ((request->date_range.from_date=0)
    AND (request->date_range.to_date=0))) )
   JOIN (ca
   WHERE ca.code_value=outerjoin(cv.code_value))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(ca.contributor_source_cd)
    AND parser(cv2_parse))
  ORDER BY cv.code_set, cv.code_value
  DETAIL
   total_cnt = (total_cnt+ 1)
   IF (cv.data_status_cd=unauth)
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].code_set = cv.code_set,
    temp->tqual[tcnt].code_value = cv.code_value, temp->tqual[tcnt].display = cv.display, temp->
    tqual[tcnt].desc = cv.description,
    temp->tqual[tcnt].create_date = cv.begin_effective_dt_tm
    IF (cv2.code_value > 0)
     temp->tqual[tcnt].cont_source = cv2.display
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Code Set"
 SET reply->collist[1].data_type = 3
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Code Value"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Code Value Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Code Value Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Contributor Source"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Date Added"
 SET reply->collist[6].data_type = 4
 SET reply->collist[6].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
   SET reply->rowlist[row_nbr].celllist[1].nbr_value = temp->tqual[x].code_set
   SET reply->rowlist[row_nbr].celllist[2].double_value = temp->tqual[x].code_value
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].display
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].desc
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].cont_source
   SET reply->rowlist[row_nbr].celllist[6].date_value = temp->tqual[x].create_date
 ENDFOR
 IF (total_cnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "UNAUTHCODEVALUES"
 SET reply->statlist[1].total_items = total_cnt
 SET reply->statlist[1].qualifying_items = tcnt
 IF (tcnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("unauthenticated_code_values.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
