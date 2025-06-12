CREATE PROGRAM bed_get_nomen_loinc:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 last_batch_ind = i2
   1 nomen_list[*]
     2 active_ind = i2
     2 nomenclature_id = f8
     2 principle_type_cd = f8
     2 principle_type_disp = vc
     2 principle_type_mean = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = vc
     2 contributor_system_mean = vc
     2 language_cd = f8
     2 language_disp = vc
     2 language_mean = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = vc
     2 source_vocabulary_mean = vc
     2 source_string = c255
     2 short_string = c60
     2 mnemonic = c25
     2 source_identifier = vc
     2 concept_identifier = vc
     2 concept_cki = vc
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = vc
     2 vocab_axis_mean = vc
     2 concept_source_cd = f8
     2 concept_source_disp = vc
     2 concept_source_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET reply->last_batch_ind = 1
 DECLARE imaxrecs = i4 WITH protect, constant(10000)
 DECLARE ivocabcnt = i4 WITH protect, constant(size(request->vocab_axis,5))
 DECLARE inomencnt = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect, noconstant(" ")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE const_source_vocab_cs = i4 WITH protect, constant(400)
 DECLARE const_loinc = c5 WITH protect, constant("LOINC")
 DECLARE dloinccd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(const_source_vocab_cs,const_loinc,1,dloinccd)
 SELECT
  IF (ivocabcnt > 0)
   PLAN (n
    WHERE (n.nomenclature_id > request->last_nomenclature_id)
     AND n.source_vocabulary_cd=dloinccd
     AND n.primary_vterm_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1
     AND n.disallowed_ind=0
     AND trim(n.concept_cki)="LOINC!*"
     AND expand(index,1,ivocabcnt,n.vocab_axis_cd,request->vocab_axis[index].vocab_axis_cd))
   ORDER BY n.nomenclature_id
   WITH maxqual(n,value((imaxrecs+ 1)))
  ELSE
   PLAN (n
    WHERE n.source_vocabulary_cd=dloinccd
     AND n.primary_vterm_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1
     AND n.disallowed_ind=0
     AND (n.concept_cki=request->concept_cki)
     AND trim(n.concept_cki)="LOINC!*")
   ORDER BY n.nomenclature_id
  ENDIF
  INTO "nl:"
  FROM nomenclature n
  DETAIL
   IF (ivocabcnt > 0)
    inomencnt = (inomencnt+ 1)
    IF (inomencnt <= imaxrecs)
     IF (mod(inomencnt,500)=1)
      stat = alterlist(reply->nomen_list,(inomencnt+ 499))
     ENDIF
     reply->nomen_list[inomencnt].active_ind = n.active_ind, reply->nomen_list[inomencnt].concept_cki
      = n.concept_cki, reply->nomen_list[inomencnt].concept_identifier = n.concept_identifier,
     reply->nomen_list[inomencnt].concept_source_cd = n.concept_source_cd, reply->nomen_list[
     inomencnt].contributor_system_cd = n.contributor_system_cd, reply->nomen_list[inomencnt].
     language_cd = n.language_cd,
     reply->nomen_list[inomencnt].mnemonic = n.mnemonic, reply->nomen_list[inomencnt].nomenclature_id
      = n.nomenclature_id, reply->nomen_list[inomencnt].principle_type_cd = n.principle_type_cd,
     reply->nomen_list[inomencnt].short_string = n.short_string, reply->nomen_list[inomencnt].
     source_identifier = n.source_identifier, reply->nomen_list[inomencnt].source_string = n
     .source_string,
     reply->nomen_list[inomencnt].source_vocabulary_cd = n.source_vocabulary_cd, reply->nomen_list[
     inomencnt].vocab_axis_cd = n.vocab_axis_cd
    ELSE
     reply->last_batch_ind = 0, inomencnt = (inomencnt - 1)
    ENDIF
   ELSE
    inomencnt = 1, stat = alterlist(reply->nomen_list,inomencnt), reply->nomen_list[inomencnt].
    active_ind = n.active_ind,
    reply->nomen_list[inomencnt].concept_cki = n.concept_cki, reply->nomen_list[inomencnt].
    concept_identifier = n.concept_identifier, reply->nomen_list[inomencnt].concept_source_cd = n
    .concept_source_cd,
    reply->nomen_list[inomencnt].contributor_system_cd = n.contributor_system_cd, reply->nomen_list[
    inomencnt].language_cd = n.language_cd, reply->nomen_list[inomencnt].mnemonic = n.mnemonic,
    reply->nomen_list[inomencnt].nomenclature_id = n.nomenclature_id, reply->nomen_list[inomencnt].
    principle_type_cd = n.principle_type_cd, reply->nomen_list[inomencnt].short_string = n
    .short_string,
    reply->nomen_list[inomencnt].source_identifier = n.source_identifier, reply->nomen_list[inomencnt
    ].source_string = n.source_string, reply->nomen_list[inomencnt].source_vocabulary_cd = n
    .source_vocabulary_cd,
    reply->nomen_list[inomencnt].vocab_axis_cd = n.vocab_axis_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->nomen_list,inomencnt)
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = serrmsg
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ELSEIF (inomencnt=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "No records found"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "Success"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
 ENDIF
END GO
