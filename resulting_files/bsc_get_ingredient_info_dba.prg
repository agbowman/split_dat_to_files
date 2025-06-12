CREATE PROGRAM bsc_get_ingredient_info:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 template_order_id = f8
     2 action_sequence = i4
     2 route_cd = f8
     2 form_cd = f8
     2 plan_ind = i2
     2 taper_ind = i2
     2 order_comment_text = vc
     2 updt_dt_tm = dq8
     2 ingred_qual[*]
       3 catalog_cd = f8
       3 event_cd = f8
       3 synonym_id = f8
       3 order_mnemonic = vc
       3 strength = f8
       3 strength_unit = f8
       3 volume = f8
       3 volume_unit = f8
       3 freetext_dose = vc
       3 freq_cd = f8
       3 last_admin_disp_basis_flag = i2
       3 med_interval_warn_flag = i2
       3 ingredient_type_flag = i2
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 clinically_significant_flag = i2
       3 ingredient_rate_conversion_ind = i2
       3 display_additives_first_ind = i2
       3 normalized_rate = f8
       3 normalized_rate_unit_cd = f8
       3 cki = vc
     2 med_order_type_cd = f8
     2 dosing_method_flag = i2
     2 template_dose_seq = i4
     2 core_action_sequence = i4
     2 order_catalog_cd = f8
     2 sequence_ind = i2
     2 active_sequence_order = f8
     2 updated_to_verified_flag = i2
     2 future_ind = i2
     2 funding_source_cd = f8
     2 corrupted_dot_found = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 order_id = f8
     2 template_order_id = f8
     2 template_order_flag = i2
     2 protocol_order_id = f8
     2 action_sequence = i4
     2 plan_ind = i2
     2 taper_ind = i2
     2 med_order_type_cd = f8
     2 dosing_method_flag = i2
     2 template_dose_seq = i4
     2 core_action_sequence = i4
     2 catalog_cd = f8
     2 verify_flag = i2
     2 updt_dt_tm = dq8
     2 task_dt_tm = dq8
     2 prn_ind = i2
 )
 FREE RECORD last_non_cores
 RECORD last_non_cores(
   1 qual[*]
     2 template_order_id = f8
     2 last_non_core_action = i4
 )
 FREE RECORD ivsequence_orders_list
 RECORD ivsequence_orders_list(
   1 order_list[*]
     2 order_id = f8
   1 debug_ind = i2
 )
 FREE RECORD active_orders_reply
 RECORD active_orders_reply(
   1 order_list[*]
     2 current_order_id = f8
     2 active_order_id = f8
     2 sequence_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD protocolanddotordersmaw
 RECORD protocolanddotordersmaw(
   1 dot_ord_list[*]
     2 protocol_ord_id = f8
     2 total_dot_cnt = i4
     2 uncorrupted_dot_cnt = i4
     2 dots[*]
       3 dot_ord_id = f8
       3 uncorrupted_dots = i2
 )
 FREE RECORD referencecatalogcds
 RECORD referencecatalogcds(
   1 catalog_list[*]
     2 catalog_cd = f8
     2 cki = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE jidx = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE size_array = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE ingred_cnt = i4 WITH protect, noconstant(0)
 DECLARE req_order_cnt = i4 WITH protect, noconstant(size(request->qual,5))
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE nsize = i4 WITH protect, noconstant(50)
 DECLARE ntotal = i4 WITH noconstant((ceil((cnvtreal(req_order_cnt)/ nsize)) * nsize))
 DECLARE oit = i4 WITH protect, noconstant(0)
 DECLARE iordactionidx = i4 WITH protect, noconstant(0)
 DECLARE next_core_action_found = i2 WITH noconstant(0)
 DECLARE iordercnt = i4 WITH protect, noconstant(0)
 DECLARE inum = i4 WITH protect, noconstant(0)
 DECLARE ipos = i2 WITH protect, noconstant(0)
 DECLARE seqordercnt = i4 WITH protect, noconstant(0)
 DECLARE replyordercnt = i4 WITH protect, noconstant(0)
 DECLARE catpos = i4 WITH protect, noconstant(0)
 DECLARE catidx = i4 WITH protect, noconstant(0)
 DECLARE compound_child = i2 WITH protect, constant(5)
 DECLARE oe_field_meaning_id_route = f8 WITH protect, constant(2050.00)
 DECLARE oe_field_meaning_id_form = f8 WITH protect, constant(2014.00)
 DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE iv_type_cd = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE med_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE int_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE ivsequence_cd = f8 WITH constant(uar_get_code_by("MEANING",30183,"IVSEQUENCE")), protect
 DECLARE oe_field_meaning_id_funding_src = f8 WITH protect, constant(6020.00)
 DECLARE count_seq = i4 WITH noconstant(0)
 DECLARE iseq = i4 WITH noconstant(0)
 DECLARE protocolordidcnt = i4 WITH noconstant(0)
 DECLARE templateordidcnt = i4 WITH noconstant(0)
 DECLARE lastaddedtemplateordid = f8 WITH noconstant(0)
 DECLARE lastaddedprotocolordid = f8 WITH noconstant(0)
 DECLARE ref_cnt = i4 WITH protect, noconstant(0)
 DECLARE getprotocolanddotorders(null) = null
 DECLARE findcorrupteddotorders(null) = null
 DECLARE updateuncorrupteddotorderscount(null) = null
 DECLARE populatereplyfordotorder(null) = null
 DECLARE getckivalueforgivencatalogcds(null) = null
 DECLARE populateckivaluestoingredient(null) = null
 FREE RECORD action_compare
 RECORD action_compare(
   1 qual[*]
     2 orig_struct_index = i4
     2 template_order_id = f8
     2 action_qual[2]
       3 form_cd = f8
       3 route_cd = f8
       3 needs_verify_ind = i2
       3 core_ind = i2
       3 non_diluent_count = i4
       3 ingred_list[*]
         4 catalog_cd = f8
         4 freetext_dose = vc
         4 strength = f8
         4 strength_unit_cd = f8
         4 volume = f8
         4 volume_unit_cd = f8
         4 ingredient_type = i2
 )
 FREE RECORD items_to_check
 RECORD items_to_check(
   1 check_parent_ind = i2
   1 qual[*]
     2 order_id = f8
     2 template_core_action_sequence = i4
     2 template_dose_seq = i4
     2 verify_success_ind = i2
     2 second_action_core_ind = i2
 )
 FREE RECORD future_check
 RECORD future_check(
   1 qual[*]
     2 template_order_id = f8
     2 next_due_ord_id = f8
     2 next_due_dt_tm = dq8
 )
 FREE RECORD protocol_check
 RECORD protocol_check(
   1 qual[*]
     2 protocol_order_id = f8
     2 next_due_ord_id = f8
     2 next_due_dt_tm = dq8
 )
 DECLARE detail_form_meaning_id = f8 WITH protect, constant(2014.0)
 DECLARE detail_route_meaning_id = f8 WITH protect, constant(2050.0)
 DECLARE ingredient_type_diluent = i2 WITH protect, constant(2)
 DECLARE ingredient_type_compchild = i4 WITH protect, constant(5)
 DECLARE nv_not_needed = i4 WITH protect, constant(0)
 DECLARE nv_verified = i4 WITH protect, constant(3)
 DECLARE checkactionsequencecompatibility(null) = null
 DECLARE getnextdueorderids(null) = null
 DECLARE getnextdueprotocolids(null) = null
 SUBROUTINE (comparedosefields(order_index=i4,action1_index=i4,action2_index=i4) =i2)
   DECLARE bdosemismatch = i2 WITH private, noconstant(0)
   IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength > 0))
    OR ((action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength > 0)))
   )
    IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength)) OR ((
    action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength_unit_cd !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength_unit_cd))) )
     SET bdosemismatch = 1
    ENDIF
   ELSEIF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume > 0)
   ) OR ((action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume > 0))) )
    IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume)) OR ((
    action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume_unit_cd !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume_unit_cd))) )
     SET bdosemismatch = 1
    ENDIF
   ELSE
    IF ((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].freetext_dose
     != action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].freetext_dose))
     SET bdosemismatch = 1
    ENDIF
   ENDIF
   RETURN(bdosemismatch)
 END ;Subroutine
 SUBROUTINE checkactionsequencecompatibility(null)
   DECLARE ordercount = i4 WITH protect, noconstant(0)
   DECLARE actionindex = i4 WITH protect, noconstant(0)
   DECLARE ingredindex = i4 WITH protect, noconstant(0)
   DECLARE nindex = i4 WITH protect, noconstant(0)
   DECLARE bmismatch = i2 WITH protect, noconstant(0)
   DECLARE bexactmatch = i4 WITH protect, noconstant(0)
   DECLARE bfulldiluentmatchneeded = i2 WITH protect, noconstant(0)
   DECLARE catalogmatchindex = i4 WITH protect, noconstant(0)
   DECLARE ord2ingredindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(items_to_check->qual,5))),
     orders o,
     order_action oa,
     order_ingredient oi,
     order_detail od
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=items_to_check->qual[d.seq].order_id)
      AND o.dosing_method_flag=0)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_sequence <= 2)
     JOIN (oi
     WHERE oi.order_id=oa.order_id
      AND oi.action_sequence=oa.action_sequence
      AND oi.ingredient_type_flag != ingredient_type_compchild)
     JOIN (od
     WHERE (od.order_id= Outerjoin(oa.order_id))
      AND (od.action_sequence= Outerjoin(oa.action_sequence)) )
    ORDER BY d.seq, oa.action_sequence, oi.catalog_cd
    HEAD d.seq
     actionindex = 0, ordercount += 1
     IF (mod(ordercount,10)=1)
      stat = alterlist(action_compare->qual,(ordercount+ 9))
     ENDIF
     action_compare->qual[ordercount].template_order_id = oi.order_id, action_compare->qual[
     ordercount].orig_struct_index = d.seq
    HEAD oa.action_sequence
     ingredindex = 0, actionindex += 1
     IF (actionindex <= 2)
      action_compare->qual[ordercount].action_qual[actionindex].needs_verify_ind = oa
      .needs_verify_ind, action_compare->qual[ordercount].action_qual[actionindex].core_ind = oa
      .core_ind, action_compare->qual[ordercount].action_qual[actionindex].non_diluent_count = 0
     ENDIF
    HEAD oi.catalog_cd
     IF (actionindex <= 2)
      IF (oi.ingredient_type_flag != ingredient_type_diluent)
       action_compare->qual[ordercount].action_qual[actionindex].non_diluent_count += 1
      ENDIF
      ingredindex += 1, stat = alterlist(action_compare->qual[ordercount].action_qual[actionindex].
       ingred_list,ingredindex)
      IF ((((items_to_check->qual[d.seq].template_core_action_sequence=1)) OR ((items_to_check->qual[
      d.seq].template_core_action_sequence=0)
       AND (items_to_check->check_parent_ind=1))) )
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].catalog_cd
        = oi.catalog_cd, action_compare->qual[ordercount].action_qual[actionindex].ingred_list[
       ingredindex].freetext_dose = oi.freetext_dose, action_compare->qual[ordercount].action_qual[
       actionindex].ingred_list[ingredindex].strength = oi.strength,
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].
       strength_unit_cd = oi.strength_unit, action_compare->qual[ordercount].action_qual[actionindex]
       .ingred_list[ingredindex].volume = oi.volume, action_compare->qual[ordercount].action_qual[
       actionindex].ingred_list[ingredindex].volume_unit_cd = oi.volume_unit,
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].
       ingredient_type = oi.ingredient_type_flag
      ELSE
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].catalog_cd
        = actionindex
      ENDIF
     ENDIF
    DETAIL
     IF (actionindex <= 2)
      IF (od.oe_field_meaning_id=detail_form_meaning_id)
       action_compare->qual[ordercount].action_qual[actionindex].form_cd = od.oe_field_value
      ELSEIF (od.oe_field_meaning_id=detail_route_meaning_id)
       action_compare->qual[ordercount].action_qual[actionindex].route_cd = od.oe_field_value
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL alterlist(action_compare->qual,ordercount)
   FOR (nindex = 1 TO ordercount BY 1)
     SET bmismatch = 0
     SET bfulldiluentmatchneeded = 0
     IF ((action_compare->qual[nindex].action_qual[1].needs_verify_ind=nv_verified)
      AND (action_compare->qual[nindex].action_qual[2].needs_verify_ind=nv_not_needed))
      IF ((action_compare->qual[nindex].action_qual[1].non_diluent_count=0)
       AND (action_compare->qual[nindex].action_qual[2].non_diluent_count=0))
       IF (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)=size(action_compare->qual[
        nindex].action_qual[2].ingred_list,5))
        SET bmismatch = 1
       ELSE
        SET bfulldiluentmatchneeded = 1
       ENDIF
      ELSEIF ((action_compare->qual[nindex].action_qual[1].non_diluent_count != action_compare->qual[
      nindex].action_qual[2].non_diluent_count))
       SET bmismatch = 1
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].route_cd > 0)
       AND (action_compare->qual[nindex].action_qual[2].route_cd > 0)
       AND (action_compare->qual[nindex].action_qual[1].route_cd != action_compare->qual[nindex].
      action_qual[2].route_cd))
       SET bmismatch = 1
      ENDIF
      IF (bmismatch=0)
       FOR (ingredindex = 1 TO size(action_compare->qual[nindex].action_qual[1].ingred_list,5) BY 1)
        SET ord2ingredindex = locateval(catalogmatchindex,1,size(action_compare->qual[nindex].
          action_qual[2].ingred_list,5),action_compare->qual[nindex].action_qual[1].ingred_list[
         ingredindex].catalog_cd,action_compare->qual[nindex].action_qual[2].ingred_list[
         catalogmatchindex].catalog_cd)
        IF (ord2ingredindex > 0)
         IF ((((action_compare->qual[nindex].action_qual[1].ingred_list[ingredindex].ingredient_type
          != ingredient_type_diluent)) OR (bfulldiluentmatchneeded=1)) )
          SET bmismatch = comparedosefields(nindex,ingredindex,ord2ingredindex)
          IF (bmismatch=1)
           SET ingredindex = (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)+ 2)
          ENDIF
         ENDIF
        ELSE
         SET bmismatch = 1
         SET ingredindex = (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)+ 2)
        ENDIF
       ENDFOR
      ENDIF
     ELSE
      SET bmismatch = 1
     ENDIF
     IF (bmismatch=0)
      SET bmismatch = 1
      IF ((((action_compare->qual[nindex].action_qual[1].form_cd=0)) OR ((action_compare->qual[nindex
      ].action_qual[2].form_cd=0))) )
       SET bmismatch = 0
       SET bexactmatch = 1
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].form_cd > 0)
       AND (action_compare->qual[nindex].action_qual[2].form_cd > 0)
       AND (action_compare->qual[nindex].action_qual[1].form_cd != action_compare->qual[nindex].
      action_qual[2].form_cd))
       SET bmismatch = 1
       SELECT
        cvg2.child_code_value
        FROM code_value_group cvg1,
         code_value_group cvg2,
         code_value cv
        PLAN (cvg1
         WHERE (cvg1.child_code_value=action_compare->qual[nindex].action_qual[1].form_cd))
         JOIN (cv
         WHERE cv.code_value=cvg1.parent_code_value
          AND cv.code_set=4003329)
         JOIN (cvg2
         WHERE cvg2.parent_code_value=cv.code_value
          AND (cvg2.child_code_value=action_compare->qual[nindex].action_qual[2].form_cd))
        DETAIL
         bmismatch = 0, bexactmatch = 1
        WITH nocounter
       ;end select
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].form_cd=action_compare->qual[nindex].
      action_qual[2].form_cd))
       SET bmismatch = 0
       SET bexactmatch = 1
      ENDIF
      IF (bmismatch=0
       AND bexactmatch=1)
       SET bexactmatch = 0
       SET items_to_check->qual[action_compare->qual[nindex].orig_struct_index].verify_success_ind =
       1
       SET items_to_check->qual[action_compare->qual[nindex].orig_struct_index].
       second_action_core_ind = action_compare->qual[nindex].action_qual[2].core_ind
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getnextdueorderids(null)
   DECLARE ordercount = i4 WITH protect, noconstant(0)
   DECLARE idxnum = i4 WITH protect, noconstant(0)
   DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"MED"))
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta
    PLAN (o
     WHERE expand(idxnum,1,size(future_check->qual,5),o.template_order_id,future_check->qual[idxnum].
      template_order_id)
      AND o.template_order_id > 0)
     JOIN (ta
     WHERE ta.task_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ta.order_id=o.order_id
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=pending_cd
      AND ta.task_type_cd=med_cd)
    ORDER BY o.template_order_id, ta.task_dt_tm
    HEAD o.template_order_id
     ordercount += 1, future_check->qual[ordercount].next_due_ord_id = o.order_id, future_check->
     qual[ordercount].next_due_dt_tm = ta.task_dt_tm
    FOOT REPORT
     stat = alterlist(future_check->qual,ordercount)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getnextdueprotocolids(null)
   DECLARE idxnum = i4 WITH protect, noconstant(0)
   DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"MED"))
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta
    PLAN (o
     WHERE expand(idxnum,1,size(protocol_check->qual,5),o.protocol_order_id,protocol_check->qual[
      idxnum].protocol_order_id)
      AND o.protocol_order_id > 0)
     JOIN (ta
     WHERE ta.task_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ta.order_id=o.order_id
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=pending_cd
      AND ta.task_type_cd=med_cd)
    ORDER BY o.protocol_order_id, ta.task_dt_tm
    HEAD o.protocol_order_id
     rowcnt += 1, protocol_check->qual[rowcnt].next_due_ord_id = o.order_id, protocol_check->qual[
     rowcnt].next_due_dt_tm = ta.task_dt_tm
    FOOT REPORT
     stat = alterlist(protocol_check->qual,rowcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM orders o,
   task_activity ta
  PLAN (o
   WHERE expand(lidx,1,req_order_cnt,o.order_id,request->qual[lidx].order_id)
    AND o.order_id > 0)
   JOIN (ta
   WHERE ta.order_id=o.order_id)
  ORDER BY o.order_id
  HEAD REPORT
   order_cnt = 0
  HEAD o.order_id
   order_cnt += 1
   IF (order_cnt > size(reply->qual,5))
    stat = alterlist(temp->qual,(order_cnt+ 9)), stat = alterlist(items_to_check->qual,(order_cnt+ 9)
     ), stat = alterlist(protocol_check->qual,(order_cnt+ 9)),
    stat = alterlist(future_check->qual,(order_cnt+ 9))
   ENDIF
   items_to_check->check_parent_ind = 0
   IF (o.template_order_id=0)
    temp->qual[order_cnt].order_id = o.order_id, temp->qual[order_cnt].template_order_id = o.order_id,
    temp->qual[order_cnt].template_order_flag = o.template_order_flag,
    temp->qual[order_cnt].protocol_order_id = o.protocol_order_id, temp->qual[order_cnt].
    action_sequence = o.last_action_sequence, temp->qual[order_cnt].core_action_sequence = o
    .last_core_action_sequence,
    temp->qual[order_cnt].med_order_type_cd = o.med_order_type_cd, temp->qual[order_cnt].updt_dt_tm
     = o.updt_dt_tm, items_to_check->qual[order_cnt].order_id = o.order_id,
    items_to_check->qual[order_cnt].template_core_action_sequence = 99, temp->qual[order_cnt].prn_ind
     = o.prn_ind, temp->qual[order_cnt].task_dt_tm = ta.task_dt_tm
   ELSE
    temp->qual[order_cnt].order_id = o.order_id, temp->qual[order_cnt].template_order_id = o
    .template_order_id, temp->qual[order_cnt].template_order_flag = o.template_order_flag,
    temp->qual[order_cnt].protocol_order_id = o.protocol_order_id, temp->qual[order_cnt].updt_dt_tm
     = o.updt_dt_tm, temp->qual[order_cnt].action_sequence = o.template_core_action_sequence,
    temp->qual[order_cnt].core_action_sequence = o.template_core_action_sequence, temp->qual[
    order_cnt].med_order_type_cd = o.med_order_type_cd, items_to_check->qual[order_cnt].order_id = o
    .template_order_id,
    items_to_check->qual[order_cnt].template_core_action_sequence = o.template_core_action_sequence,
    temp->qual[order_cnt].prn_ind = o.prn_ind, temp->qual[order_cnt].task_dt_tm = ta.task_dt_tm
   ENDIF
   IF (o.med_order_type_cd IN (med_type_cd, int_type_cd)
    AND o.prn_ind=0
    AND ta.task_dt_tm > cnvtdatetime(sysdate))
    IF (o.template_order_id > 0
     AND o.protocol_order_id=0)
     IF (lastaddedtemplateordid != o.template_order_id)
      pos = locateval(inum,1,size(future_check->qual,5),o.template_order_id,future_check->qual[inum].
       template_order_id)
      IF (pos <= 0)
       templateordidcnt += 1, future_check->qual[templateordidcnt].template_order_id = o
       .template_order_id, lastaddedtemplateordid = o.template_order_id
      ENDIF
     ENDIF
    ELSEIF (o.protocol_order_id > 0)
     IF (lastaddedprotocolordid != o.protocol_order_id)
      pos = locateval(inum,1,size(protocol_check->qual,5),o.protocol_order_id,protocol_check->qual[
       inum].protocol_order_id)
      IF (pos <= 0)
       protocolordidcnt += 1, protocol_check->qual[protocolordidcnt].protocol_order_id = o
       .protocol_order_id, lastaddedprotocolordid = o.protocol_order_id
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (o.pathway_catalog_id > 0)
    temp->qual[order_cnt].plan_ind = 1
   ELSE
    temp->qual[order_cnt].plan_ind = 0
   ENDIF
   temp->qual[order_cnt].taper_ind = 0, temp->qual[order_cnt].dosing_method_flag = o
   .dosing_method_flag, temp->qual[order_cnt].template_dose_seq = o.template_dose_sequence,
   temp->qual[order_cnt].catalog_cd = o.catalog_cd, temp->qual[order_cnt].verify_flag = 0
  FOOT REPORT
   stat = alterlist(temp->qual,order_cnt), stat = alterlist(protocol_check->qual,protocolordidcnt),
   stat = alterlist(future_check->qual,templateordidcnt)
  WITH nocounter, expand = 1
 ;end select
 CALL checkactionsequencecompatibility(null)
 FOR (count_seq = 1 TO value(size(temp->qual,5)) BY 1)
   IF ((items_to_check->qual[count_seq].verify_success_ind=1))
    SET temp->qual[count_seq].verify_flag = 1
    SET temp->qual[count_seq].action_sequence = 2
    IF ((items_to_check->qual[count_seq].second_action_core_ind=1))
     SET temp->qual[count_seq].core_action_sequence = 2
    ENDIF
   ENDIF
 ENDFOR
 IF (templateordidcnt > 0)
  CALL getnextdueorderids(null)
  SET stat = alterlist(future_check->qual,templateordidcnt)
 ENDIF
 IF (protocolordidcnt > 0)
  CALL getnextdueprotocolids(null)
  SET stat = alterlist(protocol_check->qual,protocolordidcnt)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   order_action oa
  PLAN (d)
   JOIN (oa
   WHERE (oa.order_id=temp->qual[d.seq].template_order_id)
    AND (oa.action_sequence > temp->qual[d.seq].core_action_sequence))
  ORDER BY d.seq, oa.action_sequence
  HEAD d.seq
   bfoundnextcoreaction = 0
  DETAIL
   IF ((temp->qual[d.seq].template_order_id > 0.0))
    IF (bfoundnextcoreaction=0
     AND oa.core_ind=0)
     temp->qual[d.seq].core_action_sequence = oa.action_sequence
    ELSEIF (oa.core_ind=1)
     bfoundnextcoreaction = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET size_array = size(temp->qual,5)
 SELECT INTO "nl:"
  FROM order_action oa,
   (dummyt d  WITH seq = value(size_array))
  PLAN (d)
   JOIN (oa
   WHERE (oa.order_id=temp->qual[d.seq].template_order_id)
    AND (temp->qual[d.seq].template_order_id > 0.0)
    AND (oa.action_sequence > temp->qual[d.seq].action_sequence))
  ORDER BY d.seq, oa.action_sequence
  DETAIL
   IF ((oa.order_id != temp->qual[d.seq].order_id))
    IF (next_core_action_found=0
     AND oa.core_ind=0)
     temp->qual[d.seq].action_sequence = oa.action_sequence
    ELSE
     IF (oa.core_ind=1)
      next_core_action_found = 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->debug_ind=1))
  CALL echo("***********AFTER FETCHING ACTION SEQUENCES**********")
  CALL echorecord(temp)
 ENDIF
 SET size_array = size(temp->qual,5)
 SELECT INTO "nl:"
  FROM act_pw_comp apc,
   pathway pw,
   (dummyt d  WITH seq = value(size_array))
  PLAN (d
   WHERE size_array > 0)
   JOIN (apc
   WHERE (apc.parent_entity_id=temp->qual[d.seq].template_order_id)
    AND apc.parent_entity_name="ORDERS"
    AND apc.active_ind=1)
   JOIN (pw
   WHERE pw.pathway_id=apc.pathway_id)
  ORDER BY d.seq
  HEAD REPORT
   iordercnt = 0, stat = alterlist(ivsequence_orders_list->order_list,10)
  HEAD d.seq
   IF (trim(pw.type_mean)="TAPERPLAN")
    temp->qual[d.seq].taper_ind = 1
   ENDIF
   IF (pw.pathway_type_cd=ivsequence_cd)
    iordercnt += 1
    IF (mod(iordercnt,10)=1)
     stat = alterlist(ivsequence_orders_list->order_list,(iordercnt+ 9))
    ENDIF
    ivsequence_orders_list->order_list[iordercnt].order_id = apc.parent_entity_id
   ENDIF
  FOOT REPORT
   stat = alterlist(ivsequence_orders_list->order_list,iordercnt)
  WITH nocounter
 ;end select
 IF ((request->debug_ind=1))
  CALL echorecord(ivsequence_orders_list)
  CALL echo("***********AFTER FETCHING TAPER IND  AND SEQUENCED IV's**********")
  CALL echorecord(temp)
 ENDIF
 SET size_array = size(temp->qual,5)
 SELECT INTO "nl:"
  FROM order_ingredient oi,
   order_ingredient_dose oid,
   order_detail od,
   code_value_event_r cve,
   order_catalog_synonym ocs,
   dummyt d1,
   (dummyt d  WITH seq = value(size_array))
  PLAN (d)
   JOIN (oi
   WHERE (oi.order_id=temp->qual[d.seq].template_order_id)
    AND oi.ingredient_type_flag != compound_child
    AND (oi.action_sequence=
   (SELECT
    max(oi2.action_sequence)
    FROM order_ingredient oi2
    WHERE oi2.order_id=oi.order_id
     AND (oi2.action_sequence <= temp->qual[d.seq].action_sequence))))
   JOIN (oid
   WHERE (oid.order_id= Outerjoin(oi.order_id))
    AND (oid.action_sequence= Outerjoin(oi.action_sequence))
    AND (oid.comp_sequence= Outerjoin(oi.comp_sequence))
    AND (oid.dose_sequence= Outerjoin(temp->qual[d.seq].template_dose_seq)) )
   JOIN (cve
   WHERE (cve.parent_cd= Outerjoin(oi.catalog_cd)) )
   JOIN (ocs
   WHERE (ocs.synonym_id= Outerjoin(oi.synonym_id)) )
   JOIN (d1)
   JOIN (od
   WHERE (od.order_id=temp->qual[d.seq].order_id)
    AND od.oe_field_meaning_id IN (oe_field_meaning_id_route, oe_field_meaning_id_form,
   oe_field_meaning_id_funding_src)
    AND (od.action_sequence <=
   (SELECT
    max(od2.action_sequence)
    FROM order_detail od2
    WHERE od2.order_id=od.order_id
     AND od2.oe_field_id=od.oe_field_id
     AND (od2.action_sequence <= temp->qual[d.seq].action_sequence))))
  ORDER BY d.seq, oi.comp_sequence, od.oe_field_meaning_id,
   od.action_sequence DESC
  HEAD REPORT
   order_cnt = 0, ref_cnt = 0
  HEAD d.seq
   order_cnt += 1
   IF (order_cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(order_cnt+ 9))
   ENDIF
   IF ((temp->qual[d.seq].order_id=temp->qual[d.seq].template_order_id))
    reply->qual[order_cnt].template_order_id = 0
   ELSE
    reply->qual[order_cnt].template_order_id = temp->qual[d.seq].template_order_id
   ENDIF
   reply->qual[order_cnt].order_id = temp->qual[d.seq].order_id, reply->qual[order_cnt].plan_ind =
   temp->qual[d.seq].plan_ind, reply->qual[order_cnt].taper_ind = temp->qual[d.seq].taper_ind,
   reply->qual[order_cnt].med_order_type_cd = temp->qual[d.seq].med_order_type_cd, reply->qual[
   order_cnt].dosing_method_flag = temp->qual[d.seq].dosing_method_flag, reply->qual[order_cnt].
   template_dose_seq = temp->qual[d.seq].template_dose_seq,
   reply->qual[order_cnt].updt_dt_tm = temp->qual[d.seq].updt_dt_tm, reply->qual[order_cnt].
   order_catalog_cd = temp->qual[d.seq].catalog_cd, reply->qual[order_cnt].updated_to_verified_flag
    = temp->qual[d.seq].verify_flag
   IF ((temp->qual[d.seq].template_order_id != temp->qual[d.seq].order_id))
    reply->qual[order_cnt].action_sequence = 1, reply->qual[order_cnt].core_action_sequence = 1
   ELSE
    reply->qual[order_cnt].action_sequence = temp->qual[d.seq].action_sequence, reply->qual[order_cnt
    ].core_action_sequence = temp->qual[d.seq].core_action_sequence
   ENDIF
   IF (((templateordidcnt > 0) OR (protocolordidcnt > 0)) )
    IF ((temp->qual[d.seq].med_order_type_cd IN (med_type_cd, int_type_cd))
     AND (temp->qual[d.seq].prn_ind=0))
     IF ((temp->qual[d.seq].task_dt_tm > cnvtdatetime(sysdate)))
      IF ((reply->qual[order_cnt].template_order_id > 0)
       AND (temp->qual[d.seq].protocol_order_id=0))
       pos = locateval(inum,1,size(future_check->qual,5),reply->qual[order_cnt].order_id,future_check
        ->qual[inum].next_due_ord_id)
       IF (pos <= 0)
        reply->qual[order_cnt].future_ind = 1
       ENDIF
      ELSEIF ((temp->qual[d.seq].protocol_order_id > 0))
       pos = locateval(inum,1,size(protocol_check->qual,5),reply->qual[order_cnt].order_id,
        protocol_check->qual[inum].next_due_ord_id)
       IF (pos <= 0)
        reply->qual[order_cnt].future_ind = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   ingred_cnt = 0
  HEAD oi.comp_sequence
   ingred_cnt += 1
   IF (ingred_cnt > size(reply->qual[order_cnt].ingred_qual,5))
    stat = alterlist(reply->qual[order_cnt].ingred_qual,(ingred_cnt+ 1))
   ENDIF
   IF (size(referencecatalogcds->catalog_list,5)=0)
    ref_cnt += 1, stat = alterlist(referencecatalogcds->catalog_list,ref_cnt), referencecatalogcds->
    catalog_list[ref_cnt].catalog_cd = oi.catalog_cd
   ELSE
    catpos = locateval(catidx,1,size(referencecatalogcds->catalog_list,5),oi.catalog_cd,
     referencecatalogcds->catalog_list[catidx].catalog_cd)
    IF (catpos=0)
     ref_cnt += 1, stat = alterlist(referencecatalogcds->catalog_list,ref_cnt), referencecatalogcds->
     catalog_list[ref_cnt].catalog_cd = oi.catalog_cd
    ENDIF
   ENDIF
   reply->qual[order_cnt].ingred_qual[ingred_cnt].order_mnemonic = oi.order_mnemonic, reply->qual[
   order_cnt].ingred_qual[ingred_cnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->qual[
   order_cnt].ingred_qual[ingred_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
   reply->qual[order_cnt].ingred_qual[ingred_cnt].catalog_cd = oi.catalog_cd, reply->qual[order_cnt].
   ingred_qual[ingred_cnt].synonym_id = oi.synonym_id, reply->qual[order_cnt].ingred_qual[ingred_cnt]
   .event_cd = cve.event_cd,
   reply->qual[order_cnt].ingred_qual[ingred_cnt].freq_cd = oi.freq_cd, reply->qual[order_cnt].
   ingred_qual[ingred_cnt].last_admin_disp_basis_flag = ocs.last_admin_disp_basis_flag, reply->qual[
   order_cnt].ingred_qual[ingred_cnt].med_interval_warn_flag = ocs.med_interval_warn_flag,
   reply->qual[order_cnt].ingred_qual[ingred_cnt].ingredient_type_flag = oi.ingredient_type_flag,
   reply->qual[order_cnt].ingred_qual[ingred_cnt].clinically_significant_flag = oi
   .clinically_significant_flag, reply->qual[order_cnt].ingred_qual[ingred_cnt].
   ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind,
   reply->qual[order_cnt].ingred_qual[ingred_cnt].display_additives_first_ind = ocs
   .display_additives_first_ind, reply->qual[order_cnt].ingred_qual[ingred_cnt].normalized_rate = oi
   .normalized_rate, reply->qual[order_cnt].ingred_qual[ingred_cnt].normalized_rate_unit_cd = oi
   .normalized_rate_unit_cd
   IF (oid.order_ingredient_dose_id > 0)
    reply->qual[order_cnt].ingred_qual[ingred_cnt].strength = oid.strength_dose_value, reply->qual[
    order_cnt].ingred_qual[ingred_cnt].strength_unit = oid.strength_dose_unit_cd, reply->qual[
    order_cnt].ingred_qual[ingred_cnt].volume = oid.volume_dose_value,
    reply->qual[order_cnt].ingred_qual[ingred_cnt].volume_unit = oid.volume_dose_unit_cd
   ELSE
    reply->qual[order_cnt].ingred_qual[ingred_cnt].strength = oi.strength, reply->qual[order_cnt].
    ingred_qual[ingred_cnt].strength_unit = oi.strength_unit, reply->qual[order_cnt].ingred_qual[
    ingred_cnt].volume = oi.volume,
    reply->qual[order_cnt].ingred_qual[ingred_cnt].volume_unit = oi.volume_unit, reply->qual[
    order_cnt].ingred_qual[ingred_cnt].freetext_dose = oi.freetext_dose
   ENDIF
  HEAD od.oe_field_meaning_id
   IF (od.oe_field_meaning_id=oe_field_meaning_id_route)
    reply->qual[order_cnt].route_cd = od.oe_field_value
   ELSEIF (od.oe_field_meaning_id=oe_field_meaning_id_form)
    reply->qual[order_cnt].form_cd = od.oe_field_value
   ELSEIF (od.oe_field_meaning_id=oe_field_meaning_id_funding_src)
    reply->qual[order_cnt].funding_source_cd = od.oe_field_value
   ENDIF
   IF ((reply->qual[order_cnt].updated_to_verified_flag=1))
    IF ((action_compare->qual[order_cnt].action_qual[1].form_cd=0))
     reply->qual[order_cnt].form_cd = action_compare->qual[order_cnt].action_qual[2].form_cd
    ENDIF
    reply->qual[order_cnt].action_sequence = temp->qual[order_cnt].action_sequence, reply->qual[
    order_cnt].core_action_sequence = temp->qual[order_cnt].core_action_sequence
    IF ((action_compare->qual[order_cnt].action_qual[1].route_cd=0))
     reply->qual[order_cnt].route_cd = action_compare->qual[order_cnt].action_qual[2].route_cd
    ENDIF
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->qual[order_cnt].ingred_qual,ingred_cnt)
  FOOT REPORT
   stat = alterlist(reply->qual,order_cnt)
  WITH counter, outerjoin = d1
 ;end select
 SET stat = alterlist(request->qual,ntotal)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   order_comment oc,
   long_text lt
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
   JOIN (oc
   WHERE expand(lidx,start,(start+ (nsize - 1)),oc.order_id,request->qual[lidx].order_id)
    AND oc.comment_type_cd=order_comment_cd)
   JOIN (lt
   WHERE oc.long_text_id=lt.long_text_id)
  ORDER BY oc.order_id, oc.action_sequence DESC
  HEAD oc.order_id
   jidx = locateval(oit,1,order_cnt,oc.order_id,reply->qual[oit].order_id), reply->qual[jidx].
   order_comment_text = lt.long_text
  FOOT REPORT
   stat = alterlist(reply->qual,order_cnt)
  WITH nocounter
 ;end select
 IF ((request->debug_ind=1))
  CALL echo("**********************Calling bsc_get_active_IV_orders************************")
 ENDIF
 SET modify = nopredeclare
 EXECUTE bsc_get_active_iv_orders  WITH replace("REQUEST","IVSEQUENCE_ORDERS_LIST"), replace("REPLY",
  "ACTIVE_ORDERS_REPLY")
 SET modify = predeclare
 IF ((request->debug_ind=1))
  CALL echo(build("bsc_get_active_iv_orders reply status",active_orders_reply->status_data.status))
 ENDIF
 IF ((active_orders_reply->status_data.status="S"))
  SET seqordercnt = size(active_orders_reply->order_list,5)
  SET replyordercnt = size(reply->qual,5)
  FOR (iordercnt = 1 TO seqordercnt)
   SET ipos = locateval(inum,1,replyordercnt,active_orders_reply->order_list[iordercnt].
    current_order_id,reply->qual[inum].order_id)
   IF (ipos > 0)
    IF ((request->debug_ind=1))
     CALL echo(build("iPos",ipos))
    ENDIF
    SET reply->qual[ipos].active_sequence_order = active_orders_reply->order_list[iordercnt].
    active_order_id
    SET reply->qual[ipos].sequence_ind = active_orders_reply->order_list[iordercnt].sequence_ind
   ENDIF
  ENDFOR
  IF ((request->debug_ind=1))
   CALL echorecord(active_orders_reply)
  ENDIF
 ENDIF
 CALL getprotocolanddotorders(0)
 CALL findcorrupteddotorders(0)
 CALL populatereplyfordotorder(0)
 CALL getckivalueforgivencatalogcds(0)
 CALL populateckivaluestoingredient(0)
 SUBROUTINE getprotocolanddotorders(null)
   IF ((request->debug_ind=1))
    CALL echo("Entering - GetProtocolAndDotOrders")
   ENDIF
   DECLARE procnt = i4 WITH protect, noconstant(0)
   DECLARE proidx = i4 WITH protect, noconstant(0)
   DECLARE propos = i4 WITH protect, noconstant(0)
   DECLARE pordid = f8 WITH protect, noconstant(0)
   DECLARE dotcnt = i4 WITH protect, noconstant(0)
   DECLARE dotidx = i4 WITH protect, noconstant(0)
   DECLARE dotpos = i4 WITH protect, noconstant(0)
   DECLARE proatdotpos = i4 WITH protect, noconstant(0)
   DECLARE dotid = f8 WITH protect, noconstant(0)
   DECLARE sizetempquallist = i4 WITH protect, noconstant(size(temp->qual,5))
   IF (sizetempquallist > 0)
    SELECT INTO "nl:"
     tmpprotocolid = temp->qual[dt.seq].protocol_order_id, tmporderid = temp->qual[dt.seq].order_id,
     tmplateorderid = temp->qual[dt.seq].template_order_id,
     tmporderflag = temp->qual[dt.seq].template_order_flag
     FROM (dummyt dt  WITH seq = size(temp->qual,5))
     WHERE (temp->qual[dt.seq].protocol_order_id > 0)
     HEAD tmpprotocolid
      propos = locateval(proidx,1,size(protocolanddotordersmaw->dot_ord_list,5),tmpprotocolid,
       protocolanddotordersmaw->dot_ord_list[proidx].protocol_ord_id)
      IF (propos=0)
       procnt += 1, stat = alterlist(protocolanddotordersmaw->dot_ord_list,procnt),
       protocolanddotordersmaw->dot_ord_list[procnt].protocol_ord_id = tmpprotocolid
      ENDIF
     HEAD tmporderid
      proatdotpos = locateval(dotidx,1,size(protocolanddotordersmaw->dot_ord_list,5),tmpprotocolid,
       protocolanddotordersmaw->dot_ord_list[dotidx].protocol_ord_id)
      IF (proatdotpos > 0)
       IF (tmplateorderid=tmporderid
        AND ((tmporderflag=0) OR (tmporderflag=1)) )
        dotid = tmporderid
       ELSE
        dotid = tmplateorderid
       ENDIF
       dotpos = locateval(dotidx,1,size(protocolanddotordersmaw->dot_ord_list[proatdotpos].dots,5),
        dotid,protocolanddotordersmaw->dot_ord_list[proatdotpos].dots[dotidx].dot_ord_id)
       IF (dotpos=0)
        dotcnt = (size(protocolanddotordersmaw->dot_ord_list[proatdotpos].dots,5)+ 1), stat =
        alterlist(protocolanddotordersmaw->dot_ord_list[proatdotpos].dots,dotcnt),
        protocolanddotordersmaw->dot_ord_list[proatdotpos].dots[dotcnt].dot_ord_id = dotid
       ENDIF
      ENDIF
     FOOT  tmpprotocolid
      IF (proatdotpos > 0)
       protocolanddotordersmaw->dot_ord_list[proatdotpos].total_dot_cnt = size(
        protocolanddotordersmaw->dot_ord_list[proatdotpos].dots,5)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("Leaving - GetProtocolAndDotOrders")
   ENDIF
 END ;Subroutine
 SUBROUTINE findcorrupteddotorders(null)
   IF ((request->debug_ind=1))
    CALL echo("Entering - FindCorruptedDotOrders")
   ENDIF
   DECLARE dotidx = i4 WITH protect, noconstant(0)
   DECLARE dotpos = i4 WITH protect, noconstant(0)
   DECLARE proidx = i4 WITH protect, noconstant(0)
   DECLARE propos = i4 WITH protect, noconstant(0)
   DECLARE pordid = f8 WITH protect, noconstant(0)
   DECLARE tmpidx = i4 WITH protect, noconstant(0)
   DECLARE tmppos = i4 WITH protect, noconstant(0)
   DECLARE tmpproordid = f8 WITH protect, noconstant(0)
   DECLARE sizetempquallist = i4 WITH protect, noconstant(size(temp->qual,5))
   DECLARE sizeprodotordlist = i4 WITH protect, noconstant(size(protocolanddotordersmaw->dot_ord_list,
     5))
   IF (sizetempquallist > 0
    AND sizeprodotordlist > 0)
    SELECT INTO "nl:"
     FROM act_pw_comp apc,
      pathway pw
     PLAN (apc
      WHERE expand(dotidx,1,sizetempquallist,apc.parent_entity_id,temp->qual[dotidx].
       template_order_id)
       AND apc.parent_entity_name="ORDERS")
      JOIN (pw
      WHERE pw.pathway_id=apc.pathway_id)
     HEAD apc.parent_entity_id
      tmppos = locateval(tmpidx,1,sizetempquallist,apc.parent_entity_id,temp->qual[tmpidx].
       template_order_id)
      IF (tmppos > 0)
       tmpproordid = temp->qual[tmppos].protocol_order_id
       IF (tmpproordid > 0)
        propos = locateval(proidx,1,sizeprodotordlist,tmpproordid,protocolanddotordersmaw->
         dot_ord_list[proidx].protocol_ord_id)
        IF (propos > 0)
         dotpos = locateval(dotidx,1,size(protocolanddotordersmaw->dot_ord_list[propos].dots,5),apc
          .parent_entity_id,protocolanddotordersmaw->dot_ord_list[propos].dots[dotidx].dot_ord_id)
         IF (dotpos > 0)
          protocolanddotordersmaw->dot_ord_list[propos].dots[dotidx].uncorrupted_dots = 1
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter, expand = 2
    ;end select
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("Leaving - FindCorruptedDotOrders")
   ENDIF
   CALL updateuncorrupteddotorderscount(0)
 END ;Subroutine
 SUBROUTINE updateuncorrupteddotorderscount(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering - UpdateUnCorruptedDotOrdersCount********")
   ENDIF
   DECLARE uncorrputdotordcnt = i4 WITH protect, noconstant(0)
   DECLARE dotcnt = i4 WITH protect, noconstant(0)
   DECLARE dotordid = f8 WITH protect, noconstant(0)
   FOR (x = 1 TO size(protocolanddotordersmaw->dot_ord_list,5))
     SET dotcnt = 0
     FOR (y = 1 TO size(protocolanddotordersmaw->dot_ord_list[x].dots,5))
       SET dotordid = protocolanddotordersmaw->dot_ord_list[x].dots[y].dot_ord_id
       SET uncorrputdotordcnt = protocolanddotordersmaw->dot_ord_list[x].dots[y].uncorrupted_dots
       IF (uncorrputdotordcnt=1)
        SET dotcnt += 1
       ENDIF
     ENDFOR
     SET protocolanddotordersmaw->dot_ord_list[x].uncorrupted_dot_cnt = dotcnt
   ENDFOR
   IF ((request->debug_ind=1))
    CALL echo("********Leaving - UpdateUnCorruptedDotOrdersCount********")
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereplyfordotorder(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering - PopulateReplyForDotOrder********")
   ENDIF
   DECLARE replyproordid = f8 WITH protect, noconstant(0)
   DECLARE replypropos = i4 WITH protect, noconstant(0)
   DECLARE replyproidx = i4 WITH protect, noconstant(0)
   DECLARE replyfreqtmpordid = f8 WITH protect, noconstant(0)
   DECLARE replyfreqpos = i4 WITH protect, noconstant(0)
   DECLARE replyfreqidx = i4 WITH protect, noconstant(0)
   DECLARE dotordid = f8 WITH protect, noconstant(0)
   DECLARE dotpos = i4 WITH protect, noconstant(0)
   DECLARE dotidx = i4 WITH protect, noconstant(0)
   DECLARE sizereplydot = i4 WITH protect, noconstant(0)
   DECLARE sizereplypro = i4 WITH protect, noconstant(0)
   DECLARE sizeproordlist = i4 WITH protect, noconstant(size(protocolanddotordersmaw->dot_ord_list,5)
    )
   IF (sizeproordlist > 0)
    FOR (x = 1 TO size(protocolanddotordersmaw->dot_ord_list,5))
      SET replyproordid = protocolanddotordersmaw->dot_ord_list[x].protocol_ord_id
      SET sizereplypro = size(reply->qual,5)
      FOR (y = 1 TO size(protocolanddotordersmaw->dot_ord_list[x].dots,5))
        SET dotordid = protocolanddotordersmaw->dot_ord_list[x].dots[y].dot_ord_id
        SET replypropos = locateval(replyproidx,1,sizereplypro,dotordid,reply->qual[replyproidx].
         order_id)
        IF (replypropos > 0
         AND (reply->qual[replypropos].template_order_id=0))
         IF ((protocolanddotordersmaw->dot_ord_list[x].total_dot_cnt=protocolanddotordersmaw->
         dot_ord_list[x].uncorrupted_dot_cnt))
          SET reply->qual[replypropos].corrupted_dot_found = 0
         ELSE
          IF ((protocolanddotordersmaw->dot_ord_list[x].dots[y].uncorrupted_dots=1))
           SET reply->qual[replypropos].corrupted_dot_found = 1
          ELSE
           SET reply->qual[replypropos].corrupted_dot_found = 2
          ENDIF
         ENDIF
        ELSE
         SET replyfreqpos = locateval(replyfreqidx,1,sizereplypro,dotordid,reply->qual[replyproidx].
          template_order_id)
         IF (replyfreqpos > 0)
          FOR (j = 1 TO sizereplypro)
           SET replyfreqtmpordid = reply->qual[j].template_order_id
           IF (replyfreqtmpordid > 0
            AND replyfreqtmpordid=dotordid)
            IF ((protocolanddotordersmaw->dot_ord_list[x].total_dot_cnt=protocolanddotordersmaw->
            dot_ord_list[x].uncorrupted_dot_cnt))
             SET reply->qual[j].corrupted_dot_found = 0
            ELSE
             IF ((protocolanddotordersmaw->dot_ord_list[x].dots[y].uncorrupted_dots=1))
              SET reply->qual[j].corrupted_dot_found = 1
             ELSE
              SET reply->qual[j].corrupted_dot_found = 2
             ENDIF
            ENDIF
           ENDIF
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("********Leaving - PopulateReplyForDotOrder********")
   ENDIF
 END ;Subroutine
 SUBROUTINE getckivalueforgivencatalogcds(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering - GetCKIValueForGivenCatalogCds********")
   ENDIF
   DECLARE sizerefcatalogcdlist = i4 WITH protect, noconstant(size(referencecatalogcds->catalog_list,
     5))
   IF (sizerefcatalogcdlist > 0)
    SELECT INTO "nl:"
     FROM order_catalog oc
     WHERE expand(catidx,1,sizerefcatalogcdlist,oc.catalog_cd,referencecatalogcds->catalog_list[
      catidx].catalog_cd)
     HEAD oc.catalog_cd
      catpos = locateval(catidx,1,sizerefcatalogcdlist,oc.catalog_cd,referencecatalogcds->
       catalog_list[catidx].catalog_cd)
      IF (catpos > 0)
       referencecatalogcds->catalog_list[catpos].cki = oc.cki
      ENDIF
     WITH nocounter, expand = 2
    ;end select
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("********Leaving - GetCKIValueForGivenCatalogCds********")
   ENDIF
 END ;Subroutine
 SUBROUTINE populateckivaluestoingredient(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering - PopulateCKIValuesToIngredient********")
   ENDIF
   DECLARE replycatpos = i4 WITH protect, noconstant(0)
   DECLARE replycatidx = i4 WITH protect, noconstant(0)
   DECLARE catlogcd = f8 WITH protect, noconstant(0)
   DECLARE sizerefcatlist = i4 WITH protect, noconstant(size(referencecatalogcds->catalog_list,5))
   IF (sizerefcatlist > 0)
    FOR (x = 1 TO sizerefcatlist)
     SET catlogcd = referencecatalogcds->catalog_list[x].catalog_cd
     FOR (y = 1 TO size(reply->qual,5))
      SET replycatpos = locateval(replycatidx,1,size(reply->qual[y].ingred_qual,5),catlogcd,reply->
       qual[y].ingred_qual[replycatidx].catalog_cd)
      IF (replycatpos > 0)
       SET reply->qual[y].ingred_qual[replycatpos].cki = referencecatalogcds->catalog_list[x].cki
      ENDIF
     ENDFOR
    ENDFOR
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("********Leaving - PopulateCKIValuesToIngredient********")
   ENDIF
 END ;Subroutine
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "031"
 SET mod_date = "05/18/2022"
 SET modify = nopredeclare
END GO
