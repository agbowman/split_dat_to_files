CREATE PROGRAM dm_get_code_alias:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 code_set = i4
     2 contrib_source_cd = f8
     2 contrib_source_disp = vc
     2 alias = c50
     2 alias_null_ind = i2
     2 alias_type_meaning = vc
     2 atm_null_ind = i2
     2 cki = vc
     2 updt_cnt = i4
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
 SET nulldisp = 0
 SET nulldescr = 0
 SET nulldef = 0
 SET nullcdf = 0
 IF ((request->cv_mode=0))
  SELECT INTO "nl:"
   cv1.cki, cva.code_value, cva.code_set,
   cva.contributor_source_cd, cv.display, cva.alias,
   nullalias = nullind(cva.alias), cva.alias_type_meaning, nullatm = nullind(cva.alias_type_meaning),
   cva.updt_cnt
   FROM code_value_alias cva,
    code_value cv,
    code_value cv1
   WHERE (request->code_set=cva.code_set)
    AND cv.code_set=73
    AND cv.code_value=cva.contributor_source_cd
    AND cv1.code_value=cva.code_value
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cva
    .code_value,
    reply->qual[count1].code_set = cva.code_set, reply->qual[count1].alias = cva.alias, reply->qual[
    count1].contrib_source_cd = cva.contributor_source_cd,
    reply->qual[count1].contrib_source_disp = cv.display, reply->qual[count1].alias_type_meaning =
    cva.alias_type_meaning, reply->qual[count1].updt_cnt = cva.updt_cnt,
    reply->qual[count1].cki = cv1.cki
    IF (nullalias=1)
     reply->qual[count1].alias_null_ind = 1
    ELSE
     reply->qual[count1].alias_null_ind = 0
    ENDIF
    IF (nullatm=1)
     reply->qual[count1].atm_null_ind = 1
    ELSE
     reply->qual[count1].atm_null_ind = 0
    ENDIF
   WITH counter
  ;end select
 ELSE
  SELECT INTO "nl:"
   cv.cki, cva.code_value, cva.code_set,
   cva.contributor_source_cd, cv1.display, cva.alias,
   nullalias = nullind(cva.alias), cva.alias_type_meaning, nullatm = nullind(cva.alias_type_meaning),
   cv.updt_cnt
   FROM code_value_alias cva,
    code_value cv,
    code_value cv1
   WHERE (request->code_set=cva.code_set)
    AND cv.code_value=cva.code_value
    AND cv.active_ind=1
    AND cv1.code_set=73
    AND cv1.code_value=cva.contributor_source_cd
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cva
    .code_value,
    reply->qual[count1].code_set = cva.code_set, reply->qual[count1].alias = cva.alias, reply->qual[
    count1].contrib_source_cd = cva.contributor_source_cd,
    reply->qual[count1].cki = cv.cki, reply->qual[count1].contrib_source_disp = cv1.display, reply->
    qual[count1].alias_type_meaning = cva.alias_type_meaning,
    reply->qual[count1].updt_cnt = cv.updt_cnt
    IF (nullalias=1)
     reply->qual[count1].alias_null_ind = 1
    ELSE
     reply->qual[count1].alias_null_ind = 0
    ENDIF
    IF (nullatm=1)
     reply->qual[count1].atm_null_ind = 1
    ELSE
     reply->qual[count1].atm_null_ind = 0
    ENDIF
   WITH counter
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,count1)
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
