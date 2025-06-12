CREATE PROGRAM ams_dcp_ord_virtual:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Virtualize or de-virtualize orders" = "VIRTUAL",
  "Select catalog type" = 0.000000,
  "Select order" = 0,
  "Select Synonym" = 0,
  "Select Facility" = 0,
  "Select Facility" = 0
  WITH outdev, poption, pcatalogtype,
  porder, psynonym, pfacility,
  pfacility2
 DECLARE faccount = i4 WITH protect
 DECLARE syncount = i4 WITH protect
 DECLARE syninputcount = i4 WITH protect
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 SET exe_error = 10
 SET script_failed = false
 EXECUTE ams_define_toolkit_common:dba
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD facrec
 RECORD facrec(
   1 facqual[*]
     2 faccd = f8
 )
 FREE RECORD synrec
 RECORD synrec(
   1 synqual[*]
     2 synid = f8
 )
 FREE RECORD request
 RECORD request(
   1 catalog_cd = f8
   1 catalog_type_cd = f8
   1 oe_format_id = f8
   1 dcp_clin_cat_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 orderable_type_flag = i2
   1 syn_add_cnt = i4
   1 add_qual[*]
     2 synonym_id = f8
     2 virtual_view = vc
     2 health_plan_view = vc
     2 concentration_strength = f8
     2 concentration_strength_unit_cd = f8
     2 concentration_volume = f8
     2 concentration_volume_unit_cd = f8
     2 oe_format_id = f8
     2 rx_mask = i4
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
     2 order_sentence_id = f8
     2 active_ind = i2
     2 ing_rate_conversion_ind = i2
     2 hide_flag = i2
     2 ref_text_mask = i4
     2 witness_flag = i2
     2 qual_facility[*]
       3 facility_cd = f8
   1 syn_upd_cnt = i4
   1 upd_qual[*]
     2 virtual_view = vc
     2 health_plan_view = vc
     2 oe_format_id = f8
     2 rx_mask = i4
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
     2 order_sentence_id = f8
     2 concentration_strength = f8
     2 concentration_strength_unit_cd = f8
     2 concentration_volume = f8
     2 concentration_volume_unit_cd = f8
     2 active_ind = i2
     2 ing_rate_conversion_ind = i2
     2 hide_flag = i2
     2 updt_cnt = i4
     2 ref_text_mask = i4
     2 witness_flag = i2
     2 qual_facility_add[*]
       3 facility_cd = f8
     2 qual_facility_remove[*]
       3 facility_cd = f8
     2 high_alert_ind = i2
     2 high_alert_long_text_id = f8
     2 high_alert_long_text = vc
     2 high_alert_notify_ind = i2
     2 intermittent_ind = i2
     2 display_additives_first_ind = i2
     2 rounding_rule_cd = f8
     2 ign_hide_flag = i2
     2 lock_target_dose_ind = i2
     2 preferred_dose_flag = i2
     2 max_final_dose = f8
     2 max_final_dose_unit_cd = f8
     2 max_dose_calc_bsa_value = f8
   1 syn_del_cnt = i4
   1 del_qual[*]
     2 synonym_id = f8
   1 therapeutic_category_qual[*]
     2 short_description = vc
 )
 SET lcheck = substring(1,1,reflect(parameter(5,0)))
 IF (lcheck="L")
  WHILE (lcheck > " ")
    SET syninputcount = (syninputcount+ 1)
    SET lcheck = substring(1,1,reflect(parameter(5,syninputcount)))
    IF (lcheck > " ")
     IF (mod(syninputcount,5)=1)
      SET stat = alterlist(synrec->synqual,(syninputcount+ 4))
     ENDIF
     SET synrec->synqual[syninputcount].synid = parameter(5,syninputcount)
    ENDIF
  ENDWHILE
  SET syninputcount = (syninputcount - 1)
  SET stat = alterlist(synrec->synqual,syninputcount)
 ELSE
  SET syninputcount = 1
  SET stat = alterlist(synrec->synqual,syninputcount)
  SET synrec->synqual[1].synid =  $PSYNONYM
 ENDIF
 IF (( $POPTION="VIRTUAL"))
  SET lcheck = substring(1,1,reflect(parameter(6,0)))
  IF (lcheck="L")
   WHILE (lcheck > " ")
     SET faccount = (faccount+ 1)
     SET lcheck = substring(1,1,reflect(parameter(6,faccount)))
     IF (lcheck > " ")
      IF (mod(faccount,5)=1)
       SET stat = alterlist(facrec->facqual,(faccount+ 4))
      ENDIF
      SET facrec->facqual[faccount].faccd = parameter(6,faccount)
     ENDIF
   ENDWHILE
   SET faccount = (faccount - 1)
   SET stat = alterlist(facrec->facqual,faccount)
  ELSE
   SET faccount = 1
   SET stat = alterlist(facrec->facqual,faccount)
   SET facrec->facqual[1].faccd =  $PFACILITY
  ENDIF
 ELSE
  SET lcheck = substring(1,1,reflect(parameter(7,0)))
  IF (lcheck="L")
   WHILE (lcheck > " ")
     SET faccount = (faccount+ 1)
     SET lcheck = substring(1,1,reflect(parameter(7,faccount)))
     IF (lcheck > " ")
      IF (mod(faccount,5)=1)
       SET stat = alterlist(facrec->facqual,(faccount+ 4))
      ENDIF
      SET facrec->facqual[faccount].faccd = parameter(7,faccount)
     ENDIF
   ENDWHILE
   SET faccount = (faccount - 1)
   SET stat = alterlist(facrec->facqual,faccount)
  ELSE
   SET faccount = 1
   SET stat = alterlist(facrec->facqual,faccount)
   SET facrec->facqual[1].faccd =  $PFACILITY2
  ENDIF
 ENDIF
 FOR (loopindex = 1 TO syninputcount)
   SET stat = initrec(request)
   CALL echo("***FOR LOOP BEGINS********")
   CALL echo(build2("value of index loopIndex :",loopindex))
   CALL echo(build2("value of synRec->synQual[",loopindex,"].synId :",synrec->synqual[loopindex].
     synid))
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs,
     order_catalog oc,
     long_text l
    PLAN (ocs
     WHERE (ocs.synonym_id=synrec->synqual[loopindex].synid)
      AND ocs.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd
      AND oc.active_ind=1)
     JOIN (l
     WHERE l.long_text_id=outerjoin(ocs.high_alert_long_text_id)
      AND l.active_ind=outerjoin(1))
    ORDER BY oc.catalog_cd, ocs.synonym_id
    HEAD REPORT
     syncount = 0
    HEAD oc.catalog_cd
     request->catalog_cd = oc.catalog_cd, request->catalog_type_cd = oc.catalog_type_cd, request->
     dcp_clin_cat_cd = oc.dcp_clin_cat_cd,
     request->oe_format_id = oc.oe_format_id, request->activity_type_cd = oc.activity_type_cd,
     request->activity_subtype_cd = oc.activity_subtype_cd,
     request->orderable_type_flag = oc.orderable_type_flag
    HEAD ocs.synonym_id
     syncount = (syncount+ 1)
     IF (mod(syncount,10)=1)
      stat = alterlist(request->upd_qual,(syncount+ 9))
     ENDIF
     request->upd_qual[syncount].synonym_id = ocs.synonym_id, request->upd_qual[syncount].rx_mask =
     ocs.rx_mask, request->upd_qual[syncount].mnemonic = ocs.mnemonic,
     request->upd_qual[syncount].virtual_view = ocs.virtual_view, request->upd_qual[syncount].
     health_plan_view = ocs.health_plan_view, request->upd_qual[syncount].mnemonic_type_cd = ocs
     .mnemonic_type_cd,
     request->upd_qual[syncount].order_sentence_id = ocs.order_sentence_id, request->upd_qual[
     syncount].ing_rate_conversion_ind = ocs.ingredient_rate_conversion_ind, request->upd_qual[
     syncount].active_ind = ocs.active_ind,
     request->upd_qual[syncount].hide_flag = ocs.hide_flag, request->upd_qual[syncount].updt_cnt =
     ocs.updt_cnt, request->upd_qual[syncount].ref_text_mask = ocs.ref_text_mask,
     request->upd_qual[syncount].oe_format_id = ocs.oe_format_id, request->upd_qual[syncount].
     concentration_strength = ocs.concentration_strength, request->upd_qual[syncount].
     concentration_strength_unit_cd = ocs.concentration_strength_unit_cd,
     request->upd_qual[syncount].concentration_volume = ocs.concentration_volume_unit_cd, request->
     upd_qual[syncount].concentration_volume_unit_cd = ocs.concentration_volume_unit_cd, request->
     upd_qual[syncount].witness_flag = ocs.witness_flag,
     request->upd_qual[syncount].high_alert_ind = ocs.high_alert_ind, request->upd_qual[syncount].
     high_alert_long_text_id = ocs.high_alert_long_text_id, request->upd_qual[syncount].
     high_alert_long_text = l.long_text,
     request->upd_qual[syncount].high_alert_notify_ind = ocs.high_alert_required_ntfy_ind, request->
     upd_qual[syncount].intermittent_ind = ocs.intermittent_ind, request->upd_qual[syncount].
     display_additives_first_ind = ocs.display_additives_first_ind,
     request->upd_qual[syncount].rounding_rule_cd = ocs.rounding_rule_cd, request->upd_qual[syncount]
     .ign_hide_flag = ocs.ignore_hide_convert_ind, request->upd_qual[syncount].lock_target_dose_ind
      = ocs.lock_target_dose_ind,
     request->upd_qual[syncount].preferred_dose_flag = ocs.preferred_dose_flag, request->upd_qual[
     syncount].max_final_dose = ocs.max_final_dose, request->upd_qual[syncount].
     max_final_dose_unit_cd = ocs.max_final_dose_unit_cd,
     request->upd_qual[syncount].max_dose_calc_bsa_value = ocs.max_dose_calc_bsa_value
    FOOT  oc.catalog_cd
     request->syn_upd_cnt = syncount, stat = alterlist(request->upd_qual,syncount)
    WITH nocounter
   ;end select
   IF (( $POPTION="VIRTUAL"))
    FOR (i = 1 TO syncount)
      SELECT INTO "nl:"
       FROM ocs_facility_r o
       WHERE (o.synonym_id=request->upd_qual[i].synonym_id)
       ORDER BY o.synonym_id
       HEAD o.synonym_id
        IF (o.facility_cd=0)
         stat = alterlist(request->upd_qual[i].qual_facility_remove,1), request->upd_qual[i].
         qual_facility_remove.facility_cd = o.facility_cd
        ENDIF
       WITH nocounter
      ;end select
      SET stat = alterlist(request->upd_qual[i].qual_facility_add,faccount)
      FOR (j = 1 TO faccount)
        SET request->upd_qual[i].qual_facility_add[j].facility_cd = facrec->facqual[j].faccd
      ENDFOR
    ENDFOR
   ELSE
    FOR (i = 1 TO syncount)
     SET stat = alterlist(request->upd_qual[i].qual_facility_remove,faccount)
     FOR (j = 1 TO faccount)
       SET request->upd_qual[i].qual_facility_remove[j].facility_cd = facrec->facqual[j].faccd
     ENDFOR
    ENDFOR
   ENDIF
   CALL echo(build2("Request built for index :",loopindex))
   CALL echorecord(request)
   CALL echo(build2("TIME BEFORE EXEC : ",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME")))
   EXECUTE orm_upd_synonym:dba
   CALL echo(build2("TIME AFTER EXEC : ",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME")))
   CALL echo("***FOR LOOP ENDS********")
 ENDFOR
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   col 0, "Script executed Successfully."
  WITH nocounter
 ;end select
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "001 10/14/15 ZA030646  Initial Release"
END GO
