CREATE PROGRAM bed_aud_bb_1606_pc_compare:dba
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
   1 qual[*]
     2 product_class_cd = f8
     2 description = vc
     2 missing_pc_ind = i2
     2 missing_cv_ind = i2
 )
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Product Class"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Missing CS 1606 Entry"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Missing Product_Class Entry"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "product_class_cd/code_value"
 SET reply->collist[4].data_type = 2
 SET reply->collist[4].hide_ind = 1
 SET totcnt = 0
 SELECT INTO "nl:"
  pcnt = count(*)
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1606
    AND cv.active_ind=1)
  DETAIL
   totcnt = pcnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pcnt = count(*)
  FROM product_class pc
  PLAN (pc
   WHERE pc.active_ind=1)
  DETAIL
   IF (pcnt > totcnt)
    totcnt = pcnt
   ENDIF
  WITH nocounter
 ;end select
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = 1),
   product_class pc
  PLAN (cv
   WHERE cv.code_set=1606
    AND cv.active_ind=1)
   JOIN (d)
   JOIN (pc
   WHERE pc.product_class_cd=cv.code_value
    AND pc.active_ind=1)
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(temp->qual,pcnt), temp->qual[pcnt].product_class_cd = cv
   .code_value,
   temp->qual[pcnt].description = cv.display, temp->qual[pcnt].missing_pc_ind = 1
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM product_class pc,
   (dummyt d  WITH seq = 1),
   code_value cv
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (d)
   JOIN (cv
   WHERE cv.code_value=pc.product_class_cd
    AND cv.code_set=1606
    AND cv.active_ind=1)
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(temp->qual,pcnt), temp->qual[pcnt].product_class_cd = pc
   .product_class_cd,
   temp->qual[pcnt].description = pc.description, temp->qual[pcnt].missing_cv_ind = 1
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET qcnt = 0
 IF (pcnt > 0)
  SELECT INTO "nl:"
   disp_key = cnvtupper(temp->qual[d.seq].description)
   FROM (dummyt d  WITH seq = pcnt)
   ORDER BY disp_key
   HEAD REPORT
    qcnt = 0
   DETAIL
    qcnt = (qcnt+ 1), stat = alterlist(reply->rowlist,qcnt), stat = alterlist(reply->rowlist[qcnt].
     celllist,4),
    reply->rowlist[qcnt].celllist[1].string_value = temp->qual[qcnt].description
    IF ((temp->qual[qcnt].missing_cv_ind=1))
     reply->rowlist[qcnt].celllist[2].string_value = "X", reply->rowlist[qcnt].celllist[3].
     string_value = " "
    ELSE
     reply->rowlist[qcnt].celllist[2].string_value = " ", reply->rowlist[qcnt].celllist[3].
     string_value = "X"
    ENDIF
    reply->rowlist[qcnt].celllist[4].double_value = temp->qual[qcnt].product_class_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (qcnt > 0)
  SET reply->run_status_flag = 3
  SET stat = alterlist(reply->statlist,1)
  SET reply->statlist[1].statistic_meaning = "BBPRODCLASSSYNCH"
  SET reply->statlist[1].total_items = totcnt
  SET reply->statlist[1].qualifying_items = qcnt
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
  SET stat = alterlist(reply->statlist,1)
  SET reply->statlist[1].statistic_meaning = "BBPRODCLASSSYNCH"
  SET reply->statlist[1].total_items = totcnt
  SET reply->statlist[1].qualifying_items = 0
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->status_data.status = "S"
END GO
