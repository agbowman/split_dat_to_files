CREATE PROGRAM bsc_generate_infusion_task:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD qualified_orders
 RECORD qualified_orders(
   1 order_cnt = i4
   1 order_list[*]
     2 order_id = f8
 )
 FREE RECORD task_create_struct
 RECORD task_create_struct(
   1 person_id = f8
   1 reference_task_id = f8
   1 task_activity_cd = f8
   1 task_type_cd = f8
   1 order_cnt = i4
   1 order_list[*]
     2 order_id = f8
     2 encntr_id = f8
     2 encntr_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 med_order_type_cd = f8
     2 create_task_ind = i2
 )
 FREE RECORD ib_task_exist
 RECORD ib_task_exist(
   1 order_list[*]
     2 order_id = f8
 )
 FREE SET pca_events
 RECORD pca_events(
   1 order_list[*]
     2 order_id = f8
     2 event_list[*]
       3 event_id = f8
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
 DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE unsched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"NSCH"))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE inf_bill_task_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"INFUSEBILL"))
 DECLARE beginbag_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE unauth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE pref_infusion_billing = vc WITH protect, constant("INFUSION_BILLING")
 DECLARE pref_infusion_billing_task = vc WITH protect, constant("INFUSION_BILLING_TASK")
 DECLARE pca_dose_cki = vc WITH public, constant("CERNER!261BD337-D806-41BD-A257-0A54E9FC53CC")
 DECLARE continuous_dose_cki = vc WITH public, constant("CERNER!61F095F2-DB50-488A-9131-B01A077EF039"
  )
 DECLARE pca_dose_cd = f8 WITH public, noconstant(0)
 DECLARE continuous_dose_cd = f8 WITH public, noconstant(0)
 DECLARE iibprefval = i4 WITH protect, noconstant(0)
 DECLARE dibtaskprefval = f8 WITH protect, noconstant(0)
 DECLARE istat = i2 WITH protect, noconstant(0)
 DECLARE isize = i4 WITH protect, constant(50)
 DECLARE itotal = i4 WITH protect, noconstant(0)
 DECLARE bsomeordersqualify = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 SET reply->status_data.status = "F"
 DECLARE fetchprefs(null) = null
 DECLARE populatetaskcreatestruct(null) = null
 DECLARE checkencntrtypecsext(null) = null
 DECLARE checkinfusecontribevents(null) = null
 DECLARE processibtask(null) = null
 DECLARE createtask(null) = null
 DECLARE updateinactivetasks(null) = null
 DECLARE updateactivetasks(null) = null
 DECLARE getpcaeventcodes(null) = null
 DECLARE storepcaevents(null) = null
 IF (size(request->order_list,5) <= 0)
  CALL endexecution(1,"bsc_generate_infusion_task","Empty Request")
 ENDIF
 CALL fetchprefs(null)
 CALL populatetaskcreatestruct(null)
 CALL checkencntrtypecsext(null)
 CALL getpcaeventcodes(null)
 IF (((bsomeordersqualify=1) OR ((request->force_update_ind=1))) )
  CALL checkinfusecontribevents(null)
  CALL processibtask(null)
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  ROLLBACK
  CALL endexecution(0,"bsc_generate_infusion_task",errmsg)
 ELSE
  SET reqinfo->commit_ind = 1
  CALL endexecution(1,"bsc_generate_infusion_task","Success")
 ENDIF
 SUBROUTINE populatetaskcreatestruct(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering PopulateTaskCreateStruct********")
   ENDIF
   SELECT INTO "nl:"
    FROM order_task ot
    PLAN (ot
     WHERE ot.reference_task_id=dibtaskprefval
      AND ot.active_ind=1)
    DETAIL
     task_create_struct->reference_task_id = ot.reference_task_id, task_create_struct->
     task_activity_cd = ot.task_activity_cd, task_create_struct->task_type_cd = ot.task_type_cd
    WITH nocounter
   ;end select
   IF ((task_create_struct->reference_task_id <= 0))
    CALL endexecution(0,"PopulateTaskCreateStruct","Invalid or inactive infusion_billing_task.")
   ELSEIF ((task_create_struct->task_type_cd != inf_bill_task_cd))
    CALL endexecution(0,"PopulateTaskCreateStruct",build("Infusion_billing_task [",task_create_struct
      ->reference_task_id,"] is not of type Continuous Infusion Billing. See code set 6026."))
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = qualified_orders->order_cnt),
     orders o,
     encounter e
    PLAN (d1)
     JOIN (o
     WHERE (o.order_id=qualified_orders->order_list[d1.seq].order_id)
      AND o.catalog_type_cd=pharmacy_cd)
     JOIN (e
     WHERE e.encntr_id=o.encntr_id)
    ORDER BY o.order_id
    HEAD REPORT
     task_create_struct->order_cnt = 0, task_create_struct->person_id = o.person_id
    HEAD o.order_id
     task_create_struct->order_cnt += 1
     IF (mod(task_create_struct->order_cnt,10)=1)
      istat = alterlist(task_create_struct->order_list,(task_create_struct->order_cnt+ 9))
     ENDIF
     task_create_struct->order_list[task_create_struct->order_cnt].order_id = o.order_id,
     task_create_struct->order_list[task_create_struct->order_cnt].encntr_id = o.encntr_id,
     task_create_struct->order_list[task_create_struct->order_cnt].encntr_type_cd = e.encntr_type_cd,
     task_create_struct->order_list[task_create_struct->order_cnt].catalog_type_cd = o
     .catalog_type_cd, task_create_struct->order_list[task_create_struct->order_cnt].catalog_cd = o
     .catalog_cd, task_create_struct->order_list[task_create_struct->order_cnt].med_order_type_cd = o
     .med_order_type_cd,
     task_create_struct->order_list[task_create_struct->order_cnt].create_task_ind = 1
    FOOT REPORT
     istat = alterlist(task_create_struct->order_list,task_create_struct->order_cnt)
    WITH nocounter
   ;end select
   IF ((task_create_struct->order_cnt <= 0))
    CALL endexecution(1,"PopulateTaskCreateStruct","No orders qualify to create IB tasks.")
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("********Exiting PopulateTaskCreateStruct********")
   ENDIF
 END ;Subroutine
 SUBROUTINE checkencntrtypecsext(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering CheckEncntrTypeCSExt********")
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE iencntrtypecnt = i4 WITH protect, noconstant(0)
   DECLARE bqualifytocreatetask = i2 WITH protect, noconstant(0)
   FREE RECORD encntr_cs_ext_request
   RECORD encntr_cs_ext_request(
     1 code_set = i4
     1 field_name = c32
   )
   FREE RECORD encntr_cs_ext_reply
   RECORD encntr_cs_ext_reply(
     1 qual[*]
       2 code_value = f8
       2 field_name = c32
       2 code_set = i4
       2 field_type = i4
       2 field_value = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET encntr_cs_ext_request->code_set = 71
   SET encntr_cs_ext_request->field_name = "CREATE_INFUSION_BILLING_TASKS"
   SET modify = nopredeclare
   EXECUTE bsc_get_code_value_by_ext  WITH replace("REQUEST","ENCNTR_CS_EXT_REQUEST"), replace(
    "REPLY","ENCNTR_CS_EXT_REPLY")
   SET modify = predeclare
   IF ((encntr_cs_ext_reply->status_data.status="F"))
    CALL endexecution(0,"CheckEncntrTypeCSExt","Failed in bsc_get_code_value_by_ext for CS 71.")
   ENDIF
   SET iencntrtypecnt = size(encntr_cs_ext_reply->qual,5)
   SET bsomeordersqualify = 0
   FOR (i = 1 TO task_create_struct->order_cnt)
     SET bqualifytocreatetask = 0
     FOR (j = 1 TO iencntrtypecnt)
       IF ((encntr_cs_ext_reply->qual[j].code_value=task_create_struct->order_list[i].encntr_type_cd)
       )
        SET bqualifytocreatetask = 1
        SET bsomeordersqualify = 1
        SET j = (iencntrtypecnt+ 1)
       ENDIF
     ENDFOR
     IF (bqualifytocreatetask=0)
      SET task_create_struct->order_list[i].create_task_ind = 0
     ENDIF
   ENDFOR
   IF ((request->debug_ind=1))
    CALL echo("********Exiting CheckEncntrTypeCSExt********")
   ENDIF
 END ;Subroutine
 SUBROUTINE checkinfusecontribevents(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering CheckInfuseContribEvents********")
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE k = i4 WITH protect, noconstant(0)
   DECLARE l = i4 WITH protect, noconstant(0)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   DECLARE iroutecnt = i4 WITH protect, noconstant(0)
   DECLARE iordercnt = i4 WITH protect, noconstant(0)
   DECLARE ineeddoceventcnt = i4 WITH protect, noconstant(0)
   DECLARE idocumentedeventcnt = i4 WITH protect, noconstant(0)
   DECLARE imatchinginfusioncnt = i4 WITH protect, noconstant(0)
   DECLARE bhasactiveresults = i2 WITH protect, noconstant(0)
   DECLARE unchartordid = f8 WITH protect, noconstant(0)
   DECLARE unchartinfuseid = f8 WITH protect, noconstant(0)
   DECLARE iordidx = i4 WITH protect, noconstant(0)
   DECLARE ieventidx = i4 WITH protect, noconstant(0)
   DECLARE iremoveidx = i4 WITH protect, noconstant(0)
   DECLARE ineedremovecnt = i4 WITH protect, noconstant(0)
   DECLARE ipcaidx = i4 WITH protect, noconstant(0)
   FREE RECORD events
   RECORD events(
     1 order_list[*]
       2 order_id = f8
       2 need_doc_event_list[*]
         3 parent_event_id = f8
     1 documented_events_list[*]
       2 parent_event_id = f8
       2 infusion_billing_id = f8
   )
   RECORD need_remove_list(
     1 remove_item_list[*]
       2 infusion_billing_id = f8
       2 order_id = f8
   )
   FREE RECORD route_cs_ext_request
   RECORD route_cs_ext_request(
     1 code_set = i4
     1 field_name = c32
   )
   FREE RECORD route_cs_ext_reply
   RECORD route_cs_ext_reply(
     1 qual[*]
       2 code_value = f8
       2 field_name = c32
       2 code_set = i4
       2 field_type = i4
       2 field_value = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD add_request
   RECORD add_request(
     1 encntr_id = f8
     1 order_id = f8
     1 new_infusion_list[*]
       2 infuse_start_dt_tm = dq8
       2 infuse_start_tz = i4
       2 infuse_end_dt_tm = dq8
       2 infuse_end_tz = i4
       2 comment = vc
       2 prsnl_id = f8
       2 infusion_duration_mins = i4
       2 infused_volume_value = f8
       2 event_list[*]
         3 clinical_event_id = f8
         3 clinical_event_seq = i4
     1 modified_infusion_list[*]
       2 infusion_billing_event_id = f8
       2 infuse_start_dt_tm = dq8
       2 infuse_start_tz = i4
       2 infuse_end_dt_tm = dq8
       2 infuse_end_tz = i4
       2 comment_modified_ind = i2
       2 comment = vc
       2 prsnl_id = f8
       2 infusion_duration_mins = i4
       2 infused_volume_value = f8
       2 event_list[*]
         3 clinical_event_id = f8
         3 clinical_event_seq = i4
     1 removed_infusion_list[*]
       2 infusion_billing_event_id = f8
     1 debug_ind = i2
   )
   SET route_cs_ext_request->code_set = 4001
   SET route_cs_ext_request->field_name = "Create_Infusion_Billing_Tasks"
   SET modify = nopredeclare
   EXECUTE bsc_get_code_value_by_ext  WITH replace("REQUEST","ROUTE_CS_EXT_REQUEST"), replace("REPLY",
    "ROUTE_CS_EXT_REPLY")
   SET modify = predeclare
   IF ((route_cs_ext_reply->status_data.status="F"))
    CALL endexecution(0,"CheckInfuseContribEvents","Failed in bsc_get_code_value_by_ext for CS 4001."
     )
   ENDIF
   SET iroutecnt = size(route_cs_ext_reply->qual,5)
   CALL storepcaevents(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = task_create_struct->order_cnt),
     ce_event_order_link ceol,
     clinical_event ce,
     ce_med_result cmr
    PLAN (d1)
     JOIN (ceol
     WHERE (ceol.parent_order_ident=task_create_struct->order_list[d1.seq].order_id))
     JOIN (ce
     WHERE ce.event_id=ceol.event_id
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
      AND ce.result_status_cd IN (auth_cd, unauth_cd, altered_cd, modified_cd))
     JOIN (cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
    ORDER BY ceol.parent_order_ident, ce.parent_event_id, ce.event_id
    HEAD REPORT
     iordercnt = 0, ineeddoceventcnt = 0
    HEAD ceol.parent_order_ident
     iordercnt += 1
     IF (mod(iordercnt,10)=1)
      istat = alterlist(events->order_list,(iordercnt+ 9))
     ENDIF
     events->order_list[iordercnt].order_id = ceol.parent_order_ident, ineeddoceventcnt = 0
    HEAD ce.parent_event_id
     ipcaidx = 0
     IF (iordercnt <= size(pca_events->order_list,5))
      ipcaidx = locateval(i,1,size(pca_events->order_list[iordercnt].event_list,5),ce.parent_event_id,
       pca_events->order_list[iordercnt].event_list[i].event_id)
     ENDIF
     IF (ipcaidx < 1)
      IF (cmr.iv_event_cd=beginbag_cd)
       ineeddoceventcnt += 1
       IF (mod(ineeddoceventcnt,10)=1)
        istat = alterlist(events->order_list[iordercnt].need_doc_event_list,(ineeddoceventcnt+ 9))
       ENDIF
       events->order_list[iordercnt].need_doc_event_list[ineeddoceventcnt].parent_event_id = ce
       .parent_event_id
      ELSEIF (cmr.iv_event_cd=0)
       FOR (i = 1 TO iroutecnt)
         IF ((cmr.admin_route_cd=route_cs_ext_reply->qual[i].code_value))
          ineeddoceventcnt += 1
          IF (mod(ineeddoceventcnt,10)=1)
           istat = alterlist(events->order_list[iordercnt].need_doc_event_list,(ineeddoceventcnt+ 9))
          ENDIF
          events->order_list[iordercnt].need_doc_event_list[ineeddoceventcnt].parent_event_id = ce
          .parent_event_id, i = (iroutecnt+ 1)
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    FOOT  ceol.parent_order_ident
     istat = alterlist(events->order_list[iordercnt].need_doc_event_list,ineeddoceventcnt)
    FOOT REPORT
     istat = alterlist(events->order_list,iordercnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = task_create_struct->order_cnt),
     infusion_billing_event ibe,
     infusion_ce_reltn icr,
     clinical_event ce
    PLAN (d1)
     JOIN (ibe
     WHERE (ibe.order_id=task_create_struct->order_list[d1.seq].order_id)
      AND ibe.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (icr
     WHERE icr.infusion_billing_event_id=ibe.infusion_billing_event_id
      AND icr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (ce
     WHERE ce.clinical_event_id=icr.clinical_event_id)
    ORDER BY ce.clinical_event_id
    HEAD ce.clinical_event_id
     IF (size(events->order_list,5) > 0)
      iordidx = locateval(i,1,size(events->order_list,5),ibe.order_id,events->order_list[i].order_id)
      IF (iordidx > 0)
       ieventidx = locateval(i,1,size(events->order_list[iordidx].need_doc_event_list,5),ce
        .parent_event_id,events->order_list[iordidx].need_doc_event_list[i].parent_event_id)
       IF (ieventidx < 1)
        iremoveidx = locateval(i,1,ineedremovecnt,ibe.infusion_billing_event_id,need_remove_list->
         remove_item_list[i].infusion_billing_id)
        IF (iremoveidx < 1)
         ineedremovecnt += 1, istat = alterlist(need_remove_list->remove_item_list,ineedremovecnt),
         need_remove_list->remove_item_list[ineedremovecnt].infusion_billing_id = ibe
         .infusion_billing_event_id,
         need_remove_list->remove_item_list[ineedremovecnt].order_id = ibe.order_id
        ENDIF
       ENDIF
      ELSE
       iremoveidx = locateval(i,1,ineedremovecnt,ibe.infusion_billing_event_id,need_remove_list->
        remove_item_list[i].infusion_billing_id)
       IF (iremoveidx < 1)
        ineedremovecnt += 1, istat = alterlist(need_remove_list->remove_item_list,ineedremovecnt),
        need_remove_list->remove_item_list[ineedremovecnt].infusion_billing_id = ibe
        .infusion_billing_event_id,
        need_remove_list->remove_item_list[ineedremovecnt].order_id = ibe.order_id
       ENDIF
      ENDIF
     ELSE
      iremoveidx = locateval(i,1,ineedremovecnt,ibe.infusion_billing_event_id,need_remove_list->
       remove_item_list[i].infusion_billing_id)
      IF (iremoveidx < 1)
       ineedremovecnt += 1, istat = alterlist(need_remove_list->remove_item_list,ineedremovecnt),
       need_remove_list->remove_item_list[ineedremovecnt].infusion_billing_id = ibe
       .infusion_billing_event_id,
       need_remove_list->remove_item_list[ineedremovecnt].order_id = ibe.order_id
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   FOR (i = 1 TO ineedremovecnt)
     SET add_request->order_id = need_remove_list->remove_item_list[i].order_id
     SET istat = alterlist(add_request->removed_infusion_list,1)
     SET add_request->removed_infusion_list[1].infusion_billing_event_id = need_remove_list->
     remove_item_list[i].infusion_billing_id
     SET modify = nopredeclare
     EXECUTE bsc_add_infusion_info  WITH replace("REQUEST","ADD_REQUEST")
     SET modify = predeclare
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = task_create_struct->order_cnt),
     infusion_billing_event ibe,
     infusion_ce_reltn icr,
     clinical_event ce
    PLAN (d1)
     JOIN (ibe
     WHERE (ibe.order_id=task_create_struct->order_list[d1.seq].order_id)
      AND ibe.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (icr
     WHERE icr.infusion_billing_event_id=ibe.infusion_billing_event_id
      AND icr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (ce
     WHERE ce.clinical_event_id=icr.clinical_event_id)
    ORDER BY ce.clinical_event_id
    HEAD REPORT
     idocumentedeventcnt = 0
    HEAD ce.clinical_event_id
     idocumentedeventcnt += 1
     IF (mod(idocumentedeventcnt,10)=1)
      istat = alterlist(events->documented_events_list,(idocumentedeventcnt+ 9))
     ENDIF
     events->documented_events_list[idocumentedeventcnt].parent_event_id = ce.parent_event_id, events
     ->documented_events_list[idocumentedeventcnt].infusion_billing_id = ibe
     .infusion_billing_event_id
    FOOT REPORT
     istat = alterlist(events->documented_events_list,idocumentedeventcnt)
    WITH nocounter
   ;end select
   IF ((request->debug_ind=1))
    CALL echorecord(events)
   ENDIF
   FOR (i = 1 TO task_create_struct->order_cnt)
     IF ((task_create_struct->order_list[i].create_task_ind=1))
      SET bhasactiveresults = 0
      FOR (j = 1 TO iordercnt)
        IF ((task_create_struct->order_list[i].order_id=events->order_list[j].order_id))
         SET bhasactiveresults = 1
         SET imatchinginfusioncnt = 0
         SET ineeddoceventcnt = size(events->order_list[j].need_doc_event_list,5)
         FOR (k = 1 TO ineeddoceventcnt)
           FOR (l = 1 TO idocumentedeventcnt)
             IF ((events->order_list[j].need_doc_event_list[k].parent_event_id=events->
             documented_events_list[l].parent_event_id))
              SET imatchinginfusioncnt += 1
              SET l = (idocumentedeventcnt+ 1)
             ENDIF
           ENDFOR
         ENDFOR
         IF (imatchinginfusioncnt=ineeddoceventcnt)
          SET task_create_struct->order_list[i].create_task_ind = 0
          SET j = (iordercnt+ 1)
         ENDIF
        ENDIF
      ENDFOR
      IF (bhasactiveresults=0)
       SET task_create_struct->order_list[i].create_task_ind = 0
      ENDIF
     ENDIF
   ENDFOR
   IF ((request->debug_ind=1))
    CALL echorecord(task_create_struct)
    CALL echo("********Exiting CheckInfuseContribEvents********")
   ENDIF
 END ;Subroutine
 SUBROUTINE processibtask(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering ProcessIBTask********")
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   DECLARE iorderidx = i4 WITH protect, noconstant(0)
   DECLARE iinactiveidx = i4 WITH protect, noconstant(0)
   DECLARE iactiveidx = i4 WITH protect, noconstant(0)
   FREE RECORD ib_tasks
   RECORD ib_tasks(
     1 complete_task_list[*]
       2 task_id = f8
     1 pending_task_list[*]
       2 task_id = f8
   )
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = task_create_struct->order_cnt),
     task_activity ta,
     orders o
    PLAN (d1)
     JOIN (o
     WHERE (o.order_id=task_create_struct->order_list[d1.seq].order_id))
     JOIN (ta
     WHERE ta.order_id=o.order_id
      AND ta.encntr_id=o.encntr_id
      AND (ta.person_id=task_create_struct->person_id)
      AND (ta.reference_task_id=task_create_struct->reference_task_id))
    ORDER BY ta.order_id, ta.task_status_cd
    HEAD REPORT
     iorderidx = 0, iinactiveidx = 0, iactiveidx = 0
    HEAD ta.order_id
     iidx = locateval(i,1,task_create_struct->order_cnt,ta.order_id,task_create_struct->order_list[i]
      .order_id), iorderidx += 1
     IF (mod(iorderidx,5)=1)
      istat = alterlist(ib_task_exist->order_list,(iorderidx+ 4))
     ENDIF
     ib_task_exist->order_list[iorderidx].order_id = ta.order_id
    HEAD ta.task_status_cd
     IF (iidx > 0)
      IF ((task_create_struct->order_list[iidx].create_task_ind=1))
       IF (ta.task_status_cd != pending_cd)
        iinactiveidx += 1
        IF (mod(iinactiveidx,5)=1)
         istat = alterlist(ib_tasks->pending_task_list,(iinactiveidx+ 4))
        ENDIF
        ib_tasks->pending_task_list[iinactiveidx].task_id = ta.task_id
       ENDIF
      ELSE
       IF (ta.task_status_cd=pending_cd)
        iactiveidx += 1
        IF (mod(iactiveidx,5)=1)
         istat = alterlist(ib_tasks->complete_task_list,(iactiveidx+ 4))
        ENDIF
        ib_tasks->complete_task_list[iactiveidx].task_id = ta.task_id
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     istat = alterlist(ib_task_exist->order_list,iorderidx), istat = alterlist(ib_tasks->
      pending_task_list,iinactiveidx), istat = alterlist(ib_tasks->complete_task_list,iactiveidx)
    WITH nocounter
   ;end select
   IF (iinactiveidx > 0)
    CALL updateinactivetasks(null)
   ENDIF
   IF (iactiveidx > 0)
    CALL updateactivetasks(null)
   ENDIF
   CALL createtask(null)
   IF ((request->debug_ind=1))
    CALL echo("********Exiting ProcessIBTask********")
   ENDIF
 END ;Subroutine
 SUBROUTINE createtask(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering CreateTask********")
   ENDIF
   DECLARE app_number = i4 WITH protect, noconstant(0)
   DECLARE app_handle = i4 WITH protect, noconstant(0)
   DECLARE task_number = i4 WITH protect, noconstant(0)
   DECLARE task_handle = i4 WITH protect, noconstant(0)
   DECLARE req_number = i4 WITH protect, noconstant(0)
   DECLARE req_handle = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE batrinit = i2 WITH protect, noconstant(0)
   DECLARE bcallserver = i2 WITH protect, noconstant(1)
   DECLARE iorderidx = i4 WITH protect, noconstant(0)
   DECLARE cur_time = dq8 WITH protect, noconstant(0)
   SET batrinit = 0
   SET iorderidx = size(ib_task_exist->order_list,5)
   SET app_number = 600005
   SET app_handle = 0
   SET task_number = 560300
   SET task_handle = 0
   SET req_number = 560300
   SET req_handle = 0
   SET hreq = 0
   FOR (i = 1 TO task_create_struct->order_cnt)
     SET bcallserver = 1
     IF ((task_create_struct->order_list[i].create_task_ind=0))
      SET bcallserver = 0
     ELSE
      FOR (j = 1 TO iorderidx)
        IF ((task_create_struct->order_list[i].order_id=ib_task_exist->order_list[j].order_id))
         SET bcallserver = 0
         SET j = (iorderidx+ 1)
        ENDIF
      ENDFOR
     ENDIF
     IF (bcallserver=1
      AND batrinit=0)
      SET istat = uar_crmbeginapp(app_number,app_handle)
      SET istat = uar_crmbegintask(app_handle,task_number,task_handle)
      SET cur_time = cnvtdatetime(sysdate)
      SET batrinit = 1
     ENDIF
     IF (bcallserver=1)
      SET istat = uar_crmbeginreq(task_handle,"",req_number,req_handle)
      SET hreq = uar_crmgetrequest(req_handle)
      IF (hreq=0)
       ROLLBACK
       CALL endexecution(0,"CreateTask","Failed to get Request handle to 560300.")
      ENDIF
      SET istat = uar_srvsetdouble(hreq,"person_id",task_create_struct->person_id)
      SET istat = uar_srvsetdouble(hreq,"encntr_id",task_create_struct->order_list[i].encntr_id)
      SET istat = uar_srvsetdouble(hreq,"task_type_cd",task_create_struct->task_type_cd)
      SET istat = uar_srvsetdouble(hreq,"reference_task_id",task_create_struct->reference_task_id)
      SET istat = uar_srvsetdate(hreq,"task_dt_tm",cur_time)
      SET istat = uar_srvsetstring(hreq,"task_activity_meaning",uar_get_code_meaning(
        task_create_struct->task_activity_cd))
      SET istat = uar_srvsetdouble(hreq,"order_id",task_create_struct->order_list[i].order_id)
      SET istat = uar_srvsetdouble(hreq,"catalog_cd",task_create_struct->order_list[i].catalog_cd)
      SET istat = uar_srvsetdouble(hreq,"task_class_cd",unsched_cd)
      SET istat = uar_srvsetdouble(hreq,"med_order_type_cd",task_create_struct->order_list[i].
       med_order_type_cd)
      SET istat = uar_srvsetdouble(hreq,"catalog_type_cd",task_create_struct->order_list[i].
       catalog_type_cd)
      SET istat = uar_srvsetstring(hreq,"task_status_meaning","PENDING")
      SET istat = - (1)
      SET istat = uar_crmperform(req_handle)
      IF (istat != 0)
       IF ((request->debug_ind=1))
        CALL echo(build("*****Failed to generated infusion billing task for order_id: ",
          task_create_struct->order_list[i].order_id))
       ENDIF
       ROLLBACK
       CALL endexecution(0,"CreateTask","Failed to perform 560300.")
      ENDIF
      CALL uar_crmendreq(req_handle)
     ENDIF
   ENDFOR
   IF (batrinit=1)
    CALL uar_crmendtask(task_handle)
    CALL uar_crmendapp(app_handle)
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("********Exiting CreateTask********")
   ENDIF
 END ;Subroutine
 SUBROUTINE updateinactivetasks(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering UpdateInactiveTasks********")
   ENDIF
   DECLARE app_number = i4 WITH protect, noconstant(0)
   DECLARE app_handle = i4 WITH protect, noconstant(0)
   DECLARE task_number = i4 WITH protect, noconstant(0)
   DECLARE task_handle = i4 WITH protect, noconstant(0)
   DECLARE req_number = i4 WITH protect, noconstant(0)
   DECLARE req_handle = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE hivitem = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE istat = i4 WITH protect, noconstant(0)
   SET app_number = 600005
   SET app_handle = 0
   SET task_number = 560300
   SET task_handle = 0
   SET req_number = 560303
   SET req_handle = 0
   SET hreq = 0
   SET hitem = 0
   SET hivitem = 0
   SET istat = uar_crmbeginapp(app_number,app_handle)
   SET istat = uar_crmbegintask(app_handle,task_number,task_handle)
   SET istat = uar_crmbeginreq(task_handle,"",req_number,req_handle)
   SET hreq = uar_crmgetrequest(req_handle)
   IF (hreq=0)
    CALL endexecution(0,"UpdateInactiveTasks",build("Failed to get Request handle to ",req_number,"."
      ))
   ENDIF
   FOR (i = 1 TO size(ib_tasks->pending_task_list,5))
     SET hitem = uar_srvadditem(hreq,"mod_list")
     SET istat = uar_srvsetdouble(hitem,"task_id",ib_tasks->pending_task_list[i].task_id)
     SET istat = uar_srvsetstring(hitem,"task_status_meaning","PENDING")
     SET istat = uar_srvsetdate(hitem,"task_dt_tm",cnvtdatetime(sysdate))
   ENDFOR
   SET hivitem = uar_srvadditem(hreq,"workflow")
   SET istat = uar_srvsetshort(hivitem,"bagCountingInd",1)
   SET istat = - (1)
   SET istat = uar_crmperform(req_handle)
   IF (istat != 0)
    IF ((request->debug_ind=1))
     CALL echo("*****Failed to update infusion billing task for the following task_ids:")
     CALL echorecord(ib_tasks->complete_task_list)
    ENDIF
    CALL endexecution(0,"UpdateInactiveTasks",build("Failed to perform ",req_number,"."))
   ENDIF
   CALL uar_crmendreq(req_handle)
   CALL uar_crmendtask(task_handle)
   CALL uar_crmendapp(app_handle)
   IF ((request->debug_ind=1))
    CALL echo("********Exiting UpdateInactiveTasks********")
   ENDIF
 END ;Subroutine
 SUBROUTINE updateactivetasks(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering UpdateActiveTasks********")
   ENDIF
   DECLARE app_number = i4 WITH protect, noconstant(0)
   DECLARE app_handle = i4 WITH protect, noconstant(0)
   DECLARE task_number = i4 WITH protect, noconstant(0)
   DECLARE task_handle = i4 WITH protect, noconstant(0)
   DECLARE req_number = i4 WITH protect, noconstant(0)
   DECLARE req_handle = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE hivitem = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE istat = i4 WITH protect, noconstant(0)
   SET app_number = 600005
   SET app_handle = 0
   SET task_number = 560300
   SET task_handle = 0
   SET req_number = 560303
   SET req_handle = 0
   SET hreq = 0
   SET hitem = 0
   SET hivitem = 0
   SET istat = uar_crmbeginapp(app_number,app_handle)
   SET istat = uar_crmbegintask(app_handle,task_number,task_handle)
   SET istat = uar_crmbeginreq(task_handle,"",req_number,req_handle)
   SET hreq = uar_crmgetrequest(req_handle)
   IF (hreq=0)
    CALL endexecution(0,"UpdateActiveTasks",build("Failed to get Request handle to ",req_number,"."))
   ENDIF
   FOR (i = 1 TO size(ib_tasks->complete_task_list,5))
     SET hitem = uar_srvadditem(hreq,"mod_list")
     SET istat = uar_srvsetdouble(hitem,"task_id",ib_tasks->complete_task_list[i].task_id)
     SET istat = uar_srvsetstring(hitem,"task_status_meaning","COMPLETE")
     SET istat = uar_srvsetdate(hitem,"task_dt_tm",cnvtdatetime(sysdate))
   ENDFOR
   SET hivitem = uar_srvadditem(hreq,"workflow")
   SET istat = uar_srvsetshort(hivitem,"bagCountingInd",1)
   SET istat = - (1)
   SET istat = uar_crmperform(req_handle)
   IF (istat != 0)
    IF ((request->debug_ind=1))
     CALL echo("*****Failed to update infusion billing task for the following task_ids:")
     CALL echorecord(ib_tasks->complete_task_list)
    ENDIF
    CALL endexecution(0,"UpdateActiveTasks",build("Failed to perform ",req_number,"."))
   ENDIF
   CALL uar_crmendreq(req_handle)
   CALL uar_crmendtask(task_handle)
   CALL uar_crmendapp(app_handle)
   IF ((request->debug_ind=1))
    CALL echo("********Exiting UpdateActiveTasks********")
   ENDIF
 END ;Subroutine
 SUBROUTINE getpcaeventcodes(null)
   SELECT INTO "nl:"
    d.seq, vesc.event_set_cd, vec.event_cd
    FROM (dummyt d  WITH seq = value(2)),
     code_value cv,
     v500_event_set_code vesc,
     v500_event_set_explode vese,
     v500_event_code vec
    PLAN (d)
     JOIN (cv
     WHERE cv.concept_cki IN (pca_dose_cki, continuous_dose_cki)
      AND cv.code_set=93
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (vesc
     WHERE vesc.event_set_cd=cv.code_value)
     JOIN (vese
     WHERE vese.event_set_cd=vesc.event_set_cd)
     JOIN (vec
     WHERE vec.event_cd=vese.event_cd
      AND cnvtupper(vec.event_set_name)=cnvtupper(vesc.event_set_name))
    ORDER BY cv.concept_cki
    HEAD cv.concept_cki
     IF (cv.concept_cki=pca_dose_cki)
      pca_dose_cd = vec.event_cd
     ENDIF
     IF (cv.concept_cki=continuous_dose_cki)
      continuous_dose_cd = vec.event_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE storepcaevents(null)
   DECLARE ieventcnt = i4 WITH protect, noconstant(0)
   DECLARE ieventlistpos = i4 WITH protect, noconstant(0)
   DECLARE iorderlistpos = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   SET istat = alterlist(pca_events->order_list,size(task_create_struct->order_list,5))
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cmr
    PLAN (ce
     WHERE expand(iterator,1,size(task_create_struct->order_list,5),ce.order_id,task_create_struct->
      order_list[iterator].order_id)
      AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ce.event_cd IN (pca_dose_cd, continuous_dose_cd)
      AND (ce.updt_dt_tm=
     (SELECT
      max(updt_dt_tm)
      FROM clinical_event
      WHERE order_id=ce.order_id
       AND event_id=ce.event_id)))
     JOIN (cmr
     WHERE cmr.event_id=ce.parent_event_id
      AND cmr.iv_event_cd=beginbag_cd
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    ORDER BY ce.parent_event_id DESC
    HEAD ce.order_id
     iorderlistpos += 1, pca_events->order_list[iorderlistpos].order_id = ce.order_id, ieventlistpos
      = size(pca_events->order_list[iorderlistpos].event_list,5)
    HEAD ce.parent_event_id
     ieventcnt += 1
     IF ((size(pca_events->order_list[iorderlistpos].event_list,5) <= (ieventlistpos+ ieventcnt)))
      istat = alterlist(pca_events->order_list[iorderlistpos].event_list,(ieventlistpos+ ieventcnt))
     ENDIF
     pca_events->order_list[iorderlistpos].event_list[(ieventlistpos+ ieventcnt)].event_id = ce
     .parent_event_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fetchprefs(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering FetchPrefs********")
   ENDIF
   DECLARE spositioncd = c20 WITH public, noconstant("")
   DECLARE sfacilitycd = c20 WITH public, noconstant("")
   DECLARE snurseunitcd = c20 WITH public, noconstant("")
   DECLARE ssystem = c6 WITH public, noconstant("system")
   DECLARE ireqordercnt = i4 WITH protect, noconstant(0)
   DECLARE bfetchprefatdefaultlevel = i2 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   SET ireqordercnt = size(request->order_list,5)
   FREE RECORD orders
   RECORD orders(
     1 order_cnt = i4
     1 order_list[*]
       2 order_id = f8
       2 facility_cd = f8
       2 nurse_unit_cd = f8
     1 facility_cnt = i4
     1 unique_facility_list[*]
       2 facility_cd = f8
       2 ib_pref_value = i2
     1 nurse_unit_cnt = i4
     1 unique_nurse_unit_list[*]
       2 nurse_unit_cd = f8
       2 ib_pref_value = i2
   )
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = ireqordercnt),
     orders o,
     encounter e
    PLAN (d1)
     JOIN (o
     WHERE (o.order_id=request->order_list[d1.seq].order_id)
      AND o.catalog_type_cd=pharmacy_cd)
     JOIN (e
     WHERE e.encntr_id=o.encntr_id)
    ORDER BY o.order_id
    HEAD REPORT
     orders->order_cnt = 0, orders->facility_cnt = 0, orders->nurse_unit_cnt = 0
    HEAD o.order_id
     orders->order_cnt += 1
     IF (mod(orders->order_cnt,10)=1)
      istat = alterlist(orders->order_list,(orders->order_cnt+ 9))
     ENDIF
     IF (o.template_order_id > 0)
      orders->order_list[orders->order_cnt].order_id = o.template_order_id
     ELSE
      orders->order_list[orders->order_cnt].order_id = o.order_id
     ENDIF
     orders->order_list[orders->order_cnt].facility_cd = e.loc_facility_cd, orders->order_list[orders
     ->order_cnt].nurse_unit_cd = e.loc_nurse_unit_cd, bnurseunitfound = 0
     FOR (i = 1 TO orders->nurse_unit_cnt)
       IF ((e.loc_nurse_unit_cd=orders->unique_nurse_unit_list[i].nurse_unit_cd))
        bnurseunitfound = 1, i = (orders->nurse_unit_cnt+ 1)
       ENDIF
     ENDFOR
     bfacilityfound = 0
     FOR (i = 1 TO orders->facility_cnt)
       IF ((e.loc_facility_cd=orders->unique_facility_list[i].facility_cd))
        bfacilityfound = 1, i = (orders->facility_cnt+ 1)
       ENDIF
     ENDFOR
     IF (bnurseunitfound=0)
      orders->nurse_unit_cnt += 1, istat = alterlist(orders->unique_nurse_unit_list,orders->
       nurse_unit_cnt), orders->unique_nurse_unit_list[orders->nurse_unit_cnt].nurse_unit_cd = e
      .loc_nurse_unit_cd,
      orders->unique_nurse_unit_list[orders->nurse_unit_cnt].ib_pref_value = - (1)
     ENDIF
     IF (bfacilityfound=0)
      orders->facility_cnt += 1, istat = alterlist(orders->unique_facility_list,orders->facility_cnt),
      orders->unique_facility_list[orders->facility_cnt].facility_cd = e.loc_facility_cd,
      orders->unique_facility_list[orders->facility_cnt].ib_pref_value = - (1)
     ENDIF
    WITH nocounter
   ;end select
   SET iibprefval = - (1)
   SET dibtaskprefval = - (1)
   SET spositioncd = trim(cnvtstring(reqinfo->position_cd,20,2))
   SET istat = getprefbycontextint(pref_infusion_billing,"position",spositioncd,iibprefval)
   IF (iibprefval=0)
    IF ((request->debug_ind=1))
     CALL echo(
      "********infusion_billing pref set to 0 at position level - will not generate IB task.")
    ENDIF
    CALL endexecution(1,"FetchPrefs","infusion_billing pref set to 0 at position level.")
   ELSEIF (iibprefval=1)
    CALL echo("infusion_billing preference found at position level.")
    IF ((request->debug_ind=1))
     CALL echo("********infusion_billing pref set to 1 at position level.")
    ENDIF
    SET qualified_orders->order_cnt = orders->order_cnt
    SET istat = alterlist(qualified_orders->order_list,qualified_orders->order_cnt)
    FOR (i = 1 TO qualified_orders->order_cnt)
      SET qualified_orders->order_list[i].order_id = orders->order_list[i].order_id
    ENDFOR
   ELSE
    SET bfetchprefatfacilitylevel = 0
    IF ((request->debug_ind=1))
     CALL echo(
      "********infusion_billing pref not defined at position level - now fetching at nurse unit level."
      )
    ENDIF
    FOR (i = 1 TO orders->nurse_unit_cnt)
      SET iibprefval = - (1)
      SET snurseunitcd = trim(cnvtstring(orders->unique_nurse_unit_list[i].nurse_unit_cd,20,2))
      SET istat = getprefbycontextint(pref_infusion_billing,"nurse unit",snurseunitcd,iibprefval)
      SET orders->unique_nurse_unit_list[i].ib_pref_value = iibprefval
      IF ((request->debug_ind=1))
       CALL echo(build("********infusion_billing pref at nurse_unit_cd: ",snurseunitcd," = ",
         iibprefval))
      ENDIF
      IF ((iibprefval=- (1)))
       SET bfetchprefatfacilitylevel = 1
      ENDIF
    ENDFOR
    IF (bfetchprefatfacilitylevel=1)
     IF ((request->debug_ind=1))
      CALL echo(
       "********infusion_billing pref not defined at nurse unit level - now fetching at facility level."
       )
     ENDIF
     SET bfetchprefatdefaultlevel = 0
     FOR (i = 1 TO orders->facility_cnt)
       SET iibprefval = - (1)
       SET sfacilitycd = trim(cnvtstring(orders->unique_facility_list[i].facility_cd,20,2))
       SET istat = getprefbycontextint(pref_infusion_billing,"facility",sfacilitycd,iibprefval)
       SET orders->unique_facility_list[i].ib_pref_value = iibprefval
       IF ((request->debug_ind=1))
        CALL echo(build("********infusion_billing pref at facility_cd: ",sfacilitycd," = ",iibprefval
          ))
       ENDIF
       IF ((iibprefval=- (1)))
        SET bfetchprefatdefaultlevel = 1
       ENDIF
     ENDFOR
    ENDIF
    IF (bfetchprefatdefaultlevel=1)
     SET iibprefval = - (1)
     SET istat = getprefbycontextint(pref_infusion_billing,"default",ssystem,iibprefval)
     IF ((request->debug_ind=1))
      CALL echo(build("********infusion_billing pref at default level is: ",iibprefval))
     ENDIF
     FOR (i = 1 TO orders->facility_cnt)
       IF ((orders->unique_facility_list[i].ib_pref_value=- (1)))
        SET orders->unique_facility_list[i].ib_pref_value = iibprefval
       ENDIF
     ENDFOR
    ENDIF
    SET qualified_orders->order_cnt = 0
    FOR (i = 1 TO orders->order_cnt)
      FOR (k = 1 TO orders->nurse_unit_cnt)
        IF ((orders->order_list[i].nurse_unit_cd=orders->unique_nurse_unit_list[k].nurse_unit_cd))
         IF ((orders->unique_nurse_unit_list[k].ib_pref_value > 0))
          IF ((request->debug_ind=1))
           CALL echo(build("********infusion_billing pref at the nurse unit level is: ",iibprefval))
          ENDIF
          SET qualified_orders->order_cnt += 1
          IF (mod(qualified_orders->order_cnt,10)=1)
           SET istat = alterlist(qualified_orders->order_list,(qualified_orders->order_cnt+ 9))
          ENDIF
          SET qualified_orders->order_list[qualified_orders->order_cnt].order_id = orders->
          order_list[i].order_id
          SET k = (orders->nurse_unit_cnt+ 1)
         ELSEIF ((orders->unique_nurse_unit_list[k].ib_pref_value=- (1)))
          FOR (j = 1 TO orders->facility_cnt)
            IF ((orders->order_list[i].facility_cd=orders->unique_facility_list[j].facility_cd))
             IF ((orders->unique_facility_list[j].ib_pref_value > 0))
              SET qualified_orders->order_cnt += 1
              IF (mod(qualified_orders->order_cnt,10)=1)
               SET istat = alterlist(qualified_orders->order_list,(qualified_orders->order_cnt+ 9))
              ENDIF
              SET qualified_orders->order_list[qualified_orders->order_cnt].order_id = orders->
              order_list[i].order_id
              SET j = (orders->facility_cnt+ 1)
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
    SET istat = alterlist(qualified_orders->order_list,qualified_orders->order_cnt)
    IF ((qualified_orders->order_cnt <= 0))
     IF ((request->debug_ind=1))
      CALL echo(
       "********infusion_billing pref is set to 0 or not defined at position, nurse unit, facility, and default levels."
       )
      CALL echo("********No orders qualify to generate infusion billing task. Exiting script.")
     ENDIF
     CALL endexecution(1,"FetchPrefs","infusion_billing pref set to 0 at all levels.")
    ENDIF
   ENDIF
   SET istat = getprefbycontextdbl(pref_infusion_billing_task,"default",ssystem,dibtaskprefval)
   SET istat = getprefbycontextint(pref_infusion_billing,"default",ssystem,iibprefval)
   IF (dibtaskprefval <= 0)
    IF ((request->debug_ind=1))
     CALL echo(
      "********infusion_billing_task pref is not defined at default level - will not generate IB task."
      )
    ENDIF
    CALL endexecution(1,"FetchPrefs","infusion_billing_task pref not defined.")
   ELSE
    IF ((request->debug_ind=1))
     CALL echo(build("********infusion_billing_task pref set at default level is:",dibtaskprefval))
    ENDIF
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("********Exiting FetchPrefs********")
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
#exit_script
 IF ((request->debug_ind != 1))
  FREE RECORD qualified_orders
  FREE RECORD task_create_struct
  FREE RECORD ib_task_exist
  FREE RECORD encntr_cs_ext_request
  FREE RECORD encntr_cs_ext_reply
  FREE RECORD route_cs_ext_request
  FREE RECORD route_cs_ext_reply
  FREE RECORD add_request
  FREE RECORD events
  FREE RECORD ib_tasks
  FREE RECORD orders
 ENDIF
 SET last_mod = "009"
 SET mod_date = "12/06/2018"
 SET modify = nopredeclare
END GO
