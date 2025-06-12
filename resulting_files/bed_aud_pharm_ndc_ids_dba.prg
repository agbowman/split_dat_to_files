CREATE PROGRAM bed_aud_pharm_ndc_ids:dba
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
     2 ndc = vc
     2 ndc_formatted = vc
     2 item_id = f8
     2 mnemonic = vc
     2 product = vc
 )
 SET ndc_type_cd = 0.0
 SET desc_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning IN ("NDC", "DESC")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="NDC")
    ndc_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DESC")
    desc_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET inpatient_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4500
   AND cv.cdf_meaning="INPATIENT"
   AND cv.active_ind=1
  DETAIL
   inpatient_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET system_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning="SYSTEM"
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="SYSTEM")
    system_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "NL:"
   hv_cnt = count(*)
   FROM med_identifier mi,
    order_catalog_synonym ocs
   PLAN (mi
    WHERE mi.med_identifier_type_cd=ndc_type_cd)
    JOIN (ocs
    WHERE ocs.item_id=mi.item_id)
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
  FROM med_identifier mi,
   order_catalog_synonym ocs
  PLAN (mi
   WHERE mi.med_identifier_type_cd=ndc_type_cd)
   JOIN (ocs
   WHERE ocs.item_id=mi.item_id)
  ORDER BY mi.value_key
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].ndc = mi.value_key,
   temp->tqual[tcnt].ndc_formatted = mi.value, temp->tqual[tcnt].item_id = mi.item_id, temp->tqual[
   tcnt].mnemonic = ocs.mnemonic
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = size(temp->tqual,5)),
   med_identifier mi
  PLAN (d)
   JOIN (mi
   WHERE (mi.item_id=temp->tqual[d.seq].item_id)
    AND mi.pharmacy_type_cd=inpatient_code_value
    AND mi.med_identifier_type_cd=desc_code_value
    AND ((mi.flex_type_cd+ 0)=system_code_value)
    AND mi.primary_ind=1
    AND ((mi.med_product_id+ 0)=0)
    AND ((mi.active_ind+ 0)=1))
  DETAIL
   temp->tqual[d.seq].product = mi.value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "NDC"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "NDC - Formatted"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Item ID"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Rx Mnemonic Synonym"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Product"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,5)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].ndc
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].ndc_formatted
   SET reply->rowlist[row_nbr].celllist[3].double_value = temp->tqual[x].item_id
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].mnemonic
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].product
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pharm_ndc_ids_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
