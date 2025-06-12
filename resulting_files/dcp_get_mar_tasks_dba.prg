CREATE PROGRAM dcp_get_mar_tasks:dba
 SET modify = predeclare
 RECORD reply(
   1 overdue_tasks_exist = i2
   1 earliest_overdue_task_dt_tm = dq8
   1 earliest_overdue_task_tz = i4
   1 orders[*]
     2 order_id = f8
     2 task_cnt = i4
     2 co_cnt = i4
     2 tasks[*]
       3 task_id = f8
       3 reference_task_id = f8
       3 order_id = f8
       3 task_status_cd = f8
       3 task_status_disp = vc
       3 task_status_mean = vc
       3 task_class_cd = f8
       3 task_class_disp = vc
       3 task_class_mean = vc
       3 task_activity_cd = f8
       3 task_activity_disp = vc
       3 task_activity_mean = vc
       3 task_priority_cd = f8
       3 task_priority_disp = vc
       3 task_priority_mean = vc
       3 template_order_action_sequence = i4
       3 task_dt_tm = dq8
       3 task_tz = i4
       3 event_id = f8
       3 careset_id = f8
       3 iv_ind = i2
       3 tpn_ind = i2
       3 updt_cnt = i4
       3 last_action_sequence = i4
       3 description = vc
       3 dcp_forms_ref_id = f8
       3 event_cd = f8
       3 task_type_cd = f8
       3 task_type_disp = vc
       3 task_type_mean = vc
       3 chart_not_done_ind = i2
       3 quick_chart_ind = i2
       3 reschedule_time = i4
       3 priv_ind = i2
       3 delta_ind = i2
     2 child_orders[*]
       3 order_id = f8
       3 encntr_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 core_action_sequence = i4
       3 need_nurse_review_ind = i2
       3 med_order_type_cd = f8
       3 current_start_dt_tm = dq8
       3 current_start_tz = i4
       3 link_nbr = f8
       3 link_type_flag = i2
       3 freq_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_child_orders(
   1 orders[*]
     2 child_order_id = f8
 )
 DECLARE initialize(null) = null
 DECLARE loadtasksandchildorders(null) = null
 DECLARE loaddeltaind(null) = null
 DECLARE ipreffound = i2 WITH protect, constant(1)
 DECLARE iprefnotfound = i2 WITH protect, constant(2)
 DECLARE ipreferror = i2 WITH protect, constant(0)
 DECLARE itypestr = i2 WITH protect, constant(0)
 DECLARE itypedbl = i2 WITH protect, constant(1)
 DECLARE itypeint = i2 WITH protect, constant(2)
 FREE RECORD preference_struct
 RECORD preference_struct(
   1 prefs[*]
     2 pref_name = vc
     2 pref_name_upper = vc
     2 pref_type = i4
     2 pref_stat = i2
     2 pref_val[*]
       3 val_str = vc
       3 val_int = i4
       3 val_dbl = f8
 )
 DECLARE initalizeprefread(null) = i2
 DECLARE proccesssingleprefread(null) = i2
 DECLARE releasehandles(null) = null
 DECLARE cnvtprefnamestoupper(null) = null
 SUBROUTINE (getprefbycontextint(spreftofetch=vc,scontextstring=vc,svaluestring=vc,iretprefvalue=i4(
   ref)) =i2)
   CALL debugecho("/********Entering GetPrefByContextInt********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypeint
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      IF (validate(request->debug_ind,1))
       CALL echorecord(preference_struct)
      ENDIF
      SET iretprefvalue = preference_struct->prefs[1].pref_val[1].val_int
      CALL debugecho(build("GetPrefByContextInt returning value: ",iretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbycontextdbl(spreftofetch=vc,scontextstring=vc,svaluestring=vc,dretprefvalue=f8(
   ref)) =i2)
   CALL debugecho("/********Entering GetPrefByContextDbl********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypedbl
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      SET dretprefvalue = preference_struct->prefs[1].pref_val[1].val_dbl
      CALL debugecho(build("GetPrefByContextDbl returning value: ",dretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbycontext(spreftofetch=vc,scontextstring=vc,svaluestring=vc,sretprefvalue=vc(ref)
  ) =i2)
   CALL debugecho("/********Entering GetPrefByContext********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypestr
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      SET sretprefvalue = preference_struct->prefs[1].pref_val[1].val_str
      CALL debugecho(build("GetPrefByContext returning value: ",sretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbystruct(scontextstring=vc,svaluestring=vc) =i2)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,0)
   RETURN(iretstat)
 END ;Subroutine
 SUBROUTINE (getprefbystructsub(scontextstring=vc,svaluestring=vc,bsimplepref=i2) =i2)
   CALL debugecho("/********Entering GetPrefByContext********/")
   DECLARE ssectionname = vc WITH protect, noconstant("config")
   DECLARE sgroupname = vc WITH protect, noconstant("medication_administration")
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE idxentry = h WITH protect, noconstant(0)
   DECLARE status = i2 WITH protect, noconstant(0)
   DECLARE entrycount = h WITH protect, noconstant(0)
   DECLARE idxval = h WITH protect, noconstant(0)
   DECLARE hentry = h WITH protect, noconstant(0)
   DECLARE attrcount = h WITH protect, noconstant(0)
   DECLARE idxattr = h WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE valcount = h WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE attrname = c100
   DECLARE entryname = c100
   DECLARE namelen = h WITH noconstant(100)
   DECLARE valname = c100
   DECLARE stempstring = c20 WITH public, noconstant("")
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   CALL debugecho(build("Fetching preference at level: ",scontextstring))
   CALL debugecho(build("Fetching preference for context_id: ",svaluestring))
   CALL debugecho(build("Fetching preference from section: ",ssectionname))
   CALL debugecho(build("Fetching preference from group: ",sgroupname))
   CALL cnvtprefnamestoupper(null)
   IF (initalizeprefread(null)=ipreferror)
    CALL debugecho("Error Setting up to read Preferences")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefperform(hpref)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to perform.")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   SET iretstat = proccessprefreply(null)
   CALL releasehandles(null)
   RETURN(iretstat)
 END ;Subroutine
 SUBROUTINE releasehandles(null)
   CALL debugecho("Cleaning up...")
   IF (hattr > 0)
    CALL debugecho("Destroyed hAttr")
    SET status = uar_prefdestroyinstance(hattr)
   ENDIF
   IF (hgroup > 0)
    CALL debugecho("Destroyed hGroup")
    SET status = uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hgroup2 > 0)
    CALL debugecho("Destroyed hGroup2")
    SET status = uar_prefdestroygroup(hgroup2)
   ENDIF
   IF (hsection > 0)
    CALL debugecho("Destroyed hSection")
    SET status = uar_prefdestroysection(hsection)
   ENDIF
   IF (hpref > 0)
    CALL debugecho("Destroyed hPref")
    SET status = uar_prefdestroyinstance(hpref)
   ENDIF
   CALL debugecho("...Done Cleaning")
 END ;Subroutine
 SUBROUTINE proccesssingleprefread(null)
   CALL debugecho("Proccessing a Single Pref Value...")
   DECLARE idxsearch = i4 WITH protect, noconstant(0)
   DECLARE idxfound = i4 WITH protect, noconstant(0)
   DECLARE istat = i4 WITH protect, noconstant(0)
   DECLARE iprefvalcnt = i4 WITH protect, noconstant(0)
   DECLARE upentryname = c100 WITH protect, noconstant("")
   SET upentryname = cnvtupper(trim(entryname,3))
   SET idxfound = locateval(idxsearch,1,size(preference_struct->prefs,5),upentryname,
    preference_struct->prefs[idxsearch].pref_name_upper)
   IF (idxfound > 0)
    SET iprefvalcnt = (size(preference_struct->prefs[idxfound].pref_val,5)+ 1)
    SET istat = alterlist(preference_struct->prefs[idxfound].pref_val,iprefvalcnt)
    IF ((preference_struct->prefs[idxfound].pref_type=itypestr))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_str = valname
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_str," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSEIF ((preference_struct->prefs[idxfound].pref_type=itypedbl))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_dbl = cnvtreal(trim(valname,3))
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_dbl," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSEIF ((preference_struct->prefs[idxfound].pref_type=itypeint))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_int = cnvtint(trim(valname,3))
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_int," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSE
     SET iprefvalcnt -= 1
     SET istat = alterlist(preference_struct->prefs[idxfound].pref_val,iprefvalcnt)
     CALL debugecho("...Unknown Pref Type")
     RETURN(iprefnotfound)
    ENDIF
    CALL debugecho("...Pref Found And Added")
    RETURN(ipreffound)
   ENDIF
   CALL debugecho("... Pref not matched")
   RETURN(iprefnotfound)
 END ;Subroutine
 SUBROUTINE initalizeprefread(null)
   CALL debugecho("Initalizing for pref read...")
   DECLARE idxit = i4 WITH protect, noconstant(0)
   FOR (idxit = 1 TO size(preference_struct->prefs,5))
    SET preference_struct->prefs[idxit].pref_stat = iprefnotfound
    SET istat = alterlist(preference_struct->prefs[idxit].pref_val,0)
   ENDFOR
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL debugecho("Error:GetPrefByContext - Invalid hPref handle. Try logging in.")
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefaddcontext(hpref,nullterm(scontextstring),nullterm(svaluestring))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to add context: ",stempcontlvl))
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefsetsection(hpref,nullterm(ssectionname))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to set",ssectionname," section."))
    RETURN(ipreferror)
   ENDIF
   SET hgroup = uar_prefcreategroup()
   IF (hgroup=0)
    CALL debugecho("Error:GetPrefByContext - Failed to create group.")
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefsetgroupname(hgroup,nullterm(sgroupname))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to set ",sgroupname," group."))
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefaddgroup(hpref,hgroup)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to add group.")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   CALL debugecho("...Initalize Complete")
   RETURN(iprefnotfound)
 END ;Subroutine
 SUBROUTINE proccessprefreply(null)
   CALL debugecho("Processing returned prefrences...")
   DECLARE iprefsubstatus = i4 WITH protect, noconstant(0)
   DECLARE batleastonepreffound = i2 WITH protect, noconstant(0)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm(ssectionname))
   IF (hsection=0)
    CALL debugecho(build("Error:GetPrefByContext - Failed to get",ssectionname," section."))
    RETURN(ipreferror)
   ENDIF
   SET hgroup2 = uar_prefgetgroupbyname(hsection,nullterm(sgroupname))
   IF (hgroup2=0)
    CALL echo(build("Error:GetPrefByContext - Failed to get ",sgroupname," group."))
    RETURN(ipreferror)
   ENDIF
   SET entrycount = 0
   SET status = uar_prefgetgroupentrycount(hgroup2,entrycount)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to get number of entry count.")
    RETURN(ipreferror)
   ENDIF
   FOR (idxentry = 0 TO (entrycount - 1))
     SET entryname = ""
     SET namelen = 100
     SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
     SET status = uar_prefgetentryname(hentry,entryname,namelen)
     CALL debugecho("Entry Found")
     CALL debugecho(build("entryName: ",entryname,"|<END"))
     SET attrcount = 0
     SET status = uar_prefgetentryattrcount(hentry,attrcount)
     IF (status != 1)
      CALL debugecho("GetPrefByContext - Invalid entryAttrCount.")
     ELSE
      FOR (idxattr = 0 TO (attrcount - 1))
        SET attrname = ""
        SET namelen = 100
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        SET status = uar_prefgetattrname(hattr,attrname,namelen)
        CALL debugecho("Attribute Found")
        CALL debugecho(build("attrName: ",attrname,"|<END"))
        SET valcount = 0
        SET status = uar_prefgetattrvalcount(hattr,valcount)
        FOR (idxval = 0 TO (valcount - 1))
          SET valname = ""
          SET namelen = 100
          SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
          CALL debugecho("Preference Found")
          CALL debugecho(build("valName: ",valname,"|<END"))
          SET iprefsubstatus = proccesssingleprefread(null)
          IF (iprefsubstatus=ipreferror)
           CALL debugecho("...ERROR FOUND ")
           RETURN(ipreferror)
          ELSEIF (iprefsubstatus=ipreffound)
           SET batleastonepreffound = 1
           IF (bsimplepref)
            CALL debugecho("...Simple Pref Found, Return")
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   IF (batleastonepreffound=1)
    CALL debugecho(build("Matching Prefs Found"))
    CALL debugecho("...Processing Complete")
    RETURN(ipreffound)
   ELSE
    CALL debugecho(build("No Matching Preference found."))
    CALL debugecho("...Processing Complete")
    RETURN(iprefnotfound)
   ENDIF
 END ;Subroutine
 SUBROUTINE (debugecho(sprint=vc) =null)
   IF (validate(request->debug_ind,1))
    CALL echo(sprint)
   ENDIF
 END ;Subroutine
 SUBROUTINE cnvtprefnamestoupper(null)
   CALL debugecho("Capitalize all requested pref names...")
   DECLARE idxpref = i4 WITH protect, noconstant(0)
   FOR (idxpref = 1 TO size(preference_struct->prefs,5))
     SET preference_struct->prefs[idxpref].pref_name_upper = cnvtupper(trim(preference_struct->prefs[
       idxpref].pref_name,3))
   ENDFOR
   CALL debugecho("...Done capitalizing")
 END ;Subroutine
 DECLARE pref_infusion_billing_task = vc WITH protect, constant("INFUSION_BILLING_TASK")
 DECLARE totaltime = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE userpositioncd = f8 WITH constant(reqinfo->position_cd)
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE encntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE search_from_dt_tm = dq8 WITH protect, noconstant
 DECLARE search_to_dt_tm = dq8 WITH protect, noconstant
 DECLARE overdue_lookback_dt_tm = dq8 WITH protect, noconstant
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE dibtaskprefval = f8 WITH protect, noconstant(0)
 DECLARE ssystem = c6 WITH protect, noconstant("system")
 CALL initialize(null)
 CALL loadtasksandchildorders(null)
 CALL loaddeltaind(null)
 IF (debug_ind=1)
  CALL echo("****************************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(sysdate),totaltime,5)))
  CALL echo("****************************************")
  CALL echorecord(reply)
 ENDIF
 IF (size(reply->orders,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",error_msg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
 ENDIF
 SUBROUTINE initialize(null)
   CALL echo("********Initialize********")
   DECLARE initializetime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   SET order_cnt = 0
   SET encntr_cnt = size(request->encntr_list,5)
   SET reply->status_data.status = "F"
   IF (request->debug_ind)
    SET debug_ind = request->debug_ind
   ELSE
    SET debug_ind = 0
   ENDIF
   SET reply->overdue_tasks_exist = 0
   SET reply->earliest_overdue_task_dt_tm = cnvtdatetime(sysdate)
   SET reply->earliest_overdue_task_tz = 0
   SET search_from_dt_tm = cnvtdatetime(request->start_dt_tm)
   SET search_to_dt_tm = cnvtdatetime(request->end_dt_tm)
   IF ((request->overdue_look_back > 0))
    SET search_from_dt_tm = cnvtdatetime((curdate - request->overdue_look_back),curtime)
    SET overdue_lookback_dt_tm = search_from_dt_tm
    IF (cnvtdatetime(search_from_dt_tm) > cnvtdatetime(request->start_dt_tm))
     SET search_from_dt_tm = cnvtdatetime(request->start_dt_tm)
    ENDIF
    IF (cnvtdatetime(sysdate) > cnvtdatetime(request->end_dt_tm))
     SET search_to_dt_tm = cnvtdatetime(sysdate)
    ENDIF
   ENDIF
   IF (getprefbycontextdbl(pref_infusion_billing_task,"default",ssystem,dibtaskprefval) != ipreffound
   )
    CALL endexecution(0,"Initialize","Failed to get preference.")
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("********Initialize Time = ",datetimediff(cnvtdatetime(sysdate),initializetime,5)
      ))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadtasksandchildorders(null)
   CALL echo("********LoadTasksAndChildOrders********")
   DECLARE loadtasksandchildorderstime = f8 WITH noconstant(cnvtdatetime(sysdate))
   DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE overdue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
   DECLARE inprocess_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"INPROCESS"))
   DECLARE validation_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"VALIDATION"))
   DECLARE prn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"PRN"))
   DECLARE continuous_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"CONT"))
   DECLARE nonsched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"NSCH"))
   DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
   DECLARE person_clause = vc WITH protect, noconstant(fillstring(100," "))
   DECLARE itaskcount = i4 WITH protect, noconstant(0)
   DECLARE ichildordercount = i4 WITH protect, noconstant(0)
   DECLARE itotalchildordercount = i4 WITH protect, noconstant(0)
   DECLARE oit = i4 WITH protect, noconstant(0)
   DECLARE coit = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   RECORD tasktemp(
     1 cnt = i4
     1 qual[*]
       2 reference_task_id = f8
       2 item_cnt = i4
       2 items[*]
         3 order_index = i4
         3 task_index = i4
   )
   IF (encntr_cnt > 0)
    SET person_clause = "expand (x, 1, encntr_cnt, ta.encntr_id, request->encntr_list[x].encntr_id)"
   ELSE
    SET person_clause = "ta.person_id = request->person_id"
   ENDIF
   SELECT INTO "nl:"
    FROM task_activity ta,
     orders o,
     order_task ot
    PLAN (ta
     WHERE parser(person_clause)
      AND ta.task_status_cd IN (pending_cd, overdue_cd, inprocess_cd, validation_cd)
      AND ((ta.task_class_cd IN (prn_cd, continuous_cd, nonsched_cd)) OR (ta.task_dt_tm >=
     cnvtdatetime(search_from_dt_tm)
      AND ta.task_dt_tm <= cnvtdatetime(search_to_dt_tm)))
      AND ta.reference_task_id != dibtaskprefval)
     JOIN (o
     WHERE o.order_id=ta.order_id
      AND o.catalog_type_cd=pharmacy_cd
      AND o.orig_ord_as_flag IN (0, 5))
     JOIN (ot
     WHERE ta.reference_task_id=ot.reference_task_id)
    ORDER BY o.template_order_id, o.order_id
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadTasksAndChildOrders Query Time = ",datetimediff(cnvtdatetime(
         sysdate),loadtasksandchildorderstime,5)))
     ENDIF
     order_cnt = 0
    HEAD ta.task_id
     IF ((request->overdue_look_back > 0)
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=overdue_cd
      AND ta.task_dt_tm >= cnvtdatetime(overdue_lookback_dt_tm)
      AND ta.task_dt_tm <= cnvtdatetime(reply->earliest_overdue_task_dt_tm))
      reply->overdue_tasks_exist = 1, reply->earliest_overdue_task_dt_tm = ta.task_dt_tm, reply->
      earliest_overdue_task_tz = ta.task_tz
     ENDIF
     IF (((ta.task_class_cd IN (prn_cd, continuous_cd, nonsched_cd)) OR (ta.task_dt_tm >=
     cnvtdatetime(request->start_dt_tm)
      AND ta.task_dt_tm <= cnvtdatetime(request->end_dt_tm))) )
      IF (o.template_order_id > 0)
       oidx = locateval(oit,1,order_cnt,o.template_order_id,reply->orders[oit].order_id)
      ELSE
       oidx = locateval(oit,1,order_cnt,o.order_id,reply->orders[oit].order_id)
      ENDIF
      IF (oidx <= 0)
       order_cnt += 1, oidx = order_cnt, itaskcount = 0
       IF (mod(order_cnt,50)=1)
        stat = alterlist(reply->orders,(order_cnt+ 49))
       ENDIF
       IF (o.template_order_id > 0)
        reply->orders[oidx].order_id = o.template_order_id
       ELSE
        reply->orders[oidx].order_id = o.order_id
       ENDIF
      ELSE
       itaskcount = reply->orders[oidx].task_cnt
      ENDIF
      IF (o.template_order_id > 0)
       ichildordercount = reply->orders[oidx].co_cnt, coidx = locateval(coit,1,ichildordercount,o
        .order_id,reply->orders[oidx].child_orders[coit].order_id)
       IF (coidx <= 0)
        ichildordercount += 1, reply->orders[oidx].co_cnt = ichildordercount, coidx =
        ichildordercount
        IF (ichildordercount > size(reply->orders[oidx].child_orders,5))
         stat = alterlist(reply->orders[oidx].child_orders,(ichildordercount+ 49))
        ENDIF
        reply->orders[oidx].child_orders[coidx].order_id = o.order_id, reply->orders[oidx].
        child_orders[coidx].core_action_sequence = o.template_core_action_sequence, reply->orders[
        oidx].child_orders[coidx].current_start_dt_tm = o.current_start_dt_tm,
        reply->orders[oidx].child_orders[coidx].current_start_tz = o.current_start_tz, reply->orders[
        oidx].child_orders[coidx].need_nurse_review_ind = o.need_nurse_review_ind, reply->orders[oidx
        ].child_orders[coidx].med_order_type_cd = o.med_order_type_cd,
        reply->orders[oidx].child_orders[coidx].link_nbr = o.link_nbr, reply->orders[oidx].
        child_orders[coidx].link_type_flag = o.link_type_flag, reply->orders[oidx].child_orders[coidx
        ].freq_type_flag = o.freq_type_flag,
        reply->orders[oidx].child_orders[coidx].encntr_id = o.encntr_id, reply->orders[oidx].
        child_orders[coidx].catalog_cd = o.catalog_cd, reply->orders[oidx].child_orders[coidx].
        catalog_type_cd = o.catalog_type_cd,
        itotalchildordercount += 1
        IF (itotalchildordercount > size(temp_child_orders->orders,5))
         stat = alterlist(temp_child_orders->orders,(itotalchildordercount+ 49))
        ENDIF
        temp_child_orders->orders[itotalchildordercount].child_order_id = o.order_id
       ENDIF
      ENDIF
      itaskcount += 1, reply->orders[oidx].task_cnt = itaskcount
      IF (itaskcount > size(reply->orders[oidx].tasks,5))
       stat = alterlist(reply->orders[oidx].tasks,(itaskcount+ 49))
      ENDIF
      reply->orders[oidx].tasks[itaskcount].task_id = ta.task_id, reply->orders[oidx].tasks[
      itaskcount].order_id = ta.order_id, reply->orders[oidx].tasks[itaskcount].reference_task_id =
      ta.reference_task_id,
      reply->orders[oidx].tasks[itaskcount].task_status_cd = ta.task_status_cd, reply->orders[oidx].
      tasks[itaskcount].task_class_cd = ta.task_class_cd, reply->orders[oidx].tasks[itaskcount].
      task_activity_cd = ta.task_activity_cd,
      reply->orders[oidx].tasks[itaskcount].careset_id = ta.careset_id, reply->orders[oidx].tasks[
      itaskcount].iv_ind = ta.iv_ind, reply->orders[oidx].tasks[itaskcount].tpn_ind = ta.tpn_ind,
      reply->orders[oidx].tasks[itaskcount].dcp_forms_ref_id = ot.dcp_forms_ref_id, reply->orders[
      oidx].tasks[itaskcount].updt_cnt = ta.updt_cnt, reply->orders[oidx].tasks[itaskcount].event_id
       = ta.event_id,
      reply->orders[oidx].tasks[itaskcount].task_type_cd = ta.task_type_cd, reply->orders[oidx].
      tasks[itaskcount].description = ot.task_description, reply->orders[oidx].tasks[itaskcount].
      chart_not_done_ind = ot.chart_not_cmplt_ind,
      reply->orders[oidx].tasks[itaskcount].quick_chart_ind = ot.quick_chart_ind, reply->orders[oidx]
      .tasks[itaskcount].event_cd = ot.event_cd, reply->orders[oidx].tasks[itaskcount].
      reschedule_time = ot.reschedule_time,
      reply->orders[oidx].tasks[itaskcount].task_priority_cd = ta.task_priority_cd, reply->orders[
      oidx].tasks[itaskcount].last_action_sequence = o.last_action_sequence, reply->orders[oidx].
      tasks[itaskcount].task_dt_tm = ta.task_dt_tm,
      reply->orders[oidx].tasks[itaskcount].task_tz = ta.task_tz, reply->orders[oidx].tasks[
      itaskcount].template_order_action_sequence = o.template_core_action_sequence, reply->orders[
      oidx].tasks[itaskcount].delta_ind = 0
      IF (ta.task_class_cd IN (prn_cd, continuous_cd, nonsched_cd)
       AND ta.task_status_cd=pending_cd)
       IF (cnvtdatetime(curdate,curtime) > cnvtdatetime(ta.task_dt_tm))
        reply->orders[oidx].tasks[itaskcount].task_dt_tm = cnvtdatetime(curdate,curtime)
       ENDIF
      ENDIF
      IF (ot.allpositionchart_ind=1)
       reply->orders[oidx].tasks[itaskcount].priv_ind = 1
      ELSE
       reply->orders[oidx].tasks[itaskcount].priv_ind = 0, qidx = locateval(i,1,tasktemp->cnt,ta
        .reference_task_id,tasktemp->qual[i].reference_task_id)
       IF (qidx=0)
        tasktemp->cnt += 1
        IF (mod(tasktemp->cnt,10)=1)
         stat = alterlist(tasktemp->qual,(tasktemp->cnt+ 9))
        ENDIF
        tasktemp->qual[tasktemp->cnt].reference_task_id = ta.reference_task_id, qidx = tasktemp->cnt
       ENDIF
       tasktemp->qual[qidx].item_cnt += 1
       IF (mod(tasktemp->qual[qidx].item_cnt,10)=1)
        stat = alterlist(tasktemp->qual[qidx].items,(tasktemp->qual[qidx].item_cnt+ 9))
       ENDIF
       tasktemp->qual[qidx].items[tasktemp->qual[qidx].item_cnt].order_index = oidx, tasktemp->qual[
       qidx].items[tasktemp->qual[qidx].item_cnt].task_index = itaskcount
      ENDIF
     ENDIF
    FOOT REPORT
     IF (order_cnt > 0)
      stat = alterlist(reply->orders,order_cnt)
     ENDIF
     stat = alterlist(temp_child_orders->orders,itotalchildordercount)
    WITH nocounter
   ;end select
   FOR (k = 1 TO order_cnt)
    SET stat = alterlist(reply->orders[k].tasks,reply->orders[k].task_cnt)
    SET stat = alterlist(reply->orders[k].child_orders,reply->orders[k].co_cnt)
   ENDFOR
   IF (debug_ind=1)
    CALL echo("********Update the priv_ind for each tasks.")
   ENDIF
   IF ((tasktemp->cnt > 0))
    DECLARE nstart = i4 WITH protect, noconstant(1)
    DECLARE nsize = i4 WITH protect, constant(50)
    DECLARE iordercnt = i4 WITH protect, noconstant(size(tasktemp->qual,5))
    DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(tasktemp->cnt)/ nsize)) * nsize))
    SET stat = alterlist(tasktemp->qual,ntotal)
    FOR (i = (tasktemp->cnt+ 1) TO ntotal)
      SET tasktemp->qual[i].reference_task_id = tasktemp->qual[tasktemp->cnt].reference_task_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      order_task_position_xref otpx
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (otpx
      WHERE expand(x,nstart,(nstart+ (nsize - 1)),otpx.reference_task_id,tasktemp->qual[x].
       reference_task_id)
       AND otpx.position_cd=userpositioncd)
     DETAIL
      idx = locateval(i,1,tasktemp->cnt,otpx.reference_task_id,tasktemp->qual[i].reference_task_id)
      FOR (j = 1 TO tasktemp->qual[idx].item_cnt)
        reply->orders[tasktemp->qual[idx].items[j].order_index].tasks[tasktemp->qual[idx].items[j].
        task_index].priv_ind = 1
      ENDFOR
     WITH nocounter
    ;end select
    SET stat = alterlist(tasktemp->qual,iordercnt)
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("********LoadTasksAndChildOrders Time = ",datetimediff(cnvtdatetime(sysdate),
       loadtasksandchildorderstime,5)))
   ELSE
    FREE RECORD tasktemp
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddeltaind(null)
   CALL echo("********LoadDeltaInd ********")
   DECLARE loaddeltaindtime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE itotalchildordercount = i4 WITH protect, noconstant(size(temp_child_orders->orders,5))
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(itotalchildordercount)/ nsize)) *
    nsize))
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   IF ((request->load_delta_ind < 1))
    CALL echo("********Skipping the load of the delta_ind.")
   ELSE
    IF (debug_ind=1)
     CALL echo("********Load the delta_ind.")
     CALL echorecord(temp_child_orders)
    ENDIF
    IF (itotalchildordercount > 0)
     SET stat = alterlist(temp_child_orders->orders,ntotal)
     FOR (i = (itotalchildordercount+ 1) TO ntotal)
       SET temp_child_orders->orders[i].child_order_id = temp_child_orders->orders[
       itotalchildordercount].child_order_id
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
       orders o1,
       orders o2
      PLAN (d1
       WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
       JOIN (o1
       WHERE expand(x,nstart,(nstart+ (nsize - 1)),o1.order_id,temp_child_orders->orders[x].
        child_order_id))
       JOIN (o2
       WHERE o2.template_order_id=o1.template_order_id
        AND o2.hide_flag IN (null, 0)
        AND (o2.current_start_dt_tm=
       (SELECT
        max(o4.current_start_dt_tm)
        FROM orders o4
        WHERE o4.template_order_id=o1.template_order_id
         AND o4.hide_flag IN (null, 0)
         AND o4.current_start_dt_tm < o1.current_start_dt_tm)))
      ORDER BY o1.order_id, o2.template_core_action_sequence DESC
      HEAD o1.order_id
       IF (o1.template_core_action_sequence != o2.template_core_action_sequence)
        idx = locateval(i,1,size(reply->orders,5),o1.template_order_id,reply->orders[i].order_id)
        IF (idx > 0)
         FOR (j = 1 TO size(reply->orders[idx].tasks,5))
           IF ((reply->orders[idx].tasks[j].order_id=o1.order_id))
            reply->orders[idx].tasks[j].delta_ind = 1
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SET stat = alterlist(temp_child_orders->orders,itotalchildordercount)
    ENDIF
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("********LoadDeltaIndTime Time = ",datetimediff(cnvtdatetime(sysdate),
       loaddeltaindtime,5)))
   ELSE
    FREE RECORD temp_child_orders
   ENDIF
 END ;Subroutine
 SET last_mod = "008 02/16/2010"
 SET modify = nopredeclare
END GO
