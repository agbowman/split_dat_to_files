CREATE PROGRAM cs_srv_get_bill_org_payor:dba
 CALL echo(concat("CS_SRV_GET_BILL_ORG_PAYOR - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(request)
 ENDIF
 DECLARE payor_cnt = i2
 SET reply->status_data.status = "F"
 SET payor_cnt = 0
 CALL echo("Read bill_org_payor table")
 SELECT INTO "nl:"
  b.bill_org_type_cd, b.bill_org_type_id, b.bill_org_type_ind
  FROM bill_org_payor b
  WHERE (b.organization_id=request->organization_id)
   AND b.active_ind=1
  DETAIL
   payor_cnt += 1, stat = alterlist(reply->payorlist,payor_cnt), reply->payorlist[payor_cnt].
   bill_org_type_cd = b.bill_org_type_cd,
   reply->payorlist[payor_cnt].bill_org_type_id = b.bill_org_type_id, reply->payorlist[payor_cnt].
   bill_org_type_ind = b.bill_org_type_ind
  WITH nocounter
 ;end select
 IF (payor_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
