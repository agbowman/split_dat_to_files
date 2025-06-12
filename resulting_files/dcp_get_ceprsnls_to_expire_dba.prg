CREATE PROGRAM dcp_get_ceprsnls_to_expire:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 super_select = vc
    1 event_prsnl_list[*]
      2 encntr_id = f8
      2 person_id = f8
      2 event_prsnl_id = f8
      2 action_type_cd = f8
      2 action_status_cd = f8
      2 action_prsnl_id = f8
      2 req_dt_tm = dq8
      2 med_rec_num = vc
      2 financial_num = vc
      2 discharge_dt_tm = dq8
      2 encounter_type_cd = f8
      2 organization_id = f8
      2 org_name = vc
      2 facility_cd = f8
      2 event_cd = f8
      2 event_cd_disp = c40
      2 ce_event_prsnl_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tempreply(
   1 event_prsnl_list[*]
     2 encntr_id = f8
     2 person_id = f8
     2 event_prsnl_id = f8
     2 action_type_cd = f8
     2 action_status_cd = f8
     2 action_prsnl_id = f8
     2 req_dt_tm = dq8
     2 med_rec_num = vc
     2 financial_num = vc
     2 discharge_dt_tm = dq8
     2 encounter_type_cd = f8
     2 organization_id = f8
     2 org_name = vc
     2 facility_cd = f8
     2 event_cd = f8
     2 event_cd_disp = c40
     2 ce_event_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE ce_where = vc WITH noconstant
 DECLARE ceep_where = vc WITH noconstant
 DECLARE e_where = vc WITH noconstant
 DECLARE e_where2 = vc WITH noconstant
 DECLARE vese_where = vc WITH noconstant
 DECLARE temp_where = vc WITH noconstant
 DECLARE temp_where2 = vc WITH noconstant
 DECLARE super_where = vc WITH noconstant
 DECLARE super_detail = vc WITH noconstant
 DECLARE swithmaxrec = vc WITH noconstant
 DECLARE addor = i2 WITH noconstant
 DECLARE grouping_order = f8 WITH noconstant
 DECLARE days = i4 WITH noconstant
 DECLARE reply_count = i4 WITH noconstant
 DECLARE ex_rule_cnt = i4 WITH noconstant
 DECLARE rule_def_cnt = i4 WITH noconstant
 DECLARE inumprnslrowsperbatch = i4 WITH noconstant
 DECLARE maxrc = i4 WITH noconstant
 DECLARE doc_type_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"DOCTYPE"))
 DECLARE action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ACTIONTYPE"))
 DECLARE action_prsnl_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ACTIONPRSNL"))
 DECLARE encounter_type_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ENCNTRTYPE"))
 DECLARE encounter_stat_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ENCNTRSTATUS"))
 DECLARE days_since_dis_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"DAYSINCEDSCH"))
 DECLARE organization_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ORGANIZATION"))
 DECLARE facility_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"FACILITY"))
 DECLARE location_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"LOCATION"))
 DECLARE age_of_request_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"AGEOFREQ"))
 DECLARE max_num_of_rows_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"MAXNUMOFROWS"))
 DECLARE pa_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE ea_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ea_fin_nbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE action_requested_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"REQUESTED"))
 DECLARE action_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"PENDING"))
 DECLARE super_select = vc WITH constant('select distinct into "nl:"')
 DECLARE valid_until_dt_tm = vc WITH constant("31-DEC-2100 00:00:00")
 DECLARE num_of_ex_rule = i4 WITH noconstant(cnvtint(size(request->expire_rule,5)))
 SET tempreply->status_data.status = "S"
 SET addor = 0
 SET grouping_order = 0
 SET days = 0
 SET reply_count = 0
 SET ex_rule_cnt = 0
 SET rule_def_cnt = 0
 SET inumprnslrowsperbatch = 0
 SET maxrc = value(request->max_rec)
 FOR (ex_rule_cnt = 1 TO num_of_ex_rule)
   SET super_where = " "
   SET vese_where = " "
   SET temp_where = " "
   SET temp_where2 = " "
   SET super_where = " "
   SET super_detail = " "
   SET ce_where = " "
   SET ceep_where = " "
   SET swithmaxrec = " "
   SET e_where = " "
   SET e_where2 = " "
   SET rule_def_cnt = cnvtint(size(request->expire_rule[ex_rule_cnt].rule_definition,5))
   SELECT INTO "nl:"
    grouping_order = request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].rule_type_cd
    FROM (dummyt d1  WITH seq = value(rule_def_cnt))
    ORDER BY grouping_order
    HEAD grouping_order
     CALL addandtowhere(request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].rule_type_cd)
     CASE (request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].rule_type_cd)
      OF doc_type_cd:
       vese_where = concat(vese_where,"vese.event_set_cd in (")
      OF action_type_cd:
       ceep_where = concat(ceep_where," ceep.action_type_cd in (")
      OF action_prsnl_cd:
       ceep_where = concat(ceep_where," ceep.action_prsnl_id in (")
      OF encounter_type_cd:
       e_where = concat(e_where," e.encntr_type_cd+0 in (")
      OF encounter_stat_cd:
       e_where = concat(e_where," e.encntr_status_cd in (")
      OF days_since_dis_cd:
       e_where = concat(e_where," e.disch_dt_tm+0 <= cnvtdatetime(")
      OF organization_cd:
       e_where = concat(e_where," e.organization_id+0 in ("),
       IF ((request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].loc_facility_cd > 0))
        e_where2 = concat(e_where2," e.loc_facility_cd+0 in (")
       ENDIF
      OF age_of_request_cd:
       ceep_where = concat(ceep_where," ceep.request_dt_tm <= cnvtdatetime(")
      OF max_num_of_rows_cd:
       swithmaxrec = concat(swithmaxrec," maxrec=")
      ELSE
       tempreply->status_data.status = "F"
     ENDCASE
     addor = 0, days = 0, temp_where = " ",
     temp_where2 = " ", days = 0, inumprnslrowsperbatch = 0
    DETAIL
     IF ((((request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].rule_type_cd=days_since_dis_cd)
     ) OR ((request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].rule_type_cd=age_of_request_cd)
     )) )
      IF (days < cnvtint(request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].param_value))
       days = cnvtint(request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].param_value)
      ENDIF
     ELSEIF ((request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].rule_type_cd=
     max_num_of_rows_cd))
      IF (inumprnslrowsperbatch < cnvtint(request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].
       param_value))
       inumprnslrowsperbatch = cnvtint(request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].
        param_value)
      ENDIF
     ELSE
      IF (addor=1)
       temp_where = concat(temp_where,","), temp_where2 = concat(temp_where2,",")
      ENDIF
      temp_where = concat(temp_where,trim(cnvtstring(request->expire_rule[ex_rule_cnt].
         rule_definition[d1.seq].merge_value))), temp_where2 = concat(temp_where2,trim(cnvtstring(
         request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].loc_facility_cd))), addor = 1
     ENDIF
    FOOT  grouping_order
     CASE (request->expire_rule[ex_rule_cnt].rule_definition[d1.seq].rule_type_cd)
      OF doc_type_cd:
       vese_where = concat(vese_where,temp_where,")")
      OF action_type_cd:
       ceep_where = concat(ceep_where,temp_where,")")
      OF action_prsnl_cd:
       ceep_where = concat(ceep_where,temp_where,")")
      OF encounter_type_cd:
       e_where = concat(e_where,temp_where,")")
      OF encounter_stat_cd:
       e_where = concat(e_where,temp_where,")")
      OF days_since_dis_cd:
       e_where = concat(e_where,concat('"',format(datetimeadd(cnvtdatetime(curdate,curtime3),- (days)
           ),";;q"),'"'),")")
      OF organization_cd:
       e_where = concat(e_where,temp_where,")"),
       IF (e_where2 > " ")
        e_where2 = concat(e_where2,temp_where2,")")
       ENDIF
      OF age_of_request_cd:
       ceep_where = concat(ceep_where,concat('"',format(datetimeadd(cnvtdatetime(curdate,curtime3),
           - (days)),";;q"),'"'),")")
      OF max_num_of_rows_cd:
       swithmaxrec = concat(swithmaxrec,cnvtstring(inumprnslrowsperbatch))
      ELSE
       tempreply->status_data.status = "F"
     ENDCASE
    WITH nocounter
   ;end select
   IF ((tempreply->status_data.status="F"))
    GO TO exit_script
   ENDIF
   CALL buildselectquery(1)
   CALL parser(super_select)
   CALL parser(super_where)
   CALL parser(super_detail)
   CALL parser("go")
   SET reply->super_select = concat(super_select," ",super_where," ",super_detail)
   CALL echo(build("########################################################"))
   CALL echo(build(super_select))
   CALL echo(build(super_where))
   CALL echo(build(super_detail))
 ENDFOR
 IF (reply_count <= 0)
  SET tempreply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d2  WITH seq = value(reply_count)),
   encntr_alias ea,
   encounter enc
  PLAN (d2)
   JOIN (enc
   WHERE (enc.encntr_id=tempreply->event_prsnl_list[d2.seq].encntr_id))
   JOIN (ea
   WHERE ea.encntr_id=enc.encntr_id)
  DETAIL
   IF (ea.encntr_alias_type_cd=ea_mrn_cd
    AND ea.alias != "")
    tempreply->event_prsnl_list[d2.seq].med_rec_num = ea.alias
   ELSEIF (ea.encntr_alias_type_cd=ea_fin_nbr_cd
    AND ea.alias != "")
    tempreply->event_prsnl_list[d2.seq].financial_num = ea.alias
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d2  WITH seq = value(reply_count)),
   person_alias pa,
   encounter enc
  PLAN (d2)
   JOIN (enc
   WHERE (enc.encntr_id=tempreply->event_prsnl_list[d2.seq].encntr_id))
   JOIN (pa
   WHERE pa.person_id=enc.person_id)
  DETAIL
   IF (pa.person_alias_type_cd=pa_mrn_cd
    AND pa.alias != ""
    AND (tempreply->event_prsnl_list[d2.seq].med_rec_num=""))
    tempreply->event_prsnl_list[d2.seq].med_rec_num = pa.alias
   ENDIF
  WITH nocounter
 ;end select
 GO TO exit_script
 SUBROUTINE addandtowhere(rule_type_cd)
   CASE (rule_type_cd)
    OF doc_type_cd:
     IF (vese_where > " ")
      SET vese_where = concat(vese_where," and ")
     ENDIF
    OF action_type_cd:
     IF (ceep_where > " ")
      SET ceep_where = concat(ceep_where," and ")
     ENDIF
    OF action_prsnl_cd:
     IF (ceep_where > " ")
      SET ceep_where = concat(ceep_where," and ")
     ENDIF
    OF encounter_type_cd:
     IF (e_where > " ")
      SET e_where = concat(e_where," and ")
     ENDIF
    OF days_since_dis_cd:
     IF (e_where > " ")
      SET e_where = concat(e_where," and ")
     ENDIF
    OF encounter_stat_cd:
     IF (e_where > " ")
      SET e_where = concat(e_where," and ")
     ENDIF
    OF organization_cd:
     IF (e_where > " ")
      SET e_where = concat(e_where," and ")
     ENDIF
     IF (e_where2 > " ")
      SET e_where2 = concat(e_where2," and ")
     ENDIF
    OF age_of_request_cd:
     IF (ceep_where > " ")
      SET ceep_where = concat(ceep_where," and ")
     ENDIF
    OF max_num_of_rows_cd:
     IF (swithmaxrec > " ")
      SET swithmaxrec = concat(swithmaxrec,"")
     ENDIF
    ELSE
     SET tempreply->status_data.status = "F"
   ENDCASE
 END ;Subroutine
 SUBROUTINE buildselectquery(int)
   SET super_where = concat(super_where," from ce_event_prsnl ceep,"," clinical_event ce,",
    " encounter e, organization o")
   IF (vese_where > " ")
    SET super_where = concat(super_where,", v500_event_set_explode vese")
   ENDIF
   SET super_where = concat(super_where,
    " plan ceep where ceep.action_status_cd in (ACTION_REQUESTED_CD, ACTION_PENDING_CD)")
   SET super_where = concat(super_where,
    " and ceep.valid_until_dt_tm in(CNVTDATETIME(VALID_UNTIL_DT_TM))")
   SET super_where = concat(super_where," and ceep.ce_event_prsnl_id > ",cnvtstring(request->
     start_ce_event_prsnl))
   SET super_where = concat(super_where,".00")
   IF (ceep_where > " ")
    SET super_where = concat(super_where," and ",ceep_where)
   ENDIF
   SET super_where = concat(super_where," join ce where ce.event_id = ceep.event_id")
   SET super_where = concat(super_where," and CNVTDATETIME(CURDATE, curtime3) < ce.valid_until_dt_tm"
    )
   IF (vese_where > " ")
    SET super_where = concat(super_where," join vese where vese.event_cd = ce.event_cd")
    SET super_where = concat(super_where," and ",vese_where)
   ENDIF
   SET super_where = concat(super_where," join e where e.encntr_id = ce.encntr_id")
   SET super_where = concat(super_where," and e.active_ind = 1")
   IF (e_where > " ")
    SET super_where = concat(super_where," and ",e_where)
   ENDIF
   IF (e_where2 > " ")
    SET super_where = concat(super_where," and ",e_where2)
   ENDIF
   SET super_where = concat(super_where," join o where o.organization_id = e.organization_id")
   IF (swithmaxrec=" ")
    SET super_where = concat(super_where," order by ceep.ce_event_prsnl_id")
   ENDIF
   SET super_detail = "head report"
   SET super_detail = concat(super_detail," reply_count = 0")
   IF (swithmaxrec=" ")
    IF (value(maxrc) > 0)
     SET super_detail = concat(super_detail," head ceep.ce_event_prsnl_id")
     SET super_detail = concat(super_detail,
      " stat = alterlist(tempreply->event_prsnl_list,value(maxrc))")
    ENDIF
   ELSE
    SET super_detail = concat(super_detail,
     " stat = alterlist(tempreply->event_prsnl_list,value(iNumPrnslRowsPerBatch))")
   ENDIF
   SET super_detail = concat(super_detail," detail")
   SET super_detail = concat(super_detail," reply_count = reply_count + 1 ")
   IF (swithmaxrec=" "
    AND value(maxrc) <= 0)
    SET super_detail = concat(super_detail,
     " if (size(tempreply->event_prsnl_list, 5) <= reply_count)")
    SET super_detail = concat(super_detail,
     " stat = alterlist(tempreply->event_prsnl_list, reply_count+25)")
    SET super_detail = concat(super_detail," endif")
   ENDIF
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->encntr_id = ce.encntr_id")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->person_id = ceep.person_id")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->event_prsnl_id = ceep.event_prsnl_id")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->action_type_cd = ceep.action_type_cd")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->action_status_cd = ceep.action_status_cd")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->action_prsnl_id = ceep.action_prsnl_id")
   SET super_detail = concat(super_detail," tempreply->event_prsnl_list[reply_count]->req_dt_tm =")
   SET super_detail = concat(super_detail," cnvtdatetime(ceep.request_dt_tm)")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->event_cd = ce.event_cd")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->ce_event_prsnl_id = ceep.ce_event_prsnl_id")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->discharge_dt_tm =")
   SET super_detail = concat(super_detail," cnvtdatetime(e.disch_dt_tm)")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->encounter_type_cd = e.encntr_type_cd")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->facility_cd = e.loc_facility_cd")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->organization_id = e.organization_id")
   SET super_detail = concat(super_detail,
    " tempreply->event_prsnl_list[reply_count]->org_name = o.org_name")
   IF (swithmaxrec=" ")
    SET super_detail = concat(super_detail," foot ceep.ce_event_prsnl_id")
   ENDIF
   SET super_detail = concat(super_detail," footorder = 0")
   SET super_detail = concat(super_detail," foot report")
   SET super_detail = concat(super_detail,
    " stat = alterlist(tempreply->event_prsnl_list, reply_count)")
   IF (swithmaxrec=" ")
    IF ((request->max_rec > 0))
     SET super_detail = concat(super_detail," with nocounter, maxrec = value(maxrc)")
    ELSE
     SET super_detail = concat(super_detail," with nocounter")
    ENDIF
   ELSE
    SET super_detail = concat(super_detail," with nocounter,",swithmaxrec)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildreply(int)
   DECLARE reply_cnt = i4 WITH noconstant
   SET reply_cnt = cnvtint(size(tempreply->event_prsnl_list,5))
   IF (reply_cnt > 0)
    SET stat = alterlist(reply->event_prsnl_list,reply_cnt)
    FOR (index = 1 TO reply_cnt)
      SET reply->event_prsnl_list[index].encntr_id = tempreply->event_prsnl_list[index].encntr_id
      SET reply->event_prsnl_list[index].person_id = tempreply->event_prsnl_list[index].person_id
      SET reply->event_prsnl_list[index].event_prsnl_id = tempreply->event_prsnl_list[index].
      event_prsnl_id
      SET reply->event_prsnl_list[index].action_type_cd = tempreply->event_prsnl_list[index].
      action_type_cd
      SET reply->event_prsnl_list[index].action_status_cd = tempreply->event_prsnl_list[index].
      action_status_cd
      SET reply->event_prsnl_list[index].action_prsnl_id = tempreply->event_prsnl_list[index].
      action_prsnl_id
      SET reply->event_prsnl_list[index].req_dt_tm = tempreply->event_prsnl_list[index].req_dt_tm
      SET reply->event_prsnl_list[index].med_rec_num = tempreply->event_prsnl_list[index].med_rec_num
      SET reply->event_prsnl_list[index].financial_num = tempreply->event_prsnl_list[index].
      financial_num
      SET reply->event_prsnl_list[index].discharge_dt_tm = tempreply->event_prsnl_list[index].
      discharge_dt_tm
      SET reply->event_prsnl_list[index].encounter_type_cd = tempreply->event_prsnl_list[index].
      encounter_type_cd
      SET reply->event_prsnl_list[index].organization_id = tempreply->event_prsnl_list[index].
      organization_id
      SET reply->event_prsnl_list[index].org_name = tempreply->event_prsnl_list[index].org_name
      SET reply->event_prsnl_list[index].facility_cd = tempreply->event_prsnl_list[index].facility_cd
      SET reply->event_prsnl_list[index].event_cd = tempreply->event_prsnl_list[index].event_cd
      SET reply->event_prsnl_list[index].event_cd_disp = tempreply->event_prsnl_list[index].
      event_cd_disp
      SET reply->event_prsnl_list[index].ce_event_prsnl_id = tempreply->event_prsnl_list[index].
      ce_event_prsnl_id
    ENDFOR
   ENDIF
   SET reply->status_data.status = tempreply->status_data.status
   SET reply->status_data.subeventstatus.operationname = tempreply->status_data.subeventstatus.
   operationname
   SET reply->status_data.subeventstatus.targetobjectname = tempreply->status_data.subeventstatus.
   targetobjectname
   SET reply->status_data.subeventstatus.targetobjectvalue = tempreply->status_data.subeventstatus.
   targetobjectvalue
   SET reply->status_data.subeventstatus.operationstatus = tempreply->status_data.subeventstatus.
   operationstatus
 END ;Subroutine
