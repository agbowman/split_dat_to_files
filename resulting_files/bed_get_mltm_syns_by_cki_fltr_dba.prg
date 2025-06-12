CREATE PROGRAM bed_get_mltm_syns_by_cki_fltr:dba
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
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tempreply(
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
       3 load_ind = i2
       3 added_parent = i2
 )
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
 DECLARE primary = f8 WITH protect, noconstant(0.0)
 DECLARE dcp_code_value = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE sub_cnt = i4 WITH protect, noconstant(0)
 DECLARE list_cnt = i4 WITH protect, noconstant(0)
 DECLARE tot_cnt = i4 WITH protect, noconstant(0)
 DECLARE synonym_cnt = i4 WITH protect, noconstant(0)
 DECLARE facilitiessize = i4 WITH protect, noconstant(0)
 DECLARE synonymtypessize = i2 WITH protect, noconstant(0)
 DECLARE oefssize = i2 WITH protect, noconstant(0)
 DECLARE cnt1 = i4 WITH protect, noconstant(0)
 DECLARE cnt2 = i4 WITH protect, noconstant(0)
 DECLARE cnt3 = i4 WITH protect, noconstant(0)
 DECLARE singleq_psn = i4 WITH protect, noconstant(0)
 DECLARE doubleq_psn = i4 WITH protect, noconstant(0)
 SET primary = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 DECLARE ocs_parse = vc
 SET ocs_parse = build(" ocs.active_ind = 1 ")
 IF ((request->show_all_ind=0))
  IF ((request->mnemonic_search_string > " "))
   DECLARE search_string = vc
   DECLARE mnemonic_search = vc
   DECLARE wcard = vc
   DECLARE len = i4
   SET wcard = "*"
   SET mnemonic_search = trim(cnvtupper(request->mnemonic_search_string))
   SET singleq_psn = findstring("'",mnemonic_search,1)
   SET doubleq_psn = findstring(char(34),mnemonic_search,1)
   IF ((request->mnemonic_search_type_flag="S"))
    SET len = (size(mnemonic_search)+ 1)
    SET search_string = concat(mnemonic_search,wcard)
   ELSE
    SET len = size(mnemonic_search)
    SET search_string = concat(wcard,mnemonic_search,wcard)
   ENDIF
   IF (singleq_psn > 0
    AND doubleq_psn=0)
    SET ocs_parse = concat(ocs_parse,' and trim(cnvtupper(ocs.mnemonic)) = "',search_string,'"')
   ELSEIF (singleq_psn=0
    AND doubleq_psn > 0)
    SET ocs_parse = concat(ocs_parse," and trim(cnvtupper(ocs.mnemonic)) = '",search_string,"'")
   ELSEIF (singleq_psn > 0
    AND doubleq_psn > 0)
    IF ((request->mnemonic_search_type_flag="C"))
     SET ocs_parse = concat(ocs_parse," and ",build2(
       "operator(cnvtupper(ocs.mnemonic), 'regexplike',patstring(@",build(len),":",mnemonic_search,
       "@, 1))"))
    ELSE
     SET ocs_parse = concat(ocs_parse," and ",build2(
       "operator(cnvtupper(ocs.mnemonic), 'like',patstring(@",build(len),":",mnemonic_search,
       "*@, 1))"))
    ENDIF
   ELSE
    SET ocs_parse = concat(ocs_parse,' and trim(cnvtupper(ocs.mnemonic)) = "',search_string,'"')
   ENDIF
   CALL echo(ocs_parse)
  ENDIF
  SET synonymtypessize = size(request->synonyms,5)
  IF (synonymtypessize > 0)
   SET ocs_parse = concat(ocs_parse," and ocs.mnemonic_type_cd in (")
   FOR (count = 1 TO synonymtypessize)
    SET ocs_parse = concat(ocs_parse,build(request->synonyms[count].type_cd))
    IF (count=synonymtypessize)
     SET ocs_parse = concat(ocs_parse,")")
    ELSE
     SET ocs_parse = concat(ocs_parse,",")
    ENDIF
   ENDFOR
  ENDIF
  SET oefssize = size(request->oefs,5)
  IF (oefssize > 0)
   SET ocs_parse = concat(ocs_parse," and ocs.oe_format_id in (")
   FOR (count = 1 TO oefssize)
    SET ocs_parse = concat(ocs_parse,build(request->oefs[count].oef_id))
    IF (count=oefssize)
     SET ocs_parse = concat(ocs_parse,")")
    ELSE
     SET ocs_parse = concat(ocs_parse,",")
    ENDIF
   ENDFOR
  ENDIF
  IF ((request->show_unhidden_synonyms_ind=1))
   SET ocs_parse = concat(ocs_parse," and ocs.hide_flag = 0 ")
  ENDIF
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
    AND ocs.mnemonic_type_cd != dcp_code_value
    AND parser(ocs_parse))
   JOIN (ocs2
   WHERE ocs2.catalog_cd=ocs.catalog_cd
    AND ocs2.mnemonic_type_cd=primary
    AND ocs2.active_ind=1)
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
    AND m.mnemonic_type_mean > " ") OR (cv4.display=m.mnemonic_type
    AND m.mnemonic_type_mean IN ("", " ", null))) )
   JOIN (b
   WHERE b.br_nv_key1=outerjoin("MLTM_IGN_SYN")
    AND b.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
    AND b.br_value=outerjoin(cnvtstring(ocs.synonym_id)))
  ORDER BY cnvtupper(ocs2.mnemonic), ocs.catalog_cd, cnvtupper(ocs.mnemonic),
   ocs.synonym_id
  HEAD REPORT
   cnt = 0, tot_cnt = 0, sub_cnt = 0,
   list_cnt = 0, stat = alterlist(tempreply->orderables,200), match_ind = 1,
   primary_ind = 0
  HEAD ocs.catalog_cd
   sub_cnt = 0, list_cnt = 0
   IF (match_ind=1)
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (tot_cnt > 200)
     stat = alterlist(tempreply->orderables,(cnt+ 200)), tot_cnt = 1
    ENDIF
   ELSE
    stat = alterlist(tempreply->orderables[cnt].synonyms,0)
   ENDIF
   tempreply->orderables[cnt].code_value = ocs.catalog_cd, stat = alterlist(tempreply->orderables[cnt
    ].synonyms,200), match_ind = 0,
   primary_ind = 0
  HEAD ocs.synonym_id
   IF ((((request->return_ignored_ind=1)) OR (b.br_name_value_id=0.0)) )
    process_ind = 0, show_all_ind = request->show_all_ind
    IF ((request->hide_flag_ind=1)
     AND ocs.hide_flag=0
     AND m.hide_ind=1)
     process_ind = 1
    ENDIF
    IF ((request->syononym_type_ind=1))
     IF (((m.mnemonic_type_mean > " "
      AND cv.cdf_meaning != m.mnemonic_type_mean) OR (m.mnemonic_type_mean IN ("", " ", null)
      AND cnvtupper(cv.display) != cnvtupper(m.mnemonic_type))) )
      process_ind = 1
     ENDIF
    ENDIF
    IF ((request->mnemonic_ind=1)
     AND ocs.mnemonic != m.mnemonic)
     process_ind = 1
    ENDIF
    IF (textlen(trim(m.mnemonic)) > 100
     AND ocs.hide_flag=m.hide_ind
     AND cnvtupper(cv.display)=cnvtupper(m.mnemonic_type))
     show_all_ind = 0, process_ind = 0
    ENDIF
    IF (((m.primary_ind=1
     AND ocs.mnemonic_type_cd != primary) OR (m.primary_ind=0
     AND ocs.mnemonic_type_cd=primary)) )
     show_all_ind = 0, process_ind = 0
    ENDIF
    IF (process_ind=1)
     sub_cnt = (sub_cnt+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 200)
      stat = alterlist(tempreply->orderables[cnt].synonyms,(sub_cnt+ 200)), list_cnt = 1
     ENDIF
     tempreply->orderables[cnt].synonyms[sub_cnt].synonym_id = ocs.synonym_id, tempreply->orderables[
     cnt].synonyms[sub_cnt].mnemonic = ocs.mnemonic, tempreply->orderables[cnt].synonyms[sub_cnt].
     hide_flag = ocs.hide_flag,
     tempreply->orderables[cnt].synonyms[sub_cnt].mnemonic_type.code_value = ocs.mnemonic_type_cd
     IF (b.br_name_value_id > 0)
      tempreply->orderables[cnt].synonyms[sub_cnt].ignore_ind = 1
     ENDIF
     tempreply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.cki = m.synonym_cki, tempreply->
     orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic_type.display = cv4.display, tempreply->
     orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic_type.meaning = cv4.cdf_meaning,
     tempreply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic_type.code_value = cv4
     .code_value, tempreply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.hide_flag = m.hide_ind,
     tempreply->orderables[cnt].synonyms[sub_cnt].mltm_synonym.mnemonic = m.mnemonic,
     tempreply->orderables[cnt].synonyms[sub_cnt].mnemonic_type.meaning = cv.cdf_meaning, tempreply->
     orderables[cnt].synonyms[sub_cnt].mnemonic_type.display = cv.display, tempreply->orderables[cnt]
     .synonyms[sub_cnt].load_ind = 1,
     tempreply->orderables[cnt].synonyms[sub_cnt].added_parent = 0, match_ind = 1
     IF (ocs.mnemonic_type_cd=primary)
      primary_ind = 1
     ENDIF
    ENDIF
   ENDIF
  FOOT  ocs.catalog_cd
   stat = alterlist(tempreply->orderables[cnt].synonyms,sub_cnt)
   IF (primary_ind=0)
    sub_cnt = (sub_cnt+ 1), stat = alterlist(tempreply->orderables[cnt].synonyms,sub_cnt), tempreply
    ->orderables[cnt].synonyms[sub_cnt].synonym_id = ocs2.synonym_id,
    tempreply->orderables[cnt].synonyms[sub_cnt].mnemonic = ocs2.mnemonic, tempreply->orderables[cnt]
    .synonyms[sub_cnt].hide_flag = ocs2.hide_flag, tempreply->orderables[cnt].synonyms[sub_cnt].
    mnemonic_type.code_value = ocs2.mnemonic_type_cd,
    tempreply->orderables[cnt].synonyms[sub_cnt].mnemonic_type.meaning = cv3.cdf_meaning, tempreply->
    orderables[cnt].synonyms[sub_cnt].mnemonic_type.display = cv3.display, tempreply->orderables[cnt]
    .synonyms[sub_cnt].load_ind = 1,
    tempreply->orderables[cnt].synonyms[sub_cnt].added_parent = 1
   ENDIF
  FOOT REPORT
   IF (cnt > 0
    AND match_ind=0)
    stat = alterlist(tempreply->orderables,(cnt - 1)), cnt = (cnt - 1)
   ELSE
    stat = alterlist(tempreply->orderables,cnt)
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to get the synonyms.")
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    (dummyt d2  WITH seq = 1),
    ocs_facility_r o,
    code_value cv
   PLAN (d
    WHERE maxrec(d2,size(tempreply->orderables[d.seq].synonyms,5)) > 0)
    JOIN (d2)
    JOIN (o
    WHERE (o.synonym_id=tempreply->orderables[d.seq].synonyms[d2.seq].synonym_id))
    JOIN (cv
    WHERE cv.code_value=outerjoin(o.facility_cd)
     AND cv.active_ind=outerjoin(1))
   ORDER BY d.seq, d2.seq, cv.code_value
   HEAD d.seq
    fcnt = 0
   HEAD d2.seq
    fcnt = 0, ftcnt = 0, stat = alterlist(tempreply->orderables[d.seq].synonyms[d2.seq].facilities,
     100)
   HEAD cv.code_value
    IF (((o.facility_cd=0) OR (cv.code_value > 0)) )
     fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
     IF (fcnt > 100)
      stat = alterlist(tempreply->orderables[d.seq].synonyms[d2.seq].facilities,(ftcnt+ 100)), fcnt
       = 1
     ENDIF
     tempreply->orderables[d.seq].synonyms[d2.seq].facilities[ftcnt].code_value = cv.code_value,
     tempreply->orderables[d.seq].synonyms[d2.seq].facilities[ftcnt].display = trim(cv.display)
    ENDIF
   FOOT  d2.seq
    stat = alterlist(tempreply->orderables[d.seq].synonyms[d2.seq].facilities,ftcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Failed to populate the facilities information.")
  DECLARE ordsize = i4 WITH protect, noconstant(0)
  DECLARE synsize = i4 WITH protect, noconstant(0)
  DECLARE facsize = i4 WITH protect, noconstant(0)
  DECLARE reqfacsize = i4 WITH protect, noconstant(0)
  DECLARE parentadded = i2 WITH protect, noconstant(0)
  DECLARE num = i4 WITH protect, noconstant(0)
  DECLARE num2 = i4 WITH protect, noconstant(0)
  SET ordsize = 0
  SET reqfacsize = size(request->facilities,5)
  FOR (cnt1 = 1 TO size(tempreply->orderables,5))
    SET ordsize = (ordsize+ 1)
    SET stat = alterlist(reply->orderables,ordsize)
    SET synsize = 0
    SET parentadded = 0
    FOR (cnt2 = 1 TO size(tempreply->orderables[cnt1].synonyms,5))
      SET num = 0
      IF ((request->all_facilities_ind=1)
       AND reqfacsize=0)
       IF (locateval(num,1,size(tempreply->orderables[cnt1].synonyms[cnt2].facilities,5),0.0,
        tempreply->orderables[cnt1].synonyms[cnt2].facilities[num].code_value)=0)
        SET tempreply->orderables[cnt1].synonyms[cnt2].load_ind = 0
       ENDIF
      ELSEIF (reqfacsize > 0)
       FOR (cnt3 = 1 TO reqfacsize)
         SET num = 0
         SET num2 = 0
         IF (size(tempreply->orderables[cnt1].synonyms[cnt2].facilities,5)=0)
          SET tempreply->orderables[cnt1].synonyms[cnt2].load_ind = 0
         ELSEIF (locateval(num,1,size(tempreply->orderables[cnt1].synonyms[cnt2].facilities,5),
          request->facilities[cnt3].code_value,tempreply->orderables[cnt1].synonyms[cnt2].facilities[
          num].code_value)=0)
          IF ((request->all_facilities_ind=1))
           IF (locateval(num2,1,size(tempreply->orderables[cnt1].synonyms[cnt2].facilities,5),0.0,
            tempreply->orderables[cnt1].synonyms[cnt2].facilities[num2].code_value)=0)
            SET tempreply->orderables[cnt1].synonyms[cnt2].load_ind = 0
            IF ((tempreply->orderables[cnt1].synonyms[cnt2].mnemonic_type.code_value=primary))
             SET tempreply->orderables[cnt1].synonyms[cnt2].added_parent = 1
             SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.cki = ""
             SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.display = ""
             SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.meaning = ""
             SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.code_value = 0
             SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.hide_flag = 0
             SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic = ""
            ENDIF
           ENDIF
          ELSE
           SET tempreply->orderables[cnt1].synonyms[cnt2].load_ind = 0
           IF ((tempreply->orderables[cnt1].synonyms[cnt2].mnemonic_type.code_value=primary))
            SET tempreply->orderables[cnt1].synonyms[cnt2].added_parent = 1
            SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.cki = ""
            SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.display = ""
            SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.meaning = ""
            SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.code_value = 0
            SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.hide_flag = 0
            SET tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic = ""
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      IF ((((tempreply->orderables[cnt1].synonyms[cnt2].load_ind=1)) OR ((tempreply->orderables[cnt1]
      .synonyms[cnt2].added_parent=1))) )
       SET synsize = (synsize+ 1)
       SET synonym_cnt = (synonym_cnt+ 1)
       IF ((tempreply->orderables[cnt1].synonyms[cnt2].added_parent=1))
        SET parentadded = 1
       ENDIF
       IF ((request->max_reply > 0)
        AND (synonym_cnt > request->max_reply))
        SET reply->too_many_results_ind = 1
        SET stat = alterlist(reply->orderables,0)
        GO TO exit_script
       ENDIF
       SET stat = alterlist(reply->orderables[ordsize].synonyms,synsize)
       SET reply->orderables[ordsize].synonyms[synsize].synonym_id = tempreply->orderables[cnt1].
       synonyms[cnt2].synonym_id
       SET reply->orderables[ordsize].synonyms[synsize].mnemonic = tempreply->orderables[cnt1].
       synonyms[cnt2].mnemonic
       SET reply->orderables[ordsize].synonyms[synsize].hide_flag = tempreply->orderables[cnt1].
       synonyms[cnt2].hide_flag
       SET reply->orderables[ordsize].synonyms[synsize].ignore_ind = tempreply->orderables[cnt1].
       synonyms[cnt2].ignore_ind
       SET reply->orderables[ordsize].synonyms[synsize].mnemonic_type.code_value = tempreply->
       orderables[cnt1].synonyms[cnt2].mnemonic_type.code_value
       SET reply->orderables[ordsize].synonyms[synsize].mnemonic_type.display = tempreply->
       orderables[cnt1].synonyms[cnt2].mnemonic_type.display
       SET reply->orderables[ordsize].synonyms[synsize].mnemonic_type.meaning = tempreply->
       orderables[cnt1].synonyms[cnt2].mnemonic_type.meaning
       SET reply->orderables[ordsize].synonyms[synsize].mltm_synonym.cki = tempreply->orderables[cnt1
       ].synonyms[cnt2].mltm_synonym.cki
       SET reply->orderables[ordsize].synonyms[synsize].mltm_synonym.mnemonic = tempreply->
       orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic
       SET reply->orderables[ordsize].synonyms[synsize].mltm_synonym.hide_flag = tempreply->
       orderables[cnt1].synonyms[cnt2].mltm_synonym.hide_flag
       SET reply->orderables[ordsize].synonyms[synsize].mltm_synonym.mnemonic_type.code_value =
       tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.code_value
       SET reply->orderables[ordsize].synonyms[synsize].mltm_synonym.mnemonic_type.display =
       tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.display
       SET reply->orderables[ordsize].synonyms[synsize].mltm_synonym.mnemonic_type.meaning =
       tempreply->orderables[cnt1].synonyms[cnt2].mltm_synonym.mnemonic_type.meaning
       SET stat = alterlist(reply->orderables[ordsize].synonyms[synsize].facilities,size(tempreply->
         orderables[cnt1].synonyms[cnt2].facilities,5))
       FOR (cnt3 = 1 TO size(tempreply->orderables[cnt1].synonyms[cnt2].facilities,5))
        SET reply->orderables[ordsize].synonyms[synsize].facilities[cnt3].code_value = tempreply->
        orderables[cnt1].synonyms[cnt2].facilities[cnt3].code_value
        SET reply->orderables[ordsize].synonyms[synsize].facilities[cnt3].display = tempreply->
        orderables[cnt1].synonyms[cnt2].facilities[cnt3].display
       ENDFOR
      ENDIF
    ENDFOR
    IF (synsize=0)
     SET ordsize = (ordsize - 1)
     SET stat = alterlist(reply->orderables,ordsize)
    ELSEIF (parentadded=1
     AND synsize=1)
     SET synonym_cnt = (synonym_cnt - 1)
     SET ordsize = (ordsize - 1)
     SET stat = alterlist(reply->orderables,ordsize)
    ELSE
     SET reply->orderables[ordsize].code_value = tempreply->orderables[cnt1].code_value
    ENDIF
  ENDFOR
 ENDIF
 CALL echo(synonym_cnt)
 IF ((request->max_reply > 0)
  AND (synonym_cnt > request->max_reply))
  SET reply->too_many_results_ind = 1
  SET stat = alterlist(reply->orderables,0)
  GO TO exit_script
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
