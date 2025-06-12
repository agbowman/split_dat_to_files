CREATE PROGRAM bsc_get_med_interval:dba
 RECORD reply(
   1 frequency_min_list[*]
     2 frequency_schedule_id = f8
     2 order_id = f8
     2 interval_minutes = i4
     2 frequency_cd = f8
   1 administration_grace_period = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD order_to_template(
   1 order_to_template_list[*]
     2 order_id = f8
     2 template_order_id = f8
 ) WITH protect
 RECORD hybrid(
   1 hybrid_list[*]
     2 frequency_id = f8
     2 freq_qualifier = f8
     2 frequency_cd = f8
 ) WITH protect
 RECORD adhoc_freq_ids(
   1 adhoc_freq_id_list[*]
     2 frequency_id = f8
     2 frequency_cd = f8
     2 order_id = f8
 ) WITH protect
 RECORD reqfreq(
   1 frequency_cd = f8
   1 order_id = f8
   1 order_provider_id = f8
   1 catalog_cd = f8
   1 med_class_cd = f8
   1 nurse_unit_cd = f8
   1 activity_type_cd = f8
   1 exclude_inactive_sched_ind = i2
 ) WITH protect
 RECORD repfreq(
   1 frequency_id = f8
 ) WITH protect
 IF (size(request->frequency_schedule_list,5) > 0
  AND size(request->order_list,5) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "Cannot process order ids AND frequency ids"
  CALL echo("order ids and schedule ids recived, use one or the other.")
  GO TO exit_script
 ENDIF
 IF (size(request->frequency_schedule_list,5)=0
  AND size(request->order_list,5)=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "No frequency ids or order ids submitted"
  CALL echo("Empty List")
  GO TO exit_script
 ENDIF
 DECLARE getmipref(null) = null
 DECLARE cminutes = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"MINUTES"))
 DECLARE chours = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"HOURS"))
 DECLARE cdays = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"DAYS"))
 DECLARE cweeks = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"WEEKS"))
 DECLARE cordercd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE templistallocatenum = i4 WITH protect, constant(10)
 DECLARE ordercnt = i4 WITH protect, noconstant(0)
 DECLARE templatecnt = i4 WITH protect, noconstant(0)
 DECLARE requestedcnt = i4 WITH protect, noconstant(0)
 DECLARE freqcnt = i4 WITH protect, noconstant(0)
 DECLARE hybridcnt = i4 WITH protect, noconstant(0)
 DECLARE adhoccnt = i4 WITH protect, noconstant(0)
 DECLARE idxhybrid = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE orderidx = i4 WITH protect, noconstant(0)
 DECLARE hybrididx = i4 WITH protect, noconstant(0)
 DECLARE replyidx = i4 WITH protect, noconstant(0)
 DECLARE nstat = i2 WITH protect, noconstant(0)
 DECLARE interval_mins = i4 WITH protect, noconstant(- (1))
 DECLARE req_disp_cnt = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE nsize = i4 WITH protect, noconstant(50)
 DECLARE ntotal = i4 WITH noconstant((ceil((cnvtreal(req_disp_cnt)/ nsize)) * nsize))
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE adhoc_freq_ind = i2 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE pref_set = i2 WITH protect, noconstant(0)
 DECLARE lidx1 = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
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
 SET reply->status_data.status = "F"
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
 CALL getmipref(null)
 IF (size(request->order_list,5) > 0)
  SET requestedcnt = size(request->order_list,5)
  SET nstat = alterlist(reply->frequency_min_list,requestedcnt)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(requestedcnt)),
    orders o
   PLAN (d1)
    JOIN (o
    WHERE (o.order_id=request->order_list[d1.seq].order_id))
   ORDER BY o.order_id
   HEAD REPORT
    ordercnt = 0, templatecnt = 0
   DETAIL
    IF (o.template_order_id > 0)
     templatecnt += 1
     IF (((mod(templatecnt,templistallocatenum)=0) OR (templatecnt=1)) )
      nstat = alterlist(order_to_template->order_to_template_list,(templatecnt+ templistallocatenum))
     ENDIF
     order_to_template->order_to_template_list[templatecnt].order_id = o.order_id, order_to_template
     ->order_to_template_list[templatecnt].template_order_id = o.template_order_id
    ELSE
     lidx2 = locateval(lidx1,1,ordercnt,o.order_id,reply->frequency_min_list[lidx1].order_id)
     IF (lidx2=0)
      ordercnt += 1, reply->frequency_min_list[ordercnt].order_id = o.order_id, reply->
      frequency_min_list[ordercnt].frequency_schedule_id = o.frequency_id
     ELSE
      reply->frequency_min_list[lidx2].frequency_schedule_id = o.frequency_id
     ENDIF
    ENDIF
   FOOT REPORT
    nstat = alterlist(request->order_list,requestedcnt), nstat = alterlist(order_to_template->
     order_to_template_list,templatecnt)
   WITH nocounter
  ;end select
  IF (templatecnt > 0)
   SET ntotal = (ceil((cnvtreal(templatecnt)/ nsize)) * nsize)
   SET nstat = alterlist(order_to_template->order_to_template_list,ntotal)
   FOR (lidx = 1 TO ntotal)
     IF ((0=order_to_template->order_to_template_list[lidx].order_id))
      SET order_to_template->order_to_template_list[lidx].order_id = order_to_template->
      order_to_template_list[1].order_id
      SET order_to_template->order_to_template_list[lidx].template_order_id = order_to_template->
      order_to_template_list[1].template_order_id
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(templatecnt)),
     orders o
    PLAN (d1)
     JOIN (o
     WHERE (o.order_id=order_to_template->order_to_template_list[d1.seq].template_order_id))
    ORDER BY o.order_id
    DETAIL
     FOR (orderidx = 1 TO templatecnt)
       IF ((order_to_template->order_to_template_list[orderidx].template_order_id=o.order_id))
        lidx2 = locateval(lidx1,1,requestedcnt,order_to_template->order_to_template_list[orderidx].
         order_id,request->order_list[lidx1].order_id)
        IF (lidx2 > 0)
         lidx2 = locateval(lidx1,1,ordercnt,order_to_template->order_to_template_list[orderidx].
          order_id,reply->frequency_min_list[lidx1].order_id)
         IF (lidx2=0)
          ordercnt += 1, reply->frequency_min_list[ordercnt].frequency_schedule_id = o.frequency_id,
          reply->frequency_min_list[ordercnt].order_id = order_to_template->order_to_template_list[
          orderidx].order_id
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   SET nstat = alterlist(order_to_template->order_to_template_list,templatecnt)
   SET nstat = alterlist(reply->frequency_min_list,ordercnt)
  ENDIF
 ELSE
  SET requestedcnt = size(request->frequency_schedule_list,5)
  SET nstat = alterlist(reply->frequency_min_list,requestedcnt)
  FOR (lidx = 1 TO requestedcnt)
   SET reply->frequency_min_list[lidx].frequency_schedule_id = request->frequency_schedule_list[lidx]
   .frequency_schedule_id
   SET reply->frequency_min_list[lidx].order_id = 0
  ENDFOR
 ENDIF
 SET start = 1
 SET nsize = 50
 SET req_disp_cnt = size(reply->frequency_min_list,5)
 SET ntotal = (ceil((cnvtreal(req_disp_cnt)/ nsize)) * nsize)
 SET nstat = alterlist(order_to_template->order_to_template_list,ntotal)
 SET nstat = alterlist(reply->frequency_min_list,ntotal)
 FOR (lidx = 1 TO ntotal)
   IF ((0=reply->frequency_min_list[lidx].frequency_schedule_id))
    SET reply->frequency_min_list[lidx].frequency_schedule_id = reply->frequency_min_list[1].
    frequency_schedule_id
   ENDIF
 ENDFOR
 IF (adhoc_freq_ind=1)
  SET lidx2 = 0
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    frequency_schedule fs
   PLAN (d1
    WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
    JOIN (fs
    WHERE expand(lidx,start,(start+ (nsize - 1)),fs.frequency_id,reply->frequency_min_list[lidx].
     frequency_schedule_id))
   ORDER BY d1.seq
   DETAIL
    lidx2 += 1
    IF (fs.min_interval_unit_cd=0.0
     AND fs.parent_entity="ORDERS"
     AND fs.frequency_id > 0.0)
     adhoccnt += 1
     IF (((mod(adhoccnt,templistallocatenum)) OR (adhoccnt=1)) )
      nstat = alterlist(adhoc_freq_ids->adhoc_freq_id_list,(adhoccnt+ templistallocatenum))
     ENDIF
     adhoc_freq_ids->adhoc_freq_id_list[adhoccnt].frequency_id = fs.frequency_id, adhoc_freq_ids->
     adhoc_freq_id_list[adhoccnt].frequency_cd = fs.frequency_cd, adhoc_freq_ids->adhoc_freq_id_list[
     adhoccnt].order_id = reply->frequency_min_list[lidx2].order_id
    ENDIF
   WITH nocounter
  ;end select
  SET nstat = alterlist(adhoc_freq_ids->adhoc_freq_id_list,adhoccnt)
  IF (debug_ind > 0)
   CALL echorecord(adhoc_freq_ids)
  ENDIF
  FOR (lidx = 1 TO size(adhoc_freq_ids->adhoc_freq_id_list,5))
    SELECT INTO "nl:"
     FROM orders o,
      order_action oa,
      encounter e
     PLAN (o
      WHERE (o.order_id=adhoc_freq_ids->adhoc_freq_id_list[lidx].order_id))
      JOIN (oa
      WHERE o.order_id=oa.order_id
       AND oa.action_type_cd=cordercd
       AND (oa.action_sequence=
      (SELECT
       max(oa2.action_sequence)
       FROM order_action oa2
       WHERE oa.order_id=oa2.order_id
        AND oa2.action_type_cd=cordercd)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
     DETAIL
      reqfreq->order_provider_id = oa.order_provider_id, reqfreq->catalog_cd = o.catalog_cd, reqfreq
      ->nurse_unit_cd = e.loc_nurse_unit_cd,
      reqfreq->activity_type_cd = o.activity_type_cd
     WITH nocounter
    ;end select
    SET reqfreq->frequency_cd = adhoc_freq_ids->adhoc_freq_id_list[lidx].frequency_cd
    SET reqfreq->order_id = 0.0
    SET reqfreq->med_class_cd = 0.0
    SET reqfreq->exclude_inactive_sched_ind = 0
    EXECUTE rx_get_freq_id
    FOR (lidx2 = 1 TO size(reply->frequency_min_list,5))
      IF ((adhoc_freq_ids->adhoc_freq_id_list[lidx].frequency_id=reply->frequency_min_list[lidx2].
      frequency_schedule_id))
       SET reply->frequency_min_list[lidx2].frequency_schedule_id = repfreq->frequency_id
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   frequency_schedule fs
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
   JOIN (fs
   WHERE expand(lidx,start,(start+ (nsize - 1)),fs.frequency_id,reply->frequency_min_list[lidx].
    frequency_schedule_id))
  ORDER BY fs.frequency_id
  HEAD REPORT
   freqcnt = 0
  HEAD fs.frequency_id
   freqcnt += 1
  DETAIL
   IF (fs.min_interval_nbr >= 0
    AND fs.min_interval_unit_cd > 0)
    IF (fs.min_interval_unit_cd=cminutes)
     interval_mins = fs.min_interval_nbr
    ELSEIF (fs.min_interval_unit_cd=chours)
     interval_mins = (fs.min_interval_nbr * 60)
    ELSEIF (fs.min_interval_unit_cd=cdays)
     interval_mins = ((fs.min_interval_nbr * 24) * 60)
    ELSE
     interval_mins = - (1)
    ENDIF
   ELSE
    IF (fs.frequency_type=3)
     hybridcnt += 1
     IF (((mod(hybridcnt,templistallocatenum)) OR (hybridcnt=1)) )
      nstat = alterlist(hybrid->hybrid_list,(hybridcnt+ templistallocatenum))
     ENDIF
     hybrid->hybrid_list[hybridcnt].frequency_id = fs.frequency_id, hybrid->hybrid_list[hybridcnt].
     freq_qualifier = fs.freq_qualifier, hybrid->hybrid_list[hybridcnt].frequency_cd = fs
     .frequency_cd
     IF (fs.interval_units=1)
      interval_mins = fs.interval
     ELSEIF (fs.interval_units=2)
      interval_mins = (fs.interval * 60)
     ELSEIF (fs.interval_units=3)
      interval_mins = ((fs.interval * 24) * 60)
     ELSEIF (fs.interval_units=4)
      interval_mins = (((fs.interval * 7) * 24) * 60)
     ELSE
      interval_mins = - (1)
     ENDIF
    ELSE
     interval_mins = - (1)
    ENDIF
   ENDIF
   FOR (replyidx = 1 TO size(reply->frequency_min_list,5))
     IF ((reply->frequency_min_list[replyidx].frequency_schedule_id=fs.frequency_id))
      reply->frequency_min_list[replyidx].interval_minutes = interval_mins, reply->
      frequency_min_list[replyidx].frequency_cd = fs.frequency_cd
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SET nstat = alterlist(reply->frequency_min_list,requestedcnt)
 IF (hybridcnt > 0)
  SET req_disp_cnt = size(hybrid->hybrid_list,5)
  SET ntotal = (ceil((cnvtreal(req_disp_cnt)/ nsize)) * nsize)
  SET nstat = alterlist(hybrid->hybrid_list,ntotal)
  FOR (lidx = 1 TO ntotal)
    IF ((0=hybrid->hybrid_list[lidx].frequency_id))
     SET hybrid->hybrid_list[lidx].frequency_id = hybrid->hybrid_list[1].frequency_id
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    scheduled_time_of_day stod
   PLAN (d1
    WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
    JOIN (stod
    WHERE expand(lidx,start,(start+ (nsize - 1)),stod.frequency_cd,hybrid->hybrid_list[lidx].
     frequency_cd))
   DETAIL
    FOR (hybrididx = 1 TO hybridcnt)
      IF ((hybrid->hybrid_list[hybrididx].freq_qualifier=stod.freq_qualifier)
       AND (hybrid->hybrid_list[hybrididx].frequency_cd=stod.frequency_cd))
       FOR (replyidx = 1 TO requestedcnt)
         IF ((hybrid->hybrid_list[hybrididx].frequency_id=reply->frequency_min_list[replyidx].
         frequency_schedule_id))
          reply->frequency_min_list[replyidx].interval_minutes = - (1)
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
  CALL echo(errmsg)
 ELSEIF (size(reply->frequency_min_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 GO TO exit_script
 SUBROUTINE getmipref(null)
   DECLARE system = c20 WITH public, noconstant("")
   DECLARE iprefstatus = i4 WITH public, noconstant(0)
   SET system = "system"
   SET iprefstatus = getprefbycontextint("MED_ADMIN_ADHOC_FREQ","default",system,adhoc_freq_ind)
   IF (iprefstatus=ipreferror)
    CALL echo("Error Getting Preference at the default level")
    SET adhoc_freq_ind = 0
   ENDIF
 END ;Subroutine
#exit_script
 SET last_mod = "011"
 SET mod_date = "06/16/2015"
 IF (debug_ind > 0)
  CALL echorecord(reply)
 ENDIF
 SET modify = nopredeclare
END GO
