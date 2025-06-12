CREATE PROGRAM cva_chk_for_dup_inbound:dba
 RECORD reply(
   1 qual[*]
     2 alias = vc
     2 alias_type_meaning = c12
     2 alias_exists_ind = i2
     2 alias_identifier = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET num_als = size(request->qual,5)
 SET stat = alterlist(reply->qual,num_als)
 SELECT INTO "nl:"
  is_there = decode(a.seq,1,0), a.alias, a.alias_type_meaning
  FROM (dummyt d  WITH seq = value(num_als)),
   code_value_alias a
  PLAN (d)
   JOIN (a
   WHERE (request->qual[d.seq].alias=a.alias)
    AND (request->code_set=a.code_set)
    AND (request->contributor_source_cd=a.contributor_source_cd))
  DETAIL
   reply->qual[d.seq].alias = request->qual[d.seq].alias, reply->qual[d.seq].alias_type_meaning =
   request->qual[d.seq].alias_type_meaning, reply->qual[d.seq].alias_exists_ind = is_there,
   reply->qual[d.seq].alias_identifier = request->qual[d.seq].alias_identifier
  WITH outerjoin = d
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
