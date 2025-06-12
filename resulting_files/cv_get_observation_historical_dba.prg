CREATE PROGRAM cv_get_observation_historical:dba
 IF (validate(reply) != 1)
  RECORD reply(
    1 qual[*]
      2 cv_proc_id = f8
      2 order_id = f8
      2 person_id = f8
      2 encntr_id = f8
      2 catalog_cd = f8
      2 accession = vc
      2 matched_im_study_id = f8
      2 im_study_id = f8
      2 updt_cnt = i4
      2 pregnancystatus = f8
      2 request_dt_tm = dq8
      2 reference_txt = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET modify = nopredeclare
 IF ((ccldminfo->sec_org_reltn=1))
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
  CALL echo(build("authorized organizations:",size(sac_org->organizations,5)))
 ENDIF
 CALL echorecord(request)
 CALL echo(build("iOrgSecurity:",ccldminfo->sec_org_reltn))
 SET modify = predeclare
 DECLARE encounterlistsize = i4 WITH protect, noconstant(size(request->encntr_list,5))
 DECLARE personlistsize = i4 WITH protect, noconstant(size(request->person_list,5))
 DECLARE proclistsize = i2 WITH protect, noconstant(size(request->cv_proc_list,5))
 DECLARE orderlistsize = i2 WITH protect, noconstant(size(request->order_list,5))
 DECLARE modalitylistsize = i2 WITH protect, noconstant(size(request->modality_list,5))
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE reqprocid = vc WITH public, noconstant(" ")
 DECLARE reqprocidsize = i2 WITH public, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE mv = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MV"))
 DECLARE mvu = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MVU"))
 DECLARE buffer[110] = c150 WITH protect, noconstant(fillstring(150," "))
 DECLARE validcompdate = i2 WITH protect, noconstant(0)
 DECLARE studyclause = vc WITH protect, noconstant("")
 DECLARE matchstudylistsize = i4 WITH protect, constant(size(request->match_status_list,5))
 DECLARE mu = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MU"))
 DECLARE eventdocclasscd = f8 WITH protect, noconstant(0.0)
 DECLARE storagecd = f8 WITH protect, noconstant(0.0)
 DECLARE activecd = f8 WITH protect, noconstant(0.0)
 DECLARE andgiven = i2 WITH protect, noconstant(0)
 IF ((request->only_unpub_flag=1))
  SET eventdocclasscd = uar_get_code_by("MEANING",53,"DOC")
  SET storagecd = uar_get_code_by("MEANING",25,"DICOM_SIUID")
  SET activecd = uar_get_code_by("MEANING",48,"ACTIVE")
 ENDIF
 IF (matchstudylistsize != 0)
  SET studyclause = " s.study_state_cd in("
  FOR (i = 1 TO matchstudylistsize)
    SET studyclause = build(studyclause,request->match_status_list[i].match_status_cd,",")
  ENDFOR
  SET studyclause = substring(1,(textlen(studyclause) - 1),studyclause)
  SET studyclause = build(studyclause,")")
 ENDIF
 IF (cnvtdatetime(request->begin_comp_dt_tm) > 0
  AND cnvtdatetime(request->end_comp_dt_tm) > 0)
  SET validcompdate = 1
 ENDIF
 SET stat = alterlist(reply->qual,10)
 SET reply->status_data.status = "F"
 SET buffer[1] = "select"
 SET buffer[2] = 'into "nl:" *'
 SET x = 3
 IF ((request->im_study_id != 0))
  SET buffer[x] = "from cv_proc_hx cv,"
  SET buffer[(x+ 1)] = "im_study s,"
  SET buffer[(x+ 2)] = "im_study_parent_r pr "
  SET x += 3
 ELSE
  SET buffer[x] = "from cv_proc_hx cv"
  SET x += 1
  IF (matchstudylistsize != 0)
   SET buffer[x] = ", im_study s,"
   SET buffer[(x+ 1)] = "im_study_parent_r pr"
   SET x += 2
  ENDIF
 ENDIF
 IF ((ccldminfo->sec_org_reltn=1))
  SET buffer[x] = ", encounter e, organization org"
  SET x += 1
 ENDIF
 IF ((request->req_proc_id != ""))
  SET buffer[x] = ", code_value cv1"
  SET x += 1
 ENDIF
 IF ((((request->req_proc_desc != "")) OR (modalitylistsize > 0)) )
  SET buffer[x] = ", order_catalog order_cat"
  SET x += 1
 ENDIF
 IF (modalitylistsize > 0)
  SET buffer[x] = ", code_value_alias cva"
  SET x += 1
 ENDIF
 IF ((request->only_unpub_flag=1))
  SET buffer[x] = ",dummyt d"
  SET buffer[(x+ 1)] = ",clinical_event ce"
  SET buffer[(x+ 2)] = ",ce_blob_result blob"
  SET x += 3
 ENDIF
 IF ((request->im_study_id != 0))
  SET buffer[x] = "plan s where s.im_study_id = request->im_study_id"
  SET buffer[(x+ 1)] = 'and s.orig_entity_name = "CV_PROC_HX"'
  SET x += 2
  IF (matchstudylistsize != 0)
   SET buffer[x] = build2(" and ",studyclause)
   SET x += 1
  ENDIF
  SET buffer[x] = "join pr where s.im_study_id = pr.im_study_id"
  SET buffer[(x+ 1)] = "join cv where cv.cv_proc_hx_id = pr.parent_entity_id "
  SET andgiven = 1
  SET x += 2
 ELSE
  SET buffer[x] = "plan cv where"
  SET x += 1
 ENDIF
 IF ((request->accession != ""))
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  SET buffer[x] = "cv.frgn_sys_accession_reference = request->accession"
  SET x += 1
 ENDIF
 IF (orderlistsize != 0)
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  SET buffer[x] = "expand(num, 1, orderListSize, cv.order_id, request->order_list[num]->order_id)"
  SET x += 1
 ENDIF
 IF (personlistsize != 0)
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  SET buffer[x] =
  "expand(num, 1, personListSize, cv.person_id, request->person_list[num]->person_id)"
  SET x += 1
 ENDIF
 IF (proclistsize != 0)
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  SET buffer[x] =
  "expand(num, 1, procListSize, cv.cv_proc_hx_id, request->cv_proc_list[num]->cv_proc_id)"
  SET x += 1
 ELSE
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  SET buffer[x] = "cv.cv_proc_hx_id + 0!=0"
  SET x += 1
 ENDIF
 IF (encounterlistsize != 0)
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  SET buffer[x] =
  "expand(num, 1, encounterListSize, cv.encntr_id, request->encntr_list[num]->encntr_id)"
  SET x += 1
 ENDIF
 IF (cnvtdatetime(request->from_dt) > 0)
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  IF (cnvtdatetime(request->to_dt) <= 0)
   SET buffer[x] =
   "(cv.completed_dt_tm between cnvtdatetime(cnvtdate(cnvtdatetimeutc(request->from_dt,1)),0)"
   SET buffer[(x+ 1)] = "and cnvtdatetime(curdate,235959))"
   SET x += 2
  ELSE
   SET buffer[x] =
   "(cv.completed_dt_tm between cnvtdatetime(cnvtdate(cnvtdatetimeutc(request->from_dt,1)),0)"
   SET buffer[(x+ 1)] = "and cnvtdatetime(cnvtdate(cnvtdatetimeutc(request->to_dt,1)),235959))"
   SET x += 2
  ENDIF
 ENDIF
 IF (cnvtdatetime(request->begin_req_dt_tm) > 0
  AND cnvtdatetime(request->end_req_dt_tm) > 0)
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  SET buffer[x] =
  "cv.completed_dt_tm between cnvtdatetime(cnvtdate(cnvtdatetimeutc(request->begin_req_dt_tm,1)), 0) "
  SET buffer[(x+ 1)] =
  " and cnvtdatetime(cnvtdate(cnvtdatetimeutc(request->end_req_dt_tm,1)), 235959) "
  SET x += 2
 ENDIF
 IF (cnvtdatetime(request->study_date) > 0)
  IF (andgiven=0)
   SET andgiven = 1
  ELSE
   SET buffer[x] = "and "
   SET x += 1
  ENDIF
  SET buffer[x] =
  '(format(cv.completed_dt_tm,"YYYYMMDD;;d")=format(cnvtdatetimeutc(request->study_date,1),"YYYYMMDD;;d"))'
  SET x += 1
 ENDIF
 IF ((ccldminfo->sec_org_reltn=1))
  SET buffer[x] = "join e where e.encntr_id = cv.encntr_id"
  SET buffer[(x+ 1)] = "join org where e.organization_id = org.organization_id and"
  SET buffer[(x+ 2)] =
"expand(num,1,size(sac_org->organizations,5),org.organization_id+0,                            sac_org->organizations[num].\
organization_id)\
"
  SET x += 3
 ENDIF
 IF ((((request->req_proc_desc != "")) OR (modalitylistsize > 0)) )
  SET buffer[x] = "join order_cat where cv.order_catalog_cd = order_cat.catalog_cd"
  SET x += 1
  IF ((request->req_proc_desc != ""))
   SET buffer[x] =
   "and cnvtupper(order_cat.description) = patstring(cnvtupper(request->req_proc_desc))"
   SET x += 1
  ENDIF
  IF (modalitylistsize > 0)
   SET buffer[x] = "join cva where order_cat.activity_subtype_cd = cva.code_value"
   SET buffer[(x+ 1)] =
   "and expand(num,1,modalityListSize,cva.alias,request->modality_list[num]->modality)"
   SET x += 2
  ENDIF
 ENDIF
 IF ((request->req_proc_id != ""))
  SET reqprocidsize = size(request->req_proc_id,1)
  IF (substring(reqprocidsize,(reqprocidsize - 1),request->req_proc_id)="%")
   SET reqprocid = request->req_proc_id
  ELSE
   SET reqprocid = build2(request->req_proc_id,"*")
  ENDIF
  SET buffer[x] = "join cv1 where cv1.code_value = cv.order_catalog_cd"
  SET buffer[(x+ 1)] = "and cv1.code_set = 200"
  SET buffer[(x+ 2)] = "and cnvtupper(cv1.display) = patstring(cnvtupper(reqProcId))"
  SET x += 3
 ENDIF
 IF (matchstudylistsize != 0
  AND (request->im_study_id=0))
  SET buffer[x] =
  'join pr where pr.parent_entity_id = cv.cv_proc_hx_id and pr.parent_entity_name="CV_PROC_HX"'
  SET buffer[(x+ 1)] =
  'join s where s.im_study_id = pr.im_study_id and s.orig_entity_name = "CV_PROC_HX" and '
  SET buffer[(x+ 2)] = studyclause
  SET x += 3
 ENDIF
 IF ((request->only_unpub_flag=1))
  SET buffer[x] = "join d"
  SET buffer[(x+ 1)] =
  "join ce where ce.order_id = cv.order_id and ce.event_class_cd + 0 = eventDocClassCd and"
  SET buffer[(x+ 2)] = 'ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00") and'
  SET buffer[(x+ 3)] = "ce.record_status_cd = activeCd"
  SET buffer[(x+ 4)] =
  "join blob where blob.event_id = ce.event_id and blob.storage_cd+0 = storageCd"
  SET x += 5
 ENDIF
 SET buffer[x] = "order cv.cv_proc_hx_id"
 SET buffer[(x+ 1)] = "head cv.cv_proc_hx_id"
 SET buffer[(x+ 2)] = "count2 = 0"
 SET buffer[(x+ 3)] = "count = count + 1 "
 SET buffer[(x+ 4)] = "if (mod(count, 10) = 1 and (count > 1)) "
 SET buffer[(x+ 5)] = "stat = alterlist(reply->qual, count + 9) "
 SET buffer[(x+ 6)] = "endif "
 SET x += 7
 SET buffer[x] = "reply->qual[count]->cv_proc_id = cv.cv_proc_hx_id "
 SET x += 1
 IF ((request->load_ids_only != 1))
  SET buffer[x] = "reply->qual[count]->order_id = cv.order_id "
  SET buffer[(x+ 1)] = "reply->qual[count]->person_id = cv.person_id "
  SET buffer[(x+ 2)] = "reply->qual[count]->encntr_id = cv.encntr_id "
  SET buffer[(x+ 3)] = "reply->qual[count]->catalog_cd = cv.order_catalog_cd "
  SET buffer[(x+ 4)] = "reply->qual[count]->accession = cv.frgn_sys_accession_reference "
  SET buffer[(x+ 5)] = "reply->qual[count]->updt_cnt = cv.updt_cnt"
  SET buffer[(x+ 6)] = "reply->qual[count]->reference_txt = cv.reference_txt"
  SET x += 7
 ENDIF
 SET buffer[x] = "with nocounter go end"
 IF ((request->only_unpub_flag=1))
  SET buffer[x] = "with outerjoin = d, dontexist go end"
 ENDIF
 WHILE (count1 < x)
   SET count1 += 1
   CALL echo(buffer[count1])
   CALL parser(buffer[count1])
 ENDWHILE
 SET stat = alterlist(reply->qual,count)
 IF (count=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REPLY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Query 1 returned zero rows"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REPLY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Query 1 executed successfully"
 ENDIF
 SET x = 0
 IF (count != 0
  AND (request->load_ids_only=0))
  SET x = 1
  SET reply->status_data.status = "F"
  SET buffer[x] =
  'select into "nl:" * from cv_proc_hx cv,order_detail ord_dtl, (dummyt d with seq=value(count)), dummyt d1'
  SET x += 1
  IF ((request->load_pertains_study_ind=1))
   SET buffer[x] = " ,im_study st1"
   SET x += 1
  ENDIF
  IF ((request->load_link_study_ind=1))
   SET buffer[x] = " ,im_study st2, im_study_parent_r sr1"
   SET x += 1
  ENDIF
  SET buffer[x] = "plan d"
  SET buffer[(x+ 1)] = "join cv where cv.cv_proc_hx_id = reply->qual[d.seq]->cv_proc_id"
  SET x += 2
  IF ((request->load_pertains_study_ind=1))
   SET buffer[x] =
'join st1 where st1.orig_entity_id=outerjoin(cv.cv_proc_hx_id) and                             st1.orig_entity_name=outerjo\
in("CV_PROC_HX")\
'
   SET x += 1
  ENDIF
  IF ((request->load_link_study_ind=1))
   SET buffer[x] =
'join sr1 where sr1.parent_entity_id=outerjoin(cv.cv_proc_hx_id)                            and sr1.parent_entity_name=oute\
rjoin("CV_PROC_HX")\
'
   SET buffer[(x+ 1)] = "join st2 where st2.im_study_id = outerjoin(sr1.im_study_id)"
   SET x += 2
  ENDIF
  SET buffer[x] = "join d1"
  SET buffer[(x+ 1)] =
  'join ord_dtl where ord_dtl.order_id=reply->qual[d.seq]->order_id and ord_dtl.oe_field_meaning="PREGNANT"'
  SET buffer[(x+ 2)] =
  "and ord_dtl.action_sequence = (select max(od1.action_sequence) from order_detail od1"
  SET buffer[(x+ 3)] =
  'where  od1.order_id = reply->qual[d.seq]->order_id and od1.oe_field_meaning = "PREGNANT")'
  SET x += 4
  SET buffer[x] = "order cv.cv_proc_hx_id"
  SET buffer[(x+ 1)] = "head cv.cv_proc_hx_id"
  SET buffer[(x+ 2)] = "count2 = 0"
  SET buffer[(x+ 3)] = "reply->qual[d.seq]->pregnancyStatus = ord_dtl.oe_field_value "
  SET x += 4
  IF ((request->load_link_study_ind=1))
   SET buffer[x] =
   "if(st2.study_state_cd = mv or st2.study_state_cd = mvu or st2.study_state_cd = mu)"
   SET buffer[(x+ 1)] = "reply->qual[d.seq]->matched_im_study_id = st2.im_study_id"
   SET buffer[(x+ 2)] = "endif"
   SET x += 3
  ENDIF
  IF ((request->load_pertains_study_ind=1))
   SET buffer[x] = "reply->qual[d.seq]->im_study_id = st1.im_study_id"
   SET x += 1
  ENDIF
  SET buffer[x] = "with OUTERJOIN=d1, nocounter go"
 ENDIF
 SET count1 = 0
 WHILE (count1 < x)
   SET count1 += 1
   CALL echo(buffer[count1])
   CALL parser(buffer[count1])
 ENDWHILE
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectname = "REPLY"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Query 2 executed successfully"
END GO
