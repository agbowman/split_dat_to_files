CREATE PROGRAM bbt_get_question:dba
 RECORD reply(
   1 qual[*]
     2 module_cd = f8
     2 process_cd = f8
     2 question_cd = f8
     2 question_disp = c40
     2 question_desc = vc
     2 question_mean = c12
     2 question = vc
     2 sequence = i4
     2 response_flg = i2
     2 response_length = i4
     2 code_set = i4
     2 cs_cdf_meaning = c12
     2 active_ind = i2
     2 def_answer = vc
     2 dwb_ind = i2
     2 updt_cnt = i4
     2 response_qual[*]
       3 response_cd = f8
       3 response_disp = c40
       3 response_desc = vc
       3 response_mean = c12
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 DECLARE failed = c1 WITH protected, noconstant("F")
 DECLARE module_cd = f8 WITH public, noconstant(0.0)
 DECLARE process_cd = f8 WITH public, noconstant(0.0)
 IF ((request->module_meaning > " "))
  SET stat = uar_get_meaning_by_codeset(1660,request->module_meaning,1,module_cd)
  IF (module_cd=0.0)
   SET failed = "T"
   CALL subevent_add("UAR","F","1660","CANNOT GET MODULE CODE VALUE")
  ENDIF
 ELSE
  CALL subevent_add("Request","F","Module_meaning","Module meaning not passed")
 ENDIF
 IF ((request->process_meaning > " "))
  SET stat = uar_get_meaning_by_codeset(1662,request->process_meaning,1,process_cd)
  IF (process_cd=0.0)
   SET failed = "T"
   CALL subevent_add("UAR","F","1662","CANNOT GET PROCESS CODE VALUE")
  ENDIF
 ELSE
  CALL subevent_add("Request","F","Process_meaning","Process meaning not passed")
 ENDIF
 SELECT INTO "nl:"
  q.question_cd, r.response_cd
  FROM question q,
   valid_response r
  PLAN (q
   WHERE q.module_cd=module_cd
    AND q.process_cd=process_cd
    AND q.active_ind=1)
   JOIN (r
   WHERE outerjoin(q.module_cd)=r.module_cd
    AND outerjoin(q.process_cd)=r.process_cd
    AND outerjoin(q.question_cd)=r.question_cd)
  ORDER BY q.question_cd
  HEAD REPORT
   count1 = 0
  HEAD q.question_cd
   count2 = 0, count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].module_cd = q.module_cd, reply->qual[count1].process_cd = q.process_cd, reply
   ->qual[count1].question_cd = q.question_cd,
   reply->qual[count1].question = trim(q.question), reply->qual[count1].sequence = q.sequence, reply
   ->qual[count1].response_flg = q.response_flag,
   reply->qual[count1].response_length = q.response_length, reply->qual[count1].code_set = q.code_set,
   reply->qual[count1].cs_cdf_meaning = q.cdf_meaning,
   reply->qual[count1].active_ind = q.active_ind, reply->qual[count1].def_answer = trim(q.def_answer),
   reply->qual[count1].dwb_ind = q.dwb_ind,
   reply->qual[count1].updt_cnt = q.updt_cnt
  DETAIL
   IF (r.response_cd != 0.0)
    count2 = (count2+ 1)
    IF (mod(count2,10)=1)
     stat = alterlist(reply->qual[count1].response_qual,(count2+ 9))
    ENDIF
    reply->qual[count1].response_qual[count2].response_cd = r.response_cd, reply->qual[count1].
    response_qual[count2].updt_cnt = r.updt_cnt
   ENDIF
  FOOT  q.question_cd
   stat = alterlist(reply->qual[count1].response_qual,count2)
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "F"
 ENDIF
END GO
