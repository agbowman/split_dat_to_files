CREATE PROGRAM ct_he_prescreen_filter:dba
 RECORD qualified_patients(
   1 persons[*]
     2 person_id = f8
 )
 RECORD eval_pt_request(
   1 persons[*]
     2 person_id = f8
   1 job_id = f8
   1 protocol_id = f8
   1 screener_id = f8
 )
 DECLARE equal_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17913,"EQUAL"))
 DECLARE grtrthan_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17913,"GRTRTHAN"))
 DECLARE grtrthaneq_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17913,"GRTRTHANEQ")
  )
 DECLARE lessthan_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17913,"LESSTHAN"))
 DECLARE lessthaneq_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17913,"LESSTHANEQ")
  )
 DECLARE notequal_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17913,"NOTEQUAL"))
 DECLARE between_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17913,"BETWEEN"))
 DECLARE encounter_date = i1 WITH protect, constant(0)
 DECLARE active_encounter = i1 WITH protect, constant(1)
 DECLARE appt_date = i1 WITH protect, constant(2)
 DECLARE active_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE active_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 DECLARE discharged_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"DISCHARGED"))
 DECLARE batch_size = i4 WITH protect, constant(5000)
 DECLARE he_job_type = i2 WITH protect, constant(3)
 DECLARE pending_job_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"PENDING")
  )
 DECLARE logical_domain_id = f8 WITH protect, noconstant(0)
 DECLARE enctr_type_qual = vc WITH protect, noconstant("1=1")
 DECLARE facility_qual = vc WITH protect, noconstant("1=1")
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE enctr_type_cnt = i4 WITH protect, noconstant(size(request->encntr_type_lst,5))
 DECLARE facility_cnt = i4 WITH protect, noconstant(size(request->facility_lst,5))
 DECLARE org_based_fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE gender_qual = vc WITH protect, noconstant("1=1")
 DECLARE age_qual = vc WITH protect, noconstant("1=1")
 DECLARE age_start_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE age_end_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE age1_lookback = vc WITH protect
 DECLARE age2_lookback = vc WITH protect
 DECLARE race_qual = vc WITH protect, noconstant("1=1")
 DECLARE ethnicity_qual = vc WITH protect, noconstant("1=1")
 DECLARE codes_qual = vc WITH protect, noconstant("1=1")
 DECLARE codes_cnt = i4 WITH protect, noconstant(size(request->codes,5))
 DECLARE patient_cnt = i4 WITH protect, noconstant(0)
 DECLARE eval_by_qual = vc WITH protect, noconstant("1=1")
 DECLARE appt_qual = vc WITH protect, noconstant("1=1")
 DECLARE bfound = i1 WITH protect, noconstant(0)
 CALL echo("Retrieving logical domain id")
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=request->screener_id)
  DETAIL
   logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 CALL echo(build("Logical domain",logical_domain_id))
 CALL echorecord(request)
 SET prescreen_parent_job_id = request->parent_job_id
 CALL echo(build("the job id is:",prescreen_parent_job_id))
 IF (enctr_type_cnt > 0)
  SET enctr_type_qual =
  "expand(idx, 1 , enctr_type_cnt, e.encntr_type_cd, request->encntr_type_lst[idx]->encntr_type_cd)"
 ENDIF
 CALL echo(build("encounter qual : ",enctr_type_qual))
 IF (facility_cnt > 0)
  SET facility_qual =
  "expand(idx, 1, facility_cnt, e.loc_facility_cd, request->facility_lst[idx]->facility_cd)"
 ENDIF
 CALL echo(build("facility qual : ",facility_qual))
 IF ((request->gender_cd > 0))
  SET gender_qual = "p.sex_cd = request->gender_cd"
 ENDIF
 CALL echo(build("gender qual : ",gender_qual))
 CASE (request->age_qualifier_cd)
  OF grtrthan_type_cd:
   IF ((request->age1 > 0))
    SET age1_lookback = build("'",(request->age1+ 1),";Y'")
    SET age_start_dt_tm = cnvtlookbehind(age1_lookback)
    SET age_start_dt_tm = datetimeadd(age_start_dt_tm,1)
    SET age2_lookback = build("'",150,";Y'")
    SET age_end_dt_tm = cnvtlookbehind(age2_lookback)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(age_end_dt_tm) AND cnvtdatetime(age_start_dt_tm)")
   ENDIF
  OF grtrthaneq_type_cd:
   IF ((request->age1 > 0))
    SET age1_lookback = build("'",(request->age1+ 1),";Y'")
    SET age_start_dt_tm = cnvtlookbehind(age1_lookback)
    SET age2_lookback = build("'",150,";Y'")
    SET age_end_dt_tm = cnvtlookbehind(age2_lookback)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(age_end_dt_tm) AND cnvtdatetime(age_start_dt_tm)")
   ENDIF
  OF lessthan_type_cd:
   IF ((request->age1 > 0))
    SET age_start_dt_tm = cnvtdatetime(sysdate)
    SET age1_lookback = build("'",request->age1,";Y'")
    SET age_end_dt_tm = cnvtlookbehind(age1_lookback)
    SET age_end_dt_tm = datetimeadd(age_end_dt_tm,1)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(age_end_dt_tm) AND cnvtdatetime(age_start_dt_tm)")
   ENDIF
  OF lessthaneq_type_cd:
   IF ((request->age1 > 0))
    SET age_start_dt_tm = cnvtdatetime(sysdate)
    SET age1_lookback = build("'",(request->age1+ 1),";Y'")
    SET age_end_dt_tm = cnvtlookbehind(age1_lookback)
    SET age_end_dt_tm = datetimeadd(age_end_dt_tm,1)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(age_end_dt_tm) AND cnvtdatetime(age_start_dt_tm)")
   ENDIF
  OF between_type_cd:
   IF ((request->age1 >= 0)
    AND (request->age2 > 0))
    SET age1_lookback = build("'",request->age1,";Y'")
    SET age_start_dt_tm = cnvtlookbehind(age1_lookback)
    SET age2_lookback = build("'",(request->age2+ 1),";Y'")
    SET age_end_dt_tm = cnvtlookbehind(age2_lookback)
    SET age_end_dt_tm = datetimeadd(age_end_dt_tm,1)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(age_end_dt_tm) AND cnvtdatetime(age_start_dt_tm)")
   ENDIF
 ENDCASE
 CALL echo(build("age qual : ",age_qual))
 IF ((request->race_cd > 0))
  SET race_qual = "p.race_cd = request->race_cd"
 ENDIF
 CALL echo(build("race qual : ",race_qual))
 IF ((request->ethnic_grp_cd > 0))
  SET ethnicity_qual = "p.ethnic_grp_cd = request->ethnic_grp_cd"
 ENDIF
 CALL echo(build("ethnicity qual : ",ethnicity_qual))
 IF (codes_cnt > 0)
  SET codes_qual =
  "expand(idx, 1, codes_cnt, n.source_identifier, request->codes[idx]->source_identifier)"
 ENDIF
 CALL echo(build("codes qual : ",codes_qual))
 CASE (request->eval_by)
  OF encounter_date:
   SET eval_by_qual =
   "e.reg_dt_tm BETWEEN cnvtdatetime(request->start_dt) and cnvtdatetime(request->end_dt)"
  OF active_encounter:
   SET eval_by_qual =
