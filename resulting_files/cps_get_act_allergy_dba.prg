CREATE PROGRAM cps_get_act_allergy:dba
 FREE SET reply
 RECORD reply(
   1 allergy_list_knt = i4
   1 allergy_list[*]
     2 allergy_instance_id = f8
     2 allergy_id = f8
     2 cki = vc
     2 source_identifier = vc
     2 source_vocab_mean = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET knt = 0
 SUBROUTINE parse_cki(cki)
   SET source_vocab = fillstring(100," ")
   SET source_ident = fillstring(100," ")
   SET source_vocab = trim(substring(1,(findstring("!",cki) - 1),cki))
   SET source_ident = trim(substring((findstring("!",cki)+ 1),(textlen(cki) - (findstring("!",cki) -
     1)),cki))
 END ;Subroutine
 SUBROUTINE build_cki(source_vocab,source_ident)
  SET cki = fillstring(100," ")
  SET cki = trim(concat(trim(source_vocab),"!",trim(source_ident)))
 END ;Subroutine
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET mul_algcat_cd = 0.0
 SET mul_drug_cd = 0.0
 SET reaction_status_cd = 0.0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET code_set = 12025
 SET code_value = 0.0
 SET cdf_meaning = "CANCELED"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET reaction_status_cd = code_value
 IF (code_value < 1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO end_program
 ENDIF
 SET code_set = 12100
 SET code_value = 0.0
 SET cdf_meaning = "MUL.ALGCAT"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET mul_algcat_cd = code_value
 IF (code_value < 1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO end_program
 ENDIF
 SET code_value = 0.0
 SET cdf_meaning = "MUL.DRUG"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET mul_drug_cd = code_value
 IF (code_value < 1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.allergy_id, n.concept_source_cd, concept_mean = uar_get_code_meaning(n.concept_source_cd)
  FROM allergy a,
   nomenclature n
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.substance_nom_id > 0
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND a.reaction_status_cd != reaction_status_cd)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id
    AND n.concept_source_cd IN (mul_algcat_cd, mul_drug_cd))
  HEAD REPORT
   knt = 0, stat = alterlist(reply->allergy_list,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->allergy_list,(knt+ 9))
   ENDIF
   reply->allergy_list[knt].allergy_instance_id = a.allergy_instance_id, reply->allergy_list[knt].
   allergy_id = a.allergy_id, reply->allergy_list[knt].description = n.source_string,
   CALL build_cki(concept_mean,n.concept_identifier), reply->allergy_list[knt].cki = cki, reply->
   allergy_list[knt].source_vocab_mean = concept_mean,
   reply->allergy_list[knt].source_identifier = n.concept_identifier
  FOOT REPORT
   reply->allergy_list_knt = knt, stat = alterlist(reply->allergy_list,knt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ORDERS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
#end_program
END GO
