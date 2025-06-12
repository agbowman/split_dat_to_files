CREATE PROGRAM aps_get_snomed_synonyms:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 nomenclature_id = f8
     2 description = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  nom1.source_identifier, nom1.source_vocabulary_cd, nom1.source_string,
  requested_code_ind = evaluate(nom1.source_identifier,request->qual[d.seq].source_identifier,1,0)
  FROM nomenclature nom,
   nomenclature nom1,
   (dummyt d  WITH seq = size(request->qual,5))
  PLAN (d)
   JOIN (nom
   WHERE ((nom.source_vocabulary_cd+ 0)=request->qual[d.seq].source_vocabulary_cd)
    AND (nom.source_identifier=request->qual[d.seq].source_identifier))
   JOIN (nom1
   WHERE trim(nom1.concept_cki) != ""
    AND nom1.concept_cki=nom.concept_cki
    AND nom1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND nom1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, requested_code_ind DESC, nom1.primary_vterm_ind DESC,
   nom1.source_identifier
  HEAD REPORT
   cnt_synonyms = 0
  DETAIL
   cnt_synonyms = (cnt_synonyms+ 1)
   IF (cnt_synonyms > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt_synonyms+ 9))
   ENDIF
   reply->qual[cnt_synonyms].nomenclature_id = nom1.nomenclature_id, reply->qual[cnt_synonyms].
   description = trim(nom1.source_string), reply->qual[cnt_synonyms].active_ind = nom1.active_ind,
   reply->qual[cnt_synonyms].beg_effective_dt_tm = cnvtdatetime(nom1.beg_effective_dt_tm), reply->
   qual[cnt_synonyms].end_effective_dt_tm = cnvtdatetime(nom1.end_effective_dt_tm), reply->qual[
   cnt_synonyms].source_vocabulary_cd = nom1.source_vocabulary_cd,
   reply->qual[cnt_synonyms].source_identifier = trim(nom1.source_identifier), reply->qual[
   cnt_synonyms].concept_cki = trim(nom1.concept_cki)
  FOOT REPORT
   stat = alterlist(reply->qual,cnt_synonyms)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL subevent_add("SELECT","F","NOMENCLATURE","No codes qualified.")
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
