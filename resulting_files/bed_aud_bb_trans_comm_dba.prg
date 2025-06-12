CREATE PROGRAM bed_aud_bb_trans_comm:dba
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
     2 owner_disp = vc
     2 owner_cd = f8
     2 inv_cd = f8
     2 inv_disp = vc
     2 prod_disp = vc
     2 dis_task_disp = vc
     2 prehours = f8
     2 posthours = f8
 )
 SET x = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   FROM transfusion_committee tc,
    trans_commit_assay tca,
    code_value cv1,
    code_value cv2
   PLAN (tc
    WHERE tc.product_cd > 0
     AND tc.active_ind=1)
    JOIN (tca
    WHERE tca.trans_commit_id=tc.trans_commit_id
     AND tca.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=tc.product_cd
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=tca.task_assay_cd
     AND cv2.active_ind=1)
   ORDER BY tc.owner_cd, tc.inv_area_cd, tc.product_cd
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1)
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
  FROM transfusion_committee tc,
   trans_commit_assay tca,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4
  PLAN (tc
   WHERE tc.product_cd > 0
    AND tc.active_ind=1)
   JOIN (tca
   WHERE tca.trans_commit_id=tc.trans_commit_id
    AND tca.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=tc.product_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=tca.task_assay_cd
    AND cv2.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(tc.owner_cd)
    AND cv3.code_value > outerjoin(0)
    AND cv3.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(tc.inv_area_cd)
    AND cv4.code_value > outerjoin(0)
    AND cv4.active_ind=outerjoin(1))
  ORDER BY cv3.display, cv4.display, cv1.display
  HEAD REPORT
   tcnt = 0
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].owner_disp = cv3.display, temp->tqual[tcnt].owner_cd = cv3.code_value, temp->
   tqual[tcnt].inv_cd = cv4.code_value,
   temp->tqual[tcnt].inv_disp = cv4.display, temp->tqual[tcnt].prod_disp = cv1.display, temp->tqual[
   tcnt].dis_task_disp = cv2.display,
   temp->tqual[tcnt].prehours = tca.pre_hours, temp->tqual[tcnt].posthours = tca.post_hours
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Owner Area"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Inventory Area"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Product"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Discrete Task"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Pre-Hours"
 SET reply->collist[5].data_type = 3
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Post-Hours"
 SET reply->collist[6].data_type = 3
 SET reply->collist[6].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
   IF ((temp->tqual[x].owner_cd > 0))
    SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].owner_disp
   ELSE
    SET reply->rowlist[row_nbr].celllist[1].string_value = "(All)"
   ENDIF
   IF ((temp->tqual[x].inv_cd > 0))
    SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].inv_disp
   ELSE
    SET reply->rowlist[row_nbr].celllist[2].string_value = "(All)"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].prod_disp
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].dis_task_disp
   SET reply->rowlist[row_nbr].celllist[5].nbr_value = temp->tqual[x].prehours
   SET reply->rowlist[row_nbr].celllist[6].nbr_value = temp->tqual[x].posthours
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_tans_comm.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
