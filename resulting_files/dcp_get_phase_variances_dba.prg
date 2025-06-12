CREATE PROGRAM dcp_get_phase_variances:dba
 SET modify = predeclare
 RECORD credential(
   1 credential_list[*]
     2 uncharted = i2
     2 prsnl_id = f8
     2 pw_variance_reltn_id = f8
     2 credential_cd = f8
     2 credentialdttm = dq8
     2 credential_string = vc
     2 crednamefullformated = vc
 )
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE credentialstring = vc
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE maxval = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE noteind = i2 WITH noconstant(0)
 DECLARE actionind = i2 WITH noconstant(0)
 DECLARE reasonind = i2 WITH noconstant(0)
 DECLARE chartind = i2 WITH noconstant(0)
 DECLARE unchartind = i2 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE where_clause = vc WITH noconstant(fillstring(500,""))
 SET high = value(size(request->phaselist,5))
 SET where_clause = "expand(num,1,high,pvr.pathway_id,request->phaseList[num]->pathwayId)"
 IF (validate(request->load_inactive_ind,999)=999)
  SET where_clause = concat(where_clause," AND pvr.active_ind = 1")
 ELSEIF ((request->load_inactive_ind=0))
  SET where_clause = concat(where_clause," AND pvr.active_ind = 1")
 ENDIF
 SELECT INTO "nl:"
  FROM pw_variance_reltn pvr
  PLAN (pvr
   WHERE parser(where_clause))
  ORDER BY pvr.chart_dt_tm DESC
  HEAD REPORT
   variancecnt = 0, credentialcnt = 1
  DETAIL
   variancecnt = (variancecnt+ 1)
   IF (variancecnt > size(reply->variancelist,5))
    stat = alterlist(reply->variancelist,(variancecnt+ 5))
   ENDIF
   IF (((credentialcnt+ 1) > size(credential->credential_list,5)))
    stat = alterlist(credential->credential_list,(credentialcnt+ 5))
   ENDIF
   reply->variancelist[variancecnt].variance_reltn_id = pvr.pw_variance_reltn_id, reply->
   variancelist[variancecnt].parent_entity_name = pvr.parent_entity_name, reply->variancelist[
   variancecnt].parent_entity_id = pvr.parent_entity_id,
   reply->variancelist[variancecnt].pathway_id = pvr.pathway_id, reply->variancelist[variancecnt].
   event_id = pvr.event_id, reply->variancelist[variancecnt].variance_type_cd = pvr.variance_type_cd,
   reply->variancelist[variancecnt].variance_type_disp = uar_get_code_display(pvr.variance_type_cd),
   reply->variancelist[variancecnt].variance_type_mean = uar_get_code_meaning(pvr.variance_type_cd),
   reply->variancelist[variancecnt].active_ind = pvr.active_ind,
   reply->variancelist[variancecnt].action_cd = pvr.action_cd, reply->variancelist[variancecnt].
   action_disp = uar_get_code_display(pvr.action_cd), reply->variancelist[variancecnt].action_mean =
   uar_get_code_meaning(pvr.action_cd),
   reply->variancelist[variancecnt].action_text_id = pvr.action_text_id
   IF (pvr.action_text_id > 0
    AND actionind=0)
    actionind = 1
   ENDIF
   reply->variancelist[variancecnt].reason_cd = pvr.reason_cd, reply->variancelist[variancecnt].
   reason_disp = uar_get_code_display(pvr.reason_cd), reply->variancelist[variancecnt].reason_mean =
   uar_get_code_meaning(pvr.reason_cd),
   reply->variancelist[variancecnt].reason_text_id = pvr.reason_text_id
   IF (pvr.reason_text_id > 0
    AND reasonind=0)
    reasonind = 1
   ENDIF
   reply->variancelist[variancecnt].variance_updt_cnt = pvr.updt_cnt, reply->variancelist[variancecnt
   ].active_ind = pvr.active_ind, reply->variancelist[variancecnt].note_text_id = pvr.note_text_id
   IF (pvr.note_text_id > 0
    AND noteind=0)
    noteind = 1
   ENDIF
   IF (pvr.chart_prsnl_id > 0)
    chartind = 1, reply->variancelist[variancecnt].chart_dt_tm = cnvtdatetime(pvr.chart_dt_tm), reply
    ->variancelist[variancecnt].chart_prsnl_id = pvr.chart_prsnl_id,
    credential->credential_list[credentialcnt].prsnl_id = pvr.chart_prsnl_id, credential->
    credential_list[credentialcnt].pw_variance_reltn_id = pvr.pw_variance_reltn_id, credential->
    credential_list[credentialcnt].uncharted = 0,
    credential->credential_list[credentialcnt].credentialdttm = pvr.chart_dt_tm, credentialcnt = (
    credentialcnt+ 1)
   ENDIF
   IF (pvr.unchart_prsnl_id > 0)
    unchartind = 1, reply->variancelist[variancecnt].unchart_dt_tm = cnvtdatetime(pvr.unchart_dt_tm),
    reply->variancelist[variancecnt].unchart_prsnl_id = pvr.unchart_prsnl_id,
    credential->credential_list[credentialcnt].prsnl_id = pvr.unchart_prsnl_id, credential->
    credential_list[credentialcnt].pw_variance_reltn_id = pvr.pw_variance_reltn_id, credential->
    credential_list[credentialcnt].uncharted = 1,
    credential->credential_list[credentialcnt].credentialdttm = pvr.unchart_dt_tm, credentialcnt = (
    credentialcnt+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->variancelist[variancecnt],variancecnt), stat = alterlist(credential->
    credential_list[credentialcnt],(credentialcnt - 1))
  WITH nocounter
 ;end select
 SET high = value(size(reply->variancelist,5))
 IF (high > 0)
  IF (chartind > 0)
   SET num = 0
   SET maxval = size(credential->credential_list,5)
   SELECT INTO "nl:"
    FROM credential c,
     code_value cv
    PLAN (c
     WHERE expand(num,1,maxval,c.prsnl_id,credential->credential_list[num].prsnl_id))
     JOIN (cv
     WHERE cv.code_value=c.credential_cd)
    ORDER BY c.display_seq
    HEAD REPORT
     credentialcnt = 0, credentialstring = ""
    DETAIL
     CALL echo(build("Personnel ID = ",c.prsnl_id)), credentialcnt = (credentialcnt+ 1)
     FOR (idx = 1 TO size(credential->credential_list,5))
       IF ((credential->credential_list[idx].prsnl_id=c.prsnl_id)
        AND (c.beg_effective_dt_tm < credential->credential_list[idx].credentialdttm)
        AND (c.end_effective_dt_tm > credential->credential_list[idx].credentialdttm)
        AND c.active_ind=1
        AND ((c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND c.display_seq > 0) OR (c.end_effective_dt_tm < cnvtdatetime(curdate,curtime3))) )
        credential->credential_list[idx].credential_string = concat(trim(cv.display_key)," ",trim(
          credential->credential_list[idx].credential_string))
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   SET num = 0
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE expand(num,1,maxval,p.person_id,credential->credential_list[num].prsnl_id))
    HEAD REPORT
     idx = 0, idx2 = 0
    DETAIL
     idx = locateval(idx,1,maxval,p.person_id,credential->credential_list[idx].prsnl_id)
     IF (idx > 0)
      credential->credential_list[idx].crednamefullformated = concat(trim(p.name_last)," ",trim(
        credential->credential_list[idx].credential_string),", ",trim(p.name_first))
     ENDIF
     idx2 = idx
     WHILE (idx != 0)
      idx2 = locateval(idx2,(idx+ 1),maxval,p.person_id,credential->credential_list[idx2].prsnl_id),
      IF (idx2 != 0)
       idx = idx2, credential->credential_list[idx2].crednamefullformated = concat(trim(p.name_last),
        " ",trim(credential->credential_list[idx2].credential_string),", ",trim(p.name_first))
      ELSE
       idx = idx2
      ENDIF
     ENDWHILE
    FOOT REPORT
     idx = idx
    WITH nocounter
   ;end select
   SET idx2 = 0
   FOR (idx = 1 TO size(credential->credential_list,5))
    SET idx2 = locateval(idx2,1,maxval,credential->credential_list[idx].pw_variance_reltn_id,reply->
     variancelist[idx2].variance_reltn_id)
    IF (idx2 > 0)
     IF ((credential->credential_list[idx].uncharted=0))
      SET reply->variancelist[idx2].chart_prsnl_name = trim(credential->credential_list[idx].
       crednamefullformated)
     ELSE
      SET reply->variancelist[idx2].unchart_prsnl_name = trim(credential->credential_list[idx].
       crednamefullformated)
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
  IF (actionind > 0)
   SET num = 0
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(num,1,high,lt.long_text_id,reply->variancelist[num].action_text_id))
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,lt.long_text_id,reply->variancelist[idx].action_text_id)
     IF (idx > 0)
      reply->variancelist[idx].action_text = trim(lt.long_text), reply->variancelist[idx].
      action_text_updt_cnt = lt.updt_cnt
     ENDIF
    FOOT REPORT
     idx = idx
    WITH nocounter
   ;end select
  ENDIF
  IF (reasonind > 0)
   SET num = 0
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(num,1,high,lt.long_text_id,reply->variancelist[num].reason_text_id))
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,lt.long_text_id,reply->variancelist[idx].reason_text_id)
     IF (idx > 0)
      reply->variancelist[idx].reason_text = trim(lt.long_text), reply->variancelist[idx].
      reason_text_updt_cnt = lt.updt_cnt
     ENDIF
    FOOT REPORT
     idx = idx
    WITH nocounter
   ;end select
  ENDIF
  IF (noteind > 0)
   SET num = 0
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(num,1,high,lt.long_text_id,reply->variancelist[num].note_text_id))
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,lt.long_text_id,reply->variancelist[idx].note_text_id)
     IF (idx > 0)
      reply->variancelist[idx].note_text = trim(lt.long_text), reply->variancelist[idx].
      note_text_updt_cnt = lt.updt_cnt
     ENDIF
    FOOT REPORT
     idx = idx
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
END GO
