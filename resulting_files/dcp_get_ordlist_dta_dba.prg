CREATE PROGRAM dcp_get_ordlist_dta:dba
 RECORD reply(
   1 catalog_cnt = i2
   1 catalog[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_desc = c60
     2 catalog_type_mean = vc
     2 activity_type_cd = f8
     2 cont_order_method_flag = i2
     2 primary_mnemonic = vc
     2 event_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 task_cnt = i2
     2 tasks[*]
       3 task_seq = i4
       3 task_type_flag = i2
       3 prim_task_ind = i2
       3 ref_task_id = f8
       3 task_description = vc
       3 task_description_key = vc
       3 task_type_cd = f8
       3 task_type_disp = c40
       3 task_type_desc = c60
       3 task_type_mean = vc
       3 assay_cnt = i2
       3 assay[*]
         4 task_assay_cd = f8
         4 sequence = i4
         4 pend_req_ind = i2
         4 mnemonic = vc
         4 mnemonic_key = vc
         4 activity_type_cd = f8
         4 event_cd = f8
         4 desc = vc
   1 order_cnt = i2
   1 orders[*]
     2 order_id = f8
     2 order_mnemonic = vc
     2 encntr_id = f8
     2 person_id = f8
     2 catalog_cd = f8
     2 orig_order_dt_tm = dq8
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_desc = c60
     2 order_status_mean = vc
     2 last_action_sequence = i4
     2 display_line = vc
     2 last_update_provider_id = f8
     2 med_order_type_cd = f8
     2 constant_ind = i2
     2 prn_ind = i2
     2 order_comment_ind = i2
     2 current_start_dt_tm = dq8
     2 projected_stop_dt_tm = dq8
     2 ingredient_ind = i2
     2 template_order_id = f8
     2 template_order_flag = i2
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 need_rx_verify_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD treq(
   1 treq_cnt = i2
   1 torders[1000]
     2 order_id = f8
 )
 RECORD temp(
   1 cc_cnt = i2
   1 cc[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 cont_order_method_flag = i2
     2 primary_mnemonic = vc
     2 ref_text_mask = i4
     2 event_cd = f8
     2 cki = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET cs_flag = 0
 SET cs_order_id = 0
 SET tcnt = 0
 SET radiology_cd = 0.0
 SET lab_cd = 0.0
 SET microbiology_cd = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 6000
 SET cdf_meaning = "RADIOLOGY"
 EXECUTE cpm_get_cd_for_cdf
 SET radiology_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "GENERAL LAB"
 EXECUTE cpm_get_cd_for_cdf
 SET lab_cd = code_value
 SET code_set = 106
 SET cdf_meaning = "MICROBIOLOGY"
 EXECUTE cpm_get_cd_for_cdf
 SET microbiology_cd = code_value
 FOR (x = 1 TO value(request->order_cnt))
  SELECT INTO "nl:"
   FROM orders o
   PLAN (o
    WHERE (o.order_id=request->orders[x].order_id))
   DETAIL
    cs_flag = o.cs_flag, cs_order_id = o.order_id
   WITH nocounter
  ;end select
  IF (((cs_flag=1) OR (((cs_flag=4) OR (cs_flag=6)) )) )
   SELECT INTO "nl:"
    o.order_id
    FROM orders o
    PLAN (o
     WHERE o.cs_order_id=cs_order_id)
    DETAIL
     tcnt = (tcnt+ 1)
     IF (tcnt > size(treq->torders,5))
      stat = alter(treq->torders,(tcnt+ 10))
     ENDIF
     treq->torders[tcnt].order_id = o.order_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET tcnt = (tcnt+ 1)
    IF (tcnt > size(treq->torders,5))
     SET stat = alter(treq->torders,(tcnt+ 10))
    ENDIF
    SET treq->torders[tcnt].order_id = request->orders[x].order_id
   ENDIF
  ELSE
   SET tcnt = (tcnt+ 1)
   IF (tcnt > size(treq->torders,5))
    SET stat = alter(treq->torders,(tcnt+ 10))
   ENDIF
   SET treq->torders[tcnt].order_id = request->orders[x].order_id
  ENDIF
 ENDFOR
 SET stat = alter(treq->torders,tcnt)
 SET request->order_cnt = tcnt
 SET stat = alterlist(request->orders,tcnt)
 FOR (x = 1 TO tcnt)
   SET request->orders[x].order_id = treq->torders[x].order_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(request->order_cnt)),
   orders o,
   order_catalog oc
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->orders[d.seq].order_id))
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->orders,5))
    stat = alterlist(reply->orders,(count1+ 20)), stat = alterlist(temp->cc,(count1+ 20))
   ENDIF
   temp->cc[count1].catalog_cd = o.catalog_cd, temp->cc[count1].catalog_type_cd = o.catalog_type_cd,
   temp->cc[count1].activity_type_cd = o.activity_type_cd,
   temp->cc[count1].cont_order_method_flag = oc.cont_order_method_flag, temp->cc[count1].
   primary_mnemonic = oc.primary_mnemonic, temp->cc[count1].ref_text_mask = oc.ref_text_mask,
   temp->cc[count1].event_cd = oc.event_cd, temp->cc[count1].cki = oc.cki, reply->orders[count1].
   catalog_cd = o.catalog_cd,
   reply->orders[count1].order_mnemonic = oc.primary_mnemonic, reply->orders[count1].order_id = o
   .order_id, reply->orders[count1].encntr_id = o.encntr_id,
   reply->orders[count1].person_id = o.person_id, reply->orders[count1].order_status_cd = o
   .order_status_cd, reply->orders[count1].orig_order_dt_tm = o.orig_order_dt_tm,
   reply->orders[count1].display_line = trim(o.order_detail_display_line), reply->orders[count1].
   last_update_provider_id = o.last_update_provider_id, reply->orders[count1].last_action_sequence =
   o.last_action_sequence,
   reply->orders[count1].med_order_type_cd = o.med_order_type_cd, reply->orders[count1].constant_ind
    = o.constant_ind, reply->orders[count1].prn_ind = o.prn_ind,
   reply->orders[count1].order_comment_ind = o.order_comment_ind, reply->orders[count1].
   current_start_dt_tm = o.current_start_dt_tm, reply->orders[count1].projected_stop_dt_tm = o
   .projected_stop_dt_tm,
   reply->orders[count1].ingredient_ind = o.ingredient_ind, reply->orders[count1].template_order_flag
    = o.template_order_flag
  FOOT REPORT
   reply->order_cnt = count1, stat = alterlist(reply->orders,count1), temp->cc_cnt = count1,
   stat = alterlist(temp->cc,count1)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  catalog_cd = temp->cc[d.seq].catalog_cd
  FROM (dummyt d  WITH seq = value(temp->cc_cnt))
  ORDER BY catalog_cd
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->catalog,5))
    stat = alterlist(reply->catalog,count1)
   ENDIF
   reply->catalog[count1].catalog_cd = catalog_cd, reply->catalog[count1].catalog_type_cd = temp->cc[
   d.seq].catalog_type_cd, reply->catalog[count1].activity_type_cd = temp->cc[d.seq].activity_type_cd,
   reply->catalog[count1].cont_order_method_flag = temp->cc[d.seq].cont_order_method_flag, reply->
   catalog[count1].primary_mnemonic = temp->cc[d.seq].primary_mnemonic, reply->catalog[count1].
   ref_text_mask = temp->cc[d.seq].ref_text_mask,
   reply->catalog[count1].cki = temp->cc[d.seq].cki, reply->catalog[count1].event_cd = temp->cc[d.seq
   ].event_cd
  FOOT REPORT
   reply->catalog_cnt = count1
  WITH nocounter
 ;end select
 FOR (x = 1 TO reply->catalog_cnt)
   SET stat = alterlist(reply->catalog[x].tasks,1)
   SET reply->catalog[x].task_cnt = 1
   SET reply->catalog[x].tasks[1].task_seq = 0
   SET reply->catalog[x].tasks[1].task_type_flag = 0
   SET reply->catalog[x].tasks[1].prim_task_ind = 0
   SET reply->catalog[x].tasks[1].ref_task_id = 0
   SET reply->catalog[x].tasks[1].task_description = " "
   SET reply->catalog[x].tasks[1].task_description_key = " "
   SET reply->catalog[x].tasks[1].task_type_cd = 0
   SELECT INTO "nl:"
    otx.catalog_cd, otx.order_task_seq, ot.task_type_cd
    FROM order_task_xref otx,
     order_task ot
    PLAN (otx
     WHERE (otx.catalog_cd=reply->catalog[x].catalog_cd))
     JOIN (ot
     WHERE ot.reference_task_id=otx.reference_task_id)
    ORDER BY otx.order_task_seq
    HEAD otx.catalog_cd
     count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (count1 > size(reply->catalog[x].tasks,5))
      stat = alterlist(reply->catalog[x].tasks,(count1+ 5))
     ENDIF
     reply->catalog[x].tasks[count1].task_seq = otx.order_task_seq, reply->catalog[x].tasks[count1].
     task_type_flag = otx.order_task_type_flag, reply->catalog[x].tasks[count1].prim_task_ind = otx
     .primary_task_ind,
     reply->catalog[x].tasks[count1].ref_task_id = otx.reference_task_id, reply->catalog[x].tasks[
     count1].task_description = ot.task_description, reply->catalog[x].tasks[count1].
     task_description_key = ot.task_description_key,
     reply->catalog[x].tasks[count1].task_type_cd = ot.task_type_cd
    FOOT  otx.catalog_cd
     reply->catalog[x].task_cnt = count1, stat = alterlist(reply->catalog[x].tasks,count1)
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO reply->catalog_cnt)
   FOR (y = 1 TO reply->catalog[x].task_cnt)
    SET reply->catalog[x].tasks[y].assay_cnt = 0
    IF ((((reply->catalog[x].catalog_type_cd=radiology_cd)) OR ((reply->catalog[x].catalog_type_cd=
    lab_cd)
     AND (reply->catalog[x].activity_type_cd=microbiology_cd))) )
     SET stat = alterlist(reply->catalog[x].tasks[y].assay,1)
     SET reply->catalog[x].tasks[y].assay_cnt = 1
     SET reply->catalog[x].tasks[y].assay[1].pend_req_ind = 0
     SET reply->catalog[x].tasks[y].assay[1].sequence = 0
     SET reply->catalog[x].tasks[y].assay[1].task_assay_cd = 0
     SET reply->catalog[x].tasks[y].assay[1].mnemonic_key = cnvtupper(reply->catalog[x].
      primary_mnemonic)
     SET reply->catalog[x].tasks[y].assay[1].mnemonic = reply->catalog[x].primary_mnemonic
     SET reply->catalog[x].tasks[y].assay[1].activity_type_cd = reply->catalog[x].activity_type_cd
     SET reply->catalog[x].tasks[y].assay[1].desc = reply->catalog[x].primary_mnemonic
     SET reply->catalog[x].tasks[y].assay[1].event_cd = 0
    ELSE
     IF ((reply->catalog[x].tasks[y].task_type_flag=0))
      SELECT INTO "nl:"
       ptr.sequence, dta.task_assay_cd
       FROM profile_task_r ptr,
        discrete_task_assay dta
       WHERE (ptr.catalog_cd=reply->catalog[x].catalog_cd)
        AND ptr.active_ind=1
        AND dta.task_assay_cd=ptr.task_assay_cd
        AND dta.active_ind=1
       ORDER BY ptr.sequence
       HEAD REPORT
        count1 = 0
       DETAIL
        count1 = (count1+ 1)
        IF (count1 > size(reply->catalog[x].tasks[y].assay,5))
         stat = alterlist(reply->catalog[x].tasks[y].assay,(count1+ 5))
        ENDIF
        reply->catalog[x].tasks[y].assay[count1].pend_req_ind = ptr.pending_ind, reply->catalog[x].
        tasks[y].assay[count1].sequence = ptr.sequence, reply->catalog[x].tasks[y].assay[count1].
        task_assay_cd = dta.task_assay_cd,
        reply->catalog[x].tasks[y].assay[count1].mnemonic_key = dta.mnemonic_key_cap, reply->catalog[
        x].tasks[y].assay[count1].mnemonic = dta.mnemonic, reply->catalog[x].tasks[y].assay[count1].
        activity_type_cd = dta.activity_type_cd,
        reply->catalog[x].tasks[y].assay[count1].desc = dta.description, reply->catalog[x].tasks[y].
        assay[count1].event_cd = dta.event_cd
       FOOT REPORT
        reply->catalog[x].tasks[y].assay_cnt = count1, stat = alterlist(reply->catalog[x].tasks[y].
         assay,count1)
       WITH nocounter
      ;end select
     ENDIF
     IF ((reply->catalog[x].tasks[y].task_type_flag=1))
      SELECT INTO "nl:"
       ptr.sequence, dta.task_assay_cd
       FROM profile_task_r ptr,
        discrete_task_assay dta
       WHERE (ptr.reference_task_id=reply->catalog[x].tasks[y].ref_task_id)
        AND (ptr.catalog_cd=reply->catalog[x].catalog_cd)
        AND ptr.active_ind=1
        AND dta.task_assay_cd=ptr.task_assay_cd
        AND dta.active_ind=1
       ORDER BY ptr.sequence
       HEAD REPORT
        count1 = 0
       DETAIL
        count1 = (count1+ 1)
        IF (count1 > size(reply->catalog[x].tasks[y].assay,5))
         stat = alterlist(reply->catalog[x].tasks[y].assay,(count1+ 5))
        ENDIF
        reply->catalog[x].tasks[y].assay[count1].pend_req_ind = ptr.pending_ind, reply->catalog[x].
        tasks[y].assay[count1].sequence = ptr.sequence, reply->catalog[x].tasks[y].assay[count1].
        task_assay_cd = dta.task_assay_cd,
        reply->catalog[x].tasks[y].assay[count1].mnemonic_key = dta.mnemonic_key_cap, reply->catalog[
        x].tasks[y].assay[count1].mnemonic = dta.mnemonic, reply->catalog[x].tasks[y].assay[count1].
        activity_type_cd = dta.activity_type_cd,
        reply->catalog[x].tasks[y].assay[count1].desc = dta.description, reply->catalog[x].tasks[y].
        assay[count1].event_cd = dta.event_cd
       FOOT REPORT
        reply->catalog[x].tasks[y].assay_cnt = count1, stat = alterlist(reply->catalog[x].tasks[y].
         assay,count1)
       WITH nocounter
      ;end select
     ELSE
      IF ((reply->catalog[x].tasks[y].task_type_flag=2))
       SELECT INTO "nl:"
        tdr.sequence, dta.task_assay_cd
        FROM task_discrete_r tdr,
         discrete_task_assay dta
        WHERE (tdr.reference_task_id=reply->catalog[x].tasks[y].ref_task_id)
         AND tdr.active_ind=1
         AND dta.task_assay_cd=tdr.task_assay_cd
         AND dta.active_ind=1
        ORDER BY tdr.sequence
        HEAD REPORT
         count1 = 0
        DETAIL
         count1 = (count1+ 1)
         IF (count1 > size(reply->catalog[x].tasks[y].assay,5))
          stat = alterlist(reply->catalog[x].tasks[y].assay,(count1+ 5))
         ENDIF
         reply->catalog[x].tasks[y].assay[count1].pend_req_ind = tdr.required_ind, reply->catalog[x].
         tasks[y].assay[count1].sequence = tdr.sequence, reply->catalog[x].tasks[y].assay[count1].
         task_assay_cd = dta.task_assay_cd,
         reply->catalog[x].tasks[y].assay[count1].mnemonic_key = dta.mnemonic_key_cap, reply->
         catalog[x].tasks[y].assay[count1].mnemonic = dta.mnemonic, reply->catalog[x].tasks[y].assay[
         count1].activity_type_cd = dta.activity_type_cd,
         reply->catalog[x].tasks[y].assay[count1].desc = dta.description, reply->catalog[x].tasks[y].
         assay[count1].event_cd = dta.event_cd
        FOOT REPORT
         reply->catalog[x].tasks[y].assay_cnt = count1, stat = alterlist(reply->catalog[x].tasks[y].
          assay,count1)
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF ((reply->order_cnt=0)
  AND (reply->catalog_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->orders,reply->order_cnt)
  SET stat = alterlist(reply->catalog,reply->catalog_cnt)
 ENDIF
 CALL echo(build("orders count :",reply->order_cnt))
 FOR (x = 1 TO reply->order_cnt)
   CALL echo(build("catalog_cd :",reply->orders[x].catalog_cd))
   CALL echo(build("order mnem:",reply->orders[x].order_mnemonic))
   CALL echo(build("order id:",reply->orders[x].order_id))
   CALL echo(build("disp line:",reply->orders[x].display_line))
 ENDFOR
 CALL echo(build("catalog count :",reply->catalog_cnt))
 FOR (x = 1 TO reply->catalog_cnt)
   CALL echo(build("catalog_cd :",reply->catalog[x].catalog_cd))
   CALL echo(build("task count :",reply->catalog[x].task_cnt))
   FOR (y = 1 TO reply->catalog[x].task_cnt)
     CALL echo(build("task type flag:",reply->catalog[x].tasks[y].task_type_flag))
     CALL echo(build("ref task id:",reply->catalog[x].tasks[y].ref_task_id))
     CALL echo(build("task desc:",reply->catalog[x].tasks[y].task_description))
     CALL echo(build("assay cnt:",reply->catalog[x].tasks[y].assay_cnt))
     FOR (z = 1 TO reply->catalog[x].tasks[y].assay_cnt)
       CALL echo(build("assay desc:",reply->catalog[x].tasks[y].assay[z].desc))
     ENDFOR
   ENDFOR
 ENDFOR
END GO
