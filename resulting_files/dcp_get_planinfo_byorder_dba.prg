CREATE PROGRAM dcp_get_planinfo_byorder:dba
 RECORD reply(
   1 planinfo[*]
     2 pathway_id = f8
     2 pathway_type_cd = f8
     2 plan_desc = vc
     2 phase_desc = vc
     2 subphase_desc = vc
     2 comp_id = f8
     2 offset_qty = f8
     2 offset_unit_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tmprec(
   1 qual[*]
     2 comp_id = f8
 )
 DECLARE cfailed = c1 WITH protect, noconstant("F")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE plancnt = i4 WITH protect, noconstant(0)
 DECLARE tmpreccnt = i4 WITH protect, noconstant(0)
 DECLARE debug = i2 WITH protect, constant(validate(request->debug))
 DECLARE locateindex = i4 WITH protect, noconstant(0)
 DECLARE unitcd_hours = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"HOURS"))
 DECLARE first_order_flag = i2 WITH protect, noconstant(0)
 DECLARE get_plan_info(ord_id=f8) = i4
 DECLARE is_first_order(sb_template_order_id=f8,sb_order_id=f8) = i2
 DECLARE get_offset() = null
 DECLARE recheck_time_zero_order() = null
 IF (debug=1)
  CALL echorecord(request)
 ENDIF
 IF (validate(request->template_order_id)=0
  AND validate(request->order_id)=0)
  SET cfailed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->template_order_id > 0))
  IF (validate(request->order_id)=0)
   SET cfailed = "T"
   GO TO exit_script
  ENDIF
  SET plancnt = get_plan_info(request->template_order_id)
  IF (plancnt > 0
   AND (request->order_id > 0))
   SET first_order_flag = is_first_order(request->template_order_id,request->order_id)
  ENDIF
  IF (first_order_flag=1)
   CALL get_offset(null)
  ENDIF
 ENDIF
 IF (plancnt=0
  AND (request->order_id > 0))
  CALL get_plan_info(request->order_id)
  CALL get_offset(null)
 ENDIF
 CALL recheck_time_zero_order(null)
 SUBROUTINE get_plan_info(ord_id)
   SET plancnt = 0
   SET tmpreccnt = 0
   IF (ord_id=0)
    RETURN(plancnt)
   ENDIF
   SELECT INTO "nl:"
    o.protocol_order_id
    FROM orders o
    WHERE o.order_id=ord_id
     AND o.protocol_order_id > 0.0
    HEAD o.protocol_order_id
     ord_id = o.protocol_order_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM act_pw_comp apc,
     pathway pw
    PLAN (apc
     WHERE apc.parent_entity_id=ord_id
      AND apc.parent_entity_name="ORDERS"
      AND apc.active_ind=1)
     JOIN (pw
     WHERE pw.pathway_id=apc.pathway_id
      AND pw.type_mean IN ("CAREPLAN", "SUBPHASE", "PHASE"))
    ORDER BY apc.act_pw_comp_id
    HEAD pw.pathway_id
     plancnt = (plancnt+ 1),
     CALL echo(build(" planCnt = ",plancnt))
     IF (plancnt > size(reply->planinfo,5))
      stat = alterlist(reply->planinfo,(plancnt+ 3))
     ENDIF
     IF (pw.type_mean="SUBPHASE")
      reply->planinfo[plancnt].plan_desc = trim(pw.pw_group_desc), reply->planinfo[plancnt].
      phase_desc = trim(pw.parent_phase_desc), reply->planinfo[plancnt].subphase_desc = trim(pw
       .description)
     ELSEIF (pw.type_mean="PHASE")
      reply->planinfo[plancnt].plan_desc = trim(pw.pw_group_desc), reply->planinfo[plancnt].
      phase_desc = trim(pw.description)
     ELSEIF (pw.type_mean="CAREPLAN")
      reply->planinfo[plancnt].plan_desc = trim(pw.description)
     ENDIF
     reply->planinfo[plancnt].pathway_id = pw.pathway_id, reply->planinfo[plancnt].pathway_type_cd =
     pw.pathway_type_cd, reply->planinfo[plancnt].comp_id = apc.act_pw_comp_id
     IF (apc.offset_quantity=0)
      tmpreccnt = (tmpreccnt+ 1)
      IF (tmpreccnt > size(tmprec->qual,5))
       stat = alterlist(tmprec->qual,(tmpreccnt+ 3))
      ENDIF
      tmprec->qual[tmpreccnt].comp_id = apc.act_pw_comp_id
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->planinfo,plancnt), stat = alterlist(tmprec->qual,tmpreccnt)
    WITH nocounter
   ;end select
   RETURN(plancnt)
 END ;Subroutine
 SUBROUTINE is_first_order(sb_template_order_id,sb_order_id)
   DECLARE sb_first_order_flag = i2 WITH protect, noconstant(0)
   DECLARE ordernum = i4 WITH protect, noconstant(0)
   IF (((sb_template_order_id <= 0) OR (sb_order_id <= 0)) )
    RETURN(sb_first_order_flag)
   ENDIF
   SELECT INTO "nl:"
    FROM orders o
    PLAN (o
     WHERE o.template_order_id=sb_template_order_id
      AND o.active_ind=1)
    ORDER BY o.orig_order_dt_tm
    HEAD o.order_id
     ordernum = (ordernum+ 1)
     IF (ordernum=1
      AND sb_order_id=o.order_id)
      sb_first_order_flag = 1
     ENDIF
    WITH maxqual(o,2)
   ;end select
   RETURN(sb_first_order_flag)
 END ;Subroutine
 SUBROUTINE get_offset(null)
   IF (((plancnt=0) OR (tmpreccnt=0)) )
    RETURN
   ENDIF
   DECLARE loopcnt = i4 WITH protect, noconstant(0)
   DECLARE locateplan = i4 WITH protect, noconstant(0)
   DECLARE maxexpcnt = i4 WITH protect, constant(20)
   DECLARE expblocksize = i4 WITH protect, constant(ceil(((tmpreccnt * 1.0)/ maxexpcnt)))
   DECLARE ex_start = i4 WITH protect, noconstant(1)
   DECLARE ex_idx = i4 WITH protect, noconstant(1)
   DECLARE expmaxsize = i4 WITH protect, noconstant((expblocksize * maxexpcnt))
   SET stat = alterlist(tmprec->qual,expmaxsize)
   FOR (loopcnt = (tmpreccnt+ 1) TO expmaxsize)
     SET tmprec->qual[loopcnt].comp_id = tmprec->qual[tmpreccnt].comp_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(expblocksize)),
     act_pw_comp_r compr
    PLAN (d1
     WHERE assign(ex_start,evaluate(d1.seq,1,1,(ex_start+ maxexpcnt))))
     JOIN (compr
     WHERE expand(ex_idx,ex_start,((ex_start+ maxexpcnt) - 1),compr.act_pw_comp_t_id,tmprec->qual[
      ex_idx].comp_id))
    ORDER BY compr.act_pw_comp_t_id
    HEAD compr.act_pw_comp_t_id
     locateplan = locateval(locateindex,1,size(reply->planinfo,5),compr.act_pw_comp_t_id,reply->
      planinfo[locateindex].comp_id)
     IF (locateplan > 0)
      reply->planinfo[locateplan].offset_qty = compr.offset_quantity, reply->planinfo[locateplan].
      offset_unit_cd = compr.offset_unit_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE recheck_time_zero_order(null)
   IF (plancnt=0)
    RETURN
   ENDIF
   DECLARE no_match_cnt = i4 WITH protect, noconstant(0)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(tmprec->qual,0)
   FOR (icnt = 1 TO plancnt)
     IF ((reply->planinfo[icnt].offset_unit_cd <= 0))
      SET no_match_cnt = (no_match_cnt+ 1)
      IF (no_match_cnt > size(tmprec->qual,5))
       SET stat = alterlist(tmprec->qual,(no_match_cnt+ 3))
      ENDIF
      SET tmprec->qual[no_match_cnt].comp_id = reply->planinfo[icnt].comp_id
     ENDIF
   ENDFOR
   IF (no_match_cnt=0)
    RETURN
   ENDIF
   DECLARE locatepl = i4 WITH protect, noconstant(0)
   DECLARE maxcnt = i4 WITH protect, constant(10)
   DECLARE blocksize = i4 WITH protect, constant(ceil(((no_match_cnt * 1.0)/ maxcnt)))
   DECLARE x_start = i4 WITH protect, noconstant(1)
   DECLARE x_idx = i4 WITH protect, noconstant(1)
   DECLARE xmaxsize = i4 WITH protect, noconstant((blocksize * maxcnt))
   SET stat = alterlist(tmprec->qual,xmaxsize)
   FOR (icnt = (no_match_cnt+ 1) TO xmaxsize)
     SET tmprec->qual[icnt].comp_id = tmprec->qual[no_match_cnt].comp_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(blocksize)),
     act_pw_comp_r compr
    PLAN (d1
     WHERE assign(x_start,evaluate(d1.seq,1,1,(x_start+ maxcnt))))
     JOIN (compr
     WHERE expand(x_idx,x_start,((x_start+ maxcnt) - 1),compr.act_pw_comp_s_id,tmprec->qual[x_idx].
      comp_id))
    ORDER BY compr.act_pw_comp_s_id
    HEAD compr.act_pw_comp_s_id
     locatepl = locateval(locateindex,1,size(reply->planinfo,5),compr.act_pw_comp_s_id,reply->
      planinfo[locateindex].comp_id)
     IF (locatepl > 0)
      reply->planinfo[locatepl].offset_unit_cd = unitcd_hours
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
END GO
