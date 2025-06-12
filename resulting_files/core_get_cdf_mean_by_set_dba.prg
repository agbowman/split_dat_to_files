CREATE PROGRAM core_get_cdf_mean_by_set:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 cdf_mean_list[*]
     2 cdf_meaning = c12
     2 definition = vc
     2 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cdf.cdf_meaning, cdf.code_set, cdf.definition,
  cdf.display
  FROM common_data_foundation cdf
  PLAN (cdf
   WHERE (cdf.code_set=request->code_set))
  HEAD REPORT
   cdf_cnt = 0
  DETAIL
   cdf_cnt = (cdf_cnt+ 1)
   IF (mod(cdf_cnt,10)=1)
    stat = alterlist(reply->cdf_mean_list,(cdf_cnt+ 9))
   ENDIF
   reply->cdf_mean_list[cdf_cnt].cdf_meaning = cdf.cdf_meaning, reply->cdf_mean_list[cdf_cnt].
   definition = cdf.definition, reply->cdf_mean_list[cdf_cnt].display = cdf.display
  FOOT REPORT
   stat = alterlist(reply->cdf_mean_list,cdf_cnt)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 03/12/03 JF8275"
END GO
