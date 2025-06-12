CREATE PROGRAM cps_get_concept_def:dba
 RECORD reply(
   1 nomen[*]
     2 nomen_id = f8
     2 def_qual = i4
     2 def[*]
       3 definition = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->nomen,1)
 SET stat = alterlist(reply->nomen[1].def,1)
 SET reply->nomen[1].def_qual = 0
 SELECT DISTINCT INTO "NL:"
  n.nomenclature_id, def = substring(1,100,cd.definition)
  FROM nomenclature n,
   concept c,
   concept_definition cd,
   (dummyt d  WITH seq = value(size(request->nomen,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (n
   WHERE (n.nomenclature_id=request->nomen[d.seq].nomen_id))
   JOIN (c
   WHERE n.concept_identifier=c.concept_identifier
    AND n.concept_source_cd=c.concept_source_cd)
   JOIN (cd
   WHERE c.concept_identifier=cd.concept_identifier
    AND c.concept_source_cd=cd.concept_source_cd)
  ORDER BY n.nomenclature_id, def
  HEAD REPORT
   count1 = 0
  HEAD n.nomenclature_id
   count1 = (count1+ 1)
   IF (count1 >= size(reply->nomen,5))
    stat = alterlist(reply->nomen,(count1+ 10))
   ENDIF
   reply->nomen[count1].nomen_id = n.nomenclature_id, count2 = 0
  HEAD def
   count2 = (count2+ 1)
   IF (count2 >= size(reply->nomen[count1].def,5))
    stat = alterlist(reply->nomen[count1].def,(count2+ 10))
   ENDIF
   reply->nomen[count1].def[count2].definition = cd.definition
  FOOT  def
   stat = alterlist(reply->nomen[count1].def,count2), reply->nomen[count1].def_qual = count2
  FOOT  n.nomenclature_id
   stat = alterlist(reply->nomen,count1)
  WITH counter
 ;end select
END GO
