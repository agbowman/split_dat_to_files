CREATE PROGRAM bed_ens_mltm_cnum:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_syn
 RECORD temp_syn(
   1 synonyms[*]
     2 synonym_id = f8
     2 dnum = vc
     2 cnum = vc
     2 display = vc
     2 dnum_concept_cki = vc
     2 cnum_concept_cki = vc
 )
 DECLARE primary_code_value = f8
 DECLARE ivsolutions_code_value = f8
 DECLARE medications_code_value = f8
 DECLARE pharmacy_code_value = f8
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16389
   AND cv.cdf_meaning="MEDICATIONS"
   AND cv.active_ind=1
  DETAIL
   medications_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16389
   AND cv.cdf_meaning="IVSOLUTIONS"
   AND cv.active_ind=1
  DETAIL
   ivsolutions_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
   AND cv.active_ind=1
  DETAIL
   primary_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharmacy_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_type_cd=pharmacy_code_value
    AND ((oc.orderable_type_flag=1) OR (oc.orderable_type_flag=0))
    AND oc.cki="MUL.ORD!*")
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.mnemonic_type_cd=primary_code_value
    AND ((ocs.cki != "MUL.ORD-SYN!*") OR (ocs.cki IN ("", " ", null))) )
  ORDER BY oc.catalog_cd, ocs.synonym_id
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(temp_syn->synonyms,100)
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(temp_syn->synonyms,(cnt+ 100)), list_cnt = 1
   ENDIF
   temp_syn->synonyms[cnt].synonym_id = ocs.synonym_id, temp_syn->synonyms[cnt].dnum = oc.cki,
   temp_syn->synonyms[cnt].dnum_concept_cki = oc.concept_cki
  FOOT REPORT
   stat = alterlist(temp_syn->synonyms,cnt)
  WITH nocoutner
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    mltm_order_catalog_load m
   PLAN (d)
    JOIN (m
    WHERE (m.catalog_cki=temp_syn->synonyms[d.seq].dnum)
     AND ((m.catalog_concept_cki IN ("", " ", null)
     AND (temp_syn->synonyms[d.seq].dnum_concept_cki IN ("", " ", null))) OR ((temp_syn->synonyms[d
    .seq].dnum_concept_cki > " ")
     AND (m.catalog_concept_cki=temp_syn->synonyms[d.seq].dnum_concept_cki)))
     AND ((m.mnemonic_type_mean="PRIMARY"
     AND m.mnemonic_type_mean > " ") OR (m.mnemonic_type_mean IN ("", " ", null)
     AND cnvtupper(m.mnemonic_type)="PRIMARY")) )
   DETAIL
    temp_syn->synonyms[d.seq].cnum = m.synonym_cki, temp_syn->synonyms[d.seq].cnum_concept_cki = m
    .synonym_concept_cki, temp_syn->synonyms[d.seq].display = m.mnemonic
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO cnt)
   IF ((temp_syn->synonyms[x].cnum > " "))
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.cki = temp_syn->synonyms[x].cnum, ocs.concept_cki = temp_syn->synonyms[x].
      cnum_concept_cki, ocs.ref_text_mask = 64,
      ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs.updt_task
       = reqinfo->updt_task,
      ocs.updt_cnt = (updt_cnt+ 1), ocs.updt_applctx = reqinfo->updt_applctx
     WHERE (ocs.synonym_id=temp_syn->synonyms[x].synonym_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update orderable: ",trim(cnvtstring(temp_syn->synonyms[
        x].synonym_id))," on the order catalog synonym table")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET concept_exist_ind = 0
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load m
  WHERE m.catalog_concept_cki > " "
   AND m.synonym_concept_cki > " "
  HEAD REPORT
   concept_exist_ind = 1
  WITH nocounter
 ;end select
 IF (concept_exist_ind=0)
  GO TO exit_script
 ENDIF
 SET stat = initrec(temp_syn)
 SET tcnt = 0
 DECLARE temp_con_cki = vc
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   order_catalog oc,
   mltm_order_catalog_load m
  PLAN (ocs
   WHERE ocs.cki="MUL.*"
    AND ocs.concept_cki IN ("", " ", null)
    AND ((ocs.catalog_type_cd+ 0)=pharmacy_code_value)
    AND ocs.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.active_ind=1)
   JOIN (m
   WHERE m.synonym_cki=ocs.cki
    AND m.synonym_concept_cki > " ")
  ORDER BY ocs.synonym_id, m.synonym_cki, m.synonym_concept_cki
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(temp_syn->synonyms,100)
  HEAD ocs.synonym_id
   mcnt = 0
  HEAD m.synonym_cki
   mcnt = mcnt
  HEAD m.synonym_concept_cki
   mcnt = (mcnt+ 1), temp_con_cki = m.synonym_concept_cki
  FOOT  ocs.synonym_id
   IF (mcnt=1)
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(temp_syn->synonyms,(tcnt+ 100)), cnt = 1
    ENDIF
    temp_syn->synonyms[tcnt].synonym_id = ocs.synonym_id, temp_syn->synonyms[tcnt].cnum_concept_cki
     = m.synonym_concept_cki
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_syn->synonyms,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM order_catalog_synonym o,
   (dummyt d  WITH seq = value(tcnt))
  SET o.concept_cki = temp_syn->synonyms[d.seq].cnum_concept_cki, o.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), o.updt_id = reqinfo->updt_id,
   o.updt_task = reqinfo->updt_task, o.updt_cnt = (o.updt_cnt+ 1), o.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (o
   WHERE (o.synonym_id=temp_syn->synonyms[d.seq].synonym_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = build("Unable to update rows")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
