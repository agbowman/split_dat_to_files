CREATE PROGRAM cpmstartup:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup")
 CALL echo("Performance usage enabled...")
 CALL echo("RTL logging will be disabled except for errors")
 SET trace = server
 SET trace rangecache 200
 SET trace progcache 250
 SET trace progcachesize 75
 SET trace = noflush
 SET trace flush 600
 SET trace = notest
 SET trace = noechoinput
 SET trace = noechoinput2
 SET trace = noechorecord
 SET message = noinformation
 IF (cnvtupper(curprcname)="SRV*")
  SET server_num = cnvtint(substring(4,4,curprcname))
 ELSE
  DECLARE _cmb_server = c4 WITH constant(substring(1,4,logical("CMB_SERVER")))
  SET server_num = cnvtint(_cmb_server)
  CALL echo(build("cpmstartup: Read CMB_SERVER logical, server_num= ",server_num))
 ENDIF
 IF (server_num > 0)
  IF (server_num IN (150, 151, 152, 170, 175))
   SET trace = noskipabort
  ENDIF
  IF (server_num IN (56, 58, 74, 79, 84,
  178, 179))
   DECLARE _ccl_rpt_audit = i2 WITH persist, noconstant(1)
   DECLARE _min_audit_secs = i4 WITH persist, noconstant(0)
   DECLARE _create_cpc = i2 WITH persist, noconstant(1)
   DECLARE _enable_custom_zoom = i2 WITH persist, noconstant(0)
   SET cclmpagertl_stat = checkdic("CCLMPAGERTL","P",0)
   IF (cclmpagertl_stat=2)
    EXECUTE cclmpagertl:dba
   ELSE
    CALL echo(build("Warning: Script CCLMPAGERTL not found. cclmpagertl_stat= ",cclmpagertl_stat))
   ENDIF
   IF (checkdic("CCL_OUTPUTVIEWER_CUST_ZOOM","P",0)=2)
    SET _enable_custom_zoom = 1
   ENDIF
  ENDIF
  IF (server_num IN (56, 74, 179))
   SET trace = skippersist
  ENDIF
 ENDIF
 SET oci_exists = checkdic("CCLUAR_OCI","P",0)
 IF (oci_exists=2)
  EXECUTE ccluar_oci "Y", 0
 ELSE
  CALL echo("CCLUAR_OCI not found. Bypassing UAR OCI init.")
 ENDIF
 SET trace = nocallecho
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE ((c.code_set IN (8, 48, 57)) OR (c.code_set=89
   AND c.cdf_meaning="POWERCHART"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm > cnvtdatetime(sysdate)))
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
  WITH nocounter
 ;end select
 IF (validate(ccldminfo->mode,2) != 2)
  SET ccldminfo->mode = 1
  SET ccldminfo->sec_org_reltn = 0
  SET ccldminfo->sec_confid = 0
  SET ccldminfo->person_org_sec = 0
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID", "PERSON_ORG_SEC"))
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     ccldminfo->sec_org_reltn = 1
    ELSEIF (di.info_name="SEC_CONFID"
     AND di.info_number=1)
     ccldminfo->sec_confid = 1
    ELSEIF (di.info_name="PERSON_ORG_SEC"
     AND di.info_number=1)
     ccldminfo->person_org_sec = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
END GO
