CREATE PROGRAM bed_get_mltm_syns_by_cki:dba
 IF ( NOT (validate(reply,0)))
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
    1 more_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE primary = f8
 DECLARE primary_dec = vc
 SET cnt = 0
 SET sub_cnt = 0
 SET list_cnt = 0
 SET tot_cnt = 0
 SET primary_flag = 0
 SET max_rep_cut = 0
 SET primary = 0.0
 SET primary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 DECLARE primary_parse = vc
 SET primary_parse =
 "ocs2.catalog_cd = ocs.catalog_cd and ocs2.mnemonic_type_cd = primary and ocs2.active_ind = 1"
 IF ((request->orderable_code_value > 0))
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs
   WHERE (ocs.catalog_cd=request->orderable_code_value)
    AND ocs.mnemonic_type_cd=primary
    AND ocs.active_ind=1
   HEAD REPORT
    primary_parse = concat(primary_parse," and cnvtupper(ocs2.mnemonic) > '",cnvtupper(ocs.mnemonic),
     "'")
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load m,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   code_value cv,
   br_name_value b,
   order_catalog oc,
   code_value cv2,
   code_value cv3,
   code_value cv4
  PLAN (m)
   JOIN (ocs
   WHERE ocs.cki=m.synonym_cki
    AND ((trim(ocs.concept_cki)=m.synonym_concept_cki
    AND trim(ocs.concept_cki) > " ") OR (trim(ocs.concept_cki) IN ("", " ", null)
    AND trim(m.synonym_concept_cki) IN ("", " ", null)))
    AND ocs.active_ind=1
    AND ocs.mnemonic_type_cd != dcp_code_value)
   JOIN (ocs2
   WHERE parser(primary_parse))
   JOIN (cv3
   WHERE cv3.code_value=ocs2.mnemonic_type_cd
    AND cv3.active_ind=1)
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
   JOIN (cv4
   WHERE cv4.code_set=6011
    AND cv4.active_ind=1
    AND ((cv4.cdf_meaning=m.mnemonic_type_mean
    AND m.mnemonic_type_mean > " ") OR (cnvtupper(cv4.display)=cnvtupper(m.mnemonic_type)
    AND m.mnemonic_type_mean IN ("", " ", null))) )
   JOIN (b
   WHERE b.br_nv_key1=outerjoin("MLTM_IGN_SYN")
    AND b.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
    AND b.br_value=outerjoin(cnvtstring(ocs.synonym_id)))
  ORDER BY cnvtupper(ocs2.mnemonic), ocs.catalog_cd, cnvtupper(ocs.mnemonic),
   ocs.synonym_id
  HEAD REPORT
   cnt = 0, tot_cnt = 0, sub_cnt = 0,
   list_cnt = 0, stat = alterlist(reply->orderables,200), match_ind = 1,
   skip_ind = 0, total_count = 0, primary_ind = 0
  HEAD ocs.catalog_cd
   IF ((total_count > request->max_reply)
    AND (request->max_reply > 0)
    AND max_rep_cut=0)
    max_rep_cut = cnt
   ENDIF
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
    synonyms,200), match_ind = 0,
   primary_ind = 0
  HEAD ocs.synonym_id
   IF ((((request->return_ignored_ind=1)) OR (b.br_name_value_id=0.0)) )
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
      cnt].synonyms[sub_cnt].mltm_synonym.mnemonic_type.display = cv4.display, reply->orderables[cnt]
      .synonyms[sub_cnt].mltm_synonym.mnemonic_type.meaning = cv4.cdf_meaning,
      reply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic_type.code_value = cv4.code_value,
      reply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.hide_flag = m.hide_ind, reply->
      orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic = m.mnemonic,
      reply->orderables[cnt].synonyms[sub_cnt].mnemonic_type.meaning = cv.cdf_meaning, reply->
      orderables[cnt].synonyms[sub_cnt].mnemonic_type.display = cv.display, match_ind = 1,
      total_count = (total_count+ 1)
      IF (ocs.mnemonic_type_cd=primary)
       primary_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  ocs.catalog_cd
   stat = alterlist(reply->orderables[cnt].synonyms,sub_cnt)
   IF (primary_ind=0)
    sub_cnt = (sub_cnt+ 1), stat = alterlist(reply->orderables[cnt].synonyms,sub_cnt), reply->
    orderables[cnt].synonyms[sub_cnt].synonym_id = ocs2.synonym_id,
    reply->orderables[cnt].synonyms[sub_cnt].mnemonic = ocs2.mnemonic, reply->orderables[cnt].
    synonyms[sub_cnt].hide_flag = ocs2.hide_flag, reply->orderables[cnt].synonyms[sub_cnt].
    mnemonic_type.code_value = ocs2.mnemonic_type_cd,
    reply->orderables[cnt].synonyms[sub_cnt].mnemonic_type.meaning = cv3.cdf_meaning, reply->
    orderables[cnt].synonyms[sub_cnt].mnemonic_type.display = cv3.display
   ENDIF
  FOOT REPORT
   IF (cnt > 0
    AND match_ind=0)
    stat = alterlist(reply->orderables,(cnt - 1)), cnt = (cnt - 1)
   ELSE
    stat = alterlist(reply->orderables,cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (max_rep_cut > 0
  AND cnt > max_rep_cut)
  SET stat = alterlist(reply->orderables,max_rep_cut)
  SET reply->more_ind = 1
  SET cnt = max_rep_cut
 ENDIF
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    (dummyt d2  WITH seq = 1),
    ocs_facility_r o,
    code_value cv
   PLAN (d
    WHERE maxrec(d2,size(reply->orderables[d.seq].synonyms,5)))
    JOIN (d2)
    JOIN (o
    WHERE (o.synonym_id=reply->orderables[d.seq].synonyms[d2.seq].synonym_id))
    JOIN (cv
    WHERE cv.code_value=outerjoin(o.facility_cd)
     AND cv.active_ind=outerjoin(1))
   ORDER BY d.seq, d2.seq, cv.code_value
   HEAD d.seq
    fcnt = 0
   HEAD d2.seq
    fcnt = 0, ftcnt = 0, stat = alterlist(reply->orderables[d.seq].synonyms[d2.seq].facilities,100)
   HEAD cv.code_value
    IF (((cv.code_value > 0
     AND o.facility_cd > 0) OR (o.facility_cd=0)) )
     fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
     IF (fcnt > 100)
      stat = alterlist(reply->orderables[d.seq].synonyms[d2.seq].facilities,(ftcnt+ 100)), fcnt = 1
     ENDIF
     reply->orderables[d.seq].synonyms[d2.seq].facilities[ftcnt].code_value = cv.code_value, reply->
     orderables[d.seq].synonyms[d2.seq].facilities[ftcnt].display = trim(cv.display)
    ENDIF
   FOOT  d2.seq
    stat = alterlist(reply->orderables[d.seq].synonyms[d2.seq].facilities,ftcnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
