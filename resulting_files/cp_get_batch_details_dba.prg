CREATE PROGRAM cp_get_batch_details:dba
 RECORD reply(
   1 charting_operations_id = f8
   1 batch_name = vc
   1 qual[1]
     2 sequence = i4
     2 update_ind = i2
     2 param_type_flag = i2
     2 param = vc
     2 active_ind = i2
     2 updt_cnt = i4
     2 param_list[*]
       3 param_id = f8
       3 param_value = vc
   1 last_update = vc
   1 no_label_updt_dt_tm = dq8
   1 modifier_name = vc
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
 DECLARE param_nbr = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "nl:"
  name = trim(substring(1,30,p.name_full_formatted)), co.charting_operations_id
  FROM charting_operations co,
   prsnl p
  PLAN (co
   WHERE (co.charting_operations_id=request->charting_operations_id)
    AND co.param_type_flag=1
    AND co.active_ind=1)
   JOIN (p
   WHERE p.person_id=co.updt_id)
  ORDER BY co.charting_operations_id
  HEAD REPORT
   reply->last_update = fillstring(100," ")
  DETAIL
   reply->last_update = concat("Last modified by: ",trim(name),"  (",format(co.updt_dt_tm,
     "mm/dd/yyyy"),")"), reply->no_label_updt_dt_tm = co.updt_dt_tm, reply->modifier_name = trim(name
    )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.batch_name
  FROM charting_operations c
  WHERE (c.charting_operations_id=request->charting_operations_id)
   AND c.active_ind=1
   AND  NOT (c.sequence IN (200, 201))
  ORDER BY c.param_type_flag, c.sequence
  HEAD REPORT
   count1 = 0, reply->charting_operations_id = c.charting_operations_id, reply->batch_name = c
   .batch_name
  DETAIL
   count1 += 1, stat = alter(reply->qual,count1), reply->qual[count1].sequence = c.sequence,
   reply->qual[count1].param_type_flag = c.param_type_flag, reply->qual[count1].param = c.param,
   reply->qual[count1].active_ind = c.active_ind,
   reply->qual[count1].updt_cnt = c.updt_cnt, reply->qual[count1].update_ind = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET param_nbr = size(reply->qual,5)
 FOR (x = 1 TO param_nbr)
   IF ((reply->qual[x].param_type_flag=20)
    AND cnvtint(reply->qual[x].param) > 0)
    SELECT INTO "nl:"
     cop.prsnl_id
     FROM charting_operations_prsnl cop,
      prsnl p
     PLAN (cop
      WHERE (cop.charting_operations_id=request->charting_operations_id))
      JOIN (p
      WHERE p.person_id=cop.prsnl_id)
     ORDER BY p.name_full_formatted
     HEAD REPORT
      nbr = 0
     DETAIL
      nbr += 1
      IF (mod(nbr,10)=1)
       stat = alterlist(reply->qual[x].param_list,(nbr+ 9))
      ENDIF
      reply->qual[x].param_list[nbr].param_id = p.person_id, reply->qual[x].param_list[nbr].
      param_value = p.name_full_formatted
     FOOT REPORT
      stat = alterlist(reply->qual[x].param_list,nbr)
     WITH nocounter
    ;end select
    IF (curqual=0
     AND cnvtint(reply->qual[x].param) != 3)
     SET reply->status_data.status = "Z"
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
    SET x = (param_nbr+ 1)
   ENDIF
 ENDFOR
#exit_script
END GO
