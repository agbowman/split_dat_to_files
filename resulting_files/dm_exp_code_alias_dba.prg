CREATE PROGRAM dm_exp_code_alias:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
     2 cki = vc
     2 contributor_source_disp = c100
     2 contributor_source_cd = f8
     2 alias = c100
     2 code_set = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET index = 0
 SELECT INTO "nl:"
  cv.code_value, cv.display, cv.cki,
  cva.contributor_source_cd, cva.alias, cva.code_set
  FROM code_value cv,
   (dummyt d  WITH seq = 1),
   code_value_alias cva,
   (dummyt d2  WITH seq = value(size(request->qual,5)))
  PLAN (d2)
   JOIN (cv
   WHERE (cv.code_set=request->qual[d2.seq].code_set)
    AND cv.active_ind=1)
   JOIN (d)
   JOIN (cva
   WHERE cva.code_value=cv.code_value
    AND (cva.contributor_source_cd=request->contributor_source_cd)
    AND cva.code_set=cv.code_set)
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].code_value = cv
   .code_value,
   reply->qual[index].display = cv.display, reply->qual[index].cki = cv.cki, reply->qual[index].
   contributor_source_disp = request->contributor_source_disp,
   reply->qual[index].contributor_source_cd = request->contributor_source_cd, reply->qual[index].
   alias = cva.alias, reply->qual[index].code_set = cv.code_set
  WITH nocounter, outerjoin = d
 ;end select
 IF (index != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
