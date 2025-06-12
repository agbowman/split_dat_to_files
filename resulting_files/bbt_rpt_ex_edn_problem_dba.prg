CREATE PROGRAM bbt_rpt_ex_edn_problem:dba
 DECLARE bb_exception_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14072,
   "EDN_PROBLEM"))
 DECLARE line8 = c8 WITH protect, constant(fillstring(8,"-"))
 DECLARE line17 = c17 WITH protect, constant(fillstring(17,"-"))
 DECLARE line22 = c22 WITH protect, constant(fillstring(22,"-"))
 DECLARE line93 = c93 WITH protect, constant(fillstring(93,"-"))
 DECLARE line131 = c131 WITH protect, constant(fillstring(131,"-"))
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE text_result = vc WITH protect, noconstant("")
 DECLARE cur_owner_area_disp = vc WITH protect, noconstant("")
 DECLARE cur_inv_area_disp = vc WITH protect, noconstant("")
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
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 as_of_date = vc
   1 beg_date = vc
   1 end_date = vc
   1 rpt_owner = vc
   1 rpt_all = vc
   1 rpt_inv_area = vc
   1 rpt_recv_date = vc
   1 rpt_prod_nbr = vc
   1 rpt_aborh = vc
   1 rpt_expire = vc
   1 rpt_date_time = vc
   1 rpt_trs_date = vc
   1 rpt_reason = vc
   1 product_comments = vc
   1 rpt_title = vc
   1 rpt_exep_type = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 head_products = vc
   1 rpt_prodcode = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As Of Date:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "B L O O D   B A N K   E X C E P T I O N   R E P O R T")
 SET captions->rpt_exep_type = trim(uar_get_code_description(bb_exception_rpt_cd))
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->rpt_owner = uar_i18ngetmessage(i18nhandle,"rpt_owner","Blood Bank Owner:")
 SET captions->rpt_inv_area = uar_i18ngetmessage(i18nhandle,"rpt_inv_area","Inventory Area:")
 SET captions->rpt_trs_date = uar_i18ngetmessage(i18nhandle,"rpt_recv_date","Transfer Date/Time")
 SET captions->rpt_prod_nbr = uar_i18ngetmessage(i18nhandle,"rpt_prod_nbr","Product Number")
 SET captions->rpt_aborh = uar_i18ngetmessage(i18nhandle,"rpt_aborh","Product ABO/Rh")
 SET captions->rpt_date_time = uar_i18ngetmessage(i18nhandle,"rpt_date_time","Expiration Date/Time")
 SET captions->rpt_all = uar_i18ngetmessage(i18nhandle,"rpt_all","(All)")
 SET captions->rpt_reason = uar_i18ngetmessage(i18nhandle,"rpt_reason","Reason")
 SET captions->product_comments = uar_i18ngetmessage(i18nhandle,"rpt_prod_comments",
  "Product Comments")
 SET captions->head_products = uar_i18ngetmessage(i18nhandle,"head_products","Product Type")
 SET captions->rpt_prodcode = uar_i18ngetmessage(i18nhandle,"head_products","Product Code")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 SET cur_owner_area_disp = fillstring(40," ")
 SET cur_inv_area_disp = fillstring(40," ")
 SET q = 0
 IF ((request->cur_owner_area_cd=0.0))
  SET cur_owner_area_disp = captions->rpt_all
 ELSE
  SET cur_owner_area_disp = uar_get_code_display(request->cur_owner_area_cd)
 ENDIF
 IF ((request->cur_inv_area_cd=0.0))
  SET cur_inv_area_disp = captions->rpt_all
 ELSE
  SET cur_inv_area_disp = uar_get_code_display(request->cur_inv_area_cd)
 ENDIF
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SELECT INTO "nl:"
  bea.*
  FROM bb_edn_admin bea
  WHERE bea.admin_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   AND bea.bb_edn_admin_id > 0
  ORDER BY bea.admin_dt_tm
  WITH nocounter, maxqual(bea,1)
 ;end select
 IF (curqual=0
  AND (request->null_ind=0))
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name_logical "bbt_edn_prob", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  transfer_date = cnvtdatetime(bea.admin_dt_tm), prod_number = substring(1,22,bep
   .edn_product_nbr_ident), p_product_disp = substring(1,22,uar_get_code_display(bep.product_cd)),
  p_product_code = substring(1,17,bep.product_type_txt), aborh = substring(1,22,concat(trim(
     uar_get_code_display(bep.abo_cd))," ",trim(uar_get_code_display(bep.rh_cd)))), expire_dt_tm =
  cnvtdatetime(bep.expiration_dt_tm),
  reason = trim(uar_get_definition(bepb.problem_type_cd)), lt_long_text = trim(substring(1,32000,lt
    .long_text)), p_long_text_id = cnvtint(bep.long_text_id),
  bb_edn_prod_id = bep.bb_edn_product_id
  FROM bb_edn_admin bea,
   bb_edn_product bep,
   long_text lt,
   bb_edn_problem bepb
  PLAN (bea
   WHERE bea.edn_complete_ind=0
    AND bea.admin_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND (((request->cur_inv_area_cd != 0.0)
    AND (bea.destination_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
    AND (((request->cur_owner_area_cd != 0.0)
    AND (bea.destination_loc_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND bea.protocol_nbr=0)
   JOIN (bep
   WHERE bep.bb_edn_admin_id=bea.bb_edn_admin_id
    AND bep.product_complete_ind=0)
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(bep.long_text_id))
    AND (lt.active_ind= Outerjoin(1)) )
   JOIN (bepb
   WHERE bepb.bb_edn_product_id=bep.bb_edn_product_id)
  ORDER BY bea.admin_dt_tm, bep.bb_edn_product_id
  HEAD REPORT
   first_page = "Y"
  HEAD PAGE
   row 0,
   CALL center(captions->rpt_title,0,125), col 110,
   captions->rpt_time, col 122, curtime,
   row + 1, col 110, captions->as_of_date,
   col 122, curdate"@DATECONDENSED;;d", save_row = row,
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
   IF (save_row > row)
    row save_row
   ENDIF
   row + 1, col 30, captions->beg_date,
   col 46, request->beg_dt_tm"@DATETIMECONDENSED;;d", col 72,
   captions->end_date, col 85, request->end_dt_tm"@DATETIMECONDENSED;;d",
   row + 2, col 0, captions->rpt_owner,
   col 18, cur_owner_area_disp, row + 1,
   col 0, captions->rpt_inv_area, col 18,
   cur_inv_area_disp, row + 2, col 0,
   captions->rpt_exep_type, row + 2, col 0,
   captions->rpt_trs_date, row + 1, col 3,
   captions->rpt_prod_nbr, col 25, captions->head_products,
   col 50, captions->rpt_prodcode, col 70,
   captions->rpt_aborh, col 95, captions->rpt_date_time,
   row + 1, col 3, captions->rpt_reason,
   row + 1, col 3, captions->product_comments,
   row + 1, col 0, line22,
   col 25, line22, col 50,
   line17, col 70, line22,
   col 95, line22, row + 1
  HEAD bea.admin_dt_tm
   IF (row > 50)
    BREAK
   ENDIF
   col 0, transfer_date"@SHORTDATETIME;;d", datafoundflag = true,
   row + 1
  HEAD bep.bb_edn_product_id
   IF (row > 51)
    BREAK
   ENDIF
   col 3, prod_number, col 25,
   p_product_disp, col 50, p_product_code,
   col 70, aborh, col 95,
   expire_dt_tm"@SHORTDATETIME;;d", datafoundflag = true, row + 1
  DETAIL
   datafoundflag = true
   IF (row > 52)
    BREAK
   ENDIF
   col 3, reason, row + 1
  FOOT  bep.bb_edn_product_id
   row + 1
   IF (row > 53)
    BREAK
   ENDIF
   CALL rtf_to_text(lt_long_text,1,125)
   FOR (q = 1 TO size(tmptext->qual,5))
     col 3, tmptext->qual[q].text, row + 1
     IF (row > 54)
      BREAK
     ENDIF
   ENDFOR
   row + 1
  FOOT  bea.admin_dt_tm
   row + 1
  FOOT PAGE
   row 57, col 0, line131,
   row + 1, col 0, cpm_cfn_info->file_name,
   col 113, captions->rpt_page, col 120,
   curpage";l", row + 1
  FOOT REPORT
   row 59,
   CALL center(captions->end_of_report,1,125)
  WITH nocounter, maxrow = 61, nullreport,
   compress, nolandscape
 ;end select
#exit_script
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  CALL echo("inside")
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
 FREE SET captions
END GO
