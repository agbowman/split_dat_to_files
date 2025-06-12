CREATE PROGRAM act_get_nomenclature_nka:dba
 RECORD reply(
   1 qual[*]
     2 value = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE pcode = f8
 DECLARE vcode = f8
 DECLARE stat = i4
 SET stat = uar_get_meaning_by_codeset(401,"ALLERGY",1,pcode)
 SET stat = uar_get_meaning_by_codeset(400,"ALLERGY",1,vcode)
 SELECT INTO "nl:"
  FROM nomenclature n
  PLAN (n
   WHERE n.source_vocabulary_cd=vcode
    AND n.principle_type_cd=pcode
    AND n.active_ind=1)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].value = n.nomenclature_id,
   reply->qual[cnt].name = n.source_string
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
