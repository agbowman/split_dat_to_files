CREATE PROGRAM bbt_rpt_erdis_cor:dba
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
 RECORD captions(
   1 correction_type = vc
   1 product_number = vc
   1 product_type = vc
   1 aborh = vc
   1 corrected = vc
   1 tech_id = vc
   1 reason = vc
   1 comments = vc
   1 unknown_pat_txt = vc
   1 update_pat_name = vc
   1 mrn = vc
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
   1 serial_number = vc
 )
 SET captions->correction_type = uar_i18ngetmessage(i18nhandle,"correction_type","Correction Type: ")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->corrected = uar_i18ngetmessage(i18nhandle,"corrected","Corrected")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"reason","Reason")
 SET captions->comments = uar_i18ngetmessage(i18nhandle,"comments","Comments")
 SET captions->unknown_pat_txt = uar_i18ngetmessage(i18nhandle,"unknown_pat_txt",
  "Unknown Patient Text  :")
 SET captions->update_pat_name = uar_i18ngetmessage(i18nhandle,"update_pat_name",
  "Update to Patient Name:")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN:")
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
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 SET line = fillstring(125,"-")
 SET page_break = "Y"
 SELECT INTO cpm_cfn_info->file_name_logical
  pr.product_id, product_disp = uar_get_code_display(pr.product_cd), cp.product_id,
  cp.correction_id, cp.correction_type_cd, cp_reason_disp = uar_get_code_display(cp
   .correction_reason_cd),
  bp_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_rh_disp = uar_get_code_display(bp.cur_rh_cd),
  per.name_full_formatted,
  alias_exists = decode(pd_ea.alias,"Y","N")
  FROM (dummyt d1  WITH seq = 1),
   corrected_product cp,
   prsnl prs,
   product pr,
   (dummyt d_bp  WITH seq = 1),
   blood_product bp,
   patient_dispense pd,
   person per,
   (dummyt d_ea  WITH seq = 1),
   product_event pe,
   encntr_alias pd_ea
  PLAN (d1)
   JOIN (cp
   WHERE cp.correction_type_cd=erdis_cd
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
   WHERE pd.product_event_id=cp.product_event_id)
   JOIN (per
   WHERE per.person_id=pd.person_id
    AND pd.person_id != null
    AND pd.person_id > 0)
   JOIN (pe
   WHERE pe.product_event_id=pd.product_event_id)
   JOIN (d_ea
   WHERE d_ea.seq=1)
   JOIN (pd_ea
   WHERE pd_ea.encntr_id=pe.encntr_id
    AND pd_ea.encntr_id != null
    AND pd_ea.encntr_id > 0
    AND pd_ea.active_ind=1
    AND pd_ea.encntr_alias_type_cd=mrn_encntr_alias_type_cd)
   JOIN (d_bp
   WHERE d_bp.seq=1)
   JOIN (bp
   WHERE bp.product_id=pr.product_id)
  ORDER BY cp.correction_id DESC
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
   erdis_disp, row + 2, col 1,
   captions->product_number, row + 1, col 1,
   captions->serial_number,
   CALL center(captions->product_type,27,45),
   CALL center(captions->aborh,46,58),
   CALL center(captions->corrected,60,72),
   CALL center(captions->tech_id,74,80),
   CALL center(captions->reason,82,98),
   CALL center(captions->comments,100,125), row + 1, col 1,
   "-------------------------", col 27, "------------------",
   col 46, "-------------", col 60,
   "-------------", col 74, "-------",
   col 82, "-----------------", col 100,
   "--------------------------", row + 1, page_break = "Y"
  HEAD cp.correction_id
   IF (page_break="N")
    col 1, "*", row + 1
   ENDIF
   page_break = "N", current_supplier_prefix = fillstring(5," "), current_aborh_disp = fillstring(15,
    " "),
   encntr_alias = fillstring(20," ")
  DETAIL
   IF (cp.correction_id > 0.0)
    datafoundflag = true, current_supplier_prefix = fillstring(5," "), current_aborh_disp =
    fillstring(13," "),
    current_aborh_disp = concat(trim(bp_abo_disp)," ",trim(bp_rh_disp)), current_supplier_prefix = bp
    .supplier_prefix, prod_nbr_display = fillstring(30," "),
    prod_nbr_display = concat(trim(current_supplier_prefix),trim(pr.product_nbr)," ",trim(pr
      .product_sub_nbr)), col 1, prod_nbr_display,
    col 27, product_disp, col 46,
    current_aborh_disp"#############", col 60, cp.updt_dt_tm"@DATECONDENSED;;d",
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
    IF (row > 56)
     BREAK
    ENDIF
    IF (pr.serial_number_txt != null)
     row + 1, col 1, pr.serial_number_txt
    ENDIF
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->unknown_pat_txt, col 25,
    cp.unknown_patient_text, row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->update_pat_name, col 25,
    per.name_full_formatted"####################", row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 20, captions->mrn
    IF (alias_exists="Y")
     encntr_alias = cnvtalias(pd_ea.alias,pd_ea.alias_pool_cd)
    ELSE
     encntr_alias = captions->not_on_file
    ENDIF
    col 25, encntr_alias"####################", row + 1
    IF (row > 54)
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
   outerjoin(d_ea), dontcare(pd_ea), outerjoin(d_bp),
   compress, nolandscape, nullreport
 ;end select
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
END GO
