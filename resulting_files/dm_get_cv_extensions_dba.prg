CREATE PROGRAM dm_get_cv_extensions:dba
 RECORD reply(
   1 qual[1]
     2 code_value = f8
     2 cki = vc
     2 ext_cnt = i4
     2 ext[1]
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
 IF ((request->cv_mode=0))
  SELECT INTO "nl:"
   cv.cki, cse.field_seq, cve.code_value,
   cve.code_set, cve.field_name, cve.field_type,
   cve.field_value, cve.updt_cnt
   FROM code_set_extension cse,
    code_value_extension cve,
    code_value cv
   PLAN (cse
    WHERE (cse.code_set=request->code_set))
    JOIN (cve
    WHERE cve.code_value > 0
     AND cve.field_name=cse.field_name
     AND cve.code_set=cse.code_set)
    JOIN (cv
    WHERE cve.code_value=cv.code_value)
   ORDER BY cve.code_value
   HEAD cve.code_value
    val_count = (val_count+ 1)
    IF (mod(val_count,10)=2)
     stat = alter(reply->qual,(val_count+ 9))
    ENDIF
    reply->qual[val_count].code_value = cve.code_value, reply->qual[val_count].cki = cv.cki,
    ext_count = 0
   DETAIL
    ext_count = (ext_count+ 1)
    IF (ext_count > max_ext)
     max_ext = ext_count, stat = alter(reply->qual.ext,max_ext)
    ENDIF
    reply->qual[val_count].ext[ext_count].field_name = cve.field_name, reply->qual[val_count].ext[
    ext_count].field_type = cve.field_type, reply->qual[val_count].ext[ext_count].field_value = cve
    .field_value,
    reply->qual[val_count].ext[ext_count].field_seq = cse.field_seq, reply->qual[val_count].ext[
    ext_count].updt_cnt = cve.updt_cnt
   FOOT  cve.code_value
    reply->qual[val_count].ext_cnt = ext_count
   WITH nocounter, outerjoin = d
  ;end select
 ELSE
  SELECT INTO "nl:"
   cv.cki, cse.field_seq, cve.code_value,
   cve.code_set, cve.field_name, cve.field_type,
   cve.field_value, cve.updt_cnt
   FROM code_set_extension cse,
    code_value_extension cve,
    code_value cv
   PLAN (cse
    WHERE (cse.code_set=request->code_set))
    JOIN (cve
    WHERE cve.code_value > 0
     AND cve.field_name=cse.field_name
     AND cve.code_set=cse.code_set)
    JOIN (cv
    WHERE cve.code_value=cv.code_value
     AND cv.active_ind=1)
   ORDER BY cve.code_value
   HEAD cve.code_value
    val_count = (val_count+ 1)
    IF (mod(val_count,10)=2)
     stat = alter(reply->qual,(val_count+ 9))
    ENDIF
    reply->qual[val_count].cki = cv.cki, reply->qual[val_count].code_value = cve.code_value,
    ext_count = 0
   DETAIL
    ext_count = (ext_count+ 1)
    IF (ext_count > max_ext)
     max_ext = ext_count, stat = alter(reply->qual.ext,max_ext)
    ENDIF
    reply->qual[val_count].ext[ext_count].field_name = cve.field_name, reply->qual[val_count].ext[
    ext_count].field_type = cve.field_type, reply->qual[val_count].ext[ext_count].field_value = cve
    .field_value,
    reply->qual[val_count].ext[ext_count].field_seq = cse.field_seq, reply->qual[val_count].ext[
    ext_count].updt_cnt = cve.updt_cnt
   FOOT  cve.code_value
    reply->qual[val_count].ext_cnt = ext_count
   WITH nocounter
  ;end select
 ENDIF
 IF (val_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,val_count)
  SET reply->status_data.status = "S"
 ENDIF
END GO
