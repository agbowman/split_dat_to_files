CREATE PROGRAM dm_estimate_object_space:dba
 SET eos_reply->obj_cnt = 0
 SET stat = alterlist(eos_reply->obj,0)
 SET eos_reply->tsp_cnt = 0
 SET stat = alterlist(eos_reply->tsp,0)
 IF (size(eos_request->obj,5)=0)
  SET eos_reply->err_ind = 1
  SET eos_reply->err_msg = "The request structure was not populated correctly"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(eos_request->obj,5))),
   dba_segments s
  PLAN (d)
   JOIN (s
   WHERE s.owner=cnvtupper(eos_request->obj[d.seq].owner)
    AND s.segment_type=cnvtupper(eos_request->obj[d.seq].obj_type)
    AND ((s.segment_name=cnvtupper(eos_request->obj[d.seq].obj_name)) OR (s.segment_name=cnvtupper(
    concat(substring(1,28,eos_request->obj[d.seq].obj_name),"$C")))) )
  DETAIL
   eos_reply->obj_cnt = (eos_reply->obj_cnt+ 1), stat = alterlist(eos_reply->obj,eos_reply->obj_cnt),
   eos_reply->obj[eos_reply->obj_cnt].owner = s.owner,
   eos_reply->obj[eos_reply->obj_cnt].obj_name = s.segment_name, eos_reply->obj[eos_reply->obj_cnt].
   obj_type = s.segment_type, eos_reply->obj[eos_reply->obj_cnt].tspace_name = s.tablespace_name,
   eos_reply->obj[eos_reply->obj_cnt].next_extent = s.next_extent, eos_reply->obj[eos_reply->obj_cnt]
   .cur_extents = s.extents, eos_reply->obj[eos_reply->obj_cnt].max_extents = s.max_extents,
   eos_reply->obj[eos_reply->obj_cnt].need_extent = 0, eos_reply->obj[eos_reply->obj_cnt].size = (
   eos_request->obj[d.seq].row_length * eos_request->obj[d.seq].rows_to_add), fnd_ti = 0
   FOR (ti = 1 TO eos_reply->tsp_cnt)
     IF ((s.tablespace_name=eos_reply->tsp[ti].tsp_name))
      fnd_ti = ti
     ENDIF
   ENDFOR
   IF (fnd_ti=0)
    eos_reply->tsp_cnt = (eos_reply->tsp_cnt+ 1), stat = alterlist(eos_reply->tsp,eos_reply->tsp_cnt),
    eos_reply->tsp[eos_reply->tsp_cnt].tsp_name = s.tablespace_name,
    eos_reply->tsp[eos_reply->tsp_cnt].free_space = 0.0, eos_reply->tsp[eos_reply->tsp_cnt].
    need_space = 0.0, eos_reply->tsp[eos_reply->tsp_cnt].max_extent = 0.0
   ELSE
    IF ((s.next_extent > eos_reply->tsp[fnd_ti].max_extent))
     eos_reply->tsp[fnd_ti].max_extent = s.next_extent
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (value(eos_reply->tsp_cnt)=0)) )
  SET eos_reply->err_ind = 1
  SET eos_reply->err_msg = "Could not find segment information based on passed in parameters"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dba_free_space d,
   (dummyt t  WITH seq = value(eos_reply->tsp_cnt))
  PLAN (t)
   JOIN (d
   WHERE (d.tablespace_name=eos_reply->tsp[t.seq].tsp_name))
  DETAIL
   IF ((d.bytes > eos_reply->tsp[t.seq].max_extent))
    eos_reply->tsp[t.seq].free_space = (eos_reply->tsp[t.seq].free_space+ d.bytes)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET eos_reply->err_ind = 1
  SET eos_reply->err_msg = "Could not find space information"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(eos_reply->obj_cnt)),
   (dummyt t  WITH seq = value(eos_reply->tsp_cnt))
  PLAN (d)
   JOIN (t
   WHERE (eos_reply->tsp[t.seq].tsp_name=eos_reply->obj[d.seq].tspace_name))
  DETAIL
   IF ((eos_reply->obj[d.seq].size > eos_reply->tsp[t.seq].free_space))
    eos_reply->tsp[t.seq].need_space = (eos_reply->tsp[t.seq].need_space+ eos_reply->obj[d.seq].size)
   ELSE
    eos_reply->tsp[t.seq].free_space = (eos_reply->tsp[t.seq].free_space - eos_reply->obj[d.seq].size
    )
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(eos_reply->obj_cnt))
  PLAN (d
   WHERE (eos_reply->obj[d.seq].next_extent > 0))
  DETAIL
   IF (((ceil((eos_reply->obj[d.seq].size/ eos_reply->obj[d.seq].next_extent))+ eos_reply->obj[d.seq]
   .cur_extents) > eos_reply->obj[d.seq].max_extents))
    eos_reply->obj[d.seq].need_extent = (ceil((eos_reply->obj[d.seq].size/ eos_reply->obj[d.seq].
     next_extent))+ eos_reply->obj[d.seq].cur_extents)
   ENDIF
  WITH nocounter
 ;end select
#exit_program
END GO
