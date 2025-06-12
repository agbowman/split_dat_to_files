CREATE PROGRAM bhs_ma_gen_procedures:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE gen_lab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE notdone_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE radiology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE blood_bank_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE blood_bank_mlh_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANKMLH"
   ))
 DECLARE blood_bank_donor_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKDONOR"))
 DECLARE blood_bank_products_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKPRODUCT"))
 DECLARE blood_bank_donor_products_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKDONORPRODUCT"))
 DECLARE ap_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ANATOMICPATHOLOGY"))
 DECLARE hla_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"HLA"))
 DECLARE code_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS"))
 DECLARE od_limited_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16449,"LIMITATIONS"))
 DECLARE most_recent_date = vc
 DECLARE micro_cnt = i4
 DECLARE blood_bank_cnt = i4
 DECLARE next_display = c15
 DECLARE current_display = c15
 DECLARE diff_between = f8
 DECLARE current_05 = f8
 DECLARE restraint_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RESTRAINTS"))
 DECLARE heparin_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"HEPARIN"))
 DECLARE enoxaparin_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"ENOXAPARIN"))
 DECLARE cath_foley_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERFOLEY"))
 DECLARE cath_care_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERCARE"))
 DECLARE cath_foley_3_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERFOLEYTHREEWAY"))
 DECLARE cath_texas_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERTEXAS"))
 DECLARE cath_suprap_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERSUPRAPUBIC"))
 DECLARE cath_coude_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERCOUDE"))
 DECLARE boots_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "PNEUMATICCOMPRESSIONBOOTS"))
 DECLARE stockings_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "ANTIEMBOLISMSTOCKINGS"))
 DECLARE placeholder_event_class_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,
   "PLACEHOLDER"))
 DECLARE lab_string = vc
 DECLARE med_string = vc
 DECLARE iv_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE intermittent_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE ivsolutions_cd = f8 WITH public, constant(uar_get_code_by("MEANING",16389,"IVSOLUTIONS"))
 DECLARE pharmacy_cattyp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE pharmacy_acttyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE dose = vc
 DECLARE strength_dose = vc
 DECLARE volume_dose = vc
 DECLARE freetext_dose = vc
 DECLARE dose_unit = vc
 DECLARE strength_unit = vc
 DECLARE volume_unit = vc
 DECLARE rate = vc
 DECLARE rate_unit = vc
 DECLARE route = vc
 DECLARE diluent = vc
 DECLARE sched_cnt = i2
 DECLARE prn_cnt = i2
 DECLARE iv_cnt = i2
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 total_lab_results = i4
     2 lab_results[*]
       3 lab_header = c30
       3 event_id = f8
       3 event_cd_disp = c15
       3 result = c15
       3 result_val = vc
       3 normalcy_disp = vc
       3 most_recent_date = vc
       3 date = vc
     2 lab_line_cnt = i4
     2 lab_line[*]
       3 column1 = vc
       3 column2 = vc
       3 column3 = vc
     2 micro_labs = i4
     2 micro_orders[*]
       3 order_id = f8
       3 orderable = vc
       3 order_status = vc
       3 order_date = vc
     2 blood_bank_labs = i4
     2 blood_bank_orders[*]
       3 order_id = f8
       3 orderable = vc
       3 order_status = vc
       3 order_date = vc
     2 rad_count = i4
     2 rad_orders[*]
       3 order_id = f8
       3 orderable = vc
       3 order_status = vc
       3 order_date = vc
     2 total_orders = i4
     2 orders[*]
       3 orderable = vc
       3 type = vc
       3 date = vc
     2 total_meds = i4
     2 sched_meds = i2
     2 prn_meds = i2
     2 iv_meds = i2
     2 home_meds = i2
     2 meds[*]
       3 order_id = f8
       3 mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 date = vc
       3 order_status_disp = vc
       3 freq = vc
       3 dose = vc
       3 strength_dose = vc
       3 volume_dose = vc
       3 freetext_dose = vc
       3 rate = vc
       3 route = vc
       3 diluent = vc
       3 need_rx_verify_ind = i2
       3 need_rx_verify_str = vc
       3 type = i2
       3 ioi = i2
       3 iv_prn = vc
       3 disp1 = vc
     2 med_line_cnt = i4
     2 med_line[*]
       3 column1 = vc
       3 column2 = vc
       3 column3 = vc
       3 medline = vc
 )
 SET eid = request->visit[1].encntr_id
 SET dlrec->encntr_total = 1
 SET stat = alterlist(dlrec->seq,dlrec->encntr_total)
 SET x = 1
 SET lidx = 0
 DECLARE tmp_display1 = vc
 DECLARE temp_disp1 = vc
 DECLARE temp_disp2 = vc
 DECLARE temp_disp5 = vc
 DECLARE temp_disp6 = vc
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SELECT INTO "nl:"
  event_display = uar_get_code_display(ce.event_cd), catalog_display = uar_get_code_display(ce
   .catalog_cd)
  FROM orders o,
   clinical_event ce
  PLAN (o
   WHERE o.encntr_id=eid
    AND o.activity_type_cd=gen_lab_cd)
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
    AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd, pending_cd))
    AND ce.result_val > " ")
  ORDER BY ce.encntr_id, catalog_display, ce.order_id DESC,
   ce.event_id
  HEAD ce.encntr_id
   lab_cnt = 0, stat = alterlist(dlrec->seq[1].lab_results,10)
  HEAD catalog_display
   lab_cnt = (lab_cnt+ 1)
   IF (mod(lab_cnt,10)=1)
    stat = alterlist(dlrec->seq[1].lab_results,(lab_cnt+ 10))
   ENDIF
   dlrec->seq[1].lab_results[lab_cnt].lab_header = concat(substring(1,28,uar_get_code_display(ce
      .catalog_cd))), dlrec->seq[1].lab_results[lab_cnt].result_val = "HEADER"
  DETAIL
   most_recent_date = " ", most_recent_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), lab_cnt
    = (lab_cnt+ 1)
   IF (mod(lab_cnt,10)=1)
    stat = alterlist(dlrec->seq[1].lab_results,(lab_cnt+ 10))
   ENDIF
   dlrec->seq[1].lab_results[lab_cnt].event_id = ce.event_id
   IF (size(trim(uar_get_code_display(ce.event_cd))) <= 15)
    dlrec->seq[1].lab_results[lab_cnt].event_cd_disp = uar_get_code_display(ce.event_cd)
   ELSE
    IF (trim(ce.result_val) <= ""
     AND trim(uar_get_code_display(ce.result_units_cd)) <= "")
     dlrec->seq[1].lab_results[lab_cnt].event_cd_disp = concat(substring(1,27,uar_get_code_display(ce
        .event_cd)),"...")
    ELSE
     dlrec->seq[1].lab_results[lab_cnt].event_cd_disp = concat(substring(1,12,uar_get_code_display(ce
        .event_cd)),"...")
    ENDIF
   ENDIF
   IF (trim(uar_get_code_display(ce.result_units_cd)) > " ")
    IF (size(trim(concat(trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd))))) >
    15)
     dlrec->seq[1].lab_results[lab_cnt].result = substring(1,12,trim(concat(trim(ce.result_val)," ",
        trim(uar_get_code_display(ce.result_units_cd)),"...")))
    ELSE
     dlrec->seq[1].lab_results[lab_cnt].result = trim(concat(trim(ce.result_val)," ",trim(
        uar_get_code_display(ce.result_units_cd))))
    ENDIF
   ELSE
    IF (size(trim(ce.result_val)) > 15)
     dlrec->seq[1].lab_results[lab_cnt].result = concat(trim(substring(1,12,ce.result_val)),"...")
    ELSE
     dlrec->seq[1].lab_results[lab_cnt].result = trim(ce.result_val)
    ENDIF
   ENDIF
   dlrec->seq[1].lab_results[lab_cnt].date = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d"), dlrec->seq[
   1].lab_results[lab_cnt].most_recent_date = most_recent_date, dlrec->seq[1].lab_results[lab_cnt].
   normalcy_disp = trim(uar_get_code_display(ce.normalcy_cd)),
   dlrec->seq[1].lab_results[lab_cnt].result_val = trim(ce.result_val)
  FOOT  ce.encntr_id
   stat = alterlist(dlrec->seq[1].lab_results,lab_cnt), dlrec->seq[1].total_lab_results = lab_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = eid
  FROM (dummyt d  WITH seq = 1)
  WHERE (dlrec->seq[1].total_lab_results > 0)
  HEAD encntr_id
   total_lab_rows = 0, total_rows = 0, save_total_rows = 0
  DETAIL
   total_lab_rows = cnvtint((dlrec->seq[1].total_lab_results/ 3.0))
   IF (mod(dlrec->seq[1].total_lab_results,3) != 0)
    total_lab_rows = cnvtint(((dlrec->seq[1].total_lab_results/ 3)+ 1))
   ENDIF
   FOR (lcnt = 1 TO dlrec->seq[1].total_lab_results)
     IF (lcnt <= total_lab_rows)
      header_swt = dlrec->seq[1].lab_results[lcnt].result_val
      IF (header_swt != "HEADER")
       lab_string = concat(wr," ",dlrec->seq[1].lab_results[lcnt].date," ",dlrec->seq[1].lab_results[
        lcnt].event_cd_disp,
        " ",trim(dlrec->seq[1].lab_results[lcnt].result))
      ELSE
       lab_string = concat(rh2b,dlrec->seq[1].lab_results[lcnt].lab_header)
      ENDIF
      total_rows = (total_rows+ 1), stat = alterlist(dlrec->seq[1].lab_line,total_rows), dlrec->seq[1
      ].lab_line_cnt = total_rows
      IF (trim(dlrec->seq[1].lab_results[lcnt].normalcy_disp) IN ("C", "C *", "H", "H *", "L",
      "L *"))
       dlrec->seq[1].lab_line[total_rows].column1 = concat(lab_string," ",dlrec->seq[1].lab_results[
        lcnt].normalcy_disp)
      ELSE
       dlrec->seq[1].lab_line[total_rows].column1 = concat(lab_string," ",dlrec->seq[1].lab_results[
        lcnt].normalcy_disp)
      ENDIF
     ENDIF
   ENDFOR
   total_rows = 0
   FOR (lcnt = 1 TO dlrec->seq[1].total_lab_results)
     IF (lcnt > total_lab_rows
      AND (lcnt <= (total_lab_rows * 2)))
      header_swt = dlrec->seq[1].lab_results[lcnt].result_val
      IF (header_swt != "HEADER")
       lab_string = concat(wr," ",dlrec->seq[1].lab_results[lcnt].date," ",dlrec->seq[1].lab_results[
        lcnt].event_cd_disp,
        " ",trim(dlrec->seq[1].lab_results[lcnt].result))
      ELSE
       lab_string = concat(rh2b,dlrec->seq[1].lab_results[lcnt].lab_header)
      ENDIF
      total_rows = (total_rows+ 1)
      IF (trim(dlrec->seq[1].lab_results[lcnt].normalcy_disp) IN ("C", "C *", "H", "H *", "L",
      "L *"))
       dlrec->seq[1].lab_line[total_rows].column2 = concat(lab_string," ",dlrec->seq[1].lab_results[
        lcnt].normalcy_disp)
      ELSE
       dlrec->seq[1].lab_line[total_rows].column2 = concat(lab_string," ",dlrec->seq[1].lab_results[
        lcnt].normalcy_disp)
      ENDIF
     ENDIF
   ENDFOR
   total_rows = 0
   FOR (lcnt = 1 TO dlrec->seq[1].total_lab_results)
     IF ((lcnt > (total_lab_rows * 2))
      AND (lcnt <= (total_lab_rows * 3)))
      header_swt = dlrec->seq[1].lab_results[lcnt].result_val
      IF (header_swt != "HEADER")
       lab_string = concat(wr," ",dlrec->seq[1].lab_results[lcnt].date," ",dlrec->seq[1].lab_results[
        lcnt].event_cd_disp,
        " ",trim(dlrec->seq[1].lab_results[lcnt].result))
      ELSE
       lab_string = concat(rh2b,dlrec->seq[1].lab_results[lcnt].lab_header)
      ENDIF
      total_rows = (total_rows+ 1)
      IF (trim(dlrec->seq[1].lab_results[lcnt].normalcy_disp) IN ("C", "C *", "H", "H *", "L",
      "L *"))
       dlrec->seq[1].lab_line[total_rows].column3 = concat(lab_string," ",dlrec->seq[1].lab_results[
        lcnt].normalcy_disp)
      ELSE
       dlrec->seq[1].lab_line[total_rows].column3 = concat(lab_string," ",dlrec->seq[1].lab_results[
        lcnt].normalcy_disp)
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_order =
  IF (o.catalog_cd IN (cath_foley_cd, cath_foley_3_cd, cath_care_cd, cath_coude_cd, cath_texas_cd,
  cath_suprap_cd)) 1
  ELSEIF (o.hna_order_mnemonic="Heparin") 2
  ELSEIF (o.hna_order_mnemonic="Enoxaparin") 3
  ELSEIF (o.hna_order_mnemonic="Anti-Embolism Stockings") 4
  ELSEIF (o.hna_order_mnemonic="Pneumatic Compression Boots") 5
  ELSEIF (o.activity_type_cd=restraint_cd) 6
  ELSE 7
  ENDIF
  FROM orders o
  PLAN (o
   WHERE o.encntr_id=eid
    AND ((o.activity_type_cd IN (micro_cd, blood_bank_cd, radiology_cd)
    AND o.current_start_dt_tm >= cnvtdatetime((curdate - 1),curtime)) OR (((o.activity_type_cd=
   restraint_cd
    AND ((o.order_status_cd+ 0)=o_ordered_cd)) OR (o.catalog_cd IN (heparin_cd, enoxaparin_cd,
   cath_foley_cd, cath_foley_3_cd, cath_care_cd,
   cath_coude_cd, cath_texas_cd, cath_suprap_cd, boots_cd, stockings_cd)
    AND ((o.order_status_cd+ 0)=o_ordered_cd))) ))
    AND o.template_order_flag IN (0, 1))
  ORDER BY o.encntr_id, sort_order, o.orig_order_dt_tm DESC,
   o.hna_order_mnemonic
  HEAD o.encntr_id
   micro_cnt = 0, stat = alterlist(dlrec->seq[1].micro_orders,10), blood_bank_cnt = 0,
   stat = alterlist(dlrec->seq[1].blood_bank_orders,10), ord_cnt = 0, stat = alterlist(dlrec->seq[1].
    orders,10),
   rad_cnt = 0, stat = alterlist(dlrec->seq[1].rad_orders,10)
  HEAD sort_order
   row + 0
  HEAD o.orig_order_dt_tm
   row + 0
  HEAD o.hna_order_mnemonic
   IF ( NOT (o.activity_type_cd IN (micro_cd, blood_bank_cd, radiology_cd)))
    ord_cnt = (ord_cnt+ 1)
    IF (mod(ord_cnt,10)=1)
     stat = alterlist(dlrec->seq[1].orders,(ord_cnt+ 10))
    ENDIF
    IF (o.catalog_cd IN (cath_foley_cd, cath_foley_3_cd, cath_care_cd, cath_coude_cd, cath_texas_cd,
    cath_suprap_cd))
     dlrec->seq[1].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[1].orders[
     ord_cnt].type = "catheter", dlrec->seq[1].orders[ord_cnt].date = format(o.orig_order_dt_tm,
      "mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic="Heparin")
     dlrec->seq[1].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[1].orders[
     ord_cnt].type = "heparin", dlrec->seq[1].orders[ord_cnt].date = format(o.orig_order_dt_tm,
      "mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic="Enoxaparin")
     dlrec->seq[1].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[1].orders[
     ord_cnt].type = "enoxaparin", dlrec->seq[1].orders[ord_cnt].date = format(o.orig_order_dt_tm,
      "mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic IN ("Pneumatic Compression Boots", "Anti-Embolism Stockings"))
     dlrec->seq[1].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[1].orders[
     ord_cnt].type = "compression device", dlrec->seq[1].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.activity_type_cd=restraint_cd)
     dlrec->seq[1].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[1].orders[
     ord_cnt].type = "restraint", dlrec->seq[1].orders[ord_cnt].date = format(o.orig_order_dt_tm,
      "mm/dd/yyyy hh:mm;;d")
    ENDIF
   ENDIF
  DETAIL
   IF (o.activity_type_cd=micro_cd)
    micro_cnt = (micro_cnt+ 1)
    IF (mod(micro_cnt,10)=1)
     stat = alterlist(dlrec->seq[1].micro_orders,(micro_cnt+ 10))
    ENDIF
    dlrec->seq[1].micro_orders[micro_cnt].order_id = o.order_id, dlrec->seq[1].micro_orders[micro_cnt
    ].order_date = format(o.orig_order_dt_tm,"mm/dd hh:mm;;d")
    IF (size(trim(o.hna_order_mnemonic)) <= 40)
     dlrec->seq[1].micro_orders[micro_cnt].orderable = trim(o.hna_order_mnemonic)
    ELSE
     dlrec->seq[1].micro_orders[micro_cnt].orderable = concat(substring(1,37,o.hna_order_mnemonic),
      "...")
    ENDIF
    IF (size(trim(uar_get_code_display(o.order_status_cd))) <= 12)
     dlrec->seq[1].micro_orders[micro_cnt].order_status = trim(uar_get_code_display(o.order_status_cd
       ))
    ELSE
     dlrec->seq[1].micro_orders[micro_cnt].order_status = concat(substring(1,9,uar_get_code_display(o
        .order_status_cd)),"...")
    ENDIF
   ELSEIF (o.activity_type_cd=blood_bank_cd)
    blood_bank_cnt = (blood_bank_cnt+ 1)
    IF (mod(blood_bank_cnt,10)=1)
     stat = alterlist(dlrec->seq[1].blood_bank_orders,(blood_bank_cnt+ 10))
    ENDIF
    dlrec->seq[1].blood_bank_orders[blood_bank_cnt].order_id = o.order_id, dlrec->seq[1].
    blood_bank_orders[blood_bank_cnt].order_date = format(o.orig_order_dt_tm,"mm/dd hh:mm;;d")
    IF (size(trim(o.hna_order_mnemonic)) <= 40)
     dlrec->seq[1].blood_bank_orders[blood_bank_cnt].orderable = trim(o.hna_order_mnemonic)
    ELSE
     dlrec->seq[1].blood_bank_orders[blood_bank_cnt].orderable = concat(substring(1,37,o
       .hna_order_mnemonic),"...")
    ENDIF
    IF (size(trim(uar_get_code_display(o.order_status_cd))) <= 12)
     dlrec->seq[1].blood_bank_orders[blood_bank_cnt].order_status = trim(uar_get_code_display(o
       .order_status_cd))
    ELSE
     dlrec->seq[1].blood_bank_orders[blood_bank_cnt].order_status = concat(substring(1,9,
       uar_get_code_display(o.order_status_cd)),"...")
    ENDIF
   ELSEIF (o.activity_type_cd=radiology_cd)
    rad_cnt = (rad_cnt+ 1)
    IF (mod(rad_cnt,10)=1)
     stat = alterlist(dlrec->seq[1].rad_orders,(rad_cnt+ 10))
    ENDIF
    dlrec->seq[1].rad_orders[rad_cnt].order_id = o.order_id, dlrec->seq[1].rad_orders[rad_cnt].
    order_date = format(o.orig_order_dt_tm,"mm/dd hh:mm;;d")
    IF (size(trim(o.hna_order_mnemonic)) <= 40)
     dlrec->seq[1].rad_orders[rad_cnt].orderable = trim(o.hna_order_mnemonic)
    ELSE
     dlrec->seq[1].rad_orders[rad_cnt].orderable = concat(substring(1,37,o.hna_order_mnemonic),"...")
    ENDIF
    IF (size(trim(uar_get_code_display(o.order_status_cd))) <= 12)
     dlrec->seq[1].rad_orders[rad_cnt].order_status = trim(uar_get_code_display(o.order_status_cd))
    ELSE
     dlrec->seq[1].rad_orders[rad_cnt].order_status = concat(substring(1,9,uar_get_code_display(o
        .order_status_cd)),"...")
    ENDIF
   ENDIF
  FOOT  o.hna_order_mnemonic
   row + 0
  FOOT  o.orig_order_dt_tm
   row + 0
  FOOT  sort_order
   row + 0
  FOOT  o.encntr_id
   stat = alterlist(dlrec->seq[1].micro_orders,micro_cnt), dlrec->seq[1].micro_labs = micro_cnt, stat
    = alterlist(dlrec->seq[1].blood_bank_orders,blood_bank_cnt),
   dlrec->seq[1].blood_bank_labs = blood_bank_cnt, stat = alterlist(dlrec->seq[1].orders,ord_cnt),
   dlrec->seq[1].total_orders = ord_cnt,
   stat = alterlist(dlrec->seq[1].rad_orders,rad_cnt), dlrec->seq[1].rad_count = rad_cnt
  WITH nocounter
 ;end select
 CALL echorecord(dlrec)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "General Lab Results in last 24 hours"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol)
 IF ((dlrec->seq[1].lab_line_cnt > 0))
  FOR (lcnt = 1 TO dlrec->seq[1].lab_line_cnt)
    SET lidx = (lidx+ 1)
    SET stat = alterlist(drec->line_qual,lidx)
    SET temp_disp1 = concat(dlrec->seq[1].lab_line[lcnt].column1)
    SET drec->line_qual[lidx].disp_line = concat(" ",trim(temp_disp1),reol)
  ENDFOR
  FOR (lcnt = 1 TO dlrec->seq[1].lab_line_cnt)
    SET lidx = (lidx+ 1)
    SET stat = alterlist(drec->line_qual,lidx)
    SET temp_disp1 = concat(dlrec->seq[1].lab_line[lcnt].column2)
    SET drec->line_qual[lidx].disp_line = concat(" ",trim(temp_disp1),reol)
  ENDFOR
  FOR (lcnt = 1 TO dlrec->seq[1].lab_line_cnt)
    SET lidx = (lidx+ 1)
    SET stat = alterlist(drec->line_qual,lidx)
    SET temp_disp1 = concat(dlrec->seq[1].lab_line[lcnt].column3)
    SET drec->line_qual[lidx].disp_line = concat(" ",trim(temp_disp1),reol)
  ENDFOR
 ELSE
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = "No Labs found on encounter in last 24 hours."
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1),reol)
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "Radiology, Micro, Blood Bank Orders in the last 24 hours"
 SET drec->line_qual[lidx].disp_line = concat(rh2bu,trim(temp_disp1),reol)
 IF ((dlrec->seq[1].micro_labs > 0))
  FOR (x = 1 TO dlrec->seq[1].micro_labs)
    SET lidx = (lidx+ 1)
    SET stat = alterlist(drec->line_qual,lidx)
    SET temp_disp1 = concat(dlrec->seq[1].micro_orders[x].order_date," ",dlrec->seq[1].micro_orders[x
     ].orderable," ",dlrec->seq[1].micro_orders[x].order_status)
    SET drec->line_qual[lidx].disp_line = concat(wr," ",trim(temp_disp1),reol)
  ENDFOR
 ELSE
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = "No Micro Orders found in last 24 hours."
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1),reol)
 ENDIF
 IF ((dlrec->seq[1].blood_bank_labs > 0))
  FOR (x = 1 TO dlrec->seq[1].blood_bank_labs)
    SET lidx = (lidx+ 1)
    SET stat = alterlist(drec->line_qual,lidx)
    SET temp_disp1 = concat(dlrec->seq[1].blood_bank_orders[x].order_date," ",dlrec->seq[1].
     blood_bank_orders[x].orderable," ",dlrec->seq[1].blood_bank_orders[x].order_status)
    SET drec->line_qual[lidx].disp_line = concat(wr," ",trim(temp_disp1),reol)
  ENDFOR
 ELSE
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = "No Blood Bank Orders found in last 24 hours."
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1),reol)
 ENDIF
 IF ((dlrec->seq[1].rad_count > 0))
  FOR (x = 1 TO dlrec->seq[1].rad_count)
    SET lidx = (lidx+ 1)
    SET stat = alterlist(drec->line_qual,lidx)
    SET temp_disp1 = concat(dlrec->seq[1].rad_orders[x].order_date," ",dlrec->seq[1].rad_orders[x].
     orderable," ",dlrec->seq[1].rad_orders[x].order_status)
    SET drec->line_qual[lidx].disp_line = concat(wr," ",trim(temp_disp1),reol)
  ENDFOR
 ELSE
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = "No Radiology Orders found in last 24 hours."
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1),reol)
 ENDIF
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD drec
END GO
