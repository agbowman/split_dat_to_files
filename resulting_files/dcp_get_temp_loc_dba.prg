CREATE PROGRAM dcp_get_temp_loc:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 description = c200
     2 display = c15
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_ind = i2
     2 child_ind = i2
     2 collation_seq = i4
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
 DECLARE group_cd = f8 WITH constant(uar_get_code_by("MEANING",222,nullterm(request->cdf_meaning))),
 protect
 SELECT INTO "nl:"
  c.code_value, lg.child_loc_cd
  FROM code_value c,
   location_group lg,
   (dummyt d  WITH seq = 1)
  PLAN (d)
   JOIN (lg
   WHERE (lg.root_loc_cd=request->root_loc_cd)
    AND lg.location_group_type_cd=group_cd
    AND lg.active_ind=1
    AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (c
   WHERE c.code_value=lg.child_loc_cd
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY c.code_value
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->qual,1)
  HEAD c.code_value
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
  DETAIL
   reply->qual[count1].code_value = c.code_value,
   CALL echo(build("Cd Value = ",reply->qual[count1].code_value)), reply->qual[count1].cdf_meaning =
   c.cdf_meaning,
   reply->qual[count1].description = c.description, reply->qual[count1].display = c.display,
   CALL echo(build("Cd Display = ",reply->qual[count1].display)),
   reply->qual[count1].active_ind = c.active_ind, reply->qual[count1].beg_effective_dt_tm = c
   .begin_effective_dt_tm, reply->qual[count1].end_effective_dt_tm = c.end_effective_dt_tm
   IF (lg.active_ind=1
    AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    reply->qual[count1].status_ind = 1
   ELSE
    reply->qual[count1].status_ind = 0
   ENDIF
   reply->qual[count1].collation_seq = c.collation_seq, reply->qual[count1].updt_cnt = c.updt_cnt
  WITH nocounter, outerjoin = d
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
