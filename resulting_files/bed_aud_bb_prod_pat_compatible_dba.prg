CREATE PROGRAM bed_aud_bb_prod_pat_compatible:dba
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
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 blood_product = vc
     2 product_aborh_type = vc
     2 validate_aborh_flag = vc
     2 validate_rh_only_flag = vc
     2 crossmatch_flag = vc
     2 autologous_flag = vc
     2 yes_list[*]
       3 code_value = f8
       3 display = vc
     2 warn_list[*]
       3 code_value = f8
       3 display = vc
     2 no_list[*]
       3 code_value = f8
       3 display = vc
 )
 FREE RECORD aborh
 RECORD aborh(
   1 types[*]
     2 code_value = f8
     2 display = vc
 )
 DECLARE high_data_limit = i4 WITH protect, noconstant(5000)
 DECLARE medium_data_limit = i4 WITH protect, noconstant(3000)
 DECLARE bloodproductsize = i4 WITH protect
 DECLARE producttypesize = i4 WITH protect
 DECLARE productparser = vc WITH protect
 DECLARE productparser = vc WITH protect
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE yes_cnt = i4 WITH protect, noconstant(0)
 DECLARE warn_cnt = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(0)
 DECLARE no_cnt = i4 WITH protect, noconstant(0)
 DECLARE row_nbr = i4 WITH protect, noconstant(0)
 DECLARE n = i4 WITH protect, noconstant(0)
 DECLARE warn_hv = i4 WITH protect
 DECLARE yes_hv = i4 WITH protect
 DECLARE w = i4 WITH protect, noconstant(0)
 DECLARE column_cnt = i4 WITH protect, noconstant(0)
 DECLARE found_ind = i4 WITH protect
 SET reply->status_data.status = "F"
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM product_aborh pa
   WHERE pa.active_ind=1
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > high_data_limit)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > medium_data_limit)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE flagparser = vc
 IF (validate(request->product_compatibility.abo_rh_option_flag))
  IF ((request->product_compatibility.abo_rh_option_flag=1))
   SET flagparser = " pa.aborh_option_flag = 0"
  ELSEIF ((request->product_compatibility.abo_rh_option_flag=2))
   SET flagparser = " pa.aborh_option_flag = 1"
  ELSEIF ((request->product_compatibility.abo_rh_option_flag=3))
   SET flagparser = " pa.aborh_option_flag in (0, 1)"
  ENDIF
 ENDIF
 IF ((request->product_compatibility.gt_prsn_flag > 0)
  AND (request->product_compatibility.abo_rh_option_flag > 0))
  SET flagparser = concat(flagparser," and ")
 ELSEIF ((request->product_compatibility.gt_prsn_flag=0)
  AND (request->product_compatibility.abo_rh_option_flag > 0)
  AND (request->product_compatibility.gt_autodir_prsn_flag > 0))
  SET flagparser = concat(flagparser," and ")
 ENDIF
 IF (validate(request->product_compatibility.gt_prsn_flag))
  IF ((request->product_compatibility.gt_prsn_flag=1))
   SET flagparser = concat(flagparser," pa.no_gt_on_prsn_flag = 0")
  ELSEIF ((request->product_compatibility.gt_prsn_flag=2))
   SET flagparser = concat(flagparser," pa.no_gt_on_prsn_flag = 1")
  ELSEIF ((request->product_compatibility.gt_prsn_flag=3))
   SET flagparser = concat(flagparser," pa.no_gt_on_prsn_flag = 2")
  ELSEIF ((request->product_compatibility.gt_prsn_flag=4))
   SET flagparser = concat(flagparser," pa.no_gt_on_prsn_flag in (0, 1)")
  ELSEIF ((request->product_compatibility.gt_prsn_flag=5))
   SET flagparser = concat(flagparser," pa.no_gt_on_prsn_flag in (0, 2)")
  ELSEIF ((request->product_compatibility.gt_prsn_flag=6))
   SET flagparser = concat(flagparser," pa.no_gt_on_prsn_flag in (1, 2)")
  ELSEIF ((request->product_compatibility.gt_prsn_flag=7))
   SET flagparser = concat(flagparser," pa.no_gt_on_prsn_flag in (0,1, 2)")
  ENDIF
 ENDIF
 IF ((request->product_compatibility.gt_autodir_prsn_flag > 0)
  AND (request->product_compatibility.gt_prsn_flag > 0))
  SET flagparser = concat(flagparser," and ")
 ENDIF
 IF (validate(request->product_compatibility.gt_autodir_prsn_flag))
  IF ((request->product_compatibility.gt_autodir_prsn_flag=1))
   SET flagparser = concat(flagparser," pa.no_gt_autodir_prsn_flag = 0")
  ELSEIF ((request->product_compatibility.gt_autodir_prsn_flag=2))
   SET flagparser = concat(flagparser," pa.no_gt_autodir_prsn_flag = 1 ")
  ELSEIF ((request->product_compatibility.gt_autodir_prsn_flag=3))
   SET flagparser = concat(flagparser," pa.no_gt_autodir_prsn_flag = 2 ")
  ELSEIF ((request->product_compatibility.gt_autodir_prsn_flag=4))
   SET flagparser = concat(flagparser," pa.no_gt_autodir_prsn_flag in (0, 1) ")
  ELSEIF ((request->product_compatibility.gt_autodir_prsn_flag=5))
   SET flagparser = concat(flagparser," pa.no_gt_autodir_prsn_flag in (0, 2) ")
  ELSEIF ((request->product_compatibility.gt_autodir_prsn_flag=6))
   SET flagparser = concat(flagparser," pa.no_gt_autodir_prsn_flag in (1, 2) ")
  ELSEIF ((request->product_compatibility.gt_autodir_prsn_flag=7))
   SET flagparser = concat(flagparser," pa.no_gt_autodir_prsn_flag in (0,1, 2) ")
  ENDIF
 ENDIF
 IF ((request->product_compatibility.gt_autodir_prsn_flag=0)
  AND (request->product_compatibility.gt_prsn_flag=0)
  AND (request->product_compatibility.abo_rh_option_flag=0))
  SET flagparser = "1 = 1"
 ENDIF
 CALL echo(flagparser)
 SET bloodproductsize = size(request->blood_product_list,5)
 IF (bloodproductsize > 0)
  SET productparser = build(productparser,"pa.product_cd IN ( ")
  FOR (bp = 1 TO bloodproductsize)
    SET productparser = build(productparser,request->blood_product_list[bp].product_cd,",")
  ENDFOR
  SET productparser = replace(productparser,",","",2)
  SET productparser = build(productparser,")")
 ENDIF
 IF (size(request->blood_product_list,5) > 0
  AND size(request->product_type_list,5) > 0)
  SET productparser = concat(productparser," and ")
 ENDIF
 SET producttypesize = size(request->product_type_list,5)
 IF (producttypesize > 0)
  SET productparser = build(productparser," pa.product_aborh_cd IN ( ")
  FOR (pt = 1 TO producttypesize)
    SET productparser = build(productparser,request->product_type_list[pt].product_aborh_cd,",")
  ENDFOR
  SET productparser = replace(productparser,",","",2)
  SET productparser = build(productparser,")")
 ENDIF
 IF (size(request->blood_product_list,5)=0
  AND size(request->product_type_list,5)=0)
  SET productparser = build(productparser,"1 = 1")
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM product_aborh pa,
   product_patient_aborh ppa,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (pa
   WHERE parser(productparser)
    AND parser(flagparser)
    AND pa.active_ind=1)
   JOIN (ppa
   WHERE ppa.product_cd=outerjoin(pa.product_cd)
    AND ppa.prod_aborh_cd=outerjoin(pa.product_aborh_cd)
    AND ppa.active_ind=outerjoin(1))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(pa.product_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(pa.product_aborh_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(ppa.prsn_aborh_cd)
    AND cv3.active_ind=outerjoin(1))
  ORDER BY cv1.display, cv2.display, cv3.display,
   pa.product_cd, pa.product_aborh_cd
  HEAD pa.product_cd
   tcnt = tcnt
  HEAD pa.product_aborh_cd
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].blood_product = cv1
   .display,
   temp->tqual[tcnt].product_aborh_type = cv2.display
   IF (pa.aborh_option_flag=1)
    temp->tqual[tcnt].validate_aborh_flag = "Yes", temp->tqual[tcnt].validate_rh_only_flag = "No"
   ELSEIF (pa.aborh_option_flag=0)
    temp->tqual[tcnt].validate_aborh_flag = "No", temp->tqual[tcnt].validate_rh_only_flag = "Yes"
   ELSE
    temp->tqual[tcnt].validate_aborh_flag = " ", temp->tqual[tcnt].validate_rh_only_flag = " "
   ENDIF
   IF (pa.no_gt_on_prsn_flag=0)
    temp->tqual[tcnt].crossmatch_flag = "No"
   ELSEIF (pa.no_gt_on_prsn_flag=1)
    temp->tqual[tcnt].crossmatch_flag = "Yes"
   ELSEIF (pa.no_gt_on_prsn_flag=2)
    temp->tqual[tcnt].crossmatch_flag = "Warn"
   ENDIF
   IF (pa.no_gt_autodir_prsn_flag=0)
    temp->tqual[tcnt].autologous_flag = "No"
   ELSEIF (pa.no_gt_autodir_prsn_flag=1)
    temp->tqual[tcnt].autologous_flag = "Yes"
   ELSEIF (pa.no_gt_autodir_prsn_flag=2)
    temp->tqual[tcnt].autologous_flag = "Warn"
   ENDIF
   yes_cnt = 0, warn_cnt = 0
  DETAIL
   IF (ppa.warn_ind=0)
    yes_cnt = (yes_cnt+ 1), stat = alterlist(temp->tqual[tcnt].yes_list,yes_cnt), temp->tqual[tcnt].
    yes_list[yes_cnt].code_value = ppa.prsn_aborh_cd,
    temp->tqual[tcnt].yes_list[yes_cnt].display = cv3.display
   ELSE
    warn_cnt = (warn_cnt+ 1), stat = alterlist(temp->tqual[tcnt].warn_list,warn_cnt), temp->tqual[
    tcnt].warn_list[warn_cnt].code_value = ppa.prsn_aborh_cd,
    temp->tqual[tcnt].warn_list[warn_cnt].display = cv3.display
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "Blood Product"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Product ABO/Rh Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Validate Patient's ABO/Rh?"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Validate Patient's Rh Only?"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Crossmatch or dispense to patient with no group or type?"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text =
 "If Autologous or Directed, associate to patient with no group or type when received?"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Compatible Patient ABO/Rh Type - Yes"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Compatible Patient ABO/Rh Type - Yes w/ Warning"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Compatible Patient ABO/Rh Type - No"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET acnt = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=1640
   AND cv.active_ind=1
  ORDER BY cv.display
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(aborh->types,acnt), aborh->types[acnt].code_value = cv
   .code_value,
   aborh->types[acnt].display = cv.display
  WITH nocounter
 ;end select
 FOR (t = 1 TO tcnt)
   SET yes_cnt = size(temp->tqual[t].yes_list,5)
   SET warn_cnt = size(temp->tqual[t].warn_list,5)
   SET no_cnt = 0
   FOR (a = 1 TO acnt)
     SET found_ind = 0
     FOR (y = 1 TO yes_cnt)
       IF ((temp->tqual[t].yes_list[y].code_value=aborh->types[a].code_value))
        SET found_ind = 1
        SET y = (yes_cnt+ 1)
       ENDIF
     ENDFOR
     IF (found_ind=0)
      FOR (w = 1 TO warn_cnt)
        IF ((temp->tqual[t].warn_list[w].code_value=aborh->types[a].code_value))
         SET found_ind = 1
         SET w = (warn_cnt+ 1)
        ENDIF
      ENDFOR
     ENDIF
     IF (found_ind=0)
      SET no_cnt = (no_cnt+ 1)
      SET stat = alterlist(temp->tqual[t].no_list,no_cnt)
      SET temp->tqual[t].no_list[no_cnt].code_value = aborh->types[a].code_value
      SET temp->tqual[t].no_list[no_cnt].display = aborh->types[a].display
     ENDIF
   ENDFOR
 ENDFOR
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].blood_product
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].product_aborh_type
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].validate_aborh_flag
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].validate_rh_only_flag
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].crossmatch_flag
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].autologous_flag
   SET yes_cnt = size(temp->tqual[x].yes_list,5)
   SET warn_cnt = size(temp->tqual[x].warn_list,5)
   SET no_cnt = size(temp->tqual[x].no_list,5)
   SET column_cnt = (column_cnt+ maxval(yes_cnt,warn_cnt,no_cnt))
   SET w = 0
   SET n = 0
   IF (yes_cnt > 0)
    FOR (y = 1 TO yes_cnt)
      SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].yes_list[y].display
      SET w = (w+ 1)
      IF (((w < warn_cnt) OR (w=warn_cnt)) )
       SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].warn_list[w].display
      ENDIF
      SET n = (n+ 1)
      IF (((n < no_cnt) OR (n=no_cnt)) )
       SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].no_list[n].display
      ENDIF
      IF (y < yes_cnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
      ENDIF
    ENDFOR
    IF (w < warn_cnt)
     SET w = (w+ 1)
     FOR (w = w TO warn_cnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
       SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].warn_list[w].display
       SET n = (n+ 1)
       IF (((n < no_cnt) OR (n=no_cnt)) )
        SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].no_list[n].display
       ENDIF
     ENDFOR
    ENDIF
    IF (n < no_cnt)
     SET n = (n+ 1)
     FOR (n = n TO no_cnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
       SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].no_list[n].display
     ENDFOR
    ENDIF
   ELSEIF (warn_cnt > 0)
    FOR (w = 1 TO warn_cnt)
      SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].warn_list[w].display
      SET n = (n+ 1)
      IF (((n < no_cnt) OR (n=no_cnt)) )
       SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].no_list[n].display
      ENDIF
      IF (w < warn_cnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
      ENDIF
    ENDFOR
    IF (n < no_cnt)
     SET n = (n+ 1)
     FOR (n = n TO no_cnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
       SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].no_list[n].display
     ENDFOR
    ENDIF
   ELSEIF (no_cnt > 0)
    FOR (n = 1 TO no_cnt)
     SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].no_list[n].display
     IF (n < no_cnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
     ENDIF
    ENDFOR
   ENDIF
   IF ((request->skip_volume_check_ind=0))
    IF (((row_nbr > high_data_limit) OR (column_cnt > high_data_limit)) )
     SET reply->high_volume_flag = 2
     SET stat = alterlist(reply->rowlist,0)
     SET stat = alterlist(reply->collist,0)
     GO TO exit_script
    ELSEIF (row_nbr > medium_data_limit)
     SET reply->high_volume_flag = 1
     SET stat = alterlist(reply->rowlist,0)
     SET stat = alterlist(reply->collist,0)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_product_patient_compatibility.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
