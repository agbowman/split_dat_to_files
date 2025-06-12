CREATE PROGRAM bhs_rad_incorrect_ord
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Location:" = "",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Email ID:" = ""
  WITH outdev, prompt1, prompt2,
  prompt3, prompt4
 FREE RECORD rec_str
 RECORD rec_str(
   1 location[*]
     2 location_cd = f8
     2 complete_locn_disp = vc
     2 person[*]
       3 person_id = f8
       3 name_full_formatted = vc
       3 orders[*]
         4 order_id = f8
         4 order_entry_dt_tm = vc
         4 exam_name = vc
         4 ordering_phy = vc
 ) WITH protect
 FREE RECORD order_catalog
 RECORD order_catalog(
   1 catalog[*]
     2 f_catalog_cd = f8
     2 s_exam_name = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 DECLARE cancel_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",1309,
   "EXAMREPLACED"))
 DECLARE outpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE location_var = vc
 DECLARE ml_cat_cnt = i4
 DECLARE ml_loc_cnt = i4
 DECLARE ml_pat_cnt = i4
 DECLARE ml_ord_cnt = i4
 DECLARE ml_expand_cnt = i4
 DECLARE ml_idx1 = i4
 DECLARE ml_idx2 = i4
 DECLARE ml_idx3 = i4
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=200
    AND ((cv.display_key="MRI*") OR (((cv.display_key="CT*") OR (cv.display_key="US*")) )) )
  ORDER BY cv.display_key, cv.code_value
  HEAD REPORT
   ml_cat_cnt = 0
  HEAD cv.code_value
   ml_cat_cnt += 1, stat = alterlist(order_catalog->catalog,ml_cat_cnt), order_catalog->catalog[
   ml_cat_cnt].s_exam_name = cv.description,
   order_catalog->catalog[ml_cat_cnt].f_catalog_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT
  IF (cnvtint( $PROMPT1)=0)
   PLAN (or1
    WHERE or1.request_dt_tm BETWEEN cnvtdatetime( $PROMPT2) AND cnvtdatetime(concat( $PROMPT3,char(32
       ),"23:59:59"))
     AND expand(ml_expand_cnt,1,ml_cat_cnt,or1.catalog_cd,order_catalog->catalog[ml_expand_cnt].
     f_catalog_cd))
    JOIN (oros
    WHERE oros.order_id=or1.order_id
     AND oros.cancel_reason_cd=cnvtreal(cancel_reason_cd))
    JOIN (e
    WHERE e.encntr_id=oros.encntr_id
     AND e.encntr_type_cd=cnvtreal(outpatient_cd))
    JOIN (ed
    WHERE ed.order_id=oros.order_id)
    JOIN (p
    WHERE p.person_id=ed.person_id)
    JOIN (pr
    WHERE pr.person_id=or1.order_physician_id)
  ELSE
   PLAN (or1
    WHERE or1.request_dt_tm BETWEEN cnvtdatetime( $PROMPT2) AND cnvtdatetime(concat( $PROMPT3,char(32
       ),"23:59:59"))
     AND expand(ml_expand_cnt,1,ml_cat_cnt,or1.catalog_cd,order_catalog->catalog[ml_expand_cnt].
     f_catalog_cd))
    JOIN (oros
    WHERE oros.order_id=or1.order_id
     AND oros.cancel_reason_cd=cnvtreal(cancel_reason_cd))
    JOIN (e
    WHERE e.encntr_id=oros.encntr_id
     AND e.encntr_type_cd=cnvtreal(outpatient_cd)
     AND e.loc_facility_cd=cnvtreal( $PROMPT1))
    JOIN (ed
    WHERE ed.order_id=oros.order_id)
    JOIN (p
    WHERE p.person_id=ed.person_id)
    JOIN (pr
    WHERE pr.person_id=or1.order_physician_id)
  ENDIF
  INTO "nl:"
  FROM order_radiology or1,
   exam_data ed,
   omf_radmgmt_order_st oros,
   person p,
   encounter e,
   prsnl pr
  ORDER BY e.loc_facility_cd, p.person_id, or1.order_id
  HEAD REPORT
   ml_loc_cnt = 0, ml_pat_cnt = 0, ml_ord_cnt = 0
  HEAD e.loc_facility_cd
   ml_pat_cnt = 0, ml_ord_cnt = 0, ml_loc_cnt += 1,
   stat = alterlist(rec_str->location,ml_loc_cnt), location_var = uar_get_code_display(e
    .loc_facility_cd), rec_str->location[ml_loc_cnt].complete_locn_disp = uar_get_code_display(e
    .loc_facility_cd),
   rec_str->location[ml_loc_cnt].location_cd = e.loc_facility_cd
  HEAD p.person_id
   ml_ord_cnt = 0, ml_pat_cnt += 1, stat = alterlist(rec_str->location[ml_loc_cnt].person,ml_pat_cnt),
   rec_str->location[ml_loc_cnt].person[ml_pat_cnt].person_id = p.person_id, rec_str->location[
   ml_loc_cnt].person[ml_pat_cnt].name_full_formatted = p.name_full_formatted
  HEAD or1.order_id
   ml_ord_cnt += 1, stat = alterlist(rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders,
    ml_ord_cnt), rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[ml_ord_cnt].order_id = or1
   .order_id,
   rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[ml_ord_cnt].exam_name =
   uar_get_code_display(or1.catalog_cd), rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[
   ml_ord_cnt].order_entry_dt_tm = format(or1.request_dt_tm,";;q"), rec_str->location[ml_loc_cnt].
   person[ml_pat_cnt].orders[ml_ord_cnt].ordering_phy = pr.name_full_formatted
  WITH nocounter, expand = 1
 ;end select
 CALL echorecord(rec_str)
 SET frec->file_name = concat("incorrect_rad_orders",format(sysdate,"MMDDYYYY;;q"),".csv")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build(char(13),'"LOCATION",','"PATIENT NAME",','"EXAM NAME",',
  '"ORDERING PHYSICIAN",',
  '"ORDER ENTRY DATE TIME",',char(13))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO size(rec_str->location,5))
   FOR (ml_idx2 = 1 TO size(rec_str->location[ml_idx1].person,5))
     FOR (ml_idx3 = 1 TO size(rec_str->location[ml_idx1].person[ml_idx2].orders,5))
      SET frec->file_buf = build('"',rec_str->location[ml_idx1].complete_locn_disp,'","',rec_str->
       location[ml_idx1].person[ml_idx2].name_full_formatted,'","',
       rec_str->location[ml_idx1].person[ml_idx2].orders[ml_idx3].exam_name,'","',rec_str->location[
       ml_idx1].person[ml_idx2].orders[ml_idx3].ordering_phy,'","',rec_str->location[ml_idx1].person[
       ml_idx2].orders[ml_idx3].order_entry_dt_tm,
       '"',char(13))
      SET stat = cclio("WRITE",frec)
     ENDFOR
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 IF (size(rec_str->location,5) > 0)
  IF (cnvtint( $PROMPT1)=0)
   SET location_var = "All Locations"
  ENDIF
  SET s_subject = concat("Incorrect Radiology Orders from ", $PROMPT2," to ", $PROMPT3," for ",
   location_var)
  SET s_email_address =  $PROMPT4
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(frec->file_name),frec->file_name,s_email_address,s_subject,0)
  SELECT INTO  $OUTDEV
   FROM dummyt d3
   HEAD REPORT
    printpsheader = 0, y_pos = 50, row + 1,
    "{F/1}{CPI/11}",
    CALL print(calcpos(25,y_pos)), "CSV with Incorrect Radiology Orders has been emailed to ",
    s_email_address
   WITH nocounter, maxrow = 1000, maxcol = 1000,
    dio = 08, format
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt d3
   HEAD REPORT
    printpsheader = 0, y_pos = 50, row + 1,
    "{F/1}{CPI/11}",
    CALL print(calcpos(25,y_pos)), "No Qualifying Records"
   WITH nocounter, maxrow = 1000, maxcol = 1000,
    dio = 08, format
  ;end select
 ENDIF
END GO
