CREATE PROGRAM cv_get_normalcy_indicators:dba
 RECORD normalcy_request(
   1 normalcy_lists[*]
     2 normalcy_indicator_meaning = vc
 )
 RECORD reply(
   1 normalcy_list[*]
     2 normalcy_indicator_cd = f8
     2 normalcy_indicator_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE cntw = i4 WITH protect, noconstant(0)
 SET stat = alterlist(normalcy_request->normalcy_lists,2)
 SET stat = alterlist(reply->normalcy_list,2)
 SET normalcy_request->normalcy_lists[1].normalcy_indicator_meaning = "ABNORMAL"
 SET normalcy_request->normalcy_lists[2].normalcy_indicator_meaning = "CRITICAL"
 FOR (cnt = 0 TO size(normalcy_request->normalcy_lists,5))
  SET reply->normalcy_list[cnt].normalcy_indicator_meaning = normalcy_request->normalcy_lists[cnt].
  normalcy_indicator_meaning
  SET reply->normalcy_list[cnt].normalcy_indicator_cd = uar_get_code_by("MEANING",52,normalcy_request
   ->normalcy_lists[cnt].normalcy_indicator_meaning)
 ENDFOR
 CALL cv_log_msg_post("001 01/18/14 JT023123")
END GO
