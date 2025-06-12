CREATE PROGRAM cdi_get_encntr_details:dba
 RECORD reply(
   1 encntr_list[*]
     2 encntr_id = f8
     2 encntr_type_cd = f8
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 aliases[*]
       3 alias_type_cd = f8
       3 alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE encntr_req_cnt = i4 WITH noconstant(value(size(request->encntr_list,5))), protect
 DECLARE alias_req_cnt = i4 WITH noconstant(value(size(request->alias_types,5))), protect
 DECLARE n1 = i4 WITH noconstant(0), protect
 DECLARE n2 = i4 WITH noconstant(0), protect
 SET i = 0
 SET encntr_cnt = 0
 SET alias_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  e.encntr_id, e.encntr_type_cd, e.reg_dt_tm,
  e.disch_dt_tm, ea.alias_type_cd, ea.alias,
  ea.alias_pool_cd
  FROM encounter e,
   encntr_alias ea
  PLAN (e
   WHERE expand(n1,1,encntr_req_cnt,e.encntr_id,request->encntr_list[n1].encntr_id))
   JOIN (ea
   WHERE ((e.encntr_id=ea.encntr_id
    AND expand(n2,1,alias_req_cnt,ea.encntr_alias_type_cd,request->alias_types[n2].alias_type_cd))
    OR (ea.encntr_alias_id=0)) )
  ORDER BY e.encntr_id
  HEAD REPORT
   encntr_cnt = 0
  HEAD e.encntr_id
   encntr_cnt = (encntr_cnt+ 1)
   IF (mod(encntr_cnt,10)=1)
    stat = alterlist(reply->encntr_list,(encntr_cnt+ 9))
   ENDIF
   reply->encntr_list[encntr_cnt].encntr_id = e.encntr_id, reply->encntr_list[encntr_cnt].
   encntr_type_cd = e.encntr_type_cd, reply->encntr_list[encntr_cnt].reg_dt_tm = e.reg_dt_tm,
   reply->encntr_list[encntr_cnt].disch_dt_tm = e.disch_dt_tm, alias_cnt = 0
  DETAIL
   IF (ea.encntr_alias_id > 0)
    alias_cnt = (alias_cnt+ 1)
    IF (mod(alias_cnt,10)=1)
     stat = alterlist(reply->encntr_list[encntr_cnt].aliases,(alias_cnt+ 9))
    ENDIF
    reply->encntr_list[encntr_cnt].aliases[alias_cnt].alias_type_cd = ea.encntr_alias_type_cd, reply
    ->encntr_list[encntr_cnt].aliases[alias_cnt].alias = cnvtalias(ea.alias,ea.alias_pool_cd)
   ENDIF
  FOOT  e.encntr_id
   stat = alterlist(reply->encntr_list[encntr_cnt].aliases,alias_cnt)
  FOOT REPORT
   stat = alterlist(reply->encntr_list,encntr_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
