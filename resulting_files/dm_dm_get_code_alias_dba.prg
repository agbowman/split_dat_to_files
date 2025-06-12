CREATE PROGRAM dm_dm_get_code_alias:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 code_set = i4
     2 contrib_source_cd = f8
     2 contrib_source_display = c30
     2 alias = c50
     2 alias_null_ind = i2
     2 alias_null_ind = i2
     2 alias_type_meaning = vc
     2 atm_null_ind = i2
     2 cki = vc
     2 updt_cnt = i4
     2 delete_ind = i2
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
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_code_value_alias dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r1->rdate))
    r1->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->cv_mode=0))
  FREE SET r2
  RECORD r2(
    1 rdate = dq8
  )
  SET r2->rdate = 0
  SELECT INTO "NL:"
   dc.schema_date
   FROM dm_adm_code_value dc
   WHERE dc.code_set=73
   DETAIL
    IF ((dc.schema_date > r2->rdate))
     r2->rdate = dc.schema_date
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cv1.cki, cva.code_value, cva.code_set,
   cva.contributor_source_cd, cv.display, cva.alias,
   nullalias = nullind(cva.alias), cva.alias_type_meaning, nullatm = nullind(cva.alias_type_meaning),
   cva.updt_cnt, cva.delete_ind
   FROM dm_adm_code_value_alias cva,
    dm_adm_code_value cv,
    dm_adm_code_value cv1
   WHERE (request->code_set=cva.code_set)
    AND datetimediff(cva.schema_date,cnvtdatetime(r1->rdate))=0
    AND cva.contributor_source_cd=cv.code_value
    AND cv.code_set=73
    AND datetimediff(cv.schema_date,cnvtdatetime(r2->rdate))=0
    AND cv1.code_value=cva.code_value
    AND datetimediff(cv1.schema_date,cnvtdatetime(r1->rdate))=0
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cva
    .code_value,
    reply->qual[count1].code_set = cva.code_set, reply->qual[count1].alias = cva.alias, reply->qual[
    count1].contrib_source_cd = cva.contributor_source_cd,
    reply->qual[count1].contrib_source_display = cv.display, reply->qual[count1].alias_type_meaning
     = cva.alias_type_meaning, reply->qual[count1].updt_cnt = cva.updt_cnt,
    reply->qual[count1].delete_ind = cva.delete_ind, reply->qual[count1].cki = cv1.cki
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
   cva.contributor_source_cd, cva.alias, cv1.display,
   nullalias = nullind(cva.alias), cva.alias_type_meaning, nullatm = nullind(cva.alias_type_meaning),
   cva.updt_cnt, cva.delete_ind
   FROM dm_adm_code_value_alias cva,
    dm_adm_code_value cv,
    dm_adm_code_value cv1
   WHERE (request->code_set=cva.code_set)
    AND datetimediff(cva.schema_date,cnvtdatetime(r1->rdate))=0
    AND cv.code_value=cva.code_value
    AND cv.active_ind=1
    AND cva.contributor_source_cd=cv1.code_value
    AND datetimediff(cva.schema_date,cv1.schema_date)=0
    AND cv1.code_set=73
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cva
    .code_value,
    reply->qual[count1].code_set = cva.code_set, reply->qual[count1].alias = cva.alias, reply->qual[
    count1].contrib_source_cd = cva.contributor_source_cd,
    reply->qual[count1].contrib_source_display = cv.display, reply->qual[count1].alias_type_meaning
     = cva.alias_type_meaning, reply->qual[count1].cki = cv.cki,
    reply->qual[count1].updt_cnt = cva.updt_cnt, reply->qual[count1].delete_ind = cva.delete_ind
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
