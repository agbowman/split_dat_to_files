CREATE PROGRAM bed_aud_cat_act_type_dupes:dba
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
  )
 ENDIF
 RECORD temp(
   1 cvlist[*]
     2 code_set = i4
     2 cdf_meaning = vc
     2 cv1 = f8
     2 display1 = vc
     2 cv2 = f8
     2 display2 = vc
 )
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Code Set"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "CDF Meaning"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Code Value1"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Display1"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Code Value2"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Display2"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET totcnt = 0
 SET ct_dupes = 0
 SET at_dupes = 0
 SET cvcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value cv2
  PLAN (cv1
   WHERE cv1.code_set=6000
    AND cv1.active_ind=1
    AND cv1.cdf_meaning > " "
    AND cv1.cdf_meaning IN ("GENERAL LAB", "RADIOLOGY", "PHARMACY", "SURGERY"))
   JOIN (cv2
   WHERE cv2.code_set=cv1.code_set
    AND cv2.active_ind=1
    AND cv2.cdf_meaning=cv1.cdf_meaning
    AND cv2.code_value > cv1.code_value)
  ORDER BY cv1.cdf_meaning
  HEAD cv1.cdf_meaning
   ct_dupes = (ct_dupes+ 1)
  DETAIL
   cvcnt = (cvcnt+ 1), stat = alterlist(temp->cvlist,cvcnt), temp->cvlist[cvcnt].code_set = cv1
   .code_set,
   temp->cvlist[cvcnt].cdf_meaning = cv1.cdf_meaning, temp->cvlist[cvcnt].cv1 = cv1.code_value, temp
   ->cvlist[cvcnt].display1 = cv1.display,
   temp->cvlist[cvcnt].cv2 = cv2.code_value, temp->cvlist[cvcnt].display2 = cv2.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value cv2
  PLAN (cv1
   WHERE cv1.code_set=106
    AND cv1.active_ind=1
    AND cv1.cdf_meaning > " "
    AND cv1.cdf_meaning IN ("AP", "BB", "GLB", "HLA", "MICROBIOLOGY",
   "RADIOLOGY", "PHARMACY"))
   JOIN (cv2
   WHERE cv2.code_set=cv1.code_set
    AND cv2.active_ind=1
    AND cv2.cdf_meaning=cv1.cdf_meaning
    AND cv2.code_value > cv1.code_value)
  ORDER BY cv1.cdf_meaning
  HEAD cv1.cdf_meaning
   at_dupes = (at_dupes+ 1)
  DETAIL
   cvcnt = (cvcnt+ 1), stat = alterlist(temp->cvlist,cvcnt), temp->cvlist[cvcnt].code_set = cv1
   .code_set,
   temp->cvlist[cvcnt].cdf_meaning = cv1.cdf_meaning, temp->cvlist[cvcnt].cv1 = cv1.code_value, temp
   ->cvlist[cvcnt].display1 = cv1.display,
   temp->cvlist[cvcnt].cv2 = cv2.code_value, temp->cvlist[cvcnt].display2 = cv2.display
  WITH nocounter
 ;end select
 SET rcnt = 0
 FOR (x = 1 TO cvcnt)
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->rowlist,rcnt)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
   SET reply->rowlist[rcnt].celllist[1].double_value = temp->cvlist[x].code_set
   SET reply->rowlist[rcnt].celllist[2].string_value = temp->cvlist[x].cdf_meaning
   SET reply->rowlist[rcnt].celllist[3].double_value = temp->cvlist[x].cv1
   SET reply->rowlist[rcnt].celllist[4].string_value = temp->cvlist[x].display1
   SET reply->rowlist[rcnt].celllist[5].double_value = temp->cvlist[x].cv2
   SET reply->rowlist[rcnt].celllist[6].string_value = temp->cvlist[x].display2
 ENDFOR
 IF (rcnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,2)
 SET reply->statlist[1].statistic_meaning = "CATALOGTYPEDUPES"
 SET reply->statlist[1].total_items = 4
 SET reply->statlist[1].qualifying_items = ct_dupes
 IF (ct_dupes > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].statistic_meaning = "ACTIVITYTYPEDUPES"
 SET reply->statlist[2].total_items = 7
 SET reply->statlist[2].qualifying_items = at_dupes
 IF (at_dupes > 0)
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
END GO
