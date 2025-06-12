CREATE PROGRAM bed_aud_rad_folder_type
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM image_class_type ict
   PLAN (ict)
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
 SET stat = alterlist(reply->collist,13)
 SET reply->collist[1].header_text = "image_class_type_cd"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Folder Type Number"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Folder Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Item"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "library_group_Cd"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Library Group"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "parent_image_class_type_cd"
 SET reply->collist[7].data_type = 2
 SET reply->collist[7].hide_ind = 1
 SET reply->collist[8].header_text = "Parent Type"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Number of Labels"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Exams Stored in Folder?"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Contents Loanable?"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Number of Exams in Folder"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Create folder by accession?"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SELECT INTO "NL:"
  ict.image_class_type_cd, cv.display, cv.description,
  cv.cdf_meaning, ict.lib_group_cd, cv3.description,
  cv3.display, ict.parent_image_class_type_cd, ict.label_cnt,
  cv.cdf_meaning, ict.store_exams_ind, ict.max_exams,
  ict.create_by_acc_ind
  FROM image_class_type ict,
   code_value cv,
   code_value cv2,
   code_value cv3
  PLAN (ict
   WHERE ict.image_class_type_cd > 0)
   JOIN (cv
   WHERE ict.image_class_type_cd=cv.code_value
    AND cv.description > " ")
   JOIN (cv2
   WHERE ict.parent_image_class_type_cd=cv2.code_value
    AND cv2.code_value > 0)
   JOIN (cv3
   WHERE ict.lib_group_cd=cv3.code_value
    AND cv3.code_value > 0
    AND cv3.display > " "
    AND cv3.description > " ")
  ORDER BY cv3.display, cv.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(reply->rowlist,(10+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,13), reply->rowlist[cnt].celllist[1].double_value =
   ict.image_class_type_cd, reply->rowlist[cnt].celllist[2].string_value = cv.display,
   reply->rowlist[cnt].celllist[3].string_value = cv.description, reply->rowlist[cnt].celllist[4].
   string_value = cv.cdf_meaning, reply->rowlist[cnt].celllist[5].double_value = ict.lib_group_cd,
   reply->rowlist[cnt].celllist[6].string_value = build(cv3.description," (",cv3.display,")"), reply
   ->rowlist[cnt].celllist[7].double_value = ict.parent_image_class_type_cd, reply->rowlist[cnt].
   celllist[8].string_value = cv.cdf_meaning,
   reply->rowlist[cnt].celllist[9].string_value = cnvtstring(ict.label_cnt)
   CASE (ict.store_exams_ind)
    OF 0:
     reply->rowlist[cnt].celllist[10].string_value = "No"
    OF 1:
     reply->rowlist[cnt].celllist[10].string_value = "Yes"
   ENDCASE
   CASE (ict.loanable_ind)
    OF 0:
     reply->rowlist[cnt].celllist[11].string_value = "No"
    OF 1:
     reply->rowlist[cnt].celllist[11].string_value = "Yes"
   ENDCASE
   IF (ict.max_exams=0)
    reply->rowlist[cnt].celllist[12].string_value = "00"
   ELSE
    reply->rowlist[cnt].celllist[12].string_value = cnvtstring(ict.max_exams)
   ENDIF
   CASE (ict.create_by_acc_ind)
    OF 0:
     reply->rowlist[cnt].celllist[13].string_value = "No"
    OF 1:
     reply->rowlist[cnt].celllist[13].string_value = "Yes"
   ENDCASE
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_folder_types_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
