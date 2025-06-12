CREATE PROGRAM aps_get_report_templates:dba
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
   1 qual[*]
     2 template_cd = f8
     2 template_disp = c40
     2 template_desc = vc
     2 template_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(_sacrtl_org_inc_,99999)=99999)
  DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
  RECORD sac_org(
    1 organizations[*]
      2 organization_id = f8
      2 confid_cd = f8
      2 confid_level = i4
  )
  EXECUTE secrtl
  EXECUTE sacrtl
  DECLARE orgcnt = i4 WITH protected, noconstant(0)
  DECLARE secstat = i2
  DECLARE logontype = i4 WITH protect, noconstant(- (1))
  DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
  DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
  DECLARE dynorg_enabled = i4 WITH constant(1)
  DECLARE dynorg_disabled = i4 WITH constant(0)
  DECLARE logontype_nhs = i4 WITH constant(1)
  DECLARE logontype_legacy = i4 WITH constant(0)
  DECLARE confid_cnt = i4 WITH protected, noconstant(0)
  RECORD confid_codes(
    1 list[*]
      2 code_value = f8
      2 coll_seq = f8
  )
  CALL uar_secgetclientlogontype(logontype)
  CALL echo(build("logontype:",logontype))
  IF (logontype != logontype_nhs)
   SET dynamic_org_ind = dynorg_disabled
  ENDIF
  IF (logontype=logontype_nhs)
   SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
     DECLARE scur_trust = vc
     DECLARE pref_val = vc
     DECLARE is_enabled = i4 WITH constant(1)
     DECLARE is_disabled = i4 WITH constant(0)
     SET scur_trust = cnvtstring(dtrustid)
     SET scur_trust = concat(scur_trust,".00")
     IF ( NOT (validate(pref_req,0)))
      RECORD pref_req(
        1 write_ind = i2
        1 delete_ind = i2
        1 pref[*]
          2 contexts[*]
            3 context = vc
            3 context_id = vc
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries[*]
            3 entry = vc
            3 values[*]
              4 value = vc
      )
     ENDIF
     IF ( NOT (validate(pref_rep,0)))
      RECORD pref_rep(
        1 pref[*]
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries[*]
            3 pref_exists_ind = i2
            3 entry = vc
            3 values[*]
              4 value = vc
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
     ENDIF
     SET stat = alterlist(pref_req->pref,1)
     SET stat = alterlist(pref_req->pref[1].contexts,2)
     SET stat = alterlist(pref_req->pref[1].entries,1)
     SET pref_req->pref[1].contexts[1].context = "organization"
     SET pref_req->pref[1].contexts[1].context_id = scur_trust
     SET pref_req->pref[1].contexts[2].context = "default"
     SET pref_req->pref[1].contexts[2].context_id = "system"
     SET pref_req->pref[1].section = "workflow"
     SET pref_req->pref[1].section_id = "UK Trust Security"
     SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
     EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
     IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
      RETURN(is_enabled)
     ELSE
      RETURN(is_disabled)
     ENDIF
   END ;Subroutine
   DECLARE hprop = i4 WITH protect, noconstant(0)
   DECLARE tmpstat = i2
   DECLARE spropname = vc
   DECLARE sroleprofile = vc
   SET hprop = uar_srvcreateproperty()
   SET tmpstat = uar_secgetclientattributesext(5,hprop)
   SET spropname = uar_srvfirstproperty(hprop)
   SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
   SELECT INTO "nl:"
    FROM prsnl_org_reltn_type prt,
     prsnl_org_reltn por
    PLAN (prt
     WHERE prt.role_profile=sroleprofile
      AND prt.active_ind=1
      AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (por
     WHERE (por.organization_id= Outerjoin(prt.organization_id))
      AND (por.person_id= Outerjoin(prt.prsnl_id))
      AND (por.active_ind= Outerjoin(1))
      AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY por.prsnl_org_reltn_id
    DETAIL
     orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
     sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
     confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
     sac_org->organizations[1].confid_level =
     IF (confid_cd > 0) confid_cd
     ELSE 0
     ENDIF
    WITH maxrec = 1
   ;end select
   SET dcur_trustid = sac_org->organizations[1].organization_id
   SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
   CALL uar_srvdestroyhandle(hprop)
  ENDIF
  IF (dynamic_org_ind=dynorg_disabled)
   SET confid_cnt = 0
   SELECT INTO "NL:"
    c.code_value, c.collation_seq
    FROM code_value c
    WHERE c.code_set=87
    DETAIL
     confid_cnt += 1
     IF (mod(confid_cnt,10)=1)
      secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
     ENDIF
     confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
     coll_seq = c.collation_seq
    WITH nocounter
   ;end select
   SET secstat = alterlist(confid_codes->list,confid_cnt)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
    HEAD REPORT
     IF (orgcnt > 0)
      secstat = alterlist(sac_org->organizations,100)
     ENDIF
    DETAIL
     orgcnt += 1
     IF (mod(orgcnt,100)=1)
      secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
     ENDIF
     sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
     orgcnt].confid_cd = por.confid_level_cd
    FOOT REPORT
     secstat = alterlist(sac_org->organizations,orgcnt)
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(orgcnt)),
     (dummyt d2  WITH seq = value(confid_cnt))
    PLAN (d1)
     JOIN (d2
     WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
    DETAIL
     sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
    WITH nocounter
   ;end select
  ELSEIF (dynamic_org_ind=dynorg_enabled)
   DECLARE nhstrustchild_org_org_reltn_cd = f8
   SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
   SELECT INTO "nl:"
    FROM org_org_reltn oor
    PLAN (oor
     WHERE oor.organization_id=dcur_trustid
      AND oor.active_ind=1
      AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
    HEAD REPORT
     IF (orgcnt > 0)
      secstat = alterlist(sac_org->organizations,10)
     ENDIF
    DETAIL
     IF (oor.related_org_id > 0)
      orgcnt += 1
      IF (mod(orgcnt,10)=1)
       secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
      ENDIF
      sac_org->organizations[orgcnt].organization_id = oor.related_org_id
     ENDIF
    FOOT REPORT
     secstat = alterlist(sac_org->organizations,orgcnt)
    WITH nocounter
   ;end select
  ELSE
   CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
  ENDIF
 ENDIF
 DECLARE lindex_var = i4 WITH protect, noconstant(1)
 DECLARE lend_pos = i4 WITH protect, noconstant(0)
 SET lend_pos = size(sac_org->organizations,5)
 SET reply->status_data.status = "F"
 DECLARE dtemplatefiltertype = f8 WITH protect, noconstant(0.0)
 DECLARE npersonorgind = i2 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE dfacilitytype = f8 WITH protect, noconstant(0.0)
 DECLARE spathnet_ap = c10 WITH protect, constant("PATHNET-AP")
 SET dfacilitytype = uar_get_code_by("MEANING",278,"FACILITY")
 IF (dfacilitytype <= 0)
  CALL subevent_add("UAR","F","UAR_GET_CODE_BY","278_FACILITY")
  GO TO exit_script
 ENDIF
 SET dtemplatefiltertype = uar_get_code_by("MEANING",30620,"CS14252")
 IF (dtemplatefiltertype <= 0)
  CALL subevent_add("UAR","F","UAR_GET_CODE_BY","30620_CS14252")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  f.parent_entity_id, template_found_ind = evaluate(nullind(f.parent_entity_id),0,1,0), stemplatetype
   = trim(uar_get_code_meaning(f.parent_entity_id))
  FROM filter_entity_reltn f,
   org_type_reltn o
  PLAN (o
   WHERE expand(lindex_var,1,lend_pos,o.organization_id,sac_org->organizations[lindex_var].
    organization_id)
    AND o.org_type_cd=dfacilitytype
    AND o.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN o.beg_effective_dt_tm AND o.end_effective_dt_tm)
   JOIN (f
   WHERE (f.filter_entity1_name= Outerjoin("ORGANIZATION"))
    AND (f.filter_entity1_id= Outerjoin(o.organization_id))
    AND (f.parent_entity_name= Outerjoin("CODE_VALUE"))
    AND (f.filter_type_cd= Outerjoin(dtemplatefiltertype))
    AND (f.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (f.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY f.parent_entity_id, 0
  HEAD REPORT
   lcnt = 0, npersonorgind = 1
  HEAD f.parent_entity_id
   IF (template_found_ind=1)
    IF (((stemplatetype=spathnet_ap) OR (((stemplatetype="") OR (stemplatetype=null)) )) )
     lcnt += 1
     IF (mod(lcnt,10)=1)
      stat = alterlist(reply->qual,(lcnt+ 9))
     ENDIF
     reply->qual[lcnt].template_cd = f.parent_entity_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  IF (npersonorgind=1)
   WHERE cv.code_set=14252
    AND cv.active_ind=1
    AND cv.cdf_meaning IN (spathnet_ap, "", null)
    AND  NOT ( EXISTS (
   (SELECT
    f.parent_entity_id
    FROM filter_entity_reltn f
    WHERE cv.code_value=f.parent_entity_id
     AND f.parent_entity_name="CODE_VALUE"
     AND ((f.filter_type_cd+ 0)=dtemplatefiltertype)
     AND f.filter_entity1_name="ORGANIZATION"
     AND cnvtdatetime(sysdate) BETWEEN f.beg_effective_dt_tm AND f.end_effective_dt_tm)))
  ELSE
   WHERE cv.code_set=14252
    AND cv.active_ind=1
    AND cv.cdf_meaning IN (spathnet_ap, "", null)
  ENDIF
  INTO "nl:"
  FROM code_value cv
  DETAIL
   lcnt += 1
   IF (mod(lcnt,10)=1)
    stat = alterlist(reply->qual,(lcnt+ 9))
   ENDIF
   reply->qual[lcnt].template_cd = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,lcnt)
 IF (lcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE RECORD sac_org
END GO
