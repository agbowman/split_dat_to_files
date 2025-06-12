CREATE PROGRAM dcp_get_event_code_by_name:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 event_cd_disp = vc
     2 event_cd_desc = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET name_text_key = build("*",cnvtupper(trim(cnvtalphanum(request->name_text))),"*")
 SET cdf_meaning = "ACTIVE"
 SET code_set = 48
 EXECUTE cpm_get_cd_for_cdf
 SET active = code_value
 SET cdf_meaning = "AUTH"
 SET code_set = 8
 EXECUTE cpm_get_cd_for_cdf
 SET authorized = code_value
 SELECT INTO "nl:"
  v.event_cd, c.updt_cnt
  FROM v500_event_code v,
   code_value c
  PLAN (v
   WHERE v.event_cd_disp_key=patstring(name_text_key)
    AND v.code_status_cd=active
    AND v.event_code_status_cd=authorized)
   JOIN (c
   WHERE c.code_value=v.event_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].event_cd = v.event_cd, reply->qual[count1].updt_cnt = c.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
