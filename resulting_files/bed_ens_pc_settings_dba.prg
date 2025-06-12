CREATE PROGRAM bed_ens_pc_settings:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 DECLARE pname = vc
 DECLARE pvalue = vc
 SET pccnt = 0
 DECLARE cv = f8
 SET cv = 0.0
 SET acnt = size(request->alist,5)
 IF (acnt=0)
  GO TO exit_script
 ENDIF
 FOR (a = 1 TO acnt)
   IF ((request->alist[a].pc_chg_ind > 0))
    SET pccnt = size(request->alist[a].pclist,5)
    SET dp_id = 0.0
    SELECT INTO "nl:"
     FROM detail_prefs dp
     PLAN (dp
      WHERE (dp.application_number=request->alist[a].application_number)
       AND dp.position_cd=0
       AND dp.prsnl_id=0
       AND dp.view_name="ClinicalDx"
       AND dp.comp_name="ClinicalDx")
     DETAIL
      dp_id = dp.detail_prefs_id
     WITH nocounter
    ;end select
    IF (dp_id > 0)
     DELETE  FROM name_value_prefs n
      PLAN (n
       WHERE n.parent_entity_id=dp_id
        AND n.pvc_name IN ("CD_Class*", "DX_DEFAULT_CLASSIFICATION"))
      WITH nocounter
     ;end delete
    ELSEIF (pccnt > 0)
     SELECT INTO "nl:"
      z = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       dp_id = cnvtreal(z)
      WITH format, nocounter
     ;end select
     INSERT  FROM detail_prefs dp
      SET dp.detail_prefs_id = dp_id, dp.application_number = request->alist[a].application_number,
       dp.position_cd = 0,
       dp.prsnl_id = 0, dp.person_id = 0, dp.view_name = "ClinicalDx",
       dp.view_seq = 0, dp.comp_name = "ClinicalDx", dp.comp_seq = 0,
       dp.active_ind = 1, dp.updt_id = reqinfo->updt_id, dp.updt_cnt = 0,
       dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_dt_tm =
       cnvtdatetime(curdate,curtime)
      WITH nocounter
     ;end insert
    ENDIF
    SET pname = "CD_Class_Cnt"
    SET pvalue = cnvtstring(pccnt)
    SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
     0)
    FOR (x = 1 TO pccnt)
      SET cv = request->alist[a].pclist[x].pc_code_value
      SET pname = build("CD_Class",cnvtint((x - 1)))
      SET pvalue = cnvtstring(cv)
      SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"CODE_VALUE",
       cv)
      IF ((request->alist[a].pclist[x].default_selected_ind=1))
       SET pname = "DX_DEFAULT_CLASSIFICATION"
       SET pvalue = cnvtstring(cv)
       SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"CODE_VALUE",
        cv)
      ENDIF
    ENDFOR
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
