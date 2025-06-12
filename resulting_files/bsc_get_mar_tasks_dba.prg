CREATE PROGRAM bsc_get_mar_tasks:dba
 SET modify = predeclare
 RECORD reply(
   1 overdue_tasks_exist = i2
   1 earliest_overdue_task_dt_tm = dq8
   1 earliest_overdue_task_tz = i4
   1 orders[*]
     2 order_id = f8
     2 template_order_id = f8
     2 protocol_order_id = f8
     2 task_cnt = i4
     2 co_cnt = i4
     2 last_action_sequence = i4
     2 need_rx_verify_ind = i2
     2 need_rx_clin_review_flag = i2
     2 verification_prsnl_id = f8
     2 verification_pos_cd = f8
     2 encntr_id = f8
     2 med_order_type_cd = f8
     2 med_order_type_disp = vc
     2 med_order_type_mean = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 freq_type_flag = i2
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
       3 day_of_treatment_sequence = i4
       3 future_ind = i2
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
       3 need_rx_clin_review_flag = i2
       3 need_rx_verify_ind = i2
       3 display_line = vc
       3 order_details[*]
         4 oe_field_id = f8
         4 oe_field_meaning = vc
         4 oe_field_meaning_id = f8
         4 oe_field_value = f8
         4 oe_field_display_value = vc
         4 oe_field_dt_tm = dq8
         4 oe_field_tz = i4
     2 order_actions[*]
       3 action_sequence = i4
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_type_cd = f8
       3 action_type_disp = vc
       3 action_type_mean = vc
       3 need_rx_verify_ind = i2
       3 need_rx_clin_review_flag = i2
       3 verification_prsnl_id = f8
       3 verification_pos_cd = f8
       3 prn_ind = i2
       3 constant_ind = i2
       3 core_ind = i2
       3 order_details[*]
         4 action_sequence = i4
         4 oe_field_id = f8
         4 oe_field_meaning = vc
         4 oe_field_meaning_id = f8
         4 oe_field_value = f8
         4 oe_field_display_value = vc
         4 oe_field_dt_tm = dq8
         4 oe_field_tz = i4
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
 FREE RECORD action_compare
 RECORD action_compare(
   1 qual[*]
     2 orig_struct_index = i4
     2 template_order_id = f8
     2 action_qual[2]
       3 form_cd = f8
       3 route_cd = f8
       3 needs_verify_ind = i2
       3 core_ind = i2
       3 non_diluent_count = i4
       3 ingred_list[*]
         4 catalog_cd = f8
         4 freetext_dose = vc
         4 strength = f8
         4 strength_unit_cd = f8
         4 volume = f8
         4 volume_unit_cd = f8
         4 ingredient_type = i2
 )
 FREE RECORD items_to_check
 RECORD items_to_check(
   1 check_parent_ind = i2
   1 qual[*]
     2 order_id = f8
     2 template_core_action_sequence = i4
     2 template_dose_seq = i4
     2 verify_success_ind = i2
     2 second_action_core_ind = i2
 )
 FREE RECORD future_check
 RECORD future_check(
   1 qual[*]
     2 template_order_id = f8
     2 next_due_ord_id = f8
     2 next_due_dt_tm = dq8
 )
 FREE RECORD protocol_check
 RECORD protocol_check(
   1 qual[*]
     2 protocol_order_id = f8
     2 next_due_ord_id = f8
     2 next_due_dt_tm = dq8
 )
 DECLARE detail_form_meaning_id = f8 WITH protect, constant(2014.0)
 DECLARE detail_route_meaning_id = f8 WITH protect, constant(2050.0)
 DECLARE ingredient_type_diluent = i2 WITH protect, constant(2)
 DECLARE ingredient_type_compchild = i4 WITH protect, constant(5)
 DECLARE nv_not_needed = i4 WITH protect, constant(0)
 DECLARE nv_verified = i4 WITH protect, constant(3)
 DECLARE checkactionsequencecompatibility(null) = null
 DECLARE getnextdueorderids(null) = null
 DECLARE getnextdueprotocolids(null) = null
 SUBROUTINE (comparedosefields(order_index=i4,action1_index=i4,action2_index=i4) =i2)
   DECLARE bdosemismatch = i2 WITH private, noconstant(0)
   IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength > 0))
    OR ((action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength > 0)))
   )
    IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength)) OR ((
    action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].strength_unit_cd !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].strength_unit_cd))) )
     SET bdosemismatch = 1
    ENDIF
   ELSEIF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume > 0)
   ) OR ((action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume > 0))) )
    IF ((((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume)) OR ((
    action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].volume_unit_cd !=
    action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].volume_unit_cd))) )
     SET bdosemismatch = 1
    ENDIF
   ELSE
    IF ((action_compare->qual[order_index].action_qual[1].ingred_list[action1_index].freetext_dose
     != action_compare->qual[order_index].action_qual[2].ingred_list[action2_index].freetext_dose))
     SET bdosemismatch = 1
    ENDIF
   ENDIF
   RETURN(bdosemismatch)
 END ;Subroutine
 SUBROUTINE checkactionsequencecompatibility(null)
   DECLARE ordercount = i4 WITH protect, noconstant(0)
   DECLARE actionindex = i4 WITH protect, noconstant(0)
   DECLARE ingredindex = i4 WITH protect, noconstant(0)
   DECLARE nindex = i4 WITH protect, noconstant(0)
   DECLARE bmismatch = i2 WITH protect, noconstant(0)
   DECLARE bexactmatch = i4 WITH protect, noconstant(0)
   DECLARE bfulldiluentmatchneeded = i2 WITH protect, noconstant(0)
   DECLARE catalogmatchindex = i4 WITH protect, noconstant(0)
   DECLARE ord2ingredindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(items_to_check->qual,5))),
     orders o,
     order_action oa,
     order_ingredient oi,
     order_detail od
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=items_to_check->qual[d.seq].order_id)
      AND o.dosing_method_flag=0)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_sequence <= 2)
     JOIN (oi
     WHERE oi.order_id=oa.order_id
      AND oi.action_sequence=oa.action_sequence
      AND oi.ingredient_type_flag != ingredient_type_compchild)
     JOIN (od
     WHERE (od.order_id= Outerjoin(oa.order_id))
      AND (od.action_sequence= Outerjoin(oa.action_sequence)) )
    ORDER BY d.seq, oa.action_sequence, oi.catalog_cd
    HEAD d.seq
     actionindex = 0, ordercount += 1
     IF (mod(ordercount,10)=1)
      stat = alterlist(action_compare->qual,(ordercount+ 9))
     ENDIF
     action_compare->qual[ordercount].template_order_id = oi.order_id, action_compare->qual[
     ordercount].orig_struct_index = d.seq
    HEAD oa.action_sequence
     ingredindex = 0, actionindex += 1
     IF (actionindex <= 2)
      action_compare->qual[ordercount].action_qual[actionindex].needs_verify_ind = oa
      .needs_verify_ind, action_compare->qual[ordercount].action_qual[actionindex].core_ind = oa
      .core_ind, action_compare->qual[ordercount].action_qual[actionindex].non_diluent_count = 0
     ENDIF
    HEAD oi.catalog_cd
     IF (actionindex <= 2)
      IF (oi.ingredient_type_flag != ingredient_type_diluent)
       action_compare->qual[ordercount].action_qual[actionindex].non_diluent_count += 1
      ENDIF
      ingredindex += 1, stat = alterlist(action_compare->qual[ordercount].action_qual[actionindex].
       ingred_list,ingredindex)
      IF ((((items_to_check->qual[d.seq].template_core_action_sequence=1)) OR ((items_to_check->qual[
      d.seq].template_core_action_sequence=0)
       AND (items_to_check->check_parent_ind=1))) )
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].catalog_cd
        = oi.catalog_cd, action_compare->qual[ordercount].action_qual[actionindex].ingred_list[
       ingredindex].freetext_dose = oi.freetext_dose, action_compare->qual[ordercount].action_qual[
       actionindex].ingred_list[ingredindex].strength = oi.strength,
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].
       strength_unit_cd = oi.strength_unit, action_compare->qual[ordercount].action_qual[actionindex]
       .ingred_list[ingredindex].volume = oi.volume, action_compare->qual[ordercount].action_qual[
       actionindex].ingred_list[ingredindex].volume_unit_cd = oi.volume_unit,
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].
       ingredient_type = oi.ingredient_type_flag
      ELSE
       action_compare->qual[ordercount].action_qual[actionindex].ingred_list[ingredindex].catalog_cd
        = actionindex
      ENDIF
     ENDIF
    DETAIL
     IF (actionindex <= 2)
      IF (od.oe_field_meaning_id=detail_form_meaning_id)
       action_compare->qual[ordercount].action_qual[actionindex].form_cd = od.oe_field_value
      ELSEIF (od.oe_field_meaning_id=detail_route_meaning_id)
       action_compare->qual[ordercount].action_qual[actionindex].route_cd = od.oe_field_value
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL alterlist(action_compare->qual,ordercount)
   FOR (nindex = 1 TO ordercount BY 1)
     SET bmismatch = 0
     SET bfulldiluentmatchneeded = 0
     IF ((action_compare->qual[nindex].action_qual[1].needs_verify_ind=nv_verified)
      AND (action_compare->qual[nindex].action_qual[2].needs_verify_ind=nv_not_needed))
      IF ((action_compare->qual[nindex].action_qual[1].non_diluent_count=0)
       AND (action_compare->qual[nindex].action_qual[2].non_diluent_count=0))
       IF (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)=size(action_compare->qual[
        nindex].action_qual[2].ingred_list,5))
        SET bmismatch = 1
       ELSE
        SET bfulldiluentmatchneeded = 1
       ENDIF
      ELSEIF ((action_compare->qual[nindex].action_qual[1].non_diluent_count != action_compare->qual[
      nindex].action_qual[2].non_diluent_count))
       SET bmismatch = 1
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].route_cd > 0)
       AND (action_compare->qual[nindex].action_qual[2].route_cd > 0)
       AND (action_compare->qual[nindex].action_qual[1].route_cd != action_compare->qual[nindex].
      action_qual[2].route_cd))
       SET bmismatch = 1
      ENDIF
      IF (bmismatch=0)
       FOR (ingredindex = 1 TO size(action_compare->qual[nindex].action_qual[1].ingred_list,5) BY 1)
        SET ord2ingredindex = locateval(catalogmatchindex,1,size(action_compare->qual[nindex].
          action_qual[2].ingred_list,5),action_compare->qual[nindex].action_qual[1].ingred_list[
         ingredindex].catalog_cd,action_compare->qual[nindex].action_qual[2].ingred_list[
         catalogmatchindex].catalog_cd)
        IF (ord2ingredindex > 0)
         IF ((((action_compare->qual[nindex].action_qual[1].ingred_list[ingredindex].ingredient_type
          != ingredient_type_diluent)) OR (bfulldiluentmatchneeded=1)) )
          SET bmismatch = comparedosefields(nindex,ingredindex,ord2ingredindex)
          IF (bmismatch=1)
           SET ingredindex = (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)+ 2)
          ENDIF
         ENDIF
        ELSE
         SET bmismatch = 1
         SET ingredindex = (size(action_compare->qual[nindex].action_qual[1].ingred_list,5)+ 2)
        ENDIF
       ENDFOR
      ENDIF
     ELSE
      SET bmismatch = 1
     ENDIF
     IF (bmismatch=0)
      SET bmismatch = 1
      IF ((((action_compare->qual[nindex].action_qual[1].form_cd=0)) OR ((action_compare->qual[nindex
      ].action_qual[2].form_cd=0))) )
       SET bmismatch = 0
       SET bexactmatch = 1
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].form_cd > 0)
       AND (action_compare->qual[nindex].action_qual[2].form_cd > 0)
       AND (action_compare->qual[nindex].action_qual[1].form_cd != action_compare->qual[nindex].
      action_qual[2].form_cd))
       SET bmismatch = 1
       SELECT
        cvg2.child_code_value
        FROM code_value_group cvg1,
         code_value_group cvg2,
         code_value cv
        PLAN (cvg1
         WHERE (cvg1.child_code_value=action_compare->qual[nindex].action_qual[1].form_cd))
         JOIN (cv
         WHERE cv.code_value=cvg1.parent_code_value
          AND cv.code_set=4003329)
         JOIN (cvg2
         WHERE cvg2.parent_code_value=cv.code_value
          AND (cvg2.child_code_value=action_compare->qual[nindex].action_qual[2].form_cd))
        DETAIL
         bmismatch = 0, bexactmatch = 1
        WITH nocounter
       ;end select
      ENDIF
      IF ((action_compare->qual[nindex].action_qual[1].form_cd=action_compare->qual[nindex].
      action_qual[2].form_cd))
       SET bmismatch = 0
       SET bexactmatch = 1
      ENDIF
      IF (bmismatch=0
       AND bexactmatch=1)
       SET bexactmatch = 0
       SET items_to_check->qual[action_compare->qual[nindex].orig_struct_index].verify_success_ind =
       1
       SET items_to_check->qual[action_compare->qual[nindex].orig_struct_index].
       second_action_core_ind = action_compare->qual[nindex].action_qual[2].core_ind
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getnextdueorderids(null)
   DECLARE ordercount = i4 WITH protect, noconstant(0)
   DECLARE idxnum = i4 WITH protect, noconstant(0)
   DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"MED"))
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta
    PLAN (o
     WHERE expand(idxnum,1,size(future_check->qual,5),o.template_order_id,future_check->qual[idxnum].
      template_order_id)
      AND o.template_order_id > 0)
     JOIN (ta
     WHERE ta.task_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ta.order_id=o.order_id
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=pending_cd
      AND ta.task_type_cd=med_cd)
    ORDER BY o.template_order_id, ta.task_dt_tm
    HEAD o.template_order_id
     ordercount += 1, future_check->qual[ordercount].next_due_ord_id = o.order_id, future_check->
     qual[ordercount].next_due_dt_tm = ta.task_dt_tm
    FOOT REPORT
     stat = alterlist(future_check->qual,ordercount)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getnextdueprotocolids(null)
   DECLARE idxnum = i4 WITH protect, noconstant(0)
   DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"MED"))
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta
    PLAN (o
     WHERE expand(idxnum,1,size(protocol_check->qual,5),o.protocol_order_id,protocol_check->qual[
      idxnum].protocol_order_id)
      AND o.protocol_order_id > 0)
     JOIN (ta
     WHERE ta.task_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ta.order_id=o.order_id
      AND ta.task_class_cd=sched_cd
      AND ta.task_status_cd=pending_cd
      AND ta.task_type_cd=med_cd)
    ORDER BY o.protocol_order_id, ta.task_dt_tm
    HEAD o.protocol_order_id
     rowcnt += 1, protocol_check->qual[rowcnt].next_due_ord_id = o.order_id, protocol_check->qual[
     rowcnt].next_due_dt_tm = ta.task_dt_tm
    FOOT REPORT
     stat = alterlist(protocol_check->qual,rowcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 FREE RECORD sac_def_pos_req
 RECORD sac_def_pos_req(
   1 personnel_id = f8
 )
 FREE RECORD sac_def_pos_list_req
 RECORD sac_def_pos_list_req(
   1 personnels[*]
     2 personnel_id = f8
 )
 FREE RECORD sac_def_pos_rep
 RECORD sac_def_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_def_pos_list_rep
 RECORD sac_def_pos_list_rep(
   1 personnels[*]
     2 personnel_id = f8
     2 personnel_found = i2
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_cur_pos_rep
 RECORD sac_cur_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getdefaultposition(null) = i2
 DECLARE getmultipledefaultpositions(null) = i2
 DECLARE getcurrentposition(null) = i2
 EXECUTE sacrtl
 SUBROUTINE getdefaultposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_rep)
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationname = "GetDefaultPosition"
   SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE (p.person_id=sac_def_pos_req->personnel_id)
    DETAIL
     sac_def_pos_rep->position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_rep->status_data.status = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2("Personnel ID of ",
     cnvtstring(sac_def_pos_req->personnel_id,17)," does not exist.")
    RETURN(0)
   ENDIF
   IF ((sac_def_pos_rep->position_cd < 0))
    SET sac_def_pos_rep->status_data.status = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Invalid POSITION_CD of ",cnvtstring(sac_def_pos_rep->position_cd,17),". Value is less than 0.")
    RETURN(0)
   ENDIF
   SET sac_def_pos_rep->status_data.status = "S"
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmultipledefaultpositions(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_list_rep)
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationname =
   "GetMultipleDefaultPositions"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   DECLARE prsnl_list_size = i4 WITH protect
   SET prsnl_list_size = size(sac_def_pos_list_req->personnels,5)
   IF (prsnl_list_size=0)
    SET sac_def_pos_list_rep->status_data.status = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnel IDs set in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET stat = alterlist(sac_def_pos_list_rep->personnels,prsnl_list_size)
   FOR (x = 1 TO prsnl_list_size)
     SET sac_def_pos_list_rep->personnels[x].personnel_id = sac_def_pos_list_req->personnels[x].
     personnel_id
     SET sac_def_pos_list_rep->personnels[x].personnel_found = 0
     SET sac_def_pos_list_rep->personnels[x].position_cd = - (1)
   ENDFOR
   DECLARE prsnl_idx = i4 WITH protect
   DECLARE expand_idx = i4 WITH protect
   DECLARE actual_idx = i4 WITH protect
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE expand(prsnl_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_req->personnels[prsnl_idx].
     personnel_id)
    DETAIL
     actual_idx = locateval(expand_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_rep->
      personnels[expand_idx].personnel_id), sac_def_pos_list_rep->personnels[actual_idx].
     personnel_found = 1, sac_def_pos_list_rep->personnels[actual_idx].position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_list_rep->status_data.status = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnels found in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET sac_def_pos_list_rep->status_data.status = "S"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcurrentposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_cur_pos_rep)
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationname = "GetCurrentPosition"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SET sac_cur_pos_rep->status_data.status = "F"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
   DECLARE hpositionhandle = i4 WITH protect, noconstant(0)
   DECLARE clearhandle = i4 WITH protect, noconstant(0)
   SET hpositionhandle = uar_sacgetcurrentpositions()
   IF (hpositionhandle=0)
    CALL echo("Get Position failed: Unable to get the position handle.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to get the position handle."
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE positioncnt = i4 WITH protect, noconstant(0)
   SET positioncnt = uar_srvgetitemcount(hpositionhandle,nullterm("Positions"))
   IF (positioncnt != 1)
    CALL echo("Get Position failed: Position count was not exactly 1.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Get Current Position Failed: ",cnvtstring(positioncnt,1)," positions returned.")
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE hpositionlisthandle = i4 WITH protect, noconstant(0)
   SET hpositionlisthandle = uar_srvgetitem(hpositionhandle,nullterm("Positions"),0)
   IF (hpositionlisthandle=0)
    CALL echo("Get Position item failed: Unable to retrieve current position.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to retrieve current position."
    SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   SET sac_cur_pos_rep->position_cd = uar_srvgetdouble(hpositionlisthandle,nullterm("PositionCode"))
   SET sac_cur_pos_rep->status_data.status = "S"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
   SET clearhandle = uar_sacclosehandle(hpositionhandle)
   RETURN(1)
 END ;Subroutine
 DECLARE initialize(null) = null
 DECLARE loadtasksandchildorders(null) = null
 DECLARE loaddeltaind(null) = null
 DECLARE loadorderactions(null) = null
 DECLARE pref_infusion_billing_task = vc WITH protect, constant("INFUSION_BILLING_TASK")
 DECLARE protocol_flag = i4 WITH constant(7)
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
 DECLARE itotalchildordercount = i4 WITH protect, noconstant(0)
 DECLARE bfutureload = i2 WITH protect, noconstant(0)
 CALL initialize(null)
 CALL loadtasksandchildorders(null)
 IF (order_cnt > 0)
  CALL loadorderactions(null)
 ENDIF
 IF (itotalchildordercount > 0)
  CALL checkactionsequencecompatibility(null)
  CALL loaddeltaind(null)
 ENDIF
 IF (debug_ind=1)
  CALL echo("****************************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(sysdate),totaltime,5)))
  CALL echo("****************************************")
 ENDIF
#exit_script
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
 IF (debug_ind=1)
  CALL echorecord(reply)
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
   IF (cnvtdatetime(request->start_dt_tm) > cnvtdatetime(sysdate))
    SET bfutureload = 1
   ENDIF
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
   IF (getprefbycontextdbl(pref_infusion_billing_task,"default",ssystem,dibtaskprefval)=ipreferror)
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
   DECLARE med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"MED"))
   DECLARE person_clause = vc WITH protect, noconstant(fillstring(100," "))
   DECLARE itaskcount = i4 WITH protect, noconstant(0)
   DECLARE ichildordercount = i4 WITH protect, noconstant(0)
   DECLARE iorddetailcount = i4 WITH protect, noconstant(0)
   DECLARE oit = i4 WITH protect, noconstant(0)
   DECLARE coit = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE secit = i4 WITH protect, noconstant(0)
   DECLARE baddorddetail = i2 WITH protect, noconstant(0)
   DECLARE baddtask = i2 WITH protect, noconstant(0)
   DECLARE encntridx = i4 WITH protect, noconstant(0)
   DECLARE encntrit = i4 WITH protect, noconstant(0)
   DECLARE template_idx = i4 WITH protect, noconstant(0)
   DECLARE futuretaskcnt = i4 WITH protect, noconstant(0)
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE ipos = i4 WITH protect, noconstant(0)
   DECLARE protocolordidcnt = i4 WITH protect, noconstant(0)
   DECLARE templateordidcnt = i4 WITH protect, noconstant(0)
   DECLARE lastaddedtemplateordid = f8 WITH protect, noconstant(0)
   DECLARE lastaddedprotocolordid = f8 WITH protect, noconstant(0)
   RECORD tasktemp(
     1 cnt = i4
     1 qual[*]
       2 reference_task_id = f8
       2 item_cnt = i4
       2 items[*]
         3 order_index = i4
         3 task_index = i4
   )
   IF (encntr_cnt > 0
    AND encntr_cnt <= 100)
    SET person_clause = "expand (x, 1, encntr_cnt, ta.encntr_id, request->encntr_list[x].encntr_id)"
   ELSE
    SET person_clause = "ta.person_id = request->person_id"
   ENDIF
   SELECT INTO "nl:"
    FROM task_activity ta,
     orders o,
     orders o2,
     order_detail od,
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
      AND o.orig_ord_as_flag IN (0, 5)
      AND o.template_order_flag != protocol_flag)
     JOIN (o2
     WHERE o.template_order_id=o2.order_id)
     JOIN (od
     WHERE od.order_id=o.order_id
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od2.order_id=od.order_id
       AND od2.oe_field_id=od.oe_field_id))
      AND od.oe_field_meaning_id IN (57, 117, 141, 2043, 2050,
     2056, 2057, 2058, 2059, 2063,
     3524))
     JOIN (ot
     WHERE ta.reference_task_id=ot.reference_task_id)
    ORDER BY o.template_order_id, ta.task_dt_tm, o.order_id,
     ta.task_id
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadTasksAndChildOrders Query Time = ",datetimediff(cnvtdatetime(
         sysdate),loadtasksandchildorderstime,5)))
     ENDIF
     order_cnt = 0
    HEAD ta.task_id
     IF (encntr_cnt > 100)
      encntridx = locateval(encntrit,1,encntr_cnt,ta.encntr_id,request->encntr_list[encntrit].
       encntr_id)
      IF (encntridx=0)
       baddtask = 0
      ELSE
       baddtask = 1
      ENDIF
     ELSE
      baddtask = 1
     ENDIF
     iorddetailcount = 0, baddorddetail = 0
     IF (uar_get_code_meaning(ta.task_type_cd) != "CLINPHARM"
      AND uar_get_code_meaning(ta.task_type_cd) != "ENDORSE"
      AND baddtask=1)
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
        order_cnt += 1, oidx = order_cnt, itaskcount = 0,
        futuretaskcnt = 0
        IF (mod(order_cnt,50)=1)
         stat = alterlist(reply->orders,(order_cnt+ 49)), stat = alterlist(protocol_check->qual,(
          order_cnt+ 49))
         IF (bfutureload=1)
          stat = alterlist(future_check->qual,(order_cnt+ 49))
         ENDIF
        ENDIF
        IF (o.template_order_id > 0)
         reply->orders[oidx].order_id = o.template_order_id, reply->orders[oidx].template_order_id =
         o.template_order_id, template_idx += 1
         IF (mod(template_idx,50)=1)
          stat = alterlist(items_to_check->qual,(template_idx+ 49))
         ENDIF
         items_to_check->check_parent_ind = 0, items_to_check->qual[template_idx].order_id = o
         .template_order_id, items_to_check->qual[template_idx].template_core_action_sequence = o
         .last_action_sequence
        ELSE
         reply->orders[oidx].order_id = o.order_id, reply->orders[oidx].template_order_id = o
         .template_order_id
        ENDIF
        IF ((request->enable_protocol_ind=1))
         IF (o.template_order_id > 0)
          reply->orders[oidx].protocol_order_id = o2.protocol_order_id
         ELSE
          reply->orders[oidx].protocol_order_id = o.protocol_order_id
         ENDIF
        ELSE
         reply->orders[oidx].protocol_order_id = 0.0
        ENDIF
        reply->orders[oidx].last_action_sequence = o.last_action_sequence, reply->orders[oidx].
        encntr_id = o.encntr_id, reply->orders[oidx].med_order_type_cd = o.med_order_type_cd,
        reply->orders[oidx].catalog_cd = o.catalog_cd, reply->orders[oidx].catalog_type_cd = o
        .catalog_type_cd, reply->orders[oidx].freq_type_flag = o.freq_type_flag
       ELSE
        itaskcount = reply->orders[oidx].task_cnt
       ENDIF
       IF (o.template_order_id > 0)
        ichildordercount = reply->orders[oidx].co_cnt, coidx = locateval(coit,1,ichildordercount,o
         .order_id,reply->orders[oidx].child_orders[coit].order_id)
        IF (coidx <= 0)
         ichildordercount += 1, reply->orders[oidx].co_cnt = ichildordercount, coidx =
         ichildordercount,
         baddorddetail = 1
         IF (ichildordercount > size(reply->orders[oidx].child_orders,5))
          stat = alterlist(reply->orders[oidx].child_orders,(ichildordercount+ 49))
         ENDIF
         reply->orders[oidx].child_orders[coidx].order_id = o.order_id, reply->orders[oidx].
         child_orders[coidx].core_action_sequence = o.template_core_action_sequence, reply->orders[
         oidx].child_orders[coidx].current_start_dt_tm = o.current_start_dt_tm,
         reply->orders[oidx].child_orders[coidx].current_start_tz = o.current_start_tz, reply->
         orders[oidx].child_orders[coidx].need_nurse_review_ind = o.need_nurse_review_ind, reply->
         orders[oidx].child_orders[coidx].med_order_type_cd = o.med_order_type_cd,
         reply->orders[oidx].child_orders[coidx].link_nbr = o.link_nbr, reply->orders[oidx].
         child_orders[coidx].link_type_flag = o.link_type_flag, reply->orders[oidx].child_orders[
         coidx].freq_type_flag = o.freq_type_flag,
         reply->orders[oidx].child_orders[coidx].encntr_id = o.encntr_id, reply->orders[oidx].
         child_orders[coidx].catalog_cd = o.catalog_cd, reply->orders[oidx].child_orders[coidx].
         catalog_type_cd = o.catalog_type_cd,
         reply->orders[oidx].child_orders[coidx].need_rx_clin_review_flag = o
         .need_rx_clin_review_flag, reply->orders[oidx].child_orders[coidx].need_rx_verify_ind = o
         .need_rx_verify_ind, reply->orders[oidx].child_orders[coidx].display_line = trim(o
          .clinical_display_line),
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
       reply->orders[oidx].tasks[itaskcount].quick_chart_ind = ot.quick_chart_ind, reply->orders[oidx
       ].tasks[itaskcount].event_cd = ot.event_cd, reply->orders[oidx].tasks[itaskcount].
       reschedule_time = ot.reschedule_time,
       reply->orders[oidx].tasks[itaskcount].task_priority_cd = ta.task_priority_cd, reply->orders[
       oidx].tasks[itaskcount].last_action_sequence = o.last_action_sequence, reply->orders[oidx].
       tasks[itaskcount].task_dt_tm = ta.task_dt_tm,
       reply->orders[oidx].tasks[itaskcount].task_tz = ta.task_tz, reply->orders[oidx].tasks[
       itaskcount].template_order_action_sequence = o.template_core_action_sequence, reply->orders[
       oidx].tasks[itaskcount].delta_ind = 0
       IF ((request->enable_protocol_ind=1))
        IF (o.template_order_id > 0)
         reply->orders[oidx].tasks[itaskcount].day_of_treatment_sequence = o2
         .day_of_treatment_sequence
        ELSE
         reply->orders[oidx].tasks[itaskcount].day_of_treatment_sequence = o
         .day_of_treatment_sequence
        ENDIF
       ELSE
        reply->orders[oidx].tasks[itaskcount].day_of_treatment_sequence = 0
       ENDIF
       IF (ta.task_class_cd IN (prn_cd, continuous_cd, nonsched_cd)
        AND ta.task_status_cd=pending_cd)
        IF (cnvtdatetime(curdate,curtime) > cnvtdatetime(ta.task_dt_tm))
         reply->orders[oidx].tasks[itaskcount].task_dt_tm = cnvtdatetime(curdate,curtime)
        ENDIF
       ENDIF
       IF ((reply->orders[oidx].tasks[(itaskcount - 1)].task_status_cd=inprocess_cd))
        futuretaskcnt = 0
       ENDIF
       IF (ta.task_class_cd=sched_cd
        AND ta.task_status_cd=pending_cd
        AND ta.task_type_cd=med_cd)
        IF (cnvtdatetime(ta.task_dt_tm) > cnvtdatetime(sysdate))
         IF (o.template_order_id > 0
          AND o.protocol_order_id=0)
          IF (bfutureload=0)
           futuretaskcnt += 1
           IF (futuretaskcnt >= 2)
            reply->orders[oidx].tasks[itaskcount].future_ind = 1
           ENDIF
          ELSE
           IF (lastaddedtemplateordid != o.template_order_id)
            pos = locateval(inum,1,size(future_check->qual,5),o.template_order_id,future_check->qual[
             inum].template_order_id)
            IF (pos <= 0)
             templateordidcnt += 1
             IF (size(future_check->qual,5) < templateordidcnt)
              stat = alterlist(future_check->qual,(templateordidcnt+ 9))
             ENDIF
             future_check->qual[templateordidcnt].template_order_id = o.template_order_id,
             lastaddedtemplateordid = o.template_order_id
            ENDIF
           ENDIF
          ENDIF
         ELSE
          IF (o.protocol_order_id > 0)
           IF (lastaddedprotocolordid != o.protocol_order_id)
            pos = locateval(inum,1,size(protocol_check->qual,5),o.protocol_order_id,protocol_check->
             qual[inum].protocol_order_id)
            IF (pos <= 0)
             protocolordidcnt += 1
             IF (size(protocol_check->qual,5) < protocolordidcnt)
              stat = alterlist(protocol_check->qual,(protocolordidcnt+ 9))
             ENDIF
             protocol_check->qual[protocolordidcnt].protocol_order_id = o.protocol_order_id,
             lastaddedprotocolordid = o.protocol_order_id
            ENDIF
           ENDIF
          ENDIF
         ENDIF
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
     ENDIF
    DETAIL
     IF (baddorddetail=1
      AND baddtask=1)
      iorddetailcount += 1
      IF (mod(iorddetailcount,10)=1)
       stat = alterlist(reply->orders[oidx].child_orders[coidx].order_details,(iorddetailcount+ 9))
      ENDIF
      reply->orders[oidx].child_orders[coidx].order_details[iorddetailcount].oe_field_id = od
      .oe_field_id, reply->orders[oidx].child_orders[coidx].order_details[iorddetailcount].
      oe_field_meaning = od.oe_field_meaning, reply->orders[oidx].child_orders[coidx].order_details[
      iorddetailcount].oe_field_meaning_id = od.oe_field_meaning_id,
      reply->orders[oidx].child_orders[coidx].order_details[iorddetailcount].oe_field_value = od
      .oe_field_value, reply->orders[oidx].child_orders[coidx].order_details[iorddetailcount].
      oe_field_display_value = od.oe_field_display_value, reply->orders[oidx].child_orders[coidx].
      order_details[iorddetailcount].oe_field_dt_tm = od.oe_field_dt_tm_value,
      reply->orders[oidx].child_orders[coidx].order_details[iorddetailcount].oe_field_tz = od
      .oe_field_tz
     ENDIF
     CALL echo(build("Order Detail count is ",iorddetailcount))
    FOOT  ta.task_id
     IF (baddorddetail=1
      AND baddtask=1)
      stat = alterlist(reply->orders[oidx].child_orders[coidx].order_details,iorddetailcount)
     ENDIF
    FOOT REPORT
     IF (order_cnt > 0)
      stat = alterlist(reply->orders,order_cnt), stat = alterlist(items_to_check->qual,template_idx)
      IF (bfutureload=1)
       stat = alterlist(future_check->qual,templateordidcnt)
      ENDIF
      stat = alterlist(protocol_check->qual,protocolordidcnt)
     ENDIF
     stat = alterlist(temp_child_orders->orders,itotalchildordercount)
    WITH nocounter
   ;end select
   IF (bfutureload=1
    AND templateordidcnt > 0)
    CALL getnextdueorderids(null)
    SET stat = alterlist(future_check->qual,templateordidcnt)
   ENDIF
   IF (protocolordidcnt > 0)
    CALL getnextdueprotocolids(null)
    SET stat = alterlist(protocol_check->qual,protocolordidcnt)
   ENDIF
   FOR (k = 1 TO order_cnt)
     SET stat = alterlist(reply->orders[k].tasks,reply->orders[k].task_cnt)
     SET stat = alterlist(reply->orders[k].child_orders,reply->orders[k].co_cnt)
     IF (((protocolordidcnt > 0) OR (templateordidcnt > 0)) )
      FOR (j = 1 TO reply->orders[k].task_cnt)
        IF ((reply->orders[k].tasks[j].task_class_cd=sched_cd)
         AND (reply->orders[k].tasks[j].task_status_cd=pending_cd)
         AND (reply->orders[k].tasks[j].task_type_cd=med_cd))
         IF (cnvtdatetime(reply->orders[k].tasks[j].task_dt_tm) > cnvtdatetime(sysdate))
          IF ((reply->orders[k].template_order_id > 0)
           AND bfutureload=1
           AND (reply->orders[k].protocol_order_id=0))
           SET ipos = locateval(inum,1,size(future_check->qual,5),reply->orders[k].tasks[j].order_id,
            future_check->qual[inum].next_due_ord_id)
           IF (ipos=0)
            SET reply->orders[k].tasks[j].future_ind = 1
           ENDIF
          ELSEIF ((reply->orders[k].protocol_order_id > 0))
           SET ipos = locateval(inum,1,size(protocol_check->qual,5),reply->orders[k].tasks[j].
            order_id,protocol_check->qual[inum].next_due_ord_id)
           IF (ipos=0)
            SET reply->orders[k].tasks[j].future_ind = 1
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
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
   DECLARE ipreviousfoundind = i2 WITH protect, noconstant(0)
   DECLARE idxdelta = i2 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   IF ((request->load_delta_ind < 1))
    CALL echo("********Skipping the load of the delta_ind.")
   ELSE
    IF (debug_ind=1)
     CALL echo("********Load the delta_ind.")
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
        AND o2.template_order_id != 0
        AND o1.template_order_id != 0
        AND o2.hide_flag IN (null, 0))
      ORDER BY o1.order_id, o2.current_start_dt_tm DESC
      HEAD o1.order_id
       ipreviousfoundind = 0
      DETAIL
       IF (ipreviousfoundind=0
        AND o2.current_start_dt_tm < o1.current_start_dt_tm)
        ipreviousfoundind = 1
        IF (o1.template_core_action_sequence != o2.template_core_action_sequence)
         idx = locateval(i,1,size(reply->orders,5),o1.template_order_id,reply->orders[i].order_id)
         IF (idx > 0)
          FOR (j = 1 TO size(reply->orders[idx].tasks,5))
            IF ((reply->orders[idx].tasks[j].order_id=o1.order_id))
             idxdelta = locateval(index,1,size(items_to_check->qual,5),o1.template_order_id,
              items_to_check->qual[index].order_id)
             IF (idxdelta > 0)
              IF (o1.template_core_action_sequence=2
               AND o2.template_core_action_sequence=1
               AND (items_to_check->qual[idxdelta].verify_success_ind=1))
               reply->orders[idx].tasks[j].delta_ind = 0
              ELSE
               reply->orders[idx].tasks[j].delta_ind = 1
              ENDIF
             ELSE
              reply->orders[idx].tasks[j].delta_ind = 1
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
        ENDIF
       ENDIF
      FOOT  o1.order_id
       ipreviousfoundind = 0
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
 SUBROUTINE loadorderactions(null)
   CALL echo("********LoadOrderActions********")
   DECLARE o_verified = i2 WITH constant(0)
   DECLARE o_needs_review = i2 WITH constant(1)
   DECLARE o_rejected = i2 WITH constant(2)
   DECLARE oa_no_verify_needed = i2 WITH constant(0)
   DECLARE oa_verify_needed = i2 WITH constant(1)
   DECLARE oa_superceded = i2 WITH constant(2)
   DECLARE oa_verified = i2 WITH constant(3)
   DECLARE oa_rejected = i2 WITH constant(4)
   DECLARE oa_reviewed = i2 WITH constant(5)
   DECLARE clinreviewflag_unset = i2 WITH constant(0)
   DECLARE clinreviewflag_needs_review = i2 WITH constant(1)
   DECLARE clinreviewflag_reviewed = i2 WITH constant(2)
   DECLARE clinreviewflag_rejected = i2 WITH constant(3)
   DECLARE clinreviewflag_dna = i2 WITH constant(4)
   DECLARE clinreviewflag_superceded = i2 WITH constant(5)
   DECLARE loadorderactionstime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE actioncnt = i4 WITH protect, noconstant(0)
   DECLARE oit = i4 WITH protect, noconstant(0)
   DECLARE odit = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(50)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(order_cnt)/ nsize)) * nsize))
   DECLARE currentpositioncd = f8 WITH protect, noconstant(0)
   SET currentpositioncd = getcurrentposition(null)
   IF (currentpositioncd)
    IF (debug_ind)
     CALL echo(build("User's current position is ",sac_cur_pos_rep->position_cd))
    ENDIF
    SET currentpositioncd = sac_cur_pos_rep->position_cd
   ELSE
    IF (debug_ind)
     CALL echo(build("Default position lookup failed with status ",sac_cur_pos_rep->status_data.
       status))
    ENDIF
    SET currentpositioncd = 0.0
   ENDIF
   SET stat = alterlist(reply->orders,ntotal)
   FOR (i = (order_cnt+ 1) TO ntotal)
     SET reply->orders[i].order_id = reply->orders[order_cnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_action oa,
     order_detail od,
     prsnl p
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oa
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),oa.order_id,reply->orders[iterator].order_id)
     )
     JOIN (od
     WHERE od.order_id=oa.order_id
      AND od.oe_field_meaning_id IN (57, 117, 141, 2043, 2050,
     2056, 2057, 2058, 2059, 2063))
     JOIN (p
     WHERE p.person_id=oa.action_personnel_id)
    ORDER BY oa.order_id, oa.action_sequence DESC, od.action_sequence DESC,
     od.detail_sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadOrderActions Query Time = ",datetimediff(cnvtdatetime(sysdate),
        loadorderactionstime,5)))
     ENDIF
    HEAD oa.order_id
     actioncnt = 0, detailcnt = 0, oidx = locateval(oit,1,order_cnt,oa.order_id,reply->orders[oit].
      order_id)
    HEAD oa.action_sequence
     IF (oidx > 0)
      detailcnt = 0, actioncnt += 1
      IF (mod(actioncnt,3)=1)
       stat = alterlist(reply->orders[oidx].order_actions,(actioncnt+ 2))
      ENDIF
      reply->orders[oidx].order_actions[actioncnt].action_sequence = oa.action_sequence, reply->
      orders[oidx].order_actions[actioncnt].action_dt_tm = oa.action_dt_tm, reply->orders[oidx].
      order_actions[actioncnt].action_tz = oa.action_tz,
      reply->orders[oidx].order_actions[actioncnt].action_type_cd = oa.action_type_cd, reply->orders[
      oidx].order_actions[actioncnt].prn_ind = oa.prn_ind, reply->orders[oidx].order_actions[
      actioncnt].constant_ind = oa.constant_ind,
      reply->orders[oidx].order_actions[actioncnt].core_ind = oa.core_ind
      CASE (oa.needs_verify_ind)
       OF oa_no_verify_needed:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_verified
       OF oa_verify_needed:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_needs_review
       OF oa_superceded:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_needs_review
       OF oa_verified:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_verified
       OF oa_rejected:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_rejected
       OF oa_reviewed:
        reply->orders[oidx].order_actions[actioncnt].need_rx_verify_ind = o_verified
      ENDCASE
      IF (oa.need_clin_review_flag=0)
       CASE (oa.needs_verify_ind)
        OF oa_no_verify_needed:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag = clinreviewflag_dna
        OF oa_verify_needed:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_needs_review
        OF oa_superceded:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_superceded
        OF oa_verified:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_reviewed
        OF oa_rejected:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_rejected
        OF oa_reviewed:
         reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag =
         clinreviewflag_reviewed
       ENDCASE
      ELSE
       reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag = oa
       .need_clin_review_flag
      ENDIF
      IF ( NOT ((reply->orders[oidx].order_actions[actioncnt].need_rx_clin_review_flag IN (
      clinreviewflag_reviewed, clinreviewflag_dna))))
       reply->orders[oidx].order_actions[actioncnt].verification_prsnl_id = p.person_id, reply->
       orders[oidx].order_actions[actioncnt].verification_pos_cd = currentpositioncd
      ENDIF
     ELSE
      CALL echo(build(
       "********LoadOrderActions - Unable to locate this order_id in the order list******** ",oa
       .order_id))
     ENDIF
    DETAIL
     IF (oidx > 0
      AND od.action_sequence <= oa.action_sequence)
      odidx = locateval(odit,1,detailcnt,od.oe_field_meaning_id,reply->orders[oidx].order_actions[
       actioncnt].order_details[odit].oe_field_meaning_id)
      IF (odidx <= 0)
       detailcnt += 1
       IF (mod(detailcnt,10)=1)
        stat = alterlist(reply->orders[oidx].order_actions[actioncnt].order_details,(detailcnt+ 9))
       ENDIF
       reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].action_sequence = od
       .action_sequence, reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].
       oe_field_id = od.oe_field_id, reply->orders[oidx].order_actions[actioncnt].order_details[
       detailcnt].oe_field_meaning = od.oe_field_meaning,
       reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].oe_field_meaning_id = od
       .oe_field_meaning_id, reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].
       oe_field_value = od.oe_field_value, reply->orders[oidx].order_actions[actioncnt].
       order_details[detailcnt].oe_field_display_value = od.oe_field_display_value,
       reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].oe_field_dt_tm = od
       .oe_field_dt_tm_value, reply->orders[oidx].order_actions[actioncnt].order_details[detailcnt].
       oe_field_tz = od.oe_field_tz
      ENDIF
     ENDIF
    FOOT  oa.action_sequence
     IF (oidx > 0
      AND actioncnt > 0)
      stat = alterlist(reply->orders[oidx].order_actions[actioncnt].order_details,detailcnt)
     ENDIF
    FOOT  oa.order_id
     IF (oidx > 0)
      stat = alterlist(reply->orders[oidx].order_actions,actioncnt), actionidx = locateval(iterator,1,
       actioncnt,reply->orders[oidx].last_action_sequence,reply->orders[oidx].order_actions[iterator]
       .action_sequence)
      IF (actionidx > 0)
       verifyind = reply->orders[oidx].order_actions[actionidx].need_rx_verify_ind, reviewflag =
       reply->orders[oidx].order_actions[actionidx].need_rx_clin_review_flag, prsnlid = reply->
       orders[oidx].order_actions[actionidx].verification_prsnl_id,
       positioncd = reply->orders[oidx].order_actions[actionidx].verification_pos_cd
      ELSE
       verifyind = reply->orders[oidx].order_actions[1].need_rx_verify_ind, reviewflag = reply->
       orders[oidx].order_actions[1].need_rx_clin_review_flag, prsnlid = reply->orders[oidx].
       order_actions[1].verification_prsnl_id,
       positioncd = reply->orders[oidx].order_actions[1].verification_pos_cd
      ENDIF
      reply->orders[oidx].need_rx_verify_ind = verifyind, reply->orders[oidx].
      need_rx_clin_review_flag = reviewflag
      IF ( NOT (reviewflag IN (clinreviewflag_reviewed, clinreviewflag_dna)))
       reply->orders[oidx].verification_prsnl_id = prsnlid, reply->orders[oidx].verification_pos_cd
        = positioncd
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->orders,iordercnt)
   IF (debug_ind=1)
    CALL echo(build("********LoadOrderActions Time = ",datetimediff(cnvtdatetime(sysdate),
       loadorderactionstime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE (endexecution(bscriptstatus=i2,stargetobjectname=vc,stargetobjectvalue=vc) =null)
   IF (bscriptstatus > 0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
   ENDIF
   SET reply->status_data.subeventstatus.targetobjectname = stargetobjectname
   SET reply->status_data.subeventstatus.targetobjectvalue = stargetobjectvalue
   IF ((request->debug_ind=1))
    CALL echo(build("********Script Message: ",stargetobjectvalue))
   ENDIF
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE (printdebug(msg=vc) =null)
   IF (debug_ind > 0)
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 SET last_mod = "020   08/10/2020"
 SET modify = nopredeclare
END GO
