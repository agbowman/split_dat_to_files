CREATE PROGRAM bbt_get_code_ext_by_code:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
     2 code_value = f8
     2 display = c40
     2 cdf_meaning = c12
     2 ext_cnt = i4
     2 ext[*]
       3 field_name = vc
       3 field_type = i4
       3 field_value = vc
       3 updt_cnt = i4
       3 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET val_count = 0
 SET ext_count = 0
 SET nbr_in_array = size(request->codelist,5)
 SELECT INTO "nl:"
  cv.code_value, cv.code_set, cve.field_name,
  x = decode(cve.field_name,1,0), cve.field_type, y = decode(cve.field_value,1,0),
  cve.field_value, cv.display, cv.cdf_meaning,
  cve.updt_cnt, cva.display
  FROM code_value cv,
   (dummyt d  WITH seq = 1),
   code_value_extension cve,
   (dummyt d1  WITH seq = 1),
   code_value cva,
   (dummyt d2  WITH seq = value(nbr_in_array))
  PLAN (d2)
   JOIN (cv
   WHERE (cv.code_value=request->codelist[d2.seq].code_value)
    AND cv.active_ind=1
    AND cv.code_value != null
    AND cv.code_value > 0)
   JOIN (d
   WHERE d.seq=1)
   JOIN (cve
   WHERE cve.code_value=cv.code_value
    AND trim(cve.field_name) > " ")
   JOIN (d1)
   JOIN (cva
   WHERE cva.code_value != null
    AND cva.code_value > 0
    AND cve.field_type != 2
    AND trim(cve.field_value) > " "
    AND cnvtreal(cve.field_value)=cva.code_value)
  ORDER BY cv.code_value
  HEAD cv.code_value
   val_count = (val_count+ 1), ext_count = 0, stat = alterlist(reply->qual,val_count),
   stat = alterlist(reply->qual[val_count].ext,ext_count), reply->qual[val_count].code_set = cv
   .code_set, reply->qual[val_count].code_value = cv.code_value,
   reply->qual[val_count].display = cv.display, reply->qual[val_count].cdf_meaning = cv.cdf_meaning
  DETAIL
   IF (cve.field_name > " ")
    ext_count = (ext_count+ 1), stat = alterlist(reply->qual[val_count].ext,ext_count), reply->qual[
    val_count].ext[ext_count].field_name = cve.field_name,
    reply->qual[val_count].ext[ext_count].field_type = cve.field_type, reply->qual[val_count].ext[
    ext_count].field_value = cve.field_value, reply->qual[val_count].ext[ext_count].updt_cnt = cve
    .updt_cnt,
    reply->qual[val_count].ext[ext_count].display = cva.display
   ENDIF
  FOOT  cv.code_value
   reply->qual[val_count].ext_cnt = ext_count
  WITH nocounter, outerjoin = d, outerjoin = d1
 ;end select
 IF (val_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
