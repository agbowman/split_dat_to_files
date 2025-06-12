CREATE PROGRAM bhs_ma_pref_card_pl_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Date range start" = "CURDATE",
  "Date range end" = "CURDATE",
  "Unused percent threshold" = "97",
  "Minimum number of cases" = "12",
  "Surgical area" = 0,
  "Surgical procedure" = 0,
  "Document type" = 0
  WITH outdev, sdate, edate,
  threshold, mincases, area,
  procedure, doctype
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE unused_percent = f8 WITH protect, noconstant(0.0)
 DECLARE filled_cnt = i4 WITH protect, noconstant(0)
 DECLARE used_cnt = i4 WITH protect, noconstant(0)
 DECLARE cases_cnt = i4 WITH protect, noconstant(0)
 DECLARE cases_used_cnt = i4 WITH protect, noconstant(0)
 DECLARE mincases_value = i4 WITH protect, noconstant(0)
 DECLARE threshold_value = i4 WITH protect, noconstant(0)
 DECLARE procedure_value = f8 WITH protect, noconstant(0.0)
 DECLARE area_value = f8 WITH protect, noconstant(0.0)
 DECLARE doctype_value = f8 WITH protect, noconstant(0.0)
 DECLARE pstring_procedure = vc WITH protect, noconstant("")
 DECLARE pstring_area = vc WITH protect, noconstant("")
 DECLARE pstring_doctype = vc WITH protect, noconstant("")
 SET mincases_value = cnvtint( $MINCASES)
 SET threshold_value = cnvtint( $THRESHOLD)
 SET procedure_value = cnvtreal( $PROCEDURE)
 SET area_value = cnvtreal( $AREA)
 SET doctype_value = cnvtreal( $DOCTYPE)
 IF (procedure_value=0.0)
  SET pstring_procedure = "1=1"
 ELSE
  SET pstring_procedure = build2("pc.catalog_cd = ", $PROCEDURE)
 ENDIF
 IF (area_value=0.0)
  SET pstring_area = "1=1"
 ELSE
  SET pstring_area = build2("pc.surg_area_cd = ", $AREA)
 ENDIF
 IF (doctype_value=0.0)
  SET pstring_doctype = "1=1"
 ELSE
  SET pstring_doctype = build2("pc.doc_type_cd = ", $DOCTYPE)
 ENDIF
 FREE SET rows
 RECORD rows(
   1 row_struct[*]
     2 surgical_area = vc
     2 specialty = vc
     2 document_type = vc
     2 procedure = vc
     2 surgeon = vc
     2 item_description = vc
     2 item_number = vc
     2 open = vc
     2 hold = vc
     2 cases_with_item = vc
     2 cases_where_item_was_used = vc
     2 percent_unused = vc
 )
 SELECT INTO "nl:"
  surgical_area = uar_get_code_display(pc.surg_area_cd), specialty = pg.prsnl_group_desc,
  document_type = uar_get_code_description(pc.doc_type_cd),
  procedure = uar_get_code_description(pc.catalog_cd), primary_proc_ind = scp1.primary_proc_ind,
  surgeon = p.name_full_formatted,
  item_description = oii1.value, item_number = oii2.value, pc_open_qty = pcpl.request_open_qty,
  pc_hold_qty = pcpl.request_hold_qty, case_number_formatted = sc.surg_case_nbr_formatted, sc
  .surg_case_id,
  sc.surg_start_dt_tm, fill_qty = ccpl.fill_qty, open_qty = ccpl.open_qty,
  hold_qty = ccpl.hold_qty, used_qty = ccpl.qty_used, wasted_qty = ccpl.wasted_qty,
  return_qty = ccpl.return_qty
  FROM pref_card_pick_list pcpl,
   preference_card pc,
   prsnl_group pg,
   prsnl p,
   object_identifier_index oii1,
   object_identifier_index oii2,
   sn_surg_case_proc_doc scpd,
   surgical_case sc,
   surg_case_procedure scp1,
   case_cart cc,
   case_cart_pick_list ccpl
  PLAN (pcpl
   WHERE pcpl.active_ind=1)
   JOIN (pc
   WHERE pc.pref_card_id=pcpl.pref_card_id
    AND pc.active_ind=1
    AND parser(pstring_doctype)
    AND parser(pstring_procedure)
    AND parser(pstring_area))
   JOIN (pg
   WHERE pg.prsnl_group_id=pc.surg_specialty_id)
   JOIN (p
   WHERE p.person_id=pc.prsnl_id)
   JOIN (oii1
   WHERE oii1.object_id=pcpl.item_id
    AND oii1.generic_object=0
    AND oii1.identifier_type_cd=value(uar_get_code_by("MEANING",11000,"DESC_CLINIC"))
    AND oii1.active_ind=1)
   JOIN (oii2
   WHERE (oii2.object_id= Outerjoin(pcpl.item_id))
    AND (oii2.generic_object= Outerjoin(0))
    AND (oii2.identifier_type_cd= Outerjoin(value(uar_get_code_by("MEANING",11000,"ITEM_NBR"))))
    AND (oii2.active_ind= Outerjoin(1)) )
   JOIN (scpd
   WHERE scpd.pref_card_id=pc.pref_card_id
    AND scpd.active_ind=1)
   JOIN (scp1
   WHERE scp1.surg_case_proc_id=scpd.surg_case_proc_id)
   JOIN (sc
   WHERE sc.surg_case_id=scp1.surg_case_id
    AND sc.surg_complete_qty=1
    AND sc.surg_stop_dt_tm >= cnvtdatetime( $SDATE)
    AND sc.surg_stop_dt_tm <= cnvtdatetime( $EDATE))
   JOIN (cc
   WHERE cc.surg_case_id=sc.surg_case_id
    AND cc.doc_type_cd=pc.doc_type_cd
    AND cc.active_ind=1)
   JOIN (ccpl
   WHERE ccpl.case_cart_id=cc.case_cart_id
    AND ccpl.active_ind=1
    AND ccpl.item_id=pcpl.item_id)
  ORDER BY surgical_area, specialty, document_type,
   procedure, surgeon, item_description
  HEAD REPORT
   null
  HEAD surgical_area
   null
  HEAD specialty
   null
  HEAD document_type
   null
  HEAD procedure
   null
  HEAD surgeon
   null
  HEAD item_description
   filled_cnt = 0, used_cnt = 0, cases_cnt = 0,
   cases_used_cnt = 0, unused_percent = 0.00
  DETAIL
   cases_cnt += 1
   IF (ccpl.fill_qty > 0)
    filled_cnt += ccpl.fill_qty
   ENDIF
   IF (ccpl.qty_used > 0)
    used_cnt += ccpl.qty_used, cases_used_cnt += 1
   ENDIF
  FOOT  item_description
   IF (cases_cnt >= mincases_value)
    IF (cases_cnt > 0)
     unused_percent = round((((cnvtreal(cases_cnt) - cnvtreal(cases_used_cnt))/ cnvtreal(cases_cnt))
       * 100.00),2)
    ELSE
     unused_percent = 100.00
    ENDIF
    IF (unused_percent >= threshold_value)
     icnt += 1, stat = alterlist(rows->row_struct,icnt), rows->row_struct[icnt].surgical_area = trim(
      surgical_area),
     rows->row_struct[icnt].specialty = trim(specialty), rows->row_struct[icnt].document_type = trim(
      document_type), rows->row_struct[icnt].procedure = trim(procedure),
     rows->row_struct[icnt].surgeon = trim(surgeon), rows->row_struct[icnt].item_description = trim(
      item_description), rows->row_struct[icnt].item_number = trim(item_number),
     rows->row_struct[icnt].open = trim(cnvtstring(open_qty)), rows->row_struct[icnt].hold = trim(
      cnvtstring(hold_qty)), rows->row_struct[icnt].cases_with_item = trim(cnvtstring(cases_cnt)),
     rows->row_struct[icnt].cases_where_item_was_used = trim(cnvtstring(cases_used_cnt)), rows->
     row_struct[icnt].percent_unused = trim(cnvtstring(unused_percent,6,2))
    ENDIF
   ENDIF
  WITH nocounter, format(date,"@SHORTDATETIME")
 ;end select
 IF (icnt > 0)
  SELECT INTO value( $OUTDEV)
   surgical_area = substring(1,20,rows->row_struct[d1.seq].surgical_area), specialty = substring(1,20,
    rows->row_struct[d1.seq].specialty), document_type = substring(1,100,rows->row_struct[d1.seq].
    document_type),
   procedure = substring(1,100,rows->row_struct[d1.seq].procedure), surgeon = substring(1,100,rows->
    row_struct[d1.seq].surgeon), item_description = substring(1,100,rows->row_struct[d1.seq].
    item_description),
   item_number = substring(1,20,rows->row_struct[d1.seq].item_number), pl_open_qty = substring(1,10,
    rows->row_struct[d1.seq].open), pl_hold_qty = substring(1,10,rows->row_struct[d1.seq].hold),
   cases_with_item_on_pl = substring(1,10,rows->row_struct[d1.seq].cases_with_item),
   cases_where_item_was_used = substring(1,10,rows->row_struct[d1.seq].cases_where_item_was_used),
   percent_unused = substring(1,10,rows->row_struct[d1.seq].percent_unused)
   FROM (dummyt d1  WITH seq = value(size(rows->row_struct,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    col 5, "No Qualifying Data for selected parameters."
   WITH nocounter
  ;end select
 ENDIF
END GO
