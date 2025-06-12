CREATE PROGRAM bbt_get_all_prod_index:dba
 RECORD reply(
   1 qual[*]
     2 product_cd = f8
     2 product_disp = c40
     2 product_desc = vc
     2 barcodelist[*]
       3 product_barcode_id = f8
       3 product_barcode = c15
       3 updt_cnt = i4
       3 active_ind = i2
     2 autologous_ind = i2
     2 directed_ind = i2
     2 max_days_expire = i4
     2 max_hrs_expire = i4
     2 default_volume = i4
     2 default_unit_meas_cd = f8
     2 default_unit_meas_disp = c40
     2 default_supplier_id = f8
     2 default_supplier_name = vc
     2 allow_dispense_ind = i2
     2 auto_quarantine_min = i4
     2 synonym_id = f8
     2 mnemonic = c40
     2 auto_bill_item_cd = f8
     2 auto_bill_item_disp = c40
     2 dir_bill_item_cd = f8
     2 dir_bill_item_disp = c40
     2 validate_ag_ab_ind = i2
     2 validate_trans_req_ind = i2
     2 intl_units_ind = i2
     2 storage_temp_cd = f8
     2 storage_temp_disp = c40
     2 drawn_dt_tm_ind = i2
     2 aliquot_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET barcode = fillstring(15," ")
 SET mnemonic = fillstring(100," ")
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  FROM product_index p,
   code_value cv,
   organization o
  PLAN (p
   WHERE (p.product_class_cd=request->product_class_cd)
    AND (p.product_cat_cd=request->product_cat_cd)
    AND p.active_ind=1)
   JOIN (o
   WHERE o.organization_id=outerjoin(p.default_supplier_id))
   JOIN (cv
   WHERE cv.code_value=p.product_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].product_cd = p.product_cd, reply->qual[count1].product_disp = cv.display,
   reply->qual[count1].product_desc = cv.description,
   reply->qual[count1].autologous_ind = p.autologous_ind, reply->qual[count1].directed_ind = p
   .directed_ind, reply->qual[count1].max_days_expire = p.max_days_expire,
   reply->qual[count1].max_hrs_expire = p.max_hrs_expire, reply->qual[count1].default_volume = p
   .default_volume, reply->qual[count1].default_supplier_id = p.default_supplier_id,
   reply->qual[count1].default_supplier_name = o.org_name, reply->qual[count1].allow_dispense_ind = p
   .allow_dispense_ind, reply->qual[count1].synonym_id = p.synonym_id,
   reply->qual[count1].auto_quarantine_min = p.auto_quarantine_min, reply->qual[count1].
   auto_bill_item_cd = p.auto_bill_item_cd, reply->qual[count1].dir_bill_item_cd = p.dir_bill_item_cd,
   reply->qual[count1].validate_ag_ab_ind = p.validate_ag_ab_ind, reply->qual[count1].
   validate_trans_req_ind = p.validate_trans_req_ind, reply->qual[count1].intl_units_ind = p
   .intl_units_ind,
   reply->qual[count1].storage_temp_cd = p.storage_temp_cd, reply->qual[count1].drawn_dt_tm_ind = p
   .drawn_dt_tm_ind, reply->qual[count1].aliquot_ind = p.aliquot_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status="S"))
  FOR (x = 1 TO count1)
    SET bar_cnt = 0
    SET stat = alterlist(reply->qual[x].barcodelist,5)
    SELECT INTO "nl:"
     b.product_barcode_id, b.product_barcode, b.updt_cnt,
     b.active_ind
     FROM product_barcode b
     WHERE (reply->qual[x].product_cd=b.product_cd)
      AND b.active_ind=1
     ORDER BY b.product_barcode
     DETAIL
      bar_cnt = (bar_cnt+ 1)
      IF (mod(bar_cnt,5)=1
       AND bar_cnt != 1)
       stat = alterlist(reply->qual[x].barcodelist,(bar_cnt+ 4))
      ENDIF
      reply->qual[x].barcodelist[bar_cnt].product_barcode_id = b.product_barcode_id, reply->qual[x].
      barcodelist[bar_cnt].product_barcode = b.product_barcode, reply->qual[x].barcodelist[bar_cnt].
      updt_cnt = b.updt_cnt,
      reply->qual[x].barcodelist[bar_cnt].active_ind = b.active_ind
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->qual[x].barcodelist,bar_cnt)
  ENDFOR
  FOR (x = 1 TO count1)
    IF ((reply->qual[x].synonym_id > 0))
     SELECT INTO "nl:"
      FROM order_catalog_synonym s
      WHERE (reply->qual[x].synonym_id=s.synonym_id)
      DETAIL
       mnemonic = s.mnemonic
      WITH nocounter
     ;end select
     IF (curqual != 0)
      SET reply->qual[x].mnemonic = mnemonic
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
END GO
