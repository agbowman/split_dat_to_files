CREATE PROGRAM bbd_get_person_phone:dba
 RECORD reply(
   1 qual[*]
     2 phone_id = f8
     2 phone_type_cd = f8
     2 phone_type_cd_mean = vc
     2 updt_cnt = i4
     2 phone_format_cd = f8
     2 phone_format_cd_mean = vc
     2 phone_format_cd_disp = vc
     2 phone_num = vc
     2 contact = vc
     2 call_instruction = vc
     2 extension = vc
     2 paging_code = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  p.*, c.*
  FROM phone p,
   code_value c
  PLAN (p
   WHERE (p.parent_entity_id=request->person_id)
    AND p.parent_entity_name="PERSON"
    AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
    AND p.active_ind=1)
   JOIN (c
   WHERE c.code_set=43
    AND c.code_value=p.phone_type_cd
    AND cnvtdatetime(curdate,curtime3) >= c.begin_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= c.end_effective_dt_tm
    AND c.active_ind=1
    AND ((c.cdf_meaning="BUSINESS") OR (((c.cdf_meaning="HOME") OR (((c.cdf_meaning="TEMPORARY") OR (
   ((c.cdf_meaning="PAGER BUS") OR (((c.cdf_meaning="PAGER PERS") OR (c.cdf_meaning="PAGER TEMP"))
   )) )) )) )) )
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].phone_id = p.phone_id,
   reply->qual[count].phone_type_cd = p.phone_type_cd, reply->qual[count].phone_type_cd_mean = c
   .cdf_meaning, reply->qual[count].updt_cnt = p.updt_cnt,
   reply->qual[count].phone_format_cd = p.phone_format_cd, reply->qual[count].phone_num = p.phone_num,
   reply->qual[count].contact = p.contact,
   reply->qual[count].call_instruction = p.call_instruction, reply->qual[count].extension = p
   .extension, reply->qual[count].paging_code = p.paging_code
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
