CREATE PROGRAM bed_aud_rad_single_segment
 FREE RECORD orders
 RECORD orders(
   1 qual[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 description = vc
 )
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
    1 mnemonics[*]
      2 primary_mnemonic = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE end_cnt = i2 WITH protect, noconstant(0)
 DECLARE radiology_type_cd = f8
 DECLARE exam_dta_cd = f8
 DECLARE exam_rooms = vc
 IF (validate(request->mnemonics))
  DECLARE isfiltered = i4 WITH protect, noconstant(1)
 ELSE
  DECLARE isfiltered = i4 WITH protect, noconstant(0)
 ENDIF
 DECLARE req_cnt = i4 WITH protect, noconstant(0)
 SET req_cnt = size(request->mnemonics,5)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="RADIOLOGY"
   AND cv.code_set=6000
  DETAIL
   radiology_type_cd = cv.code_value
  WITH noheading, nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="11"
   AND cv.code_set=289
  DETAIL
   exam_dta_cd = cv.code_value
  WITH noheading, nocounter
 ;end select
 DECLARE high_volume_cnt = i2 WITH protect, noconstant(0)
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc,
    profile_task_r ptr,
    discrete_task_assay dta
   PLAN (oc
    WHERE oc.catalog_type_cd=radiology_type_cd
     AND oc.active_ind=1
     AND oc.catalog_type_cd != 6)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.default_result_type_cd=exam_dta_cd)
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
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "catalog_Cd"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Primary Mnemonic"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "task_assay_cd"
 SET reply->collist[4].data_type = 2
 SET reply->collist[4].hide_ind = 1
 SET reply->collist[5].header_text = "Segment"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Required"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Default"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "service_resource_cd"
 SET reply->collist[8].data_type = 2
 SET reply->collist[8].hide_ind = 1
 SET reply->collist[9].header_text = "Exam Room"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 IF (isfiltered=0)
  SELECT INTO "nl:"
   oc.catalog_cd, oc.primary_mnemonic, oc.description
   FROM order_catalog oc,
    profile_task_r ptr,
    discrete_task_assay dta
   PLAN (oc
    WHERE oc.catalog_type_cd=radiology_type_cd
     AND oc.active_ind=1
     AND oc.catalog_type_cd != 6)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.default_result_type_cd=exam_dta_cd)
   GROUP BY oc.primary_mnemonic, oc.description, oc.catalog_cd
   HAVING count(*)=1
   ORDER BY oc.primary_mnemonic
   HEAD REPORT
    cnt = 0, stat = alterlist(orders->qual,100)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,100)=0)
     stat = alterlist(orders->qual,(100+ cnt))
    ENDIF
    orders->qual[cnt].catalog_cd = oc.catalog_cd, orders->qual[cnt].description = oc.description,
    orders->qual[cnt].primary_mnemonic = oc.primary_mnemonic
   FOOT REPORT
    stat = alterlist(orders->qual,cnt)
   WITH nocounter, noheading
  ;end select
 ELSE
  SELECT INTO "nl:"
   oc.catalog_cd, oc.primary_mnemonic, oc.description
   FROM (dummyt d  WITH seq = value(req_cnt)),
    order_catalog oc,
    profile_task_r ptr,
    discrete_task_assay dta
   PLAN (d)
    JOIN (oc
    WHERE oc.catalog_type_cd=radiology_type_cd
     AND oc.active_ind=1
     AND oc.catalog_type_cd != 6
     AND (oc.primary_mnemonic=request->mnemonics[d.seq].primary_mnemonic))
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.default_result_type_cd=exam_dta_cd)
   GROUP BY oc.primary_mnemonic, oc.description, oc.catalog_cd
   HAVING count(*)=1
   ORDER BY oc.primary_mnemonic
   HEAD REPORT
    cnt = 0, stat = alterlist(orders->qual,100)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,100)=0)
     stat = alterlist(orders->qual,(100+ cnt))
    ENDIF
    orders->qual[cnt].catalog_cd = oc.catalog_cd, orders->qual[cnt].description = oc.description,
    orders->qual[cnt].primary_mnemonic = oc.primary_mnemonic
   FOOT REPORT
    stat = alterlist(orders->qual,cnt)
   WITH nocounter, noheading
  ;end select
 ENDIF
 SELECT INTO "nl:"
  dta.task_assay_cd, dta.description, ptr.pending_ind,
  arl.primary_ind, cv.code_value, cv.display
  FROM (dummyt d  WITH seq = value(size(orders->qual,5))),
   profile_task_r ptr,
   discrete_task_assay dta,
   dummyt d2,
   assay_resource_list arl,
   code_value cv
  PLAN (d)
   JOIN (ptr
   WHERE (ptr.catalog_cd=orders->qual[d.seq].catalog_cd)
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND dta.active_ind=1)
   JOIN (d2)
   JOIN (arl
   WHERE dta.task_assay_cd=arl.task_assay_cd
    AND arl.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=arl.service_resource_cd
    AND cv.active_ind=1)
  ORDER BY d.seq, ptr.sequence, arl.sequence
  HEAD REPORT
   cnt = 0, end_cnt = 0, stat = alterlist(reply->rowlist,10)
  HEAD d.seq
   IF (end_cnt=cnt)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=0)
     stat = alterlist(reply->rowlist,(10+ cnt))
    ENDIF
    stat = alterlist(reply->rowlist[cnt].celllist,9)
   ENDIF
   reply->rowlist[cnt].celllist[1].double_value = orders->qual[d.seq].catalog_cd, reply->rowlist[cnt]
   .celllist[2].string_value = orders->qual[d.seq].description, reply->rowlist[cnt].celllist[3].
   string_value = orders->qual[d.seq].primary_mnemonic
  HEAD dta.description
   IF (end_cnt=cnt)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=0)
     stat = alterlist(reply->rowlist,(10+ cnt))
    ENDIF
    stat = alterlist(reply->rowlist[cnt].celllist,9)
   ENDIF
   reply->rowlist[cnt].celllist[4].double_value = dta.task_assay_cd, reply->rowlist[cnt].celllist[5].
   string_value = dta.description
   CASE (ptr.pending_ind)
    OF 0:
     reply->rowlist[cnt].celllist[6].string_value = "No"
    OF 1:
     reply->rowlist[cnt].celllist[6].string_value = "Yes"
   ENDCASE
  HEAD cv.code_value
   IF (end_cnt=cnt)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=0)
     stat = alterlist(reply->rowlist,(10+ cnt))
    ENDIF
    stat = alterlist(reply->rowlist[cnt].celllist,9)
   ENDIF
   IF (arl.primary_ind=1)
    reply->rowlist[cnt].celllist[7].string_value = "Default"
   ENDIF
   reply->rowlist[cnt].celllist[8].double_value = cv.code_value, reply->rowlist[cnt].celllist[9].
   string_value = cv.display
  DETAIL
   end_cnt = cnt
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading, outerjoin = d2
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_single_segment_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echo(high_volume_cnt)
 CALL echorecord(reply)
END GO
