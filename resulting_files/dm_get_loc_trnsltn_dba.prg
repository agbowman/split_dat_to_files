CREATE PROGRAM dm_get_loc_trnsltn:dba
 RECORD reply(
   1 qual[*]
     2 from_code_value = f8
     2 from_display = c40
     2 from_description = c60
     2 from_cdf_meaning = c12
     2 to_cd = f8
     2 to_disp = c40
     2 to_desc = c60
     2 to_mean = c12
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->qual,1)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_value, c.display, c.description,
  c.cdf_meaning, t.from_value, t.to_value
  FROM dm_merge_translate t,
   code_value@loc_mrg_link c
  PLAN (t
   WHERE (t.env_source_id=request->env_source_id)
    AND (t.env_target_id=request->env_target_id)
    AND t.table_name="CODE_VALUE")
   JOIN (c
   WHERE c.code_set=220
    AND c.code_value=t.from_value)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].from_code_value = t.from_value, reply->qual[count1].from_display = c.display,
   reply->qual[count1].from_description = c.description,
   reply->qual[count1].from_cdf_meaning = c.cdf_meaning, reply->qual[count1].to_cd = t.to_value,
   reply->qual[count1].sequence = t.seq
  WITH nocounter
 ;end select
 IF (count1 > 0)
  SET stat = alterlist(reply->qual,count1)
  SET reply->status_data.status = "S"
 ELSE
  SET stat = alterlist(reply->qual,0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
