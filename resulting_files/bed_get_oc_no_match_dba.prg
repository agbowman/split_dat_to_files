CREATE PROGRAM bed_get_oc_no_match:dba
 FREE SET reply
 RECORD reply(
   1 client_oc_list[*]
     2 oc_id = f8
     2 short_desc = c100
     2 long_desc = c100
     2 facility = vc
     2 cpt4_code = vc
   1 oc_list[*]
     2 catalog_code_value = f8
     2 primary_name = c100
     2 description = c100
     2 autobuild_ind = i2
     2 selected_ind = i2
     2 procedure_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET wlist
 RECORD wlist(
   1 work_list[*]
     2 catalog_cd = f8
     2 concept_cki = vc
 )
 FREE SET slist
 RECORD slist(
   1 start_list[*]
     2 catalog_cd = f8
     2 concept_cki = vc
     2 active_ind = i2
     2 mnemonic_key_cap = vc
 )
 SET reply->status_data.status = "F"
 DECLARE br_parse = vc
 SET count = 0
 SET listcount = 0
 SET auto_client_id = 0.0
 SET work_count = 0
 SET tot_work_count = 0
 SET start_count = 0
 SET tot_start_count = 0
 SET i = 0
 IF ((request->load.client=1))
  SET catalog_display = fillstring(42," ")
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=6000
    AND cv.active_ind=1
    AND (cv.code_value=request->filters.catalog_type_code_value)
   DETAIL
    catalog_display = concat("'",trim(cnvtupper(cv.display)),"'")
   WITH nocounter
  ;end select
  SET activity_display = fillstring(42," ")
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=106
    AND cv.active_ind=1
    AND (cv.code_value=request->filters.activity_type_code_value)
   DETAIL
    activity_display = concat("'",trim(cnvtupper(cv.display)),"'")
   WITH nocounter
  ;end select
  IF (catalog_display > "   *")
   SET br_parse = concat(br_parse,"b.status_ind = 0")
   SET br_parse = concat(br_parse," and cnvtupper(b.catalog_type) =",catalog_display)
  ENDIF
  IF (activity_display > "   *")
   SET br_parse = concat(br_parse," and cnvtupper(b.activity_type) =",activity_display)
  ENDIF
  SET fac_count = size(request->filters.fac_list,5)
  IF (fac_count > 0)
   FOR (i = 1 TO fac_count)
     IF (i=1)
      SET br_parse = concat(br_parse," and (b.facility = '",trim(request->filters.fac_list[i].name),
       "'")
     ELSE
      SET br_parse = concat(br_parse," or b.facility = '",trim(request->filters.fac_list[i].name),"'"
       )
     ENDIF
   ENDFOR
   SET br_parse = concat(br_parse,")")
  ENDIF
  CALL echo(build("parser = ",br_parse))
  SET cpt4_code_value = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=14002
    AND cv.cki="CKI.CODEVALUE!3600"
   DETAIL
    cpt4_code_value = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM br_oc_work b,
    br_oc_pricing bp
   PLAN (b
    WHERE parser(br_parse))
    JOIN (bp
    WHERE bp.oc_id=outerjoin(b.oc_id)
     AND bp.billcode_sched_cd=outerjoin(cpt4_code_value))
   HEAD REPORT
    stat = alterlist(reply->client_oc_list,10), count = 0, listcount = 0
   DETAIL
    count = (count+ 1), listcount = (listcount+ 1)
    IF (listcount > 10)
     stat = alterlist(reply->client_oc_list,(count+ 10)), listcount = 0
    ENDIF
    reply->client_oc_list[count].short_desc = b.short_desc, reply->client_oc_list[count].long_desc =
    b.long_desc, reply->client_oc_list[count].oc_id = b.oc_id,
    reply->client_oc_list[count].facility = b.facility, reply->client_oc_list[count].cpt4_code = bp
    .billcode
   FOOT REPORT
    stat = alterlist(reply->client_oc_list,count)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load.cerner=1))
  SET stat = alterlist(reply->oc_list,10)
  SET count = 0
  SET listcount = 0
  DECLARE search_string = vc
  SET search_string = "*"
  IF ((request->filters.search_type_flag="S"))
   SET search_string = concat('"',trim(request->filters.search_string),'*"')
  ELSE
   SET search_string = concat('"*',trim(request->filters.search_string),'*"')
  ENDIF
  SET search_string = cnvtupper(search_string)
  DECLARE oc_parse = vc
  DECLARE full_oc_parse = vc
  SET oc_parse = build(" ((o.active_ind = 1 and o.primary_mnemonic != 'zz*') or ",
   " (o.active_ind = 0)) and "," o.orderable_type_flag != 6 and o.orderable_type_flag != 2 and ",
   " o.catalog_type_cd = ",request->filters.catalog_type_code_value)
  IF ((request->filters.activity_type_code_value > 0))
   SET oc_parse = build(oc_parse," and o.activity_type_cd = ",request->filters.
    activity_type_code_value)
  ENDIF
  IF ((request->filters.subactivity_type_code_value > 0))
   SET oc_parse = build(oc_parse," and o.activity_subtype_cd = ",request->filters.
    subactivity_type_code_value)
  ENDIF
  IF (search_string > "    ")
   SET oc_parse = concat(oc_parse," and cnvtupper(o.primary_mnemonic) = ",search_string)
  ENDIF
  SET full_oc_parse = oc_parse
  SET oc_parse = concat(oc_parse," and not exists(select b.oc_id from br_oc_work b",
   " where o.catalog_cd = b.match_orderable_cd) ")
  SELECT INTO "NL:"
   FROM order_catalog o
   PLAN (o
    WHERE parser(oc_parse))
   ORDER BY o.catalog_cd
   DETAIL
    count = (count+ 1), listcount = (listcount+ 1)
    IF (listcount > 10)
     stat = alterlist(reply->oc_list,(count+ 10)), listcount = 1
    ENDIF
    reply->oc_list[count].catalog_code_value = o.catalog_cd, reply->oc_list[count].primary_name = o
    .primary_mnemonic, reply->oc_list[count].description = o.description,
    reply->oc_list[count].concept_cki = o.concept_cki
    IF (o.active_ind=0)
     reply->oc_list[count].selected_ind = 0
    ELSE
     reply->oc_list[count].selected_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (count > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = count),
     service_directory l,
     code_value cv
    PLAN (d)
     JOIN (l
     WHERE (l.catalog_cd=reply->oc_list[d.seq].catalog_code_value)
      AND l.bb_processing_cd > 0)
     JOIN (cv
     WHERE cv.code_value=l.bb_processing_cd)
    DETAIL
     reply->oc_list[d.seq].procedure_type.code_value = l.bb_processing_cd, reply->oc_list[d.seq].
     procedure_type.display = cv.display, reply->oc_list[d.seq].procedure_type.mean = cv.cdf_meaning
    WITH nocounter
   ;end select
  ENDIF
  SET tot_oc_count = count
  SET surg_code = 0.0
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="SURGERY"
    AND cv.active_ind=1
   DETAIL
    surg_code = cv.code_value
   WITH nocounter
  ;end select
  DECLARE oc_parse = vc
  SET oc_parse = build(" o.catalog_type_cd = ",request->filters.catalog_type_code_value)
  IF ((surg_code=request->filters.catalog_type_code_value))
   SET oc_parse = concat(oc_parse," and o.surgery_ind = 1")
  ELSE
   IF ((request->filters.activity_type_code_value > 0))
    SET oc_parse = build(oc_parse," and o.activity_type_cd = ",request->filters.
     activity_type_code_value)
   ENDIF
   IF ((request->filters.subactivity_type_code_value > 0))
    SET oc_parse = build(oc_parse," and o.activity_subtype_cd = ",request->filters.
     subactivity_type_code_value)
   ENDIF
  ENDIF
  IF (search_string > "    ")
   SET oc_parse = concat(oc_parse," and cnvtupper(o.primary_mnemonic) = ",search_string)
  ENDIF
  SELECT INTO "NL:"
   FROM br_oc_work b,
    order_catalog oc
   PLAN (b
    WHERE b.match_orderable_cd > 0)
    JOIN (oc
    WHERE oc.catalog_cd=b.match_orderable_cd)
   ORDER BY b.match_orderable_cd
   HEAD REPORT
    stat = alterlist(wlist->work_list,50)
   DETAIL
    work_count = (work_count+ 1), tot_work_count = (tot_work_count+ 1)
    IF (work_count > 50)
     stat = alterlist(wlist->work_list,(tot_work_count+ 50)), work_count = 1
    ENDIF
    wlist->work_list[tot_work_count].catalog_cd = b.match_orderable_cd, wlist->work_list[
    tot_work_count].concept_cki = oc.concept_cki
   FOOT REPORT
    stat = alterlist(wlist->work_list,tot_work_count)
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM order_catalog o
   PLAN (o
    WHERE parser(full_oc_parse))
   ORDER BY o.catalog_cd
   HEAD REPORT
    stat = alterlist(slist->start_list,50)
   DETAIL
    start_count = (start_count+ 1), tot_start_count = (tot_start_count+ 1)
    IF (start_count > 50)
     stat = alterlist(slist->start_list,(tot_start_count+ 50)), start_count = 1
    ENDIF
    slist->start_list[tot_start_count].catalog_cd = o.catalog_cd, slist->start_list[tot_start_count].
    active_ind = o.active_ind, slist->start_list[tot_start_count].concept_cki = o.concept_cki
   FOOT REPORT
    stat = alterlist(slist->start_list,tot_start_count)
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM br_auto_order_catalog o
   PLAN (o
    WHERE parser(oc_parse))
   ORDER BY o.primary_mnemonic
   DETAIL
    found = 0, found_selected = 0
    FOR (i = 1 TO tot_work_count)
      IF ((wlist->work_list[i].concept_cki=o.concept_cki))
       i = tot_work_count, found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     FOR (i = 1 TO tot_oc_count)
       IF ((((reply->oc_list[i].catalog_code_value=o.catalog_cd)) OR (cnvtupper(reply->oc_list[i].
        primary_name)=cnvtupper(o.primary_mnemonic))) )
        i = tot_start_count, found = 1
       ENDIF
     ENDFOR
    ENDIF
    IF (found=0)
     FOR (i = 1 TO tot_start_count)
       IF ((slist->start_list[i].concept_cki=o.concept_cki))
        i = tot_start_count, found = 1
       ENDIF
     ENDFOR
    ENDIF
    IF (found=0)
     count = (count+ 1), listcount = (listcount+ 1)
     IF (listcount > 10)
      stat = alterlist(reply->oc_list,(count+ 10)), listcount = 1
     ENDIF
     reply->oc_list[count].catalog_code_value = o.catalog_cd, reply->oc_list[count].primary_name = o
     .primary_mnemonic, reply->oc_list[count].description = o.description,
     reply->oc_list[count].autobuild_ind = 1, reply->oc_list[count].concept_cki = o.concept_cki,
     reply->oc_list[count].procedure_type.code_value = o.bb_processing_cd
    ENDIF
   WITH skipbedrock = 1, nocounter
  ;end select
  IF (count > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = count),
     code_value cv
    PLAN (d
     WHERE (reply->oc_list[d.seq].procedure_type.code_value > 0)
      AND (reply->oc_list[d.seq].autobuild_ind=1))
     JOIN (cv
     WHERE (cv.code_value=reply->oc_list[d.seq].procedure_type.code_value))
    DETAIL
     reply->oc_list[d.seq].procedure_type.display = cv.display, reply->oc_list[d.seq].procedure_type.
     mean = cv.cdf_meaning
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->oc_list,count)
 ENDIF
 SET x = size(reply->oc_list,5)
 SET y = size(reply->client_oc_list,5)
 IF (x=0
  AND y=0)
  SET reply->status_data.status = "Z"
 ELSEIF (x > 0)
  SET reply->status_data.status = "S"
 ELSEIF (y > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
