CREATE PROGRAM dcp_plan_order_move_report:dba
 SET modify = predeclare
 CALL echo("<----------------------------------------------->")
 CALL echo("<---   BEGIN: dcp_plan_order_move_report     --->")
 CALL echo("<----------------------------------------------->")
 DECLARE dqtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(dqtimerbegindttm,";;Q"),"      ==="))
 CALL echo("====================================================")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE RECORD temp
 RECORD temp(
   1 persons[*]
     2 person_id = f8
     2 demog_pos = i4
     2 plans[*]
       3 pw_group_nbr = f8
       3 plan_name = vc
       3 phases[*]
         4 pathway_id = f8
         4 pathway_group_id = f8
         4 demog_pos = i4
         4 plan_name = vc
         4 phase_desc = vc
         4 ordered_dt_tm = vc
         4 prot_dot_orders[*]
           5 order_id = f8
           5 hna_order_mnemonic = vc
           5 clinical_disp_line = vc
           5 demog_pos = i4
         4 orders[*]
           5 order_id = f8
           5 protocol_order_id = f8
           5 hna_order_mnemonic = vc
           5 clinical_disp_line = vc
           5 demog_pos = i4
         4 treat_periods[*]
           5 pathway_id = f8
           5 pw_desc = vc
           5 demog_pos = i4
 )
 FREE RECORD demog_info
 RECORD demog_info(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 dob = vc
     2 mrn = vc
     2 fin = vc
 )
 IF ( NOT (validate(errors,0)))
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nstatus_unknown = i2 WITH private, constant(0)
 DECLARE nsuccess = i2 WITH private, constant(1)
 DECLARE nfailed_ccl_error = i2 WITH private, constant(2)
 DECLARE nscriptstatus = i2 WITH private, noconstant(nstatus_unknown)
 DECLARE nstat = i2 WITH private, noconstant(0)
 DECLARE slastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE smoddate = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"FUTURE"))
 DECLARE initiated_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"INITIATED"))
 DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"COMPLETED"))
 DECLARE discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"DISCONTINUED"))
 DECLARE comp_status_activated_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16789,
   "ACTIVATED"))
 DECLARE encntr_alias_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE encntr_alias_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE person_alias_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE plan_cnt = i4 WITH protect, noconstant(0)
 DECLARE phase_cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_dot_cnt = i4 WITH protect, noconstant(0)
 DECLARE treat_prd_cnt = i4 WITH protect, noconstant(0)
 DECLARE orders_cnt = i4 WITH protect, noconstant(0)
 DECLARE demog_cnt = i4 WITH protect, noconstant(0)
 DECLARE person_pos = i4 WITH protect, noconstant(0)
 DECLARE plan_pos = i4 WITH protect, noconstant(0)
 DECLARE phase_pos = i4 WITH protect, noconstant(0)
 DECLARE prot_dot_pos = i4 WITH protect, noconstant(0)
 DECLARE treat_prd_pos = i4 WITH protect, noconstant(0)
 DECLARE orders_pos = i4 WITH protect, noconstant(0)
 DECLARE dpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE ilookbackdays = i4 WITH protect, noconstant(0)
 DECLARE parameter_value = vc
 DECLARE ndebugmode = i1 WITH protect, constant(0)
 DECLARE ntemplateorderflag_orderbased = i1 WITH protect, constant(2)
 DECLARE ntemplateorderflag_taskbased = i1 WITH protect, constant(3)
 DECLARE ntemplateorderflag_rxbased = i1 WITH protect, constant(4)
 DECLARE getprotocoldotordersseparation(ilookbackdays=i4) = null
 DECLARE getphaseordersseparation(ilookbackdays=i4) = null
 DECLARE getphasedotseparation(ilookbackdays=i4) = null
 DECLARE addpersonidencntrid(dpersonid=f8,dencntrid=f8) = i4
 DECLARE getpersondemoginfo("") = null
 DECLARE generateencountermovereport("") = null
 DECLARE getformatteddatetime(date_time=dq8,time_zone=i4) = vc
 SET parameter_value = parameter(1,0)
 IF (((parameter_value=" ") OR (""=parameter_value)) )
  SET ilookbackdays = 30
 ELSE
  SET ilookbackdays = cnvtint(parameter_value)
  IF (ilookbackdays <= 0)
   SET ilookbackdays = 30
  ELSEIF (ilookbackdays > 500)
   SET ilookbackdays = 500
  ENDIF
 ENDIF
 IF (ndebugmode)
  CALL echo(build("The number of days to get data for are: ",ilookbackdays))
 ENDIF
 CALL getprotocoldotordersseparation(ilookbackdays)
 IF (ndebugmode)
  CALL echo("Record structure after populating GetProtocolDoTOrdersSeparation()")
  CALL echorecord(temp)
 ENDIF
 CALL getphaseordersseparation(ilookbackdays)
 IF (ndebugmode)
  CALL echo("Record structure after populating GetPhaseOrdersSeparation()")
  CALL echorecord(temp)
 ENDIF
 CALL getphasedotseparation(ilookbackdays)
 IF (ndebugmode)
  CALL echo("Record structure after populating GetPhaseDoTSeparation()")
  CALL echorecord(temp)
 ENDIF
 SET nstat = alterlist(demog_info->qual,demog_cnt)
 CALL getpersondemoginfo("")
 IF (ndebugmode)
  CALL echo("Person demographic information.")
  CALL echorecord(demog_info)
 ENDIF
 CALL generateencountermovereport("")
 SUBROUTINE getprotocoldotordersseparation(ilookbackdays)
   SELECT INTO "nl:"
    FROM pathway pw,
     act_pw_comp apc,
     orders o1,
     orders o2
    PLAN (pw
     WHERE pw.order_dt_tm >= cnvtdatetime((curdate - ilookbackdays),0)
      AND pw.type_mean IN ("PHASE", "CAREPLAN")
      AND pw.pathway_group_id > 0.0
      AND pw.pw_group_nbr > 0.0
      AND pw.pw_status_cd IN (future_cd, initiated_cd, completed_cd, discontinued_cd))
     JOIN (apc
     WHERE apc.pathway_id=pw.pathway_id
      AND apc.parent_entity_name="ORDERS"
      AND apc.comp_status_cd=comp_status_activated_cd)
     JOIN (o1
     WHERE o1.order_id=apc.parent_entity_id
      AND band(o1.warning_level_bit,8)=8)
     JOIN (o2
     WHERE o2.protocol_order_id=o1.order_id
      AND  NOT (o2.template_order_flag IN (ntemplateorderflag_orderbased,
     ntemplateorderflag_taskbased, ntemplateorderflag_rxbased)))
    ORDER BY pw.person_id, pw.pw_group_nbr, pw.pathway_id,
     o1.order_id, o2.order_id
    HEAD pw.person_id
     person_pos = locateval(idx,1,size(temp->persons,5),pw.person_id,temp->persons[idx].person_id)
     IF (0=person_pos)
      person_cnt = (person_cnt+ 1), stat = alterlist(temp->persons,person_cnt), temp->persons[
      person_cnt].person_id = pw.person_id,
      temp->persons[person_cnt].demog_pos = addpersonidencntrid(pw.person_id,pw.encntr_id),
      person_pos = person_cnt
     ENDIF
    HEAD pw.pw_group_nbr
     IF (pw.pw_group_nbr > 0.0)
      plan_pos = locateval(idx,1,size(temp->persons[person_pos].plans,5),pw.pw_group_nbr,temp->
       persons[person_pos].plans[idx].pw_group_nbr)
      IF (0=plan_pos)
       plan_cnt = (plan_cnt+ 1), nstat = alterlist(temp->persons[person_pos].plans,plan_cnt), temp->
       persons[person_pos].plans[plan_cnt].pw_group_nbr = pw.pw_group_nbr,
       temp->persons[person_pos].plans[plan_cnt].plan_name = pw.pw_group_desc, plan_pos = plan_cnt
      ENDIF
     ENDIF
    HEAD pw.pathway_id
     IF (pw.pathway_id > 0.0)
      phase_pos = locateval(idx,1,size(temp->persons[person_pos].plans[plan_pos].phases,5),pw
       .pathway_id,temp->persons[person_pos].plans[plan_pos].phases[idx].pathway_id)
      IF (0=phase_pos)
       phase_cnt = (phase_cnt+ 1), nstat = alterlist(temp->persons[person_pos].plans[plan_pos].phases,
        phase_cnt), temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].pathway_id = pw
       .pathway_id,
       temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].pathway_group_id = pw
       .pathway_group_id, temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].demog_pos =
       addpersonidencntrid(pw.person_id,pw.encntr_id)
       IF ("CAREPLAN"=pw.type_mean)
        temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].plan_name = trim(pw.pw_group_desc
         )
       ELSE
        temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].plan_name = trim(pw.pw_group_desc
         ), temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].phase_desc = trim(pw
         .description)
       ENDIF
       temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].ordered_dt_tm =
       getformatteddatetime(pw.order_dt_tm,pw.order_tz), phase_pos = phase_cnt
      ENDIF
     ENDIF
    DETAIL
     IF ((demog_info->qual[temp->persons[person_pos].plans[plan_pos].phases[phase_pos].demog_pos].
     person_id != o1.person_id))
      prot_dot_pos = locateval(idx,1,size(temp->persons[person_pos].plans[plan_pos].phases[phase_pos]
        .prot_dot_orders,5),o1.order_id,temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
       prot_dot_orders[idx].order_id)
      IF (0=prot_dot_pos)
       prot_dot_cnt = (prot_dot_cnt+ 1)
       IF (prot_dot_cnt > size(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
        prot_dot_orders,5))
        stat = alterlist(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders,
         (prot_dot_cnt+ 10))
       ENDIF
       temp->persons[person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders[prot_dot_cnt].
       order_id = o1.order_id, temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
       prot_dot_orders[prot_dot_cnt].hna_order_mnemonic = o1.hna_order_mnemonic, temp->persons[
       person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders[prot_dot_cnt].clinical_disp_line
        = o1.clinical_display_line,
       temp->persons[person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders[prot_dot_cnt].
       demog_pos = addpersonidencntrid(o1.person_id,o1.encntr_id)
      ENDIF
     ENDIF
     IF ((demog_info->qual[temp->persons[person_pos].plans[plan_pos].phases[phase_pos].demog_pos].
     person_id != o2.person_id))
      prot_dot_pos = locateval(idx,1,size(temp->persons[person_pos].plans[plan_pos].phases[phase_pos]
        .prot_dot_orders,5),o2.order_id,temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
       prot_dot_orders[idx].order_id)
      IF (0=prot_dot_pos)
       prot_dot_cnt = (prot_dot_cnt+ 1)
       IF (prot_dot_cnt > size(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
        prot_dot_orders,5))
        stat = alterlist(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders,
         (prot_dot_cnt+ 10))
       ENDIF
       temp->persons[person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders[prot_dot_cnt].
       order_id = o2.order_id, temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
       prot_dot_orders[prot_dot_cnt].hna_order_mnemonic = o2.hna_order_mnemonic, temp->persons[
       person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders[prot_dot_cnt].clinical_disp_line
        = o2.clinical_display_line,
       temp->persons[person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders[prot_dot_cnt].
       demog_pos = addpersonidencntrid(o2.person_id,o2.encntr_id)
      ENDIF
     ENDIF
    FOOT  pw.pathway_id
     nstat = alterlist(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].prot_dot_orders,
      prot_dot_cnt), prot_dot_cnt = 0
    FOOT  pw.pw_group_nbr
     phase_cnt = 0
    FOOT  pw.person_id
     plan_cnt = 0
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getphaseordersseparation(ilookbackdays)
   SELECT INTO "nl:"
    FROM pathway pw,
     act_pw_comp apc,
     orders o
    PLAN (pw
     WHERE pw.order_dt_tm >= cnvtdatetime((curdate - ilookbackdays),0)
      AND pw.type_mean IN ("PHASE", "CAREPLAN")
      AND pw.pw_status_cd IN (future_cd, initiated_cd, completed_cd, discontinued_cd)
      AND pw.pw_group_nbr > 0.0)
     JOIN (apc
     WHERE apc.pathway_id=pw.pathway_id
      AND apc.parent_entity_name="ORDERS"
      AND apc.comp_status_cd=comp_status_activated_cd)
     JOIN (o
     WHERE o.order_id=apc.parent_entity_id
      AND o.person_id != pw.person_id)
    ORDER BY pw.person_id, pw.pw_group_nbr, pw.pathway_id,
     o.order_id
    HEAD pw.person_id
     person_pos = locateval(idx,1,size(temp->persons,5),pw.person_id,temp->persons[idx].person_id)
     IF (0=person_pos)
      person_cnt = (size(temp->persons,5)+ 1), nstat = alterlist(temp->persons,person_cnt), temp->
      persons[person_cnt].person_id = pw.person_id,
      temp->persons[person_cnt].demog_pos = addpersonidencntrid(pw.person_id,pw.encntr_id),
      person_pos = person_cnt
     ENDIF
    HEAD pw.pw_group_nbr
     IF (pw.pw_group_nbr > 0.0)
      plan_pos = locateval(idx,1,size(temp->persons[person_pos].plans,5),pw.pw_group_nbr,temp->
       persons[person_pos].plans[idx].pw_group_nbr)
      IF (0=plan_pos)
       plan_cnt = (size(temp->persons[person_pos].plans,5)+ 1), nstat = alterlist(temp->persons[
        person_pos].plans,plan_cnt), temp->persons[person_pos].plans[plan_cnt].pw_group_nbr = pw
       .pw_group_nbr,
       temp->persons[person_pos].plans[plan_cnt].plan_name = pw.pw_group_desc, plan_pos = plan_cnt
      ENDIF
     ENDIF
    HEAD pw.pathway_id
     IF (pw.pathway_id > 0.0)
      phase_pos = locateval(idx,1,size(temp->persons[person_pos].plans[plan_pos].phases,5),pw
       .pathway_id,temp->persons[person_pos].plans[plan_pos].phases[idx].pathway_id)
      IF (0=phase_pos)
       phase_cnt = (size(temp->persons[person_pos].plans[plan_pos].phases,5)+ 1), nstat = alterlist(
        temp->persons[person_pos].plans[plan_pos].phases,phase_cnt), temp->persons[person_pos].plans[
       plan_pos].phases[phase_cnt].pathway_id = pw.pathway_id,
       temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].pathway_group_id = pw
       .pathway_group_id, temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].demog_pos =
       addpersonidencntrid(pw.person_id,pw.encntr_id)
       IF ("CAREPLAN"=pw.type_mean)
        temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].plan_name = trim(pw.pw_group_desc
         )
       ELSE
        temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].plan_name = trim(pw.pw_group_desc
         ), temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].phase_desc = trim(pw
         .description)
       ENDIF
       temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].ordered_dt_tm =
       getformatteddatetime(pw.order_dt_tm,pw.order_tz), phase_pos = phase_cnt
      ENDIF
     ENDIF
    DETAIL
     IF (o.order_id > 0.0)
      orders_pos = locateval(idx,1,size(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
        orders,5),o.order_id,temp->persons[person_pos].plans[plan_pos].phases[phase_pos].orders[idx].
       order_id)
      IF (0=orders_pos)
       orders_cnt = (orders_cnt+ 1)
       IF (orders_cnt > size(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].orders,5))
        nstat = alterlist(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].orders,(
         orders_cnt+ 10))
       ENDIF
       temp->persons[person_pos].plans[plan_pos].phases[phase_pos].orders[orders_cnt].order_id = o
       .order_id, temp->persons[person_pos].plans[plan_pos].phases[phase_pos].orders[orders_cnt].
       protocol_order_id = o.protocol_order_id, temp->persons[person_pos].plans[plan_pos].phases[
       phase_pos].orders[orders_cnt].hna_order_mnemonic = o.hna_order_mnemonic,
       temp->persons[person_pos].plans[plan_pos].phases[phase_pos].orders[orders_cnt].
       clinical_disp_line = o.clinical_display_line, temp->persons[person_pos].plans[plan_pos].
       phases[phase_pos].orders[orders_cnt].demog_pos = addpersonidencntrid(o.person_id,o.encntr_id)
      ENDIF
     ENDIF
    FOOT  pw.pathway_id
     nstat = alterlist(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].orders,orders_cnt),
     orders_cnt = 0
    FOOT  pw.pw_group_nbr
     phase_cnt = 0
    FOOT  pw.person_id
     plan_cnt = 0
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getphasedotseparation(ilookbackdays)
   SELECT INTO "nl:"
    FROM pathway pw,
     pathway pw2
    PLAN (pw
     WHERE pw.order_dt_tm >= cnvtdatetime((curdate - ilookbackdays),0)
      AND pw.type_mean IN ("PHASE", "CAREPLAN")
      AND pw.pathway_group_id > 0.0
      AND pw.pw_group_nbr > 0.0
      AND pw.pw_status_cd IN (future_cd, initiated_cd, completed_cd, discontinued_cd))
     JOIN (pw2
     WHERE pw2.pathway_group_id=pw.pathway_group_id
      AND pw2.type_mean="DOT"
      AND pw2.person_id != pw.person_id)
    ORDER BY pw.person_id, pw.pw_group_nbr, pw.pathway_id,
     pw2.pathway_id
    HEAD pw.person_id
     person_pos = locateval(idx,1,size(temp->persons,5),pw.person_id,temp->persons[idx].person_id)
     IF (0=person_pos)
      person_cnt = (size(temp->persons,5)+ 1), stat = alterlist(temp->persons,person_cnt), temp->
      persons[person_cnt].person_id = pw.person_id,
      temp->persons[person_cnt].demog_pos = addpersonidencntrid(pw.person_id,pw.encntr_id),
      person_pos = person_cnt
     ENDIF
    HEAD pw.pw_group_nbr
     IF (pw.pw_group_nbr > 0.0)
      plan_pos = locateval(idx,1,size(temp->persons[person_pos].plans,5),pw.pw_group_nbr,temp->
       persons[person_pos].plans[idx].pw_group_nbr)
      IF (0=plan_pos)
       plan_cnt = (size(temp->persons[person_pos].plans,5)+ 1), stat = alterlist(temp->persons[
        person_pos].plans,plan_cnt), temp->persons[person_pos].plans[plan_cnt].pw_group_nbr = pw
       .pw_group_nbr
       IF ("CAREPLAN"=pw.type_mean)
        temp->persons[person_pos].plans[plan_cnt].plan_name = pw.description
       ELSE
        temp->persons[person_pos].plans[plan_cnt].plan_name = pw.pw_group_desc
       ENDIF
       plan_pos = plan_cnt
      ENDIF
     ENDIF
    HEAD pw.pathway_id
     IF (pw.pathway_id > 0.0)
      phase_pos = locateval(idx,1,size(temp->persons[person_pos].plans[plan_pos].phases,5),pw
       .pathway_id,temp->persons[person_pos].plans[plan_pos].phases[idx].pathway_id)
      IF (0=phase_pos)
       phase_cnt = (size(temp->persons[person_pos].plans[plan_pos].phases,5)+ 1), nstat = alterlist(
        temp->persons[person_pos].plans[plan_pos].phases,phase_cnt), temp->persons[person_pos].plans[
       plan_pos].phases[phase_cnt].pathway_id = pw.pathway_id,
       temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].pathway_group_id = pw
       .pathway_group_id, temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].demog_pos =
       addpersonidencntrid(pw.person_id,pw.encntr_id)
       IF ("CAREPLAN"=pw.type_mean)
        temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].plan_name = trim(pw.pw_group_desc
         )
       ELSE
        temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].plan_name = trim(pw.pw_group_desc
         ), temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].phase_desc = trim(pw
         .description)
       ENDIF
       temp->persons[person_pos].plans[plan_pos].phases[phase_cnt].ordered_dt_tm =
       getformatteddatetime(pw.order_dt_tm,pw.order_tz), phase_pos = phase_cnt
      ENDIF
     ENDIF
    DETAIL
     IF ((demog_info->qual[temp->persons[person_pos].plans[plan_pos].phases[phase_pos].demog_pos].
     person_id != pw2.person_id))
      treat_prd_cnt = (treat_prd_cnt+ 1)
      IF (treat_prd_cnt > size(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
       treat_periods,5))
       nstat = alterlist(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].treat_periods,(
        treat_prd_cnt+ 10))
      ENDIF
      temp->persons[person_pos].plans[plan_pos].phases[phase_pos].treat_periods[treat_prd_cnt].
      pathway_id = pw2.pathway_id, temp->persons[person_pos].plans[plan_pos].phases[phase_pos].
      treat_periods[treat_prd_cnt].pw_desc = pw2.description, temp->persons[person_pos].plans[
      plan_pos].phases[phase_pos].treat_periods[treat_prd_cnt].demog_pos = addpersonidencntrid(pw2
       .person_id,pw2.encntr_id)
     ENDIF
    FOOT  pw.pathway_id
     nstat = alterlist(temp->persons[person_pos].plans[plan_pos].phases[phase_pos].treat_periods,
      treat_prd_cnt), treat_prd_cnt = 0
    FOOT  pw.pw_group_nbr
     phase_cnt = 0
    FOOT  pw.person_id
     plan_cnt = 0
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getformatteddatetime(date_time,time_zone)
   DECLARE sdatetime = vc
   IF (curutc)
    SET sdatetime = concat(trim(datetimezoneformat(date_time,time_zone,"@SHORTDATE"))," ",trim(
      datetimezoneformat(date_time,time_zone,"@TIMENOSECONDS")),trim(datetimezoneformat(date_time,
       time_zone," ZZZ")))
   ELSE
    SET sdatetime = concat(format(cnvtdatetime(date_time),"@SHORTDATE")," ",format(cnvtdatetime(
       date_time),"@TIMENOSECONDS"))
   ENDIF
   RETURN(sdatetime)
 END ;Subroutine
 SUBROUTINE addpersonidencntrid(dpersonid,dencntrid)
   DECLARE demog_pos = i4 WITH protect, noconstant(0)
   SET demog_pos = locateval(idx,1,size(demog_info->qual,5),dpersonid,demog_info->qual[idx].person_id,
    dencntrid,demog_info->qual[idx].encntr_id)
   IF (0=demog_pos)
    SET demog_cnt = (demog_cnt+ 1)
    IF (demog_cnt > size(demog_info->qual,5))
     SET nstat = alterlist(demog_info->qual,(demog_cnt+ 10))
    ENDIF
    SET demog_info->qual[demog_cnt].person_id = dpersonid
    SET demog_info->qual[demog_cnt].encntr_id = dencntrid
    SET demog_pos = demog_cnt
   ENDIF
   RETURN(demog_pos)
 END ;Subroutine
 SUBROUTINE getpersondemoginfo("")
   IF (size(demog_info->qual,5) > 0)
    DECLARE idx = i4 WITH protect, noconstant(0)
    DECLARE num = i4 WITH protect, noconstant(0)
    DECLARE num2 = i4 WITH protect, noconstant(0)
    DECLARE pos = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM encntr_alias ea
     WHERE expand(idx,1,size(demog_info->qual,5),ea.encntr_id,demog_info->qual[idx].encntr_id)
      AND ea.active_ind=1
      AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     ORDER BY cnvtdatetime(ea.updt_dt_tm)
     DETAIL
      IF (ea.encntr_id > 0.0)
       IF (ea.encntr_alias_type_cd=encntr_alias_mrn_cd)
        pos = locateval(num,1,size(demog_info->qual,5),ea.encntr_id,demog_info->qual[num].encntr_id)
        WHILE (pos > 0)
         demog_info->qual[pos].mrn = cnvtalias(ea.alias,ea.alias_pool_cd),pos = locateval(num,(pos+ 1
          ),size(demog_info->qual,5),ea.encntr_id,demog_info->qual[num].encntr_id)
        ENDWHILE
       ELSEIF (ea.encntr_alias_type_cd=encntr_alias_fin_cd)
        pos = locateval(num,1,size(demog_info->qual,5),ea.encntr_id,demog_info->qual[num].encntr_id)
        WHILE (pos > 0)
         demog_info->qual[pos].fin = cnvtalias(ea.alias,ea.alias_pool_cd),pos = locateval(num,(pos+ 1
          ),size(demog_info->qual,5),ea.encntr_id,demog_info->qual[num].encntr_id)
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM person p,
      person_alias pa
     PLAN (p
      WHERE expand(idx,1,size(demog_info->qual,5),p.person_id,demog_info->qual[idx].person_id)
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      JOIN (pa
      WHERE p.person_id=outerjoin(pa.person_id)
       AND pa.active_ind=outerjoin(1)
       AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
     ORDER BY cnvtdatetime(pa.updt_dt_tm)
     DETAIL
      pos = locateval(num,1,size(demog_info->qual,5),p.person_id,demog_info->qual[num].person_id)
      WHILE (pos > 0)
        demog_info->qual[pos].dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
         "@SHORTDATE")
        IF (size(demog_info->qual[pos].mrn,1)=0)
         IF (person_alias_mrn_cd=pa.person_alias_type_cd)
          demog_info->qual[pos].mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
         ENDIF
        ENDIF
        pos = locateval(num2,(pos+ 1),size(demog_info->qual,5),p.person_id,demog_info->qual[num2].
         person_id)
      ENDWHILE
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE generateencountermovereport("")
   IF (validate(i18nuar_def,999)=999)
    CALL echo("Declaring i18nuar_def")
    DECLARE i18nuar_def = i2 WITH persist
    SET i18nuar_def = 1
    DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
    DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
    DECLARE uar_i18nbuildmessage() = vc WITH persist
    DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref))
     = c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
    "uar_i18nGetHijriDate",
    persist
    DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
     stitle=vc(ref),
     sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
    "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
    persist
    DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
    "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
    persist
   ENDIF
   DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4
   DECLARE hi18nhandle = i4 WITH protect, noconstant(0)
   DECLARE iretval = i4 WITH protect, noconstant(0)
   SET iretval = uar_i18nlocalizationinit(hi18nhandle,curprog,"",curcclrev)
   DECLARE pid_str = vc
   DECLARE person_id_str = vc
   DECLARE dob_str = vc
   DECLARE mrn_str = vc
   DECLARE fin_str = vc
   DECLARE plan_name_str = vc
   DECLARE phase_name_str = vc
   DECLARE ordered_dt_tm_str = vc
   DECLARE pathway_id_str = vc
   DECLARE plan_phase_info = vc
   DECLARE prev_demog_pos = i4
   DECLARE demog_pos = i4
   DECLARE order_person_id_str = vc
   DECLARE order_dob = vc
   DECLARE order_mrn = vc
   DECLARE order_fin = vc
   DECLARE disp_orders_listed_info = vc
   DECLARE hna_order_mnem_disp = vc
   DECLARE clin_disp_line = vc
   DECLARE order_id = f8
   DECLARE order_detail_disp = vc
   DECLARE dot_person_id_str = vc
   DECLARE dot_dob = vc
   DECLARE dot_mrn = vc
   DECLARE dot_fin = vc
   DECLARE dot_pathway_id = f8
   DECLARE disp_pathway_desc = vc
   DECLARE treat_prd_disp = vc
   DECLARE disp_dot_listed_info = vc
   DECLARE cur_date = dq8
   DECLARE datestr = vc
   DECLARE monthstr = vc
   DECLARE daystr = vc
   DECLARE yearstr = vc
   DECLARE datedisp = vc
   DECLARE filename = vc
   DECLARE disp_no_plan_order_qualify = vc
   DECLARE desc1 = vc
   DECLARE desc2 = vc
   DECLARE desc3 = vc
   DECLARE desc4 = vc
   DECLARE disp_cur_page = vc
   DECLARE rows_per_page = i2 WITH protect, constant(53)
   DECLARE max_order_det_chars_per_line = i2 WITH protect, constant(210)
   SET cur_date = cnvtdatetime(curdate,curtime)
   SET datestr = format(curdate,"@SHORTDATE")
   SET monthstr = substring(1,2,datestr)
   SET daystr = substring(4,2,datestr)
   SET yearstr = substring(7,2,datestr)
   SET datedisp = concat(monthstr,daystr,yearstr)
   SET filename = concat("cer_temp:plan_order_move_report_",datedisp,".ps")
   SELECT INTO value(filename)
    d.seq
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD REPORT
     "{ps/792 0 translate 90 rotate/}", "{f/8}", "{cpi/10}",
     "{ipc}", row + 2, header_disp = concat("plan_order_move_report_",datedisp,".ps"),
     "{b}",
     CALL print(calcpos(190,20)), header_disp,
     row + 5, "{endb}", "{f/8}",
     "{cpi/14}", "{ipc}", x = 30,
     y = 35, desc1 = uar_i18ngetmessage(hi18nhandle,"DESC1",
"This report is intended to identify the following situations in which PowerPlans and Orders data are split between two dif\
ferent patients as a result of an encounter move:\
"),
     CALL print(calcpos(x,y)), desc1, row + 1,
     x = (x+ 50), y = (y+ 12), desc2 = uar_i18ngetmessage(hi18nhandle,"DESC2",
      "(1) A protocol order has a different person_id than one or more of the day of treatment orders."
      ),
     CALL print(calcpos(x,y)), desc2, row + 1,
     y = (y+ 12), desc3 = uar_i18ngetmessage(hi18nhandle,"DESC3",
      "(2) Orders from a phase have a different person_id than the person_id on the phase."),
     CALL print(calcpos(x,y)),
     desc3, row + 1, y = (y+ 12),
     desc4 = uar_i18ngetmessage(hi18nhandle,"DESC4",
      "(3) Treatment periods from a phase are split between two different patients."),
     CALL print(calcpos(x,y)), desc4,
     row + 2
    HEAD PAGE
     IF (curpage > 1)
      "{ps/792 0 translate 90 rotate/}", y = 15, row + 7
     ENDIF
     "{f/8}", "{cpi/18}", "{ipc}"
     IF (size(temp->persons,5)=0)
      y = (y+ 12),
      CALL print(calcpos(0,y)),
