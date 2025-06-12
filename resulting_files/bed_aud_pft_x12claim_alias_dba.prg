CREATE PROGRAM bed_aud_pft_x12claim_alias:dba
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
     2 code_value_alias = vc
     2 code_value_desc = vc
     2 code_set = i4
     2 code_value = f8
 )
 DECLARE x12claim = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=73
    AND cv.display_key="X12CLAIM"
    AND cv.active_ind=1)
  DETAIL
   x12claim = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv,
    code_value_outbound cvo
   PLAN (cv
    WHERE cv.active_ind=1)
    JOIN (cvo
    WHERE cvo.code_value=cv.code_value
     AND cvo.contributor_source_cd=x12claim)
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
  FROM code_value cv,
   code_value_outbound cvo
  PLAN (cv
   WHERE cv.active_ind=1)
   JOIN (cvo
   WHERE cvo.code_value=cv.code_value
    AND cvo.contributor_source_cd=x12claim)
  ORDER BY cv.code_set
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].code_value_alias = cvo
   .alias,
   temp->tqual[tcnt].code_value_desc = cv.description, temp->tqual[tcnt].code_set = cv.code_set, temp
   ->tqual[tcnt].code_value = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Code Value Alias"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Code Value Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Code Set"
 SET reply->collist[3].data_type = 3
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Code Value"
 SET reply->collist[4].data_type = 2
 SET reply->collist[4].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].code_value_alias
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].code_value_desc
   SET reply->rowlist[row_nbr].celllist[3].nbr_value = temp->tqual[x].code_set
   SET reply->rowlist[row_nbr].celllist[4].double_value = temp->tqual[x].code_value
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pft_x12claim_bill_alias.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
