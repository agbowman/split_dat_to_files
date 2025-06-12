CREATE PROGRAM bhs_ma_gen_meds:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 40581347.00
  SET request->visit_cnt = 1
 ENDIF
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
       3 cur_dt = vc
       3 disp1 = vc
       3 admindt = vc
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
  med_type =
  IF (((o.med_order_type_cd IN (iv_cd, intermittent_cd)) OR (o.dcp_clin_cat_cd=ivsolutions_cd)) ) 4
  ELSEIF (o.orig_ord_as_flag IN (1, 2)) 6
  ELSEIF (o.prn_ind=0
   AND o.freq_type_flag != 5) 1
  ELSEIF (o.prn_ind=0
   AND o.freq_type_flag=5) 2
  ELSEIF (o.prn_ind=1) 3
  ELSE 5
  ENDIF
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.encntr_id=eid
    AND ((o.order_status_cd+ 0) IN (o_inprocess_cd, o_ordered_cd, o_pending_cd, o_pending_rev_cd))
    AND o.catalog_type_cd=pharmacy_cattyp_cd
    AND o.template_order_flag IN (0, 1)
    AND  NOT (o.orig_ord_as_flag IN (1, 2)))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE")) OR (od.oe_field_meaning="OTHER"
    AND (od.oe_field_value=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_value=od.oe_field_value
     AND ((cv.code_set+ 0)=102202))))) )
  ORDER BY o.encntr_id, o.order_mnemonic, o.order_id,
   od.action_sequence
  HEAD o.encntr_id
   med_cnt = 0, stat = alterlist(dlrec->seq[1].meds,10), sched_cnt = 0,
   prn_cnt = 0, iv_cnt = 0
  HEAD o.order_mnemonic
   row + 0
  HEAD o.order_id
   dose = " ", strength_dose = " ", freetext_dose = " ",
   volume_dose = " ", dose_unit = " ", strength_unit = " ",
   volume_unit = " ", rate = " ", rate_unit = " ",
   med_cnt = (med_cnt+ 1)
   IF (mod(med_cnt,10)=1)
    stat = alterlist(dlrec->seq[1].meds,(med_cnt+ 10))
   ENDIF
   dlrec->seq[1].meds[med_cnt].order_id = o.order_id, dlrec->seq[1].meds[med_cnt].type = med_type,
   dlrec->seq[1].meds[med_cnt].ioi = o.incomplete_order_ind,
   dlrec->seq[1].meds[med_cnt].mnemonic =
   IF (trim(o.order_mnemonic) > "") concat(trim(o.order_mnemonic),"|")
   ELSE concat(trim(o.ordered_as_mnemonic),"|")
   ENDIF
   , dlrec->seq[1].meds[med_cnt].date = format(o.current_start_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->
   seq[1].meds[med_cnt].order_status_disp = uar_get_code_display(o.order_status_cd),
   dlrec->seq[1].meds[med_cnt].need_rx_verify_ind = o.need_rx_verify_ind
   CASE (o.need_rx_verify_ind)
    OF 0:
     dlrec->seq[1].meds[med_cnt].need_rx_verify_str = "(Verified)"
    OF 1:
     dlrec->seq[1].meds[med_cnt].need_rx_verify_str = "(Unverified)"
    OF 2:
     dlrec->seq[1].meds[med_cnt].need_rx_verify_str = "(Rejected)"
   ENDCASE
  DETAIL
   IF (od.oe_field_meaning="FREQ")
    dlrec->seq[1].meds[med_cnt].freq = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATE")
    rate = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATEUNIT")
    rate_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSE")
    dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    strength_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSE")
    volume_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="FREETXTDOSE")
    freetext_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSEUNIT")
    dose_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    strength_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    volume_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="OTHER")
    dlrec->seq[1].meds[med_cnt].diluent = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RXROUTE")
    dlrec->seq[1].meds[med_cnt].route = concat(trim(od.oe_field_display_value),"|")
   ENDIF
  FOOT  o.order_id
   IF (med_type=1)
    sched_cnt = (sched_cnt+ 1)
   ELSEIF (med_type=3)
    prn_cnt = (prn_cnt+ 1)
   ELSEIF (med_type=4)
    iv_cnt = (iv_cnt+ 1)
   ENDIF
   IF (med_type=4
    AND o.prn_ind=1)
    dlrec->seq[1].meds[med_cnt].iv_prn = "PRN"
   ENDIF
   IF (rate > " ")
    IF (rate_unit > " ")
     dlrec->seq[1].meds[med_cnt].rate = concat(rate,rate_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].rate = rate
    ENDIF
   ENDIF
   IF (dose > " ")
    IF (dose_unit > " ")
     dlrec->seq[1].meds[med_cnt].dose = concat(dose,dose_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].dose = concat(dose)
    ENDIF
   ENDIF
   IF (strength_dose > " ")
    IF (strength_unit > " ")
     dlrec->seq[1].meds[med_cnt].strength_dose = concat(strength_dose,strength_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].strength_dose = concat(strength_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " ")
    IF (volume_unit > " ")
     dlrec->seq[1].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " "
    AND strength_dose <= ""
    AND dose <= "")
    IF (volume_unit > " ")
     dlrec->seq[1].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (freetext_dose > " ")
    dlrec->seq[1].meds[med_cnt].freetext_dose = concat(freetext_dose)
   ENDIF
  FOOT  o.order_mnemonic
   row + 0
  FOOT  o.encntr_id
   dlrec->seq[1].total_meds = med_cnt, stat = alterlist(dlrec->seq[1].meds,med_cnt), dlrec->seq[1].
   sched_meds = sched_cnt,
   dlrec->seq[1].prn_meds = prn_cnt, dlrec->seq[1].iv_meds = iv_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  med_type = 6
  FROM encounter e,
   orders o,
   order_detail od,
   dummyt do
  PLAN (e
   WHERE e.encntr_id=eid)
   JOIN (o
   WHERE o.person_id=e.person_id
    AND ((o.order_status_cd+ 0) IN (o_inprocess_cd, o_ordered_cd, o_pending_cd, o_pending_rev_cd))
    AND o.catalog_type_cd=pharmacy_cattyp_cd
    AND o.template_order_flag IN (0, 1)
    AND o.orig_ord_as_flag IN (1, 2))
   JOIN (do)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE")) OR (od.oe_field_meaning="OTHER"
    AND (od.oe_field_value=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_value=od.oe_field_value
     AND ((cv.code_set+ 0)=102202))))) )
  ORDER BY o.person_id, o.order_mnemonic, o.order_id,
   od.action_sequence
  HEAD o.person_id
   med_cnt = size(dlrec->seq[1].meds,5), stat = alterlist(dlrec->seq[1].meds,(med_cnt+ 10)), home_cnt
    = 0
  HEAD o.order_mnemonic
   row + 0
  HEAD o.order_id
   dose = " ", strength_dose = " ", freetext_dose = " ",
   volume_dose = " ", dose_unit = " ", strength_unit = " ",
   volume_unit = " ", rate = " ", rate_unit = " ",
   home_cnt = (home_cnt+ 1), med_cnt = (med_cnt+ 1)
   IF (mod(med_cnt,10)=1)
    stat = alterlist(dlrec->seq[1].meds,(med_cnt+ 10))
   ENDIF
   dlrec->seq[1].meds[med_cnt].order_id = o.order_id, dlrec->seq[1].meds[med_cnt].type = med_type,
   dlrec->seq[1].meds[med_cnt].ioi = o.incomplete_order_ind,
   dlrec->seq[1].meds[med_cnt].mnemonic =
   IF (trim(o.order_mnemonic) > "") concat(trim(o.order_mnemonic),"|")
   ELSE concat(trim(o.ordered_as_mnemonic),"|")
   ENDIF
   , dlrec->seq[1].meds[med_cnt].date = format(o.current_start_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->
   seq[1].meds[med_cnt].order_status_disp = uar_get_code_display(o.order_status_cd),
   dlrec->seq[1].meds[med_cnt].need_rx_verify_ind = o.need_rx_verify_ind
   CASE (o.need_rx_verify_ind)
    OF 0:
     dlrec->seq[1].meds[med_cnt].need_rx_verify_str = "(Verified)"
    OF 1:
     dlrec->seq[1].meds[med_cnt].need_rx_verify_str = "(Unverified)"
    OF 2:
     dlrec->seq[1].meds[med_cnt].need_rx_verify_str = "(Rejected)"
   ENDCASE
  DETAIL
   IF (od.oe_field_meaning="FREQ")
    dlrec->seq[1].meds[med_cnt].freq = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATE")
    rate = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATEUNIT")
    rate_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSE")
    dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    strength_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSE")
    volume_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="FREETXTDOSE")
    freetext_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSEUNIT")
    dose_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    strength_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    volume_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="OTHER")
    dlrec->seq[1].meds[med_cnt].diluent = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RXROUTE")
    dlrec->seq[1].meds[med_cnt].route = concat(trim(od.oe_field_display_value),"|")
   ENDIF
  FOOT  o.order_id
   IF (rate > " ")
    IF (rate_unit > " ")
     dlrec->seq[1].meds[med_cnt].rate = concat(rate,rate_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].rate = rate
    ENDIF
   ENDIF
   IF (dose > " ")
    IF (dose_unit > " ")
     dlrec->seq[1].meds[med_cnt].dose = concat(dose,dose_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].dose = concat(dose)
    ENDIF
   ENDIF
   IF (strength_dose > " ")
    IF (strength_unit > " ")
     dlrec->seq[1].meds[med_cnt].strength_dose = concat(strength_dose,strength_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].strength_dose = concat(strength_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " ")
    IF (volume_unit > " ")
     dlrec->seq[1].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " "
    AND strength_dose <= ""
    AND dose <= "")
    IF (volume_unit > " ")
     dlrec->seq[1].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[1].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (freetext_dose > " ")
    dlrec->seq[1].meds[med_cnt].freetext_dose = concat(freetext_dose)
   ENDIF
  FOOT  o.order_mnemonic
   row + 0
  FOOT  o.person_id
   dlrec->seq[1].home_meds = home_cnt, dlrec->seq[1].total_meds = med_cnt, stat = alterlist(dlrec->
    seq[1].meds,med_cnt)
  WITH nocounter, outerjoin = do
 ;end select
 FOR (mcnt = 1 TO dlrec->seq[1].total_meds)
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cem
    PLAN (ce
     WHERE (ce.order_id=dlrec->seq[1].meds[mcnt].order_id))
     JOIN (cem
     WHERE cem.event_id=ce.event_id
      AND cem.valid_until_dt_tm > sysdate)
    ORDER BY cem.admin_start_dt_tm
    DETAIL
     dlrec->seq[1].meds[mcnt].admindt = format(cem.admin_start_dt_tm,"mm/dd/yy hh:mm")
    WITH nocounter
   ;end select
 ENDFOR
 CALL echorecord(dlrec)
 SELECT INTO "nl:"
  encntr_id = eid
  FROM (dummyt d1  WITH seq = 1)
  ORDER BY encntr_id
  HEAD REPORT
   cnt = 0
  HEAD encntr_id
   cnt = 0
  DETAIL
   sched_med_found = 0, cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].med_line,cnt),
   dlrec->seq[1].med_line[cnt].medline = concat(rh2b,"Scheduled Meds")
   FOR (mcnt = 1 TO dlrec->seq[1].total_meds)
     IF ((dlrec->seq[1].meds[mcnt].type=1))
      sched_med_found = 1, med_string = replace(trim(concat(dlrec->seq[1].meds[mcnt].date," - ",dlrec
         ->seq[1].meds[mcnt].mnemonic,dlrec->seq[1].meds[mcnt].dose,dlrec->seq[1].meds[mcnt].
         freetext_dose,
         dlrec->seq[1].meds[mcnt].rate,dlrec->seq[1].meds[mcnt].strength_dose,dlrec->seq[1].meds[mcnt
         ].volume_dose,dlrec->seq[1].meds[mcnt].diluent,dlrec->seq[1].meds[mcnt].route,
         dlrec->seq[1].meds[mcnt].freq)),"|"," ",0), cnt = (cnt+ 1),
      stat = alterlist(dlrec->seq[1].med_line,cnt), dlrec->seq[1].med_line[cnt].medline = concat(wr,
       " ",med_string)
     ENDIF
   ENDFOR
   IF (sched_med_found=0)
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].med_line,cnt), dlrec->seq[1].med_line[cnt].medline
     = concat(wr," ","No Scheduled meds found for encounter.")
   ENDIF
   prn_med_found = 0, cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].med_line,cnt),
   dlrec->seq[1].med_line[cnt].medline = concat(rh2b,"PRN Meds")
   FOR (mcnt = 1 TO dlrec->seq[1].total_meds)
     IF ((dlrec->seq[1].meds[mcnt].type=3))
      prn_med_found = 1, med_string = replace(trim(concat(dlrec->seq[1].meds[mcnt].date," - ",dlrec->
         seq[1].meds[mcnt].mnemonic,dlrec->seq[1].meds[mcnt].dose,dlrec->seq[1].meds[mcnt].
         freetext_dose,
         dlrec->seq[1].meds[mcnt].rate,dlrec->seq[1].meds[mcnt].strength_dose,dlrec->seq[1].meds[mcnt
         ].volume_dose,dlrec->seq[1].meds[mcnt].diluent,dlrec->seq[1].meds[mcnt].route,
         dlrec->seq[1].meds[mcnt].freq)),"|"," ",0), cnt = (cnt+ 1),
      stat = alterlist(dlrec->seq[1].med_line,cnt)
      IF ((dlrec->seq[1].meds[mcnt].admindt > " "))
       dlrec->seq[1].med_line[cnt].medline = concat(wr," ",med_string," [Last Given: ",dlrec->seq[1].
        meds[mcnt].admindt,
        "]")
      ELSE
       dlrec->seq[1].med_line[cnt].medline = concat(wr," ",med_string)
      ENDIF
     ENDIF
   ENDFOR
   IF (prn_med_found=0)
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].med_line,cnt), dlrec->seq[1].med_line[cnt].medline
     = concat(wr," ","No PRN meds found for encounter.")
   ENDIF
   iv_med_found = 0, cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].med_line,cnt),
   dlrec->seq[1].med_line[cnt].medline = concat(rh2b,"IV Fluids")
   FOR (mcnt = 1 TO dlrec->seq[1].total_meds)
     IF ((dlrec->seq[1].meds[mcnt].type=4))
      iv_med_found = 1, med_string = replace(trim(concat(dlrec->seq[1].meds[mcnt].date," - ",dlrec->
         seq[1].meds[mcnt].mnemonic,dlrec->seq[1].meds[mcnt].dose,dlrec->seq[1].meds[mcnt].
         freetext_dose,
         substring(1,(findstring(".",dlrec->seq[1].meds[mcnt].rate,1,0)+ 4),dlrec->seq[1].meds[mcnt].
          rate),substring(findstring("m",dlrec->seq[1].meds[mcnt].rate,1,1),6,dlrec->seq[1].meds[mcnt
          ].rate),dlrec->seq[1].meds[mcnt].strength_dose,dlrec->seq[1].meds[mcnt].volume_dose,dlrec->
         seq[1].meds[mcnt].diluent,
         dlrec->seq[1].meds[mcnt].route,dlrec->seq[1].meds[mcnt].iv_prn,dlrec->seq[1].meds[mcnt].freq
         )),"|"," ",0), cnt = (cnt+ 1),
      stat = alterlist(dlrec->seq[1].med_line,cnt), dlrec->seq[1].med_line[cnt].medline = concat(wr,
       " ",med_string)
     ENDIF
   ENDFOR
   IF (iv_med_found=0)
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].med_line,cnt), dlrec->seq[1].med_line[cnt].medline
     = concat(wr," ","No IV meds found for encounter.")
   ENDIF
   home_med_found = 0, cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].med_line,cnt),
   dlrec->seq[1].med_line[cnt].medline = concat(rh2b,"Home Meds")
   FOR (mcnt = 1 TO dlrec->seq[1].total_meds)
     IF ((dlrec->seq[1].meds[mcnt].type=6))
      home_med_found = 1, med_string = replace(trim(concat(dlrec->seq[1].meds[mcnt].date," - ",dlrec
         ->seq[1].meds[mcnt].mnemonic,dlrec->seq[1].meds[mcnt].dose,dlrec->seq[1].meds[mcnt].
         freetext_dose,
         dlrec->seq[1].meds[mcnt].rate,dlrec->seq[1].meds[mcnt].strength_dose,dlrec->seq[1].meds[mcnt
         ].volume_dose,dlrec->seq[1].meds[mcnt].diluent,dlrec->seq[1].meds[mcnt].route,
         dlrec->seq[1].meds[mcnt].freq)),"|"," ",0), cnt = (cnt+ 1),
      stat = alterlist(dlrec->seq[1].med_line,cnt), dlrec->seq[1].med_line[cnt].medline = concat(wr,
       " ",med_string)
     ENDIF
   ENDFOR
   IF (home_med_found=0)
    cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].med_line,cnt), dlrec->seq[1].med_line[cnt].medline
     = concat(wr," ","No Home meds found for encounter.")
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(dlrec)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "MEDICATIONS AND IV's"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol)
 FOR (x = 1 TO size(dlrec->seq[1].med_line,5))
   SET lidx = (lidx+ 1)
   SET stat = alterlist(drec->line_qual,lidx)
   SET temp_disp1 = dlrec->seq[1].med_line[x].medline
   SET drec->line_qual[lidx].disp_line = concat(trim(temp_disp1),reol)
 ENDFOR
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
END GO
