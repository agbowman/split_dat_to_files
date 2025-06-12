CREATE PROGRAM bed_aud_bb_aborh_values:dba
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
     2 abo_display = vc
     2 rh_display = vc
     2 display = vc
     2 description = vc
     2 meaning = vc
     2 standard = vc
     2 bar_code = vc
     2 isbt = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=1640
     AND cv.active_ind=1)
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
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_extension cve,
   code_value cv2,
   common_data_foundation cdf,
   code_value_extension cve2,
   code_value cv3,
   code_value_extension cve3,
   code_value cv4,
   code_value_extension cve4,
   code_value cv5
  PLAN (cv
   WHERE cv.code_set=1640
    AND cv.active_ind=1)
   JOIN (cve
   WHERE cve.code_value=outerjoin(cv.code_value)
    AND cve.field_name=outerjoin("Barcode"))
   JOIN (cv2
   WHERE cv2.code_set=outerjoin(1643)
    AND cv2.display=outerjoin(cv.display)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cdf
   WHERE cdf.code_set=outerjoin(cv2.code_set)
    AND cdf.cdf_meaning=outerjoin(cv2.cdf_meaning))
   JOIN (cve2
   WHERE cve2.code_value=outerjoin(cv2.code_value)
    AND cve2.field_name=outerjoin("ABORH_cd"))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(cnvtreal(cve2.field_value))
    AND cv3.active_ind=outerjoin(1))
   JOIN (cve3
   WHERE cve3.code_value=outerjoin(cv.code_value)
    AND cve3.field_name=outerjoin("ABOOnly_cd"))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(cnvtreal(cve3.field_value))
    AND cv4.active_ind=outerjoin(1))
   JOIN (cve4
   WHERE cve4.code_value=outerjoin(cv.code_value)
    AND cve4.field_name=outerjoin("RhOnly_cd"))
   JOIN (cv5
   WHERE cv5.code_value=outerjoin(cnvtreal(cve4.field_value))
    AND cv5.active_ind=outerjoin(1))
  ORDER BY cv.display
  HEAD REPORT
   tcnt = 0
  HEAD cv.code_value
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].abo_display = cv4.display, temp->tqual[tcnt].rh_display = cv5.display, temp->
   tqual[tcnt].display = cv.display,
   temp->tqual[tcnt].description = cv.description, temp->tqual[tcnt].meaning = cdf.display, temp->
   tqual[tcnt].bar_code = cve.field_value,
   temp->tqual[tcnt].standard = cv3.display, temp->tqual[tcnt].isbt = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "ABO/Rh Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "ABO/Rh Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Meaning"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "ABO Value"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Rh Value"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Standard"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Bar Code Value"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "ISBT Value"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,8)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].display
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].description
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].meaning
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].abo_display
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].rh_display
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].standard
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].bar_code
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].isbt
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_aborh_values.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
