CREATE PROGRAM bbt_get_dependency:dba
 RECORD reply(
   1 qual[*]
     2 dep_question_cd = f8
     2 dep_question_disp = c40
     2 dep_question_desc = vc
     2 dep_question_mean = c12
     2 dependent_qual[*]
       3 question_cd = f8
       3 question_disp = c40
       3 question_desc = vc
       3 question_mean = c12
       3 response_cd = f8
       3 response_disp = c40
       3 response_desc = vc
       3 response_mean = c12
       3 updt_cnt = i4
       3 answer_given = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET number_of_dependent = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_of_dependent)
 SELECT INTO "nl:"
  d.question_cd, d.depend_quest_cd, a.answer
  FROM (dummyt d1  WITH seq = value(number_of_dependent)),
   dependency d,
   answer a
  PLAN (d1)
   JOIN (d
   WHERE (d.module_cd=request->module_cd)
    AND (d.process_cd=request->process_cd)
    AND (d.depend_quest_cd=request->qual[d1.seq].dep_question_cd))
   JOIN (a
   WHERE outerjoin(d.question_cd)=a.question_cd
    AND a.active_ind=outerjoin(1))
  ORDER BY d.depend_quest_cd
  HEAD REPORT
   count1 = 0
  HEAD d.depend_quest_cd
   count2 = 0, count1 = (count1+ 1), reply->qual[count1].dep_question_cd = d.depend_quest_cd
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->qual[count1].dependent_qual,count2), reply->qual[
   count1].dependent_qual[count2].question_cd = d.question_cd,
   reply->qual[count1].dependent_qual[count2].response_cd = d.response_cd, reply->qual[count1].
   dependent_qual[count2].updt_cnt = d.updt_cnt, reply->qual[count1].dependent_qual[count2].
   answer_given = trim(a.answer)
  WITH nocounter
 ;end select
 IF ((reply->qual[1].dep_question_cd > 0))
  SET stat = alterlist(reply->qual,count1)
  SET reply->status_data.status = "S"
 ELSE
  SET stat = alterlist(reply->qual,0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
