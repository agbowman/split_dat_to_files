CREATE PROGRAM bbd_cs_get_active_codes:dba
 RECORD reply(
   1 code_set_display = c40
   1 code_set_description = c60
   1 authentic_cd = f8
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = c50
     2 display_key = c50
     2 description = c100
     2 definition = c100
     2 collation_seq = i4
     2 active_type_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 data_status_cd = f8
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c.display, c.description
  FROM code_value_set c
  WHERE (c.code_set=request->code_set)
  DETAIL
   reply->code_set_display = c.display, reply->code_set_description = c.description
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SELECT
   c.code_value
   FROM code_value c
   WHERE c.code_set=8
    AND c.cdf_meaning="AUTH"
   DETAIL
    reply->authentic_cd = c.code_value
   WITH nocounter
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  GO TO stop
 ENDIF
 SET count1 = 0
 SET stat = alterlist(reply->qual,0)
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND c.active_ind=1
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->qual,0)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = c
   .code_value,
   reply->qual[count1].cdf_meaning = c.cdf_meaning, reply->qual[count1].display = c.display, reply->
   qual[count1].display_key = c.display_key,
   reply->qual[count1].description = c.description, reply->qual[count1].definition = c.definition,
   reply->qual[count1].collation_seq = c.collation_seq,
   reply->qual[count1].active_type_cd = c.active_type_cd, reply->qual[count1].active_ind = c
   .active_ind, reply->qual[count1].updt_cnt = c.updt_cnt,
   reply->qual[count1].data_status_cd = c.data_status_cd, reply->qual[count1].begin_effective_dt_tm
    = cnvtdatetime(c.begin_effective_dt_tm), reply->qual[count1].end_effective_dt_tm = cnvtdatetime(c
    .end_effective_dt_tm)
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alterlist(reply->qual,count1)
#stop
END GO
