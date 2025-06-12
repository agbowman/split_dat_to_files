CREATE PROGRAM bed_get_pc_settings:dba
 FREE SET reply
 RECORD reply(
   01 alist[*]
     02 application_number = i4
     02 pclist[*]
       03 pc_code_value = f8
       03 pc_display = vc
       03 default_selected_ind = i2
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
 FOR (a = 1 TO 3)
   SET class_pvc = 0
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
    SELECT INTO "nl:"
     FROM name_value_prefs nv
     PLAN (nv
      WHERE nv.parent_entity_id=detail_prefs_id
       AND nv.pvc_name="CD_Class_Cnt*")
     ORDER BY nv.name_value_prefs_id DESC
     HEAD REPORT
      class_pvc = cnvtint(nv.pvc_value)
     WITH nocounter
    ;end select
    SET pccnt = 0
    IF (class_pvc > 0)
     SET class_pvc = (class_pvc - 1)
     FOR (i = 0 TO class_pvc)
      SET class_value = concat("CD_Class",trim(cnvtstring(i)))
      SELECT INTO "nl:"
       FROM name_value_prefs nv,
        code_value c
       PLAN (nv
        WHERE nv.parent_entity_id=detail_prefs_id
         AND nv.pvc_name=trim(class_value))
        JOIN (c
        WHERE c.code_value=cnvtreal(nv.pvc_value))
       ORDER BY nv.name_value_prefs_id
       DETAIL
        pccnt = (pccnt+ 1), stat = alterlist(reply->alist[acnt].pclist,pccnt), reply->alist[acnt].
        pclist[pccnt].pc_code_value = c.code_value,
        reply->alist[acnt].pclist[pccnt].pc_display = c.display
       WITH nocounter
      ;end select
     ENDFOR
    ENDIF
    IF (pccnt > 0)
     SET default_pc_cv = 0.0
     SELECT INTO "nl:"
      FROM name_value_prefs nv
      PLAN (nv
       WHERE nv.parent_entity_id=detail_prefs_id
        AND nv.pvc_name="DX_DEFAULT_CLASSIFICATION")
      DETAIL
       default_pc_cv = cnvtreal(nv.pvc_value)
      WITH nocounter
     ;end select
     FOR (x = 1 TO pccnt)
       IF ((reply->alist[acnt].pclist[x].pc_code_value=default_pc_cv))
        SET reply->alist[acnt].pclist[x].default_selected_ind = 1
        SET x = pccnt
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
