CREATE PROGRAM dm_dm_code_values:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 code_set = f8
     2 cdf_meaning = c12
     2 cdf_null_ind = i2
     2 display = c50
     2 disp_null_ind = i2
     2 display_key = c50
     2 description = c100
     2 descr_null_ind = i2
     2 definition = c100
     2 def_null_ind = i2
     2 collation_seq = i4
     2 active_ind = i2
     2 cki = vc
     2 data_status_cd = f8
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
 SELECT INTO "nl:"
  y = max(dcf.schema_date)
  FROM dm_adm_code_value_set dcf
  WHERE (dcf.code_set=request->code_set)
  DETAIL
   r1->rdate = y
  WITH nocounter
 ;end select
 SET display_dup_ind = 0
 SET display_key_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET definition_dup_ind = 0
 SELECT INTO "nl:"
  cv.display_dup_ind, cv.display_key_dup_ind, cv.cdf_meaning_dup_ind,
  cv.definition_dup_ind
  FROM dm_adm_code_value_set cv
  WHERE (cv.code_set=request->code_set)
   AND datetimediff(cv.schema_date,cnvtdatetime(r1->rdate))=0
  DETAIL
   display_dup_ind = cv.display_dup_ind, display_key_dup_ind = cv.display_key_dup_ind,
   cdf_meaning_dup_ind = cv.cdf_meaning_dup_ind
  WITH nocounter
 ;end select
 SET x = fillstring(40," ")
 SELECT
  IF (cdf_meaning_dup_ind=1)
   x = cv.cdf_meaning
  ELSEIF (display_key_dup_ind=1)
   x = cv.display_key
  ELSEIF (display_dup_ind=1)
   x = cv.display
  ELSEIF (definition_dup_ind=1)
   x = cv.definition
  ELSEIF (display_key_dup_ind=0
   AND display_dup_ind=0
   AND cdf_meaning_dup_ind=0
   AND definition_dup_ind=0)
   x = cv.display
  ELSE
  ENDIF
  INTO "nl:"
  cv.code_value, cv.code_set, nullcdf = nullind(cv.cdf_meaning),
  cv.cdf_meaning, nulldisp = nullind(cv.display), cv.display,
  cv.display_key, nulldescr = nullind(cv.description), cv.description,
  nulldef = nullind(cv.definition), cv.definition, cv.collation_seq,
  cv.active_ind, cv.data_status_cd, cv.updt_cnt,
  cv.cki, cv.delete_ind
  FROM dm_adm_code_value cv
  WHERE (request->code_set=cv.code_set)
   AND datetimediff(cv.schema_date,cnvtdatetime(r1->rdate))=0
  ORDER BY x
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cv
   .code_value,
   reply->qual[count1].code_set = cv.code_set, reply->qual[count1].cdf_meaning = cv.cdf_meaning,
   reply->qual[count1].display = cv.display,
   reply->qual[count1].display_key = cv.display_key, reply->qual[count1].description = cv.description,
   reply->qual[count1].definition = cv.definition,
   reply->qual[count1].collation_seq = cv.collation_seq, reply->qual[count1].active_ind = cv
   .active_ind, reply->qual[count1].data_status_cd = cv.data_status_cd,
   reply->qual[count1].cki = cv.cki, reply->qual[count1].updt_cnt = cv.updt_cnt
   IF (nullcdf=1)
    reply->qual[count1].cdf_null_ind = 1
   ELSE
    reply->qual[count1].cdf_null_ind = 0
   ENDIF
   IF (nulldescr=1)
    reply->qual[count1].descr_null_ind = 1
   ELSE
    reply->qual[count1].descr_null_ind = 0
   ENDIF
   IF (nulldef=1)
    reply->qual[count1].def_null_ind = 1
   ELSE
    reply->qual[count1].def_null_ind = 0
   ENDIF
   IF (nulldisp=1)
    reply->qual[count1].disp_null_ind = 1
   ELSE
    reply->qual[count1].disp_null_ind = 0
   ENDIF
   reply->qual[count1].delete_ind = cv.delete_ind
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,count1)
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
