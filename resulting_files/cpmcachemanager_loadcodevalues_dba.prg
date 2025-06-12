CREATE PROGRAM cpmcachemanager_loadcodevalues:dba
 RECORD reply(
   1 codevaluelist[*]
     2 code_set = i4
     2 cache_ind = i2
     2 value_cd = f8
     2 active_ind = i2
     2 collation_seq = i4
     2 code_disp = vc
     2 code_descr = vc
     2 meaning = vc
     2 display_key = vc
     2 cki = vc
     2 concept_cki = vc
     2 definition = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET valid_rec
 RECORD valid_rec(
   1 qual[*]
     2 valid_ind = i2
 )
 DECLARE count = i4
 SET count = 0
 SET reply->status_data.status = "F"
 DECLARE count1 = i4
 SET count1 = 1
 DECLARE listsize = i4
 SET listsize = value(size(request->codevaluelist,5))
 DECLARE num = i4 WITH noconstant(1)
 IF (listsize > 0)
  SET status = alterlist(valid_rec->qual,listsize)
  SET status = alterlist(reply->codevaluelist,1)
  SELECT INTO "nl:"
   FROM code_value c,
    code_value_set cs
   PLAN (c
    WHERE expand(num,1,listsize,c.code_value,request->codevaluelist[num].code_value))
    JOIN (cs
    WHERE cs.code_set=c.code_set)
   DETAIL
    locval = locateval(num,1,listsize,c.code_value,request->codevaluelist[num].code_value), valid_rec
    ->qual[locval].valid_ind = 1, count = (count+ 1),
    stat = alterlist(reply->codevaluelist,count), reply->codevaluelist[count].code_set = c.code_set,
    reply->codevaluelist[count].cache_ind = cs.cache_ind,
    reply->codevaluelist[count].value_cd = c.code_value, reply->codevaluelist[count].active_ind = c
    .active_ind, reply->codevaluelist[count].collation_seq = c.collation_seq,
    reply->codevaluelist[count].code_disp = c.display, reply->codevaluelist[count].code_descr = c
    .description, reply->codevaluelist[count].meaning = c.cdf_meaning,
    reply->codevaluelist[count].display_key = c.display_key, reply->codevaluelist[count].cki = c.cki,
    reply->codevaluelist[count].concept_cki = c.concept_cki,
    reply->codevaluelist[count].definition = c.definition,
    CALL echo(build("codevalue: ",reply->codevaluelist[count].value_cd)),
    CALL echo(build("codeset: ",reply->codevaluelist[count].code_set))
   WITH nocounter
  ;end select
  FOR (count1 = 1 TO listsize)
   CALL echo(build("codevalue: ",request->codevaluelist[count1].code_value))
   IF ((valid_rec->qual[count1].valid_ind=0))
    CALL echo(build("code value",request->codevaluelist[count1].code_value,"does not exist!!!!!"))
   ENDIF
  ENDFOR
 ENDIF
 CALL echo(build("alterlist reply->codevaluelist: ",count))
 SET replysize = value(size(reply->codevaluelist,5))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