#exit_script
 IF ((tempreply->status_data.status="S"))
  SET tempreply->status_data.subeventstatus.operationname = "Get Items to Expire"
  SET tempreply->status_data.subeventstatus.targetobjectname = "CE_E_PRSNL,C_EVNT,ENCTER"
  SET tempreply->status_data.subeventstatus.targetobjectvalue =
  "dcp_get_ce_event_prsnls_to_expire.prg"
  SET tempreply->status_data.subeventstatus.operationstatus = "S"
 ELSEIF ((tempreply->status_data.status="Z"))
  SET tempreply->status_data.subeventstatus.operationname = "Get Items to Expire"
  SET tempreply->status_data.subeventstatus.targetobjectname = "CE_E_PRSNL,C_EVNT,ENCTER"
  SET tempreply->status_data.subeventstatus.targetobjectvalue =
  "dcp_get_ce_event_prsnls_to_expire.prg"
  SET tempreply->status_data.subeventstatus.operationstatus = "Z"
 ELSE
  SET tempreply->status_data.subeventstatus.operationname = "Get Items to Expire"
  SET tempreply->status_data.subeventstatus.targetobjectname = "CE_E_PRSNL,C_EVNT,ENCTER"
  SET tempreply->status_data.subeventstatus.targetobjectvalue =
  "dcp_get_ce_event_prsnls_to_expire.prg"
  SET tempreply->status_data.subeventstatus.operationstatus = "F"
 ENDIF
 CALL buildreply(1)
END GO
