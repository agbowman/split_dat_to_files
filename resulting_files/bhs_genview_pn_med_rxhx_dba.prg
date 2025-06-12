CREATE PROGRAM bhs_genview_pn_med_rxhx:dba
 RECORD pt_info(
   1 person_id = f8
   1 encntr_id = f8
 )
 IF (validate(request->visit[1],0.00) <= 0.00)
  IF (reflect(parameter(1,0)) > " ")
   SET pt_info->person_id = cnvtreal( $1)
   RECORD reply(
     1 text = vc
   )
  ENDIF
 ELSE
  SET pt_info->encntr_id = request->visit[1].encntr_id
 ENDIF
 IF ((pt_info->encntr_id <= 0.00))
  CALL echo("no valid enctr_id given. exitting script")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  e.person_id, e.encntr_id
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.person_id > 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   pt_info->person_id = e.person_id
  WITH nocounter
 ;end select
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
 )
 DECLARE cs106_pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_medstudent_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE cs6004_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE cs6004_pendingrev_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDINGREV"))
 DECLARE cs6004_unscheduled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
 DECLARE add_oe_field(meaning=vc) = null
 CALL add_oe_field("FREETEXTORD")
 DECLARE var_freetextord_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("STRENGTHDOSE")
 DECLARE var_strengthdose_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("STRENGTHDOSEUNIT")
 DECLARE var_strengthdoseunit_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("VOLUMEDOSE")
 DECLARE var_volumedose_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("VOLUMEDOSEUNIT")
 DECLARE var_volumedoseunit_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("FREETXTDOSE")
 DECLARE var_freetxtdose_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("RXROUTE")
 DECLARE var_rxroute_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("FREQ")
 DECLARE var_freq_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("SCH/PRN")
 DECLARE var_schprn_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("DURATION")
 DECLARE var_duration_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("DURATIONUNIT")
 DECLARE var_durationunit_slot = i4 WITH constant(med_info->f_cnt)
 CALL add_oe_field("SPECINX")
 DECLARE var_specinx_slot = i4 WITH constant(med_info->f_cnt)
 FREE SET add_oe_field
 SUBROUTINE add_oe_field(meaning)
   IF (trim(meaning,4) <= " ")
    CALL echo("no valid meaning given.")
   ELSE
    SET tmp = (med_info->f_cnt+ 1)
    SET stat = alterlist(med_info->fields,tmp)
    SET med_info->f_cnt = tmp
    SET med_info->fields[tmp].meaning = trim(meaning,4)
    FREE SET tmp
   ENDIF
 END ;Subroutine
 DECLARE add_value = vc
 SELECT INTO "nl:"
  o.ordered_as_mnemonic, o.order_mnemonic, od.action_sequence,
  d.seq
  FROM orders o,
   order_detail od,
   (dummyt d  WITH seq = value(med_info->f_cnt))
  PLAN (o
   WHERE (o.person_id=pt_info->person_id)
    AND o.activity_type_cd=cs106_pharmacy_cd
    AND ((o.order_status_cd+ 0) IN (cs6004_inprocess_cd, cs6004_medstudent_cd, cs6004_ordered_cd,
   cs6004_pending_cd, cs6004_pendingrev_cd,
   cs6004_unscheduled_cd))
    AND o.template_order_id=0.00
    AND o.orig_ord_as_flag > 0
    AND ((o.discontinue_effective_dt_tm+ 0) IN (null))
    AND ((o.active_ind+ 0)=1)
    AND ((o.updt_id+ 0) != 1))
   JOIN (od
   WHERE o.order_id=od.order_id)
   JOIN (d
   WHERE (od.oe_field_meaning=med_info->fields[d.seq].meaning))
  ORDER BY o.hna_order_mnemonic, o.ordered_as_mnemonic, o.order_id,
   od.action_sequence, d.seq
  HEAD REPORT
   m_cnt = 0, r_cnt = 0,
   MACRO (add_to_sig)
    IF (trim(add_value,3) > " ")
     med_info->rx[r_cnt].sig = build2(med_info->rx[r_cnt].sig," ",trim(add_value,3))
    ENDIF
   ENDMACRO
  HEAD o.order_id
   r_cnt = (med_info->r_cnt+ 1), stat = alterlist(med_info->rx,r_cnt), med_info->r_cnt = r_cnt,
   med_info->rx[r_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, med_info->rx[r_cnt].
   order_mnemonic = o.hna_order_mnemonic
  HEAD od.action_sequence
   stat = alterlist(med_info->rx[r_cnt].fields,med_info->f_cnt)
  DETAIL
   med_info->rx[r_cnt].fields[d.seq].value = trim(od.oe_field_display_value,3)
  FOOT  o.order_id
   IF ((med_info->rx[r_cnt].fields[var_freetextord_slot].value > " "))
    med_info->rx[r_cnt].ordered_as_mnemonic = med_info->rx[r_cnt].fields[var_freetextord_slot].value
   ENDIF
   IF ((med_info->rx[r_cnt].fields[var_volumedose_slot].value <= " "))
    add_value = med_info->rx[r_cnt].fields[var_strengthdose_slot].value, add_to_sig, add_value =
    med_info->rx[r_cnt].fields[var_strengthdoseunit_slot].value,
    add_to_sig
   ENDIF
   add_value = med_info->rx[r_cnt].fields[var_volumedose_slot].value, add_to_sig, add_value =
   med_info->rx[r_cnt].fields[var_volumedoseunit_slot].value,
   add_to_sig
   IF ((med_info->rx[r_cnt].fields[var_freetxtdose_slot].value="See Instructions"))
    add_value = med_info->rx[r_cnt].fields[var_freetxtdose_slot].value
   ELSE
    add_value = med_info->rx[r_cnt].fields[var_freetxtdose_slot].value
   ENDIF
   add_to_sig
   IF ((med_info->rx[r_cnt].fields[var_rxroute_slot].value > " "))
    add_value = build2(", ",med_info->rx[r_cnt].fields[var_rxroute_slot].value), add_to_sig
   ENDIF
   IF ((med_info->rx[r_cnt].fields[var_freq_slot].value > " "))
    add_value = build2(", ",med_info->rx[r_cnt].fields[var_freq_slot].value), add_to_sig
   ENDIF
   IF ((med_info->rx[r_cnt].fields[var_schprn_slot].value="Yes")
    AND o.prn_ind=1)
    add_value = build2(" PRN "), add_to_sig
   ENDIF
   IF ((med_info->rx[r_cnt].fields[var_duration_slot].value > " "))
    add_value = build2("for ",med_info->rx[r_cnt].fields[var_duration_slot].value), add_to_sig,
    add_value = med_info->rx[r_cnt].fields[var_durationunit_slot].value,
    add_to_sig
   ENDIF
   IF ((med_info->rx[r_cnt].fields[var_specinx_slot].value > " "))
    add_value = build2(", ",med_info->rx[r_cnt].fields[var_specinx_slot].value), add_to_sig
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
 FREE SET add_value
 DECLARE newline = vc WITH constant(concat(char(10),char(13),"\li0",char(10),char(13)))
 DECLARE tmp_str = vc
 DECLARE indent1 = c6 WITH constant("\li288")
 DECLARE indent2 = c6 WITH constant("\li576")
 SET reply->text = "{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 tahoma;}}"
 SET reply->text = build2(reply->text,"\pard\f0\fs20",newline)
 SET reply->text = build2(reply->text,"\b\ul Prescriptions/Home Medications\ul0\b0\par",newline)
 IF ((med_info->r_cnt <= 0))
  SET reply->text = build2(reply->text,indent1," no prescriptions found\par",newline)
 ELSE
  FOR (r = 1 TO med_info->r_cnt)
    SET tmp_str = " "
    IF (r > 1)
     SET reply->text = build2(reply->text,"\par",newline)
    ENDIF
    IF (trim(med_info->rx[r].order_mnemonic,3) > " ")
     IF (trim(tmp_str,3) > " ")
      SET tmp_str = build2(indent1," ",med_info->rx[r].order_mnemonic)
     ELSE
      SET tmp_str = trim(med_info->rx[r].order_mnemonic,3)
     ENDIF
    ENDIF
    IF (trim(med_info->rx[r].ordered_as_mnemonic,3) > " ")
     SET tmp_str = build2(tmp_str," (",med_info->rx[r].ordered_as_mnemonic,")")
    ELSE
     SET tmp_str = " "
    ENDIF
    SET reply->text = build2(reply->text,tmp_str,"\par",newline)
    IF (trim(med_info->rx[r].sig,3) > " ")
     SET reply->text = build2(reply->text,indent2," ",med_info->rx[r].sig,"\par",
      newline)
    ENDIF
  ENDFOR
 ENDIF
 SET reply->text = build2(reply->text,"{\*\program name:",trim(cnvtupper(curprog),3),"}")
 SET reply->text = build2(reply->text,"{\*\person_id:",pt_info->person_id,"}")
 SET reply->text = build2(reply->text,"{\*\encntr_id:",pt_info->encntr_id,"}")
 SET reply->text = build2(reply->text,"}")
 FREE SET newline
 FREE SET tmp_str
#exit_script
END GO
