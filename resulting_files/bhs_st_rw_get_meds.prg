CREATE PROGRAM bhs_st_rw_get_meds
 RECORD med_pt_info(
   1 person_id = f8
   1 encntr_id = f8
 ) WITH persist
 IF (cnvtreal(parameter(1,0)) > 0.00)
  SET med_pt_info->person_id = cnvtreal( $1)
 ENDIF
 IF (cnvtreal(parameter(2,0)) > 0.00)
  SET med_pt_info->encntr_id = cnvtreal( $2)
 ENDIF
 IF (((med_pt_info->person_id+ med_pt_info->encntr_id) <= 0.00))
  CALL echo("No valid PERSON_ID or ENCNTR_ID given. Exitting Script")
  GO TO exit_script
 ENDIF
 FREE RECORD med_info
 RECORD med_info(
   1 m_cnt = i4
   1 meds[*]
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 sig = vc
     2 fields[*]
       3 value = vc
   1 r_cnt = i4
   1 rx[*]
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 sig = vc
     2 fields[*]
       3 value = vc
   1 f_cnt = i4
   1 fields[*]
     2 meaning = vc
 ) WITH persist
 DECLARE cs106_pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_medstudent_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE cs6004_pendingrev_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDINGREV"))
 DECLARE cs6004_unscheduled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
 DECLARE add_oe_field(meaning=vc) = null
 DECLARE add_to_sig(value=vc) = null
 DECLARE var_freetextord_slot = i4
 CALL add_oe_field("FREETEXTORD")
 SET var_freetextord_slot = med_info->f_cnt
 DECLARE var_strengthdose_slot = i4
 CALL add_oe_field("STRENGTHDOSE")
 SET var_strengthdose_slot = med_info->f_cnt
 DECLARE var_strengthdoseunit_slot = i4
 CALL add_oe_field("STRENGTHDOSEUNIT")
 SET var_strengthdoseunit_slot = med_info->f_cnt
 DECLARE var_volumedose_slot = i4
 CALL add_oe_field("VOLUMEDOSE")
 SET var_volumedose_slot = med_info->f_cnt
 DECLARE var_volumedoseunit_slot = i4
 CALL add_oe_field("VOLUMEDOSEUNIT")
 SET var_volumedoseunit_slot = med_info->f_cnt
 DECLARE var_freetxtdose_slot = i4
 CALL add_oe_field("FREETXTDOSE")
 SET var_freetxtdose_slot = med_info->f_cnt
 DECLARE var_rxroute_slot = i4
 CALL add_oe_field("RXROUTE")
 SET var_rxroute_slot = med_info->f_cnt
 DECLARE var_freq_slot = i4
 CALL add_oe_field("FREQ")
 SET var_freq_slot = med_info->f_cnt
 DECLARE var_duration_slot = i4
 CALL add_oe_field("DURATION")
 SET var_duration_slot = med_info->f_cnt
 DECLARE var_durationunit_slot = i4
 CALL add_oe_field("DURATIONUNIT")
 SET var_durationunit_slot = med_info->f_cnt
 DECLARE var_specinx_slot = i4
 CALL add_oe_field("SPECINX")
 SET var_specinx_slot = med_info->f_cnt
 FREE SET add_oe_field
 SUBROUTINE add_oe_field(meaning)
   IF (trim(meaning,4) <= " ")
    CALL echo("No valid meaning given.")
   ELSE
    SET tmp = (med_info->f_cnt+ 1)
    SET stat = alterlist(med_info->fields,tmp)
    SET med_info->f_cnt = tmp
    SET med_info->fields[tmp].meaning = trim(meaning,4)
    FREE SET tmp
   ENDIF
 END ;Subroutine
 SUBROUTINE add_to_sig(add_value,slot,type)
   IF (type="M")
    IF (trim(add_value,3) > " ")
     SET med_info->meds[slot].sig = build2(med_info->meds[slot].sig," ",trim(add_value,3))
    ENDIF
   ELSEIF (type="R")
    IF (trim(add_value,3) > " ")
     SET med_info->rx[slot].sig = build2(med_info->rx[slot].sig," ",trim(add_value,3))
    ENDIF
   ENDIF
 END ;Subroutine
 SELECT INTO "NL:"
  o.ordered_as_mnemonic, o.order_mnemonic, od.action_sequence,
  d.seq
  FROM orders o,
   order_detail od,
   (dummyt d  WITH seq = value(med_info->f_cnt))
  PLAN (o
   WHERE (o.person_id=med_pt_info->person_id)
    AND o.activity_type_cd=cs106_pharmacy_cd
    AND ((o.order_status_cd+ 0) IN (cs6004_inprocess_cd, cs6004_medstudent_cd, cs6004_ordered_cd,
   cs6004_pending_cd, cs6004_pendingrev_cd,
   cs6004_unscheduled_cd))
    AND o.template_order_id=0.00)
   JOIN (od
   WHERE o.order_id=od.order_id)
   JOIN (d
   WHERE (od.oe_field_meaning=med_info->fields[d.seq].meaning))
  ORDER BY o.orig_order_dt_tm, o.order_id, od.action_sequence,
   d.seq
  HEAD REPORT
   m_cnt = 0, r_cnt = 0
  HEAD o.order_id
   IF (o.orig_ord_as_flag=0)
    m_cnt = (med_info->m_cnt+ 1), stat = alterlist(med_info->meds,m_cnt), med_info->m_cnt = m_cnt,
    med_info->meds[m_cnt].ordered_as_mnemonic = o.hna_order_mnemonic, med_info->meds[m_cnt].
    order_mnemonic = o.ordered_as_mnemonic
   ELSE
    r_cnt = (med_info->r_cnt+ 1), stat = alterlist(med_info->rx,r_cnt), med_info->r_cnt = r_cnt,
    med_info->rx[r_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, med_info->rx[r_cnt].
    order_mnemonic = o.order_mnemonic
   ENDIF
  HEAD od.action_sequence
   IF (od.action_sequence <= 1)
    IF (o.orig_ord_as_flag=0)
     med_info->meds[m_cnt].sig = o.clinical_display_line, stat = alterlist(med_info->meds[m_cnt].
      fields,med_info->f_cnt)
    ELSE
     stat = alterlist(med_info->rx[r_cnt].fields,med_info->f_cnt)
    ENDIF
   ENDIF
  DETAIL
   IF (o.orig_ord_as_flag=0)
    med_info->meds[m_cnt].fields[d.seq].value = trim(od.oe_field_display_value,3)
   ELSE
    med_info->rx[r_cnt].fields[d.seq].value = trim(od.oe_field_display_value,3)
   ENDIF
  FOOT  o.order_id
   IF (o.orig_ord_as_flag=0)
    IF ((med_info->meds[m_cnt].fields[var_freetextord_slot].value > " "))
     med_info->meds[m_cnt].ordered_as_mnemonic = med_info->meds[m_cnt].fields[var_freetextord_slot].
     value
    ENDIF
   ELSE
    IF ((med_info->rx[r_cnt].fields[var_freetextord_slot].value > " "))
     med_info->rx[r_cnt].ordered_as_mnemonic = med_info->rx[r_cnt].fields[var_freetextord_slot].value
    ENDIF
    CALL add_to_sig(med_info->rx[r_cnt].fields[var_strengthdose_slot].value,r_cnt,"R"),
    CALL add_to_sig(med_info->rx[r_cnt].fields[var_strengthdoseunit_slot].value,r_cnt,"R"),
    CALL add_to_sig(med_info->rx[r_cnt].fields[var_volumedose_slot].value,r_cnt,"R"),
    CALL add_to_sig(med_info->rx[r_cnt].fields[var_volumedoseunit_slot].value,r_cnt,"R")
    IF ((med_info->rx[r_cnt].fields[var_freetxtdose_slot].value="See Instructions"))
     CALL add_to_sig(med_info->rx[r_cnt].fields[var_specinx_slot].value,r_cnt,"R")
    ELSE
     CALL add_to_sig(med_info->rx[r_cnt].fields[var_freetxtdose_slot].value,r_cnt,"R")
    ENDIF
    CALL add_to_sig(med_info->rx[r_cnt].fields[var_rxroute_slot].value,r_cnt,"R"),
    CALL add_to_sig(med_info->rx[r_cnt].fields[var_freq_slot].value,r_cnt,"R")
    IF ((med_info->rx[r_cnt].fields[var_duration_slot].value > " "))
     CALL add_to_sig(build2("for ",med_info->rx[r_cnt].fields[var_duration_slot].value),r_cnt,"R"),
     CALL add_to_sig(med_info->rx[r_cnt].fields[var_durationunit_slot].value,r_cnt,"R")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FREE SET cs106_pharmacy_cd
 FREE SET cs6004_inprocess_cd
 FREE SET cs6004_medstudent_cd
 FREE SET cs6004_ordered_cd
 FREE SET cs6004_pending_cd
 FREE SET cs6004_pendingrev_cd
 FREE SET cs6004_unscheduled_cd
 FREE SET add_oe_field
 FREE SET add_to_sig
#exit_script
END GO
