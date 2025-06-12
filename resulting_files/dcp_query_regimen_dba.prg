CREATE PROGRAM dcp_query_regimen:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 regimenlist[*]
     2 person_id = f8
     2 encntr_id = f8
     2 regimen_id = f8
     2 regimen_catalog_id = f8
     2 regimen_description = vc
     2 regimen_name = vc
     2 regimen_status_cd = f8
     2 ordered_as_name = vc
     2 regimen_stop_cd = f8
     2 regimen_stop_text = vc
     2 order_dt_tm = dq8
     2 order_tz = i4
     2 requested_start_dt_tm = dq8
     2 requested_start_tz = i4
     2 end_dt_tm = dq8
     2 end_tz = i4
     2 extend_treatment_ind = i2
     2 updt_cnt = i4
     2 elementlist[*]
       3 regimen_detail_id = f8
       3 regimen_cat_detail_id = f8
       3 activity_entity_id = f8
       3 activity_entity_name = vc
       3 reference_entity_id = f8
       3 reference_entity_name = vc
       3 regimen_detail_sequence = i4
       3 requested_start_dt_tm = dq8
       3 requested_start_tz = i4
       3 cycle_nbr = i4
       3 description = vc
       3 version_pw_cat_id = f8
       3 newest_pw_cat_id = f8
       3 evidence_type_mean = c12
       3 evidence_locator = vc
       3 ref_text_ind = i2
       3 cycle_ind = i2
       3 cycle_label_cd = f8
       3 cycle_begin_nbr = i4
       3 cycle_standard_nbr = i4
       3 cycle_end_nbr = i4
       3 cycle_increment_nbr = i4
       3 cycle_display_end_ind = i2
       3 plan_type_cd = f8
       3 available_ind = i2
       3 active_ind = i2
       3 regimen_detail_status_cd = f8
       3 skip_reason_cd = f8
       3 skip_reason = vc
       3 skip_dt_tm = dq8
       3 skip_tz = i4
       3 skip_prsnl_id = f8
       3 skip_prsnl_name_first = vc
       3 skip_prsnl_name_last = vc
       3 skipcredentiallist[*]
         4 display = vc
       3 relationlist[*]
         4 regimen_detail_r_id = f8
         4 regimen_detail_s_id = f8
         4 type_mean = c12
         4 offset_value = f8
         4 offset_unit_cd = f8
       3 note_text = vc
       3 diagnosis_capture_ind = i2
     2 attributelist[*]
       3 regimen_attribute_id = f8
       3 regimen_cat_attribute_r_id = f8
       3 attribute_display = vc
       3 attribute_display_flag = i2
       3 attribute_mean = c12
       3 input_type_flag = i2
       3 code_set = f8
       3 default_value_id = f8
       3 default_value_name = c30
       3 sequence = i4
     2 add_plan_ind = i2
     2 diagnosis[*]
       3 diagnosis_id = f8
       3 diagnosis_group_id = f8
       3 nomenclature_id = f8
       3 encounter_id = f8
       3 display = vc
       3 concept_cki = vc
       3 source_vocabulary_cd = f8
       3 diagnosis_type_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD cycle_evidence_request
 RECORD cycle_evidence_request(
   1 planlist[*]
     2 pathway_catalog_id = f8
 )
 FREE RECORD planelements
 RECORD planelements(
   1 planlist[*]
     2 pathway_catalog_id = f8
     2 regimen_detail_id = f8
     2 regimen_id = f8
 )
 FREE RECORD noteelements
 RECORD noteelements(
   1 notelist[*]
     2 long_text_id = f8
     2 regimen_detail_id = f8
     2 regimen_id = f8
 )
 FREE RECORD startedplans
 RECORD startedplans(
   1 planlist[*]
     2 planid = f8
 )
 FREE RECORD updateregimens
 RECORD updateregimens(
   1 regimenlist[*]
     2 regimenid = f8
     2 updt_cnt = i4
 )
 FREE RECORD planidbyerrorflag
 RECORD planidbyerrorflag(
   1 planidbyerrorflagcontainer[*]
     2 planid = f8
     2 errorflag = i2
 )
 DECLARE slastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE slastmoddate = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE regimenidx = i4 WITH noconstant(0), protect
 DECLARE attributeidx = i4 WITH noconstant(0), protect
 DECLARE elementidx = i4 WITH noconstant(0), protect
 DECLARE relationidx = i4 WITH noconstant(0), protect
 DECLARE planidx = i4 WITH noconstant(0), protect
 DECLARE plancnt = i4 WITH noconstant(0), protect
 DECLARE planelementidx = i4 WITH noconstant(0), protect
 DECLARE cercnt = i4 WITH noconstant(0), protect
 DECLARE facilityidx = i4 WITH noconstant(0), protect
 DECLARE regimencnt = i4 WITH noconstant(0), protect
 DECLARE regimen_list_start = i4 WITH noconstant(1), protect
 DECLARE credentialcnt = i4 WITH noconstant(0), protect
 DECLARE credentialsize = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE notecnt = i4 WITH noconstant(0), protect
 DECLARE noteidx = i4 WITH noconstant(0), protect
 DECLARE personid = f8 WITH constant(request->person_id), protect
 DECLARE providerid = f8 WITH constant(request->provider_id), protect
 DECLARE providerpatientrelationcd = f8 WITH constant(request->ppr_cd), protect
 DECLARE filterdoneregimensind = i2 WITH constant(request->load_indicators.filter_done_regimens_ind),
 protect
 DECLARE startedplansidx = i4 WITH noconstant(0), protect
 DECLARE startedplanscount = i4 WITH noconstant(0), protect
 DECLARE invokeisregimendoneind = i2 WITH noconstant(0), protect
 DECLARE regimenid = f8 WITH noconstant(0), protect
 DECLARE updateregimensidx = i4 WITH noconstant(0), protect
 DECLARE regimen_action_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002500,
   "CANCEL"))
 DECLARE regimen_action_discontinue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002500,
   "DISCONTINUE"))
 DECLARE detail_skipped_cd = f8 WITH constant(uar_get_code_by("MEANING",4002515,"SKIPPED"))
 DECLARE detail_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",4002515,"PENDING"))
 DECLARE detail_plan_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",4002364,"PENDING"))
 DECLARE detail_plan_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",4002364,"INPROCESS"))
 DECLARE detail_plan_inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",4002364,"INERROR"))
 DECLARE detail_plan_done_cd = f8 WITH constant(uar_get_code_by("MEANING",4002364,"DONE"))
 DECLARE detail_skip_cd = f8 WITH constant(uar_get_code_by("MEANING",4002532,"SKIP")), protect
 DECLARE regimen_status_discontinue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002501,
   "DISCONTINUED"))
 DECLARE regimen_status_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002501,
   "CANCELLED"))
 DECLARE regimen_status_notstarted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002501,
   "NOTSTARTED"))
 DECLARE regimen_status_started_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002501,
   "STARTED"))
 DECLARE regimen_status_done_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002501,"DONE")
  )
 DECLARE enablechartaccessorgind = i2 WITH noconstant(0), protect
 DECLARE planidbyerrorflagidx = i4 WITH noconstant(0), protect
 DECLARE regimen_diagnosis_reltn_cd = f8 WITH constant(uar_get_code_by("MEANING",23549,"REGIMENDIAG")
  ), protect
 DECLARE validate_load_indicators(null) = c1
 DECLARE load_regimens(null) = c1
 DECLARE load_elements(null) = null
 DECLARE load_element_entitys(null) = null
 DECLARE load_element_relations(null) = null
 DECLARE load_attributes(null) = null
 DECLARE load_regimen_stop_info(null) = null
 DECLARE load_regimen_catalog_info(null) = null
 DECLARE load_element_skip_info(null) = null
 DECLARE load_note_elements(null) = null
 DECLARE update_regimens(null) = null
 DECLARE load_diagnosis_relations(null) = null
 DECLARE load_diagnosis_capture_indicator(null) = null
 DECLARE update_redacted_plan(null) = null
 SET reply->status_data.status = "F"
 IF (validate(request->enable_chart_access_org_ind)=1)
  SET enablechartaccessorgind = request->enable_chart_access_org_ind
 ENDIF
 IF (validate_load_indicators(null)="F")
  SET reply->status_data.subeventstatus.operationname = "dcp_query_regimen"
  SET reply->status_data.subeventstatus.operationstatus = "Fail"
  SET reply->status_data.subeventstatus.targetobjectname = "REGIMEN"
  SET reply->status_data.subeventstatus.targetobjectvalue = "Invalid Load Indicators"
  GO TO exit_script
 ENDIF
 IF (load_regimens(null)="Z")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 CALL load_regimen_stop_info(null)
 CALL load_regimen_catalog_info(null)
 IF ((request->load_indicators.attributes_ind=1))
  CALL load_attributes(null)
 ENDIF
 IF ((request->load_indicators.elements_ind=1))
  CALL load_elements(null)
  CALL load_element_skip_info(null)
  CALL load_note_elements(null)
 ENDIF
 IF ((request->load_indicators.element_relations_ind=1))
  CALL load_element_relations(null)
 ENDIF
 IF ((request->load_indicators.element_entity_ind=1))
  CALL load_element_entitys(null)
 ENDIF
 CALL update_regimens(null)
 IF ((request->load_indicators.load_diagnosis_ind=1))
  CALL load_diagnosis_relations(null)
  CALL load_diagnosis_capture_indicator(null)
 ENDIF
 CALL update_invalid_encounter_error_flag(null)
 CALL update_redacted_plan(null)
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE validate_load_indicators(null)
  IF ((request->load_indicators.elements_ind=0))
   IF ((((request->load_indicators.element_entity_ind=1)) OR ((request->load_indicators.
   element_relations_ind=1))) )
    RETURN("F")
   ENDIF
  ENDIF
  RETURN("S")
 END ;Subroutine
 SUBROUTINE load_regimens(null)
  SELECT INTO "nl:"
   FROM regimen r
   WHERE (r.person_id=request->person_id)
   ORDER BY r.order_dt_tm DESC
   HEAD REPORT
    regimenidx = 0
   DETAIL
    IF (((r.regimen_status_cd IN (regimen_status_started_cd, regimen_status_notstarted_cd)) OR (
    filterdoneregimensind=0
     AND r.regimen_status_cd IN (regimen_status_done_cd, regimen_status_discontinue_cd,
    regimen_status_cancelled_cd))) )
     regimenidx += 1
     IF (regimenidx > size(reply->regimenlist,5))
      stat = alterlist(reply->regimenlist,(regimenidx+ 10))
     ENDIF
     reply->regimenlist[regimenidx].person_id = r.person_id, reply->regimenlist[regimenidx].encntr_id
      = r.encntr_id, reply->regimenlist[regimenidx].regimen_id = r.regimen_id,
     reply->regimenlist[regimenidx].regimen_catalog_id = r.regimen_catalog_id, reply->regimenlist[
     regimenidx].regimen_description = r.regimen_description, reply->regimenlist[regimenidx].
     regimen_name = r.regimen_name,
     reply->regimenlist[regimenidx].regimen_status_cd = r.regimen_status_cd, reply->regimenlist[
     regimenidx].ordered_as_name = r.ordered_as_name, reply->regimenlist[regimenidx].order_dt_tm = r
     .order_dt_tm,
     reply->regimenlist[regimenidx].order_tz = r.order_tz, reply->regimenlist[regimenidx].
     requested_start_dt_tm = r.requested_start_dt_tm, reply->regimenlist[regimenidx].
     requested_start_tz = r.requested_start_tz,
     reply->regimenlist[regimenidx].end_dt_tm = r.end_dt_tm, reply->regimenlist[regimenidx].end_tz =
     r.end_tz, reply->regimenlist[regimenidx].updt_cnt = r.updt_cnt
    ENDIF
   FOOT REPORT
    regimencnt = regimenidx, stat = alterlist(reply->regimenlist,regimencnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   RETURN("Z")
  ELSE
   RETURN("S")
  ENDIF
 END ;Subroutine
 SUBROUTINE load_attributes(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(regimencnt)),
     regimen_attribute ra
    PLAN (d1)
     JOIN (ra
     WHERE (ra.regimen_id=reply->regimenlist[d1.seq].regimen_id))
    ORDER BY ra.regimen_id, ra.sequence
    HEAD ra.regimen_id
     attributeidx = 0, regimenidx = locateval(regimenidx,1,value(regimencnt),ra.regimen_id,reply->
      regimenlist[regimenidx].regimen_id)
    DETAIL
     attributeidx += 1
     IF (attributeidx > size(reply->regimenlist[regimenidx].attributelist,5))
      stat = alterlist(reply->regimenlist[regimenidx].attributelist,(attributeidx+ 10))
     ENDIF
     reply->regimenlist[regimenidx].attributelist[attributeidx].regimen_attribute_id = ra
     .regimen_attribute_id, reply->regimenlist[regimenidx].attributelist[attributeidx].
     regimen_cat_attribute_r_id = ra.regimen_cat_attribute_r_id, reply->regimenlist[regimenidx].
     attributelist[attributeidx].attribute_display = ra.attribute_display,
     reply->regimenlist[regimenidx].attributelist[attributeidx].attribute_display_flag = ra
     .attribute_display_flag, reply->regimenlist[regimenidx].attributelist[attributeidx].
     attribute_mean = ra.attribute_mean, reply->regimenlist[regimenidx].attributelist[attributeidx].
     input_type_flag = ra.input_type_flag,
     reply->regimenlist[regimenidx].attributelist[attributeidx].code_set = ra.code_set, reply->
     regimenlist[regimenidx].attributelist[attributeidx].default_value_id = ra.value_id, reply->
     regimenlist[regimenidx].attributelist[attributeidx].default_value_name = ra.value_name,
     reply->regimenlist[regimenidx].attributelist[attributeidx].sequence = ra.sequence
    FOOT  ra.regimen_id
     stat = alterlist(reply->regimenlist[regimenidx].attributelist,attributeidx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE load_elements(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(regimencnt)),
     regimen_detail rd
    PLAN (d1)
     JOIN (rd
     WHERE (rd.regimen_id=reply->regimenlist[d1.seq].regimen_id))
    ORDER BY rd.regimen_id, rd.regimen_detail_sequence
    HEAD REPORT
     planidx = 0, plancnt = 0
    HEAD rd.regimen_id
     elementidx = 0, regimenidx = locateval(regimenidx,1,value(regimencnt),rd.regimen_id,reply->
      regimenlist[regimenidx].regimen_id)
    DETAIL
     elementidx += 1
     IF (elementidx > size(reply->regimenlist[regimenidx].elementlist,5))
      stat = alterlist(reply->regimenlist[regimenidx].elementlist,(elementidx+ 10))
     ENDIF
     reply->regimenlist[regimenidx].elementlist[elementidx].regimen_detail_id = rd.regimen_detail_id,
     reply->regimenlist[regimenidx].elementlist[elementidx].regimen_cat_detail_id = rd
     .regimen_cat_detail_id, reply->regimenlist[regimenidx].elementlist[elementidx].
     activity_entity_id = rd.activity_entity_id,
     reply->regimenlist[regimenidx].elementlist[elementidx].activity_entity_name = rd
     .activity_entity_name, reply->regimenlist[regimenidx].elementlist[elementidx].
     reference_entity_id = rd.reference_entity_id, reply->regimenlist[regimenidx].elementlist[
     elementidx].reference_entity_name = rd.reference_entity_name,
     reply->regimenlist[regimenidx].elementlist[elementidx].regimen_detail_sequence = rd
     .regimen_detail_sequence, reply->regimenlist[regimenidx].elementlist[elementidx].
     requested_start_dt_tm = rd.start_dt_tm, reply->regimenlist[regimenidx].elementlist[elementidx].
     requested_start_tz = rd.start_tz,
     reply->regimenlist[regimenidx].elementlist[elementidx].cycle_nbr = rd.cycle_nbr, reply->
     regimenlist[regimenidx].elementlist[elementidx].regimen_detail_status_cd = rd
     .regimen_detail_status_cd
     IF (rd.reference_entity_name="PATHWAY_CATALOG")
      planidx += 1
      IF (planidx > plancnt)
       plancnt += 10, stat = alterlist(planelements->planlist,plancnt), stat = alterlist(
        cycle_evidence_request->planlist,plancnt)
      ENDIF
      planelements->planlist[planidx].pathway_catalog_id = rd.reference_entity_id, planelements->
      planlist[planidx].regimen_detail_id = rd.regimen_detail_id, planelements->planlist[planidx].
      regimen_id = rd.regimen_id,
      cycle_evidence_request->planlist[planidx].pathway_catalog_id = rd.reference_entity_id
      IF ((reply->regimenlist[regimenidx].regimen_status_cd=regimen_status_started_cd))
       IF (rd.activity_entity_id > 0)
        IF (enablechartaccessorgind=1)
         planidbyerrorflagidx += 1
         IF (planidbyerrorflagidx > size(planidbyerrorflag->planidbyerrorflagcontainer,5))
          stat = alterlist(planidbyerrorflag->planidbyerrorflagcontainer,(planidbyerrorflagidx+ 5))
         ENDIF
         planidbyerrorflag->planidbyerrorflagcontainer[planidbyerrorflagidx].planid = rd
         .activity_entity_id, planidbyerrorflag->planidbyerrorflagcontainer[planidbyerrorflagidx].
         errorflag = - (1)
        ENDIF
        startedplansidx += 1
        IF (startedplansidx > startedplanscount)
         startedplanscount += 10, stat = alterlist(startedplans->planlist,startedplanscount)
        ENDIF
        startedplans->planlist[startedplansidx].planid = rd.activity_entity_id,
        invokeisregimendoneind = 1
       ELSEIF (rd.regimen_detail_status_cd=detail_pending_cd)
        invokeisregimendoneind = 0
       ENDIF
      ENDIF
     ELSEIF (rd.reference_entity_name="LONG_TEXT_REFERENCE")
      notecnt += 1
      IF (mod(notecnt,10)=1)
       stat = alterlist(noteelements->notelist,(notecnt+ 9))
      ENDIF
      noteelements->notelist[notecnt].long_text_id = rd.activity_entity_id, noteelements->notelist[
      notecnt].regimen_detail_id = rd.regimen_detail_id, noteelements->notelist[notecnt].regimen_id
       = rd.regimen_id
     ENDIF
    FOOT  rd.regimen_id
     stat = alterlist(startedplans->planlist,startedplansidx), stat = alterlist(planidbyerrorflag->
      planidbyerrorflagcontainer,planidbyerrorflagidx)
     IF (invokeisregimendoneind=1
      AND is_regimen_valid(rd.regimen_id)="Y"
      AND filterdoneregimensind=1)
      regimencnt -= 1, regimenidx -= 1, stat = alterlist(reply->regimenlist,regimencnt,regimenidx)
     ELSE
      stat = alterlist(reply->regimenlist[regimenidx].elementlist,elementidx)
     ENDIF
     stat = alterlist(startedplans->planlist,0), startedplansidx = 0, startedplanscount = 0,
     invokeisregimendoneind = 0
    FOOT REPORT
     plancnt = planidx, stat = alterlist(planelements->planlist,plancnt), stat = alterlist(
      cycle_evidence_request->planlist,plancnt),
     stat = alterlist(noteelements->notelist,notecnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (is_regimen_valid(regimenid=f8) =c1)
   DECLARE hpatientstruct = i4 WITH noconstant(0), protect
   DECLARE hcontextstruct = i4 WITH noconstant(0), protect
   DECLARE hplanidslist = i4 WITH noconstant(0), protect
   DECLARE hloadindicatorsstruct = i4 WITH noconstant(0), protect
   DECLARE planinformationcount = i4 WITH noconstant(0), protect
   DECLARE hplaninformationlistitem = i4 WITH noconstant(0), protect
   DECLARE plancount = i4 WITH noconstant(0), protect
   DECLARE hplanitem = i4 WITH noconstant(0), protect
   DECLARE statuscount = i4 WITH noconstant(0), protect
   DECLARE hstatusitem = i4 WITH noconstant(0), protect
   DECLARE planstatuscd = f8 WITH noconstant(0), protect
   DECLARE planstatuscount = i4 WITH noconstant(0), protect
   DECLARE doneplanavailable = i4 WITH noconstant(0), protect
   DECLARE hrequest = i4 WITH noconstant(0), protect
   DECLARE hreply = i4 WITH noconstant(0), protect
   DECLARE hmsg601453 = i4 WITH noconstant(0), protect
   DECLARE srvrequestid = i4 WITH constant(601453), protect
   DECLARE srv_invalid_handle = i2 WITH noconstant(0), protect
   DECLARE planid = f8 WITH noconstant(0), protect
   DECLARE errorflag = i2 WITH noconstant(0), protect
   DECLARE regimendone = c1 WITH noconstant(""), protect
   DECLARE noaccesstoencountererror = i2 WITH constant(512), protect
   DECLARE planbyerrorflaglistsize = i4 WITH noconstant(0), protect
   DECLARE planbyerrorflagloc = i4 WITH protect, noconstant(0)
   SET hmsg601453 = uar_srvselectmessage(srvrequestid)
   IF (hmsg601453=srv_invalid_handle)
    SET hmsg601453 = 0
    RETURN("F")
   ENDIF
   SET hrequest = uar_srvcreaterequest(hmsg601453)
   IF (hrequest=srv_invalid_handle)
    SET hmsg601453 = 0
    SET hrequest = 0
    RETURN("F")
   ENDIF
   SET hreply = uar_srvcreatereply(hmsg601453)
   IF (hreply=srv_invalid_handle)
    SET hmsg601453 = 0
    SET hrequest = 0
    SET hreply = 0
    RETURN("F")
   ENDIF
   SET hpatientstruct = uar_srvgetstruct(hrequest,"patient")
   SET hcontextstruct = uar_srvgetstruct(hrequest,"context")
   IF (((hpatientstruct=null) OR (hcontextstruct=null)) )
    SET hmsg601453 = 0
    SET hrequest = 0
    SET hreply = 0
    RETURN("F")
   ENDIF
   SET stat = uar_srvsetdouble(hpatientstruct,"person_id",personid)
   SET stat = uar_srvsetdouble(hpatientstruct,"provider_patient_relation_cd",
    providerpatientrelationcd)
   SET stat = uar_srvsetdouble(hcontextstruct,"provider_id",providerid)
   FOR (startedplansidx = 1 TO size(startedplans->planlist,5))
    SET hplanidslist = uar_srvadditem(hrequest,"plan_ids")
    SET stat = uar_srvsetdouble(hplanidslist,"plan_id",startedplans->planlist[startedplansidx].planid
     )
   ENDFOR
   SET hloadindicatorsstruct = uar_srvgetstruct(hrequest,"load_indicators")
   SET stat = uar_srvsetshort(hloadindicatorsstruct,"plan_status_ind",1)
   SET stat = uar_srvexecute(hmsg601453,hrequest,hreply)
   IF (stat != 0)
    SET hmsg601453 = 0
    SET hrequest = 0
    SET hreply = 0
    RETURN("F")
   ENDIF
   IF (hreply > 0)
    SET planinformationcount = uar_srvgetitemcount(hreply,nullterm("plan_information"))
    FOR (x = 0 TO (planinformationcount - 1))
      SET hplaninformationlistitem = uar_srvgetitem(hreply,nullterm("plan_information"),x)
      SET plancount = uar_srvgetitemcount(hplaninformationlistitem,nullterm("plan"))
      SET planid = uar_srvgetdouble(hplaninformationlistitem,"plan_id")
      IF (enablechartaccessorgind=1)
       SET errorflag = uar_srvgetshort(hplaninformationlistitem,"error_flag")
       SET planbyerrorflaglistsize = size(planidbyerrorflag->planidbyerrorflagcontainer,5)
       SET planbyerrorflagloc = locateval(planbyerrorflagloc,1,planbyerrorflaglistsize,planid,
        planidbyerrorflag->planidbyerrorflagcontainer[planbyerrorflagloc].planid)
       IF (((mod(errorflag,1024) - mod(errorflag,noaccesstoencountererror))=noaccesstoencountererror)
       )
        SET planidbyerrorflag->planidbyerrorflagcontainer[planbyerrorflagloc].errorflag = 1
       ELSE
        SET planidbyerrorflag->planidbyerrorflagcontainer[planbyerrorflagloc].errorflag = 0
       ENDIF
      ENDIF
      IF (plancount > 0)
       SET hplanitem = uar_srvgetitem(hplaninformationlistitem,"plan",0)
       SET statuscount = uar_srvgetitemcount(hplanitem,"status")
       IF (statuscount > 0)
        SET hstatusitem = uar_srvgetitem(hplanitem,"status",0)
        SET planstatuscd = uar_srvgetdouble(hstatusitem,"status_cd")
        IF (planstatuscd IN (detail_plan_pending_cd, detail_plan_inprocess_cd))
         SET regimendone = "N"
        ELSEIF (planstatuscd=detail_plan_done_cd)
         SET doneplanavailable = 1
        ENDIF
        SET planstatuscount += 1
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (((regimendone="N") OR (((doneplanavailable=0) OR (size(startedplans->planlist,5) >
   planstatuscount)) )) )
    RETURN("N")
   ENDIF
   SET updateregimensidx += 1
   SET stat = alterlist(updateregimens->regimenlist,updateregimensidx)
   SET updateregimens->regimenlist[updateregimensidx].regimenid = rd.regimen_id
   SET updateregimens->regimenlist[updateregimensidx].updt_cnt = reply->regimenlist[regimenidx].
   updt_cnt
   SET reply->regimenlist[regimenidx].regimen_status_cd = regimen_status_done_cd
   RETURN("Y")
 END ;Subroutine
 SUBROUTINE load_element_relations(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(regimencnt)),
     (dummyt d2  WITH seq = 1),
     regimen_detail_r rdr
    PLAN (d1
     WHERE maxrec(d2,size(reply->regimenlist[d1.seq].elementlist,5)))
     JOIN (d2)
     JOIN (rdr
     WHERE (rdr.regimen_detail_t_id=reply->regimenlist[d1.seq].elementlist[d2.seq].regimen_detail_id)
     )
    ORDER BY rdr.regimen_id, rdr.regimen_detail_t_id
    HEAD rdr.regimen_id
     regimenidx = locateval(regimenidx,1,regimencnt,rdr.regimen_id,reply->regimenlist[regimenidx].
      regimen_id)
    HEAD rdr.regimen_detail_t_id
     relationidx = 0, elementidx = locateval(elementidx,1,size(reply->regimenlist[regimenidx].
       elementlist,5),rdr.regimen_detail_t_id,reply->regimenlist[regimenidx].elementlist[elementidx].
      regimen_detail_id)
    DETAIL
     relationidx += 1
     IF (relationidx > size(reply->regimenlist[regimenidx].elementlist[elementidx].relationlist,5))
      stat = alterlist(reply->regimenlist[regimenidx].elementlist[elementidx].relationlist,(
       relationidx+ 10))
     ENDIF
     reply->regimenlist[regimenidx].elementlist[elementidx].relationlist[relationidx].
     regimen_detail_r_id = rdr.regimen_detail_r_id, reply->regimenlist[regimenidx].elementlist[
     elementidx].relationlist[relationidx].regimen_detail_s_id = rdr.regimen_detail_s_id, reply->
     regimenlist[regimenidx].elementlist[elementidx].relationlist[relationidx].type_mean = rdr
     .type_mean,
     reply->regimenlist[regimenidx].elementlist[elementidx].relationlist[relationidx].offset_value =
     rdr.offset_value, reply->regimenlist[regimenidx].elementlist[elementidx].relationlist[
     relationidx].offset_unit_cd = rdr.offset_unit_cd
    FOOT  rdr.regimen_detail_t_id
     stat = alterlist(reply->regimenlist[regimenidx].elementlist[elementidx].relationlist,relationidx
      )
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE load_element_entitys(null)
   SET trace = recpersist
   EXECUTE dcp_get_plan_cycle_evidence  WITH replace("REQUEST","CYCLE_EVIDENCE_REQUEST"), replace(
    "REPLY","CYCLE_EVIDENCE_REPLY")
   SET planelementidx = 0
   IF ((((cycle_evidence_reply->status_data.status="S")) OR ((cycle_evidence_reply->status_data.
   status="s"))) )
    SET cercnt = size(cycle_evidence_reply->planlist,5)
    FOR (ceridx = 1 TO cercnt)
     SET planelementidx = locateval(planelementidx,1,plancnt,cycle_evidence_reply->planlist[ceridx].
      requested_pathway_catalog_id,planelements->planlist[planelementidx].pathway_catalog_id)
     WHILE (planelementidx > 0)
       SET regimenidx = locateval(regimenidx,1,regimencnt,planelements->planlist[planelementidx].
        regimen_id,reply->regimenlist[regimenidx].regimen_id)
       IF (regimenidx > 0)
        SET elementidx = locateval(elementidx,1,size(reply->regimenlist[regimenidx].elementlist,5),
         planelements->planlist[planelementidx].regimen_detail_id,reply->regimenlist[regimenidx].
         elementlist[elementidx].regimen_detail_id)
        IF (elementidx > 0)
         SET reply->regimenlist[regimenidx].elementlist[elementidx].description =
         cycle_evidence_reply->planlist[ceridx].display_description
         SET reply->regimenlist[regimenidx].elementlist[elementidx].version_pw_cat_id =
         cycle_evidence_reply->planlist[ceridx].version_pw_cat_id
         SET reply->regimenlist[regimenidx].elementlist[elementidx].newest_pw_cat_id =
         cycle_evidence_reply->planlist[ceridx].pathway_catalog_id
         SET reply->regimenlist[regimenidx].elementlist[elementidx].active_ind = cycle_evidence_reply
         ->planlist[ceridx].active_ind
         SET reply->regimenlist[regimenidx].elementlist[elementidx].plan_type_cd =
         cycle_evidence_reply->planlist[ceridx].plan_type_cd
         SET reply->regimenlist[regimenidx].elementlist[elementidx].evidence_locator =
         cycle_evidence_reply->planlist[ceridx].evidence_locator
         SET reply->regimenlist[regimenidx].elementlist[elementidx].ref_text_ind =
         cycle_evidence_reply->planlist[ceridx].ref_text_ind
         SET reply->regimenlist[regimenidx].elementlist[elementidx].cycle_ind = cycle_evidence_reply
         ->planlist[ceridx].cycle_ind
         SET reply->regimenlist[regimenidx].elementlist[elementidx].cycle_label_cd =
         cycle_evidence_reply->planlist[ceridx].cycle_label_cd
         SET reply->regimenlist[regimenidx].elementlist[elementidx].cycle_begin_nbr =
         cycle_evidence_reply->planlist[ceridx].cycle_begin_nbr
         SET reply->regimenlist[regimenidx].elementlist[elementidx].cycle_standard_nbr =
         cycle_evidence_reply->planlist[ceridx].cycle_standard_nbr
         SET reply->regimenlist[regimenidx].elementlist[elementidx].cycle_end_nbr =
         cycle_evidence_reply->planlist[ceridx].cycle_end_nbr
         SET reply->regimenlist[regimenidx].elementlist[elementidx].cycle_increment_nbr =
         cycle_evidence_reply->planlist[ceridx].cycle_increment_nbr
         SET reply->regimenlist[regimenidx].elementlist[elementidx].cycle_display_end_ind =
         cycle_evidence_reply->planlist[ceridx].cycle_display_end_ind
         IF ((request->facility_cd=0.0))
          SET reply->regimenlist[regimenidx].elementlist[elementidx].available_ind = 1
         ELSE
          IF (cycle_evidence_reply->planlist[ceridx].all_facilities_ind)
           SET reply->regimenlist[regimenidx].elementlist[elementidx].available_ind = 1
          ELSE
           FOR (facilityidx = 1 TO size(cycle_evidence_reply->planlist[ceridx].facilitylist,5))
             IF ((cycle_evidence_reply->planlist[ceridx].facilitylist[facilityidx].facility_cd=
             request->facility_cd))
              SET reply->regimenlist[regimenidx].elementlist[elementidx].available_ind = 1
             ENDIF
           ENDFOR
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       SET planelementidx = locateval(planelementidx,(planelementidx+ 1),plancnt,cycle_evidence_reply
        ->planlist[ceridx].requested_pathway_catalog_id,planelements->planlist[planelementidx].
        pathway_catalog_id)
     ENDWHILE
    ENDFOR
   ENDIF
   SET trace = norecpersist
 END ;Subroutine
 SUBROUTINE load_regimen_stop_info(null)
  SET regimen_list_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = regimencnt),
    regimen_action ra,
    long_text lt
   PLAN (d1
    WHERE initarray(regimen_list_start,evaluate(d1.seq,1,1,regimencnt)))
    JOIN (ra
    WHERE expand(regimenidx,regimen_list_start,regimencnt,ra.regimen_id,reply->regimenlist[regimenidx
     ].regimen_id)
     AND ((ra.action_type_cd=regimen_action_cancel_cd) OR (ra.action_type_cd=
    regimen_action_discontinue_cd)) )
    JOIN (lt
    WHERE (lt.parent_entity_id= Outerjoin(ra.regimen_action_id)) )
   HEAD ra.regimen_id
    regimenidx = locateval(regimenidx,1,regimencnt,ra.regimen_id,reply->regimenlist[regimenidx].
     regimen_id)
   DETAIL
    reply->regimenlist[regimenidx].regimen_stop_cd = ra.discontinue_reason_cd, reply->regimenlist[
    regimenidx].regimen_stop_text = lt.long_text
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE load_element_skip_info(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(regimencnt)),
     (dummyt d2  WITH seq = 1),
     regimen_detail_action rda,
     long_text lt,
     prsnl p,
     credential c
    PLAN (d1
     WHERE maxrec(d2,size(reply->regimenlist[d1.seq].elementlist,5)))
     JOIN (d2
     WHERE (reply->regimenlist[d1.seq].elementlist[d2.seq].regimen_detail_status_cd=detail_skipped_cd
     ))
     JOIN (rda
     WHERE (rda.regimen_detail_id=reply->regimenlist[d1.seq].elementlist[d2.seq].regimen_detail_id)
      AND rda.action_type_cd=detail_skip_cd)
     JOIN (lt
     WHERE (lt.long_text_id= Outerjoin(rda.long_text_id))
      AND (lt.long_text_id!= Outerjoin(0.0)) )
     JOIN (p
     WHERE p.person_id=rda.action_prsnl_id
      AND p.person_id != 0)
     JOIN (c
     WHERE (c.prsnl_id= Outerjoin(p.person_id))
      AND (c.active_ind= Outerjoin(1)) )
    ORDER BY rda.regimen_detail_id, rda.action_prsnl_id, p.person_id,
     c.credential_id
    HEAD rda.regimen_detail_id
     reply->regimenlist[d1.seq].elementlist[d2.seq].skip_reason_cd = rda.action_reason_cd, reply->
     regimenlist[d1.seq].elementlist[d2.seq].skip_reason = lt.long_text, reply->regimenlist[d1.seq].
     elementlist[d2.seq].skip_prsnl_id = rda.action_prsnl_id,
     reply->regimenlist[d1.seq].elementlist[d2.seq].skip_dt_tm = rda.action_dt_tm, reply->
     regimenlist[d1.seq].elementlist[d2.seq].skip_tz = rda.action_tz
    HEAD p.person_id
     reply->regimenlist[d1.seq].elementlist[d2.seq].skip_prsnl_name_first = p.name_first, reply->
     regimenlist[d1.seq].elementlist[d2.seq].skip_prsnl_name_last = p.name_last, credentialcnt = 0,
     credentialsize = 0
    HEAD c.credential_id
     IF (rda.action_dt_tm BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm)
      credentialcnt += 1
      IF (credentialcnt > credentialsize)
       credentialsize += 5, stat = alterlist(reply->regimenlist[d1.seq].elementlist[d2.seq].
        skipcredentiallist,credentialsize)
      ENDIF
      reply->regimenlist[d1.seq].elementlist[d2.seq].skipcredentiallist[credentialcnt].display =
      uar_get_code_display(c.credential_cd)
     ENDIF
    FOOT  p.person_id
     stat = alterlist(reply->regimenlist[d1.seq].elementlist[d2.seq].skipcredentiallist,credentialcnt
      ), credentialsize = credentialcnt
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE load_regimen_catalog_info(null)
  SET regimen_list_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = regimencnt),
    regimen_catalog rc
   PLAN (d1
    WHERE initarray(regimen_list_start,evaluate(d1.seq,1,1,regimencnt)))
    JOIN (rc
    WHERE expand(regimenidx,regimen_list_start,regimencnt,rc.regimen_catalog_id,reply->regimenlist[
     regimenidx].regimen_catalog_id))
   HEAD rc.regimen_catalog_id
    FOR (regimenidx = 1 TO regimencnt)
      IF ((reply->regimenlist[regimenidx].regimen_catalog_id=rc.regimen_catalog_id))
       reply->regimenlist[regimenidx].extend_treatment_ind = rc.extend_treatment_ind, reply->
       regimenlist[regimenidx].add_plan_ind = rc.add_plan_ind
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE load_note_elements(null)
   IF (notecnt > 0)
    SET idx = 0
    CALL echo(build("noteCnt: ",notecnt))
    SELECT INTO "nl:"
     FROM long_text lt
     PLAN (lt
      WHERE expand(idx,1,notecnt,lt.long_text_id,noteelements->notelist[idx].long_text_id))
     HEAD REPORT
      noteidx = 0
     DETAIL
      noteidx = locateval(noteidx,1,size(noteelements->notelist,5),lt.long_text_id,noteelements->
       notelist[noteidx].long_text_id)
      IF (noteidx > 0)
       regimenidx = locateval(regimenidx,1,size(reply->regimenlist,5),noteelements->notelist[noteidx]
        .regimen_id,reply->regimenlist[regimenidx].regimen_id)
       IF (regimenidx > 0)
        elementidx = locateval(elementidx,1,size(reply->regimenlist[regimenidx].elementlist,5),
         noteelements->notelist[noteidx].regimen_detail_id,reply->regimenlist[regimenidx].
         elementlist[elementidx].regimen_detail_id)
        IF (elementidx > 0)
         reply->regimenlist[regimenidx].elementlist[elementidx].note_text = lt.long_text
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET elementidx = 0
    SET regimenidx = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE update_regimens(null)
  DECLARE regimenidx = i4 WITH noconstant(0), protect
  IF (size(updateregimens->regimenlist,5) > 0)
   SELECT INTO "n1:"
    r.*
    FROM regimen r
    WHERE expand(regimenidx,1,size(updateregimens->regimenlist,5),r.regimen_id,updateregimens->
     regimenlist[regimenidx].regimenid,
     r.updt_cnt,updateregimens->regimenlist[regimenidx].updt_cnt)
    WITH forupdate(r), nocounter, expand = 1
   ;end select
   IF (curqual=0)
    RETURN
   ENDIF
   SET regimenidx = 0
   UPDATE  FROM regimen r
    SET r.regimen_status_cd = regimen_status_done_cd, r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id
      = reqinfo->updt_id,
     r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r
     .updt_cnt+ 1)
    WHERE expand(regimenidx,1,size(updateregimens->regimenlist,5),r.regimen_id,updateregimens->
     regimenlist[regimenidx].regimenid,
     r.updt_cnt,updateregimens->regimenlist[regimenidx].updt_cnt)
    WITH nocounter, expand = 1
   ;end update
   IF (curqual=0)
    RETURN
   ENDIF
   SET reqinfo->commit_ind = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE load_diagnosis_relations(null)
   DECLARE diagnosiscnt = i4 WITH noconstant(0), protect
   DECLARE regimenidx1 = i4 WITH noconstant(0), protect
   DECLARE regimenidx = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM nomen_entity_reltn ner,
     diagnosis dg,
     nomenclature no
    PLAN (ner
     WHERE ner.parent_entity_name="REGIMEN"
      AND ner.reltn_type_cd=regimen_diagnosis_reltn_cd
      AND expand(regimenidx,1,size(reply->regimenlist,5),ner.parent_entity_id,reply->regimenlist[
      regimenidx].regimen_id)
      AND ner.active_ind=1)
     JOIN (dg
     WHERE ner.child_entity_id=dg.diagnosis_id
      AND ner.child_entity_name="DIAGNOSIS")
     JOIN (no
     WHERE no.nomenclature_id=ner.nomenclature_id)
    ORDER BY ner.parent_entity_id, ner.priority
    HEAD ner.parent_entity_id
     diagnosiscnt = 0, regimenidx1 = locateval(regimenidx,1,value(regimencnt),ner.parent_entity_id,
      reply->regimenlist[regimenidx].regimen_id)
    DETAIL
     diagnosiscnt += 1
     IF (diagnosiscnt > size(reply->regimenlist[regimenidx1].diagnosis,5))
      stat = alterlist(reply->regimenlist[regimenidx1].diagnosis,(diagnosiscnt+ 10))
     ENDIF
     reply->regimenlist[regimenidx1].diagnosis[diagnosiscnt].display = no.source_string, reply->
     regimenlist[regimenidx1].diagnosis[diagnosiscnt].concept_cki = no.concept_cki, reply->
     regimenlist[regimenidx1].diagnosis[diagnosiscnt].diagnosis_id = ner.child_entity_id,
     reply->regimenlist[regimenidx1].diagnosis[diagnosiscnt].encounter_id = ner.encntr_id, reply->
     regimenlist[regimenidx1].diagnosis[diagnosiscnt].nomenclature_id = ner.nomenclature_id, reply->
     regimenlist[regimenidx1].diagnosis[diagnosiscnt].diagnosis_group_id = dg.diagnosis_group,
     reply->regimenlist[regimenidx1].diagnosis[diagnosiscnt].diagnosis_type_disp =
     uar_get_code_display(dg.diag_type_cd), reply->regimenlist[regimenidx1].diagnosis[diagnosiscnt].
     source_vocabulary_cd = no.source_vocabulary_cd
    FOOT  ner.parent_entity_id
     stat = alterlist(reply->regimenlist[regimenidx1].diagnosis,diagnosiscnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE load_diagnosis_capture_indicator(null)
  DECLARE elementidx1 = i4 WITH noconstant(0), protect
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(regimencnt)),
    (dummyt d2  WITH seq = 1),
    pathway_catalog pc,
    regimen r
   PLAN (d1
    WHERE maxrec(d2,size(reply->regimenlist[d1.seq].elementlist,5)))
    JOIN (r
    WHERE (r.regimen_id= Outerjoin(reply->regimenlist[d1.seq].regimen_id))
     AND  NOT (r.regimen_status_cd IN (regimen_status_done_cd, regimen_status_discontinue_cd,
    regimen_status_cancelled_cd)))
    JOIN (d2)
    JOIN (pc
    WHERE (pc.pathway_catalog_id=reply->regimenlist[d1.seq].elementlist[d2.seq].reference_entity_id))
   ORDER BY pc.pathway_catalog_id
   HEAD r.regimen_id
    elementidx = 0, regimenidx = locateval(regimenidx,1,regimencnt,r.regimen_id,reply->regimenlist[
     regimenidx].regimen_id)
   HEAD pc.pathway_catalog_id
    elementidx1 = 0
   DETAIL
    elementidx = locateval(elementidx1,(elementidx+ 1),size(reply->regimenlist[regimenidx].
      elementlist,5),pc.pathway_catalog_id,reply->regimenlist[regimenidx].elementlist[elementidx1].
     reference_entity_id)
    IF (elementidx > 0)
     reply->regimenlist[regimenidx].elementlist[elementidx].diagnosis_capture_ind = pc
     .diagnosis_capture_ind
    ENDIF
  ;end select
 END ;Subroutine
 SUBROUTINE update_invalid_encounter_error_flag(null)
   IF (enablechartaccessorgind=1)
    DECLARE planidbyerrorflagindex = i4 WITH noconstant(0), protect
    DECLARE planidbyerrorflagsize = i4 WITH noconstant(0), protect
    DECLARE planbyerrorflagloc = i4 WITH protect, noconstant(0)
    DECLARE startedplanssize = i4 WITH protect, noconstant(0)
    DECLARE hpatientstruct = i4 WITH noconstant(0), protect
    DECLARE hcontextstruct = i4 WITH noconstant(0), protect
    DECLARE hplanidslist = i4 WITH noconstant(0), protect
    DECLARE hloadindicatorsstruct = i4 WITH noconstant(0), protect
    DECLARE planinformationcount = i4 WITH noconstant(0), protect
    DECLARE hplaninformationlistitem = i4 WITH noconstant(0), protect
    DECLARE planbyerrorflaglistsize = i4 WITH noconstant(0), protect
    DECLARE noaccesstoencountererror = i2 WITH constant(512), protect
    DECLARE plancount = i4 WITH noconstant(0), protect
    DECLARE planid = f8 WITH noconstant(0), protect
    DECLARE errorflag = i2 WITH noconstant(0), protect
    SET planidbyerrorflagsize = size(planidbyerrorflag->planidbyerrorflagcontainer,5)
    SET startedplansidx = 0
    SET stat = alterlist(startedplans->planlist,0)
    SET stat = alterlist(startedplans->planlist,planidbyerrorflagsize)
    FOR (planidbyerrorflagindex = 1 TO planidbyerrorflagsize)
      IF ((planidbyerrorflag->planidbyerrorflagcontainer[planidbyerrorflagindex].errorflag=- (1)))
       SET startedplansidx += 1
       SET startedplans->planlist[startedplansidx].planid = planidbyerrorflag->
       planidbyerrorflagcontainer[planidbyerrorflagindex].planid
      ENDIF
    ENDFOR
    CALL alterlist(startedplans->planlist,startedplansidx)
    SET startedplanssize = size(startedplans->planlist,5)
    IF (startedplanssize > 0)
     DECLARE hrequest = i4 WITH noconstant(0), protect
     DECLARE hreply = i4 WITH noconstant(0), protect
     DECLARE hmsg601453 = i4 WITH noconstant(0), protect
     DECLARE srvrequestid = i4 WITH constant(601453), protect
     DECLARE srv_invalid_handle = i2 WITH noconstant(0), protect
     SET hmsg601453 = uar_srvselectmessage(srvrequestid)
     IF (hmsg601453=srv_invalid_handle)
      SET hmsg601453 = 0
      RETURN("F")
     ENDIF
     SET hrequest = uar_srvcreaterequest(hmsg601453)
     IF (hrequest=srv_invalid_handle)
      SET hmsg601453 = 0
      SET hrequest = 0
      RETURN("F")
     ENDIF
     SET hreply = uar_srvcreatereply(hmsg601453)
     IF (hreply=srv_invalid_handle)
      SET hmsg601453 = 0
      SET hrequest = 0
      SET hreply = 0
      RETURN("F")
     ENDIF
     SET hpatientstruct = uar_srvgetstruct(hrequest,"patient")
     SET hcontextstruct = uar_srvgetstruct(hrequest,"context")
     IF (((hpatientstruct=null) OR (hcontextstruct=null)) )
      SET hmsg601453 = 0
      SET hrequest = 0
      SET hreply = 0
      RETURN("F")
     ENDIF
     SET stat = uar_srvsetdouble(hpatientstruct,"person_id",personid)
     SET stat = uar_srvsetdouble(hpatientstruct,"provider_patient_relation_cd",
      providerpatientrelationcd)
     SET stat = uar_srvsetdouble(hcontextstruct,"provider_id",providerid)
     FOR (startedplansidx = 1 TO size(startedplans->planlist,5))
      SET hplanidslist = uar_srvadditem(hrequest,"plan_ids")
      SET stat = uar_srvsetdouble(hplanidslist,"plan_id",startedplans->planlist[startedplansidx].
       planid)
     ENDFOR
     SET hloadindicatorsstruct = uar_srvgetstruct(hrequest,"load_indicators")
     SET stat = uar_srvsetshort(hloadindicatorsstruct,"plan_status_ind",1)
     SET stat = uar_srvexecute(hmsg601453,hrequest,hreply)
     IF (stat != 0)
      SET hmsg601453 = 0
      SET hrequest = 0
      SET hreply = 0
      RETURN("F")
     ENDIF
     IF (hreply > 0)
      SET planinformationcount = uar_srvgetitemcount(hreply,nullterm("plan_information"))
      FOR (x = 0 TO (planinformationcount - 1))
        SET hplaninformationlistitem = uar_srvgetitem(hreply,nullterm("plan_information"),x)
        SET plancount = uar_srvgetitemcount(hplaninformationlistitem,nullterm("plan"))
        SET planid = uar_srvgetdouble(hplaninformationlistitem,"plan_id")
        SET errorflag = uar_srvgetshort(hplaninformationlistitem,"error_flag")
        SET planbyerrorflaglistsize = size(planidbyerrorflag->planidbyerrorflagcontainer,5)
        SET planbyerrorflagloc = locateval(planbyerrorflagloc,1,planbyerrorflaglistsize,planid,
         planidbyerrorflag->planidbyerrorflagcontainer[planbyerrorflagloc].planid)
        IF (((mod(errorflag,1024) - mod(errorflag,noaccesstoencountererror))=noaccesstoencountererror
        ))
         SET planidbyerrorflag->planidbyerrorflagcontainer[planbyerrorflagloc].errorflag = 1
        ELSE
         SET planidbyerrorflag->planidbyerrorflagcontainer[planbyerrorflagloc].errorflag = 0
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE update_redacted_plan(null)
   IF (enablechartaccessorgind=1)
    DECLARE replyregimenlistsize = i4 WITH noconstant(0), protect
    DECLARE idxregimen = i4 WITH protect, noconstant(1)
    DECLARE idxplan = i4 WITH protect, noconstant(1)
    DECLARE replyplanlistsize = i4 WITH noconstant(0), protect
    DECLARE planbyerrorflagloc = i4 WITH protect, noconstant(0)
    DECLARE planbyerrorflaglistsize = i4 WITH noconstant(0), protect
    SET replyregimenlistsize = size(reply->regimenlist,5)
    SET planbyerrorflaglistsize = size(planidbyerrorflag->planidbyerrorflagcontainer,5)
    FOR (idxregimen = 1 TO replyregimenlistsize)
     SET replyplanlistsize = size(reply->regimenlist[idxregimen].elementlist,5)
     FOR (idxplan = 1 TO replyplanlistsize)
      SET planbyerrorflagloc = locateval(planbyerrorflagloc,1,planbyerrorflaglistsize,reply->
       regimenlist[idxregimen].elementlist[idxplan].activity_entity_id,planidbyerrorflag->
       planidbyerrorflagcontainer[planbyerrorflagloc].planid)
      IF (planbyerrorflagloc > 0
       AND (planidbyerrorflag->planidbyerrorflagcontainer[planbyerrorflagloc].errorflag=1))
       SET reply->regimenlist[idxregimen].elementlist[idxplan].activity_entity_name = "REDACTED"
      ENDIF
     ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 FREE RECORD noteelements
#exit_script
 SET slastmoddate = "01/19/2022"
 SET slastmod = "007 Arun Godekar"
END GO
