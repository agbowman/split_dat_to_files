CREATE PROGRAM bed_get_oc_virtual_views:dba
 FREE SET reply
 RECORD reply(
   1 fac_list[*]
     2 facility_ind = c1
     2 flist[*]
       3 facility_cd = f8
       3 facility_display = c40
       3 facility_description = c60
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD syn(
   1 slist[*]
     2 synonym_id = f8
 )
 RECORD facsfirstsyn(
   1 list[*]
     2 facility_cd = f8
     2 facility_display = c40
     2 facility_description = c60
 )
 RECORD facs(
   1 flist[*]
     2 facility_cd = f8
     2 facility_display = c40
     2 facility_description = c60
 )
 SET reply->status_data.status = "F"
 SET icnt = 0
 SET icnt = size(request->id_list,5)
 IF (icnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->fac_list,icnt)
 IF ((request->id_list[1].id_type="O"))
  FOR (i = 1 TO icnt)
    SET stat = alterlist(syn->slist,10)
    SET alterlistcnt = 0
    SET scnt = 0
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs
     WHERE (ocs.catalog_cd=request->id_list[i].id)
      AND ocs.synonym_id > 0
     DETAIL
      alterlistcnt = (alterlistcnt+ 1)
      IF (alterlistcnt > 10)
       stat = alterlist(syn->slist,(scnt+ 10)), alterlistcnt = 1
      ENDIF
      scnt = (scnt+ 1), syn->slist[scnt].synonym_id = ocs.synonym_id
     WITH nocounter
    ;end select
    IF (scnt=0)
     GO TO exit_script
    ENDIF
    SET stat = alterlist(facsfirstsyn->list,10)
    SET alterlistcnt = 0
    SET firstsynfcnt = 0
    SELECT INTO "NL:"
     FROM ocs_facility_r ofr,
      code_value cv
     PLAN (ofr
      WHERE (ofr.synonym_id=syn->slist[1].synonym_id))
      JOIN (cv
      WHERE cv.code_value=outerjoin(ofr.facility_cd))
     ORDER BY ofr.facility_cd
     DETAIL
      alterlistcnt = (alterlistcnt+ 1)
      IF (alterlistcnt > 10)
       stat = alterlist(facsfirstsyn->list,(firstsynfcnt+ 10)), alterlistcnt = 1
      ENDIF
      firstsynfcnt = (firstsynfcnt+ 1), facsfirstsyn->list[firstsynfcnt].facility_cd = ofr
      .facility_cd
      IF ((facsfirstsyn->list[firstsynfcnt].facility_cd > 0))
       facsfirstsyn->list[firstsynfcnt].facility_display = cv.display, facsfirstsyn->list[
       firstsynfcnt].facility_description = cv.description
      ENDIF
     WITH nocounter
    ;end select
    IF (firstsynfcnt=0)
     SET number_rows = 0
     IF (scnt > 0)
      SELECT INTO "NL:"
       FROM (dummyt d  WITH seq = scnt),
        ocs_facility_r ofr
       PLAN (d)
        JOIN (ofr
        WHERE (ofr.synonym_id=syn->slist[d.seq].synonym_id))
       DETAIL
        number_rows = (number_rows+ 1)
       WITH nocounter
      ;end select
     ENDIF
     IF (number_rows=0)
      SET reply->fac_list[i].facility_ind = "N"
     ELSE
      SET reply->fac_list[i].facility_ind = "X"
     ENDIF
    ELSEIF ((facsfirstsyn->list[1].facility_cd=0))
     SET number_rows = 0
     IF (scnt > 0)
      SELECT INTO "NL:"
       FROM (dummyt d  WITH seq = scnt),
        ocs_facility_r ofr
       PLAN (d)
        JOIN (ofr
        WHERE (ofr.synonym_id=syn->slist[d.seq].synonym_id)
         AND ofr.facility_cd=0.0)
       DETAIL
        number_rows = (number_rows+ 1)
       WITH nocounter
      ;end select
     ENDIF
     IF (number_rows=scnt)
      SET reply->fac_list[i].facility_ind = "A"
     ELSE
      SET reply->fac_list[i].facility_ind = "X"
     ENDIF
    ELSE
     SET all_match = 1
     FOR (s = 2 TO scnt)
       SET stat = alterlist(facs->flist,10)
       SET alterlistcnt = 0
       SET fcnt = 0
       SELECT INTO "NL:"
        FROM ocs_facility_r ofr
        WHERE (ofr.synonym_id=syn->slist[s].synonym_id)
        ORDER BY ofr.facility_cd
        DETAIL
         alterlistcnt = (alterlistcnt+ 1)
         IF (alterlistcnt > 10)
          stat = alterlist(facs->flist,(fcnt+ 10)), alterlistcnt = 1
         ENDIF
         fcnt = (fcnt+ 1), facs->flist[fcnt].facility_cd = ofr.facility_cd
        WITH nocounter
       ;end select
       IF (fcnt != firstsynfcnt)
        SET all_match = 0
        SET s = (scnt+ 1)
       ELSE
        IF (fcnt > 0)
         SELECT INTO "NL:"
          FROM (dummyt d  WITH seq = fcnt)
          PLAN (d
           WHERE (facsfirstsyn->list[d.seq].facility_cd > 0)
            AND (facsfirstsyn->list[d.seq].facility_cd != facs->flist[d.seq].facility_cd))
          WITH nocounter
         ;end select
         IF (curqual > 0)
          SET all_match = 0
         ENDIF
        ENDIF
        IF (all_match=0)
         SET s = (scnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
     IF (all_match=1)
      SET reply->fac_list[i].facility_ind = "L"
      SET stat = alterlist(reply->fac_list[i].flist,firstsynfcnt)
      FOR (f = 1 TO firstsynfcnt)
        SET reply->fac_list[i].flist[f].facility_cd = facsfirstsyn->list[f].facility_cd
        SET reply->fac_list[i].flist[f].facility_display = facsfirstsyn->list[f].facility_display
        SET reply->fac_list[i].flist[f].facility_description = facsfirstsyn->list[f].
        facility_description
      ENDFOR
     ELSE
      SET reply->fac_list[i].facility_ind = "X"
     ENDIF
    ENDIF
  ENDFOR
 ELSEIF ((request->id_list[1].id_type="S"))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = icnt),
    order_catalog_synonym ocs,
    ocs_facility_r ofr,
    code_value cv
   PLAN (d
    WHERE (request->id_list[d.seq].id > 0))
    JOIN (ocs
    WHERE (ocs.synonym_id=request->id_list[d.seq].id))
    JOIN (ofr
    WHERE ofr.synonym_id=ocs.synonym_id)
    JOIN (cv
    WHERE cv.code_value=outerjoin(ofr.facility_cd))
   HEAD d.seq
    stat = alterlist(reply->fac_list[d.seq].flist,10), alterlistcnt = 0, fcnt = 0
   DETAIL
    alterlistcnt = (alterlistcnt+ 1)
    IF (alterlistcnt > 10)
     stat = alterlist(reply->fac_list[d.seq].flist,(fcnt+ 10)), alterlistcnt = 1
    ENDIF
    fcnt = (fcnt+ 1), reply->fac_list[d.seq].flist[fcnt].facility_cd = ofr.facility_cd
    IF ((reply->fac_list[d.seq].flist[fcnt].facility_cd > 0))
     reply->fac_list[d.seq].flist[fcnt].facility_display = cv.display, reply->fac_list[d.seq].flist[
     fcnt].facility_description = cv.description
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->fac_list[d.seq].flist,fcnt)
    IF ((reply->fac_list[d.seq].flist[1].facility_cd=0))
     reply->fac_list[d.seq].facility_ind = "A"
    ELSE
     reply->fac_list[d.seq].facility_ind = "L"
    ENDIF
   WITH nocounter
  ;end select
  FOR (x = 1 TO icnt)
    IF ((reply->fac_list[x].facility_ind IN (" ", null)))
     SET fcnt = size(reply->fac_list[x],5)
     IF (((fcnt=0) OR ((reply->fac_list[x].flist[1].facility_cd IN (0, null)))) )
      SET reply->fac_list[x].facility_ind = "N"
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
