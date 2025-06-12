CREATE PROGRAM bed_get_mltm_synonyms_by_cki:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 synonyms[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 hide_flag = i2
       3 ignore_ind = i2
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 meaning = vc
       3 mltm_synonym
         4 cki = vc
         4 mnemonic = vc
         4 hide_flag = i2
         4 mnemonic_type
           5 code_value = f8
           5 display = vc
           5 meaning = vc
       3 facilities[*]
         4 code_value = f8
         4 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE primary = f8
 SET primary = 0.0
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET sub_cnt = 0
 SET list_cnt = 0
 SET tot_cnt = 0
 SET primary_flag = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
   AND cv.active_ind=1
  DETAIL
   primary = cv.code_value
  WITH nocoutner
 ;end select
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 IF ((request->return_ignored_ind=1))
  SELECT INTO "nl:"
   FROM mltm_order_catalog_load m,
    order_catalog_synonym ocs,
    code_value cv,
    br_name_value b,
    order_catalog oc,
    code_value cv2
   PLAN (m)
    JOIN (ocs
    WHERE ocs.cki=m.synonym_cki
     AND ((trim(ocs.concept_cki)=m.synonym_concept_cki
     AND ocs.concept_cki > " ") OR (trim(ocs.concept_cki) IN ("", " ", null)
     AND m.synonym_concept_cki IN ("", " ", null)))
     AND ocs.active_ind=1
     AND ocs.mnemonic_type_cd != dcp_code_value)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=oc.catalog_cd
     AND cv2.code_set=200
     AND cv2.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
    JOIN (b
    WHERE b.br_nv_key1=outerjoin("MLTM_IGN_SYN")
     AND b.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
     AND b.br_value=outerjoin(cnvtstring(ocs.synonym_id)))
   ORDER BY ocs.catalog_cd, ocs.synonym_id
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->orderables,200),
    match_ind = 1
   HEAD ocs.catalog_cd
    sub_cnt = 0, list_cnt = 0
    IF (match_ind=1)
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (tot_cnt > 200)
      stat = alterlist(reply->orderables,(cnt+ 200)), tot_cnt = 1
     ENDIF
    ELSE
     stat = alterlist(reply->orderables[cnt].synonyms,0)
    ENDIF
    reply->orderables[cnt].code_value = ocs.catalog_cd, stat = alterlist(reply->orderables[cnt].
     synonyms,200), match_ind = 0
   HEAD ocs.synonym_id
    mt_mismatch_ind = 0
    IF (((m.mnemonic_type_mean > " "
     AND cv.cdf_meaning != m.mnemonic_type_mean) OR (m.mnemonic_type_mean IN ("", " ", null)
     AND cnvtupper(cv.display) != cnvtupper(m.mnemonic_type))) )
     mt_mismatch_ind = 1
    ENDIF
    IF (((cnvtupper(ocs.mnemonic) != cnvtupper(m.mnemonic)) OR (((ocs.hide_flag != m.hide_ind) OR (
    mt_mismatch_ind=1)) )) )
     IF (((cnvtupper(ocs.mnemonic)=cnvtupper(m.mnemonic)
      AND mt_mismatch_ind=0
      AND ocs.hide_flag=1) OR (cnvtupper(ocs.mnemonic) != cnvtupper(m.mnemonic)
      AND mt_mismatch_ind=0
      AND ((ocs.hide_flag=1) OR (ocs.hide_flag=m.hide_ind))
      AND textlen(trim(m.mnemonic)) > 100)) )
      sub_cnt = sub_cnt
     ELSE
      sub_cnt = (sub_cnt+ 1), list_cnt = (list_cnt+ 1)
      IF (list_cnt > 200)
       stat = alterlist(reply->orderables[cnt].synonyms,(sub_cnt+ 200)), list_cnt = 1
      ENDIF
      reply->orderables[cnt].synonyms[sub_cnt].synonym_id = ocs.synonym_id, reply->orderables[cnt].
      synonyms[sub_cnt].mnemonic = ocs.mnemonic, reply->orderables[cnt].synonyms[sub_cnt].hide_flag
       = ocs.hide_flag,
      reply->orderables[cnt].synonyms[sub_cnt].mnemonic_type.code_value = ocs.mnemonic_type_cd
      IF (b.br_name_value_id > 0)
       reply->orderables[cnt].synonyms[sub_cnt].ignore_ind = 1
      ENDIF
      reply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.cki = m.synonym_cki, reply->orderables[
      cnt].synonyms[sub_cnt].mltm_synonym.mnemonic_type.display = m.mnemonic_type, reply->orderables[
      cnt].synonyms[sub_cnt].mltm_synonym.mnemonic_type.meaning = m.mnemonic_type_mean,
      reply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.hide_flag = m.hide_ind, reply->
      orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic = m.mnemonic, match_ind = 1
     ENDIF
    ENDIF
   FOOT  ocs.catalog_cd
    stat = alterlist(reply->orderables[cnt].synonyms,sub_cnt)
   FOOT REPORT
    IF (cnt > 0
     AND match_ind=0)
     stat = alterlist(reply->orderables,(cnt - 1)), cnt = (cnt - 1)
    ELSE
     stat = alterlist(reply->orderables,cnt)
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM mltm_order_catalog_load m,
    order_catalog_synonym ocs,
    code_value cv,
    br_name_value b,
    order_catalog oc,
    code_value cv2
   PLAN (m)
    JOIN (ocs
    WHERE ocs.cki=m.synonym_cki
     AND ((trim(ocs.concept_cki)=m.synonym_concept_cki
     AND ocs.concept_cki > " ") OR (trim(ocs.concept_cki) IN ("", " ", null)
     AND m.synonym_concept_cki IN ("", " ", null)))
     AND ocs.active_ind=1
     AND ocs.mnemonic_type_cd != dcp_code_value)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=oc.catalog_cd
     AND cv2.code_set=200
     AND cv2.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
    JOIN (b
    WHERE b.br_nv_key1=outerjoin("MLTM_IGN_SYN")
     AND b.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
     AND b.br_value=outerjoin(cnvtstring(ocs.synonym_id)))
   ORDER BY ocs.catalog_cd, ocs.synonym_id
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->orderables,200),
    match_ind = 1
   HEAD ocs.catalog_cd
    sub_cnt = 0, list_cnt = 0
    IF (match_ind=1)
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (tot_cnt > 200)
      stat = alterlist(reply->orderables,(cnt+ 200)), tot_cnt = 1
     ENDIF
    ELSE
     stat = alterlist(reply->orderables[cnt].synonyms,0)
    ENDIF
    reply->orderables[cnt].code_value = ocs.catalog_cd, stat = alterlist(reply->orderables[cnt].
     synonyms,200), match_ind = 0
   HEAD ocs.synonym_id
    mt_mismatch_ind = 0
    IF (((m.mnemonic_type_mean > " "
     AND cv.cdf_meaning != m.mnemonic_type_mean) OR (m.mnemonic_type_mean IN ("", " ", null)
     AND cnvtupper(cv.display) != cnvtupper(m.mnemonic_type))) )
     mt_mismatch_ind = 1
    ENDIF
    IF (((cnvtupper(ocs.mnemonic) != cnvtupper(m.mnemonic)) OR (((ocs.hide_flag != m.hide_ind) OR (
    mt_mismatch_ind=1)) ))
     AND b.br_name_value_id=0)
     IF (((cnvtupper(ocs.mnemonic)=cnvtupper(m.mnemonic)
      AND mt_mismatch_ind=0
      AND ocs.hide_flag=1) OR (cnvtupper(ocs.mnemonic) != cnvtupper(m.mnemonic)
      AND mt_mismatch_ind=0
      AND ((ocs.hide_flag=1) OR (ocs.hide_flag=m.hide_ind))
      AND textlen(trim(m.mnemonic)) > 100)) )
      sub_cnt = sub_cnt
     ELSE
      sub_cnt = (sub_cnt+ 1), list_cnt = (list_cnt+ 1)
      IF (list_cnt > 200)
       stat = alterlist(reply->orderables[cnt].synonyms,(sub_cnt+ 200)), list_cnt = 1
      ENDIF
      reply->orderables[cnt].synonyms[sub_cnt].synonym_id = ocs.synonym_id, reply->orderables[cnt].
      synonyms[sub_cnt].mnemonic = ocs.mnemonic, reply->orderables[cnt].synonyms[sub_cnt].hide_flag
       = ocs.hide_flag,
      reply->orderables[cnt].synonyms[sub_cnt].mnemonic_type.code_value = ocs.mnemonic_type_cd, reply
      ->orderables[cnt].synonyms[sub_cnt].mltm_synonym.cki = m.synonym_cki, reply->orderables[cnt].
      synonyms[sub_cnt].mltm_synonym.mnemonic_type.display = m.mnemonic_type,
      reply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic_type.meaning = m
      .mnemonic_type_mean, reply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.hide_flag = m
      .hide_ind, reply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic = m.mnemonic,
      match_ind = 1
     ENDIF
    ENDIF
   FOOT  ocs.catalog_cd
    stat = alterlist(reply->orderables[cnt].synonyms,sub_cnt)
   FOOT REPORT
    IF (cnt > 0
     AND match_ind=0)
     stat = alterlist(reply->orderables,(cnt - 1)), cnt = (cnt - 1)
    ELSE
     stat = alterlist(reply->orderables,cnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt > 0)
  FOR (x = 1 TO cnt)
    SET list_cnt = size(reply->orderables[x].synonyms,5)
    SET primary_flag = 0
    IF (list_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = list_cnt),
       code_value cv
      PLAN (d
       WHERE (reply->orderables[x].synonyms[d.seq].mltm_synonym.mnemonic_type.meaning > " "))
       JOIN (cv
       WHERE (cv.cdf_meaning=reply->orderables[x].synonyms[d.seq].mltm_synonym.mnemonic_type.meaning)
        AND cv.code_set=6011
        AND cv.active_ind=1)
      ORDER BY d.seq
      DETAIL
       reply->orderables[x].synonyms[d.seq].mltm_synonym.mnemonic_type.code_value = cv.code_value,
       reply->orderables[x].synonyms[d.seq].mltm_synonym.mnemonic_type.meaning = cv.cdf_meaning,
       reply->orderables[x].synonyms[d.seq].mltm_synonym.mnemonic_type.display = cv.display
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = list_cnt),
       code_value cv
      PLAN (d
       WHERE (reply->orderables[x].synonyms[d.seq].mltm_synonym.mnemonic_type.meaning IN ("", " ",
       null)))
       JOIN (cv
       WHERE cnvtupper(cv.display)=cnvtupper(reply->orderables[x].synonyms[d.seq].mltm_synonym.
        mnemonic_type.display)
        AND cv.code_set=6011
        AND cv.active_ind=1)
      ORDER BY d.seq
      DETAIL
       reply->orderables[x].synonyms[d.seq].mltm_synonym.mnemonic_type.code_value = cv.code_value,
       reply->orderables[x].synonyms[d.seq].mltm_synonym.mnemonic_type.meaning = cv.cdf_meaning
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = list_cnt),
       code_value cv
      PLAN (d)
       JOIN (cv
       WHERE (cv.code_value=reply->orderables[x].synonyms[d.seq].mnemonic_type.code_value)
        AND cv.active_ind=1)
      ORDER BY d.seq
      DETAIL
       reply->orderables[x].synonyms[d.seq].mnemonic_type.display = cv.display, reply->orderables[x].
       synonyms[d.seq].mnemonic_type.meaning = cv.cdf_meaning
       IF (cv.code_value=primary)
        primary_flag = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (primary_flag=0)
      SELECT INTO "nl:"
       FROM order_catalog_synonym ocs,
        code_value cv
       PLAN (ocs
        WHERE (ocs.catalog_cd=reply->orderables[x].code_value)
         AND ocs.mnemonic_type_cd=primary)
        JOIN (cv
        WHERE cv.code_value=ocs.mnemonic_type_cd
         AND cv.active_ind=1)
       DETAIL
        list_cnt = (list_cnt+ 1), stat = alterlist(reply->orderables[x].synonyms,list_cnt), reply->
        orderables[x].synonyms[list_cnt].synonym_id = ocs.synonym_id,
        reply->orderables[x].synonyms[list_cnt].hide_flag = ocs.hide_flag, reply->orderables[x].
        synonyms[list_cnt].mnemonic = ocs.mnemonic, reply->orderables[x].synonyms[list_cnt].
        mnemonic_type.code_value = ocs.mnemonic_type_cd,
        reply->orderables[x].synonyms[list_cnt].mnemonic_type.display = cv.display, reply->
        orderables[x].synonyms[list_cnt].mnemonic_type.meaning = cv.cdf_meaning
       WITH nocoutner
      ;end select
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(list_cnt)),
       ocs_facility_r o,
       code_value cv
      PLAN (d)
       JOIN (o
       WHERE (o.synonym_id=reply->orderables[x].synonyms[d.seq].synonym_id))
       JOIN (cv
       WHERE cv.code_value=outerjoin(o.facility_cd)
        AND cv.active_ind=outerjoin(1))
      ORDER BY d.seq, cv.code_value
      HEAD d.seq
       fcnt = 0, ftcnt = 0, stat = alterlist(reply->orderables[x].synonyms[d.seq].facilities,100)
      HEAD cv.code_value
       IF (((cv.code_value > 0
        AND o.facility_cd > 0) OR (o.facility_cd=0)) )
        fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
        IF (fcnt > 100)
         stat = alterlist(reply->orderables[x].synonyms[d.seq].facilities,(ftcnt+ 100)), fcnt = 1
        ENDIF
        reply->orderables[x].synonyms[d.seq].facilities[ftcnt].code_value = cv.code_value, reply->
        orderables[x].synonyms[d.seq].facilities[ftcnt].display = trim(cv.display)
       ENDIF
      FOOT  d.seq
       stat = alterlist(reply->orderables[x].synonyms[d.seq].facilities,ftcnt)
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
