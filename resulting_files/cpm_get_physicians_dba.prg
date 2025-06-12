CREATE PROGRAM cpm_get_physicians:dba
 RECORD reply(
   1 qual[1]
     2 person_id = f8
     2 name_full_formatted = vc
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
 SET continue_flag = 0
 SET maxqualrows = 0
 SET start_name = fillstring(200," ")
 SET name_first = fillstring(100," ")
 SET name_last = fillstring(100," ")
 SET name_first_temp = fillstring(100," ")
 SET name_last_temp = fillstring(100," ")
 SET person_id = 0.0
 SET prsnl_type_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 IF (validate(context->context_ind,0) != 0)
  SET continue_flag = 1
  SET name_first = context->name_first_key
  SET name_last = context->name_last_key
  SET person_id = context->person_id
  SET maxqualrows = context->maxqual
  SET prsnl_type_cd = context->prsnl_type_cd
 ELSE
  SET continue_flag = 0
  SET start_name = cnvtupper(request->start_name)
  SET position = findstring(",",start_name)
  IF (position > 0)
   SET name_last_temp = substring(1,(position - 1),start_name)
   SET name_last = concat(trim(cnvtalphanum(name_last_temp)),"*")
   SET name_first_temp = substring((position+ 1),100,start_name)
   SET name_first_temp = trim(name_first_temp,3)
   SET mid_init_position = findstring(" ",name_first_temp)
   IF (mid_init_position > 0)
    SET name_first_temp = substring((position+ 1),mid_init_position,start_name)
   ENDIF
   SET name_first = concat(trim(cnvtalphanum(name_first_temp)),"*")
  ELSE
   SET name_last_temp = cnvtalphanum(start_name)
   SET name_last = concat(trim(name_last_temp),"*")
   SET name_first = "*"
  ENDIF
  SET person_id = 0
  SET maxqualrows = request->maxqual
  RECORD context(
    1 context_ind = i2
    1 name_last_key = c100
    1 name_first_key = c100
    1 name_last_found = c100
    1 name_first_found = c100
    1 person_id = f8
    1 prsnl_type_cd = f8
    1 maxqual = i4
  )
  SET cdf_meaning = "USER"
  SET code_set = 309
  EXECUTE cpm_get_cd_for_cdf
  SET prsnl_type_cd = code_value
  SET context->prsnl_type_cd = code_value
  SET context->maxqual = request->maxqual
 ENDIF
 SET stat = alter(reply->qual,maxqualrows)
 SELECT
  IF (continue_flag=0)
   WHERE p.name_last_key=patstring(name_last)
    AND p.name_first_key=patstring(name_first)
    AND p.active_ind=1
    AND p.prsnl_type_cd=prsnl_type_cd
    AND p.physician_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ELSE
   WHERE ((p.name_last_key=patstring(name_last)
    AND (p.name_last_key > context->name_last_found)
    AND p.name_first_key=patstring(name_first)) OR ((((p.name_last_key=context->name_last_found)
    AND p.name_first_key=patstring(name_first)
    AND (p.name_first_key > context->name_first_found)) OR ((p.name_last_key=context->name_last_found
   )
    AND (p.name_first_key=context->name_first_found)
    AND (p.person_id > context->person_id))) ))
    AND p.active_ind=1
    AND p.prsnl_type_cd=prsnl_type_cd
    AND p.physician_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ENDIF
  INTO "nl:"
  p.person_id
  FROM prsnl p
  HEAD REPORT
   context->context_ind = 0
  DETAIL
   count1 = (count1+ 1), reply->qual[count1].person_id = p.person_id, reply->qual[count1].
   name_full_formatted = p.name_full_formatted
   IF (count1=maxqualrows)
    context->context_ind = 1, context->name_last_key = name_last, context->name_first_key =
    name_first,
    context->name_last_found = p.name_last_key, context->name_first_found = p.name_first_key, context
    ->person_id = p.person_id,
    context->prsnl_type_cd = prsnl_type_cd
   ENDIF
  WITH nocounter, maxqual(p,value(maxqualrows)), orahint("index (p XIE2PRSNL)")
 ;end select
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->qual,1)
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
