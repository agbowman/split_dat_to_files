CREATE PROGRAM bhs_athn_get_ord_ingr_v2
 FREE RECORD orequest
 RECORD orequest(
   1 order_list[*]
     2 order_id = f8
 )
 FREE RECORD oreply
 RECORD oreply(
   1 order_list[*]
     2 order_id = f8
     2 ingred_list[*]
       3 order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 order_detail_display_line = vc
       3 synonym_id = f8
       3 catalog_cd = f8
       3 volume_value = f8
       3 volume_unit_cd = f8
       3 volume_unit_disp = vc
       3 strength_value = f8
       3 strength_unit_cd = f8
       3 strength_unit_disp = vc
       3 freetext_dose = vc
       3 frequency_cd = f8
       3 frequency_disp = vc
       3 comp_sequence = i2
       3 ingredient_type_flag = i2
       3 iv_seq = i2
       3 hna_order_mnemonic = vc
       3 dose_quantity = f8
       3 dose_quantity_unit = f8
       3 event_cd = f8
       3 normalized_rate = f8
       3 normalized_rate_unit_cd = f8
       3 concentration = f8
       3 concentration_unit_cd = f8
       3 include_in_total_volume_flag = i2
       3 ingredient_source_flag = i2
       3 cki = vc
       3 actual_dose = vc
       3 target_dose = vc
   1 status_data
     2 status = c1
 )
 SET stat = alterlist(orequest->order_list,1)
 SET orequest->order_list[1].order_id =  $2
 SET stat = tdbexecute(600005,3202004,3200141,"REC",orequest,
  "REC",oreply)
 IF ((oreply->status_data.status != "S"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(oreply->order_list[1].ingred_list,5)),
   order_catalog_synonym oc
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (oc
   WHERE (oc.synonym_id=oreply->order_list[1].ingred_list[d1.seq].synonym_id))
  DETAIL
   oreply->order_list[1].ingred_list[d1.seq].cki = oc.cki
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(oreply->order_list[1].ingred_list,5)),
   order_ingredient o,
   long_text lt
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (o
   WHERE (o.synonym_id=oreply->order_list[1].ingred_list[d1.seq].synonym_id)
    AND o.order_id=cnvtreal( $2))
   JOIN (lt
   WHERE lt.long_text_id=o.dose_calculator_long_text_id
    AND lt.parent_entity_id=o.order_id)
  HEAD lt.long_text_id
   targetdosex = findstring("<TargetDose",lt.long_text), targetdosey = findstring(">",lt.long_text,
    targetdosex), targetdosez = findstring("</TargetDose",lt.long_text),
   target_dose1 = substring((targetdosey+ 1),(targetdosez - (targetdosey+ 1)),lt.long_text),
   targetdoseunitx = findstring("<TargetDoseUnitDisp",lt.long_text), targetdoseunity = findstring(">",
    lt.long_text,targetdoseunitx),
   targetdoseunitz = findstring("</TargetDoseUnitDisp",lt.long_text), target_dose_unit = substring((
    targetdoseunity+ 1),(targetdoseunitz - (targetdoseunity+ 1)),lt.long_text), actualdosex =
   findstring("<ActualFinalDose",lt.long_text),
   actualdosey = findstring(">",lt.long_text,actualdosex), actualdosez = findstring(
    "</ActualFinalDose",lt.long_text), actual_dose1 = substring((actualdosey+ 1),(actualdosez - (
    actualdosey+ 1)),lt.long_text),
   actualdoseunitx = findstring("<ActualFinalDoseUnitDisp",lt.long_text), actualdoseunity =
   findstring(">",lt.long_text,actualdoseunitx), actualdoseunitz = findstring(
    "</ActualFinalDoseUnitDisp",lt.long_text),
   actual_dose_unit = substring((actualdoseunity+ 1),(actualdoseunitz - (actualdoseunity+ 1)),lt
    .long_text)
   IF (target_dose1 != " ")
    oreply->order_list[1].ingred_list[d1.seq].target_dose = build(target_dose1,"|",target_dose_unit)
   ENDIF
   IF (actual_dose1 != " ")
    oreply->order_list[1].ingred_list[d1.seq].actual_dose = trim(build(actual_dose1,"|",
      actual_dose_unit),3)
   ENDIF
  WITH time = 20
 ;end select
#exit_script
 SET _memory_reply_string = cnvtrectojson(oreply,5)
END GO
