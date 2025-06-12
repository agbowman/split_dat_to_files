CREATE PROGRAM dcp_search_power_trials:dba
 SET modify = predeclare
 RECORD reply(
   1 power_trials[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE searchstring = vc
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE ncnt = i4 WITH noconstant(0), protect
 DECLARE where_clause = vc WITH noconstant(fillstring(500,""))
 SET reply->status_data.status = "F"
 SET searchstring = cnvtupper(trim(request->search_string,3))
 IF (textlen(searchstring)=0)
  DECLARE i18nhandle = i4 WITH noconstant(uar_i18nalphabet_init())
  DECLARE lowcharbuffer = c20 WITH protect, noconstant(fillstring(1," "))
  CALL uar_i18nalphabet_lowchar(i18nhandle,lowcharbuffer,1)
  SET searchstring = cnvtupper(trim(lowcharbuffer))
  CALL uar_i18nalphabet_end(i18nhandle)
 ENDIF
 SET searchstring = replace(searchstring,"\","\\",0)
 SET where_clause = build('pm.primary_mnemonic_key like "',searchstring,'*"')
 SET ncnt = value(size(request->status_codes,5))
 CALL echo(build("string:",searchstring))
 SELECT INTO "nl:"
  pm.prot_master_id, pm.primary_mnemonic
  FROM prot_master pm
  WHERE parser(where_clause)
   AND expand(num,1,ncnt,pm.prot_status_cd,request->status_codes[num].prot_status_cd)
   AND pm.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY pm.primary_mnemonic, pm.prot_master_id
  HEAD REPORT
   index = 0, stat = alterlist(reply->power_trials,100)
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1
    AND index > 100)
    stat = alterlist(reply->power_trials,(index+ 9))
   ENDIF
   reply->power_trials[index].prot_master_id = pm.prot_master_id, reply->power_trials[index].
   primary_mnemonic = pm.primary_mnemonic
  FOOT REPORT
   stat = alterlist(reply->power_trials,index)
  WITH nocounter
 ;end select
 IF (size(reply->power_trials,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
