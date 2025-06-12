CREATE PROGRAM dm_get_cv_cvextensions:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 cki = vc
     2 ext_cnt = i4
     2 ext[*]
       3 field_name = vc
       3 field_type = i4
       3 field_value = vc
       3 field_seq = i4
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET val_count = 0
 SET ext_count = 0
 SET max_ext = 1
 SET nbr_to_get = cnvtint(size(request->qual,5))
 SELECT INTO "nl:"
  cse.field_seq, cve.code_value, cve.code_set,
  cve.field_name, cve.field_type, cve.field_value,
  cve.updt_cnt, cv.cki
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   code_set_extension cse,
   code_value cv,
   code_value_extension cve
  PLAN (d)
   JOIN (cse
   WHERE (cse.code_set=request->code_set))
   JOIN (cve
   WHERE cve.field_name=cse.field_name
    AND cve.code_set=cse.code_set
    AND (cve.code_value=request->qual[d.seq].code_value))
   JOIN (cv
   WHERE cv.code_value=cve.code_value)
  ORDER BY cve.code_value, cse.field_seq
  HEAD cve.code_value
   val_count = (val_count+ 1), stat = alterlist(reply->qual,val_count), reply->qual[val_count].
   code_value = cve.code_value,
   reply->qual[val_count].cki = cv.cki, ext_count = 0
  DETAIL
   ext_count = (ext_count+ 1), stat = alterlist(reply->qual[val_count].ext,ext_count), reply->qual[
   val_count].ext[ext_count].field_name = cve.field_name,
   reply->qual[val_count].ext[ext_count].field_type = cve.field_type, reply->qual[val_count].ext[
   ext_count].field_value = cve.field_value, reply->qual[val_count].ext[ext_count].field_seq = cse
   .field_seq,
   reply->qual[val_count].ext[ext_count].updt_cnt = cve.updt_cnt
  FOOT  cve.code_value
   reply->qual[val_count].ext_cnt = ext_count
  WITH nocounter
 ;end select
 IF (val_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
