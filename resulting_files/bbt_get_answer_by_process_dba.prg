CREATE PROGRAM bbt_get_answer_by_process:dba
 RECORD reply(
   1 process_qual[2]
     2 process_cd = f8
     2 process_disp = c40
     2 process_desc = c60
     2 process_mean = c12
     2 nbr_of_question = i4
     2 question_qual[1]
       3 question_cd = f8
       3 question_disp = c40
       3 question_desc = c60
       3 question_mean = c12
       3 response_flag = i2
       3 code_set = i4
       3 answer = vc
       3 code_value = f8
       3 oe_format_id = f8
       3 catalog_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_name = c25 WITH constant("bbt_get_answer_by_process")
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE questions_cs = i4 WITH protect, constant(1661)
 DECLARE comp_xm_ordrble_prompt_mean = c12 WITH protect, constant("ORDBL COMPXM")
 DECLARE comp_xm_ordrble_prompt_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ordbl_compxm_idx_hold = i4 WITH protect, noconstant(0)
 DECLARE bbtcompxm_idx_hold = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET max2 = 1
 SET number_of_process = size(request->process_qual,5)
 SET mod_cd = 0.0
 SET proc_cd[value(number_of_process)] = 0
 SET code_cnt = 1
 SET code_set = 1660
 SET cdf_meaning = request->module_mean
 SET mod_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,mod_cd)
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   (dummyt d  WITH seq = value(number_of_process))
  PLAN (d)
   JOIN (c
   WHERE c.code_set=1662
    AND (c.cdf_meaning=request->process_qual[d.seq].process_mean)
    AND c.active_ind=1)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1, proc_cd[count1] = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO resize_reply
 ENDIF
 SET comp_xm_ordrble_prompt_cd = uar_get_code_by("MEANING",questions_cs,nullterm(
   comp_xm_ordrble_prompt_mean))
 IF (comp_xm_ordrble_prompt_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve question code with meaning of ",trim(
    comp_xm_ordrble_prompt_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SELECT INTO "nl:"
  d1.seq, q.process_cd, q.response_flag,
  q.active_ind, q.code_set, d2.seq,
  answer_yn = decode(a.seq,"Y","N"), a.answer, a.active_ind,
  d3.seq, c.cdf_meaning, c.active_ind
  FROM (dummyt d1  WITH seq = value(number_of_process)),
   question q,
   (dummyt d2  WITH seq = 1),
   answer a,
   (dummyt d3  WITH seq = 1),
   code_value c
  PLAN (d1)
   JOIN (q
   WHERE q.module_cd=mod_cd
    AND (q.process_cd=proc_cd[d1.seq])
    AND q.active_ind=1)
   JOIN (d2)
   JOIN (a
   WHERE a.question_cd=q.question_cd
    AND a.module_cd=q.module_cd
    AND a.process_cd=q.process_cd
    AND a.active_ind=1)
   JOIN (d3)
   JOIN (c
   WHERE ((c.code_set=q.code_set
    AND q.code_set > 0
    AND q.response_flag=0) OR (c.code_set=1659
    AND q.response_flag=1))
    AND trim(cnvtstring(c.code_value))=trim(a.answer)
    AND c.active_ind=1)
  ORDER BY q.process_cd
  HEAD REPORT
   count1 = 0, max2 = 1
  HEAD q.process_cd
   IF (q.active_ind=1)
    count2 = 0, count1 += 1
    IF (mod(count1,2)=1
     AND count1 != 1)
     stat = alter(reply->process_qual,(count1+ 1))
    ENDIF
    reply->process_qual[count1].process_cd = q.process_cd
   ENDIF
  DETAIL
   IF (q.active_ind=1
    AND a.active_ind=1)
    count2 += 1
    IF (count2 > max2)
     max2 = count2, stat = alter(reply->process_qual.question_qual,max2)
    ENDIF
    reply->process_qual[count1].nbr_of_question = count2, reply->process_qual[count1].question_qual[
    count2].question_cd = q.question_cd, reply->process_qual[count1].question_qual[count2].
    response_flag = q.response_flag,
    reply->process_qual[count1].question_qual[count2].code_set = q.code_set
    IF (answer_yn="Y")
     IF (((q.response_flag=0) OR (q.response_flag=1)) )
      reply->process_qual[count1].question_qual[count2].answer = c.cdf_meaning, reply->process_qual[
      count1].question_qual[count2].code_value = c.code_value
     ELSE
      reply->process_qual[count1].question_qual[count2].answer = trim(a.answer), reply->process_qual[
      count1].question_qual[count2].code_value = 0
     ENDIF
    ELSE
     reply->process_qual[count1].question_qual[count2].answer = " ", reply->process_qual[count1].
     question_qual[count2].code_value = 0
    ENDIF
    IF (q.question_cd=comp_xm_ordrble_prompt_cd)
     bbtcompxm_idx_hold = count1, ordbl_compxm_idx_hold = count2
    ENDIF
   ENDIF
  FOOT  q.process_cd
   row + 0
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, dontcare = c, dontcare = a
 ;end select
 IF (comp_xm_ordrble_prompt_cd > 0.0)
  IF (ordbl_compxm_idx_hold > 0)
   IF ((reply->process_qual[bbtcompxm_idx_hold].question_qual[ordbl_compxm_idx_hold].code_value > 0))
    SELECT INTO "nl:"
     oc.oe_format_id, oc.catalog_type_cd
     FROM order_catalog oc
     WHERE (oc.catalog_cd=reply->process_qual[bbtcompxm_idx_hold].question_qual[ordbl_compxm_idx_hold
     ].code_value)
     DETAIL
      reply->process_qual[bbtcompxm_idx_hold].question_qual[ordbl_compxm_idx_hold].oe_format_id = oc
      .oe_format_id, reply->process_qual[bbtcompxm_idx_hold].question_qual[ordbl_compxm_idx_hold].
      catalog_type_cd = oc.catalog_type_cd
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select order_catalog",errmsg)
    ENDIF
    IF (curqual=0)
     CALL errorhandler("F","Select order_catalog","Failed to qualify on order_catalog table.")
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO resize_reply
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#resize_reply
 IF (curqual > 0)
  SET stat = alter(reply->process_qual,count1)
  SET reply->status_data.status = "S"
 ELSE
  SET stat = alter(reply->process_qual,1)
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
