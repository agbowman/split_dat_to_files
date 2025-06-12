CREATE PROGRAM bed_aud_careteam:dba
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
 SET row_nbr = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_group cvg1,
   code_value cv2,
   code_value_group cvg2,
   code_value cv3
  PLAN (cv1
   WHERE cv1.code_set=100006
    AND cv1.active_ind=1)
   JOIN (cvg1
   WHERE cvg1.parent_code_value=cv1.code_value
    AND cvg1.code_set=357)
   JOIN (cv2
   WHERE cv2.code_value=cvg1.child_code_value
    AND cv2.active_ind=1)
   JOIN (cvg2
   WHERE cvg2.parent_code_value=cv2.code_value
    AND cvg2.code_set=34)
   JOIN (cv3
   WHERE cv3.code_value=cvg2.child_code_value
    AND cv3.active_ind=1)
  ORDER BY cv1.display_key, cv3.display_key
  HEAD REPORT
   row_nbr = 0
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,2),
   reply->rowlist[row_nbr].celllist[1].string_value = cv1.display, reply->rowlist[row_nbr].celllist[2
   ].string_value = cv3.display
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (row_nbr > 5000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (row_nbr > 3000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Care Team"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Treatment Function"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 CALL echorecord(reply)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("careteamreport.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
