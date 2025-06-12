CREATE PROGRAM bbt_rpt_fin_dis_ent:dba
 SET nbr_prod_id = size(request->dis_product,5)
 SET line = fillstring(175,"_")
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
 RECORD aborh(
   1 aborh_list[*]
     2 aborh_display = c6
     2 abo_code = f8
     2 rh_code = f8
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
   1 disposed_units_rpt = vc
   1 time = vc
   1 as_of_date = vc
   1 packing_list = vc
   1 expire = vc
   1 product_number = vc
   1 product_type = vc
   1 aborh = vc
   1 qty = vc
   1 dt_tm = vc
   1 tech = vc
   1 alternate_unit = vc
   1 supplier = vc
   1 reason = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 i_certify = vc
   1 continuously_at = vc
   1 fda_aabb = vc
   1 sign_dt_tm = vc
   1 signature = vc
   1 end_of_report = vc
   1 serial_number = vc
 )
 SET captions->disposed_units_rpt = uar_i18ngetmessage(i18nhandle,"disposed_units_rpt",
  "D I S P O S E D   U N I T S")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->packing_list = uar_i18ngetmessage(i18nhandle,"packing_list","P A C K I N G   L I S T")
 SET captions->expire = uar_i18ngetmessage(i18nhandle,"expire","   Expire    ")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number",
  "   Product Number/    ")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","    Product Type     ")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","  ABO/Rh  ")
 SET captions->qty = uar_i18ngetmessage(i18nhandle,"qty"," Qty ")
 SET captions->dt_tm = uar_i18ngetmessage(i18nhandle,"dt_tm","  Date/Time   ")
 SET captions->tech = uar_i18ngetmessage(i18nhandle,"tech","  Tech  ")
 SET captions->alternate_unit = uar_i18ngetmessage(i18nhandle,"alternate_unit",
  "    Alternate Unit   ")
 SET captions->supplier = uar_i18ngetmessage(i18nhandle,"supplier","      Supplier       ")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"reason","        Reason       ")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_FIN_DIS_ENT"
  )
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->i_certify = uar_i18ngetmessage(i18nhandle,"i_certify",
  "I certify that the above listed blood has been stored")
 SET captions->continuously_at = uar_i18ngetmessage(i18nhandle,"continuously_at",
  "continuously at a temperature range in accordance with")
 SET captions->fda_aabb = uar_i18ngetmessage(i18nhandle,"fda_aabb",
  "FDA/AABB regulations and is free from hemolysis.")
 SET captions->sign_dt_tm = uar_i18ngetmessage(i18nhandle,"sign_dt_tm",
  "Date:___________________  Time:___________  ")
 SET captions->signature = uar_i18ngetmessage(i18nhandle,"signature","Signature")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","   Serial Number    ")
 SET stat = alterlist(aborh->aborh_list,10)
 SET aborh_index = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_extension cve1,
   code_value_extension cve2,
   (dummyt d1  WITH seq = 1),
   code_value cv2,
   (dummyt d2  WITH seq = 1),
   code_value cv3
  PLAN (cv1
   WHERE cv1.code_set=1640
    AND cv1.active_ind=1)
   JOIN (cve1
   WHERE cve1.code_set=1640
    AND cv1.code_value=cve1.code_value
    AND cve1.field_name="ABOOnly_cd")
   JOIN (cve2
   WHERE cve2.code_set=1640
    AND cv1.code_value=cve2.code_value
    AND cve2.field_name="RhOnly_cd")
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (cv2
   WHERE cv2.code_set=1641
    AND cnvtint(cve1.field_value)=cv2.code_value)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (cv3
   WHERE cv3.code_set=1642
    AND cnvtint(cve2.field_value)=cv3.code_value)
  ORDER BY cve1.field_value, cve2.field_value
  DETAIL
   aborh_index += 1
   IF (mod(aborh_index,10)=1
    AND aborh_index != 1)
    stat = alterlist(aborh->aborh_list,(aborh_index+ 9))
   ENDIF
   aborh->aborh_list[aborh_index].aborh_display = cv1.display, aborh->aborh_list[aborh_index].
   abo_code = cv2.code_value, aborh->aborh_list[aborh_index].rh_code = cv3.code_value
  WITH outerjoin(d1), outerjoin(d2), check,
   nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(aborh->aborh_list,aborh_index)
 ENDIF
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_fin_dsp_ent", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  d_flg = decode(bp.seq,"BP",de.seq,"DE","XX"), og.org_name"##########################", pe
  .product_event_id,
  pe.product_id, pr.product_nbr, pr.product_sub_nbr,
  pr.alternate_nbr, c1.display"####################", bp.cur_abo_cd,
  bp.cur_rh_cd, di.disposed_qty, pr.cur_expire_dt_tm,
  pe.active_status_prsnl_id, prs.username"########", reason_disp = uar_get_code_display(di.reason_cd)
  FROM (dummyt d1  WITH seq = value(nbr_prod_id)),
   product_event pe,
   product pr,
   code_value c1,
   organization og,
   prsnl prs,
   disposition di,
   (dummyt d2  WITH seq = 1),
   blood_product bp,
   derivative de
  PLAN (d1)
   JOIN (pe
   WHERE (pe.product_event_id=request->dis_product[d1.seq].prod_event_id))
   JOIN (pr
   WHERE pe.product_id=pr.product_id)
   JOIN (c1
   WHERE c1.code_set=1604
    AND pr.product_cd=c1.code_value)
   JOIN (og
   WHERE pr.cur_supplier_id=og.organization_id)
   JOIN (prs
   WHERE pe.active_status_prsnl_id=prs.person_id)
   JOIN (di
   WHERE pe.product_event_id=di.product_event_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (((bp
   WHERE pe.product_id=bp.product_id)
   ) ORJOIN ((de
   WHERE pe.product_id=de.product_id)
   ))
  ORDER BY pr.product_nbr, pr.product_sub_nbr
  HEAD REPORT
   new_report = "Y", select_ok_ind = 0
  HEAD PAGE
   CALL center(captions->disposed_units_rpt,1,160), col 149, captions->time,
   col 160, curtime"@TIMENOSECONDS;;M", row + 1,
   col 149, captions->as_of_date, col 160,
   curdate"@DATECONDENSED;;d", inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,
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
   save_row = row, row 1,
   CALL center(captions->packing_list,1,160),
   row save_row, row + 1, col 70,
   captions->expire, row + 1, col 1,
   captions->product_number, col 27, captions->product_type,
   col 50, captions->aborh, col 62,
   captions->qty, col 70, captions->dt_tm,
   col 90, captions->tech, col 100,
   captions->alternate_unit, col 125, captions->supplier,
   col 150, captions->reason, row + 1,
   col 1, captions->serial_number, row + 1,
   col 1, "-------------------------", col 27,
   "---------------------", col 50, "----------",
   col 62, "-----", col 70,
   "--------------", col 90, "--------",
   col 100, "---------------------", col 125,
   "---------------------", col 150, "---------------------",
   row + 1
  DETAIL
   prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr.product_nbr)," ",trim(pr
     .product_sub_nbr)), col 1, prod_nbr_display,
   col 27, c1.display
   IF (d_flg="BP")
    idx_a = 1, finish_flag = "N"
    WHILE (idx_a <= aborh_index
     AND finish_flag="N")
      IF ((bp.cur_abo_cd=aborh->aborh_list[idx_a].abo_code)
       AND (bp.cur_rh_cd=aborh->aborh_list[idx_a].rh_code))
       col 50, aborh->aborh_list[idx_a].aborh_display"######", finish_flag = "Y"
      ELSE
       idx_a += 1
      ENDIF
    ENDWHILE
   ENDIF
   IF (d_flg="DE")
    qty = trim(cnvtstring(di.disposed_qty,4,0,r)), col 62, qty
   ENDIF
   dt_tm = cnvtdatetime(pr.cur_expire_dt_tm), col 70, dt_tm"@DATETIMECONDENSED;;d",
   col 90, prs.username
   IF (pr.alternate_nbr > " ")
    col 100, pr.alternate_nbr
   ENDIF
   col 125, og.org_name, col 150,
   reason_disp"#########################"
   IF (pr.serial_number_txt != null)
    row + 1, col 1, pr.serial_number_txt
   ENDIF
   row + 2, save_row = row
   IF (row > 44)
    BREAK
   ENDIF
  FOOT PAGE
   row 45, col 1, line,
   row + 1, col 1, captions->report_id,
   col 88, captions->page_no, col 94,
   curpage"###", col 142, captions->printed,
   col 152, curdate"@DATECONDENSED;;d", col 166,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   IF (save_row > 35)
    BREAK, row 45, col 1,
    line, row + 1, col 1,
    captions->report_id, col 88, captions->page_no,
    col 94, curpage"###", col 142,
    captions->printed, col 152, curdate"@DATECONDENSED;;d",
    col 166, curtime"@TIMENOSECONDS;;M"
   ENDIF
   row 38, col 12, captions->i_certify,
   col 66, captions->continuously_at, row + 1,
   col 12, captions->fda_aabb, row + 2,
   col 12, captions->sign_dt_tm, col 56,
   "________________________________________________________________", row + 1, col 81,
   captions->signature, row 48, col 78,
   captions->end_of_report, select_ok_ind = 1
  WITH nocounter, nullreport, maxrow = 49,
   maxcol = 180, compress, landscape
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
