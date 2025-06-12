CREATE PROGRAM cp_get_power_plans:dba
 RECORD print(
   1 phases[*]
     2 display = vc
     2 wrapcnt = i2
     2 wrap[*]
       3 line = vc
     2 statuscd = f8
     2 initiateddisp = vc
     2 initwrapcnt = i2
     2 initwrap[*]
       3 line = vc
     2 stopdisp = vc
     2 stopwrapcnt = i2
     2 stopwrap[*]
       3 line = vc
     2 outcomes[*]
       3 display = vc
       3 wrapcnt = i2
       3 wrap[*]
         4 line = vc
       3 results[*]
         4 met_ind = i2
         4 value = vc
         4 valuewrapcnt = i2
         4 valuewrap[*]
           5 line = vc
         4 charteddisp = vc
         4 chartedwrapcnt = i2
         4 chartedwrap[*]
           5 line = vc
         4 variances[*]
           5 varreasondisp = vc
           5 reasonwrapcnt = i2
           5 reasonwrap[*]
             6 line = vc
           5 varactiondisp = vc
           5 actionwrapcnt = i2
           5 actionwrap[*]
             6 line = vc
           5 varnotedisp = vc
           5 notewrapcnt = i2
           5 notewrap[*]
             6 line = vc
           5 varchartdisp = vc
           5 varchartcnt = i2
           5 varchartwrap[*]
             6 line = vc
           5 varunchartdisp = vc
           5 varunchartcnt = i2
           5 varunchartwrap[*]
             6 line = vc
     2 interventions[*]
       3 display = vc
       3 wrapcnt = i2
       3 wrap[*]
         4 line = vc
       3 results[*]
         4 met_ind = i2
         4 value = vc
         4 valuewrapcnt = i2
         4 valuewrap[*]
           5 line = vc
         4 charteddisp = vc
         4 chartedwrapcnt = i2
         4 chartedwrap[*]
           5 line = vc
         4 variances[*]
           5 varreasondisp = vc
           5 reasonwrapcnt = i2
           5 reasonwrap[*]
             6 line = vc
           5 varactiondisp = vc
           5 actionwrapcnt = i2
           5 actionwrap[*]
             6 line = vc
           5 varnotedisp = vc
           5 notewrapcnt = i2
           5 notewrap[*]
             6 line = vc
           5 varchartdisp = vc
           5 varchartcnt = i2
           5 varchartwrap[*]
             6 line = vc
           5 varunchartdisp = vc
           5 varunchartcnt = i2
           5 varunchartwrap[*]
             6 line = vc
     2 plan_actions[*]
       3 planactiondisp = vc
       3 planduplicatemodify = i2
       3 planwrapcnt = i2
       3 planwrap[*]
         4 line = vc
 )
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 output_file = vc
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 sinitiated = vc
   1 sdiscontinued = vc
   1 svoided = vc
   1 sby = vc
   1 son = vc
   1 soutcomes = vc
   1 sinterventions = vc
   1 scharted = vc
   1 suncharted = vc
   1 scompleted = vc
   1 splanned = vc
   1 sexcluded = vc
   1 sfuture = vc
   1 smodified = vc
   1 srouteforreview = vc
   1 sacceptreview = vc
   1 srejectreview = vc
   1 srescheduled = vc
   1 snoroutereview = vc
   1 soverride = vc
   1 ssuggested = vc
   1 saccepted = vc
   1 srejected = vc
   1 sat = vc
   1 selectronicallysigned = vc
 )
 SUBROUTINE fillcaptions(dummyvar)
   SET captions->sinitiated = trim(uar_i18ngetmessage(i18nhandle,"INITIATED","Initiated"))
   SET captions->sdiscontinued = trim(uar_i18ngetmessage(i18nhandle,"DISCONTINUED","Discontinued"))
   SET captions->svoided = trim(uar_i18ngetmessage(i18nhandle,"VOIDED","Voided"))
   SET captions->sby = trim(uar_i18ngetmessage(i18nhandle,"BY","By"))
   SET captions->son = trim(uar_i18ngetmessage(i18nhandle,"ON","On"))
   SET captions->soutcomes = trim(uar_i18ngetmessage(i18nhandle,"OUTCOMES","Outcomes"))
   SET captions->sinterventions = trim(uar_i18ngetmessage(i18nhandle,"INTERVENTIONS","Interventions")
    )
   SET captions->scharted = trim(uar_i18ngetmessage(i18nhandle,"CHARTED","Charted"))
   SET captions->suncharted = trim(uar_i18ngetmessage(i18nhandle,"UNCHARTED","Uncharted"))
   SET captions->scompleted = trim(uar_i18ngetmessage(i18nhandle,"COMPLETED","Completed"))
   SET captions->splanned = trim(uar_i18ngetmessage(i18nhandle,"PLANNED","Planned"))
   SET captions->sexcluded = trim(uar_i18ngetmessage(i18nhandle,"EXCLUDED","Excluded"))
   SET captions->sfuture = trim(uar_i18ngetmessage(i18nhandle,"FUTURE","Future"))
   SET captions->smodified = trim(uar_i18ngetmessage(i18nhandle,"MODIFIED","Modified"))
   SET captions->srouteforreview = trim(uar_i18ngetmessage(i18nhandle,"ROUTED_FOR_REVIEW",
     "Routed For Review"))
   SET captions->sacceptreview = trim(uar_i18ngetmessage(i18nhandle,"ACCEPT_REVIEW","Accept Review"))
   SET captions->srejectreview = trim(uar_i18ngetmessage(i18nhandle,"REJECT_REVIEW","Reject Review"))
   SET captions->srescheduled = trim(uar_i18ngetmessage(i18nhandle,"RESCHEDULED","Rescheduled"))
   SET captions->snoroutereview = trim(uar_i18ngetmessage(i18nhandle,"DO_NOT_ROUTE_FOR_REVIEW",
     "Do Not Route For Review"))
   SET captions->soverride = trim(uar_i18ngetmessage(i18nhandle,"OVERRODE_CLINICAL_TRAIL_WARNING",
     "Overrode Clinical Trail Warning"))
   SET captions->ssuggested = trim(uar_i18ngetmessage(i18nhandle,"SUGGESTED","Suggested"))
   SET captions->saccepted = trim(uar_i18ngetmessage(i18nhandle,"ACCEPTED","Accepted"))
   SET captions->srejected = trim(uar_i18ngetmessage(i18nhandle,"REJECTED","Rejected"))
   SET captions->sat = trim(uar_i18ngetmessage(i18nhandle,"AT","at"))
   SET captions->selectronicallysigned = trim(uar_i18ngetmessage(i18nhandle,"ELECTRONICALLY_SIGNED",
     "Electronically Signed"))
 END ;Subroutine
 RECORD data(
   1 phases[*]
     2 pw_group_nbr = f8
     2 pw_type_mean = c12
     2 pw_group_desc = vc
     2 pw_start_dt_tm = dq8
     2 pw_start_tz = i4
     2 pathway_id = f8
     2 pw_status_cd = f8
     2 description = vc
     2 type_mean = c12
     2 start_dt_tm = dq8
     2 start_tz = i4
     2 calc_end_dt_tm = dq8
     2 calc_end_tz = i4
     2 order_dt_tm = dq8
     2 order_tz = i4
     2 sequence = i4
     2 parent_phase_desc = vc
     2 treatment_schedule_desc = vc
     2 comps[*]
       3 act_pw_comp_id = f8
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_sub_cat_cd = f8
       3 comp_type_cd = f8
       3 comp_status_cd = f8
       3 sequence = i4
       3 linked_to_tf_ind = i2
       3 parent_entity_id = f8
       3 outcome_description = vc
       3 outcome_expectation = vc
       3 outcome_type_cd = f8
       3 outcome_status_cd = f8
       3 target_type_cd = f8
       3 outcome_start_dt_tm = dq8
       3 outcome_start_tz = i4
       3 outcome_end_dt_tm = dq8
       3 outcome_end_tz = i4
       3 sort_idx = i2
       3 outcome_valid_flag = i2
       3 nomen_string_flag = i2
       3 labels[*]
         4 ce_dynamic_label_id = f8
         4 label_name = vc
         4 results[*]
           5 met_ind = i2
           5 event_id = f8
           5 event_end_dt_tm = dq8
           5 event_end_tz = i4
           5 result_val = vc
           5 result_units_disp = c40
           5 perform_dt_tm = dq8
           5 perform_tz = i4
           5 perform_prsnl_name = vc
           5 nomen_string_flag = i2
           5 preferred_nomen_disp = vc
           5 variances[*]
             6 variance_idx = i4
             6 variance_reltn_id = f8
     2 actions[*]
       3 action_type_cd = f8
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_prsnl_id = f8
       3 action_prsnl_disp = vc
       3 pw_action_seq = i4
       3 pw_status_cd = f8
   1 variances[*]
     2 variance_reltn_id = f8
     2 parent_entity_id = f8
     2 pathway_id = f8
     2 event_id = f8
     2 variance_type_cd = f8
     2 active_ind = i2
     2 action_cd = f8
     2 action_text = vc
     2 reason_cd = f8
     2 reason_text = vc
     2 note_text = vc
     2 chart_prsnl_name = vc
     2 chart_dt_tm = dq8
     2 chart_tz = i4
     2 unchart_prsnl_name = vc
     2 unchart_dt_tm = dq8
     2 unchart_tz = i4
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
 )
 DECLARE numrows = i4 WITH noconstant(0)
 DECLARE numlines = i4 WITH noconstant(0)
 DECLARE pagevar = i4 WITH noconstant(0)
 DECLARE i = i4
 DECLARE j = i4
 DECLARE k_iterator = i4
 DECLARE ln = i4 WITH noconstant(0)
 DECLARE cnodata = c1 WITH noconstant("Y")
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE exceptioncnt = i4 WITH noconstant(0)
 DECLARE loginfocnt = i4 WITH noconstant(0)
 DECLARE dummyvoid = i2 WITH constant(0)
 DECLARE debug = i2 WITH noconstant(0)
 IF ((request->scope_flag=777))
  SET debug = 1
 ENDIF
 DECLARE viewplans_cd = f8 WITH constant(uar_get_code_by("MEANING",6016,"VIEWPLANS"))
 DECLARE initiated_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"INITIATED"))
 DECLARE initreview_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"INITREVIEW"))
 DECLARE planned_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE excluded_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"EXCLUDED"))
 DECLARE future_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"FUTURE"))
 DECLARE futurereview_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"FUTUREREVIEW"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"COMPLETED"))
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"ORDER"))
 DECLARE modify_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"MODIFY"))
 DECLARE acceptreview_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"ACCEPTREVIEW"))
 DECLARE noroutereview_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"NOROUTEREVIE"))
 DECLARE rejectreview_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"REJECTREVIEW"))
 DECLARE routereview_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"ROUTEREVIEW"))
 DECLARE reschedule_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"RESCHEDULE"))
 DECLARE schedmodify_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"SCHEDMODIFY"))
 DECLARE void_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"VOID"))
 DECLARE override_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"PTWRNOVERIDE"))
 DECLARE complete_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"COMPLETE"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"DISCONTINUE"))
 DECLARE suggest_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"SUGGEST"))
 DECLARE accept_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"ACCEPT"))
 DECLARE reject_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"REJECT"))
 DECLARE ranalert_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"RANALERT"))
 DECLARE stime = vc WITH protect
 DECLARE processprivileges(dummyvar=i2) = null
 DECLARE populatereply(dummyvar=i2) = null
 DECLARE fetchdata(dummyvar=i2) = null
 DECLARE parsedata(dummyvar=i2) = null
 DECLARE formatreport(dummyvar=i2) = null
 DECLARE loadcomponent(dataphaseidx=i4,datacompidx=i4,printphaseidx=i4,printoutidx=i4(ref),
  printintidx=i4(ref)) = null
 DECLARE loadoutcome(dataphaseidx=i4,datacompidx=i4,printphaseidx=i4,printoutidx=i4(ref)) = null
 DECLARE loadintervention(dataphaseidx=i4,datacompidx=i4,printphaseidx=i4,printintidx=i4(ref)) = null
 DECLARE getformattedtime(date_time=dq8,time_zone=i4) = null
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE gettimeformatted(date_time=dq8,time_zone=i4) = vc
 CALL fillcaptions(dummyvoid)
 CALL fetchdata(dummyvoid)
 CALL parsedata(dummyvoid)
 CALL formatreport(dummyvoid)
 CALL populatereply(dummyvoid)
 SUBROUTINE fetchdata(dummyvar)
   RECORD get_print_data(
     1 querymode = c12
     1 person_id = f8
     1 encntr_id = f8
     1 plantypeincludelist[*]
       2 pathway_type_cd = f8
     1 plantypeexcludelist[*]
       2 pathway_type_cd = f8
   )
   RECORD get_print_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET get_print_data->querymode = "INITOUT"
   SET get_print_data->person_id = request->person_id
   SET get_print_data->encntr_id = request->encntr_id
   CALL processprivileges(dummyvoid)
   IF (debug=1)
    CALL echorecord(get_print_data)
   ENDIF
   EXECUTE dcp_get_plan_data_to_print  WITH replace("REQUEST","GET_PRINT_DATA"), replace("REPLY",
    "GET_PRINT_REPLY")
   IF ((get_print_reply->status_data.status="F"))
    CALL report_failure("EXECUTE","F","CP_GET_POWER_PLANS",
     "Call to DCP_GET_PLAN_DATA_TO_PRINT failed")
    FOR (errcnt = 1 TO value(size(reply->status_data.subeventstatus,5)))
      CALL report_failure(get_print_reply->status_data.subeventstatus[errcnt].operationname,
       get_print_reply->status_data.subeventstatus[errcnt].operationstatus,get_print_reply->
       status_data.subeventstatus[errcnt].targetobjectname,get_print_reply->status_data.
       subeventstatus[errcnt].targetobjectvalue)
    ENDFOR
   ENDIF
   IF (debug=1)
    CALL echorecord(get_print_reply)
    CALL echorecord(data)
   ENDIF
   FREE RECORD get_print_data
   FREE RECORD get_print_reply
   IF (cfailed="T")
    GO TO exit_script
   ELSE
    IF (value(size(data->phases,5)) > 0)
     SET cnodata = "N"
    ELSE
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE processprivileges(dummyvar)
  IF (validate(request->privileges) <= 0)
   RETURN
  ENDIF
  FOR (i = 1 TO value(size(request->privileges,5)))
    IF ((request->privileges[i].privilege_cd=viewplans_cd)
     AND value(size(request->privileges[i].default,5)) > 0)
     SET exceptioncnt = size(request->privileges[i].default[1].exceptions,5)
     IF ((request->privileges[i].default[1].granted_ind=1))
      IF (exceptioncnt < 1)
       RETURN
      ENDIF
      SET stat = alterlist(get_print_data->plantypeexcludelist,exceptioncnt)
      FOR (j = 1 TO exceptioncnt)
        SET get_print_data->plantypeexcludelist[j].pathway_type_cd = request->privileges[i].default[1
        ].exceptions[j].id
      ENDFOR
     ELSE
      IF (exceptioncnt < 1)
       GO TO exit_script
      ENDIF
      SET stat = alterlist(get_print_data->plantypeincludelist,exceptioncnt)
      FOR (j = 1 TO exceptioncnt)
        SET get_print_data->plantypeincludelist[j].pathway_type_cd = request->privileges[i].default[1
        ].exceptions[j].id
      ENDFOR
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE populatereply(dummyvar)
   SET loginfocnt = size(data->log_info,5)
   IF (loginfocnt <= 0)
    RETURN
   ENDIF
   SET stat = alterlist(reply->log_info,loginfocnt)
   FOR (i = 1 TO loginfocnt)
    SET reply->log_info[i].log_level = data->log_info[i].log_level
    SET reply->log_info[i].log_message = data->log_info[i].log_message
   ENDFOR
 END ;Subroutine
 SUBROUTINE parsedata(dummyvar)
   DECLARE phasecnt = i4 WITH protect, noconstant(0)
   DECLARE max_length = i4 WITH noconstant(0)
   DECLARE result_type_cs = i4 WITH protect, constant(289)
   DECLARE alpha_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",result_type_cs,"2")))
   DECLARE multi_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",result_type_cs,"5")))
   DECLARE prevactioncd = f8 WITH protect, noconstant(0.0)
   DECLARE prevstatuscd = f8 WITH protect, noconstant(0.0)
   DECLARE nextactioncd = f8 WITH protect, noconstant(0.0)
   DECLARE nextstatuscd = f8 WITH protect, noconstant(0.0)
   DECLARE nextactdatetime = vc WITH protect, noconstant(fillstring(60," "))
   DECLARE duplicatemodify = i2 WITH protect, noconstant(0)
   RECORD pt(
     1 line_cnt = i2
     1 lns[*]
       2 line = vc
   )
   SELECT INTO "nl:"
    pw_start_dt_tm = cnvtdatetime(data->phases[d1.seq].pw_start_dt_tm), pw_group_nbr = data->phases[
    d1.seq].pw_group_nbr, sequence = data->phases[d1.seq].sequence,
    comp_sort_idx = data->phases[d1.seq].comps[d2.seq].sort_idx, comp_seq = data->phases[d1.seq].
    comps[d2.seq].sequence
    FROM (dummyt d1  WITH seq = value(size(data->phases,5))),
     (dummyt d2  WITH seq = 5)
    PLAN (d1
     WHERE maxrec(d2,size(data->phases[d1.seq].comps,5)) > 0)
     JOIN (d2)
    ORDER BY pw_start_dt_tm, pw_group_nbr, sequence
    HEAD REPORT
     phscnt = 0
    HEAD pw_start_dt_tm
     dummy = 0
    HEAD pw_group_nbr
     dummy = 0
    HEAD sequence
     phscnt = (phscnt+ 1)
     IF (phscnt > size(print->phases,5))
      stat = alterlist(print->phases,(phscnt+ 10))
     ENDIF
     IF ((data->phases[d1.seq].type_mean="CAREPLAN"))
      name = data->phases[d1.seq].pw_group_desc
     ELSEIF ((data->phases[d1.seq].type_mean="PHASE"))
      name = concat(data->phases[d1.seq].pw_group_desc," - ",data->phases[d1.seq].description)
     ELSEIF ((data->phases[d1.seq].type_mean="SUBPHASE"))
      IF ((data->phases[d1.seq].pw_type_mean="CAREPLAN"))
       name = concat(data->phases[d1.seq].pw_group_desc," - ",data->phases[d1.seq].description)
      ELSE
       name = concat(data->phases[d1.seq].pw_group_desc," - ",data->phases[d1.seq].parent_phase_desc,
        " - ",data->phases[d1.seq].description)
      ENDIF
     ELSEIF ((data->phases[d1.seq].type_mean="DOT"))
      IF ((data->phases[d1.seq].pw_type_mean="CAREPLAN"))
       name = concat(data->phases[d1.seq].pw_group_desc," - ",data->phases[d1.seq].description)
      ELSE
       name = concat(data->phases[d1.seq].pw_group_desc," - ",data->phases[d1.seq].
        treatment_schedule_desc," - ",data->phases[d1.seq].description)
      ENDIF
     ENDIF
     print->phases[phscnt].statuscd = data->phases[d1.seq].pw_status_cd, statuscddisp = trim(
      uar_get_code_display(data->phases[d1.seq].pw_status_cd)), print->phases[phscnt].display =
     concat(trim(name)," (",trim(statuscddisp),")"),
     actioncnt = size(data->phases[d1.seq].actions,5), stat = alterlist(print->phases[phscnt].
      plan_actions,actioncnt)
     FOR (j = 1 TO actioncnt)
      duplicatemodify = 0,
      CASE (data->phases[d1.seq].actions[j].action_type_cd)
       OF order_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)orderedprsnl = trim(data->phases[d1.seq].actions[j].action_prsnl_disp),
        IF ((data->phases[d1.seq].actions[j].pw_status_cd=planned_cd))
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->splanned," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          orderedprsnl)
        ELSEIF ((((data->phases[d1.seq].actions[j].pw_status_cd=initiated_cd)) OR ((data->phases[d1
        .seq].actions[j].pw_status_cd=initreview_cd))) )
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sinitiated," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          orderedprsnl)
        ELSEIF ((data->phases[d1.seq].actions[j].pw_status_cd=excluded_cd))
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sexcluded," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          orderedprsnl)
        ELSEIF ((((data->phases[d1.seq].actions[j].pw_status_cd=future_cd)) OR ((data->phases[d1.seq]
        .actions[j].pw_status_cd=futurereview_cd))) )
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sfuture," ",captions
          ->sinitiated," ",captions->sat,
          " ",trim(stime)," ",captions->selectronicallysigned," ",
          captions->sby," ",orderedprsnl)
        ENDIF
        ,prevactioncd = data->phases[d1.seq].actions[j].action_type_cd,prevstatuscd = data->phases[d1
        .seq].actions[j].pw_status_cd
       OF modify_cd:
        modifieddttmdisp = gettimeformatted(data->phases[d1.seq].actions[j].action_dt_tm,data->
         phases[d1.seq].actions[j].action_tz),modifiedprsnl = trim(data->phases[d1.seq].actions[j].
         action_prsnl_disp),k_iterator = (j+ 1),
        IF (k_iterator <= actioncnt)
         nextactioncd = data->phases[d1.seq].actions[k_iterator].action_type_cd, nextstatuscd = data
         ->phases[d1.seq].actions[k_iterator].pw_status_cd, nextactdatetime = gettimeformatted(data->
          phases[d1.seq].actions[k_iterator].action_dt_tm,data->phases[d1.seq].actions[k_iterator].
          action_tz)
        ENDIF
        ,
        IF (nextactdatetime=modifieddttmdisp
         AND ((nextactioncd=acceptreview_cd) OR (nextactioncd=rejectreview_cd)) )
         nextactioncd = 0.0, nextactdatetime = fillstring(60," "), duplicatemodify = 1,
         print->phases[phscnt].plan_actions[j].planduplicatemodify = 1
        ELSEIF (duplicatemodify=0
         AND nextactioncd=routereview_cd
         AND nextactdatetime=modifieddttmdisp)
         IF (((prevactioncd=order_cd) OR (prevactioncd=modify_cd))
          AND (data->phases[d1.seq].actions[j].action_type_cd=modify_cd)
          AND (prevstatuscd=data->phases[d1.seq].actions[j].pw_status_cd))
          nextactioncd = 0.0, nextactdatetime = fillstring(60," "), duplicatemodify = 1,
          print->phases[phscnt].plan_actions[j].planduplicatemodify = 1
         ELSEIF ((data->phases[d1.seq].actions[j].pw_status_cd=initreview_cd))
          print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sinitiated," ",
           captions->sat," ",trim(modifieddttmdisp),
           " ",captions->selectronicallysigned," ",captions->sby," ",
           modifiedprsnl)
         ELSEIF ((data->phases[d1.seq].actions[j].pw_status_cd=futurereview_cd))
          print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sfuture," ",
           captions->sinitiated," ",captions->sat,
           " ",trim(modifieddttmdisp)," ",captions->selectronicallysigned," ",
           captions->sby," ",modifiedprsnl)
         ENDIF
        ELSEIF (duplicatemodify=0
         AND nextactioncd=reschedule_cd
         AND nextactdatetime=modifieddttmdisp)
         IF (((prevactioncd=order_cd) OR (prevactioncd=modify_cd))
          AND (data->phases[d1.seq].actions[j].action_type_cd=modify_cd)
          AND (prevstatuscd=data->phases[d1.seq].actions[j].pw_status_cd))
          nextactioncd = 0.0, nextactdatetime = fillstring(60," "), duplicatemodify = 1,
          print->phases[phscnt].plan_actions[j].planduplicatemodify = 1
         ELSEIF ((((data->phases[d1.seq].actions[j].pw_status_cd=initiated_cd)) OR ((data->phases[d1
         .seq].actions[j].pw_status_cd=initreview_cd))) )
          print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sinitiated," ",
           captions->sat," ",trim(modifieddttmdisp),
           " ",captions->selectronicallysigned," ",captions->sby," ",
           modifiedprsnl)
         ELSEIF ((((data->phases[d1.seq].actions[j].pw_status_cd=future_cd)) OR ((data->phases[d1.seq
         ].actions[j].pw_status_cd=futurereview_cd))) )
          print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sfuture," ",
           captions->sinitiated," ",captions->sat,
           " ",trim(modifieddttmdisp)," ",captions->selectronicallysigned," ",
           captions->sby," ",modifiedprsnl)
         ENDIF
        ELSE
         IF (duplicatemodify=0
          AND ((prevactioncd=order_cd) OR (prevactioncd=modify_cd))
          AND (data->phases[d1.seq].actions[j].action_type_cd=modify_cd)
          AND (((prevstatuscd=data->phases[d1.seq].actions[j].pw_status_cd)) OR ((data->phases[d1.seq
         ].actions[j].pw_status_cd=completed_cd))) )
          print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->smodified," ",
           captions->sat," ",trim(modifieddttmdisp),
           " ",captions->selectronicallysigned," ",captions->sby," ",
           modifiedprsnl)
         ELSEIF (duplicatemodify=0
          AND (((data->phases[d1.seq].actions[j].pw_status_cd=future_cd)) OR ((data->phases[d1.seq].
         actions[j].pw_status_cd=futurereview_cd))) )
          print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sfuture," ",
           captions->sinitiated," ",captions->sat,
           " ",trim(modifieddttmdisp)," ",captions->selectronicallysigned," ",
           captions->sby," ",modifiedprsnl)
         ELSEIF (duplicatemodify=0
          AND (data->phases[d1.seq].actions[j].pw_status_cd=planned_cd))
          print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->splanned," ",
           captions->sat," ",trim(modifieddttmdisp),
           " ",captions->selectronicallysigned," ",captions->sby," ",
           modifiedprsnl)
         ELSEIF (duplicatemodify=0
          AND (((data->phases[d1.seq].actions[j].pw_status_cd=initiated_cd)) OR ((data->phases[d1.seq
         ].actions[j].pw_status_cd=initreview_cd))) )
          print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sinitiated," ",
           captions->sat," ",trim(modifieddttmdisp),
           " ",captions->selectronicallysigned," ",captions->sby," ",
           modifiedprsnl)
         ENDIF
        ENDIF
        ,prevactioncd = data->phases[d1.seq].actions[j].action_type_cd,prevstatuscd = data->phases[d1
        .seq].actions[j].pw_status_cd
       OF routereview_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)routedreviewprsnl = trim(data->phases[d1.seq].actions[j].
         action_prsnl_disp),
        IF (stime > " "
         AND routedreviewprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->srouteforreview," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          routedreviewprsnl)
        ENDIF
       OF acceptreview_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)acceptreviewprsnl = trim(data->phases[d1.seq].actions[j].
         action_prsnl_disp),
        IF (stime > " "
         AND acceptreviewprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sacceptreview," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          acceptreviewprsnl)
        ENDIF
       OF rejectreview_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)rejectreviewprsnl = trim(data->phases[d1.seq].actions[j].
         action_prsnl_disp),
        IF (stime > " "
         AND rejectreviewprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->srejectreview," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          rejectreviewprsnl)
        ENDIF
       OF schedmodify_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)schedmodifyprsnl = trim(data->phases[d1.seq].actions[j].
         action_prsnl_disp),
        IF (stime > " "
         AND schedmodifyprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->smodified," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          schedmodifyprsnl)
        ENDIF
       OF reschedule_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)rescheduleprsnl = trim(data->phases[d1.seq].actions[j].action_prsnl_disp
         ),
        IF (stime > " "
         AND rescheduleprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->srescheduled," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          rescheduleprsnl)
        ENDIF
       OF void_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)voidprsnl = trim(data->phases[d1.seq].actions[j].action_prsnl_disp),
        IF (stime > " "
         AND voidprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->svoided," ",captions
          ->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          voidprsnl)
        ENDIF
       OF noroutereview_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)norouteprsnl = trim(data->phases[d1.seq].actions[j].action_prsnl_disp),
        IF (stime > " "
         AND norouteprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->snoroutereview," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          norouteprsnl)
        ENDIF
       OF override_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)overrideprsnl = trim(data->phases[d1.seq].actions[j].action_prsnl_disp),
        IF (stime > " "
         AND overrideprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->soverride," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          overrideprsnl)
        ENDIF
       OF complete_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)completeprsnl = trim(data->phases[d1.seq].actions[j].action_prsnl_disp),
        IF (stime > " "
         AND completeprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->scompleted," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          completeprsnl)
        ENDIF
       OF discontinued_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)discontinueprsnl = trim(data->phases[d1.seq].actions[j].
         action_prsnl_disp),
        IF (stime > " "
         AND discontinueprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->sdiscontinued," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          discontinueprsnl)
        ENDIF
       OF suggest_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)
        IF (stime > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->ssuggested," ",
          captions->sat," ",trim(stime))
        ENDIF
       OF accept_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)acceptprsnl = trim(data->phases[d1.seq].actions[j].action_prsnl_disp),
        IF (stime > " "
         AND acceptprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->saccepted," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          acceptprsnl)
        ENDIF
       OF reject_cd:
        CALL getformattedtime(data->phases[d1.seq].actions[j].action_dt_tm,data->phases[d1.seq].
        actions[j].action_tz)rejectprsnl = trim(data->phases[d1.seq].actions[j].action_prsnl_disp),
        IF (stime > " "
         AND rejectprsnl > " ")
         print->phases[phscnt].plan_actions[j].planactiondisp = concat(captions->srejected," ",
          captions->sat," ",trim(stime),
          " ",captions->selectronicallysigned," ",captions->sby," ",
          rejectprsnl)
        ENDIF
       OF ranalert_cd:
        print->phases[phscnt].plan_actions[j].planduplicatemodify = 1
      ENDCASE
     ENDFOR
     outcnt = 0, intcnt = 0
    HEAD comp_sort_idx
     dummy = 0
    HEAD comp_seq
     dummy = 0
    DETAIL
     CALL loadcomponent(d1.seq,d2.seq,phscnt,outcnt,intcnt)
    FOOT  comp_seq
     dummy = 0
    FOOT  comp_sort_idx
     dummy = 0
    FOOT  sequence
     IF (outcnt > 0)
      stat = alterlist(print->phases[phscnt].outcomes,outcnt)
     ENDIF
     IF (intcnt > 0)
      stat = alterlist(print->phases[phscnt].interventions,intcnt)
     ENDIF
    FOOT  pw_group_nbr
     dummy = 0
    FOOT  pw_start_dt_tm
     dummy = 0
    FOOT REPORT
     IF (phscnt > 0)
      stat = alterlist(print->phases,phscnt)
     ENDIF
    WITH nocounter, outerjoin(d1)
   ;end select
   SET phasecnt = value(size(print->phases,5))
   FOR (i = 1 TO phasecnt)
     SET max_length = 40
     SET pt->line_cnt = 0
     EXECUTE dcp_parse_text value(print->phases[i].display), value(max_length)
     SET stat = alterlist(print->phases[i].wrap,pt->line_cnt)
     SET print->phases[i].wrapcnt = pt->line_cnt
     FOR (j = 1 TO pt->line_cnt)
       SET print->phases[i].wrap[j].line = pt->lns[j].line
     ENDFOR
     SET actioncnt = size(print->phases[i].plan_actions,5)
     FOR (j = 1 TO actioncnt)
       SET pt->line_cnt = 0
       SET m = j
       EXECUTE dcp_parse_text value(print->phases[i].plan_actions[j].planactiondisp), value(
        max_length)
       SET j = m
       SET stat = alterlist(print->phases[i].plan_actions[j].planwrap,pt->line_cnt)
       SET print->phases[i].plan_actions[j].planwrapcnt = pt->line_cnt
       FOR (k_iterator = 1 TO pt->line_cnt)
         SET print->phases[i].plan_actions[j].planwrap[k_iterator].line = pt->lns[k_iterator].line
       ENDFOR
     ENDFOR
     SET outcomecnt = value(size(print->phases[i].outcomes,5))
     FOR (x = 1 TO outcomecnt)
       SET max_length = 110
       SET pt->line_cnt = 0
       EXECUTE dcp_parse_text value(print->phases[i].outcomes[x].display), value(max_length)
       SET stat = alterlist(print->phases[i].outcomes[x].wrap,pt->line_cnt)
       SET print->phases[i].outcomes[x].wrapcnt = pt->line_cnt
       FOR (y = 1 TO pt->line_cnt)
         SET print->phases[i].outcomes[x].wrap[y].line = pt->lns[y].line
       ENDFOR
       SET rescnt = value(size(print->phases[i].outcomes[x].results,5))
       FOR (y = 1 TO rescnt)
         SET max_length = 52
         SET pt->line_cnt = 0
         EXECUTE dcp_parse_text value(print->phases[i].outcomes[x].results[y].value), value(
          max_length)
         SET stat = alterlist(print->phases[i].outcomes[x].results[y].valuewrap,pt->line_cnt)
         SET print->phases[i].outcomes[x].results[y].valuewrapcnt = pt->line_cnt
         FOR (z = 1 TO pt->line_cnt)
           SET print->phases[i].outcomes[x].results[y].valuewrap[z].line = pt->lns[z].line
         ENDFOR
         SET max_length = 40
         SET pt->line_cnt = 0
         EXECUTE dcp_parse_text value(print->phases[i].outcomes[x].results[y].charteddisp), value(
          max_length)
         SET stat = alterlist(print->phases[i].outcomes[x].results[y].chartedwrap,pt->line_cnt)
         SET print->phases[i].outcomes[x].results[y].chartedwrapcnt = pt->line_cnt
         FOR (z = 1 TO pt->line_cnt)
           SET print->phases[i].outcomes[x].results[y].chartedwrap[z].line = pt->lns[z].line
         ENDFOR
         SET varcnt = value(size(print->phases[i].outcomes[x].results[y].variances,5))
         FOR (v = 1 TO varcnt)
           SET max_length = 50
           IF ((print->phases[i].outcomes[x].results[y].variances[v].varreasondisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].outcomes[x].results[y].variances[v].
             varreasondisp), value(max_length)
            SET stat = alterlist(print->phases[i].outcomes[x].results[y].variances[v].reasonwrap,pt->
             line_cnt)
            SET print->phases[i].outcomes[x].results[y].variances[v].reasonwrapcnt = pt->line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].outcomes[x].results[y].variances[v].reasonwrap[z].line = pt->lns[z
              ].line
            ENDFOR
           ENDIF
           IF ((print->phases[i].outcomes[x].results[y].variances[v].varactiondisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].outcomes[x].results[y].variances[v].
             varactiondisp), value(max_length)
            SET stat = alterlist(print->phases[i].outcomes[x].results[y].variances[v].actionwrap,pt->
             line_cnt)
            SET print->phases[i].outcomes[x].results[y].variances[v].actionwrapcnt = pt->line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].outcomes[x].results[y].variances[v].actionwrap[z].line = pt->lns[z
              ].line
            ENDFOR
           ENDIF
           IF ((print->phases[i].outcomes[x].results[y].variances[v].varnotedisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].outcomes[x].results[y].variances[v].
             varnotedisp), value(max_length)
            SET stat = alterlist(print->phases[i].outcomes[x].results[y].variances[v].notewrap,pt->
             line_cnt)
            SET print->phases[i].outcomes[x].results[y].variances[v].notewrapcnt = pt->line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].outcomes[x].results[y].variances[v].notewrap[z].line = pt->lns[z].
              line
            ENDFOR
           ENDIF
           SET max_length = 40
           IF ((print->phases[i].outcomes[x].results[y].variances[v].varchartdisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].outcomes[x].results[y].variances[v].
             varchartdisp), value(max_length)
            SET stat = alterlist(print->phases[i].outcomes[x].results[y].variances[v].varchartwrap,pt
             ->line_cnt)
            SET print->phases[i].outcomes[x].results[y].variances[v].varchartcnt = pt->line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].outcomes[x].results[y].variances[v].varchartwrap[z].line = pt->
              lns[z].line
            ENDFOR
           ENDIF
           SET max_length = 40
           IF ((print->phases[i].outcomes[x].results[y].variances[v].varunchartdisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].outcomes[x].results[y].variances[v].
             varunchartdisp), value(max_length)
            SET stat = alterlist(print->phases[i].outcomes[x].results[y].variances[v].varunchartwrap,
             pt->line_cnt)
            SET print->phases[i].outcomes[x].results[y].variances[v].varunchartcnt = pt->line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].outcomes[x].results[y].variances[v].varunchartwrap[z].line = pt->
              lns[z].line
            ENDFOR
           ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
     SET interventioncnt = value(size(print->phases[i].interventions,5))
     FOR (x = 1 TO interventioncnt)
       SET max_length = 110
       SET pt->line_cnt = 0
       EXECUTE dcp_parse_text value(print->phases[i].interventions[x].display), value(max_length)
       SET stat = alterlist(print->phases[i].interventions[x].wrap,pt->line_cnt)
       SET print->phases[i].interventions[x].wrapcnt = pt->line_cnt
       FOR (y = 1 TO pt->line_cnt)
         SET print->phases[i].interventions[x].wrap[y].line = pt->lns[y].line
       ENDFOR
       SET rescnt = value(size(print->phases[i].interventions[x].results,5))
       FOR (y = 1 TO rescnt)
         SET max_length = 52
         SET pt->line_cnt = 0
         EXECUTE dcp_parse_text value(print->phases[i].interventions[x].results[y].value), value(
          max_length)
         SET stat = alterlist(print->phases[i].interventions[x].results[y].valuewrap,pt->line_cnt)
         SET print->phases[i].interventions[x].results[y].valuewrapcnt = pt->line_cnt
         FOR (z = 1 TO pt->line_cnt)
           SET print->phases[i].interventions[x].results[y].valuewrap[z].line = pt->lns[z].line
         ENDFOR
         SET max_length = 40
         SET pt->line_cnt = 0
         EXECUTE dcp_parse_text value(print->phases[i].interventions[x].results[y].charteddisp),
         value(max_length)
         SET stat = alterlist(print->phases[i].interventions[x].results[y].chartedwrap,pt->line_cnt)
         SET print->phases[i].interventions[x].results[y].chartedwrapcnt = pt->line_cnt
         FOR (z = 1 TO pt->line_cnt)
           SET print->phases[i].interventions[x].results[y].chartedwrap[z].line = pt->lns[z].line
         ENDFOR
         SET varcnt = value(size(print->phases[i].interventions[x].results[y].variances,5))
         FOR (v = 1 TO varcnt)
           SET max_length = 50
           IF ((print->phases[i].interventions[x].results[y].variances[v].varreasondisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].interventions[x].results[y].variances[v].
             varreasondisp), value(max_length)
            SET stat = alterlist(print->phases[i].interventions[x].results[y].variances[v].reasonwrap,
             pt->line_cnt)
            SET print->phases[i].interventions[x].results[y].variances[v].reasonwrapcnt = pt->
            line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].interventions[x].results[y].variances[v].reasonwrap[z].line = pt->
              lns[z].line
            ENDFOR
           ENDIF
           IF ((print->phases[i].interventions[x].results[y].variances[v].varactiondisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].interventions[x].results[y].variances[v].
             varactiondisp), value(max_length)
            SET stat = alterlist(print->phases[i].interventions[x].results[y].variances[v].actionwrap,
             pt->line_cnt)
            SET print->phases[i].interventions[x].results[y].variances[v].actionwrapcnt = pt->
            line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].interventions[x].results[y].variances[v].actionwrap[z].line = pt->
              lns[z].line
            ENDFOR
           ENDIF
           IF ((print->phases[i].interventions[x].results[y].variances[v].varnotedisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].interventions[x].results[y].variances[v].
             varnotedisp), value(max_length)
            SET stat = alterlist(print->phases[i].interventions[x].results[y].variances[v].notewrap,
             pt->line_cnt)
            SET print->phases[i].interventions[x].results[y].variances[v].notewrapcnt = pt->line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].interventions[x].results[y].variances[v].notewrap[z].line = pt->
              lns[z].line
            ENDFOR
           ENDIF
           SET max_length = 40
           IF ((print->phases[i].interventions[x].results[y].variances[v].varchartdisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].interventions[x].results[y].variances[v].
             varchartdisp), value(max_length)
            SET stat = alterlist(print->phases[i].interventions[x].results[y].variances[v].
             varchartwrap,pt->line_cnt)
            SET print->phases[i].interventions[x].results[y].variances[v].varchartcnt = pt->line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].interventions[x].results[y].variances[v].varchartwrap[z].line = pt
              ->lns[z].line
            ENDFOR
           ENDIF
           SET max_length = 40
           IF ((print->phases[i].interventions[x].results[y].variances[v].varunchartdisp > " "))
            SET pt->line_cnt = 0
            EXECUTE dcp_parse_text value(print->phases[i].interventions[x].results[y].variances[v].
             varunchartdisp), value(max_length)
            SET stat = alterlist(print->phases[i].interventions[x].results[y].variances[v].
             varunchartwrap,pt->line_cnt)
            SET print->phases[i].interventions[x].results[y].variances[v].varunchartcnt = pt->
            line_cnt
            FOR (z = 1 TO pt->line_cnt)
              SET print->phases[i].interventions[x].results[y].variances[v].varunchartwrap[z].line =
              pt->lns[z].line
            ENDFOR
           ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   IF (debug=1)
    CALL echorecord(print)
   ENDIF
 END ;Subroutine
 SUBROUTINE getformattedtime(date_time,time_zone)
   IF (curutc)
    SET stime = concat(trim(datetimezoneformat(date_time,time_zone,"@SHORTDATE"))," ",trim(
      datetimezoneformat(date_time,time_zone,"@TIMENOSECONDS")),trim(datetimezoneformat(date_time,
       time_zone," ZZZ")))
   ELSE
    SET stime = concat(format(cnvtdatetime(date_time),"@SHORTDATE")," ",format(cnvtdatetime(date_time
       ),"@TIMENOSECONDS"))
   ENDIF
 END ;Subroutine
 SUBROUTINE gettimeformatted(date_time,time_zone)
  CALL getformattedtime(date_time,time_zone)
  RETURN(stime)
 END ;Subroutine
 SUBROUTINE loadcomponent(dataphaseidx,datacompidx,printphaseidx,printoutidx,printintidx)
   IF (dataphaseidx > 0
    AND datacompidx > 0
    AND printphaseidx > 0
    AND (data->phases[dataphaseidx].comps[datacompidx].outcome_valid_flag=1))
    IF ((data->phases[dataphaseidx].comps[datacompidx].sort_idx=0))
     CALL loadoutcome(dataphaseidx,datacompidx,printphaseidx,printoutidx)
    ELSE
     CALL loadintervention(dataphaseidx,datacompidx,printphaseidx,printintidx)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE loadoutcome(dataphaseidx,datacompidx,printphaseidx,printoutidx)
   SET lidx = 0
   SET ridx = 0
   SET vidx = 0
   SET rvidx = 0
   SET datalabelcnt = 0
   SET dataresultcnt = 0
   SET datavariancetcnt = 0
   SET compnomenstringflag = 2
   SET resnomenstringflag = 2
   SET cedynamiclabelid = 0.0
   SET tempdttmdisp = ""
   SET temptz = 0
   SET variance = 0
   DECLARE svalue = vc WITH protect
   SET datalabelcnt = size(data->phases[dataphaseidx].comps[datacompidx].labels,5)
   FOR (lidx = 1 TO datalabelcnt)
     SET variance = 0
     SET printoutidx = (printoutidx+ 1)
     IF (printoutidx > size(print->phases[printphaseidx].outcomes,5))
      SET stat = alterlist(print->phases[printphaseidx].outcomes,(printoutidx+ 10))
     ENDIF
     SET cedynamiclabelid = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].
     ce_dynamic_label_id
     SET labelname = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].label_name
     SET sdisplay = trim(data->phases[dataphaseidx].comps[datacompidx].outcome_description)
     IF (cedynamiclabelid > 0.0
      AND labelname != sdisplay)
      SET sdisplay = concat(sdisplay," (",labelname,")")
     ENDIF
     SET sdisplay = concat(sdisplay," - ",data->phases[dataphaseidx].comps[datacompidx].
      outcome_expectation)
     SET print->phases[printphaseidx].outcomes[printoutidx].display = sdisplay
     SET dataresultcnt = size(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results,5)
     SET stat = alterlist(print->phases[printphaseidx].outcomes[printoutidx].results,dataresultcnt)
     FOR (ridx = 1 TO dataresultcnt)
       SET sresultvalue = trim(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[
        ridx].result_val)
       SET sresultunits = trim(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[
        ridx].result_units_disp)
       SET compnomenstringflag = data->phases[dataphaseidx].comps[datacompidx].nomen_string_flag
       SET resnomenstringflag = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[
       ridx].nomen_string_flag
       SET spreferreddisp = trim(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[
        ridx].preferred_nomen_disp)
       SET svalue = sresultvalue
       IF (sresultunits > " ")
        SET svalue = concat(sresultvalue,sresultunits)
       ENDIF
       IF (compnomenstringflag != resnomenstringflag
        AND sresultvalue != spreferreddisp
        AND spreferreddisp > " ")
        SET svalue = concat(svalue," (",spreferreddisp,")")
       ENDIF
       SET print->phases[printphaseidx].outcomes[printoutidx].results[ridx].value = svalue
       SET print->phases[printphaseidx].outcomes[printoutidx].results[ridx].met_ind = data->phases[
       dataphaseidx].comps[datacompidx].labels[lidx].results[ridx].met_ind
       SET tempdttm = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[ridx].
       perform_dt_tm
       SET temptz = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[ridx].
       perform_tz
       CALL getformattedtime(tempdttm,temptz)
       SET print->phases[printphaseidx].outcomes[printoutidx].results[ridx].charteddisp = concat(
        captions->scharted," ",captions->son," ",trim(stime),
        " ",captions->sby," ",trim(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].
         results[ridx].perform_prsnl_name))
       SET datavariancetcnt = size(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].
        results[ridx].variances,5)
       SET stat = alterlist(print->phases[printphaseidx].outcomes[printoutidx].results[ridx].
        variances,datavariancetcnt)
       FOR (rvidx = 1 TO datavariancetcnt)
         SET sreasondisp = fillstring(1000," ")
         SET sactiondisp = fillstring(1000," ")
         SET vidx = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[ridx].
         variances[rvidx].variance_idx
         IF ((data->variances[vidx].reason_cd > 0.0))
          SET variance = 1
          SET sreasondisp = trim(uar_get_code_display(data->variances[vidx].reason_cd))
         ENDIF
         IF ((data->variances[vidx].reason_text > " "))
          SET variance = 1
          IF (sreasondisp > " ")
           SET sreasondisp = concat(trim(sreasondisp)," - ",trim(data->variances[vidx].reason_text))
          ELSE
           SET sreasondisp = trim(data->variances[vidx].reason_text)
          ENDIF
         ENDIF
         IF (sreasondisp > " ")
          SET print->phases[printphaseidx].outcomes[printoutidx].results[ridx].variances[rvidx].
          varreasondisp = sreasondisp
         ENDIF
         IF ((data->variances[vidx].action_cd > 0.0))
          SET variance = 1
          SET sactiondisp = trim(uar_get_code_display(data->variances[vidx].action_cd))
         ENDIF
         IF ((data->variances[vidx].action_text > " "))
          SET variance = 1
          IF (sactiondisp > " ")
           SET sactiondisp = concat(trim(sactiondisp)," - ",trim(data->variances[vidx].action_text))
          ELSE
           SET sactiondisp = trim(data->variances[vidx].action_text)
          ENDIF
         ENDIF
         IF (sactiondisp > " ")
          SET print->phases[printphaseidx].outcomes[printoutidx].results[ridx].variances[rvidx].
          varactiondisp = sactiondisp
         ENDIF
         IF ((data->variances[vidx].note_text > " "))
          SET variance = 1
          SET print->phases[printphaseidx].outcomes[printoutidx].results[ridx].variances[rvidx].
          varnotedisp = trim(data->variances[vidx].note_text)
         ENDIF
         IF (variance=1)
          IF ((data->variances[vidx].chart_dt_tm != null))
           CALL getformattedtime(data->variances[vidx].chart_dt_tm,data->variances[vidx].chart_tz)
           SET print->phases[printphaseidx].outcomes[printoutidx].results[ridx].variances[rvidx].
           varchartdisp = concat(captions->scharted," ",captions->son," ",trim(stime),
            " ",captions->sby," ",trim(data->variances[vidx].chart_prsnl_name))
          ENDIF
          IF ((data->variances[vidx].unchart_dt_tm != null))
           CALL getformattedtime(data->variances[vidx].unchart_dt_tm,data->variances[vidx].unchart_tz
            )
           SET print->phases[printphaseidx].outcomes[printoutidx].results[ridx].variances[rvidx].
           varunchartdisp = concat(captions->suncharted," ",captions->son," ",trim(stime),
            " ",captions->sby," ",trim(data->variances[vidx].unchart_prsnl_name))
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadintervention(dataphaseidx,datacompidx,printphaseidx,printintidx)
   SET lidx = 0
   SET ridx = 0
   SET vidx = 0
   SET rvidx = 0
   SET datalabelcnt = 0
   SET dataresultcnt = 0
   SET datavariancetcnt = 0
   SET compnomenstringflag = 2
   SET resnomenstringflag = 2
   SET cedynamiclabelid = 0.0
   SET tempdttmdisp = ""
   SET temptz = 0
   SET variance = 0
   DECLARE svalue = vc WITH protect
   SET datalabelcnt = size(data->phases[dataphaseidx].comps[datacompidx].labels,5)
   FOR (lidx = 1 TO datalabelcnt)
     SET variance = 0
     SET printintidx = (printintidx+ 1)
     IF (printintidx > size(print->phases[printphaseidx].interventions,5))
      SET stat = alterlist(print->phases[printphaseidx].interventions,(printintidx+ 10))
     ENDIF
     SET cedynamiclabelid = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].
     ce_dynamic_label_id
     SET labelname = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].label_name
     SET sdisplay = data->phases[dataphaseidx].comps[datacompidx].outcome_description
     IF (cedynamiclabelid > 0.0
      AND labelname > " ")
      SET sdisplay = concat(sdisplay," (",labelname,")")
     ENDIF
     SET sdisplay = concat(sdisplay," - ",data->phases[dataphaseidx].comps[datacompidx].
      outcome_expectation)
     SET print->phases[printphaseidx].interventions[printintidx].display = sdisplay
     SET dataresultcnt = size(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results,5)
     SET stat = alterlist(print->phases[printphaseidx].interventions[printintidx].results,
      dataresultcnt)
     FOR (ridx = 1 TO dataresultcnt)
       SET sresultvalue = trim(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[
        ridx].result_val)
       SET sresultunits = trim(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[
        ridx].result_units_disp)
       SET compnomenstringflag = data->phases[dataphaseidx].comps[datacompidx].nomen_string_flag
       SET resnomenstringflag = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[
       ridx].nomen_string_flag
       SET spreferreddisp = trim(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[
        ridx].preferred_nomen_disp)
       SET svalue = sresultvalue
       IF (sresultunits > " ")
        SET svalue = concat(sresultvalue,sresultunits)
       ENDIF
       IF (compnomenstringflag != resnomenstringflag
        AND sresultvalue != spreferreddisp
        AND spreferreddisp > " ")
        SET svalue = concat(svalue," (",spreferreddisp,")")
       ENDIF
       SET print->phases[printphaseidx].interventions[printintidx].results[ridx].value = svalue
       SET print->phases[printphaseidx].interventions[printintidx].results[ridx].met_ind = data->
       phases[dataphaseidx].comps[datacompidx].labels[lidx].results[ridx].met_ind
       SET tempdttm = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[ridx].
       perform_dt_tm
       SET temptz = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[ridx].
       perform_tz
       CALL getformattedtime(tempdttm,temptz)
       SET print->phases[printphaseidx].interventions[printintidx].results[ridx].charteddisp = concat
       (captions->scharted," ",captions->son," ",trim(stime),
        " ",captions->sby," ",trim(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].
         results[ridx].perform_prsnl_name))
       SET datavariancetcnt = size(data->phases[dataphaseidx].comps[datacompidx].labels[lidx].
        results[ridx].variances,5)
       SET stat = alterlist(print->phases[printphaseidx].interventions[printintidx].results[ridx].
        variances,datavariancetcnt)
       FOR (rvidx = 1 TO datavariancetcnt)
         SET sreasondisp = fillstring(1000," ")
         SET sactiondisp = fillstring(1000," ")
         SET vidx = data->phases[dataphaseidx].comps[datacompidx].labels[lidx].results[ridx].
         variances[rvidx].variance_idx
         IF ((data->variances[vidx].reason_cd > 0.0))
          SET variance = 1
          SET sreasondisp = trim(uar_get_code_display(data->variances[vidx].reason_cd))
         ENDIF
         IF ((data->variances[vidx].reason_text > " "))
          SET variance = 1
          IF (sreasondisp > " ")
           SET sreasondisp = concat(trim(sreasondisp)," - ",trim(data->variances[vidx].reason_text))
          ELSE
           SET sreasondisp = trim(data->variances[vidx].reason_text)
          ENDIF
         ENDIF
         IF (sreasondisp > " ")
          SET print->phases[printphaseidx].interventions[printintidx].results[ridx].variances[rvidx].
          varreasondisp = sreasondisp
         ENDIF
         IF ((data->variances[vidx].action_cd > 0.0))
          SET variance = 1
          SET sactiondisp = trim(uar_get_code_display(data->variances[vidx].action_cd))
         ENDIF
         IF ((data->variances[vidx].action_text > " "))
          SET variance = 1
          IF (sactiondisp > " ")
           SET sactiondisp = concat(trim(sactiondisp)," - ",trim(data->variances[vidx].action_text))
          ELSE
           SET sactiondisp = trim(data->variances[vidx].action_text)
          ENDIF
         ENDIF
         IF (sactiondisp > " ")
          SET print->phases[printphaseidx].interventions[printintidx].results[ridx].variances[rvidx].
          varactiondisp = sactiondisp
         ENDIF
         IF ((data->variances[vidx].note_text > " "))
          SET variance = 1
          SET print->phases[printphaseidx].interventions[printintidx].results[ridx].variances[rvidx].
          varnotedisp = trim(data->variances[vidx].note_text)
         ENDIF
         IF (variance=1)
          IF ((data->variances[vidx].chart_dt_tm != null))
           CALL getformattedtime(data->variances[vidx].chart_dt_tm,data->variances[vidx].chart_tz)
           SET print->phases[printphaseidx].interventions[printintidx].results[ridx].variances[rvidx]
           .varchartdisp = concat(captions->scharted," ",captions->son," ",trim(stime),
            " ",captions->sby," ",trim(data->variances[vidx].chart_prsnl_name))
          ENDIF
          IF ((data->variances[vidx].unchart_dt_tm != null))
           CALL getformattedtime(data->variances[vidx].unchart_dt_tm,data->variances[vidx].unchart_tz
            )
           SET print->phases[printphaseidx].interventions[printintidx].results[ridx].variances[rvidx]
           .varunchartdisp = concat(captions->suncharted," ",captions->son," ",trim(stime),
            " ",captions->sby," ",trim(data->variances[vidx].unchart_prsnl_name))
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE formatreport(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = 1)
   PLAN (d1)
   HEAD REPORT
    dummy = 0
   DETAIL
    phasecnt = size(print->phases,5)
    FOR (i = 1 TO phasecnt)
      wrapcnt = maxval(print->phases[i].wrapcnt,(print->phases[i].initwrapcnt+ print->phases[i].
       stopwrapcnt))
      FOR (j = 1 TO wrapcnt)
       IF ((print->phases[i].wrapcnt >= j))
        col 0, print->phases[i].wrap[j].line
       ENDIF
       ,row + 1
      ENDFOR
      actioncnt = size(print->phases[i].plan_actions,5)
      FOR (k_iterator = 1 TO actioncnt)
       wrapcnt = size(print->phases[i].plan_actions[k_iterator].planwrap,5),
       FOR (j = 1 TO wrapcnt)
         IF ((print->phases[i].plan_actions[k_iterator].planduplicatemodify=0))
          col 70, print->phases[i].plan_actions[k_iterator].planwrap[j].line, row + 1
         ENDIF
       ENDFOR
      ENDFOR
      outcomecnt = size(print->phases[i].outcomes,5)
      IF (outcomecnt > 0)
       col 3, captions->soutcomes, row + 1
       FOR (j = 1 TO outcomecnt)
         FOR (k = 1 TO print->phases[i].outcomes[j].wrapcnt)
           col 5, print->phases[i].outcomes[j].wrap[k].line, row + 1
         ENDFOR
         rescnt = size(print->phases[i].outcomes[j].results,5)
         FOR (k = 1 TO rescnt)
           reswrapcnt = maxval(print->phases[i].outcomes[j].results[k].valuewrapcnt,print->phases[i].
            outcomes[j].results[k].chartedwrapcnt)
           FOR (l = 1 TO reswrapcnt)
             IF ((l <= print->phases[i].outcomes[j].results[k].valuewrapcnt))
              col 7, print->phases[i].outcomes[j].results[k].valuewrap[l].line
             ENDIF
             IF ((l <= print->phases[i].outcomes[j].results[k].chartedwrapcnt))
              col 70, print->phases[i].outcomes[j].results[k].chartedwrap[l].line
             ENDIF
             row + 1
           ENDFOR
           varcnt = size(print->phases[i].outcomes[j].results[k].variances,5)
           FOR (v = 1 TO varcnt)
             varcharteddisp = 0
             IF ((((print->phases[i].outcomes[j].results[k].variances[v].reasonwrapcnt > 0)) OR ((
             print->phases[i].outcomes[j].results[k].variances[v].actionwrapcnt > 0))) )
              reasonwrapcnt = print->phases[i].outcomes[j].results[k].variances[v].reasonwrapcnt,
              actionwrapcnt = print->phases[i].outcomes[j].results[k].variances[v].actionwrapcnt,
              varchartcnt = print->phases[i].outcomes[j].results[k].variances[v].varchartcnt,
              varunchartcnt = print->phases[i].outcomes[j].results[k].variances[v].varunchartcnt,
              wrapcnt = maxval((reasonwrapcnt+ actionwrapcnt),(varchartcnt+ varunchartcnt))
              FOR (l = 1 TO wrapcnt)
                IF (l <= reasonwrapcnt)
                 col 10, print->phases[i].outcomes[j].results[k].variances[v].reasonwrap[l].line
                ENDIF
                IF (l > reasonwrapcnt
                 AND (l <= (reasonwrapcnt+ actionwrapcnt)))
                 idx1 = (l - reasonwrapcnt), col 10, print->phases[i].outcomes[j].results[k].
                 variances[v].actionwrap[idx1].line
                ENDIF
                IF (l <= varunchartcnt)
                 col 70, print->phases[i].outcomes[j].results[k].variances[v].varunchartwrap[l].line
                ENDIF
                IF (l > varunchartcnt
                 AND (l <= (varchartcnt+ varunchartcnt)))
                 idx2 = (l - varunchartcnt), col 70, print->phases[i].outcomes[j].results[k].
                 variances[v].varchartwrap[idx2].line
                ENDIF
                row + 1
              ENDFOR
             ENDIF
             IF ((print->phases[i].outcomes[j].results[k].variances[v].notewrapcnt > 0))
              notewrapcnt = print->phases[i].outcomes[j].results[k].variances[v].notewrapcnt,
              varchartcnt = print->phases[i].outcomes[j].results[k].variances[v].varchartcnt,
              varunchartcnt = print->phases[i].outcomes[j].results[k].variances[v].varunchartcnt,
              wrapcnt = maxval(notewrapcnt,(varchartcnt+ varunchartcnt))
              FOR (l = 1 TO wrapcnt)
                IF (l <= notewrapcnt)
                 col 10, print->phases[i].outcomes[j].results[k].variances[v].notewrap[l].line
                ENDIF
                IF (l <= varunchartcnt)
                 col 70, print->phases[i].outcomes[j].results[k].variances[v].varunchartwrap[l].line
                ENDIF
                IF (l > varunchartcnt
                 AND (l <= (varchartcnt+ varunchartcnt)))
                 idx = (l - varunchartcnt), col 70, print->phases[i].outcomes[j].results[k].
                 variances[v].varchartwrap[idx].line
                ENDIF
                row + 1
              ENDFOR
             ENDIF
           ENDFOR
         ENDFOR
       ENDFOR
      ENDIF
      interventioncnt = size(print->phases[i].interventions,5)
      IF (interventioncnt > 0)
       col 3, captions->sinterventions, row + 1
       FOR (j = 1 TO interventioncnt)
         FOR (k = 1 TO print->phases[i].interventions[j].wrapcnt)
           col 5, print->phases[i].interventions[j].wrap[k].line, row + 1
         ENDFOR
         rescnt = size(print->phases[i].interventions[j].results,5)
         FOR (k = 1 TO rescnt)
           reswrapcnt = maxval(print->phases[i].interventions[j].results[k].valuewrapcnt,print->
            phases[i].interventions[j].results[k].chartedwrapcnt)
           FOR (l = 1 TO reswrapcnt)
             IF ((l <= print->phases[i].interventions[j].results[k].valuewrapcnt))
              col 7, print->phases[i].interventions[j].results[k].valuewrap[l].line
             ENDIF
             IF ((l <= print->phases[i].interventions[j].results[k].chartedwrapcnt))
              col 70, print->phases[i].interventions[j].results[k].chartedwrap[l].line
             ENDIF
             row + 1
           ENDFOR
           varcnt = size(print->phases[i].interventions[j].results[k].variances,5)
           FOR (v = 1 TO varcnt)
            IF ((((print->phases[i].interventions[j].results[k].variances[v].reasonwrapcnt > 0)) OR (
            (print->phases[i].interventions[j].results[k].variances[v].actionwrapcnt > 0))) )
             reasonwrapcnt = print->phases[i].interventions[j].results[k].variances[v].reasonwrapcnt,
             actionwrapcnt = print->phases[i].interventions[j].results[k].variances[v].actionwrapcnt,
             varchartcnt = print->phases[i].interventions[j].results[k].variances[v].varchartcnt,
             varunchartcnt = print->phases[i].interventions[j].results[k].variances[v].varunchartcnt,
             wrapcnt = maxval((reasonwrapcnt+ actionwrapcnt),(varchartcnt+ varunchartcnt))
             FOR (l = 1 TO wrapcnt)
               IF (l <= reasonwrapcnt)
                col 10, print->phases[i].interventions[j].results[k].variances[v].reasonwrap[l].line
               ENDIF
               IF (l > reasonwrapcnt
                AND (l <= (reasonwrapcnt+ actionwrapcnt)))
                idx1 = (l - reasonwrapcnt), col 10, print->phases[i].interventions[j].results[k].
                variances[v].actionwrap[idx1].line
               ENDIF
               IF (l <= varunchartcnt)
                col 70, print->phases[i].interventions[j].results[k].variances[v].varunchartwrap[l].
                line
               ENDIF
               IF (l > varunchartcnt
                AND (l <= (varchartcnt+ varunchartcnt)))
                idx2 = (l - varunchartcnt), col 70, print->phases[i].interventions[j].results[k].
                variances[v].varchartwrap[idx2].line
               ENDIF
               row + 1
             ENDFOR
            ENDIF
            ,
            IF ((print->phases[i].interventions[j].results[k].variances[v].notewrapcnt > 0))
             notewrapcnt = print->phases[i].interventions[j].results[k].variances[v].notewrapcnt,
             varchartcnt = print->phases[i].interventions[j].results[k].variances[v].varchartcnt,
             varunchartcnt = print->phases[i].interventions[j].results[k].variances[v].varunchartcnt,
             wrapcnt = maxval(notewrapcnt,(varchartcnt+ varunchartcnt))
             FOR (l = 1 TO wrapcnt)
               IF (l <= notewrapcnt)
                col 10, print->phases[i].interventions[j].results[k].variances[v].notewrap[l].line
               ENDIF
               IF (l <= varunchartcnt)
                col 70, print->phases[i].interventions[j].results[k].variances[v].varunchartwrap[l].
                line
               ENDIF
               IF (l > varunchartcnt
                AND (l <= (varchartcnt+ varunchartcnt)))
                idx = (l - varunchartcnt), col 70, print->phases[i].interventions[j].results[k].
                variances[v].varchartwrap[idx].line
               ENDIF
               row + 1
             ENDFOR
            ENDIF
           ENDFOR
         ENDFOR
       ENDFOR
      ENDIF
      row + 2
    ENDFOR
   FOOT PAGE
    numrows = row, stat = alterlist(reply->qual,((ln+ numrows)+ 1))
    FOR (pagevar = 0 TO numrows)
      ln = (ln+ 1), reply->qual[ln].line = reportrow((pagevar+ 1)), done = "F"
      WHILE (done="F")
       nullpos = findstring(char(0),reply->qual[ln].line),
       IF (nullpos > 0)
        stat = movestring(" ",1,reply->qual[ln].line,nullpos,1)
       ELSE
        done = "T"
       ENDIF
      ENDWHILE
    ENDFOR
    reply->num_lines = ln
   WITH nocounter, maxcol = 132, maxrow = 10000
  ;end select
  FREE RECORD print
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  IF (cnodata="Y")
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
END GO
