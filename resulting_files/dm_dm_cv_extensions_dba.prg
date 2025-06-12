CREATE PROGRAM dm_dm_cv_extensions:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 field_name = vc
     2 field_type = i4
     2 field_value = vc
     2 field_seq = i4
     2 updt_cnt = i4
     2 cki = vc
     2 delete_ind = i2
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
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "NL:"
  dcv.schema_date
  FROM dm_adm_code_set_extension dcf,
   dm_adm_code_value_extension dcv
  WHERE (dcf.code_set=request->code_set)
   AND dcf.code_set=dcv.code_set
  DETAIL
   IF ((dcf.schema_date > r1->rdate))
    r1->rdate = dcf.schema_date
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.cki, cve.code_value, cve.code_set,
  cve.field_name, cve.field_type, cve.field_value,
  cve.updt_cnt, cve.delete_ind
  FROM dm_adm_code_set_extension cse,
   dm_adm_code_value_extension cve,
   dm_adm_code_value cv
  WHERE cve.code_value > 0
   AND cve.code_set=cse.code_set
   AND (cse.code_set=request->code_set)
   AND cve.field_name=cse.field_name
   AND datetimediff(cve.schema_date,cnvtdatetime(r1->rdate))=0
   AND cv.code_value=cve.code_value
   AND datetimediff(cv.schema_date,cnvtdatetime(r1->rdate))=0
  ORDER BY cve.code_value
  DETAIL
   ext_count = (ext_count+ 1), stat = alterlist(reply->qual,ext_count), reply->qual[ext_count].
   code_value = cve.code_value,
   reply->qual[ext_count].field_name = cve.field_name, reply->qual[ext_count].field_type = cve
   .field_type, reply->qual[ext_count].field_value = cve.field_value,
   reply->qual[ext_count].cki = cv.cki, reply->qual[ext_count].field_seq = cse.field_seq, reply->
   qual[ext_count].updt_cnt = cve.updt_cnt,
   reply->qual[ext_count].delete_ind = cve.delete_ind
  WITH nocounter
 ;end select
 IF (ext_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
