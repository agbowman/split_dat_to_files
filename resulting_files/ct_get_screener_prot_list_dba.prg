CREATE PROGRAM ct_get_screener_prot_list:dba
 RECORD reply(
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
     2 prot_amendment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD curprots(
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
     2 prot_amendment_id = f8
 )
 RECORD history_request(
   1 status_list[*]
     2 prot_status_cd = f8
   1 protocol_list[*]
     2 prot_master_id = f8
 )
 RECORD history_reply(
   1 protocol_list[*]
     2 prot_master_id = f8
 )
 DECLARE concept_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"CONCEPT"))
 DECLARE discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"DISCONTINUED"))
 DECLARE curprotcnt = i2 WITH protect, noconstant(0)
 DECLARE qualifiedprotcnt = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE squery = vc WITH private, noconstant("")
 DECLARE curprotindex = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 DECLARE pos = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SET reply->status_data.status = "F"
 IF ((request->active_ind=0))
  SET squery = "(pm.prot_status_cd = concept_cd OR pm.prot_status_cd = discontinued_cd)"
 ELSE
  SET squery = "pm.prot_status_cd = concept_cd"
 ENDIF
 SELECT INTO "NL:"
  pm.prot_master_id, pm.primary_mnemonic, pm.prev_prot_master_id,
  pa.prot_amendment_id
  FROM prot_master pm,
   prot_amendment pa
  PLAN (pm
   WHERE pm.prot_master_id > 0
    AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ((pm.screener_ind=1) OR (pm.network_flag=1))
    AND parser(squery))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id
    AND pa.amendment_status_cd=pm.prot_status_cd)
  ORDER BY pm.primary_mnemonic
  DETAIL
   curprotcnt = (curprotcnt+ 1)
   IF (mod(curprotcnt,50)=1)
    stat = alterlist(curprots->protocols,(curprotcnt+ 50)), stat = alterlist(history_request->
     protocol_list,(curprotcnt+ 50))
   ENDIF
   curprots->protocols[curprotcnt].primary_mnemonic = pm.primary_mnemonic, curprots->protocols[
   curprotcnt].prot_master_id = pm.prot_master_id, curprots->protocols[curprotcnt].prot_amendment_id
    = pa.prot_amendment_id,
   history_request->protocol_list[curprotcnt].prot_master_id = pm.prot_master_id
  WITH nocounter
 ;end select
 IF (curqual=0
  AND cnt=0)
  CALL report_failure("SELECT","Z","ct_get_screener_prot_list",
   "Did not find any open protocols for prescreening.")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(curprots->protocols,curprotcnt)
 SET stat = alterlist(history_request->status_list,2)
 SET stat = alterlist(history_request->protocol_list,curprotcnt)
 SET history_request->status_list[1].prot_status_cd = concept_cd
 SET history_request->status_list[2].prot_status_cd = discontinued_cd
 EXECUTE ct_get_prot_by_status_history  WITH replace("REQUEST","HISTORY_REQUEST"), replace("REPLY",
  "HISTORY_REPLY")
 SET qualifiedprotcnt = size(history_reply->protocol_list,5)
 SET stat = alterlist(reply->protocols,qualifiedprotcnt)
 FOR (idx = 1 TO qualifiedprotcnt)
   SET pos = locateval(num,1,curprotcnt,history_reply->protocol_list[idx].prot_master_id,curprots->
    protocols[num].prot_master_id)
   SET reply->protocols[idx].primary_mnemonic = curprots->protocols[pos].primary_mnemonic
   SET reply->protocols[idx].prot_master_id = curprots->protocols[pos].prot_master_id
   SET reply->protocols[idx].prot_amendment_id = curprots->protocols[pos].prot_amendment_id
 ENDFOR
 GO TO exit_script
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "April 23, 2009"
END GO
