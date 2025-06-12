CREATE PROGRAM dd_fax_pref_lookup:dba
 SUBROUTINE (errorcheck(opname=vc,targetname=vc) =i2)
   DECLARE problemcount = i2
   SET problemcount = errorchecknosetcommitind(opname,targetname)
   IF (problemcount > 0)
    SET reqinfo->commit_ind = 2
   ENDIF
   RETURN(problemcount)
 END ;Subroutine
 SUBROUTINE (errorchecknosetcommitind(opname=vc,targetname=vc) =i2)
   DECLARE errormessage = vc
   DECLARE errorcode = i2
   DECLARE errorcount = i2
   DECLARE retval = i2
   SET retval = 0
   SET errorcode = error(errormessage,0)
   IF (errorcode != 0)
    IF (validate(reply)=1)
     SET errorcount = size(reply->status_data.subeventstatus,5)
     WHILE (errorcode != 0
      AND errorcount < 50)
       SET retval = 1
       SET reply->status_data.status = "F"
       SET errorcount += 1
       SET stat = alterlist(reply->status_data.subeventstatus,errorcount)
       SET reply->status_data.subeventstatus[errorcount].operationname = opname
       SET reply->status_data.subeventstatus[errorcount].operationstatus = "F"
       SET reply->status_data.subeventstatus[errorcount].targetobjectname = targetname
       SET reply->status_data.subeventstatus[errorcount].targetobjectvalue = errormessage
       SET errorcode = error(errormessage,0)
     ENDWHILE
    ELSE
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE (frnaddreplytimestampname(opname=vc,starttime=f8) =i2)
  IF (validate(reply)=1)
   DECLARE timeentryindex = i2
   SET timeentryindex = (1+ size(reply->status_data.subeventstatus,5))
   SET stat = alterlist(reply->status_data.subeventstatus,timeentryindex)
   SET reply->status_data.subeventstatus[timeentryindex].operationname = opname
   SET reply->status_data.subeventstatus[timeentryindex].operationstatus = "T"
   SET reply->status_data.subeventstatus[timeentryindex].targetobjectname = "Elapsed Time in Script"
   SET reply->status_data.subeventstatus[timeentryindex].targetobjectvalue = build2(cnvtint((curtime3
      - starttime)),"0 ms")
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE (frnaddreplytimestamp(starttime=f8) =i2)
  IF (validate(reply)=1)
   DECLARE timeentryindex = i2
   SET timeentryindex = (1+ size(reply->status_data.subeventstatus,5))
   SET stat = alterlist(reply->status_data.subeventstatus,timeentryindex)
   SET reply->status_data.subeventstatus[timeentryindex].operationname = ""
   SET reply->status_data.subeventstatus[timeentryindex].operationstatus = "T"
   SET reply->status_data.subeventstatus[timeentryindex].targetobjectname = "Elapsed Time in Script"
   SET reply->status_data.subeventstatus[timeentryindex].targetobjectvalue = build2(cnvtint((curtime3
      - starttime)),"0 ms")
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE (frnadderror(opname=vc,targetname=vc) =i2)
  IF (validate(reply)=1)
   DECLARE icount = i4
   SET icount = (1+ size(reply->status_data.subeventstatus,5))
   SET stat = alterlist(reply->status_data.subeventstatus,icount)
   SET reply->status_data.subeventstatus[icount].operationname = targetname
   SET reply->status_data.subeventstatus[icount].operationstatus = "F"
   SET reply->status_data.subeventstatus[icount].targetobjectname = targetname
   SET reply->status_data.subeventstatus[icount].targetobjectvalue = opname
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE (frnaddstatus(opname=vc,targetname=vc,targetvalue=vc,operationstatus=vc) =i2)
  IF (validate(reply)=1)
   DECLARE icount = i4
   SET icount = (1+ size(reply->status_data.subeventstatus,5))
   SET stat = alterlist(reply->status_data.subeventstatus,icount)
   SET reply->status_data.subeventstatus[icount].operationname = opname
   SET reply->status_data.subeventstatus[icount].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[icount].targetobjectname = targetname
   SET reply->status_data.subeventstatus[icount].targetobjectvalue = targetvalue
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE (frnmsgwrite(sdomainname=vc,seventname=vc,smessage=vc) =i2)
   DECLARE ilogtype = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=sdomainname
     AND di.info_name="fn_log"
    DETAIL
     ilogtype = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   IF (ilogtype=1)
    DECLARE emsglog_commit = i4 WITH constant(0)
    DECLARE emsglvl_debug = i4 WITH constant(4)
    DECLARE hmsg = i4 WITH noconstant(0)
    EXECUTE msgrtl
    SET hmsg = uar_msgopen("fn_log")
    CALL uar_msgsetlevel(hmsg,emsglvl_debug)
    CALL uar_msgwrite(hmsg,emsglog_commit,nullterm(seventname),emsglvl_debug,nullterm(smessage))
    CALL uar_msgclose(hmsg)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (gettrackgroupforencounter(_encntrid=f8(val)) =f8)
   DECLARE gettrackgroupforencounter = f8 WITH private, noconstant(curtime3)
   DECLARE orderdir_ascend = i4 WITH constant(0), protect
   DECLARE orderdir_desc = i4 WITH constant(1), protect
   DECLARE orderbydirection = i4 WITH noconstant(orderdir_ascend)
   FREE RECORD pref_request
   RECORD pref_request(
     1 context = vc
     1 context_id = vc
     1 section = vc
     1 section_id = vc
     1 groups[*]
       2 name = vc
     1 debug = vc
   )
   FREE RECORD pref_reply
   RECORD pref_reply(
     1 entries[*]
       2 name = vc
       2 values[*]
         3 value = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE curvalue = i4 WITH private, noconstant(0)
   DECLARE curpref = i4 WITH private, noconstant(1)
   DECLARE prefcnt = i4 WITH private, noconstant(0)
   SET pref_request->context = "default"
   SET pref_request->context_id = "system"
   SET pref_request->section = "module"
   SET pref_request->section_id = "tracking"
   SET stat = alterlist(pref_request->groups,1)
   SET pref_request->groups[1].name = "common"
   SET pref_request->debug = "0"
   EXECUTE fn_get_prefs  WITH replace("REQUEST",pref_request), replace("REPLY",pref_reply)
   IF ((pref_reply->status_data.status="F"))
    CALL echo("fn_get_prefs returned failed status")
   ENDIF
   SET curpref = 1
   SET prefcnt = size(pref_reply->entries,5)
   FOR (curpref = 1 TO prefcnt)
     IF ((pref_reply->entries[curpref].name="send charging performing location"))
      FOR (curvalue = 1 TO size(pref_reply->entries[curpref].values,5))
        IF ((pref_reply->entries[curpref].values[curvalue].value="1"))
         SET orderbydirection = orderdir_desc
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (validate(debug_ind,0)=1)
    CALL echo(build("orderByDirection: ",orderbydirection))
   ENDIF
   DECLARE dtrackgroupcd = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM tracking_item ti,
     tracking_checkin tc
    PLAN (ti
     WHERE ti.encntr_id=_encntrid)
     JOIN (tc
     WHERE tc.tracking_id=ti.tracking_id)
    ORDER BY orderdir(tc.checkin_dt_tm,orderbydirection)
    DETAIL
     IF (uar_get_code_meaning(tc.tracking_group_cd)="ER")
      dtrackgroupcd = tc.tracking_group_cd
     ENDIF
    WITH nocounter
   ;end select
   IF (dtrackgroupcd=0.0)
    SELECT INTO "nl:"
     FROM tracking_item ti,
      tracking_checkin tc
     PLAN (ti
      WHERE ti.encntr_id=_encntrid)
      JOIN (tc
      WHERE tc.tracking_id=ti.tracking_id)
     ORDER BY orderdir(tc.checkin_dt_tm,orderbydirection)
     DETAIL
      dtrackgroupcd = tc.tracking_group_cd
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("GetTrackGroupForEncounter -> ",build2(cnvtint((curtime3 -
       gettrackgroupforencounter))),"0 ms"))
   RETURN(dtrackgroupcd)
 END ;Subroutine
 SUBROUTINE (gettrackgroupforencounterbynurseunit(_encntrid=f8(val)) =f8)
   DECLARE gettrackgroupforencntrbynurseunit = f8 WITH private, noconstant(curtime3)
   DECLARE dtrackgroupcd = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM encounter e,
     track_group tg
    PLAN (e
     WHERE e.encntr_id=_encntrid
      AND e.active_ind=1
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (tg
     WHERE tg.parent_value=e.loc_nurse_unit_cd
      AND tg.child_table="TRACK_ASSOC")
    DETAIL
     dtrackgroupcd = tg.tracking_group_cd
    WITH nocounter
   ;end select
   CALL echo(build("GetTrackGroupForEncntrByNurseUnit -> ",build2(cnvtint((curtime3 -
       gettrackgroupforencntrbynurseunit))),"0 ms"))
   RETURN(dtrackgroupcd)
 END ;Subroutine
 SUBROUTINE (gettrackgroupforencounterbytrackinglocation(_encntrid=f8(val)) =f8)
   DECLARE dtrackgroupcd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM tracking_item ti,
     tracking_locator tl,
     track_group tg,
     code_value cv
    PLAN (ti
     WHERE ti.encntr_id=_encntrid
      AND ti.active_ind=1)
     JOIN (tl
     WHERE tl.tracking_id=ti.tracking_id)
     JOIN (tg
     WHERE tg.parent_value=tl.loc_nurse_unit_cd
      AND tg.child_table="TRACK_ASSOC")
     JOIN (cv
     WHERE cv.code_value=tg.tracking_group_cd
      AND cv.cdf_meaning="ER"
      AND cv.code_set=16370
      AND cv.active_ind=1)
    ORDER BY tl.locator_create_date DESC
    HEAD REPORT
     dtrackgroupcd = tg.tracking_group_cd
    WITH nocounter
   ;end select
   RETURN(dtrackgroupcd)
 END ;Subroutine
 SUBROUTINE (getparametervalues(_index=i4(val),_value_rec=vc(ref)) =null)
   DECLARE getparametervalues = f8 WITH private, noconstant(curtime3)
   DECLARE par = vc WITH noconstant(""), protect
   DECLARE lnum = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(1), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE cnt2 = i4 WITH noconstant(0), protect
   DECLARE param_value = f8 WITH noconstant(0.0), protect
   DECLARE param_value_str = vc WITH noconstant(""), protect
   SET par = cnvtupper(reflect(parameter(_index,0)))
   IF (validate(debug_ind,0)=1)
    CALL echo(build("par: ",par))
   ENDIF
   IF (((par="F8") OR (par="I4")) )
    SET param_value = parameter(_index,0)
    IF (param_value > 0)
     SET _value_rec->cnt += 1
     SET stat = alterlist(_value_rec->qual,_value_rec->cnt)
     SET _value_rec->qual[_value_rec->cnt].value = param_value
    ENDIF
   ELSEIF (substring(1,1,par)="C")
    SET param_value_str = parameter(_index,0)
    IF (trim(param_value_str,3) != "")
     SET _value_rec->cnt += 1
     SET stat = alterlist(_value_rec->qual,_value_rec->cnt)
     SET _value_rec->qual[_value_rec->cnt].value = trim(param_value_str,3)
    ENDIF
   ELSEIF (substring(1,1,par)="L")
    SET lnum = 1
    WHILE (lnum > 0)
     SET par = reflect(parameter(_index,lnum))
     IF (par != " ")
      IF (((par="F8") OR (par="I4")) )
       SET param_value = parameter(_index,lnum)
       IF (param_value > 0)
        SET _value_rec->cnt += 1
        SET stat = alterlist(_value_rec->qual,_value_rec->cnt)
        SET _value_rec->qual[_value_rec->cnt].value = param_value
       ENDIF
       SET lnum += 1
      ELSEIF (substring(1,1,par)="C")
       SET param_value_str = parameter(_index,lnum)
       IF (trim(param_value_str,3) != "")
        SET _value_rec->cnt += 1
        SET stat = alterlist(_value_rec->qual,_value_rec->cnt)
        SET _value_rec->qual[_value_rec->cnt].value = trim(param_value_str,3)
       ENDIF
       SET lnum += 1
      ENDIF
     ELSE
      SET lnum = 0
     ENDIF
    ENDWHILE
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(_value_rec)
   ENDIF
   CALL echo(build("GetParameterValues -> ",build2(cnvtint((curtime3 - getparametervalues))),"0 ms"))
 END ;Subroutine
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null)
   DECLARE putjsonrecordtofile = f8 WITH private, noconstant(curtime3)
   DECLARE svalue = vc WITH noconstant(trim(cnvtrectojson(record_data),3))
   CALL echo(svalue)
   IF (size(svalue) > 0)
    IF (validate(_memory_reply_string)=1)
     SET _memory_reply_string = svalue
    ELSE
     FREE RECORD putrequest
     RECORD putrequest(
       1 source_dir = vc
       1 source_filename = vc
       1 nbrlines = i4
       1 line[*]
         2 linedata = vc
       1 overflowpage[*]
         2 ofr_qual[*]
           3 ofr_line = vc
       1 isblob = c1
       1 document_size = i4
       1 document = gvc
     )
     SET putrequest->source_dir =  $OUTDEV
     SET putrequest->isblob = "1"
     SET putrequest->document = svalue
     SET putrequest->document_size = size(svalue)
     EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
    ENDIF
   ENDIF
   CALL echo(build("PutJSONRecordToFile -> ",build2(cnvtint((curtime3 - putjsonrecordtofile))),"0 ms"
     ))
 END ;Subroutine
 RECORD reply(
   1 output_destination_cd = f8
   1 foll_prov_phs[*]
     2 followup_provider = vc
     2 phone[*]
       3 phone_id = f8
       3 phone_type_cd = f8
       3 phone_type_disp = c40
       3 phone_type_desc = c60
       3 phone_type_seq = i2
       3 default = i2
       3 phone_number = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ddcomplete = f8 WITH private, noconstant(curtime3)
 SET reply->status_data.status = "F"
 IF ((request->encounter_id <= 0.0))
  CALL frnaddstatus("read","request","encntr_id <= 0.0","I")
  GO TO exit_script
 ELSEIF ((request->user_id <= 0.0))
  CALL frnaddstatus("read","request","user_id <= 0.0","I")
  GO TO exit_script
 ENDIF
 DECLARE outputdestinationcode = f8 WITH protect, noconstant(0.0)
 DECLARE dtrackgroupcd = f8 WITH protect, noconstant(0.0)
 DECLARE dtrackingproviderroleid = f8 WITH protect, noconstant(0.0)
 DECLARE dphonetypecode = f8 WITH protect, noconstant(0.0)
 DECLARE sdefaultfaxstation = vc WITH protect, noconstant("")
 DECLARE strackingfaxstation = vc WITH protect, noconstant("")
 DECLARE srolefaxstation = vc WITH protect, noconstant("")
 DECLARE sdefaultfaxnum = vc WITH protect, noconstant("")
 DECLARE strackingfaxnum = vc WITH protect, noconstant("")
 DECLARE srolefaxnum = vc WITH protect, noconstant("")
 DECLARE sfaxstationname = vc WITH protect, noconstant("")
 DECLARE duserid = f8 WITH constant(request->user_id)
 DECLARE dencounterid = f8 WITH constant(request->encounter_id)
 DECLARE sdefaultcontext = vc WITH protect, constant("default")
 DECLARE strackingcontext = vc WITH protect, constant("tracking group")
 DECLARE srolecontext = vc WITH protect, constant("tracking provider role")
 DECLARE sdefaultcontextid = vc WITH protect, constant("system")
 DECLARE sfaxstationpref = vc WITH protect, constant("fax station")
 DECLARE sfaxnumpref = vc WITH protect, constant("fax number")
 DECLARE max_list_size = ui4 WITH public, constant(65535)
 DECLARE getfaxprefsbycontext(context=vc) = vc
 SET dtrackgroupcd = gettrackgroupforencounter(dencounterid)
 IF (validate(debug_ind,0)=1)
  CALL echo(dtrackgroupcd)
 ENDIF
 IF (dtrackgroupcd != 0)
  SELECT INTO "nl"
   FROM tracking_prsnl tp
   WHERE tp.person_id=duserid
    AND tp.tracking_group_cd=dtrackgroupcd
   DETAIL
    dtrackingproviderroleid = tp.tracking_prsnl_task_id
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(dtrackingproviderroleid)
 ENDIF
 FREE RECORD fax_station_request
 RECORD fax_station_request(
   1 station_cd = f8
   1 filteroptionlist[1]
     2 exclude_ad_hoc_ind = i2
     2 exclude_manual_ind = i2
     2 organization_id = f8
 )
 FREE RECORD fax_station_reply
 RECORD fax_station_reply(
   1 qual[*]
     2 station_cd = f8
     2 station_name = c20
     2 device_cd = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 quallist[*]
     2 qual[*]
       3 station_cd = f8
       3 station_name = c20
       3 device_cd = f8
       3 active_ind = i2
   1 totalqual = ui4
 )
 IF (dtrackgroupcd != 0.0)
  SET srolefaxstation = getfaxprefsbycontext(srolecontext,cnvtstring(dtrackingproviderroleid,16,2),
   sfaxstationpref)
  IF (srolefaxstation != "")
   SET sfaxstationname = srolefaxstation
  ELSE
   SET strackingfaxstation = getfaxprefsbycontext(strackingcontext,cnvtstring(dtrackgroupcd,16,2),
    sfaxstationpref)
   IF (strackingfaxstation != "")
    SET sfaxstationname = strackingfaxstation
   ELSE
    SET sdefaultfaxstation = getfaxprefsbycontext(sdefaultcontext,sdefaultcontextid,sfaxstationpref)
    IF (sdefaultfaxstation != "")
     SET sfaxstationname = sdefaultfaxstation
    ELSE
     SET sfaxstationname = "FirstNet Fax"
    ENDIF
   ENDIF
  ENDIF
 ELSE
  SET sdefaultfaxstation = getfaxprefsbycontext(sdefaultcontext,sdefaultcontextid,sfaxstationpref)
  IF (sdefaultfaxstation != "")
   SET sfaxstationname = sdefaultfaxstation
  ELSE
   SET sfaxstationname = "FirstNet Fax"
  ENDIF
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(build("Fax Station Name =",sfaxstationname))
 ENDIF
 IF (dtrackgroupcd != 0.0)
  SET srolefaxnum = getfaxprefsbycontext(srolecontext,cnvtstring(dtrackingproviderroleid,16,2),
   sfaxnumpref)
  IF (srolefaxnum != "")
   SET dphonetypecode = cnvtreal(srolefaxnum)
  ELSE
   SET strackingfaxnum = getfaxprefsbycontext(strackingcontext,cnvtstring(dtrackgroupcd,16,2),
    sfaxnumpref)
   IF (strackingfaxnum != "")
    SET dphonetypecode = cnvtreal(strackingfaxnum)
   ELSE
    SET sdefaultfaxnum = getfaxprefsbycontext(sdefaultcontext,sdefaultcontextid,sfaxnumpref)
    IF (sdefaultfaxnum != "")
     SET dphonetypecode = cnvtreal(sdefaultfaxnum)
    ELSE
     IF (uar_get_code_by("MEANING",43,"FAX BUS") > 0)
      SET dphonetypecode = uar_get_code_by("MEANING",43,"FAX BUS")
     ELSE
      IF (uar_get_code_by("MEANING",43,"FAX BILL") > 0)
       SET dphonetypecode = uar_get_code_by("MEANING",43,"FAX BILL")
      ELSE
       SET dphonetypecode = 0.0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSE
  SET sdefaultfaxnum = getfaxprefsbycontext(sdefaultcontext,sdefaultcontextid,sfaxnumpref)
  IF (sdefaultfaxnum != "")
   SET dphonetypecode = cnvtreal(sdefaultfaxnum)
  ELSE
   IF (uar_get_code_by("MEANING",43,"FAX BUS") > 0)
    SET dphonetypecode = uar_get_code_by("MEANING",43,"FAX BUS")
   ELSE
    IF (uar_get_code_by("MEANING",43,"FAX BILL") > 0)
     SET dphonetypecode = uar_get_code_by("MEANING",43,"FAX BILL")
    ELSE
     SET dphonetypecode = 0.0
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(build("Phone Type Code =",dphonetypecode))
 ENDIF
 FREE RECORD fax_org_prov_list_request
 RECORD fax_org_prov_list_request(
   1 followup_type_flag = i2
   1 followup_id = f8
   1 phone_type[*]
     2 phone_type_cd = f8
 )
 FREE RECORD fax_org_prov_list_reply
 RECORD fax_org_prov_list_reply(
   1 followup_provider = vc
   1 phone[*]
     2 phone_id = f8
     2 phone_type_cd = f8
     2 phone_type_disp = c40
     2 phone_type_desc = c60
     2 phone_type_seq = i2
     2 default = i2
     2 phone_number = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET followupprovcnt = size(request->follow_up,5)
 SET stat = alterlist(reply->foll_prov_phs,followupprovcnt)
 SET stat = alterlist(fax_org_prov_list_request->phone_type,1)
 FOR (follprovidx = 1 TO followupprovcnt)
   IF ((request->follow_up[follprovidx].prov_id != 0))
    SET fax_org_prov_list_request->followup_type_flag = 2
    SET fax_org_prov_list_request->followup_id = request->follow_up[follprovidx].prov_id
   ELSE
    SET fax_org_prov_list_request->followup_type_flag = 1
    SET fax_org_prov_list_request->followup_id = request->follow_up[follprovidx].organization_id
   ENDIF
   SET fax_org_prov_list_request->phone_type[1].phone_type_cd = dphonetypecode
   EXECUTE frn_get_org_prov_fax_list  WITH replace("REQUEST",fax_org_prov_list_request), replace(
    "REPLY",fax_org_prov_list_reply)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(fax_org_prov_list_reply)
   ENDIF
   IF ((fax_org_prov_list_reply->status_data.status="F"))
    CALL frnaddstatus("execute","frn_get_org_prov_fax_list",
     "frn_get_org_prov_fax_list could not be executed","F")
    SET smessage = build(sbeginmessage," frn_get_org_prov_fax_list could not be executed")
    GO TO exit_script
   ENDIF
   SET phonecnt = size(fax_org_prov_list_reply->phone,5)
   SET stat = alterlist(reply->foll_prov_phs[follprovidx].phone,phonecnt)
   SET reply->foll_prov_phs[follprovidx].followup_provider = fax_org_prov_list_reply->
   followup_provider
   FOR (phoneidx = 1 TO phonecnt)
     SET reply->foll_prov_phs[follprovidx].phone[phoneidx].phone_id = fax_org_prov_list_reply->phone[
     phoneidx].phone_id
     SET reply->foll_prov_phs[follprovidx].phone[phoneidx].phone_number = fax_org_prov_list_reply->
     phone[phoneidx].phone_number
     SET reply->foll_prov_phs[follprovidx].phone[phoneidx].phone_type_seq = fax_org_prov_list_reply->
     phone[phoneidx].phone_type_seq
     SET reply->foll_prov_phs[follprovidx].phone[phoneidx].phone_type_cd = fax_org_prov_list_reply->
     phone[phoneidx].phone_type_cd
     SET reply->foll_prov_phs[follprovidx].phone[phoneidx].phone_type_desc = fax_org_prov_list_reply
     ->phone[phoneidx].phone_type_desc
     SET reply->foll_prov_phs[follprovidx].phone[phoneidx].default = fax_org_prov_list_reply->phone[
     phoneidx].default
     SET reply->foll_prov_phs[follprovidx].phone[phoneidx].phone_type_disp = fax_org_prov_list_reply
     ->phone[phoneidx].phone_type_disp
   ENDFOR
 ENDFOR
 SET fax_station_request->station_cd = 0.0
 EXECUTE rrd_get_all_stations  WITH replace("REQUEST",fax_station_request), replace("REPLY",
  fax_station_reply)
 IF ((fax_station_reply->status_data.status="F"))
  CALL frnaddstatus("execute","rrd_get_all_stations","rrd_get_all_stations could not be executed","F"
   )
  SET smessage = build(sbeginmessage," rrd_get_all_stations could not be executed")
  GO TO exit_script
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echorecord(fax_station_reply)
 ENDIF
 SET stationcnt = size(fax_station_reply->qual,5)
 IF (stationcnt <= max_list_size)
  FOR (curstation = 1 TO stationcnt)
    IF ((fax_station_reply->qual[curstation].station_name=sfaxstationname))
     SET reply->output_destination_cd = fax_station_reply->qual[curstation].station_cd
     SET curstation = stationcnt
    ENDIF
  ENDFOR
 ENDIF
 IF ((reply->output_destination_cd=0.0)
  AND validate(fax_station_reply->totalqual)=1
  AND (fax_station_reply->totalqual > max_list_size))
  SET quallistcnt = size(fax_station_reply->quallist,5)
  FOR (qualcnt = 1 TO quallistcnt)
   SET stationcnt = size(fax_station_reply->quallist[qualcnt].qual,5)
   FOR (curstation = 1 TO stationcnt)
     IF ((fax_station_reply->quallist[qualcnt].qual[curstation].station_name=sfaxstationname))
      SET reply->output_destination_cd = fax_station_reply->quallist[qualcnt].qual[curstation].
      station_cd
      SET curstation = stationcnt
      SET qualcnt = quallistcnt
     ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 IF (validate(debug_ind,0)=1)
  CALL echorecord(reply)
  CALL echo(build("Output Destination Code =",reply->output_destination_cd))
 ENDIF
 SUBROUTINE getfaxprefsbycontext(context,context_id,preference_name)
   DECLARE curvalue = i4 WITH private, noconstant(0)
   DECLARE curpref = i4 WITH private, noconstant(1)
   DECLARE prefcnt = i4 WITH private, noconstant(0)
   DECLARE preferencevalue = vc WITH private, noconstant("")
   FREE RECORD pref_request
   RECORD pref_request(
     1 context = vc
     1 context_id = vc
     1 section = vc
     1 section_id = vc
     1 groups[*]
       2 name = vc
     1 debug = vc
   )
   FREE RECORD pref_reply
   RECORD pref_reply(
     1 entries[*]
       2 name = vc
       2 values[*]
         3 value = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET pref_request->context = context
   SET pref_request->context_id = context_id
   SET pref_request->section = "module"
   SET pref_request->section_id = "cwd"
   EXECUTE fn_get_prefs  WITH replace("REQUEST",pref_request), replace("REPLY",pref_reply)
   IF ((pref_reply->status_data.status="F"))
    IF (validate(debug_ind,0)=1)
     CALL echo("fn_get_prefs returned failed status")
    ENDIF
    IF ((pref_reply->status_data.status="F"))
     CALL frnaddstatus("execute","fn_get_prefs","fn_get_prefs could not be executed","F")
     SET smessage = build(sbeginmessage," fn_get_prefs could not be executed")
     GO TO exit_script
    ENDIF
   ENDIF
   SET prefcnt = size(pref_reply->entries,5)
   FOR (curpref = 1 TO prefcnt)
     IF ((pref_reply->entries[curpref].name=preference_name))
      FOR (curvalue = 1 TO size(pref_reply->entries[curpref].values,5))
        SET preferencevalue = pref_reply->entries[curpref].values[curvalue].value
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(preferencevalue)
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(build("DDComplete -> ",build2(cnvtint((curtime3 - ddcomplete))),"0 ms"))
 ENDIF
 CALL frnaddreplytimestamp(ddcomplete)
END GO
