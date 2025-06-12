CREATE PROGRAM dcp_get_event_task_sum_data:dba
 SET modify = predeclare
 RECORD reply(
   1 person_name = vc
   1 fin_nbr = vc
   1 current_order_mnemonic = vc
   1 current_hna_order_mnemonic = vc
   1 current_ordered_as_mnemonic = vc
   1 current_clinical_display_line = vc
   1 current_med_order_type_cd = f8
   1 current_order_status_cd = f8
   1 previous_clinical_display_line = vc
   1 previous_med_order_type_cd = f8
   1 previous_order_status_cd = f8
   1 multi_ingred_for_event_cd_ind = i2
   1 previous_ingredients[*]
     2 order_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 strength = f8
     2 strength_unit = f8
     2 volume = f8
     2 volume_unit = f8
     2 freetext_dose = vc
     2 ingredient_type_flag = i2
     2 ingredientrateconversionind = i2
     2 clinically_significant_flag = i2
     2 freq_cd = f8
     2 normalized_rate = f8
     2 normalized_rate_unit_cd = f8
     2 normalized_rate_unit_cd_disp = vc
     2 normalized_rate_unit_cd_desc = vc
     2 normalized_rate_unit_cd_mean = vc
     2 concentration = f8
     2 concentration_unit_cd = f8
     2 concentration_unit_cd_disp = vc
     2 concentration_unit_cd_desc = vc
     2 concentration_unit_cd_mean = vc
     2 display_additives_first_ind = i2
   1 tasks[*]
     2 task_id = f8
     2 task_status_cd = f8
     2 task_status_cd_disp = vc
     2 task_status_cd_desc = vc
     2 task_status_cd_mean = vc
     2 task_dt_tm = dq8
     2 task_tz = i4
     2 task_route = vc
     2 task_class_cd = f8
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 task_ingredients[*]
       3 task_mnemonic = vc
       3 task_volume = f8
       3 task_volume_unit = f8
       3 task_strength = f8
       3 task_strength_unit = f8
       3 task_freetext_dose = vc
       3 ingred_event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp_tasks
 RECORD temp_tasks(
   1 tasks[*]
     2 task_id = f8
     2 task_status_cd = f8
     2 task_status_cd_disp = vc
     2 task_status_cd_desc = vc
     2 task_status_cd_mean = vc
     2 task_dt_tm = dq8
     2 task_tz = i4
     2 task_route = vc
     2 task_class_cd = f8
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 task_ingredients[*]
       3 task_mnemonic = vc
       3 task_volume = f8
       3 task_volume_unit = f8
       3 task_strength = f8
       3 task_strength_unit = f8
       3 task_freetext_dose = vc
       3 ingred_event_cd = f8
 )
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE prev_action_seq = i2 WITH protect, noconstant(0)
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE taskcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE from_dt_tm = f8 WITH protect, noconstant(cnvtlookbehind(concat(trim(cnvtstring(request->
      overdue_look_back_min)),",MIN")))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE querybyeventcd = i2 WITH protect, noconstant(request->query_by_event_cd)
 DECLARE eventcd = f8 WITH protect, noconstant(0.0)
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE vda_task = i2 WITH protect, noconstant(0)
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voidedwrslt_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE pendingtaskcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE overduetaskcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE inprocesstaskcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE pendingvaltaskcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 DECLARE maxtoreturn = i2 WITH protect, constant(2)
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"MED"))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE overdue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE iv = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE prn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE continuous_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE nonsched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"NSCH"))
 DECLARE loadviaeventcd(null) = null
 DECLARE loadcurrentorder(null) = null
 DECLARE loadpreviousorder(null) = null
 DECLARE loadpreviousingredients(null) = null
 DECLARE loadprevioustask(null) = null
 DECLARE loadfuturetask(null) = null
 DECLARE loadpersonname(null) = null
 DECLARE loadfinnbr(null) = null
 DECLARE loadprevioustasksbyeventcd = null
 DECLARE loadfuturetasksbyeventcd = null
 DECLARE addtemptasktoreply(temptaskidx=i4) = null
 DECLARE loadpreviousvdatasks(null) = null
 DECLARE loadfuturevdatasks(null) = null
 DECLARE loadvdatasksbyeventcd(null) = null
 SET reply->status_data.status = "F"
 CALL loadviaeventcd(null)
 CALL loadcurrentorder(null)
 CALL loadpersonname(null)
 CALL loadfinnbr(null)
 IF (prev_action_seq > 0)
  CALL loadpreviousorder(null)
  CALL loadpreviousingredients(null)
 ENDIF
 IF (querybyeventcd=1)
  IF ((reply->multi_ingred_for_event_cd_ind=0))
   IF (vda_task=1)
    CALL loadvdatasksbyeventcd(null)
   ELSE
    CALL loadtasksbyeventcd(null)
   ENDIF
  ENDIF
 ELSE
  IF (vda_task=1)
   CALL loadpreviousvdatasks(null)
   CALL loadfuturevdatasks(null)
  ELSE
   CALL loadprevioustasks(null)
   CALL loadfuturetasks(null)
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 SUBROUTINE loadcurrentorder(null)
   CALL echo("------------>LoadCurrentOrder<------------")
   DECLARE start_dt_diff = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    FROM orders o
    PLAN (o
     WHERE (o.order_id=request->template_order_id))
    HEAD REPORT
     prev_action_seq = 0
    HEAD o.order_id
     reply->current_order_mnemonic = o.order_mnemonic, reply->current_ordered_as_mnemonic = o
     .ordered_as_mnemonic, reply->current_hna_order_mnemonic = o.hna_order_mnemonic,
     reply->current_clinical_display_line = o.clinical_display_line, reply->current_med_order_type_cd
      = o.med_order_type_cd, reply->current_order_status_cd = o.order_status_cd,
     prev_action_seq = (o.last_action_sequence - 1), person_id = o.person_id, encntr_id = o.encntr_id
     IF (((o.dosing_method_flag=1) OR (o.template_dose_sequence > 0)) )
      vda_task = 1
     ENDIF
     IF ((request->overdue_look_back_min=0))
      start_dt_diff = datetimediff(cnvtdatetime(curdate,curtime3),o.current_start_dt_tm,4),
      from_dt_tm = cnvtlookbehind(concat(trim(cnvtstring(start_dt_diff)),",MIN"))
     ENDIF
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LCO - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero Qual Current"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadpreviousorder(null)
   CALL echo("------------>LoadPreviousOrder<------------")
   SELECT INTO "NL:"
    FROM order_action oa
    PLAN (oa
     WHERE (oa.order_id=request->template_order_id)
      AND oa.action_sequence=prev_action_seq
      AND oa.core_ind=1)
    HEAD oa.order_id
     reply->previous_clinical_display_line = oa.clinical_display_line, reply->
     previous_med_order_type_cd = reply->current_med_order_type_cd, reply->previous_order_status_cd
      = oa.order_status_cd
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LPO - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadpreviousingredients(null)
   CALL echo("------------>LoadPreviousIngredients<------------")
   DECLARE iingredcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM order_ingredient oi,
     order_catalog_synonym ocs
    PLAN (oi
     WHERE (oi.order_id=request->template_order_id)
      AND (oi.action_sequence=
     (SELECT
      max(oi1.action_sequence)
      FROM order_ingredient oi1
      WHERE (oi1.order_id=request->template_order_id)
       AND oi1.action_sequence <= prev_action_seq))
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id)
    ORDER BY oi.action_sequence, oi.comp_sequence
    HEAD oi.action_sequence
     iingredcnt = 0
    HEAD oi.comp_sequence
     iingredcnt = (iingredcnt+ 1)
     IF (mod(iingredcnt,5)=1)
      stat = alterlist(reply->previous_ingredients,(iingredcnt+ 4))
     ENDIF
     reply->previous_ingredients[iingredcnt].order_mnemonic = oi.order_mnemonic, reply->
     previous_ingredients[iingredcnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->
     previous_ingredients[iingredcnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
     reply->previous_ingredients[iingredcnt].strength = oi.strength, reply->previous_ingredients[
     iingredcnt].strength_unit = oi.strength_unit, reply->previous_ingredients[iingredcnt].volume =
     oi.volume,
     reply->previous_ingredients[iingredcnt].volume_unit = oi.volume_unit, reply->
     previous_ingredients[iingredcnt].freetext_dose = oi.freetext_dose, reply->previous_ingredients[
     iingredcnt].ingredient_type_flag = oi.ingredient_type_flag,
     reply->previous_ingredients[iingredcnt].concentration = oi.concentration, reply->
     previous_ingredients[iingredcnt].concentration_unit_cd = oi.concentration_unit_cd, reply->
     previous_ingredients[iingredcnt].freq_cd = oi.freq_cd,
     reply->previous_ingredients[iingredcnt].normalized_rate = oi.normalized_rate, reply->
     previous_ingredients[iingredcnt].normalized_rate_unit_cd = oi.normalized_rate_unit_cd, reply->
     previous_ingredients[iingredcnt].ingredientrateconversionind = ocs
     .ingredient_rate_conversion_ind,
     reply->previous_ingredients[iingredcnt].clinically_significant_flag = oi
     .clinically_significant_flag
     IF (validate(ocs.display_additives_first_ind))
      reply->previous_ingredients[iingredcnt].display_additives_first_ind = ocs
      .display_additives_first_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->previous_ingredients,iingredcnt)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LPI - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadprevioustasks(null)
   CALL echo("------------>LoadPreviousTasks<------------")
   DECLARE previoustaskcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM orders o,
     task_activity ta,
     order_ingredient oi,
     order_detail od
    PLAN (o
     WHERE (o.template_order_id=request->template_order_id)
      AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
     trans_cancel_cd,
     voidedwrslt_cd))))
     JOIN (oi
     WHERE oi.order_id=o.template_order_id
      AND oi.action_sequence <= o.template_core_action_sequence
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (od
     WHERE od.order_id=o.template_order_id
      AND od.action_sequence <= o.template_core_action_sequence
      AND od.oe_field_meaning_id=2050.00)
     JOIN (ta
     WHERE ta.order_id=o.order_id
      AND ta.task_status_cd IN (pendingtaskcd, overduetaskcd)
      AND ta.task_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ta.task_dt_tm >= cnvtdatetime(from_dt_tm))
    ORDER BY ta.task_dt_tm DESC, od.action_sequence, oi.action_sequence,
     oi.comp_sequence
    HEAD REPORT
     taskcnt = size(reply->tasks,5), previoustaskcnt = 0
    HEAD ta.task_id
     previoustaskcnt = (previoustaskcnt+ 1), taskcnt = (taskcnt+ 1), stat = alterlist(reply->tasks,
      taskcnt),
     reply->tasks[taskcnt].task_dt_tm = ta.task_dt_tm, reply->tasks[taskcnt].task_id = ta.task_id,
     reply->tasks[taskcnt].task_status_cd = ta.task_status_cd,
     reply->tasks[taskcnt].task_tz = ta.task_tz, reply->tasks[taskcnt].task_class_cd = ta
     .task_class_cd, reply->tasks[taskcnt].current_start_dt_tm = o.current_start_dt_tm,
     reply->tasks[taskcnt].current_start_tz = o.current_start_tz
    HEAD oi.action_sequence
     taskingredcnt = 0
    HEAD oi.comp_sequence
     taskingredcnt = (taskingredcnt+ 1), stat = alterlist(reply->tasks[taskcnt].task_ingredients,
      taskingredcnt), reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_mnemonic = oi
     .order_mnemonic,
     reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_strength = oi.strength, reply->tasks[
     taskcnt].task_ingredients[taskingredcnt].task_strength_unit = oi.strength_unit, reply->tasks[
     taskcnt].task_ingredients[taskingredcnt].task_volume = oi.volume,
     reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume_unit = oi.volume_unit, reply->
     tasks[taskcnt].task_ingredients[taskingredcnt].task_freetext_dose = oi.freetext_dose, reply->
     tasks[taskcnt].task_route = od.oe_field_display_value
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LPT - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadfuturetasks(null)
   CALL echo("------------>LoadFutureTasks<------------")
   DECLARE futuretaskcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM orders o,
     task_activity ta,
     order_ingredient oi,
     order_detail od
    PLAN (o
     WHERE (o.template_order_id=request->template_order_id)
      AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
     trans_cancel_cd,
     voidedwrslt_cd))))
     JOIN (oi
     WHERE oi.order_id=o.template_order_id
      AND oi.action_sequence <= o.template_core_action_sequence
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (od
     WHERE od.order_id=o.template_order_id
      AND od.action_sequence <= o.template_core_action_sequence
      AND od.oe_field_meaning_id=2050.00)
     JOIN (ta
     WHERE ta.order_id=o.order_id
      AND ta.task_status_cd IN (pendingtaskcd, overduetaskcd)
      AND ta.task_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ta.task_dt_tm >= cnvtdatetime(from_dt_tm))
    ORDER BY ta.task_dt_tm, od.action_sequence, oi.action_sequence,
     oi.comp_sequence
    HEAD REPORT
     taskcnt = size(reply->tasks,5), futuretaskcnt = 0
    HEAD ta.task_id
     futuretaskcnt = (futuretaskcnt+ 1)
     IF (futuretaskcnt > maxtoreturn)
      CALL cancel(1)
     ENDIF
     IF (futuretaskcnt <= maxtoreturn)
      taskcnt = (taskcnt+ 1), stat = alterlist(reply->tasks,taskcnt), reply->tasks[taskcnt].
      task_route = od.oe_field_display_value,
      reply->tasks[taskcnt].task_dt_tm = ta.task_dt_tm, reply->tasks[taskcnt].task_id = ta.task_id,
      reply->tasks[taskcnt].task_status_cd = ta.task_status_cd,
      reply->tasks[taskcnt].task_tz = ta.task_tz, reply->tasks[taskcnt].task_class_cd = ta
      .task_class_cd, reply->tasks[taskcnt].current_start_dt_tm = o.current_start_dt_tm,
      reply->tasks[taskcnt].current_start_tz = o.current_start_tz
     ENDIF
    HEAD oi.action_sequence
     taskingredcnt = 0
    HEAD oi.comp_sequence
     IF (futuretaskcnt <= maxtoreturn)
      taskingredcnt = (taskingredcnt+ 1), stat = alterlist(reply->tasks[taskcnt].task_ingredients,
       taskingredcnt), reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_mnemonic = oi
      .order_mnemonic,
      reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_strength = oi.strength, reply->
      tasks[taskcnt].task_ingredients[taskingredcnt].task_strength_unit = oi.strength_unit, reply->
      tasks[taskcnt].task_ingredients[taskingredcnt].task_volume = oi.volume,
      reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume_unit = oi.volume_unit, reply
      ->tasks[taskcnt].task_ingredients[taskingredcnt].task_freetext_dose = oi.freetext_dose, reply->
      tasks[taskcnt].task_route = od.oe_field_display_value
     ENDIF
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LFT - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadpersonname(null)
   SELECT INTO "nl:"
    FROM person p
    PLAN (p
     WHERE p.person_id=person_id)
    HEAD p.person_id
     reply->person_name = p.name_full_formatted
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadfinnbr(null)
  DECLARE cfinnbr = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
  SELECT INTO "nl:"
   FROM encntr_alias ea
   PLAN (ea
    WHERE ea.encntr_id=encntr_id
     AND ea.encntr_alias_type_cd=cfinnbr)
   HEAD ea.encntr_id
    reply->fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE loadviaeventcd(null)
   CALL echo("------------>LoadViaEventCd<------------")
   DECLARE ingredcnt = i2 WITH protect, noconstant(0)
   IF (querybyeventcd=1)
    SELECT INTO "nl:"
     FROM orders o,
      order_ingredient oi,
      code_value_event_r cver
     PLAN (o
      WHERE (o.order_id=request->template_order_id))
      JOIN (oi
      WHERE oi.order_id=o.order_id
       AND oi.action_sequence=o.last_ingred_action_sequence
       AND oi.ingredient_type_flag != icompoundchild)
      JOIN (cver
      WHERE cver.parent_cd=oi.catalog_cd)
     HEAD REPORT
      ingredcnt = 0
     DETAIL
      ingredcnt = (ingredcnt+ 1)
      IF (iv=o.med_order_type_cd)
       querybyeventcd = 0
      ENDIF
      IF (ingredcnt <= 1)
       eventcd = cver.event_cd, personid = o.person_id
      ENDIF
     WITH nocounter
    ;end select
    IF (ingredcnt > 1
     AND querybyeventcd=1)
     SET reply->multi_ingred_for_event_cd_ind = 1
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE loadtasksbyeventcd(null)
   CALL echo("------------>LoadTasksByEventCd<------------")
   DECLARE ingredcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM task_activity ta,
     orders o,
     order_ingredient oi,
     order_detail od,
     code_value_event_r cver
    PLAN (ta
     WHERE ta.person_id=personid
      AND ta.task_type_cd=pharmacy_cd
      AND ta.task_status_cd IN (pending_cd, overdue_cd)
      AND ta.task_class_cd != continuous_cd
      AND ((ta.task_dt_tm > cnvtdatetime(from_dt_tm)) OR (ta.task_class_cd IN (prn_cd, nonsched_cd)
     )) )
     JOIN (o
     WHERE o.order_id=ta.order_id
      AND o.template_order_id=0
      AND o.orig_ord_as_flag IN (0, 5))
     JOIN (oi
     WHERE oi.order_id=o.order_id
      AND oi.action_sequence=o.last_ingred_action_sequence
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.oe_field_meaning_id=2050.00
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od2.order_id=od.order_id
       AND od2.oe_field_id=od.oe_field_id)))
     JOIN (cver
     WHERE cver.parent_cd=oi.catalog_cd)
    HEAD REPORT
     taskcnt = 0
    HEAD ta.task_id
     taskcnt = (taskcnt+ 1), stat = alterlist(temp_tasks->tasks,taskcnt), temp_tasks->tasks[taskcnt].
     task_dt_tm = ta.task_dt_tm,
     temp_tasks->tasks[taskcnt].task_id = ta.task_id, temp_tasks->tasks[taskcnt].task_status_cd = ta
     .task_status_cd, temp_tasks->tasks[taskcnt].task_tz = ta.task_tz,
     temp_tasks->tasks[taskcnt].task_class_cd = ta.task_class_cd, temp_tasks->tasks[taskcnt].
     current_start_dt_tm = o.current_start_dt_tm, temp_tasks->tasks[taskcnt].current_start_tz = o
     .current_start_tz
    HEAD oi.action_sequence
     taskingredcnt = 0
    HEAD oi.comp_sequence
     taskingredcnt = (taskingredcnt+ 1), stat = alterlist(temp_tasks->tasks[taskcnt].task_ingredients,
      taskingredcnt), temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_mnemonic = oi
     .order_mnemonic,
     temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_strength = oi.strength,
     temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_strength_unit = oi.strength_unit,
     temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume = oi.volume,
     temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume_unit = oi.volume_unit,
     temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_freetext_dose = oi.freetext_dose,
     temp_tasks->tasks[taskcnt].task_route = od.oe_field_display_value,
     temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].ingred_event_cd = cver.event_cd
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LPT - ",errmsg)
    GO TO exit_script
   ENDIF
   DECLARE futuretaskcnt = i4 WITH protect, noconstant(0)
   DECLARE addtask = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM task_activity ta,
     orders o,
     order_ingredient oi,
     order_detail od,
     code_value_event_r cver
    PLAN (ta
     WHERE ta.person_id=personid
      AND ta.task_type_cd=pharmacy_cd
      AND ta.task_status_cd IN (pending_cd, overdue_cd)
      AND ta.task_dt_tm > cnvtdatetime(from_dt_tm))
     JOIN (o
     WHERE o.order_id=ta.order_id
      AND o.template_order_id > 0
      AND o.orig_ord_as_flag IN (0, 5))
     JOIN (oi
     WHERE oi.order_id=o.template_order_id
      AND oi.action_sequence=o.template_core_action_sequence
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.oe_field_meaning_id=2050.00
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od2.order_id=od.order_id
       AND od2.oe_field_id=od.oe_field_id)))
     JOIN (cver
     WHERE cver.parent_cd=oi.catalog_cd)
    HEAD REPORT
     taskcnt = taskcnt, futuretaskcnt = 0
    HEAD ta.task_id
     addtask = 1
     IF (ta.task_dt_tm > cnvtdatetime(curdate,curtime3))
      futuretaskcnt = (futuretaskcnt+ 1)
      IF (futuretaskcnt > maxtoreturn)
       addtask = 0
      ENDIF
     ENDIF
     IF (addtask=1)
      taskcnt = (taskcnt+ 1), stat = alterlist(temp_tasks->tasks,taskcnt), temp_tasks->tasks[taskcnt]
      .task_dt_tm = ta.task_dt_tm,
      temp_tasks->tasks[taskcnt].task_id = ta.task_id, temp_tasks->tasks[taskcnt].task_status_cd = ta
      .task_status_cd, temp_tasks->tasks[taskcnt].task_tz = ta.task_tz,
      temp_tasks->tasks[taskcnt].task_class_cd = ta.task_class_cd, temp_tasks->tasks[taskcnt].
      current_start_dt_tm = o.current_start_dt_tm, temp_tasks->tasks[taskcnt].current_start_tz = o
      .current_start_tz
     ENDIF
    HEAD oi.action_sequence
     taskingredcnt = 0
    HEAD oi.comp_sequence
     IF (addtask=1)
      taskingredcnt = (taskingredcnt+ 1), stat = alterlist(temp_tasks->tasks[taskcnt].
       task_ingredients,taskingredcnt), temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].
      task_mnemonic = oi.order_mnemonic,
      temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_strength = oi.strength,
      temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_strength_unit = oi
      .strength_unit, temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume = oi
      .volume,
      temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume_unit = oi.volume_unit,
      temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_freetext_dose = oi
      .freetext_dose, temp_tasks->tasks[taskcnt].task_route = od.oe_field_display_value,
      temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].ingred_event_cd = cver.event_cd
     ENDIF
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LPT - ",errmsg)
    GO TO exit_script
   ENDIF
   IF (taskcnt > 0)
    FOR (taskidx = 1 TO taskcnt)
     SET ingredcnt = value(size(temp_tasks->tasks[taskidx].task_ingredients,5))
     FOR (ingredidx = 1 TO ingredcnt)
       IF ((temp_tasks->tasks[taskidx].task_ingredients[ingredidx].ingred_event_cd=eventcd))
        CALL addtemptasktoreply(taskidx)
        SET ingredidx = ingredcnt
       ENDIF
     ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE addtemptasktoreply(temptaskidx)
   DECLARE ingredcnt = i2 WITH protect, noconstant(0)
   DECLARE taskingredcnt = i2 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   SET cnt = (size(reply->tasks,5)+ 1)
   SET stat = alterlist(reply->tasks,cnt)
   SET reply->tasks[cnt].task_dt_tm = temp_tasks->tasks[temptaskidx].task_dt_tm
   SET reply->tasks[cnt].task_id = temp_tasks->tasks[temptaskidx].task_id
   SET reply->tasks[cnt].task_status_cd = temp_tasks->tasks[temptaskidx].task_status_cd
   SET reply->tasks[cnt].task_tz = temp_tasks->tasks[temptaskidx].task_tz
   SET reply->tasks[cnt].task_route = temp_tasks->tasks[temptaskidx].task_route
   SET reply->tasks[cnt].task_class_cd = temp_tasks->tasks[temptaskidx].task_class_cd
   SET reply->tasks[cnt].current_start_dt_tm = temp_tasks->tasks[temptaskidx].current_start_dt_tm
   SET reply->tasks[cnt].current_start_tz = temp_tasks->tasks[temptaskidx].current_start_tz
   SET ingredcnt = value(size(temp_tasks->tasks[taskidx].task_ingredients,5))
   SET stat = alterlist(reply->tasks[cnt].task_ingredients,ingredcnt)
   FOR (ingredidx = 0 TO ingredcnt)
     SET reply->tasks[cnt].task_ingredients[ingredidx].task_mnemonic = temp_tasks->tasks[temptaskidx]
     .task_ingredients[ingredidx].task_mnemonic
     SET reply->tasks[cnt].task_ingredients[ingredidx].task_strength = temp_tasks->tasks[temptaskidx]
     .task_ingredients[ingredidx].task_strength
     SET reply->tasks[cnt].task_ingredients[ingredidx].task_strength_unit = temp_tasks->tasks[
     temptaskidx].task_ingredients[ingredidx].task_strength_unit
     SET reply->tasks[cnt].task_ingredients[ingredidx].task_volume = temp_tasks->tasks[temptaskidx].
     task_ingredients[ingredidx].task_volume
     SET reply->tasks[cnt].task_ingredients[ingredidx].task_volume_unit = temp_tasks->tasks[
     temptaskidx].task_ingredients[ingredidx].task_volume_unit
     SET reply->tasks[cnt].task_ingredients[ingredidx].task_freetext_dose = temp_tasks->tasks[
     temptaskidx].task_ingredients[ingredidx].task_freetext_dose
     SET reply->tasks[cnt].task_ingredients[ingredidx].ingred_event_cd = temp_tasks->tasks[
     temptaskidx].task_ingredients[ingredidx].ingred_event_cd
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadpreviousvdatasks(null)
   CALL echo("------------>LoadPreviousVDATasks<------------")
   DECLARE previousvdataskcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM orders o,
     task_activity ta,
     order_ingredient oi,
     order_detail od,
     order_ingredient_dose oid
    PLAN (o
     WHERE (o.template_order_id=request->template_order_id)
      AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
     trans_cancel_cd,
     voidedwrslt_cd))))
     JOIN (oi
     WHERE oi.order_id=o.template_order_id
      AND oi.action_sequence <= o.template_core_action_sequence
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (od
     WHERE od.order_id=o.template_order_id
      AND od.action_sequence <= o.template_core_action_sequence
      AND od.oe_field_meaning_id=2050.00)
     JOIN (ta
     WHERE ta.order_id=o.order_id
      AND ta.task_status_cd IN (pendingtaskcd, overduetaskcd)
      AND ta.task_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ta.task_dt_tm >= cnvtdatetime(from_dt_tm))
     JOIN (oid
     WHERE oid.order_id=oi.order_id
      AND oid.action_sequence=oi.action_sequence
      AND oid.comp_sequence=oi.comp_sequence
      AND oid.dose_sequence=o.template_dose_sequence)
    ORDER BY ta.task_dt_tm DESC, od.action_sequence, oi.action_sequence,
     oi.comp_sequence
    HEAD REPORT
     taskcnt = size(reply->tasks,5), previousvdataskcnt = 0
    HEAD ta.task_id
     previousvdataskcnt = (previousvdataskcnt+ 1), taskcnt = (taskcnt+ 1), stat = alterlist(reply->
      tasks,taskcnt),
     reply->tasks[taskcnt].task_dt_tm = ta.task_dt_tm, reply->tasks[taskcnt].task_id = ta.task_id,
     reply->tasks[taskcnt].task_status_cd = ta.task_status_cd,
     reply->tasks[taskcnt].task_tz = ta.task_tz, reply->tasks[taskcnt].task_class_cd = ta
     .task_class_cd, reply->tasks[taskcnt].current_start_dt_tm = o.current_start_dt_tm,
     reply->tasks[taskcnt].current_start_tz = o.current_start_tz
    HEAD oi.action_sequence
     taskingredcnt = 0
    HEAD oi.comp_sequence
     taskingredcnt = (taskingredcnt+ 1), stat = alterlist(reply->tasks[taskcnt].task_ingredients,
      taskingredcnt), reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_mnemonic = oi
     .order_mnemonic,
     reply->tasks[taskcnt].task_route = od.oe_field_display_value, reply->tasks[taskcnt].
     task_ingredients[taskingredcnt].task_strength = oid.strength_dose_value, reply->tasks[taskcnt].
     task_ingredients[taskingredcnt].task_strength_unit = oid.strength_dose_unit_cd,
     reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume = oid.volume_dose_value, reply
     ->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume_unit = oid.volume_dose_unit_cd
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LPT - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadfuturevdatasks(null)
   CALL echo("------------>LoadFutureVDATasks<------------")
   DECLARE futurevdataskcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM orders o,
     task_activity ta,
     order_ingredient oi,
     order_detail od,
     order_ingredient_dose oid
    PLAN (o
     WHERE (o.template_order_id=request->template_order_id)
      AND  NOT (((o.order_status_cd+ 0) IN (canceled_cd, completed_cd, deleted_cd, discontinued_cd,
     trans_cancel_cd,
     voidedwrslt_cd))))
     JOIN (oi
     WHERE oi.order_id=o.template_order_id
      AND oi.action_sequence <= o.template_core_action_sequence
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (od
     WHERE od.order_id=o.template_order_id
      AND od.action_sequence <= o.template_core_action_sequence
      AND od.oe_field_meaning_id=2050.00)
     JOIN (ta
     WHERE ta.order_id=o.order_id
      AND ta.task_status_cd IN (pendingtaskcd, overduetaskcd)
      AND ta.task_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ta.task_dt_tm >= cnvtdatetime(from_dt_tm))
     JOIN (oid
     WHERE oid.order_id=oi.order_id
      AND oid.action_sequence=oi.action_sequence
      AND oid.comp_sequence=oi.comp_sequence
      AND oid.dose_sequence=o.template_dose_sequence)
    ORDER BY ta.task_dt_tm, od.action_sequence, oi.action_sequence,
     oi.comp_sequence
    HEAD REPORT
     taskcnt = size(reply->tasks,5), futurevdataskcnt = 0
    HEAD ta.task_id
     futurevdataskcnt = (futurevdataskcnt+ 1)
     IF (futurevdataskcnt > maxtoreturn)
      CALL cancel(1)
     ENDIF
     IF (futurevdataskcnt <= maxtoreturn)
      taskcnt = (taskcnt+ 1), stat = alterlist(reply->tasks,taskcnt), reply->tasks[taskcnt].
      task_route = od.oe_field_display_value,
      reply->tasks[taskcnt].task_dt_tm = ta.task_dt_tm, reply->tasks[taskcnt].task_id = ta.task_id,
      reply->tasks[taskcnt].task_status_cd = ta.task_status_cd,
      reply->tasks[taskcnt].task_tz = ta.task_tz, reply->tasks[taskcnt].task_class_cd = ta
      .task_class_cd, reply->tasks[taskcnt].current_start_dt_tm = o.current_start_dt_tm,
      reply->tasks[taskcnt].current_start_tz = o.current_start_tz
     ENDIF
    HEAD oi.action_sequence
     taskingredcnt = 0
    HEAD oi.comp_sequence
     IF (futurevdataskcnt <= maxtoreturn)
      taskingredcnt = (taskingredcnt+ 1), stat = alterlist(reply->tasks[taskcnt].task_ingredients,
       taskingredcnt), reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_mnemonic = oi
      .order_mnemonic,
      reply->tasks[taskcnt].task_route = od.oe_field_display_value, reply->tasks[taskcnt].
      task_ingredients[taskingredcnt].task_strength = oid.strength_dose_value, reply->tasks[taskcnt].
      task_ingredients[taskingredcnt].task_strength_unit = oid.strength_dose_unit_cd,
      reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume = oid.volume_dose_value,
      reply->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume_unit = oid
      .volume_dose_unit_cd
     ENDIF
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LFT - ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadvdatasksbyeventcd(null)
   CALL echo("------------>LoadVDATasksByEventCd<------------")
   DECLARE ingredcnt = i2 WITH protect, noconstant(0)
   DECLARE futuretaskcnt = i4 WITH protect, noconstant(0)
   DECLARE addtask = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM task_activity ta,
     orders o,
     order_ingredient oi,
     order_detail od,
     code_value_event_r cver,
     order_ingredient_dose oid
    PLAN (ta
     WHERE ta.person_id=personid
      AND ta.task_type_cd=pharmacy_cd
      AND ta.task_status_cd IN (pending_cd, overdue_cd)
      AND ta.task_dt_tm > cnvtdatetime(from_dt_tm))
     JOIN (o
     WHERE o.order_id=ta.order_id
      AND o.template_order_id > 0
      AND o.orig_ord_as_flag IN (0, 5))
     JOIN (oi
     WHERE oi.order_id=o.template_order_id
      AND oi.action_sequence=o.template_core_action_sequence
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.oe_field_meaning_id=2050.00
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od2.order_id=od.order_id
       AND od2.oe_field_id=od.oe_field_id)))
     JOIN (cver
     WHERE cver.parent_cd=oi.catalog_cd)
     JOIN (oid
     WHERE oid.order_id=oi.order_id
      AND oid.action_sequence=oi.action_sequence
      AND oid.comp_sequence=oi.comp_sequence
      AND oid.dose_sequence=o.template_dose_sequence)
    HEAD REPORT
     taskcnt = taskcnt, futuretaskcnt = 0
    HEAD ta.task_id
     addtask = 1
     IF (ta.task_dt_tm > cnvtdatetime(curdate,curtime3))
      futuretaskcnt = (futuretaskcnt+ 1)
      IF (futuretaskcnt > maxtoreturn)
       addtask = 0
      ENDIF
     ENDIF
     IF (addtask=1)
      taskcnt = (taskcnt+ 1), stat = alterlist(temp_tasks->tasks,taskcnt), temp_tasks->tasks[taskcnt]
      .task_dt_tm = ta.task_dt_tm,
      temp_tasks->tasks[taskcnt].task_id = ta.task_id, temp_tasks->tasks[taskcnt].task_status_cd = ta
      .task_status_cd, temp_tasks->tasks[taskcnt].task_tz = ta.task_tz,
      temp_tasks->tasks[taskcnt].task_class_cd = ta.task_class_cd, temp_tasks->tasks[taskcnt].
      current_start_dt_tm = o.current_start_dt_tm, temp_tasks->tasks[taskcnt].current_start_tz = o
      .current_start_tz
     ENDIF
    HEAD oi.action_sequence
     taskingredcnt = 0
    HEAD oi.comp_sequence
     IF (addtask=1)
      taskingredcnt = (taskingredcnt+ 1), stat = alterlist(temp_tasks->tasks[taskcnt].
       task_ingredients,taskingredcnt), temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].
      task_mnemonic = oi.order_mnemonic,
      temp_tasks->tasks[taskcnt].task_route = od.oe_field_display_value, temp_tasks->tasks[taskcnt].
      task_ingredients[taskingredcnt].ingred_event_cd = cver.event_cd, temp_tasks->tasks[taskcnt].
      task_ingredients[taskingredcnt].task_strength = oid.strength_dose_value,
      temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_strength_unit = oid
      .strength_dose_unit_cd, temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].task_volume
       = oid.volume_dose_value, temp_tasks->tasks[taskcnt].task_ingredients[taskingredcnt].
      task_volume_unit = oid.volume_dose_unit_cd
     ENDIF
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("LPT - ",errmsg)
    GO TO exit_script
   ENDIF
   IF (taskcnt > 0)
    FOR (taskidx = 1 TO taskcnt)
     SET ingredcnt = value(size(temp_tasks->tasks[taskidx].task_ingredients,5))
     FOR (ingredidx = 1 TO ingredcnt)
       IF ((temp_tasks->tasks[taskidx].task_ingredients[ingredidx].ingred_event_cd=eventcd))
        CALL addtemptasktoreply(taskidx)
        SET ingredidx = ingredcnt
       ENDIF
     ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 SET last_mod = "005 04/26/10"
 SET modify = nopredeclare
END GO
