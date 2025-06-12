CREATE PROGRAM bsc_get_infuse_related_orders:dba
 SET modify = predeclare
 RECORD reply(
   1 order_list[*]
     2 order_id = f8
     2 pending_ind = i2
     2 existing_ind = i2
     2 protocol_order_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE unchart_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE iordercnt = i4 WITH protect, noconstant(0)
 DECLARE iencntrcnt = i4 WITH protect, noconstant(0)
 DECLARE dibtaskprefval = f8 WITH protect, noconstant(0)
 DECLARE istat = i2 WITH protect, noconstant(0)
 DECLARE istart = i4 WITH protect, noconstant(1)
 DECLARE isize = i4 WITH protect, constant(50)
 DECLARE itotal = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE slastmod = c3 WITH private, noconstant("")
 DECLARE smoddate = c10 WITH private, noconstant("")
 SET reply->status_data.status = "F"
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
 IF (getprefbycontextdbl("INFUSION_BILLING_TASK","default","system",dibtaskprefval)=ipreferror)
  CALL echo("Error Reading Preference.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (dibtaskprefval <= 0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 SET iencntrcnt = size(request->encntr_list,5)
 SET itotal = (ceil((cnvtreal(iencntrcnt)/ isize)) * isize)
 SET istat = alterlist(request->encntr_list,itotal)
 SET istart = 1
 FOR (i = (iencntrcnt+ 1) TO itotal)
   SET request->encntr_list[i].encntr_id = request->encntr_list[iencntrcnt].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((itotal - 1)/ isize)))),
   task_activity ta,
   orders o
  PLAN (d1
   WHERE initarray(istart,evaluate(d1.seq,1,1,(istart+ isize))))
   JOIN (ta
   WHERE expand(i,istart,(istart+ (isize - 1)),(ta.encntr_id+ 0),request->encntr_list[i].encntr_id)
    AND (ta.person_id=request->person_id)
    AND ((ta.reference_task_id+ 0)=dibtaskprefval))
   JOIN (o
   WHERE o.order_id=ta.order_id)
  ORDER BY ta.order_id
  HEAD REPORT
   iordercnt = 0
  HEAD ta.order_id
   IF (ta.task_status_cd=pending_cd)
    iordercnt += 1
    IF (mod(iordercnt,10)=1)
     istat = alterlist(reply->order_list,(iordercnt+ 9))
    ENDIF
    reply->order_list[iordercnt].order_id = ta.order_id, reply->order_list[iordercnt].pending_ind = 1,
    reply->order_list[iordercnt].existing_ind = 0,
    reply->order_list[iordercnt].protocol_order_id = o.protocol_order_id
   ENDIF
  FOOT REPORT
   istat = alterlist(reply->order_list,iordercnt)
  WITH nocounter
 ;end select
 SET istart = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((itotal - 1)/ isize)))),
   infusion_billing_event ibe,
   infusion_ce_reltn icr,
   orders o
  PLAN (d1
   WHERE initarray(istart,evaluate(d1.seq,1,1,(istart+ isize))))
   JOIN (ibe
   WHERE expand(i,istart,(istart+ (isize - 1)),ibe.encntr_id,request->encntr_list[i].encntr_id)
    AND ibe.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (icr
   WHERE icr.infusion_billing_event_id=ibe.infusion_billing_event_id)
   JOIN (o
   WHERE o.order_id=ibe.order_id)
  ORDER BY ibe.order_id
  HEAD ibe.order_id
   borderfound = 0
   FOR (i = 1 TO iordercnt)
     IF ((ibe.order_id=reply->order_list[i].order_id))
      borderfound = 1, reply->order_list[i].existing_ind = 1, i = (iordercnt+ 1)
     ENDIF
   ENDFOR
   IF (borderfound=0)
    iordercnt += 1, istat = alterlist(reply->order_list,iordercnt), reply->order_list[iordercnt].
    order_id = ibe.order_id,
    reply->order_list[iordercnt].pending_ind = 0, reply->order_list[iordercnt].existing_ind = 1,
    reply->order_list[iordercnt].protocol_order_id = o.protocol_order_id
   ENDIF
  FOOT REPORT
   istat = alterlist(reply->order_list,iordercnt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "bsc_get_infuse_related_orders"
  SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
  CALL echo(errmsg)
 ELSEIF (iordercnt=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.targetobjectname = "iOrderCnt = 0"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SET slastmod = "004"
 SET smoddate = "12/17/2010"
 SET modify = nopredeclare
END GO
