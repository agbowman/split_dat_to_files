CREATE PROGRAM bbt_rpt_final_disp_cor:dba
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
 FREE SET prod
 RECORD captions(
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
   1 scortyp = vc
   1 scornotes = vc
   1 sdemog = vc
   1 scurrent = vc
   1 sprev = vc
   1 scorrected = vc
   1 stechid = vc
   1 scorreason = vc
   1 sprodnum = vc
   1 sserialnum = vc
   1 sprodtyp = vc
   1 sdispdate = vc
   1 sdispreason = vc
   1 sdestdate = vc
   1 sdestmethod = vc
   1 sdestservice = vc
   1 smanifest = vc
   1 snodata = vc
   1 end_of_report = vc
 )
 DECLARE ddispcv = f8 WITH protect, noconstant(0.0)
 DECLARE ddestcv = f8 WITH protect, noconstant(0.0)
 DECLARE n = i4 WITH protect, noconstant(0)
 DECLARE nprodcnt = i4 WITH protect, noconstant(0)
 DECLARE ndispdatecnt = i4 WITH protect, noconstant(0)
 DECLARE ndispreasoncnt = i4 WITH protect, noconstant(0)
 DECLARE ndestdatecnt = i4 WITH protect, noconstant(0)
 DECLARE ndestautocnt = i4 WITH protect, noconstant(0)
 DECLARE ndestmethodcnt = i4 WITH protect, noconstant(0)
 DECLARE ndestmancnt = i4 WITH protect, noconstant(0)
 DECLARE ndestservcnt = i4 WITH protect, noconstant(0)
 DECLARE nnotecnt = i4 WITH protect, noconstant(0)
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 DECLARE stemp = vc WITH protect, noconstant(" ")
 RECORD prod(
   1 products[*]
     2 own_cd = f8
     2 inv_cd = f8
     2 prod_id = f8
     2 prod_nbr = vc
     2 serial_nbr = vc
     2 prod_type = vc
     2 disp_date_chg_ind = i2
     2 disp_date_new_val = dq8
     2 disp_date_chg[*]
       3 old_val = dq8
       3 reason = vc
       3 chg_date = dq8
       3 username = c13
     2 reason_chg_ind = i2
     2 reason_new_val = vc
     2 reason_chg[*]
       3 old_val = vc
       3 reason = vc
       3 chg_date = dq8
       3 username = c13
     2 date_chg_ind = i2
     2 date_new_val = dq8
     2 date_chg[*]
       3 old_val = dq8
       3 reason = vc
       3 chg_date = dq8
       3 username = c13
     2 autoclave_ind = i2
     2 autoclave_new_val = i2
     2 autoclave_chg[*]
       3 old_val = i2
       3 reason = vc
       3 chg_date = dq8
       3 username = c13
     2 method_ind = i2
     2 method_new_val = vc
     2 method_chg[*]
       3 old_val = vc
       3 reason = vc
       3 chg_date = dq8
       3 username = c13
     2 man_ind = i2
     2 man_new_val = vc
     2 man_chg[*]
       3 old_val = vc
       3 reason = vc
       3 chg_date = dq8
       3 username = c13
     2 serv_ind = i2
     2 serv_new_val = vc
     2 serv_chg[*]
       3 old_val = vc
       3 reason = vc
       3 chg_date = dq8
       3 username = c13
     2 note_ind = i2
     2 cor_notes[*]
       3 updt_dt_tm = dq8
       3 username = c13
       3 correction_reason = vc
       3 correction_note = vc
 )
 SET captions->scortyp = uar_i18ngetmessage(i18nhandle,"correction_type","Correction Type: ")
 SET captions->sdemog = uar_i18ngetmessage(i18nhandle,"demographic","Demographic")
 SET captions->scurrent = uar_i18ngetmessage(i18nhandle,"current","Current")
 SET captions->sprev = uar_i18ngetmessage(i18nhandle,"previous","Previous")
 SET captions->scorrected = uar_i18ngetmessage(i18nhandle,"corrected","Corrected")
 SET captions->stechid = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->scorreason = uar_i18ngetmessage(i18nhandle,"correction_reason","Correction Reason")
 SET captions->scornotes = uar_i18ngetmessage(i18nhandle,"correction_notes","Correction Notes")
 SET captions->sprodnum = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->sserialnum = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
 SET captions->sprodtyp = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->sdispdate = uar_i18ngetmessage(i18nhandle,"disp_date","Dispose Date/Time")
 SET captions->sdispreason = uar_i18ngetmessage(i18nhandle,"disp_reason","Dispose Reason")
 SET captions->sdestdate = uar_i18ngetmessage(i18nhandle,"dest_date","Destruction Date/Time")
 SET captions->sdestmethod = uar_i18ngetmessage(i18nhandle,"dest_method","Destruction Method")
 SET captions->sdestservice = uar_i18ngetmessage(i18nhandle,"dest_service","Destruction Service")
 SET captions->smanifest = uar_i18ngetmessage(i18nhandle,"manifest","Manifest Number")
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
  "Report ID: BBT_FIN_DISP_COR")
 SET captions->inc_page = uar_i18ngetmessage(i18nhandle,"inc_page","Page:")
 SET captions->inc_printed = uar_i18ngetmessage(i18nhandle,"inc_printed","Printed:")
 SET captions->snodata = uar_i18ngetmessage(i18nhandle,"no_data","(none)")
 SET ddispcv = uar_get_code_by("MEANING",1610,"5")
 SET ddestcv = uar_get_code_by("MEANING",1610,"14")
 SUBROUTINE (assignstring(sstring=vc,nmaxlen=i4) =vc WITH persist)
  IF (textlen(sstring) <= nmaxlen)
   RETURN(sstring)
  ENDIF
  RETURN(substring(1,nmaxlen,sstring))
 END ;Subroutine
 DECLARE b_strg = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  cp_origdttm_exists = evaluate(nullind(cp.orig_updt_dt_tm),0,1,0), cp_notes_exist = evaluate(size(
    trim(cp.correction_note)),0,0,1), di_reason_exists = evaluate(nullind(di.reason_cd),0,1,0)
  FROM corrected_product cp,
   product pr,
   prsnl p,
   product_event pe,
   disposition di,
   destruction de,
   organization o,
   organization o2
  PLAN (cp
   WHERE cp.correction_type_cd=disp_cd
    AND cp.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((cp.correction_flag=0) OR (cp.correction_flag = null))
    AND cp.correction_id > 0
    AND cp.product_id > 0)
   JOIN (pr
   WHERE pr.product_id=cp.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (p
   WHERE p.person_id=cp.updt_id)
   JOIN (pe
   WHERE pe.product_event_id=cp.product_event_id
    AND pe.event_type_cd IN (ddestcv, ddispcv))
   JOIN (di
   WHERE di.product_id=cp.product_id)
   JOIN (de
   WHERE de.product_id=cp.product_id)
   JOIN (o
   WHERE (o.organization_id= Outerjoin(cp.destruction_org_id)) )
   JOIN (o2
   WHERE (o2.organization_id= Outerjoin(de.destruction_org_id)) )
  ORDER BY cp.product_id, pe.product_event_id
  HEAD cp.product_id
   nprodcnt += 1
   IF (mod(nprodcnt,10)=1)
    stat = alterlist(prod->products,(nprodcnt+ 9))
   ENDIF
   prod->products[nprodcnt].prod_id = cp.product_id, prod->products[nprodcnt].prod_nbr = pr
   .product_nbr, prod->products[nprodcnt].serial_nbr = pr.serial_number_txt,
   prod->products[nprodcnt].prod_type = uar_get_code_display(pr.product_cd), prod->products[nprodcnt]
   .own_cd = pr.cur_owner_area_cd, prod->products[nprodcnt].inv_cd = pr.cur_inv_area_cd,
   prod->products[nprodcnt].reason_new_val = captions->snodata
   IF (di_reason_exists=1)
    IF (di.reason_cd > 0)
     prod->products[nprodcnt].reason_new_val = uar_get_code_display(di.reason_cd)
    ENDIF
   ENDIF
   prod->products[nprodcnt].autoclave_new_val = de.autoclave_ind, prod->products[nprodcnt].
   method_new_val = uar_get_code_display(de.method_cd), prod->products[nprodcnt].man_new_val =
   evaluate(textlen(trim(de.manifest_nbr)),0,captions->snodata,de.manifest_nbr),
   prod->products[nprodcnt].serv_new_val = evaluate(textlen(trim(o2.org_name)),0,captions->snodata,o2
    .org_name)
  HEAD pe.product_event_id
   IF (pe.event_type_cd=ddispcv)
    prod->products[nprodcnt].disp_date_new_val = cnvtdatetime(pe.event_dt_tm)
   ELSE
    prod->products[nprodcnt].date_new_val = cnvtdatetime(pe.event_dt_tm)
   ENDIF
  DETAIL
   IF ((cp.autoclave_ind=- (2)))
    IF (cp_origdttm_exists=1)
     ndispdatecnt += 1, prod->products[nprodcnt].disp_date_chg_ind = 1
     IF (mod(ndispdatecnt,10)=1)
      stat = alterlist(prod->products[nprodcnt].disp_date_chg,(ndispdatecnt+ 9))
     ENDIF
     prod->products[nprodcnt].disp_date_chg[ndispdatecnt].old_val = cnvtdatetime(cp.orig_updt_dt_tm),
     prod->products[nprodcnt].disp_date_chg[ndispdatecnt].reason = uar_get_code_display(cp
      .correction_reason_cd), prod->products[nprodcnt].disp_date_chg[ndispdatecnt].chg_date =
     cnvtdatetime(cp.updt_dt_tm),
     prod->products[nprodcnt].disp_date_chg[ndispdatecnt].username = p.username
    ENDIF
    IF ((cp.reason_cd > - (1)))
     ndispreasoncnt += 1, prod->products[nprodcnt].reason_chg_ind = 1
     IF (mod(ndispreasoncnt,10)=1)
      stat = alterlist(prod->products[nprodcnt].reason_chg,(ndispreasoncnt+ 9))
     ENDIF
     prod->products[nprodcnt].reason_chg[ndispreasoncnt].old_val = uar_get_code_display(cp.reason_cd),
     prod->products[nprodcnt].reason_chg[ndispreasoncnt].reason = uar_get_code_display(cp
      .correction_reason_cd), prod->products[nprodcnt].reason_chg[ndispreasoncnt].chg_date =
     cnvtdatetime(cp.updt_dt_tm),
     prod->products[nprodcnt].reason_chg[ndispreasoncnt].username = p.username
    ENDIF
   ELSE
    IF (cp_origdttm_exists=1)
     ndestdatecnt += 1, prod->products[nprodcnt].date_chg_ind = 1
     IF (mod(ndestdatecnt,10)=1)
      stat = alterlist(prod->products[nprodcnt].date_chg,(ndestdatecnt+ 9))
     ENDIF
     prod->products[nprodcnt].date_chg[ndestdatecnt].old_val = cnvtdatetime(cp.orig_updt_dt_tm), prod
     ->products[nprodcnt].date_chg[ndestdatecnt].reason = uar_get_code_display(cp
      .correction_reason_cd), prod->products[nprodcnt].date_chg[ndestdatecnt].chg_date = cnvtdatetime
     (cp.updt_dt_tm),
     prod->products[nprodcnt].date_chg[ndestdatecnt].username = p.username
    ENDIF
    IF ((cp.autoclave_ind > - (1)))
     ndestautocnt += 1, prod->products[nprodcnt].autoclave_ind = 1
     IF (mod(ndestautocnt,10)=1)
      stat = alterlist(prod->products[nprodcnt].autoclave_chg,(ndestautocnt+ 9))
     ENDIF
     prod->products[nprodcnt].autoclave_chg[ndestautocnt].old_val = cp.autoclave_ind, prod->products[
     nprodcnt].autoclave_chg[ndestautocnt].reason = uar_get_code_display(cp.correction_reason_cd),
     prod->products[nprodcnt].autoclave_chg[ndestautocnt].chg_date = cnvtdatetime(cp.updt_dt_tm),
     prod->products[nprodcnt].autoclave_chg[ndestautocnt].username = p.username
    ENDIF
    IF ((cp.destruction_method_cd > - (1)))
     ndestmethodcnt += 1, prod->products[nprodcnt].method_ind = 1
     IF (mod(ndestmethodcnt,10)=1)
      stat = alterlist(prod->products[nprodcnt].method_chg,(ndestmethodcnt+ 9))
     ENDIF
     prod->products[nprodcnt].method_chg[ndestmethodcnt].old_val = uar_get_code_display(cp
      .destruction_method_cd), prod->products[nprodcnt].method_chg[ndestmethodcnt].reason =
     uar_get_code_display(cp.correction_reason_cd), prod->products[nprodcnt].method_chg[
     ndestmethodcnt].chg_date = cnvtdatetime(cp.updt_dt_tm),
     prod->products[nprodcnt].method_chg[ndestmethodcnt].username = p.username
    ENDIF
    IF (cp.manifest_nbr != "-1")
     ndestmancnt += 1, prod->products[nprodcnt].man_ind = 1
     IF (mod(ndestmancnt,10)=1)
      stat = alterlist(prod->products[nprodcnt].man_chg,(ndestmancnt+ 9))
     ENDIF
     prod->products[nprodcnt].man_chg[ndestmancnt].old_val = evaluate(textlen(trim(cp.manifest_nbr)),
      0,captions->snodata,cp.manifest_nbr), prod->products[nprodcnt].man_chg[ndestmancnt].reason =
     uar_get_code_display(cp.correction_reason_cd), prod->products[nprodcnt].man_chg[ndestmancnt].
     chg_date = cnvtdatetime(cp.updt_dt_tm),
     prod->products[nprodcnt].man_chg[ndestmancnt].username = p.username
    ENDIF
    IF ((cp.destruction_org_id > - (1))
     AND cp.destruction_org_id_flag != 2)
     ndestservcnt += 1, prod->products[nprodcnt].serv_ind = 1
     IF (mod(ndestservcnt,10)=1)
      stat = alterlist(prod->products[nprodcnt].serv_chg,(ndestservcnt+ 9))
     ENDIF
     prod->products[nprodcnt].serv_chg[ndestservcnt].old_val = o.org_name, prod->products[nprodcnt].
     serv_chg[ndestservcnt].reason = uar_get_code_display(cp.correction_reason_cd), prod->products[
     nprodcnt].serv_chg[ndestservcnt].chg_date = cnvtdatetime(cp.updt_dt_tm),
     prod->products[nprodcnt].serv_chg[ndestservcnt].username = p.username
    ENDIF
   ENDIF
   IF (cp_notes_exist=1)
    nnotecnt += 1, prod->products[nprodcnt].note_ind = 1
    IF (mod(nnotecnt,10)=1)
     stat = alterlist(prod->products[nprodcnt].cor_notes,(nnotecnt+ 9))
    ENDIF
    prod->products[nprodcnt].cor_notes[nnotecnt].correction_note = cp.correction_note, prod->
    products[nprodcnt].cor_notes[nnotecnt].correction_reason = uar_get_code_display(cp
     .correction_reason_cd), prod->products[nprodcnt].cor_notes[nnotecnt].username = p.username,
    prod->products[nprodcnt].cor_notes[nnotecnt].updt_dt_tm = cnvtdatetime(cp.updt_dt_tm)
   ENDIF
  FOOT  pe.product_event_id
   row + 0
  FOOT  cp.product_id
   stat = alterlist(prod->products[nprodcnt].cor_notes,nnotecnt), stat = alterlist(prod->products[
    nprodcnt].serv_chg,ndestservcnt), stat = alterlist(prod->products[nprodcnt].man_chg,ndestmancnt),
   stat = alterlist(prod->products[nprodcnt].method_chg,ndestmethodcnt), stat = alterlist(prod->
    products[nprodcnt].autoclave_chg,ndestautocnt), stat = alterlist(prod->products[nprodcnt].
    date_chg,ndestdatecnt),
   stat = alterlist(prod->products[nprodcnt].reason_chg,ndispreasoncnt), stat = alterlist(prod->
    products[nprodcnt].disp_date_chg,ndispdatecnt), ndestservcnt = 0,
   ndestmancnt = 0, nnotecnt = 0, ndestmethodcnt = 0,
   ndestautocnt = 0, ndestdatecnt = 0, ndispreasoncnt = 0,
   ndispdatecnt = 0
  WITH nocounter
 ;end select
 SET stat = alterlist(prod->products,nprodcnt)
 SELECT INTO cpm_cfn_info->file_name_logical
  hd_prod_nbr = substring(1,28,prod->products[d.seq].prod_nbr), hd_own_cd = prod->products[d.seq].
  own_cd, hd_inv_cd = prod->products[d.seq].inv_cd,
  seq_exists = evaluate(nullind(d.seq),0,1,0)
  FROM (dummyt d  WITH seq = value(nprodcnt))
  WHERE d.seq <= nprodcnt
  ORDER BY hd_own_cd, hd_inv_cd, hd_prod_nbr
  HEAD REPORT
   row + 0, line1 = fillstring(25,"-"), line2 = fillstring(27,"-"),
   line3 = fillstring(13,"-"), line4 = fillstring(19,"-"), first_owner = 1,
   first_inv = 1
  HEAD PAGE
   row 0
   IF (seq_exists=1)
    cur_owner_area_disp = uar_get_code_display(prod->products[d.seq].own_cd), cur_inv_area_disp =
    uar_get_code_display(prod->products[d.seq].inv_cd)
   ENDIF
   CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
   col 121, curtime"@TIMENOSECONDS;;m", row + 1,
   col 107, captions->inc_as_of_date, col 119,
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
   col 1, captions->scortyp, col 18,
   disp_disp, row + 2, col 8,
   captions->sdemog, col 37, captions->scurrent,
   col 64, captions->sprev, col 86,
   captions->scorrected, col 98, captions->stechid,
   col 113, captions->scorreason, row + 1,
   col 1, line1, col 27,
   line2, col 55, line2,
   col 84, line3, col 98,
   line3, col 112, line4,
   row + 1
  HEAD hd_own_cd
   IF (first_owner=1)
    first_owner = 0
   ELSE
    first_inv = 1, BREAK
   ENDIF
  HEAD hd_inv_cd
   IF (first_inv=1)
    first_inv = 0
   ELSE
    BREAK
   ENDIF
  HEAD hd_prod_nbr
   datafoundflag = true, col 1, "*",
   row + 1
   IF (row=57)
    BREAK
   ENDIF
   col 1, captions->sprodnum, col 27,
   prod->products[d.seq].prod_nbr, row + 1
   IF (row=57)
    BREAK
   ENDIF
   IF ((prod->products[d.seq].serial_nbr != null))
    col 1, captions->sserialnum, col 27,
    prod->products[d.seq].serial_nbr, row + 1
   ENDIF
   IF (row=57)
    BREAK
   ENDIF
   col 1, captions->sprodtyp, col 27,
   prod->products[d.seq].prod_type, row + 1
   IF (row=57)
    BREAK
   ENDIF
   col 1, captions->sdispdate
   IF ((prod->products[d.seq].disp_date_new_val > 0))
    col 27, prod->products[d.seq].disp_date_new_val"@DATECONDENSED;;d", col 35,
    prod->products[d.seq].disp_date_new_val"@TIMENOSECONDS;;M"
   ELSE
    col 27, captions->snodata
   ENDIF
   IF ((prod->products[d.seq].disp_date_chg_ind=1))
    col 55, prod->products[d.seq].disp_date_chg[1].old_val"@DATECONDENSED;;d", col 63,
    prod->products[d.seq].disp_date_chg[1].old_val"@TIMENOSECONDS;;M", col 84, prod->products[d.seq].
    disp_date_chg[1].chg_date"@DATECONDENSED;;d",
    col 92, prod->products[d.seq].disp_date_chg[1].chg_date"@TIMENOSECONDS;;M", stemp = assignstring(
     prod->products[d.seq].disp_date_chg[1].username,13),
    col 98, stemp, stemp = assignstring(prod->products[d.seq].disp_date_chg[1].reason,19),
    col 112, stemp, row + 1
    IF (row=57)
     BREAK
    ENDIF
    FOR (n = 2 TO size(prod->products[d.seq].disp_date_chg,5))
      col 55, prod->products[d.seq].disp_date_chg[n].old_val"@DATECONDENSED;;d", col 63,
      prod->products[d.seq].disp_date_chg[n].old_val"@TIMENOSECONDS;;M", col 84, prod->products[d.seq
      ].disp_date_chg[n].chg_date"@DATECONDENSED;;d",
      col 92, prod->products[d.seq].disp_date_chg[n].chg_date"@TIMENOSECONDS;;M", stemp =
      assignstring(prod->products[d.seq].disp_date_chg[n].username,13),
      col 98, stemp, stemp = assignstring(prod->products[d.seq].disp_date_chg[n].reason,19),
      col 112, stemp, row + 1
      IF (row=57)
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1
    IF (row=57)
     BREAK
    ENDIF
   ENDIF
   col 1, captions->sdispreason, col 27,
   prod->products[d.seq].reason_new_val
   IF ((prod->products[d.seq].reason_chg_ind=1))
    col 55, prod->products[d.seq].reason_chg[1].old_val, col 84,
    prod->products[d.seq].reason_chg[1].chg_date"@DATECONDENSED;;d", col 92, prod->products[d.seq].
    reason_chg[1].chg_date"@TIMENOSECONDS;;M",
    stemp = assignstring(prod->products[d.seq].reason_chg[1].username,13), col 98, stemp,
    stemp = assignstring(prod->products[d.seq].reason_chg[1].reason,19), col 112, stemp,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    FOR (n = 2 TO size(prod->products[d.seq].reason_chg,5))
      col 55, prod->products[d.seq].reason_chg[n].old_val, col 84,
      prod->products[d.seq].reason_chg[n].chg_date"@DATECONDENSED;;d", col 92, prod->products[d.seq].
      reason_chg[n].chg_date"@TIMENOSECONDS;;M",
      stemp = assignstring(prod->products[d.seq].reason_chg[n].username,13), col 98, stemp,
      stemp = assignstring(prod->products[d.seq].reason_chg[n].reason,19), col 112, stemp,
      row + 1
      IF (row=57)
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1
    IF (row=57)
     BREAK
    ENDIF
   ENDIF
   col 1, captions->sdestdate
   IF ((prod->products[d.seq].date_new_val > 0))
    col 27, prod->products[d.seq].date_new_val"@DATECONDENSED;;d", col 35,
    prod->products[d.seq].date_new_val"@TIMENOSECONDS;;M"
   ELSE
    col 27, captions->snodata
   ENDIF
   IF ((prod->products[d.seq].date_chg_ind=1))
    col 55, prod->products[d.seq].date_chg[1].old_val"@DATECONDENSED;;d", col 63,
    prod->products[d.seq].date_chg[1].old_val"@TIMENOSECONDS;;M", col 84, prod->products[d.seq].
    date_chg[1].chg_date"@DATECONDENSED;;d",
    col 92, prod->products[d.seq].date_chg[1].chg_date"@TIMENOSECONDS;;M", stemp = assignstring(prod
     ->products[d.seq].date_chg[1].username,13),
    col 98, stemp, stemp = assignstring(prod->products[d.seq].date_chg[1].reason,19),
    col 112, stemp, row + 1
    IF (row=57)
     BREAK
    ENDIF
    FOR (n = 2 TO size(prod->products[d.seq].date_chg,5))
      col 55, prod->products[d.seq].date_chg[n].old_val"@DATECONDENSED;;d", col 63,
      prod->products[d.seq].date_chg[n].old_val"@TIMENOSECONDS;;M", col 84, prod->products[d.seq].
      date_chg[n].chg_date"@DATECONDENSED;;d",
      col 92, prod->products[d.seq].date_chg[n].chg_date"@TIMENOSECONDS;;M", stemp = assignstring(
       prod->products[d.seq].date_chg[n].username,13),
      col 98, stemp, stemp = assignstring(prod->products[d.seq].date_chg[n].reason,19),
      col 112, stemp, row + 1
      IF (row=57)
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1
    IF (row=57)
     BREAK
    ENDIF
   ENDIF
   col 1, captions->sdestmethod, col 27,
   prod->products[d.seq].method_new_val
   IF ((prod->products[d.seq].method_ind=1))
    col 55, prod->products[d.seq].method_chg[1].old_val, col 84,
    prod->products[d.seq].method_chg[1].chg_date"@DATECONDENSED;;d", col 92, prod->products[d.seq].
    method_chg[1].chg_date"@TIMENOSECONDS;;M",
    stemp = assignstring(prod->products[d.seq].method_chg[1].username,13), col 98, stemp,
    stemp = assignstring(prod->products[d.seq].method_chg[1].reason,19), col 112, stemp,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    FOR (n = 2 TO size(prod->products[d.seq].method_chg,5))
      col 55, prod->products[d.seq].method_chg[n].old_val, col 84,
      prod->products[d.seq].method_chg[n].chg_date"@DATECONDENSED;;d", col 92, prod->products[d.seq].
      method_chg[n].chg_date"@TIMENOSECONDS;;M",
      stemp = assignstring(prod->products[d.seq].method_chg[n].username,13), col 98, stemp,
      stemp = assignstring(prod->products[d.seq].method_chg[n].reason,19), col 112, stemp,
      row + 1
      IF (row=57)
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1
    IF (row=57)
     BREAK
    ENDIF
   ENDIF
   col 1, captions->sdestservice, col 27,
   prod->products[d.seq].serv_new_val
   IF ((prod->products[d.seq].serv_ind=1))
    col 55, prod->products[d.seq].serv_chg[1].old_val, col 84,
    prod->products[d.seq].serv_chg[1].chg_date"@DATECONDENSED;;d", col 92, prod->products[d.seq].
    serv_chg[1].chg_date"@TIMENOSECONDS;;M",
    stemp = assignstring(prod->products[d.seq].serv_chg[1].username,13), col 98, stemp,
    stemp = assignstring(prod->products[d.seq].serv_chg[1].reason,19), col 112, stemp,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    FOR (n = 2 TO size(prod->products[d.seq].serv_chg,5))
      col 55, prod->products[d.seq].serv_chg[n].old_val, col 84,
      prod->products[d.seq].serv_chg[n].chg_date"@DATECONDENSED;;d", col 92, prod->products[d.seq].
      serv_chg[n].chg_date"@TIMENOSECONDS;;M",
      stemp = assignstring(prod->products[d.seq].serv_chg[n].username,13), col 98, stemp,
      stemp = assignstring(prod->products[d.seq].serv_chg[n].reason,19), col 112, stemp,
      row + 1
      IF (row=57)
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1
    IF (row=57)
     BREAK
    ENDIF
   ENDIF
   col 1, captions->smanifest, col 27,
   prod->products[d.seq].man_new_val
   IF ((prod->products[d.seq].man_ind=1))
    col 55, prod->products[d.seq].man_chg[1].old_val, col 84,
    prod->products[d.seq].man_chg[1].chg_date"@DATECONDENSED;;d", col 92, prod->products[d.seq].
    man_chg[1].chg_date"@TIMENOSECONDS;;M",
    stemp = assignstring(prod->products[d.seq].man_chg[1].username,13), col 98, stemp,
    stemp = assignstring(prod->products[d.seq].man_chg[1].reason,19), col 112, stemp,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    FOR (n = 2 TO size(prod->products[d.seq].man_chg,5))
      col 55, prod->products[d.seq].man_chg[n].old_val, col 84,
      prod->products[d.seq].man_chg[n].chg_date"@DATECONDENSED;;d", col 92, prod->products[d.seq].
      man_chg[n].chg_date"@TIMENOSECONDS;;M",
      stemp = assignstring(prod->products[d.seq].man_chg[n].username,13), col 98, stemp,
      stemp = assignstring(prod->products[d.seq].man_chg[n].reason,19), col 112, stemp,
      row + 1
      IF (row=57)
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1
    IF (row=57)
     BREAK
    ENDIF
   ENDIF
   col 1, captions->scornotes, b_str_len = 0,
   b_cnt = 1, start_col_cnt = 26, col_cnt = 26,
   pos_left = 54, max_width = 54
   IF ((prod->products[d.seq].note_ind=1))
    col 84, prod->products[d.seq].cor_notes[1].updt_dt_tm"@DATECONDENSED;;d", col 92,
    prod->products[d.seq].cor_notes[1].updt_dt_tm"@TIMENOSECONDS;;M", stemp = assignstring(prod->
     products[d.seq].cor_notes[1].username,13), col 98,
    stemp, stemp = assignstring(prod->products[d.seq].cor_notes[1].correction_reason,19), col 112,
    stemp, b_strg = prod->products[d.seq].cor_notes[1].correction_note, b_str_len = size(trim(b_strg)
     )
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
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    FOR (n = 2 TO size(prod->products[d.seq].cor_notes,5))
      IF ((prod->products[d.seq].cor_notes[n].updt_dt_tm != prod->products[d.seq].cor_notes[(n - 1)].
      updt_dt_tm))
       b_str_len = 0, b_cnt = 1, start_col_cnt = 26,
       col_cnt = 26, pos_left = 54, col 84,
       prod->products[d.seq].cor_notes[n].updt_dt_tm"@DATECONDENSED;;d", col 92, prod->products[d.seq
       ].cor_notes[n].updt_dt_tm"@TIMENOSECONDS;;M",
       stemp = assignstring(prod->products[d.seq].cor_notes[n].username,13), col 98, stemp,
       stemp = assignstring(prod->products[d.seq].cor_notes[n].correction_reason,19), col 112, stemp,
       b_strg = prod->products[d.seq].cor_notes[n].correction_note, b_str_len = size(trim(b_strg))
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
              IF (((substring(b_cnt_sub,1,b_strg)=" ") OR (substring(b_cnt_sub,2,b_strg)=concat(char(
                13),char(10)))) )
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
       row + 1
       IF (row=57)
        BREAK
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    col 26, captions->snodata, row + 1
    IF (row=57)
     BREAK
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  hd_prod_nbr
   row + 0
  FOOT  hd_inv_cd
   row + 0
  FOOT  hd_own_cd
   row + 0
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
  WITH nocounter, maxrow = 61, compress,
   nolandscape, nullreport
 ;end select
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
END GO
