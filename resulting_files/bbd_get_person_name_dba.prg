CREATE PROGRAM bbd_get_person_name:dba
 RECORD reply(
   1 qual[*]
     2 person_name_id = f8
     2 name_type_cd = f8
     2 name_type_cd_disp = vc
     2 name_type_cd_mean = c12
     2 updt_cnt = i4
     2 name_original = vc
     2 name_format_cd = f8
     2 name_full = vc
     2 name_first = vc
     2 name_middle = vc
     2 name_last = vc
     2 name_degree = vc
     2 name_title = vc
     2 name_prefix = vc
     2 name_suffix = vc
     2 name_initials = vc
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
  p.person_id
  FROM person_name p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
    AND p.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].person_name_id = p
   .person_name_id,
   reply->qual[count].name_type_cd = p.name_type_cd, reply->qual[count].updt_cnt = p.updt_cnt, reply
   ->qual[count].name_original = p.name_original,
   reply->qual[count].name_format_cd = p.name_format_cd, reply->qual[count].name_full = p.name_full,
   reply->qual[count].name_first = p.name_first,
   reply->qual[count].name_middle = p.name_middle, reply->qual[count].name_last = p.name_last, reply
   ->qual[count].name_degree = p.name_degree,
   reply->qual[count].name_title = p.name_title, reply->qual[count].name_prefix = p.name_prefix,
   reply->qual[count].name_suffix = p.name_suffix,
   reply->qual[count].name_initials = p.name_initials
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
