CREATE PROGRAM bed_aud_iview_titrate_ind:dba
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
     2 mill_name = vc
 )
 SET reply->run_status_flag = 1
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog_synonym ocs
   WHERE (ocs.ingredient_rate_conversion_ind=- (1))
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
  FROM order_catalog_synonym ocs
  WHERE ocs.ingredient_rate_conversion_ind IN (1, - (1))
  ORDER BY ocs.mnemonic
  DETAIL
   total_cnt = (total_cnt+ 1)
   IF ((ocs.ingredient_rate_conversion_ind=- (1)))
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].mill_name = ocs.mnemonic
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,1)
 SET reply->collist[1].header_text = "Millennium Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,1)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].mill_name
 ENDFOR
 IF (total_cnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "IVIEWTITRATEIND"
 SET reply->statlist[1].total_items = total_cnt
 SET reply->statlist[1].qualifying_items = tcnt
 IF (tcnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("trirateable_with_incorrect_ind.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