"__________________________________________________________________________________________________________________________\
__________________________________________________________________________________________________________________________\
______________\
", row + 1, disp_no_plan_order_qualify = uar_i18nbuildmessage(hi18nhandle,"NOTHING_QUALIFY",
       "*** There is no data qualified for the input date range of %1 day(s) in the past. ***","i",
       ilookbackdays), y = (y+ 12),
      row + 1, "{b}",
      CALL print(calcpos(190,y)),
      disp_no_plan_order_qualify, row + 1, "{endb}"
     ENDIF
    DETAIL
     IF (row >= rows_per_page)
      BREAK
     ENDIF
     x1 = 30, x2 = 190, x3 = 350,
     x4 = 500, y = (y+ 12)
     FOR (i = 1 TO size(temp->persons,5))
       pid_str = fillstring(100," "), person_id_str = fillstring(100," "), dob_str = fillstring(100,
        " "),
       mrn_str = fillstring(300," "), fin_str = fillstring(300," "), pid_str = trim(format(temp->
         persons[i].person_id,";T(1);F"),2),
       person_id_str = uar_i18nbuildmessage(hi18nhandle,"PERSON_ID","person_id: %1","s",nullterm(
         trim(pid_str))), dob_str = uar_i18nbuildmessage(hi18nhandle,"DOB","DOB: %1","s",nullterm(
         demog_info->qual[temp->persons[i].demog_pos].dob)), mrn_str = uar_i18nbuildmessage(
        hi18nhandle,"MRN","MRN: %1","s",nullterm(demog_info->qual[temp->persons[i].demog_pos].mrn)),
       fin_str = uar_i18nbuildmessage(hi18nhandle,"FIN","FIN: %1","s",nullterm(demog_info->qual[temp
         ->persons[i].demog_pos].fin)), person_id_str = trim(person_id_str), dob_str = trim(dob_str),
       mrn_str = trim(mrn_str), fin_str = trim(fin_str),
       CALL print(calcpos(0,y)),
