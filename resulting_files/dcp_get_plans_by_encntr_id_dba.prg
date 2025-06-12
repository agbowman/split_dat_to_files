CREATE PROGRAM dcp_get_plans_by_encntr_id:dba
 SET modify = predeclare
 CALL echo("<--------------------------------------------->")
 CALL echo("<---   BEGIN: DCP_GET_PLANS_BY_ENCNTR_ID   --->")
 CALL echo("<--------------------------------------------->")
 DECLARE qtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(qtimerbegindttm,";;Q"),"      ==="))
 CALL echo("====================================================")
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 pw_group_nbr = f8
     2 pw_group_desc = vc
     2 start_dt_tm = dq8
     2 start_tz = i2
     2 pw_evidence_reltn_id = f8
     2 evidence_locator = vc
     2 old_version = i4
     2 new_version = i4
     2 old_pw_cat_id = f8
     2 new_pw_cat_id = f8
     2 diagnosis_display = vc
     2 ref_text_ind = i2
     2 pw_cat_synonym_id = f8
     2 primary_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pathway(
   1 qual[*]
     2 pw_group_nbr = f8
     2 pw_group_desc = vc
     2 start_dt_tm = dq8
     2 start_tz = i2
     2 pw_evidence_reltn_id = f8
     2 evidence_locator = vc
     2 old_version = i4
     2 new_version = i4
     2 old_pw_cat_id = f8
     2 new_pw_cat_id = f8
     2 privilege_ind = i2
     2 version_pw_cat_id = f8
     2 pathway_id = f8
     2 diagnosis_display = vc
     2 pw_cat_synonym_id = f8
     2 primary_ind = i2
 )
 RECORD version(
   1 qual[*]
     2 version_pw_cat_id = f8
     2 highest_version_used = i4
 )
 FREE SET catalogs
 RECORD catalogs(
   1 size = i4
   1 new_size = i4
   1 loop_count = i4
   1 batch_size = i4
   1 qual[*]
     2 pathway_catalog_id = f8
 )
 SET reply->status_data.status = "F"
 IF (validate(request->visit_list)=0)
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ENDIF
 IF (validate(request->visit_list[1].encntr_id,0.0)=0)
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ENDIF
 DECLARE debug = i2 WITH protect, constant(validate(request->debug))
 DECLARE virtual_catalog_flag = i2 WITH protect, constant(validate(request->virtual_catalog_flag,0))
 DECLARE facility_cd = f8 WITH protect, constant(validate(request->facility_cd,0.0))
 DECLARE allow_copy_personal_plan = i2 WITH protect, constant(validate(request->
   allow_copy_personal_plan,0))
 DECLARE personal_plans_none = i2 WITH protect, constant(0)
 DECLARE personal_plans_marked = i2 WITH protect, constant(1)
 DECLARE personal_plans_all = i2 WITH protect, constant(2)
 DECLARE load_phase = i2 WITH protect, constant(0)
 DECLARE check_facility = i2 WITH protect, constant(1)
 DECLARE do_not_load = i2 WITH protect, constant(2)
 DECLARE pathway_status_code_set = i4 WITH protect, constant(16769)
 DECLARE initiated_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",
   pathway_status_code_set,"INITIATED"))
 DECLARE discontinued_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",
   pathway_status_code_set,"DISCONTINUED"))
 DECLARE completed_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",
   pathway_status_code_set,"COMPLETED"))
 DECLARE planned_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",
   pathway_status_code_set,"PLANNED"))
 DECLARE void_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",
   pathway_status_code_set,"VOID"))
 DECLARE initreview_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",
   pathway_status_code_set,"INITREVIEW"))
 DECLARE futurereview_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",
   pathway_status_code_set,"FUTUREREVIEW"))
 DECLARE future_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",
   pathway_status_code_set,"FUTURE"))
 DECLARE encounter_batch_size = i4 WITH protect, constant(10)
 DECLARE encounter_list_size = i4 WITH protect, constant(size(request->visit_list,5))
 DECLARE encounter_loop_count = i4 WITH protect, constant(ceil((cnvtreal(encounter_list_size)/
   encounter_batch_size)))
 DECLARE encounter_new_list_size = i4 WITH protect, constant((encounter_loop_count *
  encounter_batch_size))
 DECLARE nincludecnt = i4 WITH protect, noconstant(0)
 DECLARE nexcludecnt = i4 WITH protect, noconstant(0)
 DECLARE pathway_batch_size = i4 WITH protect, constant(10)
 DECLARE findidx = i4 WITH protect, noconstant(0)
 DECLARE foundidx = i4 WITH protect, noconstant(0)
 DECLARE pathwayidx = i4 WITH protect, noconstant(0)
 DECLARE pathwayloopcount = i4 WITH protect, noconstant(0)
 DECLARE nversionsize = i4 WITH protect, noconstant(0)
 DECLARE nversioncount = i4 WITH protect, noconstant(0)
 DECLARE nversionidx = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE replyidx = i4 WITH protect, noconstant(0)
 DECLARE bcanadd = i2 WITH protect, noconstant(0)
 DECLARE nphasecount = i4 WITH protect, noconstant(0)
 DECLARE nversion = i4 WITH protect, noconstant(0)
 DECLARE ballowcopyforwardind = i2 WITH protect, noconstant(0)
 DECLARE lpathwaysize = i4 WITH protect, noconstant(0)
 DECLARE lpathwaycount = i4 WITH protect, noconstant(0)
 DECLARE plantotal = i4 WITH protect, noconstant(0)
 DECLARE bavailableind = i2 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(0)
 DECLARE bphasestartedind = i2 WITH protect, noconstant(0)
 DECLARE dcurrentdatetime = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE dtimeinseconds = f8 WITH noconstant(0.0)
 DECLARE dtotaltimeinseconds = f8 WITH noconstant(0.0)
 DECLARE starttime = q8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE stoptime = q8
 DECLARE ndummy = i2 WITH noconstant(0)
 DECLARE starttimer(dummy=i2) = null
 DECLARE stoptimer(sdisplay=vc) = null
 SUBROUTINE starttimer(dummy)
   IF (debug=1)
    SET starttime = cnvtdatetime(curdate,curtime3)
   ENDIF
 END ;Subroutine
 SUBROUTINE stoptimer(sdisplay)
   IF (debug=1)
    SET stoptime = cnvtdatetime(curdate,curtime3)
    SET dtimeinseconds = datetimediff(cnvtdatetime(curdate,curtime3),starttime,5)
    SET dtotaltimeinseconds = (dtotaltimeinseconds+ dtimeinseconds)
    IF (sdisplay > " ")
     CALL echo("'*****************************************************************'")
     CALL echo(build("'",sdisplay," = ",dtimeinseconds,"'"))
     CALL echo("'-----------------------------------------------------------------'")
     CALL echo(build("'","Total time = ",dtotaltimeinseconds,"'"))
     CALL echo("'*****************************************************************'")
    ENDIF
   ENDIF
 END ;Subroutine
 IF (validate(request->plan_type_include_list[1].pathway_type_cd)=1)
  SET nincludecnt = size(request->plan_type_include_list,5)
 ENDIF
 IF (validate(request->plan_type_exclude_list[1].pathway_type_cd)=1)
  SET nexcludecnt = size(request->plan_type_exclude_list,5)
 ENDIF
 DECLARE canaddphase(pathway_id=f8,pathway_type_cd=f8,ref_owner_person_id=f8,started_ind=i2,type_mean
  =vc) = c1
 DECLARE canaddplantype(dpathwaytypecd=f8) = c1
 SUBROUTINE canaddphase(pathway_id,pathway_type_cd,ref_owner_person_id,started_ind,type_mean)
   IF (started_ind=0)
    IF (debug=1)
     CALL echo(build2("MESSAGE: ","Cannot add pathway_id ",pathway_id,"."))
     CALL echo(build2("REASON:  ","Phase has never been initiated."))
    ENDIF
    RETURN("N")
   ENDIF
   IF ( NOT (type_mean IN ("CAREPLAN", "PHASE")))
    IF (debug=1)
     CALL echo(build2("MESSAGE: ","Cannot add pathway_id ",pathway_id,"."))
     CALL echo(build2("REASON:  ",
       "Phase is not a single phase plan or phase of a multiple phase plan."))
    ENDIF
    RETURN("N")
   ENDIF
   IF (allow_copy_personal_plan <= personal_plans_none
    AND ref_owner_person_id > 0.0)
    IF (debug=1)
     CALL echo(build2("MESSAGE: ","Cannot add pathway_id ",pathway_id,"."))
     CALL echo(build2("REASON:  ","No personal plans are allowed."))
    ENDIF
    RETURN("N")
   ENDIF
   IF (canaddplantype(pathway_type_cd)="N")
    IF (debug=1)
     CALL echo(build2("MESSAGE: ","Cannot add pathway_id ",pathway_id,"."))
     CALL echo(build2("REASON:  ","Do not have privileges to add this pathway_type_cd."))
    ENDIF
    RETURN("N")
   ENDIF
   RETURN("Y")
 END ;Subroutine
 SUBROUTINE canaddplantype(dpathwaytypecd)
   IF (nexcludecnt > 0)
    SET foundidx = locateval(findidx,1,nexcludecnt,dpathwaytypecd,request->plan_type_exclude_list[
     findidx].pathway_type_cd)
    IF (foundidx > 0)
     RETURN("N")
    ENDIF
   ENDIF
   IF (nincludecnt > 0)
    SET foundidx = locateval(findidx,1,nincludecnt,dpathwaytypecd,request->plan_type_include_list[
     findidx].pathway_type_cd)
    IF (foundidx=0)
     RETURN("N")
    ENDIF
   ENDIF
   RETURN("Y")
 END ;Subroutine
 SET stat = alterlist(request->visit_list,encounter_new_list_size)
 FOR (idx = (encounter_list_size+ 1) TO encounter_new_list_size)
   SET request->visit_list[idx].encntr_id = request->visit_list[encounter_list_size].encntr_id
 ENDFOR
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(encounter_loop_count)),
   pathway pw
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ encounter_batch_size))))
   JOIN (pw
   WHERE expand(idx,nstart,(nstart+ (encounter_batch_size - 1)),pw.encntr_id,request->visit_list[idx]
    .encntr_id)
    AND pw.pw_status_cd IN (initiated_code_value, discontinued_code_value, completed_code_value,
   initreview_code_value, futurereview_code_value,
   future_code_value)
    AND pw.review_status_flag != 3)
  HEAD REPORT
   dummy = 0
  DETAIL
   IF (pw.pw_status_cd IN (initreview_code_value, futurereview_code_value, future_code_value))
    bphasestartedind = 1
   ELSE
    bphasestartedind = pw.started_ind
   ENDIF
   IF (canaddphase(pw.pathway_id,pw.pathway_type_cd,pw.ref_owner_person_id,bphasestartedind,pw
    .type_mean)="Y")
    pathwayidx = 0
    IF (lpathwaycount > 0)
     pathwayidx = locateval(findidx,1,lpathwaycount,pw.pw_group_nbr,pathway->qual[findidx].
      pw_group_nbr,
      check_facility,pathway->qual[findidx].privilege_ind)
    ENDIF
    IF (pathwayidx=0)
     lpathwaycount = (lpathwaycount+ 1)
     IF (lpathwaycount > lpathwaysize)
      lpathwaysize = (lpathwaysize+ pathway_batch_size), pathwayloopcount = (pathwayloopcount+ 1),
      stat = alterlist(pathway->qual,lpathwaysize)
     ENDIF
     pathwayidx = lpathwaycount
    ELSEIF (cnvtdatetimeutc(pw.start_dt_tm,3,pw.start_tz) >= cnvtdatetimeutc(pathway->qual[pathwayidx
     ].start_dt_tm,3,pathway->qual[pathwayidx].start_tz))
     pathwayidx = 0
    ENDIF
    IF (pathwayidx > 0)
     pathway->qual[pathwayidx].old_pw_cat_id = pw.pw_cat_group_id, pathway->qual[pathwayidx].
     old_version = pw.version, pathway->qual[pathwayidx].privilege_ind = check_facility,
     pathway->qual[pathwayidx].pw_group_desc = trim(pw.pw_group_desc), pathway->qual[pathwayidx].
     pw_group_nbr = pw.pw_group_nbr, pathway->qual[pathwayidx].start_dt_tm = pw.start_dt_tm,
     pathway->qual[pathwayidx].start_tz = pw.start_tz, pathway->qual[pathwayidx].pathway_id = pw
     .pathway_id, pathway->qual[pathwayidx].pw_cat_synonym_id = 0.0,
     pathway->qual[pathwayidx].primary_ind = 1
    ENDIF
   ENDIF
  FOOT REPORT
   FOR (pathwayidx = (lpathwaycount+ 1) TO lpathwaysize)
     pathway->qual[pathwayidx].pw_group_nbr = pathway->qual[lpathwaycount].pw_group_nbr, pathway->
     qual[pathwayidx].old_pw_cat_id = pathway->qual[lpathwaycount].old_pw_cat_id, pathway->qual[
     pathwayidx].pathway_id = pathway->qual[lpathwaycount].pathway_id,
     pathway->qual[pathwayidx].privilege_ind = do_not_load
   ENDFOR
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL stoptimer("01 - Get current active plans")
 ENDIF
 SET reply->status_data.status = "Z"
 IF (lpathwaysize < 1)
  GO TO exit_program
 ENDIF
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 IF (virtual_catalog_flag=1)
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(pathwayloopcount)),
    pathway pw,
    encounter e
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ pathway_batch_size))))
    JOIN (pw
    WHERE expand(idx,nstart,(nstart+ (pathway_batch_size - 1)),pw.pw_group_nbr,pathway->qual[idx].
     pw_group_nbr))
    JOIN (e
    WHERE e.encntr_id=pw.encntr_id)
   ORDER BY pw.pw_group_nbr, pw.pathway_id
   HEAD REPORT
    dummy = 0
   HEAD pw.pw_group_nbr
    bavailableind = 0
   HEAD pw.pathway_id
    IF (pw.pw_status_cd IN (futurereview_code_value, future_code_value))
     bavailableind = 1
    ELSE
     IF (pw.pw_status_cd=initreview_code_value)
      bphasestartedind = 1
     ELSE
      bphasestartedind = pw.started_ind
     ENDIF
     IF (bphasestartedind=1
      AND e.loc_facility_cd=facility_cd)
      bavailableind = 1
     ENDIF
    ENDIF
   DETAIL
    dummy = 0
   FOOT  pw.pathway_id
    dummy = 0
   FOOT  pw.pw_group_nbr
    IF (bavailableind=0)
     pathwayidx = locateval(findidx,1,lpathwaysize,pw.pw_group_nbr,pathway->qual[findidx].
      pw_group_nbr)
     IF (pathwayidx > 0)
      pathway->qual[pathwayidx].privilege_ind = do_not_load
     ENDIF
    ENDIF
   FOOT REPORT
    dummy = 0
   WITH nocounter
  ;end select
 ENDIF
 IF (debug=1)
  CALL stoptimer("02 - Filter plans by facility")
 ENDIF
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pathwayloopcount)),
   pathway pw
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ pathway_batch_size))))
   JOIN (pw
   WHERE expand(idx,nstart,(nstart+ (pathway_batch_size - 1)),pw.pw_group_nbr,pathway->qual[idx].
    pw_group_nbr)
    AND pw.pw_status_cd=void_code_value
    AND pw.type_mean="PHASE")
  HEAD REPORT
   dummy = 0
  DETAIL
   pathwayidx = locateval(findidx,1,lpathwaysize,pw.pw_group_nbr,pathway->qual[findidx].pw_group_nbr)
   IF (pathwayidx > 0)
    pathway->qual[pathwayidx].privilege_ind = do_not_load
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL stoptimer("03 - Filter plans with voided phases")
 ENDIF
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pathwayloopcount)),
   nomen_entity_reltn ner,
   nomenclature n
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ pathway_batch_size))))
   JOIN (ner
   WHERE ner.parent_entity_name="PATHWAY"
    AND expand(idx,nstart,(nstart+ (pathway_batch_size - 1)),ner.parent_entity_id,pathway->qual[idx].
    pathway_id)
    AND ner.child_entity_name="DIAGNOSIS"
    AND ner.priority=1)
   JOIN (n
   WHERE n.nomenclature_id=ner.nomenclature_id)
  HEAD REPORT
   dummy = 0
  DETAIL
   pathwayidx = locateval(findidx,1,lpathwaysize,ner.parent_entity_id,pathway->qual[findidx].
    pathway_id,
    check_facility,pathway->qual[findidx].privilege_ind)
   IF (pathwayidx > 0)
    pathway->qual[pathwayidx].diagnosis_display = n.source_string
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL stoptimer("04 - Get diagnosis for plans")
 ENDIF
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SET nstart = 1
 SELECT
  IF (facility_cd > 0.0)
   FROM (dummyt d1  WITH seq = value(pathwayloopcount)),
    pathway_catalog pwc,
    pathway_catalog pwc2,
    pw_cat_flex pwcf
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ pathway_batch_size))))
    JOIN (pwc
    WHERE expand(idx,nstart,(nstart+ (pathway_batch_size - 1)),pwc.pathway_catalog_id,pathway->qual[
     idx].old_pw_cat_id))
    JOIN (pwc2
    WHERE pwc2.version_pw_cat_id=pwc.version_pw_cat_id)
    JOIN (pwcf
    WHERE pwcf.pathway_catalog_id=pwc2.pathway_catalog_id
     AND ((pwcf.parent_entity_id IN (facility_cd, 0.0)
     AND pwcf.parent_entity_name="CODE_VALUE") OR (pwcf.parent_entity_id=pwc2.ref_owner_person_id
     AND pwcf.parent_entity_name="PRSNL")) )
  ELSE
   FROM (dummyt d1  WITH seq = value(pathwayloopcount)),
    pathway_catalog pwc,
    pathway_catalog pwc2
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ pathway_batch_size))))
    JOIN (pwc
    WHERE expand(idx,nstart,(nstart+ (pathway_batch_size - 1)),pwc.pathway_catalog_id,pathway->qual[
     idx].old_pw_cat_id))
    JOIN (pwc2
    WHERE pwc2.version_pw_cat_id=pwc.version_pw_cat_id)
  ENDIF
  INTO "nl:"
  ORDER BY pwc2.version_pw_cat_id, pwc2.version DESC
  HEAD REPORT
   dummy = 0
  HEAD pwc2.version_pw_cat_id
   nversion = 0, ballowcopyforwardind = 0
  DETAIL
   IF (nversion=0
    AND cnvtdatetime(pwc2.beg_effective_dt_tm) <= cnvtdatetime(dcurrentdatetime)
    AND cnvtdatetime(pwc2.end_effective_dt_tm) > cnvtdatetime(dcurrentdatetime))
    nversion = pwc2.version
    IF (pwc2.active_ind=1)
     ballowcopyforwardind = pwc2.allow_copy_forward_ind
    ENDIF
   ENDIF
   IF (((ballowcopyforwardind=1) OR (allow_copy_personal_plan=personal_plans_all
    AND pwc2.ref_owner_person_id > 0.0)) )
    pathwayidx = locateval(findidx,1,lpathwaysize,pwc.pathway_catalog_id,pathway->qual[findidx].
     old_pw_cat_id,
     check_facility,pathway->qual[findidx].privilege_ind)
    WHILE (pathwayidx > 0)
      pathway->qual[pathwayidx].old_version = pwc.version, pathway->qual[pathwayidx].new_version =
      pwc2.version, pathway->qual[pathwayidx].new_pw_cat_id = pwc2.pathway_catalog_id,
      pathway->qual[pathwayidx].version_pw_cat_id = pwc2.version_pw_cat_id, pathway->qual[pathwayidx]
      .privilege_ind = load_phase, nversionidx = 0
      IF (nversioncount > 0)
       nversionidx = locateval(findidx,1,nversioncount,pwc.version_pw_cat_id,version->qual[findidx].
        version_pw_cat_id)
      ENDIF
      IF (nversionidx=0)
       nversioncount = (nversioncount+ 1)
       IF (nversioncount > nversionsize)
        nversionsize = (nversionsize+ 20), stat = alterlist(version->qual,nversionsize)
       ENDIF
       nversionidx = nversioncount, version->qual[nversionidx].version_pw_cat_id = pwc
       .version_pw_cat_id
      ENDIF
      IF (nversionidx > 0)
       IF ((version->qual[nversionidx].highest_version_used < pwc.version))
        version->qual[nversionidx].highest_version_used = pwc.version
       ENDIF
      ENDIF
      pathwayidx = locateval(findidx,(pathwayidx+ 1),lpathwaysize,pwc.pathway_catalog_id,pathway->
       qual[findidx].old_pw_cat_id,
       check_facility,pathway->qual[findidx].privilege_ind)
    ENDWHILE
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL stoptimer("05 - Get plan catalog information")
 ENDIF
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pathwayloopcount)),
   pw_evidence_reltn pwer
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ pathway_batch_size))))
   JOIN (pwer
   WHERE expand(idx,nstart,(nstart+ (pathway_batch_size - 1)),pwer.pathway_catalog_id,pathway->qual[
    idx].old_pw_cat_id))
  HEAD REPORT
   dummy = 0
  DETAIL
   IF (pwer.dcp_clin_cat_cd=0.0
    AND pwer.dcp_clin_sub_cat_cd=0.0
    AND pwer.pathway_comp_id=0.0
    AND pwer.type_mean IN ("REFTEXT", "ZYNX", "URL"))
    pathwayidx = locateval(findidx,1,lpathwaysize,pwer.pathway_catalog_id,pathway->qual[findidx].
     old_pw_cat_id,
     load_phase,pathway->qual[findidx].privilege_ind)
    WHILE (pathwayidx > 0)
      IF (pwer.ref_text_reltn_id > 0.0)
       pathway->qual[pathwayidx].pw_evidence_reltn_id = pwer.ref_text_reltn_id, pathway->qual[
       pathwayidx].pw_evidence_reltn_id = pwer.pw_evidence_reltn_id
      ENDIF
      IF (pwer.evidence_locator > " ")
       pathway->qual[pathwayidx].evidence_locator = pwer.evidence_locator
      ENDIF
      pathwayidx = locateval(findidx,(pathwayidx+ 1),lpathwaysize,pwer.pathway_catalog_id,pathway->
       qual[findidx].old_pw_cat_id,
       load_phase,pathway->qual[findidx].privilege_ind)
    ENDWHILE
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL stoptimer("06 - Get plan reference text")
 ENDIF
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SET replyidx = 0
 SET findidx = 0
 SET idx = locateval(findidx,(findidx+ 1),lpathwaycount,load_phase,pathway->qual[findidx].
  privilege_ind)
 WHILE (idx > 0)
   SET nversionidx = locateval(findidx,1,nversioncount,pathway->qual[idx].version_pw_cat_id,version->
    qual[findidx].version_pw_cat_id)
   IF ((version->qual[nversionidx].highest_version_used=pathway->qual[idx].old_version))
    SET replyidx = (replyidx+ 1)
    IF (replyidx > size(reply->qual,5))
     SET stat = alterlist(reply->qual,(replyidx+ 9))
     SET stat = alterlist(catalogs->qual,(replyidx+ 9))
    ENDIF
    SET reply->qual[replyidx].pw_group_nbr = pathway->qual[idx].pw_group_nbr
    SET reply->qual[replyidx].pw_group_desc = pathway->qual[idx].pw_group_desc
    SET reply->qual[replyidx].start_dt_tm = pathway->qual[idx].start_dt_tm
    SET reply->qual[replyidx].start_tz = pathway->qual[idx].start_tz
    SET reply->qual[replyidx].pw_evidence_reltn_id = pathway->qual[idx].pw_evidence_reltn_id
    SET reply->qual[replyidx].evidence_locator = pathway->qual[idx].evidence_locator
    SET reply->qual[replyidx].old_version = pathway->qual[idx].old_version
    SET reply->qual[replyidx].new_version = pathway->qual[idx].new_version
    SET reply->qual[replyidx].old_pw_cat_id = pathway->qual[idx].old_pw_cat_id
    SET reply->qual[replyidx].new_pw_cat_id = pathway->qual[idx].new_pw_cat_id
    SET reply->qual[replyidx].diagnosis_display = pathway->qual[idx].diagnosis_display
    SET catalogs->qual[replyidx].pathway_catalog_id = pathway->qual[idx].old_pw_cat_id
    SET reply->qual[replyidx].pw_cat_synonym_id = pathway->qual[idx].pw_cat_synonym_id
    SET reply->qual[replyidx].primary_ind = 1
   ENDIF
   SET idx = locateval(findidx,(idx+ 1),lpathwaysize,load_phase,pathway->qual[findidx].privilege_ind)
 ENDWHILE
 IF (replyidx > 0
  AND replyidx < size(reply->qual,5))
  SET stat = alterlist(reply->qual,replyidx)
 ENDIF
 IF (replyidx > 0)
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug=1)
  CALL stoptimer("07 - Populate reply")
 ENDIF
 SET plantotal = value(size(reply->qual,5))
 SET lstart = 1
 SET num = 0
 SET catalogs->batch_size = 20
 SET catalogs->size = plantotal
 SET catalogs->loop_count = ceil((cnvtreal(plantotal)/ catalogs->batch_size))
 SET catalogs->new_size = (catalogs->loop_count * catalogs->batch_size)
 SET stat = alterlist(catalogs->qual,catalogs->new_size)
 FOR (indx = (catalogs->size+ 1) TO catalogs->new_size)
   SET catalogs->qual[indx].pathway_catalog_id = catalogs->qual[plantotal].pathway_catalog_id
 ENDFOR
 SELECT INTO "nl:"
  rtr.parent_entity_name, rtr.parent_entity_id
  FROM (dummyt d1  WITH seq = value(catalogs->loop_count)),
   ref_text_reltn rtr
  PLAN (d1
   WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ catalogs->batch_size))))
   JOIN (rtr
   WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
    AND expand(num,lstart,(lstart+ (catalogs->batch_size - 1)),rtr.parent_entity_id,catalogs->qual[
    num].pathway_catalog_id)
    AND rtr.active_ind=1)
  ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
  HEAD rtr.parent_entity_id
   FOR (indx = 1 TO plantotal)
     IF ((reply->qual[indx].old_pw_cat_id=rtr.parent_entity_id))
      reply->qual[indx].ref_text_ind = 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
#exit_program
 CALL echorecord(pathway)
 FREE SET pathway
 FREE SET version
 SET mod_date = "April 21, 2011"
 SET last_mod = "004"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),qtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<------------------------------------------>")
 CALL echo("<---   END DCP_GET_PLANS_BY_ENCNTR_ID   --->")
 CALL echo("<------------------------------------------>")
END GO
