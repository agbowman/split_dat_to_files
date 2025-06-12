CREATE PROGRAM ct_get_domain_info:dba
 RECORD reply(
   1 domains[*]
     2 ct_domain_id = f8
     2 domain_name = c255
     2 domain_identifier = c255
     2 url_one_text = c255
     2 url_two_text = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->ct_domain_id=0.0))
  SELECT INTO "NL:"
   FROM ct_domain_info cdi
   WHERE cdi.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND cdi.ct_domain_info_id > 0.0
    AND (cdi.logical_domain_id=domain_reply->logical_domain_id)
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->domains,(cnt+ 9))
    ENDIF
    reply->domains[cnt].ct_domain_id = cdi.ct_domain_info_id, reply->domains[cnt].domain_name = cdi
    .domain_name, reply->domains[cnt].domain_identifier = cdi.domain_name_ident,
    reply->domains[cnt].url_one_text = cdi.url1_txt, reply->domains[cnt].url_two_text = cdi.url2_txt
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->domains,cnt)
 ELSE
  SELECT INTO "NL:"
   FROM ct_domain_info cdi
   WHERE (cdi.ct_domain_info_id=request->ct_domain_id)
    AND cdi.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    stat = alterlist(reply->domains,1), reply->domains[1].ct_domain_id = cdi.ct_domain_info_id, reply
    ->domains[1].domain_name = cdi.domain_name,
    reply->domains[1].domain_identifier = cdi.domain_name_ident, reply->domains[1].url_one_text = cdi
    .url1_txt, reply->domains[1].url_two_text = cdi.url2_txt
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "February 25, 2019"
END GO
