CREATE PROGRAM bsc_get_events_to_endorse:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 order_list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 template_order_id = f8
     2 order_status_cd = f8
     2 catalog_cd = f8
     2 order_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 orig_order_dt_tm = dq8
     2 event_list[*]
       3 event_id = f8
       3 parent_event_id = f8
       3 event_class_cd = f8
       3 event_cd = f8
       3 event_tag = vc
       3 event_title_text = vc
       3 result_val = vc
       3 result_unit_cd = f8
       3 result_status_cd = f8
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 normalcy_cd = f8
       3 normal_low = vc
       3 normal_high = vc
       3 critical_low = vc
       3 critical_high = vc
       3 ce_dynamic_label_id = f8
       3 label_name = vc
       3 importance_flag = i4
       3 note_prsnl_id = f8
       3 note_dt_tm = dq8
       3 note_tz = i4
       3 result_comment = vc
       3 order_action_prsnl_list[*]
         4 action_prsnl_id = f8
         4 action_prsnl_name = vc
         4 action_dt_tm = dq8
         4 role_list[*]
           5 role_type_cd = f8
           5 role_type_disp = vc
           5 role_type_desc = vc
           5 role_type_mean = vc
       3 event_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 FREE RECORD prsnl
 RECORD prsnl(
   1 prsnl_list[*]
     2 action_prsnl_id = f8
     2 encntr_id = f8
     2 role_list[*]
       3 role_type_cd = f8
       3 role_type_disp = vc
       3 role_type_desc = vc
       3 role_type_mean = vc
       3 role_beg_dt_tm = dq8
       3 role_end_dt_tm = dq8
       3 parent_entity_id = f8
 )
 DECLARE initialize(null) = null
 DECLARE loadresults(null) = null
 DECLARE loadresultcomments(null) = null
 DECLARE parsecommentlb(note_format_cd=f8,compression_cd=f8,long_blob=vc) = vc
 DECLARE getprsnlrole(null) = null
 DECLARE finalize(null) = null
 DECLARE printdebugmsg(msg=vc) = null
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE total_script_timer = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE subroutine_timer = f8 WITH protect, noconstant(0)
 DECLARE query_timer = f8 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE encntr_idx = i4 WITH protect, noconstant(1)
 DECLARE encntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE updt_dt_tm_parser = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE encntr_parser = vc WITH protect, noconstant(fillstring(150," "))
 DECLARE max_result_cnt = i4 WITH protect, noconstant(0)
 DECLARE max_order_prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE action_type_order = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ORDER"))
 DECLARE event_class_med = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE event_class_immun = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 DECLARE rtf = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"RTF"))
 DECLARE compressed = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE nsize = i4 WITH protect, constant(60)
 CALL initialize(null)
 CALL loadresults(null)
 CALL loadresultcomments(null)
 CALL getprsnlrole(null)
 CALL finalize(null)
 SUBROUTINE initialize(null)
   CALL printdebugmsg("***SUBROUTINE Initialize()***")
   IF ((request->from_dt_tm > 0)
    AND (request->to_dt_tm > 0))
    CALL printdebugmsg("*****Search for results bounded by both from_dt_tm and to_dt_tm.")
    SET updt_dt_tm_parser =
    " cea.updt_dt_tm >= cnvtdatetimeutc(request->from_dt_tm) and cea.updt_dt_tm <= cnvtdatetimeutc(request->to_dt_tm) "
   ELSE
    CALL printdebugmsg("*****Search for results without qualifying on cea.updt_dt_tm")
    SET updt_dt_tm_parser = " 0=0 "
   ENDIF
   SET encntr_cnt = size(request->encntr_list,5)
   IF (encntr_cnt > 0)
    SET encntr_parser =
    " expand (encntr_idx, 1, encntr_cnt, cea.encntr_id+0, request->encntr_list[encntr_idx].encntr_id) "
   ELSE
    SET encntr_parser = " 0=0 "
   ENDIF
 END ;Subroutine
 SUBROUTINE finalize(null)
   CALL printdebugmsg("***SUBROUTINE Finalize()***")
   IF ((request->debug_ind > 0))
    CALL echo("*********************************")
    CALL echo(build("Total Script Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       total_script_timer,5)))
    CALL echo("*********************************")
   ENDIF
   IF ((request->debug_ind <= 0))
    FREE RECORD prsnl
   ENDIF
   IF (size(reply->order_list,5)=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   SET error_cd = error(error_msg,1)
   IF (error_cd != 0)
    CALL echo("*********************************")
    CALL echo(build("ERROR MESSAGE : ",error_msg))
    CALL fillsubeventstatus("bsc_get_events_to_endorse.prg","F","Finalize",error_msg)
    CALL echo("*********************************")
    SET reply->status_data.status = "F"
   ENDIF
 END ;Subroutine
 SUBROUTINE loadresults(null)
   CALL printdebugmsg("***SUBROUTINE LoadResults()***")
   SET subroutine_timer = cnvtdatetime(curdate,curtime3)
   DECLARE event_cnt = i4 WITH protect, noconstant(0)
   DECLARE order_prsnl_cnt = i4 WITH protect, noconstant(0)
   DECLARE order_prsnl_cnt2 = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE order_idx = i4 WITH protect, noconstant(0)
   DECLARE prsnl_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM ce_event_action cea,
     v500_event_set_explode ese,
     v500_event_set_code esc,
     clinical_event ce,
     orders o,
     ce_dynamic_label dl,
     prsnl psl,
     v500_event_code ec,
     v500_event_set_code esc2
    PLAN (cea
     WHERE (cea.person_id=request->person_id)
      AND parser(updt_dt_tm_parser)
      AND parser(encntr_parser)
      AND ((cea.action_type_cd+ 0)=action_type_order)
      AND  NOT (((cea.event_class_cd+ 0) IN (event_class_med, event_class_immun))))
     JOIN (ese
     WHERE ese.event_cd=cea.event_cd)
     JOIN (esc
     WHERE esc.event_set_cd=ese.event_set_cd
      AND trim(esc.event_set_name)="ALL RESULT SECTIONS")
     JOIN (ce
     WHERE ce.event_id=cea.event_id
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (o
     WHERE o.order_id=ce.order_id)
     JOIN (dl
     WHERE dl.ce_dynamic_label_id=ce.ce_dynamic_label_id)
     JOIN (psl
     WHERE psl.person_id=cea.action_prsnl_id)
     JOIN (ec
     WHERE ec.event_cd=ce.event_cd)
     JOIN (esc2
     WHERE cnvtupper(esc2.event_set_name)=cnvtupper(ec.event_set_name))
    ORDER BY ce.event_end_dt_tm, o.order_id, cea.event_id,
     cea.action_prsnl_id, cea.updt_dt_tm DESC
    HEAD REPORT
     CALL printdebugmsg(build("*****LoadResults() Query Time = ",datetimediff(cnvtdatetime(curdate,
        curtime3),subroutine_timer,5))), order_cnt = 0, order_idx = 0,
     event_cnt = 0, order_prsnl_cnt = 0, order_prsnl_cnt2 = 0,
     max_result_cnt = 0
    HEAD ce.event_end_dt_tm
     order_idx = 0
    HEAD o.order_id
     order_idx = 0, event_cnt = 0
    HEAD cea.event_id
     order_prsnl_cnt = 0
     IF (((order_idx=0) OR ((o.order_id != reply->order_list[order_idx].order_id))) )
      IF (event_cnt > 0)
       stat = alterlist(reply->order_list[order_idx].event_list,event_cnt)
      ENDIF
      order_cnt = (order_cnt+ 1), order_idx = order_cnt, event_cnt = 0
     ENDIF
     IF (order_cnt > size(reply->order_list,5))
      stat = alterlist(reply->order_list,(order_cnt+ 9))
     ENDIF
     reply->order_list[order_idx].person_id = cea.person_id, reply->order_list[order_idx].encntr_id
      = cea.encntr_id
     IF (o.order_id > 0)
      reply->order_list[order_idx].order_id = o.order_id, reply->order_list[order_idx].
      template_order_id = o.template_order_id, reply->order_list[order_idx].order_status_cd = o
      .order_status_cd,
      reply->order_list[order_idx].catalog_cd = o.catalog_cd, reply->order_list[order_idx].
      order_mnemonic = o.order_mnemonic, reply->order_list[order_idx].hna_order_mnemonic = o
      .hna_order_mnemonic,
      reply->order_list[order_idx].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->order_list[
      order_idx].orig_order_dt_tm = o.orig_order_dt_tm
     ENDIF
     event_cnt = (event_cnt+ 1)
     IF (max_result_cnt < event_cnt)
      max_result_cnt = event_cnt
     ENDIF
     IF (event_cnt > size(reply->order_list[order_idx].event_list,5))
      stat = alterlist(reply->order_list[order_idx].event_list,(event_cnt+ 9))
     ENDIF
     reply->order_list[order_idx].event_list[event_cnt].event_id = cea.event_id, reply->order_list[
     order_idx].event_list[event_cnt].parent_event_id = cea.parent_event_id, reply->order_list[
     order_idx].event_list[event_cnt].event_class_cd = cea.event_class_cd,
     reply->order_list[order_idx].event_list[event_cnt].event_cd = cea.event_cd, reply->order_list[
     order_idx].event_list[event_cnt].event_tag = cea.event_tag, reply->order_list[order_idx].
     event_list[event_cnt].event_title_text = cea.event_title_text,
     reply->order_list[order_idx].event_list[event_cnt].result_val = ce.result_val, reply->
     order_list[order_idx].event_list[event_cnt].result_unit_cd = ce.result_units_cd, reply->
     order_list[order_idx].event_list[event_cnt].result_status_cd = cea.result_status_cd,
     reply->order_list[order_idx].event_list[event_cnt].event_end_dt_tm = ce.event_end_dt_tm, reply->
     order_list[order_idx].event_list[event_cnt].event_end_tz = ce.event_end_tz, reply->order_list[
     order_idx].event_list[event_cnt].normalcy_cd = cea.normalcy_cd,
     reply->order_list[order_idx].event_list[event_cnt].normal_low = ce.normal_low, reply->
     order_list[order_idx].event_list[event_cnt].normal_high = ce.normal_high, reply->order_list[
     order_idx].event_list[event_cnt].critical_low = ce.critical_low,
     reply->order_list[order_idx].event_list[event_cnt].critical_high = ce.critical_high, reply->
     order_list[order_idx].event_list[event_cnt].ce_dynamic_label_id = ce.ce_dynamic_label_id, reply
     ->order_list[order_idx].event_list[event_cnt].label_name = dl.label_name,
     reply->order_list[order_idx].event_list[event_cnt].event_set_name = esc2.event_set_name
    HEAD cea.action_prsnl_id
     IF (cea.action_prsnl_id > 0)
      order_prsnl_cnt = (order_prsnl_cnt+ 1)
      IF (max_order_prsnl_cnt < order_prsnl_cnt)
       max_order_prsnl_cnt = order_prsnl_cnt
      ENDIF
      IF (order_prsnl_cnt > size(reply->order_list[order_idx].event_list[event_cnt].
       order_action_prsnl_list,5))
       stat = alterlist(reply->order_list[order_idx].event_list[event_cnt].order_action_prsnl_list,(
        order_prsnl_cnt+ 3))
      ENDIF
      reply->order_list[order_idx].event_list[event_cnt].order_action_prsnl_list[order_prsnl_cnt].
      action_prsnl_id = cea.action_prsnl_id, reply->order_list[order_idx].event_list[event_cnt].
      order_action_prsnl_list[order_prsnl_cnt].action_prsnl_name = psl.name_full_formatted, reply->
      order_list[order_idx].event_list[event_cnt].order_action_prsnl_list[order_prsnl_cnt].
      action_dt_tm = cea.action_dt_tm,
      prsnl_idx = 0
      IF (order_prsnl_cnt2 > 0)
       prsnl_idx = locateval(iterator,1,order_prsnl_cnt2,cea.action_prsnl_id,prsnl->prsnl_list[
        iterator].action_prsnl_id)
      ENDIF
      IF (prsnl_idx=0)
       order_prsnl_cnt2 = (order_prsnl_cnt2+ 1)
       IF (order_prsnl_cnt2 > size(prsnl->prsnl_list,5))
        stat = alterlist(prsnl->prsnl_list,(order_prsnl_cnt2+ 9))
       ENDIF
       prsnl->prsnl_list[order_prsnl_cnt2].action_prsnl_id = cea.action_prsnl_id, prsnl->prsnl_list[
       order_prsnl_cnt2].encntr_id = cea.encntr_id
      ENDIF
     ENDIF
    FOOT  cea.event_id
     stat = alterlist(reply->order_list[order_idx].event_list[event_cnt].order_action_prsnl_list,
      order_prsnl_cnt)
    FOOT  o.order_id
     stat = alterlist(reply->order_list[order_idx].event_list,event_cnt)
    FOOT REPORT
     stat = alterlist(reply->order_list,order_cnt), stat = alterlist(prsnl->prsnl_list,
      order_prsnl_cnt2)
    WITH nocounter
   ;end select
   CALL printdebugmsg(build("*****LoadResults() SUBROUTINE Timer = ",datetimediff(cnvtdatetime(
       curdate,curtime3),subroutine_timer,5)))
 END ;Subroutine
 SUBROUTINE loadresultcomments(null)
   CALL printdebugmsg("***SUBROUTINE LoadResultComments()***")
   IF (max_result_cnt <= 0)
    RETURN
   ENDIF
   SET subroutine_timer = cnvtdatetime(curdate,curtime3)
   SELECT INTO "nl:"
    FROM ce_event_note cen,
     long_blob lb,
     (dummyt dorders  WITH seq = value(size(reply->order_list,5))),
     (dummyt dresults  WITH seq = value(max_result_cnt))
    PLAN (dorders)
     JOIN (dresults
     WHERE dresults.seq <= cnvtint(size(reply->order_list[dorders.seq].event_list,5)))
     JOIN (cen
     WHERE (cen.event_id=reply->order_list[dorders.seq].event_list[dresults.seq].event_id)
      AND cen.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (lb
     WHERE lb.parent_entity_id=cen.ce_event_note_id
      AND lb.parent_entity_name="CE_EVENT_NOTE")
    ORDER BY cen.event_id, cen.valid_from_dt_tm DESC
    HEAD REPORT
     CALL printdebugmsg(build("*****LoadResultComments() Query Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutine_timer,5)))
    HEAD dorders.seq
     dummy_var = 0
    HEAD dresults.seq
     dummy_var = 0
    HEAD cen.event_id
     reply->order_list[dorders.seq].event_list[dresults.seq].importance_flag = cen.importance_flag,
     reply->order_list[dorders.seq].event_list[dresults.seq].note_prsnl_id = cen.note_prsnl_id, reply
     ->order_list[dorders.seq].event_list[dresults.seq].note_dt_tm = cen.note_dt_tm,
     reply->order_list[dorders.seq].event_list[dresults.seq].note_tz = cen.note_tz, reply->
     order_list[dorders.seq].event_list[dresults.seq].result_comment = parsecommentlb(cen
      .note_format_cd,cen.compression_cd,lb.long_blob)
    FOOT REPORT
     CALL printdebugmsg(build("*****LoadResultComments() Query Total Time = ",datetimediff(
       cnvtdatetime(curdate,curtime3),subroutine_timer,5)))
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE parsecommentlb(note_format_cd,compression_cd,long_blob)
   DECLARE inbuffer = vc WITH protect, noconstant("")
   DECLARE inbuflen = i4 WITH noconstant(0)
   DECLARE outbuffer = c32000 WITH noconstant("")
   DECLARE outbuflen = i4 WITH noconstant(32000)
   DECLARE retbuflen = i4 WITH noconstant(0)
   DECLARE comment_text = vc WITH protect, noconstant("")
   DECLARE ocf = i2 WITH protect, noconstant(0)
   DECLARE bflag = i4 WITH protect, noconstant(0)
   IF (note_format_cd=rtf)
    IF (compression_cd=compressed)
     SET inbuflen = size(long_blob)
     CALL uar_ocf_uncompress(long_blob,inbuflen,outbuffer,30000,outbuflen)
     SET inbuflen = size(outbuffer)
     CALL uar_rtf2(outbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
      bflag)
     SET comment_text = outbuffer
    ELSE
     SET inbuffer = long_blob
     SET inbuflen = size(inbuffer)
     CALL uar_rtf2(inbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
      bflag)
     SET comment_text = outbuffer
    ENDIF
   ELSE
    IF (compression_cd=compressed)
     SET inbuflen = size(long_blob)
     CALL uar_ocf_uncompress(long_blob,inbuflen,outbuffer,30000,outbuflen)
     SET inbuflen = size(outbuffer)
     CALL uar_rtf2(outbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
      bflag)
     SET comment_text = outbuffer
    ELSE
     SET comment_text = long_blob
    ENDIF
   ENDIF
   SET ocf = findstring("ocf_blob",comment_text)
   IF (ocf=0)
    SET comment_text = comment_text
   ELSE
    SET comment_text = substring(1,(ocf - 1),comment_text)
   ENDIF
   RETURN(comment_text)
 END ;Subroutine
 SUBROUTINE getprsnlrole(null)
   CALL printdebugmsg("***SUBROUTINE GetPrsnlRole()***")
   SET subroutine_timer = cnvtdatetime(curdate,curtime3)
   DECLARE prsnl_cnt = i4 WITH protect, noconstant(size(prsnl->prsnl_list,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   IF (prsnl_cnt <= 0)
    CALL printdebugmsg("*****GetPrsnlRole() - prsnl_cnt is 0")
    RETURN
   ENDIF
   FREE RECORD encntr_org_reltn
   RECORD encntr_org_reltn(
     1 encounter_list[*]
       2 encntr_id = f8
       2 organization_id = f8
   )
   SET nstart = 1
   SET ntotal = (ceil((cnvtreal(prsnl_cnt)/ nsize)) * nsize)
   DECLARE role_cnt = i4 WITH protect, noconstant(0)
   DECLARE encntr_cnt = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET stat = alterlist(prsnl->prsnl_list,ntotal)
   FOR (i = (prsnl_cnt+ 1) TO ntotal)
    SET prsnl->prsnl_list[i].action_prsnl_id = prsnl->prsnl_list[prsnl_cnt].action_prsnl_id
    SET prsnl->prsnl_list[i].encntr_id = prsnl->prsnl_list[prsnl_cnt].encntr_id
   ENDFOR
   SET query_timer = cnvtdatetime(curdate,curtime3)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     prsnl_role_type prt,
     role_type_reltn rtr
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (prt
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),prt.person_id,prsnl->prsnl_list[iterator].
      action_prsnl_id))
     JOIN (rtr
     WHERE rtr.role_type_reltn_id=prt.role_type_reltn_id
      AND rtr.parent_entity_name="ORGANIZATION")
    ORDER BY prt.person_id, prt.role_type_reltn_id
    HEAD REPORT
     CALL printdebugmsg(build("*****GetPrsnlRole() Query #1 Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),query_timer,5))), role_cnt = 0
    HEAD prt.person_id
     role_cnt = 0, idx = locateval(iterator,1,prsnl_cnt,prt.person_id,prsnl->prsnl_list[iterator].
      action_prsnl_id)
    HEAD prt.role_type_reltn_id
     IF (idx > 0)
      role_cnt = (role_cnt+ 1)
      IF (role_cnt > size(prsnl->prsnl_list[idx].role_list,5))
       stat = alterlist(prsnl->prsnl_list[idx].role_list,(role_cnt+ 3))
      ENDIF
      prsnl->prsnl_list[idx].role_list[role_cnt].role_type_cd = rtr.role_type_cd, prsnl->prsnl_list[
      idx].role_list[role_cnt].role_beg_dt_tm = prt.role_beg_dt_tm, prsnl->prsnl_list[idx].role_list[
      role_cnt].role_end_dt_tm = prt.role_end_dt_tm,
      prsnl->prsnl_list[idx].role_list[role_cnt].parent_entity_id = rtr.parent_entity_id
     ENDIF
    FOOT  prt.person_id
     stat = alterlist(prsnl->prsnl_list[idx].role_list,role_cnt)
    FOOT REPORT
     CALL printdebugmsg(build("*****GetPrsnlRole() Query #1 Total Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),query_timer,5)))
    WITH nocounter
   ;end select
   SET query_timer = cnvtdatetime(curdate,curtime3)
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     encounter e
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (e
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),e.encntr_id,prsnl->prsnl_list[iterator].
      encntr_id)
      AND ((e.organization_id+ 0) > 0))
    ORDER BY e.encntr_id
    HEAD REPORT
     CALL printdebugmsg(build("*****GetPrsnlRole() Query #2 Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),query_timer,5))), encntr_cnt = 0
    DETAIL
     encntr_cnt = (encntr_cnt+ 1)
     IF (encntr_cnt > size(encntr_org_reltn->encounter_list,5))
      stat = alterlist(encntr_org_reltn->encounter_list,(encntr_cnt+ 9))
     ENDIF
     encntr_org_reltn->encounter_list[encntr_cnt].encntr_id = e.encntr_id, encntr_org_reltn->
     encounter_list[encntr_cnt].organization_id = e.organization_id
    FOOT REPORT
     stat = alterlist(encntr_org_reltn->encounter_list,encntr_cnt),
     CALL printdebugmsg(build("*****GetPrsnlRole() Query #2 Total Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),query_timer,5)))
    WITH nocounter
   ;end select
   SET stat = alterlist(prsnl->prsnl_list,prsnl_cnt)
   SET query_timer = cnvtdatetime(curdate,curtime3)
   DECLARE order_idx = i4 WITH protect, noconstant(0)
   DECLARE event_idx = i4 WITH protect, noconstant(0)
   DECLARE prsnl_idx = i4 WITH protect, noconstant(0)
   DECLARE prsnl2_idx = i4 WITH protect, noconstant(0)
   DECLARE role_idx = i4 WITH protect, noconstant(0)
   FOR (order_idx = 1 TO order_cnt)
     FOR (event_idx = 1 TO size(reply->order_list[order_idx].event_list,5))
       FOR (prsnl_idx = 1 TO size(reply->order_list[order_idx].event_list[event_idx].
        order_action_prsnl_list,5))
        SET prsnl2_idx = locateval(iterator,1,prsnl_cnt,reply->order_list[order_idx].event_list[
         event_idx].order_action_prsnl_list[prsnl_idx].action_prsnl_id,prsnl->prsnl_list[iterator].
         action_prsnl_id)
        IF (prsnl2_idx > 0)
         SET role_cnt = 0
         FOR (role_idx = 1 TO size(prsnl->prsnl_list[prsnl2_idx].role_list,5))
           IF ((((reply->order_list[order_idx].order_id > 0)
            AND (reply->order_list[order_idx].orig_order_dt_tm >= prsnl->prsnl_list[prsnl2_idx].
           role_list[role_idx].role_beg_dt_tm)
            AND (reply->order_list[order_idx].orig_order_dt_tm <= prsnl->prsnl_list[prsnl2_idx].
           role_list[role_idx].role_end_dt_tm)) OR ((reply->order_list[order_idx].order_id=0)
            AND (reply->order_list[order_idx].event_list[event_idx].event_end_dt_tm >= prsnl->
           prsnl_list[prsnl2_idx].role_list[role_idx].role_beg_dt_tm)
            AND (reply->order_list[order_idx].event_list[event_idx].event_end_dt_tm <= prsnl->
           prsnl_list[prsnl2_idx].role_list[role_idx].role_end_dt_tm))) )
            SET encntr_idx = locateval(iterator,1,encntr_cnt,reply->order_list[order_idx].encntr_id,
             encntr_org_reltn->encounter_list[iterator].encntr_id)
            IF (encntr_idx > 0)
             IF ((encntr_org_reltn->encounter_list[encntr_idx].organization_id=prsnl->prsnl_list[
             prsnl2_idx].role_list[role_idx].parent_entity_id))
              SET role_cnt = (role_cnt+ 1)
              SET stat = alterlist(reply->order_list[order_idx].event_list[event_idx].
               order_action_prsnl_list[prsnl_idx].role_list,role_cnt)
              SET reply->order_list[order_idx].event_list[event_idx].order_action_prsnl_list[
              prsnl_idx].role_list[role_cnt].role_type_cd = prsnl->prsnl_list[prsnl2_idx].role_list[
              role_idx].role_type_cd
             ENDIF
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   CALL printdebugmsg(build("*****GetPrsnlRole() Populate Roles Time = ",datetimediff(cnvtdatetime(
       curdate,curtime3),query_timer,5)))
   IF ((request->debug_ind <= 0))
    FREE RECORD encntr_org_reltn
   ENDIF
   CALL printdebugmsg(build("*****GetPrsnlRole() SUBROUTINE Timer = ",datetimediff(cnvtdatetime(
       curdate,curtime3),subroutine_timer,5)))
 END ;Subroutine
 SUBROUTINE printdebugmsg(msg)
   IF ((request->debug_ind > 0))
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 SET last_mod = "002 01/11/17"
 SET modify = nopredeclare
END GO
