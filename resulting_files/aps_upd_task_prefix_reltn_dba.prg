CREATE PROGRAM aps_upd_task_prefix_reltn:dba
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
   1 association_list[*]
     2 object_key = i4
     2 action_flag = i2
     2 ap_prefix_task_r_id = f8
     2 catalog_cd = f8
     2 prefix_id = f8
     2 task_assay_cd = f8
 )
 RECORD reply(
   1 association_list[*]
     2 object_key = i4
     2 ap_prefix_task_r_id = f8
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
 DECLARE current_dt_tm_hold = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE nnone_action = i2 WITH protect, constant(0)
 DECLARE nadd_action = i2 WITH protect, constant(1)
 DECLARE nupdate_action = i2 WITH protect, constant(2)
 DECLARE ndelete_action = i2 WITH protect, constant(4)
 DECLARE lnbrassociations = i4 WITH protect, noconstant(0)
 DECLARE ccclerror = vc WITH protect, noconstant(" ")
 DECLARE lsub = i4 WITH protect, noconstant(1)
 DECLARE ltempaddcount = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE lreplycount = i4 WITH protect, noconstant(0)
 DECLARE dtasktypecd = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SET lnbrassociations = size(request->association_list,5)
 IF (lnbrassociations=0)
  CALL subevent_add(build("Set number of associations"),"F",build("lNbrAssociations"),
   "lNbrAssociations is zero")
  GO TO exit_script
 ENDIF
 IF ((request->task_type_ind=0))
  SET stat = uar_get_meaning_by_codeset(5801,"APPROCESS",1,dtasktypecd)
 ELSEIF ((request->task_type_ind=1))
  SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,dtasktypecd)
 ENDIF
 IF (dtasktypecd=0.0)
  CALL subevent_add(build("Obtain task type code"),"F",build("dTaskTypeCd"),"dTaskTypeCd is zero")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lnbrassociations),
   ap_prefix_task_r a,
   profile_task_r ptr
  PLAN (d)
   JOIN (ptr
   WHERE (ptr.task_assay_cd=request->association_list[d.seq].task_assay_cd)
    AND cnvtdatetime(current_dt_tm_hold) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
    AND ptr.active_ind=1)
   JOIN (a
   WHERE (request->association_list[d.seq].action_flag=nadd_action)
    AND (a.prefix_id=request->association_list[d.seq].prefix_id)
    AND a.catalog_cd=ptr.catalog_cd)
  DETAIL
   request->association_list[d.seq].action_flag = nnone_action
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lnbrassociations)
  PLAN (d
   WHERE (request->association_list[d.seq].action_flag=nadd_action))
  DETAIL
   ltempaddcount = (ltempaddcount+ 1)
   IF (ltempaddcount > size(tempadd->association_list,5))
    stat = alterlist(tempadd->association_list,(ltempaddcount+ 9))
   ENDIF
   tempadd->association_list[ltempaddcount].object_key = request->association_list[d.seq].object_key,
   tempadd->association_list[ltempaddcount].action_flag = request->association_list[d.seq].
   action_flag, tempadd->association_list[ltempaddcount].prefix_id = request->association_list[d.seq]
   .prefix_id,
   tempadd->association_list[ltempaddcount].task_assay_cd = request->association_list[d.seq].
   task_assay_cd
  FOOT REPORT
   stat = alterlist(tempadd->association_list,ltempaddcount)
  WITH nocounter
 ;end select
 IF (ltempaddcount > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ltempaddcount),
    profile_task_r ptr,
    order_catalog oc
   PLAN (d)
    JOIN (ptr
    WHERE (ptr.task_assay_cd=tempadd->association_list[d.seq].task_assay_cd)
     AND cnvtdatetime(current_dt_tm_hold) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
     AND ptr.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ptr.catalog_cd
     AND oc.activity_subtype_cd=dtasktypecd
     AND oc.active_ind=1)
   DETAIL
    tempadd->association_list[d.seq].catalog_cd = ptr.catalog_cd
   WITH nocounter
  ;end select
  EXECUTE dm2_dar_get_bulk_seq "TempAdd->association_list", ltempaddcount, "ap_prefix_task_r_id",
  1, "reference_seq"
  IF ((m_dm2_seq_stat->n_status != 1))
   CALL subevent_add(build("Bulk seq script call"),"F",build("dm2_dar_get_bulk_seq"),m_dm2_seq_stat->
    s_error_msg)
   FREE SET m_dm2_seq_stat
   GO TO exit_script
  ENDIF
  FREE SET m_dm2_seq_stat
  INSERT  FROM (dummyt d  WITH seq = ltempaddcount),
    ap_prefix_task_r a
   SET a.prefix_id = tempadd->association_list[d.seq].prefix_id, a.catalog_cd = tempadd->
    association_list[d.seq].catalog_cd, a.ap_prefix_task_r_id = tempadd->association_list[d.seq].
    ap_prefix_task_r_id,
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime)
   PLAN (d)
    JOIN (a)
   WITH nocounter
  ;end insert
  IF (logcclerror("INSERT","AP_PREFIX_TASK_R")=0)
   GO TO exit_script
  ENDIF
  IF (curqual > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ltempaddcount)
    PLAN (d
     WHERE (tempadd->association_list[d.seq].action_flag=nadd_action))
    HEAD REPORT
     lreplycount = 0
    DETAIL
     lreplycount = (lreplycount+ 1)
     IF (lreplycount > size(reply->association_list,5))
      stat = alterlist(reply->association_list,(lreplycount+ 9))
     ENDIF
     reply->association_list[lreplycount].object_key = tempadd->association_list[d.seq].object_key,
     reply->association_list[lreplycount].ap_prefix_task_r_id = tempadd->association_list[d.seq].
     ap_prefix_task_r_id
    FOOT REPORT
     stat = alterlist(reply->association_list,lreplycount)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lnbrassociations),
   ap_prefix_task_r a
  PLAN (d)
   JOIN (a
   WHERE (a.ap_prefix_task_r_id=request->association_list[d.seq].ap_prefix_task_r_id)
    AND (ndelete_action=request->association_list[d.seq].action_flag))
  WITH nocounter, forupdate(pipr)
 ;end select
 IF (logcclerror("LOCK","AP_PREFIX_TASK_R")=0)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET lreplycount = size(reply->association_list,5)
  FOR (lsub = 1 TO lnbrassociations)
    DELETE  FROM ap_prefix_task_r a
     PLAN (a
      WHERE (a.ap_prefix_task_r_id=request->association_list[lsub].ap_prefix_task_r_id)
       AND (ndelete_action=request->association_list[lsub].action_flag))
     WITH nocounter
    ;end delete
    SET lreplycount = (lreplycount+ 1)
    IF (lreplycount > size(reply->association_list,5))
     SET stat = alterlist(reply->association_list,(lreplycount+ 9))
    ENDIF
    SET reply->association_list[lreplycount].object_key = request->association_list[lsub].object_key
    SET reply->association_list[lreplycount].ap_prefix_task_r_id = 0.0
  ENDFOR
  SET stat = alterlist(reply->association_list,lreplycount)
  IF (logcclerror("DELETE","AP_PREFIX_TASK_R")=0)
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
