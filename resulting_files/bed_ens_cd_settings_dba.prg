CREATE PROGRAM bed_ens_cd_settings:dba
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
 DECLARE mrg_id = f8
 SET dtcnt = 0
 SET cvcnt = 0
 SET cscnt = 0
 DECLARE cv = f8
 SET cv = 0.0
 SET appcnt = size(request->alist,5)
 IF (appcnt=0)
  GO TO exit_script
 ENDIF
 FOR (a = 1 TO appcnt)
   SET dtcnt = size(request->alist[a].dtlist,5)
   SET cvcnt = size(request->alist[a].cvlist,5)
   SET cscnt = size(request->alist[a].cslist,5)
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
   IF ((request->alist[a].dt_chg_ind > 0))
    IF (dp_id > 0)
     DELETE  FROM name_value_prefs n
      PLAN (n
       WHERE n.parent_entity_id=dp_id
        AND n.pvc_name IN ("CD_DxType*", "DX_DEFAULT_TYPE"))
      WITH nocounter
     ;end delete
    ELSEIF (dtcnt > 0)
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
    IF (dtcnt > 0)
     SET pname = "CD_DxTypes_Cnt"
     SET pvalue = cnvtstring(dtcnt)
     SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
      0)
     FOR (x = 1 TO dtcnt)
       SET cv = request->alist[a].dtlist[x].dt_code_value
       SET pname = build("CD_DxType",cnvtint((x - 1)))
       SET pvalue = cnvtstring(cv)
       SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"CODE_VALUE",
        cv)
       IF ((request->alist[a].dtlist[x].default_selected_ind=1))
        SET pname = "DX_DEFAULT_TYPE"
        SET pvalue = cnvtstring(cv)
        SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"CODE_VALUE",
         cv)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF ((request->alist[a].cv_chg_ind > 0))
    IF (dp_id > 0)
     DELETE  FROM name_value_prefs n
      PLAN (n
       WHERE n.parent_entity_id=dp_id
        AND n.pvc_name IN ("DX_Auth_Vocab*", "DX_AuthVocabListCnt"))
      WITH nocounter
     ;end delete
    ELSEIF (cvcnt > 0)
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
    IF (cvcnt > 0)
     SET pname = "DX_AuthVocabListCnt"
     SET pvalue = cnvtstring(cvcnt)
     SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
      0)
     FOR (x = 1 TO cvcnt)
       SET pname = build("DX_Auth_Vocab",cnvtint((x - 1)))
       SET pvalue = " "
       SET mrg_id = request->alist[a].cvlist[x].cv_code_value
       SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"CODE_VALUE",
        mrg_id)
     ENDFOR
    ENDIF
   ENDIF
   IF ((request->alist[a].def_cv_chg_ind > 0))
    IF (dp_id > 0)
     DELETE  FROM name_value_prefs n
      PLAN (n
       WHERE n.parent_entity_id=dp_id
        AND n.pvc_name IN ("DX_VOCAB*", "DX_VocabList"))
      WITH nocounter
     ;end delete
     DELETE  FROM name_value_prefs n
      PLAN (n
       WHERE n.parent_entity_id=dp_id
        AND n.pvc_name IN ("DX_AxesList", "DX_AXES*"))
      WITH nocounter
     ;end delete
    ENDIF
    SET defcnt = 0
    FOR (i = 1 TO cvcnt)
      IF ((request->alist[a].cvlist[i].default_selected_ind=1))
       SET defcnt = (defcnt+ 1)
      ENDIF
    ENDFOR
    IF (defcnt > 0)
     SET pname = "DX_VocabList"
     SET pvalue = cnvtstring(defcnt)
     SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
      0)
     SET defcnt = 0
     FOR (x = 1 TO cvcnt)
       IF ((request->alist[a].cvlist[x].default_selected_ind=1))
        SET defcnt = (defcnt+ 1)
        SET pname = build("DX_VOCAB",cnvtint((defcnt - 1)))
        SET pvalue = trim(request->alist[a].cvlist[x].cv_meaning)
        SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
         0)
       ENDIF
     ENDFOR
     IF (defcnt=1)
      FOR (x = 1 TO cvcnt)
        IF ((request->alist[a].cvlist[x].default_selected_ind=1))
         IF ((request->alist[a].cvlist[x].cv_meaning="SNMCT"))
          SET pname = "DX_AxesList"
          SET pvalue = "3"
          SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
           0)
          SET pname = "DX_AXES0"
          SET pvalue = "DISEASE"
          SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
           0)
          SET pname = "DX_AXES1"
          SET pvalue = "FINDING"
          SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
           0)
          SET pname = "DX_AXES2"
          SET pvalue = "OBSENTITY"
          SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
           0)
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   IF ((request->alist[a].cs_chg_ind > 0))
    IF (dp_id > 0)
     DELETE  FROM name_value_prefs n
      PLAN (n
       WHERE n.parent_entity_id=dp_id
        AND n.pvc_name="CD_Clin_Service*")
      WITH nocounter
     ;end delete
    ELSEIF (cscnt > 0)
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
    IF (cscnt > 0)
     SET pname = "CD_Clin_Service_Cnt"
     SET pvalue = cnvtstring(cscnt)
     SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"",
      0)
     FOR (x = 1 TO cscnt)
       SET cv = request->alist[a].cslist[x].cs_code_value
       SET pname = build("CD_Clin_Service",cnvtint((x - 1)))
       SET pvalue = cnvtstring(cv)
       SET stat = addnvp(dp_id,"DETAIL_PREFS",pname,pvalue,"CODE_VALUE",
        cv)
     ENDFOR
    ENDIF
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
