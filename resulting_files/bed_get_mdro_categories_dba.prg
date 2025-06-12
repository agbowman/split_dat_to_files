CREATE PROGRAM bed_get_mdro_categories:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 categories[*]
      2 category_id = f8
      2 category_name = vc
      2 category_type_ind = i2
      2 category_settings
        3 outbreak_id = f8
        3 facility_occurrence_cnt = i4
        3 facility_time_span = i4
        3 facility_time_span_unit_cd = f8
        3 unit_occurrence_cnt = i4
        3 unit_time_span = i4
        3 unit_time_span_unit_cd = f8
        3 facility_probability_flag = i2
    1 mdro_names[*]
      2 mdro_id = f8
      2 mdro_name = vc
      2 mdro_name_settings
        3 outbreak_id = f8
        3 facility_occurrence_cnt = i4
        3 facility_time_span = i4
        3 facility_time_span_unit_cd = f8
        3 unit_occurrence_cnt = i4
        3 unit_time_span = i4
        3 unit_time_span_unit_cd = f8
        3 facility_probability_flag = i2
    1 cat_organisms[*]
      2 br_mdro_cat_organism_id = f8
      2 organism_cd = f8
      2 organism_display = vc
      2 organism_description = vc
      2 category_id = f8
      2 mdro_id = f8
      2 all_facilities_ind = i2
      2 facility
        3 location_cd = f8
        3 location_display = vc
        3 location_description = vc
      2 cat_organism_settings
        3 outbreak_id = f8
        3 facility_occurrence_cnt = i4
        3 facility_time_span = i4
        3 facility_time_span_unit_cd = f8
        3 unit_occurrence_cnt = i4
        3 unit_time_span = i4
        3 unit_time_span_unit_cd = f8
        3 facility_probability_flag = i2
      2 lookback_time_span_nbr = i4
      2 lookback_time_span_unit_cd
        3 code_value = f8
        3 display = vc
    1 cat_events[*]
      2 br_mdro_cat_event_id = f8
      2 event_cd = f8
      2 event_display = vc
      2 event_description = vc
      2 category_id = f8
      2 mdro_id = f8
      2 all_facilities_ind = i2
      2 facility
        3 location_cd = f8
        3 location_display = vc
        3 location_description = vc
      2 cat_event_settings
        3 outbreak_id = f8
        3 facility_occurrence_cnt = i4
        3 facility_time_span = i4
        3 facility_time_span_unit_cd = f8
        3 unit_occurrence_cnt = i4
        3 unit_time_span = i4
        3 unit_time_span_unit_cd = f8
        3 facility_probability_flag = i2
      2 lookback_time_span_nbr = i4
      2 lookback_time_span_unit_cd
        3 code_value = f8
        3 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE allfacilityind = i2 WITH protect, noconstant(0)
 DECLARE facilitycd = f8 WITH protect, noconstant(0.0)
 DECLARE logdebugmessage(message_header=vc,message=vc) = i2 WITH protect
 DECLARE isvalidrequest(dummyt=i2) = i2
 DECLARE getcategories(categorytypeind=i2,allfacilityind=i2,facilitycd=f8) = i2
 DECLARE getmdronames(categorytypeind=i2,allfacilityind=i2,facilitycd=f8) = i2
 DECLARE getcatorganisms(categorytypeind=i2,allfacilityind=i2,facilitycd=f8) = i2
 DECLARE getcatorganismlookbacksettings(dummy_var=i2) = i2 WITH protect
 DECLARE getcatevents(categorytypeind=i2,allfacilityind=i2,facilitycd=f8) = i2
 DECLARE getcateventlookbacksettings(dummy_var=i2) = i2 WITH protect
 DECLARE logmessage(message=vc) = i2
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 IF ( NOT (isvalidrequest(0)))
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SET allfacilityind = validate(request->all_facilities_ind,0)
 SET facilitycd = validate(request->facility_code_value,0.0)
 CALL getcategories(request->category_type_ind,allfacilityind,facilitycd)
 CALL getmdronames(request->category_type_ind,allfacilityind,facilitycd)
 CALL getcatorganisms(request->category_type_ind,allfacilityind,facilitycd)
 CALL getcatevents(request->category_type_ind,allfacilityind,facilitycd)
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE logdebugmessage(message_header,message)
  IF (validate(debug,0)=1)
   CALL bedlogmessage(message_header,message)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE isvalidrequest(dummyt)
  IF ((request->category_type_ind < 0))
   CALL logmessage(" checkValidRequest() : Invalid request: category_type_ind < 0")
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE getcategories(categorytypeind,allfacilityind,facilitycd)
   DECLARE catcnt = i4 WITH protect, noconstant(0)
   DECLARE lparser = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM br_mdro_cat cat
    PLAN (cat
     WHERE cat.cat_type_flag=categorytypeind
      AND cat.br_mdro_cat_id > 0)
    ORDER BY cat.br_mdro_cat_id
    HEAD cat.br_mdro_cat_id
     catcnt = (catcnt+ 1), stat = alterlist(reply->categories,catcnt), reply->categories[catcnt].
     category_id = cat.br_mdro_cat_id,
     reply->categories[catcnt].category_name = cat.mdro_cat_name, reply->categories[catcnt].
     category_type_ind = cat.cat_type_flag
    WITH nocounter
   ;end select
   IF (size(reply->categories,5) > 0)
    SET lparser = "bmo.parent_entity_name  = 'BR_MDRO_CAT' and"
    SET lparser = build2(lparser," bmo.parent_entity_id = reply->categories[d1.seq].category_id")
    IF (facilitycd > 0
     AND allfacilityind=1)
     SET lparser = build2(lparser," and bmo.location_cd in (0.0, ")
     SET lparser = build2(lparser,facilitycd,")")
    ELSEIF (facilitycd > 0)
     SET lparser = build2(lparser," and bmo.location_cd = ")
     SET lparser = build2(lparser,facilitycd)
    ELSEIF (allfacilityind=1)
     SET lparser = build2(lparser," and bmo.location_cd = 0")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(reply->categories,5)),
      br_mdro_outbreak bmo
     PLAN (d1)
      JOIN (bmo
      WHERE parser(lparser))
     DETAIL
      reply->categories[d1.seq].category_settings.outbreak_id = bmo.br_mdro_outbreak_id, reply->
      categories[d1.seq].category_settings.facility_occurrence_cnt = bmo.facility_occurrence_cnt,
      reply->categories[d1.seq].category_settings.facility_time_span = bmo.facility_time_span_nbr,
      reply->categories[d1.seq].category_settings.facility_time_span_unit_cd = bmo
      .facility_time_span_unit_cd, reply->categories[d1.seq].category_settings.
      facility_probability_flag = bmo.probability_theory_ind, reply->categories[d1.seq].
      category_settings.unit_occurrence_cnt = bmo.unit_occurrence_cnt,
      reply->categories[d1.seq].category_settings.unit_time_span = bmo.unit_time_span_nbr, reply->
      categories[d1.seq].category_settings.unit_time_span_unit_cd = bmo.unit_time_span_unit_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL bederrorcheck(build2(curprog,"Failure in getCategories()"))
 END ;Subroutine
 SUBROUTINE getmdronames(categorytypeind,allfacilityind,facilitycd)
   DECLARE ncnt = i4 WITH protect, noconstant(0)
   DECLARE lparser = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM br_mdro bmn
    PLAN (bmn
     WHERE bmn.br_mdro_id > 0)
    ORDER BY bmn.br_mdro_id
    HEAD bmn.br_mdro_id
     ncnt = (ncnt+ 1), stat = alterlist(reply->mdro_names,ncnt), reply->mdro_names[ncnt].mdro_id =
     bmn.br_mdro_id,
     reply->mdro_names[ncnt].mdro_name = bmn.mdro_name
    WITH nocounter
   ;end select
   IF (size(reply->mdro_names,5) > 0)
    SET lparser = "bmo.parent_entity_name  = 'BR_MDRO' and"
    SET lparser = build2(lparser," bmo.parent_entity_id = reply->mdro_names[d1.seq].mdro_id")
    IF (facilitycd > 0
     AND allfacilityind=1)
     SET lparser = build2(lparser," and bmo.location_cd in (0.0, ")
     SET lparser = build2(lparser,facilitycd,")")
    ELSEIF (facilitycd > 0)
     SET lparser = build2(lparser," and bmo.location_cd = ")
     SET lparser = build2(lparser,facilitycd)
    ELSEIF (allfacilityind=1)
     SET lparser = build2(lparser," and bmo.location_cd = 0")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(reply->mdro_names,5)),
      br_mdro_outbreak bmo
     PLAN (d1)
      JOIN (bmo
      WHERE parser(lparser))
     DETAIL
      reply->mdro_names[d1.seq].mdro_name_settings.outbreak_id = bmo.br_mdro_outbreak_id, reply->
      mdro_names[d1.seq].mdro_name_settings.facility_occurrence_cnt = bmo.facility_occurrence_cnt,
      reply->mdro_names[d1.seq].mdro_name_settings.facility_time_span = bmo.facility_time_span_nbr,
      reply->mdro_names[d1.seq].mdro_name_settings.facility_time_span_unit_cd = bmo
      .facility_time_span_unit_cd, reply->mdro_names[d1.seq].mdro_name_settings.
      facility_probability_flag = bmo.probability_theory_ind, reply->mdro_names[d1.seq].
      mdro_name_settings.unit_occurrence_cnt = bmo.unit_occurrence_cnt,
      reply->mdro_names[d1.seq].mdro_name_settings.unit_time_span = bmo.unit_time_span_nbr, reply->
      mdro_names[d1.seq].mdro_name_settings.unit_time_span_unit_cd = bmo.unit_time_span_unit_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL bederrorcheck(build2(curprog,"Failure in getMdroNames()"))
 END ;Subroutine
 SUBROUTINE getcatorganisms(categorytypeind,allfacilityind,facilitycd)
   IF (size(reply->categories,5) > 0)
    DECLARE oparser = vc WITH protect, noconstant("")
    DECLARE ocnt = i4 WITH protect, noconstant(0)
    SET oparser = "cat_o.br_mdro_cat_id > 0 and cat_o.br_mdro_cat_organism_id > 0"
    IF (facilitycd > 0
     AND allfacilityind=1)
     SET oparser = build2(oparser," and cat_o.location_cd in (0.0, ")
     SET oparser = build2(oparser,facilitycd,")")
    ELSEIF (facilitycd > 0)
     SET oparser = build2(oparser," and cat_o.location_cd = ")
     SET oparser = build2(oparser,facilitycd)
    ELSEIF (allfacilityind=1)
     SET oparser = build2(oparser," and cat_o.location_cd = 0")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(reply->categories,5)),
      br_mdro_cat_organism cat_o,
      br_mdro bmn,
      br_mdro_cat cat,
      code_value loc_cv,
      br_mdro_outbreak bmo
     PLAN (d1)
      JOIN (cat_o
      WHERE (cat_o.br_mdro_cat_id=reply->categories[d1.seq].category_id)
       AND parser(oparser))
      JOIN (bmn
      WHERE bmn.br_mdro_id=cat_o.br_mdro_id)
      JOIN (cat
      WHERE cat.br_mdro_cat_id=cat_o.br_mdro_cat_id
       AND cat.cat_type_flag=categorytypeind)
      JOIN (loc_cv
      WHERE loc_cv.code_value=cat_o.location_cd)
      JOIN (bmo
      WHERE bmo.parent_entity_id=outerjoin(cat_o.br_mdro_cat_organism_id)
       AND bmo.parent_entity_name=outerjoin("BR_MDRO_CAT_ORGANISM"))
     ORDER BY cat_o.br_mdro_cat_organism_id
     HEAD cat_o.br_mdro_cat_organism_id
      ocnt = (ocnt+ 1), stat = alterlist(reply->cat_organisms,ocnt), reply->cat_organisms[ocnt].
      br_mdro_cat_organism_id = cat_o.br_mdro_cat_organism_id,
      reply->cat_organisms[ocnt].organism_cd = cat_o.organism_cd, reply->cat_organisms[ocnt].
      organism_display = uar_get_code_display(cat_o.organism_cd), reply->cat_organisms[ocnt].
      organism_description = uar_get_code_description(cat_o.organism_cd),
      reply->cat_organisms[ocnt].category_id = reply->categories[d1.seq].category_id, reply->
      cat_organisms[ocnt].mdro_id = bmn.br_mdro_id, reply->cat_organisms[ocnt].facility.location_cd
       = cat_o.location_cd,
      reply->cat_organisms[ocnt].facility.location_display = loc_cv.display, reply->cat_organisms[
      ocnt].facility.location_description = loc_cv.description
      IF (cat_o.location_cd=0)
       reply->cat_organisms[ocnt].all_facilities_ind = 1
      ENDIF
      IF (bmo.br_mdro_outbreak_id > 0)
       reply->cat_organisms[ocnt].cat_organism_settings.outbreak_id = bmo.br_mdro_outbreak_id, reply
       ->cat_organisms[ocnt].cat_organism_settings.facility_occurrence_cnt = bmo
       .facility_occurrence_cnt, reply->cat_organisms[ocnt].cat_organism_settings.facility_time_span
        = bmo.facility_time_span_nbr,
       reply->cat_organisms[ocnt].cat_organism_settings.facility_time_span_unit_cd = bmo
       .facility_time_span_unit_cd, reply->cat_organisms[ocnt].cat_organism_settings.
       facility_probability_flag = bmo.probability_theory_ind, reply->cat_organisms[ocnt].
       cat_organism_settings.unit_occurrence_cnt = bmo.unit_occurrence_cnt,
       reply->cat_organisms[ocnt].cat_organism_settings.unit_time_span = bmo.unit_time_span_nbr,
       reply->cat_organisms[ocnt].cat_organism_settings.unit_time_span_unit_cd = bmo
       .unit_time_span_unit_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL bederrorcheck(build2(curprog,"Failure in getCatOrganisms()"))
   IF (getcatorganismlookbacksettings(0)=false)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getcatorganismlookbacksettings(dummy_var)
   CALL logdebugmessage("DEBUG 001: getCatOrganismLookbackSettings",
    "Entering subroutine getCatOrganismLookbackSettings")
   FREE RECORD getlookbackrequest
   RECORD getlookbackrequest(
     1 mdro_items[*]
       2 br_mdro_id = f8
       2 br_mdro_cat_id = f8
       2 organism_cd = f8
       2 location_cd = f8
   )
   FREE RECORD getlookbackreply
   RECORD getlookbackreply(
     1 mdro_items[*]
       2 br_mdro_id = f8
       2 br_mdro_cat_id = f8
       2 organism_cd = f8
       2 location_cd = f8
       2 lookback_time_span_nbr = i4
       2 lookback_time_span_unit_cd
         3 code_value = f8
         3 display = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   CALL logdebugmessage("DEBUG 003: getCatOrganismLookbackSettings",
    "Populating request for subscript bed_get_mdro_cat_org_lookback.prg")
   DECLARE mdro_item_count = i4 WITH protect, constant(size(reply->cat_organisms,5))
   SET stat = alterlist(getlookbackrequest->mdro_items,mdro_item_count)
   FOR (index = 1 TO mdro_item_count)
     SET getlookbackrequest->mdro_items[index].br_mdro_id = reply->cat_organisms[index].mdro_id
     SET getlookbackrequest->mdro_items[index].br_mdro_cat_id = reply->cat_organisms[index].
     category_id
     SET getlookbackrequest->mdro_items[index].organism_cd = reply->cat_organisms[index].organism_cd
     IF ((reply->cat_organisms[index].all_facilities_ind=0))
      SET getlookbackrequest->mdro_items[index].location_cd = reply->cat_organisms[index].facility.
      location_cd
     ENDIF
   ENDFOR
   CALL logdebugmessage("DEBUG 004: getCatOrganismLookbackSettings",
    "Calling subscript bed_get_mdro_cat_org_lookback.prg")
   EXECUTE bed_get_mdro_cat_org_lookback  WITH replace("REQUEST",getlookbackrequest), replace("REPLY",
    getlookbackreply)
   IF ((getlookbackreply->status_data.status="F"))
    CALL logdebugmessage("DEBUG 005: getCatOrganismLookbackSettings","Child script failed..")
    CALL bederror(getlookbackreply->status_data.subeventstatus[1].targetobjectname)
   ENDIF
   CALL logdebugmessage("DEBUG 006: getCatOrganismLookbackSettings",
    "Placing subscript reply in current script's reply.")
   FOR (index1 = 1 TO mdro_item_count)
     FOR (index2 = 1 TO size(getlookbackreply->mdro_items,5))
       IF ((reply->cat_organisms[index1].mdro_id=getlookbackreply->mdro_items[index2].br_mdro_id)
        AND (reply->cat_organisms[index1].category_id=getlookbackreply->mdro_items[index2].
       br_mdro_cat_id)
        AND (reply->cat_organisms[index1].organism_cd=getlookbackreply->mdro_items[index2].
       organism_cd)
        AND (reply->cat_organisms[index1].facility.location_cd=getlookbackreply->mdro_items[index2].
       location_cd))
        SET reply->cat_organisms[index1].lookback_time_span_nbr = getlookbackreply->mdro_items[index2
        ].lookback_time_span_nbr
        SET reply->cat_organisms[index1].lookback_time_span_unit_cd.code_value = getlookbackreply->
        mdro_items[index2].lookback_time_span_unit_cd.code_value
        SET reply->cat_organisms[index1].lookback_time_span_unit_cd.display = getlookbackreply->
        mdro_items[index2].lookback_time_span_unit_cd.display
       ENDIF
     ENDFOR
   ENDFOR
   CALL logdebugmessage("DEBUG 007: getCatOrganismLookbackSettings",
    "Exiting subroutine getCatOrganismLookbackSettings")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getcatevents(categorytypeind,allfacilityind,facilitycd)
   IF (size(reply->categories,5) > 0)
    DECLARE eparser = vc WITH protect, noconstant("")
    DECLARE ecnt = i4 WITH protect, noconstant(0)
    SET eparser = "cat_e.br_mdro_cat_id > 0 and cat_e.br_mdro_cat_event_id > 0"
    IF (facilitycd > 0
     AND allfacilityind=1)
     SET eparser = build2(eparser," and cat_e.location_cd in (0.0, ")
     SET eparser = build2(eparser,facilitycd,")")
    ELSEIF (facilitycd > 0)
     SET eparser = build2(eparser," and cat_e.location_cd = ")
     SET eparser = build2(eparser,facilitycd)
    ELSEIF (allfacilityind=1)
     SET eparser = build2(eparser," and cat_e.location_cd = 0")
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(reply->categories,5)),
      br_mdro_cat_event cat_e,
      br_mdro bmn,
      br_mdro_cat cat,
      code_value loc_cv,
      br_mdro_outbreak bmo
     PLAN (d1)
      JOIN (cat_e
      WHERE (cat_e.br_mdro_cat_id=reply->categories[d1.seq].category_id)
       AND parser(eparser))
      JOIN (bmn
      WHERE bmn.br_mdro_id=cat_e.br_mdro_id)
      JOIN (cat
      WHERE cat.br_mdro_cat_id=cat_e.br_mdro_cat_id
       AND cat.cat_type_flag=categorytypeind)
      JOIN (loc_cv
      WHERE loc_cv.code_value=cat_e.location_cd)
      JOIN (bmo
      WHERE bmo.parent_entity_id=outerjoin(cat_e.br_mdro_cat_event_id)
       AND bmo.parent_entity_name=outerjoin("BR_MDRO_CAT_EVENT"))
     ORDER BY cat_e.br_mdro_cat_event_id
     HEAD cat_e.br_mdro_cat_event_id
      ecnt = (ecnt+ 1), stat = alterlist(reply->cat_events,ecnt), reply->cat_events[ecnt].
      br_mdro_cat_event_id = cat_e.br_mdro_cat_event_id,
      reply->cat_events[ecnt].event_cd = cat_e.event_cd, reply->cat_events[ecnt].event_display =
      uar_get_code_display(cat_e.event_cd), reply->cat_events[ecnt].event_description =
      uar_get_code_description(cat_e.event_cd),
      reply->cat_events[ecnt].category_id = reply->categories[d1.seq].category_id, reply->cat_events[
      ecnt].mdro_id = bmn.br_mdro_id, reply->cat_events[ecnt].facility.location_cd = cat_e
      .location_cd,
      reply->cat_events[ecnt].facility.location_display = loc_cv.display, reply->cat_events[ecnt].
      facility.location_description = loc_cv.description
      IF (cat_e.location_cd=0)
       reply->cat_events[ecnt].all_facilities_ind = 1
      ENDIF
      IF (bmo.br_mdro_outbreak_id > 0)
       reply->cat_events[ecnt].cat_event_settings.outbreak_id = bmo.br_mdro_outbreak_id, reply->
       cat_events[ecnt].cat_event_settings.facility_occurrence_cnt = bmo.facility_occurrence_cnt,
       reply->cat_events[ecnt].cat_event_settings.facility_time_span = bmo.facility_time_span_nbr,
       reply->cat_events[ecnt].cat_event_settings.facility_time_span_unit_cd = bmo
       .facility_time_span_unit_cd, reply->cat_events[ecnt].cat_event_settings.
       facility_probability_flag = bmo.probability_theory_ind, reply->cat_events[ecnt].
       cat_event_settings.unit_occurrence_cnt = bmo.unit_occurrence_cnt,
       reply->cat_events[ecnt].cat_event_settings.unit_time_span = bmo.unit_time_span_nbr, reply->
       cat_events[ecnt].cat_event_settings.unit_time_span_unit_cd = bmo.unit_time_span_unit_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (getcateventlookbacksettings(0)=false)
    RETURN(false)
   ENDIF
   CALL bederrorcheck(build2(curprog,"Failure in getCatEvents()"))
 END ;Subroutine
 SUBROUTINE getcateventlookbacksettings(dummy_var)
   CALL logdebugmessage("DEBUG 001: getCatEventLookbackSettings",
    "Entering subroutine getCatEventLookbackSettings")
   FREE RECORD getlookbackrequest
   RECORD getlookbackrequest(
     1 mdro_items[*]
       2 br_mdro_id = f8
       2 br_mdro_cat_id = f8
       2 event_cd = f8
       2 location_cd = f8
   )
   FREE RECORD getlookbackreply
   RECORD getlookbackreply(
     1 mdro_items[*]
       2 br_mdro_id = f8
       2 br_mdro_cat_id = f8
       2 event_cd = f8
       2 location_cd = f8
       2 lookback_time_span_nbr = i4
       2 lookback_time_span_unit_cd
         3 code_value = f8
         3 display = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   CALL logdebugmessage("DEBUG 003: getCatEventLookbackSettings",
    "Populating request for subscript bed_get_mdro_cat_es_lookback.prg")
   DECLARE mdro_item_count = i4 WITH protect, constant(size(reply->cat_events,5))
   SET stat = alterlist(getlookbackrequest->mdro_items,mdro_item_count)
   FOR (index = 1 TO mdro_item_count)
     SET getlookbackrequest->mdro_items[index].br_mdro_id = reply->cat_events[index].mdro_id
     SET getlookbackrequest->mdro_items[index].br_mdro_cat_id = reply->cat_events[index].category_id
     SET getlookbackrequest->mdro_items[index].event_cd = reply->cat_events[index].event_cd
     IF ((reply->cat_events[index].all_facilities_ind=0))
      SET getlookbackrequest->mdro_items[index].location_cd = reply->cat_events[index].facility.
      location_cd
     ENDIF
   ENDFOR
   CALL logdebugmessage("DEBUG 004: getCatEventLookbackSettings",
    "Calling subscript bed_get_mdro_cat_es_lookback.prg")
   EXECUTE bed_get_mdro_cat_es_lookback  WITH replace("REQUEST",getlookbackrequest), replace("REPLY",
    getlookbackreply)
   IF ((getlookbackreply->status_data.status="F"))
    CALL logdebugmessage("DEBUG 005: getCatEventLookbackSettings","Child script failed..")
    CALL bederror(getlookbackreply->status_data.subeventstatus[1].targetobjectname)
   ENDIF
   CALL logdebugmessage("DEBUG 006: getCatEventLookbackSettings",
    "Placing subscript reply in current script's reply.")
   FOR (index1 = 1 TO mdro_item_count)
     FOR (index2 = 1 TO size(getlookbackreply->mdro_items,5))
       IF ((reply->cat_events[index1].mdro_id=getlookbackreply->mdro_items[index2].br_mdro_id)
        AND (reply->cat_events[index1].category_id=getlookbackreply->mdro_items[index2].
       br_mdro_cat_id)
        AND (reply->cat_events[index1].event_cd=getlookbackreply->mdro_items[index2].event_cd)
        AND (reply->cat_events[index1].facility.location_cd=getlookbackreply->mdro_items[index2].
       location_cd))
        SET reply->cat_events[index1].lookback_time_span_nbr = getlookbackreply->mdro_items[index2].
        lookback_time_span_nbr
        SET reply->cat_events[index1].lookback_time_span_unit_cd.code_value = getlookbackreply->
        mdro_items[index2].lookback_time_span_unit_cd.code_value
        SET reply->cat_events[index1].lookback_time_span_unit_cd.display = getlookbackreply->
        mdro_items[index2].lookback_time_span_unit_cd.display
       ENDIF
     ENDFOR
   ENDFOR
   CALL logdebugmessage("DEBUG 007: getCatEventLookbackSettings",
    "Exiting subroutine getCatEventLookbackSettings")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE logmessage(message)
   CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
   CALL echo(concat(curprog,message))
   CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 END ;Subroutine
END GO
