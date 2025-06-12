CREATE PROGRAM bbt_get_answer:dba
 RECORD reply(
   1 process_qual[2]
     2 process_cd = f8
     2 process_disp = c40
     2 process_desc = vc
     2 process_mean = c12
     2 question_qual[1]
       3 question_cd = f8
       3 question_disp = c40
       3 question_desc = vc
       3 question_mean = c12
       3 answer_id = f8
       3 answer = vc
       3 updt_cnt = i4
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
 SET max2 = 1
 SET number_of_process = size(request->process_qual,5)
 SET number_of_question = size(request->process_qual.question_qual,5)
 SELECT INTO "nl:"
  a.answer_id, a.question_cd, a.process_cd
  FROM (dummyt d1  WITH seq = value(number_of_process)),
   (dummyt d2  WITH seq = value(number_of_question)),
   answer a
  PLAN (d1)
   JOIN (d2)
   JOIN (a
   WHERE (a.module_cd=request->module_cd)
    AND (a.process_cd=request->process_qual[d1.seq].process_cd)
    AND (a.question_cd=request->process_qual[d1.seq].question_qual[d2.seq].question_cd)
    AND a.active_ind=1)
  ORDER BY a.process_cd
  HEAD REPORT
   count1 = 0, max2 = 1
  HEAD a.process_cd
   count2 = 0, count1 = (count1+ 1)
   IF (mod(count1,2)=1
    AND count1 != 1)
    stat = alter(reply->process_qual,(count1+ 1))
   ENDIF
   reply->process_qual[count1].process_cd = a.process_cd
  DETAIL
   count2 = (count2+ 1)
   IF (count2 > max2)
    max2 = count2, stat = alter(reply->process_qual.question_qual,max2)
   ENDIF
   reply->process_qual[count1].question_qual[count2].question_cd = a.question_cd, reply->
   process_qual[count1].question_qual[count2].answer_id = a.answer_id, reply->process_qual[count1].
   question_qual[count2].answer = trim(a.answer),
   reply->process_qual[count1].question_qual[count2].updt_cnt = a.updt_cnt
  WITH nocounter
 ;end select
 IF ((reply->process_qual[1].process_cd > 0))
  SET stat = alter(reply->process_qual,count1)
  SET reply->status_data.status = "S"
 ELSE
  SET stat = alter(reply->process_qual,0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
