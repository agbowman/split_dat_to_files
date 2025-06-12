CREATE PROGRAM aps_upd_task_protocol_reltn:dba
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD tempadd(
   1 assignment_list[*]
     2 object_key = i4
     2 action_flag = i2
     2 proc_instr_prot_id = f8
     2 catalog_cd = f8
     2 instrument_protocol_id = f8
     2 task_assay_cd = f8
 )
 RECORD reply(
   1 assignment_list[*]
     2 object_key = i4
     2 proc_instr_prot_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE current_dt_tm_hold = q8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE nnone_action = i2 WITH protect, constant(0)
 DECLARE nadd_action = i2 WITH protect, constant(1)
 DECLARE nupdate_action = i2 WITH protect, constant(2)
 DECLARE ndelete_action = i2 WITH protect, constant(3)
 DECLARE lnbrassignment = i4 WITH protect, noconstant(0)
 DECLARE ccclerror = vc WITH protect, noconstant(" ")
 DECLARE lsub = i4 WITH protect, noconstant(1)
 DECLARE ltempaddcount = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET lnbrassignment = size(request->assignment_list,5)
 IF (lnbrassignment=0)
  CALL subevent_add(build("Set number of assignments"),"F",build("lNbrAssignment"),
   "lNbrAssignment is zero")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lnbrassignment),
   proc_instrmt_protcl_r pipr,
   profile_task_r ptr
  PLAN (d)
   JOIN (ptr
   WHERE (ptr.task_assay_cd=request->assignment_list[d.seq].task_assay_cd)
    AND cnvtdatetime(current_dt_tm_hold) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
    AND ptr.active_ind=1)
   JOIN (pipr
   WHERE (request->assignment_list[d.seq].action_flag=nadd_action)
    AND (pipr.instrument_protocol_id=request->assignment_list[d.seq].instrument_protocol_id)
    AND pipr.catalog_cd=ptr.catalog_cd)
  DETAIL
   request->assignment_list[d.seq].action_flag = nnone_action
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lnbrassignment)
  PLAN (d
   WHERE (request->assignment_list[d.seq].action_flag=nadd_action))
  DETAIL
   ltempaddcount = (ltempaddcount+ 1)
   IF (ltempaddcount > size(tempadd->assignment_list,5))
    stat = alterlist(tempadd->assignment_list,(ltempaddcount+ 9))
   ENDIF
   tempadd->assignment_list[ltempaddcount].object_key = request->assignment_list[d.seq].object_key,
   tempadd->assignment_list[ltempaddcount].action_flag = request->assignment_list[d.seq].action_flag,
   tempadd->assignment_list[ltempaddcount].instrument_protocol_id = request->assignment_list[d.seq].
   instrument_protocol_id,
   tempadd->assignment_list[ltempaddcount].task_assay_cd = request->assignment_list[d.seq].
   task_assay_cd
  FOOT REPORT
   stat = alterlist(tempadd->assignment_list,ltempaddcount)
  WITH nocounter
 ;end select
 IF (ltempaddcount > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ltempaddcount),
    profile_task_r ptr
   PLAN (d)
    JOIN (ptr
    WHERE (ptr.task_assay_cd=tempadd->assignment_list[d.seq].task_assay_cd)
     AND cnvtdatetime(current_dt_tm_hold) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
     AND ptr.active_ind=1)
   DETAIL
    tempadd->assignment_list[d.seq].catalog_cd = ptr.catalog_cd
   WITH nocounter
  ;end select
  EXECUTE dm2_dar_get_bulk_seq "TempAdd->assignment_list", ltempaddcount, "proc_instr_prot_id",
  1, "pathnet_seq"
  IF ((m_dm2_seq_stat->n_status != 1))
   CALL subevent_add(build("Bulk seq script call"),"F",build("dm2_dar_get_bulk_seq"),m_dm2_seq_stat->
    s_error_msg)
   FREE SET m_dm2_seq_stat
   GO TO exit_script
  ENDIF
  FREE SET m_dm2_seq_stat
  INSERT  FROM (dummyt d  WITH seq = ltempaddcount),
    proc_instrmt_protcl_r pipr
   SET pipr.instrument_protocol_id = tempadd->assignment_list[d.seq].instrument_protocol_id, pipr
    .catalog_cd = tempadd->assignment_list[d.seq].catalog_cd, pipr.proc_instrmt_protcl_r_id = tempadd
    ->assignment_list[d.seq].proc_instr_prot_id,
    pipr.updt_id = reqinfo->updt_id, pipr.updt_task = reqinfo->updt_task, pipr.updt_applctx = reqinfo
    ->updt_applctx,
    pipr.updt_dt_tm = cnvtdatetime(curdate,curtime)
   PLAN (d)
    JOIN (pipr)
   WITH nocounter
  ;end insert
  IF (logcclerror("INSERT","PROC_INSTRMT_PROTCL_R")=0)
   GO TO exit_script
  ENDIF
  IF (curqual > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ltempaddcount)
    PLAN (d
     WHERE (tempadd->assignment_list[d.seq].action_flag=nadd_action))
    HEAD REPORT
     lreplycount = 0
    DETAIL
     lreplycount = (lreplycount+ 1)
     IF (lreplycount > size(reply->assignment_list,5))
      stat = alterlist(reply->assignment_list,(lreplycount+ 9))
     ENDIF
     reply->assignment_list[lreplycount].object_key = tempadd->assignment_list[d.seq].object_key,
     reply->assignment_list[lreplycount].proc_instr_prot_id = tempadd->assignment_list[d.seq].
     proc_instr_prot_id
    FOOT REPORT
     stat = alterlist(reply->assignment_list,lreplycount)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lnbrassignment),
   proc_instrmt_protcl_r pipr
  PLAN (d)
   JOIN (pipr
   WHERE (pipr.proc_instrmt_protcl_r_id=request->assignment_list[d.seq].proc_instr_prot_id)
    AND (ndelete_action=request->assignment_list[d.seq].action_flag))
  WITH nocounter, forupdate(pipr)
 ;end select
 IF (logcclerror("LOCK","PROC_INSTRMT_PROTCL_R")=0)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  FOR (lsub = 1 TO lnbrassignment)
    DELETE  FROM proc_instrmt_protcl_r pipr
     PLAN (pipr
      WHERE (pipr.proc_instrmt_protcl_r_id=request->assignment_list[lsub].proc_instr_prot_id)
       AND (ndelete_action=request->assignment_list[lsub].action_flag))
     WITH nocounter
    ;end delete
  ENDFOR
  IF (logcclerror("DELETE","PROC_INSTRMT_PROTCL_R")=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE logcclerror(soperation,stablename)
  IF (error(ccclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),ccclerror)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
END GO
