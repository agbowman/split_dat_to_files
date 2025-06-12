CREATE PROGRAM dcp_get_problem_dx_plans:dba
 SET modify = predeclare
 RECORD reply(
   1 nomlist[*]
     2 nomenclatureid = f8
     2 planlist[*]
       3 pathwaycatid = f8
       3 dispdescription = vc
       3 pwevidencereltnid = f8
       3 evidencelocator = vc
       3 typemean = vc
       3 ref_text_ind = i2
     2 previousplanlist[*]
       3 pw_group_nbr = f8
       3 pw_group_desc = vc
       3 start_dt_tm = dq8
       3 start_tz = i2
       3 pw_evidence_reltn_id = f8
       3 evidence_locator = vc
       3 old_version = i4
       3 new_version = i4
       3 old_pw_cat_id = f8
       3 new_pw_cat_id = f8
       3 ref_text_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 list[*]
     2 nomenclature_id = f8
     2 concept_cki = vc
 )
 RECORD temp2(
   1 list[*]
     2 nomenclatureid = f8
     2 pathwaycatid = f8
     2 dispdescription = vc
     2 pwevidencereltnid = f8
     2 evidencelocator = vc
     2 typemean = vc
 )
 RECORD temp3(
   1 list[*]
     2 nomenclature_id = f8
 )
 FREE RECORD pathway
 RECORD pathway(
   1 qual[*]
     2 nomenclature_id = f8
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
 )
 DECLARE i = i4 WITH noconstant(0)
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE pcnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE nomid = f8 WITH noconstant(0.0)
 DECLARE prevnomid = f8 WITH noconstant(0.0)
 DECLARE snomedct_cd = f8 WITH constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE plananddx_cd = f8 WITH constant(uar_get_code_by("MEANING",29753,"PLANANDDX"))
 DECLARE debug = i2 WITH protect, constant(validate(request->debug))
 DECLARE virtual_catalog_flag = i2 WITH protect, constant(validate(request->virtual_catalog_flag,0))
 DECLARE facility_cd = f8 WITH protect, constant(validate(request->facilitycd,0.0))
 DECLARE allow_copy_personal_plan = i2 WITH protect, constant(validate(request->
   allow_copy_personal_plan,0))
 DECLARE last_mod = c3 WITH public, constant("000")
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
 DECLARE nomenclature_list_size = i4 WITH protect, constant(size(request->nomlist,5))
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
 DECLARE replynomenidx = i4 WITH protect, noconstant(0)
 DECLARE replynomensize = i4 WITH protect, noconstant(0)
 DECLARE replyidx = i4 WITH protect, noconstant(0)
 DECLARE bcanadd = i2 WITH protect, noconstant(0)
 DECLARE nphasecountatfacility = i4 WITH protect, noconstant(0)
 DECLARE nphasecount = i4 WITH protect, noconstant(0)
 DECLARE nversion = i4 WITH protect, noconstant(0)
 DECLARE ballowcopyforwardind = i2 WITH protect, noconstant(0)
 DECLARE bvalidatfacility = i2 WITH protect, noconstant(0)
 DECLARE indx = i2 WITH protect, noconstant(0)
 DECLARE nomlistsize = i2 WITH protect, noconstant(0)
 DECLARE planlistsize = i2 WITH protect, noconstant(0)
 DECLARE previousplanlistsize = i2 WITH protect, noconstant(0)
 DECLARE reftextcnt = i2 WITH protect, noconstant(0)
 DECLARE lpathwaysize = i4 WITH protect, noconstant(0)
 DECLARE lpathwaycount = i4 WITH protect, noconstant(0)
 DECLARE iavailableflag = i2 WITH protect, noconstant(0)
 DECLARE l_batch_size = i4 WITH protect, noconstant(20)
 DECLARE l_size = i4 WITH protect, noconstant(0)
 DECLARE l_loop_count = i4 WITH protect, noconstant(0)
 DECLARE l_new_size = i4 WITH protect, noconstant(0)
 DECLARE l_start = i4 WITH protect, noconstant(0)
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
  =vc,
  nomenclature_id=f8) = c1
 DECLARE canaddplantype(dpathwaytypecd=f8) = c1
 SUBROUTINE canaddphase(pathway_id,pathway_type_cd,ref_owner_person_id,started_ind,type_mean,
  nomenclature_id)
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
   IF (locateval(findidx,1,nomenclature_list_size,nomenclature_id,request->nomlist[findidx].id)=0)
    IF (debug=1)
     CALL echo(build2("MESSAGE: ","Cannot add pathway_id ",pathway_id,"."))
     CALL echo(build2("REASON:  ","Diagnosis was not found in list."))
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
 SET reply->status_data.status = "F"
 SET high = value(size(request->nomlist,5))
 SELECT INTO "NL:"
  n.nomenclature_id, cce.child_concept_cki, cce.parent_concept_cki
  FROM nomenclature n,
   cmt_concept_explode cce,
   (dummyt d  WITH seq = value(size(request->nomlist,5)))
  PLAN (d)
   JOIN (n
   WHERE (n.nomenclature_id=request->nomlist[d.seq].id)
    AND n.source_vocabulary_cd=snomedct_cd)
   JOIN (cce
   WHERE cce.child_concept_cki=n.concept_cki)
  ORDER BY n.nomenclature_id, cce.child_concept_cki, cce.parent_concept_cki
  HEAD REPORT
   cnt = 0
  HEAD cce.child_concept_cki
   cnt = (cnt+ 1)
   IF (cnt > size(temp->list,5))
    stat = alterlist(temp->list,(cnt+ 20))
   ENDIF
   temp->list[cnt].nomenclature_id = n.nomenclature_id, temp->list[cnt].concept_cki = cce
   .child_concept_cki
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(temp->list,5))
    stat = alterlist(temp->list,(cnt+ 20))
   ENDIF
   temp->list[cnt].nomenclature_id = n.nomenclature_id, temp->list[cnt].concept_cki = cce
   .parent_concept_cki
  FOOT  cce.child_concept_cki
   cnt = cnt
  FOOT REPORT
   stat = alterlist(temp->list,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM nomenclature n,
   cmt_cross_map ccm,
   cmt_concept_explode cce,
   (dummyt d  WITH seq = value(size(request->nomlist,5)))
  PLAN (d)
   JOIN (n
   WHERE (n.nomenclature_id=request->nomlist[d.seq].id)
    AND n.source_vocabulary_cd != snomedct_cd)
   JOIN (ccm
   WHERE ccm.concept_cki=outerjoin(n.concept_cki)
    AND ccm.beg_effective_dt_tm >= outerjoin(n.beg_effective_dt_tm)
    AND ccm.end_effective_dt_tm <= outerjoin(n.end_effective_dt_tm))
   JOIN (cce
   WHERE cce.child_concept_cki=outerjoin(ccm.target_concept_cki))
  ORDER BY n.nomenclature_id, cce.child_concept_cki, cce.parent_concept_cki
  HEAD REPORT
   cnt = size(temp->list,5)
  HEAD n.nomenclature_id
   IF (n.concept_cki > " ")
    cnt = (cnt+ 1)
    IF (cnt > size(temp->list,5))
     stat = alterlist(temp->list,(cnt+ 20))
    ENDIF
    temp->list[cnt].nomenclature_id = n.nomenclature_id, temp->list[cnt].concept_cki = n.concept_cki
   ENDIF
  HEAD cce.child_concept_cki
   IF (((ccm.map_type_flag=1) OR (ccm.map_type_flag=5)) )
    cnt = (cnt+ 1)
    IF (cnt > size(temp->list,5))
     stat = alterlist(temp->list,(cnt+ 20))
    ENDIF
    temp->list[cnt].nomenclature_id = n.nomenclature_id, temp->list[cnt].concept_cki = cce
    .child_concept_cki
   ENDIF
  DETAIL
   IF (((ccm.map_type_flag=1) OR (ccm.map_type_flag=5)) )
    cnt = (cnt+ 1)
    IF (cnt > size(temp->list,5))
     stat = alterlist(temp->list,(cnt+ 20))
    ENDIF
    temp->list[cnt].nomenclature_id = n.nomenclature_id, temp->list[cnt].concept_cki = cce
    .parent_concept_cki
   ENDIF
  FOOT  cce.child_concept_cki
   cnt = cnt
  FOOT REPORT
   stat = alterlist(temp->list,cnt)
  WITH nocounter
 ;end select
 IF (value(size(temp->list,5)) <= 0)
  GO TO exit_script
 ENDIF
 SET high = value(size(temp->list,5))
 SELECT INTO "nl:"
  nomid = temp->list[d.seq].nomenclature_id, pwc.display_description
  FROM concept_cki_entity_r ccer,
   pw_cat_flex pcf,
   pathway_catalog pwc,
   (dummyt d  WITH seq = value(high))
  PLAN (d)
   JOIN (ccer
   WHERE (ccer.concept_cki=temp->list[d.seq].concept_cki)
    AND ccer.reltn_type_cd=plananddx_cd
    AND ccer.entity_name="PATHWAY_CATALOG")
   JOIN (pcf
   WHERE pcf.parent_entity_id IN (0, request->facilitycd)
    AND pcf.parent_entity_name="CODE_VALUE"
    AND ((pcf.pathway_catalog_id+ 0.0)=(ccer.entity_id+ 0.0)))
   JOIN (pwc
   WHERE pwc.pathway_catalog_id=pcf.pathway_catalog_id
    AND pwc.active_ind=1
    AND pwc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
  ORDER BY nomid, pwc.display_description
  HEAD REPORT
   cnt = 0
  HEAD nomid
   cnt = cnt
  HEAD pwc.display_description
   IF (canaddplantype(pwc.pathway_type_cd)="Y")
    cnt = (cnt+ 1)
    IF (cnt > size(temp2->list,5))
     stat = alterlist(temp2->list,(cnt+ 20))
    ENDIF
    temp2->list[cnt].nomenclatureid = temp->list[d.seq].nomenclature_id, temp2->list[cnt].
    pathwaycatid = pwc.pathway_catalog_id, temp2->list[cnt].dispdescription = trim(pwc
     .display_description)
   ENDIF
  DETAIL
   dummy = 0
  FOOT  pwc.pathway_catalog_id
   dummy = 0
  FOOT  nomid
   dummy = 0
  FOOT REPORT
   stat = alterlist(temp2->list,cnt)
  WITH nocounter
 ;end select
 SET high = value(size(temp2->list,5))
 IF (high > 0)
  SELECT INTO "nl:"
   FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = value(size(temp2->list,5)))
   PLAN (d)
    JOIN (per
    WHERE (per.pathway_catalog_id=temp2->list[d.seq].pathwaycatid))
   HEAD REPORT
    cnt = 0
   DETAIL
    idx = 0
    IF (per.dcp_clin_cat_cd=0
     AND per.dcp_clin_sub_cat_cd=0
     AND per.pathway_comp_id=0)
     IF (per.type_mean="REFTEXT")
      temp2->list[d.seq].pwevidencereltnid = per.pw_evidence_reltn_id
     ENDIF
     IF (((per.type_mean="ZYNX") OR (per.type_mean="URL")) )
      temp2->list[d.seq].evidencelocator = per.evidence_locator
     ENDIF
    ENDIF
   FOOT REPORT
    cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 SET high = value(size(temp2->list,5))
 SET prevnomid = 0.0
 SET ncnt = 0
 SET pcnt = 0
 FOR (i = 1 TO high)
   IF ((prevnomid != temp2->list[i].nomenclatureid))
    SET ncnt = (ncnt+ 1)
    IF (ncnt > size(reply->nomlist,5))
     SET stat = alterlist(reply->nomlist,(ncnt+ 10))
    ENDIF
    SET reply->nomlist[ncnt].nomenclatureid = temp2->list[i].nomenclatureid
    IF (prevnomid != 0)
     SET stat = alterlist(reply->nomlist[(ncnt - 1)].planlist,pcnt)
    ENDIF
    SET prevnomid = temp2->list[i].nomenclatureid
    SET pcnt = 0
   ENDIF
   SET pcnt = (pcnt+ 1)
   IF (pcnt > size(reply->nomlist[ncnt].planlist,5))
    SET stat = alterlist(reply->nomlist[ncnt].planlist,(pcnt+ 10))
   ENDIF
   SET reply->nomlist[ncnt].planlist[pcnt].pathwaycatid = temp2->list[i].pathwaycatid
   SET reply->nomlist[ncnt].planlist[pcnt].dispdescription = trim(temp2->list[i].dispdescription)
   SET reply->nomlist[ncnt].planlist[pcnt].pwevidencereltnid = temp2->list[i].pwevidencereltnid
   SET reply->nomlist[ncnt].planlist[pcnt].evidencelocator = trim(temp2->list[i].evidencelocator)
   SET reply->nomlist[ncnt].planlist[pcnt].typemean = trim(temp2->list[i].typemean)
   IF (i=high)
    SET stat = alterlist(reply->nomlist[ncnt].planlist,pcnt)
    SET stat = alterlist(reply->nomlist,ncnt)
   ENDIF
 ENDFOR
 IF (validate(request->copy_forward_ind,0)=0)
  GO TO exit_script
 ENDIF
 RECORD version(
   1 qual[*]
     2 version_pw_cat_id = f8
     2 highest_version_used = i4
 )
 IF (validate(request->visit_list)=0)
  GO TO exit_script
 ENDIF
 IF (validate(request->visit_list[1].encntr_id)=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(request->visit_list,encounter_new_list_size)
 FOR (idx = (encounter_list_size+ 1) TO encounter_new_list_size)
   SET request->visit_list[idx].encntr_id = request->visit_list[encounter_list_size].encntr_id
 ENDFOR
 IF (debug=1)
  CALL starttimer(ndummy)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(encounter_loop_count)),
   pathway pw,
   nomen_entity_reltn ner
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ encounter_batch_size))))
   JOIN (pw
   WHERE expand(idx,nstart,(nstart+ (encounter_batch_size - 1)),pw.encntr_id,request->visit_list[idx]
    .encntr_id)
    AND pw.pw_status_cd IN (initiated_code_value, discontinued_code_value, completed_code_value))
   JOIN (ner
   WHERE ner.parent_entity_name="PATHWAY"
    AND ner.parent_entity_id=pw.pathway_id
    AND ner.child_entity_name="DIAGNOSIS"
    AND ner.priority=1)
  HEAD REPORT
   dummy = 0
  DETAIL
   IF (canaddphase(pw.pathway_id,pw.pathway_type_cd,pw.ref_owner_person_id,pw.started_ind,pw
    .type_mean,
    ner.nomenclature_id)="Y")
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
     pathway->qual[pathwayidx].nomenclature_id = ner.nomenclature_id, pathway->qual[pathwayidx].
     old_pw_cat_id = pw.pw_cat_group_id, pathway->qual[pathwayidx].old_version = pw.version,
     pathway->qual[pathwayidx].privilege_ind = check_facility, pathway->qual[pathwayidx].
     pw_group_desc = trim(pw.pw_group_desc), pathway->qual[pathwayidx].pw_group_nbr = pw.pw_group_nbr,
     pathway->qual[pathwayidx].start_dt_tm = pw.start_dt_tm, pathway->qual[pathwayidx].start_tz = pw
     .start_tz
    ENDIF
   ENDIF
  FOOT REPORT
   FOR (pathwayidx = (lpathwaycount+ 1) TO lpathwaysize)
     pathway->qual[pathwayidx].pw_group_nbr = pathway->qual[lpathwaycount].pw_group_nbr, pathway->
     qual[pathwayidx].old_pw_cat_id = pathway->qual[lpathwaycount].old_pw_cat_id, pathway->qual[
     pathwayidx].privilege_ind = do_not_load
   ENDFOR
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL stoptimer("01 - Get current active plans")
 ENDIF
 SET reply->status_data.status = "Z"
 IF (lpathwaysize < 1)
  GO TO exit_script
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
    iavailableflag = 0
   HEAD pw.pathway_id
    IF (iavailableflag=0
     AND pw.started_ind=1
     AND e.loc_facility_cd=facility_cd)
     iavailableflag = 1
    ENDIF
   DETAIL
    dummy = 0
   FOOT  pw.pathway_id
    dummy = 0
   FOOT  pw.pw_group_nbr
    IF (iavailableflag < 1)
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
    AND cnvtdatetime(pwc2.beg_effective_dt_tm) <= cnvtdatetime(curdate,curtime3)
    AND cnvtdatetime(pwc2.end_effective_dt_tm) > cnvtdatetime(curdate,curtime3))
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
       pathway->qual[pathwayidx].pw_evidence_reltn_id = pwer.pw_evidence_reltn_id
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
    SET replynomenidx = 0
    SET replynomensize = size(reply->nomlist,5)
    SET replynomenidx = locateval(findidx,1,replynomensize,pathway->qual[idx].nomenclature_id,reply->
     nomlist[findidx].nomenclatureid)
    IF (replynomenidx=0)
     SET replynomensize = (replynomensize+ 1)
     SET replynomenidx = replynomensize
     SET stat = alterlist(reply->nomlist,replynomensize)
     SET reply->nomlist[replynomenidx].nomenclatureid = pathway->qual[idx].nomenclature_id
    ENDIF
    IF (replynomenidx > 0)
     SET replyidx = (size(reply->nomlist[replynomenidx].previousplanlist,5)+ 1)
     IF (replyidx > 0)
      SET stat = alterlist(reply->nomlist[replynomenidx].previousplanlist,replyidx)
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].pw_group_nbr = pathway->qual[idx].
      pw_group_nbr
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].pw_group_desc = pathway->qual[idx]
      .pw_group_desc
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].start_dt_tm = pathway->qual[idx].
      start_dt_tm
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].start_tz = pathway->qual[idx].
      start_tz
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].pw_evidence_reltn_id = pathway->
      qual[idx].pw_evidence_reltn_id
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].evidence_locator = pathway->qual[
      idx].evidence_locator
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].old_version = pathway->qual[idx].
      old_version
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].new_version = pathway->qual[idx].
      new_version
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].old_pw_cat_id = pathway->qual[idx]
      .old_pw_cat_id
      SET reply->nomlist[replynomenidx].previousplanlist[replyidx].new_pw_cat_id = pathway->qual[idx]
      .new_pw_cat_id
     ENDIF
    ENDIF
   ENDIF
   SET idx = locateval(findidx,(idx+ 1),lpathwaysize,load_phase,pathway->qual[findidx].privilege_ind)
 ENDWHILE
 IF (debug=1)
  CALL stoptimer("07 - Populate reply")
 ENDIF
 RECORD pw_cat_id_list(
   1 list[*]
     2 pathway_catalog_id = f8
 )
 SET l_size = size(pathway->qual,5)
 SET l_loop_count = ceil((cnvtreal(l_size)/ l_batch_size))
 SET l_new_size = (l_loop_count * l_batch_size)
 SET stat = alterlist(pathway->qual,l_new_size)
 FOR (idx = (l_size+ 1) TO l_new_size)
   SET pathway->qual[idx].old_pw_cat_id = pathway->qual[l_size].old_pw_cat_id
 ENDFOR
 SET l_start = 1
 SELECT INTO "nl:"
  rtr.parent_entity_name, rtr.parent_entity_id
  FROM (dummyt d1  WITH seq = value(l_loop_count)),
   ref_text_reltn rtr
  PLAN (d1
   WHERE initarray(l_start,evaluate(d1.seq,1,1,(l_start+ l_batch_size))))
   JOIN (rtr
   WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
    AND expand(idx,l_start,(l_start+ (l_batch_size - 1)),rtr.parent_entity_id,pathway->qual[idx].
    old_pw_cat_id)
    AND rtr.active_ind=1)
  ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
  HEAD REPORT
   reftextcnt = 0
  HEAD rtr.parent_entity_id
   IF (rtr.parent_entity_id > 0.0)
    reftextcnt = (reftextcnt+ 1)
    IF (reftextcnt >= size(pw_cat_id_list->list,5))
     stat = alterlist(pw_cat_id_list->list,(reftextcnt+ 10))
    ENDIF
    pw_cat_id_list->list[reftextcnt].pathway_catalog_id = rtr.parent_entity_id
   ENDIF
  FOOT REPORT
   stat = alterlist(pw_cat_id_list->list,reftextcnt)
  WITH nocounter
 ;end select
 IF (l_size > 0
  AND l_size < l_new_size)
  SET stat = alterlist(pathway->qual,l_size)
 ENDIF
 SET l_size = size(temp2->list,5)
 SET l_loop_count = ceil((cnvtreal(l_size)/ l_batch_size))
 SET l_new_size = (l_loop_count * l_batch_size)
 SET stat = alterlist(temp2->list,l_new_size)
 FOR (idx = (l_size+ 1) TO l_new_size)
   SET temp2->list[idx].pathwaycatid = temp2->list[l_size].pathwaycatid
 ENDFOR
 SET l_start = 1
 SELECT INTO "nl:"
  rtr.parent_entity_name, rtr.parent_entity_id
  FROM (dummyt d1  WITH seq = value(l_loop_count)),
   ref_text_reltn rtr
  PLAN (d1
   WHERE initarray(l_start,evaluate(d1.seq,1,1,(l_start+ l_batch_size))))
   JOIN (rtr
   WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
    AND expand(idx,l_start,(l_start+ (l_batch_size - 1)),rtr.parent_entity_id,temp2->list[idx].
    pathwaycatid)
    AND rtr.active_ind=1)
  ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
  HEAD REPORT
   num = 0
  HEAD rtr.parent_entity_id
   IF (rtr.parent_entity_id > 0.0)
    reftextcnt = (reftextcnt+ 1)
    IF (reftextcnt >= size(pw_cat_id_list->list,5))
     stat = alterlist(pw_cat_id_list->list,(reftextcnt+ 10))
    ENDIF
    pw_cat_id_list->list[reftextcnt].pathway_catalog_id = rtr.parent_entity_id
   ENDIF
  FOOT REPORT
   stat = alterlist(pw_cat_id_list->list,reftextcnt)
  WITH nocounter
 ;end select
 IF (l_size > 0
  AND l_size < l_new_size)
  SET stat = alterlist(temp2->list,l_size)
 ENDIF
 SET indx = 0
 SET num = 0
 SET nomlistsize = size(reply->nomlist,5)
 CALL echorecord(pw_cat_id_list)
 FOR (nomindx = 1 TO nomlistsize)
   CALL echo("FOR (nomIndx = 1 to nomListSize)")
   SET planlistsize = size(reply->nomlist[nomindx].planlist,5)
   SET previousplanlistsize = size(reply->nomlist[nomindx].previousplanlist,5)
   FOR (indx = 1 TO planlistsize)
     CALL echo("FOR (indx = 1 TO planListSize )")
     CALL echo(concat("LOCATEVAL1 = ",build(locateval(num,1,reftextcnt,reply->nomlist[nomindx].
         planlist[indx].pathwaycatid,pw_cat_id_list->list[num].pathway_catalog_id))))
     IF (locateval(num,1,reftextcnt,reply->nomlist[nomindx].planlist[indx].pathwaycatid,
      pw_cat_id_list->list[num].pathway_catalog_id) > 0)
      SET reply->nomlist[nomindx].planlist[indx].ref_text_ind = 1
     ELSE
      SET reply->nomlist[nomindx].planlist[indx].ref_text_ind = 0
     ENDIF
   ENDFOR
   FOR (indx = 1 TO previousplanlistsize)
    CALL echo(concat("LOCATEVAL2 = ",build(locateval(num,1,reftextcnt,reply->nomlist[nomindx].
        previousplanlist[indx].old_pw_cat_id,pw_cat_id_list->list[num].pathway_catalog_id))))
    IF (locateval(num,1,reftextcnt,reply->nomlist[nomindx].previousplanlist[indx].old_pw_cat_id,
     pw_cat_id_list->list[num].pathway_catalog_id) > 0)
     SET reply->nomlist[nomindx].previousplanlist[indx].ref_text_ind = 1
    ELSE
     SET reply->nomlist[nomindx].previousplanlist[indx].ref_text_ind = 0
    ENDIF
   ENDFOR
 ENDFOR
 FREE RECORD pw_cat_id_list
 FREE RECORD temp
#exit_script
 IF (size(reply->nomlist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 FREE SET pathway
 FREE SET version
END GO
