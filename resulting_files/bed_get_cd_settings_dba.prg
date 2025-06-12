CREATE PROGRAM bed_get_cd_settings:dba
 FREE SET reply
 RECORD reply(
   01 alist[*]
     02 application_number = i4
     02 dtlist[*]
       03 dt_code_value = f8
       03 dt_display = vc
       03 default_selected_ind = i2
     02 cvlist[*]
       03 cv_code_value = f8
       03 cv_display = vc
       03 cv_meaning = vc
       03 default_selected_ind = i2
     02 cslist[*]
       03 cs_code_value = f8
       03 cs_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 alist[3]
     2 app_nbr = i4
 )
 SET reply->status_data.status = "F"
 SET temp->alist[1].app_nbr = 961000
 SET temp->alist[2].app_nbr = 600005
 SET temp->alist[3].app_nbr = 4250111
 SET acnt = 0
 DECLARE pname = vc
 DECLARE pvalue = vc
 SET mrg_id = 0.0
 FOR (a = 1 TO 3)
   SET detail_prefs_id = 0.0
   SELECT INTO "nl:"
    FROM detail_prefs dp
    PLAN (dp
     WHERE (dp.application_number=temp->alist[a].app_nbr)
      AND dp.position_cd=0
      AND dp.prsnl_id=0
      AND dp.view_name="ClinicalDx"
      AND dp.comp_name="ClinicalDx")
    DETAIL
     detail_prefs_id = dp.detail_prefs_id
    WITH nocounter
   ;end select
   IF (detail_prefs_id > 0)
    SET acnt = (acnt+ 1)
    SET stat = alterlist(reply->alist,acnt)
    SET reply->alist[acnt].application_number = temp->alist[a].app_nbr
    SET dtcnt = 0
    SELECT INTO "nl:"
     FROM name_value_prefs nv,
      code_value c
     PLAN (nv
      WHERE nv.parent_entity_id=detail_prefs_id
       AND nv.pvc_name="CD_DxType*"
       AND nv.pvc_name != "CD_DxTypes_Cnt*")
      JOIN (c
      WHERE c.code_value=cnvtreal(nv.pvc_value))
     ORDER BY nv.name_value_prefs_id
     HEAD REPORT
      dtcnt = 0
     DETAIL
      dtcnt = (dtcnt+ 1), stat = alterlist(reply->alist[acnt].dtlist,dtcnt), reply->alist[acnt].
      dtlist[dtcnt].dt_code_value = c.code_value,
      reply->alist[acnt].dtlist[dtcnt].dt_display = c.display
     WITH nocounter
    ;end select
    IF (dtcnt > 0)
     SET default_dt_cv = 0.0
     SELECT INTO "nl:"
      FROM name_value_prefs nv
      PLAN (nv
       WHERE nv.parent_entity_id=detail_prefs_id
        AND nv.pvc_name="DX_DEFAULT_TYPE")
      DETAIL
       default_dt_cv = cnvtreal(nv.pvc_value)
      WITH nocounter
     ;end select
     FOR (x = 1 TO dtcnt)
       IF ((reply->alist[acnt].dtlist[x].dt_code_value=default_dt_cv))
        SET reply->alist[acnt].dtlist[x].default_selected_ind = 1
        SET x = dtcnt
       ENDIF
     ENDFOR
    ENDIF
    SET cvcnt = 0
    SELECT INTO "nl:"
     FROM name_value_prefs nv,
      code_value c
     PLAN (nv
      WHERE nv.parent_entity_id=detail_prefs_id
       AND nv.pvc_name="DX_Auth_Vocab*")
      JOIN (c
      WHERE c.code_set=400
       AND c.code_value=nv.merge_id)
     ORDER BY c.display
     HEAD REPORT
      cvcnt = 0
     DETAIL
      cvcnt = (cvcnt+ 1), stat = alterlist(reply->alist[acnt].cvlist,cvcnt), reply->alist[acnt].
      cvlist[cvcnt].cv_code_value = c.code_value,
      reply->alist[acnt].cvlist[cvcnt].cv_display = c.display, reply->alist[acnt].cvlist[cvcnt].
      cv_meaning = c.cdf_meaning
     WITH nocounter
    ;end select
    IF (cvcnt=0)
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=400
        AND cv.active_ind=1
        AND cv.cdf_meaning IN ("SNMCT", "ICD9", "NANDA", "ICD10", "ICD10-CA",
       "ICD10CM", "ICD10WHO", "ICD10-SGB", "LYNX", "ICDO",
       "DSM4_TR"))
      ORDER BY cv.display
      HEAD REPORT
       cvcnt = 0
      DETAIL
       cvcnt = (cvcnt+ 1), stat = alterlist(reply->alist[acnt].cvlist,cvcnt), reply->alist[acnt].
       cvlist[cvcnt].cv_code_value = cv.code_value,
       reply->alist[acnt].cvlist[cvcnt].cv_display = cv.display, reply->alist[acnt].cvlist[cvcnt].
       cv_meaning = cv.cdf_meaning
      WITH nocounter
     ;end select
     IF (cvcnt > 0)
      SET reqinfo->commit_ind = 1
      UPDATE  FROM name_value_prefs nvp
       SET nvp.pvc_value = cnvtstring(cvcnt)
       WHERE nvp.parent_entity_id=detail_prefs_id
        AND nvp.parent_entity_name="DETAIL_PREFS"
        AND nvp.pvc_name="DX_AuthVocabListCnt"
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET pname = "DX_AuthVocabListCnt"
       SET pvalue = cnvtstring(cvcnt)
       SET stat = addnvp(detail_prefs_id,"DETAIL_PREFS",pname,pvalue,"",
        0)
      ENDIF
      FOR (cvidx = 1 TO cvcnt)
        SET pname = build("DX_Auth_Vocab",cnvtint((cvidx - 1)))
        SET pvalue = " "
        SET mrg_id = reply->alist[acnt].cvlist[cvidx].cv_code_value
        SET stat = addnvp(detail_prefs_id,"DETAIL_PREFS",pname,pvalue,"CODE_VALUE",
         mrg_id)
      ENDFOR
     ENDIF
    ENDIF
    IF (cvcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = cvcnt),
       name_value_prefs nv
      PLAN (d)
       JOIN (nv
       WHERE nv.parent_entity_id=detail_prefs_id
        AND nv.pvc_name="DX_VOCAB*"
        AND (nv.pvc_value=reply->alist[acnt].cvlist[d.seq].cv_meaning))
      DETAIL
       reply->alist[acnt].cvlist[d.seq].default_selected_ind = 1
      WITH nocounter
     ;end select
    ENDIF
    SET cscnt = 0
    SELECT INTO "nl:"
     FROM name_value_prefs nv,
      code_value c
     PLAN (nv
      WHERE nv.parent_entity_id=detail_prefs_id
       AND nv.pvc_name="CD_Clin_Service*"
       AND nv.pvc_name != "CD_Clin_Service_Cnt")
      JOIN (c
      WHERE c.code_value=cnvtreal(nv.pvc_value))
     ORDER BY nv.name_value_prefs_id
     HEAD REPORT
      dtcnt = 0
     DETAIL
      cscnt = (cscnt+ 1), stat = alterlist(reply->alist[acnt].cslist,cscnt), reply->alist[acnt].
      cslist[cscnt].cs_code_value = c.code_value,
      reply->alist[acnt].cslist[cscnt].cs_display = c.display
     WITH nocounter
    ;end select
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
 CALL echorecord(reply)
END GO
