CREATE PROGRAM cps_plm_sch_basic:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD trequest
 RECORD trequest(
   1 call_echo_ind = i2
   1 person_id = f8
   1 resource_cd = f8
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 FREE RECORD treply
 RECORD treply(
   1 data_dt_tm = dq8
   1 day_qual_cnt = i4
   1 day_qual[*]
     2 qual_cnt = i4
     2 qual[*]
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 description = vc
       3 reason = vc
       3 person_id = f8
       3 person_name = vc
       3 location = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD hold
 RECORD hold(
   1 day_knt = i4
   1 day[*]
     2 separator = vc
     2 appt_knt = i2
     2 appt[*]
       3 day_week = c3
       3 day_nbr = c2
       3 short_month = c3
       3 start_time = c8
       3 duration = c7
       3 stop_time = c8
       3 appt_type = vc
       3 appt_reason = vc
       3 appt_loc = vc
       3 person_id = f8
       3 person_name = vc
       3 person_sex = c40
       3 person_age = c11
       3 med_knt = i4
       3 med[*]
         4 med_name = vc
         4 details = vc
       3 allergy_knt = i4
       3 allergy[*]
         4 substance = vc
         4 serverity = vc
       3 problem_knt = i4
       3 problem[*]
         4 name = vc
         4 life_cycle = vc
         4 course = vc
         4 onset_date = vc
       3 doc_knt = i4
       3 doc[*]
         4 doc_name = vc
         4 doc_title = vc
         4 doc_blob = vc
         4 doc_author = vc
         4 doc_dt_tm = vc
         4 event_cd = f8
 )
 SET day_name = fillstring(3," ")
 SET month_name = fillstring(3," ")
 SET day_nbr = fillstring(3," ")
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET pharmacy_cd = 0.0
 SET ordered_cd = 0.0
 SET canceled_cd = 0.0
 SET doc_cd = 0.0
 SET mdoc_cd = 0.0
 SET inerror_cd = 0.0
 SET canceled_life_cd = 0.0
 SET def_note_cd = 0
 SET my_note = false
 SET security_on = false
 SET confid_ind = false
 SET first_event_id = 0.0
 FREE RECORD exp_cd
 RECORD exp_cd(
   1 qual_knt = i4
   1 qual[*]
     2 event_cd = f8
 )
 SET trequest->person_id = reqinfo->updt_id
 IF (hour(cnvtdatetime(curdate,curtime3)) > 14)
  SET trequest->beg_dt_tm = cnvtdatetime((curdate+ 1),0000)
 ELSE
  SET trequest->beg_dt_tm = cnvtdatetime(curdate,0000)
 ENDIF
 EXECUTE sch_get_appt_palm  WITH replace(request,trequest), replace(reply,treply)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="SECURITY"
    AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
  DETAIL
   IF (di.info_name="SEC_ORG_RELTN"
    AND di.info_number=1)
    security_on = 1
   ENDIF
   IF (di.info_name="SEC_CONFID"
    AND di.info_number=1)
    confid_ind = 1, security_on = 1
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DM_INFO"
  GO TO exit_script
 ENDIF
 SET reply->title = "Basic Schedule"
 SET reply->check_box_ind = 0
 SET reply->expiration_dt_tm = datetimeadd(trequest->beg_dt_tm,1)
 SET reply->delete_dt_tm = datetimeadd(trequest->beg_dt_tm,6)
 IF ((treply->day_qual_cnt < 1))
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET cdf_meaning = "PHARMACY"
 SET code_set = 6000
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET code_value = 0.0
 SET cdf_meaning = "ORDERED"
 SET code_set = 6004
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 SET code_value = 0.0
 SET cdf_meaning = "CANCELED"
 SET code_set = 12025
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET code_value = 0.0
 SET code_set = 53
 SET cdf_meaning = "DOC"
 EXECUTE cpm_get_cd_for_cdf
 SET doc_cd = code_value
 SET code_value = 0.0
 SET code_set = 53
 SET cdf_meaning = "MDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET mdoc_cd = code_value
 SET code_value = 0.0
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET code_value = 0.0
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocfcomp_cd = code_value
 SET code_value = 0.0
 SET cdf_meaning = "CANCELED"
 SET code_set = 12030
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_life_cd = code_value
 SELECT DISTINCT INTO "nl:"
  vsc.event_set_cd, vse.event_cd
  FROM v500_event_set_code vsc,
   v500_event_set_explode vse
  PLAN (vsc
   WHERE vsc.event_set_name="Phone Msg")
   JOIN (vse
   WHERE vse.event_set_cd=vsc.event_set_cd)
  HEAD REPORT
   knt = 0, stat = alterlist(exp_cd->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(10,knt)=1
    AND knt != 1)
    stat = alterlist(exp_cd->qual,(knt+ 9))
   ENDIF
   exp_cd->qual[knt].event_cd = vse.event_cd
  FOOT REPORT
   exp_cd->qual_knt = knt, stat = alterlist(exp_cd->qual,knt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   name_value_prefs nvp
  PLAN (dp
   WHERE dp.application_number=1400000
    AND dp.position_cd=0
    AND dp.prsnl_id IN (0, trequest->person_id)
    AND dp.view_name="RL_PALM"
    AND dp.view_seq=1
    AND dp.comp_name="RL_PALM"
    AND dp.comp_seq=1
    AND dp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_name IN ("RL_MY_NOTE", "RL_NOTE_TYPE")
    AND nvp.active_ind=1)
  ORDER BY dp.application_number, dp.position_cd, dp.prsnl_id
  HEAD REPORT
   found_my_note = false, found_note_cd = false
  DETAIL
   IF (found_my_note=false)
    IF (dp.prsnl_id > 0
     AND nvp.pvc_name="RL_MY_NOTE")
     my_note = cnvtint(nvp.pvc_value), found_my_note = true
    ELSEIF (nvp.pvc_name="RL_MY_NOTE")
     my_note = cnvtint(nvp.pvc_value)
    ENDIF
   ENDIF
   IF (found_note_cd=false)
    IF (dp.prsnl_id > 0
     AND nvp.pvc_name="RL_NOTE_TYPE"
     AND nvp.merge_id > 0)
     def_note_cd = nvp.merge_id, found_note_cd = true
    ELSEIF (nvp.pvc_name="RL_NOTE_TYPE"
     AND nvp.merge_id > 0)
     def_note_cd = nvp.merge_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo(build("***   my_note     :",my_note))
 CALL echo(build("***   def_note_cd :",def_note_cd))
 CALL echo("***")
 SET hold->day_knt = treply->day_qual_cnt
 SET stat = alterlist(hold->day,hold->day_knt)
 FOR (i = 1 TO treply->day_qual_cnt)
   IF ((treply->day_qual[i].qual_cnt < 1))
    SET day_name = format(datetimeadd(trequest->beg_dt_tm,(i - 1)),"WWW;;d")
    SET day_nbr = trim(cnvtstring(day(datetimeadd(trequest->beg_dt_tm,(i - 1)))))
    SET month_name = format(datetimeadd(trequest->beg_dt_tm,(i - 1)),"MMM;;d")
    SET hold->day[i].separator = concat(trim(day_name)," ",trim(day_nbr)," ",trim(month_name),
     " No Appts.................................")
   ELSE
    SET hold->day[i].appt_knt = treply->day_qual[i].qual_cnt
    SET stat = alterlist(hold->day[i].appt,hold->day[i].appt_knt)
    SET hold->day[i].separator = concat(format(cnvtdatetime(treply->day_qual[i].qual[1].beg_dt_tm),
      "WWW;;d")," ",trim(cnvtstring(day(treply->day_qual[i].qual[1].beg_dt_tm)))," ",format(
      cnvtdatetime(treply->day_qual[i].qual[1].beg_dt_tm),"MMM;;d"),
     " ",format(cnvtdatetime(treply->day_qual[i].qual[1].beg_dt_tm),"HH:MM;;S")," ",format(
      cnvtdatetime(treply->day_qual[i].qual[treply->day_qual[i].qual_cnt].beg_dt_tm),"HH:MM;;S"),
     ".....................................")
    FOR (j = 1 TO treply->day_qual[i].qual_cnt)
      CALL echo("***")
      CALL echo(build("***   security_on :",security_on))
      CALL echo(build("***    confid_ind :",confid_ind))
      CALL echo("***")
      FREE RECORD valid_encntr
      RECORD valid_encntr(
        1 qual_knt = i4
        1 qual[*]
          2 encntr_id = f8
      )
      IF (security_on=true)
       FREE RECORD user_org
       RECORD user_org(
         1 qual_knt = i4
         1 qual[*]
           2 org_id = f8
           2 confid_level = i4
       )
       SELECT INTO "nl:"
        FROM prsnl_org_reltn por,
         code_value cv
        PLAN (por
         WHERE (por.person_id=trequest->person_id)
          AND por.active_ind=1
          AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
          AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         JOIN (cv
         WHERE cv.code_value=por.confid_level_cd)
        HEAD REPORT
         knt = 0, stat = alterlist(user_org->qual,10)
        DETAIL
         knt = (knt+ 1)
         IF (mod(knt,10)=1
          AND knt != 1)
          stat = alterlist(user_org->qual,(knt+ 9))
         ENDIF
         user_org->qual[knt].org_id = por.organization_id
         IF (cv.collation_seq > 0)
          user_org->qual[knt].confid_level = cv.collation_seq
         ELSE
          user_org->qual[knt].confid_level = 0
         ENDIF
        FOOT REPORT
         user_org->qual_knt = knt, stat = alterlist(user_org->qual,knt)
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(user_org->qual_knt)),
         encounter e,
         code_value cv
        PLAN (d
         WHERE d.seq > 0)
         JOIN (e
         WHERE (e.person_id=treply->day_qual[i].qual[j].person_id)
          AND (e.organization_id=user_org->qual[d.seq].org_id))
         JOIN (cv
         WHERE cv.code_value=e.confid_level_cd)
        HEAD REPORT
         knt = 0, stat = alterlist(valid_encntr->qual,10),
         CALL echo("***")
        DETAIL
         IF (((confid_ind=true
          AND (cv.collation_seq <= user_org->qual[d.seq].confid_level)) OR (confid_ind=false)) )
          knt = (knt+ 1)
          IF (mod(knt,10)=1
           AND knt != 1)
           stat = alterlist(valid_encntr->qual,(knt+ 9))
          ENDIF
          valid_encntr->qual[knt].encntr_id = e.encntr_id,
          CALL echo(build("***   encntr_id :",e.encntr_id))
         ENDIF
        FOOT REPORT
         CALL echo("***"), valid_encntr->qual_knt = knt, stat = alterlist(valid_encntr->qual,knt)
        WITH nocounter
       ;end select
      ENDIF
      SELECT INTO "nl:"
       FROM person p
       PLAN (p
        WHERE (p.person_id=treply->day_qual[i].qual[j].person_id))
       DETAIL
        hold->day[i].appt[j].person_id = p.person_id, hold->day[i].appt[j].person_name = p
        .name_full_formatted, hold->day[i].appt[j].person_sex = uar_get_code_display(p.sex_cd),
        hold->day[i].appt[j].person_age = cnvtage(p.birth_dt_tm), hold->day[i].appt[j].day_week =
        format(cnvtdatetime(treply->day_qual[i].qual[j].beg_dt_tm),"WWW;;d"), hold->day[i].appt[j].
        short_month = format(cnvtdatetime(treply->day_qual[i].qual[j].beg_dt_tm),"MMM;;d"),
        hold->day[i].appt[j].day_nbr = trim(cnvtstring(day(treply->day_qual[i].qual[j].beg_dt_tm))),
        hold->day[i].appt[j].start_time = format(cnvtdatetime(treply->day_qual[i].qual[j].beg_dt_tm),
         "HH:MM;;S"), hold->day[i].appt[j].stop_time = format(cnvtdatetime(treply->day_qual[i].qual[j
          ].end_dt_tm),"HH:MM;;S"),
        hold->day[i].appt[j].duration = concat(trim(cnvtstring(ceil(datetimediff(treply->day_qual[i].
             qual[j].end_dt_tm,treply->day_qual[i].qual[j].beg_dt_tm,4))))," ","m"), hold->day[i].
        appt[j].appt_type = treply->day_qual[i].qual[j].description, hold->day[i].appt[j].appt_reason
         = treply->day_qual[i].qual[j].reason,
        hold->day[i].appt[j].appt_loc = treply->day_qual[i].qual[j].location
       WITH nocounter
      ;end select
      CALL echo("***")
      CALL echo(build("***   valid_encntr->qual_knt :",valid_encntr->qual_knt))
      CALL echo("***")
      SELECT
       IF (security_on=true
        AND (valid_encntr->qual_knt > 0))
        FROM (dummyt d  WITH seq = value(valid_encntr->qual_knt)),
         orders o,
         order_catalog_synonym ocs
        PLAN (d
         WHERE d.seq > 0)
         JOIN (o
         WHERE (o.person_id=treply->day_qual[i].qual[j].person_id)
          AND (o.encntr_id=valid_encntr->qual[d.seq].encntr_id)
          AND o.catalog_type_cd=pharmacy_cd
          AND o.order_status_cd=ordered_cd
          AND o.active_ind=1)
         JOIN (ocs
         WHERE ocs.synonym_id=o.synonym_id)
       ELSEIF (security_on=false)
        FROM orders o,
         order_catalog_synonym ocs
        PLAN (o
         WHERE (o.person_id=treply->day_qual[i].qual[j].person_id)
          AND o.catalog_type_cd=pharmacy_cd
          AND o.order_status_cd=ordered_cd
          AND o.active_ind=1)
         JOIN (ocs
         WHERE ocs.synonym_id=o.synonym_id)
       ELSE
        FROM orders o,
         order_catalog_synonym ocs
        PLAN (o
         WHERE (o.order_id=- (83)))
         JOIN (ocs
         WHERE ocs.synonym_id=o.synonym_id)
       ENDIF
       INTO "nl:"
       o.orig_order_dt_tm
       ORDER BY o.orig_order_dt_tm DESC
       HEAD REPORT
        knt = 0, stat = alterlist(hold->day[i].appt[j].med,10)
       DETAIL
        knt = (knt+ 1)
        IF (mod(knt,10)=1
         AND knt != 1)
         stat = alterlist(hold->day[i].appt[j].med,(knt+ 9))
        ENDIF
        hold->day[i].appt[j].med[knt].details = o.clinical_display_line
        IF (o.ordered_as_mnemonic != null
         AND o.ordered_as_mnemonic > " ")
         hold->day[i].appt[j].med[knt].med_name = o.ordered_as_mnemonic
        ELSE
         hold->day[i].appt[j].med[knt].med_name = ocs.mnemonic
        ENDIF
       FOOT REPORT
        hold->day[i].appt[j].med_knt = knt, stat = alterlist(hold->day[i].appt[j].med,knt)
       WITH nocounter
      ;end select
      SELECT
       IF (security_on=true
        AND (valid_encntr->qual_knt > 0))
        FROM (dummyt d  WITH seq = value(valid_encntr->qual_knt)),
         allergy a,
         nomenclature n
        PLAN (d
         WHERE d.seq > 0)
         JOIN (a
         WHERE (a.person_id=treply->day_qual[i].qual[j].person_id)
          AND ((a.encntr_id+ 0)=valid_encntr->qual[d.seq].encntr_id)
          AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
          AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
          AND a.reaction_status_cd != canceled_cd)
         JOIN (n
         WHERE n.nomenclature_id=a.substance_nom_id)
       ELSEIF (security_on=false)
        FROM allergy a,
         nomenclature n
        PLAN (a
         WHERE (a.person_id=treply->day_qual[i].qual[j].person_id)
          AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
          AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
          AND a.reaction_status_cd != canceled_cd)
         JOIN (n
         WHERE n.nomenclature_id=a.substance_nom_id)
       ELSE
        FROM allergy a,
         nomenclature n
        PLAN (a
         WHERE (a.allergy_instance_id=- (83)))
         JOIN (n
         WHERE n.nomenclature_id=a.substance_nom_id)
       ENDIF
       INTO "nl:"
       serverity_level = uar_get_code_display(a.severity_cd)
       HEAD REPORT
        knt = 0, stat = alterlist(hold->day[i].appt[j].allergy,10)
       DETAIL
        knt = (knt+ 1)
        IF (mod(knt,10)=1
         AND knt != 1)
         stat = alterlist(hold->day[i].appt[j].allergy,(knt+ 9))
        ENDIF
        IF (n.nomenclature_id > 0)
         hold->day[i].appt[j].allergy[knt].substance = n.source_string
        ELSE
         hold->day[i].appt[j].allergy[knt].substance = a.substance_ftdesc
        ENDIF
        hold->day[i].appt[j].allergy[knt].serverity = serverity_level
       FOOT REPORT
        hold->day[i].appt[j].allergy_knt = knt, stat = alterlist(hold->day[i].appt[j].allergy,knt)
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM problem p,
        nomenclature n
       PLAN (p
        WHERE (p.person_id=treply->day_qual[i].qual[j].person_id)
         AND p.life_cycle_status_cd != canceled_life_cd
         AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
         AND p.problem_id > 0)
        JOIN (n
        WHERE n.nomenclature_id=p.nomenclature_id)
       ORDER BY p.onset_dt_tm DESC
       HEAD REPORT
        knt = 0, stat = alterlist(hold->day[i].appt[j].problem,10)
       DETAIL
        knt = (knt+ 1)
        IF (mod(knt,10)=1
         AND knt != 1)
         stat = alterlist(hold->day[i].appt[j].problem,(knt+ 9))
        ENDIF
        IF (n.nomenclature_id > 0)
         hold->day[i].appt[j].problem[knt].name = n.source_string
        ELSE
         hold->day[i].appt[j].problem[knt].name = p.problem_ftdesc
        ENDIF
        hold->day[i].appt[j].problem[knt].life_cycle = trim(uar_get_code_display(p
          .life_cycle_status_cd)), hold->day[i].appt[j].problem[knt].course = trim(
         uar_get_code_display(p.course_cd)), hold->day[i].appt[j].problem[knt].onset_date = format(p
         .onset_dt_tm,"mm/dd/yyyy;;d")
       FOOT REPORT
        hold->day[i].appt[j].problem_knt = knt, stat = alterlist(hold->day[i].appt[j].problem,knt)
       WITH nocounter
      ;end select
      IF (def_note_cd > 0)
       CALL echo("***")
       CALL echo(build("***              def_note_cd :",def_note_cd))
       CALL echo(build("***                  my_note :",my_note))
       CALL echo(build("***              security_on :",security_on))
       CALL echo(build("***   valid_encntr->qual_knt :",valid_encntr->qual_knt))
       CALL echo("***")
       SELECT
        IF (my_note=true
         AND security_on=true
         AND (valid_encntr->qual_knt > 0))
         FROM (dummyt d  WITH seq = value(valid_encntr->qual_knt)),
          clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (d
          WHERE d.seq > 0)
          JOIN (ce
          WHERE (ce.person_id=treply->day_qual[i].qual[j].person_id)
           AND (ce.encntr_id=valid_encntr->qual[d.seq].encntr_id)
           AND ce.event_cd=def_note_cd
           AND ce.view_level=1
           AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
           AND ce.result_status_cd != inerror_cd
           AND ce.event_class_cd IN (doc_cd, mdoc_cd)
           AND (ce.performed_prsnl_id=trequest->person_id))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
        ELSEIF (my_note=true
         AND security_on=true
         AND (valid_encntr->qual_knt < 1))
         FROM clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (ce
          WHERE (ce.clinical_event_id=- (83)))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
        ELSEIF (my_note=false
         AND security_on=true
         AND (valid_encntr->qual_knt > 0))
         FROM (dummyt d  WITH seq = value(valid_encntr->qual_knt)),
          clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (d
          WHERE d.seq > 0)
          JOIN (ce
          WHERE (ce.person_id=treply->day_qual[i].qual[j].person_id)
           AND (ce.encntr_id=valid_encntr->qual[d.seq].encntr_id)
           AND ce.event_cd=def_note_cd
           AND ce.view_level=1
           AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
           AND ce.result_status_cd != inerror_cd
           AND ce.event_class_cd IN (doc_cd, mdoc_cd))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
        ELSEIF (my_note=false
         AND security_on=true
         AND (valid_encntr->qual_knt < 1))
         FROM clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (ce
          WHERE (ce.clinical_event_id=- (83)))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
        ELSEIF (my_note=true)
         FROM clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (ce
          WHERE (ce.person_id=treply->day_qual[i].qual[j].person_id)
           AND ce.event_cd=def_note_cd
           AND ce.view_level=1
           AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
           AND ce.result_status_cd != inerror_cd
           AND ce.event_class_cd IN (doc_cd, mdoc_cd)
           AND (ce.performed_prsnl_id=trequest->person_id))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
        ELSE
         FROM clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (ce
          WHERE (ce.person_id=treply->day_qual[i].qual[j].person_id)
           AND ce.event_cd=def_note_cd
           AND ce.view_level=1
           AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
           AND ce.result_status_cd != inerror_cd
           AND ce.event_class_cd IN (doc_cd, mdoc_cd))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
        ENDIF
        INTO "nl:"
        sze = textlen(cb.blob_contents)
        ORDER BY ce.event_end_dt_tm DESC
        HEAD REPORT
         hold_event_id = 0, cnt = 0
        DETAIL
         IF (ce2.parent_event_id=hold_event_id)
          blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring
          (32000," ")
          IF (cb.compression_cd=ocfcomp_cd)
           blob_out = fillstring(32000," "), blob_ret_len = 0,
           CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
          ELSE
           blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(
            1,(y1 - 8),cb.blob_contents)
          ENDIF
          CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), hold->day[i].appt[j].doc[
          cnt].doc_blob = concat(hold->day[i].appt[j].doc[cnt].doc_blob," | ",trim(blob_out2))
         ELSE
          cnt = (cnt+ 1)
          IF (cnt=1)
           stat = alterlist(hold->day[i].appt[j].doc,cnt), blob_out = fillstring(32000," "),
           blob_out2 = fillstring(32000," "),
           blob_out3 = fillstring(32000," ")
           IF (cb.compression_cd=ocfcomp_cd)
            blob_out = fillstring(32000," "), blob_ret_len = 0,
            CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
           ELSE
            blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring
            (1,(y1 - 8),cb.blob_contents)
           ENDIF
           hold->day[i].appt[j].doc[cnt].doc_dt_tm = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
           hold->day[i].appt[j].doc[cnt].doc_author = concat(trim(pl.name_full_formatted)), hold->
           day[i].appt[j].doc[cnt].doc_title = trim(ce.event_title_text),
           hold->day[i].appt[j].doc[cnt].doc_name = trim(ce.event_tag),
           CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), hold->day[i].appt[j].
           doc[cnt].doc_blob = trim(blob_out2),
           hold->day[i].appt[j].doc[cnt].event_cd = ce.event_cd, hold_event_id = ce.event_id,
           first_event_id = ce.event_id
          ENDIF
         ENDIF
        FOOT REPORT
         hold->day[i].appt[j].doc_knt = cnt
        WITH nocounter, memsort, maxqual(ce,1)
       ;end select
      ENDIF
      IF ((hold->day[i].appt[j].doc_knt < 1)
       AND my_note=true)
       CALL echo("***")
       CALL echo(build("***   hold->day[i].appt[j].doc_knt :",hold->day[i].appt[j].doc_knt))
       CALL echo(build("***                        my_note :",my_note))
       CALL echo(build("***                    security_on :",security_on))
       CALL echo(build("***         valid_encntr->qual_knt :",valid_encntr->qual_knt))
       CALL echo("***")
       SELECT
        IF (security_on=true
         AND (valid_encntr->qual_knt > 0))
         FROM (dummyt d2  WITH seq = value(valid_encntr->qual_knt)),
          (dummyt d  WITH seq = value(exp_cd->qual_knt)),
          (dummyt d1  WITH seq = 1),
          clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (d2
          WHERE d2.seq > 0)
          JOIN (ce
          WHERE (ce.person_id=treply->day_qual[i].qual[j].person_id)
           AND ((ce.encntr_id+ 0)=valid_encntr->qual[d2.seq].encntr_id)
           AND ce.view_level=1
           AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
           AND ce.result_status_cd != inerror_cd
           AND ce.event_class_cd IN (doc_cd, mdoc_cd)
           AND (ce.performed_prsnl_id=trequest->person_id))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
          JOIN (d1)
          JOIN (d
          WHERE (exp_cd->qual[d.seq].event_cd=ce.event_cd))
        ELSEIF (security_on=true
         AND (valid_encntr->qual_knt < 1))
         FROM (dummyt d  WITH seq = value(exp_cd->qual_knt)),
          (dummyt d1  WITH seq = 1),
          clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (ce
          WHERE (ce.clinical_event_id=- (83)))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
          JOIN (d1)
          JOIN (d
          WHERE (exp_cd->qual[d.seq].event_cd=ce.event_cd))
        ELSE
         FROM (dummyt d  WITH seq = value(exp_cd->qual_knt)),
          (dummyt d1  WITH seq = 1),
          clinical_event ce,
          clinical_event ce2,
          ce_blob_result cbr,
          ce_blob cb,
          prsnl pl
         PLAN (ce
          WHERE (ce.person_id=treply->day_qual[i].qual[j].person_id)
           AND ce.view_level=1
           AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
           AND ce.result_status_cd != inerror_cd
           AND ce.event_class_cd IN (doc_cd, mdoc_cd)
           AND (ce.performed_prsnl_id=trequest->person_id))
          JOIN (ce2
          WHERE ce2.parent_event_id=ce.event_id
           AND ce2.view_level=0
           AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (cbr
          WHERE cbr.event_id=ce2.event_id
           AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
          JOIN (cb
          WHERE cb.event_id=ce2.event_id
           AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
          JOIN (pl
          WHERE pl.person_id=ce.performed_prsnl_id)
          JOIN (d1)
          JOIN (d
          WHERE (exp_cd->qual[d.seq].event_cd=ce.event_cd))
        ENDIF
        INTO "nl:"
        sze = textlen(cb.blob_contents)
        ORDER BY ce.event_end_dt_tm DESC
        HEAD REPORT
         hold_event_id = 0, cnt = 0, fcnt = 0
        DETAIL
         IF (ce2.parent_event_id=hold_event_id
          AND fcnt=1)
          blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring
          (32000," ")
          IF (cb.compression_cd=ocfcomp_cd)
           blob_out = fillstring(32000," "), blob_ret_len = 0,
           CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
          ELSE
           blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(
            1,(y1 - 8),cb.blob_contents)
          ENDIF
          CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), hold->day[i].appt[j].doc[
          fcnt].doc_blob = concat(hold->day[i].appt[j].doc[fcnt].doc_blob," | ",trim(blob_out2))
         ELSE
          cnt = (cnt+ 1)
          IF (cnt=1)
           fknt = 1, stat = alterlist(hold->day[i].appt[j].doc,cnt), blob_out = fillstring(32000," "),
           blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
           IF (cb.compression_cd=ocfcomp_cd)
            blob_out = fillstring(32000," "), blob_ret_len = 0,
            CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
           ELSE
            blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring
            (1,(y1 - 8),cb.blob_contents)
           ENDIF
           hold->day[i].appt[j].doc[cnt].doc_dt_tm = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
           hold->day[i].appt[j].doc[cnt].doc_author = concat(trim(pl.name_full_formatted)), hold->
           day[i].appt[j].doc[cnt].doc_title = trim(ce.event_title_text),
           hold->day[i].appt[j].doc[cnt].doc_name = trim(ce.event_tag),
           CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), hold->day[i].appt[j].
           doc[cnt].doc_blob = trim(blob_out2),
           hold->day[i].appt[j].doc[cnt].event_cd = ce.event_cd, hold_event_id = ce.event_id,
           first_event_id = ce.event_id
          ENDIF
         ENDIF
        FOOT REPORT
         IF (cnt > 0)
          hold->day[i].appt[j].doc_knt = 1
         ENDIF
        WITH nocounter, memsort, outerjoin = d1,
         dontexist
       ;end select
      ENDIF
      CALL echo("***")
      CALL echo(build("***   security_on :",security_on))
      CALL echo(build("***   valid_encntr->qual_knt :",valid_encntr->qual_knt))
      CALL echo("***")
      SELECT
       IF (security_on=true
        AND (valid_encntr->qual_knt > 0))
        FROM (dummyt d2  WITH seq = value(valid_encntr->qual_knt)),
         (dummyt d  WITH seq = value(exp_cd->qual_knt)),
         (dummyt d1  WITH seq = 1),
         clinical_event ce,
         clinical_event ce2,
         ce_blob_result cbr,
         ce_blob cb,
         prsnl pl
        PLAN (d2
         WHERE d2.seq > 0)
         JOIN (ce
         WHERE (ce.person_id=treply->day_qual[i].qual[j].person_id)
          AND ((ce.encntr_id+ 0)=valid_encntr->qual[d2.seq].encntr_id)
          AND ce.view_level=1
          AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
          AND ce.result_status_cd != inerror_cd
          AND ce.event_id != first_event_id
          AND ce.event_class_cd IN (doc_cd, mdoc_cd))
         JOIN (ce2
         WHERE ce2.parent_event_id=ce.event_id
          AND ce2.view_level=0
          AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
         JOIN (cbr
         WHERE cbr.event_id=ce2.event_id
          AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
         JOIN (cb
         WHERE cb.event_id=ce2.event_id
          AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
         JOIN (pl
         WHERE pl.person_id=ce.performed_prsnl_id)
         JOIN (d1)
         JOIN (d
         WHERE (exp_cd->qual[d.seq].event_cd=ce.event_cd))
       ELSEIF (security_on=true
        AND (valid_encntr->qual_knt < 1))
        FROM (dummyt d  WITH seq = value(exp_cd->qual_knt)),
         (dummyt d1  WITH seq = 1),
         clinical_event ce,
         clinical_event ce2,
         ce_blob_result cbr,
         ce_blob cb,
         prsnl pl
        PLAN (ce
         WHERE (ce.clinical_event_id=- (83)))
         JOIN (ce2
         WHERE ce2.parent_event_id=ce.event_id
          AND ce2.view_level=0
          AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
         JOIN (cbr
         WHERE cbr.event_id=ce2.event_id
          AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
         JOIN (cb
         WHERE cb.event_id=ce2.event_id
          AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
         JOIN (pl
         WHERE pl.person_id=ce.performed_prsnl_id)
         JOIN (d1)
         JOIN (d
         WHERE (exp_cd->qual[d.seq].event_cd=ce.event_cd))
       ELSE
        FROM (dummyt d  WITH seq = value(exp_cd->qual_knt)),
         (dummyt d1  WITH seq = 1),
         clinical_event ce,
         clinical_event ce2,
         ce_blob_result cbr,
         ce_blob cb,
         prsnl pl
        PLAN (ce
         WHERE (ce.person_id=treply->day_qual[i].qual[j].person_id)
          AND ce.view_level=1
          AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
          AND ce.result_status_cd != inerror_cd
          AND ce.event_id != first_event_id
          AND ce.event_class_cd IN (doc_cd, mdoc_cd))
         JOIN (ce2
         WHERE ce2.parent_event_id=ce.event_id
          AND ce2.view_level=0
          AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
         JOIN (cbr
         WHERE cbr.event_id=ce2.event_id
          AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
         JOIN (cb
         WHERE cb.event_id=ce2.event_id
          AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
         JOIN (pl
         WHERE pl.person_id=ce.performed_prsnl_id)
         JOIN (d1)
         JOIN (d
         WHERE (exp_cd->qual[d.seq].event_cd=ce.event_cd))
       ENDIF
       INTO "nl:"
       sze = textlen(cb.blob_contents)
       ORDER BY ce.event_end_dt_tm DESC
       HEAD REPORT
        hold_event_id = 0, cnt = hold->day[i].appt[j].doc_knt
       DETAIL
        IF (ce2.parent_event_id=hold_event_id)
         blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
          32000," ")
         IF (cb.compression_cd=ocfcomp_cd)
          blob_out = fillstring(32000," "), blob_ret_len = 0,
          CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
         ELSE
          blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,
           (y1 - 8),cb.blob_contents)
         ENDIF
         CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), hold->day[i].appt[j].doc[
         cnt].doc_blob = concat(hold->day[i].appt[j].doc[cnt].doc_blob," | ",trim(blob_out2))
        ELSE
         IF (cnt < 21)
          cnt = (cnt+ 1), stat = alterlist(hold->day[i].appt[j].doc,cnt), blob_out = fillstring(32000,
           " "),
          blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000," ")
          IF (cb.compression_cd=ocfcomp_cd)
           blob_out = fillstring(32000," "), blob_ret_len = 0,
           CALL uar_ocf_uncompress(cb.blob_contents,sze,blob_out,32000,blob_ret_len)
          ELSE
           blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(
            1,(y1 - 8),cb.blob_contents)
          ENDIF
          hold->day[i].appt[j].doc[cnt].doc_dt_tm = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
          hold->day[i].appt[j].doc[cnt].doc_author = concat(trim(pl.name_full_formatted)), hold->day[
          i].appt[j].doc[cnt].doc_title = trim(ce.event_title_text),
          hold->day[i].appt[j].doc[cnt].doc_name = trim(ce.event_tag),
          CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), hold->day[i].appt[j].doc[
          cnt].doc_blob = trim(blob_out2),
          hold->day[i].appt[j].doc[cnt].event_cd = ce.event_cd, hold_event_id = ce.event_id
         ENDIF
        ENDIF
       FOOT REPORT
        hold->day[i].appt[j].doc_knt = cnt
       WITH nocounter, memsort, outerjoin = d1,
        dontexist
      ;end select
    ENDFOR
   ENDIF
 ENDFOR
 SET lknt = 0
 SET stat = alterlist(reply->col,4)
 SET reply->col[1].header = "Start"
 SET reply->col[1].width = 28
 SET reply->col[1].primary_ind = 0
 SET reply->col[2].header = "Duration"
 SET reply->col[2].width = 19
 SET reply->col[2].primary_ind = 0
 SET reply->col[3].header = "Stop"
 SET reply->col[3].width = 0
 SET reply->col[3].primary_ind = 0
 SET reply->col[4].header = "Patient Name"
 SET reply->col[4].width = 53
 SET reply->col[4].primary_ind = 1
 SET lknt = (lknt+ 1)
 SET stat = alterlist(reply->links,lknt)
 SET reply->links[lknt].title = "Info"
 SET reply->links[lknt].type = 1
 SET reply->links[lknt].menuname = "Patient Info"
 SET reply->links[lknt].buttonname = "Info"
 SET reply->links[lknt].initial_ind = 1
 SET stat = alterlist(reply->links[lknt].col,1)
 SET reply->links[lknt].col[1].header = "details"
 SET reply->links[lknt].col[1].width = 100
 SET lknt = (lknt+ 1)
 SET stat = alterlist(reply->links,lknt)
 SET reply->links[lknt].title = "Meds"
 SET reply->links[lknt].type = 0
 SET reply->links[lknt].menuname = "Medications"
 SET reply->links[lknt].buttonname = "Meds"
 SET reply->links[lknt].initial_ind = 0
 SET stat = alterlist(reply->links[lknt].col,2)
 SET reply->links[lknt].col[1].header = "Med"
 SET reply->links[lknt].col[1].width = 100
 SET reply->links[lknt].col[2].header = "Details"
 SET reply->links[lknt].col[2].width = 0
 SET lknt = (lknt+ 1)
 SET stat = alterlist(reply->links,lknt)
 SET reply->links[lknt].title = "Allergies"
 SET reply->links[lknt].type = 0
 SET reply->links[lknt].menuname = "Allergies"
 SET reply->links[lknt].buttonname = "Algy"
 SET reply->links[lknt].initial_ind = 0
 SET stat = alterlist(reply->links[lknt].col,2)
 SET reply->links[lknt].col[1].header = "Substance"
 SET reply->links[lknt].col[1].width = 70
 SET reply->links[lknt].col[2].header = "Severity"
 SET reply->links[lknt].col[2].width = 30
 SET lknt = (lknt+ 1)
 SET stat = alterlist(reply->links,lknt)
 SET reply->links[lknt].title = "Problems"
 SET reply->links[lknt].type = 0
 SET reply->links[lknt].menuname = "Problems"
 SET reply->links[lknt].buttonname = "Prob"
 SET reply->links[lknt].initial_ind = 0
 SET stat = alterlist(reply->links[lknt].col,4)
 SET reply->links[lknt].col[1].header = "Name"
 SET reply->links[lknt].col[1].width = 70
 SET reply->links[lknt].col[2].header = "Course"
 SET reply->links[lknt].col[2].width = 30
 SET reply->links[lknt].col[3].header = "Status"
 SET reply->links[lknt].col[3].width = 0
 SET reply->links[lknt].col[4].header = "Onset Date"
 SET reply->links[lknt].col[4].width = 0
 SET lknt = (lknt+ 1)
 SET stat = alterlist(reply->links,lknt)
 SET reply->links[lknt].title = "Documents"
 SET reply->links[lknt].type = 0
 SET reply->links[lknt].menuname = "Documents"
 SET reply->links[lknt].buttonname = "Docs"
 SET reply->links[lknt].initial_ind = 0
 SET stat = alterlist(reply->links[lknt].col,5)
 SET reply->links[lknt].col[1].header = "Document Name"
 SET reply->links[lknt].col[1].width = 50
 SET reply->links[lknt].col[2].header = "Author"
 SET reply->links[lknt].col[2].width = 50
 SET reply->links[lknt].col[3].header = "Date"
 SET reply->links[lknt].col[3].width = 0
 SET reply->links[lknt].col[4].header = "Title"
 SET reply->links[lknt].col[4].width = 0
 SET reply->links[lknt].col[5].header = "Text"
 SET reply->links[lknt].col[5].width = 0
 SET row_knt = 0
 FOR (i = 1 TO hold->day_knt)
   SET row_knt = (row_knt+ 1)
   SET stat = alterlist(reply->row,row_knt)
   SET reply->row[row_knt].separator_ind = 1
   SET reply->row[row_knt].separator_value = trim(hold->day[i].separator)
   IF ((hold->day[i].appt_knt > 0))
    FOR (j = 1 TO hold->day[i].appt_knt)
      SET row_knt = (row_knt+ 1)
      SET stat = alterlist(reply->row,row_knt)
      SET reply->row[row_knt].separator_ind = 0
      SET reply->row[row_knt].separator_value = ""
      SET stat = alterlist(reply->row[row_knt].col,4)
      SET reply->row[row_knt].col[1].value = trim(hold->day[i].appt[j].start_time)
      SET reply->row[row_knt].col[2].value = trim(hold->day[i].appt[j].duration)
      SET reply->row[row_knt].col[3].value = trim(hold->day[i].appt[j].stop_time)
      SET reply->row[row_knt].col[4].value = trim(hold->day[i].appt[j].person_name)
      SET stat = alterlist(reply->row[row_knt].links,lknt)
      SET stat = alterlist(reply->row[row_knt].links[1].row,1)
      SET stat = alterlist(reply->row[row_knt].links[1].row[1].col,1)
      SET reply->row[row_knt].links[1].row[1].col[1].value = concat(trim(hold->day[i].appt[j].
        start_time)," ",trim(hold->day[i].appt[j].duration)," ",trim(hold->day[i].appt[j].appt_loc),
       " ",trim(hold->day[i].appt[j].appt_type)," ",trim(hold->day[i].appt[j].person_age)," ",
       trim(hold->day[i].appt[j].person_sex)," ",trim(hold->day[i].appt[j].appt_reason))
      IF ((hold->day[i].appt[j].med_knt > 0))
       SET stat = alterlist(reply->row[row_knt].links[2].row,hold->day[i].appt[j].med_knt)
       FOR (k = 1 TO hold->day[i].appt[j].med_knt)
         SET stat = alterlist(reply->row[row_knt].links[2].row[k].col,2)
         SET reply->row[row_knt].links[2].row[k].col[1].value = hold->day[i].appt[j].med[k].med_name
         SET reply->row[row_knt].links[2].row[k].col[2].value = hold->day[i].appt[j].med[k].details
       ENDFOR
      ENDIF
      IF ((hold->day[i].appt[j].allergy_knt > 0))
       SET stat = alterlist(reply->row[row_knt].links[3].row,hold->day[i].appt[j].allergy_knt)
       FOR (k = 1 TO hold->day[i].appt[j].allergy_knt)
         SET stat = alterlist(reply->row[row_knt].links[3].row[k].col,2)
         SET reply->row[row_knt].links[3].row[k].col[1].value = hold->day[i].appt[j].allergy[k].
         substance
         SET reply->row[row_knt].links[3].row[k].col[2].value = hold->day[i].appt[j].allergy[k].
         serverity
       ENDFOR
      ENDIF
      IF ((hold->day[i].appt[j].problem_knt > 0))
       SET stat = alterlist(reply->row[row_knt].links[4].row,hold->day[i].appt[j].problem_knt)
       FOR (k = 1 TO hold->day[i].appt[j].problem_knt)
         SET stat = alterlist(reply->row[row_knt].links[4].row[k].col,4)
         SET reply->row[row_knt].links[4].row[k].col[1].value = hold->day[i].appt[j].problem[k].name
         SET reply->row[row_knt].links[4].row[k].col[2].value = hold->day[i].appt[j].problem[k].
         course
         SET reply->row[row_knt].links[4].row[k].col[3].value = hold->day[i].appt[j].problem[k].
         life_cycle
         SET reply->row[row_knt].links[4].row[k].col[4].value = hold->day[i].appt[j].problem[k].
         onset_date
       ENDFOR
      ENDIF
      IF ((hold->day[i].appt[j].doc_knt > 0))
       SET stat = alterlist(reply->row[row_knt].links[5].row,hold->day[i].appt[j].doc_knt)
       FOR (k = 1 TO hold->day[i].appt[j].doc_knt)
         SET stat = alterlist(reply->row[row_knt].links[5].row[k].col,5)
         SET reply->row[row_knt].links[5].row[k].col[1].value = hold->day[i].appt[j].doc[k].doc_name
         SET reply->row[row_knt].links[5].row[k].col[2].value = hold->day[i].appt[j].doc[k].
         doc_author
         SET reply->row[row_knt].links[5].row[k].col[3].value = hold->day[i].appt[j].doc[k].doc_dt_tm
         SET reply->row[row_knt].links[5].row[k].col[4].value = hold->day[i].appt[j].doc[k].doc_title
         SET reply->row[row_knt].links[5].row[k].col[5].value = hold->day[i].appt[j].doc[k].doc_blob
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
