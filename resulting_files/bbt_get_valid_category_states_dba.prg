CREATE PROGRAM bbt_get_valid_category_states:dba
 RECORD reply(
   1 qual[*]
     2 state_cd = f8
     2 state_disp = c40
     2 state_desc = vc
     2 state_mean = c12
     2 active_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 DECLARE process_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET process_cd = 0.0
 SET process_cd = get_code_value(1664,request->process_meaning)
 SELECT INTO "nl:"
  v.state_cd
  FROM valid_state v
  WHERE v.process_cd=process_cd
   AND (v.category_cd=request->category_cd)
   AND v.active_ind=1
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->qual,2)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,2)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 2))
   ENDIF
   reply->qual[count1].state_cd = v.state_cd, reply->qual[count1].updt_cnt = v.updt_cnt, reply->qual[
   count1].active_ind = v.active_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->qual,0)
 ELSE
  SET stat = alterlist(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
