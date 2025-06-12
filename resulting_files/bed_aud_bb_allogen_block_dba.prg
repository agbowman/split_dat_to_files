CREATE PROGRAM bed_aud_bb_allogen_block:dba
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
 SET x = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   FROM bb_dspns_block bb,
    product_index pi,
    bb_dspns_block_product bp,
    code_value cv1,
    code_value cv2
   PLAN (bb
    WHERE bb.active_ind=1)
    JOIN (pi
    WHERE pi.product_cd=bb.product_cd
     AND pi.active_ind=1)
    JOIN (bp
    WHERE bp.dispense_block_id=bb.dispense_block_id
     AND bp.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=bb.product_cd
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=bp.product_cd
     AND cv2.active_ind=1)
   ORDER BY cv1.display, cv2.display
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
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Blood Product Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Blood Product Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Autologous or Directed?"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Override Status"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Blocked Product Display"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Blocked Product Description"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM bb_dspns_block bb,
   product_index pi,
   bb_dspns_block_product bp,
   code_value cv1,
   code_value cv2
  PLAN (bb
   WHERE bb.active_ind=1)
   JOIN (pi
   WHERE pi.product_cd=bb.product_cd
    AND pi.active_ind=1
    AND pi.allow_dispense_ind=1)
   JOIN (bp
   WHERE bp.dispense_block_id=bb.dispense_block_id
    AND bp.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=bb.product_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=bp.product_cd
    AND cv2.active_ind=1)
  ORDER BY cv1.display, cv2.display
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->rowlist,100)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
   ENDIF
   stat = alterlist(reply->rowlist[tcnt].celllist,6), reply->rowlist[tcnt].celllist[1].string_value
    = cv1.display, reply->rowlist[tcnt].celllist[2].string_value = cv1.description
   IF (pi.autologous_ind=1
    AND pi.directed_ind=1)
    reply->rowlist[tcnt].celllist[3].string_value = "Both"
   ELSEIF (pi.autologous_ind=1)
    reply->rowlist[tcnt].celllist[3].string_value = "Autologous"
   ELSEIF (pi.directed_ind=1)
    reply->rowlist[tcnt].celllist[3].string_value = "Directed"
   ENDIF
   IF (bb.allow_override_ind=1)
    reply->rowlist[tcnt].celllist[4].string_value = "Warn"
   ELSE
    reply->rowlist[tcnt].celllist[4].string_value = "Not Allowed"
   ENDIF
   reply->rowlist[tcnt].celllist[5].string_value = cv2.display, reply->rowlist[tcnt].celllist[6].
   string_value = cv2.description
  FOOT REPORT
   stat = alterlist(reply->rowlist,tcnt)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_allogen_block.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
