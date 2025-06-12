CREATE PROGRAM bed_aud_rad_bill_only_r
 FREE RECORD orders
 RECORD orders(
   1 qual[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 bill_only[*]
       3 task_assay_cd = f8
       3 description = vc
       3 standard_qty = i2
     2 categories[*]
       3 code_value = f8
       3 description = vc
 )
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM bill_only_proc_reltn bopr
   PLAN (bopr)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE radiology_type_cd = f8
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="RADIOLOGY"
   AND cv.code_set=6000
  DETAIL
   radiology_type_cd = cv.code_value
  WITH noheading, nocounter
 ;end select
 CALL echo("Retrieving Orders")
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd=radiology_type_cd
    AND oc.active_ind=1)
  HEAD REPORT
   cnt = 0, stat = alterlist(orders->qual,100)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=0)
    stat = alterlist(orders->qual,(100+ cnt))
   ENDIF
   orders->qual[cnt].catalog_cd = oc.catalog_cd, orders->qual[cnt].primary_mnemonic = oc
   .primary_mnemonic
  FOOT REPORT
   stat = alterlist(orders->qual,cnt)
  WITH nocounter, noheading
 ;end select
 CALL echo("Retrieving Bill Onlys")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(orders->qual,5))),
   bill_only_proc_reltn bopr,
   discrete_task_assay dta
  PLAN (d)
   JOIN (bopr
   WHERE (bopr.catalog_cd=orders->qual[d.seq].catalog_cd)
    AND bopr.entity_name="DISCRETE_TASK_ASSAY")
   JOIN (dta
   WHERE dta.task_assay_cd=bopr.entity_id)
  HEAD d.seq
   cnt = 0, stat = alterlist(orders->qual[d.seq].bill_only,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(orders->qual[d.seq].bill_only,(10+ cnt))
   ENDIF
   orders->qual[d.seq].bill_only[cnt].task_assay_cd = dta.task_assay_cd, orders->qual[d.seq].
   bill_only[cnt].description = dta.description, orders->qual[d.seq].bill_only[cnt].standard_qty =
   bopr.standard_qty
  FOOT  d.seq
   stat = alterlist(orders->qual[d.seq].bill_only,cnt)
  WITH noheading, nocounter
 ;end select
 CALL echo("Retreiving Categories")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(orders->qual,5))),
   bill_only_proc_reltn bopr,
   code_value cv
  PLAN (d)
   JOIN (bopr
   WHERE (bopr.catalog_cd=orders->qual[d.seq].catalog_cd)
    AND bopr.entity_name="CODE_VALUE")
   JOIN (cv
   WHERE cv.code_value=bopr.entity_id)
  HEAD d.seq
   cnt = 0, stat = alterlist(orders->qual[d.seq].categories,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(orders->qual[d.seq].categories,(10+ cnt))
   ENDIF
   orders->qual[d.seq].categories[cnt].code_value = cv.code_value, orders->qual[d.seq].categories[cnt
   ].description = cv.display
  FOOT  d.seq
   stat = alterlist(orders->qual[d.seq].categories,cnt)
  WITH noheading, nocounter
 ;end select
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "catalog_cd"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Primary Mnemonic"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "task_assay_cd"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Bill-Only Items"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Default Quantity"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "category_cd"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 1
 SET reply->collist[7].header_text = "Bill-Only Category"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET maxlist = size(orders->qual,5)
 SET order_cnt = 0
 CALL echo("Creating Reply")
 WHILE (order_cnt < maxlist)
  SET order_cnt = (order_cnt+ 1)
  IF (size(orders->qual[order_cnt].bill_only,5) > size(orders->qual[order_cnt].categories,5))
   CALL add_rows(order_cnt,size(orders->qual[order_cnt].bill_only,5),size(orders->qual[order_cnt].
     categories,5),1)
  ELSEIF (size(orders->qual[order_cnt].bill_only,5) < size(orders->qual[order_cnt].categories,5))
   CALL add_rows(order_cnt,size(orders->qual[order_cnt].categories,5),size(orders->qual[order_cnt].
     bill_only,5),2)
  ELSEIF (((size(orders->qual[order_cnt].bill_only,5)+ size(orders->qual[order_cnt].categories,5))=0)
  )
   CALL add_rows(order_cnt,size(orders->qual[order_cnt].bill_only,5),size(orders->qual[order_cnt].
     categories,5),3)
  ELSEIF (size(orders->qual[order_cnt].bill_only,5)=size(orders->qual[order_cnt].categories,5))
   CALL add_rows(order_cnt,size(orders->qual[order_cnt].bill_only,5),size(orders->qual[order_cnt].
     categories,5),4)
  ENDIF
 ENDWHILE
 SUBROUTINE add_rows(array_location,high,low,type_ind)
   SET row_cnt = size(reply->rowlist,5)
   SET stat = alterlist(reply->rowlist,((row_cnt+ high)+ 1))
   SET cnt = 0
   SET row_cnt = (row_cnt+ 1)
   SET stat = alterlist(reply->rowlist[row_cnt].celllist,7)
   IF ((orders->qual[array_location].catalog_cd=0))
    SET reply->rowlist[row_cnt].celllist[1].string_value = " "
   ELSE
    SET reply->rowlist[row_cnt].celllist[1].string_value = cnvtstring(orders->qual[array_location].
     catalog_cd)
   ENDIF
   SET reply->rowlist[row_cnt].celllist[2].string_value = orders->qual[array_location].
   primary_mnemonic
   WHILE (low > cnt)
     SET cnt = (cnt+ 1)
     IF (cnt > 1)
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,7)
     ENDIF
     IF ((orders->qual[array_location].bill_only[cnt].task_assay_cd=0))
      SET reply->rowlist[row_cnt].celllist[3].string_value = " "
     ELSE
      SET reply->rowlist[row_cnt].celllist[3].string_value = cnvtstring(orders->qual[array_location].
       bill_only[cnt].task_assay_cd)
     ENDIF
     SET reply->rowlist[row_cnt].celllist[4].string_value = orders->qual[array_location].bill_only[
     cnt].description
     SET reply->rowlist[row_cnt].celllist[5].string_value = cnvtstring(orders->qual[array_location].
      bill_only[cnt].standard_qty)
     IF ((orders->qual[array_location].categories[cnt].code_value=0))
      SET reply->rowlist[row_cnt].celllist[6].string_value = " "
     ELSE
      SET reply->rowlist[row_cnt].celllist[6].string_value = cnvtstring(orders->qual[array_location].
       categories[cnt].code_value)
     ENDIF
     SET reply->rowlist[row_cnt].celllist[7].string_value = orders->qual[array_location].categories[
     cnt].description
   ENDWHILE
   WHILE (high > cnt)
     SET cnt = (cnt+ 1)
     IF (cnt > 1)
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,7)
     ENDIF
     CASE (type_ind)
      OF 1:
       IF ((orders->qual[array_location].bill_only[cnt].task_assay_cd=0))
        SET reply->rowlist[row_cnt].celllist[3].string_value = " "
       ELSE
        SET reply->rowlist[row_cnt].celllist[3].string_value = cnvtstring(orders->qual[array_location
         ].bill_only[cnt].task_assay_cd)
       ENDIF
       SET reply->rowlist[row_cnt].celllist[4].string_value = orders->qual[array_location].bill_only[
       cnt].description
       SET reply->rowlist[row_cnt].celllist[5].string_value = cnvtstring(orders->qual[array_location]
        .bill_only[cnt].standard_qty)
      OF 2:
       IF ((orders->qual[array_location].categories[cnt].code_value=0))
        SET reply->rowlist[row_cnt].celllist[6].string_value = " "
       ELSE
        SET reply->rowlist[row_cnt].celllist[6].string_value = cnvtstring(orders->qual[array_location
         ].categories[cnt].code_value)
       ENDIF
       SET reply->rowlist[row_cnt].celllist[7].string_value = orders->qual[array_location].
       categories[cnt].description
      OF 4:
       SET reply->rowlist[row_cnt].celllist[4].double_value = orders->qual[array_location].bill_only[
       cnt].task_assay_cd
       SET reply->rowlist[row_cnt].celllist[4].string_value = orders->qual[array_location].bill_only[
       cnt].description
       SET reply->rowlist[row_cnt].celllist[5].string_value = cnvtstring(orders->qual[array_location]
        .bill_only[cnt].standard_qty)
       IF ((orders->qual[array_location].categories[cnt].code_value=0))
        SET reply->rowlist[row_cnt].celllist[6].string_value = " "
       ELSE
        SET reply->rowlist[row_cnt].celllist[6].string_value = cnvtstring(orders->qual[array_location
         ].categories[cnt].code_value)
       ENDIF
       SET reply->rowlist[row_cnt].celllist[7].string_value = orders->qual[array_location].
       categories[cnt].description
     ENDCASE
   ENDWHILE
   SET stat = alterlist(reply->rowlist,row_cnt)
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_bill_only_assoc.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
