CREATE PROGRAM dcp_get_all_for_output:dba
 RECORD reply(
   1 output_route_cnt = i4
   1 output_route[1]
     2 dcp_output_route_id = f8
     2 route_description = vc
     2 route_type_flag = i2
     2 param_cnt = i4
     2 param1_cd = f8
     2 param2_cd = f8
     2 param3_cd = f8
     2 param4_cd = f8
     2 param5_cd = f8
   1 flex_rtg_cnt = i4
   1 flex_rtg[1]
     2 dcp_flex_rtg_id = f8
     2 dcp_output_route_id = f8
     2 value1_cd = f8
     2 value2_cd = f8
     2 value3_cd = f8
     2 value4_cd = f8
     2 value5_cd = f8
     2 flex_dest_ind = i2
   1 flex_dest_cnt = i4
   1 flex_dest[1]
     2 dcp_flex_dest_id = f8
     2 dcp_flex_rtg_id = f8
     2 dcp_output_route_id = f8
     2 dest_dow = i4
     2 dest_beg_time = i4
     2 dest_end_time = i4
   1 flex_printer_cnt = i4
   1 flex_printer[1]
     2 dcp_flex_printer_id = f8
     2 dcp_flex_rtg_id = f8
     2 dcp_flex_dest_id = f8
     2 dcp_output_route_id = f8
     2 printer_cd = f8
     2 printer_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dcp_output_route route
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->output_route,5))
    stat = alter(reply->output_route,(count1+ 10))
   ENDIF
   reply->output_route[count1].dcp_output_route_id = route.dcp_output_route_id, reply->output_route[
   count1].route_description = route.route_description, reply->output_route[count1].route_type_flag
    = route.route_type_flag,
   reply->output_route[count1].param_cnt = route.param_cnt, reply->output_route[count1].param1_cd =
   route.param1_cd, reply->output_route[count1].param2_cd = route.param2_cd,
   reply->output_route[count1].param3_cd = route.param3_cd, reply->output_route[count1].param4_cd =
   route.param4_cd, reply->output_route[count1].param5_cd = route.param5_cd
  FOOT REPORT
   reply->output_route_cnt = count1, stat = alter(reply->output_route,count1)
  WITH nocounter
 ;end select
 SET count1 = 0
 SELECT INTO "nl:"
  FROM dcp_flex_rtg rtg
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->flex_rtg,5))
    stat = alter(reply->flex_rtg,(count1+ 10))
   ENDIF
   reply->flex_rtg[count1].dcp_flex_rtg_id = rtg.dcp_flex_rtg_id, reply->flex_rtg[count1].
   dcp_output_route_id = rtg.dcp_output_route_id, reply->flex_rtg[count1].value1_cd = rtg.value1_cd,
   reply->flex_rtg[count1].value2_cd = rtg.value2_cd, reply->flex_rtg[count1].value3_cd = rtg
   .value3_cd, reply->flex_rtg[count1].value4_cd = rtg.value4_cd,
   reply->flex_rtg[count1].value5_cd = rtg.value5_cd, reply->flex_rtg[count1].flex_dest_ind = rtg
   .flex_dest_ind
  FOOT REPORT
   reply->flex_rtg_cnt = count1, stat = alter(reply->flex_rtg,count1)
  WITH nocounter
 ;end select
 SET count1 = 0
 SELECT INTO "nl:"
  FROM dcp_flex_dest dest
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->flex_dest,5))
    stat = alter(reply->flex_dest,(count1+ 10))
   ENDIF
   reply->flex_dest[count1].dcp_flex_dest_id = dest.dcp_flex_dest_id, reply->flex_dest[count1].
   dcp_flex_rtg_id = dest.dcp_flex_rtg_id, reply->flex_dest[count1].dcp_output_route_id = dest
   .dcp_output_route_id,
   reply->flex_dest[count1].dest_dow = dest.dest_dow, reply->flex_dest[count1].dest_beg_time = dest
   .dest_beg_time, reply->flex_dest[count1].dest_end_time = dest.dest_end_time
  FOOT REPORT
   reply->flex_dest_cnt = count1, stat = alter(reply->flex_dest,count1)
  WITH nocounter
 ;end select
 SET count1 = 0
 SELECT INTO "nl:"
  FROM dcp_flex_printer printer
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->flex_printer,5))
    stat = alter(reply->flex_printer,(count1+ 10))
   ENDIF
   reply->flex_printer[count1].dcp_flex_printer_id = printer.dcp_flex_printer_id, reply->
   flex_printer[count1].dcp_flex_rtg_id = printer.dcp_flex_rtg_id, reply->flex_printer[count1].
   dcp_flex_dest_id = printer.dcp_flex_dest_id,
   reply->flex_printer[count1].dcp_output_route_id = printer.dcp_output_route_id, reply->
   flex_printer[count1].printer_cd = printer.printer_cd, reply->flex_printer[count1].printer_name =
   printer.printer_name
  FOOT REPORT
   reply->flex_printer_cnt = count1, stat = alter(reply->flex_printer,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
