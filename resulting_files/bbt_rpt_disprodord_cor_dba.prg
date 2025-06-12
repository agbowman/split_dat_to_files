CREATE PROGRAM bbt_rpt_disprodord_cor:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 SET sub_get_location_name = fillstring(25," ")
 SET sub_get_location_address1 = fillstring(100," ")
 SET sub_get_location_address2 = fillstring(100," ")
 SET sub_get_location_address3 = fillstring(100," ")
 SET sub_get_location_address4 = fillstring(100," ")
 SET sub_get_location_citystatezip = fillstring(100," ")
 SET sub_get_location_country = fillstring(100," ")
 IF ((request->address_location_cd != 0))
  SET addr_type_cd = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",code_cnt,addr_type_cd)
  IF (addr_type_cd=0.0)
   SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
  ELSE
   SELECT INTO "nl:"
    a.street_addr, a.street_addr2, a.street_addr3,
    a.street_addr4, a.city, a.state,
    a.zipcode, a.country, l.location_cd
    FROM address a
    WHERE a.active_ind=1
     AND a.address_type_cd=addr_type_cd
     AND a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=request->address_location_cd)
    DETAIL
     sub_get_location_name = uar_get_code_display(request->address_location_cd),
     sub_get_location_address1 = a.street_addr, sub_get_location_address2 = a.street_addr2,
     sub_get_location_address3 = a.street_addr3, sub_get_location_address4 = a.street_addr4,
     sub_get_location_citystatezip = concat(trim(a.city),", ",trim(a.state),"  ",trim(a.zipcode)),
     sub_get_location_country = a.country
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
   ENDIF
  ENDIF
 ELSE
  SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
 ENDIF
 SET disprodordcd = 0.0
 SET disprodord_disp = fillstring(40," ")
 SET disprodordcd = uar_get_code_by("MEANING",14115,"DISPPRODORD")
 SET serial_count = 0
 RECORD text(
   1 s_char = c1
 )
 SET b_cnt = 0
 SET b_strg = fillstring(255," ")
 SET col_cnt = 0
 SET start_col_cnt = 0
 SET max_width = 0
 SET pos_left = 0
 SET b_str_len = 0
 RECORD captions(
   1 correction_type = vc
   1 product_number = vc
   1 product_type = vc
   1 dispensed = vc
   1 tech_id = vc
   1 reason = vc
   1 comments = vc
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
   1 not_on_file = vc
   1 product_order = vc
   1 ordering_physician = vc
   1 accession_number = vc
   1 current = vc
   1 previous = vc
   1 serial_number = vc
 )
 SET captions->correction_type = uar_i18ngetmessage(i18nhandle,"correction_type","Correction Type: ")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->dispensed = uar_i18ngetmessage(i18nhandle,"dispensed","Dispensed")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"reason","Correction Reason")
 SET captions->comments = uar_i18ngetmessage(i18nhandle,"comments","Comments")
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
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->product_order = uar_i18ngetmessage(i18nhandle,"product_order","Product Order")
 SET captions->ordering_physician = uar_i18ngetmessage(i18nhandle,"ordering_physician",
  "Ordering Physician")
 SET captions->accession_number = uar_i18ngetmessage(i18nhandle,"accession_number","Accession Number"
  )
 SET captions->current = uar_i18ngetmessage(i18nhandle,"corrected_info","Corrected: ")
 SET captions->previous = uar_i18ngetmessage(i18nhandle,"original_info","Original: ")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
 SET line = fillstring(125,"-")
 SET page_break = "Y"
 EXECUTE cpm_create_file_name_logical "bbt_rpt_disprodord_cor", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  pr.product_id, product_disp = uar_get_code_display(pr.product_cd), cp.product_id,
  cp.correction_id, cp.correction_type_cd, cp_reason_disp = uar_get_code_display(cp
   .correction_reason_cd),
  per.name_full_formatted, prev_order_menmonic = decode(o_prev.seq,o_prev.order_mnemonic,captions->
   not_on_file)"##############################", prev_formatted_acc = decode(acc_prev.seq,cnvtacc(
    acc_prev.accession),captions->not_on_file)"########################",
  prev_name_full_formatted = decode(ph_prev.seq,ph_prev.name_full_formatted,captions->not_on_file)
  "##############################", corr_order_menmonic = decode(o_corr.seq,o_corr.order_mnemonic,
   captions->not_on_file)"##############################", corr_formatted_acc = decode(acc_corr.seq,
   cnvtacc(acc_corr.accession),captions->not_on_file)"########################",
  corr_name_full_formatted = decode(ph_corr.seq,ph_corr.name_full_formatted,captions->not_on_file)
  "##############################"
  FROM (dummyt d1  WITH seq = 1),
   corrected_product cp,
   prsnl prs,
   product pr,
   (dummyt d_bp  WITH seq = 1),
   (dummyt d_ph  WITH seq = 1),
   (dummyt d_po  WITH seq = 1),
   blood_product bp,
   patient_dispense pd,
   orders o_corr,
   accession_order_r acc_corr,
   prsnl ph_corr,
   prsnl ph_prev,
   accession_order_r acc_prev,
   orders o_prev
  PLAN (d1)
   JOIN (cp
   WHERE cp.correction_type_cd=disprodordcd
    AND cp.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm))
   JOIN (prs
   WHERE prs.person_id=cp.updt_id)
   JOIN (pr
   WHERE pr.product_id=cp.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (pd
   WHERE cp.product_event_id > 0.0
    AND pd.product_event_id=cp.product_event_id)
   JOIN (o_corr
   WHERE cp.corr_disp_prod_order_id > 0
    AND cp.corr_disp_prod_order_id=o_corr.order_id)
   JOIN (ph_corr
   WHERE ph_corr.person_id=o_corr.last_update_provider_id)
   JOIN (acc_corr
   WHERE acc_corr.order_id=o_corr.order_id
    AND acc_corr.primary_flag=0)
   JOIN (d_ph
   WHERE d_ph.seq=1)
   JOIN (ph_prev
   WHERE cp.orig_disp_prov_id > 0
    AND cp.orig_disp_prov_id=ph_prev.person_id)
   JOIN (d_bp
   WHERE d_bp.seq=1)
   JOIN (bp
   WHERE bp.product_id=cp.product_id)
   JOIN (d_po
   WHERE d_po.seq=1)
   JOIN (o_prev
   WHERE cp.orig_disp_prod_order_id > 0
    AND cp.orig_disp_prod_order_id=o_prev.order_id)
   JOIN (acc_prev
   WHERE acc_prev.order_id=o_prev.order_id
    AND acc_prev.primary_flag=0)
  ORDER BY cp.correction_id DESC
  HEAD PAGE
   disprodord_disp = uar_get_code_display(disprodordcd), row 0,
   CALL center(captions->inc_title,1,125),
   col 107, captions->inc_time, col 121,
   curtime"@TIMENOSECONDS;;m", row + 1, col 107,
   captions->inc_as_of_date, col 119, curdate"@DATECONDENSED;;d",
   inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
   disprodord_disp, row + 2, col 1,
   captions->product_number, row + 1, col 1,
   captions->serial_number,
   CALL center(captions->product_type,27,58),
   CALL center(captions->dispensed,60,72),
   CALL center(captions->tech_id,74,80),
   CALL center(captions->reason,82,98),
   CALL center(captions->comments,100,125),
   row + 1, col 1, "-------------------------",
   col 27, "-------------------------------", col 60,
   "-------------", col 74, "-------",
   col 82, "-----------------", col 100,
   "--------------------------", row + 1, page_break = "Y"
  HEAD cp.correction_id
   IF (page_break="N")
    col 1, "*", row + 1
   ENDIF
   page_break = "N", current_supplier_prefix = fillstring(5," ")
  DETAIL
   IF (cp.correction_id > 0.0)
    datafoundflag = true, current_supplier_prefix = fillstring(5," "), current_supplier_prefix = bp
    .supplier_prefix,
    prod_nbr_display = fillstring(30," "), prod_nbr_display = concat(trim(current_supplier_prefix),
     trim(pr.product_nbr)," ",trim(pr.product_sub_nbr))
    IF (row > 54)
     BREAK
    ENDIF
    col 1, prod_nbr_display, col 27,
    product_disp, col 60, cp.updt_dt_tm"@DATECONDENSED;;d",
    col 68, cp.updt_dt_tm"@TIMENOSECONDS;;M", col 74,
    prs.username"#######", col 82, cp_reason_disp,
    b_cnt = 1, col_cnt = 100, start_col_cnt = 100,
    max_width = 25, pos_left = 25, b_strg = cp.correction_note,
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
    IF (pr.serial_number_txt != null)
     row + 1, col 1, pr.serial_number_txt
    ENDIF
    row + 1
    IF (row > 53)
     BREAK
    ENDIF
    CALL center(captions->product_order,35,65),
    CALL center(captions->accession_number,67,91),
    CALL center(captions->ordering_physician,93,123),
    row + 1, col 35, "------------------------------",
    col 67, "------------------------", col 93,
    "------------------------------", row + 1
    IF (row > 54)
     BREAK
    ENDIF
    col 21, captions->current, col 35,
    corr_order_menmonic, col 67, corr_formatted_acc,
    col 93, corr_name_full_formatted, row + 1,
    col 22, captions->previous, col 35,
    prev_order_menmonic, col 67, prev_formatted_acc,
    col 93, prev_name_full_formatted, row + 2
    IF (row > 56)
     BREAK
    ENDIF
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
   row 60, col 51, captions->end_of_report
  WITH nocounter, maxrow = 61, outerjoin(d1),
   outerjoin(d_po), dontcare(ph_prev), dontcare(bp),
   compress, nolandscape, nullreport
 ;end select
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
#exit_script
END GO
