CREATE PROGRAM bbt_rpt_spec_test_cor:dba
 RECORD spec_test(
   1 spec_list[*]
     2 spec_test_disp = c40
 )
 RECORD cor_spec_test(
   1 spec_list[*]
     2 spec_test_disp = c40
     2 correction_ind = i2
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 RECORD captions(
   1 correction_type = vc
   1 demographic = vc
   1 current = vc
   1 product_number = vc
   1 product_sub_number = vc
   1 supplier_prefix = vc
   1 product_type = vc
   1 volume = vc
   1 unit_of_measure = vc
   1 exp_dt_tm = vc
   1 aborh = vc
   1 special_testing = vc
   1 current2 = vc
   1 added = vc
   1 removed = vc
   1 corrected = vc
   1 dt_tm = vc
   1 tech_id = vc
   1 reason = vc
   1 note = vc
   1 end_of_report = vc
   1 inc_title = vc
   1 inc_time = vc
   1 inc_as_of_date = vc
   1 inc_blood_bank_owner = vc
   1 inc_inventory_area = vc
   1 inc_beg_dt_tm = vc
   1 inc_end_dt_tm = vc
   1 inc_report_id = vc
   1 inc_page = vc
   1 inc_printed = vc
 )
 SET captions->correction_type = uar_i18ngetmessage(i18nhandle,"correction_type","Correction Type: ")
 SET captions->demographic = uar_i18ngetmessage(i18nhandle,"demographic","Demographic")
 SET captions->current = uar_i18ngetmessage(i18nhandle,"current","Current")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->product_sub_number = uar_i18ngetmessage(i18nhandle,"product_sub_number",
  "Product Sub Number")
 SET captions->supplier_prefix = uar_i18ngetmessage(i18nhandle,"supplier_prefix","Supplier Prefix")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->volume = uar_i18ngetmessage(i18nhandle,"volume","Volume")
 SET captions->unit_of_measure = uar_i18ngetmessage(i18nhandle,"unit_of_measure","Unit of Measure")
 SET captions->exp_dt_tm = uar_i18ngetmessage(i18nhandle,"exp_dt_tm","Expiration Date/Time")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->special_testing = uar_i18ngetmessage(i18nhandle,"special_testing","Special Testing ")
 SET captions->current2 = uar_i18ngetmessage(i18nhandle,"current2","Current:")
 SET captions->added = uar_i18ngetmessage(i18nhandle,"added","Added:")
 SET captions->removed = uar_i18ngetmessage(i18nhandle,"removed","Removed:")
 SET captions->corrected = uar_i18ngetmessage(i18nhandle,"corrected","CORRECTED:")
 SET captions->dt_tm = uar_i18ngetmessage(i18nhandle,"dt_tm","Date/Time")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"reason","Reason")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->inc_title = uar_i18ngetmessage(i18nhandle,"inc_title",
  "P R O D U C T   C O R R E C T I O N S")
 SET captions->inc_time = uar_i18ngetmessage(i18nhandle,"inc_time","Time:")
 SET captions->inc_as_of_date = uar_i18ngetmessage(i18nhandle,"inc_as_of_date","As of Date:")
 SET captions->inc_blood_bank_owner = uar_i18ngetmessage(i18nhandle,"inc_blood_bank_owner",
  "Blood Bank Owner: ")
 SET captions->inc_inventory_area = uar_i18ngetmessage(i18nhandle,"inc_inventory_area",
  "Inventory Area: ")
 SET captions->inc_beg_dt_tm = uar_i18ngetmessage(i18nhandle,"inc_beg_dt_tm","Beginnning Date/Time:")
 SET captions->inc_end_dt_tm = uar_i18ngetmessage(i18nhandle,"inc_end_dt_tm","Ending Date/Time:")
 SET captions->inc_report_id = uar_i18ngetmessage(i18nhandle,"inc_report_id",
  "Report ID: BBT_RPT_PROD_COR")
 SET captions->inc_page = uar_i18ngetmessage(i18nhandle,"inc_page","Page:")
 SET captions->inc_printed = uar_i18ngetmessage(i18nhandle,"inc_printed","Printed:")
 SET line = fillstring(125,"_")
 SET st_cnt = 0
 SET cst_cnt = 0
 SET k = 0
 SET idx = 0
 SET stat = alterlist(spec_test->spec_list,5)
 SET stat = alterlist(cor_spec_test->spec_list,5)
 SET found_cmp = "N"
 SELECT INTO cpm_cfn_info->file_name_logical
  cp.product_id, cp_reason_disp = uar_get_code_display(cp.correction_reason_cd), cp.correction_id,
  cp.updt_dt_tm, cp.updt_id, prs.username,
  pr.product_nbr, pr.product_sub_nbr, pr_product_disp = uar_get_code_display(pr.product_cd),
  pr_cur_unit_meas = uar_get_code_display(pr.cur_unit_meas_cd), bp.supplier_prefix, bp.cur_volume,
  bp_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_rh_disp = uar_get_code_display(bp.cur_rh_cd),
  st.special_testing_id,
  st.special_testing_cd, st_special_testing_disp = uar_get_code_display(st.special_testing_cd), cst
  .special_testing_cd,
  cst_special_testing_disp = uar_get_code_display(cst.special_testing_cd), cst.new_spec_test_ind,
  cst_flg = decode(cst.seq,"CST","XXX"),
  st_flg = decode(st.seq,"ST","XX")
  FROM (dummyt d1  WITH seq = 1),
   corrected_product cp,
   prsnl prs,
   product pr,
   blood_product bp,
   (dummyt d_st  WITH seq = 1),
   special_testing st,
   corrected_special_tests cst
  PLAN (d1)
   JOIN (cp
   WHERE cp.correction_type_cd=spec_test_cd
    AND cp.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm))
   JOIN (prs
   WHERE prs.person_id=cp.updt_id)
   JOIN (pr
   WHERE pr.product_id=cp.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (bp
   WHERE bp.product_id=pr.product_id)
   JOIN (d_st
   WHERE d_st.seq=1)
   JOIN (((st
   WHERE st.product_id=pr.product_id
    AND st.active_ind=1)
   ) ORJOIN ((cst
   WHERE cst.correction_id=cp.correction_id)
   ))
  ORDER BY cp.correction_id DESC, st.special_testing_id
  HEAD REPORT
   cmp_cnt = 0
  HEAD PAGE
   row 0,
   CALL center(captions->inc_title,1,125), col 107,
   captions->inc_time, col 121, curtime"@TIMENOSECONDS;;m",
   row + 1, col 107, captions->inc_as_of_date,
   col 119, curdate"@DATECONDENSED;;d", inc_i18nhandle = 0,
   inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
   IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
    inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
     "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
   ELSE
    col 1, sub_get_location_name
   ENDIF
   row + 1
   IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
    IF (sub_get_location_address1 != " ")
     col 1, sub_get_location_address1, row + 1
    ENDIF
    IF (sub_get_location_address2 != " ")
     col 1, sub_get_location_address2, row + 1
    ENDIF
    IF (sub_get_location_address3 != " ")
     col 1, sub_get_location_address3, row + 1
    ENDIF
    IF (sub_get_location_address4 != " ")
     col 1, sub_get_location_address4, row + 1
    ENDIF
    IF (sub_get_location_citystatezip != ",   ")
     col 1, sub_get_location_citystatezip, row + 1
    ENDIF
    IF (sub_get_location_country != " ")
     col 1, sub_get_location_country, row + 1
    ENDIF
   ENDIF
   row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
   captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
   col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
   col 74, captions->inc_end_dt_tm, col 92,
   dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
   row + 2, col 1, captions->inc_blood_bank_owner
   IF ((request->cur_owner_area_cd=0.0))
    cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
   ENDIF
   col 19, cur_owner_area_disp, row + 1,
   col 1, captions->inc_inventory_area
   IF ((request->cur_inv_area_cd=0.0))
    cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
   ENDIF
   col 17, cur_inv_area_disp, row + 2,
   col 1, captions->correction_type, col 19,
   spec_test_disp, row + 2
  HEAD cp.correction_id
   cst_cnt = 0, st_cnt = 0
  DETAIL
   IF (cst_flg="CST")
    datafoundflag = true, cst_cnt += 1
    IF (mod(cst_cnt,5)=1
     AND cst_cnt != 1)
     stat = alterlist(cor_spec_test->spec_list,(cst_cnt+ 4))
    ENDIF
    cor_spec_test->spec_list[cst_cnt].correction_ind = cst.new_spec_test_ind, cor_spec_test->
    spec_list[cst_cnt].spec_test_disp = cst_special_testing_disp
   ENDIF
   IF (st_flg="ST")
    datafoundflag = true, st_cnt += 1
    IF (mod(st_cnt,5)=1
     AND st_cnt != 1)
     stat = alterlist(spec_test->spec_list,(st_cnt+ 4))
    ENDIF
    spec_test->spec_list[st_cnt].spec_test_disp = st_special_testing_disp
   ENDIF
  FOOT  cp.correction_id
   row + 1, col 9, captions->demographic,
   col 38, captions->current, row + 1,
   col 1, "------------------------", col 27,
   "-----------------------------", row + 1
   IF (cp.correction_id > 0.0)
    stat = alterlist(spec_test->spec_list,st_cnt), stat = alterlist(cor_spec_test->spec_list,cst_cnt)
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->product_number, col 27,
    pr.product_nbr, row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->product_sub_number, col 27,
    pr.product_sub_nbr, row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->supplier_prefix, col 27,
    bp.supplier_prefix, row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->product_type, col 27,
    pr_product_disp, row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->volume, vol = trim(cnvtstring(bp.cur_volume,4,0,r)),
    col 27, vol, row + 1
    IF (row > 56)
     BREAK
    ENDIF
    cur_unit_meas = trim(pr_cur_unit_meas), col 1, captions->unit_of_measure,
    col 27, cur_unit_meas"##########", row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->exp_dt_tm, expire_dt_tm = cnvtdatetime(pr.cur_expire_dt_tm),
    col 27, expire_dt_tm"@DATECONDENSED;;d", col 35,
    expire_dt_tm"@TIMENOSECONDS;;M", row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->aborh, cur_abo_rh_disp = concat(trim(bp_abo_disp)," ",trim(bp_rh_disp)),
    col 27, cur_abo_rh_disp"###############", row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->special_testing, col 27,
    captions->current2, st_display = fillstring(90," "), idx = 0
    IF (st_cnt > 0)
     FOR (idx = 1 TO st_cnt)
      st_display_temp = concat(trim(spec_test->spec_list[idx].spec_test_disp),", ",trim(st_display)),
      IF (size(trim(st_display_temp)) > 84)
       col 36, st_display, row + 1
       IF (row > 56)
        BREAK
       ENDIF
       st_display = fillstring(90," "), st_display = concat(trim(spec_test->spec_list[idx].
         spec_test_disp),", ",trim(st_display)), st_display_temp = trim(st_display)
      ELSE
       st_display = concat(trim(spec_test->spec_list[idx].spec_test_disp),", ",trim(st_display))
      ENDIF
     ENDFOR
    ENDIF
    st_display = substring(1,(size(trim(st_display)) - 1),st_display), col 36, st_display,
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    cst_added_display = fillstring(90," "), cst_removed_display = fillstring(90," "), first_time =
    "Y",
    idx = 0
    IF (cst_cnt > 0)
     FOR (idx = 1 TO cst_cnt)
       IF ((cor_spec_test->spec_list[idx].correction_ind=1))
        IF (first_time="Y")
         first_time = "N", col 27, captions->added,
         st_display = fillstring(90," ")
        ENDIF
        cst_added_display_temp = concat(trim(cor_spec_test->spec_list[idx].spec_test_disp),", ",trim(
          cst_added_display))
        IF (size(trim(cst_added_display_temp)) > 84)
         col 36, cst_added_display, row + 1
         IF (row > 56)
          BREAK
         ENDIF
         cst_added_display = concat(trim(cor_spec_test->spec_list[idx].spec_test_disp),",")
        ELSE
         cst_added_display = concat(trim(cor_spec_test->spec_list[idx].spec_test_disp),", ",trim(
           cst_added_display))
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    cst_added_display = substring(1,(size(trim(cst_added_display)) - 1),cst_added_display)
    IF (cst_added_display > " ")
     col 36, cst_added_display, row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
    first_time = "Y", st_display = fillstring(90," ")
    FOR (idx = 1 TO cst_cnt)
      IF ((cor_spec_test->spec_list[idx].correction_ind=0))
       IF (first_time="Y")
        first_time = "N", col 27, captions->removed,
        st_display = fillstring(90," ")
       ENDIF
       cst_removed_display_temp = concat(trim(cor_spec_test->spec_list[idx].spec_test_disp),", ",trim
        (cst_removed_display))
       IF (size(trim(cst_removed_display_temp)) > 84)
        col 36, cst_removed_display, row + 1
        IF (row > 56)
         BREAK
        ENDIF
        cst_removed_display = concat(trim(cor_spec_test->spec_list[idx].spec_test_disp),",")
       ELSE
        cst_removed_display = concat(trim(cor_spec_test->spec_list[idx].spec_test_disp),", ",trim(
          cst_removed_display))
       ENDIF
      ENDIF
    ENDFOR
    cst_removed_display = substring(1,(size(trim(cst_removed_display)) - 1),cst_removed_display)
    IF (cst_removed_display > " ")
     col 36, cst_removed_display, row + 1
    ENDIF
    row + 1
    IF (row > 54)
     BREAK
    ENDIF
    col 1, captions->corrected, col 12,
    captions->dt_tm, col 27, captions->tech_id,
    col 41, captions->reason, col 77,
    captions->note, row + 1, col 12,
    "---------", col 27, "----------",
    col 36, "--------------------", col 56,
    "-----------------------------------------------------------", row + 1, updt_dt_tm = cnvtdatetime
    (cp.updt_dt_tm),
    col 12, updt_dt_tm"@DATECONDENSED;;d", col 20,
    updt_dt_tm"@TIMENOSECONDS;;M", col 27, prs.username"######",
    col 36, cp_reason_disp, b_cnt = 1,
    col_cnt = 63, start_col_cnt = 63, max_width = 62,
    pos_left = 62, correction_notes = trim(cp.correction_note), b_strg = correction_notes,
    b_str_len = size(trim(b_strg))
    IF (b_str_len > 0)
     WHILE (b_cnt <= b_str_len)
       IF (substring(b_cnt,2,b_strg)=concat(char(13),char(10)))
        b_cnt += 2, col_cnt = start_col_cnt, pos_left = max_width
       ELSE
        text->s_char = substring(b_cnt,1,b_strg)
        IF ((text->s_char=" "))
         IF ((col_cnt > (start_col_cnt+ max_width)))
          b_cnt += 1, row + 1
          IF (row > 55)
           BREAK
          ENDIF
          col_cnt = start_col_cnt, pos_left = max_width
         ELSE
          b_cnt += 1, col col_cnt, text->s_char,
          col_cnt += 1, pos_left -= 1
         ENDIF
        ELSE
         cont_flg = "Y", word_len = 0, inc_flg = "N",
         b_cnt_sub = (b_cnt+ 1)
         WHILE (cont_flg="Y")
           IF (((substring(b_cnt_sub,1,b_strg)=" ") OR (substring(b_cnt_sub,2,b_strg)=concat(char(13),
            char(10)))) )
            cont_flg = "N"
           ELSE
            word_len += 1
            IF (word_len > pos_left)
             inc_flg = "Y", cont_flg = "N"
            ELSE
             b_cnt_sub += 1
            ENDIF
           ENDIF
         ENDWHILE
         IF (inc_flg="Y")
          b_cnt += 1, row + 1
          IF (row > 55)
           BREAK
          ENDIF
          col_cnt = start_col_cnt, pos_left = max_width, col col_cnt,
          text->s_char, col_cnt += 1, pos_left -= 1
         ELSE
          b_cnt += 1, col col_cnt, text->s_char,
          col_cnt += 1, pos_left -= 1
         ENDIF
        ENDIF
       ENDIF
     ENDWHILE
    ENDIF
    row + 2
    IF (row > 56)
     BREAK
    ENDIF
    col 1, "*", stat = alterlist(spec_test->spec_list,0),
    stat = alterlist(spec_test->spec_list,5), stat = alterlist(cor_spec_test->spec_list,0), stat =
    alterlist(cor_spec_test->spec_list,5)
   ENDIF
  FOOT PAGE
   row 57, col 1,
   "------------------------------------------------------------------------------------------------------------------------------"
,
   row + 1, col 1, captions->inc_report_id,
   col 58, captions->inc_page, col 64,
   curpage"###", col 109, captions->inc_printed,
   col 119, curdate"@DATECONDENSED;;d", row + 1
  FOOT REPORT
   row 60,
   CALL center(captions->end_of_report,1,125)
  WITH nocounter, maxrow = 63, outerjoin(d1),
   outerjoin(d_st), dontcare(st), compress,
   nolandscape, nullreport
 ;end select
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
 SET reply->status_data.status = "S"
END GO
