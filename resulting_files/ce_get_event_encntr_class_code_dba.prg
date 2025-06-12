CREATE PROGRAM ce_get_event_encntr_class_code:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e
  PLAN (ce
   WHERE (ce.event_id=request->event_id)
    AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
   JOIN (e
   WHERE expand(num,1,size(request->encntr_class_list,5),e.encntr_type_class_cd,request->
    encntr_class_list[num].encntr_class_type_cd)
    AND e.encntr_id=ce.encntr_id
    AND e.active_ind=1)
  DETAIL
   cnt += 1, reply->encntr_type_class_cd = e.encntr_type_class_cd
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
