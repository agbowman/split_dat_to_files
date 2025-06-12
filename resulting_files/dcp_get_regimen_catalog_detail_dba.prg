CREATE PROGRAM dcp_get_regimen_catalog_detail:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 regimenlist[*]
     2 catalog_id = f8
     2 description = vc
     2 name = vc
     2 active_ind = i2
     2 extend_treatment_ind = i2
     2 updt_cnt = i4
     2 elementlist[*]
       3 regimen_cat_detail_id = f8
       3 description = vc
       3 entity_id = f8
       3 entity_name = vc
       3 regimen_detail_sequence = i4
       3 updt_cnt = i4
       3 cycle_nbr = i4
       3 cycle_ind = i2
       3 cycle_label_cd = f8
       3 cycle_begin_nbr = i4
       3 cycle_standard_nbr = i4
       3 cycle_end_nbr = i4
       3 cycle_increment_nbr = i4
       3 cycle_display_end_ind = i2
       3 pathway_catalog_id = f8
       3 evidence_locator = vc
       3 ref_text_ind = i2
       3 plan_type_cd = f8
       3 available_ind = i2
       3 active_ind = i2
       3 relationlist[*]
         4 regimen_cat_detail_r_id = f8
         4 source_element_cat_id = f8
         4 type_mean = c12
         4 offset_quantity = f8
         4 offset_unit_cd = f8
       3 note_text = vc
       3 diagnosis_capture_ind = i2
     2 attributelist[*]
       3 regimen_cat_attribute_r_id = f8
       3 regimen_cat_attribute_id = f8
       3 display_flag = i2
       3 default_value_id = f8
       3 default_value_name = c30
       3 sequence = i4
       3 updt_cnt = i4
       3 display = vc
       3 mean = vc
       3 input_type_flag = i2
       3 code_set = f8
     2 synonymlist[*]
       3 regimen_cat_synonym_id = f8
       3 display = c100
       3 primary_ind = i2
     2 facilitylist[*]
       3 facility_cd = f8
     2 add_plan_ind = i2
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
     2 version_pw_cat_id = f8
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
 DECLARE regimen_cnt = i4 WITH constant(value(size(request->regimenlist,5))), protect
 DECLARE regimenidx = i4 WITH noconstant(0), protect
 DECLARE elementidx = i4 WITH noconstant(0), protect
 DECLARE regimen_list_start = i4 WITH noconstant(1), protect
 DECLARE high = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE status = i2 WITH noconstant(0)
 DECLARE facilityidx = i4 WITH noconstant(0), protect
 DECLARE previousid = f8 WITH noconstant(0.0), protect
 DECLARE ceridx = i4 WITH noconstant(0), protect
 DECLARE cercnt = i4 WITH noconstant(0), protect
 DECLARE planidx = i4 WITH noconstant(0), protect
 DECLARE plancnt = i4 WITH noconstant(0), protect
 DECLARE notecnt = i4 WITH noconstant(0), protect
 DECLARE noteidx = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET status = 0
 CALL echorecord(request)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = regimen_cnt),
   regimen_catalog rc,
   regimen_cat_detail rcd,
   regimen_cat_detail_r rcdr
  PLAN (d1
   WHERE initarray(regimen_list_start,evaluate(d1.seq,1,1,regimen_cnt)))
   JOIN (rc
   WHERE rc.regimen_catalog_id=outerjoin(request->regimenlist[d1.seq].catalog_id))
   JOIN (rcd
   WHERE rcd.active_ind=outerjoin(1)
    AND rcd.regimen_catalog_id=outerjoin(rc.regimen_catalog_id))
   JOIN (rcdr
   WHERE rcdr.regimen_cat_detail_t_id=outerjoin(rcd.regimen_cat_detail_id))
  ORDER BY rc.regimen_catalog_id, rcd.regimen_detail_sequence
  HEAD REPORT
   regimenidx = 0, stat = alterlist(reply->regimenlist,regimen_cnt)
  HEAD rc.regimen_catalog_id
   regimenidx = (regimenidx+ 1), reply->regimenlist[regimenidx].catalog_id = rc.regimen_catalog_id,
   reply->regimenlist[regimenidx].description = rc.regimen_description,
   reply->regimenlist[regimenidx].name = rc.regimen_name, reply->regimenlist[regimenidx].active_ind
    = rc.active_ind, reply->regimenlist[regimenidx].extend_treatment_ind = rc.extend_treatment_ind,
   reply->regimenlist[regimenidx].add_plan_ind = rc.add_plan_ind, reply->regimenlist[regimenidx].
   updt_cnt = rc.updt_cnt, elementidx = 0
  HEAD rcd.regimen_cat_detail_id
   elementidx = (elementidx+ 1)
   IF (elementidx > size(reply->regimenlist[regimenidx].elementlist,5))
    stat = alterlist(reply->regimenlist[regimenidx].elementlist,(elementidx+ 10))
   ENDIF
   reply->regimenlist[regimenidx].elementlist[elementidx].regimen_cat_detail_id = rcd
   .regimen_cat_detail_id, reply->regimenlist[regimenidx].elementlist[elementidx].entity_id = rcd
   .entity_id, reply->regimenlist[regimenidx].elementlist[elementidx].entity_name = rcd.entity_name,
   reply->regimenlist[regimenidx].elementlist[elementidx].regimen_detail_sequence = rcd
   .regimen_detail_sequence, reply->regimenlist[regimenidx].elementlist[elementidx].updt_cnt = rcd
   .updt_cnt, reply->regimenlist[regimenidx].elementlist[elementidx].cycle_nbr = rcd.cycle_nbr
   IF (rcd.entity_name="PATHWAY_CATALOG")
    planidx = (planidx+ 1)
    IF (planidx > plancnt)
     plancnt = (plancnt+ 10), stat = alterlist(planelements->planlist,plancnt), stat = alterlist(
      cycle_evidence_request->planlist,plancnt)
    ENDIF
    planelements->planlist[planidx].version_pw_cat_id = rcd.entity_id, planelements->planlist[planidx
    ].regimen_detail_id = rcd.regimen_cat_detail_id, planelements->planlist[planidx].regimen_id = rcd
    .regimen_catalog_id,
    cycle_evidence_request->planlist[planidx].pathway_catalog_id = rcd.entity_id
   ELSEIF (rcd.entity_name="LONG_TEXT_REFERENCE")
    notecnt = (notecnt+ 1)
    IF (mod(notecnt,10)=1)
     stat = alterlist(noteelements->notelist,(notecnt+ 9))
    ENDIF
    noteelements->notelist[notecnt].long_text_id = rcd.entity_id, noteelements->notelist[notecnt].
    regimen_detail_id = rcd.regimen_cat_detail_id, noteelements->notelist[notecnt].regimen_id = rcd
    .regimen_catalog_id
   ENDIF
   reltnidx = 0
  DETAIL
   IF (rcdr.regimen_cat_detail_r_id > 0.0)
    reltnidx = (reltnidx+ 1)
    IF (reltnidx > size(reply->regimenlist[regimenidx].elementlist[elementidx].relationlist,5))
     stat = alterlist(reply->regimenlist[regimenidx].elementlist[elementidx].relationlist,(reltnidx+
      4))
    ENDIF
    reply->regimenlist[regimenidx].elementlist[elementidx].relationlist[reltnidx].
    regimen_cat_detail_r_id = rcdr.regimen_cat_detail_r_id, reply->regimenlist[regimenidx].
    elementlist[elementidx].relationlist[reltnidx].source_element_cat_id = rcdr
    .regimen_cat_detail_s_id, reply->regimenlist[regimenidx].elementlist[elementidx].relationlist[
    reltnidx].type_mean = rcdr.type_mean,
    reply->regimenlist[regimenidx].elementlist[elementidx].relationlist[reltnidx].offset_quantity =
    rcdr.offset_value, reply->regimenlist[regimenidx].elementlist[elementidx].relationlist[reltnidx].
    offset_unit_cd = rcdr.offset_unit_cd
   ENDIF
  FOOT  rcd.regimen_cat_detail_id
   stat = alterlist(reply->regimenlist[regimenidx].elementlist[elementidx].relationlist,reltnidx)
  FOOT  rc.regimen_catalog_id
   stat = alterlist(reply->regimenlist[regimenidx].elementlist,elementidx)
  FOOT REPORT
   stat = alterlist(reply->regimenlist,regimenidx), plancnt = planidx, stat = alterlist(planelements
    ->planlist,plancnt),
   stat = alterlist(cycle_evidence_request->planlist,plancnt), stat = alterlist(noteelements->
    notelist,notecnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET status = 1
 ENDIF
 SET high = value(size(request->regimenlist,5))
 SELECT INTO "nl:"
  FROM regimen_cat_attribute_r rcar,
   regimen_cat_attribute rca
  PLAN (rcar
   WHERE rcar.active_ind=1
    AND expand(idx,1,high,rcar.regimen_catalog_id,request->regimenlist[idx].catalog_id))
   JOIN (rca
   WHERE rca.regimen_cat_attribute_id=outerjoin(rcar.regimen_cat_attribute_id))
  ORDER BY rcar.regimen_catalog_id, rcar.sequence
  HEAD REPORT
   idx = 0
  HEAD rcar.regimen_catalog_id
   attributecount = 0, idx = locateval(idx,1,high,rcar.regimen_catalog_id,reply->regimenlist[idx].
    catalog_id)
  DETAIL
   attributecount = (attributecount+ 1)
   IF (attributecount > size(reply->regimenlist[idx].attributelist,5))
    stat = alterlist(reply->regimenlist[idx].attributelist,(attributecount+ 5))
   ENDIF
   reply->regimenlist[idx].attributelist[attributecount].regimen_cat_attribute_r_id = rcar
   .regimen_cat_attribute_r_id, reply->regimenlist[idx].attributelist[attributecount].
   regimen_cat_attribute_id = rcar.regimen_cat_attribute_id, reply->regimenlist[idx].attributelist[
   attributecount].display_flag = rcar.display_flag,
   reply->regimenlist[idx].attributelist[attributecount].default_value_id = rcar.default_value_id,
   reply->regimenlist[idx].attributelist[attributecount].default_value_name = rcar.default_value_name,
   reply->regimenlist[idx].attributelist[attributecount].sequence = rcar.sequence,
   reply->regimenlist[idx].attributelist[attributecount].updt_cnt = rcar.updt_cnt, reply->
   regimenlist[idx].attributelist[attributecount].display = rca.attribute_display, reply->
   regimenlist[idx].attributelist[attributecount].mean = rca.attribute_mean,
   reply->regimenlist[idx].attributelist[attributecount].input_type_flag = rca.input_type_flag, reply
   ->regimenlist[idx].attributelist[attributecount].code_set = rca.code_set
  FOOT  rcar.regimen_catalog_id
   stat = alterlist(reply->regimenlist[idx].attributelist,attributecount)
  WITH nocounter
 ;end select
 SET high = value(size(request->regimenlist,5))
 SELECT INTO "nl:"
  FROM regimen_cat_synonym rcs
  WHERE expand(idx,1,high,rcs.regimen_catalog_id,request->regimenlist[idx].catalog_id)
  ORDER BY rcs.regimen_catalog_id, rcs.updt_dt_tm
  HEAD REPORT
   idx = 0
  HEAD rcs.regimen_catalog_id
   synonymcount = 0, idx = locateval(idx,1,high,rcs.regimen_catalog_id,reply->regimenlist[idx].
    catalog_id)
  DETAIL
   synonymcount = (synonymcount+ 1)
   IF (synonymcount > size(reply->regimenlist[idx].synonymlist,5))
    stat = alterlist(reply->regimenlist[idx].synonymlist,(synonymcount+ 5))
   ENDIF
   reply->regimenlist[idx].synonymlist[synonymcount].regimen_cat_synonym_id = rcs
   .regimen_cat_synonym_id, reply->regimenlist[idx].synonymlist[synonymcount].display = trim(rcs
    .synonym_display), reply->regimenlist[idx].synonymlist[synonymcount].primary_ind = rcs
   .primary_ind
  FOOT  rcs.regimen_catalog_id
   stat = alterlist(reply->regimenlist[idx].synonymlist,synonymcount)
  WITH nocounter
 ;end select
 SET high = value(size(request->regimenlist,5))
 SELECT INTO "nl:"
  FROM regimen_cat_facility_r rcfr
  WHERE expand(idx,1,high,rcfr.regimen_catalog_id,request->regimenlist[idx].catalog_id)
  ORDER BY rcfr.regimen_catalog_id
  HEAD REPORT
   regimenidx = 0
  HEAD rcfr.regimen_catalog_id
   facilityidx = 0, regimenidx = locateval(idx,1,high,rcfr.regimen_catalog_id,reply->regimenlist[
    regimenidx].catalog_id)
  DETAIL
   facilityidx = (facilityidx+ 1)
   IF (facilityidx > size(reply->regimenlist[regimenidx].facilitylist,5))
    stat = alterlist(reply->regimenlist[regimenidx].facilitylist,(facilityidx+ 5))
   ENDIF
   reply->regimenlist[regimenidx].facilitylist[facilityidx].facility_cd = rcfr.location_cd
  FOOT  rcfr.regimen_catalog_id
   stat = alterlist(reply->regimenlist[regimenidx].facilitylist,facilityidx)
  WITH nocounter
 ;end select
 CALL echorecord(cycle_evidence_request)
 SET trace = recpersist
 EXECUTE dcp_get_plan_cycle_evidence  WITH replace("REQUEST","CYCLE_EVIDENCE_REQUEST"), replace(
  "REPLY","CYCLE_EVIDENCE_REPLY")
 CALL echorecord(cycle_evidence_reply)
 IF ((((cycle_evidence_reply->status_data.status="S")) OR ((cycle_evidence_reply->status_data.status=
 "s"))) )
  SET cercnt = size(cycle_evidence_reply->planlist,5)
  FOR (ceridx = 1 TO cercnt)
   SET planidx = locateval(planidx,1,plancnt,cycle_evidence_reply->planlist[ceridx].
    requested_pathway_catalog_id,planelements->planlist[planidx].version_pw_cat_id)
   WHILE (planidx > 0)
     SET regimenidx = locateval(regimenidx,1,size(reply->regimenlist,5),planelements->planlist[
      planidx].regimen_id,reply->regimenlist[regimenidx].catalog_id)
     IF (regimenidx > 0)
      SET elementidx = locateval(elementidx,1,size(reply->regimenlist[regimenidx].elementlist,5),
       planelements->planlist[planidx].regimen_detail_id,reply->regimenlist[regimenidx].elementlist[
       elementidx].regimen_cat_detail_id)
      IF (elementidx > 0)
       SET reply->regimenlist[regimenidx].elementlist[elementidx].pathway_catalog_id =
       cycle_evidence_reply->planlist[ceridx].pathway_catalog_id
       SET reply->regimenlist[regimenidx].elementlist[elementidx].description = cycle_evidence_reply
       ->planlist[ceridx].display_description
       SET reply->regimenlist[regimenidx].elementlist[elementidx].plan_type_cd = cycle_evidence_reply
       ->planlist[ceridx].plan_type_cd
       SET reply->regimenlist[regimenidx].elementlist[elementidx].active_ind = cycle_evidence_reply->
       planlist[ceridx].active_ind
       SET reply->regimenlist[regimenidx].elementlist[elementidx].evidence_locator =
       cycle_evidence_reply->planlist[ceridx].evidence_locator
       SET reply->regimenlist[regimenidx].elementlist[elementidx].ref_text_ind = cycle_evidence_reply
       ->planlist[ceridx].ref_text_ind
       SET reply->regimenlist[regimenidx].elementlist[elementidx].cycle_ind = cycle_evidence_reply->
       planlist[ceridx].cycle_ind
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
           IF ((cycle_evidence_reply->planlist[ceridx].facilitylist[facilityidx].facility_cd=request
           ->facility_cd))
            SET reply->regimenlist[regimenidx].elementlist[elementidx].available_ind = 1
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET planidx = locateval(planidx,(planidx+ 1),plancnt,cycle_evidence_reply->planlist[ceridx].
      requested_pathway_catalog_id,planelements->planlist[planidx].version_pw_cat_id)
   ENDWHILE
  ENDFOR
 ENDIF
 IF (notecnt > 0)
  SET idx = 0
  CALL echo(build("noteCnt: ",notecnt))
  SELECT INTO "nl:"
   FROM long_text_reference ltr
   PLAN (ltr
    WHERE expand(idx,1,notecnt,ltr.long_text_id,noteelements->notelist[idx].long_text_id))
   HEAD REPORT
    noteidx = 0
   DETAIL
    noteidx = locateval(noteidx,1,size(noteelements->notelist,5),ltr.long_text_id,noteelements->
     notelist[noteidx].long_text_id)
    IF (noteidx > 0)
     regimenidx = locateval(regimenidx,1,size(reply->regimenlist,5),noteelements->notelist[noteidx].
      regimen_id,reply->regimenlist[regimenidx].catalog_id)
     IF (regimenidx > 0)
      elementidx = locateval(elementidx,1,size(reply->regimenlist[regimenidx].elementlist,5),
       noteelements->notelist[noteidx].regimen_detail_id,reply->regimenlist[regimenidx].elementlist[
       elementidx].regimen_cat_detail_id)
      IF (elementidx > 0)
       reply->regimenlist[regimenidx].elementlist[elementidx].note_text = ltr.long_text
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  CALL echorecord(noteelements)
  FREE RECORD noteelements
 ENDIF
 IF (size(reply->regimenlist[regimenidx].elementlist,5) > 0)
  DECLARE elementidx1 = i4 WITH noconstant(0), protect
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = regimen_cnt),
    (dummyt d2  WITH seq = 1),
    pathway_catalog pc,
    regimen_catalog rc
   PLAN (d1
    WHERE maxrec(d2,size(reply->regimenlist[d1.seq].elementlist,5)))
    JOIN (rc
    WHERE rc.regimen_catalog_id=outerjoin(request->regimenlist[d1.seq].catalog_id))
    JOIN (d2)
    JOIN (pc
    WHERE (pc.pathway_catalog_id=reply->regimenlist[d1.seq].elementlist[d2.seq].pathway_catalog_id))
   ORDER BY pc.pathway_catalog_id
   HEAD rc.regimen_catalog_id
    elementidx = 0, regimenidx = locateval(regimenidx,1,regimen_cnt,rc.regimen_catalog_id,reply->
     regimenlist[regimenidx].catalog_id)
   HEAD pc.pathway_catalog_id
    elementidx1 = 0
   DETAIL
    elementidx = locateval(elementidx1,(elementidx+ 1),size(reply->regimenlist[regimenidx].
      elementlist,5),pc.pathway_catalog_id,reply->regimenlist[regimenidx].elementlist[elementidx1].
     pathway_catalog_id)
    IF (elementidx > 0)
     reply->regimenlist[regimenidx].elementlist[elementidx].diagnosis_capture_ind = pc
     .diagnosis_capture_ind
    ENDIF
  ;end select
 ENDIF
 SET trace = norecpersist
 IF (status=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
