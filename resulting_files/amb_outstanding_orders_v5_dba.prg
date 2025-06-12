CREATE PROGRAM amb_outstanding_orders_v5:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Location" = 0,
  "Provider" = 0,
  "Orders Prompt" = 0,
  "Run in spreadsheet format" = 1,
  "Future Order Status" = 0
  WITH outdev, ordered_from, ordered_to,
  org_prompt, provider_prompt, meds,
  excel_prompt, future_order_status
 DECLARE organization_name = vc WITH public
 DECLARE notdocumented = vc WITH public, constant("--")
 SET line = fillstring(130,"*")
 DECLARE who_running = f8
 DECLARE who_running_name = vc
 DECLARE display_date = vc
 DECLARE emrn = f8 WITH public, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE pmrn = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE encntr_fin_alias_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE prov_number = f8
 DECLARE home_address_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE home_phone_cd = f8 WITH constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE us_ph_format = f8 WITH constant(uar_get_code_by("MEANING",281,"US"))
 DECLARE orderedcd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE did_we_print = vc
 SET did_we_print = "N"
 DECLARE report_name = vc WITH protect, constant("Outstanding Orders Report")
 DECLARE org_id_from_prompt = f8 WITH protect
 FREE RECORD loc_rec
 RECORD loc_rec(
   1 loc_cnt = i4
   1 loc_list[*]
     2 loc_cd = f8
     2 loc_name = vc
 )
 DECLARE location_name = vc WITH protect
 DECLARE loc_ctr = i4
 SELECT INTO "nl:"
  FROM organization org,
   location l
  PLAN (org
   WHERE (org.organization_id= $ORG_PROMPT)
    AND org.active_ind=1)
   JOIN (l
   WHERE l.organization_id=org.organization_id)
  ORDER BY org.org_name
  HEAD REPORT
   location_name = org.org_name, stat = alterlist(loc_rec->loc_list,10)
  DETAIL
   loc_ctr = (loc_ctr+ 1)
   IF (mod(loc_ctr,10)=1)
    stat = alterlist(loc_rec->loc_list,(loc_ctr+ 9))
   ENDIF
   loc_rec->loc_list[loc_ctr].loc_cd = l.location_cd, loc_rec->loc_list[loc_ctr].loc_name =
   uar_get_code_display(l.location_cd)
  FOOT REPORT
   stat = alterlist(loc_rec->loc_list,loc_ctr), loc_rec->loc_cnt = loc_ctr
  WITH nocounter
 ;end select
 DECLARE future_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE")), protect
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")), protect
 DECLARE pname_max = i4 WITH protect, noconstant(0)
 DECLARE prname_max = i4 WITH protect, noconstant(0)
 DECLARE pr2name_max = i4 WITH protect, noconstant(0)
 DECLARE ordname_max = i4 WITH protect, noconstant(0)
 DECLARE ordtype_max = i4 WITH protect, noconstant(0)
 DECLARE orddet_max = i4 WITH protect, noconstant(0)
 DECLARE addr_max = i4 WITH protect, noconstant(0)
 SET display_start =  $ORDERED_FROM
 SET display_end =  $ORDERED_TO
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   who_running = p.person_id, who_running_name = p.name_full_formatted
  WITH nocounter
 ;end select
 DECLARE prov_parser = vc WITH public, noconstant("")
 DECLARE prov_num = i4 WITH public, constant(5)
 IF (substring(1,1,reflect(parameter(prov_num,0))) != "C")
  DECLARE prov_parser_val = f8
  SET prov_parser_val =  $PROVIDER_PROMPT
  SET prov_parser = concat("pr1.person_id=",cnvtstring( $PROVIDER_PROMPT),
   " and pr1.person_id=oa.order_provider_id")
 ELSE
  SET prov_parser = "pr1.person_id=oa.order_provider_id"
 ENDIF
 DECLARE catparser = vc WITH public, noconstant("")
 IF (( $MEDS=1))
  SET catparser = "o.catalog_type_cd != PHARMACY and o.order_status_cd in (ORDERED_CD,FUTURE_CD)"
 ELSEIF (( $MEDS=2))
  SET catparser =
  "o.catalog_type_cd > 0 and o.orig_ord_as_flag not in (1,2) and o.order_status_cd in (ORDERED_CD,FUTURE_CD)"
 ELSEIF (( $MEDS=3))
  SET catparser =
  "o.catalog_type_cd = PHARMACY and o.orig_ord_as_flag not in (1,2) and o.order_status_cd in (ORDERED_CD,FUTURE_CD)"
 ELSEIF (( $MEDS=4))
  SET catparser = "o.order_status_cd in (FUTURE_CD)"
 ENDIF
 FREE RECORD prsnl_rec
 RECORD prsnl_rec(
   1 list[*]
     2 prsnl_id = f8
 )
 FREE RECORD qual
 RECORD qual(
   1 qual_cnt = i4
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 dob = vc
     2 age = vc
     2 gender = vc
     2 mrn = vc
     2 fin = vc
     2 home_address = vc
     2 home_phone = vc
     2 ord_type = vc
     2 ord_name = vc
     2 orig_date = vc
     2 ord_prov = vc
     2 ord_by = vc
     2 ord_det = vc
     2 ord_status = vc
     2 order_id = f8
     2 future_date = dq8
     2 grace = vc
     2 future_order_status = vc
     2 future_order_status_id = f8
 )
 FREE RECORD qual_dup
 RECORD qual_dup(
   1 qual_cnt = i4
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 dob = vc
     2 age = vc
     2 gender = vc
     2 mrn = vc
     2 fin = vc
     2 home_address = vc
     2 home_phone = vc
     2 ord_type = vc
     2 ord_name = vc
     2 orig_date = vc
     2 ord_prov = vc
     2 ord_by = vc
     2 ord_det = vc
     2 ord_status = vc
     2 order_id = f8
     2 future_date = dq8
     2 grace = vc
     2 future_order_status = vc
     2 future_order_status_id = f8
 )
 FREE RECORD order_detail_info
 RECORD order_detail_info(
   1 cnt = i4
   1 list[*]
     2 order_id = f8
     2 date = dq8
     2 date_string = vc
     2 num = i4
     2 unit = vc
 )
 FREE RECORD future_order_info
 RECORD future_order_info(
   1 cnt = i4
   1 list[*]
     2 order_id = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 status = vc
     2 status_id = f8
 )
 DECLARE prsnl_itr = i4
 SELECT INTO "nl:"
  FROM prsnl_org_reltn por,
   prsnl p
  PLAN (por
   WHERE (por.organization_id= $ORG_PROMPT)
    AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=por.person_id
    AND  NOT ((p.position_cd=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=88
     AND cdf_meaning="DBA")))
    AND p.username > " "
    AND p.active_ind=1
    AND p.physician_ind=1)
  ORDER BY p.person_id
  HEAD REPORT
   prsnl_itr = 0, stat = alterlist(prsnl_rec->list,10)
  DETAIL
   prsnl_itr = (prsnl_itr+ 1)
   IF (mod(prsnl_itr,10)=1)
    stat = alterlist(prsnl_rec->list,(prsnl_itr+ 9))
   ENDIF
   prsnl_rec->list[prsnl_itr].prsnl_id = p.person_id
  FOOT REPORT
   stat = alterlist(prsnl_rec->list,prsnl_itr)
  WITH nocounter
 ;end select
 DECLARE facility_pos = i4 WITH public
 DECLARE nu_pos = i4 WITH public
 DECLARE future_facility_pos = i4 WITH public
 DECLARE future_nu_pos = i4 WITH public
 DECLARE pos_itr = i4 WITH public
 SELECT INTO "nl:"
  provider_name = pr1.name_full_formatted, patient_name = substring(1,40,p.name_full_formatted),
  ord_as_mn = substring(1,40,o.ordered_as_mnemonic),
  ord_start = format(o.orig_order_dt_tm,"MM/DD/YYYY;;d")
  FROM orders o,
   order_action oa,
   prsnl pr1,
   prsnl pr2,
   encounter e,
   person p,
   person_alias pa,
   encntr_alias ea1,
   address a,
   phone ph
  PLAN (o
   WHERE o.order_status_cd IN (ordered_cd, future_cd)
    AND o.template_order_flag=0
    AND parser(catparser)
    AND o.orig_order_dt_tm >= cnvtdatetime(cnvtdate2( $ORDERED_FROM,"MM/DD/YYYY"),0)
    AND o.orig_order_dt_tm <= cnvtdatetime(cnvtdate2( $ORDERED_TO,"MM/DD/YYYY"),235959)
    AND o.orderable_type_flag != 6)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (pr1
   WHERE parser(prov_parser)
    AND expand(prsnl_itr,1,size(prsnl_rec->list,5),pr1.person_id,prsnl_rec->list[prsnl_itr].prsnl_id)
   )
   JOIN (pr2
   WHERE pr2.person_id=oa.action_personnel_id)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=outerjoin(o.encntr_id))
   JOIN (pa
   WHERE pa.person_id=outerjoin(o.person_id)
    AND pa.person_alias_type_cd=outerjoin(pmrn)
    AND pa.active_ind=outerjoin(1)
    AND pa.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(value(uar_get_code_by("MEANING",319,"FIN NBR")))
    AND ea1.active_ind=outerjoin(1)
    AND ea1.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND trim(a.parent_entity_name)=outerjoin("PERSON")
    AND a.address_type_cd=outerjoin(value(uar_get_code_by("MEANING",212,"HOME")))
    AND a.address_type_seq=outerjoin(1)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.active_ind=outerjoin(1))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND trim(ph.parent_entity_name)=outerjoin("PERSON")
    AND ph.phone_type_cd=outerjoin(value(uar_get_code_by("MEANING",43,"HOME")))
    AND ph.phone_type_seq=outerjoin(1)
    AND ph.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ph.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ph.active_ind=outerjoin(1))
  ORDER BY ord_start DESC, ord_as_mn
  HEAD REPORT
   qual->qual_cnt = 0
  DETAIL
   IF (( $MEDS=1)
    AND o.catalog_type_cd=pharmacy)
    null
   ELSE
    facility_pos = locateval(pos_itr,1,loc_rec->loc_cnt,e.loc_facility_cd,loc_rec->loc_list[pos_itr].
     loc_cd), nu_pos = locateval(pos_itr,1,loc_rec->loc_cnt,e.loc_nurse_unit_cd,loc_rec->loc_list[
     pos_itr].loc_cd), future_facility_pos = locateval(pos_itr,1,loc_rec->loc_cnt,o
     .future_location_facility_cd,loc_rec->loc_list[pos_itr].loc_cd),
    future_nu_pos = locateval(pos_itr,1,loc_rec->loc_cnt,o.future_location_nurse_unit_cd,loc_rec->
     loc_list[pos_itr].loc_cd)
    IF (((facility_pos > 0) OR (((nu_pos > 0) OR (((future_facility_pos > 0) OR (future_nu_pos > 0))
    )) )) )
     qual->qual_cnt = (qual->qual_cnt+ 1)
     IF (mod(qual->qual_cnt,1000)=1)
      stat = alterlist(qual->qual,(qual->qual_cnt+ 999))
     ENDIF
     IF ((qual->qual_cnt=1))
      qual->qual[qual->qual_cnt].name = "Patient_Name", qual->qual[qual->qual_cnt].dob =
      "Date_of_Birth", qual->qual[qual->qual_cnt].age = "Age",
      qual->qual[qual->qual_cnt].gender = "Gender", qual->qual[qual->qual_cnt].mrn = "MRN", qual->
      qual[qual->qual_cnt].fin = "FIN",
      qual->qual[qual->qual_cnt].home_phone = "Home_Phone", qual->qual[qual->qual_cnt].home_address
       = "Home_Address", qual->qual[qual->qual_cnt].ord_type = "Type",
      qual->qual[qual->qual_cnt].ord_name = "Order_Name", qual->qual[qual->qual_cnt].orig_date =
      "Order_Date", qual->qual[qual->qual_cnt].ord_prov = "Ordering_Provider",
      qual->qual[qual->qual_cnt].ord_by = "Ordered_By", qual->qual[qual->qual_cnt].ord_det =
      "Order_Details", qual->qual[qual->qual_cnt].ord_status = "Status",
      qual->qual[qual->qual_cnt].future_order_status = "Future_Order_Status", qual->qual[qual->
      qual_cnt].grace = "Future_Date_Range", pname_max = cnvtint(textlen(trim(qual->qual[qual->
         qual_cnt].name))),
      addr_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].home_address))), ordname_max =
      cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_name))), prname_max = cnvtint(textlen(trim(
         qual->qual[qual->qual_cnt].ord_prov))),
      pr2name_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_by))), orddet_max = cnvtint(
       textlen(trim(qual->qual[qual->qual_cnt].ord_det))), qual->qual_cnt = (qual->qual_cnt+ 1)
     ENDIF
     qual->qual[qual->qual_cnt].name = notdocumented, qual->qual[qual->qual_cnt].dob = notdocumented,
     qual->qual[qual->qual_cnt].age = notdocumented,
     qual->qual[qual->qual_cnt].home_phone = notdocumented, qual->qual[qual->qual_cnt].home_address
      = notdocumented, qual->qual[qual->qual_cnt].ord_type = notdocumented,
     qual->qual[qual->qual_cnt].ord_name = notdocumented, qual->qual[qual->qual_cnt].orig_date =
     notdocumented, qual->qual[qual->qual_cnt].ord_prov = notdocumented,
     qual->qual[qual->qual_cnt].ord_by = notdocumented, qual->qual[qual->qual_cnt].ord_status =
     notdocumented, qual->qual[qual->qual_cnt].future_order_status = notdocumented,
     qual->qual[qual->qual_cnt].grace = notdocumented, qual->qual[qual->qual_cnt].person_id = o
     .person_id, qual->qual[qual->qual_cnt].encntr_id = o.encntr_id,
     qual->qual[qual->qual_cnt].name = trim(p.name_full_formatted)
     IF (pname_max < cnvtint(textlen(trim(qual->qual[qual->qual_cnt].name))))
      pname_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].name)))
     ENDIF
     qual->qual[qual->qual_cnt].dob = datetimezoneformat(p.birth_dt_tm,p.birth_tz,"MM/DD/YYYY"), qual
     ->qual[qual->qual_cnt].age = trim(substring(1,12,cnvtage(cnvtdate(p.birth_dt_tm),curdate)),3),
     qual->qual[qual->qual_cnt].gender = uar_get_code_display(p.sex_cd)
     IF ((qual->qual[qual->qual_cnt].gender=null))
      qual->qual[qual->qual_cnt].gender = notdocumented
     ENDIF
     qual->qual[qual->qual_cnt].mrn = substring(1,16,cnvtalias(pa.alias,pa.alias_pool_cd))
     IF ((qual->qual[qual->qual_cnt].mrn=null))
      qual->qual[qual->qual_cnt].mrn = notdocumented
     ENDIF
     qual->qual[qual->qual_cnt].fin = substring(1,16,cnvtalias(ea1.alias,ea1.alias_pool_cd))
     IF ((qual->qual[qual->qual_cnt].fin=null))
      qual->qual[qual->qual_cnt].fin = notdocumented
     ENDIF
     IF (ph.phone_type_cd=home_phone_cd)
      IF (ph.phone_format_cd=0.0)
       qual->qual[qual->qual_cnt].home_phone = cnvtphone(ph.phone_num_key,us_ph_format)
      ELSE
       qual->qual[qual->qual_cnt].home_phone = cnvtphone(ph.phone_num_key,ph.phone_format_cd)
      ENDIF
     ENDIF
     IF (a.street_addr > " ")
      qual->qual[qual->qual_cnt].home_address = trim(a.street_addr)
      IF (a.street_addr2 > " ")
       qual->qual[qual->qual_cnt].home_address = concat(trim(qual->qual[qual->qual_cnt].home_address),
        " ",trim(a.street_addr2))
      ENDIF
      IF (a.state_cd > 0.0)
       qual->qual[qual->qual_cnt].home_address = concat(qual->qual[qual->qual_cnt].home_address," ",
        trim(a.city),", ",trim(uar_get_code_display(a.state_cd)),
        " ",trim(a.zipcode))
      ELSE
       qual->qual[qual->qual_cnt].home_address = concat(qual->qual[qual->qual_cnt].home_address," ",
        trim(a.city),", ",trim(a.state),
        " ",trim(a.zipcode))
      ENDIF
      IF (addr_max < cnvtint(textlen(trim(qual->qual[qual->qual_cnt].home_address))))
       addr_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].home_address)))
      ENDIF
     ENDIF
     qual->qual[qual->qual_cnt].ord_type = trim(uar_get_code_display(o.activity_type_cd))
     IF (ordtype_max < cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_type))))
      ordtype_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_type)))
     ENDIF
     qual->qual[qual->qual_cnt].ord_name = trim(o.order_mnemonic)
     IF (ordname_max < cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_name))))
      ordname_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_name)))
     ENDIF
     qual->qual[qual->qual_cnt].orig_date = format(o.orig_order_dt_tm,"MM/DD/YYYY;;d"), qual->qual[
     qual->qual_cnt].ord_prov = trim(pr1.name_full_formatted)
     IF (prname_max < cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_prov))))
      prname_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_prov)))
     ENDIF
     qual->qual[qual->qual_cnt].ord_by = trim(pr2.name_full_formatted)
     IF (pr2name_max < cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_by))))
      pr2name_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_by)))
     ENDIF
     qual->qual[qual->qual_cnt].ord_det = trim(o.order_detail_display_line)
     IF (orddet_max < cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_det))))
      orddet_max = cnvtint(textlen(trim(qual->qual[qual->qual_cnt].ord_det)))
     ENDIF
     IF ((qual->qual[qual->qual_cnt].ord_det=null))
      qual->qual[qual->qual_cnt].ord_det = notdocumented
     ENDIF
     qual->qual[qual->qual_cnt].ord_status = trim(uar_get_code_display(o.order_status_cd)), qual->
     qual[qual->qual_cnt].order_id = o.order_id
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(qual->qual,qual->qual_cnt)
  WITH expand = 1, nocounter
 ;end select
 DECLARE itr = i4 WITH protect
 DECLARE ctr = i4 WITH protect
 DECLARE ctr1 = i4 WITH protect
 DECLARE ctr2 = i4 WITH protect
 DECLARE ctr3 = i4 WITH protect
 DECLARE temp_dt_tm = dq8 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE num_of_days = i4 WITH protect
 DECLARE num_of_days_neg = i4 WITH protect
 SELECT INTO "nl:"
  FROM order_detail od
  WHERE expand(itr,1,qual->qual_cnt,od.order_id,qual->qual[itr].order_id)
   AND od.oe_field_meaning IN ("FORDGRACENBR", "REQSTARTDTTM", "FORDGRACEUNIT")
  ORDER BY od.order_id
  HEAD REPORT
   ctr = 0, stat = alterlist(order_detail_info->list,10)
  HEAD od.order_id
   ctr = (ctr+ 1)
   IF (mod(ctr,10)=1)
    stat = alterlist(order_detail_info->list,(ctr+ 9))
   ENDIF
   order_detail_info->list[ctr].order_id = od.order_id
  HEAD od.oe_field_id
   IF (od.oe_field_meaning="REQSTARTDTTM")
    order_detail_info->list[ctr].date = od.oe_field_dt_tm_value, order_detail_info->list[ctr].
    date_string = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="FORDGRACENBR")
    order_detail_info->list[ctr].num = cnvtint(od.oe_field_display_value)
   ENDIF
   IF (od.oe_field_meaning="FORDGRACEUNIT")
    order_detail_info->list[ctr].unit = od.oe_field_display_value
   ENDIF
  FOOT REPORT
   stat = alterlist(order_detail_info->list,ctr), order_detail_info->cnt = ctr
   FOR (ctr1 = 1 TO order_detail_info->cnt)
    pos = locateval(itr,1,qual->qual_cnt,order_detail_info->list[ctr1].order_id,qual->qual[itr].
     order_id),
    IF (pos > 0)
     num_of_days = order_detail_info->list[ctr1].num, num_of_days_neg = - ((1 * num_of_days))
     IF ((qual->qual[pos].ord_status="Future"))
      qual->qual[pos].grace = build(format(datetimeadd(order_detail_info->list[ctr1].date,
         num_of_days_neg),";;D"),"-",format(datetimeadd(order_detail_info->list[ctr1].date,
         num_of_days),";;D"))
     ELSE
      qual->qual[pos].grace = notdocumented
     ENDIF
    ENDIF
   ENDFOR
  WITH expand = 1, nocounter
 ;end select
 CALL echorecord(order_detail_info)
 DECLARE ofi_date_parser = vc
 DECLARE ofi_status = vc
 DECLARE ofi_status_id = f8
 DECLARE future_ord_num = i4 WITH public, constant(8)
 DECLARE temp_parser_upcoming = vc
 SET temp_parser_upcoming =
 " (ofi.begin_due_dt_tm >= cnvtdatetime(curdate,235959)) and (ofi.end_due_dt_tm > cnvtdatetime(curdate,0)) "
 DECLARE temp_parser_due = vc
 SET temp_parser_due =
 " (ofi.begin_due_dt_tm <= cnvtdatetime(curdate,235959)) and (ofi.end_due_dt_tm > cnvtdatetime(curdate,0)) "
 DECLARE temp_parser_overdue = vc
 SET temp_parser_overdue =
 " (ofi.begin_due_dt_tm < cnvtdatetime(curdate,235959)) and (ofi.end_due_dt_tm <= cnvtdatetime(curdate,0)) "
 IF (substring(1,1,reflect(parameter(future_ord_num,0))) != "L")
  IF (( $FUTURE_ORDER_STATUS=1))
   SET ofi_date_parser = temp_parser_upcoming
   SET ofi_status = "Upcoming"
   SET ofi_status_id =  $FUTURE_ORDER_STATUS
  ELSEIF (( $FUTURE_ORDER_STATUS=2))
   SET ofi_date_parser = temp_parser_due
   SET ofi_status = "Due"
   SET ofi_status_id =  $FUTURE_ORDER_STATUS
  ELSEIF (( $FUTURE_ORDER_STATUS=3))
   SET ofi_date_parser = temp_parser_overdue
   SET ofi_status = "Overdue"
   SET ofi_status_id =  $FUTURE_ORDER_STATUS
  ELSEIF (( $FUTURE_ORDER_STATUS=0))
   SET ofi_date_parser = "1=1"
   SET ofi_status_id =  $FUTURE_ORDER_STATUS
  ENDIF
 ELSE
  IF (3 IN ( $FUTURE_ORDER_STATUS)
   AND 1 IN ( $FUTURE_ORDER_STATUS))
   SET ofi_date_parser = concat(temp_parser_overdue," or ",temp_parser_upcoming)
  ELSEIF (2 IN ( $FUTURE_ORDER_STATUS)
   AND 1 IN ( $FUTURE_ORDER_STATUS))
   SET ofi_date_parser = concat(temp_parser_due," or ",temp_parser_upcoming)
  ELSEIF (2 IN ( $FUTURE_ORDER_STATUS)
   AND 3 IN ( $FUTURE_ORDER_STATUS))
   SET ofi_date_parser = concat(temp_parser_due," or ",temp_parser_overdue)
  ELSEIF (2 IN ( $FUTURE_ORDER_STATUS)
   AND 3 IN ( $FUTURE_ORDER_STATUS)
   AND 1 IN ( $FUTURE_ORDER_STATUS))
   SET ofi_date_parser = concat(temp_parser_due," or ",temp_parser_overdue," or ",
    temp_parser_upcoming)
  ENDIF
 ENDIF
 CALL echo(concat("ofi_date_parser",ofi_date_parser))
 SELECT INTO "nl:"
  FROM order_future_info ofi
  WHERE expand(itr,1,qual->qual_cnt,ofi.order_id,qual->qual[itr].order_id)
   AND ofi.order_future_info_id != 0
   AND parser(ofi_date_parser)
  ORDER BY ofi.order_id
  HEAD REPORT
   ctr2 = 0, stat = alterlist(future_order_info->list,10)
  HEAD ofi.order_id
   ctr2 = (ctr2+ 1)
   IF (mod(ctr2,10)=1)
    stat = alterlist(future_order_info->list,(ctr2+ 9))
   ENDIF
   future_order_info->list[ctr2].beg_dt_tm = ofi.begin_due_dt_tm, future_order_info->list[ctr2].
   end_dt_tm = ofi.begin_due_dt_tm, future_order_info->list[ctr2].order_id = ofi.order_id,
   future_order_info->list[ctr2].status_id = ofi_status_id
   IF (substring(1,1,reflect(parameter(future_ord_num,0))) != "L")
    IF (((( $FUTURE_ORDER_STATUS=1)) OR (((( $FUTURE_ORDER_STATUS=2)) OR (( $FUTURE_ORDER_STATUS=3)
    )) )) )
     future_order_info->list[ctr2].status = ofi_status
    ELSE
     IF (ofi.begin_due_dt_tm >= cnvtdatetime(curdate,235959)
      AND ofi.end_due_dt_tm > cnvtdatetime(curdate,0))
      future_order_info->list[ctr2].status = "Upcoming"
     ELSEIF (ofi.begin_due_dt_tm <= cnvtdatetime(curdate,235959)
      AND ofi.end_due_dt_tm > cnvtdatetime(curdate,0))
      future_order_info->list[ctr2].status = "Due"
     ELSEIF (ofi.begin_due_dt_tm < cnvtdatetime(curdate,235959)
      AND ofi.end_due_dt_tm <= cnvtdatetime(curdate,0))
      future_order_info->list[ctr2].status = "Overdue"
     ENDIF
    ENDIF
   ELSE
    IF (ofi.begin_due_dt_tm >= cnvtdatetime(curdate,235959)
     AND ofi.end_due_dt_tm > cnvtdatetime(curdate,0))
     future_order_info->list[ctr2].status = "Upcoming"
    ELSEIF (ofi.begin_due_dt_tm <= cnvtdatetime(curdate,235959)
     AND ofi.end_due_dt_tm > cnvtdatetime(curdate,0))
     future_order_info->list[ctr2].status = "Due"
    ELSEIF (ofi.begin_due_dt_tm < cnvtdatetime(curdate,235959)
     AND ofi.end_due_dt_tm <= cnvtdatetime(curdate,0))
     future_order_info->list[ctr2].status = "Overdue"
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(future_order_info->list,ctr2), future_order_info->cnt = ctr2
   FOR (ctr3 = 1 TO future_order_info->cnt)
    pos = locateval(itr,1,qual->qual_cnt,future_order_info->list[ctr3].order_id,qual->qual[itr].
     order_id),
    IF (pos > 0)
     qual->qual[pos].future_order_status = future_order_info->list[ctr3].status, qual->qual[pos].
     future_order_status_id = future_order_info->list[ctr3].status_id
    ENDIF
   ENDFOR
  WITH expand = 1, nocounter
 ;end select
 CALL echorecord(qual)
 DECLARE itr1 = i4
 SET stat = alterlist(qual_dup->qual,qual->qual_cnt)
 FOR (itr = 0 TO qual->qual_cnt)
   IF ((((qual->qual[itr].ord_status="Ordered")) OR ((qual->qual[itr].ord_status="Future")
    AND (qual->qual[itr].future_order_status != "--"))) )
    SET itr1 = (itr1+ 1)
    SET qual_dup->qual[itr1].person_id = qual->qual[itr].person_id
    SET qual_dup->qual[itr1].encntr_id = qual->qual[itr].encntr_id
    SET qual_dup->qual[itr1].name = qual->qual[itr].name
    SET qual_dup->qual[itr1].dob = qual->qual[itr].dob
    SET qual_dup->qual[itr1].age = qual->qual[itr].age
    SET qual_dup->qual[itr1].gender = qual->qual[itr].gender
    SET qual_dup->qual[itr1].mrn = qual->qual[itr].mrn
    SET qual_dup->qual[itr1].fin = qual->qual[itr].fin
    SET qual_dup->qual[itr1].home_address = qual->qual[itr].home_address
    SET qual_dup->qual[itr1].home_phone = qual->qual[itr].home_phone
    SET qual_dup->qual[itr1].ord_type = qual->qual[itr].ord_type
    SET qual_dup->qual[itr1].ord_name = qual->qual[itr].ord_name
    SET qual_dup->qual[itr1].orig_date = qual->qual[itr].orig_date
    SET qual_dup->qual[itr1].ord_prov = qual->qual[itr].ord_prov
    SET qual_dup->qual[itr1].ord_by = qual->qual[itr].ord_by
    SET qual_dup->qual[itr1].ord_det = qual->qual[itr].ord_det
    SET qual_dup->qual[itr1].ord_status = qual->qual[itr].ord_status
    SET qual_dup->qual[itr1].order_id = qual->qual[itr].order_id
    SET qual_dup->qual[itr1].future_date = qual->qual[itr].future_date
    SET qual_dup->qual[itr1].grace = qual->qual[itr].grace
    SET qual_dup->qual[itr1].future_order_status = qual->qual[itr].future_order_status
    SET qual_dup->qual[itr1].future_order_status_id = qual->qual[itr].future_order_status_id
   ENDIF
 ENDFOR
 SET qual_dup->qual_cnt = itr1
 SET stat = alterlist(qual_dup->qual,itr1)
 CALL echorecord(qual_dup)
 IF (( $EXCEL_PROMPT=1))
  SELECT DISTINCT INTO  $OUTDEV
   name = substring(1,value(pname_max),qual_dup->qual[d.seq].name), dob = substring(1,15,qual_dup->
    qual[d.seq].dob), age = substring(1,12,qual_dup->qual[d.seq].age),
   gender = substring(1,15,qual_dup->qual[d.seq].gender), mrn = substring(1,15,qual_dup->qual[d.seq].
    mrn), fin = substring(1,15,qual_dup->qual[d.seq].fin),
   home_address = substring(1,value(addr_max),qual_dup->qual[d.seq].home_address), home_phone =
   substring(1,15,qual_dup->qual[d.seq].home_phone), ord_type = substring(1,value(ordtype_max),
    qual_dup->qual[d.seq].ord_type),
   ord_name = substring(1,50,qual_dup->qual[d.seq].ord_name), orig_date = substring(1,20,qual_dup->
    qual[d.seq].orig_date), ord_prov = substring(1,value(prname_max),qual_dup->qual[d.seq].ord_prov),
   ord_by = substring(1,value(pr2name_max),qual_dup->qual[d.seq].ord_by), ord_det = substring(1,value
    (orddet_max),qual_dup->qual[d.seq].ord_det), status = substring(1,10,qual_dup->qual[d.seq].
    ord_status),
   future_order_status = substring(1,25,qual_dup->qual[d.seq].future_order_status), future_date =
   substring(1,25,qual_dup->qual[d.seq].grace)
   FROM (dummyt d  WITH seq = value(qual_dup->qual_cnt))
   PLAN (d
    WHERE d.seq > 0)
   WITH nocounter, format, separator = " "
  ;end select
  IF ((qual_dup->qual_cnt > 0))
   SET did_we_print = "Y"
  ENDIF
 ELSE
  SELECT DISTINCT INTO  $OUTDEV
   person_id = qual_dup->qual[d.seq].person_id, name = substring(1,40,qual_dup->qual[d.seq].name),
   dob = substring(1,15,qual_dup->qual[d.seq].dob),
   age = substring(1,12,qual_dup->qual[d.seq].age), gender = substring(1,10,qual_dup->qual[d.seq].
    gender), mrn = substring(1,10,qual_dup->qual[d.seq].mrn),
   fin = substring(1,15,qual_dup->qual[d.seq].fin), home_address = substring(1,100,qual_dup->qual[d
    .seq].home_address), home_phone = substring(1,15,qual_dup->qual[d.seq].home_phone),
   ord_type = substring(1,20,qual_dup->qual[d.seq].ord_type), ord_name = substring(1,40,qual_dup->
    qual[d.seq].ord_name), orig_date = substring(1,20,qual_dup->qual[d.seq].orig_date),
   ord_prov = substring(1,25,qual_dup->qual[d.seq].ord_prov), ord_by = substring(1,25,qual_dup->qual[
    d.seq].ord_by), ord_det = substring(1,45,qual_dup->qual[d.seq].ord_det),
   status = substring(1,12,qual_dup->qual[d.seq].ord_status), future_order_status = substring(1,10,
    qual_dup->qual[d.seq].future_order_status), future_date = substring(1,25,qual_dup->qual[d.seq].
    grace)
   FROM (dummyt d  WITH seq = value(qual_dup->qual_cnt))
   PLAN (d
    WHERE d.seq > 1)
   HEAD REPORT
    null
   HEAD PAGE
    row 1, col 1, report_name,
    row 1, col 100, "By: ",
    row 1, col 106, who_running_name,
    row 2, col 1, "Requested Dates:",
    row 2, col 22, display_start,
    row 2, col 33, "to",
    row 2, col 36, display_end,
    row 2, col 100, "Run:",
    today = format(curdate,"MM/DD/YY;;d"), row 2, col 106,
    today, now = format(curtime,"hh:mm;;s"), row 2,
    col 115, now, row 3,
    col 1, location_name, row 3,
    col 100, "Page:", pge = trim(cnvtstring(curpage),3),
    row 3, col 106, pge,
    row + 1
   HEAD person_id
    row + 2, col 1, line,
    row + 1, col 3, "Patient:",
    col 20, name, col 60,
    "MRN:", col + 1, mrn,
    col 100, "FIN:", col + 1,
    fin, row + 1, col 20,
    "DOB:", col + 1, dob,
    col 60, "Gender:", col + 1,
    gender, row + 1, col 20,
    "Address:", col + 1, home_address,
    col 100, "Phone:", col + 1,
    home_phone, row + 1, col 1,
    line
   DETAIL
    row + 1, col 8, "Order:",
    col + 1, ord_name, col 70,
    "Order Details:", col + 1, ord_det,
    row + 1, col 23, "Ordered:",
    col + 1, orig_date, col 70,
    "Current Order Status:", col + 1, status,
    row + 1, col 23, "Ordering Provider:",
    col + 1, ord_prov, col 70,
    "Ordered By:", col + 1, ord_by,
    row + 1, col 23, "Future Date Range:",
    col + 1, future_date, col 70,
    "Future Order Status:", col + 1, future_order_status,
    row + 1, did_we_print = "Y"
   FOOT REPORT
    row + 2, col 1, line,
    row + 1,
    CALL center("***** END OF REPORT *****",0,130)
   WITH nocounter, landscape, maxrow = 45
  ;end select
  IF (did_we_print="N")
   SELECT INTO  $OUTDEV
    FROM dummyt d
    PLAN (d)
    DETAIL
     row 1, col 1, report_name,
     row 1, col 100, "By: ",
     row 1, col 106, who_running_name,
     row 2, col 1, "Requested Dates:",
     row 2, col 22, display_start,
     row 2, col 33, "to",
     row 2, col 36, display_end,
     row 2, col 100, "Run:",
     today = format(curdate,"MM/DD/YY;;d"), row 2, col 106,
     today, now = format(curtime,"hh:mm;;s"), row 2,
     col 115, now, row 3,
     col 1, location_name, row 3,
     col 100, "Page:", pge = trim(cnvtstring(curpage),3),
     row 3, col 106, pge,
     row + 1, col 1, line,
     row + 3,
     CALL center("NO INFORMATION RETURNED",0,130), row + 3,
     col 1, line, row + 1,
     CALL center("***** END OF REPORT *****",0,130)
    WITH nocounter, dontcare = d
   ;end select
  ENDIF
 ENDIF
#exit_program
END GO
