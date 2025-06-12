CREATE PROGRAM ct_get_templates_for_pref:dba
 RECORD reply(
   1 qual[*]
     2 value = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE template_cnt = i2 WITH protect, noconstant(0)
 DECLARE serror = vc WITH protect, noconstant("")
 SELECT DISTINCT INTO "NL:"
  item_display = crt.template_name, item_keyvalue = crt.report_template_id
  FROM cr_report_template crt
  WHERE crt.report_template_id > 0.00
   AND crt.active_ind=1
  ORDER BY cnvtupper(crt.template_name)
  HEAD REPORT
   template_cnt = 0
  DETAIL
   template_cnt = (template_cnt+ 1)
   IF (mod(template_cnt,10)=1)
    stat = alterlist(reply->qual,(template_cnt+ 9))
   ENDIF
   reply->qual[template_cnt].name = crt.template_name, reply->qual[template_cnt].value = crt
   .report_template_id
  FOOT REPORT
   stat = alterlist(reply->qual,template_cnt)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
 ELSEIF (template_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "December 7, 2009"
END GO
