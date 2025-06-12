CREATE PROGRAM cps_get_nomen_cat:dba
 RECORD reply(
   1 nomen_cat_qual = i4
   1 nomen_cat[*]
     2 nomen_category_id = f8
     2 category_name = vc
     2 child_cat_ind = i4
     2 nomen_cat_list_qual = i4
     2 nomen_cat_list[*]
       3 category_name = vc
       3 nomen_category_id = f8
       3 nomen_cat_list_id = f8
       3 nomenclature_id = f8
       3 parent_category_id = f8
       3 child_category_id = f8
       3 child_flag = i2
       3 source_string = vc
       3 string_identifier = vc
       3 source_identifier = vc
       3 concept_identifier = vc
       3 concept_source_cd = f8
       3 source_vocabulary_cd = f8
       3 string_source_cd = f8
       3 principle_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD context(
   1 nomen_category_id = f8
   1 nomen_cat_list_id = f8
 )
 RECORD t_reply(
   1 nomen_cat_list_qual = i4
   1 nomen_cat_list[*]
     2 category_name = vc
     2 nomen_category_id = f8
     2 nomen_cat_list_id = f8
     2 nomenclature_id = f8
     2 parent_category_id = f8
     2 child_category_id = f8
     2 child_flag = i2
     2 source_string = vc
     2 end_eff_dt_tm = dq8
     2 string_identifier = vc
     2 source_identifier = vc
     2 concept_identifier = vc
     2 concept_source_cd = f8
     2 source_vocabulary_cd = f8
     2 string_source_cd = f8
     2 principle_type_cd = f8
 )
 RECORD s_reply(
   1 nomen_cat_list_qual = i4
   1 nomen_cat_list[*]
     2 category_name = vc
     2 nomen_category_id = f8
     2 nomen_cat_list_id = f8
     2 nomenclature_id = f8
     2 parent_category_id = f8
     2 child_category_id = f8
     2 child_flag = i2
     2 source_string = vc
     2 end_eff_dt_tm = dq8
     2 string_identifier = vc
     2 source_identifier = vc
     2 concept_identifier = vc
     2 concept_source_cd = f8
     2 source_vocabulary_cd = f8
     2 string_source_cd = f8
     2 principle_type_cd = f8
 )
 SET reply->status_data.status = "F"
 IF ((request->nomen_list[1].get_child_cat=0))
  SET stat = alterlist(reply->nomen_cat,10)
  SET count1 = 0
  SELECT
   IF ((request->nomen_list[1].nomen_category_id=0))
    PLAN (d)
     JOIN (nc
     WHERE (nc.nomen_category_id > request->nomen_list[d.seq].nomen_category_id))
     JOIN (d2
     WHERE d.seq=1)
     JOIN (nl
     WHERE nc.nomen_category_id=nl.parent_category_id)
   ELSEIF ((request->nomen_list[1].nomen_category_id > 0))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (nc
     WHERE (nc.nomen_category_id=request->nomen_list[d.seq].nomen_category_id))
     JOIN (d2
     WHERE d.seq=1)
     JOIN (nl
     WHERE nc.nomen_category_id=nl.parent_category_id)
   ELSE
   ENDIF
   INTO "nl:"
   nc.nomen_category_id, nc.category_name
   FROM nomen_category nc,
    (dummyt d  WITH seq = value(request->nomen_qual)),
    (dummyt d2  WITH seq = 1),
    nomen_cat_list nl
   ORDER BY cnvtupper(nc.category_name)
   HEAD REPORT
    count1 = 0
   HEAD nc.nomen_category_id
    IF (nc.nomen_category_id > 0)
     count1 = (count1+ 1)
     IF (count1 > size(reply->nomen_cat,5))
      stat = alterlist(reply->nomen_cat,(count1+ 4))
     ENDIF
     reply->nomen_cat[count1].nomen_category_id = nc.nomen_category_id, reply->nomen_cat[count1].
     category_name = nc.category_name
    ENDIF
   DETAIL
    IF (nl.child_category_id > 0)
     reply->nomen_cat[count1].child_cat_ind = 1
    ENDIF
   FOOT REPORT
    reply->nomen_cat_qual = count1
   WITH check, nocounter, outerjoin = d,
    outerjoin = d2
  ;end select
  SET stat = alterlist(reply->nomen_cat,count1)
 ENDIF
 IF ((((request->nomen_list[1].get_child_cat=1)
  AND (request->nomen_list[1].nomen_category_id > 0)) OR ((context->nomen_category_id > 0))) )
  SET stat = alterlist(reply->nomen_cat,1)
  SET reply->nomen_cat[1].nomen_cat_list_qual = 0
  SET stat = alterlist(reply->nomen_cat[1].nomen_cat_list,0)
  SET stat = alterlist(t_reply->nomen_cat_list,10)
  SELECT
   IF ((request->nomen_list[1].nomen_category_id > 0))
    PLAN (nc
     WHERE (request->nomen_list[1].nomen_category_id=nc.nomen_category_id)
      AND nc.nomen_category_id > 0.0)
     JOIN (nl
     WHERE nc.nomen_category_id=nl.parent_category_id)
     JOIN (d
     WHERE d.seq=1)
     JOIN (nc2
     WHERE nl.child_category_id=nc2.nomen_category_id)
   ELSEIF ((context->nomen_category_id > 0)
    AND (context->nomen_cat_list_id > 0))
    PLAN (nc
     WHERE (context->nomen_category_id=nc.nomen_category_id)
      AND nc.nomen_category_id > 0.0)
     JOIN (nl
     WHERE nc.nomen_category_id=nl.parent_category_id
      AND (context->nomen_cat_list_id < nl.nomen_cat_list_id))
     JOIN (d
     WHERE d.seq=1)
     JOIN (nc2
     WHERE nl.child_category_id=nc2.nomen_category_id)
   ELSE
   ENDIF
   INTO "nl:"
   nc2.category_name
   FROM nomen_category nc,
    nomen_cat_list nl,
    nomen_category nc2,
    (dummyt d  WITH seq = 1)
   ORDER BY cnvtupper(nc2.category_name)
   HEAD REPORT
    count1 = 0, reply->nomen_cat_qual = 1, reply->nomen_cat[1].nomen_category_id = nc
    .nomen_category_id,
    reply->nomen_cat[1].category_name = nc.category_name
   DETAIL
    count1 = (count1+ 1)
    IF (count1 > size(t_reply->nomen_cat_list,5))
     stat = alterlist(t_reply->nomen_cat_list,(count1+ 4))
    ENDIF
    t_reply->nomen_cat_list[count1].category_name = nc2.category_name, t_reply->nomen_cat_list[count1
    ].nomen_category_id = nc2.nomen_category_id, t_reply->nomen_cat_list[count1].nomen_cat_list_id =
    nl.nomen_cat_list_id,
    t_reply->nomen_cat_list[count1].nomenclature_id = nl.nomenclature_id, t_reply->nomen_cat_list[
    count1].parent_category_id = nl.parent_category_id, t_reply->nomen_cat_list[count1].
    child_category_id = nl.child_category_id,
    t_reply->nomen_cat_list[count1].child_flag = nl.child_flag
   FOOT REPORT
    stat = alterlist(t_reply->nomen_cat_list,count1), t_reply->nomen_cat_list_qual = count1, context
    ->nomen_category_id = reply->nomen_cat[1].nomen_category_id,
    context->nomen_cat_list_id = t_reply->nomen_cat_list[count1].nomen_cat_list_id
   WITH check, nocounter, outerjoin = d
  ;end select
  IF ((t_reply->nomen_cat_list_qual != 0))
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(t_reply->nomen_cat_list_qual)),
     nomenclature n
    PLAN (d)
     JOIN (n
     WHERE (t_reply->nomen_cat_list[d.seq].nomenclature_id=n.nomenclature_id)
      AND (t_reply->nomen_cat_list[d.seq].child_flag=2))
    DETAIL
     count1 = 0, found = fillstring(01,"N")
     WHILE (found="N")
      count1 = (count1+ 1),
      IF ((n.nomenclature_id=t_reply->nomen_cat_list[count1].nomenclature_id)
       AND (t_reply->nomen_cat_list[count1].child_flag=2))
       t_reply->nomen_cat_list[count1].source_string = n.source_string, t_reply->nomen_cat_list[
       count1].end_eff_dt_tm = n.end_effective_dt_tm, t_reply->nomen_cat_list[count1].
       string_identifier = n.string_identifier,
       t_reply->nomen_cat_list[count1].concept_identifier = n.concept_identifier, t_reply->
       nomen_cat_list[count1].concept_source_cd = n.concept_source_cd, t_reply->nomen_cat_list[count1
       ].source_vocabulary_cd = n.source_vocabulary_cd,
       t_reply->nomen_cat_list[count1].source_identifier = n.source_identifier, t_reply->
       nomen_cat_list[count1].string_source_cd = n.string_source_cd, t_reply->nomen_cat_list[count1].
       principle_type_cd = n.principle_type_cd,
       found = "Y"
      ENDIF
     ENDWHILE
    WITH check, nocounter
   ;end select
   SET stat = alterlist(s_reply->nomen_cat_list,t_reply->nomen_cat_list_qual)
   SET s_reply->nomen_cat_list_qual = t_reply->nomen_cat_list_qual
   SET knt = 0
   SELECT INTO "nl:"
    source_string = cnvtupper(t_reply->nomen_cat_list[d.seq].source_string), cat_name = cnvtupper(
     t_reply->nomen_cat_list[d.seq].category_name)
    FROM (dummyt d  WITH seq = value(t_reply->nomen_cat_list_qual))
    PLAN (d
     WHERE d.seq > 0)
    ORDER BY cat_name, source_string
    HEAD REPORT
     knt = 0
    DETAIL
     knt = (knt+ 1)
     IF ((knt > s_reply->nomen_cat_list_qual))
      stat = alterlist(s_reply->nomen_cat_list,knt), s_reply->nomen_cat_list_qual = knt
     ENDIF
     s_reply->nomen_cat_list[knt].category_name = t_reply->nomen_cat_list[d.seq].category_name,
     s_reply->nomen_cat_list[knt].nomen_category_id = t_reply->nomen_cat_list[d.seq].
     nomen_category_id, s_reply->nomen_cat_list[knt].nomen_cat_list_id = t_reply->nomen_cat_list[d
     .seq].nomen_cat_list_id,
     s_reply->nomen_cat_list[knt].nomenclature_id = t_reply->nomen_cat_list[d.seq].nomenclature_id,
     s_reply->nomen_cat_list[knt].parent_category_id = t_reply->nomen_cat_list[d.seq].
     parent_category_id, s_reply->nomen_cat_list[knt].child_category_id = t_reply->nomen_cat_list[d
     .seq].child_category_id,
     s_reply->nomen_cat_list[knt].child_flag = t_reply->nomen_cat_list[d.seq].child_flag, s_reply->
     nomen_cat_list[knt].source_string = t_reply->nomen_cat_list[d.seq].source_string, s_reply->
     nomen_cat_list[knt].end_eff_dt_tm = t_reply->nomen_cat_list[d.seq].end_eff_dt_tm,
     s_reply->nomen_cat_list[knt].string_identifier = t_reply->nomen_cat_list[d.seq].
     string_identifier, s_reply->nomen_cat_list[knt].source_identifier = t_reply->nomen_cat_list[d
     .seq].source_identifier, s_reply->nomen_cat_list[knt].concept_identifier = t_reply->
     nomen_cat_list[d.seq].concept_identifier,
     s_reply->nomen_cat_list[knt].concept_source_cd = t_reply->nomen_cat_list[d.seq].
     concept_source_cd, s_reply->nomen_cat_list[knt].source_vocabulary_cd = t_reply->nomen_cat_list[d
     .seq].source_vocabulary_cd, s_reply->nomen_cat_list[knt].string_source_cd = t_reply->
     nomen_cat_list[d.seq].string_source_cd,
     s_reply->nomen_cat_list[knt].principle_type_cd = t_reply->nomen_cat_list[d.seq].
     principle_type_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->nomen_cat[1].nomen_cat_list,s_reply->nomen_cat_list_qual)
   SET knt = 0
   FOR (i = 1 TO s_reply->nomen_cat_list_qual)
    SET knt = (knt+ 1)
    IF ((s_reply->nomen_cat_list[i].child_flag=2))
     IF ((s_reply->nomen_cat_list[i].end_eff_dt_tm > cnvtdatetime(curdate,curtime3)))
      SET reply->nomen_cat[1].nomen_cat_list[knt].category_name = s_reply->nomen_cat_list[i].
      category_name
      SET reply->nomen_cat[1].nomen_cat_list[knt].nomen_category_id = s_reply->nomen_cat_list[i].
      nomen_category_id
      SET reply->nomen_cat[1].nomen_cat_list[knt].nomen_cat_list_id = s_reply->nomen_cat_list[i].
      nomen_cat_list_id
      SET reply->nomen_cat[1].nomen_cat_list[knt].nomenclature_id = s_reply->nomen_cat_list[i].
      nomenclature_id
      SET reply->nomen_cat[1].nomen_cat_list[knt].parent_category_id = s_reply->nomen_cat_list[i].
      parent_category_id
      SET reply->nomen_cat[1].nomen_cat_list[knt].child_category_id = s_reply->nomen_cat_list[i].
      child_category_id
      SET reply->nomen_cat[1].nomen_cat_list[knt].child_flag = s_reply->nomen_cat_list[i].child_flag
      SET reply->nomen_cat[1].nomen_cat_list[knt].source_string = s_reply->nomen_cat_list[i].
      source_string
      SET reply->nomen_cat[1].nomen_cat_list[knt].source_identifier = s_reply->nomen_cat_list[i].
      source_identifier
      SET reply->nomen_cat[1].nomen_cat_list[knt].concept_identifier = s_reply->nomen_cat_list[i].
      concept_identifier
      SET reply->nomen_cat[1].nomen_cat_list[knt].concept_source_cd = s_reply->nomen_cat_list[i].
      concept_source_cd
      SET reply->nomen_cat[1].nomen_cat_list[knt].source_vocabulary_cd = s_reply->nomen_cat_list[i].
      source_vocabulary_cd
      SET reply->nomen_cat[1].nomen_cat_list[knt].principle_type_cd = s_reply->nomen_cat_list[i].
      principle_type_cd
     ELSE
      SET knt = (knt - 1)
     ENDIF
    ELSE
     SET reply->nomen_cat[1].nomen_cat_list[knt].category_name = s_reply->nomen_cat_list[i].
     category_name
     SET reply->nomen_cat[1].nomen_cat_list[knt].nomen_category_id = s_reply->nomen_cat_list[i].
     nomen_category_id
     SET reply->nomen_cat[1].nomen_cat_list[knt].nomen_cat_list_id = s_reply->nomen_cat_list[i].
     nomen_cat_list_id
     SET reply->nomen_cat[1].nomen_cat_list[knt].nomenclature_id = s_reply->nomen_cat_list[i].
     nomenclature_id
     SET reply->nomen_cat[1].nomen_cat_list[knt].parent_category_id = s_reply->nomen_cat_list[i].
     parent_category_id
     SET reply->nomen_cat[1].nomen_cat_list[knt].child_category_id = s_reply->nomen_cat_list[i].
     child_category_id
     SET reply->nomen_cat[1].nomen_cat_list[knt].child_flag = s_reply->nomen_cat_list[i].child_flag
     SET reply->nomen_cat[1].nomen_cat_list[knt].source_string = s_reply->nomen_cat_list[i].
     source_string
     SET reply->nomen_cat[1].nomen_cat_list[knt].source_identifier = s_reply->nomen_cat_list[i].
     source_identifier
     SET reply->nomen_cat[1].nomen_cat_list[knt].concept_identifier = s_reply->nomen_cat_list[i].
     concept_identifier
     SET reply->nomen_cat[1].nomen_cat_list[knt].concept_source_cd = s_reply->nomen_cat_list[i].
     concept_source_cd
     SET reply->nomen_cat[1].nomen_cat_list[knt].source_vocabulary_cd = s_reply->nomen_cat_list[i].
     source_vocabulary_cd
     SET reply->nomen_cat[1].nomen_cat_list[knt].principle_type_cd = s_reply->nomen_cat_list[i].
     principle_type_cd
    ENDIF
   ENDFOR
   SET stat = alterlist(reply->nomen_cat[1].nomen_cat_list,knt)
   SET reply->nomen_cat[1].nomen_cat_list_qual = knt
  ENDIF
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