"__________________________________________________________________________________________________________________________\
__________________________________________________________________________________________________________________________\
______________\
", row + 1, y = (y+ 12),
       CALL print(calcpos(x1,y)),
       "{b}", person_id_str,
       CALL print(calcpos(x2,y)),
       dob_str,
       CALL print(calcpos(x3,y)), mrn_str,
       CALL print(calcpos(x4,y)), fin_str, "{endb}",
       row + 1, y = (y+ 12)
       IF (row >= rows_per_page)
        BREAK
       ENDIF
       FOR (j = 1 TO size(temp->persons[i].plans,5))
        FOR (k = 1 TO size(temp->persons[i].plans[j].phases,5))
          plan_name_str = fillstring(500," "), phase_name_str = fillstring(500," "),
          ordered_dt_tm_str = fillstring(100," "),
          pathway_id_str = fillstring(100," "), plan_phase_info = fillstring(500," "), prev_demog_pos
           = 0,
          plan_name_str = temp->persons[i].plans[j].phases[k].plan_name, phase_name_str = temp->
          persons[i].plans[j].phases[k].phase_desc, ordered_dt_tm_str = uar_i18nbuildmessage(
           hi18nhandle,"ORDERED_ON","ordered on: %1","s",nullterm(temp->persons[i].plans[j].phases[k
            ].ordered_dt_tm)),
          pathway_id_str = build2(" (pathway_id = ",trim(format(temp->persons[i].plans[j].phases[k].
             pathway_id,";T(1);F"),2),")"), plan_phase_info = build2(trim(plan_name_str),", ",trim(
            phase_name_str)," ",nullterm(trim(ordered_dt_tm_str)),
           trim(pathway_id_str)), plan_phase_info = trim(plan_phase_info),
          row + 1, y = (y+ 12)
          IF (row >= rows_per_page)
           BREAK
          ENDIF
          CALL print(calcpos(30,y)), "{b}", plan_phase_info,
          "{endb}", row + 1, y = (y+ 12)
          IF (row >= rows_per_page)
           BREAK
          ENDIF
          IF (size(temp->persons[i].plans[j].phases[k].prot_dot_orders,5) > 0)
           FOR (n = 1 TO size(temp->persons[i].plans[j].phases[k].prot_dot_orders,5))
             IF ((prev_demog_pos != temp->persons[i].plans[j].phases[k].prot_dot_orders[n].demog_pos)
             )
              demog_pos = temp->persons[i].plans[j].phases[k].prot_dot_orders[n].demog_pos,
              prev_demog_pos = demog_pos, order_person_id_str = fillstring(100," "),
              order_dob = fillstring(100," "), order_mrn = fillstring(300," "), order_fin =
              fillstring(300," "),
              disp_orders_listed_info = fillstring(500," "), order_person_id_str = trim(format(
                demog_info->qual[demog_pos].person_id,";T(1);F"),2), order_dob = uar_i18nbuildmessage
              (hi18nhandle,"ORDER_DOB","DOB: %1","s",nullterm(demog_info->qual[demog_pos].dob)),
              order_mrn = uar_i18nbuildmessage(hi18nhandle,"ORDER_MRN","MRN: %1","s",nullterm(
                demog_info->qual[demog_pos].mrn)), order_fin = uar_i18nbuildmessage(hi18nhandle,
               "ORDER_FIN","FIN: %1","s",nullterm(demog_info->qual[demog_pos].fin)),
              disp_orders_listed_info = uar_i18nbuildmessage(hi18nhandle,"ORDERS_LISTED",
               "(1) The orders listed below from this phase %1 are on the following patient: person_id = %2, %3, %4, %5",
               "sssss",nullterm(trim(phase_name_str)),
               nullterm(trim(order_person_id_str)),nullterm(trim(order_dob)),nullterm(trim(order_mrn)
                ),nullterm(trim(order_fin))),
              disp_orders_listed_info = trim(disp_orders_listed_info), y = (y+ 12), row + 1
              IF (row >= rows_per_page)
               BREAK
              ENDIF
              CALL print(calcpos(30,y)), disp_orders_listed_info
             ENDIF
             hna_order_mnem_disp = fillstring(500," "), hna_order_mnem_disp = temp->persons[i].plans[
             j].phases[k].prot_dot_orders[n].hna_order_mnemonic, clin_disp_line = fillstring(500," "),
             clin_disp_line = temp->persons[i].plans[j].phases[k].prot_dot_orders[n].
             clinical_disp_line, order_id = temp->persons[i].plans[j].phases[k].prot_dot_orders[n].
             order_id, order_detail_disp = fillstring(500," "),
             order_detail_disp = build2(trim(hna_order_mnem_disp),", ",trim(clin_disp_line))
             IF ((size(order_detail_disp,1) > (max_order_det_chars_per_line - 3)))
              order_detail_disp = substring(1,(max_order_det_chars_per_line - 3),order_detail_disp),
              order_detail_disp = build2(trim(order_detail_disp),"...",", ","(order_id = ",trim(
                format(order_id,";T(1);F"),2),
               ")")
             ELSE
              order_detail_disp = build2(trim(hna_order_mnem_disp),", ",trim(clin_disp_line),", ",
               "(order_id = ",
               trim(format(order_id,";T(1);F"),2),")")
             ENDIF
             order_detail_disp = trim(order_detail_disp), y = (y+ 12), row + 1
             IF (row >= rows_per_page)
              BREAK
             ENDIF
             CALL print(calcpos(50,y)), order_detail_disp
           ENDFOR
          ENDIF
          prev_demog_pos = 0
          IF (size(temp->persons[i].plans[j].phases[k].orders,5) > 0)
           FOR (m = 1 TO size(temp->persons[i].plans[j].phases[k].orders,5))
             IF ((prev_demog_pos != temp->persons[i].plans[j].phases[k].orders[m].demog_pos))
              demog_pos = temp->persons[i].plans[j].phases[k].orders[m].demog_pos, prev_demog_pos =
              demog_pos, order_person_id_str = fillstring(100," "),
              order_dob = fillstring(100," "), order_mrn = fillstring(300," "), order_fin =
              fillstring(300," "),
              disp_orders_listed_info = fillstring(500," "), order_person_id_str = trim(format(
                demog_info->qual[demog_pos].person_id,";T(1);F"),2), order_dob = uar_i18nbuildmessage
              (hi18nhandle,"ORDER_DOB","DOB: %1","s",nullterm(demog_info->qual[demog_pos].dob)),
              order_mrn = uar_i18nbuildmessage(hi18nhandle,"ORDER_MRN","MRN: %1","s",nullterm(
                demog_info->qual[demog_pos].mrn)), order_fin = uar_i18nbuildmessage(hi18nhandle,
               "ORDER_FIN","FIN: %1","s",nullterm(demog_info->qual[demog_pos].fin)),
              disp_orders_listed_info = uar_i18nbuildmessage(hi18nhandle,"ORDERS_LISTED",
               "(2) The orders listed below from this phase %1 are on the following patient: person_id = %2, %3, %4, %5",
               "sssss",nullterm(trim(phase_name_str)),
               nullterm(trim(order_person_id_str)),nullterm(trim(order_dob)),nullterm(trim(order_mrn)
                ),nullterm(trim(order_fin))),
              disp_orders_listed_info = trim(disp_orders_listed_info), y = (y+ 12), row + 1
              IF (row >= rows_per_page)
               BREAK
              ENDIF
              CALL print(calcpos(30,y)), disp_orders_listed_info
             ENDIF
             hna_order_mnem_disp = fillstring(500," "), clin_disp_line = fillstring(500," "),
             order_detail_disp = fillstring(500," "),
             hna_order_mnem_disp = temp->persons[i].plans[j].phases[k].orders[m].hna_order_mnemonic,
             clin_disp_line = temp->persons[i].plans[j].phases[k].orders[m].clinical_disp_line,
             order_id = temp->persons[i].plans[j].phases[k].orders[m].order_id,
             order_detail_disp = build2(trim(hna_order_mnem_disp),", ",trim(clin_disp_line))
             IF ((size(order_detail_disp,1) > (max_order_det_chars_per_line - 3)))
              order_detail_disp = substring(1,(max_order_det_chars_per_line - 3),order_detail_disp),
              order_detail_disp = build2(trim(order_detail_disp),"...",", ","(order_id = ",trim(
                format(order_id,";T(1);F"),2),
               ")")
             ELSE
              order_detail_disp = build2(trim(hna_order_mnem_disp),", ",trim(clin_disp_line),", ",
               "(order_id = ",
               trim(format(order_id,";T(1);F"),2),")")
             ENDIF
             order_detail_disp = trim(order_detail_disp), y = (y+ 12), row + 1
             IF (row >= rows_per_page)
              BREAK
             ENDIF
             CALL print(calcpos(50,y)), order_detail_disp
           ENDFOR
          ENDIF
          prev_demog_pos = 0
          IF (size(temp->persons[i].plans[j].phases[k].treat_periods,5) > 0)
           FOR (p = 1 TO size(temp->persons[i].plans[j].phases[k].treat_periods,5))
             IF ((prev_demog_pos != temp->persons[i].plans[j].phases[k].treat_periods[p].demog_pos))
              demog_pos = temp->persons[i].plans[j].phases[k].treat_periods[p].demog_pos,
              prev_demog_pos = demog_pos, dot_person_id_str = fillstring(100," "),
              dot_dob = fillstring(100," "), dot_mrn = fillstring(300," "), dot_fin = fillstring(300,
               " "),
              disp_dot_listed_info = fillstring(500," "), dot_person_id_str = trim(format(demog_info
                ->qual[demog_pos].person_id,";T(1);F"),2), dot_dob = uar_i18nbuildmessage(hi18nhandle,
               "DOT_DOB","DOB: %1","s",nullterm(demog_info->qual[demog_pos].dob)),
              dot_mrn = uar_i18nbuildmessage(hi18nhandle,"DOT_MRN","MRN: %1","s",nullterm(demog_info
                ->qual[demog_pos].mrn)), dot_fin = uar_i18nbuildmessage(hi18nhandle,"DOT_FIN",
               "FIN: %1","s",nullterm(demog_info->qual[demog_pos].fin)), disp_dot_listed_info =
              uar_i18nbuildmessage(hi18nhandle,"TREAT_LIST",
               "(3) The treatment periods listed below from this phase %1 are on the following patient: person_id = %2, %3, %4, %5"
,
               "sssss",nullterm(trim(phase_name_str)),
               nullterm(trim(dot_person_id_str)),nullterm(trim(dot_dob)),nullterm(trim(dot_mrn)),
               nullterm(trim(dot_fin))),
              disp_dot_listed_info = trim(disp_dot_listed_info), y = (y+ 12), row + 1
              IF (row >= rows_per_page)
               BREAK
              ENDIF
              CALL print(calcpos(30,y)), disp_dot_listed_info
             ENDIF
             dot_pathway_id = temp->persons[i].plans[j].phases[k].treat_periods[p].pathway_id,
             disp_pathway_desc = fillstring(500," "), disp_pathway_desc = temp->persons[i].plans[j].
             phases[k].treat_periods[p].pw_desc,
             treat_prd_disp = fillstring(500," "), treat_prd_disp = build2(trim(disp_pathway_desc),
              " (pathway_id = ",trim(format(dot_pathway_id,";T(1);F"),2),")"), treat_prd_disp = trim(
              treat_prd_disp),
             y = (y+ 12), row + 1
             IF (row >= rows_per_page)
              BREAK
             ENDIF
             CALL print(calcpos(50,y)), treat_prd_disp
           ENDFOR
          ENDIF
          y = (y+ 12), row + 1
          IF (row >= rows_per_page)
           BREAK
          ENDIF
        ENDFOR
        ,
        IF (row >= rows_per_page)
         BREAK
        ENDIF
       ENDFOR
       CALL print(calcpos(0,y)),
