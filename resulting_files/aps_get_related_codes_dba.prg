CREATE PROGRAM aps_get_related_codes:dba
 RECORD reply(
   1 qual[10]
     2 nomenclature_id = f8
     2 group_nbr = i4
     2 related_qual[*]
       3 nomenclature_id = f8
       3 source_identifier = vc
       3 source_string = vc
       3 source_vocabulary_cd = f8
       3 source_vocabulary_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET inputsize = cnvtint(size(request->qual,5))
 SET stat = alter(reply->qual,inputsize)
 SET x = 0
 SET relatedcnt = 0
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = value(inputsize))
  DETAIL
   reply->qual[d1.seq].nomenclature_id = request->qual[d1.seq].nomenclature_id, reply->qual[d1.seq].
   group_nbr = request->qual[d1.seq].group_nbr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  n.nomenclature_id, n1.nomenclature_id, vrc.vocab_rel_code_id,
  source_vocab_display = uar_get_code_display(n1.source_vocabulary_cd), d2.seq
  FROM (dummyt d2  WITH seq = value(inputsize)),
   nomenclature n,
   vocab_related_code vrc,
   nomenclature n1
  PLAN (d2)
   JOIN (n
   WHERE (n.nomenclature_id=request->qual[d2.seq].nomenclature_id))
   JOIN (vrc
   WHERE vrc.source_identifier=n.source_identifier
    AND vrc.source_vocab_cd=n.source_vocabulary_cd
    AND vrc.active_ind=1
    AND vrc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND vrc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (n1
   WHERE n1.source_vocabulary_cd=vrc.related_vocab_cd
    AND n1.source_identifier=vrc.related_identifier
    AND n1.active_ind=1
    AND n1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d2.seq
  HEAD d2.seq
   relatedcnt = 0
  DETAIL
   relatedcnt = (relatedcnt+ 1)
   IF (mod(relatedcnt,5)=1)
    stat = alterlist(reply->qual[d2.seq].related_qual,(relatedcnt+ 4))
   ENDIF
   reply->qual[d2.seq].related_qual[relatedcnt].nomenclature_id = n1.nomenclature_id, reply->qual[d2
   .seq].related_qual[relatedcnt].source_identifier = n1.source_identifier, reply->qual[d2.seq].
   related_qual[relatedcnt].source_string = n1.source_string,
   reply->qual[d2.seq].related_qual[relatedcnt].source_vocabulary_cd = n1.source_vocabulary_cd, reply
   ->qual[d2.seq].related_qual[relatedcnt].source_vocabulary_display = source_vocab_display
  FOOT  d2.seq
   stat = alterlist(reply->qual[d2.seq].related_qual,relatedcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMENCLATURE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
