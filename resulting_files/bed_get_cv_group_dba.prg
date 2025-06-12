CREATE PROGRAM bed_get_cv_group:dba
 RECORD reply(
   1 parent_code_set = i4
   1 child_code_set = i4
   1 pcode[*]
     2 code = f8
     2 description = vc
     2 display = vc
     2 meaning = vc
     2 definition = vc
     2 collation_seq = i4
     2 ccode[*]
       3 code = f8
       3 description = vc
       3 display = vc
       3 meaning = vc
       3 definition = vc
       3 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET j = 0
 SET i = 0
 SELECT INTO "nl:"
  FROM code_value c1,
   code_value_group cvg,
   code_value c2
  PLAN (c1
   WHERE (c1.code_set=request->parent_code_set)
    AND c1.active_ind=1)
   JOIN (cvg
   WHERE cvg.parent_code_value=c1.code_value)
   JOIN (c2
   WHERE c2.code_value=cvg.child_code_value
    AND (c2.code_set=request->child_code_set)
    AND c2.active_ind=1)
  ORDER BY c1.code_value
  HEAD REPORT
   i = 0, j = 0, reply->parent_code_set = request->parent_code_set,
   reply->child_code_set = request->child_code_set
  HEAD c1.code_value
   i = (i+ 1), stat = alterlist(reply->pcode,i), reply->pcode[i].code = c1.code_value,
   reply->pcode[i].description = trim(c1.description,3), reply->pcode[i].display = trim(c1.display,3),
   reply->pcode[i].meaning = trim(c1.cdf_meaning,3),
   reply->pcode[i].definition = trim(c1.definition,3), reply->pcode[i].collation_seq = c1
   .collation_seq, j = 0
  DETAIL
   j = (j+ 1), stat = alterlist(reply->pcode[i].ccode,j), reply->pcode[i].ccode[j].code = c2
   .code_value,
   reply->pcode[i].ccode[j].description = trim(c2.description,3), reply->pcode[i].ccode[j].display =
   trim(c2.display,3), reply->pcode[i].ccode[j].meaning = trim(c2.cdf_meaning,3),
   reply->pcode[i].ccode[j].definition = trim(c2.definition,3), reply->pcode[i].ccode[j].
   collation_seq = c2.collation_seq
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
 CALL echorecord(reply)
END GO
