CREATE PROGRAM aps_upd_proc_grp_prefix_reltn:dba
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
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
 RECORD reply(
   1 association_list[*]
     2 object_key = i4
     2 ap_prefix_proc_grp_r_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tempadd(
   1 association_list[*]
     2 object_key = i4
     2 action_flag = i2
     2 ap_prefix_proc_grp_r_id = f8
     2 processing_grp_cd = f8
     2 prefix_id = f8
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE nnone_action = i2 WITH protect, constant(0)
 DECLARE nadd_action = i2 WITH protect, constant(1)
 DECLARE nupdate_action = i2 WITH protect, constant(2)
 DECLARE ndelete_action = i2 WITH protect, constant(4)
 DECLARE lnbrassociations = i4 WITH protect, noconstant(0)
 DECLARE ccclerror = vc WITH protect, noconstant(" ")
 DECLARE ltempaddcount = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE lreplycount = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET lnbrassociations = size(request->association_list,5)
 IF (lnbrassociations=0)
  CALL subevent_add(build("Set number of associations"),"F",build("lNbrAssociations"),
   "lNbrAssociations is zero")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lnbrassociations),
   ap_prefix_proc_grp_r appg
  PLAN (d
   WHERE (request->association_list[d.seq].action_flag=nadd_action))
   JOIN (appg
   WHERE (appg.prefix_id=request->association_list[d.seq].prefix_id)
    AND (appg.processing_grp_cd=request->association_list[d.seq].processing_grp_cd))
  DETAIL
   request->association_list[d.seq].action_flag = nnone_action
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lnbrassociations)
  PLAN (d
   WHERE (request->association_list[d.seq].action_flag=nadd_action))
  DETAIL
   ltempaddcount += 1
   IF (ltempaddcount > size(tempadd->association_list,5))
    stat = alterlist(tempadd->association_list,(ltempaddcount+ 9))
   ENDIF
   tempadd->association_list[ltempaddcount].object_key = request->association_list[d.seq].object_key,
   tempadd->association_list[ltempaddcount].action_flag = request->association_list[d.seq].
   action_flag, tempadd->association_list[ltempaddcount].prefix_id = request->association_list[d.seq]
   .prefix_id,
   tempadd->association_list[ltempaddcount].processing_grp_cd = request->association_list[d.seq].
   processing_grp_cd
  FOOT REPORT
   stat = alterlist(tempadd->association_list,ltempaddcount)
  WITH nocounter
 ;end select
 IF (ltempaddcount > 0)
  EXECUTE dm2_dar_get_bulk_seq "TempAdd->association_list", ltempaddcount, "ap_prefix_proc_grp_r_id",
  1, "reference_seq"
  IF ((m_dm2_seq_stat->n_status != 1))
   CALL subevent_add(build("Bulk seq script call"),"F",build("dm2_dar_get_bulk_seq"),m_dm2_seq_stat->
    s_error_msg)
   FREE SET m_dm2_seq_stat
   GO TO exit_script
  ENDIF
  FREE SET m_dm2_seq_stat
  INSERT  FROM (dummyt d  WITH seq = ltempaddcount),
    ap_prefix_proc_grp_r appg
   SET appg.prefix_id = tempadd->association_list[d.seq].prefix_id, appg.ap_prefix_proc_grp_r_id =
    tempadd->association_list[d.seq].ap_prefix_proc_grp_r_id, appg.processing_grp_cd = tempadd->
    association_list[d.seq].processing_grp_cd,
    appg.updt_id = reqinfo->updt_id, appg.updt_task = reqinfo->updt_task, appg.updt_applctx = reqinfo
    ->updt_applctx,
    appg.updt_cnt = 1, appg.updt_dt_tm = cnvtdatetime(sysdate)
   PLAN (d)
    JOIN (appg)
   WITH nocounter
  ;end insert
  IF (logcclerror("INSERT","AP_PREFIX_PROC_GRP_R")=0)
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
     lreplycount += 1
     IF (lreplycount > size(reply->association_list,5))
      stat = alterlist(reply->association_list,(lreplycount+ 9))
     ENDIF
     reply->association_list[lreplycount].object_key = tempadd->association_list[d.seq].object_key,
     reply->association_list[lreplycount].ap_prefix_proc_grp_r_id = tempadd->association_list[d.seq].
     ap_prefix_proc_grp_r_id
    FOOT REPORT
     stat = alterlist(reply->association_list,lreplycount)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 FOR (lsub = 1 TO lnbrassociations)
  DELETE  FROM ap_prefix_proc_grp_r appg
   PLAN (appg
    WHERE (appg.ap_prefix_proc_grp_r_id=request->association_list[lsub].ap_prefix_proc_grp_r_id)
     AND (ndelete_action=request->association_list[lsub].action_flag))
   WITH nocounter
  ;end delete
  IF (curqual > 0)
   SET lreplycount += 1
   IF (lreplycount > size(reply->association_list,5))
    SET stat = alterlist(reply->association_list,(lreplycount+ 9))
   ENDIF
   SET reply->association_list[lreplycount].object_key = request->association_list[lsub].object_key
   SET reply->association_list[lreplycount].ap_prefix_proc_grp_r_id = 0.0
  ENDIF
 ENDFOR
 SET stat = alterlist(reply->association_list,lreplycount)
 IF (logcclerror("DELETE","AP_PREFIX_PROC_GRP_R")=0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE (logcclerror(soperation=vc,stablename=vc) =i2)
  IF (error(ccclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),ccclerror)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
END GO
