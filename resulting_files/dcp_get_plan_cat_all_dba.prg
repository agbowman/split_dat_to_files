CREATE PROGRAM dcp_get_plan_cat_all:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 pathway_catalog_id = f8
     2 description = vc
     2 active_ind = i2
     2 version = i4
     2 version_pw_cat_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 version_qual[*]
       3 pathway_catalog_id = f8
       3 version_pw_cat_id = f8
       3 description = vc
       3 active_ind = i2
       3 version = i4
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 updt_cnt = i4
     2 pw_evidence_reltn_id = f8
     2 evidence_locator = vc
     2 owner_name = vc
     2 ref_owner_person_id = f8
     2 phase_qual[*]
       3 pathway_catalog_id = f8
       3 description = vc
     2 facilityflexlist[*]
       3 facility_cd = f8
       3 facility_disp = c40
       3 facility_mean = c12
     2 power_trials[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE ndetailcnt = i4 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE highbuffer = c20 WITH noconstant(fillstring(20," "))
 DECLARE highvalues = vc
 DECLARE lowvalues = vc
 DECLARE get_versions_flag = c1 WITH noconstant("Y")
 DECLARE get_personal_plans_flag = c1 WITH noconstant("Y")
 DECLARE get_phase_flag = c1 WITH noconstant("Y")
 DECLARE get_facility_flag = c1 WITH noconstant("Y")
 DECLARE where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE nphasecnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE keyword = c1 WITH noconstant("N")
 DECLARE personal_plans_found_flag = c1 WITH noconstant("N")
 SET i18nhandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
 SET highvalues = trim(highbuffer)
 CALL uar_i18nalphabet_end(i18nhandle)
 SET reply->status_data.status = "F"
 SET lowvalues = trim(cnvtupper(request->description))
 IF (value(size(lowvalues,1)) >= 3)
  SET where_clause = "(pwc.description_key like '*"
  SET where_clause = concat(where_clause,cnvtupper(request->description))
  SET where_clause = concat(where_clause,"*'")
  SET keyword = "Y"
 ELSE
  SET where_clause = "((pwc.description_key BETWEEN LowValues AND HighValues)"
  SET keyword = "N"
 ENDIF
 SET where_clause = concat(where_clause," AND pwc.type_mean in ('PATHWAY','CAREPLAN')")
 SET where_clause = concat(where_clause," AND pwc.end_effective_dt_tm = cnvtdatetime('31-DEC-2100'))"
  )
 IF (((validate(request->personal_plans_ind,999)=999) OR (validate(request->personal_plans_ind,999)=0
 )) )
  SET where_clause = concat(where_clause," AND pwc.ref_owner_person_id = 0")
  SET get_personal_plans_flag = "N"
 ENDIF
 IF (validate(request->sub_phase_ind,999)=1)
  SET where_clause = concat(where_clause," AND pwc.sub_phase_ind = request->sub_phase_ind")
  SET where_clause = concat(where_clause,
   " AND pwc.beg_effective_dt_tm <= cnvtdatetime(CURDATE,CURTIME3)")
 ENDIF
 IF (validate(request->active_version_ind,999)=999)
  SET get_versions_flag = "Y"
 ELSE
  IF ((request->active_version_ind=1))
   SET get_versions_flag = "N"
   SET where_clause = concat(where_clause," AND pwc.active_ind = 1")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  pwc.description_key, pwc.type_mean, pwc.version,
  pwc.updt_cnt, per.type_mean
  FROM pathway_catalog pwc,
   pw_evidence_reltn per
  PLAN (pwc
   WHERE parser(where_clause))
   JOIN (per
   WHERE per.pathway_catalog_id=outerjoin(pwc.pathway_catalog_id))
  ORDER BY pwc.description_key, pwc.version_pw_cat_id, pwc.version DESC
  HEAD REPORT
   ncnt = 0
  HEAD pwc.description_key
   dummy = 0
  HEAD pwc.version_pw_cat_id
   flag = pwc.version
  HEAD pwc.version
   IF (pwc.version=flag)
    ncnt = (ncnt+ 1)
    IF (((keyword="N"
     AND ncnt <= 50) OR (keyword="Y")) )
     IF (ncnt > size(reply->qual,5))
      stat = alterlist(reply->qual,(ncnt+ 20))
     ENDIF
     reply->qual[ncnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->qual[ncnt].description =
     trim(pwc.description), reply->qual[ncnt].active_ind = pwc.active_ind,
     reply->qual[ncnt].version = pwc.version, reply->qual[ncnt].beg_effective_dt_tm = pwc
     .beg_effective_dt_tm, reply->qual[ncnt].end_effective_dt_tm = pwc.end_effective_dt_tm,
     reply->qual[ncnt].updt_cnt = pwc.updt_cnt
     IF (pwc.version_pw_cat_id > 0)
      reply->qual[ncnt].version_pw_cat_id = pwc.version_pw_cat_id
     ELSE
      reply->qual[ncnt].version_pw_cat_id = pwc.pathway_catalog_id
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (pwc.version=flag)
    IF (((keyword="N"
     AND ncnt <= 50) OR (keyword="Y")) )
     IF (per.dcp_clin_cat_cd=0
      AND per.dcp_clin_sub_cat_cd=0
      AND per.pathway_comp_id=0)
      IF (per.type_mean="REFTEXT")
       reply->qual[ncnt].pw_evidence_reltn_id = per.pw_evidence_reltn_id
      ENDIF
      IF (((per.type_mean="ZYNX") OR (per.type_mean="URL")) )
       reply->qual[ncnt].evidence_locator = per.evidence_locator
      ENDIF
     ENDIF
     IF (get_personal_plans_flag="Y")
      reply->qual[ncnt].ref_owner_person_id = pwc.ref_owner_person_id
      IF (personal_plans_found_flag="N")
       personal_plans_found_flag = "Y"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  pwc.description_key
   ncnt = ncnt
  FOOT REPORT
   IF (((keyword="N"
    AND ncnt <= 50) OR (keyword="Y")) )
    stat = alterlist(reply->qual,ncnt)
   ELSEIF (keyword="N"
    AND ncnt > 50)
    stat = alterlist(reply->qual,50)
   ENDIF
  WITH nocounter
 ;end select
 IF (value(size(reply->qual,5)) <= 0)
  GO TO exit_script
 ENDIF
 IF (get_personal_plans_flag="Y"
  AND personal_plans_found_flag="Y")
  SELECT INTO "nl:"
   FROM prsnl p,
    (dummyt d  WITH seq = value(size(reply->qual,5)))
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=reply->qual[d.seq].ref_owner_person_id))
   HEAD REPORT
    dummy = 0
   DETAIL
    reply->qual[d.seq].owner_name = trim(p.name_full_formatted)
   FOOT REPORT
    dummy = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (get_versions_flag="Y")
  SELECT INTO "nl:"
   plan_id = reply->qual[d.seq].pathway_catalog_id
   FROM pathway_catalog pwc,
    (dummyt d  WITH seq = value(size(reply->qual,5)))
   PLAN (d)
    JOIN (pwc
    WHERE (pwc.version_pw_cat_id=reply->qual[d.seq].version_pw_cat_id)
     AND (pwc.version != reply->qual[d.seq].version))
   ORDER BY plan_id, pwc.version
   HEAD REPORT
    ncnt = 0
   HEAD plan_id
    ncnt = 0
   DETAIL
    IF (pwc.pathway_catalog_id > 0)
     ncnt = (ncnt+ 1)
     IF (ncnt > size(reply->qual[d.seq].version_qual,5))
      stat = alterlist(reply->qual[d.seq].version_qual,(ncnt+ 10))
     ENDIF
     reply->qual[d.seq].version_qual[ncnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->qual[d
     .seq].version_qual[ncnt].version_pw_cat_id = pwc.version_pw_cat_id, reply->qual[d.seq].
     version_qual[ncnt].description = trim(pwc.description),
     reply->qual[d.seq].version_qual[ncnt].active_ind = pwc.active_ind, reply->qual[d.seq].
     version_qual[ncnt].version = pwc.version, reply->qual[d.seq].version_qual[ncnt].
     beg_effective_dt_tm = pwc.beg_effective_dt_tm,
     reply->qual[d.seq].version_qual[ncnt].end_effective_dt_tm = pwc.end_effective_dt_tm, reply->
     qual[d.seq].version_qual[ncnt].updt_cnt = pwc.updt_cnt
    ENDIF
   FOOT  plan_id
    stat = alterlist(reply->qual[d.seq].version_qual,ncnt)
   FOOT REPORT
    ncnt = ncnt
   WITH nocounter
  ;end select
 ENDIF
 IF (((validate(request->phase_ind,999)=999) OR (validate(request->phase_ind,999)=0)) )
  SET get_phase_flag = "N"
 ENDIF
 IF (get_phase_flag="Y")
  SET ncnt = value(size(reply->qual,5))
  SET num = 0
  SELECT INTO "nl:"
   pcr.pw_cat_s_id, pcr.pw_cat_t_id, pcr.type_mean,
   pc.pathway_catalog_id, pc.description
   FROM pw_cat_reltn pcr,
    pathway_catalog pc
   PLAN (pcr
    WHERE expand(num,1,ncnt,pcr.pw_cat_s_id,reply->qual[num].pathway_catalog_id)
     AND pcr.type_mean="GROUP")
    JOIN (pc
    WHERE pc.pathway_catalog_id=pcr.pw_cat_t_id
     AND pc.type_mean="PHASE")
   ORDER BY pcr.pw_cat_s_id
   HEAD REPORT
    idx = 0
   HEAD pcr.pw_cat_s_id
    nphasecnt = 0, idx = locateval(idx,1,ncnt,pcr.pw_cat_s_id,reply->qual[idx].pathway_catalog_id)
   DETAIL
    nphasecnt = (nphasecnt+ 1)
    IF (nphasecnt > size(reply->qual[idx].phase_qual,5))
     stat = alterlist(reply->qual[idx].phase_qual,(nphasecnt+ 10))
    ENDIF
    reply->qual[idx].phase_qual[nphasecnt].pathway_catalog_id = pc.pathway_catalog_id, reply->qual[
    idx].phase_qual[nphasecnt].description = trim(pc.description)
   FOOT  pcr.pw_cat_s_id
    stat = alterlist(reply->qual[idx].phase_qual,nphasecnt)
   FOOT REPORT
    nphasecnt = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (((validate(request->facility_flexing_ind,999)=999) OR (validate(request->facility_flexing_ind,
  999)=0)) )
  SET get_facility_flag = "N"
 ENDIF
 IF (get_facility_flag="Y")
  DECLARE facilitycnt = i4 WITH noconstant(0), protect
  SET ncnt = value(size(reply->qual,5))
  SET num = 0
  SELECT INTO "nl:"
   FROM pw_cat_flex pcf
   PLAN (pcf
    WHERE expand(num,1,ncnt,pcf.pathway_catalog_id,reply->qual[num].pathway_catalog_id)
     AND pcf.parent_entity_name="CODE_VALUE"
     AND pcf.parent_entity_id != 0)
   ORDER BY pcf.pathway_catalog_id
   HEAD REPORT
    idx = 0
   HEAD pcf.pathway_catalog_id
    facilitycnt = 0, idx = locateval(idx,1,ncnt,pcf.pathway_catalog_id,reply->qual[idx].
     pathway_catalog_id)
   DETAIL
    facilitycnt = (facilitycnt+ 1)
    IF (facilitycnt > size(reply->qual[idx].facilityflexlist,5))
     stat = alterlist(reply->qual[idx].facilityflexlist,(facilitycnt+ 5))
    ENDIF
    reply->qual[idx].facilityflexlist[facilitycnt].facility_cd = pcf.parent_entity_id
   FOOT  pcf.pathway_catalog_id
    stat = alterlist(reply->qual[idx].facilityflexlist,facilitycnt)
   FOOT REPORT
    facilitycnt = 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load_trial_plan_ind > 0))
  DECLARE powertrialcnt = i4 WITH noconstant(0), protect
  SET ncnt = value(size(reply->qual,5))
  SET num = 0
  SELECT INTO "nl:"
   FROM pw_pt_reltn ppr,
    prot_master pm
   WHERE expand(num,1,ncnt,ppr.pathway_catalog_id,reply->qual[num].pathway_catalog_id)
    AND ppr.prot_master_id=pm.prot_master_id
    AND ppr.active_ind=1
   ORDER BY ppr.pathway_catalog_id
   HEAD REPORT
    idx = 0
   HEAD ppr.pathway_catalog_id
    powertrialcnt = 0, idx = locateval(idx,1,ncnt,ppr.pathway_catalog_id,reply->qual[idx].
     pathway_catalog_id)
   DETAIL
    dcurdate = cnvtdatetime(curdate,curtime3), dbegdate = cnvtdatetime(ppr.beg_effective_dt_tm),
    denddate = cnvtdatetime(ppr.end_effective_dt_tm),
    dlowdate = datetimediff(dcurdate,dbegdate), dhighdate = datetimediff(dcurdate,denddate)
    IF (dlowdate > 0
     AND dhighdate < 0)
     powertrialcnt = (powertrialcnt+ 1)
     IF (powertrialcnt > size(reply->qual[idx].power_trials,5))
      stat = alterlist(reply->qual[idx].power_trials,(powertrialcnt+ 5))
     ENDIF
     reply->qual[idx].power_trials[powertrialcnt].prot_master_id = ppr.prot_master_id, reply->qual[
     idx].power_trials[powertrialcnt].primary_mnemonic = pm.primary_mnemonic
    ENDIF
   FOOT  ppr.pathway_catalog_id
    IF (powertrialcnt > 0)
     stat = alterlist(reply->qual[idx].power_trials,powertrialcnt)
    ENDIF
   FOOT REPORT
    powertrialcnt = 0
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
