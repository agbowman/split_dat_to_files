CREATE PROGRAM cpmstartup_tasksrv:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_tasksrv")
 CALL echo("Performance usage enabled...")
 CALL echo("RTL logging will be disabled except for errors")
 SET trace = nocallecho
 SET trace = server
 SET trace rangecache 200
 SET trace progcache 200
 SET trace progcachesize 100
 SET trace = noflush
 SET trace flush 600
 SET trace = notest
 SET trace = noechoinput
 SET trace = noechoinput2
 SET trace = noechorecord
 SET message = noinformation
 RECORD tasksrv_info(
   1 security_on = i2
 ) WITH persist
 SET tasksrv_info->security_on = 0
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="SECURITY"
    AND di.info_name="SEC_CONFID")
  DETAIL
   IF (di.info_number=1)
    tasksrv_info->security_on = 1
   ENDIF
  WITH nocounter
 ;end select
 RECORD code_val(
   1 doc = f8
   1 mdoc = f8
   1 grpdoc = f8
   1 onhold = f8
   1 complete = f8
   1 dropped = f8
   1 inerror = f8
   1 refused = f8
   1 deleted = f8
   1 canceled = f8
 ) WITH persist
 CALL uar_get_meaning_by_codeset(53,"DOC",1,code_val->doc)
 CALL uar_get_meaning_by_codeset(53,"MDOC",1,code_val->mdoc)
 CALL uar_get_meaning_by_codeset(53,"GRPDOC",1,code_val->grpdoc)
 CALL uar_get_meaning_by_codeset(79,"ONHOLD",1,code_val->onhold)
 CALL uar_get_meaning_by_codeset(79,"COMPLETE",1,code_val->complete)
 CALL uar_get_meaning_by_codeset(79,"DROPPED",1,code_val->dropped)
 CALL uar_get_meaning_by_codeset(79,"INERROR",1,code_val->inerror)
 CALL uar_get_meaning_by_codeset(79,"REFUSED",1,code_val->refused)
 CALL uar_get_meaning_by_codeset(79,"DELETED",1,code_val->deleted)
 CALL uar_get_meaning_by_codeset(79,"CANCELED",1,code_val->canceled)
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE ((c.code_set IN (8, 48, 57)) OR (c.code_set=89
   AND c.cdf_meaning="POWERCHART"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)))
  DETAIL
   IF (c.code_set=8)
    CASE (c.cdf_meaning)
     OF "AUTH":
      reqdata->data_status_cd = c.code_value,reqdata->auth_auth_cd = c.code_value
     OF "ACTIVE":
      reqdata->auth_active_cd = c.code_value
     OF "ALTERED":
      reqdata->auth_altered_cd = c.code_value
     OF "ANTICIPATED":
      reqdata->auth_anticipated_cd = c.code_value
     OF "CANCELLED":
      reqdata->auth_cancel_cd = c.code_value
     OF "IN ERROR":
      reqdata->auth_inerror_cd = c.code_value
     OF "IN LAB":
      reqdata->auth_inlab_cd = c.code_value
     OF "IN PROGRESS":
      reqdata->auth_inprogress_cd = c.code_value
     OF "MODIFIED":
      reqdata->auth_modified_cd = c.code_value
     OF "NOT DONE":
      reqdata->auth_notdone_cd = c.code_value
     OF "SUPERSEDED":
      reqdata->auth_superseded_cd = c.code_value
     OF "UNAUTH":
      reqdata->auth_unauth_cd = c.code_value
     OF "UNKNOWN":
      reqdata->auth_unknown_cd = c.code_value
    ENDCASE
   ELSEIF (c.code_set=48)
    CASE (c.cdf_meaning)
     OF "ACTIVE":
      reqdata->active_status_cd = c.code_value
     OF "INACTIVE":
      reqdata->inactive_status_cd = c.code_value
     OF "COMBINED":
      reqdata->combined_cd = c.code_value
     OF "COMBINEHIST":
      reqdata->combinedhist_cd = c.code_value
     OF "DELETED":
      reqdata->deleted_cd = c.code_value
     OF "REVIEWED":
      reqdata->reviewed_cd = c.code_value
     OF "SUSPENDED":
      reqdata->suspended_cd = c.code_value
     OF "UNKNOWN":
      reqdata->recstd_unknown_cd = c.code_value
    ENDCASE
   ELSEIF (c.code_set=57)
    CASE (c.cdf_meaning)
     OF "MALE":
      reqdata->male_cd = c.code_value
     OF "FEMALE":
      reqdata->female_cd = c.code_value
     OF "UNKNOWN":
      reqdata->unknown_sex_cd = c.code_value
    ENDCASE
   ELSEIF (c.code_set=89)
    reqdata->contributor_system_cd = c.code_value
   ENDIF
 ;end select
END GO
