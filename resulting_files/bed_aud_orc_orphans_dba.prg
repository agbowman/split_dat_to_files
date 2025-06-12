CREATE PROGRAM bed_aud_orc_orphans:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD temp(
   1 orclist[*]
     2 orc_cd = f8
     2 display = vc
     2 missing_oc_ind = i2
     2 missing_cv_ind = i2
     2 missing_ocs_ind = i2
     2 activity_type_cd = f8
     2 activity_type = vc
     2 catalog_type_cd = f8
     2 catalog_type = vc
 )
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Desc/Mnem/Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "catalog_cd"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Catalog Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Activity Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "No Active Order Catalog"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "No Code Set 200 Entry"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "No Active Primary Synonym"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET primary_cd = get_code_value(6011,"PRIMARY")
 SET totcnt = 0
 SELECT INTO "nl:"
  tcnt = count(*)
  FROM order_catalog
  WHERE active_ind=1
  DETAIL
   totcnt = tcnt
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (totcnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (totcnt > 15000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET ocnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   (dummyt d  WITH seq = 1),
   code_value cv
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd > 0)
   JOIN (d)
   JOIN (cv
   WHERE cv.code_value=oc.catalog_cd
    AND cv.active_ind=1)
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp->orclist,ocnt), temp->orclist[ocnt].orc_cd = oc.catalog_cd,
   temp->orclist[ocnt].display = oc.description, temp->orclist[ocnt].missing_cv_ind = 1, temp->
   orclist[ocnt].activity_type_cd = oc.activity_type_cd,
   temp->orclist[ocnt].catalog_type_cd = oc.catalog_type_cd
  WITH outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc,
   (dummyt d  WITH seq = 1),
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd > 0)
   JOIN (d)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd=primary_cd
    AND ocs.active_ind=1)
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp->orclist,ocnt), temp->orclist[ocnt].orc_cd = oc.catalog_cd,
   temp->orclist[ocnt].display = oc.description, temp->orclist[ocnt].missing_ocs_ind = 1, temp->
   orclist[ocnt].activity_type_cd = oc.activity_type_cd,
   temp->orclist[ocnt].catalog_type_cd = oc.catalog_type_cd
  WITH outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   order_catalog oc
  PLAN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=200
    AND cv.code_value > 0)
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(cv.code_value))
  DETAIL
   IF (((oc.active_ind=0) OR (oc.catalog_cd=0.0)) )
    ocnt = (ocnt+ 1), stat = alterlist(temp->orclist,ocnt), temp->orclist[ocnt].orc_cd = cv
    .code_value,
    temp->orclist[ocnt].display = cv.display, temp->orclist[ocnt].missing_oc_ind = 1, temp->orclist[
    ocnt].activity_type_cd = oc.activity_type_cd,
    temp->orclist[ocnt].catalog_type_cd = oc.catalog_type_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = 1),
   order_catalog_synonym ocs,
   order_catalog oc
  PLAN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=200
    AND cv.code_value > 0)
   JOIN (d)
   JOIN (ocs
   WHERE ocs.catalog_cd=cv.code_value
    AND ocs.mnemonic_type_cd=primary_cd
    AND ocs.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp->orclist,ocnt), temp->orclist[ocnt].orc_cd = cv.code_value,
   temp->orclist[ocnt].display = cv.display, temp->orclist[ocnt].missing_ocs_ind = 1, temp->orclist[
   ocnt].activity_type_cd = oc.activity_type_cd,
   temp->orclist[ocnt].catalog_type_cd = oc.catalog_type_cd
  WITH outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   (dummyt d  WITH seq = 1),
   code_value cv,
   order_catalog oc
  PLAN (ocs
   WHERE ocs.active_ind=1
    AND ocs.mnemonic_type_cd=primary_cd
    AND ocs.catalog_cd > 0)
   JOIN (d)
   JOIN (cv
   WHERE cv.code_value=ocs.catalog_cd
    AND cv.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp->orclist,ocnt), temp->orclist[ocnt].orc_cd = ocs
   .catalog_cd,
   temp->orclist[ocnt].display = ocs.mnemonic, temp->orclist[ocnt].missing_cv_ind = 1, temp->orclist[
   ocnt].activity_type_cd = oc.activity_type_cd,
   temp->orclist[ocnt].catalog_type_cd = oc.catalog_type_cd
  WITH outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   order_catalog oc
  PLAN (ocs
   WHERE ocs.active_ind=1
    AND ocs.mnemonic_type_cd=primary_cd
    AND ocs.catalog_cd > 0)
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(ocs.catalog_cd))
  DETAIL
   IF (((oc.active_ind=0) OR (oc.catalog_cd=0.0)) )
    ocnt = (ocnt+ 1), stat = alterlist(temp->orclist,ocnt), temp->orclist[ocnt].orc_cd = cv
    .code_value,
    temp->orclist[ocnt].display = cv.display, temp->orclist[ocnt].missing_oc_ind = 1, temp->orclist[
    ocnt].activity_type_cd = oc.activity_type_cd,
    temp->orclist[ocnt].catalog_type_cd = oc.catalog_type_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = ocnt)
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=temp->orclist[d.seq].activity_type_cd))
  ORDER BY d.seq
  DETAIL
   temp->orclist[d.seq].activity_type = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = ocnt)
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=temp->orclist[d.seq].catalog_type_cd))
  ORDER BY d.seq
  DETAIL
   temp->orclist[d.seq].catalog_type = cv.display
  WITH nocounter
 ;end select
 SET rcnt = 0
 IF (ocnt > 0)
  SELECT INTO "nl:"
   orc_cd = temp->orclist[d.seq].orc_cd
   FROM (dummyt d  WITH seq = ocnt)
   ORDER BY temp->orclist[d.seq].orc_cd
   HEAD REPORT
    rcnt = 0
   HEAD orc_cd
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,7),
    reply->rowlist[rcnt].celllist[1].string_value = temp->orclist[d.seq].display, reply->rowlist[rcnt
    ].celllist[2].double_value = temp->orclist[d.seq].orc_cd, reply->rowlist[rcnt].celllist[3].
    string_value = temp->orclist[d.seq].catalog_type,
    reply->rowlist[rcnt].celllist[4].string_value = temp->orclist[d.seq].activity_type
   DETAIL
    IF ((temp->orclist[d.seq].missing_oc_ind=1))
     reply->rowlist[rcnt].celllist[5].string_value = "X"
    ENDIF
    IF ((temp->orclist[d.seq].missing_cv_ind=1))
     reply->rowlist[rcnt].celllist[6].string_value = "X"
    ENDIF
    IF ((temp->orclist[d.seq].missing_ocs_ind=1))
     reply->rowlist[rcnt].celllist[7].string_value = "X"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (rcnt > 0)
  SET reply->run_status_flag = 3
  SET stat = alterlist(reply->statlist,1)
  SET reply->statlist[1].statistic_meaning = "ORPHANORCISSUES"
  SET reply->statlist[1].total_items = totcnt
  SET reply->statlist[1].qualifying_items = rcnt
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
  SET stat = alterlist(reply->statlist,1)
  SET reply->statlist[1].statistic_meaning = "ORPHANORCISSUES"
  SET reply->statlist[1].total_items = totcnt
  SET reply->statlist[1].qualifying_items = 0
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("orc_orphans_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
