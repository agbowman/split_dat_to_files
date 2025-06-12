CREATE PROGRAM bed_aud_rad_tech_proc_fmt_r
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
  )
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_type_cd=radiology_type_cd
     AND oc.active_ind=1
     AND oc.orderable_type_flag != 6)
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
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "catalog_cd"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Primary Mnemonic"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "format_id"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Technical Comment Format"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Exam Rooms"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SELECT INTO "nl:"
  oc.catalog_cd, oc.primary_mnemonic, rtf.format_id,
  rtf.format_desc, cv.display
  FROM order_catalog oc,
   profile_task_r ptr,
   assay_resource_list arl,
   code_value cv,
   dummyt d,
   rad_tech_fmt_erprc_r rt,
   rad_tech_format rtf
  PLAN (oc
   WHERE oc.catalog_type_cd=radiology_type_cd
    AND oc.orderable_type_flag != 6
    AND oc.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1)
   JOIN (arl
   WHERE arl.task_assay_cd=ptr.task_assay_cd
    AND arl.active_ind=1)
   JOIN (cv
   WHERE arl.service_resource_cd=cv.code_value
    AND arl.active_ind=1)
   JOIN (d)
   JOIN (rt
   WHERE rt.catalog_cd=oc.catalog_cd
    AND rt.service_resource_cd=arl.service_resource_cd)
   JOIN (rtf
   WHERE rtf.format_id=rt.format_id
    AND rtf.active_ind=1)
  ORDER BY oc.primary_mnemonic, rt.format_id, cv.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,100)
  HEAD oc.primary_mnemonic
   format_cnt = 0
  HEAD rt.format_id
   format_cnt = 0, cnt = (cnt+ 1)
   IF (mod(cnt,100)=0)
    stat = alterlist(reply->rowlist,(cnt+ 100))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,5), reply->rowlist[cnt].celllist[1].double_value =
   oc.catalog_cd, reply->rowlist[cnt].celllist[2].string_value = oc.primary_mnemonic,
   reply->rowlist[cnt].celllist[3].double_value = rtf.format_id, reply->rowlist[cnt].celllist[4].
   string_value = rtf.format_desc
  HEAD cv.display
   format_cnt = (format_cnt+ 1)
   IF (format_cnt=1)
    reply->rowlist[cnt].celllist[5].string_value = cv.display
   ELSE
    reply->rowlist[cnt].celllist[5].string_value = concat(reply->rowlist[cnt].celllist[5].
     string_value,", ",cv.display)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH outerjoin = d
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_tech_cmt_assoc_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
