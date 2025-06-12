CREATE PROGRAM ce_event_order_link_ins:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 FREE RECORD orders
 RECORD orders(
   1 lst[*]
     2 order_id = f8
 )
 DECLARE batch_size = i4 WITH noconstant(20)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(0)
 DECLARE expand_idx = i4 WITH noconstant(0)
 DECLARE locateval_idx = i4 WITH noconstant(0)
 DECLARE request_size = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SET request_size = size(request->lst,5)
 FOR (for_idx = 1 TO request_size)
   IF ((((request->lst[for_idx].parent_order_ident=0)) OR ((request->lst[for_idx].catalog_type_cd=0)
   )) )
    SET cnt += 1
    SET stat = alterlist(orders->lst,cnt)
    SET orders->lst[cnt].order_id = request->lst[for_idx].order_id
   ENDIF
 ENDFOR
 SET cur_list_size = size(orders->lst,5)
 IF (cur_list_size)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET nstart = 1
  SET stat = alterlist(orders->lst,new_list_size)
  FOR (for_idx = (cur_list_size+ 1) TO new_list_size)
    SET orders->lst[for_idx].order_id = orders->lst[cur_list_size].order_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    orders o
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (o
    WHERE expand(expand_idx,nstart,(nstart+ (batch_size - 1)),o.order_id,orders->lst[expand_idx].
     order_id))
   DETAIL
    idx = locateval(locateval_idx,1,request_size,o.order_id,request->lst[locateval_idx].order_id)
    WHILE (idx != 0)
      request->lst[idx].parent_order_ident = o.template_order_id, request->lst[idx].catalog_type_cd
       = o.catalog_type_cd, idx = locateval(locateval_idx,(idx+ 1),request_size,o.order_id,request->
       lst[locateval_idx].order_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET error_code = error(error_msg,0)
  IF (error_code)
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (for_idx = 1 TO request_size)
   IF ((request->lst[for_idx].parent_order_ident=0))
    SET request->lst[for_idx].parent_order_ident = request->lst[for_idx].order_id
   ENDIF
 ENDFOR
 INSERT  FROM ce_event_order_link t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.order_id = evaluate2(
    IF ((request->lst[d.seq].order_id=- (1))) 0
    ELSE request->lst[d.seq].order_id
    ENDIF
    ), t.order_action_sequence = evaluate2(
    IF ((request->lst[d.seq].order_action_sequence=- (1))) 0
    ELSE request->lst[d.seq].order_action_sequence
    ENDIF
    ),
   t.valid_from_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_from_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_from_dt_tm)
    ENDIF
    ), t.valid_until_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_until_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_until_dt_tm)
    ENDIF
    ), t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].updt_dt_tm),
   t.updt_task = request->lst[d.seq].updt_task, t.updt_id = request->lst[d.seq].updt_id, t.updt_cnt
    = request->lst[d.seq].updt_cnt,
   t.updt_applctx = request->lst[d.seq].updt_applctx, t.parent_order_ident = evaluate2(
    IF ((request->lst[d.seq].parent_order_ident=- (1))) 0
    ELSE request->lst[d.seq].parent_order_ident
    ENDIF
    ), t.event_end_dt_tm = cnvtdatetimeutc(request->lst[d.seq].event_end_dt_tm),
   t.person_id = evaluate2(
    IF ((request->lst[d.seq].person_id=- (1))) 0
    ELSE request->lst[d.seq].person_id
    ENDIF
    ), t.encntr_id = evaluate2(
    IF ((request->lst[d.seq].encntr_id=- (1))) 0
    ELSE request->lst[d.seq].encntr_id
    ENDIF
    ), t.catalog_type_cd = evaluate2(
    IF ((request->lst[d.seq].catalog_type_cd=- (1))) 0
    ELSE request->lst[d.seq].catalog_type_cd
    ENDIF
    ),
   t.ce_event_order_link_id = request->lst[d.seq].ce_event_order_link_id
  PLAN (d)
   JOIN (t)
  WITH rdbarrayinsert = 100, counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
#exit_script
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
