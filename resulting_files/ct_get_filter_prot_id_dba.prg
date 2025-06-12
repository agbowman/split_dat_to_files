CREATE PROGRAM ct_get_filter_prot_id:dba
 RECORD reply(
   1 sub_initserv_count = i2
   1 qual_group[*]
     2 initserv_cd = f8
     2 initserv_disp = vc
     2 initserv_desc = vc
     2 initserv_mean = vc
     2 sub_qual_group[*]
       3 sub_initserv_cd = f8
       3 sub_initserv_disp = vc
       3 initserv_cd = f8
   1 qual[*]
     2 prot_master_id = f8
     2 prot_status_cd = f8
     2 prot_status_disp = vc
     2 prot_status_desc = vc
     2 prot_status_mean = vc
     2 initserv_cd = f8
     2 initserv_disp = vc
     2 initserv_desc = vc
     2 initserv_mean = vc
     2 sub_initserv_cd = f8
     2 sub_initserv_disp = vc
     2 sub_initserv_desc = vc
     2 sub_initserv_mean = vc
     2 prot_alias = vc
     2 parent_prot_master_id = f8
     2 collab_site_org_id = f8
     2 parent_ind = i2
     2 enroll_id_ind = i2
     2 therapeutic_ind = i2
     2 prot_role_priv_ind = i2
     2 prot_del_ind = i2
     2 prot_prescreen_type = i2
     2 amend_qual[*]
       3 prot_amendment_id = f8
       3 amendment_status_cd = f8
       3 amendment_status_disp = vc
       3 amendment_status_desc = vc
       3 amendment_status_mean = vc
       3 amendment_nbr = i4
       3 amendment_dt_tm = dq8
       3 data_capture_ind = i2
       3 registry_ind = i2
       3 auto_enroll_ind = i2
       3 participation_type_cd = f8
       3 participation_type_disp = vc
       3 participation_type_desc = vc
       3 participation_type_mean = c12
       3 rev_qual[*]
         4 prot_amendment_id = f8
         4 revision_nbr = c30
         4 revision_seq = i4
         4 revision_status_cd = f8
         4 revision_status_disp = vc
         4 revision_status_desc = vc
         4 revision_status_mean = c12
         4 revision_dt_tm = dq8
         4 data_capture_ind = i2
         4 registry_ind = i2
         4 auto_enroll_ind = i2
         4 participation_type_cd = f8
         4 participation_type_disp = vc
         4 participation_type_desc = vc
         4 participation_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 RECORD pref_request(
   1 pref_entry = vc
 )
 FREE RECORD pref_reply
 RECORD pref_reply(
   1 pref_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE bstat = i2 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE queryfailed = c1 WITH protect, noconstant("F")
 DECLARE collaborator_cd = f8 WITH protect, noconstant(0.0)
 DECLARE participating_site_cd = f8 WITH protect, noconstant(0.0)
 DECLARE institution_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activated_cd = f8 WITH protect, noconstant(0.0)
 DECLARE protalias_cd = f8 WITH protect, noconstant(0.0)
 DECLARE invalid_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE init_service_cnt = i2 WITH protect, noconstant(0)
 DECLARE sub_init_service_cnt = i2 WITH protect, noconstant(0)
 DECLARE qual_cnt = i2 WITH protect, noconstant(0)
 DECLARE wsize = i2 WITH protect, noconstant(0)
 DECLARE tsize = i2 WITH protect, noconstant(0)
 DECLARE sselect = vc WITH protect, noconstant
 DECLARE sfromtable = vc WITH protect, noconstant
 DECLARE shead1 = vc WITH protect, noconstant
 DECLARE shead2 = vc WITH protect, noconstant
 DECLARE sdetail1 = vc WITH protect, noconstant
 DECLARE sdetail2 = vc WITH protect, noconstant
 DECLARE sdetail3 = vc WITH protect, noconstant
 DECLARE sdetail4 = vc WITH protect, noconstant
 DECLARE sdetail6 = vc WITH protect, noconstant
 DECLARE sdetail8 = vc WITH protect, noconstant
 DECLARE sdetail9 = vc WITH protect, noconstant
 DECLARE sdetail10 = vc WITH protect, noconstant
 DECLARE sdetail11 = vc WITH protect, noconstant
 DECLARE sdetail12 = vc WITH protect, noconstant
 DECLARE sdetail13 = vc WITH protect, noconstant
 DECLARE sdetail14 = vc WITH protect, noconstant
 DECLARE sdetail15 = vc WITH protect, noconstant
 DECLARE sdetail16 = vc WITH protect, noconstant
 DECLARE sdetail17 = vc WITH protect, noconstant
 DECLARE amd_cnt = i2 WITH protect, noconstant(0)
 DECLARE rev_cnt = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE therapeutic_mean = vc WITH protect, constant("THERAPEUTIC")
 DECLARE registry_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"REGISTRY"))
 DECLARE yes_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17907,"YES"))
 DECLARE init_service_codeset = f8 WITH protect, noconstant(0)
 DECLARE sub_init_service_codeset = f8 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE orgcnt = i4 WITH protect, noconstant(0)
 SET bstat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SET bstat = uar_get_meaning_by_codeset(17441,"COLLABORATOR",1,collaborator_cd)
 SET bstat = uar_get_meaning_by_codeset(17441,"PARTSITE",1,participating_site_cd)
 SET bstat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,institution_cd)
 SET bstat = uar_get_meaning_by_codeset(12801,"PROT_MASTER",1,protalias_cd)
 SET bstat = uar_get_meaning_by_codeset(17274,"INVALID",1,invalid_cd)
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET wsize = size(request->qual_where,5)
 SET tsize = size(request->qual_table,5)
 SET orgcnt = size(request->orgs,5)
 SET init_service_codeset = 17273
 SET sub_init_service_codeset = 4330005
 SET sselect = concat("Select distinct into ",char(34),"nl:",char(34))
 SET sfromtable = "From"
 SET shead1 = "Head Report"
 SET shead2 = "cnt = 0"
 SET sdetail1 = concat("Detail if (pm.network_flag < 2)")
 SET sdetail2 = "cnt = cnt +1"
 SET sdetail3 = "bstat = alterlist(reply->qual,cnt)"
 SET sdetail4 = "reply->qual[cnt]->prot_master_id = pm.prot_master_id"
 SET sdetail6 = "reply->qual[cnt]->prot_status_cd = pm.prot_status_cd"
 SET sdetail8 = "reply->qual[cnt]->initserv_cd = pm.initiating_service_cd"
 SET sdetail16 = "reply->qual[cnt]->sub_initserv_cd = pm.sub_initiating_service_cd"
 SET sdetail17 = "reply->qual[cnt]->prot_prescreen_type = pm.prescreen_type_flag"
 SET sdetail9 = "reply->qual[cnt]->prot_alias = pm.primary_mnemonic"
 SET sdetail10 = "reply->qual[cnt]->parent_prot_master_id = pm.parent_prot_master_id"
 SET sdetail11 = "reply->qual[cnt]->collab_site_org_id = pm.collab_site_org_id"
 SET sdetail13 = concat("if (pm.accession_nbr_sig_dig = -1) ","reply->qual[cnt]->enroll_id_ind = 0 ",
  "else ","reply->qual[cnt]->enroll_id_ind = 1 ","endif")
 SET sdetail14 = concat("if (uar_get_code_meaning(pm.prot_type_cd) = therapeutic_mean) ",
  "reply->qual[cnt]->therapeutic_ind = 1 ","else ","reply->qual[cnt]->therapeutic_ind = 0 ","endif")
 SET sdetail15 = "endif"
 SET sdetail12 = "with nocounter, expand = 2 go"
 IF (wsize > 0
  AND tsize > 0)
  CALL parser(sselect)
  CALL parser(sfromtable)
  FOR (i = 1 TO tsize)
    CALL parser(request->qual_table[i].q_str)
  ENDFOR
  FOR (i = 1 TO wsize)
    CALL parser(request->qual_where[i].q_str)
  ENDFOR
  CALL parser(shead1)
  CALL parser(shead2)
  CALL parser(sdetail1)
  CALL parser(sdetail2)
  CALL parser(sdetail3)
  CALL parser(sdetail4)
  CALL parser(sdetail6)
  CALL parser(sdetail8)
  CALL parser(sdetail16)
  CALL parser(sdetail17)
  CALL parser(sdetail9)
  CALL parser(sdetail10)
  CALL parser(sdetail11)
  CALL parser(sdetail13)
  CALL parser(sdetail14)
  CALL parser(sdetail15)
  CALL parser(sdetail12)
 ENDIF
 IF (cnt > 0)
  SET queryfailed = "S"
 ELSE
  SET queryfailed = "Z"
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.code_set=sub_init_service_codeset)
   JOIN (cv
   WHERE cvg.parent_code_value=cv.code_value
    AND cv.code_set=init_service_codeset)
  WITH nocounter
 ;end select
 SET reply->sub_initserv_count = curqual
 SET qual_cnt = size(request->groups,5)
 IF (qual_cnt > 0)
  SELECT INTO "nl:"
   FROM code_value c,
    (dummyt d  WITH seq = value(qual_cnt)),
    code_value_group cvg,
    code_value c1
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=request->groups[d.seq].group_cd)
     AND c.active_ind=1)
    JOIN (cvg
    WHERE (cvg.parent_code_value= Outerjoin(c.code_value))
     AND (cvg.code_set= Outerjoin(sub_init_service_codeset)) )
    JOIN (c1
    WHERE (c1.code_value= Outerjoin(cvg.child_code_value))
     AND (c1.code_set= Outerjoin(sub_init_service_codeset))
     AND (c1.active_ind= Outerjoin(1)) )
   ORDER BY c.display, c1.display
   HEAD REPORT
    init_service_cnt = 0
   HEAD c.display
    sub_init_service_cnt = 0, init_service_cnt += 1
    IF (init_service_cnt > size(reply->qual_group,5))
     bstat = alterlist(reply->qual_group,(init_service_cnt+ 5))
    ENDIF
    reply->qual_group[init_service_cnt].initserv_cd = c.code_value, reply->qual_group[
    init_service_cnt].initserv_disp = c.display
   DETAIL
    IF (c1.code_value > 0)
     sub_init_service_cnt += 1
     IF (sub_init_service_cnt > size(reply->qual_group[init_service_cnt].sub_qual_group,5))
      bstat = alterlist(reply->qual_group[init_service_cnt].sub_qual_group,(sub_init_service_cnt+ 5))
     ENDIF
     reply->qual_group[init_service_cnt].sub_qual_group[sub_init_service_cnt].sub_initserv_cd = c1
     .code_value, reply->qual_group[init_service_cnt].sub_qual_group[sub_init_service_cnt].
     sub_initserv_disp = c1.display, reply->qual_group[init_service_cnt].sub_qual_group[
     sub_init_service_cnt].initserv_cd = cvg.parent_code_value
    ENDIF
   FOOT  c.display
    bstat = alterlist(reply->qual_group[init_service_cnt].sub_qual_group,sub_init_service_cnt)
   FOOT REPORT
    bstat = alterlist(reply->qual_group,init_service_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value c,
    code_value_group cvg,
    code_value c1
   PLAN (c
    WHERE c.code_set=init_service_codeset
     AND c.active_ind=1)
    JOIN (cvg
    WHERE (cvg.parent_code_value= Outerjoin(c.code_value))
     AND (cvg.code_set= Outerjoin(sub_init_service_codeset)) )
    JOIN (c1
    WHERE (c1.code_value= Outerjoin(cvg.child_code_value))
     AND (c1.code_set= Outerjoin(sub_init_service_codeset))
     AND (c1.active_ind= Outerjoin(1)) )
   ORDER BY c.display, c1.display
   HEAD REPORT
    init_service_cnt = 0
   HEAD c.display
    sub_init_service_cnt = 0, init_service_cnt += 1
    IF (init_service_cnt > size(reply->qual_group,5))
     bstat = alterlist(reply->qual_group,(init_service_cnt+ 5))
    ENDIF
    reply->qual_group[init_service_cnt].initserv_cd = c.code_value, reply->qual_group[
    init_service_cnt].initserv_disp = c.display
   DETAIL
    IF (c1.code_value > 0)
     sub_init_service_cnt += 1
     IF (sub_init_service_cnt > size(reply->qual_group[init_service_cnt].sub_qual_group,5))
      bstat = alterlist(reply->qual_group[init_service_cnt].sub_qual_group,(sub_init_service_cnt+ 5))
     ENDIF
     reply->qual_group[init_service_cnt].sub_qual_group[sub_init_service_cnt].sub_initserv_cd = c1
     .code_value, reply->qual_group[init_service_cnt].sub_qual_group[sub_init_service_cnt].
     sub_initserv_disp = c1.display, reply->qual_group[init_service_cnt].sub_qual_group[
     sub_init_service_cnt].initserv_cd = cvg.parent_code_value
    ENDIF
   FOOT  c.display
    bstat = alterlist(reply->qual_group[init_service_cnt].sub_qual_group,sub_init_service_cnt)
   FOOT REPORT
    bstat = alterlist(reply->qual_group,init_service_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0
  AND init_service_cnt > 0)
  CALL report_failure("SELECT","F","CT_GET_FILTER_PROT_ID","Failed to retrieve initiating services.")
  GO TO exit_script
 ENDIF
 SET qual_cnt = size(reply->qual,5)
 IF (qual_cnt > 0)
  SELECT INTO "nl:"
   FROM prot_amendment pa,
    (dummyt d  WITH seq = value(qual_cnt)),
    prot_role pr
   PLAN (d)
    JOIN (pa
    WHERE (pa.prot_master_id=reply->qual[d.seq].prot_master_id))
    JOIN (pr
    WHERE pr.prot_amendment_id=pa.prot_amendment_id
     AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    IF ((pr.person_id=reqinfo->updt_id))
     reply->qual[d.seq].prot_role_priv_ind = 1
    ELSEIF (pr.person_id=0
     AND (pr.position_cd=reqinfo->position_cd))
     reply->qual[d.seq].prot_role_priv_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prot_master pm,
    (dummyt d  WITH seq = value(qual_cnt)),
    prot_amendment pa
   PLAN (d)
    JOIN (pm
    WHERE (pm.parent_prot_master_id=reply->qual[d.seq].prot_master_id)
     AND (pm.prot_master_id != reply->qual[d.seq].prot_master_id))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id)
   DETAIL
    reply->qual[d.seq].parent_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prot_master pm,
    (dummyt d  WITH seq = value(qual_cnt)),
    prot_amendment pa
   PLAN (d)
    JOIN (pm
    WHERE (pm.prot_master_id=reply->qual[d.seq].prot_master_id))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pm.end_effective_dt_tm <= cnvtdatetime(sysdate))
   DETAIL
    reply->qual[d.seq].prot_del_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prot_amendment am,
    ct_prot_type_config cfg,
    (dummyt d  WITH seq = value(qual_cnt))
   PLAN (d)
    JOIN (am
    WHERE (am.prot_master_id=reply->qual[d.seq].prot_master_id))
    JOIN (cfg
    WHERE cfg.protocol_type_cd=am.participation_type_cd
     AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND cfg.item_cd=registry_cd
     AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
   ORDER BY d.seq, am.amendment_nbr, am.revision_seq
   HEAD d.seq
    amd_cnt = 0,
    CALL echo(reply->qual[d.seq].prot_alias)
   HEAD am.amendment_nbr
    rev_cnt = 0
    IF (((am.revision_ind=0) OR ((reply->qual[d.seq].collab_site_org_id > 0))) )
     CALL echo(build("amd added, ",am.prot_amendment_id)), amd_cnt += 1
     IF (amd_cnt > size(reply->qual[d.seq].amend_qual,5))
      bstat = alterlist(reply->qual[d.seq].amend_qual,(amd_cnt+ 5))
     ENDIF
     reply->qual[d.seq].amend_qual[amd_cnt].prot_amendment_id = am.prot_amendment_id, reply->qual[d
     .seq].amend_qual[amd_cnt].amendment_nbr = am.amendment_nbr, reply->qual[d.seq].amend_qual[
     amd_cnt].amendment_status_cd = am.amendment_status_cd,
     reply->qual[d.seq].amend_qual[amd_cnt].amendment_dt_tm = am.amendment_dt_tm, reply->qual[d.seq].
     amend_qual[amd_cnt].data_capture_ind = am.data_capture_ind, reply->qual[d.seq].amend_qual[
     amd_cnt].auto_enroll_ind = am.dcv_auto_enroll_ind,
     reply->qual[d.seq].amend_qual[amd_cnt].participation_type_cd = am.participation_type_cd
     IF (cfg.config_value_cd=yes_cd)
      reply->qual[d.seq].amend_qual[amd_cnt].registry_ind = 1
     ELSE
      reply->qual[d.seq].amend_qual[amd_cnt].registry_ind = 0
     ENDIF
    ENDIF
   DETAIL
    IF (am.revision_ind=1)
     CALL echo(build("revision added, ",am.prot_amendment_id)), rev_cnt += 1
     IF (rev_cnt > size(reply->qual[d.seq].amend_qual[amd_cnt].rev_qual,5))
      bstat = alterlist(reply->qual[d.seq].amend_qual[amd_cnt].rev_qual,(rev_cnt+ 5))
     ENDIF
     reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].prot_amendment_id = am
     .prot_amendment_id, reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].revision_nbr = am
     .revision_nbr_txt, reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].revision_seq = am
     .revision_seq,
     reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].revision_status_cd = am
     .amendment_status_cd, reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].revision_dt_tm =
     am.amendment_dt_tm, reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].data_capture_ind =
     am.data_capture_ind,
     reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].auto_enroll_ind = am
     .dcv_auto_enroll_ind, reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].
     participation_type_cd = am.participation_type_cd
     IF (cfg.config_value_cd=yes_cd)
      reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].registry_ind = 1
     ELSE
      reply->qual[d.seq].amend_qual[amd_cnt].rev_qual[rev_cnt].registry_ind = 0
     ENDIF
    ENDIF
   FOOT  am.revision_seq
    bstat = alterlist(reply->qual[d.seq].amend_qual[amd_cnt].rev_qual,rev_cnt)
   FOOT  d.seq
    bstat = alterlist(reply->qual[d.seq].amend_qual,amd_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0
   AND amd_cnt > 0)
   CALL report_failure("SELECT","F","CT_GET_FILTER_PROT_ID",
    "Failed to retrieve amendments and revisions.")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = queryfailed
 ENDIF
 SET last_mod = "021"
 SET mod_date = "May 16, 2022"
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
