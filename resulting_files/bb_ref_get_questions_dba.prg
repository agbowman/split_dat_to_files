CREATE PROGRAM bb_ref_get_questions:dba
 RECORD reply(
   1 question[*]
     2 module_cd = f8
     2 module_display = vc
     2 module_meaning = vc
     2 process_cd = f8
     2 process_display = vc
     2 process_meaning = vc
     2 question_cd = f8
     2 question_meaning = vc
     2 question = vc
     2 response_length = i4
     2 response_type = i2
     2 code_set = i4
     2 default_answer_cd = f8
     2 default_answer_meaning = vc
     2 default_answer_alpha = vc
     2 default_answer_numeric = i4
     2 default_answer_boolean = i2
     2 answer[*]
       3 answer_cd = f8
       3 answer_disp = c40
       3 answer_desc = c60
       3 answer_mean = c12
       3 answer_meaning = vc
       3 answer_alpha = vc
       3 answer_numeric = i4
       3 answer_boolean = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nrequestsize = i2
 DECLARE nidx = i2
 DECLARE nanswercnt = i2
 SET codeset = 0
 SET responsecode = 1
 SET numeric = 2
 SET alphanumeric = 3
 SET boolean = 4
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET nrequestsize = size(request->qual,5)
 SET stat = alterlist(reply->question,nrequestsize)
 FOR (nidx = 1 TO nrequestsize)
   SET reply->question[nidx].question_meaning = request->qual[nidx].cdf_meaning
   SET stat = uar_get_meaning_by_codeset(1661,request->qual[nidx].cdf_meaning,1,reply->question[nidx]
    .question_cd)
   IF ((reply->question[nidx].question_cd=0))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("Code lookup for question ",
     request->qual[nidx].cdf_meaning,"failed")
    GO TO exit_script
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  *
  FROM question q,
   answer a,
   (dummyt d1  WITH seq = value(nrequestsize))
  PLAN (d1)
   JOIN (q
   WHERE (q.question_cd=reply->question[d1.seq].question_cd)
    AND q.active_ind=1)
   JOIN (a
   WHERE q.question_cd=a.question_cd
    AND a.active_ind=1)
  ORDER BY q.question_cd
  HEAD q.question_cd
   reply->question[d1.seq].module_cd = q.module_cd, reply->question[d1.seq].module_display =
   uar_get_code_display(q.module_cd), reply->question[d1.seq].module_meaning = uar_get_code_meaning(q
    .module_cd),
   reply->question[d1.seq].process_cd = q.process_cd, reply->question[d1.seq].process_display =
   uar_get_code_display(q.process_cd), reply->question[d1.seq].process_meaning = uar_get_code_meaning
   (q.process_cd),
   reply->question[d1.seq].question = q.question, reply->question[d1.seq].response_length = q
   .response_length, reply->question[d1.seq].response_type = q.response_flag,
   reply->question[d1.seq].code_set = q.code_set, nanswercnt = 0
  DETAIL
   nanswercnt = (nanswercnt+ 1), stat = alterlist(reply->question[d1.seq].answer,nanswercnt)
   IF (((q.response_flag=responsecode) OR (q.response_flag=codeset)) )
    IF (trim(q.def_answer)="")
     reply->question[d1.seq].default_answer_cd = 0, reply->question[d1.seq].default_answer_meaning =
     ""
    ELSE
     reply->question[d1.seq].default_answer_cd = cnvtreal(q.def_answer)
     IF ((reply->question[d1.seq].default_answer_cd=0))
      reply->question[d1.seq].default_answer_meaning = ""
     ELSE
      reply->question[d1.seq].default_answer_meaning = uar_get_code_meaning(cnvtreal(q.def_answer))
     ENDIF
    ENDIF
    IF (trim(a.answer)="")
     reply->question[d1.seq].answer[nanswercnt].answer_cd = 0
    ELSE
     reply->question[d1.seq].answer[nanswercnt].answer_cd = cnvtreal(a.answer)
     IF ((reply->question[d1.seq].answer[nanswercnt].answer_cd=0))
      reply->question[d1.seq].answer[nanswercnt].answer_meaning = ""
     ELSE
      reply->question[d1.seq].answer[nanswercnt].answer_meaning = uar_get_code_meaning(cnvtreal(a
        .answer))
     ENDIF
    ENDIF
   ELSEIF (q.response_flag IN (alphanumeric, 5))
    reply->question[d1.seq].default_answer_alpha = q.def_answer, reply->question[d1.seq].answer[
    nanswercnt].answer_alpha = a.answer
   ELSEIF (q.response_flag=numeric)
    IF (trim(q.def_answer)="")
     reply->question[d1.seq].default_answer_numeric = 0
    ELSE
     reply->question[d1.seq].default_answer_numeric = cnvtint(q.def_answer)
    ENDIF
    IF (trim(a.answer)="")
     reply->question[d1.seq].answer[nanswercnt].answer_numeric = 0
    ELSE
     reply->question[d1.seq].answer[nanswercnt].answer_numeric = cnvtint(a.answer)
    ENDIF
   ELSEIF (q.response_flag=boolean)
    IF (trim(q.def_answer)="1")
     reply->question[d1.seq].default_answer_boolean = 1
    ELSE
     reply->question[d1.seq].default_answer_boolean = 0
    ENDIF
    IF (trim(a.answer)="1")
     reply->question[d1.seq].answer[nanswercnt].answer_boolean = 1
    ELSE
     reply->question[d1.seq].answer[nanswercnt].answer_boolean = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
