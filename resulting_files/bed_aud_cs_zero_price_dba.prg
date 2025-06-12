CREATE PROGRAM bed_aud_cs_zero_price:dba
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
 RECORD temp(
   1 bilist[*]
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 ext_owner_cd = f8
     2 ext_owner_disp = vc
     2 ext_description = vc
     2 zero_price_ind = i2
 )
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Bill_Item_ID"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Zero Price"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET chg_point_cd = get_code_value(13019,"CHARGE POINT")
 SET bitotcnt = 0
 SELECT INTO "nl:"
  bicnt = count(*)
  FROM bill_item
  WHERE active_ind=1
  DETAIL
   bitotcnt = bicnt
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (bitotcnt > 25000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (bitotcnt > 20000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET bcnt = 0
 SET totcnt = 0
 SELECT INTO "nl:"
  FROM price_sched_items psi,
   bill_item bi,
   (dummyt d  WITH seq = 1),
   bill_item_modifier bim
  PLAN (psi
   WHERE psi.price=0
    AND psi.active_ind=1
    AND psi.price_sched_id != 0
    AND psi.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
    AND psi.end_effective_dt_tm > cnvtdatetime(curdate,235959)
    AND psi.stats_only_ind IN (0, null))
   JOIN (bi
   WHERE bi.bill_item_id=psi.bill_item_id
    AND bi.active_ind=1
    AND bi.stats_only_ind IN (0, null)
    AND bi.misc_ind IN (0, null))
   JOIN (d)
   JOIN (bim
   WHERE bim.bill_item_id=bi.bill_item_id
    AND bim.bill_item_type_cd=chg_point_cd
    AND bim.bim1_int IN (1, 3, 5, 7, 9,
   11, 13, 15)
    AND bim.active_ind=1)
  DETAIL
   totcnt = (totcnt+ 1)
   IF (bim.bill_item_id != bi.bill_item_id)
    bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
    .bill_item_id,
    temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
    ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
    .ext_owner_cd,
    temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].zero_price_ind = 1
   ENDIF
  WITH outerjoin = d, dontexist
 ;end select
 SET zero_price_cnt = 0
 IF (bcnt > 0)
  SET stat = alterlist(temp2->bilist,bcnt)
  SELECT INTO "nl:"
   bi_id = temp->bilist[d.seq].bill_item_id, item_disp = cnvtupper(temp->bilist[d.seq].
    ext_description)
   FROM (dummyt d  WITH seq = bcnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=temp->bilist[d.seq].ext_owner_cd))
   ORDER BY cv.display_key, item_disp, bi_id
   HEAD REPORT
    rcnt = 0
   HEAD bi_id
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,4),
    reply->rowlist[rcnt].celllist[1].string_value = cv.display, reply->rowlist[rcnt].celllist[2].
    double_value = temp->bilist[d.seq].bill_item_id, reply->rowlist[rcnt].celllist[3].string_value =
    temp->bilist[d.seq].ext_description
   DETAIL
    IF ((temp->bilist[d.seq].zero_price_ind=1))
     zero_price_cnt = (zero_price_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = "X"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (zero_price_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].total_items = bitotcnt
 SET reply->statlist[1].qualifying_items = zero_price_cnt
 SET reply->statlist[1].statistic_meaning = "CHGSERVZEROPRICE"
 IF (zero_price_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cs_zero_price_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
