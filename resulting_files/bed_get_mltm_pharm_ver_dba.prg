CREATE PROGRAM bed_get_mltm_pharm_ver:dba
 FREE SET reply
 RECORD reply(
   1 actions[*]
     2 code_value = f8
     2 display = vc
     2 meaning = vc
     2 pharm_verify_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 actions[*]
     2 code_value = f8
     2 display = vc
     2 meaning = vc
     2 rx_verify_flag = i2
     2 count = i4
 )
 DECLARE parse_action = vc
 SET reply->status_data.status = "F"
 SET pharmacy_code_value = 0.0
 SET percent_level = 0.0
 SET tcnt = 0
 SET qual_cnt = 0
 SET pharmacy_code_value = uar_get_code_by("MEANING",6000,"PHARMACY")
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value c
  PLAN (oc
   WHERE oc.catalog_type_cd=pharmacy_code_value
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (c
   WHERE c.code_value=oc.catalog_cd
    AND c.active_ind=1)
  DETAIL
   qual_cnt = (qual_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c,
   order_catalog_review ocr,
   order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd=pharmacy_code_value
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocr
   WHERE ocr.catalog_cd=oc.catalog_cd)
   JOIN (c
   WHERE c.code_value=ocr.action_type_cd
    AND c.code_set=6003
    AND c.active_ind=1)
  ORDER BY ocr.action_type_cd, ocr.rx_verify_flag
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(temp->actions,10)
  HEAD ocr.action_type_cd
   cnt = cnt
  HEAD ocr.rx_verify_flag
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(temp->actions,(tcnt+ 10)), cnt = 1
   ENDIF
   temp->actions[tcnt].code_value = ocr.action_type_cd, temp->actions[tcnt].display = c.display, temp
   ->actions[tcnt].meaning = c.cdf_meaning,
   temp->actions[tcnt].rx_verify_flag = ocr.rx_verify_flag
  DETAIL
   temp->actions[tcnt].count = (temp->actions[tcnt].count+ 1)
  FOOT REPORT
   stat = alterlist(temp->actions,tcnt)
  WITH nocounter
 ;end select
 SET percent_level = (qual_cnt * 0.90)
 SET fin_cnt = 0
 FOR (x = 1 TO tcnt)
   IF (cnvtreal(temp->actions[x].count) >= percent_level)
    SET fin_cnt = (fin_cnt+ 1)
    SET stat = alterlist(reply->actions,fin_cnt)
    SET reply->actions[fin_cnt].code_value = temp->actions[x].code_value
    SET reply->actions[fin_cnt].display = temp->actions[x].display
    SET reply->actions[fin_cnt].meaning = temp->actions[x].meaning
    SET reply->actions[fin_cnt].pharm_verify_flag = temp->actions[x].rx_verify_flag
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
