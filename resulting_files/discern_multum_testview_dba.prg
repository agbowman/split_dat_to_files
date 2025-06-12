CREATE PROGRAM discern_multum_testview:dba
 PROMPT
  "Enter output device= " = "MINE",
  "Interaction data string= " = ""
  WITH outdev, alertdata
 RECORD alertdata(
   1 person_id = f8
   1 encntr_id = f8
   1 person_name = vc
   1 person_mrn = vc
   1 subject_synonym_id = f8
   1 mul_overriderequired = i2
   1 mul_overriderequired_types = vc
   1 mulreat = i2
   1 mulintr = i2
   1 muldfintr = i2
   1 muldup = i2
   1 mul_allergyinterrupt = i2
   1 mul_drugdruginterrupt = i2
   1 mul_drugfoodinterrupt = i2
   1 mul_dupinterrupt = i2
   1 mul_ivcompatinterrupt = i2
   1 sec_allowoverride = i2
   1 is_display_only = i2
   1 override_reason_list = vc
   1 override_all[*]
     2 reason_cd = f8
     2 reason_disp = vc
   1 override_allergy[*]
     2 reason_cd = f8
     2 reason_disp = vc
   1 override_drugdrug[*]
     2 reason_cd = f8
     2 reason_disp = vc
   1 override_drugfood[*]
     2 reason_cd = f8
     2 reason_disp = vc
   1 override_duptherapy[*]
     2 reason_cd = f8
     2 reason_disp = vc
   1 override_reasons[*]
     2 reason_cd = f8
     2 reason_disp = vc
   1 action_flag = i2
   1 is_orders_mode = i2
   1 triggering_order
     2 order_action_type = i2
     2 unique_identifier = vc
     2 subject_entity_id = f8
     2 subject_entity_name = vc
     2 subject_catalog_cd = f8
     2 subject_entity_cki = vc
     2 subject_component_name = vc
     2 target_mnemonic = vc
     2 order_details = vc
     2 duplicate_order_id = f8
     2 synonym_count = i4
     2 synonyms[*]
       3 synonym_id = f8
     2 venue_type = vc
     2 is_iv = i2
     2 req_comp_of_careset = i4
     2 order_details_list[*]
       3 field_id = f8
       3 field_meaning = vc
       3 field_meaning_id = f8
       3 field_value = f8
       3 field_display_value = vc
       3 field_dt_tm_value = dq8
   1 triggering_allergy
     2 allergy_id = f8
     2 allergy_name = vc
     2 allergy_source = vc
     2 allergy_reaction_type = vc
   1 interactions[*]
     2 causing_entity_id = f8
     2 causing_entity_name = vc
     2 causing_catalog_cd = f8
     2 causing_entity_unique_string = vc
     2 causing_entity_cki = vc
     2 causing_component_name = vc
     2 causing_synonym_id = f8
     2 interaction_type = vc
     2 interaction_desc = vc
     2 severity_level = vc
     2 severity_desc = vc
     2 subject_entity_id = f8
     2 subject_entity_name = vc
     2 subject_catalog_cd = f8
     2 subject_entity_unique_string = vc
     2 subject_entity_cki = vc
     2 subject_component_name = vc
     2 override_reason_cd = f8
     2 override_reason = vc
     2 is_override_required = i2
     2 prev_override_reason_cd = f8
     2 prev_override_reason = vc
     2 is_order_hidden = i2
     2 order_status = vc
     2 order_details = vc
     2 ordered_as = vc
     2 order_venue_type = vc
     2 order_status_date = vc
     2 ordered_as_flag = i4
     2 ordering_physician = vc
     2 order_has_reftext = i2
     2 additional_info = vc
     2 is_allergy_hidden = i4
     2 allergy_comments = vc
     2 allergy_source = vc
     2 allergy_reaction_type = vc
     2 allergy_reactions = vc
     2 order_details_list[*]
       3 field_id = f8
       3 field_meaning = vc
       3 field_meaning_id = f8
       3 field_value = f8
       3 field_display_value = vc
 )
 DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
 RECORD prefcheck(
   1 boverriderequired = i2
   1 overriderequiredtypes[5]
     2 brequired = i2
   1 bdupinterruption = i2
   1 ballergyinterruption = i2
   1 ndrugdruginterruption = i2
   1 ndrugfoodinterruption = i2
 )
 DECLARE _nerrcode = i2 WITH protect
 DECLARE _serrmessage = vc WITH protect
 DECLARE _notfound = vc WITH protect, constant("<not_found>")
 DECLARE loverrideallbw = i4 WITH public, noconstant(0)
 DECLARE loverrideallergybw = i4 WITH public, noconstant(0)
 DECLARE loverridedrugdrugbw = i4 WITH public, noconstant(0)
 DECLARE loverridedrugfoodbw = i4 WITH public, noconstant(0)
 DECLARE loverrideduptherapybw = i4 WITH public, noconstant(0)
 DECLARE populateinteractiondatafromquery(null) = i4 WITH protect
 DECLARE setoverridesrequired(null) = i4 WITH protect
 SUBROUTINE populateinteractiondatafromquery(null)
   IF (setoverridesrequired(null)=0)
    RETURN(false)
   ENDIF
   IF (populateoveridereasons(alertdata->override_reason_list)=0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE setoverridesrequired(null)
   DECLARE _nitem = i2 WITH protect
   DECLARE boverriderequired = i2 WITH protect
   DECLARE sseverity = vc WITH protect
   DECLARE nseverity = i2 WITH protect
   DECLARE sinteractiontype = vc WITH protect
   DECLARE ninteractions = i2 WITH protect
   DECLARE _prefstr = vc WITH noconstant(""), protect
   DECLARE soverriderequiredtypes = vc WITH protect
   SET ninteractions = size(alertdata->interactions,5)
   IF (ninteractions=0)
    RETURN(false)
   ENDIF
   DECLARE enoseverity = i2 WITH constant(0)
   DECLARE eminorseverity = i2 WITH constant(1)
   DECLARE emoderateseverity = i2 WITH constant(2)
   DECLARE emajorseverity = i2 WITH constant(3)
   DECLARE enodataseverity = i2 WITH constant(4)
   DECLARE eunknownseverity = i2 WITH constant(5)
   DECLARE emixedseverity = i2 WITH constant(6)
   DECLARE eincompatibleseverity = i2 WITH constant(7)
   DECLARE emajorcontraindicatedseverity = i2 WITH constant(8)
   SET prefcheck->boverriderequired = alertdata->mul_overriderequired
   FOR (_nitem = 1 TO 5)
     SET prefcheck->overriderequiredtypes[_nitem].brequired = 0
   ENDFOR
   SET soverriderequiredtypes = alertdata->mul_overriderequired_types
   SET prefcheck->bdupinterruption = alertdata->mul_dupinterrupt
   SET prefcheck->ballergyinterruption = alertdata->mul_allergyinterrupt
   SET prefcheck->ndrugdruginterruption = alertdata->mul_drugdruginterrupt
   SET prefcheck->ndrugfoodinterruption = alertdata->mul_drugfoodinterrupt
   SET _num = 1
   CALL echo(concat("sOverrideRequiredTypes= ",soverriderequiredtypes))
   WHILE (_prefstr != _notfound)
     SET _prefstr = piece(soverriderequiredtypes,",",_num,_notfound)
     IF (isnumeric(_prefstr))
      SET prefcheck->overriderequiredtypes[_num].brequired = cnvtint(_prefstr)
     ELSE
      SET _serrmessage = concat("Pref value MUL_OVERRIDEREQUIRED_TYPES contains non-numeric data: ",
       soverriderequiredtypes)
     ENDIF
     SET _num += 1
   ENDWHILE
   CALL echorecord(prefcheck)
   FOR (_nitem = 1 TO ninteractions)
     SET boverriderequired = 0
     SET nseverity = 0
     SET sinteractiontype = alertdata->interactions[_nitem].interaction_type
     SET sseverity = alertdata->interactions[_nitem].severity_level
     IF (sseverity="Minor")
      SET nseverity = 1
     ELSEIF (sseverity="Moderate")
      SET nseverity = 2
     ELSEIF (sseverity="Major")
      SET nseverity = 3
     ELSEIF (sseverity="Mixed")
      SET nseverity = 6
     ELSEIF (sseverity="Major-Contraindicated")
      SET nseverity = 8
     ENDIF
     IF ((prefcheck->boverriderequired=1))
      CALL echo(build("nItem= ",_nitem,", sInteractionType= ",sinteractiontype,", nSeverity= ",
        nseverity," (",sseverity,")"))
      IF (sinteractiontype="DrugDrug")
       IF ((prefcheck->overriderequiredtypes[1].brequired=1))
        IF ((((prefcheck->ndrugdruginterruption=0)) OR ((((prefcheck->ndrugdruginterruption=1)
         AND ((emoderateseverity=nseverity) OR (((emajorseverity=nseverity) OR (
        emajorcontraindicatedseverity=nseverity)) )) ) OR ((((prefcheck->ndrugdruginterruption=2)
         AND ((emajorseverity=nseverity) OR (emajorcontraindicatedseverity=nseverity)) ) OR ((
        prefcheck->ndrugdruginterruption=4)
         AND emajorcontraindicatedseverity=nseverity)) )) )) )
         SET boverriderequired = 1
        ENDIF
       ENDIF
      ELSEIF (sinteractiontype="DuplicateTherapy")
       IF ((prefcheck->overriderequiredtypes[3].brequired=1)
        AND (prefcheck->bdupinterruption=1))
        SET boverriderequired = 1
       ENDIF
      ELSEIF (((sinteractiontype="AllergyDrug") OR (sinteractiontype="DrugAllergy")) )
       IF ((prefcheck->overriderequiredtypes[2].brequired=1)
        AND (prefcheck->ballergyinterruption=1))
        SET boverriderequired = 1
       ENDIF
      ELSEIF (sinteractiontype="DrugFood")
       IF ((prefcheck->overriderequiredtypes[4].brequired=1))
        IF ((((prefcheck->ndrugfoodinterruption=0)) OR ((((prefcheck->ndrugfoodinterruption=1)
         AND ((emoderateseverity=nseverity) OR (emajorseverity=nseverity)) ) OR ((prefcheck->
        ndrugfoodinterruption=2)
         AND emajorseverity=nseverity)) )) )
         SET boverriderequired = 1
        ENDIF
       ENDIF
      ENDIF
      IF (boverriderequired)
       CALL echo(concat("setOverridesRequired() index= ",build(_nitem),", interactionType= ",
         sinteractiontype,", setting Is_override_required = 1"))
       SET alertdata->interactions[_nitem].is_override_required = 1
      ENDIF
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (populateoveridereasons(reasonstr=vc) =i4 WITH protect)
   RECORD overridereasons(
     1 qual[*]
       2 reason_cd = f8
       2 reason_disp = vc
   )
   DECLARE _nallcnt = i4 WITH noconstant(0)
   DECLARE _nallergycnt = i4 WITH noconstant(0)
   DECLARE _ndrugdrugcnt = i4 WITH noconstant(0)
   DECLARE _ndrugfoodcnt = i4 WITH noconstant(0)
   DECLARE _ndupcnt = i4 WITH noconstant(0)
   DECLARE _nreasons = i2 WITH noconstant(0)
   DECLARE num = i4 WITH noconstant(0)
   IF (loverridedrugdrugbw=0)
    IF (validate(alertdata->override_drugdrug)=0)
     CALL echo(
      "AlertData->Override_DrugDrug list not available.  Override reasons by type will not be populated."
      )
     RETURN(false)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    cve.code_value, cv.display, cve.field_name,
    cve.field_value
    FROM code_value_extension cve,
     code_value cv
    PLAN (cve
     WHERE cve.code_set=800
      AND cve.field_value=cnvtstring("1"))
     JOIN (cv
     WHERE cve.code_value=cv.code_value
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate))
    ORDER BY cv.collation_seq, cv.display, cve.field_name
    HEAD REPORT
     _nallcnt = 0, _nallergycnt = 0, _ndrugdrugcnt = 0,
     _ndrugfoodcnt = 0, _ndupcnt = 0
    DETAIL
     IF (cve.field_name="MULTUM_ALL")
      IF (loverrideallbw=0)
       IF (locateval(num,1,_nallcnt,cv.code_value,alertdata->override_all[num].reason_cd)=0)
        _nallcnt += 1, _alterstat = alterlist(alertdata->override_all,_nallcnt), alertdata->
        override_all[_nallcnt].reason_cd = cv.code_value,
        alertdata->override_all[_nallcnt].reason_disp = cv.display
       ENDIF
      ENDIF
      IF (loverrideallergybw=0)
       IF (locateval(num,1,_nallergycnt,cv.code_value,alertdata->override_allergy[num].reason_cd)=0)
        _nallergycnt += 1, _alterstat = alterlist(alertdata->override_allergy,_nallergycnt),
        alertdata->override_allergy[_nallergycnt].reason_cd = cv.code_value,
        alertdata->override_allergy[_nallergycnt].reason_disp = cv.display
       ENDIF
      ENDIF
      IF (loverridedrugdrugbw=0)
       IF (locateval(num,1,_ndrugdrugcnt,cv.code_value,alertdata->override_drugdrug[num].reason_cd)=0
       )
        _ndrugdrugcnt += 1, _alterstat = alterlist(alertdata->override_drugdrug,_ndrugdrugcnt),
        alertdata->override_drugdrug[_ndrugdrugcnt].reason_cd = cv.code_value,
        alertdata->override_drugdrug[_ndrugdrugcnt].reason_disp = cv.display
       ENDIF
      ENDIF
      IF (loverridedrugfoodbw=0)
       IF (locateval(num,1,_ndrugfoodcnt,cv.code_value,alertdata->override_drugfood[num].reason_cd)=0
       )
        _ndrugfoodcnt += 1, _alterstat = alterlist(alertdata->override_drugfood,_ndrugfoodcnt),
        alertdata->override_drugfood[_ndrugfoodcnt].reason_cd = cv.code_value,
        alertdata->override_drugfood[_ndrugfoodcnt].reason_disp = cv.display
       ENDIF
      ENDIF
      IF (loverrideduptherapybw=0)
       IF (locateval(num,1,_ndupcnt,cv.code_value,alertdata->override_duptherapy[num].reason_cd)=0)
        _ndupcnt += 1, _alterstat = alterlist(alertdata->override_duptherapy,_ndupcnt), alertdata->
        override_duptherapy[_ndupcnt].reason_cd = cv.code_value,
        alertdata->override_duptherapy[_ndupcnt].reason_disp = cv.display
       ENDIF
      ENDIF
     ENDIF
     IF (cve.field_name="ALLERGY")
      IF (loverrideallergybw=0)
       IF (locateval(num,1,_nallergycnt,cv.code_value,alertdata->override_allergy[num].reason_cd)=0)
        _nallergycnt += 1, _alterstat = alterlist(alertdata->override_allergy,_nallergycnt),
        alertdata->override_allergy[_nallergycnt].reason_cd = cv.code_value,
        alertdata->override_allergy[_nallergycnt].reason_disp = cv.display
       ENDIF
      ENDIF
      IF (loverrideallbw=0)
       IF (locateval(num,1,_nallcnt,cv.code_value,alertdata->override_all[num].reason_cd)=0)
        _nallcnt += 1, _alterstat = alterlist(alertdata->override_all,_nallcnt), alertdata->
        override_all[_nallcnt].reason_cd = cv.code_value,
        alertdata->override_all[_nallcnt].reason_disp = cv.display
       ENDIF
      ENDIF
     ENDIF
     IF (cve.field_name="DRUGDRUG")
      IF (loverridedrugdrugbw=0)
       IF (locateval(num,1,_ndrugdrugcnt,cv.code_value,alertdata->override_drugdrug[num].reason_cd)=0
       )
        _ndrugdrugcnt += 1, _alterstat = alterlist(alertdata->override_drugdrug,_ndrugdrugcnt),
        alertdata->override_drugdrug[_ndrugdrugcnt].reason_cd = cv.code_value,
        alertdata->override_drugdrug[_ndrugdrugcnt].reason_disp = cv.display
       ENDIF
      ENDIF
      IF (loverrideallbw=0)
       IF (locateval(num,1,_nallcnt,cv.code_value,alertdata->override_all[num].reason_cd)=0)
        _nallcnt += 1, _alterstat = alterlist(alertdata->override_all,_nallcnt), alertdata->
        override_all[_nallcnt].reason_cd = cv.code_value,
        alertdata->override_all[_nallcnt].reason_disp = cv.display
       ENDIF
      ENDIF
     ENDIF
     IF (cve.field_name="DRUGFOOD")
      IF (loverridedrugfoodbw=0)
       IF (locateval(num,1,_ndrugfoodcnt,cv.code_value,alertdata->override_drugfood[num].reason_cd)=0
       )
        _ndrugfoodcnt += 1, _alterstat = alterlist(alertdata->override_drugfood,_ndrugfoodcnt),
        alertdata->override_drugfood[_ndrugfoodcnt].reason_cd = cv.code_value,
        alertdata->override_drugfood[_ndrugfoodcnt].reason_disp = cv.display
       ENDIF
      ENDIF
      IF (loverrideallbw=0)
       IF (locateval(num,1,_nallcnt,cv.code_value,alertdata->override_all[num].reason_cd)=0)
        _nallcnt += 1, _alterstat = alterlist(alertdata->override_all,_nallcnt), alertdata->
        override_all[_nallcnt].reason_cd = cv.code_value,
        alertdata->override_all[_nallcnt].reason_disp = cv.display
       ENDIF
      ENDIF
     ENDIF
     IF (cve.field_name="DUPTHERAPY")
      IF (loverrideduptherapybw=0)
       IF (locateval(num,1,_ndupcnt,cv.code_value,alertdata->override_duptherapy[num].reason_cd)=0)
        _ndupcnt += 1, _alterstat = alterlist(alertdata->override_duptherapy,_ndupcnt), alertdata->
        override_duptherapy[_ndupcnt].reason_cd = cv.code_value,
        alertdata->override_duptherapy[_ndupcnt].reason_disp = cv.display
       ENDIF
      ENDIF
      IF (loverrideallbw=0)
       IF (locateval(num,1,_nallcnt,cv.code_value,alertdata->override_all[num].reason_cd)=0)
        _nallcnt += 1, _alterstat = alterlist(alertdata->override_all,_nallcnt), alertdata->
        override_all[_nallcnt].reason_cd = cv.code_value,
        alertdata->override_all[_nallcnt].reason_disp = cv.display
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("No code value extensions found for code set 800.")
    SELECT INTO "nl:"
     c.display, c.code_value, c.collation_seq
     FROM code_value c
     WHERE c.code_set=800
      AND c.active_ind=1
     ORDER BY c.collation_seq, c.display
     HEAD REPORT
      _nreasons = 0
     DETAIL
      _nreasons += 1, _alterstat = alterlist(overridereasons->qual,_nreasons), overridereasons->qual[
      _nreasons].reason_cd = c.code_value,
      overridereasons->qual[_nreasons].reason_disp = c.display
     WITH nocounter
    ;end select
    IF (loverrideallbw=0)
     SET _movestat = moverec(overridereasons->qual,alertdata->override_all)
    ENDIF
    IF (loverrideallergybw=0)
     SET _movestat = moverec(overridereasons->qual,alertdata->override_allergy)
    ENDIF
    IF (loverridedrugdrugbw=0)
     SET _movestat = moverec(overridereasons->qual,alertdata->override_drugdrug)
    ENDIF
    IF (loverridedrugfoodbw=0)
     SET _movestat = moverec(overridereasons->qual,alertdata->override_drugfood)
    ENDIF
    IF (loverrideduptherapybw=0)
     SET _movestat = moverec(overridereasons->qual,alertdata->override_duptherapy)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE current_time_zone = i4 WITH constant(datetimezonebyname(curtimezone)), protect
 DECLARE ending_date_time = dq8 WITH constant(cnvtdatetime("31-DEC-2100")), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE lower_bound_date = vc WITH constant("01-JAN-1800 00:00:00.00"), protect
 DECLARE upper_bound_date = vc WITH constant("31-DEC-2100 23:59:59.99"), protect
 DECLARE codelistcnt = i4 WITH noconstant(0), protect
 DECLARE prsnllistcnt = i4 WITH noconstant(0), protect
 DECLARE phonelistcnt = i4 WITH noconstant(0), protect
 DECLARE code_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_idx = i4 WITH noconstant(0), protect
 DECLARE phone_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_cnt = i4 WITH noconstant(0), protect
 DECLARE mpc_ap_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_doc_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_mdoc_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_rad_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_txt_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_num_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_immun_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_med_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_date_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_done_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_mbo_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_procedure_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_grp_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE eventclasscdpopulated = i2 WITH protect, noconstant(0)
 DECLARE getorgsecurityflag(null) = i2 WITH protect
 DECLARE cclimpersonation(null) = null WITH protect
 SUBROUTINE (addcodetolist(code_value=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (code_value != 0)
    IF (((codelistcnt=0) OR (locateval(code_idx,1,codelistcnt,code_value,record_data->codes[code_idx]
     .code) <= 0)) )
     SET codelistcnt += 1
     SET stat = alterlist(record_data->codes,codelistcnt)
     SET record_data->codes[codelistcnt].code = code_value
     SET record_data->codes[codelistcnt].sequence = uar_get_collation_seq(code_value)
     SET record_data->codes[codelistcnt].meaning = uar_get_code_meaning(code_value)
     SET record_data->codes[codelistcnt].display = uar_get_code_display(code_value)
     SET record_data->codes[codelistcnt].description = uar_get_code_description(code_value)
     SET record_data->codes[codelistcnt].code_set = uar_get_code_set(code_value)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputcodelist(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputCodeList() @deprecated",log_level_debug)
 END ;Subroutine
 SUBROUTINE (addpersonneltolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   CALL addpersonneltolistwithdate(prsnl_id,record_data,current_date_time)
 END ;Subroutine
 SUBROUTINE (addpersonneltolistwithdate(prsnl_id=f8(val),record_data=vc(ref),active_date=f8(val)) =
  null WITH protect)
   DECLARE personnel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   IF (((active_date=null) OR (active_date=0.0)) )
    SET active_date = current_date_time
   ENDIF
   IF (prsnl_id != 0)
    IF (((prsnllistcnt=0) OR (locateval(prsnl_idx,1,prsnllistcnt,prsnl_id,record_data->prsnl[
     prsnl_idx].id,
     active_date,record_data->prsnl[prsnl_idx].active_date) <= 0)) )
     SET prsnllistcnt += 1
     IF (prsnllistcnt > size(record_data->prsnl,5))
      SET stat = alterlist(record_data->prsnl,(prsnllistcnt+ 9))
     ENDIF
     SET record_data->prsnl[prsnllistcnt].id = prsnl_id
     IF (validate(record_data->prsnl[prsnllistcnt].active_date) != 0)
      SET record_data->prsnl[prsnllistcnt].active_date = active_date
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputpersonnellist(report_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPersonnelList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE prsnl_name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
   DECLARE active_date_ind = i2 WITH protect, noconstant(0)
   DECLARE filteredcnt = i4 WITH protect, noconstant(0)
   DECLARE prsnl_seq = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   IF (prsnllistcnt > 0)
    SELECT INTO "nl:"
     FROM prsnl p,
      (left JOIN person_name pn ON pn.person_id=p.person_id
       AND pn.name_type_cd=prsnl_name_type_cd
       AND pn.active_ind=1)
     PLAN (p
      WHERE expand(idx,1,size(report_data->prsnl,5),p.person_id,report_data->prsnl[idx].id))
      JOIN (pn)
     ORDER BY p.person_id, pn.end_effective_dt_tm DESC
     HEAD REPORT
      prsnl_seq = 0, active_date_ind = validate(report_data->prsnl[1].active_date,0)
     HEAD p.person_id
      IF (active_date_ind=0)
       prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id)
       IF (pn.person_id > 0)
        report_data->prsnl[prsnl_seq].provider_name.name_full = trim(pn.name_full,3), report_data->
        prsnl[prsnl_seq].provider_name.name_first = trim(pn.name_first,3), report_data->prsnl[
        prsnl_seq].provider_name.name_middle = trim(pn.name_middle,3),
        report_data->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3), report_data->
        prsnl[prsnl_seq].provider_name.username = trim(p.username,3), report_data->prsnl[prsnl_seq].
        provider_name.initials = trim(pn.name_initials,3),
        report_data->prsnl[prsnl_seq].provider_name.title = trim(pn.name_initials,3)
       ELSE
        report_data->prsnl[prsnl_seq].provider_name.name_full = trim(p.name_full_formatted,3),
        report_data->prsnl[prsnl_seq].provider_name.name_first = trim(p.name_first,3), report_data->
        prsnl[prsnl_seq].provider_name.name_last = trim(p.name_last,3),
        report_data->prsnl[prsnl_seq].provider_name.username = trim(p.username,3)
       ENDIF
      ENDIF
     DETAIL
      IF (active_date_ind != 0)
       prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id)
       WHILE (prsnl_seq > 0)
        IF ((report_data->prsnl[prsnl_seq].active_date BETWEEN pn.beg_effective_dt_tm AND pn
        .end_effective_dt_tm))
         IF (pn.person_id > 0)
          report_data->prsnl[prsnl_seq].person_name_id = pn.person_name_id, report_data->prsnl[
          prsnl_seq].beg_effective_dt_tm = pn.beg_effective_dt_tm, report_data->prsnl[prsnl_seq].
          end_effective_dt_tm = pn.end_effective_dt_tm,
          report_data->prsnl[prsnl_seq].provider_name.name_full = trim(pn.name_full,3), report_data->
          prsnl[prsnl_seq].provider_name.name_first = trim(pn.name_first,3), report_data->prsnl[
          prsnl_seq].provider_name.name_middle = trim(pn.name_middle,3),
          report_data->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3), report_data->
          prsnl[prsnl_seq].provider_name.username = trim(p.username,3), report_data->prsnl[prsnl_seq]
          .provider_name.initials = trim(pn.name_initials,3),
          report_data->prsnl[prsnl_seq].provider_name.title = trim(pn.name_initials,3)
         ELSE
          report_data->prsnl[prsnl_seq].provider_name.name_full = trim(p.name_full_formatted,3),
          report_data->prsnl[prsnl_seq].provider_name.name_first = trim(p.name_first,3), report_data
          ->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3),
          report_data->prsnl[prsnl_seq].provider_name.username = trim(p.username,3)
         ENDIF
         IF ((report_data->prsnl[prsnl_seq].active_date=current_date_time))
          report_data->prsnl[prsnl_seq].active_date = 0
         ENDIF
        ENDIF
        ,prsnl_seq = locateval(idx,(prsnl_seq+ 1),prsnllistcnt,p.person_id,report_data->prsnl[idx].id
         )
       ENDWHILE
      ENDIF
     FOOT REPORT
      stat = alterlist(report_data->prsnl,prsnllistcnt)
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec(curqual,"PRSNL","OutputPersonnelList",1,0,
     report_data)
    IF (active_date_ind != 0)
     SELECT INTO "nl:"
      end_effective_dt_tm = report_data->prsnl[d.seq].end_effective_dt_tm, person_name_id =
      report_data->prsnl[d.seq].person_name_id, prsnl_id = report_data->prsnl[d.seq].id
      FROM (dummyt d  WITH seq = size(report_data->prsnl,5))
      ORDER BY end_effective_dt_tm DESC, person_name_id, prsnl_id
      HEAD REPORT
       filteredcnt = 0, idx = size(report_data->prsnl,5), stat = alterlist(report_data->prsnl,(idx *
        2))
      HEAD end_effective_dt_tm
       donothing = 0
      HEAD prsnl_id
       idx += 1, filteredcnt += 1, report_data->prsnl[idx].id = report_data->prsnl[d.seq].id,
       report_data->prsnl[idx].person_name_id = report_data->prsnl[d.seq].person_name_id
       IF ((report_data->prsnl[d.seq].person_name_id > 0.0))
        report_data->prsnl[idx].beg_effective_dt_tm = report_data->prsnl[d.seq].beg_effective_dt_tm,
        report_data->prsnl[idx].end_effective_dt_tm = report_data->prsnl[d.seq].end_effective_dt_tm
       ELSE
        report_data->prsnl[idx].beg_effective_dt_tm = cnvtdatetime("01-JAN-1900"), report_data->
        prsnl[idx].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       ENDIF
       report_data->prsnl[idx].provider_name.name_full = report_data->prsnl[d.seq].provider_name.
       name_full, report_data->prsnl[idx].provider_name.name_first = report_data->prsnl[d.seq].
       provider_name.name_first, report_data->prsnl[idx].provider_name.name_middle = report_data->
       prsnl[d.seq].provider_name.name_middle,
       report_data->prsnl[idx].provider_name.name_last = report_data->prsnl[d.seq].provider_name.
       name_last, report_data->prsnl[idx].provider_name.username = report_data->prsnl[d.seq].
       provider_name.username, report_data->prsnl[idx].provider_name.initials = report_data->prsnl[d
       .seq].provider_name.initials,
       report_data->prsnl[idx].provider_name.title = report_data->prsnl[d.seq].provider_name.title
      FOOT REPORT
       stat = alterlist(report_data->prsnl,idx), stat = alterlist(report_data->prsnl,filteredcnt,0)
      WITH nocounter
     ;end select
     CALL error_and_zero_check_rec(curqual,"PRSNL","FilterPersonnelList",1,0,
      report_data)
    ENDIF
   ENDIF
   CALL log_message(build("Exit OutputPersonnelList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addphonestolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (prsnl_id != 0)
    IF (((phonelistcnt=0) OR (locateval(phone_idx,1,phonelistcnt,prsnl_id,record_data->phone_list[
     prsnl_idx].person_id) <= 0)) )
     SET phonelistcnt += 1
     IF (phonelistcnt > size(record_data->phone_list,5))
      SET stat = alterlist(record_data->phone_list,(phonelistcnt+ 9))
     ENDIF
     SET record_data->phone_list[phonelistcnt].person_id = prsnl_id
     SET prsnl_cnt += 1
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputphonelist(report_data=vc(ref),phone_types=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPhoneList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE personcnt = i4 WITH protect, constant(size(report_data->phone_list,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE idx3 = i4 WITH protect, noconstant(0)
   DECLARE phonecnt = i4 WITH protect, noconstant(0)
   DECLARE prsnlidx = i4 WITH protect, noconstant(0)
   IF (phonelistcnt > 0)
    SELECT
     IF (size(phone_types->phone_codes,5)=0)
      phone_sorter = ph.phone_id
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ph.active_ind=1
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ELSE
      phone_sorter = locateval(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->
       phone_codes[idx2].phone_cd)
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ph.active_ind=1
       AND expand(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->phone_codes[
       idx2].phone_cd)
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ENDIF
     INTO "nl:"
     HEAD ph.parent_entity_id
      phonecnt = 0, prsnlidx = locateval(idx3,1,personcnt,ph.parent_entity_id,report_data->
       phone_list[idx3].person_id)
     HEAD phone_sorter
      phonecnt += 1
      IF (size(report_data->phone_list[prsnlidx].phones,5) < phonecnt)
       stat = alterlist(report_data->phone_list[prsnlidx].phones,(phonecnt+ 5))
      ENDIF
      report_data->phone_list[prsnlidx].phones[phonecnt].phone_id = ph.phone_id, report_data->
      phone_list[prsnlidx].phones[phonecnt].phone_type_cd = ph.phone_type_cd, report_data->
      phone_list[prsnlidx].phones[phonecnt].phone_type = uar_get_code_display(ph.phone_type_cd),
      report_data->phone_list[prsnlidx].phones[phonecnt].phone_num = formatphonenumber(ph.phone_num,
       ph.phone_format_cd,ph.extension)
     FOOT  ph.parent_entity_id
      stat = alterlist(report_data->phone_list[prsnlidx].phones,phonecnt)
     WITH nocounter, expand = value(evaluate(floor(((personcnt - 1)/ 30)),0,0,1))
    ;end select
    SET stat = alterlist(report_data->phone_list,prsnl_cnt)
    CALL error_and_zero_check_rec(curqual,"PHONE","OutputPhoneList",1,0,
     report_data)
   ENDIF
   CALL log_message(build("Exit OutputPhoneList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putstringtofile(svalue=vc(val)) =null WITH protect)
   CALL log_message("In PutStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (validate(_memory_reply_string)=1)
    SET _memory_reply_string = svalue
   ELSE
    FREE RECORD putrequest
    RECORD putrequest(
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line[*]
        2 linedata = vc
      1 overflowpage[*]
        2 ofr_qual[*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
    )
    SET putrequest->source_dir =  $OUTDEV
    SET putrequest->isblob = "1"
    SET putrequest->document = svalue
    SET putrequest->document_size = size(putrequest->document)
    EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
   ENDIF
   CALL log_message(build("Exit PutStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putunboundedstringtofile(trec=vc(ref)) =null WITH protect)
   CALL log_message("In PutUnboundedStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE curstringlength = i4 WITH noconstant(textlen(trec->val))
   DECLARE newmaxvarlen = i4 WITH noconstant(0)
   DECLARE origcurmaxvarlen = i4 WITH noconstant(0)
   IF (curstringlength > curmaxvarlen)
    SET origcurmaxvarlen = curmaxvarlen
    SET newmaxvarlen = (curstringlength+ 10000)
    SET modify maxvarlen newmaxvarlen
   ENDIF
   CALL putstringtofile(trec->val)
   IF (newmaxvarlen > 0)
    SET modify maxvarlen origcurmaxvarlen
   ENDIF
   CALL log_message(build("Exit PutUnboundedStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In PutJSONRecordToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   RECORD _tempjson(
     1 val = gvc
   )
   SET _tempjson->val = cnvtrectojson(record_data)
   CALL putunboundedstringtofile(_tempjson)
   CALL log_message(build("Exit PutJSONRecordToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getparametervalues(index=i4(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE par = vc WITH noconstant(""), protect
   DECLARE lnum = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(1), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE cnt2 = i4 WITH noconstant(0), protect
   DECLARE param_value = f8 WITH noconstant(0.0), protect
   DECLARE param_value_str = vc WITH noconstant(""), protect
   SET par = reflect(parameter(index,0))
   IF (validate(debug_ind,0)=1)
    CALL echo(par)
   ENDIF
   IF (((par="F8") OR (par="I4")) )
    SET param_value = parameter(index,0)
    IF (param_value > 0)
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = param_value
    ENDIF
   ELSEIF (substring(1,1,par)="C")
    SET param_value_str = parameter(index,0)
    IF (trim(param_value_str,3) != "")
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
    ENDIF
   ELSEIF (substring(1,1,par)="L")
    SET lnum = 1
    WHILE (lnum > 0)
     SET par = reflect(parameter(index,lnum))
     IF (par != " ")
      IF (((par="F8") OR (par="I4")) )
       SET param_value = parameter(index,lnum)
       IF (param_value > 0)
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = param_value
       ENDIF
       SET lnum += 1
      ELSEIF (substring(1,1,par)="C")
       SET param_value_str = parameter(index,lnum)
       IF (trim(param_value_str,3) != "")
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
       ENDIF
       SET lnum += 1
      ENDIF
     ELSE
      SET lnum = 0
     ENDIF
    ENDWHILE
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getlookbackdatebytype(units=i4(val),flag=i4(val)) =dq8 WITH protect)
   DECLARE looback_date = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
   IF (units != 0)
    CASE (flag)
     OF 1:
      SET looback_date = cnvtlookbehind(build(units,",H"),cnvtdatetime(sysdate))
     OF 2:
      SET looback_date = cnvtlookbehind(build(units,",D"),cnvtdatetime(sysdate))
     OF 3:
      SET looback_date = cnvtlookbehind(build(units,",W"),cnvtdatetime(sysdate))
     OF 4:
      SET looback_date = cnvtlookbehind(build(units,",M"),cnvtdatetime(sysdate))
     OF 5:
      SET looback_date = cnvtlookbehind(build(units,",Y"),cnvtdatetime(sysdate))
    ENDCASE
   ENDIF
   RETURN(looback_date)
 END ;Subroutine
 SUBROUTINE (getcodevaluesfromcodeset(evt_set_rec=vc(ref),evt_cd_rec=vc(ref)) =null WITH protect)
  DECLARE csidx = i4 WITH noconstant(0)
  SELECT DISTINCT INTO "nl:"
   FROM v500_event_set_explode vese
   WHERE expand(csidx,1,evt_set_rec->cnt,vese.event_set_cd,evt_set_rec->qual[csidx].value)
   DETAIL
    evt_cd_rec->cnt += 1, stat = alterlist(evt_cd_rec->qual,evt_cd_rec->cnt), evt_cd_rec->qual[
    evt_cd_rec->cnt].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (geteventsetnamesfromeventsetcds(evt_set_rec=vc(ref),evt_set_name_rec=vc(ref)) =null
  WITH protect)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE expand(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
    HEAD REPORT
     cnt = 0, evt_set_name_rec->cnt = evt_set_rec->cnt, stat = alterlist(evt_set_name_rec->qual,
      evt_set_rec->cnt)
    DETAIL
     pos = locateval(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     WHILE (pos > 0)
       cnt += 1, evt_set_name_rec->qual[pos].value = v.event_set_name, pos = locateval(index,(pos+ 1),
        evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_name_rec->cnt -= 1, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt,(pos
         - 1)), pos = locateval(index,pos,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].
        value)
     ENDWHILE
     evt_set_name_rec->cnt = cnt, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE (returnviewertype(eventclasscd=f8(val),eventid=f8(val)) =vc WITH protect)
   CALL log_message("In returnViewerType()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (eventclasscdpopulated=0)
    SET mpc_ap_type_cd = uar_get_code_by("MEANING",53,"AP")
    SET mpc_doc_type_cd = uar_get_code_by("MEANING",53,"DOC")
    SET mpc_mdoc_type_cd = uar_get_code_by("MEANING",53,"MDOC")
    SET mpc_rad_type_cd = uar_get_code_by("MEANING",53,"RAD")
    SET mpc_txt_type_cd = uar_get_code_by("MEANING",53,"TXT")
    SET mpc_num_type_cd = uar_get_code_by("MEANING",53,"NUM")
    SET mpc_immun_type_cd = uar_get_code_by("MEANING",53,"IMMUN")
    SET mpc_med_type_cd = uar_get_code_by("MEANING",53,"MED")
    SET mpc_date_type_cd = uar_get_code_by("MEANING",53,"DATE")
    SET mpc_done_type_cd = uar_get_code_by("MEANING",53,"DONE")
    SET mpc_mbo_type_cd = uar_get_code_by("MEANING",53,"MBO")
    SET mpc_procedure_type_cd = uar_get_code_by("MEANING",53,"PROCEDURE")
    SET mpc_grp_type_cd = uar_get_code_by("MEANING",53,"GRP")
    SET mpc_hlatyping_type_cd = uar_get_code_by("MEANING",53,"HLATYPING")
    SET eventclasscdpopulated = 1
   ENDIF
   DECLARE sviewerflag = vc WITH protect, noconstant("")
   CASE (eventclasscd)
    OF mpc_ap_type_cd:
     SET sviewerflag = "AP"
    OF mpc_doc_type_cd:
    OF mpc_mdoc_type_cd:
    OF mpc_rad_type_cd:
     SET sviewerflag = "DOC"
    OF mpc_txt_type_cd:
    OF mpc_num_type_cd:
    OF mpc_immun_type_cd:
    OF mpc_med_type_cd:
    OF mpc_date_type_cd:
    OF mpc_done_type_cd:
     SET sviewerflag = "EVENT"
    OF mpc_mbo_type_cd:
     SET sviewerflag = "MICRO"
    OF mpc_procedure_type_cd:
     SET sviewerflag = "PROC"
    OF mpc_grp_type_cd:
     SET sviewerflag = "GRP"
    OF mpc_hlatyping_type_cd:
     SET sviewerflag = "HLA"
    ELSE
     SET sviewerflag = "STANDARD"
   ENDCASE
   IF (eventclasscd=mpc_mdoc_type_cd)
    SELECT INTO "nl:"
     c2.*
     FROM clinical_event c1,
      clinical_event c2
     PLAN (c1
      WHERE c1.event_id=eventid)
      JOIN (c2
      WHERE c1.parent_event_id=c2.event_id
       AND c2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     HEAD c2.event_id
      IF (c2.event_class_cd=mpc_ap_type_cd)
       sviewerflag = "AP"
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit returnViewerType(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(sviewerflag)
 END ;Subroutine
 SUBROUTINE (cnvtisodttmtodq8(isodttmstr=vc) =dq8 WITH protect)
   DECLARE converteddq8 = dq8 WITH protect, noconstant(0)
   SET converteddq8 = cnvtdatetimeutc2(substring(1,10,isodttmstr),"YYYY-MM-DD",substring(12,8,
     isodttmstr),"HH:MM:SS",4,
    curtimezonedef)
   RETURN(converteddq8)
 END ;Subroutine
 SUBROUTINE (cnvtdq8toisodttm(dq8dttm=f8) =vc WITH protect)
   DECLARE convertedisodttm = vc WITH protect, noconstant("")
   IF (dq8dttm > 0.0)
    SET convertedisodttm = build(replace(datetimezoneformat(cnvtdatetime(dq8dttm),datetimezonebyname(
        "UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
   ELSE
    SET convertedisodttm = nullterm(convertedisodttm)
   ENDIF
   RETURN(convertedisodttm)
 END ;Subroutine
 SUBROUTINE getorgsecurityflag(null)
   DECLARE org_security_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    HEAD REPORT
     org_security_flag = 0
    DETAIL
     org_security_flag = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(org_security_flag)
 END ;Subroutine
 SUBROUTINE (getcomporgsecurityflag(dminfo_name=vc(val)) =i2 WITH protect)
   DECLARE org_security_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name=dminfo_name
    HEAD REPORT
     org_security_flag = 0
    DETAIL
     org_security_flag = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(org_security_flag)
 END ;Subroutine
 SUBROUTINE (populateauthorizedorganizations(personid=f8(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE organization_cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE por.person_id=personid
     AND por.active_ind=1
     AND por.beg_effective_dt_tm BETWEEN cnvtdatetime(lower_bound_date) AND cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime(upper_bound_date)
    ORDER BY por.organization_id
    HEAD REPORT
     organization_cnt = 0
    DETAIL
     organization_cnt += 1
     IF (mod(organization_cnt,20)=1)
      stat = alterlist(value_rec->organizations,(organization_cnt+ 19))
     ENDIF
     value_rec->organizations[organization_cnt].organizationid = por.organization_id
    FOOT REPORT
     value_rec->cnt = organization_cnt, stat = alterlist(value_rec->organizations,organization_cnt)
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getuserlogicaldomain(id=f8) =f8 WITH protect)
   DECLARE returnid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=id
    DETAIL
     returnid = p.logical_domain_id
    WITH nocounter
   ;end select
   RETURN(returnid)
 END ;Subroutine
 SUBROUTINE (getpersonneloverride(ppr_cd=f8(val)) =i2 WITH protect)
   DECLARE override_ind = i2 WITH protect, noconstant(0)
   IF (ppr_cd <= 0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=ppr_cd
     AND cve.code_set=331
     AND ((cve.field_value="1") OR (cve.field_value="2"))
     AND cve.field_name="Override"
    DETAIL
     override_ind = 1
    WITH nocounter
   ;end select
   RETURN(override_ind)
 END ;Subroutine
 SUBROUTINE cclimpersonation(null)
   CALL log_message("In cclImpersonation()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   EXECUTE secrtl
   DECLARE uar_secsetcontext(hctx=i4) = i2 WITH image_axp = "secrtl", image_aix =
   "libsec.a(libsec.o)", uar = "SecSetContext",
   persist
   DECLARE seccntxt = i4 WITH public
   DECLARE namelen = i4 WITH public
   DECLARE domainnamelen = i4 WITH public
   SET namelen = (uar_secgetclientusernamelen()+ 1)
   SET domainnamelen = (uar_secgetclientdomainnamelen()+ 2)
   SET stat = memalloc(name,1,build("C",namelen))
   SET stat = memalloc(domainname,1,build("C",domainnamelen))
   SET stat = uar_secgetclientusername(name,namelen)
   SET stat = uar_secgetclientdomainname(domainname,domainnamelen)
   SET setcntxt = uar_secimpersonate(nullterm(name),nullterm(domainname))
   CALL log_message(build("Exit cclImpersonation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (geteventsetdisplaysfromeventsetcds(evt_set_rec=vc(ref),evt_set_disp_rec=vc(ref)) =null
  WITH protect)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE expand(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
    HEAD REPORT
     cnt = 0, evt_set_disp_rec->cnt = evt_set_rec->cnt, stat = alterlist(evt_set_disp_rec->qual,
      evt_set_rec->cnt)
    DETAIL
     pos = locateval(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     WHILE (pos > 0)
       cnt += 1, evt_set_disp_rec->qual[pos].value = v.event_set_cd_disp, pos = locateval(index,(pos
        + 1),evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_disp_rec->cnt -= 1, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt,(pos
         - 1)), pos = locateval(index,pos,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].
        value)
     ENDWHILE
     evt_set_disp_rec->cnt = cnt, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE (decodestringparameter(description=vc(val)) =vc WITH protect)
   DECLARE decodeddescription = vc WITH private
   SET decodeddescription = replace(description,"%3B",";",0)
   SET decodeddescription = replace(decodeddescription,"%25","%",0)
   RETURN(decodeddescription)
 END ;Subroutine
 SUBROUTINE (urlencode(json=vc(val)) =vc WITH protect)
   DECLARE encodedjson = vc WITH private
   SET encodedjson = replace(json,char(91),"%5B",0)
   SET encodedjson = replace(encodedjson,char(123),"%7B",0)
   SET encodedjson = replace(encodedjson,char(58),"%3A",0)
   SET encodedjson = replace(encodedjson,char(125),"%7D",0)
   SET encodedjson = replace(encodedjson,char(93),"%5D",0)
   SET encodedjson = replace(encodedjson,char(44),"%2C",0)
   SET encodedjson = replace(encodedjson,char(34),"%22",0)
   RETURN(encodedjson)
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4(val)) =i2 WITH protect)
   CALL log_message("In IsTaskGranted",log_level_debug)
   DECLARE fntime = f8 WITH private, noconstant(curtime3)
   DECLARE task_granted = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM task_access ta,
     application_group ag
    PLAN (ta
     WHERE ta.task_number=task_number
      AND ta.app_group_cd > 0.0)
     JOIN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.app_group_cd=ta.app_group_cd
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     task_granted = 1
    WITH nocounter, maxqual(ta,1)
   ;end select
   CALL log_message(build("Exit IsTaskGranted - ",build2(cnvtint((curtime3 - fntime))),"0 ms"),
    log_level_debug)
   RETURN(task_granted)
 END ;Subroutine
 SET log_program_name = "discern_multum_304580"
 DECLARE proccessalertdata(null) = null WITH protect
 DECLARE buildbasehtml(null) = vc WITH protect
 DECLARE buildstaticcontenttags(null) = vc WITH protect
 DECLARE salertdata = vc WITH protect
 DECLARE scustomprgname = vc WITH noconstant("CCL_CUST_MULTUM_VIEW_TEST")
 DECLARE soutfile = vc WITH noconstant(""), protect
 DECLARE srecfile = vc WITH noconstant(""), protect
 DECLARE shtml = vc WITH noconstant(""), protect
 DECLARE sjavascripttags = vc WITH noconstant(""), protect
 DECLARE scsslinktags = vc WITH noconstant(""), protect
 SET soutfile = build("ccluserdir:ccl_multum_",cnvtstring(reqinfo->updt_id),".xml")
 SET srecfile = build("ccluserdir:ccl_multum_",cnvtstring(reqinfo->updt_id),".dat")
 IF (validate(request->blob_in))
  IF ((request->blob_in > " "))
   SET salertdata = request->blob_in
  ELSE
   SET salertdata = trim( $ALERTDATA)
  ENDIF
 ELSE
  SET salertdata = trim( $ALERTDATA)
 ENDIF
 IF (textlen(salertdata) <= 32000)
  SELECT INTO value(soutfile)
   jsonstring = salertdata
   WITH nocounter, maxcol = 10000
  ;end select
 ELSE
  CALL echo(build("sAlertData size= ",textlen(salertdata),", begin= ",substring(1,500,salertdata)))
 ENDIF
 IF (salertdata != "")
  SET cnvtstat = cnvtjsontorec(salertdata)
  IF (cnvtstat=1)
   CALL setoverridesrequired(null)
   SET _substat = populateinteractiondatafromquery(null)
   IF (_substat=0)
    CALL echo("populateInteractionDataFromQuery failed!")
    GO TO exit_error
   ENDIF
   CALL echorecord(alertdata,srecfile)
   CALL buildbasehtml(null)
  ELSE
   CALL echo("CNVTJSONTOREC failed!")
  ENDIF
 ELSE
  SET shtml = "discern_multum_304580 error! JSON data parameter is empty."
 ENDIF
 GO TO exit_script
 SUBROUTINE processalertdata(null)
   DECLARE prgexistsdba = i4 WITH noconstant(0), private
   DECLARE prgexists = i4 WITH noconstant(0), private
   DECLARE logmessage = vc WITH noconstant(""), private
   SET prgexistsdba = checkdic(scustomprgname,"P",0)
   SET prgexists = checkdic(scustomprgname,"P",1)
   IF (((prgexistsdba=2) OR (prgexists=2)) )
    IF (validate(debug_ind,0)=1)
     CALL echo("Calling Custom PRG")
    ENDIF
    SET stat = callprg(scustomprgname)
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo("Either the custom PRG did not exist or permission was denied")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE buildbasehtml(null)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SET buttonaudit = concat('<input type="button" value="Ccl_Rpt_Query" ',
    'class="ButtonDefaultText" onclick="javascript:runCclRptQuery();">')
   SET buttoncontinue = concat('<input type="button" value="Continue" ',
    'class="ButtonDefaultText" onclick="javascript:closeWindowWithStatus(3);">')
   SET buttoncancelorder = concat('<input type="button" value="Cancel Order" ',
    'class="ButtonDefaultText" onclick="javascript:closeWindowWithStatus(5);">')
   SET buttonerror = concat('<input type="button" value="Return Error" ',
    'class="ButtonDefaultText" onclick="javascript:closeWindowWithStatus(0);">')
   SET buttongetleafletsen = concat('<input type="button" value="Get Leaflets (English)" ',
    ^class="ButtonDefaultText" onclick="javascript:getHTMLLeaflets(0,'EN');">^)
   SET buttongetleafletssp = concat('<input type="button" value="Get Leaflets (Spanish)" ',
    ^class="ButtonDefaultText" onclick="javascript:getHTMLLeaflets(0,'SP');">^)
   SET buttongetpharm = concat('<input type="button" value="Get Pharmacology" ',
    ^class="ButtonDefaultText" onclick="javascript:getClinText('PHARMACOLOGY');">^)
   SET buttongetwarn = concat('<input type="button" value="Get Warnings" ',
    ^class="ButtonDefaultText" onclick="javascript:getClinText('WARNINGS');">^)
   SET buttongetlactation = concat('<input type="button" value="Get Lactation" ',
    ^class="ButtonDefaultText" onclick="javascript:getClinText('LACTATION');">^)
   SET buttongetsideeffects = concat('<input type="button" value="Get Side Effects" ',
    ^class="ButtonDefaultText" onclick="javascript:getClinText('SIDEFFECTS');">^)
   SET buttongetpregnancy = concat('<input type="button" value="Get Pregnancy" ',
    ^class="ButtonDefaultText" onclick="javascript:getClinText('PREGNANCY');">^)
   SET buttongetivcompat = concat('<input type="button" value="Get IV Compat" ',
    ^class="ButtonDefaultText" onclick="javascript:getClinText('IVCOMPAT');">^)
   SET buttongetdosage = concat('<input type="button" value="Get Dosage" ',
    ^class="ButtonDefaultText" onclick="javascript:getClinText('DOSAGE');">^)
   SET buttongetdosageadditional = concat('<input type="button" value="Get Dosage Additional" ',
    ^class="ButtonDefaultText" onclick="javascript:getClinText('DOSAGEADDITIONAL');">^)
   SET buttonshowalerthistory = concat('<input type="button" value="Show Alert History" ',
    'class="ButtonDefaultText" onclick="javascript:showAlertHistory(1);">')
   SET buttonshowalerthistory2 = concat('<input type="button" value="Show Alert History" ',
    'class="ButtonDefaultText" onclick="javascript:showAlertHistory(2);">')
   SET buttongetdescription = concat('<input type="button" value="Get Description" ',
    'class="ButtonDefaultText" onclick="javascript:getDescription();">')
   DECLARE ninteractions = i4
   DECLARE ntriggeringorderdetails = i4
   DECLARE _nitem = i4
   DECLARE _nitem2 = i4
   DECLARE ssetsubjectid = vc
   DECLARE ssetorderid = vc
   DECLARE ssetorderid2 = vc
   DECLARE ssetreasoncd = vc
   DECLARE dreasoncd = f8
   DECLARE show_title = vc
   DECLARE show_causing_id = vc
   DECLARE show_causing_disp = vc
   DECLARE show_interactions_title = vc
   DECLARE show_interactions_header = vc
   DECLARE show_person = vc
   DECLARE interactions_title = vc
   SET show_interactions_title = "<h4>Interactions:</h4>"
   IF ((alertdata->is_orders_mode=1))
    SET ntriggeringorderdetails = size(alertdata->triggering_order.order_details_list,5)
    IF (ntriggeringorderdetails=1
     AND (alertdata->triggering_order.order_details_list[1].field_meaning < ""))
     SET ntriggeringorderdetails = 0
    ENDIF
    SET show_title = "<h4>Triggering Order:</h4>"
    SET show_causing_info = concat('<table border="1"><tr>',"<td>",build(alertdata->triggering_order.
      subject_entity_id),"</td>","<td>",
     build(alertdata->triggering_order.subject_entity_name),"</td>","<td>",build(alertdata->
      triggering_order.subject_entity_cki),"</td>",
     "</tr></table>")
    SET ssetsubjectid = build("var dSubjectId = ",alertdata->triggering_order.subject_entity_id,";")
   ELSE
    SET ntriggeringorderdetails = 0
    SET show_title = "<h4>Triggering Allergy:</h4>"
    SET show_causing_info = concat('<table border="1"><tr>',"<td>",build(alertdata->interactions[1].
      subject_entity_id),"</td>","<td>",
     build(alertdata->interactions[1].subject_entity_name),"</td>","<td>",build(alertdata->
      interactions[1].subject_entity_cki),"</td>",
     "</tr></table>")
    SET ssetsubjectid = build("var dSubjectId = ",alertdata->interactions[1].subject_entity_id,";")
   ENDIF
   SET ninteractions = size(alertdata->interactions,5)
   SET ssetorderid = build("var dOrderId = ",alertdata->interactions[1].causing_entity_id,";")
   IF (ninteractions > 1)
    SET ssetorderid2 = build("var dOrderId = ",alertdata->interactions[2].causing_entity_id,";")
   ENDIF
   SET ssetcausingid = build("var dCausingId = ",alertdata->interactions[1].causing_entity_id,";")
   SET dreasoncd = uar_get_code_by("DISPLAYKEY",800,"NOTAPPLICABLE")
   SET ssetreasoncd = build("var dReasonCd = ",dreasoncd,";")
   SET ssetinteracty = build("var interactTy = ",alertdata->interactions[1].interaction_type,";")
   SET ssetcausingcki = build('var ckiValue = "',alertdata->interactions[1].causing_entity_cki,'";')
   SET ssetsubjectid2 = "var dSubjectId2 = 0;"
   SET ssetcausingid2 = "var dCausingId2 = 0;"
   SET ssetinteracty2 = "var interactTy2 = 0;"
   SET ssetcausingck2 = "var ckiValue2   = 0;"
   SET ssetsubjectid3 = "var dSubjectId3 = 0;"
   SET ssetcausingid3 = "var dCausingId3 = 0;"
   SET ssetinteracty3 = "var interactTy3 = 0;"
   SET ssetcausingck3 = "var ckiValue3   = 0;"
   SET ssetsubjectid4 = "var dSubjectId4 = 0;"
   SET ssetcausingid4 = "var dCausingId4 = 0;"
   SET ssetinteracty4 = "var interactTy4 = 0;"
   SET ssetcausingck4 = "var ckiValue4   = 0;"
   SET ssetsubjectid5 = "var dSubjectId5 = 0;"
   SET ssetcausingid5 = "var dCausingId5 = 0;"
   SET ssetinteracty5 = "var interactTy5 = 0;"
   SET ssetcausingck5 = "var ckiValue5   = 0;"
   IF (ninteractions >= 2)
    IF ((alertdata->interactions[2].is_override_required=1))
     SET ssetsubjectid2 = build("var dSubjectId2 = ",alertdata->interactions[2].subject_entity_id,";"
      )
     SET ssetcausingid2 = build("var dCausingId2 = ",alertdata->interactions[2].causing_entity_id,";"
      )
     SET ssetinteracty2 = build("var interactTy2 = ",alertdata->interactions[2].interaction_type,";")
     SET ssetcausingck2 = build("var ckiValue2   = ",alertdata->interactions[2].causing_entity_cki,
      ";")
    ENDIF
   ENDIF
   IF (ninteractions >= 3)
    IF ((alertdata->interactions[3].is_override_required=1))
     SET ssetsubjectid3 = build("var dSubjectId3 = ",alertdata->interactions[3].subject_entity_id,";"
      )
     SET ssetcausingid3 = build("var dCausingId3 = ",alertdata->interactions[3].causing_entity_id,";"
      )
     SET ssetinteracty3 = build("var interactTy3 = ",alertdata->interactions[3].interaction_type,";")
     SET ssetcausingck3 = build("var ckiValue3   = ",alertdata->interactions[3].causing_entity_cki,
      ";")
    ENDIF
   ENDIF
   IF (ninteractions >= 4)
    IF ((alertdata->interactions[4].is_override_required=1))
     SET ssetsubjectid4 = build("var dSubjectId4 = ",alertdata->interactions[4].subject_entity_id,";"
      )
     SET ssetcausingid4 = build("var dCausingId4 = ",alertdata->interactions[4].causing_entity_id,";"
      )
     SET ssetinteracty4 = build("var interactTy4 = ",alertdata->interactions[4].interaction_type,";")
     SET ssetcausingck4 = build("var ckiValue4   = ",alertdata->interactions[4].causing_entity_cki,
      ";")
    ENDIF
   ENDIF
   IF (ninteractions >= 5)
    IF ((alertdata->interactions[5].is_override_required=1))
     SET ssetsubjectid5 = build("var dSubjectId5 = ",alertdata->interactions[5].subject_entity_id,";"
      )
     SET ssetcausingid5 = build("var dCausingId5 = ",alertdata->interactions[5].causing_entity_id,";"
      )
     SET ssetinteracty5 = build("var interactTy5 = ",alertdata->interactions[5].interaction_type,";")
     SET ssetcausingck5 = build("var ckiValue5   = ",alertdata->interactions[5].causing_entity_cki,
      ";")
    ENDIF
   ENDIF
   SET ssetcausingcki = build('var ckiValue = "',alertdata->interactions[1].causing_entity_cki,'";')
   SET show_interactions_header = concat(
    "<th>Interaction Type</th><th>Severity</th><th>Causing Id</th><th>Causing Entity</th>",
    "<th>Causing CKI</th><th>Override Required</th><th>Order Status</th><th>Order Details</th><th>Order Details List</th></tr>"
    )
   SET show_person = concat("<h4>Name= ",alertdata->person_name,"</h4>")
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     row + 1, col 0, "<html>",
     row + 1, col 0, "<head><title> Multum Clinical Decision Support (mCDS) </title>",
     row + 1, col 0, "<META content='CCLLINK' name='discern'>",
     row + 1, col 0, '<script language="JavaScript" type="text/javascript">',
     row + 1, col 0, "function runCclRptQuery() {",
     row + 1, col 0, 'var obj_params = " ";',
     row + 1, col 0,
     "obj_params = '^MINE^, ^MJS_MULTUM_VIEW^, CURDATE-1, CURDATE+1, ^*^, ^*^, 0, ^*^, ^P^';",
     row + 1, col 0, '   javascript:CCLLINK("ccl_rpt_query",obj_params,1);',
     row + 1, col 0, "}   ",
     row + 1, col 0, "function closeWindowWithStatus(nStatus) {",
     row + 1, col 0, 'var formObject = window.external.DiscernObjectFactory("DISCERNMULTUMCOM");',
     row + 1, col 0, "if (null != formObject) ",
     row + 1, col 0, '{ updateOverrideReason("Not Applicable");',
     row + 1, col 0, "	formObject.DiscernCloseViewerWithStatus(nStatus);  }",
     row + 1, col 0, 'else {  alert("Failed to initialize DISCERNMULTUMCOM!");  }',
     row + 1, col 0, "}   ",
     row + 1, col 0, "function getHTMLLeaflets(nStatus, sLanguage) {",
     row + 1, col 0, ssetcausingcki,
     row + 1, col 0, 'var formObject = window.external.DiscernObjectFactory("DISCERNMULTUMCOM");',
     row + 1, col 0, "if (null != formObject) ",
     row + 1, col 0, "{  var sHtmlFile = formObject.DiscernGetHTMLLeaflets(ckiValue, sLanguage);  ",
     row + 1, col 0, " alert(sHtmlFile);  ",
     row + 1, col 0, "}  ",
     row + 1, col 0, 'else {  alert("Failed to initialize DISCERNMULTUMCOM!");  }',
     row + 1, col 0, "}  ",
     row + 1, col 0, "function getClinText(sName) {",
     row + 1, col 0, ssetcausingcki,
     row + 1, col 0, 'var formObject = window.external.DiscernObjectFactory("DISCERNMULTUMCOM");',
     row + 1, col 0, "if (null != formObject) ",
     row + 1, col 0, "{  var sClinText = formObject.DiscernGetClinicalText(ckiValue,sName);  ",
     row + 1, col 0, " alert(sClinText);  ",
     row + 1, col 0, "}  ",
     row + 1, col 0, 'else {  alert("Failed to initialize DISCERNMULTUMCOM!");  }',
     row + 1, col 0, "}  ",
     row + 1, col 0, "function updateOverrideReason(reasonDisp) {",
     row + 1, col 0, ssetcausingcki,
     row + 1, col 0, ssetcausingid,
     row + 1, col 0, ssetsubjectid,
     row + 1, col 0, ssetcausingid2,
     row + 1, col 0, ssetsubjectid2,
     row + 1, col 0, ssetcausingid3,
     row + 1, col 0, ssetsubjectid3,
     row + 1, col 0, ssetcausingid4,
     row + 1, col 0, ssetsubjectid4,
     row + 1, col 0, ssetcausingid5,
     row + 1, col 0, ssetsubjectid5,
     row + 1, col 0, ssetreasoncd,
     row + 1, col 0, 'var formObject = window.external.DiscernObjectFactory("DISCERNMULTUMCOM");',
     row + 1, col 0, "if (null != formObject) ",
     row + 1, col 0, "{	if ( dCausingId && dSubjectId)",
     row + 1, col 0,
     "		{formObject.DiscernUpdateOverrideReason(dCausingId,dSubjectId,dReasonCd,reasonDisp); }",
     row + 1, col 0, "	if ( dCausingId2 && dSubjectId2)",
     row + 1, col 0,
     "		{formObject.DiscernUpdateOverrideReason(dCausingId2,dSubjectId2,dReasonCd,reasonDisp); }",
     row + 1, col 0, "	if ( dCausingId3 && dSubjectId3)",
     row + 1, col 0,
     "		{formObject.DiscernUpdateOverrideReason(dCausingId3,dSubjectId3,dReasonCd,reasonDisp); }",
     row + 1, col 0, "	if ( dCausingId4 && dSubjectId4)",
     row + 1, col 0,
     "		{formObject.DiscernUpdateOverrideReason(dCausingId4,dSubjectId4,dReasonCd,reasonDisp); }",
     row + 1, col 0, "	if ( dCausingId5 && dSubjectId5)",
     row + 1, col 0,
     "		{formObject.DiscernUpdateOverrideReason(dCausingId5,dSubjectId5,dReasonCd,reasonDisp); }",
     row + 1, col 0, "}  ",
     row + 1, col 0, 'else {  alert("Failed to initialize DISCERNMULTUMCOM!");  }',
     row + 1, col 0, "}  ",
     row + 1, col 0, "function updateOverrideReason(reasonDisp) {",
     row + 1, col 0, ssetcausingcki,
     row + 1, col 0, ssetreasoncd,
     row + 1, col 0, ssetcausingid,
     row + 1, col 0, ssetsubjectid,
     row + 1, col 0, ssetinteracty,
     row + 1, col 0, ssetcausingck2,
     row + 1, col 0, ssetcausingid2,
     row + 1, col 0, ssetsubjectid2,
     row + 1, col 0, ssetinteracty2,
     row + 1, col 0, ssetcausingck3,
     row + 1, col 0, ssetcausingid3,
     row + 1, col 0, ssetsubjectid3,
     row + 1, col 0, ssetinteracty3,
     row + 1, col 0, ssetcausingck4,
     row + 1, col 0, ssetcausingid4,
     row + 1, col 0, ssetsubjectid4,
     row + 1, col 0, ssetinteracty4,
     row + 1, col 0, ssetcausingck5,
     row + 1, col 0, ssetcausingid5,
     row + 1, col 0, ssetsubjectid5,
     row + 1, col 0, ssetinteracty5,
     row + 1, col 0, 'var formObject = window.external.DiscernObjectFactory("DISCERNMULTUMCOM");',
     row + 1, col 0, "if (null != formObject) ",
     row + 1, col 0, "{	if ( dCausingId && dSubjectId && ckiValue && interactTy) {",
     row + 1, col 0, "	    formObject.DiscernUpdateOverrideReasonWithType(",
     row + 1, col 0, "			dCausingId",
     row + 1, col 0, "			,dSubjectId",
     row + 1, col 0, "			,dReasonCd",
     row + 1, col 0, "			,reasonDisp",
     row + 1, col 0, "			,interactTy",
     row + 1, col 0, "			,ckiValue);",
     row + 1, col 0, "	}",
     row + 1, col 0, "	if ( dCausingId2 && dSubjectId2 && ckiValue2 && interactTy2) {",
     row + 1, col 0, "	    formObject.DiscernUpdateOverrideReasonWithType(",
     row + 1, col 0, "			dCausingId2",
     row + 1, col 0, "			,dSubjectId2",
     row + 1, col 0, "			,dReasonCd",
     row + 1, col 0, "			,reasonDisp",
     row + 1, col 0, "			,interactTy2",
     row + 1, col 0, "			,ckiValue2);",
     row + 1, col 0, "	}",
     row + 1, col 0, "	if ( dCausingId3 && dSubjectId3 && ckiValue3 && interactTy3) {",
     row + 1, col 0, "	    formObject.DiscernUpdateOverrideReasonWithType(",
     row + 1, col 0, "			dCausingId3",
     row + 1, col 0, "			,dSubjectId3",
     row + 1, col 0, "			,dReasonCd",
     row + 1, col 0, "			,reasonDisp",
     row + 1, col 0, "			,interactTy3",
     row + 1, col 0, "			,ckiValue3);",
     row + 1, col 0, "	}",
     row + 1, col 0, "	if ( dCausingId4 && dSubjectId4 && ckiValue4 && interactTy4) {",
     row + 1, col 0, "	    formObject.DiscernUpdateOverrideReasonWithType(",
     row + 1, col 0, "			dCausingId4",
     row + 1, col 0, "			,dSubjectId4",
     row + 1, col 0, "			,dReasonCd",
     row + 1, col 0, "			,reasonDisp",
     row + 1, col 0, "			,interactTy4",
     row + 1, col 0, "			,ckiValue4);",
     row + 1, col 0, "	}",
     row + 1, col 0, "	if ( dCausingId4 && dSubjectId4 && ckiValue4 && interactTy4) {",
     row + 1, col 0, "	    formObject.DiscernUpdateOverrideReasonWithType(",
     row + 1, col 0, "			dCausingId5",
     row + 1, col 0, "			,dSubjectId5",
     row + 1, col 0, "			,dReasonCd",
     row + 1, col 0, "			,reasonDisp",
     row + 1, col 0, "			,interactTy5",
     row + 1, col 0, "			,ckiValue5);",
     row + 1, col 0, "	}",
     row + 1, col 0, "}  ",
     row + 1, col 0, 'else {  alert("Failed to initialize DISCERNMULTUMCOM!");  }',
     row + 1, col 0, "}  ",
     row + 1, col 0, "function doAlertsExist() {",
     ssetcausingid = build("var dOrderId = ",alertdata->interactions[1].causing_entity_id,";"), row
      + 1, col 0,
     ssetcausingid, row + 1, col 0,
     'var formObject = window.external.DiscernObjectFactory("DISCERNMULTUMCOM");', row + 1, col 0,
     "if (null != formObject) ", row + 1, col 0,
     "{  var sExists = formObject.DiscernCheckAlertsExist(dOrderId,0);  ", row + 1, col 0,
     '   if (sExists) { alert("Alerts exists");  }  else { alert("No alerts exist");  }', row + 1,
     col 0,
     "}  ", row + 1, col 0,
     'else {  alert("Failed to initialize DISCERNMULTUMCOM!");  }', row + 1, col 0,
     "}  ", row + 1, col 0,
     "function showAlertHistory(nInteraction) {", row + 1, col 0,
     "if (nInteraction == 1) { ", row + 1, col 0,
     ssetorderid, row + 1, col 0,
     "} else { ", row + 1, col 0,
     ssetorderid2, row + 1, col 0,
     "} ", row + 1, col 0,
     'var formObject = window.external.DiscernObjectFactory("DISCERNMULTUMCOM");', row + 1, col 0,
     "if (null != formObject) ", row + 1, col 0,
     "{  var sExists = formObject.DiscernCheckAlertsExist(dOrderId,0);  ", row + 1, col 0,
     "   if (sExists) { formObject.DiscernShowAlertHistory(dOrderId,0,0);  } ", row + 1, col 0,
     '   else { alert("No alerts exist");  }', row + 1, col 0,
     "}  ", row + 1, col 0,
     'else {  alert("Failed to initialize DISCERNMULTUMCOM!");  }', row + 1, col 0,
     "}  ", row + 1, col 0,
     "function getDescription() {", ssetcausingid = build("var dCausingId = ",alertdata->
      interactions[1].causing_entity_id,";"), row + 1,
     col 0, ssetcausingid, row + 1,
     col 0, ssetsubjectid, row + 1,
     col 0, 'var formObject = window.external.DiscernObjectFactory("DISCERNMULTUMCOM");', row + 1,
     col 0, "if (null != formObject) ", row + 1,
     col 0, "{  var sDescText = formObject.DiscernGetInteractionDesc(dCausingId,dSubjectId);  ", row
      + 1,
     col 0, " alert(sDescText);  ", row + 1,
     col 0, "}  ", row + 1,
     col 0, 'else {  alert("Failed to initialize DISCERNMULTUMCOM!");  }', row + 1,
     col 0, "}  ", row + 1,
     col 0, "</script>", row + 1,
     col 0, "</head><body>", row + 1,
     col 0, '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>', row + 1,
     col 0, "<h2>DiscernMultum Interactions Test View</h2>", row + 1,
     col 0, show_person, row + 1,
     col 0, show_title, row + 1,
     col 0, show_causing_info
     IF (ntriggeringorderdetails > 0)
      row + 1, col 0, '<table border= "1"><tr>',
      row + 1, col 0, "<h4>Order Details:</h4>",
      row + 1, col 0, "</tr>",
      row + 1, col 0, "<th>Meaning</th>",
      row + 1, col 0, "<th>value</th>"
      FOR (_nitem = 1 TO ntriggeringorderdetails)
        row + 1, col 0, "<tr>",
        row + 1, col 0, "<td>",
        alertdata->triggering_order.order_details_list[_nitem].field_meaning, "</td>", row + 1,
        col 0, "<td>", alertdata->triggering_order.order_details_list[_nitem].field_value,
        "</td>", row + 1, col 0,
        "</tr>"
      ENDFOR
      row + 1, col 0, "</table>"
     ENDIF
     row + 1, col 0, show_interactions_title,
     row + 1, col 0, '<table border= "1"><tr>',
     row + 1, col 0, show_interactions_header,
     row + 1, col 0, "<tr>"
     FOR (_nitem = 1 TO ninteractions)
       row + 1, col 0, "<td>",
       alertdata->interactions[_nitem].interaction_type, "</td>", row + 1,
       col 0, "<td>", alertdata->interactions[_nitem].severity_level,
       "</td>", row + 1, col 0,
       "<td>", alertdata->interactions[_nitem].causing_entity_id, "</td>",
       row + 1, col 0, "<td>",
       alertdata->interactions[_nitem].causing_entity_name, "</td>", row + 1,
       col 0, "<td>", alertdata->interactions[_nitem].causing_entity_cki,
       "</td>", row + 1, col 0,
       "<td>", alertdata->interactions[_nitem].is_override_required, "</td>",
       row + 1, col 0, "<td>",
       alertdata->interactions[_nitem].order_status, "</td>", row + 1,
       col 0, "<td>", alertdata->interactions[_nitem].order_details,
       "</td>", row + 1, col 0,
       "<td>", alertdata->interactions[_nitem].action_type_cd, "</td>",
       row + 1, col 0, "<td>",
       alertdata->interactions[_nitem].pathway_id, "</td>"
       IF ((alertdata->interactions[_nitem].order_details_list[1].field_meaning > ""))
        row + 1, col 0, '<td><table border="1">',
        row + 1, col 0, "<th>Meaning</th>",
        row + 1, col 0, "<th>value</th>",
        ndetailsize = size(alertdata->interactions[_nitem].order_details_list,5)
        FOR (_nitem2 = 1 TO ndetailsize)
          row + 1, col 0, "<tr>",
          row + 1, col 0, "<td>",
          alertdata->interactions[_nitem].order_details_list[_nitem2].field_meaning, "</td>", row + 1,
          col 0, "<td>", alertdata->interactions[_nitem].order_details_list[_nitem2].field_value,
          "</td>", row + 1, col 0,
          "</tr>"
        ENDFOR
        row + 1, col 0, "</table></td>"
       ENDIF
       row + 1, col 0, "</tr>"
     ENDFOR
     row + 1, col 0, "</table>",
     showtexttitle = concat("<h4>Multum Clinical Text (",ssetcausingcki,")</h4>"), row + 1, col 0,
     showtexttitle, row + 1, col 0,
     buttongetleafletsen, row + 1, col 0,
     buttongetleafletssp, row + 1, col 0,
     buttongetpharm, row + 1, col 0,
     buttongetwarn, row + 1, col 0,
     buttongetsideeffects, row + 1, col 0,
     buttongetdosage, row + 1, col 0,
     buttongetdosageadditional, showhistorytitle = concat("<h4>Alert History (",ssetorderid,")</h4>"),
     row + 1,
     col 0, showhistorytitle, row + 1,
     col 0, buttonshowalerthistory
     IF (ninteractions > 1)
      showhistorytitle2 = concat("<h4>Alert History (",ssetorderid2,")</h4>"), row + 1, col 0,
      showhistorytitle2, row + 1, col 0,
      buttonshowalerthistory2
     ENDIF
     row + 1, col 0, "<h4>Multum Actions:</h4>",
     row + 1, col 0, buttoncontinue
     IF ((alertdata->is_orders_mode=1))
      row + 1, col 0, buttoncancelorder
     ENDIF
     row + 1, col 0, buttongetdescription,
     row + 1, col 0, "</body>",
     row + 1, col 0, "</html>",
     row + 1
    WITH nocounter, format = variable, maxcol = 250
   ;end select
 END ;Subroutine
#exit_error
 SELECT INTO  $OUTDEV
  FROM dummyt d
  DETAIL
   row + 1, col 0, "<html>",
   row + 1, col 0, "<head><title> Multum Clinical Decision Support (mCDS)  </title>",
   row + 1, col 0, "<META content='CCLLINK' name='discern'>",
   row + 1, col 0, '<script language="JavaScript" type="text/javascript">',
   row + 1, col 0, "</script>",
   row + 1, col 0, "</head><body>",
   row + 1, col 0, '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>',
   row + 1, col 0, "<h3>Multum Clinical Decision Support - Script failure</h3>",
   row + 1, col 0, shtml,
   row + 1, col 0, "</body>",
   row + 1, col 0, "</html>",
   row + 1
  WITH nocounter, format = variable, maxcol = 300
 ;end select
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echorecord(alertdata)
  CALL echo(shtml)
 ELSE
  FREE RECORD alertdata
 ENDIF
 CALL echo(concat("Exiting script: ",log_program_name))
 DECLARE end_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
 CALL echo(build("Total time in seconds:",datetimediff(end_date_time,begin_date_time,5)))
END GO
