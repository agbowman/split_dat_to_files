CREATE PROGRAM dcp_get_act_comp_group_actions:dba
 SET modify = predeclare
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE lfindindex = i4 WITH protect, noconstant(0)
 DECLARE lcount = i4 WITH protect, noconstant(0)
 DECLARE lsize = i4 WITH protect, noconstant(0)
 DECLARE lreplycompgroupactionsize = i4 WITH protect, noconstant(0)
 DECLARE lactionscount = i4 WITH protect, noconstant(0)
 DECLARE lactionssize = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 SET lsize = size(request->compgroupidlist,5)
 SET stat = alterlist(reply->compgroupactionlist,lsize)
 FOR (lcount = 1 TO lsize)
   SET reply->compgroupactionlist[lcount].act_pw_comp_g_id = request->compgroupidlist[lcount].
   act_pw_comp_g_id
 ENDFOR
 SET lreplycompgroupactionsize = size(reply->compgroupactionlist,5)
 SELECT INTO "nl:"
  apcga.act_pw_comp_g_id
  FROM act_pw_comp_g_action apcga
  WHERE expand(num,1,lreplycompgroupactionsize,apcga.act_pw_comp_g_id,reply->compgroupactionlist[num]
   .act_pw_comp_g_id)
  ORDER BY apcga.act_pw_comp_g_id, apcga.sequence
  HEAD REPORT
   ndummy = 0
  HEAD apcga.act_pw_comp_g_id
   lactionscount = 0, lactionssize = 0, idx = locateval(lfindindex,1,lreplycompgroupactionsize,apcga
    .act_pw_comp_g_id,reply->compgroupactionlist[lfindindex].act_pw_comp_g_id)
  DETAIL
   IF (idx > 0)
    lactionscount = (lactionscount+ 1)
    IF (lactionscount > lactionssize)
     lactionssize = (lactionssize+ 5), stat = alterlist(reply->compgroupactionlist[idx].actions,
      lactionssize)
    ENDIF
    reply->compgroupactionlist[idx].act_pw_comp_g_id = apcga.act_pw_comp_g_id, reply->
    compgroupactionlist[idx].actions[lactionscount].sequence = apcga.sequence, reply->
    compgroupactionlist[idx].actions[lactionscount].type_flag = apcga.type_flag,
    reply->compgroupactionlist[idx].actions[lactionscount].prsnl_id = apcga.prsnl_id, reply->
    compgroupactionlist[idx].actions[lactionscount].reason_cd = apcga.reason_cd, reply->
    compgroupactionlist[idx].actions[lactionscount].reason_comment = apcga.reason_comment,
    reply->compgroupactionlist[idx].actions[lactionscount].action_dt_tm = apcga.action_dt_tm, reply->
    compgroupactionlist[idx].actions[lactionscount].action_tz = apcga.action_tz
   ENDIF
  FOOT  apcga.act_pw_comp_g_id
   IF (lactionscount > 0)
    stat = alterlist(reply->compgroupactionlist[idx].actions,lactionscount)
   ENDIF
  FOOT REPORT
   ndummy = 0
  WITH nocounter, expand = 1
 ;end select
 IF (lreplycompgroupactionsize > 0)
  SET cstatus = "S"
 ENDIF
 SET reply->status_data.status = cstatus
 DECLARE last_mod = c3 WITH protect, constant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, constant(fillstring(30,"April 9, 2013"))
END GO
