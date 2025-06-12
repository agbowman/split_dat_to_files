CREATE PROGRAM bed_get_pwrform_cern_codes:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 codes[*]
      2 uid = vc
      2 display = vc
      2 mean = vc
      2 code_set = i4
      2 name = vc
      2 assay_desc = vc
      2 assay_uid = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 SET acnt = 0
 SET ccnt = 0
 FREE SET temp
 RECORD temp(
   1 codes[*]
     2 uid = vc
     2 cs = i4
     2 disp = vc
     2 mean = vc
     2 cd = f8
     2 assay_desc = vc
     2 task_assay_uid = vc
 )
 SET acnt = size(request->assays,5)
 IF (acnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(acnt)),
   cnt_dta c,
   cnt_dta_rrf_r rr,
   cnt_rrf_key k,
   cnt_rrf rrf,
   cnt_rrf_ar_r r,
   cnt_alpha_response_key ark,
   cnt_alpha_response ar
  PLAN (d)
   JOIN (c
   WHERE (c.task_assay_uid=request->assays[d.seq].task_assay_uid))
   JOIN (rr
   WHERE rr.task_assay_uid=outerjoin(c.task_assay_uid))
   JOIN (k
   WHERE k.rrf_uid=outerjoin(rr.rrf_uid))
   JOIN (rrf
   WHERE rrf.rrf_uid=outerjoin(k.rrf_uid))
   JOIN (r
   WHERE r.rrf_uid=outerjoin(k.rrf_uid))
   JOIN (ark
   WHERE ark.ar_uid=outerjoin(r.ar_uid))
   JOIN (ar
   WHERE ar.ar_uid=outerjoin(ark.ar_uid))
  ORDER BY d.seq
  DETAIL
   IF (c.activity_type_cd=0)
    found = 0
    FOR (z = 1 TO ccnt)
      IF ((temp->codes[z].uid=c.activity_type_cduid)
       AND (temp->codes[z].task_assay_uid=c.task_assay_uid))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     ccnt = (ccnt+ 1), stat = alterlist(temp->codes,ccnt), temp->codes[ccnt].uid = c
     .activity_type_cduid,
     temp->codes[ccnt].assay_desc = c.description, temp->codes[ccnt].task_assay_uid = c
     .task_assay_uid
    ENDIF
   ENDIF
   IF (k.age_from_units_cd=0)
    found = 0
    FOR (z = 1 TO ccnt)
      IF ((temp->codes[z].uid=k.age_from_units_cduid)
       AND (temp->codes[z].task_assay_uid=c.task_assay_uid))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     ccnt = (ccnt+ 1), stat = alterlist(temp->codes,ccnt), temp->codes[ccnt].uid = k
     .age_from_units_cduid,
     temp->codes[ccnt].assay_desc = c.description, temp->codes[ccnt].task_assay_uid = c
     .task_assay_uid
    ENDIF
   ENDIF
   IF (k.age_to_units_cd=0)
    found = 0
    FOR (z = 1 TO ccnt)
      IF ((temp->codes[z].uid=k.age_to_units_cduid)
       AND (temp->codes[z].task_assay_uid=c.task_assay_uid))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     ccnt = (ccnt+ 1), stat = alterlist(temp->codes,ccnt), temp->codes[ccnt].uid = k
     .age_to_units_cduid,
     temp->codes[ccnt].assay_desc = c.description, temp->codes[ccnt].task_assay_uid = c
     .task_assay_uid
    ENDIF
   ENDIF
   IF (rrf.units_cd=0)
    found = 0
    FOR (z = 1 TO ccnt)
      IF ((temp->codes[z].uid=rrf.units_cduid)
       AND (temp->codes[z].task_assay_uid=c.task_assay_uid))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     ccnt = (ccnt+ 1), stat = alterlist(temp->codes,ccnt), temp->codes[ccnt].uid = rrf.units_cduid,
     temp->codes[ccnt].assay_desc = c.description, temp->codes[ccnt].task_assay_uid = c
     .task_assay_uid
    ENDIF
   ENDIF
   IF (ark.principle_type_cd=0)
    found = 0
    FOR (z = 1 TO ccnt)
      IF ((temp->codes[z].uid=ark.principle_type_cduid)
       AND (temp->codes[z].task_assay_uid=c.task_assay_uid))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     ccnt = (ccnt+ 1), stat = alterlist(temp->codes,ccnt), temp->codes[ccnt].uid = ark
     .principle_type_cduid,
     temp->codes[ccnt].assay_desc = c.description, temp->codes[ccnt].task_assay_uid = c
     .task_assay_uid
    ENDIF
   ENDIF
   IF (ark.source_vocabulary_cd=0)
    found = 0
    FOR (z = 1 TO ccnt)
      IF ((temp->codes[z].uid=ark.source_vocabulary_cduid)
       AND (temp->codes[z].task_assay_uid=c.task_assay_uid))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     ccnt = (ccnt+ 1), stat = alterlist(temp->codes,ccnt), temp->codes[ccnt].uid = ark
     .source_vocabulary_cduid,
     temp->codes[ccnt].assay_desc = c.description, temp->codes[ccnt].task_assay_uid = c
     .task_assay_uid
    ENDIF
   ENDIF
   IF (ar.contributor_system_cd=0)
    found = 0
    FOR (z = 1 TO ccnt)
      IF ((temp->codes[z].uid=ar.contributor_system_cduid)
       AND (temp->codes[z].task_assay_uid=c.task_assay_uid))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     ccnt = (ccnt+ 1), stat = alterlist(temp->codes,ccnt), temp->codes[ccnt].uid = ar
     .contributor_system_cduid,
     temp->codes[ccnt].assay_desc = c.description, temp->codes[ccnt].task_assay_uid = c
     .task_assay_uid
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ccnt = size(temp->codes,5)
 IF (ccnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    cnt_code_value_key c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value_uid=temp->codes[d.seq].uid))
   HEAD d.seq
    temp->codes[d.seq].cs = c.code_set, temp->codes[d.seq].disp = c.display, temp->codes[d.seq].mean
     = c.cdf_meaning,
    temp->codes[d.seq].cd = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(temp)
 SET rcnt = 0
 FOR (y = 1 TO ccnt)
   IF ((temp->codes[y].uid > " ")
    AND (temp->codes[y].cd=0.0))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->codes,rcnt)
    SET reply->codes[rcnt].uid = temp->codes[y].uid
    SET reply->codes[rcnt].display = temp->codes[y].disp
    SET reply->codes[rcnt].mean = temp->codes[y].mean
    SET reply->codes[rcnt].code_set = temp->codes[y].cs
    SET reply->codes[rcnt].assay_desc = temp->codes[y].assay_desc
    SET reply->codes[rcnt].assay_uid = temp->codes[y].task_assay_uid
   ENDIF
 ENDFOR
 IF (rcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rcnt)),
    code_value_set c
   PLAN (d)
    JOIN (c
    WHERE (c.code_set=reply->codes[d.seq].code_set))
   ORDER BY d.seq
   HEAD d.seq
    reply->codes[d.seq].name = c.display
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
