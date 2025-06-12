CREATE PROGRAM bhs_dietary_report_new
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please enter a facility:" = 0,
  "Nursing Unit" = 0,
  "TPN Order Options" = 0,
  "Order Statuses" = value(2550.000000)
  WITH outdev, facility, nurse_unit,
  tpn_option, order_status
 IF (( $FACILITY=0)
  AND ( $NURSE_UNIT=0))
  SELECT INTO  $OUTDEV
   FROM dummyt d
   DETAIL
    col 1, "You must select a nursing unit, or a facility"
   WITH nocounter
  ;end select
  GO TO exitscript
 ENDIF
 DECLARE inpatient_enc_type_cd = f8
 DECLARE observation_enc_type_cd = f8
 DECLARE daystay_enc_type_cd = f8
 DECLARE food_allergy_type_cd = f8
 DECLARE tube_continuous_cd = f8
 DECLARE infant_formula_cd = f8
 DECLARE infant_formula_add_cd = f8
 DECLARE tube_feeding_add_cd = f8
 DECLARE tube_feeding_bolus_cd = f8
 DECLARE nut_services_consult_cd = f8
 DECLARE supplements_cd = f8
 DECLARE diets_cd = f8
 DECLARE diet_spec_inst = f8
 DECLARE pharm_act_type_cd = f8
 DECLARE order_comment_type_cd = f8
 DECLARE clear1_cd = f8
 DECLARE clear2_cd = f8
 DECLARE clear3_cd = f8
 DECLARE clear4_cd = f8
 DECLARE fullliquid1_cd = f8
 DECLARE fullliquid2_cd = f8
 SET inpatient_enc_type_cd = uar_get_code_by("DISPLAY",71,"Inpatient")
 SET observation_enc_type_cd = uar_get_code_by("DISPLAY",71,"Observation")
 SET daystay_enc_type_cd = uar_get_code_by("DISPLAY",71,"Daystay")
 SET food_allergy_type_cd = uar_get_code_by("MEANING",12020,"FOOD")
 SET active_allergy_cd = uar_get_code_by("MEANING",12025,"ACTIVE")
 SET tube_continuous_cd = uar_get_code_by("DISPLAY",106,"Tube Feeding Continuous")
 SET infant_formula_cd = uar_get_code_by("DISPLAY",106,"Infant Formulas")
 SET infant_formula_add_cd = uar_get_code_by("DISPLAY",106,"Infant Formula Additives")
 SET tube_feeding_add_cd = uar_get_code_by("DISPLAY",106,"Tube Feeding Additives")
 SET tube_feeding_bolus_cd = uar_get_code_by("DISPLAY",106,"Tube Feeding Bolus")
 SET nut_services_consult_cd = uar_get_code_by("DISPLAY",106,"Nutrition Services Consults")
 SET supplements_cd = uar_get_code_by("DISPLAY",106,"Supplements")
 SET diets_cd = uar_get_code_by("DISPLAY",106,"Diets")
 SET diet_spec_inst = uar_get_code_by("DISPLAY",106,"Diet Special Instructions")
 SET pharm_act_type_cd = uar_get_code_by("DISPLAY",106,"Pharmacy")
 SET order_comment_type_cd = uar_get_code_by("MEANING",14,"ORD COMMENT")
 SET clear1_cd = uar_get_code_by("DISPLAYKEY",200,"CLEARLIQUIDDIET")
 SET clear2_cd = uar_get_code_by("DISPLAYKEY",200,"CLEARLIQUIDDIETPEDIADOL")
 SET clear3_cd = uar_get_code_by("DISPLAYKEY",200,"CLEARLIQUIDNOREDCOLORDIETPEDIADO")
 SET clear4_cd = uar_get_code_by("DISPLAYKEY",200,"CLEARLIQUIDBREAKFASTNPOLUNCH")
 SET fullliquid1_cd = uar_get_code_by("DISPLAYKEY",200,"FULLLIQUIDDIET")
 SET fullliquid2_cd = uar_get_code_by("DISPLAYKEY",200,"FULLLIQUIDDIETPEDIADOL")
 CALL echo(pharm_act_type_cd)
 FREE RECORD diet
 RECORD diet(
   1 cnt = i4
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 has_tpn_order = i4
     2 has_diet_order = i4
     2 has_clear_order = i4
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 name_full_formatted = vc
     2 encntr_type_cd = f8
     2 fmrn = vc
     2 acct_num = vc
     2 allergy_cnt = i4
     2 allergies[*]
       3 allergy_id = f8
       3 nomenclature_id = f8
       3 source_string = vc
       3 severity_cd = f8
     2 order_cnt = i4
     2 orders[*]
       3 order_id = f8
       3 activity_type_cd = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 order_status_cd = f8
       3 order_mnemonic = vc
       3 clinical_display_line = vc
       3 ingredients[*]
         4 component_seq = i4
         4 order_mnemonic = vc
         4 order_detail_display_line = vc
         4 hna_order_mnemonic = vc
         4 ordered_as_mnemonic = vc
       3 comments[*]
         4 long_text_id = f8
         4 order_comment = vc
 )
 SELECT
  IF (( $NURSE_UNIT=0))
   PLAN (ed
    WHERE ed.active_ind=1
     AND (ed.loc_facility_cd= $FACILITY)
     AND ed.end_effective_dt_tm > sysdate
     AND ed.loc_nurse_unit_cd != 0
     AND ed.loc_room_cd != 0
     AND ed.loc_bed_cd != 0)
    JOIN (e
    WHERE e.encntr_id=ed.encntr_id
     AND e.encntr_type_cd IN (inpatient_enc_type_cd, observation_enc_type_cd, daystay_enc_type_cd)
     AND e.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN e.beg_effective_dt_tm AND e.end_effective_dt_tm)
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (a
    WHERE a.person_id=outerjoin(e.person_id)
     AND a.substance_type_cd=outerjoin(food_allergy_type_cd)
     AND a.active_ind=outerjoin(1)
     AND a.reaction_status_cd=outerjoin(active_allergy_cd))
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
  ELSE
   PLAN (ed
    WHERE (ed.loc_nurse_unit_cd= $NURSE_UNIT)
     AND ed.end_effective_dt_tm > sysdate
     AND ed.loc_room_cd != 0
     AND ed.loc_bed_cd != 0
     AND ed.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=ed.encntr_id
     AND e.encntr_type_cd IN (inpatient_enc_type_cd, observation_enc_type_cd, daystay_enc_type_cd)
     AND e.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN e.beg_effective_dt_tm AND e.end_effective_dt_tm)
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (a
    WHERE a.person_id=outerjoin(e.person_id)
     AND a.substance_type_cd=outerjoin(food_allergy_type_cd)
     AND a.active_ind=outerjoin(1)
     AND a.reaction_status_cd=outerjoin(active_allergy_cd))
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
  ENDIF
  INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   person p,
   allergy a,
   nomenclature n
  ORDER BY e.encntr_id, n.nomenclature_id
  HEAD REPORT
   cnt = 0
  HEAD e.encntr_id
   cnt = (cnt+ 1), allergy_cnt = 0
   IF (mod(cnt,100)=1)
    stat = alterlist(diet->qual,(cnt+ 99))
   ENDIF
   diet->qual[cnt].encntr_id = e.encntr_id, diet->qual[cnt].person_id = e.person_id, diet->qual[cnt].
   encntr_type_cd = e.encntr_type_cd,
   diet->qual[cnt].loc_facility_cd = e.loc_facility_cd, diet->qual[cnt].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd, diet->qual[cnt].loc_room_cd = e.loc_room_cd,
   diet->qual[cnt].loc_bed_cd = e.loc_bed_cd, diet->qual[cnt].name_full_formatted = p
   .name_full_formatted, diet->qual[cnt].has_tpn_order = 0,
   diet->qual[cnt].has_diet_order = 0, diet->qual[cnt].has_diet_order = 0
  HEAD n.nomenclature_id
   IF (a.allergy_id > 0)
    allergy_cnt = (allergy_cnt+ 1)
    IF (mod(allergy_cnt,10)=1)
     stat = alterlist(diet->qual[cnt].allergies,(allergy_cnt+ 9))
    ENDIF
    diet->qual[cnt].allergies[allergy_cnt].allergy_id = a.allergy_id, diet->qual[cnt].allergies[
    allergy_cnt].nomenclature_id = n.nomenclature_id, diet->qual[cnt].allergies[allergy_cnt].
    source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,a
       .substance_ftdesc))),
    diet->qual[cnt].allergies[allergy_cnt].severity_cd = a.severity_cd
   ENDIF
  FOOT  e.encntr_id
   stat = alterlist(diet->qual[cnt].allergies,allergy_cnt), diet->qual[cnt].allergy_cnt = allergy_cnt
  FOOT REPORT
   stat = alterlist(diet->qual,cnt), diet->cnt = cnt
  WITH nocounter
 ;end select
 CALL echo("select1")
 SELECT INTO "nl:"
  FROM orders o,
   (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ( $TPN_OPTION IN (1, 3)))
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.active_ind=1
    AND (o.order_status_cd= $ORDER_STATUS)
    AND o.activity_type_cd IN (tube_continuous_cd, infant_formula_cd, infant_formula_add_cd,
   tube_feeding_add_cd, tube_feeding_bolus_cd,
   nut_services_consult_cd, supplements_cd, diets_cd, diet_spec_inst))
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ord_cnt = 0
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1), comment_cnt = 0
   IF (mod(ord_cnt,10)=1)
    stat = alterlist(diet->qual[d.seq].orders,(ord_cnt+ 9))
   ENDIF
   diet->qual[d.seq].orders[ord_cnt].order_id = o.order_id, diet->qual[d.seq].orders[ord_cnt].
   activity_type_cd = o.activity_type_cd, diet->qual[d.seq].orders[ord_cnt].catalog_cd = o.catalog_cd,
   diet->qual[d.seq].orders[ord_cnt].catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].orders[
   ord_cnt].order_mnemonic = o.order_mnemonic, diet->qual[d.seq].orders[ord_cnt].
   clinical_display_line = o.clinical_display_line,
   diet->qual[d.seq].orders[ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].
   has_diet_order = 1
  FOOT  o.encntr_id
   stat = alterlist(diet->qual[d.seq].orders,ord_cnt), diet->qual[d.seq].order_cnt = ord_cnt
  WITH nocounter
 ;end select
 CALL echo("select2")
 SELECT INTO "nl:"
  FROM orders o,
   (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ( $TPN_OPTION=4))
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.active_ind=1
    AND (o.order_status_cd= $ORDER_STATUS)
    AND o.catalog_cd IN (792547.00, 792549.00, 908254.00, 1547738.00))
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ord_cnt = 0
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1), comment_cnt = 0
   IF (mod(ord_cnt,10)=1)
    stat = alterlist(diet->qual[d.seq].orders,(ord_cnt+ 9))
   ENDIF
   diet->qual[d.seq].orders[ord_cnt].order_id = o.order_id, diet->qual[d.seq].orders[ord_cnt].
   activity_type_cd = o.activity_type_cd, diet->qual[d.seq].orders[ord_cnt].catalog_cd = o.catalog_cd,
   diet->qual[d.seq].orders[ord_cnt].catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].orders[
   ord_cnt].order_mnemonic = o.order_mnemonic, diet->qual[d.seq].orders[ord_cnt].
   clinical_display_line = o.clinical_display_line,
   diet->qual[d.seq].orders[ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].
   has_clear_order = 1
  FOOT  o.encntr_id
   stat = alterlist(diet->qual[d.seq].orders,ord_cnt), diet->qual[d.seq].order_cnt = ord_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_ingredient oi,
   (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ( $TPN_OPTION IN (1, 2)))
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.active_ind=1
    AND (o.order_status_cd= $ORDER_STATUS)
    AND o.activity_type_cd=pharm_act_type_cd
    AND o.order_mnemonic="TPN*")
   JOIN (oi
   WHERE oi.order_id=o.order_id
    AND oi.ingredient_type_flag=3
    AND oi.action_sequence=o.last_action_sequence)
  ORDER BY o.encntr_id, o.order_id, oi.comp_sequence
  HEAD o.encntr_id
   row + 0
  HEAD o.order_id
   diet->qual[d.seq].order_cnt = (diet->qual[d.seq].order_cnt+ 1), ord_cnt = diet->qual[d.seq].
   order_cnt, ing_cnt = 0,
   stat = alterlist(diet->qual[d.seq].orders,ord_cnt), diet->qual[d.seq].orders[ord_cnt].order_id = o
   .order_id, diet->qual[d.seq].orders[ord_cnt].activity_type_cd = o.activity_type_cd,
   diet->qual[d.seq].orders[ord_cnt].catalog_cd = o.catalog_cd, diet->qual[d.seq].orders[ord_cnt].
   catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].orders[ord_cnt].order_mnemonic = o
   .order_mnemonic,
   diet->qual[d.seq].orders[ord_cnt].clinical_display_line = o.clinical_display_line, diet->qual[d
   .seq].orders[ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].has_tpn_order = 1
  DETAIL
   ing_cnt = (ing_cnt+ 1)
   IF (mod(ing_cnt,10)=1)
    stat = alterlist(diet->qual[d.seq].orders[ord_cnt].ingredients,(ing_cnt+ 9))
   ENDIF
   diet->qual[d.seq].orders[ord_cnt].ingredients[ing_cnt].component_seq = oi.comp_sequence, diet->
   qual[d.seq].orders[ord_cnt].ingredients[ing_cnt].order_mnemonic = oi.order_mnemonic, diet->qual[d
   .seq].orders[ord_cnt].ingredients[ing_cnt].hna_order_mnemonic = oi.hna_order_mnemonic,
   diet->qual[d.seq].orders[ord_cnt].ingredients[ing_cnt].ordered_as_mnemonic = oi
   .ordered_as_mnemonic, diet->qual[d.seq].orders[ord_cnt].ingredients[ing_cnt].
   order_detail_display_line = oi.order_detail_display_line
  FOOT  o.order_id
   stat = alterlist(diet->qual[d.seq].orders[ord_cnt].ingredients,ing_cnt)
  WITH nocounter
 ;end select
 FREE RECORD cmts
 RECORD cmts(
   1 qual[*]
     2 index1 = i4
     2 index2 = i4
     2 order_id = f8
 )
 DECLARE cmt_cnt = i4
 SET cmt_cnt = 0
 FOR (i = 1 TO diet->cnt)
   FOR (j = 1 TO diet->qual[i].order_cnt)
     SET cmt_cnt = (cmt_cnt+ 1)
     IF (mod(cmt_cnt,100)=1)
      SET stat = alterlist(cmts->qual,(cmt_cnt+ 99))
     ENDIF
     SET cmts->qual[cmt_cnt].index1 = i
     SET cmts->qual[cmt_cnt].index2 = j
     SET cmts->qual[cmt_cnt].order_id = diet->qual[i].orders[j].order_id
   ENDFOR
 ENDFOR
 SET stat = alterlist(cmts->qual,cmt_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cmt_cnt)),
   order_comment oc,
   long_text lt
  PLAN (d)
   JOIN (oc
   WHERE (oc.order_id=cmts->qual[d.seq].order_id))
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
  DETAIL
   idx = (size(diet->qual[cmts->qual[d.seq].index1].orders[cmts->qual[d.seq].index2].comments,5)+ 1),
   stat = alterlist(diet->qual[cmts->qual[d.seq].index1].orders[cmts->qual[d.seq].index2].comments,
    idx), diet->qual[cmts->qual[d.seq].index1].orders[cmts->qual[d.seq].index2].comments[idx].
   order_comment = trim(lt.long_text)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(diet->cnt)),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=diet->qual[d.seq].encntr_id)
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm)
  DETAIL
   IF (uar_get_code_display(ea.encntr_alias_type_cd)="MRN")
    diet->qual[d.seq].fmrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSE
    diet->qual[d.seq].acct_num = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(diet)
 DECLARE allergy_string = vc
 DECLARE order_string = vc
 DECLARE tempstring = vc
 SELECT INTO  $OUTDEV
  encntr_id = diet->qual[d.seq].encntr_id, loc_facility = substring(1,30,uar_get_code_display(diet->
    qual[d.seq].loc_facility_cd)), loc_nurse_unit = substring(1,30,uar_get_code_display(diet->qual[d
    .seq].loc_nurse_unit_cd)),
  loc_room = substring(1,5,uar_get_code_display(diet->qual[d.seq].loc_room_cd)), loc_bed = substring(
   1,5,uar_get_code_display(diet->qual[d.seq].loc_bed_cd)), room_and_bed = build(trim(
    uar_get_code_display(diet->qual[d.seq].loc_room_cd)),"/",trim(uar_get_code_display(diet->qual[d
     .seq].loc_bed_cd))),
  enc_type_disp = substring(1,20,uar_get_code_display(diet->qual[d.seq].encntr_type_cd)),
  patient_name = substring(1,30,diet->qual[d.seq].name_full_formatted), fmrn = diet->qual[d.seq].fmrn,
  acct_num = diet->qual[d.seq].acct_num
  FROM (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ((( $TPN_OPTION=1)) OR (((( $TPN_OPTION=2)
    AND (diet->qual[d.seq].has_tpn_order=1)) OR (((( $TPN_OPTION=3)
    AND (diet->qual[d.seq].has_diet_order=1)) OR (( $TPN_OPTION=4)
    AND (diet->qual[d.seq].has_clear_order=1))) )) )) )
  ORDER BY loc_facility, loc_nurse_unit, loc_room,
   loc_bed
  HEAD REPORT
   event_len = 0, date_len = 0, line = fillstring(120,"="),
   line2 = fillstring(120,"*"), xcol = 0, ycol = 0,
   temp1 = fillstring(500,""), temp2 = fillstring(500,""), sord_cnt = 0,
   pord_cnt = 0, cord_cnt = 0, breakflag = 0,
   xcolvar = 0, wrapcol = 0, boldflag = 0,
   underflag = 0, leftindentsize = 0,
   MACRO (rowplusone)
    ycol = (ycol+ 10), row + 1
    IF (ycol > 710)
     BREAK
    ENDIF
   ENDMACRO
   ,
   MACRO (rowplusone2)
    ycol = (ycol+ 10), row + 1
   ENDMACRO
   ,
   MACRO (line_wrap)
    limit = 0, maxlen = wrapcol, cr = char(10),
    initialloop = 1
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0,
      tempstring = trim(tempstring,2)
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      printstring = substring(1,pos,tempstring)
      IF (boldflag=1)
       printstring = concat("{B}",printstring,"{ENDB}")
      ENDIF
      IF (underflag=1)
       printstring = concat("{U}",printstring,"{ENDU}")
      ENDIF
      CALL print(calcpos(xcol,ycol)), printstring
      IF (limit=1)
       maxlen = (maxlen - 5)
      ENDIF
      IF (breakflag=1)
       rowplusone
      ELSE
       rowplusone2
      ENDIF
      tempstring = substring((pos+ 1),size(tempstring),tempstring)
      IF (initialloop=1)
       xcol = (xcol+ leftindentsize), initialloop = 0
      ENDIF
    ENDWHILE
   ENDMACRO
  HEAD PAGE
   "{cpi/10}", row + 1, ycol = 30,
   CALL print(calcpos(0,ycol)), "{CENTER/Baystate Health System/8/5}", row + 1,
   ycol = (ycol+ 15),
   CALL print(calcpos(0,ycol)), "{CENTER/Dietary Master Report/8/5}",
   row + 1, "{cpi/14}", row + 1,
   xcol = 30, ycol = (ycol+ 20),
   CALL print(calcpos(xcol,ycol)),
   "Run Time: ", curdate, " ",
   curtime, row + 1, ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)), "Facility: ", loc_facility,
   row + 1, ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)),
   "Nurse Unit: ", loc_nurse_unit, row + 1,
   ycol = (ycol+ 10)
  HEAD loc_nurse_unit
   row + 0
  HEAD loc_bed
   row + 0
  HEAD encntr_id
   IF (ycol > 700)
    BREAK
   ENDIF
   CALL print(calcpos(50,ycol)), room_and_bed, row + 1,
   CALL print(calcpos(100,ycol)), patient_name, row + 1,
   CALL print(calcpos(350,ycol)), fmrn, row + 1,
   CALL print(calcpos(400,ycol)), acct_num, row + 1,
   CALL print(calcpos(460,ycol)), enc_type_disp, row + 1,
   ycol = (ycol+ 10)
   IF ((diet->qual[d.seq].allergy_cnt > 0))
    tempstring = concat("Allergies: ",trim(diet->qual[d.seq].allergies[1].source_string))
    FOR (i = 2 TO diet->qual[d.seq].allergy_cnt)
      tempstring = concat(tempstring,", ",trim(diet->qual[d.seq].allergies[i].source_string))
    ENDFOR
    xcol = 50, wrapcol = 110, boldflag = 1,
    line_wrap, boldflag = 0
   ENDIF
   IF ((diet->qual[d.seq].order_cnt > 0))
    FOR (i = 1 TO diet->qual[d.seq].order_cnt)
      IF (ycol > 700)
       BREAK
      ENDIF
      tempstring = substring(1,500,trim(concat(trim(diet->qual[d.seq].orders[i].order_mnemonic)," ",
         trim(diet->qual[d.seq].orders[i].clinical_display_line)," (",trim(uar_get_code_display(diet
           ->qual[d.seq].orders[i].order_status_cd)),
         ")"))), xcol = 75, wrapcol = 95,
      leftindentsize = 10, line_wrap, leftindentsize = 0
      IF (size(diet->qual[d.seq].orders[i].ingredients,5) > 0)
       CALL print(calcpos(75,ycol)), "{B}Order Ingredients: {ENDB}", row + 1,
       ycol = (ycol+ 10)
      ENDIF
      FOR (j = 1 TO size(diet->qual[d.seq].orders[i].ingredients,5))
        IF (ycol > 700)
         BREAK
        ENDIF
        beg_ycol = ycol, tempstring = concat(trim(diet->qual[d.seq].orders[i].ingredients[j].
          hna_order_mnemonic)," (",trim(diet->qual[d.seq].orders[i].ingredients[j].
          ordered_as_mnemonic),")"), xcol = 85,
        wrapcol = 53, leftindentsize = 5, line_wrap,
        leftindentsize = 0, end_ycol = ycol, ycol = beg_ycol,
        tempstring = trim(diet->qual[d.seq].orders[i].ingredients[j].order_detail_display_line), xcol
         = 350, wrapcol = 50,
        leftindentsize = 5, line_wrap, leftindentsize = 0
        IF (end_ycol > ycol)
         ycol = end_ycol
        ENDIF
      ENDFOR
      FOR (k = 1 TO size(diet->qual[d.seq].orders[i].comments,5))
        IF ((diet->qual[d.seq].orders[i].comments[k].order_comment > " "))
         CALL print(calcpos(75,ycol)), "{B}Order Comment: {ENDB}", row + 1,
         tempstring = diet->qual[d.seq].orders[i].comments[k].order_comment, xcol = 150, wrapcol = 80,
         leftindentsize = 0, line_wrap
        ENDIF
      ENDFOR
      ycol = (ycol+ 5)
    ENDFOR
   ENDIF
  FOOT  encntr_id
   ycol = (ycol+ 5)
  FOOT  loc_nurse_unit
   IF ( NOT (curendreport))
    BREAK
   ENDIF
  WITH dio = 8, maxrow = 10000, maxcol = 1000
 ;end select
#exitscript
END GO
