CREATE PROGRAM bbt_get_product_state_values:dba
 RECORD reply(
   1 qual[20]
     2 code_value = f8
     2 code_set = i4
     2 cdf_meaning = c12
     2 primary_ind = i2
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET state_cnt = 0
 SET count1 = 0
 SET product_state_code_set = 1610
#begin_main
 SELECT INTO "nl:"
  cv.code_value, cv.code_set, cv.cdf_meaning,
  cv.display, cv.display_key, cv.description,
  cv.definition, cv.collation_seq
  FROM code_value cv
  WHERE cv.code_set=product_state_code_set
   AND cv.active_ind=1
  ORDER BY cv.cdf_meaning
  HEAD REPORT
   state_cnt = 0
  DETAIL
   state_cnt = (state_cnt+ 1)
   IF (mod(state_cnt,20)=1
    AND state_cnt != 1)
    stat = alter(reply->qual,(state_cnt+ 19))
   ENDIF
   reply->qual[state_cnt].code_value = cv.code_value, reply->qual[state_cnt].code_set = cv.code_set,
   reply->qual[state_cnt].cdf_meaning = cv.cdf_meaning,
   reply->qual[state_cnt].primary_ind = 0, reply->qual[state_cnt].display = cv.display, reply->qual[
   state_cnt].display_key = cv.display_key,
   reply->qual[state_cnt].description = cv.description, reply->qual[state_cnt].definition = cv
   .definition, reply->qual[state_cnt].collation_seq = cv.collation_seq
  WITH nocounter
 ;end select
 GO TO exit_script
#end_main
#exit_script
 IF (state_cnt > 0)
  SET reply->status_data.status = "S"
  SET count1 = (count1+ 1)
  IF (mod(count1,10)=1
   AND count1 != 1)
   SET stat = alter(reply->status_data,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get product state values"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "SUCCESS"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(state_cnt,
   " product states returned")
 ELSE
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (mod(count1,10)=1
   AND count1 != 1)
   SET stat = alter(reply->status_data,count1)
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get product state values"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "SCRIPT FAILURE"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "no product states found"
 ENDIF
 SET stat = alter(reply->qual,state_cnt)
 FOR (x = 1 TO state_cnt)
   CALL echo(build(x,".",reply->qual[x].code_value,"/",reply->qual[x].code_set,
     "/",reply->qual[x].cdf_meaning,"/",reply->qual[x].primary_ind,"/",
     reply->qual[x].display,"/",reply->qual[x].display_key,"/",reply->qual[x].description,
     "/",reply->qual[x].definition,"/",reply->qual[x].collation_seq))
 ENDFOR
END GO
