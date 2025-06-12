CREATE PROGRAM dcp_get_condbehav:dba
 RECORD reply(
   1 qual[10]
     2 condition_id = f8
     2 version_nbr = i4
     2 condition_control_cd = f8
     2 effected_control_cd = f8
     2 condition_flag = i2
     2 behavior_flag = i2
     2 range_value_1 = vc
     2 range_value_2 = vc
     2 active_ind = i2
     2 updt_cnt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  cb.condition_id
  FROM conditional_behavior cb
  WHERE (cb.input_form_cd=request->input_form_cd)
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].condition_id = cb.condition_id, reply->qual[count1].version_nbr = cb
   .version_nbr, reply->qual[count1].condition_control_cd,
   reply->qual[count1].effected_control_cd, reply->qual[count1].condition_flag, reply->qual[count1].
   behavior_flag,
   reply->qual[count1].range_value_1, reply->qual[count1].range_value_2, reply->qual[count1].
   active_ind,
   reply->qual[count1].updt_cnt
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
