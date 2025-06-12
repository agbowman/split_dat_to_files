CREATE PROGRAM bed_ext_mos_ord_sent
 PROMPT
  "Number of days to extract (max. 180): " = "   "
 DECLARE nbr_of_days = vc
 SET nbr_of_days =  $1
 SET check_numeric = isnumeric(nbr_of_days)
 IF (check_numeric != 1)
  CALL echo("*** entry is not numeric ***")
  GO TO exit_program
 ENDIF
 DECLARE inc_lookback_days = i4
 SET inc_lookback_days = cnvtint(nbr_of_days)
 IF (inc_lookback_days > 180)
  CALL echo("*** entry is > 180 ***")
  GO TO exit_program
 ENDIF
 SET inc_min_ord_threshold = 3
 DECLARE sentence_line = vc
 DECLARE out_line = vc
 SET cpharm = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET batch_number = 0
 SET cur_lookback_day = inc_lookback_days
 FREE RECORD list
 RECORD list(
   1 orders[*]
     2 mmdc_cki = vc
     2 order_sentence = vc
     2 count = f8
     2 strengthdose = vc
     2 strengthdoseunit = vc
     2 volumedose = vc
     2 volumedoseunit = vc
     2 rxroute = vc
     2 freq = vc
     2 schprn = vc
     2 prnreason = vc
     2 rate = vc
     2 rateunit = vc
     2 freetextrate = vc
     2 infuseover = vc
     2 infuseoverunit = vc
     2 rxpriority = vc
 )
 WHILE (cur_lookback_day > 0)
   SET batch_number = (batch_number+ 1)
   CALL echo("------------------------------------------------")
   CALL echo(build("Processing day number: ",batch_number))
   CALL echo(build("Days remaining: ",(cur_lookback_day - 1)))
   CALL echo("------------------------------------------------")
   SELECT INTO "nl:"
    o.order_id, oi.ingredient_type_flag, o.iv_ind,
    order_name = substring(1,40,o.order_mnemonic), mmdc = md.cki, strengthdose = od1.oe_field_value,
    strengthdoseunit = uar_get_code_display(od2.oe_field_value), volumedose = od3.oe_field_value,
    volumedoseunit = uar_get_code_display(od4.oe_field_value),
    frequency = uar_get_code_display(od8.oe_field_value), route = uar_get_code_display(od5
     .oe_field_value), prn = od6.oe_field_value,
    prn_reason = uar_get_code_display(od7.oe_field_value), freetextrate = od9.oe_field_display_value,
    rate = od10.oe_field_value,
    rateunit = uar_get_code_display(od11.oe_field_value), infuseover = od12.oe_field_value,
    infuseoverunit = uar_get_code_display(od13.oe_field_value),
    rxpriority = uar_get_code_display(od14.oe_field_value)
    FROM orders o,
     order_product op,
     order_ingredient oi,
     medication_definition md,
     order_detail od1,
     order_detail od2,
     order_detail od3,
     order_detail od4,
     order_detail od5,
     order_detail od6,
     order_detail od7,
     order_detail od8,
     order_detail od9,
     order_detail od10,
     order_detail od11,
     order_detail od12,
     order_detail od13,
     order_detail od14
    PLAN (o
     WHERE o.catalog_type_cd=cpharm
      AND o.orig_order_dt_tm > cnvtdatetime((curdate - cur_lookback_day),curtime3)
      AND o.orig_order_dt_tm < cnvtdatetime(((curdate - cur_lookback_day)+ 1),curtime3)
      AND o.orig_ord_as_flag=0
      AND o.template_order_flag IN (0, 1)
      AND o.cs_flag != 1
      AND ((o.iv_ind = null) OR (o.iv_ind=0)) )
     JOIN (op
     WHERE op.order_id=o.order_id
      AND op.action_sequence=1)
     JOIN (oi
     WHERE oi.order_id=op.order_id
      AND oi.comp_sequence=op.ingred_sequence
      AND oi.action_sequence=1
      AND oi.ingredient_type_flag IN (1, 3))
     JOIN (md
     WHERE op.item_id=md.item_id
      AND md.cki IS NOT null
      AND trim(md.cki) >= " ")
     JOIN (od1
     WHERE od1.order_id=outerjoin(o.order_id)
      AND od1.oe_field_meaning=outerjoin("STRENGTHDOSE")
      AND od1.action_sequence=outerjoin(1))
     JOIN (od2
     WHERE od2.order_id=outerjoin(o.order_id)
      AND od2.oe_field_meaning=outerjoin("STRENGTHDOSEUNIT")
      AND od2.action_sequence=outerjoin(1))
     JOIN (od3
     WHERE od3.order_id=outerjoin(o.order_id)
      AND od3.oe_field_meaning=outerjoin("VOLUMEDOSE")
      AND od3.action_sequence=outerjoin(1))
     JOIN (od4
     WHERE od4.order_id=outerjoin(o.order_id)
      AND od4.oe_field_meaning=outerjoin("VOLUMEDOSEUNIT")
      AND od4.action_sequence=outerjoin(1))
     JOIN (od5
     WHERE od5.order_id=outerjoin(o.order_id)
      AND od5.oe_field_meaning=outerjoin("RXROUTE")
      AND od5.action_sequence=outerjoin(1))
     JOIN (od6
     WHERE od6.order_id=outerjoin(o.order_id)
      AND od6.oe_field_meaning=outerjoin("SCH/PRN")
      AND od6.action_sequence=outerjoin(1))
     JOIN (od7
     WHERE od7.order_id=outerjoin(o.order_id)
      AND od7.oe_field_meaning=outerjoin("PRNREASON")
      AND od7.action_sequence=outerjoin(1))
     JOIN (od8
     WHERE od8.order_id=outerjoin(o.order_id)
      AND od8.oe_field_meaning=outerjoin("FREQ")
      AND od8.action_sequence=outerjoin(1))
     JOIN (od9
     WHERE od9.order_id=outerjoin(o.order_id)
      AND od9.oe_field_meaning=outerjoin("FREETEXTRATE")
      AND od9.action_sequence=outerjoin(1))
     JOIN (od10
     WHERE od10.order_id=outerjoin(o.order_id)
      AND od10.oe_field_meaning=outerjoin("RATE")
      AND od10.action_sequence=outerjoin(1))
     JOIN (od11
     WHERE od11.order_id=outerjoin(o.order_id)
      AND od11.oe_field_meaning=outerjoin("RATEUNIT")
      AND od11.action_sequence=outerjoin(1))
     JOIN (od12
     WHERE od12.order_id=outerjoin(o.order_id)
      AND od12.oe_field_meaning=outerjoin("INFUSEOVER")
      AND od12.action_sequence=outerjoin(1))
     JOIN (od13
     WHERE od13.order_id=outerjoin(o.order_id)
      AND od13.oe_field_meaning=outerjoin("INFUSEOVERUNIT")
      AND od13.action_sequence=outerjoin(1))
     JOIN (od14
     WHERE od14.order_id=outerjoin(o.order_id)
      AND od14.oe_field_meaning=outerjoin("RXPRIORITY")
      AND od14.action_sequence=outerjoin(1))
    ORDER BY md.cki, o.order_id
    HEAD REPORT
     cnt = 0, assigned = 0, sentence_pos = 0,
     mmdc_begin_pos = 0, str_flag = 0, err_flag = 0
    HEAD md.cki
     mmdc_begin_pos = 0
    HEAD o.order_id
     cnt = (cnt+ 1), sentence_pos = 0, str_flag = 0,
     err_flag = 0, sentence_line = "Error"
     IF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0
      AND od3.oe_field_value > 0
      AND od4.oe_field_value > 0)
      str_flag = 1, sentence_line = concat(build(num_to_str(od1.oe_field_value))," ",trim(
        strengthdoseunit)," / ",build(num_to_str(od3.oe_field_value)),
       " ",trim(volumedoseunit))
     ELSEIF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0)
      str_flag = 1, sentence_line = concat(build(num_to_str(od1.oe_field_value))," ",trim(
        strengthdoseunit))
     ELSEIF (od3.oe_field_value > 0
      AND od4.oe_field_value > 0)
      sentence_line = concat(build(num_to_str(od3.oe_field_value))," ",trim(volumedoseunit))
     ELSE
      err_flag = 1
     ENDIF
     IF (od8.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ",trim(frequency))
     ENDIF
     IF (od14.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ",trim(rxpriority))
     ENDIF
     sentence_line = concat(sentence_line,", ",route)
     IF (prn=1)
      sentence_line = concat(sentence_line,", ","PRN")
     ENDIF
     IF (od7.oe_field_value > 0)
      sentence_line = concat(sentence_line,", ","reason: ",trim(prn_reason))
     ENDIF
     IF (od10.oe_field_value > 0
      AND o.iv_ind=1)
      sentence_line = concat(sentence_line,", ",cnvtstring(rate,11,3))
     ENDIF
     IF (od11.oe_field_value > 0
      AND o.iv_ind=1)
      sentence_line = concat(sentence_line," ",rateunit)
     ENDIF
     IF (trim(freetextrate) > " ")
      sentence_line = concat(sentence_line,", ",trim(freetextrate))
     ENDIF
     IF (od12.oe_field_value > 0
      AND ((o.iv_ind=0) OR (o.iv_ind = null)) )
      sentence_line = concat(sentence_line,", ",cnvtstring(infuseover,11,3))
     ENDIF
     IF (od13.oe_field_value > 0
      AND ((o.iv_ind=0) OR (o.iv_ind = null)) )
      sentence_line = concat(sentence_line," ",infuseoverunit)
     ENDIF
     IF (size(list->orders,5)=0
      AND err_flag=0)
      stat = alterlist(list->orders,1), list->orders[1].mmdc_cki = trim(md.cki), list->orders[1].
      order_sentence = sentence_line,
      list->orders[1].count = 1, assigned = (assigned+ 1), mmdc_begin_pos = 1
      IF (str_flag=1)
       list->orders[1].strengthdose = build(num_to_str(od1.oe_field_value)), list->orders[1].
       strengthdoseunit = strengthdoseunit
      ELSE
       list->orders[1].volumedose = build(num_to_str(od3.oe_field_value)), list->orders[1].
       volumedoseunit = volumedoseunit
      ENDIF
      list->orders[1].rxroute = route, list->orders[1].freq = frequency, list->orders[1].rxpriority
       = rxpriority,
      list->orders[1].schprn = trim(cnvtstring(prn,11,0)), list->orders[1].prnreason = prn_reason
      IF (rate > 0
       AND o.iv_ind=1)
       list->orders[1].rate = trim(cnvtstring(rate,11,3)), list->orders[1].rateunit = rateunit
      ENDIF
      list->orders[1].freetextrate = freetextrate
      IF (infuseover > 0
       AND ((o.iv_ind = null) OR (o.iv_ind=0)) )
       list->orders[1].infuseover = trim(cnvtstring(infuseover,11,3)), list->orders[1].infuseoverunit
        = infuseoverunit
      ENDIF
     ELSEIF (err_flag=0)
      sentence_pos = find_sentence_pos_mmdc(trim(md.cki),sentence_line)
      IF ((list->orders[sentence_pos].order_sentence=sentence_line)
       AND sentence_line != "Error"
       AND sentence_pos > 0)
       list->orders[sentence_pos].count = (list->orders[sentence_pos].count+ 1), assigned = (assigned
       + 1)
      ELSE
       stat = alterlist(list->orders,(size(list->orders,5)+ 1)), list->orders[size(list->orders,5)].
       mmdc_cki = trim(md.cki), list->orders[size(list->orders,5)].order_sentence = sentence_line,
       list->orders[size(list->orders,5)].count = 1, assigned = (assigned+ 1), mmdc_begin_pos = size(
        list->orders,5)
       IF (str_flag=1)
        list->orders[size(list->orders,5)].strengthdose = build(num_to_str(od1.oe_field_value)), list
        ->orders[size(list->orders,5)].strengthdoseunit = strengthdoseunit
       ELSE
        list->orders[size(list->orders,5)].volumedose = build(num_to_str(od3.oe_field_value)), list->
        orders[size(list->orders,5)].volumedoseunit = volumedoseunit
       ENDIF
       list->orders[size(list->orders,5)].rxroute = route, list->orders[size(list->orders,5)].freq =
       frequency, list->orders[size(list->orders,5)].rxpriority = rxpriority,
       list->orders[size(list->orders,5)].schprn = trim(cnvtstring(prn,11,0)), list->orders[size(list
        ->orders,5)].prnreason = prn_reason
       IF (rate > 0
        AND o.iv_ind=1)
        list->orders[size(list->orders,5)].rate = trim(cnvtstring(rate,11,3)), list->orders[size(list
         ->orders,5)].rateunit = rateunit
       ENDIF
       list->orders[size(list->orders,5)].freetextrate = freetextrate
       IF (infuseover > 0
        AND ((o.iv_ind = null) OR (o.iv_ind=0)) )
        list->orders[size(list->orders,5)].infuseover = trim(cnvtstring(infuseover,11,3)), list->
        orders[size(list->orders,5)].infuseoverunit = infuseoverunit
       ENDIF
      ENDIF
     ENDIF
    WITH nullreport, nocounter
   ;end select
   SET cur_lookback_day = (cur_lookback_day - 1)
 ENDWHILE
 CALL echo("------------------------")
 CALL echo("Creating output file... ")
 CALL echo("------------------------")
 SELECT INTO "br_order_sentences.csv"
  dnum = nmdc.drug_identifier, generic_name = dn1.drug_name, mmdc = substring(1,16,list->orders[d.seq
   ].mmdc_cki),
  description = dn2.drug_name, sentence = substring(1,100,list->orders[d.seq].order_sentence), count
   = cnvtstring(list->orders[d.seq].count,3,0)
  FROM (dummyt d  WITH seq = value(size(list->orders,5))),
   mltm_ndc_main_drug_code nmdc,
   mltm_mmdc_name_map mnm1,
   mltm_mmdc_name_map mnm2,
   mltm_drug_name dn1,
   mltm_drug_name dn2
  PLAN (d
   WHERE (list->orders[d.seq].count >= inc_min_ord_threshold))
   JOIN (nmdc
   WHERE nmdc.main_multum_drug_code=cnvtreal(trim(substring(12,18,list->orders[d.seq].mmdc_cki))))
   JOIN (mnm1
   WHERE nmdc.main_multum_drug_code=mnm1.main_multum_drug_code
    AND mnm1.function_id=16)
   JOIN (dn1
   WHERE mnm1.drug_synonym_id=dn1.drug_synonym_id)
   JOIN (mnm2
   WHERE nmdc.main_multum_drug_code=mnm2.main_multum_drug_code
    AND mnm2.function_id=59)
   JOIN (dn2
   WHERE mnm2.drug_synonym_id=dn2.drug_synonym_id)
  ORDER BY list->orders[d.seq].mmdc_cki, list->orders[d.seq].count DESC
  HEAD REPORT
   order_cnt = 0, col 0, "GENERIC,",
   "ORDER_CAT_CKI,", "MMDC,", "MMDC_DESC,",
   "COUNT,", "SCRIPT,", "STRENGTHDOSE,",
   "STRENGTHDOSEUNIT,", "VOLUMEDOSE,", "VOLUMEDOSEUNIT,",
   "FREQ,", "PRIORITY,", "RXROUTE,",
   "SCH_PRN,", "PRNREASON,", "SPECINX,",
   "RATE,", "RATEUNIT,", "FREETEXTRATE,",
   "INFUSEOVER,", "INFUSEOVERUNIT,", "DURATION,",
   "DURATIONUNIT"
  DETAIL
   order_cnt = (order_cnt+ 1), row + 1, out_line = concat('"',trim(dn1.drug_name),'"',",",'"',
    concat("MUL.ORD!",trim(nmdc.drug_identifier)),'"',",",'"',trim(list->orders[d.seq].mmdc_cki),
    '"',",",'"',trim(dn2.drug_name),'"',
    ",",'"',trim(cnvtstring(list->orders[d.seq].count)),'"',",",
    '"',trim(list->orders[d.seq].order_sentence),'"',",",'"',
    trim(list->orders[d.seq].strengthdose),'"',",",'"',trim(list->orders[d.seq].strengthdoseunit),
    '"',",",'"',trim(list->orders[d.seq].volumedose),'"',
    ",",'"',trim(list->orders[d.seq].volumedoseunit),'"',",",
    '"',trim(list->orders[d.seq].freq),'"',",",'"',
    trim(list->orders[d.seq].rxpriority),'"',",",'"',trim(list->orders[d.seq].rxroute),
    '"',",",'"',trim(list->orders[d.seq].schprn),'"',
    ",",'"',trim(list->orders[d.seq].prnreason),'"',",",
    '"','"',",",'"',trim(list->orders[d.seq].rate),
    '"',",",'"',trim(list->orders[d.seq].rateunit),'"',
    ",",'"',trim(list->orders[d.seq].freetextrate),'"',",",
    '"',trim(list->orders[d.seq].infuseover),'"',",",'"',
    trim(list->orders[d.seq].infuseoverunit),'"',",",'"','"',
    ",",'"','"'),
   col 0, out_line
  FOOT REPORT
   CALL echo("."),
   CALL echo("------------------------------------------------"),
   CALL echo(build("Processing complete")),
   CALL echo(build("Results written to CCLUSERDIR file: br_order_sentences.csv")),
   CALL echo(concat("Total unqiue orders meeting minimum threshold: ",build(order_cnt))),
   CALL echo("------------------------------------------------")
   IF (order_cnt > 65535)
    CALL echo(build("... WARNING!!! ...")),
    CALL echo(build("Results exceeded maximum Excel row count")),
    CALL echo(build("Recommend increasing minimum order threshold")),
    CALL echo("------------------------------------------------")
   ENDIF
  WITH check, maxcol = 1500, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1, nocounter
 ;end select
 SUBROUTINE find_sentence_pos_mmdc(inc_mmdc,inc_sent)
   DECLARE result = f8
   SET result = 0
   SET pos = 0
   SET search_loc = 0
   SET start_loc = 1
   WHILE (start_loc <= size(list->orders,5)
    AND result=0)
    SET pos = locateval(search_loc,start_loc,size(list->orders,5),inc_mmdc,list->orders[search_loc].
     mmdc_cki)
    IF ((list->orders[search_loc].mmdc_cki=inc_mmdc)
     AND trim(list->orders[search_loc].order_sentence)=trim(inc_sent))
     SET result = search_loc
    ELSE
     SET start_loc = (search_loc+ 1)
    ENDIF
   ENDWHILE
   RETURN(result)
 END ;Subroutine
 SUBROUTINE num_to_str(inc_num)
   DECLARE cur_string = c15
   SET decimal_loc = 0
   SET cur_string = cnvtstring(inc_num,15,3)
   SET cur_pos = textlen(cnvtstring(inc_num,15,3))
   SET decimal_loc = findstring(".",cur_string,1)
   SET trim_flag = false
   SET trim_finished = false
   SET trim_pos = 0
   WHILE (cur_pos > 1
    AND cur_pos >= decimal_loc
    AND decimal_loc > 0
    AND trim_finished=false)
    IF (isnumeric(substring(cur_pos,1,cur_string))
     AND trim_finished=false)
     IF (substring(cur_pos,1,cur_string)="0"
      AND trim_finished=false)
      SET trim_flag = true
      SET trim_pos = cur_pos
     ELSE
      SET trim_finished = true
      SET trim_pos = cur_pos
     ENDIF
    ENDIF
    SET cur_pos = (cur_pos - 1)
   ENDWHILE
   IF (substring(trim_pos,1,cur_string)=".")
    SET trim_pos = (trim_pos - 1)
   ENDIF
   RETURN(substring(1,trim_pos,cur_string))
 END ;Subroutine
#exit_program
END GO
