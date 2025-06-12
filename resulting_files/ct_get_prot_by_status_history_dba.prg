CREATE PROGRAM ct_get_prot_by_status_history:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 protocol_list[*]
      2 prot_master_id = f8
  )
 ENDIF
 DECLARE status_list_size = i2 WITH protect, noconstant(0)
 DECLARE protocol_list_size = i2 WITH protect, noconstant(0)
 DECLARE qualifiedprotcnt = i2 WITH protect, noconstant(0)
 DECLARE qualifiedstatus = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 SET status_list_size = size(request->status_list,5)
 SET protocol_list_size = size(request->protocol_list,5)
 SET stat = alterlist(reply->protocol_list,protocol_list_size)
 SET batch_size = 20
 SET loop_cnt = ceil((cnvtreal(protocol_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(request->protocol_list,new_list_size)
 SET nstart = 1
 FOR (idx = (protocol_list_size+ 1) TO new_list_size)
   SET request->protocol_list[idx].prot_master_id = request->protocol_list[protocol_list_size].
   prot_master_id
 ENDFOR
 SET qualifiedprotcnt = 0
 SELECT INTO "NL:"
  FROM prot_master pm,
   (dummyt d1  WITH seq = value(loop_cnt))
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (pm
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),pm.prev_prot_master_id,request->protocol_list[
    num].prot_master_id))
  ORDER BY pm.prev_prot_master_id, pm.prot_master_id
  HEAD pm.prev_prot_master_id
   foundother = 0
  DETAIL
   qualifiedstatus = 0
   FOR (idx = 1 TO status_list_size)
     IF ((pm.prot_status_cd=request->status_list[idx].prot_status_cd))
      qualifiedstatus = 1
     ENDIF
   ENDFOR
   IF (qualifiedstatus=0)
    foundother = 1
   ENDIF
  FOOT  pm.prev_prot_master_id
   IF (foundother=0)
    qualifiedprotcnt = (qualifiedprotcnt+ 1), reply->protocol_list[qualifiedprotcnt].prot_master_id
     = pm.prev_prot_master_id
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->protocol_list,qualifiedprotcnt)
 SET last_mod = "000"
 SET mod_date = "May 06, 2009"
END GO
