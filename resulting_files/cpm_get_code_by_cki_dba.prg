CREATE PROGRAM cpm_get_code_by_cki:dba
 RECORD reply(
   1 value_cd = f8
   1 code_set = i4
   1 collation_seq = i4
   1 code_disp = vc
   1 code_descr = vc
   1 meaning = vc
   1 display_key = vc
   1 cki = vc
   1 concept_cki = vc
   1 definition = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value c
  WHERE (c.cki=request->cki)
  DETAIL
   reply->value_cd = c.code_value, reply->code_set = c.code_set, reply->collation_seq = c
   .collation_seq,
   reply->code_disp = c.display, reply->code_descr = c.description, reply->meaning = c.cdf_meaning,
   reply->display_key = c.display_key, reply->cki = c.cki, reply->concept_cki = c.concept_cki,
   reply->definition = c.definition,
   CALL echo(build("code_value: ",c.code_value)),
   CALL echo(build("code_set: ",c.code_set))
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  CALL echo(build("cki: ",request->cki," doesn't exist"))
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("status: ",reply->status_data.status))
END GO
