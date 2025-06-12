CREATE PROGRAM ct_get_filter_prescreen_list:dba
 RECORD paramlists(
   1 faccnt = i4
   1 fanyflag = i2
   1 fqual[*]
     2 faccd = f8
 )
 RECORD reply(
   1 prescreenlist[*]
     2 pt_prot_prescreen_id = f8
     2 prot_master_id = f8
     2 person_id = f8
     2 added_via_flag = i2
     2 last_name = vc
     2 first_name = vc
     2 full_name = vc
     2 birth_dt_tm = dq8
     2 sex_cd = f8
     2 race_cd = f8
     2 prot_alias = vc
     2 screening_dt_tm = dq8
     2 screener_person_id = f8
     2 screener_full_name = vc
     2 screening_status_cd = f8
     2 screening_status_disp = vc
     2 screening_status_desc = vc
     2 screening_status_mean = c12
     2 referral_dt_tm = dq8
     2 referral_person_id = f8
     2 referral_full_name = vc
     2 comment_text = vc
     2 reason_text = vc
     2 filename = vc
     2 displayable_docs_ind = i2
     2 cur_pt_elig_tracking_id = f8
     2 open_amendment_id = f8
     2 mrns[*]
       3 mrn = vc
       3 orgid = f8
       3 orgname = vc
       3 alias_pool_cd = f8
       3 alias_pool_disp = vc
       3 alias_pool_desc = vc
       3 alias_pool_mean = c12
   1 latest_prescreen_dt_tm = dq8
   1 latest_prescreen_person_id = f8
   1 latest_prescreen_full_name = vc
   1 pending_jobs = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 total_patients_cnt = f8
 )
 IF ( NOT (validate(pref_request,0)))
  RECORD pref_request(
    1 pref_entry = vc
  )
 ENDIF
 IF ( NOT (validate(pref_reply,0)))
  RECORD pref_reply(
    1 pref_value = i4
    1 pref_values[*]
      2 values = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD org_sec_reply(
   1 orgsecurityflag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD qualifiers(
   1 persons[*]
     2 person_id = f8
 )
 RECORD person(
   1 person_list[*]
     2 person_id = f8
     2 type = i2
     2 index = i2
     2 name_full_formatted = vc
 )
 DECLARE updatequeryforevaluationby(dummy) = null WITH protect
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE facility_cnt = i2 WITH protect, noconstant(0)
 DECLARE faccnt = i4 WITH protect, noconstant(0)
 DECLARE empty_facility_ind = i2 WITH protect, noconstant(0)
 DECLARE indx = i4 WITH public, noconstant(0)
 DECLARE inner_indx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE evaluationbywherestring = vc WITH protect, noconstant("")
 DECLARE facilitywherestring = vc WITH protect, noconstant("")
 DECLARE facstringformanuallyadded = vc WITH protect, noconstant("")
 DECLARE appointmentwherestring = vc WITH protect, noconstant("")
 DECLARE active_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE active_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 DECLARE discharged_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"DISCHARGED"))
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE num2 = i4 WITH public, noconstant(0)
 DECLARE facility_itr = i4 WITH protect, noconstant(0)
 DECLARE status_list_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_person_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_person_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE cur_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE batch_size = i2 WITH protect, noconstant(20)
 DECLARE cntm = i2 WITH protect, noconstant(0)
 DECLARE ndefaultinterest = i2 WITH protect, noconstant(0)
 DECLARE interest_where_string = vc WITH protect, noconstant("")
 DECLARE where_status = vc WITH protect
 DECLARE temp = vc WITH protect
 DECLARE it = i4 WITH protect, noconstant(0)
 DECLARE qualifier_cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_list_cnt = i4 WITH public, noconstant(0)
 DECLARE org_security_ind = i2 WITH protect, noconstant(0)
 DECLARE start_rownum = i4 WITH protect, noconstant(0)
 DECLARE end_rownum = i4 WITH protect, noconstant(0)
 DECLARE patient_cnt = i4 WITH protect, noconstant(0)
 DECLARE page_size = i4 WITH protect, noconstant(0)
 DECLARE page_num = i4 WITH protect, noconstant(0)
 DECLARE rowqualifier = vc WITH protect, noconstant(fillstring(30," "))
 DECLARE print_all = i4 WITH protect, noconstant(0)
 DECLARE mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE protocoldoccd = f8 WITH protect, noconstant(0.0)
 DECLARE opencd = f8 WITH protect, noconstant(0.0)
 DECLARE conceptcd = f8 WITH protect, noconstant(0.0)
 DECLARE enrollingcd = f8 WITH protect, noconstant(0.0)
 DECLARE eligiblecd = f8 WITH protect, noconstant(0.0)
 DECLARE elignoverifcd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancelcd = f8 WITH protect, noconstant(0.0)
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE protid = f8 WITH protect, noconstant(0.0)
 DECLARE start_dt = dq8 WITH protect, noconstant(0.0)
 DECLARE end_dt = dq8 WITH protect, noconstant(0.0)
 DECLARE joinconditionstringformanuallyadded = vc WITH protect, noconstant("")
 SET protid = request->protocols[1].protocolid
 SET start_dt = cnvtdatetime(request->start_dt_tm)
 SET end_dt = cnvtdatetime(request->end_dt_tm)
 SET org_security_ind = request->org_security_ind
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancelcd)
 SET stat = uar_get_meaning_by_codeset(17304,"PROTOCOL",1,protocoldoccd)
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,opencd)
 SET stat = uar_get_meaning_by_codeset(17274,"CONCEPT",1,conceptcd)
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrollingcd)
 SET stat = uar_get_meaning_by_codeset(17285,"ELIGIBLE",1,eligiblecd)
 SET stat = uar_get_meaning_by_codeset(17285,"ELIGNOVER",1,elignoverifcd)
 SET prot_list_cnt = size(request->protocols,5)
 SET status_list_cnt = size(request->statuslist,5)
 IF (status_list_cnt > 0)
  SET where_status = build("ppr.screening_status_cd in (",request->statuslist[1].status_cd)
  FOR (i = 2 TO status_list_cnt)
    SET temp = concat(trim(where_status),",",build(request->statuslist[i].status_cd))
    SET where_status = trim(temp)
    CALL echo(request->statuslist[i].status_cd)
  ENDFOR
  SET where_status = concat(where_status,")")
 ELSE
  SET where_status = "1=1"
 ENDIF
 IF ((org_security_ind=- (1)))
  EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
  IF ((org_sec_reply->orgsecurityflag=1))
   SET org_security_ind = 1
  ELSE
   SET org_security_ind = 0
  ENDIF
 ENDIF
 SET paramlists->fanyflag = 0
 SET facility_cnt = size(request->facilities,5)
 IF (facility_cnt < 1)
  SET empty_facility_ind = 1
  GO TO end_script
 ENDIF
 IF (org_security_ind=1)
  RECORD calling_fac_reply(
    1 skip = i2
    1 org_security_ind = i2
    1 org_security_fnd = i2
    1 facility_list[*]
      2 facility_display = vc
      2 facility_cd = f8
  )
  SET calling_fac_reply->skip = 1
  SET calling_fac_reply->org_security_ind = org_security_ind
  SET calling_fac_reply->org_security_fnd = 1
  EXECUTE ct_get_facility_list  WITH replace("FACILITYLIST","CALLING_FAC_REPLY")
  SET faccnt = size(calling_fac_reply->facility_list,5)
  SET cnt = 0
  IF (facility_cnt=1
   AND (request->facilities[1].facility_cd=0))
   SET stat = alterlist(paramlists->fqual,faccnt)
   FOR (indx = 1 TO faccnt)
     SET paramlists->fqual[indx].faccd = calling_fac_reply->facility_list[indx].facility_cd
   ENDFOR
   SET paramlists->faccnt = faccnt
  ELSE
   FOR (indx = 1 TO facility_cnt)
     FOR (inner_indx = 1 TO faccnt)
       IF ((request->facilities[indx].facility_cd=calling_fac_reply->facility_list[inner_indx].
       facility_cd))
        SET cnt += 1
        IF (mod(cnt,10)=1)
         SET stat = alterlist(paramlists->fqual,(cnt+ 9))
        ENDIF
        SET paramlists->fqual[cnt].faccd = request->facilities[indx].facility_cd
        SET inner_indx = faccnt
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(paramlists->fqual,cnt)
   SET paramlists->faccnt = cnt
  ENDIF
  IF ((paramlists->faccnt=0))
   SET empty_facility_ind = 1
   GO TO end_script
  ENDIF
  SET facstringformanuallyadded =
  "expand(facility_itr, 1, paramLists->facCnt,    	ee.loc_facility_cd, paramLists->fQual[facility_itr].facCd)"
  SET joinconditionstringformanuallyadded = "ee.person_id = pp.person_id"
 ELSE
  CALL echo("org security is off")
  IF (facility_cnt=1
   AND (request->facilities[1].facility_cd=0))
   SET paramlists->fanyflag = 1
  ELSE
   SET stat = alterlist(paramlists->fqual,facility_cnt)
   FOR (indx = 1 TO facility_cnt)
     SET paramlists->fqual[indx].faccd = request->facilities[indx].facility_cd
   ENDFOR
   SET paramlists->faccnt = facility_cnt
  ENDIF
  SET facstringformanuallyadded = "1=1"
  SET joinconditionstringformanuallyadded = "ee.person_id = outerjoin(pp.person_id)"
 ENDIF
 IF ((paramlists->fanyflag=1))
  SET facilitywherestring = "1=1"
 ELSE
  SET facilitywherestring =
  "expand(num2, 1, paramLists->facCnt, e.loc_facility_cd, paramLists->fQual[num2].facCd)"
 ENDIF
 SET pref_request->pref_entry = "default_interest"
 EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 CALL echo(build("pref",pref_reply->pref_value))
 IF ((pref_reply->pref_value=1))
  SET ndefaultinterest = 1
  SET interest_where_string = "cps.not_interested_ind = 0"
 ELSE
  SET ndefaultinterest = 0
  SET interest_where_string = "cps.not_interested_ind = 1"
 ENDIF
 SELECT INTO "nl:"
  FROM ct_pt_settings cps
  WHERE cps.active_ind=1
   AND parser(interest_where_string)
  ORDER BY cps.person_id
  DETAIL
   qualifier_cnt += 1
   IF (mod(qualifier_cnt,10)=1)
    stat = alterlist(qualifiers->persons,(qualifier_cnt+ 9))
   ENDIF
   qualifiers->persons[qualifier_cnt].person_id = cps.person_id
 ;end select
 SET stat = alterlist(qualifiers->persons,qualifier_cnt)
 IF (ndefaultinterest=1)
  SET interest_where_string =
  "expand(it, 1 , qualifier_cnt, ppr.person_id, qualifiers->persons[it].person_id)"
 ELSE
  SET interest_where_string =
  "not expand(it, 1, qualifier_cnt, ppr.person_id, qualifiers->persons[it].person_id)"
 ENDIF
 SET page_size = request->page_size
 SET page_num = request->page_num
 CALL echo(request->page_size)
 IF (page_size=0)
  SET print_all = 1
 ELSE
  SET start_rownum = ((page_size * (page_num - 1))+ 1)
  SET end_rownum = ((start_rownum+ page_size) - 1)
 ENDIF
 CALL updatequeryforevaluationby(null)
 CALL echo(evaluationbywherestring)
 SET cnt = 0
 IF ((request->eval_by < 2))
  SELECT INTO "nl:"
   prescreen_info.*, protocol_info.*
   FROM (
    (
    (SELECT DISTINCT INTO "nl:"
     pt_prot_prescreen_id = ppr.pt_prot_prescreen_id, prot_master_id = ppr.prot_master_id, person_id
      = p.person_id,
     last_name = p.name_last, first_name = p.name_first, full_name = p.name_full_formatted,
     birth_dt_tm = p.birth_dt_tm, sex_cd = p.sex_cd, race_cd = p.race_cd,
     screening_dt_tm = ppr.screened_dt_tm, screener_person_id = ppr.screener_person_id,
     screening_status_cd = ppr.screening_status_cd,
     referral_dt_tm = ppr.referred_dt_tm, referral_person_id = ppr.referred_person_id, comment_text
      = ppr.comment_text,
     reason_text = ppr.reason_text, added_via_flag = ppr.added_via_flag
     FROM encounter e,
      person p,
      pt_prot_prescreen ppr
     WHERE parser(evaluationbywherestring)
      AND parser(facilitywherestring)
      AND p.person_id=e.person_id
      AND p.active_ind=1
      AND ppr.person_id=p.person_id
      AND ppr.prot_master_id=protid
      AND ppr.added_via_flag != 1
      AND parser(interest_where_string)
      AND ppr.screening_status_cd != syscancelcd
      AND ((parser(where_status)) UNION (
     (SELECT INTO "nl:"
      pt_prot_prescreen_id = ppr.pt_prot_prescreen_id, prot_master_id = ppr.prot_master_id, person_id
       = pp.person_id,
      last_name = pp.name_last, first_name = pp.name_first, full_name = pp.name_full_formatted,
      birth_dt_tm = pp.birth_dt_tm, sex_cd = pp.sex_cd, race_cd = pp.race_cd,
      screening_dt_tm = ppr.screened_dt_tm, screener_person_id = ppr.screener_person_id,
      screening_status_cd = ppr.screening_status_cd,
      referral_dt_tm = ppr.referred_dt_tm, referral_person_id = ppr.referred_person_id, comment_text
       = ppr.comment_text,
      reason_text = ppr.reason_text, added_via_flag = ppr.added_via_flag
      FROM pt_prot_prescreen ppr,
       person pp,
       encounter ee
      WHERE ppr.added_via_flag=1
       AND ppr.prot_master_id=protid
       AND ppr.screening_status_cd != syscancelcd
       AND parser(where_status)
       AND pp.person_id=ppr.person_id
       AND pp.active_ind=1
       AND parser(joinconditionstringformanuallyadded)
       AND parser(facstringformanuallyadded))))
     WITH nocounter, rdbunion, sqltype("f8","f8","f8","vc","vc",
       "vc","dq8","f8","f8","dq8",
       "f8","f8","dq8","f8","vc",
       "vc","i2")))
    prescreen_info),
    (
    (
    (SELECT INTO "nl:"
     prot_master_id = pm.prot_master_id, prot_alias = pm.primary_mnemonic, open_amendment_id = pra
     .prot_amendment_id
     FROM prot_master pm,
      prot_amendment pra
     WHERE pm.prot_master_id=protid
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
      AND (pra.amendment_status_cd= Outerjoin(opencd))
     WITH nocounter, sqltype("f8","vc","f8")))
    protocol_info)
   WHERE protocol_info.prot_master_id=prescreen_info.prot_master_id
   ORDER BY cnvtupper(prescreen_info.last_name), cnvtupper(prescreen_info.first_name), prescreen_info
    .person_id
   HEAD REPORT
    cnt = 0, patient_cnt = 0
   HEAD prescreen_info.person_id
    CALL echo(prescreen_info.person_id), patient_cnt += 1
    IF (((print_all=1) OR (patient_cnt >= start_rownum
     AND patient_cnt <= end_rownum)) )
     cnt += 1
     IF (mod(cnt,100)=1)
      stat = alterlist(reply->prescreenlist,(cnt+ 99))
     ENDIF
     reply->prescreenlist[cnt].pt_prot_prescreen_id = prescreen_info.pt_prot_prescreen_id, reply->
     prescreenlist[cnt].prot_master_id = protocol_info.prot_master_id, reply->prescreenlist[cnt].
     person_id = prescreen_info.person_id,
     reply->prescreenlist[cnt].last_name = prescreen_info.last_name, reply->prescreenlist[cnt].
     first_name = prescreen_info.first_name, reply->prescreenlist[cnt].full_name = prescreen_info
     .full_name,
     reply->prescreenlist[cnt].birth_dt_tm = prescreen_info.birth_dt_tm, reply->prescreenlist[cnt].
     sex_cd = prescreen_info.sex_cd, reply->prescreenlist[cnt].race_cd = prescreen_info.race_cd,
     reply->prescreenlist[cnt].prot_alias = protocol_info.prot_alias, reply->prescreenlist[cnt].
     screening_dt_tm = prescreen_info.screening_dt_tm, reply->prescreenlist[cnt].screener_person_id
      = prescreen_info.screener_person_id,
     reply->prescreenlist[cnt].screening_status_cd = prescreen_info.screening_status_cd, reply->
     prescreenlist[cnt].referral_dt_tm = prescreen_info.referral_dt_tm, reply->prescreenlist[cnt].
     referral_person_id = prescreen_info.referral_person_id,
     reply->prescreenlist[cnt].comment_text = prescreen_info.comment_text, reply->prescreenlist[cnt].
     reason_text = prescreen_info.reason_text, reply->prescreenlist[cnt].open_amendment_id =
     protocol_info.open_amendment_id,
     reply->prescreenlist[cnt].added_via_flag = prescreen_info.added_via_flag
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->prescreenlist,cnt), reply->total_patients_cnt = patient_cnt,
    CALL echo(patient_cnt)
   WITH nocounter, orahintcbo(" GATHER_PLAN_STATISTICS ")
  ;end select
 ELSEIF ((request->eval_by=2))
  SELECT INTO "nl:"
   prescreen_info.*, protocol_info.*
   FROM (
    (
    (SELECT DISTINCT INTO "nl:"
     pt_prot_prescreen_id = ppr.pt_prot_prescreen_id, prot_master_id = ppr.prot_master_id, person_id
      = p.person_id,
     last_name = p.name_last, first_name = p.name_first, full_name = p.name_full_formatted,
     birth_dt_tm = p.birth_dt_tm, sex_cd = p.sex_cd, race_cd = p.race_cd,
     screening_dt_tm = ppr.screened_dt_tm, screener_person_id = ppr.screener_person_id,
     screening_status_cd = ppr.screening_status_cd,
     referral_dt_tm = ppr.referred_dt_tm, referral_person_id = ppr.referred_person_id, comment_text
      = ppr.comment_text,
     reason_text = ppr.reason_text, added_via_flag = ppr.added_via_flag
     FROM encounter e,
      person p,
      sch_appt sa,
      pt_prot_prescreen ppr
     WHERE parser(evaluationbywherestring)
      AND parser(facilitywherestring)
      AND parser(appointmentwherestring)
      AND p.person_id=e.person_id
      AND p.active_ind=1
      AND ppr.person_id=p.person_id
      AND ppr.prot_master_id=protid
      AND ppr.added_via_flag != 1
      AND parser(interest_where_string)
      AND ppr.screening_status_cd != syscancelcd
      AND ((parser(where_status)) UNION (
     (SELECT INTO "nl:"
      pt_prot_prescreen_id = ppr.pt_prot_prescreen_id, prot_master_id = ppr.prot_master_id, person_id
       = pp.person_id,
      last_name = pp.name_last, first_name = pp.name_first, full_name = pp.name_full_formatted,
      birth_dt_tm = pp.birth_dt_tm, sex_cd = pp.sex_cd, race_cd = pp.race_cd,
      screening_dt_tm = ppr.screened_dt_tm, screener_person_id = ppr.screener_person_id,
      screening_status_cd = ppr.screening_status_cd,
      referral_dt_tm = ppr.referred_dt_tm, referral_person_id = ppr.referred_person_id, comment_text
       = ppr.comment_text,
      reason_text = ppr.reason_text, added_via_flag = ppr.added_via_flag
      FROM pt_prot_prescreen ppr,
       person pp,
       encounter ee
      WHERE ppr.added_via_flag=1
       AND ppr.prot_master_id=protid
       AND ppr.screening_status_cd != syscancelcd
       AND parser(where_status)
       AND pp.person_id=ppr.person_id
       AND pp.active_ind=1
       AND parser(joinconditionstringformanuallyadded)
       AND parser(facstringformanuallyadded))))
     WITH nocounter, rdbunion, sqltype("f8","f8","f8","vc","vc",
       "vc","dq8","f8","f8","dq8",
       "f8","f8","dq8","f8","vc",
       "vc","i2")))
    prescreen_info),
    (
    (
    (SELECT INTO "nl:"
     prot_master_id = pm.prot_master_id, prot_alias = pm.primary_mnemonic, open_amendment_id = pra
     .prot_amendment_id
     FROM prot_master pm,
      prot_amendment pra
     WHERE pm.prot_master_id=protid
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
      AND (pra.amendment_status_cd= Outerjoin(opencd))
     WITH nocounter, sqltype("f8","vc","f8")))
    protocol_info)
   WHERE protocol_info.prot_master_id=prescreen_info.prot_master_id
   ORDER BY cnvtupper(prescreen_info.last_name), cnvtupper(prescreen_info.first_name), prescreen_info
    .person_id
   HEAD REPORT
    cnt = 0, patient_cnt = 0
   HEAD prescreen_info.person_id
    patient_cnt += 1
    IF (((print_all=1) OR (patient_cnt >= start_rownum
     AND patient_cnt <= end_rownum)) )
     cnt += 1
     IF (mod(cnt,100)=1)
      stat = alterlist(reply->prescreenlist,(cnt+ 99))
     ENDIF
     reply->prescreenlist[cnt].pt_prot_prescreen_id = prescreen_info.pt_prot_prescreen_id, reply->
     prescreenlist[cnt].prot_master_id = protocol_info.prot_master_id, reply->prescreenlist[cnt].
     person_id = prescreen_info.person_id,
     reply->prescreenlist[cnt].last_name = prescreen_info.last_name, reply->prescreenlist[cnt].
     first_name = prescreen_info.first_name, reply->prescreenlist[cnt].full_name = prescreen_info
     .full_name,
     reply->prescreenlist[cnt].birth_dt_tm = prescreen_info.birth_dt_tm, reply->prescreenlist[cnt].
     sex_cd = prescreen_info.sex_cd, reply->prescreenlist[cnt].race_cd = prescreen_info.race_cd,
     reply->prescreenlist[cnt].prot_alias = protocol_info.prot_alias, reply->prescreenlist[cnt].
     screening_dt_tm = prescreen_info.screening_dt_tm, reply->prescreenlist[cnt].screener_person_id
      = prescreen_info.screener_person_id,
     reply->prescreenlist[cnt].screening_status_cd = prescreen_info.screening_status_cd, reply->
     prescreenlist[cnt].referral_dt_tm = prescreen_info.referral_dt_tm, reply->prescreenlist[cnt].
     referral_person_id = prescreen_info.referral_person_id,
     reply->prescreenlist[cnt].comment_text = prescreen_info.comment_text, reply->prescreenlist[cnt].
     reason_text = prescreen_info.reason_text, reply->prescreenlist[cnt].open_amendment_id =
     protocol_info.open_amendment_id,
     reply->prescreenlist[cnt].added_via_flag = prescreen_info.added_via_flag
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->prescreenlist,cnt), reply->total_patients_cnt = patient_cnt
   WITH nocounter, orahintcbo(" GATHER_PLAN_STATISTICS ")
  ;end select
 ENDIF
 IF (cnt > 0)
  SET person_cnt = 0
  FOR (i = 1 TO cnt)
   IF ((reply->prescreenlist[i].screener_person_id > 0))
    SET person_cnt += 1
    SET stat = alterlist(person->person_list,person_cnt)
    SET person->person_list[person_cnt].person_id = reply->prescreenlist[i].screener_person_id
    SET person->person_list[person_cnt].index = i
    SET person->person_list[person_cnt].type = 1
   ENDIF
   IF ((reply->prescreenlist[i].referral_person_id > 0))
    SET person_cnt += 1
    SET stat = alterlist(person->person_list,person_cnt)
    SET person->person_list[person_cnt].person_id = reply->prescreenlist[i].referral_person_id
    SET person->person_list[person_cnt].index = i
    SET person->person_list[person_cnt].type = 2
   ENDIF
  ENDFOR
  IF ((reply->latest_prescreen_person_id > 0))
   SET person_cnt += 1
   SET stat = alterlist(person->person_list,person_cnt)
   SET person->person_list[person_cnt].person_id = reply->latest_prescreen_person_id
   SET person->person_list[person_cnt].index = - (1)
   SET person->person_list[person_cnt].type = 3
  ENDIF
  SET cur_list_cnt = size(person->person_list,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_cnt)/ batch_size))
  SET new_list_cnt = (batch_size * loop_cnt)
  SET stat = alterlist(person->person_list,new_list_cnt)
  FOR (i = (cur_list_cnt+ 1) TO new_list_cnt)
    SET person->person_list[i].person_id = person->person_list[cur_list_cnt].person_id
  ENDFOR
  SET num = 1
  SET nstart = 1
  SELECT INTO "NL:"
   p.name_first, p.name_last, p.name_full_formatted,
   p.person_id
   FROM person p,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(num,nstart,((nstart+ batch_size) - 1),p.person_id,person->person_list[num].person_id
     )
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    index = locateval(num,1,cur_list_cnt,p.person_id,person->person_list[num].person_id)
    WHILE (index > 0
     AND index <= cur_list_cnt)
     person->person_list[index].name_full_formatted = p.name_full_formatted,index = locateval(num,(
      index+ 1),cur_list_cnt,p.person_id,person->person_list[num].person_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(person->person_list,cur_list_cnt)
  FOR (i = 1 TO person_cnt)
    IF ((person->person_list[i].type=1))
     SET index = person->person_list[i].index
     SET reply->prescreenlist[index].screener_full_name = person->person_list[i].name_full_formatted
    ELSEIF ((person->person_list[i].type=2))
     SET index = person->person_list[i].index
     SET reply->prescreenlist[index].referral_full_name = person->person_list[i].name_full_formatted
    ELSEIF ((person->person_list[i].type=3))
     SET reply->latest_prescreen_full_name = person->person_list[i].name_full_formatted
    ENDIF
  ENDFOR
  SELECT INTO "NL:"
   pt.pt_elig_tracking_id
   FROM pt_elig_tracking pt,
    prot_amendment pa,
    prot_questionnaire pq,
    (dummyt d  WITH seq = value(cnt))
   PLAN (d)
    JOIN (pa
    WHERE (pa.prot_master_id=reply->prescreenlist[d.seq].prot_master_id))
    JOIN (pq
    WHERE pq.prot_amendment_id=pa.prot_amendment_id
     AND pq.questionnaire_type_cd=enrollingcd)
    JOIN (pt
    WHERE (pt.person_id=reply->prescreenlist[d.seq].person_id)
     AND pt.prot_questionnaire_id=pq.prot_questionnaire_id
     AND pt.elig_status_cd IN (elignoverifcd, eligiblecd))
   DETAIL
    reply->prescreenlist[d.seq].cur_pt_elig_tracking_id = pt.pt_elig_tracking_id
   WITH nocounter
  ;end select
  SET cur_person_list_cnt = size(reply->prescreenlist,5)
  SET loop_cnt = ceil((cnvtreal(cur_person_list_cnt)/ batch_size))
  SET new_person_list_cnt = (batch_size * loop_cnt)
  SET stat = alterlist(reply->prescreenlist,new_person_list_cnt)
  FOR (i = (cur_person_list_cnt+ 1) TO new_person_list_cnt)
    SET reply->prescreenlist[i].person_id = reply->prescreenlist[cur_person_list_cnt].person_id
  ENDFOR
  SET num = 1
  SET nstart = 1
  SELECT INTO "NL:"
   pa.alias, pa.alias_pool_cd
   FROM person_alias pa,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (pa
    WHERE expand(num,nstart,((nstart+ batch_size) - 1),pa.person_id,reply->prescreenlist[num].
     person_id)
     AND pa.person_alias_type_cd=mrn_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
   HEAD pa.person_id
    cntm = 0, index = 0
   DETAIL
    index = locateval(num,1,cur_person_list_cnt,pa.person_id,reply->prescreenlist[num].person_id)
    IF (index > 0)
     cntm += 1
    ENDIF
    WHILE (index > 0
     AND index <= cur_person_list_cnt)
      stat = alterlist(reply->prescreenlist[index].mrns,cntm), reply->prescreenlist[index].mrns[cntm]
      .mrn = cnvtalias(pa.alias,pa.alias_pool_cd), reply->prescreenlist[index].mrns[cntm].
      alias_pool_cd = pa.alias_pool_cd,
      index = locateval(num,(index+ 1),cur_person_list_cnt,pa.person_id,reply->prescreenlist[num].
       person_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->prescreenlist,cur_person_list_cnt)
 ENDIF
#end_script
 IF (empty_facility_ind=1)
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "No Data"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Facilities were empty"
 ENDIF
 SET reply->status_data.status = "S"
 SET last_mod = "001"
 SET mod_date = "May 9, 2019"
 SUBROUTINE updatequeryforevaluationby(dummy)
  SET appointmentwherestring = "1=1"
  IF ((request->eval_by=0))
   SET evaluationbywherestring =
   "e.reg_dt_tm BETWEEN cnvtdatetime(start_dt) 				and cnvtdatetime(end_dt)"
  ELSEIF ((request->eval_by=1))
   SET evaluationbywherestring =
"(e.active_ind = 1 and e.active_status_cd = ACTIVE_CD and e.reg_dt_tm <=                         cnvtdatetime(end_dt)) AND \
((e.encntr_status_cd = DISCHARGED_ENCNTR_CD and e.disch_dt_tm >=                         cnvtdatetime(start_dt)) OR (e.enc\
ntr_status_cd = ACTIVE_ENCNTR_CD and e.disch_dt_tm is NULL))\
"
  ELSEIF ((request->eval_by=2))
   SET evaluationbywherestring = "e.encntr_id > 0.0"
   SET appointmentwherestring =
"((sa.active_ind = 1 AND sa.encntr_id = e.encntr_id)                         AND (sa.beg_dt_tm BETWEEN cnvtdatetime(start_d\
t) AND cnvtdatetime(end_dt))                         AND (sa.state_meaning in ('SCHEDULED', 'RESCHEDULED','CHECKED IN','CH\
ECKED OUT','CONFIRMED')))\
"
  ENDIF
 END ;Subroutine
END GO