"(e.active_ind = 1 and e.active_status_cd = ACTIVE_CD and e.reg_dt_tm <=                         cnvtdatetime(request->end_\
dt)) AND ((e.encntr_status_cd = DISCHARGED_ENCNTR_CD and e.disch_dt_tm >=                         cnvtdatetime(request->st\
art_dt)) OR (e.encntr_status_cd = ACTIVE_ENCNTR_CD and e.disch_dt_tm is NULL))\
"
  OF appt_date:
   SET eval_by_qual = "e.encntr_id > 0.0"
   SET appt_qual =
"((sa.active_ind = 1 AND sa.encntr_id = e.encntr_id)                   AND (sa.beg_dt_tm BETWEEN cnvtdatetime(request->star\
t_dt) AND cnvtdatetime(request->end_dt))                   AND (sa.state_meaning in ('SCHEDULED', 'RESCHEDULED','CHECKED I\
N','CHECKED OUT','CONFIRMED')))\
"
 ENDCASE
 CALL echo(build("eval by qual : ",eval_by_qual))
 CALL echo(build("appt qual : ",appt_qual))
 IF ((((request->eval_by=encounter_date)) OR ((request->eval_by=active_encounter))) )
  SELECT
   IF (codes_cnt > 0)DISTINCT INTO "nl:"
    p.person_id
    FROM encounter e,
     person p,
     nomenclature n,
     diagnosis d
    PLAN (e
     WHERE parser(eval_by_qual)
      AND parser(facility_qual)
      AND parser(enctr_type_qual)
      AND e.active_ind=1
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=e.person_id
      AND p.active_ind=1
      AND p.logical_domain_id=logical_domain_id
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND parser(gender_qual)
      AND parser(race_qual)
      AND parser(ethnicity_qual))
     JOIN (d
     WHERE d.encntr_id=e.encntr_id)
     JOIN (n
     WHERE n.nomenclature_id=d.nomenclature_id
      AND (n.source_vocabulary_cd=request->terminology_cd)
      AND n.active_ind=1
      AND n.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND parser(codes_qual))
    GROUP BY e.person_id, p.person_id, p.sex_cd,
     p.birth_dt_tm, p.name_last_key, p.name_last,
     p.name_first_key, p.name_first, p.name_middle_key,
     p.race_cd, p.ethnic_grp_cd
    HAVING count(DISTINCT n.source_identifier)=codes_cnt
    ORDER BY p.person_id
   ELSE DISTINCT INTO "nl:"
    FROM encounter e,
     person p
    PLAN (e
     WHERE parser(eval_by_qual)
      AND parser(facility_qual)
      AND parser(enctr_type_qual)
      AND e.active_ind=1
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=e.person_id
      AND p.active_ind=1
      AND p.logical_domain_id=logical_domain_id
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND parser(gender_qual)
      AND parser(race_qual)
      AND parser(ethnicity_qual))
    ORDER BY p.person_id
   ENDIF
   HEAD p.person_id
    bfound = 0
    IF (age_qual != "1=1")
     IF (parser(age_qual))
      bfound = 1
     ELSE
      bfound = 0
     ENDIF
    ELSE
     bfound = 1
    ENDIF
    IF (bfound=1)
     patient_cnt += 1
     IF (patient_cnt > size(qualified_patients->persons,5))
      stat = alterlist(qualified_patients->persons,(patient_cnt+ 100))
     ENDIF
     qualified_patients->persons[patient_cnt].person_id = p.person_id
    ENDIF
   WITH nocounter, orahintcbo(" GATHER_PLAN_STATISTICS ")
  ;end select
 ELSE
  SELECT
   IF (codes_cnt > 0)DISTINCT INTO "nl:"
    p.person_id
    FROM encounter e,
     person p,
     nomenclature n,
     diagnosis d,
     sch_appt sa
    PLAN (e
     WHERE parser(eval_by_qual)
      AND parser(facility_qual)
      AND parser(enctr_type_qual)
      AND e.active_ind=1
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (sa
     WHERE parser(appt_qual))
     JOIN (p
     WHERE p.person_id=sa.person_id
      AND p.active_ind=1
      AND p.logical_domain_id=logical_domain_id
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND parser(gender_qual)
      AND parser(race_qual)
      AND parser(ethnicity_qual))
     JOIN (d
     WHERE d.encntr_id=e.encntr_id)
     JOIN (n
     WHERE n.nomenclature_id=d.nomenclature_id
      AND (n.source_vocabulary_cd=request->terminology_cd)
      AND n.active_ind=1
      AND n.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND parser(codes_qual))
    GROUP BY e.person_id, p.person_id, p.sex_cd,
     p.birth_dt_tm, p.name_last_key, p.name_last,
     p.name_first_key, p.name_first, p.name_middle_key,
     p.race_cd, p.ethnic_grp_cd
    HAVING count(DISTINCT n.source_identifier)=codes_cnt
    ORDER BY p.person_id
   ELSE DISTINCT INTO "nl:"
    FROM encounter e,
     person p,
     sch_appt sa
    PLAN (e
     WHERE parser(eval_by_qual)
      AND parser(facility_qual)
      AND parser(enctr_type_qual)
      AND e.active_ind=1
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (sa
     WHERE parser(appt_qual))
     JOIN (p
     WHERE p.person_id=sa.person_id
      AND p.active_ind=1
      AND p.logical_domain_id=logical_domain_id
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND parser(gender_qual)
      AND parser(race_qual)
      AND parser(ethnicity_qual))
    ORDER BY p.person_id
   ENDIF
   HEAD p.person_id
    bfound = 0
    IF (age_qual != "1=1")
     IF (parser(age_qual))
      bfound = 1
     ELSE
      bfound = 0
     ENDIF
    ELSE
     bfound = 1
    ENDIF
    IF (bfound=1)
     patient_cnt += 1
     IF (patient_cnt > size(qualified_patients->persons,5))
      stat = alterlist(qualified_patients->persons,(patient_cnt+ 100))
     ENDIF
     qualified_patients->persons[patient_cnt].person_id = p.person_id
    ENDIF
   WITH nocounter, orahintcbo(" GATHER_PLAN_STATISTICS ")
  ;end select
 ENDIF
 SET stat = alterlist(qualified_patients->persons,patient_cnt)
 CALL echo(build("The total number of patients qualified is : ",patient_cnt))
 IF (patient_cnt=0)
  DECLARE complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"COMPLETE"))
  SELECT INTO "nl:"
   FROM ct_prot_prescreen_job_info cji
   WHERE cji.ct_prescreen_job_id=prescreen_parent_job_id
   WITH nocounter, forupdatewait(cji)
  ;end select
  UPDATE  FROM ct_prot_prescreen_job_info cji
   SET cji.completed_flag = 1
   WHERE cji.ct_prescreen_job_id=prescreen_parent_job_id
  ;end update
  SELECT INTO "nl:"
   FROM ct_prescreen_job cj
   WHERE cj.ct_prescreen_job_id=prescreen_parent_job_id
   WITH nocounter, forupdatewait(cj)
  ;end select
  UPDATE  FROM ct_prescreen_job cj
   SET cj.job_start_dt_tm = cnvtdatetime(sysdate), cj.job_status_cd = complete_cd, cj.job_end_dt_tm
     = cnvtdatetime(sysdate)
   WHERE cj.ct_prescreen_job_id=prescreen_parent_job_id
  ;end update
 ELSE
  DECLARE loop_cnt = i4 WITH protect, noconstant(ceil(((patient_cnt * 1.0)/ batch_size)))
  DECLARE batch_idx = i4 WITH protect, noconstant(1)
  DECLARE cur_cnt_idx = i4 WITH protect, noconstant(0)
  DECLARE start_idx = i4 WITH protect, noconstant(1)
  DECLARE remain_pat_cnt = i4 WITH noconstant(patient_cnt)
  SELECT INTO "nl:"
   FROM ct_prot_prescreen_job_info cji
   WHERE cji.ct_prescreen_job_id=prescreen_parent_job_id
   WITH nocounter, forupdatewait(cji)
  ;end select
  UPDATE  FROM ct_prot_prescreen_job_info cji
   SET cji.total_eval_pat_cnt = patient_cnt
   WHERE cji.ct_prescreen_job_id=prescreen_parent_job_id
  ;end update
  SELECT INTO "nl:"
   FROM ct_prescreen_job cj
   WHERE cj.ct_prescreen_job_id=prescreen_parent_job_id
   WITH nocounter, forupdatewait(cj)
  ;end select
  UPDATE  FROM ct_prescreen_job cj
   SET cj.job_start_dt_tm = cnvtdatetime(sysdate)
   WHERE cj.ct_prescreen_job_id=prescreen_parent_job_id
  ;end update
  FOR (batch_idx = 1 TO loop_cnt)
    SET stat = initrec(eval_pt_request)
    SET eval_pt_request->job_id = prescreen_parent_job_id
    SET eval_pt_request->protocol_id = request->prot_master_id
    SET eval_pt_request->screener_id = request->screener_id
    SET cur_cnt_idx = minval(batch_size,remain_pat_cnt)
    SET stat = movereclist(qualified_patients->persons,eval_pt_request->persons,start_idx,0,
     cur_cnt_idx,
     1)
    SET stat = tdbexecute(4150006,4150039,4150099,"REC",eval_pt_request,
     "REC",reply_out)
    CALL echo(build("status of call: ",stat))
    SET remain_pat_cnt -= batch_size
    SET start_idx += batch_size
  ENDFOR
  CALL echo(build("The total number of batches : ",loop_cnt))
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  CALL echo("Transaction error, changes rolled back")
 ELSE
  COMMIT
 ENDIF
END GO
