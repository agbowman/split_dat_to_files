CREATE PROGRAM dcp_get_order_review_actions:dba
 RECORD reply(
   1 order_list[*]
     2 order_id = f8
     2 med_order_type_cd = f8
     2 hna_order_mnemonic = vc
     2 order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 action_list[*]
       3 action_sequence = i4
       3 action_type_cd = f8
       3 action_type_disp = c40
       3 clinical_display_line = vc
       3 order_comment_text = vc
       3 ingredient_list[*]
         4 hna_order_mnemonic = vc
         4 order_mnemonic = vc
         4 ordered_as_mnemonic = vc
         4 ingredient_type_flag = i2
         4 strength = f8
         4 strength_unit = f8
         4 volume = f8
         4 volume_unit = f8
         4 freetext_dose = vc
         4 freq_cd = f8
         4 clinically_significant_flag = i2
         4 normalized_rate = f8
         4 normalized_rate_unit_cd = f8
         4 synonym_id = f8
       3 action_dttm = dq8
       3 action_tz = i4
       3 action_personnel_id = f8
       3 action_personnel_name = vc
       3 review_type_flag = i2
       3 last_action_sequence_ind = i2
       3 source_dot_order_id = f8
       3 source_dot_action_seq = i4
       3 review_group_value = f8
     2 catalog_type_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 protocol_order_id = f8
     2 cs_order_id = f8
     2 pathway_catalog_id = f8
     2 template_order_flag = i2
     2 order_set_plan_name = vc
     2 ordering_provider_name = vc
     2 action_list_cnt = i4
     2 need_phys_ind = i2
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp_req_list
 RECORD temp_req_list(
   1 qual[*]
     2 order_id = f8
 )
 SET stat = alterlist(temp_req_list->qual,size(request->order_list,5))
 FREE RECORD review_groups
 RECORD review_groups(
   1 qual[*]
     2 group_id = f8
 )
 FREE RECORD comments
 RECORD comments(
   1 qual_cnt = i4
   1 qual[*]
     2 long_text_id = f8
     2 order_list_index = i4
     2 action_list_index = i4
 )
 FREE RECORD order_notification
 RECORD order_notification(
   1 order_list[*]
     2 order_id = f8
     2 action_sequence = i4
     2 to_prsnl_id = f8
 )
 SET reply->status_data.status = "F"
 SET comments->qual_cnt = 0
 IF ((request->review_type_flag=- (1))
  AND size(request->review_type_flag_list,5)=0)
  GO TO endofprogram
 ENDIF
 IF (size(request->order_list,5)=0)
  GO TO endofprogram
 ENDIF
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE order_list_cnt = i4 WITH protect, noconstant(size(request->order_list,5))
 DECLARE max_comment_action_seq = i2 WITH noconstant(0)
 DECLARE action_cnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE ordernotificationidx = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE num1 = i4 WITH protect, noconstant(0)
 DECLARE num2 = i4 WITH protect, noconstant(0)
 DECLARE ordernotifnum = i4 WITH protect, noconstant(0)
 DECLARE returnindex = i4 WITH protect, noconstant(0)
 DECLARE returnindex1 = i4 WITH protect, noconstant(0)
 DECLARE reviewgroupsize = i4 WITH protect, noconstant(0)
 DECLARE numreplylist = i4 WITH protect, noconstant(0)
 DECLARE bfoundinreply = i2 WITH protect, noconstant(1)
 DECLARE ordered_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE protocol_order = i2 WITH constant(7)
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE new_list_size = i4 WITH protect, noconstant(0)
 DECLARE unusedparameter = i1 WITH protect, constant(0)
 DECLARE loadcommentind = i2 WITH protect, noconstant(0)
 DECLARE req_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_order_review_group_value = f8 WITH noconstant(- (1))
 IF (order_list_cnt > 0)
  SET req_loop_cnt = ceil((cnvtreal(order_list_cnt)/ batch_size))
  SET new_list_size = (req_loop_cnt * batch_size)
  SET stat = alterlist(temp_req_list->qual,new_list_size)
  FOR (idx = 1 TO order_list_cnt)
    SET temp_req_list->qual[idx].order_id = request->order_list[idx].order_id
  ENDFOR
  FOR (idx = (order_list_cnt+ 1) TO new_list_size)
    SET temp_req_list->qual[idx].order_id = temp_req_list->qual[order_list_cnt].order_id
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_loop_cnt)),
   orders o,
   orders o1
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (o
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),o.order_id,temp_req_list->qual[num].order_id)
    AND ((o.template_order_flag=protocol_order) OR (o.protocol_order_id > 0.0)) )
   JOIN (o1
   WHERE ((o.protocol_order_id=o1.order_id) OR (((o.order_id=o1.protocol_order_id
    AND o1.protocol_order_id > 0.0) OR (o.order_id=o1.order_id)) )) )
  DETAIL
   IF (o1.order_id > 0.0)
    IF (((o1.protocol_order_id > 0.0) OR (o1.template_order_flag=protocol_order)) )
     IF (locateval(num1,1,size(request->order_list,5),o1.order_id,request->order_list[num1].order_id)
     =0)
      order_list_cnt += 1
      IF (order_list_cnt > size(request->order_list,5))
       stat = alterlist(request->order_list,(order_list_cnt+ 10))
      ENDIF
      request->order_list[order_list_cnt].order_id = o1.order_id
     ENDIF
    ENDIF
    IF (o1.template_order_flag=protocol_order)
     IF (locateval(num1,1,size(reply->order_list,5),o1.order_id,reply->order_list[num1].order_id)=0)
      numreplylist += 1
      IF (numreplylist > size(reply->order_list,5))
       stat = alterlist(reply->order_list,(numreplylist+ 10))
      ENDIF
      reply->order_list[numreplylist].order_id = o1.order_id, reply->order_list[numreplylist].
      protocol_order_id = o1.protocol_order_id, reply->order_list[numreplylist].cs_order_id = o1
      .cs_order_id,
      reply->order_list[numreplylist].pathway_catalog_id = o1.pathway_catalog_id, reply->order_list[
      numreplylist].catalog_type_cd = o1.catalog_type_cd, reply->order_list[numreplylist].
      med_order_type_cd = o1.med_order_type_cd,
      reply->order_list[numreplylist].template_order_flag = o1.template_order_flag, reply->
      order_list[numreplylist].hna_order_mnemonic = o1.hna_order_mnemonic, reply->order_list[
      numreplylist].order_mnemonic = o1.order_mnemonic,
      reply->order_list[numreplylist].ordered_as_mnemonic = o1.ordered_as_mnemonic, reply->
      order_list[numreplylist].person_id = o1.person_id, reply->order_list[numreplylist].encntr_id =
      o1.encntr_id,
      reply->order_list[numreplylist].action_list_cnt = 0, reply->order_list[numreplylist].
      need_phys_ind = o.need_physician_validate_ind, reply->order_list[numreplylist].
      need_nurse_review_ind = o.need_nurse_review_ind,
      reply->order_list[numreplylist].need_doctor_cosign_ind = o.need_doctor_cosign_ind
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(request->order_list,order_list_cnt)
 SET stat = alterlist(reply->order_list,numreplylist)
 FREE RECORD temp_req_list
 CALL getordernotifications(unusedparameter)
 IF (order_list_cnt > 0)
  SET req_loop_cnt = ceil((cnvtreal(order_list_cnt)/ batch_size))
  SET new_list_size = (req_loop_cnt * batch_size)
  SET stat = alterlist(request->order_list,new_list_size)
  FOR (idx = (order_list_cnt+ 1) TO new_list_size)
    SET request->order_list[idx].order_id = request->order_list[order_list_cnt].order_id
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_loop_cnt)),
   orders o,
   order_review orev,
   order_action oa,
   order_comment oc,
   prsnl p,
   prsnl p2
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (o
   WHERE expand(num1,nstart,(nstart+ (batch_size - 1)),o.order_id,request->order_list[num1].order_id)
   )
   JOIN (orev
   WHERE orev.order_id=o.order_id
    AND (((request->review_type_flag > 0)
    AND (orev.review_type_flag=request->review_type_flag)) OR ((request->review_type_flag=- (1))
    AND expand(idx1,1,size(request->review_type_flag_list,5),orev.review_type_flag,request->
    review_type_flag_list[idx1].review_type_flag)))
    AND orev.reviewed_status_flag=0)
   JOIN (oa
   WHERE oa.order_id=orev.order_id
    AND oa.action_sequence=orev.action_sequence)
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(oa.order_id))
    AND (oc.action_sequence<= Outerjoin(oa.action_sequence))
    AND (oc.comment_type_cd= Outerjoin(order_comment_cd)) )
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id)
   JOIN (p2
   WHERE p2.person_id=oa.order_provider_id)
  ORDER BY orev.review_type_flag, o.order_id, orev.action_sequence DESC,
   oc.action_sequence DESC
  HEAD o.order_id
   returnindex = locateval(num1,1,size(reply->order_list,5),o.order_id,reply->order_list[num1].
    order_id)
   IF (orev.order_id > 0.0
    AND returnindex=0)
    numreplylist += 1
    IF (numreplylist > size(reply->order_list,5))
     stat = alterlist(reply->order_list,(numreplylist+ 10))
    ENDIF
    reply->order_list[numreplylist].order_id = o.order_id, reply->order_list[numreplylist].
    protocol_order_id = o.protocol_order_id, reply->order_list[numreplylist].cs_order_id = o
    .cs_order_id,
    reply->order_list[numreplylist].pathway_catalog_id = o.pathway_catalog_id, reply->order_list[
    numreplylist].catalog_type_cd = o.catalog_type_cd, reply->order_list[numreplylist].
    med_order_type_cd = o.med_order_type_cd,
    reply->order_list[numreplylist].template_order_flag = o.template_order_flag, reply->order_list[
    numreplylist].hna_order_mnemonic = o.hna_order_mnemonic, reply->order_list[numreplylist].
    order_mnemonic = o.order_mnemonic,
    reply->order_list[numreplylist].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->order_list[
    numreplylist].person_id = o.person_id, reply->order_list[numreplylist].encntr_id = o.encntr_id,
    reply->order_list[numreplylist].need_phys_ind = o.need_physician_validate_ind, reply->order_list[
    numreplylist].need_nurse_review_ind = o.need_nurse_review_ind, reply->order_list[numreplylist].
    need_doctor_cosign_ind = o.need_doctor_cosign_ind
    IF (p2.person_id > 0.0)
     reply->order_list[numreplylist].ordering_provider_name = trim(p2.name_full_formatted)
    ENDIF
    reply->order_list[numreplylist].action_list_cnt = 0, returnindex = numreplylist
   ELSEIF (returnindex > 0
    AND o.template_order_flag=protocol_order
    AND p2.person_id > 0.0)
    reply->order_list[returnindex].ordering_provider_name = trim(p2.name_full_formatted)
   ENDIF
  HEAD orev.action_sequence
   loadcommentind = 0
   IF (orev.order_id > 0.0)
    ordernotificationidx = locateval(ordernotifnum,1,size(order_notification->order_list,5),orev
     .order_id,order_notification->order_list[ordernotifnum].order_id,
     orev.action_sequence,order_notification->order_list[ordernotifnum].action_sequence)
    IF ((((request->order_provider_id <= 0)) OR ((((reply->order_list[returnindex].
    template_order_flag=protocol_order)) OR ((((reply->order_list[returnindex].protocol_order_id >
    0.0)) OR (((ordernotificationidx > 0
     AND (request->order_provider_id=order_notification->order_list[ordernotificationidx].to_prsnl_id
    )) OR ((((request->order_provider_id=orev.provider_id)) OR (((orev.provider_id=0
     AND (request->order_provider_id=oa.supervising_provider_id)) OR (orev.provider_id=0
     AND oa.supervising_provider_id=0
     AND ((oa.order_provider_id=0) OR ((oa.order_provider_id=request->order_provider_id))) )) )) ))
    )) )) )) )
     loadcommentind = 1, max_comment_action_seq = 0, action_cnt = (reply->order_list[returnindex].
     action_list_cnt+ 1)
     IF (action_cnt > size(reply->order_list[returnindex].action_list,5))
      stat = alterlist(reply->order_list[returnindex].action_list,(action_cnt+ 2))
     ENDIF
     reply->order_list[returnindex].action_list_cnt = action_cnt, reply->order_list[returnindex].
     action_list[action_cnt].action_sequence = orev.action_sequence, reply->order_list[returnindex].
     action_list[action_cnt].action_type_cd = oa.action_type_cd,
     reply->order_list[returnindex].action_list[action_cnt].clinical_display_line = oa
     .clinical_display_line, reply->order_list[returnindex].action_list[action_cnt].action_dttm = oa
     .action_dt_tm, reply->order_list[returnindex].action_list[action_cnt].action_tz = oa.action_tz,
     reply->order_list[returnindex].action_list[action_cnt].action_personnel_id = oa
     .action_personnel_id, reply->order_list[returnindex].action_list[action_cnt].
     action_personnel_name = trim(p.name_full_formatted), reply->order_list[returnindex].action_list[
     action_cnt].review_type_flag = orev.review_type_flag
     IF (orev.action_sequence=o.last_action_sequence)
      reply->order_list[returnindex].action_list[action_cnt].last_action_sequence_ind = 1
     ELSE
      reply->order_list[returnindex].action_list[action_cnt].last_action_sequence_ind = 0
     ENDIF
     temp_order_review_group_value = validate(orev.review_grp_value,- (1))
     IF ((temp_order_review_group_value > - (1)))
      reply->order_list[returnindex].action_list[action_cnt].review_group_value =
      temp_order_review_group_value
      IF (o.protocol_order_id > 0.0
       AND temp_order_review_group_value=0.0)
       returnindex1 = locateval(num1,1,size(reply->order_list,5),o.protocol_order_id,reply->
        order_list[num1].order_id)
       IF (returnindex1 > 0)
        newactioncnt = (reply->order_list[returnindex1].action_list_cnt+ 1)
        IF (newactioncnt > size(reply->order_list[returnindex1].action_list,5))
         stat = alterlist(reply->order_list[returnindex1].action_list,(newactioncnt+ 2))
        ENDIF
        reply->order_list[returnindex1].action_list[newactioncnt].review_type_flag = orev
        .review_type_flag, reply->order_list[returnindex1].action_list[newactioncnt].
        source_dot_action_seq = oa.action_sequence, reply->order_list[returnindex1].action_list[
        newactioncnt].source_dot_order_id = o.order_id,
        reply->order_list[returnindex1].action_list_cnt = newactioncnt, stat = alterlist(reply->
         order_list[returnindex1].action_list,newactioncnt)
       ENDIF
      ELSEIF (temp_order_review_group_value > 0.0)
       IF (locateval(num1,1,size(review_groups->qual,5),temp_order_review_group_value,review_groups->
        qual[num1].group_id)=0)
        reviewgroupsize += 1
        IF (reviewgroupsize > size(review_groups->qual,5))
         stat = alterlist(review_groups->qual,(reviewgroupsize+ 10))
        ENDIF
        review_groups->qual[reviewgroupsize].group_id = temp_order_review_group_value
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (o.order_id > 0.0
    AND loadcommentind=1)
    IF (oc.long_text_id > 0.0
     AND oc.action_sequence > max_comment_action_seq)
     comments->qual_cnt += 1
     IF ((comments->qual_cnt > size(comments->qual,5)))
      stat = alterlist(comments->qual,(comments->qual_cnt+ 10))
     ENDIF
     max_comment_action_seq = oc.action_sequence, comments->qual[comments->qual_cnt].long_text_id =
     oc.long_text_id, comments->qual[comments->qual_cnt].order_list_index = returnindex,
     comments->qual[comments->qual_cnt].action_list_index = action_cnt
    ENDIF
   ENDIF
  FOOT  o.order_id
   IF (o.order_id > 0.0)
    stat = alterlist(reply->order_list[returnindex].action_list,reply->order_list[returnindex].
     action_list_cnt), stat = alterlist(reply->order_list,numreplylist), stat = alterlist(
     review_groups->qual,reviewgroupsize)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET stat = alterlist(request->order_list,order_list_cnt)
 SET action_cnt = 0
 DECLARE rg_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE orig_rg_list_size = i4 WITH protect, constant(size(review_groups->qual,5))
 IF (orig_rg_list_size > 0)
  SET rg_loop_cnt = ceil((cnvtreal(orig_rg_list_size)/ batch_size))
  SET new_list_size = (rg_loop_cnt * batch_size)
  SET stat = alterlist(review_groups->qual,new_list_size)
  FOR (idx = (orig_rg_list_size+ 1) TO new_list_size)
    SET review_groups->qual[idx].group_id = review_groups->qual[orig_rg_list_size].group_id
  ENDFOR
 ENDIF
 IF (size(review_groups->qual,5) > 0
  AND (validate(orev.review_grp_value,- (1)) > - (1)))
  SET num = 1
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rg_loop_cnt)),
    order_review orev,
    orders o,
    order_action oa,
    order_comment oc,
    prsnl p,
    prsnl p2
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (orev
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),orev.review_grp_value,review_groups->qual[num]
     .group_id)
     AND orev.reviewed_status_flag=0)
    JOIN (o
    WHERE o.order_id=orev.order_id)
    JOIN (oa
    WHERE oa.order_id=orev.order_id
     AND oa.action_sequence=orev.action_sequence)
    JOIN (oc
    WHERE (oc.order_id= Outerjoin(oa.order_id))
     AND (oc.action_sequence<= Outerjoin(oa.action_sequence))
     AND (oc.comment_type_cd= Outerjoin(order_comment_cd)) )
    JOIN (p
    WHERE p.person_id=oa.action_personnel_id)
    JOIN (p2
    WHERE p2.person_id=oa.order_provider_id)
   ORDER BY orev.review_type_flag, o.order_id, orev.action_sequence DESC,
    oc.action_sequence DESC
   HEAD o.order_id
    bfoundinreply = 1, returnindex = locateval(num2,1,size(reply->order_list,5),o.order_id,reply->
     order_list[num2].order_id)
    IF (o.order_id > 0.0
     AND returnindex=0)
     bfoundinreply = 0, numreplylist += 1
     IF (numreplylist > size(reply->order_list,5))
      stat = alterlist(reply->order_list,(numreplylist+ 10))
     ENDIF
     reply->order_list[numreplylist].action_list_cnt = 0, returnindex = numreplylist, reply->
     order_list[returnindex].order_id = o.order_id,
     reply->order_list[returnindex].protocol_order_id = o.protocol_order_id, reply->order_list[
     returnindex].cs_order_id = o.cs_order_id, reply->order_list[returnindex].pathway_catalog_id = o
     .pathway_catalog_id,
     reply->order_list[returnindex].catalog_type_cd = o.catalog_type_cd, reply->order_list[
     returnindex].med_order_type_cd = o.med_order_type_cd, reply->order_list[returnindex].
     template_order_flag = o.template_order_flag,
     reply->order_list[returnindex].hna_order_mnemonic = o.hna_order_mnemonic, reply->order_list[
     returnindex].order_mnemonic = o.order_mnemonic, reply->order_list[returnindex].
     ordered_as_mnemonic = o.ordered_as_mnemonic,
     reply->order_list[returnindex].person_id = o.person_id, reply->order_list[returnindex].encntr_id
      = o.encntr_id, reply->order_list[returnindex].need_phys_ind = o.need_physician_validate_ind,
     reply->order_list[returnindex].need_nurse_review_ind = o.need_nurse_review_ind, reply->
     order_list[returnindex].need_doctor_cosign_ind = o.need_doctor_cosign_ind
     IF (p2.person_id > 0.0)
      reply->order_list[returnindex].ordering_provider_name = trim(p2.name_full_formatted)
     ENDIF
    ELSEIF (returnindex > 0
     AND o.template_order_flag=protocol_order
     AND p2.person_id > 0.0)
     reply->order_list[returnindex].ordering_provider_name = trim(p2.name_full_formatted)
    ENDIF
   HEAD orev.action_sequence
    returnindex1 = locateval(num2,1,size(reply->order_list[returnindex].action_list,5),orev
     .action_sequence,reply->order_list[returnindex].action_list[num2].action_sequence)
    IF (returnindex1=0)
     max_comment_action_seq = 0, action_cnt = (reply->order_list[returnindex].action_list_cnt+ 1)
     IF (action_cnt > size(reply->order_list[returnindex].action_list,5))
      stat = alterlist(reply->order_list[returnindex].action_list,(action_cnt+ 2))
     ENDIF
     reply->order_list[returnindex].action_list_cnt = action_cnt, reply->order_list[returnindex].
     action_list[action_cnt].action_sequence = orev.action_sequence, reply->order_list[returnindex].
     action_list[action_cnt].action_type_cd = oa.action_type_cd,
     reply->order_list[returnindex].action_list[action_cnt].clinical_display_line = oa
     .clinical_display_line, reply->order_list[returnindex].action_list[action_cnt].action_dttm = oa
     .action_dt_tm, reply->order_list[returnindex].action_list[action_cnt].action_tz = oa.action_tz,
     reply->order_list[returnindex].action_list[action_cnt].action_personnel_id = oa
     .action_personnel_id, reply->order_list[returnindex].action_list[action_cnt].
     action_personnel_name = trim(p.name_full_formatted), reply->order_list[returnindex].action_list[
     action_cnt].review_type_flag = orev.review_type_flag,
     reply->order_list[returnindex].action_list[action_cnt].review_group_value = validate(orev
      .review_grp_value,- (1))
     IF (orev.action_sequence=o.last_action_sequence)
      reply->order_list[returnindex].action_list[action_cnt].last_action_sequence_ind = 1
     ELSE
      reply->order_list[returnindex].action_list[action_cnt].last_action_sequence_ind = 0
     ENDIF
    ENDIF
   DETAIL
    IF (returnindex1=0)
     IF (oc.long_text_id > 0.0
      AND oc.action_sequence > max_comment_action_seq)
      comments->qual_cnt += 1
      IF ((comments->qual_cnt > size(comments->qual,5)))
       stat = alterlist(comments->qual,(comments->qual_cnt+ 10))
      ENDIF
      max_comment_action_seq = oc.action_sequence, comments->qual[comments->qual_cnt].long_text_id =
      oc.long_text_id, comments->qual[comments->qual_cnt].order_list_index = returnindex,
      comments->qual[comments->qual_cnt].action_list_index = action_cnt
     ENDIF
    ENDIF
   FOOT  o.order_id
    IF (returnindex1=0)
     stat = alterlist(reply->order_list[returnindex].action_list,reply->order_list[returnindex].
      action_list_cnt), stat = alterlist(reply->order_list,numreplylist)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 FREE RECORD review_groups
 IF (size(reply->order_list,5) > 0)
  FOR (i = size(reply->order_list,5) TO 1)
    IF ((reply->order_list[i].template_order_flag=protocol_order)
     AND size(reply->order_list[i].action_list,5)=0)
     SET stat = alterlist(reply->order_list,(size(reply->order_list,5) - 1),(i - 1))
    ENDIF
  ENDFOR
 ENDIF
 FREE RECORD plan_order_id_list
 RECORD plan_order_id_list(
   1 qual[*]
     2 order_id = f8
 )
 FREE RECORD careset_order_id_list
 RECORD careset_order_id_list(
   1 qual[*]
     2 order_id = f8
 )
 DECLARE orig_reply_list_size = i4 WITH protect, constant(size(reply->order_list,5))
 DECLARE plan_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE careset_list_cnt = i4 WITH protect, noconstant(0)
 IF (orig_reply_list_size > 0)
  FOR (i = 1 TO orig_reply_list_size)
    IF ((reply->order_list[i].pathway_catalog_id > 0.0))
     SET plan_list_cnt += 1
     IF (plan_list_cnt > size(plan_order_id_list->qual,5))
      SET stat = alterlist(plan_order_id_list->qual,(plan_list_cnt+ 10))
     ENDIF
     SET plan_order_id_list->qual[plan_list_cnt].order_id = reply->order_list[i].order_id
    ELSEIF ((reply->order_list[i].cs_order_id > 0.0))
     SET careset_list_cnt += 1
     IF (careset_list_cnt > size(careset_order_id_list->qual,5))
      SET stat = alterlist(careset_order_id_list->qual,(careset_list_cnt+ 10))
     ENDIF
     SET careset_order_id_list->qual[careset_list_cnt].order_id = reply->order_list[i].cs_order_id
    ENDIF
  ENDFOR
  SET stat = alterlist(plan_order_id_list->qual,plan_list_cnt)
  SET stat = alterlist(careset_order_id_list->qual,careset_list_cnt)
 ENDIF
 DECLARE pn_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE cn_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE npos = i4 WITH protect, noconstant(0)
 IF (plan_list_cnt > 0)
  SET pn_loop_cnt = ceil((cnvtreal(plan_list_cnt)/ batch_size))
  SET new_list_size = (pn_loop_cnt * batch_size)
  SET stat = alterlist(plan_order_id_list->qual,new_list_size)
  FOR (idx = (plan_list_cnt+ 1) TO new_list_size)
    SET plan_order_id_list->qual[idx].order_id = plan_order_id_list->qual[plan_list_cnt].order_id
  ENDFOR
  CALL getplannames(unusedparameter)
  FREE RECORD plan_order_id_list
 ENDIF
 IF (careset_list_cnt > 0)
  SET cn_loop_cnt = ceil((cnvtreal(careset_list_cnt)/ batch_size))
  SET new_list_size = (cn_loop_cnt * batch_size)
  SET stat = alterlist(careset_order_id_list->qual,new_list_size)
  FOR (idx = (careset_list_cnt+ 1) TO new_list_size)
    SET careset_order_id_list->qual[idx].order_id = careset_order_id_list->qual[careset_list_cnt].
    order_id
  ENDFOR
  CALL getcaresetnames(unusedparameter)
  FREE RECORD careset_order_id_list
 ENDIF
 SUBROUTINE (getplannames(unusedparameter=i1) =null)
   SET num = 1
   SET nstart = 1
   SET idx = 1
   DECLARE careplanname = vc
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(pn_loop_cnt)),
     act_pw_comp apc,
     pathway pw
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (apc
     WHERE expand(num,nstart,(nstart+ (batch_size - 1)),apc.parent_entity_id,plan_order_id_list->
      qual[num].order_id)
      AND apc.parent_entity_name="ORDERS")
     JOIN (pw
     WHERE pw.pathway_id=apc.pathway_id
      AND pw.type_mean != "TAPERPLAN")
    ORDER BY pw.pathway_id
    HEAD REPORT
     npos = 0
    HEAD pw.pathway_id
     careplanname = fillstring(305," ")
     IF (pw.type_mean="SUBPHASE")
      careplanname = build2(trim(pw.pw_group_desc),", ",trim(pw.parent_phase_desc),", ",trim(pw
        .description))
     ELSEIF (((pw.type_mean="PHASE") OR (pw.type_mean="DOT")) )
      careplanname = build2(trim(pw.pw_group_desc),", ",trim(pw.description))
     ELSEIF (pw.type_mean="CAREPLAN")
      careplanname = trim(pw.description)
     ELSE
      careplanname = trim(pw.description)
     ENDIF
    HEAD apc.parent_entity_id
     npos = locateval(idx,1,size(reply->order_list,5),apc.parent_entity_id,reply->order_list[idx].
      order_id)
     IF (npos != 0)
      reply->order_list[npos].order_set_plan_name = trim(careplanname)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (getcaresetnames(unusedparameter=i1) =null)
   SET num = 1
   SET nstart = 1
   SET idx = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cn_loop_cnt)),
     orders o
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (o
     WHERE expand(num,nstart,(nstart+ (batch_size - 1)),o.order_id,careset_order_id_list->qual[num].
      order_id))
    HEAD REPORT
     npos = 0
    DETAIL
     npos = locateval(idx,1,size(reply->order_list,5),o.order_id,reply->order_list[idx].cs_order_id)
     IF (npos != 0)
      reply->order_list[npos].order_set_plan_name = trim(o.ordered_as_mnemonic)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 IF (size(reply->order_list,5) > 0)
  FOR (i = 1 TO size(reply->order_list,5))
    IF ((reply->order_list[i].med_order_type_cd > 0.0))
     CALL getingredients(i)
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (getingredients(idx=i4) =null)
   IF (size(reply->order_list[idx].action_list,5) > 0)
    DECLARE ingred_cnt = i4 WITH noconstant(0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(reply->order_list[idx].action_list,5))),
      order_ingredient oi
     PLAN (d)
      JOIN (oi
      WHERE (oi.order_id=reply->order_list[idx].order_id)
       AND (oi.action_sequence=
      (SELECT
       max(oi2.action_sequence)
       FROM order_ingredient oi2
       WHERE oi2.order_id=oi.order_id
        AND (oi2.action_sequence <= reply->order_list[idx].action_list[d.seq].action_sequence))))
     ORDER BY d.seq
     HEAD d.seq
      ingred_cnt = 0
     DETAIL
      ingred_cnt += 1
      IF (mod(ingred_cnt,3)=1)
       stat = alterlist(reply->order_list[idx].action_list[d.seq].ingredient_list,(ingred_cnt+ 2))
      ENDIF
      reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].hna_order_mnemonic = oi
      .hna_order_mnemonic, reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].
      ordered_as_mnemonic = oi.ordered_as_mnemonic, reply->order_list[idx].action_list[d.seq].
      ingredient_list[ingred_cnt].order_mnemonic = oi.order_mnemonic,
      reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].ingredient_type_flag = oi
      .ingredient_type_flag, reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].
      strength = oi.strength, reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].
      strength_unit = oi.strength_unit,
      reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].volume = oi.volume, reply
      ->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].volume_unit = oi.volume_unit,
      reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].freetext_dose = oi
      .freetext_dose,
      reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].freq_cd = oi.freq_cd,
      reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].
      clinically_significant_flag = oi.clinically_significant_flag, reply->order_list[idx].
      action_list[d.seq].ingredient_list[ingred_cnt].normalized_rate = oi.normalized_rate,
      reply->order_list[idx].action_list[d.seq].ingredient_list[ingred_cnt].normalized_rate_unit_cd
       = oi.normalized_rate_unit_cd, reply->order_list[idx].action_list[d.seq].ingredient_list[
      ingred_cnt].synonym_id = oi.synonym_id
     FOOT  d.seq
      stat = alterlist(reply->order_list[idx].action_list[d.seq].ingredient_list,ingred_cnt)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (getordernotifications(unusedparameter=i1) =null)
   DECLARE bcosign = i2 WITH protect, noconstant(0)
   IF ((request->order_provider_id > 0))
    DECLARE review_type_total = i4 WITH protect, constant(size(request->review_type_flag_list,5))
    DECLARE cosign_review_type = i4 WITH protect, constant(2)
    DECLARE activate_review_type = i4 WITH protect, constant(4)
    IF ((request->review_type_flag IN (cosign_review_type, activate_review_type)))
     SET bcosign = 1
    ELSE
     DECLARE cosignindex = i4 WITH protect, noconstant(0)
     DECLARE activateindex = i4 WITH protect, noconstant(0)
     IF (locateval(cosignindex,1,review_type_total,cosign_review_type,request->review_type_flag_list[
      cosignindex].review_type_flag) != 0)
      SET bcosign = 1
     ENDIF
     IF (bcosign=0
      AND locateval(activateindex,1,review_type_total,activate_review_type,request->
      review_type_flag_list[activateindex].review_type_flag) != 0)
      SET bcosign = 1
     ENDIF
    ENDIF
   ENDIF
   IF (bcosign)
    DECLARE order_total = i4 WITH protect, constant(size(request->order_list,5))
    DECLARE cosign_notification_type = i4 WITH protect, constant(2)
    DECLARE med_student_notification_type = i4 WITH protect, constant(3)
    DECLARE pending_notification_status = i4 WITH protect, constant(1)
    DECLARE ordernotificationindex = i4 WITH protect, noconstant(0)
    DECLARE ordernotificationcnt = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM order_notification onot
     PLAN (onot
      WHERE expand(ordernotificationindex,1,order_total,onot.order_id,request->order_list[
       ordernotificationindex].order_id)
       AND onot.notification_type_flag IN (cosign_notification_type, med_student_notification_type)
       AND onot.notification_status_flag=pending_notification_status
       AND (onot.to_prsnl_id=request->order_provider_id))
     ORDER BY onot.order_id, onot.action_sequence DESC
     DETAIL
      ordernotificationcnt += 1
      IF (ordernotificationcnt > size(order_notification->order_list,5))
       stat = alterlist(order_notification->order_list,(ordernotificationcnt+ 10))
      ENDIF
      order_notification->order_list[ordernotificationcnt].order_id = onot.order_id,
      order_notification->order_list[ordernotificationcnt].action_sequence = onot.action_sequence,
      order_notification->order_list[ordernotificationcnt].to_prsnl_id = onot.to_prsnl_id
     WITH nocounter, expand = 1
    ;end select
    SET stat = alterlist(order_notification->order_list,ordernotificationcnt)
   ENDIF
 END ;Subroutine
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE stop = i4 WITH protect, noconstant(0)
 DECLARE comments_cnt = i4 WITH protect, noconstant(0)
 DECLARE iterations = i4 WITH protect, noconstant(0)
 DECLARE new_array_size = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE olistindex = i4 WITH protect, noconstant(0)
 DECLARE alistindex = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, constant(20)
 IF ((comments->qual_cnt > 0))
  SET comments_cnt = comments->qual_cnt
  SET iterations = (((comments_cnt+ nsize) - 1)/ nsize)
  SET new_array_size = (iterations * nsize)
  SET stat = alterlist(comments->qual,new_array_size)
  FOR (num = (comments_cnt+ 1) TO new_array_size)
    SET comments->qual[num].long_text_id = comments->qual[comments_cnt].long_text_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d2  WITH seq = value(iterations)),
    long_text lt
   PLAN (d2
    WHERE initarray(start,evaluate(d2.seq,1,1,(start+ nsize))))
    JOIN (lt
    WHERE expand(num,start,(start+ (nsize - 1)),lt.long_text_id,comments->qual[num].long_text_id))
   HEAD REPORT
    num = 0
   DETAIL
    pos = locateval(num,1,comments_cnt,lt.long_text_id,comments->qual[num].long_text_id)
    WHILE (pos != 0)
      olistindex = comments->qual[pos].order_list_index, alistindex = comments->qual[pos].
      action_list_index, reply->order_list[olistindex].action_list[alistindex].order_comment_text =
      lt.long_text,
      pos = locateval(num,(pos+ 1),comments_cnt,lt.long_text_id,comments->qual[num].long_text_id)
    ENDWHILE
   WITH nocounter
  ;end select
  FREE RECORD comments
 ENDIF
 FREE RECORD order_notification
 IF (order_list_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#endofprogram
 SET script_version = "017 11/06/2019 AN020661"
END GO
