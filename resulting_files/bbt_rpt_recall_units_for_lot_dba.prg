CREATE PROGRAM bbt_rpt_recall_units_for_lot:dba
 RECORD reply(
   1 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 qual[*]
     2 product_id = f8
     2 product_nbr = c20
     2 product_cd = f8
     2 product_disp = c25
     2 exp_dt_tm = dq8
     2 prod_aborh = c20
     2 cur_location = c25
     2 person_exists = i2
     2 modified_ind = i2
     2 modified_prod_id = f8
     2 modified_prod_nbr = c20
     2 modified_prod_disp = c25
     2 serial_nbr_txt = c22
     2 product_sub_number = c5
     2 octoplas_prod_ind = i2
     2 event_qual[*]
       3 product_event_id = f8
       3 event_type_cd = f8
       3 event_type_disp = c20
       3 event_dt_tm = dq8
       3 person_id = f8
       3 person_name = c30
       3 person_dob = dq8
       3 encntr_id = f8
       3 encntr_mrn = c20
 )
 DECLARE prod_cnt = i4 WITH protect, noconstant(0)
 DECLARE event_cnt = i4 WITH protect, noconstant(0)
 DECLARE prod_display_ind = i2 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE mrn_code = f8 WITH protect, noconstant(0.0)
 DECLARE dshippedeventtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dintransiteventtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dtransferredeventtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE ddestroyeventcd = f8 WITH noconstant(0.0)
 DECLARE modify_disp = vc WITH protect, constant(uar_get_code_display(uar_get_code_by("MEANING",1610,
    "8")))
 DECLARE add_footnote = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(319,nullterm("MRN"),code_cnt,mrn_code)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,nullterm("15"),code_cnt,dshippedeventtypecd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,nullterm("25"),code_cnt,dintransiteventtypecd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,nullterm("6"),code_cnt,dtransferredeventtypecd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,nullterm("14"),1,ddestroyeventcd)
 IF (((mrn_code=0) OR (((dshippedeventtypecd=0) OR (((dintransiteventtypecd=0) OR (((
 dtransferredeventtypecd=0) OR (ddestroyeventcd=0)) )) )) )) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_recall_units_for_lot"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read Code Value"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Issue while reading code value"
  GO TO exit_script
 ENDIF
 FREE RECORD reply_filter
 RECORD reply_filter(
   1 ownerlist[*]
     2 owner_cd = f8
     2 owner_disp = vc
     2 invlist[*]
       3 inventory_cd = f8
       3 inventory_disp = vc
       3 org_id = f8
       3 restrict_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->own_inv_enabled="Y"))
  EXECUTE bb_ref_get_owner_inv_areas  WITH replace(reply,reply_filter)
 ENDIF
 DECLARE where1 = vc
 IF (trim(request->lot_alt_nbr) > "")
  SET where1 = concat(" p.alternate_nbr = request->lot_alt_nbr ",
   "AND p.active_ind = 1 AND p.product_id > 0.0")
 ELSEIF (trim(request->product_nbr) > "")
  SET where1 = concat(" p.product_nbr = request->product_nbr ",
   "AND p.active_ind = 1 AND p.product_id > 0.0")
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.product_id, p.serial_number_txt, p.product_sub_nbr,
  pe.event_type_cd, person_exists = decode(per.seq,"Y","N"), alias_exists = decode(ea.seq,"Y","N"),
  prod_abo = trim(uar_get_code_display(bp.cur_abo_cd)), prod_rh = trim(uar_get_code_display(bp
    .cur_rh_cd)), inventory_area_display = substring(1,25,uar_get_code_display(p.cur_inv_area_cd)),
  octoplas_prod = evaluate(substring(1,2,p.product_type_barcode),"X0",1,0)
  FROM product p,
   blood_product bp,
   product_event pe,
   (dummyt d_per  WITH seq = 1),
   person per,
   (dummyt d_ea  WITH seq = 1),
   encntr_alias ea
  PLAN (p
   WHERE parser(where1))
   JOIN (bp
   WHERE (bp.product_id= Outerjoin(p.product_id)) )
   JOIN (pe
   WHERE pe.product_id=p.product_id
    AND pe.active_ind=1)
   JOIN (d_per
   WHERE d_per.seq=1)
   JOIN (per
   WHERE pe.person_id=per.person_id
    AND per.person_id > 0)
   JOIN (d_ea
   WHERE d_ea.seq=1)
   JOIN (ea
   WHERE ea.encntr_id=pe.encntr_id
    AND ea.encntr_alias_type_cd=mrn_code
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY p.cur_owner_area_cd, p.cur_inv_area_cd, p.product_id,
   pe.product_event_id
  HEAD REPORT
   prod_cnt = 0, owner_found = 0, inv_found = 0,
   filter_product = 0, filter_event = 0
  HEAD p.cur_owner_area_cd
   owner_found = 0
   IF ((request->own_inv_enabled="Y"))
    owner_found = locateval(x,1,size(reply_filter->ownerlist,5),p.cur_owner_area_cd,reply_filter->
     ownerlist[x].owner_cd)
   ENDIF
  HEAD p.cur_inv_area_cd
   inv_found = 0, filter_product = 0
   IF (owner_found > 0)
    inv_found = locateval(y,1,size(reply_filter->ownerlist[owner_found].invlist,5),p.cur_inv_area_cd,
     reply_filter->ownerlist[owner_found].invlist[y].inventory_cd)
   ENDIF
   IF (inv_found > 0)
    filter_product = reply_filter->ownerlist[owner_found].invlist[inv_found].restrict_ind
   ENDIF
  HEAD p.product_id
   IF (filter_product=1)
    add_footnote = 1
   ENDIF
   IF (filter_product=0)
    event_cnt = 0, prod_cnt += 1
    IF (prod_cnt > size(temp_rec->qual,5))
     stat = alterlist(temp_rec->qual,(prod_cnt+ 4))
    ENDIF
    temp_rec->qual[prod_cnt].product_id = p.product_id, temp_rec->qual[prod_cnt].product_nbr = p
    .product_nbr, temp_rec->qual[prod_cnt].product_cd = p.product_cd,
    temp_rec->qual[prod_cnt].product_disp = uar_get_code_display(p.product_cd), temp_rec->qual[
    prod_cnt].exp_dt_tm = p.cur_expire_dt_tm, temp_rec->qual[prod_cnt].prod_aborh = trim(concat(trim(
       prod_abo)," ",trim(prod_rh))),
    temp_rec->qual[prod_cnt].cur_location = inventory_area_display, temp_rec->qual[prod_cnt].
    modified_ind = p.modified_product_ind, temp_rec->qual[prod_cnt].modified_prod_id = p
    .modified_product_id,
    temp_rec->qual[prod_cnt].serial_nbr_txt = p.serial_number_txt, temp_rec->qual[prod_cnt].
    product_sub_number = p.product_sub_nbr, temp_rec->qual[prod_cnt].octoplas_prod_ind =
    octoplas_prod
   ENDIF
  HEAD pe.product_event_id
   filter_event = 0
   IF (pe.event_type_cd=ddestroyeventcd
    AND pe.event_status_flag=1)
    filter_event = 1
   ENDIF
   IF (curutc=1)
    birth_dt_tm = datetimezone(per.birth_dt_tm,per.birth_tz)
   ELSE
    birth_dt_tm = per.birth_dt_tm
   ENDIF
   IF (filter_product=0
    AND filter_event=0)
    event_cnt += 1, stat = alterlist(temp_rec->qual[prod_cnt].event_qual,event_cnt), temp_rec->qual[
    prod_cnt].event_qual[event_cnt].product_event_id = pe.product_event_id,
    temp_rec->qual[prod_cnt].event_qual[event_cnt].event_type_cd = pe.event_type_cd, temp_rec->qual[
    prod_cnt].event_qual[event_cnt].event_type_disp = uar_get_code_display(pe.event_type_cd),
    temp_rec->qual[prod_cnt].event_qual[event_cnt].event_dt_tm = pe.event_dt_tm,
    temp_rec->qual[prod_cnt].event_qual[event_cnt].person_id = pe.person_id, temp_rec->qual[prod_cnt]
    .event_qual[event_cnt].encntr_id = pe.encntr_id
    IF (person_exists="Y")
     temp_rec->qual[prod_cnt].event_qual[event_cnt].person_name = per.name_full_formatted, temp_rec->
     qual[prod_cnt].event_qual[event_cnt].person_dob = birth_dt_tm, temp_rec->qual[prod_cnt].
     person_exists = 1
    ENDIF
    IF (alias_exists="Y")
     temp_rec->qual[prod_cnt].event_qual[event_cnt].encntr_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_rec->qual,prod_cnt)
  WITH nocounter, outerjoin(d_per), dontcare(per),
   outerjoin(d_ea), dontcare(ea)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_recall_units_for_lot"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve data for Lot Number"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Unable to retrieve data"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO prod_cnt)
  IF ((temp_rec->qual[x].modified_prod_id > 0))
   SELECT INTO "nl:"
    p.product_id
    FROM product p
    PLAN (p
     WHERE (p.product_id=temp_rec->qual[x].modified_prod_id))
    DETAIL
     temp_rec->qual[x].modified_prod_nbr = p.product_nbr, temp_rec->qual[x].modified_prod_disp =
     uar_get_code_display(p.product_cd)
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   pe.product_id, event_date_display = substring(1,11,format(pe.event_dt_tm,"YYYY/MM/DD;;D")),
   inventory_area_display = decode(bs.seq,substring(1,25,uar_get_code_display(bs.inventory_area_cd)),
    " "),
   organization_display = decode(bs.seq,substring(1,25,o.org_name)," ")
   FROM product_event pe,
    bb_ship_event bse,
    bb_shipment bs,
    organization o
   PLAN (pe
    WHERE (pe.product_id=temp_rec->qual[x].product_id)
     AND pe.event_type_cd IN (dshippedeventtypecd, dintransiteventtypecd)
     AND pe.active_ind=1)
    JOIN (bse
    WHERE (bse.product_event_id= Outerjoin(pe.product_event_id)) )
    JOIN (bs
    WHERE (bs.shipment_id= Outerjoin(bse.shipment_id))
     AND (bs.active_ind= Outerjoin(1)) )
    JOIN (o
    WHERE (o.organization_id= Outerjoin(bs.organization_id))
     AND (o.organization_id> Outerjoin(0)) )
   ORDER BY pe.product_id, event_date_display DESC
   HEAD pe.product_id
    IF (organization_display != " ")
     temp_rec->qual[x].cur_location = organization_display
    ELSEIF (inventory_area_display != " ")
     temp_rec->qual[x].cur_location = inventory_area_display
    ENDIF
   WITH nocounter
  ;end select
 ENDFOR
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
 DECLARE line = vc WITH noconstant(fillstring(125,"_"))
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE person_exists = i4 WITH protect, noconstant(0)
 DECLARE row_break = i4 WITH protect, noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 aud_lot_rep = vc
   1 time = vc
   1 as_of_date = vc
   1 lot_nbr = vc
   1 original_prod_info = vc
   1 product_number = vc
   1 product_type = vc
   1 aborh = vc
   1 states = vc
   1 dt_tm = vc
   1 location = vc
   1 patient_information = vc
   1 date_of_birth = vc
   1 name = vc
   1 mrn = vc
   1 exp_dt_tm = vc
   1 tech_id = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 note = vc
   1 not_on_file = vc
   1 foot_note = vc
   1 serial_number = vc
   1 div_char = vc
   1 no_data = vc
 )
 SET captions->aud_lot_rep = uar_i18ngetmessage(i18nhandle,"aud_lot_rep",
  "P R O D U C T   R E C A L L   R E P O R T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->lot_nbr = uar_i18ngetmessage(i18nhandle,"lot_nbr","(Alternate ID :")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->exp_dt_tm = uar_i18ngetmessage(i18nhandle,"exp_dt_tm","Expiration")
 SET captions->states = uar_i18ngetmessage(i18nhandle,"states","States")
 SET captions->dt_tm = uar_i18ngetmessage(i18nhandle,"dt_tm","Date/Time")
 SET captions->location = uar_i18ngetmessage(i18nhandle,"location","Location")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_nbr","Serial Number")
 SET captions->div_char = uar_i18ngetmessage(i18nhandle,"div_char","Div Char")
 SET captions->patient_information = uar_i18ngetmessage(i18nhandle,"patient_information",
  "Patient Information")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","Name")
 SET captions->date_of_birth = uar_i18ngetmessage(i18nhandle,"dob","Date of Birth")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_RPT_RECALL_UNITS_FOR_LOT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->original_prod_info = uar_i18ngetmessage(i18nhandle,"original_prod_info",
  "Original Product Information")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note:")
 SET captions->foot_note = uar_i18ngetmessage(i18nhandle,"foot_note",
  "Unable to display one or more products. You are not associated with the facility to which the product is associated."
  )
 SET captions->no_data = uar_i18ngetmessage(i18nhandle,"no_data","( None )")
 EXECUTE cpm_create_file_name_logical "bbt_rpt_recall_lot", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  d.seq, product_type = substring(1,40,temp_rec->qual[d.seq].product_disp), sort_prod_aborh =
  substring(1,15,temp_rec->qual[d.seq].prod_aborh),
  sort_prod_nbr = substring(1,20,temp_rec->qual[d.seq].product_nbr)
  FROM (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d)
  ORDER BY product_type, sort_prod_aborh, sort_prod_nbr
  HEAD REPORT
   line = fillstring(125,"_")
  HEAD PAGE
   CALL center(captions->aud_lot_rep,1,125), col 104, captions->time,
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
   orig_row = row, row 1
   IF ((temp_rec->qual[prod_cnt].octoplas_prod_ind=1))
    CALL center(concat(captions->lot_nbr," ",trim(request->lot_alt_nbr),")"),1,125)
   ELSE
    CALL center(concat("(",captions->product_number,":"," ",trim(request->product_nbr),
     ")"),1,125)
   ENDIF
   col 104, captions->as_of_date, col 118,
   curdate"@DATECONDENSED;;d", call reportmove('ROW',(orig_row+ 2),0)
   IF ((request->product_type="D"))
    col 1, captions->serial_number
   ELSEIF ((request->product_type="B"))
    col 1, captions->div_char
   ELSE
    col 1, captions->product_number
   ENDIF
   col 23, captions->aborh, col 36,
   captions->product_type, col 61, captions->exp_dt_tm,
   col 75, captions->states, col 92,
   captions->dt_tm, col 106, captions->location,
   row + 1, col 1, "---------------------",
   col 23, "------------", col 36,
   "------------------------", col 61, "-------------",
   col 75, "----------------", col 92,
   "-------------", col 106, "-------------------------",
   row + 1
  DETAIL
   last_row = 0
   IF ((temp_rec->qual[d.seq].person_exists=1))
    last_row = 5
   ENDIF
   IF ((temp_rec->qual[d.seq].modified_prod_id > 0)
    AND last_row=0)
    last_row = 4
   ENDIF
   IF ((((temp_rec->qual[d.seq].person_exists=1)) OR ((temp_rec->qual[d.seq].modified_prod_id > 0)))
   )
    IF ((temp_rec->qual[d.seq].modified_ind=1))
     row_break = ((size(temp_rec->qual[d.seq].event_qual,5)+ 1)+ last_row)
    ELSE
     row_break = (size(temp_rec->qual[d.seq].event_qual,5)+ last_row)
    ENDIF
   ELSE
    IF ((temp_rec->qual[d.seq].modified_ind=1))
     row_break = (size(temp_rec->qual[d.seq].event_qual,5)+ 1)
    ELSE
     row_break = size(temp_rec->qual[d.seq].event_qual,5)
    ENDIF
   ENDIF
   IF (((row+ row_break) > 56))
    BREAK
   ENDIF
   IF (trim(temp_rec->qual[d.seq].serial_nbr_txt) > "")
    col 1, temp_rec->qual[d.seq].serial_nbr_txt
   ELSEIF (trim(temp_rec->qual[d.seq].product_sub_number) > "")
    col 1, temp_rec->qual[d.seq].product_sub_number
   ELSEIF (trim(request->lot_alt_nbr) > "")
    col 1, temp_rec->qual[d.seq].product_nbr
   ELSE
    col 1, captions->no_data
   ENDIF
   col 23, temp_rec->qual[d.seq].prod_aborh"############", col 36,
   temp_rec->qual[d.seq].product_disp"#########################", col 61, temp_rec->qual[d.seq].
   exp_dt_tm"@DATETIMECONDENSED;;d",
   col 106, temp_rec->qual[d.seq].cur_location"#########################", person_exists = 0
   FOR (i = 1 TO size(temp_rec->qual[d.seq].event_qual,5))
     IF (i > 1)
      row + 1
     ENDIF
     col 75, temp_rec->qual[d.seq].event_qual[i].event_type_disp"####################", col 92,
     temp_rec->qual[d.seq].event_qual[i].event_dt_tm"@DATETIMECONDENSED;;d"
     IF ((temp_rec->qual[d.seq].event_qual[i].person_id > 0))
      person_exists = i
     ENDIF
   ENDFOR
   IF ((temp_rec->qual[d.seq].modified_ind=1))
    row + 1, col 75, "(",
    modify_disp, ")"
   ENDIF
   orig_row = row, last_row = 0
   IF (person_exists > 0)
    call reportmove('ROW',(orig_row+ 1),0), col 15, captions->patient_information,
    row + 1, col 15, "----------------------------------------------",
    row + 1, col 15, captions->name,
    ":", col 30, temp_rec->qual[d.seq].event_qual[person_exists].person_name
    "##############################",
    row + 1, col 15, captions->date_of_birth,
    ":"
    IF ((temp_rec->qual[d.seq].event_qual[person_exists].person_dob > 0))
     IF (curutc=1)
      col 30, temp_rec->qual[d.seq].event_qual[person_exists].person_dob"@DATETIMECONDENSED;4;q"
     ELSE
      col 30, temp_rec->qual[d.seq].event_qual[person_exists].person_dob"@DATETIMECONDENSED;;d"
     ENDIF
    ELSE
     col 30, captions->not_on_file
    ENDIF
    row + 1, col 15, captions->mrn,
    ":"
    IF (trim(temp_rec->qual[d.seq].event_qual[person_exists].encntr_mrn) > " ")
     col 30, temp_rec->qual[d.seq].event_qual[person_exists].encntr_mrn"###############"
    ELSE
     col 30, captions->not_on_file
    ENDIF
    last_row = row
   ENDIF
   IF ((temp_rec->qual[d.seq].modified_prod_id > 0))
    call reportmove('ROW',(orig_row+ 1),0), col 75, captions->original_prod_info,
    row + 1, col 75, "-----------------------------------------",
    row + 1, col 75, captions->product_number,
    ":", col 91, temp_rec->qual[d.seq].modified_prod_nbr,
    row + 1, col 75, captions->product_type,
    ":", col 91, temp_rec->qual[d.seq].modified_prod_disp"#########################"
    IF (last_row=0)
     last_row = row
    ENDIF
   ENDIF
   IF (last_row=0)
    row + 2
   ELSE
    call reportmove('ROW',(last_row+ 2),0)
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
   IF (add_footnote=1)
    row + 1, col 1, captions->note,
    " ", captions->foot_note
   ENDIF
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH nocounter, nullreport, maxrow = 61,
   maxcol = 132, compress
 ;end select
 SET reply->rpt_filename = cpm_cfn_info->file_name_path
 IF ((reply->rpt_filename > ""))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
END GO
