CREATE PROGRAM bed_ens_workflow_info:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET wfcnt = 0
 SET wfidx = 0
 SET scnt = 0
 SET sidx = 0
 SET dp_id = 0.0
 DECLARE pname = vc
 DECLARE pvalue = vc
 SET pcnt = 0
 SET pcnt = size(request->plist,5)
 IF (((pcnt=0) OR ((request->plist[1].position_code_value=0))) )
  GO TO exit_script
 ENDIF
 FOR (p = 1 TO pcnt)
   SET wfcnt = 0
   SET wfidx = 0
   SET scnt = 0
   SET sidx = 0
   SET dp_id = 0.0
   SET pname = " "
   SET pvalue = " "
   SELECT INTO "nl:"
    FROM detail_prefs dp
    PLAN (dp
     WHERE dp.application_number=961000
      AND (dp.position_cd=request->plist[p].position_code_value)
      AND dp.prsnl_id=0
      AND dp.view_name="PCOFFICE"
      AND dp.view_seq=0
      AND dp.comp_name="PCOFFICE"
      AND dp.comp_seq=0
      AND dp.active_ind=1)
    DETAIL
     dp_id = dp.detail_prefs_id
    WITH nocounter
   ;end select
   CALL echo(build("dp id:",dp_id))
   IF (dp_id > 0)
    DELETE  FROM name_value_prefs nvp
     WHERE nvp.parent_entity_id=dp_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND ((nvp.pvc_name="ALL_WORKFLOW_COUNT") OR (((nvp.pvc_name="WORKFLOW_NAME*") OR (((nvp
     .pvc_name="WORKFLOW_LAYOUT_COUNT*") OR (((nvp.pvc_name="LAYOUT*_*") OR (((nvp.pvc_name=
     "INITIAL_WORKFLOW_CATEGORY") OR (((nvp.pvc_name="CUSTOM_WORKFLOW_INDEX") OR (nvp.pvc_name=
     "INITIAL_ACTION")) )) )) )) )) ))
     WITH nocounter
    ;end delete
   ELSEIF (dp_id=0)
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      dp_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM detail_prefs dp
     SET dp.detail_prefs_id = dp_id, dp.application_number = 961000, dp.position_cd = request->plist[
      p].position_code_value,
      dp.prsnl_id = 0, dp.view_name = "PCOFFICE", dp.view_seq = 0,
      dp.comp_name = "PCOFFICE", dp.comp_seq = 0, dp.active_ind = 1,
      dp.updt_cnt = 0, dp.updt_id = reqinfo->updt_id, dp.updt_task = reqinfo->updt_task,
      dp.updt_applctx = reqinfo->updt_applctx, dp.updt_dt_tm = cnvtdatetime(curdate,curtime)
     WITH nocounter
    ;end insert
   ENDIF
   SET wfcnt = size(request->plist[p].wlist,5)
   IF (wfcnt > 0
    AND dp_id > 0
    AND (request->plist[p].wlist[1].workflow_name > ""))
    SET pname = "ALL_WORKFLOW_COUNT"
    SET pvalue = cnvtstring(wfcnt)
    SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
     0)
    SET pname = "INITIAL_WORKFLOW_CATEGORY"
    SET pvalue = "0"
    SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
     0)
    SET pname = "CUSTOM_WORKFLOW_INDEX"
    SET pvalue = "0"
    SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
     0)
    SET pname = "INITIAL_ACTION"
    SET pvalue = "1"
    SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
     0)
    FOR (x = 1 TO wfcnt)
      SET pname = build("WORKFLOW_NAME",cnvtint((x - 1)))
      SET pvalue = request->plist[p].wlist[x].workflow_name
      SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
       0)
      SET scnt = size(request->plist[p].wlist[x].slist,5)
      IF (scnt > 0)
       SET pname = build("WORKFLOW_LAYOUT_COUNT",cnvtint((x - 1)))
       SET pvalue = cnvtstring(scnt)
       SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
        0)
       FOR (y = 1 TO scnt)
         SET pname = build("LAYOUT",cnvtint((x - 1)),"_",cnvtint((y - 1)))
         SET pvalue = build(request->plist[p].wlist[x].slist[y].comp1_name,",",request->plist[p].
          wlist[x].slist[y].comp2_name,",",cnvtint(request->plist[p].wlist[x].slist[y].
           layout_orientation))
         IF ((request->plist[p].wlist[x].slist[y].splitter_percent > 0))
          SET pvalue = build(pvalue,",",cnvtstring(request->plist[p].wlist[x].slist[y].
            splitter_percent,5,3,r))
         ENDIF
         SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
          0)
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF ((request->plist[p].reviewed_ind=1))
    SELECT INTO "nl:"
     FROM br_name_value bnv
     PLAN (bnv
      WHERE bnv.br_nv_key1="REVIEWED"
       AND bnv.br_name="PCOWORKFLOW"
       AND bnv.br_value=cnvtstring(request->plist[p].position_code_value))
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM br_name_value bnv
      SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "REVIEWED", bnv.br_name
        = "PCOWORKFLOW",
       bnv.br_value = cnvtstring(request->plist[p].position_code_value), bnv.updt_id = reqinfo->
       updt_id, bnv.updt_task = reqinfo->updt_task,
       bnv.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ELSE
    DELETE  FROM br_name_value bnv
     PLAN (bnv
      WHERE bnv.br_nv_key1="REVIEWED"
       AND bnv.br_name="PCOWORKFLOW"
       AND bnv.br_value=cnvtstring(request->plist[p].position_code_value))
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE addnvp(pe_id,pe_name,pvc_name,pvc_value,merge_name,merge_id)
  INSERT  FROM name_value_prefs nvp
   SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = pe_name, nvp
    .parent_entity_id = pe_id,
    nvp.pvc_name = pvc_name, nvp.pvc_value = pvc_value, nvp.active_ind = 1,
    nvp.updt_id = reqinfo->updt_id, nvp.updt_cnt = 0, nvp.updt_task = reqinfo->updt_task,
    nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp
    .merge_name = merge_name,
    nvp.merge_id = merge_id
   WITH nocounter
  ;end insert
  RETURN(1.0)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
