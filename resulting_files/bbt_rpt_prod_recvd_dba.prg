CREATE PROGRAM bbt_rpt_prod_recvd:dba
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
 RECORD captions(
   1 products_received = vc
   1 time = vc
   1 sorted_by = vc
   1 aborh = vc
   1 product_number = vc
   1 product_type = vc
   1 supplier = vc
   1 as_of_date = vc
   1 prod_no = vc
   1 prod_type = vc
   1 expires = vc
   1 quantity = vc
   1 space_supplier = vc
   1 received = vc
   1 no_supplier = vc
   1 total = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 serial_number = vc
 )
 SET captions->products_received = uar_i18ngetmessage(i18nhandle,"products_received",
  "P R O D U C T S   R E C E I V E D   R E P O R T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->sorted_by = uar_i18ngetmessage(i18nhandle,"sorted_by","Sorted by: ")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->supplier = uar_i18ngetmessage(i18nhandle,"supplier","Supplier")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->prod_no = uar_i18ngetmessage(i18nhandle,"prod_no","   Product Number/   ")
 SET captions->prod_type = uar_i18ngetmessage(i18nhandle,"prod_type","      Product Type       ")
 SET captions->expires = uar_i18ngetmessage(i18nhandle,"expires","Expires")
 SET captions->quantity = uar_i18ngetmessage(i18nhandle,"quantity","Quantity")
 SET captions->space_supplier = uar_i18ngetmessage(i18nhandle,"space_supplier",
  "         Supplier        ")
 SET captions->received = uar_i18ngetmessage(i18nhandle,"received","Received")
 SET captions->no_supplier = uar_i18ngetmessage(i18nhandle,"no_supplier","Supplier not on File")
 SET captions->total = uar_i18ngetmessage(i18nhandle,"total","Total")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_PROD_RECVD")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","   Serial Number")
 DECLARE m_aborh = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"ABO/Rh","ABO/Rh"))
 DECLARE m_prodnum = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"Product Number",
   "Product Number"))
 DECLARE m_prodtype = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"Product Type",
   "Product Type"))
 DECLARE m_supplier = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"Supplier","Supplier"))
 RECORD product_rec(
   1 products[*]
     2 product_id = f8
     2 cur_abo_disp = c10
     2 cur_rh_disp = c10
 )
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
 SET nbr_prod_id = size(request->prr_product_id,5)
 RECORD prod_tbl(
   1 prod_list[*]
     2 prod_display = c25
     2 prod_cnt = f8
 )
 SET stat = alterlist(prod_tbl->prod_list,10)
 SET stat = alterlist(product_rec->products,nbr_prod_id)
 SELECT INTO "nl:"
  bp_ind = decode(bp.seq,"bp","xx"), cur_abo_disp = decode(bp.cur_abo_cd,uar_get_code_display(bp
    .cur_abo_cd)," "), cur_rh_disp = decode(bp.cur_rh_cd,uar_get_code_display(bp.cur_rh_cd)," ")
  FROM (dummyt d1  WITH seq = value(nbr_prod_id)),
   blood_product bp
  PLAN (d1)
   JOIN (bp
   WHERE (bp.product_id=request->prr_product_id[d1.seq].prod_id))
  DETAIL
   product_rec->products[d1.seq].product_id = request->prr_product_id[d1.seq].prod_id
   IF (bp_ind="bp")
    product_rec->products[d1.seq].cur_abo_disp = cur_abo_disp, product_rec->products[d1.seq].
    cur_rh_disp = cur_rh_disp
   ELSE
    product_rec->products[d1.seq].cur_abo_disp = " ", product_rec->products[d1.seq].cur_rh_disp = " "
   ENDIF
  WITH nocounter, outerjoin(d1)
 ;end select
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_prod_recvd", "txt", "x"
 SELECT
  IF ((request->sort_ascdes1=0)
   AND (request->sort_ascdes2=0)
   AND (request->sort_ascdes3=0))
   ORDER BY sort1 DESC, sort2 DESC, sort3 DESC,
    pr.product_cd
  ELSEIF ((request->sort_ascdes1=0)
   AND (request->sort_ascdes2=0)
   AND (request->sort_ascdes3=- (1)))
   ORDER BY sort1 DESC, sort2 DESC, sort3,
    pr.product_cd
  ELSEIF ((request->sort_ascdes1=0)
   AND (request->sort_ascdes2=- (1))
   AND (request->sort_ascdes3=0))
   ORDER BY sort1 DESC, sort2, sort3 DESC,
    pr.product_cd
  ELSEIF ((request->sort_ascdes1=0)
   AND (request->sort_ascdes2=- (1))
   AND (request->sort_ascdes3=- (1)))
   ORDER BY sort1 DESC, sort2, sort3,
    pr.product_cd
  ELSEIF ((request->sort_ascdes1=- (1))
   AND (request->sort_ascdes2=0)
   AND (request->sort_ascdes3=0))
   ORDER BY sort1, sort2 DESC, sort3 DESC,
    pr.product_cd
  ELSEIF ((request->sort_ascdes1=- (1))
   AND (request->sort_ascdes2=0)
   AND (request->sort_ascdes3=- (1)))
   ORDER BY sort1, sort2 DESC, sort3,
    pr.product_cd
  ELSEIF ((request->sort_ascdes1=- (1))
   AND (request->sort_ascdes2=- (1))
   AND (request->sort_ascdes3=0))
   ORDER BY sort1, sort2, sort3 DESC,
    pr.product_cd
  ELSE
   ORDER BY sort1, sort2, sort3,
    pr.product_cd
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  bp_seq = bp.seq, de_seq = de.seq, d_flg = decode(bp.seq,"BP",de.seq,"DE","XX"),
  og.org_name, org_name = substring(1,25,og.org_name), og.organization_id,
  pr.product_nbr, pr.product_sub_nbr, pr.product_id,
  product_type = substring(1,25,uar_get_code_display(pr.product_cd)), pr.cur_supplier_id, bp
  .cur_abo_cd,
  bp.cur_rh_cd, pr.recv_dt_tm, pr.cur_expire_dt_tm,
  pe.event_dt_tm, abo_rh = concat(trim(substring(1,10,uar_get_code_display(bp.cur_abo_cd)))," ",trim(
    substring(1,10,uar_get_code_display(bp.cur_rh_cd)))), sort1 =
  IF (trim(request->sort_key1)=m_aborh) concat(product_rec->products[d1.seq].cur_abo_disp,product_rec
    ->products[d1.seq].cur_rh_disp)
  ELSEIF (trim(request->sort_key1)=m_prodnum) substring(1,25,pr.product_nbr)
  ELSEIF (trim(request->sort_key1)=m_prodtype) substring(1,25,uar_get_code_display(pr.product_cd))
  ELSEIF (trim(request->sort_key1)=m_supplier) concat(substring(1,25,og.org_name),cnvtstring(og
     .organization_id,32,2))
  ENDIF
  ,
  sort2 =
  IF ((request->sort_key2=m_aborh)) concat(product_rec->products[d1.seq].cur_abo_disp,product_rec->
    products[d1.seq].cur_rh_disp)
  ELSEIF ((request->sort_key2=m_prodnum)) substring(1,25,pr.product_nbr)
  ELSEIF ((request->sort_key2=m_prodtype)) substring(1,25,uar_get_code_display(pr.product_cd))
  ELSEIF ((request->sort_key2=m_supplier)) concat(substring(1,25,og.org_name),cnvtstring(og
     .organization_id,32,2))
  ELSE ""
  ENDIF
  , sort3 =
  IF ((request->sort_key3=m_aborh)) concat(product_rec->products[d1.seq].cur_abo_disp,product_rec->
    products[d1.seq].cur_rh_disp)
  ELSEIF ((request->sort_key3=m_prodnum)) substring(1,25,pr.product_nbr)
  ELSEIF ((request->sort_key3=m_prodtype)) substring(1,25,uar_get_code_display(pr.product_cd))
  ELSEIF ((request->sort_key3=m_supplier)) concat(substring(1,25,og.org_name),cnvtstring(og
     .organization_id,32,2))
  ELSE ""
  ENDIF
  FROM (dummyt d1  WITH seq = value(nbr_prod_id)),
   product pr,
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   blood_product bp,
   (dummyt d2  WITH seq = 1),
   organization og,
   derivative de,
   receipt r,
   product_event pe
  PLAN (d1)
   JOIN (pr
   WHERE pr.active_ind=1
    AND (pr.product_id=request->prr_product_id[d1.seq].prod_id)
    AND pr.product_id > 0)
   JOIN (r
   WHERE r.product_id=pr.product_id
    AND (r.updt_applctx=reqinfo->updt_applctx))
   JOIN (pe
   WHERE pe.product_event_id=r.product_event_id)
   JOIN (og
   WHERE pr.cur_supplier_id=og.organization_id)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (((d4
   WHERE d4.seq=1)
   JOIN (bp
   WHERE pr.product_id=bp.product_id)
   ) ORJOIN ((d2
   WHERE d2.seq=1)
   JOIN (de
   WHERE pr.product_id=de.product_id)
   ))
  HEAD REPORT
   idx = 0, prod_cnt = 0, line = fillstring(125,"_"),
   first_time = "Y", detail_summary_flg = "D", print_page_head_ind = "Y",
   select_ok_ind = 0
  HEAD PAGE
   IF (print_page_head_ind="Y")
    IF (detail_summary_flg="D")
     CALL center(captions->products_received,1,125), col 104, captions->time,
     col 118, curtime"@TIMENOSECONDS;;M", inc_i18nhandle = 0,
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
     save_row = row, row 1, col 45,
     captions->sorted_by
     IF ((request->sort_key1=m_aborh))
      col 57, captions->aborh
     ELSEIF ((request->sort_key1=m_prodnum))
      col 57, captions->product_number
     ELSEIF ((request->sort_key1=m_prodtype))
      col 57, captions->product_type
     ELSEIF ((request->sort_key1=m_supplier))
      col 57, captions->supplier
     ENDIF
     col 104, captions->as_of_date, col 118,
     curdate"@DATECONDENSED;;d", row + 1
     IF ((request->sort_key2=m_aborh))
      col 57, captions->aborh
     ELSEIF ((request->sort_key2=m_prodnum))
      col 57, captions->product_number
     ELSEIF ((request->sort_key2=m_prodtype))
      col 57, captions->product_type
     ELSEIF ((request->sort_key2=m_supplier))
      col 57, captions->supplier
     ENDIF
     row + 1
     IF ((request->sort_key3=m_aborh))
      col 57, captions->aborh
     ELSEIF ((request->sort_key3=m_prodnum))
      col 57, captions->product_number
     ELSEIF ((request->sort_key3=m_prodtype))
      col 57, captions->product_type
     ELSEIF ((request->sort_key3=m_supplier))
      col 57, captions->supplier
     ENDIF
     IF (save_row >= row)
      row save_row, row + 1
     ELSE
      row + 1
     ENDIF
     IF ((request->sort_key1=m_aborh))
      col 3, captions->aborh, ":"
      IF (d_flg="BP")
       col 11, abo_rh, finish_flag = "Y"
      ELSE
       col 11, "      "
      ENDIF
      row + 3, col 5, captions->prod_no,
      col 32, captions->prod_type, col 59,
      captions->expires, col 74, captions->quantity,
      col 83, captions->space_supplier, col 110,
      captions->received, row + 1, col 5,
      captions->serial_number, row + 1, col 5,
      "---------------------", col 32, "-------------------------",
      col 59, "-------------", col 74,
      "--------", col 83, "-------------------------",
      col 110, "-------------", row + 1
     ELSEIF ((request->sort_key1=m_prodnum))
      row + 2, col 0, captions->prod_no,
      col 23, captions->prod_type, col 44,
      captions->aborh, col 65, captions->expires,
      col 79, captions->quantity, col 88,
      captions->space_supplier, col 114, captions->received,
      row + 1, col 0, captions->serial_number,
      row + 1, col 0, "---------------------",
      col 23, "--------------------", col 44,
      "-------------------", col 65, "-------------",
      col 79, "--------", col 88,
      "-------------------------", col 114, "-------------",
      row + 1
     ELSEIF ((request->sort_key1=m_prodtype))
      col 3, captions->product_type, ":",
      col 17, product_type, row + 3,
      col 4, captions->prod_no, col 31,
      captions->aborh, col 53, captions->expires,
      col 68, captions->quantity, col 81,
      captions->space_supplier, col 113, captions->received,
      row + 1, col 4, captions->serial_number,
      row + 1, col 4, "-------------------------",
      col 31, "--------------------", col 53,
      "-------------", col 68, "--------",
      col 81, "-------------------------", col 113,
      "-------------", row + 1
     ELSEIF ((request->sort_key1=m_supplier))
      col 3, captions->supplier, ":"
      IF (og.org_name > " ")
       col 13, og.org_name
      ELSE
       col 13, captions->no_supplier
      ENDIF
      row + 3, col 3, captions->prod_no,
      col 28, captions->prod_type, col 59,
      captions->aborh, col 81, captions->expires,
      col 97, captions->quantity, col 114,
      captions->received, row + 1, col 3,
      captions->serial_number, row + 1, col 3,
      "------------------------", col 28, "-------------------------",
      col 59, "------------------", col 81,
      "------------", col 97, "--------",
      col 114, "-------------", row + 1
     ENDIF
    ENDIF
   ENDIF
  HEAD sort1
   IF ((request->sort_key1=m_aborh))
    idx = 0, stat = alterlist(prod_tbl->prod_list,10)
    IF (first_time="Y")
     first_time = "N"
    ELSE
     BREAK
    ENDIF
   ELSEIF ((request->sort_key1=m_prodnum))
    idx = 0, stat = alterlist(prod_tbl->prod_list,10)
   ELSEIF ((request->sort_key1=m_prodtype))
    idx = 0, stat = alterlist(prod_tbl->prod_list,10)
    IF (first_time="Y")
     first_time = "N"
    ELSE
     BREAK
    ENDIF
   ELSEIF ((request->sort_key1=m_supplier))
    idx = 0, stat = alterlist(prod_tbl->prod_list,10)
    IF (first_time="Y")
     first_time = "N"
    ELSE
     BREAK
    ENDIF
   ENDIF
  HEAD pr.product_cd
   IF ((request->sort_key2=m_prodtype))
    idx += 1
    IF (mod(idx,10)=1
     AND idx != 1)
     stat = alterlist(prod_tbl->prod_list,(idx+ 9))
    ENDIF
   ENDIF
  DETAIL
   recv_dt_tm = cnvtdatetime(pe.event_dt_tm), expire_dt_tm = cnvtdatetime(pr.cur_expire_dt_tm),
   supplier = substring(1,25,og.org_name),
   product_nbr_formatted = concat(trim(bp.supplier_prefix),trim(pr.product_nbr)," ",trim(pr
     .product_sub_nbr))
   IF ((request->sort_key1=m_aborh))
    IF (row >= 55)
     BREAK
    ENDIF
    col 5, product_nbr_formatted, col 32,
    product_type, col 59, expire_dt_tm"@DATETIMECONDENSED;;d"
    IF (d_flg="DE")
     col 79, r.orig_rcvd_qty"####;p "
    ELSE
     col 74, "    "
    ENDIF
    col 83, org_name, col 110,
    recv_dt_tm"@DATETIMECONDENSED;;d"
    IF (pr.serial_number_txt != null)
     row + 1, col 5, pr.serial_number_txt
    ENDIF
    row + 2
    IF (d_flg="BP")
     prod_cnt += 1
    ELSEIF (d_flg="DE")
     prod_cnt += r.orig_rcvd_qty
    ENDIF
   ELSEIF ((request->sort_key1=m_prodnum))
    IF (row >= 55)
     BREAK
    ENDIF
    col 0, product_nbr_formatted, col 23,
    product_type
    IF (d_flg="BP")
     col 44, abo_rh, finish_flag = "Y"
    ELSE
     col 44, "                "
    ENDIF
    col 65, expire_dt_tm"@DATETIMECONDENSED;;d"
    IF (d_flg="DE")
     col 79, r.orig_rcvd_qty"####;p "
    ELSE
     col 79, "    "
    ENDIF
    col 88, org_name, col 113,
    recv_dt_tm"@DATETIMECONDENSED;;d"
    IF (pr.serial_number_txt != null)
     row + 1, col 0, pr.serial_number_txt
    ENDIF
    row + 2
    IF (d_flg="BP")
     prod_cnt += 1
    ELSEIF (d_flg="DE")
     prod_cnt += r.orig_rcvd_qty
    ENDIF
    detail_summary_flg = "D"
    IF (row > 56)
     BREAK
    ENDIF
   ELSEIF ((request->sort_key1=m_prodtype))
    IF (row >= 55)
     BREAK
    ENDIF
    col 4, product_nbr_formatted
    IF (d_flg="BP")
     col 31, abo_rh, finish_flag = "Y"
    ELSE
     col 31, "               "
    ENDIF
    col 53, expire_dt_tm"@DATETIMECONDENSED;;d"
    IF (d_flg="DE")
     col 68, r.orig_rcvd_qty"####;p "
    ELSE
     col 68, "    "
    ENDIF
    col 81, org_name, col 113,
    recv_dt_tm"@DATETIMECONDENSED;;d"
    IF (pr.serial_number_txt != null)
     row + 1, col 4, pr.serial_number_txt
    ENDIF
    row + 2
    IF (d_flg="BP")
     prod_cnt += 1
    ELSEIF (d_flg="DE")
     prod_cnt += r.orig_rcvd_qty
    ENDIF
    detail_summary_flg = "D"
    IF (row > 56)
     BREAK
    ENDIF
   ELSEIF ((request->sort_key1=m_supplier))
    IF (row >= 55)
     BREAK
    ENDIF
    col 3, product_nbr_formatted, col 28,
    product_type
    IF (d_flg="BP")
     col 59, abo_rh, finish_flag = "Y"
    ELSE
     col 59, "      "
    ENDIF
    col 81, expire_dt_tm"@DATETIMECONDENSED;;d", col 114,
    recv_dt_tm"@DATETIMECONDENSED;;d"
    IF (d_flg="DE")
     col 97, r.orig_rcvd_qty"####;p "
    ELSE
     col 97, "    "
    ENDIF
    IF (pr.serial_number_txt != null)
     row + 1, col 3, pr.serial_number_txt
    ENDIF
    row + 2
    IF (d_flg="BP")
     prod_cnt += 1
    ELSEIF (d_flg="DE")
     prod_cnt += r.orig_rcvd_qty
    ENDIF
    detail_summary_flg = "D"
    IF (row > 56)
     BREAK
    ENDIF
   ENDIF
  FOOT  pr.product_cd
   IF ((request->sort_key2=m_prodtype))
    prod_tbl->prod_list[idx].prod_display = product_type, prod_tbl->prod_list[idx].prod_cnt =
    prod_cnt, prod_cnt = 0
   ENDIF
  FOOT  sort1
   IF ((request->sort_key1=m_supplier)
    AND (request->sort_key2=m_prodtype))
    detail_summary_flg = "S", BREAK,
    CALL center(captions->products_received,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,
     curprog,"",curcclrev),
    row 0
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
    save_row = row, row 1, col 45,
    captions->sorted_by
    IF ((request->sort_key1=m_aborh))
     col 57, captions->aborh
    ELSEIF ((request->sort_key1=m_prodnum))
     col 57, captions->product_number
    ELSEIF ((request->sort_key1=m_prodtype))
     col 57, captions->product_type
    ELSEIF ((request->sort_key1=m_supplier))
     col 57, captions->supplier
    ENDIF
    col 104, captions->as_of_date, col 118,
    curdate"@DATECONDENSED;;d", row + 1
    IF ((request->sort_key2=m_aborh))
     col 57, captions->aborh
    ELSEIF ((request->sort_key2=m_prodnum))
     col 57, captions->product_number
    ELSEIF ((request->sort_key2=m_prodtype))
     col 57, captions->product_type
    ELSEIF ((request->sort_key2=m_supplier))
     col 57, captions->supplier
    ENDIF
    row + 1
    IF ((request->sort_key3=m_aborh))
     col 57, captions->aborh
    ELSEIF ((request->sort_key3=m_prodnum))
     col 57, captions->product_number
    ELSEIF ((request->sort_key3=m_prodtype))
     col 57, captions->product_type
    ELSEIF ((request->sort_key3=m_supplier))
     col 57, captions->supplier
    ENDIF
    IF (save_row >= row)
     row save_row, row + 1
    ELSE
     row + 1
    ENDIF
    col 3, captions->supplier, ":"
    IF (og.org_name > " ")
     col 13, og.org_name
    ELSE
     col 13, captions->no_supplier
    ENDIF
    row + 3, col 9, captions->product_type,
    col 33, captions->total, row + 1,
    col 3, "-------------------------", col 33,
    "-----", row + 1, idx1 = 1,
    stat = alterlist(prod_tbl->prod_list,idx)
    WHILE (idx1 <= idx)
      col 3, prod_tbl->prod_list[idx1].prod_display, col 33,
      prod_tbl->prod_list[idx1].prod_cnt"#####;p ", row + 2
      IF (row > 56)
       BREAK,
       CALL center(captions->products_received,1,125), col 104,
       captions->time, col 118, curtime"@TIMENOSECONDS;;M",
       inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row
        0
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
       save_row = row, row 1, col 45,
       captions->sorted_by
       IF ((request->sort_key1=m_aborh))
        col 57, captions->aborh
       ELSEIF ((request->sort_key1=m_prodnum))
        col 57, captions->product_number
       ELSEIF ((request->sort_key1=m_prodtype))
        col 57, captions->product_type
       ELSEIF ((request->sort_key1=m_supplier))
        col 57, captions->supplier
       ENDIF
       col 104, captions->as_of_date, col 118,
       curdate"@DATECONDENSED;;d", row + 1
       IF ((request->sort_key2=m_aborh))
        col 57, captions->aborh
       ELSEIF ((request->sort_key2=m_prodnum))
        col 57, captions->product_number
       ELSEIF ((request->sort_key2=m_prodtype))
        col 57, captions->product_type
       ELSEIF ((request->sort_key2=m_supplier))
        col 57, captions->supplier
       ENDIF
       row + 1
       IF ((request->sort_key3=m_aborh))
        col 57, captions->aborh
       ELSEIF ((request->sort_key3=m_prodnum))
        col 57, captions->product_number
       ELSEIF ((request->sort_key3=m_prodtype))
        col 57, captions->product_type
       ELSEIF ((request->sort_key3=m_supplier))
        col 57, captions->supplier
       ENDIF
       IF (save_row >= row)
        row save_row, row + 1
       ELSE
        row + 1
       ENDIF
       col 3, captions->supplier, ":"
       IF (og.org_name > " ")
        col 13, og.org_name
       ELSE
        col 13, captions->no_supplier
       ENDIF
       row + 3, col 9, captions->product_type,
       col 33, captions->total, row + 1,
       col 3, "-------------------------", col 33,
       "-----", row + 1
      ENDIF
      idx1 += 1
    ENDWHILE
    detail_summary_flg = "D"
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 60, col 51, captions->end_of_report,
   print_page_head_ind = "N", BREAK, select_ok_ind = 1
  WITH nullreport, maxrow = 61, nocounter,
   compress, nolandscape
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
