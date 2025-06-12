CREATE PROGRAM bed_aud_sch_ord_appt_type:dba
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
     2 ord_item = vc
     2 appt_type = vc
 )
 SET reply->status_data.status = "S"
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM br_sched_appt_type_ord br1,
    br_sched_appt_type br2,
    order_catalog oc
   PLAN (br1)
    JOIN (br2
    WHERE br2.appt_type_id=br1.appt_type_id)
    JOIN (oc
    WHERE oc.concept_cki=br1.concept_cki
     AND oc.active_ind=1)
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
  FROM br_sched_appt_type_ord br1,
   br_sched_appt_type br2,
   order_catalog oc
  PLAN (br1)
   JOIN (br2
   WHERE br2.appt_type_id=br1.appt_type_id)
   JOIN (oc
   WHERE oc.concept_cki=br1.concept_cki
    AND oc.active_ind=1)
  ORDER BY cnvtupper(oc.primary_mnemonic)
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].ord_item = oc
   .primary_mnemonic,
   temp->tqual[tcnt].appt_type = br2.appt_type_display
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Orderable Item"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Appointment Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,2)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].ord_item
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].appt_type
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("orders_with_proposed_appt_types.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
