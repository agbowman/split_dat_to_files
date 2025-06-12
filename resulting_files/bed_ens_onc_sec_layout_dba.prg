CREATE PROGRAM bed_ens_onc_sec_layout:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_req
 RECORD temp_req(
   1 layouts[*]
     2 action_flag = i2
     2 onc_docset_elem_decorator_id = f8
     2 prev_docset_elem_decorator_id = f8
     2 doc_set_element_id = f8
     2 group_start_ind = i2
     2 start_group_type_flag = i2
     2 group_end_ind = i2
     2 end_group_type_flag = i2
     2 group_caption = vc
     2 element_style_flag = i2
 )
 FREE SET cpy
 RECORD cpy(
   1 cpys[*]
     2 doc_set_element_id = f8
     2 element_style_flag = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 end_group_type_flag = i2
     2 group_caption = cv
     2 group_end_ind = i2
     2 group_start_ind = i2
     2 onc_docset_elem_decorator_id = f8
     2 prev_docset_elem_decorator_id = f8
     2 start_group_type_flag = i2
     2 active_ind = i2
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = 0
 SET req_cnt = size(request->layouts,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp_req->layouts,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET temp_req->layouts[x].action_flag = request->layouts[x].action_flag
   SET temp_req->layouts[x].doc_set_element_id = request->layouts[x].doc_set_element_id
   SET temp_req->layouts[x].element_style_flag = request->layouts[x].element_style_flag
   SET temp_req->layouts[x].end_group_type_flag = request->layouts[x].end_group_type_flag
   SET temp_req->layouts[x].group_caption = request->layouts[x].group_caption
   SET temp_req->layouts[x].group_end_ind = request->layouts[x].group_end_ind
   SET temp_req->layouts[x].group_start_ind = request->layouts[x].group_start_ind
   SET temp_req->layouts[x].start_group_type_flag = request->layouts[x].start_group_type_flag
 ENDFOR
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   onc_docset_elem_decorator o
  PLAN (d)
   JOIN (o
   WHERE (o.doc_set_element_id=temp_req->layouts[d.seq].doc_set_element_id)
    AND o.onc_docset_elem_decorator_id=o.prev_docset_elem_decorator_id)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  HEAD d.seq
   temp_req->layouts[d.seq].onc_docset_elem_decorator_id = o.onc_docset_elem_decorator_id, temp_req->
   layouts[d.seq].prev_docset_elem_decorator_id = o.prev_docset_elem_decorator_id
   IF ((temp_req->layouts[d.seq].action_flag=1))
    temp_req->layouts[d.seq].action_flag = 2
   ENDIF
   cnt = (cnt+ 1), stat = alterlist(cpy->cpys,cnt), cpy->cpys[cnt].active_ind = o.active_ind,
   cpy->cpys[cnt].beg_effective_dt_tm = o.beg_effective_dt_tm, cpy->cpys[cnt].doc_set_element_id = o
   .doc_set_element_id, cpy->cpys[cnt].element_style_flag = o.element_style_flag,
   cpy->cpys[cnt].end_effective_dt_tm = o.end_effective_dt_tm, cpy->cpys[cnt].end_group_type_flag = o
   .end_group_type_flag, cpy->cpys[cnt].group_caption = o.group_caption,
   cpy->cpys[cnt].group_end_ind = o.group_end_ind, cpy->cpys[cnt].group_start_ind = o.group_start_ind,
   cpy->cpys[cnt].onc_docset_elem_decorator_id = o.onc_docset_elem_decorator_id,
   cpy->cpys[cnt].prev_docset_elem_decorator_id = o.prev_docset_elem_decorator_id, cpy->cpys[cnt].
   start_group_type_flag = o.start_group_type_flag, cpy->cpys[cnt].updt_applctx = o.updt_applctx,
   cpy->cpys[cnt].updt_cnt = o.updt_cnt, cpy->cpys[cnt].updt_dt_tm = o.updt_dt_tm, cpy->cpys[cnt].
   updt_id = o.updt_id,
   cpy->cpys[cnt].updt_task = o.updt_task
  WITH nocounter
 ;end select
 FOR (x = 1 TO req_cnt)
   IF ((temp_req->layouts[x].action_flag=1))
    SET new_cv = 0.0
    SELECT INTO "NL:"
     j = seq(tracking_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp_req->layouts[x].onc_docset_elem_decorator_id = cnvtreal(j), temp_req->layouts[x].
      prev_docset_elem_decorator_id = cnvtreal(j)
     WITH format, counter
    ;end select
   ENDIF
 ENDFOR
 IF (cnt > 0)
  SET ierrcode = 0
  INSERT  FROM onc_docset_elem_decorator o,
    (dummyt d  WITH seq = value(cnt))
   SET o.doc_set_element_id = cpy->cpys[d.seq].doc_set_element_id, o.element_style_flag = cpy->cpys[d
    .seq].element_style_flag, o.beg_effective_dt_tm = cnvtdatetime(cpy->cpys[d.seq].
     beg_effective_dt_tm),
    o.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.end_group_type_flag = cpy->cpys[d.seq].
    end_group_type_flag, o.group_caption = cpy->cpys[d.seq].group_caption,
    o.group_end_ind = cpy->cpys[d.seq].group_end_ind, o.group_start_ind = cpy->cpys[d.seq].
    group_start_ind, o.onc_docset_elem_decorator_id = seq(tracking_seq,nextval),
    o.prev_docset_elem_decorator_id = cpy->cpys[d.seq].prev_docset_elem_decorator_id, o
    .start_group_type_flag = cpy->cpys[d.seq].start_group_type_flag, o.active_ind = cpy->cpys[d.seq].
    active_ind,
    o.updt_applctx = cpy->cpys[d.seq].updt_applctx, o.updt_cnt = cpy->cpys[d.seq].updt_cnt, o
    .updt_dt_tm = cnvtdatetime(cpy->cpys[d.seq].updt_dt_tm),
    o.updt_id = cpy->cpys[d.seq].updt_id, o.updt_task = cpy->cpys[d.seq].updt_task
   PLAN (d)
    JOIN (o)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error on insert onc_docset_elem_decorator1")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 INSERT  FROM onc_docset_elem_decorator o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.doc_set_element_id = temp_req->layouts[d.seq].doc_set_element_id, o.element_style_flag =
   temp_req->layouts[d.seq].element_style_flag, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3
    ),
   o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.end_group_type_flag = temp_req->layouts[d
   .seq].end_group_type_flag, o.group_caption = temp_req->layouts[d.seq].group_caption,
   o.group_end_ind = temp_req->layouts[d.seq].group_end_ind, o.group_start_ind = temp_req->layouts[d
   .seq].group_start_ind, o.onc_docset_elem_decorator_id = temp_req->layouts[d.seq].
   onc_docset_elem_decorator_id,
   o.prev_docset_elem_decorator_id = temp_req->layouts[d.seq].prev_docset_elem_decorator_id, o
   .start_group_type_flag = temp_req->layouts[d.seq].start_group_type_flag, o.active_ind = 1,
   o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (temp_req->layouts[d.seq].action_flag=1))
   JOIN (o)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on insert onc_docset_elem_decorator2")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM onc_docset_elem_decorator o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.doc_set_element_id = temp_req->layouts[d.seq].doc_set_element_id, o.element_style_flag =
   temp_req->layouts[d.seq].element_style_flag, o.end_group_type_flag = temp_req->layouts[d.seq].
   end_group_type_flag,
   o.group_caption = temp_req->layouts[d.seq].group_caption, o.group_end_ind = temp_req->layouts[d
   .seq].group_end_ind, o.group_start_ind = temp_req->layouts[d.seq].group_start_ind,
   o.start_group_type_flag = temp_req->layouts[d.seq].start_group_type_flag, o.active_ind =
   IF ((temp_req->layouts[d.seq].action_flag=3)) 0
   ELSE 1
   ENDIF
   , o.updt_applctx = reqinfo->updt_applctx,
   o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->
   updt_id,
   o.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (temp_req->layouts[d.seq].action_flag IN (2, 3)))
   JOIN (o
   WHERE (o.onc_docset_elem_decorator_id=temp_req->layouts[d.seq].onc_docset_elem_decorator_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on update onc_docset_elem_decorator1")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
