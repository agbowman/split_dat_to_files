CREATE PROGRAM afc_get_nomenclature:dba
 RECORD reply(
   1 nomenclature_id = f8
   1 source_string = vc
   1 source_identifier = c50
   1 source_vocabulary_cd = f8
   1 valid_codes_qual = i4
   1 valid_codes[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 source_identifier = c50
     2 source_vocabulary_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE cs400_icd9_cd = f8
 SET stat = uar_get_meaning_by_codeset(400,"ICD9",1,cs400_icd9_cd)
 SET valid_flag = 1
 SET count1 = 0
 DECLARE icdparsestring = vc
 SET len = 0
 CALL echo("Main select")
 SELECT INTO "nl:"
  FROM nomenclature n
  WHERE (n.source_identifier=request->source_identifier)
   AND (n.source_vocabulary_cd=request->source_vocabulary_cd)
   AND n.active_ind=1
   AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   reply->nomenclature_id = n.nomenclature_id, reply->source_string = n.source_string, reply->
   source_identifier = n.source_identifier,
   reply->source_vocabulary_cd = n.source_vocabulary_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMENCLATURE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->nomenclature_id > 0))
  IF ((reply->source_vocabulary_cd=cs400_icd9_cd))
   SELECT INTO "nl:"
    FROM icd9cm_extension ie
    WHERE (ie.source_identifier=reply->source_identifier)
     AND ie.active_ind=1
     AND ie.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ie.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ie.valid_flag_desc="N"
    DETAIL
     valid_flag = 0
    WITH nocounter
   ;end select
   IF (valid_flag=0)
    CALL echo(build("the size is: ",size(trim(reply->source_identifier,1))))
    SET len = size(trim(reply->source_identifier),1)
    SET icdparsestring = concat("ie.source_identifier='",substring(1,len,reply->source_identifier),
     "*'")
    SELECT INTO "nl:"
     FROM icd9cm_extension ie
     WHERE parser(icdparsestring)
      AND ie.active_ind=1
      AND ie.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ie.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ie.valid_flag_desc="Y"
     ORDER BY ie.source_identifier
     DETAIL
      count1 = (count1+ 1), stat = alterlist(reply->valid_codes,count1), reply->valid_codes[count1].
      source_identifier = ie.source_identifier
     WITH nocounter
    ;end select
    SET reply->valid_codes_qual = count1
    IF (count1 > 0)
     SELECT INTO "nl:"
      FROM nomenclature n,
       (dummyt d1  WITH seq = value(reply->valid_codes_qual))
      PLAN (d1)
       JOIN (n
       WHERE (n.source_identifier=reply->valid_codes[d1.seq].source_identifier)
        AND (n.source_vocabulary_cd=request->source_vocabulary_cd)
        AND n.active_ind=1
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      DETAIL
       reply->valid_codes[d1.seq].nomenclature_id = n.nomenclature_id, reply->valid_codes[d1.seq].
       source_string = n.source_string, reply->valid_codes[d1.seq].source_vocabulary_cd = n
       .source_vocabulary_cd
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ELSE
   SELECT INTO "nl:"
    FROM nomenclature n,
     cmt_concept_extension cce
    PLAN (n
     WHERE (n.source_identifier=reply->source_identifier)
      AND (n.source_vocabulary_cd=request->source_vocabulary_cd))
     JOIN (cce
     WHERE cce.concept_cki=n.concept_cki
      AND cce.extension_type_mean="BILLABLE"
      AND cce.active_ind=1
      AND cce.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cce.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND  NOT (cce.extension_value IN ("Y", "1")))
    DETAIL
     valid_flag = 0
    WITH nocounter
   ;end select
   IF (valid_flag=0)
    CALL echo(build("the size is: ",size(trim(reply->source_identifier,1))))
    SET len = size(trim(reply->source_identifier),1)
    SET icdparsestring = concat("n.source_identifier='",substring(1,len,reply->source_identifier),
     "*' ")
    SELECT INTO "nl:"
     FROM nomenclature n,
      cmt_concept_extension cce
     PLAN (n
      WHERE parser(icdparsestring)
       AND (n.source_vocabulary_cd=request->source_vocabulary_cd))
      JOIN (cce
      WHERE cce.concept_cki=n.concept_cki
       AND cce.extension_type_mean="BILLABLE"
       AND cce.active_ind=1
       AND cce.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND cce.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND cce.extension_value IN ("Y", "1"))
     ORDER BY n.source_identifier
     DETAIL
      count1 = (count1+ 1), stat = alterlist(reply->valid_codes,count1), reply->valid_codes[count1].
      nomenclature_id = n.nomenclature_id,
      reply->valid_codes[count1].source_string = n.source_string, reply->valid_codes[count1].
      source_vocabulary_cd = n.source_vocabulary_cd
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