"__________________________________________________________________________________________________________________________\
__________________________________________________________________________________________________________________________\
______________\
"
       IF (row >= rows_per_page)
        BREAK
       ENDIF
     ENDFOR
    FOOT PAGE
     row + 2, y = (y+ 24), disp_cur_page = uar_i18nbuildmessage(hi18nhandle,"PAGE_CAPTION","Page %1",
      "i",curpage),
     CALL print(calcpos(380,580)), disp_cur_page,
     CALL print(calcpos(700,580)),
     cur_date"@SHORTDATETIME", row + 1
    WITH nocounter, maxcol = 792, maxrow = 600,
     landscape, dio = 08, compress,
     noheading, format = variable
   ;end select
 END ;Subroutine
#exit_script
 CALL echo("***********************************")
 CALL echo("***   Start of error checking   ***")
 CALL echo("***********************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET nstat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET nstat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  SET nscriptstatus = nfailed_ccl_error
  CALL echorecord(errors)
 ELSE
  SET nscriptstatus = nsuccess
 ENDIF
 CALL echo("*************************************")
 CALL echo("***   Start of error processing   ***")
 CALL echo("*************************************")
 IF (nscriptstatus != nsuccess)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  CASE (nscriptstatus)
   OF nfailed_ccl_error:
    SET reply->status_data.subeventstatus[1].operationname = "CCL ERROR"
    SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_plan_order_move_report"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errors->err[1].err_msg
  ENDCASE
 ELSEIF (size(temp->persons,5)=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (ndebugmode)
  CALL echo("The reply structure:")
  CALL echorecord(reply)
 ENDIF
 CALL echo("***********************************************")
 CALL echo("***   Start of internal structure cleanup   ***")
 CALL echo("***********************************************")
 FREE RECORD errors
 FREE RECORD temp
 FREE RECORD demog_info
 SET smoddate = "April 04, 2013"
 SET slastmod = "005"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),dqtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<------------------------------------------------>")
 CALL echo("<---   END dcp_plan_order_move_report.prg     --->")
 CALL echo("<------------------------------------------------>")
END GO
