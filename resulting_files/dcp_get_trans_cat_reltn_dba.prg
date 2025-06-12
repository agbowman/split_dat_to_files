CREATE PROGRAM dcp_get_trans_cat_reltn:dba
 RECORD reply(
   1 qual[*]
     2 category_name = vc
     2 category_id = f8
     2 transfer_type_cd = f8
     2 active_ind = i2
     2 relationship[*]
       3 trans_event_cd_r_id = f8
       3 source_event_cd = f8
       3 target_event_cd = f8
       3 association_identifier_cd = f8
       3 transfer_type = f8
       3 active_ind = i2
       3 reltn_sequence = i4
   1 status_data
     2 status = c1
 )
 RECORD relationship(
   1 qual[*]
     2 category_id = f8
     2 trans_event_cd_r_id = f8
     2 source_event_cd = f8
     2 target_event_cd = f8
     2 association_identifier_cd = f8
     2 transfer_type = f8
     2 active_ind = i2
     2 reltn_sequence = i4
 )
 DECLARE num = i4 WITH noconstant(0)
 DECLARE index = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE reltn_idx = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE batch_size = i4 WITH constant(25)
 SET cat_cnt = size(request->qual,5)
 SET reply->status_data.status = "S"
 SET cur_list_size = cat_cnt
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(reply->qual,new_list_size)
 FOR (idx = 1 TO cur_list_size)
   SET reply->qual[idx].category_id = request->qual[idx].category_id
 ENDFOR
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET reply->qual[idx].category_id = reply->qual[cur_list_size].category_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dcp_cf_trans_cat cat
  PLAN (d1
   WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cat
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),cat.dcp_cf_trans_cat_id,reply->qual[num].
    category_id))
  HEAD REPORT
   index = 0
  DETAIL
   index = locateval(num,1,cur_list_size,cat.dcp_cf_trans_cat_id,reply->qual[num].category_id), reply
   ->qual[index].active_ind = cat.active_ind, reply->qual[index].category_id = cat
   .dcp_cf_trans_cat_id,
   reply->qual[index].category_name = cat.cf_category_name, reply->qual[index].transfer_type_cd = cat
   .cf_transfer_type_cd
  WITH nocounter
 ;end select
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET reply->qual[idx].active_ind = reply->qual[cur_list_size].active_ind
   SET reply->qual[idx].category_id = reply->qual[cur_list_size].category_id
   SET reply->qual[idx].category_name = reply->qual[cur_list_size].category_name
   SET reply->qual[idx].transfer_type_cd = reply->qual[cur_list_size].transfer_type_cd
 ENDFOR
 SET nstart = 1
 IF ((request->need_inactive_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    dcp_cf_trans_cat_reltn rel
   PLAN (d1
    WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (rel
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),rel.dcp_cf_trans_cat_id,reply->qual[num].
     category_id))
   ORDER BY rel.dcp_cf_trans_cat_id, rel.active_ind DESC, rel.reltn_sequence
   HEAD rel.dcp_cf_trans_cat_id
    index = locateval(num,1,cur_list_size,rel.dcp_cf_trans_cat_id,reply->qual[num].category_id),
    reltn_idx = 0
   DETAIL
    reltn_idx = (reltn_idx+ 1)
    IF (mod(reltn_idx,10)=1)
     stat = alterlist(reply->qual[index].relationship,(reltn_idx+ 9))
    ENDIF
    reply->qual[index].relationship[reltn_idx].trans_event_cd_r_id = rel.dcp_cf_trans_event_cd_r_id,
    reply->qual[index].relationship[reltn_idx].active_ind = rel.active_ind, reply->qual[index].
    relationship[reltn_idx].reltn_sequence = rel.reltn_sequence
   FOOT  rel.dcp_cf_trans_cat_id
    stat = alterlist(reply->qual[index].relationship,reltn_idx)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,cur_list_size)
 ELSEIF ((request->need_inactive_ind=0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    dcp_cf_trans_cat_reltn rel
   PLAN (d1
    WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (rel
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),rel.dcp_cf_trans_cat_id,reply->qual[num].
     category_id)
     AND rel.active_ind=1)
   ORDER BY rel.dcp_cf_trans_cat_id, rel.reltn_sequence
   HEAD rel.dcp_cf_trans_cat_id
    index = locateval(num,1,cur_list_size,rel.dcp_cf_trans_cat_id,reply->qual[num].category_id),
    reltn_idx = 0
   DETAIL
    reltn_idx = (reltn_idx+ 1)
    IF (mod(reltn_idx,10)=1)
     stat = alterlist(reply->qual[index].relationship,(reltn_idx+ 9))
    ENDIF
    reply->qual[index].relationship[reltn_idx].trans_event_cd_r_id = rel.dcp_cf_trans_event_cd_r_id,
    reply->qual[index].relationship[reltn_idx].active_ind = rel.active_ind, reply->qual[index].
    relationship[reltn_idx].reltn_sequence = rel.reltn_sequence
   FOOT  rel.dcp_cf_trans_cat_id
    stat = alterlist(reply->qual[index].relationship,reltn_idx)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,cur_list_size)
 ELSE
  GO TO exit_script
  SET reply->status_data.status = "F"
 ENDIF
 SET nstart = 1
 SET reltn_idx = 0
 FOR (index = 1 TO cat_cnt)
  SET reltn_size = size(reply->qual[index].relationship,5)
  FOR (idx = 1 TO reltn_size)
    SET reltn_idx = (reltn_idx+ 1)
    IF (mod(reltn_idx,10)=1)
     SET stat = alterlist(relationship->qual,(reltn_idx+ 9))
    ENDIF
    SET relationship->qual[reltn_idx].category_id = reply->qual[index].category_id
    SET relationship->qual[reltn_idx].trans_event_cd_r_id = reply->qual[index].relationship[idx].
    trans_event_cd_r_id
    SET relationship->qual[reltn_idx].active_ind = reply->qual[index].relationship[idx].active_ind
    SET relationship->qual[reltn_idx].reltn_sequence = reply->qual[index].relationship[idx].
    reltn_sequence
  ENDFOR
 ENDFOR
 SET stat = alterlist(relationship->qual,reltn_idx)
 SET cur_list_size = size(relationship->qual,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(relationship->qual,new_list_size)
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET relationship->qual[idx].category_id = relationship->qual[cur_list_size].category_id
   SET relationship->qual[idx].trans_event_cd_r_id = relationship->qual[cur_list_size].
   trans_event_cd_r_id
   SET relationship->qual[idx].active_ind = relationship->qual[cur_list_size].active_ind
   SET relationship->qual[idx].reltn_sequence = relationship->qual[cur_list_size].reltn_sequence
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dcp_cf_trans_event_cd_r cdr
  PLAN (d1
   WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cdr
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),cdr.dcp_cf_trans_event_cd_r_id,relationship->
    qual[num].trans_event_cd_r_id))
  HEAD REPORT
   num = 0
  DETAIL
   index = locateval(num,1,cur_list_size,cdr.dcp_cf_trans_event_cd_r_id,relationship->qual[num].
    trans_event_cd_r_id)
   WHILE (index != 0)
     relationship->qual[index].source_event_cd = cdr.source_event_cd, relationship->qual[index].
     target_event_cd = cdr.target_event_cd, relationship->qual[index].association_identifier_cd = cdr
     .association_identifier_cd,
     relationship->qual[index].transfer_type = cdr.cf_transfer_type_cd, index = locateval(num,(index
      + 1),cur_list_size,cdr.dcp_cf_trans_event_cd_r_id,relationship->qual[num].trans_event_cd_r_id)
   ENDWHILE
  WITH nocounter, outerjoin = d1
 ;end select
 SET stat = alterlist(relationship->qual,cur_list_size)
 SET idx = 0
 FOR (index = 1 TO cat_cnt)
  SET reltn_count = size(reply->qual[index].relationship,5)
  FOR (reltn_idx = 1 TO reltn_count)
    SET idx = (idx+ 1)
    SET reply->qual[index].relationship[reltn_idx].association_identifier_cd = relationship->qual[idx
    ].association_identifier_cd
    SET reply->qual[index].relationship[reltn_idx].source_event_cd = relationship->qual[idx].
    source_event_cd
    SET reply->qual[index].relationship[reltn_idx].target_event_cd = relationship->qual[idx].
    target_event_cd
    SET reply->qual[index].relationship[reltn_idx].transfer_type = relationship->qual[idx].
    transfer_type
  ENDFOR
 ENDFOR
 SET stat = alterlist(relationship->qual,0)
 CALL echorecord(request)
 CALL echorecord(reply)
 CALL echo(build("Script status = ",reply->status_data.status))
#exit_script
 IF (cat_cnt=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
