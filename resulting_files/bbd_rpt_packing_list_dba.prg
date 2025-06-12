CREATE PROGRAM bbd_rpt_packing_list:dba
 DECLARE get_username(sub_person_id) = c10
 SUBROUTINE get_username(sub_person_id)
   SET sub_get_username = fillstring(10," ")
   SELECT INTO "nl:"
    pnl.username
    FROM prsnl pnl
    WHERE pnl.person_id=sub_person_id
     AND pnl.person_id != null
     AND pnl.person_id > 0.0
    DETAIL
     sub_get_username = pnl.username
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET inc_i18nhandle = 0
    SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
    SET sub_get_username = uar_i18ngetmessage(inc_i18nhandle,"inc_unknown","<Unknown>")
   ENDIF
   RETURN(sub_get_username)
 END ;Subroutine
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
 RECORD reply(
   1 report_name_list[*]
     2 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
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
 RECORD ship_from_locs(
   1 qual[*]
     2 ship_from_loc_disp = vc
 )
 RECORD product_data(
   1 ad_person_cnt = i4
   1 ad_persons[*]
     2 ad_person = vc
   1 antigen_cnt = i4
   1 antigens[*]
     2 antigen_disp = vc
 )
 RECORD captions(
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 ship_to = vc
   1 shipment_number = vc
   1 ordered = vc
   1 order_placed_by = vc
   1 needed = vc
   1 courier = vc
   1 actual = vc
   1 container_number = vc
   1 type = vc
   1 condition = vc
   1 weight = vc
   1 prod_number = vc
   1 formatted_type = vc
   1 abo_rh = vc
   1 expiration_date = vc
   1 volume = vc
   1 assigned_to = vc
   1 notes = vc
   1 packed_inspected_by = vc
   1 printed_by = vc
   1 temperature = vc
   1 antigens = vc
   1 visual_inspection = vc
   1 order_priority = vc
   1 ship_from = vc
   1 recipients = vc
 )
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "S H I P M E N T   P A C K I N G   L I S T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->ship_to = uar_i18ngetmessage(i18nhandle,"ship_to","Ship To:")
 SET captions->shipment_number = uar_i18ngetmessage(i18nhandle,"shipment_number","Shipment Number:")
 SET captions->ordered = uar_i18ngetmessage(i18nhandle,"ordered","Ordered:")
 SET captions->order_placed_by = uar_i18ngetmessage(i18nhandle,"order_placed_by","Order Placed By:")
 SET captions->needed = uar_i18ngetmessage(i18nhandle,"needed","Needed:")
 SET captions->courier = uar_i18ngetmessage(i18nhandle,"courier","Courier:")
 SET captions->actual = uar_i18ngetmessage(i18nhandle,"actual","Actual:")
 SET captions->container_number = uar_i18ngetmessage(i18nhandle,"container_number",
  "Container Number:")
 SET captions->type = uar_i18ngetmessage(i18nhandle,"type","Type:")
 SET captions->condition = uar_i18ngetmessage(i18nhandle,"condition","Condition:")
 SET captions->weight = uar_i18ngetmessage(i18nhandle,"weight","Weight:")
 SET captions->prod_number = uar_i18ngetmessage(i18nhandle,"prod_number","Product Number")
 SET captions->abo_rh = uar_i18ngetmessage(i18nhandle,"abo_rh","ABO/Rh")
 SET captions->formatted_type = uar_i18ngetmessage(i18nhandle,"formatted_type","Type")
 SET captions->expiration_date = uar_i18ngetmessage(i18nhandle,"expiration_date","Expiration")
 SET captions->volume = uar_i18ngetmessage(i18nhandle,"volume","Volume")
 SET captions->assigned_to = uar_i18ngetmessage(i18nhandle,"assigned_to","Assigned To:")
 SET captions->notes = uar_i18ngetmessage(i18nhandle,"notes","Notes:")
 SET captions->packed_inspected_by = uar_i18ngetmessage(i18nhandle,"packed_inspected_by",
  "Packed and inspected by: _______________________________________  Date: _________________")
 SET captions->printed_by = uar_i18ngetmessage(i18nhandle,"printed_by","Printed By:")
 SET captions->temperature = uar_i18ngetmessage(i18nhandle,"temperature","Temperature:")
 SET captions->antigens = uar_i18ngetmessage(i18nhandle,"antigens","Antigens")
 SET captions->visual_inspection = uar_i18ngetmessage(i18nhandle,"visual_inspection","Visual Inspect"
  )
 SET captions->order_priority = uar_i18ngetmessage(i18nhandle,"order_priority","Order Priority:")
 SET captions->ship_from = uar_i18ngetmessage(i18nhandle,"ship_from","Ship From:")
 SET captions->recipients = uar_i18ngetmessage(i18nhandle,"recipients","Recipient(s)")
 DECLARE sbbinvarea = c9 WITH protect, constant("BBINVAREA")
 DECLARE sbbownerroot = c11 WITH protect, constant("BBOWNERROOT")
 DECLARE address_loc_cdf = c12 WITH protect, noconstant("")
 DECLARE num_locations = i4 WITH protect, noconstant(0)
 SET line = fillstring(130,"_")
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
 SET sfilename = build("cer_temp:bbpck_",sfiledate,sfiletime,".txt")
 SET code_set = 0
 SET code_cnt = 0
 SET cdf_mean = fillstring(12," ")
 SET assign_cd = 0.0
 SET address_type_cd = 0.0
 SET failed = "F"
 SET cur_username = fillstring(10," ")
 SET hold_product = 0.0
 SET cur_username = get_username(reqinfo->updt_id)
 SET code_set = 1610
 SET cdf_mean = "1"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,assign_cd)
 SET code_set = 212
 SET cdf_mean = fillstring(12," ")
 SET cdf_mean = "SHIPTO"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_mean,code_cnt,address_type_cd)
 IF (((assign_cd=0.0) OR (address_type_cd=0.0)) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_rpt_packing_list.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (assign_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the assign event type code value."
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the ship to address type code value."
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET address_loc_cdf = uar_get_code_meaning(request->address_location_cd)
 IF (trim(address_loc_cdf)=trim(sbbinvarea))
  SET stat = alterlist(ship_from_locs->qual,1)
  SET num_locations = 1
  SELECT INTO "nl:"
   FROM location_group lg
   WHERE (lg.child_loc_cd=request->address_location_cd)
   DETAIL
    owner_area_disp = uar_get_code_display(lg.parent_loc_cd), inv_area_disp = uar_get_code_display(
     request->address_location_cd), ship_from_locs->qual[1].ship_from_loc_disp = concat(trim(
      owner_area_disp)," -> ",trim(inv_area_disp))
   WITH nocounter
  ;end select
 ELSEIF (trim(address_loc_cdf)=trim(sbbownerroot))
  SELECT INTO "nl:"
   FROM location_group lg
   WHERE (lg.parent_loc_cd=request->address_location_cd)
   HEAD REPORT
    num_locations = 0
   DETAIL
    num_locations = (num_locations+ 1)
    IF (mod(num_locations,10)=1)
     stat = alterlist(ship_from_locs->qual,(num_locations+ 9))
    ENDIF
    owner_area_disp = uar_get_code_display(request->address_location_cd), inv_area_disp =
    uar_get_code_display(lg.child_loc_cd), ship_from_locs->qual[num_locations].ship_from_loc_disp =
    concat(trim(owner_area_disp)," -> ",trim(inv_area_disp))
   FOOT REPORT
    stat = alterlist(ship_from_locs->qual,num_locations)
   WITH nocounter
  ;end select
 ELSE
  SET num_locations = 1
  SET stat = alterlist(ship_from_locs->qual,1)
  SET ship_from_locs->qual[1].ship_from_loc_disp = uar_get_code_display(request->address_location_cd)
 ENDIF
 SELECT INTO value(sfilename)
  add_ind = evaluate(nullind(a.address_id),0,1,0), bp_ind = evaluate(nullind(bp.product_id),0,1,0),
  asg_ind = evaluate(nullind(per.person_id),0,1,0),
  st_ind = evaluate(nullind(st.special_testing_cd),0,1,0), c.container_id, s.shipment_nbr,
  s.shipment_dt_tm, s.needed_dt_tm, courier = uar_get_code_display(s.courier_cd),
  order_priority_disp = uar_get_code_display(s.order_priority_cd), order_placed_by = substring(1,40,s
   .order_placed_by), s.order_dt_tm,
  owner_area = uar_get_code_display(s.owner_area_cd), inventory_area = uar_get_code_display(s
   .inventory_area_cd), notes_display = substring(1,120,l.long_text),
  o.org_name, c.container_nbr, container_type = substring(1,16,uar_get_code_display(c
    .container_type_cd)),
  container_condition = substring(1,18,uar_get_code_display(c.container_condition_cd)), c
  .total_weight, unit_of_measure = substring(1,5,uar_get_code_display(c.unit_of_meas_cd)),
  visual_inspection = substring(1,13,uar_get_code_display(e.vis_insp_cd)), p.product_nbr,
  product_type = substring(1,20,uar_get_code_display(p.product_cd)),
  volume_unit_of_measure = substring(1,5,uar_get_code_display(p.cur_unit_meas_cd)), p
  .cur_expire_dt_tm, ad_person_name = substring(1,20,trim(ad_per.name_full_formatted)),
  abo_display = uar_get_code_display(bp.cur_abo_cd), rh_display = uar_get_code_display(bp.cur_rh_cd),
  bp.cur_volume,
  display_name = substring(1,15,per.name_full_formatted), address1 = substring(1,30,a.street_addr),
  address2 = substring(1,30,a.street_addr2),
  address3 = substring(1,30,a.street_addr3), address4 = substring(1,30,a.street_addr4), city =
  substring(1,35,a.city),
  state = substring(1,2,uar_get_code_display(a.state_cd)), zip = substring(1,14,a.zipcode),
  antigen_disp = substring(1,10,uar_get_code_display(st.special_testing_cd))
  FROM bb_shipment s,
   long_text l,
   organization o,
   address a,
   bb_ship_container c,
   bb_ship_event e,
   product p,
   auto_directed ad,
   person ad_per,
   blood_product bp,
   product_event pe,
   assign asg,
   person per,
   special_testing st
  PLAN (s
   WHERE (s.shipment_id=request->shipment_id))
   JOIN (l
   WHERE l.long_text_id=s.long_text_id)
   JOIN (o
   WHERE o.organization_id=s.organization_id)
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(o.organization_id)
    AND a.parent_entity_name=outerjoin("ORGANIZATION")
    AND a.address_type_cd=outerjoin(address_type_cd)
    AND a.active_ind=outerjoin(1))
   JOIN (c
   WHERE c.shipment_id=s.shipment_id
    AND c.active_ind=1)
   JOIN (e
   WHERE e.container_id=c.container_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.product_id=e.product_id)
   JOIN (ad
   WHERE ad.product_id=outerjoin(p.product_id)
    AND ad.active_ind=outerjoin(1))
   JOIN (ad_per
   WHERE ad_per.person_id=outerjoin(ad.person_id))
   JOIN (st
   WHERE st.product_id=outerjoin(p.product_id))
   JOIN (pe
   WHERE pe.product_id=outerjoin(p.product_id)
    AND pe.event_type_cd=outerjoin(assign_cd)
    AND pe.active_ind=outerjoin(1))
   JOIN (asg
   WHERE asg.product_event_id=outerjoin(pe.product_event_id)
    AND asg.active_ind=outerjoin(1))
   JOIN (per
   WHERE per.person_id=outerjoin(asg.person_id))
   JOIN (bp
   WHERE bp.product_id=outerjoin(p.product_id)
    AND bp.active_ind=outerjoin(1))
  ORDER BY c.container_nbr, c.container_id, p.product_id,
   antigen_disp
  HEAD REPORT
   row + 0
  HEAD c.container_nbr
   row + 0
  HEAD c.container_id
   col 86, captions->rpt_title, row + 1,
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1, col 104,
   captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
   row + 1, col 1, line,
   row + 1, col 1, captions->ship_to,
   org_display = fillstring(100," ")
   IF (s.organization_id=0.0)
    org_display = concat(trim(owner_area)," -> ",trim(inventory_area))
   ELSE
    org_display = trim(o.org_name)
   ENDIF
   col 11, org_display, col 70,
   captions->ship_from
   IF (s.organization_id > 0.0)
    col 82, sub_get_location_name, hold_row = row
    IF (sub_get_location_address1 > " ")
     row + 1, sub_address1_display = substring(1,30,sub_get_location_address1), col 82,
     sub_address1_display
    ENDIF
    IF (sub_get_location_address2 > " ")
     row + 1, sub_address2_display = substring(1,30,sub_get_location_address2), col 82,
     sub_address2_display
    ENDIF
    IF (sub_get_location_address3 > " ")
     row + 1, sub_address3_display = substring(1,30,sub_get_location_address3), col 82,
     sub_address3_display
    ENDIF
    IF (sub_get_location_address4 > " ")
     row + 1, sub_address4_display = substring(1,30,sub_get_location_address4), col 82,
     sub_address4_display
    ENDIF
    IF (sub_get_location_citystatezip > " ")
     row + 1, sub_citystatezip_display = substring(1,40,sub_get_location_citystatezip), col 82,
     sub_citystatezip_display
    ENDIF
    max_row = row, row hold_row
   ELSE
    FOR (i = 1 TO num_locations)
      sub_loc_name = substring(1,40,ship_from_locs->qual[i].ship_from_loc_disp), col 82, sub_loc_name,
      row + 1
    ENDFOR
    row- (1), max_row = row, row hold_row
   ENDIF
   IF (add_ind=1)
    IF (address1 > " ")
     row + 1, address_display = trim(address1), col 11,
     address_display
    ENDIF
    IF (address2 > " ")
     row + 1, address2_display = trim(address2), col 11,
     address2_display
    ENDIF
    IF (address3 > " ")
     row + 1, address3_display = trim(address3), col 11,
     address3_display
    ENDIF
    IF (address4 > " ")
     row + 1, address4_display = trim(address4), col 11,
     address4_display
    ENDIF
    IF (city > " ")
     row + 1, city_state_zip = concat(trim(city),", ",trim(state),"  ",trim(zip)), col 11,
     city_state_zip
    ENDIF
   ENDIF
   IF (row < max_row)
    row max_row
   ENDIF
   row + 2, col 1, captions->shipment_number,
   shipment_nbr_display = trim(cnvtstring(s.shipment_nbr),3), col 18, shipment_nbr_display,
   col 70, captions->order_priority, col 88,
   order_priority_disp, row + 1, col 1,
   captions->ordered, col 18, s.order_dt_tm"@DATETIMECONDENSED;;d",
   col 70, captions->order_placed_by, col 88,
   order_placed_by, row + 1, col 1,
   captions->needed, col 18, s.needed_dt_tm"@DATETIMECONDENSED;;d",
   col 70, captions->courier, courier_display = trim(courier),
   col 88, courier_display, row + 1,
   col 1, captions->actual, col 18,
   s.shipment_dt_tm"@DATETIMECONDENSED;;d", row + 1, col 1,
   line, row + 1, col 1,
   captions->container_number, col 19, c.container_nbr"###",
   col 27, captions->type, col 33,
   container_type, col 51, captions->condition,
   col 62, container_condition, col 82,
   captions->temperature, temp_meas_disp = uar_get_code_display(c.temperature_degree_cd),
   temp_display = uar_i18nbuildmessage(i18nhandle,"TEMP","%1 %2","ds",c.temperature_value,
    nullterm(temp_meas_disp)),
   sub_temp_display = substring(1,15,temp_display), col 95, sub_temp_display,
   col 111, captions->weight, col 120
   IF (c.total_weight > 0)
    c.total_weight"###"
   ELSE
    "(none)"
   ENDIF
   col 124
   IF (c.total_weight > 0)
    unit_of_measure
   ENDIF
   row + 1, col 1, line,
   row + 2, col 1, captions->prod_number,
   col 28, captions->abo_rh, col 45,
   captions->formatted_type, col 72, captions->expiration_date,
   col 87, captions->volume, col 99,
   captions->visual_inspection, col 116, captions->antigens,
   row + 1, col 48, captions->recipients,
   row + 1, col 1, "-------------------------",
   col 28, "---------------", col 45,
   "-------------------------", col 72, "-------------",
   col 87, "----------", col 99,
   "---------------", col 116, "----------",
   row + 1
  HEAD p.product_id
   product_display = fillstring(20," "), product_display = concat(trim(bp.supplier_prefix),trim(p
     .product_nbr)," ",trim(p.product_sub_nbr)), col 1,
   product_display, aborh_display = substring(1,15,concat(trim(abo_display)," ",trim(rh_display))),
   col 28,
   aborh_display, col 45, product_type,
   col 72, p.cur_expire_dt_tm"@DATETIMECONDENSED;;d", col 87,
   bp.cur_volume"###", col 91, volume_unit_of_measure,
   col 99, visual_inspection, product_data->ad_person_cnt = 0,
   stat = alterlist(product_data->ad_persons,0), ad_person_idx = 0, product_data->antigen_cnt = 0,
   stat = alterlist(product_data->antigens,0), antigen_idx = 0, max_list_size = 0
  DETAIL
   IF (ad.person_id > 0)
    IF ((product_data->ad_person_cnt=0))
     product_data->ad_person_cnt = 1, stat = alterlist(product_data->ad_persons,1), product_data->
     ad_persons[1].ad_person = ad_person_name
    ELSE
     IF (locateval(ad_person_idx,1,product_data->ad_person_cnt,ad_person_name,product_data->
      ad_persons[ad_person_idx].ad_person) < 1)
      product_data->ad_person_cnt = (product_data->ad_person_cnt+ 1), stat = alterlist(product_data->
       ad_persons,product_data->ad_person_cnt), product_data->ad_persons[product_data->ad_person_cnt]
      .ad_person = ad_person_name
     ENDIF
    ENDIF
   ENDIF
   IF (st.special_testing_id > 0)
    antigen_disp_trimmed = nullterm(antigen_disp)
    IF ((product_data->antigen_cnt=0))
     product_data->antigen_cnt = 1, stat = alterlist(product_data->antigens,1), product_data->
     antigens[1].antigen_disp = antigen_disp_trimmed
    ELSE
     IF (locateval(antigen_idx,1,product_data->antigen_cnt,antigen_disp_trimmed,product_data->
      antigens[antigen_idx].antigen_disp) < 1)
      product_data->antigen_cnt = (product_data->antigen_cnt+ 1), stat = alterlist(product_data->
       antigens,product_data->antigen_cnt), product_data->antigens[product_data->antigen_cnt].
      antigen_disp = antigen_disp_trimmed
     ENDIF
    ENDIF
   ENDIF
  FOOT  p.product_id
   IF ((product_data->ad_person_cnt > product_data->antigen_cnt))
    max_list_size = product_data->ad_person_cnt
   ELSE
    max_list_size = product_data->antigen_cnt
   ENDIF
   FOR (ad_person_idx = 1 TO max_list_size)
     IF ((ad_person_idx <= product_data->antigen_cnt))
      col 116, product_data->antigens[ad_person_idx].antigen_disp
     ENDIF
     IF (row > 44)
      BREAK
     ELSE
      row + 1
     ENDIF
     IF ((ad_person_idx <= product_data->ad_person_cnt))
      col 48, product_data->ad_persons[ad_person_idx].ad_person
     ENDIF
   ENDFOR
   IF (asg_ind=1)
    row + 1, col 5, captions->assigned_to,
    col 18, display_name
   ENDIF
   row + 1
  FOOT  c.container_id
   row 53, col 1, captions->notes,
   col 9
   IF (notes_display != "0")
    notes_display
   ENDIF
   row 57, col 1, line,
   row + 2, col 1, captions->packed_inspected_by,
   col 100, captions->printed_by, col 114,
   cur_username, BREAK
  FOOT  c.container_nbr
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter, compress, nolandscape,
   maxrow = 61
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ELSE
  SET stat = alterlist(reply->report_name_list,1)
  SET reply->report_name_list[1].report_name = sfilename
 ENDIF
#exit_script
 FREE SET captions
 FREE SET ship_from_locs
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
