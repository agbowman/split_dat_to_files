CREATE PROGRAM bb_upd_qc_group_activity:dba
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
 RECORD reply(
   1 group_activity_list[*]
     2 group_activity_id = f8
     2 updt_cnt = i4
     2 object_key = i4
     2 reagent_activity_list[*]
       3 group_reagent_activity_id = f8
       3 updt_cnt = i4
       3 object_key = i4
       3 result_list[*]
         4 result_id = f8
         4 updt_cnt = i4
         4 object_key = i4
         4 comment_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE nfail = i2 WITH protect, constant(0)
 DECLARE nsuccess = i2 WITH protect, constant(1)
 DECLARE nunlock_and_update = i2 WITH protect, constant(1)
 DECLARE nunlock_only = i2 WITH protect, constant(2)
 DECLARE lgroup_activity_cnt = i4 WITH protect, constant(size(request->group_activity_list,5))
 DECLARE ninsert_new = i2 WITH protect, constant(1)
 DECLARE nupdate_existing = i2 WITH protect, constant(2)
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE lstatus = i4 WITH protect, noconstant(0)
 DECLARE lresult_status_cs = i4 WITH protect, constant(325577)
 DECLARE spending_cdf_meaning = c12 WITH protect, constant("PENDING")
 DECLARE sverified_cdf_meaning = c12 WITH protect, constant("VERIFIED")
 DECLARE saccepted_cdf_meaning = c12 WITH protect, constant("ACCEPTED")
 DECLARE sretested_cdf_meaning = c12 WITH protect, constant("RETESTED")
 DECLARE sdiscarded_cdf_meaning = c12 WITH protect, constant("DISCARDED")
 DECLARE dpendingstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE dverifiedstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE dacceptedstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE dretestedstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE ddiscardedstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE unlockgroupactivity(no_param=i2(value)) = i2 WITH protect
 DECLARE updategroupactivity(no_param=i2(value)) = i2 WITH protect
 DECLARE updatereagentactivity(lgroupidx=i4(value)) = i2 WITH protect
 DECLARE updateresults(lgroupidx=i4(value),lreagentactivityidx=i4(value)) = i2 WITH protect
 DECLARE generateid(no_param=i2(value)) = f8 WITH protect
 DECLARE updatecommenttext(dqcresultid=f8(value),dcommenttextid=f8(value),scommenttext=vc(value)) =
 f8 WITH protect
 DECLARE getcodevalues(no_param=i2(value)) = i2 WITH protect
#begin_script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (getcodevalues(0)=nfail)
  GO TO end_script
 ENDIF
 IF ((request->unlock_flag=nunlock_only))
  IF (unlockgroupactivity(0)=nfail)
   GO TO end_script
  ENDIF
 ELSEIF ((request->unlock_flag=nunlock_and_update))
  IF (updategroupactivity(0)=nfail)
   GO TO end_script
  ELSE
   IF (unlockgroupactivity(0)=nfail)
    GO TO end_script
   ENDIF
  ENDIF
 ELSE
  IF (updategroupactivity(0)=nfail)
   GO TO end_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 SUBROUTINE unlockgroupactivity(no_param)
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO lgroup_activity_cnt)
     SELECT INTO "nl:"
      FROM bb_qc_group_activity ga
      WHERE (ga.group_activity_id=request->group_activity_list[i].group_activity_id)
       AND ga.group_activity_id > 0.0
      WITH nocounter, forupdate(ga)
     ;end select
     SET lerrorcode = error(serrormsg,1)
     IF (lerrorcode != 0)
      SET reply->group_activity_list[i].updt_cnt = request->group_activity_list[i].updt_cnt
      CALL subevent_add("UPDATE","F","BB_QC_GROUP_ACTIVITY","Unable to establish lock.")
      RETURN(nfail)
     ENDIF
     UPDATE  FROM bb_qc_group_activity ga
      SET ga.lock_prsnl_id = 0.0, ga.lock_dt_tm = null, ga.updt_cnt = (request->group_activity_list[i
       ].updt_cnt+ 1),
       ga.updt_id = reqinfo->updt_id, ga.updt_dt_tm = cnvtdatetime(curdate,curtime3), ga.updt_task =
       reqinfo->updt_task,
       ga.updt_applctx = reqinfo->updt_applctx
      WHERE (ga.group_activity_id=request->group_activity_list[i].group_activity_id)
       AND ga.group_activity_id > 0.0
       AND (ga.updt_cnt=request->group_activity_list[i].updt_cnt)
     ;end update
   ENDFOR
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode != 0)
    CALL subevent_add("UPDATE","F","BB_QC_GROUP_ACTIVITY","Failed to unlock group activity rows.")
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
 SUBROUTINE updategroupactivity(no_param)
   SET lstatus = alterlist(reply->group_activity_list,lgroup_activity_cnt)
   FOR (i = 1 TO lgroup_activity_cnt)
     SET reply->group_activity_list[i].group_activity_id = request->group_activity_list[i].
     group_activity_id
     SET reply->group_activity_list[i].object_key = request->group_activity_list[i].object_key
     IF ((request->group_activity_list[i].save_flag=nupdate_existing))
      SELECT INTO "nl:"
       FROM bb_qc_group_activity ga
       WHERE (ga.group_activity_id=request->group_activity_list[i].group_activity_id)
        AND ga.group_activity_id > 0.0
        AND (((ga.lock_prsnl_id=reqinfo->updt_id)) OR (ga.lock_prsnl_id=0.0
        AND (ga.updt_cnt=request->group_activity_list[i].updt_cnt)))
       WITH nocounter, forupdate(ga)
      ;end select
      SET lerrorcode = error(serrormsg,1)
      IF (lerrorcode != 0)
       SET reply->group_activity_list[i].updt_cnt = request->group_activity_list[i].updt_cnt
       CALL subevent_add("UPDATE","F","BB_QC_GROUP_ACTIVITY","Unable to establish lock.")
       RETURN(nfail)
      ENDIF
      UPDATE  FROM bb_qc_group_activity ga
       SET ga.related_group_id = request->group_activity_list[i].xref_group_id, ga.updt_cnt = (
        request->group_activity_list[i].updt_cnt+ 1), ga.updt_id = reqinfo->updt_id,
        ga.updt_dt_tm = cnvtdatetime(curdate,curtime3), ga.updt_task = reqinfo->updt_task, ga
        .updt_applctx = reqinfo->updt_applctx
       WHERE (ga.group_activity_id=request->group_activity_list[i].group_activity_id)
        AND ga.group_activity_id > 0.0
        AND (ga.updt_cnt=request->group_activity_list[i].updt_cnt)
        AND (((ga.lock_prsnl_id=reqinfo->updt_id)) OR (ga.lock_prsnl_id=0.0))
       WITH nocounter
      ;end update
      SET lerrorcode = error(serrormsg,1)
      IF (lerrorcode != 0)
       SET reply->group_activity_list[i].updt_cnt = request->group_activity_list[i].updt_cnt
       CALL subevent_add("UPDATE","F","BB_QC_GROUP_ACTIVITY","Failed to update group activity.")
       RETURN(nfail)
      ENDIF
      SET reply->group_activity_list[i].updt_cnt = (request->group_activity_list[i].updt_cnt+ 1)
     ENDIF
     IF (updatereagentactivity(i)=nfail)
      RETURN(nfail)
     ENDIF
   ENDFOR
   RETURN(nsuccess)
 END ;Subroutine
 SUBROUTINE updatereagentactivity(lgroupidx)
   DECLARE lreagentactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET lreagentactivitycnt = size(request->group_activity_list[lgroupidx].reagent_activity_list,5)
   SET lstatus = alterlist(reply->group_activity_list[lgroupidx].reagent_activity_list,
    lreagentactivitycnt)
   FOR (i = 1 TO lreagentactivitycnt)
     SET reply->group_activity_list[lgroupidx].reagent_activity_list[i].group_reagent_activity_id =
     request->group_activity_list[lgroupidx].reagent_activity_list[i].group_reagent_activity_id
     SET reply->group_activity_list[lgroupidx].reagent_activity_list[i].object_key = request->
     group_activity_list[lgroupidx].reagent_activity_list[i].object_key
     IF ((request->group_activity_list[lgroupidx].reagent_activity_list[i].save_flag=nupdate_existing
     ))
      SELECT INTO "nl:"
       FROM bb_qc_grp_reagent_activity gra
       WHERE (gra.group_reagent_activity_id=request->group_activity_list[lgroupidx].
       reagent_activity_list[i].group_reagent_activity_id)
        AND gra.group_reagent_activity_id > 0.0
        AND (gra.updt_cnt=request->group_activity_list[lgroupidx].reagent_activity_list[i].updt_cnt)
       WITH nocounter, forupdate(gra)
      ;end select
      SET lerrorcode = error(serrormsg,1)
      IF (lerrorcode != 0)
       SET reply->group_activity_list[lgroupidx].reagent_activity_list[i].updt_cnt = request->
       group_activity_list[lgroupidx].reagent_activity_list[i].updt_cnt
       CALL subevent_add("UPDATE","F","BB_QC_GRP_REAGENT_ACTIVITY","Failed to establish lock.")
       RETURN(nfail)
      ENDIF
      UPDATE  FROM bb_qc_grp_reagent_activity gra
       SET gra.visual_inspection_cd = request->group_activity_list[lgroupidx].reagent_activity_list[i
        ].visual_inspection_cd, gra.interpretation_cd = request->group_activity_list[lgroupidx].
        reagent_activity_list[i].interpretation_cd, gra.activity_dt_tm = cnvtdatetime(request->
         group_activity_list[lgroupidx].reagent_activity_list[i].activity_dt_tm),
        gra.activity_prsnl_id = reqinfo->updt_id, gra.updt_cnt = (request->group_activity_list[
        lgroupidx].reagent_activity_list[i].updt_cnt+ 1), gra.updt_id = reqinfo->updt_id,
        gra.updt_dt_tm = cnvtdatetime(curdate,curtime3), gra.updt_task = reqinfo->updt_task, gra
        .updt_applctx = reqinfo->updt_applctx
       WHERE (gra.group_reagent_activity_id=request->group_activity_list[lgroupidx].
       reagent_activity_list[i].group_reagent_activity_id)
        AND gra.group_reagent_activity_id > 0.0
        AND (gra.updt_cnt=request->group_activity_list[lgroupidx].reagent_activity_list[i].updt_cnt)
       WITH nocounter
      ;end update
      SET lerrorcode = error(serrormsg,1)
      IF (lerrorcode != 0)
       CALL subevent_add("UPDATE","F","BB_QC_GRP_REAGENT_ACTIVITY",
        "Failed to update group reagent activity.")
       RETURN(nfail)
      ENDIF
      SET reply->group_activity_list[lgroupidx].reagent_activity_list[i].updt_cnt = (request->
      group_activity_list[lgroupidx].reagent_activity_list[i].updt_cnt+ 1)
     ENDIF
     IF (updateresults(lgroupidx,i)=nfail)
      RETURN(nfail)
     ENDIF
   ENDFOR
   RETURN(nsuccess)
 END ;Subroutine
 SUBROUTINE updateresults(lgroupidx,lreagentactivityidx)
   DECLARE lresultcnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE dnewresultid = f8 WITH protect, noconstant(0.0)
   DECLARE dcommenttextid = f8 WITH protect, noconstant(0.0)
   DECLARE scommenttext = vc WITH protect, noconstant("")
   DECLARE ltrblcnt = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE dnewtrblid = f8 WITH protect, noconstant(0.0)
   DECLARE naddtrblind = i2 WITH protect, noconstant(0)
   DECLARE dqcresultid = f8 WITH protect, noconstant(0.0)
   DECLARE nupdresultuserind = i2 WITH protect, noconstant(0)
   DECLARE nupdactionuserind = i2 WITH protect, noconstant(0)
   DECLARE dnomenclatureid = f8 WITH protect, noconstant(0.0)
   SET lresultcnt = size(request->group_activity_list[lgroupidx].reagent_activity_list[
    lreagentactivityidx].result_list,5)
   SET lstatus = alterlist(reply->group_activity_list[lgroupidx].reagent_activity_list[
    lreagentactivityidx].result_list,lresultcnt)
   FOR (i = 1 TO lresultcnt)
     SET naddtrblind = 0
     SET nupdresultuserind = 0
     SET nupdactionuserind = 0
     SET dnomenclatureid = 0.0
     SET ltrblcnt = size(request->group_activity_list[lgroupidx].reagent_activity_list[
      lreagentactivityidx].result_list[i].result_troubleshooting_list,5)
     SET reply->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
     result_list[i].object_key = request->group_activity_list[lgroupidx].reagent_activity_list[
     lreagentactivityidx].result_list[i].object_key
     IF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
     result_list[i].status_cd IN (dverifiedstatuscd, dacceptedstatuscd)))
      SET nupdresultuserind = 1
      SET nupdactionuserind = 0
     ELSEIF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
     result_list[i].status_cd IN (dpendingstatuscd, ddiscardedstatuscd)))
      SET nupdresultuserind = 0
      SET nupdactionuserind = 1
     ENDIF
     IF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
     result_list[i].save_flag=nupdate_existing))
      SET dcommenttextid = request->group_activity_list[lgroupidx].reagent_activity_list[
      lreagentactivityidx].result_list[i].comment_text_id
      IF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
      result_list[i].updt_comment_ind=1))
       SET scommenttext = request->group_activity_list[lgroupidx].reagent_activity_list[
       lreagentactivityidx].result_list[i].comment_text
       SET dqcresultid = request->group_activity_list[lgroupidx].reagent_activity_list[
       lreagentactivityidx].result_list[i].result_id
       SET dcommenttextid = updatecommenttext(dqcresultid,dcommenttextid,scommenttext)
       SET reply->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
       result_list[i].comment_text_id = dcommenttextid
      ENDIF
      SELECT INTO "nl:"
       FROM bb_qc_result r
       WHERE (r.qc_result_id=request->group_activity_list[lgroupidx].reagent_activity_list[
       lreagentactivityidx].result_list[i].result_id)
        AND r.qc_result_id > 0.0
        AND (r.updt_cnt=request->group_activity_list[lgroupidx].reagent_activity_list[
       lreagentactivityidx].result_list[i].updt_cnt)
       DETAIL
        dnomenclatureid = r.nomenclature_id
       WITH nocounter, forupdate(r)
      ;end select
      SET lerrorcode = error(serrormsg,1)
      IF (lerrorcode != 0)
       CALL subevent_add("UPDATE","F","BB_QC_RESULT","Unable to establish lock.")
       RETURN(nfail)
      ENDIF
      IF (curqual=0)
       CALL subevent_add("LOCK","F","BB_QC_RESULT",build(
         "Unable to establish lock for qc_result_id->",request->group_activity_list[lgroupidx].
         reagent_activity_list[lreagentactivityidx].result_list[i].result_id))
       RETURN(nfail)
      ENDIF
      IF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
      result_list[i].status_cd=dretestedstatuscd))
       IF (dnomenclatureid > 0.0)
        SET nupdresultuserind = 0
        SET nupdactionuserind = 1
       ELSE
        SET nupdresultuserind = 1
        SET nupdactionuserind = 1
       ENDIF
      ENDIF
      UPDATE  FROM bb_qc_result r
       SET r.nomenclature_id = request->group_activity_list[lgroupidx].reagent_activity_list[
        lreagentactivityidx].result_list[i].nomenclature_id, r.comment_text_id = dcommenttextid, r
        .result_dt_tm =
        IF (nupdresultuserind=1) cnvtdatetime(request->group_activity_list[lgroupidx].
          reagent_activity_list[lreagentactivityidx].result_list[i].result_dt_tm)
        ELSE r.result_dt_tm
        ENDIF
        ,
        r.result_prsnl_id =
        IF (nupdresultuserind=1) reqinfo->updt_id
        ELSE r.result_prsnl_id
        ENDIF
        , r.action_dt_tm =
        IF (nupdactionuserind=1) cnvtdatetime(request->group_activity_list[lgroupidx].
          reagent_activity_list[lreagentactivityidx].result_list[i].result_dt_tm)
        ELSE null
        ENDIF
        , r.action_prsnl_id =
        IF (nupdactionuserind=1) reqinfo->updt_id
        ELSE 0.0
        ENDIF
        ,
        r.abnormal_ind = request->group_activity_list[lgroupidx].reagent_activity_list[
        lreagentactivityidx].result_list[i].abnormal_ind, r.reason_cd = request->group_activity_list[
        lgroupidx].reagent_activity_list[lreagentactivityidx].result_list[i].reason_cd, r.status_cd
         = request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
        result_list[i].status_cd,
        r.updt_cnt = (request->group_activity_list[lgroupidx].reagent_activity_list[
        lreagentactivityidx].result_list[i].updt_cnt+ 1), r.updt_id = reqinfo->updt_id, r.updt_dt_tm
         = cnvtdatetime(curdate,curtime3),
        r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx
       WHERE (r.qc_result_id=request->group_activity_list[lgroupidx].reagent_activity_list[
       lreagentactivityidx].result_list[i].result_id)
        AND r.qc_result_id > 0.0
        AND (r.updt_cnt=request->group_activity_list[lgroupidx].reagent_activity_list[
       lreagentactivityidx].result_list[i].updt_cnt)
       WITH nocounter
      ;end update
      SET reply->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
      result_list[i].result_id = request->group_activity_list[lgroupidx].reagent_activity_list[
      lreagentactivityidx].result_list[i].result_id
      SET lerrorcode = error(serrormsg,1)
      IF (lerrorcode != 0)
       CALL subevent_add("UPDATE","F","BB_QC_RESULT","Failed to update qc results.")
       RETURN(nfail)
      ENDIF
      SET reply->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
      result_list[i].updt_cnt = (request->group_activity_list[lgroupidx].reagent_activity_list[
      lreagentactivityidx].result_list[i].updt_cnt+ 1)
      IF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
      result_list[i].updt_troubleshooting_ind=1))
       DELETE  FROM bb_qc_result_troubleshooting_r tr
        WHERE (tr.qc_result_id=request->group_activity_list[lgroupidx].reagent_activity_list[
        lreagentactivityidx].result_list[i].result_id)
        WITH nocounter
       ;end delete
       SET naddtrblind = 1
      ENDIF
     ELSEIF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
     result_list[i].save_flag=ninsert_new))
      SET dnewresultid = generateid(0)
      IF (dnewresultid > 0.0)
       SET scommenttext = request->group_activity_list[lgroupidx].reagent_activity_list[
       lreagentactivityidx].result_list[i].comment_text
       SET dcommenttextid = request->group_activity_list[lgroupidx].reagent_activity_list[
       lreagentactivityidx].result_list[i].comment_text_id
       SET dcommenttextid = updatecommenttext(dnewresultid,dcommenttextid,scommenttext)
       SET reply->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
       result_list[i].comment_text_id = dcommenttextid
       IF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
       result_list[i].status_cd=dretestedstatuscd))
        IF ((request->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
        result_list[i].nomenclature_id > 0.0))
         SET nupdresultuserind = 1
         SET nupdactionuserind = 1
        ELSE
         SET nupdresultuserind = 0
         SET nupdactionuserind = 1
        ENDIF
       ENDIF
       INSERT  FROM bb_qc_result r
        SET r.qc_result_id = dnewresultid, r.group_reagent_activity_id = request->
         group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
         group_reagent_activity_id, r.enhancement_activity_id = request->group_activity_list[
         lgroupidx].reagent_activity_list[lreagentactivityidx].result_list[i].enhancement_activity_id,
         r.control_activity_id = request->group_activity_list[lgroupidx].reagent_activity_list[
         lreagentactivityidx].result_list[i].control_activity_id, r.phase_cd = request->
         group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].result_list[i].
         phase_cd, r.comment_text_id = dcommenttextid,
         r.nomenclature_id = request->group_activity_list[lgroupidx].reagent_activity_list[
         lreagentactivityidx].result_list[i].nomenclature_id, r.result_dt_tm =
         IF (nupdresultuserind=1) cnvtdatetime(request->group_activity_list[lgroupidx].
           reagent_activity_list[lreagentactivityidx].result_list[i].result_dt_tm)
         ELSE cnvtdatetime(curdate,curtime3)
         ENDIF
         , r.result_prsnl_id =
         IF (nupdresultuserind=1) reqinfo->updt_id
         ELSE 0.0
         ENDIF
         ,
         r.action_dt_tm =
         IF (nupdactionuserind=1) cnvtdatetime(request->group_activity_list[lgroupidx].
           reagent_activity_list[lreagentactivityidx].result_list[i].result_dt_tm)
         ENDIF
         , r.action_prsnl_id =
         IF (nupdactionuserind=1) reqinfo->updt_id
         ELSE 0.0
         ENDIF
         , r.abnormal_ind = request->group_activity_list[lgroupidx].reagent_activity_list[
         lreagentactivityidx].result_list[i].abnormal_ind,
         r.reason_cd = request->group_activity_list[lgroupidx].reagent_activity_list[
         lreagentactivityidx].result_list[i].reason_cd, r.status_cd = request->group_activity_list[
         lgroupidx].reagent_activity_list[lreagentactivityidx].result_list[i].status_cd, r.updt_cnt
          = 0,
         r.updt_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task =
         reqinfo->updt_task,
         r.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       SET reply->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
       result_list[i].result_id = dnewresultid
       SET reply->group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].
       result_list[i].updt_cnt = 0
       SET lerrorcode = error(serrormsg,1)
       IF (lerrorcode != 0)
        CALL subevent_add("INSERT","F","BB_QC_RESULT","Failed to insert qc results.")
        RETURN(nfail)
       ENDIF
       SET naddtrblind = 1
      ENDIF
     ENDIF
     IF (naddtrblind=1)
      FOR (j = 1 TO ltrblcnt)
       SET dnewtrblid = generateid(0)
       IF (dnewtrblid > 0.0)
        INSERT  FROM bb_qc_result_troubleshooting_r rtr
         SET rtr.result_troubleshooting_id = dnewtrblid, rtr.qc_result_id = request->
          group_activity_list[lgroupidx].reagent_activity_list[lreagentactivityidx].result_list[i].
          result_id, rtr.troubleshooting_id = request->group_activity_list[lgroupidx].
          reagent_activity_list[lreagentactivityidx].result_list[i].result_troubleshooting_list[j].
          troubleshooting_id,
          rtr.updt_cnt = 0, rtr.updt_id = reqinfo->updt_id, rtr.updt_dt_tm = cnvtdatetime(curdate,
           curtime3),
          rtr.updt_task = reqinfo->updt_task, rtr.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        SET lerrorcode = error(serrormsg,1)
        IF (lerrorcode != 0)
         CALL subevent_add("INSERT","F","BB_QC_RESULT_TROUBLESHOOTING",
          "Failed to insert result troubleshooting.")
         RETURN(nfail)
        ENDIF
       ENDIF
      ENDFOR
     ENDIF
     SET lerrorcode = error(serrormsg,1)
     IF (lerrorcode != 0)
      CALL subevent_add("UPDATE","F","BB_QC_RESULT","Failed to update qc results.")
      RETURN(nfail)
     ENDIF
   ENDFOR
   RETURN(nsuccess)
 END ;Subroutine
 SUBROUTINE generateid(no_param)
   DECLARE did = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     did = next_seq_nbr
    WITH nocounter
   ;end select
   RETURN(did)
 END ;Subroutine
 SUBROUTINE updatecommenttext(dqcresultid,dcommenttextid,scommenttext)
   DECLARE dnewcommenttextid = f8 WITH protect, noconstant(0.0)
   IF (trim(scommenttext) != ""
    AND dcommenttextid=0.0)
    SELECT INTO "nl:"
     next_seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      dnewcommenttextid = cnvtreal(next_seq_nbr)
     WITH nocounter
    ;end select
    INSERT  FROM long_text lt
     SET lt.long_text_id = dnewcommenttextid, lt.parent_entity_name = "BB_QC_RESULT", lt
      .parent_entity_id = dqcresultid,
      lt.long_text = scommenttext, lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.updt_cnt = 0
     WITH nocounter
    ;end insert
    SET lerrorcode = error(serrormsg,1)
    IF (lerrorcode != 0)
     CALL subevent_add("INSERT","F","LONG_TEXT",
      "Failed to insert qc result comment on long_text table.")
    ELSE
     RETURN(dnewcommenttextid)
    ENDIF
   ELSEIF (dcommenttextid > 0.0)
    SELECT INTO "nl:"
     FROM long_text lt
     WHERE lt.long_text_id=dcommenttextid
      AND lt.parent_entity_name="BB_QC_RESULT"
      AND lt.parent_entity_id=dqcresultid
     WITH nocounter, forupdate(lt)
    ;end select
    SET lerrorcode = error(serrormsg,1)
    IF (lerrorcode != 0)
     CALL subevent_add("UPDATE","F","LONG_TEXT","Unable to establish lock.")
     RETURN(0.0)
    ENDIF
    UPDATE  FROM long_text lt
     SET lt.long_text = scommenttext, lt.active_ind = 1, lt.active_status_cd = reqdata->
      active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.updt_cnt = (lt.updt_cnt+ 1)
     WHERE lt.long_text_id=dcommenttextid
      AND lt.parent_entity_name="BB_QC_RESULT"
      AND lt.parent_entity_id=dqcresultid
     WITH nocounter
    ;end update
    SET lerrorcode = error(serrormsg,1)
    IF (lerrorcode != 0)
     CALL subevent_add("UPDATE","F","LONG_TEXT","Failed to update long_text with qc result comment.")
    ELSE
     RETURN(dcommenttextid)
    ENDIF
   ENDIF
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE getcodevalues(no_param)
   SET lstatus = uar_get_meaning_by_codeset(lresult_status_cs,nullterm(spending_cdf_meaning),1,
    dpendingstatuscd)
   IF (dpendingstatuscd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE",
     "Could not find PENDING result status code in CS 325577.")
    RETURN(nfail)
   ENDIF
   SET lstatus = uar_get_meaning_by_codeset(lresult_status_cs,nullterm(sverified_cdf_meaning),1,
    dverifiedstatuscd)
   IF (dverifiedstatuscd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE",
     "Could not find VERIFIED result status code in CS 325577.")
    RETURN(nfail)
   ENDIF
   SET lstatus = uar_get_meaning_by_codeset(lresult_status_cs,nullterm(saccepted_cdf_meaning),1,
    dacceptedstatuscd)
   IF (dacceptedstatuscd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE",
     "Could not find ACCEPTED result status code in CS 325577.")
    RETURN(nfail)
   ENDIF
   SET lstatus = uar_get_meaning_by_codeset(lresult_status_cs,nullterm(sretested_cdf_meaning),1,
    dretestedstatuscd)
   IF (dretestedstatuscd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE",
     "Could not find RETESTED result status code in CS 325577.")
    RETURN(nfail)
   ENDIF
   SET lstatus = uar_get_meaning_by_codeset(lresult_status_cs,nullterm(sdiscarded_cdf_meaning),1,
    ddiscardedstatuscd)
   IF (ddiscardedstatuscd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE",
     "Could not find DISCARDED result status code in CS 325577.")
    RETURN(nfail)
   ENDIF
   RETURN(nsuccess)
 END ;Subroutine
END GO
