CREATE PROGRAM cps_chk_dupl_dx
 FREE SET reply
 RECORD reply(
   1 dupl_level = i2
   1 dupl_source_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD hold(
   1 source_vocab_cd = f8
   1 source_identifier = vc
 )
 SET duplnone = 0
 SET duplnomid = 1
 SET duplsrccode = 2
 SET reply->dupl_level = duplnone
 SET reply->dupl_source_string = ""
 SET reply->status_data[1].status = "F"
 IF ((request->nomenclature_id <= 0))
  SET reply->dupl_level = duplnone
  GO TO end_program
 ENDIF
 SELECT INTO "NL:"
  d.person_id, d.encntr_id, d.nomenclature_id
  FROM diagnosis d
  PLAN (d
   WHERE (d.person_id=request->person_id)
    AND (d.encntr_id=request->encntr_id)
    AND (d.nomenclature_id=request->nomenclature_id)
    AND d.active_ind=1)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->dupl_level = duplnomid
  GO TO end_program
 ENDIF
 SET hold->source_vocab_cd = 0.0
 SET hold->source_identifier = ""
 SELECT INTO "NL:"
  FROM nomenclature n
  PLAN (n
   WHERE (n.nomenclature_id=request->nomenclature_id))
  DETAIL
   hold->source_vocab_cd = n.source_vocabulary_cd, hold->source_identifier = n.source_identifier
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE (d.person_id=request->person_id)
    AND (d.encntr_id=request->encntr_id)
    AND d.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
  DETAIL
   IF ((n.source_vocabulary_cd=hold->source_vocab_cd)
    AND (n.source_identifier=hold->source_identifier))
    reply->dupl_level = duplsrccode, reply->dupl_source_string = n.source_string
   ENDIF
  WITH nocounter
 ;end select
#end_program
 SET reply->status_data.status = "S"
END GO
