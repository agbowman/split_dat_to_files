CREATE PROGRAM bed_get_res_sch_generic_res:dba
 FREE SET reply
 RECORD reply(
   1 resources[*]
     2 sch_resource_code_value = f8
     2 mnemonic = vc
     2 booking_limit = i4
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 DECLARE sch_parse = vc
 DECLARE search_string = vc
 IF ((request->search_type_flag="S"))
  SET search_string = concat('"',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
 ELSEIF ((request->search_type_flag="C"))
  SET search_string = concat('"*',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
 ENDIF
 SET sch_parse = concat("s.mnemonic_key = ",search_string)
 SELECT INTO "nl:"
  FROM sch_resource s
  PLAN (s
   WHERE parser(sch_parse)
    AND s.res_type_flag=1
    AND s.active_ind=1)
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->resources,100)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->resources,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->resources[tot_cnt].sch_resource_code_value = s.resource_cd, reply->resources[tot_cnt].
   mnemonic = s.mnemonic, reply->resources[tot_cnt].booking_limit = s.quota
  FOOT REPORT
   stat = alterlist(reply->resources,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 IF ((tot_cnt > request->max_reply)
  AND (request->max_reply > 0))
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
