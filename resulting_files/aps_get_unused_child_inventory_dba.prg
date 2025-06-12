CREATE PROGRAM aps_get_unused_child_inventory:dba
 RECORD reply(
   1 list[*]
     2 content_table_name = vc
     2 content_table_id = f8
     2 inventory_task_id = f8
     2 last_print_task_id = f8
     2 last_print_task_disp = vc
     2 inventory_task_disp = vc
     2 inventory_tag_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 cassette_list[*]
     2 content_table_id = f8
     2 inventory_task_id = f8
     2 inventory_task_disp = vc
     2 last_print_task_id = f8
     2 last_print_task_disp = vc
     2 used_ind = i2
     2 inventory_tag_disp = vc
     2 inventory_tag_seq = i4
   1 slide_list[*]
     2 content_table_id = f8
     2 inventory_task_id = f8
     2 inventory_task_disp = vc
     2 last_print_task_id = f8
     2 last_print_task_disp = vc
     2 used_ind = i2
     2 inventory_tag_disp = vc
     2 inventory_tag_seq = i4
 )
 SET reply->status_data.status = "F"
 DECLARE specimen_table_name = vc WITH protect, constant("CASE_SPECIMEN")
 DECLARE cassette_table_name = vc WITH protect, constant("CASSETTE")
 DECLARE slide_table_name = vc WITH protect, constant("SLIDE")
 DECLARE canceled_task_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1305,"CANCEL"))
 DECLARE verified_task_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1305,"VERIFIED"))
 DECLARE mismatch_event_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",2061,"MISMATCHED"))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE cassette_cnt = i4 WITH protect, noconstant(0)
 DECLARE slide_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(10)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE start_pos = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SELECT
  IF ((request->content_table_name=specimen_table_name))
   PLAN (pt
    WHERE (pt.case_specimen_id=request->content_table_id)
     AND pt.case_specimen_id > 0
     AND pt.create_inventory_flag IN (1, 2, 3)
     AND  NOT (pt.status_cd IN (canceled_task_cd, verified_task_cd)))
  ELSEIF ((request->content_table_name=cassette_table_name))
   PLAN (pt
    WHERE (pt.cassette_id=request->content_table_id)
     AND pt.cassette_id > 0
     AND pt.create_inventory_flag IN (2, 3)
     AND  NOT (pt.status_cd IN (canceled_task_cd, verified_task_cd)))
  ELSE
   PLAN (pt
    WHERE pt.processing_task_id=0)
  ENDIF
  INTO "nl:"
  FROM processing_task pt
  DETAIL
   IF ((request->content_table_name=specimen_table_name))
    IF (band(request->query_mode,1)=1
     AND band(pt.create_inventory_flag,1)=1
     AND pt.cassette_id > 0)
     cassette_cnt = (cassette_cnt+ 1), stat = alterlist(temp->cassette_list,cassette_cnt), temp->
     cassette_list[cassette_cnt].content_table_id = pt.cassette_id,
     temp->cassette_list[cassette_cnt].inventory_task_disp = uar_get_code_display(pt.task_assay_cd),
     temp->cassette_list[cassette_cnt].inventory_task_id = pt.processing_task_id, temp->
     cassette_list[cassette_cnt].used_ind = 0
    ENDIF
    IF (band(request->query_mode,2)=2
     AND band(pt.create_inventory_flag,2)=2
     AND pt.cassette_id=0
     AND pt.slide_id > 0)
     slide_cnt = (slide_cnt+ 1), stat = alterlist(temp->slide_list,slide_cnt), temp->slide_list[
     slide_cnt].content_table_id = pt.slide_id,
     temp->slide_list[slide_cnt].inventory_task_id = pt.processing_task_id, temp->slide_list[
     slide_cnt].inventory_task_disp = uar_get_code_display(pt.task_assay_cd), temp->slide_list[
     slide_cnt].last_print_task_id = 0,
     temp->slide_list[slide_cnt].used_ind = 0
    ENDIF
   ELSEIF ((request->content_table_name=cassette_table_name))
    IF (band(request->query_mode,2)=2
     AND band(pt.create_inventory_flag,2)=2
     AND pt.cassette_id > 0
     AND pt.slide_id > 0)
     slide_cnt = (slide_cnt+ 1), stat = alterlist(temp->slide_list,slide_cnt), temp->slide_list[
     slide_cnt].content_table_id = pt.slide_id,
     temp->slide_list[slide_cnt].inventory_task_id = pt.processing_task_id, temp->slide_list[
     slide_cnt].inventory_task_disp = uar_get_code_display(pt.task_assay_cd), temp->slide_list[
     slide_cnt].last_print_task_id = 0,
     temp->slide_list[slide_cnt].used_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (cassette_cnt > 0)
  SET loop_cnt = ceil((cnvtreal(cassette_cnt)/ batch_size))
  SET start_pos = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    cassette c,
    ap_tag at
   PLAN (d
    WHERE initarray(start_pos,evaluate(d.seq,1,1,(start_pos+ batch_size))))
    JOIN (c
    WHERE expand(idx,start_pos,minval(cassette_cnt,(start_pos+ (batch_size - 1))),c.cassette_id,temp
     ->cassette_list[idx].content_table_id))
    JOIN (at
    WHERE at.tag_id=c.cassette_tag_id)
   DETAIL
    pos = locateval(idx,1,cassette_cnt,c.cassette_id,temp->cassette_list[idx].content_table_id)
    IF (pos > 0)
     temp->cassette_list[pos].inventory_tag_disp = at.tag_disp, temp->cassette_list[pos].
     inventory_tag_seq = at.tag_sequence
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (slide_cnt > 0)
  SET loop_cnt = ceil((cnvtreal(slide_cnt)/ batch_size))
  SET start_pos = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    slide s,
    ap_tag at
   PLAN (d
    WHERE initarray(start_pos,evaluate(d.seq,1,1,(start_pos+ batch_size))))
    JOIN (s
    WHERE expand(idx,start_pos,minval(slide_cnt,(start_pos+ (batch_size - 1))),s.slide_id,temp->
     slide_list[idx].content_table_id))
    JOIN (at
    WHERE at.tag_id=s.tag_id)
   DETAIL
    pos = locateval(idx,1,slide_cnt,s.slide_id,temp->slide_list[idx].content_table_id)
    IF (pos > 0)
     temp->slide_list[pos].inventory_tag_disp = at.tag_disp, temp->slide_list[pos].inventory_tag_seq
      = at.tag_sequence
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cassette_cnt > 0)
  SET loop_cnt = ceil((cnvtreal(cassette_cnt)/ batch_size))
  SET start_pos = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    storage_content sc,
    storage_content_event sce
   PLAN (d
    WHERE initarray(start_pos,evaluate(d.seq,1,1,(start_pos+ batch_size))))
    JOIN (sc
    WHERE expand(idx,start_pos,minval(cassette_cnt,(start_pos+ (batch_size - 1))),sc.content_table_id,
     temp->cassette_list[idx].content_table_id,
     sc.content_table_name,"CASSETTE"))
    JOIN (sce
    WHERE sce.storage_content_id=sc.storage_content_id
     AND sce.storage_content_event_id > 0
     AND sce.action_cd != mismatch_event_cd)
   DETAIL
    pos = locateval(idx,1,cassette_cnt,sc.content_table_id,temp->cassette_list[idx].content_table_id)
    IF (pos > 0)
     temp->cassette_list[pos].used_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (slide_cnt > 0)
  SET loop_cnt = ceil((cnvtreal(slide_cnt)/ batch_size))
  SET start_pos = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    storage_content sc,
    storage_content_event sce
   PLAN (d
    WHERE initarray(start_pos,evaluate(d.seq,1,1,(start_pos+ batch_size))))
    JOIN (sc
    WHERE expand(idx,start_pos,minval(slide_cnt,(start_pos+ (batch_size - 1))),sc.content_table_id,
     temp->slide_list[idx].content_table_id,
     sc.content_table_name,"SLIDE"))
    JOIN (sce
    WHERE sce.storage_content_id=sc.storage_content_id
     AND sce.storage_content_event_id > 0
     AND sce.action_cd != mismatch_event_cd)
   DETAIL
    pos = locateval(idx,1,slide_cnt,sc.content_table_id,temp->slide_list[idx].content_table_id)
    IF (pos > 0)
     temp->slide_list[pos].used_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (slide_cnt > 0)
  SET loop_cnt = ceil((cnvtreal(slide_cnt)/ batch_size))
  SET start_pos = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    processing_task pt,
    ap_task_assay_addl ataa
   PLAN (d
    WHERE initarray(start_pos,evaluate(d.seq,1,1,(start_pos+ batch_size))))
    JOIN (pt
    WHERE expand(idx,start_pos,minval(slide_cnt,(start_pos+ (batch_size - 1))),pt.slide_id,temp->
     slide_list[idx].content_table_id,
     0,temp->slide_list[idx].used_ind))
    JOIN (ataa
    WHERE ataa.task_assay_cd=pt.task_assay_cd
     AND ataa.task_assay_cd > 0
     AND ataa.print_label_ind=1)
   ORDER BY pt.slide_id, pt.request_dt_tm DESC, pt.processing_task_id DESC
   HEAD pt.slide_id
    pos = locateval(idx,1,slide_cnt,pt.slide_id,temp->slide_list[idx].content_table_id)
    IF (pos > 0)
     temp->slide_list[pos].last_print_task_id = pt.processing_task_id, temp->slide_list[pos].
     last_print_task_disp = uar_get_code_display(pt.task_assay_cd)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET cnt = 0
 IF (cassette_cnt > 0)
  SELECT INTO "nl:"
   tag_seq = temp->cassette_list[d.seq].inventory_tag_seq
   FROM (dummyt d  WITH seq = value(cassette_cnt))
   PLAN (d)
   ORDER BY tag_seq
   DETAIL
    IF ((temp->cassette_list[d.seq].used_ind=0))
     cnt = (cnt+ 1)
     IF (cnt > size(reply->list,5))
      stat = alterlist(reply->list,(cnt+ 9))
     ENDIF
     reply->list[cnt].content_table_name = cassette_table_name, reply->list[cnt].content_table_id =
     temp->cassette_list[d.seq].content_table_id, reply->list[cnt].inventory_task_id = temp->
     cassette_list[d.seq].inventory_task_id,
     reply->list[cnt].last_print_task_id = temp->cassette_list[d.seq].inventory_task_id, reply->list[
     cnt].last_print_task_disp = temp->cassette_list[d.seq].inventory_task_disp, reply->list[cnt].
     inventory_task_disp = temp->cassette_list[d.seq].inventory_task_disp,
     reply->list[cnt].inventory_tag_disp = temp->cassette_list[d.seq].inventory_tag_disp
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->list,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (slide_cnt > 0)
  SELECT INTO "nl:"
   tag_seq = temp->slide_list[d.seq].inventory_tag_seq
   FROM (dummyt d  WITH seq = value(slide_cnt))
   PLAN (d)
   ORDER BY tag_seq
   DETAIL
    IF ((temp->slide_list[d.seq].used_ind=0))
     cnt = (cnt+ 1)
     IF (cnt > size(reply->list,5))
      stat = alterlist(reply->list,(cnt+ 9))
     ENDIF
     reply->list[cnt].content_table_name = slide_table_name, reply->list[cnt].content_table_id = temp
     ->slide_list[d.seq].content_table_id, reply->list[cnt].inventory_task_id = temp->slide_list[d
     .seq].inventory_task_id,
     reply->list[cnt].last_print_task_id = temp->slide_list[d.seq].last_print_task_id, reply->list[
     cnt].last_print_task_disp = temp->slide_list[d.seq].last_print_task_disp, reply->list[cnt].
     inventory_task_disp = temp->slide_list[d.seq].inventory_task_disp,
     reply->list[cnt].inventory_tag_disp = temp->slide_list[d.seq].inventory_tag_disp
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->list,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE RECORD temp
END GO
