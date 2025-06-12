CREATE PROGRAM dcp_get_generic_priorities:dba
 RECORD reply(
   1 fmt_cnt = i4
   1 fmt_list[10]
     2 oe_format_id = f8
     2 priority_cnt = i4
     2 priority_list[10]
       3 priority_cd = f8
       3 priority_disp = c40
       3 disable_freq_ind = i2
       3 default_start_dt_tm = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  opf.*, cv.*
  FROM order_priority_flexing opf,
   code_value cv
  PLAN (opf
   WHERE opf.priority_cd > 0.00
    AND opf.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=opf.priority_cd
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY opf.oe_format_id, opf.priority_cd
  HEAD REPORT
   count1 = 0
  HEAD opf.oe_format_id
   count2 = 0, count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->fmt_list,(count1+ 9))
   ENDIF
   reply->fmt_list[count1].oe_format_id = opf.oe_format_id
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,10)=1
    AND count2 != 1)
    stat = alter(reply->fmt_list[count1].priority_list,(count2+ 10))
   ENDIF
   reply->fmt_list[count1].priority_list[count2].priority_cd = opf.priority_cd, reply->fmt_list[
   count1].priority_list[count2].priority_disp = cv.display, reply->fmt_list[count1].priority_list[
   count2].disable_freq_ind = opf.disable_freq_ind,
   reply->fmt_list[count1].priority_list[count2].default_start_dt_tm = opf.default_start_dt_tm
  FOOT  opf.oe_format_id
   reply->fmt_list[count1].priority_cnt = count2
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
  SET reply->fmt_cnt = count1
 ELSE
  SET reply->status_data.status = "S"
  SET reply->fmt_cnt = count1
 ENDIF
END GO
