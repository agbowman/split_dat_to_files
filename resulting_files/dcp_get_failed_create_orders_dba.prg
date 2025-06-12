CREATE PROGRAM dcp_get_failed_create_orders:dba
 DECLARE script_name = vc WITH private, constant("dcp_get_failed_create_orders")
 CALL echo("<--------------------------------------------->")
 CALL echo(concat("<---	BEGIN: ",script_name,"	--->"))
 CALL echo("<--------------------------------------------->")
 DECLARE qtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(qtimerbegindttm,";;Q"),"    ==="))
 CALL echo("====================================================")
 IF (validate(reply->failed_create_orders)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 failed_create_orders[*]
      2 order_id = f8
      2 orderable = vc
      2 order_activated_dt_tm = dq8
      2 order_activated_personnel_name = vc
      2 patient_id = f8
      2 patient_name = vc
      2 encounter_id = f8
      2 plan_name = vc
      2 phase_id = f8
      2 phase_name = vc
      2 phase_ordered_dt_tm = dq8
      2 phase_start_dt_tm = dq8
      2 phase_ordering_personnel_name = vc
  )
 ENDIF
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
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE ndebugscript = i2 WITH public, constant(1)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "S"
 DECLARE report_status(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE numberofminutesuntilfailedcreate = i4 WITH protect, noconstant(validate(request->
   number_of_minutes_until_failed_create,10))
 IF (numberofminutesuntilfailedcreate < 1)
  SET numberofminutesuntilfailedcreate = 10
 ENDIF
 DECLARE failed_create_dt_tm = dq8 WITH protect, constant(cnvtlookbehind(build(
    numberofminutesuntilfailedcreate,",MIN"),cnvtdatetime(curdate,curtime3)))
 DECLARE clinical_category_display_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   30720,"CLINCAT"))
 DECLARE order_component_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,
   "ORDER CREATE"))
 DECLARE prescription_component_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,
   "PRESCRIPTION"))
 DECLARE initiated_phase_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "INITIATED"))
 DECLARE future_phase_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"FUTURE")
  )
 DECLARE discontinued_phase_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "DISCONTINUED"))
 DECLARE complete_phase_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "COMPLETED"))
 DECLARE order_phase_action_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "ORDER"))
 DECLARE searchbegindttm = dq8 WITH protect, noconstant(cnvtdatetimeutc(request->begin_dt_tm,0))
 DECLARE searchenddttm = dq8 WITH protect, noconstant(cnvtdatetime(failed_create_dt_tm))
 IF ((request->end_dt_tm != null))
  IF ((request->end_dt_tm < failed_create_dt_tm))
   SET searchenddttm = cnvtdatetime(request->end_dt_tm)
  ENDIF
 ENDIF
 SET searchenddttm = cnvtdatetimeutc(searchenddttm,0)
 FREE RECORD failed_create_components
 RECORD failed_create_components(
   1 index = i4
   1 size = i4
   1 components[*]
     2 component_id = f8
 )
 SELECT INTO "nl:"
  FROM act_pw_comp apc
  PLAN (apc
   WHERE apc.activated_dt_tm BETWEEN cnvtdatetime(searchbegindttm) AND cnvtdatetime(searchenddttm)
    AND apc.comp_type_cd IN (order_component_type_cd, prescription_component_type_cd)
    AND apc.activated_ind=1
    AND apc.parent_entity_name="ORDERS"
    AND  NOT ( EXISTS (
   (SELECT
    o.order_id
    FROM orders o
    WHERE o.order_id=apc.parent_entity_id))))
  HEAD REPORT
   dummy = 0
  DETAIL
   failed_create_components->index = (failed_create_components->index+ 1)
   IF ((failed_create_components->index > failed_create_components->size))
    failed_create_components->size = (failed_create_components->size+ 10), stat = alterlist(
     failed_create_components->components,failed_create_components->size)
   ENDIF
   failed_create_components->components[failed_create_components->index].component_id = apc
   .act_pw_comp_id
  FOOT REPORT
   IF ((failed_create_components->index < failed_create_components->size)
    AND (failed_create_components->index > 0))
    failed_create_components->size = failed_create_components->index, stat = alterlist(
     failed_create_components->components,failed_create_components->index)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE orders_size = i4 WITH protect, noconstant(0)
 DECLARE orders_index = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM act_pw_comp apc,
   pathway p,
   pathway_action pa,
   order_catalog_synonym ocs,
   person ps,
   encounter e,
   prsnl pn,
   prsnl pn1
  PLAN (apc
   WHERE expand(index,1,failed_create_components->size,apc.act_pw_comp_id,failed_create_components->
    components[index].component_id))
   JOIN (p
   WHERE p.pathway_id=apc.pathway_id
    AND p.pw_status_cd IN (initiated_phase_status_cd, future_phase_status_cd,
   discontinued_phase_status_cd, complete_phase_status_cd)
    AND p.type_mean IN ("CAREPLAN", "PHASE", "DOT", "SUBPHASE"))
   JOIN (ocs
   WHERE ocs.synonym_id=apc.ref_prnt_ent_id)
   JOIN (pa
   WHERE pa.pathway_id=apc.pathway_id
    AND pa.action_type_cd IN (order_phase_action_type_cd))
   JOIN (ps
   WHERE ps.person_id=apc.person_id)
   JOIN (e
   WHERE e.encntr_id=apc.encntr_id)
   JOIN (pn
   WHERE pn.person_id=outerjoin(pa.action_prsnl_id))
   JOIN (pn1
   WHERE pn1.person_id=outerjoin(apc.activated_prsnl_id))
  ORDER BY p.pw_group_nbr, p.pathway_id, apc.parent_entity_id
  HEAD REPORT
   orders_size = 0, orders_index = 0
  HEAD p.pathway_id
   dummy = 0
  HEAD pa.pw_action_seq
   dummy = 0
  HEAD apc.parent_entity_id
   orders_index = (orders_index+ 1)
   IF (orders_index > orders_size)
    orders_size = (orders_size+ 10), stat = alterlist(reply->failed_create_orders,orders_size)
   ENDIF
   reply->failed_create_orders[orders_index].order_id = apc.parent_entity_id, reply->
   failed_create_orders[orders_index].orderable = trim(ocs.mnemonic), reply->failed_create_orders[
   orders_index].patient_id = apc.person_id,
   reply->failed_create_orders[orders_index].patient_name = trim(ps.name_full_formatted), reply->
   failed_create_orders[orders_index].encounter_id = apc.encntr_id, reply->failed_create_orders[
   orders_index].plan_name = trim(p.pw_group_desc),
   reply->failed_create_orders[orders_index].phase_id = p.pathway_id, reply->failed_create_orders[
   orders_index].order_activated_dt_tm = cnvtdatetime(apc.activated_dt_tm), reply->
   failed_create_orders[orders_index].phase_start_dt_tm = cnvtdatetime(p.start_dt_tm),
   reply->failed_create_orders[orders_index].phase_ordered_dt_tm = cnvtdatetime(p.order_dt_tm)
   IF (trim(p.type_mean)="SUBPHASE")
    reply->failed_create_orders[orders_index].phase_name = concat(trim(p.parent_phase_desc)," - ",
     trim(p.description))
   ELSE
    reply->failed_create_orders[orders_index].phase_name = trim(p.description)
   ENDIF
   IF (pa.action_prsnl_id > 0.0
    AND pn.person_id > 0.0)
    reply->failed_create_orders[orders_index].phase_ordering_personnel_name = trim(pn
     .name_full_formatted)
   ENDIF
   IF (apc.activated_prsnl_id > 0.0
    AND pn1.person_id > 0.0)
    reply->failed_create_orders[orders_index].order_activated_personnel_name = trim(pn1
     .name_full_formatted)
   ENDIF
  FOOT  pa.pw_action_seq
   dummy = 0
  FOOT  p.pathway_id
   dummy = 0
  FOOT REPORT
   IF (orders_index < orders_size
    AND orders_index > 0)
    stat = alterlist(reply->failed_create_orders,orders_index)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SUBROUTINE report_status(opname,opstatus,targetname,targetvalue)
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alter(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     opname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (targetname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 CALL echo("***********************************")
 CALL echo("***   Start of error checking   ***")
 CALL echo("***********************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 50)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   CALL report_status("CCL ERROR","F",script_name,errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET stat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  SET reply->status_data.status = "F"
  CALL echorecord(errors)
 ENDIF
 IF (ndebugscript)
  CALL echorecord(failed_create_components)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD failed_create_components
 DECLARE last_mod = c3 WITH private, constant("001")
 DECLARE mod_date = vc WITH private, constant("January 5, 2015")
 DECLARE qtimerenddttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     End Dt/Tm: ",format(qtimerenddttm,";;Q"),"    ==="))
 CALL echo("====================================================")
 SET dentirescriptdiffinsec = datetimediff(qtimerenddttm,qtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<-------------------------------------->")
 CALL echo(concat("<--- END ",script_name," --->"))
 CALL echo("<-------------------------------------->")
END GO
