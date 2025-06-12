CREATE PROGRAM ct_get_prescreen_type:dba
 RECORD reply(
   1 protinfo[*]
     2 prot_mnemonic = vc
     2 prescreen_type = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE protmnemoniccnt = i4 WITH protect, constant(size(request->protmnemonic,5))
 SET reply->status_data.status = "F"
 FOR (idx = 1 TO protmnemoniccnt)
   SET request->protmnemonic[idx].prot_mnemonic = trim(request->protmnemonic[idx].prot_mnemonic)
 ENDFOR
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE expand(idx,1,protmnemoniccnt,trim(pm.primary_mnemonic),request->protmnemonic[idx].
   prot_mnemonic)
   AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->protinfo,(cnt+ 9))
   ENDIF
   reply->protinfo[cnt].prot_mnemonic = trim(pm.primary_mnemonic), reply->protinfo[cnt].
   prescreen_type = pm.prescreen_type_flag
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->protinfo,cnt)
 SET reply->status_data.status = "S"
 SET last_mod = "000"
 SET mod_date = "Nov 20, 2018"
END GO
