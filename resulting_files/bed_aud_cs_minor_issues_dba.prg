CREATE PROGRAM bed_aud_cs_minor_issues:dba
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
     2 ext_description = vc
     2 item_id = f8
     2 item_type = vc
     2 bill_code_missing_bi_ind = i2
     2 price_missing_bi_ind = i2
 )
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Bill_Item_ID"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Bill Item Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Item ID"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Bill Item Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Bill Code Row With No Active Bill Item"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Price Row With No Active Bill Item"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET totcnt = 0
 SET bimtotcnt = 0
 SELECT INTO "nl:"
  bimcnt = count(*)
  FROM bill_item_modifier
  WHERE active_ind=1
  DETAIL
   bimtotcnt = bimcnt
  WITH nocounter
 ;end select
 SET psitotcnt = 0
 SELECT INTO "nl:"
  psicnt = count(*)
  FROM bill_item_modifier
  WHERE active_ind=1
  DETAIL
   psitotcnt = psicnt
  WITH nocounter
 ;end select
 SET totcnt = (bimtotcnt+ psitotcnt)
 IF ((request->skip_volume_check_ind=0))
  IF (totcnt > 40000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (totcnt > 20000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET bcnt = 0
 SELECT INTO "nl:"
  FROM price_sched_items psi,
   (dummyt d  WITH seq = 1),
   bill_item bi
  PLAN (psi
   WHERE psi.active_ind=1
    AND psi.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
    AND psi.end_effective_dt_tm > cnvtdatetime(curdate,235959))
   JOIN (d)
   JOIN (bi
   WHERE bi.bill_item_id=psi.bill_item_id)
  DETAIL
   IF (bi.bill_item_id > 0)
    IF (bi.active_ind=0)
     bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
     .bill_item_id,
     temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].item_id = psi
     .price_sched_items_id, temp->bilist[bcnt].item_type = "Price_Sched_Items",
     temp->bilist[bcnt].bill_code_missing_bi_ind = 0, temp->bilist[bcnt].price_missing_bi_ind = 1
    ENDIF
   ELSE
    bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = 0,
    temp->bilist[bcnt].ext_description = " ", temp->bilist[bcnt].item_id = psi.price_sched_items_id,
    temp->bilist[bcnt].item_type = "Price_Sched_Items",
    temp->bilist[bcnt].bill_code_missing_bi_ind = 0, temp->bilist[bcnt].price_missing_bi_ind = 1
   ENDIF
  WITH outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM bill_item_modifier bim,
   (dummyt d  WITH seq = 1),
   bill_item bi
  PLAN (bim
   WHERE bim.active_ind=1
    AND bim.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
    AND bim.end_effective_dt_tm > cnvtdatetime(curdate,235959))
   JOIN (d)
   JOIN (bi
   WHERE bi.bill_item_id=bim.bill_item_id)
  DETAIL
   IF (bi.bill_item_id > 0)
    IF (bi.active_ind=0)
     bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
     .bill_item_id,
     temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].item_id = bim
     .bill_item_mod_id, temp->bilist[bcnt].item_type = "Bill_Item_Modifier",
     temp->bilist[bcnt].bill_code_missing_bi_ind = 1, temp->bilist[bcnt].price_missing_bi_ind = 0
    ENDIF
   ELSE
    bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = 0,
    temp->bilist[bcnt].ext_description = " ", temp->bilist[bcnt].item_id = bim.bill_item_mod_id, temp
    ->bilist[bcnt].item_type = "Bill_Item_Modifier",
    temp->bilist[bcnt].bill_code_missing_bi_ind = 1, temp->bilist[bcnt].price_missing_bi_ind = 0
   ENDIF
  WITH outerjoin = d
 ;end select
 SET bill_code_missing_bi_cnt = 0
 SET price_missing_bi_cnt = 0
 IF (bcnt > 0)
  SELECT INTO "nl:"
   item_id = temp->bilist[d.seq].item_id
   FROM (dummyt d  WITH seq = bcnt)
   PLAN (d)
   ORDER BY item_id
   HEAD REPORT
    rcnt = 0
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,6),
    reply->rowlist[rcnt].celllist[1].double_value = temp->bilist[d.seq].bill_item_id, reply->rowlist[
    rcnt].celllist[2].string_value = temp->bilist[d.seq].ext_description
    IF ((temp->bilist[d.seq].bill_code_missing_bi_ind=1))
     bill_code_missing_bi_cnt = (bill_code_missing_bi_cnt+ 1), reply->rowlist[rcnt].celllist[3].
     double_value = temp->bilist[d.seq].item_id, reply->rowlist[rcnt].celllist[4].string_value = temp
     ->bilist[d.seq].item_type,
     reply->rowlist[rcnt].celllist[5].string_value = "X", reply->rowlist[rcnt].celllist[6].
     string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].price_missing_bi_ind=1))
     price_missing_bi_cnt = (price_missing_bi_cnt+ 1), reply->rowlist[rcnt].celllist[3].double_value
      = temp->bilist[d.seq].item_id, reply->rowlist[rcnt].celllist[4].string_value = temp->bilist[d
     .seq].item_type,
     reply->rowlist[rcnt].celllist[5].string_value = " ", reply->rowlist[rcnt].celllist[6].
     string_value = "X"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (bill_code_missing_bi_cnt=0
  AND price_missing_bi_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,2)
 SET reply->statlist[1].total_items = 0
 SET reply->statlist[1].qualifying_items = bill_code_missing_bi_cnt
 SET reply->statlist[1].statistic_meaning = "CSBILLCODENOBI"
 IF (bill_code_missing_bi_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = 0
 SET reply->statlist[2].qualifying_items = price_missing_bi_cnt
 SET reply->statlist[2].statistic_meaning = "CSPRICENOBI"
 IF (price_missing_bi_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
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
  SET reply->output_filename = build("cs_minor_issues_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
