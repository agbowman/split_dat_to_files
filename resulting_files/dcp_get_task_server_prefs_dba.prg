CREATE PROGRAM dcp_get_task_server_prefs:dba
 SET junk = 0
 SET reply->chargeprncont_value = 0
 SET reply->chargesched_value = 0
 SET reply->prnnodttm_value = 0
 SET reply->encntroffwithloc_value = 0
 SET reply->notdnkeepord_value = 0
 SET reply->comp_cont_iv_value = "STOPDTTM"
 SELECT INTO "nl:"
  a.app_prefs_id, nv.seq, nv.name_value_prefs_id
  FROM app_prefs a,
   name_value_prefs nv
  PLAN (a
   WHERE a.application_number=600005
    AND a.active_ind=1
    AND a.position_cd=0
    AND a.prsnl_id=0)
   JOIN (nv
   WHERE nv.parent_entity_name="APP_PREFS"
    AND nv.parent_entity_id=a.app_prefs_id
    AND nv.active_ind=1
    AND ((nv.pvc_name="TSK_CHGPRNCT") OR (((nv.pvc_name="TSK_CHGSCHED") OR (((nv.pvc_name=
   "TSK_CHGADHOC") OR (((nv.pvc_name="TSK_PRNNODTTM") OR (nv.pvc_name="TSK_ENCNTROFFWITHLOC")) )) ))
   )) )
  HEAD REPORT
   junk = junk
  HEAD nv.pvc_name
   IF (nv.pvc_name="TSK_CHGPRNCT")
    reply->chargeprncont_value = cnvtint(nv.pvc_value)
   ELSEIF (nv.pvc_name="TSK_CHGSCHED")
    reply->chargesched_value = cnvtint(nv.pvc_value)
   ELSEIF (nv.pvc_name="TSK_CHGADHOC")
    reply->chargeadhoc_value = cnvtint(nv.pvc_value)
   ELSEIF (nv.pvc_name="TSK_PRNNODTTM")
    reply->prnnodttm_value = cnvtint(nv.pvc_value)
   ELSEIF (nv.pvc_name="TSK_ENCNTROFFWITHLOC")
    reply->encntroffwithloc_value = cnvtint(nv.pvc_value)
   ENDIF
  DETAIL
   junk = junk
  FOOT  nv.pvc_name
   junk = junk
  FOOT REPORT
   junk = junk
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->chargeprncont_value = 0
  SET reply->chargesched_value = 0
  SET reply->prnnodttm_value = 0
  SET reply->encntroffwithloc_value = 0
  SET reply->chargeprncont_value = 0
  SET reply->chargesched_value = 0
 ENDIF
 SELECT INTO "NL:"
  FROM config_prefs cp
  WHERE cp.config_name IN ("NOTDNKEEPORD", "COMP_CONT_IV")
  DETAIL
   IF (cp.config_name="NOTDNKEEPORD")
    reply->notdnkeepord_value =
    IF (((cp.config_value="") OR (cp.config_value=null)) ) 0
    ELSE cnvtint(cp.config_value)
    ENDIF
   ELSEIF (cp.config_name="COMP_CONT_IV")
    reply->comp_cont_iv_value =
    IF (cp.config_value="TASK") "TASK"
    ELSE "STOPDTTM"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
