CREATE PROGRAM bed_get_fn_trk_column:dba
 FREE SET reply
 RECORD reply(
   1 cat_list[*]
     2 category_name = vc
     2 column_header = i2
     2 slist[*]
       3 sub_category_name = vc
       3 sub_category_mean = vc
       3 clist[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
         4 mean = vc
         4 elist[*]
           5 event_id = f8
           5 display = vc
           5 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_scount = 0
 SET count = 0
 SET tot_count = 0
 SET ccount = 0
 SET tot_ccount = 0
 SET ecount = 0
 SET tot_ecount = 0
 SET stat = alterlist(reply->cat_list,20)
 IF ((request->list_type_mean="TRKBEDLIST"))
  SET found_alias = 0
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.definition=trim(request->list_type_mean)
     AND cv.cdf_meaning="TEALLIASCOL")
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   DETAIL
    found_alias = 1
   WITH nocounter
  ;end select
  IF (found_alias=1)
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.active_ind=1
     AND cv.code_set=28701
     AND cv.cdf_meaning="FNALIAS"
    DETAIL
     count = (count+ 1), tot_count = (tot_count+ 1)
     IF (count > 20)
      stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
     ENDIF
     reply->cat_list[tot_count].category_name = cv.display, reply->cat_list[tot_count].column_header
      = 1
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=319
     AND cv.active_ind=1
    ORDER BY cv.description
    HEAD REPORT
     stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,20)
    DETAIL
     ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
     IF (ccount > 20)
      stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,(tot_ccount+ 20)), ccount
       = 1
     ENDIF
     reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = cv.code_value, reply->
     cat_list[tot_count].slist[1].clist[tot_ccount].display = cv.display, reply->cat_list[tot_count].
     slist[1].clist[tot_ccount].description = cv.description,
     reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = cv.cdf_meaning
    FOOT REPORT
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNASSIGNED"
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
    ENDIF
    reply->cat_list[tot_count].category_name = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.active_ind=1
     AND cv.definition=trim(request->list_type_mean)
     AND cv.cdf_meaning="TEAS*N*")
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   ORDER BY cv.description
   HEAD REPORT
    stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,20)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,(tot_ccount+ 20)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = cv.code_value, reply->
    cat_list[tot_count].slist[1].clist[tot_ccount].display = cv.display, reply->cat_list[tot_count].
    slist[1].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNBSCCOLS"
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
    ENDIF
    reply->cat_list[tot_count].category_name = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.active_ind=1
     AND cv.definition=trim(request->list_type_mean)
     AND cv.cdf_meaning != "TERESULTS*"
     AND cv.cdf_meaning != "TEEV*"
     AND cv.cdf_meaning != "TEALLIASCOL*"
     AND cv.cdf_meaning != "TEAS*N*"
     AND cv.cdf_meaning != "TECMT*"
     AND cv.cdf_meaning != "TELOS*"
     AND cv.cdf_meaning != "TEMAR*"
     AND cv.cdf_meaning != "TEORD*"
     AND cv.cdf_meaning != "TEPRVROLE"
     AND cv.cdf_meaning != "TETRK*"
     AND cv.cdf_meaning != "TESUR*")
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   ORDER BY cv.description
   HEAD REPORT
    stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,20)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,(tot_ccount+ 20)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = cv.code_value, reply->
    cat_list[tot_count].slist[1].clist[tot_ccount].display = cv.display, reply->cat_list[tot_count].
    slist[1].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNCOMMENTS"
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
    ENDIF
    reply->cat_list[tot_count].category_name = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.active_ind=1
     AND cv.definition=trim(request->list_type_mean)
     AND cv.cdf_meaning="TECMT*")
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   ORDER BY cv.description
   HEAD REPORT
    stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,20)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,(tot_ccount+ 20)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = cv.code_value, reply->
    cat_list[tot_count].slist[1].clist[tot_ccount].display = cv.display, reply->cat_list[tot_count].
    slist[1].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNEVENTICON"
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
    ENDIF
    reply->cat_list[tot_count].column_header = 1, tot_scount = (tot_scount+ 1), stat = alterlist(
     reply->cat_list[tot_count].slist,tot_scount),
    reply->cat_list[tot_count].slist[tot_scount].sub_category_name = cv.display, reply->cat_list[
    tot_count].slist[tot_scount].sub_category_mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.active_ind=1
     AND cv.code_set=6202
     AND cv.display="Events")
   DETAIL
    ccount = 1, tot_ccount = 1, stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,
     10),
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].code_value = cv.code_value, reply
    ->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].display = cv.display, reply->cat_list[
    tot_count].slist[tot_scount].clist[tot_ccount].description = "All Event Icons",
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].mean = "TEETICONCOL"
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNEVENTS"
   DETAIL
    reply->cat_list[tot_count].category_name = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.active_ind=1
     AND cv.code_set=6202
     AND cv.display != "Discharge"
     AND cv.display != "Triage"
     AND cv.display != "Fast Track"
     AND cv.display != "Acute"
     AND cv.display != "Prearrival"
     AND cv.display != "Events")
   ORDER BY cv.description
   HEAD REPORT
    ccount = 1, tot_ccount = 1, stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,
     10)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 10)
     stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,(tot_ccount+ 10)), ccount =
     1
    ENDIF
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].code_value = cv.code_value, reply
    ->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].display = cv.display, reply->cat_list[
    tot_count].slist[tot_scount].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].mean = "TEETICONCOL"
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,tot_ccount)
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNEVENTNAME"
   DETAIL
    tot_scount = (tot_scount+ 1), stat = alterlist(reply->cat_list[tot_count].slist,tot_scount),
    reply->cat_list[tot_count].slist[tot_scount].sub_category_name = cv.display,
    reply->cat_list[tot_count].slist[tot_scount].sub_category_mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.active_ind=1
     AND cv.code_set=6202
     AND cv.display="Events")
   DETAIL
    ccount = 1, tot_ccount = 1, stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,
     10),
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].code_value = cv.code_value, reply
    ->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].display = cv.display, reply->cat_list[
    tot_count].slist[tot_scount].clist[tot_ccount].description = "All Event Names",
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].mean = "TEETTEXTCOL"
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.active_ind=1
     AND cv.code_set=6202
     AND cv.display != "Discharge"
     AND cv.display != "Triage"
     AND cv.display != "Fast Track"
     AND cv.display != "Acute"
     AND cv.display != "Prearrival"
     AND cv.display != "Events")
   ORDER BY cv.description
   HEAD REPORT
    ccount = 1, tot_ccount = 1, stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,
     10)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 10)
     stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,(tot_ccount+ 10)), ccount =
     1
    ENDIF
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].code_value = cv.code_value, reply
    ->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].display = cv.display, reply->cat_list[
    tot_count].slist[tot_scount].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].mean = "TEETTEXTCOL"
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,tot_ccount)
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNEVENTIND"
   DETAIL
    tot_scount = (tot_scount+ 1), stat = alterlist(reply->cat_list[tot_count].slist,tot_scount),
    reply->cat_list[tot_count].slist[tot_scount].sub_category_name = cv.display,
    reply->cat_list[tot_count].slist[tot_scount].sub_category_mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv,
    track_event te
   PLAN (cv
    WHERE cv.active_ind=1
     AND cv.code_set=6202
     AND cv.display IN ("Depart Action", "PowerNote ED", "Events", "Patient Care"))
    JOIN (te
    WHERE te.active_ind=1
     AND (te.tracking_group_cd=request->trk_group_code_value)
     AND te.tracking_event_type_cd=cv.code_value)
   ORDER BY cv.description, te.description
   HEAD REPORT
    ccount = 0, tot_ccount = 0, stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,5
     )
   HEAD cv.code_value
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 5)
     stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,(tot_ccount+ 5)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].code_value = cv.code_value, reply
    ->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].display = cv.display, reply->cat_list[
    tot_count].slist[tot_scount].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].mean = "TEEVENTCOL", ecount = 0,
    tot_ecount = 0,
    stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].elist,20)
   DETAIL
    ecount = (ecount+ 1), tot_ecount = (tot_ecount+ 1)
    IF (ecount > 20)
     stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].elist,(
      tot_ecount+ 5)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].elist[tot_ecount].event_id = te
    .track_event_id, reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].elist[tot_ecount]
    .display = te.display, reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].elist[
    tot_ecount].description = te.description
   FOOT  cv.code_value
    stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist[tot_ccount].elist,tot_ecount)
   FOOT REPORT
    stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,tot_ccount)
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNLOS"
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
    ENDIF
    reply->cat_list[tot_count].category_name = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.active_ind=1
     AND cv.definition=trim(request->list_type_mean)
     AND cv.cdf_meaning="TELOS*")
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   ORDER BY cv.description
   HEAD REPORT
    stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,20)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,(tot_ccount+ 20)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = cv.code_value, reply->
    cat_list[tot_count].slist[1].clist[tot_ccount].display = cv.display, reply->cat_list[tot_count].
    slist[1].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNORDERS"
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
    ENDIF
    reply->cat_list[tot_count].category_name = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.active_ind=1
     AND cv.definition=trim(request->list_type_mean)
     AND ((cv.cdf_meaning="TEORD*") OR (cv.cdf_meaning="TEMAR*"))
     AND cv.cdf_meaning != "TEORDINFO*")
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   ORDER BY cv.description
   HEAD REPORT
    stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,20)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,(tot_ccount+ 20)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = cv.code_value, reply->
    cat_list[tot_count].slist[1].clist[tot_ccount].display = cv.display, reply->cat_list[tot_count].
    slist[1].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
   WITH nocounter
  ;end select
  SET found_prv_role = 0
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.definition=trim(request->list_type_mean)
     AND cv.cdf_meaning="TEPRVROLE")
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   DETAIL
    found_prv_role = 1
   WITH nocounter
  ;end select
  IF (found_prv_role=1)
   SET track_ref_type_cd = 0.0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=16409
     AND cv.active_ind=1
     AND cv.cdf_meaning="PRVRELN"
    DETAIL
     track_ref_type_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (track_ref_type_cd > 0.0)
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.active_ind=1
      AND cv.code_set=28701
      AND cv.cdf_meaning="FNPROVROLES"
     DETAIL
      count = (count+ 1), tot_count = (tot_count+ 1)
      IF (count > 20)
       stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
      ENDIF
      reply->cat_list[tot_count].category_name = cv.display
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM track_reference tr
     WHERE tr.tracking_ref_type_cd=track_ref_type_cd
      AND (tr.tracking_group_cd=request->trk_group_code_value)
      AND tr.active_ind=1
     ORDER BY tr.description
     HEAD REPORT
      stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
      stat = alterlist(reply->cat_list[tot_count].slist[1].clist,20)
     DETAIL
      ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
      IF (ccount > 20)
       stat = alterlist(reply->cat_list[tot_count].slist[1].clist,(tot_ccount+ 20)), ccount = 1
      ENDIF
      reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = tr.tracking_ref_id, reply->
      cat_list[tot_count].slist[1].clist[tot_ccount].display = tr.description, reply->cat_list[
      tot_count].slist[1].clist[tot_ccount].description = tr.description,
      reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = "TEPRVROLE"
     FOOT REPORT
      stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNTRACK"
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
    ENDIF
    reply->cat_list[tot_count].category_name = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.active_ind=1
     AND cv.definition=trim(request->list_type_mean)
     AND ((cv.cdf_meaning="TETRKCMNT*") OR (((cv.cdf_meaning="TETRKREA*") OR (((cv.cdf_meaning=
    "TETRKDPTTME") OR (cv.cdf_meaning="TETRKCODE")) )) )) )
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   ORDER BY cv.description
   HEAD REPORT
    stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,20)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,(tot_ccount+ 20)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = cv.code_value, reply->
    cat_list[tot_count].slist[1].clist[tot_ccount].display = cv.display, reply->cat_list[tot_count].
    slist[1].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
   WITH nocounter
  ;end select
 ELSEIF ((request->list_type_mean="TRKPRVLIST"))
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.active_ind=1
    AND cv.code_set=28701
    AND cv.cdf_meaning="FNBSCCOLS"
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->cat_list,(tot_count+ 20)), count = 1
    ENDIF
    reply->cat_list[tot_count].category_name = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=6020
     AND cv.active_ind=1
     AND cv.definition=trim(request->list_type_mean)
     AND ((cv.cdf_meaning="PE*") OR (cv.cdf_meaning="TEALERT"))
     AND cv.cdf_meaning != "PETEAMCOL")
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="FLD_VALUE")
   ORDER BY cv.description
   HEAD REPORT
    stat = alterlist(reply->cat_list[tot_count].slist,1), ccount = 0, tot_ccount = 0,
    stat = alterlist(reply->cat_list[tot_count].slist[tot_scount].clist,20)
   DETAIL
    ccount = (ccount+ 1), tot_ccount = (tot_ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->cat_list[tot_count].slist[1].clist,(tot_ccount+ 20)), ccount = 1
    ENDIF
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].code_value = cv.code_value, reply->
    cat_list[tot_count].slist[1].clist[tot_ccount].display = cv.display, reply->cat_list[tot_count].
    slist[1].clist[tot_ccount].description = cv.description,
    reply->cat_list[tot_count].slist[1].clist[tot_ccount].mean = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->cat_list[tot_count].slist[1].clist,tot_ccount)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->cat_list,tot_count)
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
