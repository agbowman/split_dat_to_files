CREATE PROGRAM dcp_upd_pw_processing_status:dba
 SET modify = predeclare
 RECORD reply(
   1 phases[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 processing_status_flag = i2
     2 com_pointer = i4
     2 acquired_lock_ind = i2
     2 lock_failed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE n_processing_status_unknown = i2 WITH protect, constant(0)
 DECLARE n_processing_status_processing = i2 WITH protect, constant(1)
 DECLARE n_processing_status_failed_in_processing = i2 WITH protect, constant(2)
 DECLARE n_processing_status_not_processing = i2 WITH protect, constant(3)
 DECLARE getpwprocessingstatus(updatecount=i4,processingupdatecount=i4,processingdttm=dq8,
  staleinminutes=i4) = i2
 SUBROUTINE getpwprocessingstatus(updatecount,processingupdatecount,processingdttm,staleinminutes)
   DECLARE expiredttm = dq8 WITH private
   SET expiredttm = cnvtlookahead(build('"',staleinminutes,',MIN"'),cnvtdatetime(processingdttm))
   IF (expiredttm > cnvtdatetime(curdate,curtime3))
    IF (updatecount < processingupdatecount)
     RETURN(n_processing_status_processing)
    ELSE
     RETURN(n_processing_status_not_processing)
    ENDIF
   ELSE
    IF (updatecount >= processingupdatecount)
     RETURN(n_processing_status_not_processing)
    ELSE
     RETURN(n_processing_status_failed_in_processing)
    ENDIF
   ENDIF
 END ;Subroutine
 FREE RECORD internal
 RECORD internal(
   1 processing_index = i4
   1 processing_count = i4
   1 processing_loop_count = i4
   1 processing_list[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 encounter_id = f8
     2 pathway_catalog_id = f8
     2 com_pointer = i4
     2 processing_status_flag = i2
     2 request_ind = i2
     2 request_update_count = i4
     2 pw_processing_action_ind = i2
     2 processing_start_dt_tm = dq8
     2 processing_update_count = i4
     2 pathway_ind = i2
     2 pathway_update_count = i4
     2 workflow_blob = gvc
     2 workflow_blob_id = f8
     2 lock_all_related_phases_ind = i2
 )
 FREE RECORD new_phases
 RECORD new_phases(
   1 phases_index = i4
   1 phases_count = i4
   1 phases[*]
     2 new_phases_to_lock_index = i4
     2 reply_index = i4
 )
 FREE RECORD new_phases_to_lock
 RECORD new_phases_to_lock(
   1 phases_index = i4
   1 phases_count = i4
   1 phases_loop_count = i4
   1 phases[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 encounter_id = f8
     2 pathway_catalog_id = f8
     2 update_count = i4
     2 reply_index = i4
     2 workflow_blob = gvc
 )
 FREE RECORD phases_to_lock
 RECORD phases_to_lock(
   1 phases_index = i4
   1 phases_count = i4
   1 phases_loop_count = i4
   1 phases[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 encounter_id = f8
     2 pathway_catalog_id = f8
     2 update_count = i4
     2 reply_index = i4
     2 workflow_blob = gvc
     2 workflow_blob_id = f8
 )
 DECLARE s_script_name = vc WITH protect, constant("dcp_upd_pw_processing_status")
 DECLARE l_list_count = i4 WITH protect, constant(value(size(request->phases,5)))
 DECLARE d_person_id = f8 WITH protect, constant(request->person_id)
 DECLARE l_stale_in_minutes = i4 WITH protect, constant(evaluate(value(request->stale_in_minutes),0,
   10,value(request->stale_in_minutes)))
 DECLARE laquiredlockindex = i4 WITH protect, noconstant(0)
 DECLARE laquiredlockcount = i4 WITH protect, noconstant(0)
 DECLARE lreplyindex = i4 WITH protect, noconstant(0)
 DECLARE lreplycount = i4 WITH protect, noconstant(0)
 DECLARE workflow_blob_id = f8 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE relatedidx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 DECLARE insert_workflow_blob(blobworkflowxml=gvc,dpathwayid=f8) = f8
 DECLARE update_workflow_blob(blobworkflowxml=gvc,dworkflowblobid=f8,dpathwayid=f8) = f8
 SET reply->status_data.status = "S"
 IF (l_list_count < 1)
  CALL set_script_status("F","BEGIN","F",s_script_name,"The pathway list was empty.")
  GO TO exit_script
 ENDIF
 IF (d_person_id <= 0.0)
  CALL set_script_status("F","BEGIN","F",s_script_name,"The person id was invalid.")
  GO TO exit_script
 ENDIF
 SET internal->processing_index = l_list_count
 SET internal->processing_loop_count = ceil((cnvtreal(l_list_count)/ cnvtreal(20.0)))
 SET internal->processing_count = (internal->processing_loop_count * 20)
 SET stat = alterlist(internal->processing_list,internal->processing_count)
 FOR (idx = 1 TO l_list_count)
   SET internal->processing_list[idx].pw_group_nbr = request->phases[idx].pw_group_nbr
   SET internal->processing_list[idx].pathway_id = request->phases[idx].pathway_id
   SET internal->processing_list[idx].encounter_id = request->phases[idx].encounter_id
   SET internal->processing_list[idx].pathway_catalog_id = request->phases[idx].pathway_catalog_id
   SET internal->processing_list[idx].com_pointer = request->phases[idx].com_pointer
   SET internal->processing_list[idx].processing_status_flag = n_processing_status_unknown
   SET internal->processing_list[idx].request_ind = 1
   SET internal->processing_list[idx].request_update_count = request->phases[idx].update_count
   SET internal->processing_list[idx].pw_processing_action_ind = 0
   SET internal->processing_list[idx].processing_update_count = 0
   SET internal->processing_list[idx].pathway_ind = 0
   SET internal->processing_list[idx].pathway_update_count = 0
   SET internal->processing_list[idx].workflow_blob = request->phases[idx].workflow_blob
   SET internal->processing_list[idx].workflow_blob_id = 0
   SET internal->processing_list[idx].lock_all_related_phases_ind = validate(request->phases[idx].
    lock_all_related_phases_ind,0)
 ENDFOR
 FOR (idx = (internal->processing_index+ 1) TO internal->processing_count)
   SET internal->processing_list[idx].pathway_id = internal->processing_list[internal->
   processing_index].pathway_id
 ENDFOR
 SELECT INTO "nl:"
  FROM pw_processing_action ppa
  PLAN (ppa
   WHERE ppa.person_id=d_person_id)
  HEAD REPORT
   idx = 0
  DETAIL
   idx = locateval(idx,1,internal->processing_index,ppa.pathway_id,internal->processing_list[idx].
    pathway_id)
   IF (idx <= 0)
    internal->processing_index = (internal->processing_index+ 1)
    IF ((internal->processing_index > internal->processing_count))
     internal->processing_count = (internal->processing_count+ 20), internal->processing_loop_count
      = (internal->processing_loop_count+ 1), stat = alterlist(internal->processing_list,internal->
      processing_count)
    ENDIF
    idx = internal->processing_index, internal->processing_list[idx].pw_group_nbr = ppa.pw_group_nbr,
    internal->processing_list[idx].pathway_id = ppa.pathway_id,
    internal->processing_list[idx].encounter_id = ppa.encntr_id, internal->processing_list[idx].
    pathway_catalog_id = ppa.pathway_catalog_id, internal->processing_list[idx].com_pointer = 0,
    internal->processing_list[idx].processing_status_flag = n_processing_status_unknown
   ENDIF
   internal->processing_list[idx].pw_processing_action_ind = 1, internal->processing_list[idx].
   processing_update_count = ppa.processing_updt_cnt, internal->processing_list[idx].
   processing_start_dt_tm = cnvtdatetime(ppa.processing_start_dt_tm),
   internal->processing_list[idx].workflow_blob_id = ppa.workflow_blob_id
  FOOT REPORT
   FOR (idx = (internal->processing_index+ 1) TO internal->processing_count)
     internal->processing_list[idx].pathway_id = internal->processing_list[internal->processing_index
     ].pathway_id
   ENDFOR
  WITH nocounter
 ;end select
 SET lstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(internal->processing_loop_count)),
   pathway pw
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ 20))))
   JOIN (pw
   WHERE pw.pathway_id > 0.0
    AND expand(idx,lstart,(lstart+ 19),pw.pathway_id,internal->processing_list[idx].pathway_id))
  HEAD REPORT
   idx = 0
  DETAIL
   idx = locateval(idx,1,internal->processing_index,pw.pathway_id,internal->processing_list[idx].
    pathway_id)
   IF (idx > 0)
    internal->processing_list[idx].pathway_ind = 1, internal->processing_list[idx].
    pathway_update_count = pw.updt_cnt
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 FOR (idx = 1 TO internal->processing_index)
   IF ((((internal->processing_list[idx].request_ind=0)) OR ((internal->processing_list[idx].
   pathway_id > 0.0))) )
    SET internal->processing_list[idx].com_pointer = 0
   ENDIF
   IF ((internal->processing_list[idx].pathway_ind=0))
    SET internal->processing_list[idx].pathway_update_count = - (1)
   ENDIF
   IF ( NOT ((internal->processing_list[idx].processing_status_flag IN (
   n_processing_status_processing, n_processing_status_failed_in_processing))))
    IF ((internal->processing_list[idx].pw_processing_action_ind=1))
     SET internal->processing_list[idx].processing_status_flag = getpwprocessingstatus(internal->
      processing_list[idx].pathway_update_count,internal->processing_list[idx].
      processing_update_count,cnvtdatetime(internal->processing_list[idx].processing_start_dt_tm),
      l_stale_in_minutes)
    ENDIF
    IF ((internal->processing_list[idx].pathway_ind=1)
     AND (internal->processing_list[idx].request_ind=1))
     IF ((internal->processing_list[idx].pathway_update_count > internal->processing_list[idx].
     request_update_count))
      SET internal->processing_list[idx].processing_status_flag = n_processing_status_processing
     ELSEIF ((internal->processing_list[idx].processing_status_flag=n_processing_status_unknown))
      SET internal->processing_list[idx].processing_status_flag = n_processing_status_not_processing
     ENDIF
    ENDIF
    IF ((internal->processing_list[idx].pathway_ind=0)
     AND (internal->processing_list[idx].request_ind=1))
     SET internal->processing_list[idx].processing_status_flag = n_processing_status_not_processing
    ENDIF
   ENDIF
   IF ((internal->processing_list[idx].lock_all_related_phases_ind=1))
    IF ((internal->processing_list[idx].processing_status_flag IN (n_processing_status_processing,
    n_processing_status_failed_in_processing)))
     FOR (relatedidx = 1 TO internal->processing_index)
       IF ((internal->processing_list[idx].pw_group_nbr=internal->processing_list[relatedidx].
       pw_group_nbr))
        IF ((internal->processing_list[relatedidx].processing_status_flag !=
        n_processing_status_failed_in_processing))
         SET internal->processing_list[relatedidx].processing_status_flag =
         n_processing_status_processing
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 FOR (idx = 1 TO internal->processing_index)
  IF ((((internal->processing_list[idx].request_ind=1)) OR ((internal->processing_list[idx].
  processing_status_flag IN (n_processing_status_processing, n_processing_status_failed_in_processing
  )))) )
   SET lreplyindex = (lreplyindex+ 1)
   IF (lreplyindex > lreplycount)
    SET lreplycount = (lreplycount+ 20)
    SET stat = alterlist(reply->phases,lreplycount)
   ENDIF
   SET reply->phases[lreplyindex].pathway_id = internal->processing_list[idx].pathway_id
   SET reply->phases[lreplyindex].pw_group_nbr = internal->processing_list[idx].pw_group_nbr
   SET reply->phases[lreplyindex].com_pointer = internal->processing_list[idx].com_pointer
   SET reply->phases[lreplyindex].processing_status_flag = internal->processing_list[idx].
   processing_status_flag
  ENDIF
  IF ((internal->processing_list[idx].request_ind=1))
   IF ((internal->processing_list[idx].pathway_ind=0))
    SET internal->processing_list[idx].request_update_count = - (1)
   ENDIF
   IF ((internal->processing_list[idx].processing_status_flag IN (n_processing_status_processing,
   n_processing_status_failed_in_processing)))
    SET reply->phases[lreplyindex].lock_failed_ind = 1
   ELSE
    IF ((internal->processing_list[idx].pw_processing_action_ind=0))
     SET new_phases_to_lock->phases_index = (new_phases_to_lock->phases_index+ 1)
     IF ((new_phases_to_lock->phases_index > new_phases_to_lock->phases_count))
      SET new_phases_to_lock->phases_count = (new_phases_to_lock->phases_count+ 20)
      SET new_phases_to_lock->phases_loop_count = (new_phases_to_lock->phases_loop_count+ 1)
      SET stat = alterlist(new_phases_to_lock->phases,new_phases_to_lock->phases_count)
     ENDIF
     SET new_phases_to_lock->phases[new_phases_to_lock->phases_index].encounter_id = internal->
     processing_list[idx].encounter_id
     SET new_phases_to_lock->phases[new_phases_to_lock->phases_index].pathway_catalog_id = internal->
     processing_list[idx].pathway_catalog_id
     SET new_phases_to_lock->phases[new_phases_to_lock->phases_index].pathway_id = internal->
     processing_list[idx].pathway_id
     SET new_phases_to_lock->phases[new_phases_to_lock->phases_index].pw_group_nbr = internal->
     processing_list[idx].pw_group_nbr
     SET new_phases_to_lock->phases[new_phases_to_lock->phases_index].update_count = internal->
     processing_list[idx].request_update_count
     SET new_phases_to_lock->phases[new_phases_to_lock->phases_index].reply_index = lreplyindex
     SET new_phases_to_lock->phases[new_phases_to_lock->phases_index].workflow_blob = internal->
     processing_list[idx].workflow_blob
     IF ((internal->processing_list[idx].pathway_id <= 0.0))
      SET new_phases->phases_index = (new_phases->phases_index+ 1)
      IF ((new_phases->phases_index > new_phases->phases_count))
       SET new_phases->phases_count = (new_phases->phases_count+ 20)
       SET stat = alterlist(new_phases->phases,new_phases->phases_count)
      ENDIF
      SET new_phases->phases[new_phases->phases_index].new_phases_to_lock_index = new_phases_to_lock
      ->phases_index
      SET new_phases->phases[new_phases->phases_index].reply_index = lreplyindex
     ENDIF
     SET reply->phases[lreplyindex].acquired_lock_ind = 1
    ELSE
     SET phases_to_lock->phases_index = (phases_to_lock->phases_index+ 1)
     IF ((phases_to_lock->phases_index > phases_to_lock->phases_count))
      SET phases_to_lock->phases_count = (phases_to_lock->phases_count+ 20)
      SET phases_to_lock->phases_loop_count = (phases_to_lock->phases_loop_count+ 1)
      SET stat = alterlist(phases_to_lock->phases,phases_to_lock->phases_count)
     ENDIF
     SET phases_to_lock->phases[phases_to_lock->phases_index].encounter_id = internal->
     processing_list[idx].encounter_id
     SET phases_to_lock->phases[phases_to_lock->phases_index].pathway_catalog_id = internal->
     processing_list[idx].pathway_catalog_id
     SET phases_to_lock->phases[phases_to_lock->phases_index].pathway_id = internal->processing_list[
     idx].pathway_id
     SET phases_to_lock->phases[phases_to_lock->phases_index].pw_group_nbr = internal->
     processing_list[idx].pw_group_nbr
     SET phases_to_lock->phases[phases_to_lock->phases_index].update_count = internal->
     processing_list[idx].request_update_count
     SET phases_to_lock->phases[phases_to_lock->phases_index].reply_index = lreplyindex
     SET phases_to_lock->phases[phases_to_lock->phases_index].workflow_blob = internal->
     processing_list[idx].workflow_blob
     SET phases_to_lock->phases[phases_to_lock->phases_index].workflow_blob_id = internal->
     processing_list[idx].workflow_blob_id
     SET reply->phases[lreplyindex].acquired_lock_ind = 1
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 IF (lreplyindex > 0
  AND lreplyindex < lreplycount)
  SET stat = alterlist(reply->phases,lreplyindex)
 ENDIF
 IF ((new_phases->phases_index > 0))
  SET stat = alterlist(new_phases->phases,new_phases->phases_index)
  SELECT INTO "nl:"
   new_pathway_id = seq(carenet_seq,nextval)
   FROM (dummyt d  WITH seq = value(new_phases->phases_index)),
    dual d2
   PLAN (d)
    JOIN (d2)
   DETAIL
    idx = new_phases->phases[d.seq].new_phases_to_lock_index
    IF (idx > 0)
     new_phases_to_lock->phases[idx].pathway_id = new_pathway_id
    ENDIF
    idx = new_phases->phases[d.seq].reply_index
    IF (idx > 0)
     reply->phases[idx].pathway_id = new_pathway_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(request->skip_lock_ind,0)=0)
  FOR (idx = 1 TO phases_to_lock->phases_index)
   SELECT INTO "nl:"
    FROM pw_processing_action ppa
    PLAN (ppa
     WHERE (ppa.pathway_id=phases_to_lock->phases[idx].pathway_id))
    WITH forupdate(ppa), nocounter
   ;end select
   IF (curqual <= 0)
    IF ((phases_to_lock->phases[idx].reply_index > 0))
     SET reply->phases[phases_to_lock->phases[idx].reply_index].acquired_lock_ind = 0
     SET reply->phases[phases_to_lock->phases[idx].reply_index].lock_failed_ind = 1
    ENDIF
   ELSE
    SET workflow_blob_id = update_workflow_blob(phases_to_lock->phases[idx].workflow_blob,
     phases_to_lock->phases[idx].workflow_blob_id,phases_to_lock->phases[idx].pathway_id)
    UPDATE  FROM pw_processing_action ppa
     SET ppa.encntr_id = phases_to_lock->phases[idx].encounter_id, ppa.processing_start_dt_tm =
      cnvtdatetime(curdate,curtime3), ppa.processing_updt_cnt = (phases_to_lock->phases[idx].
      update_count+ 1),
      ppa.workflow_blob_id = workflow_blob_id, ppa.updt_dt_tm = cnvtdatetime(curdate,curtime3), ppa
      .updt_id = reqinfo->updt_id,
      ppa.updt_task = reqinfo->updt_task, ppa.updt_cnt = (ppa.updt_cnt+ 1), ppa.updt_applctx =
      reqinfo->updt_applctx
     PLAN (ppa
      WHERE (ppa.pathway_id=phases_to_lock->phases[idx].pathway_id))
     WITH nocounter
    ;end update
    IF (curqual <= 0)
     IF ((phases_to_lock->phases[idx].reply_index > 0))
      SET reply->phases[phases_to_lock->phases[idx].reply_index].acquired_lock_ind = 0
      SET reply->phases[phases_to_lock->phases[idx].reply_index].lock_failed_ind = 1
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
  FOR (idx = 1 TO new_phases_to_lock->phases_index)
    IF ((new_phases_to_lock->phases[idx].pathway_id > 0.0))
     SET workflow_blob_id = insert_workflow_blob(new_phases_to_lock->phases[idx].workflow_blob,
      new_phases_to_lock->phases[idx].pathway_id)
     INSERT  FROM pw_processing_action ppa
      SET ppa.encntr_id = new_phases_to_lock->phases[idx].encounter_id, ppa.pathway_catalog_id =
       new_phases_to_lock->phases[idx].pathway_catalog_id, ppa.pathway_id = new_phases_to_lock->
       phases[idx].pathway_id,
       ppa.person_id = d_person_id, ppa.processing_start_dt_tm = cnvtdatetime(curdate,curtime3), ppa
       .processing_updt_cnt = (new_phases_to_lock->phases[idx].update_count+ 1),
       ppa.pw_group_nbr = new_phases_to_lock->phases[idx].pw_group_nbr, ppa.workflow_blob_id =
       workflow_blob_id, ppa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ppa.updt_id = reqinfo->updt_id, ppa.updt_task = reqinfo->updt_task, ppa.updt_cnt = 0,
       ppa.updt_applctx = reqinfo->updt_applctx
      PLAN (ppa
       WHERE (ppa.pathway_id=new_phases_to_lock->phases[idx].pathway_id))
      WITH nocounter
     ;end insert
     IF (curqual <= 0)
      IF ((new_phases_to_lock->phases[idx].reply_index > 0))
       SET reply->phases[new_phases_to_lock->phases[idx].reply_index].acquired_lock_ind = 0
       SET reply->phases[new_phases_to_lock->phases[idx].reply_index].lock_failed_ind = 1
      ENDIF
     ENDIF
    ELSE
     IF ((new_phases_to_lock->phases[idx].reply_index > 0))
      SET reply->phases[new_phases_to_lock->phases[idx].reply_index].acquired_lock_ind = 0
      SET reply->phases[new_phases_to_lock->phases[idx].reply_index].lock_failed_ind = 1
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   SET reply->status_data.status = cstatus
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
 SUBROUTINE insert_workflow_blob(blobworkflowxml,dpathwayid)
   SET blobworkflowxml = trim(blobworkflowxml)
   IF (textlen(blobworkflowxml) > 0)
    SELECT INTO "nl:"
     seqid = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      workflow_blob_id = cnvtreal(seqid)
     WITH nocounter
    ;end select
    INSERT  FROM long_blob lb
     SET lb.long_blob_id = workflow_blob_id, lb.long_blob = blobworkflowxml, lb.parent_entity_name =
      "PW_PROCESSING_ACTION",
      lb.parent_entity_id = dpathwayid, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id =
      reqinfo->updt_id,
      lb.updt_task = reqinfo->updt_task, lb.updt_cnt = 0, lb.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    RETURN(workflow_blob_id)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE update_workflow_blob(blobworkflowxml,dworkflowblobid,dpathwayid)
   SET blobworkflowxml = trim(blobworkflowxml)
   IF (textlen(blobworkflowxml) > 0)
    IF (dworkflowblobid=0.0)
     RETURN(insert_workflow_blob(blobworkflowxml,dpathwayid))
    ELSE
     UPDATE  FROM long_blob lb
      SET lb.long_blob = blobworkflowxml, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id
        = reqinfo->updt_id,
       lb.updt_task = reqinfo->updt_task, lb.updt_cnt = (lb.updt_cnt+ 1), lb.updt_applctx = reqinfo->
       updt_applctx
      PLAN (lb
       WHERE lb.long_blob_id=dworkflowblobid)
      WITH nocounter
     ;end update
     RETURN(dworkflowblobid)
    ENDIF
   ENDIF
   RETURN(dworkflowblobid)
 END ;Subroutine
#exit_script
 FREE RECORD internal
 FREE RECORD new_phases
 FREE RECORD new_phases_to_lock
 FREE RECORD phases_to_lock
 IF ((reply->status_data.status="F"))
  SET stat = alterlist(reply->phases,0)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 DECLARE last_mod = vc WITH protect, constant("002 04/10/2014")
END GO
