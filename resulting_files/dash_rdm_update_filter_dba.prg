CREATE PROGRAM dash_rdm_update_filter:dba
 PROMPT
  "Config String:" = "",
  "Dash Template Name:" = ""
  WITH configstr, templatename
 DECLARE includeinresponse = i4 WITH protect, noconstant(0)
 DECLARE logdetails(p1=vc(val),p2=vc(val),p3=vc(val)) = null WITH protect
 DECLARE logeffort(p1=vc(val),p2=dq8(val),p3=vc(ref)) = null WITH protect
 DECLARE findattrbyname(obj=vc(ref),name=vc,value=vc(ref)) = i2 WITH copy
 DECLARE getnextlistitem(json=vc(ref),pos=i4,item=vc(ref)) = i4 WITH copy
 DECLARE getnextattrandvalue(json=vc(ref),pos=i4,name=vc(ref),value=vc(ref)) = i4 WITH copy
 DECLARE getvalueatpos(string=vc(ref),pos=i4,max=i4,value=vc(ref)) = i4 WITH copy
 DECLARE findnexttokenchar(string=vc(ref),pos=i4,max=i4) = i4 WITH copy
 DECLARE findclosingdelimiter(string=vc(ref),pos=i4) = i4 WITH copy
 DECLARE skipwhitespace(string=vc(ref),pos=i4,max=i4) = i4 WITH copy
 DECLARE getquotedstring(json=vc(ref),pos=i4,string=vc(ref)) = i4 WITH copy
 SUBROUTINE findattrbyname(obj,name,value)
   DECLARE pos = i4 WITH protect, noconstant(1)
   DECLARE aname = vc WITH protect
   WHILE (pos > 0)
     SET pos = getnextattrandvalue(obj,pos,aname,value)
     IF (validate(debug_ind,0)=1)
      CALL echo("In FindAttrByName.  Just called GetNextAttrAndValue.")
      CALL echo(build("pos=",pos))
      CALL echo(build("name(looking for attribute)=",name))
      CALL echo(build("aname(found attribute)=",aname))
      CALL echo(build("value=",value))
     ENDIF
     IF (pos > 0
      AND aname=name)
      RETURN(1)
     ENDIF
   ENDWHILE
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE getnextlistitem(json,pos,item)
   DECLARE len = i4 WITH protect, constant(textlen(json))
   DECLARE char = c1 WITH protect
   DECLARE vpos = i4 WITH protect
   SET pos = skipwhitespace(json,pos,len)
   SET char = substring(pos,1,json)
   IF (char="]")
    RETURN(0)
   ELSEIF (char="[")
    SET vpos = skipwhitespace(json,(pos+ 1),len)
    IF (substring(vpos,1,json)="]")
     RETURN(0)
    ENDIF
   ELSEIF (char != ",")
    RETURN(- (1))
   ENDIF
   IF (char=",")
    SET vpos = skipwhitespace(json,(pos+ 1),len)
    IF (vpos > 0
     AND substring(vpos,1,json)="]")
     RETURN(0)
    ENDIF
   ENDIF
   SET vpos = getvalueatpos(json,(pos+ 1),len,item)
   IF (validate(debug_ind,0)=1)
    CALL echo("In GetNextListItem.  Just called GetValueAtPos.")
    CALL echo(build("item(value)=",item))
    CALL echo(build("pos=",pos))
    CALL echo(build("vpos=",vpos))
   ENDIF
   IF (vpos > 0)
    SET vpos = findnexttokenchar(json,vpos,len)
   ELSEIF (vpos=0)
    SET vpos = - (1)
   ENDIF
   RETURN(vpos)
 END ;Subroutine
 SUBROUTINE getnextattrandvalue(json,pos,name,value)
   DECLARE length = i4 WITH constant(textlen(json))
   DECLARE clpos = i4 WITH protect
   DECLARE qpos = i4 WITH protect
   DECLARE eqpos = i4 WITH protect
   DECLARE cmpos = i4 WITH protect
   DECLARE brpos = i4 WITH protect
   DECLARE vpos = i4 WITH protect
   DECLARE char = c1 WITH protect
   IF (validate(debug_ind,0)=1)
    CALL echo("In GetNextAttrAndValue.")
   ENDIF
   SET qpos = findstring('"',json,pos)
   SET brpos = findstring("}",json,pos)
   IF (((qpos=0) OR (qpos > brpos)) )
    IF (validate(debug_ind,0)=1)
     CALL echo("No more values. Returning 0.")
    ENDIF
    RETURN(0)
   ENDIF
   SET eqpos = getquotedstring(json,qpos,name)
   IF (eqpos=0)
    IF (validate(debug_ind,0)=1)
     CALL echo("Couldn't find attribute name. Returning -1.")
    ENDIF
    RETURN(- (1))
   ENDIF
   SET clpos = findnexttokenchar(json,eqpos,length)
   IF (((clpos=0) OR (substring(clpos,1,json) != ":")) )
    IF (validate(debug_ind,0)=1)
     CALL echo("Couldn't find ':'. Returning -1.")
    ENDIF
    RETURN(- (1))
   ENDIF
   SET vpos = getvalueatpos(json,(clpos+ 1),length,value)
   IF ((vpos < (clpos+ 1)))
    IF (validate(debug_ind,0)=1)
     CALL echo("Couldn't find value. Returning -1.")
    ENDIF
    RETURN(- (1))
   ENDIF
   SET vpos = findnexttokenchar(json,vpos,length)
   IF (vpos=0)
    SET vpos = (length+ 1)
   ENDIF
   RETURN(vpos)
 END ;Subroutine
 SUBROUTINE getvalueatpos(string,pos,max,value)
   DECLARE endpos = i4 WITH protect, noconstant(0)
   DECLARE char = c1 WITH protect
   DECLARE functiontxt = vc WITH protect, noconstant("")
   DECLARE strlen = i4 WITH protect, noconstant(0)
   DECLARE functblockstartpos = i4 WITH protect, noconstant(0)
   DECLARE functblockendpos = i4 WITH protect, noconstant(0)
   DECLARE valuedetermined = i4 WITH protect, noconstant(0)
   SET pos = skipwhitespace(string,pos,max)
   IF (pos=0)
    RETURN(0)
   ENDIF
   SET char = substring(pos,1,string)
   IF (char='"')
    SET endpos = getquotedstring(string,pos,value)
    SET valuedetermined = 1
    IF (validate(debug_ind,0)=1)
     CALL echo("Value is a String.")
    ENDIF
   ELSEIF (((char="{") OR (char="[")) )
    SET endpos = findclosingdelimiter(string,pos)
    IF (endpos > 0)
     SET endpos = (endpos+ 1)
     SET value = substring(pos,(endpos - pos),string)
     SET valuedetermined = 1
     IF (validate(debug_ind,0)=1)
      CALL echo("Value is an object or collection.")
     ENDIF
    ELSE
     SET endpos = - (1)
     SET value = ""
     IF (validate(debug_ind,0)=1)
      CALL echo("Value is an invalid object or collection.")
     ENDIF
    ENDIF
   ELSEIF (char="t")
    SET endpos = findnexttokenchar(string,pos,max)
    IF (substring(endpos,1,string) IN (",", "}"))
     SET strlen = (endpos - pos)
     SET value = substring(pos,strlen,string)
     SET value = trim(value)
     IF (value="true")
      SET valuedetermined = 1
      IF (validate(debug_ind,0)=1)
       CALL echo("Value is 'true'.")
      ENDIF
     ELSE
      SET value = ""
     ENDIF
    ENDIF
   ELSEIF (char="f")
    SET endpos = findnexttokenchar(string,pos,max)
    IF (substring(endpos,1,string) IN (",", "}"))
     SET strlen = (endpos - pos)
     SET value = substring(pos,strlen,string)
     SET value = trim(value)
     IF (value="false")
      SET valuedetermined = 1
      IF (validate(debug_ind,0)=1)
       CALL echo("Value is 'false'.")
      ENDIF
     ELSEIF (substring(pos,8,string)="function")
      SET endpos = findstring("{",string,(pos+ 9),1)
      SET endpos = findclosingdelimiter(string,endpos)
      SET strlen = (endpos - pos)
      SET value = substring(pos,strlen,string)
      SET valuedetermined = 1
      IF (validate(debug_ind,0)=1)
       CALL echo("Value is an inline function.  THIS CODEPATH IS NOT TESTED!")
      ENDIF
     ELSE
      SET value = ""
     ENDIF
    ENDIF
   ELSEIF (char IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9",
   "-", "."))
    SET endpos = findnexttokenchar(string,pos,max)
    IF (endpos > 0)
     SET value = trim(substring(pos,(endpos - pos),string),3)
     IF (isnumeric(value)=1)
      SET valuedetermined = 1
      IF (validate(debug_ind,0)=1)
       CALL echo("Value is numeric.")
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (char IN (",", "}"))
    IF (validate(debug_ind,0)=1)
     CALL echo("Value is MISSING.")
    ENDIF
    SET endpos = - (1)
   ENDIF
   IF (valuedetermined=0
    AND  NOT ((endpos=- (1))))
    SET endpos = (findstring(",",string,pos,1) - 1)
    SET strlen = (endpos - pos)
    SET value = substring(pos,strlen,string)
    IF (validate(debug_ind,0)=1)
     CALL echo("Value is assumed to be an object reference.")
    ENDIF
   ENDIF
   RETURN(endpos)
 END ;Subroutine
 SUBROUTINE findnexttokenchar(string,pos,max)
   WHILE (pos <= max
    AND  NOT (substring(pos,1,string) IN ('"', ",", ":", "}", "]")))
     SET pos = (pos+ 1)
   ENDWHILE
   IF (pos > max)
    SET pos = 0
   ENDIF
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE findclosingdelimiter(string,pos)
   DECLARE length = i4 WITH protect, noconstant(textlen(string))
   DECLARE opencount = i4 WITH protect, noconstant(1)
   DECLARE openq = c1 WITH protect, noconstant(" ")
   DECLARE delimiter = c1 WITH protect
   DECLARE closer = c1 WITH protect
   DECLARE char = c1 WITH protect
   SET delimiter = substring(pos,1,string)
   IF (delimiter="[")
    SET closer = "]"
   ELSEIF (delimiter="{")
    SET closer = "}"
   ELSE
    RETURN(- (1))
   ENDIF
   WHILE (pos < length
    AND opencount > 0)
     SET pos = (pos+ 1)
     SET char = substring(pos,1,string)
     IF (char='"')
      IF (openq=" ")
       SET openq = char
      ELSEIF (substring((pos - 1),1,string) != "\")
       SET openq = " "
      ENDIF
     ELSEIF (char=closer)
      SET opencount = (opencount - 1)
     ELSEIF (char=delimiter)
      SET opencount = (opencount+ 1)
     ENDIF
   ENDWHILE
   IF (opencount > 0)
    RETURN(- (1))
   ENDIF
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE skipwhitespace(string,pos,max)
   DECLARE char = c1 WITH protect
   SET char = substring(pos,1,string)
   WHILE (pos <= max
    AND char IN (" ", char(9), char(10), char(13)))
    SET pos = (pos+ 1)
    SET char = substring(pos,1,string)
   ENDWHILE
   IF (pos > max)
    SET pos = 0
   ENDIF
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE getquotedstring(json,pos,string)
   DECLARE eqpos = i4 WITH protect
   IF (substring(pos,1,json) != '"')
    RETURN(- (1))
   ENDIF
   SET eqpos = findstring('"',json,(pos+ 1))
   WHILE (eqpos > 0
    AND substring((eqpos - 1),1,json)="\")
     SET eqpos = findstring('"',json,(eqpos+ 1))
   ENDWHILE
   IF (eqpos=0)
    RETURN(- (1))
   ENDIF
   SET string = substring((pos+ 1),((eqpos - pos) - 1),json)
   RETURN((eqpos+ 1))
 END ;Subroutine
 SUBROUTINE logdetails(message,variblename,variable)
   CALL log_message(message,log_level_debug)
   SET response->results.output = concat(response->results.output,message)
   IF (validate(debug_ind,0)=1)
    SET includeinresponse = 1
   ENDIF
   IF (includeinresponse=1)
    IF ( NOT (variblename=""))
     SET response->results.output = build(response->results.output,variblename," = ",variable,"<br>")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE logeffort(subroutinename,begindatetime,result_record)
  CALL log_message(build("Exiting ",log_program_name,".",subroutinename,
    "(). Elapsed time in seconds: ",
    datetimediff(cnvtdatetime(curdate,curtime3),begindatetime,5)),log_level_debug)
  IF (validate(debug_ind,0)=1)
   CALL echo(result_record)
  ENDIF
 END ;Subroutine
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 RECORD filterlist(
   1 filter[*]
     2 filterid = f8
     2 updtcnt = i4
 )
 RECORD dashboardlist(
   1 dashboard[*]
     2 id = f8
     2 org_id = f8
 )
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE importdata(null) = null WITH protect
 DECLARE processfilter(p1=vc(val),p2=f8(val)) = null WITH protect
 DECLARE processfiltergroup(p1=vc(val)) = null WITH protect
 DECLARE logandexit(p1=vc(val)) = null WITH protect
 DECLARE log_message(p1=vc(val)) = null WITH protect
 SET log_program_name = "DASH_RDM_UPDATE_FILTER"
 CALL log_message(concat("Begin script ",log_program_name))
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed during script DASH_RDM_UPDATE_FILTER..."
 CALL importdata(null)
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Success: filters loaded successfully."
 GO TO exit_script
 SUBROUTINE importdata(null)
   DECLARE json = vc WITH protect, noconstant("")
   DECLARE ok = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE filters = vc WITH protect, noconstant("")
   DECLARE filterdef = vc WITH protect, noconstant("")
   DECLARE filtergroup = vc WITH protect, noconstant("")
   DECLARE listitem = vc WITH protect, noconstant("")
   SET json = trim( $CONFIGSTR)
   SELECT INTO "nl:"
    FROM dash_dashboard dd
    WHERE (dd.dashboard_template_name= $TEMPLATENAME)
     AND dd.active_ind=1
    ORDER BY dd.org_id
    HEAD REPORT
     cnt = 0, stat = alterlist(dashboardlist->dashboard,10)
    DETAIL
     cnt = (cnt+ 1), cursize = size(dashboardlist->dashboard,5)
     IF (cnt > cursize)
      stat = alterlist(dashboardlist->dashboard,(cursize+ 10))
     ENDIF
     dashboardlist->dashboard[cnt].id = dd.dash_dashboard_id, dashboardlist->dashboard[cnt].org_id =
     dd.org_id
    FOOT REPORT
     stat = alterlist(dashboardlist->dashboard,cnt)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    CALL logandexit(concat("Failed trying to get all Instance IDs for this template.",errmsg))
   ENDIF
   FOR (idx = 1 TO cnt)
    SET ok = findattrbyname(json,"pageFilters",filters)
    IF (ok > 0)
     SET lpos = getnextlistitem(filters,1,listitem)
     WHILE (lpos > 0)
       SET ok = findattrbyname(listitem,"filterDef",filterdef)
       IF (ok > 0)
        CALL processfilter(listitem,0.0,dashboardlist->dashboard[idx].id,dashboardlist->dashboard[idx
         ].org_id)
       ELSE
        SET ok = findattrbyname(listitem,"filterGroup",filtergroup)
        IF (ok > 0)
         CALL processfiltergroup(listitem,dashboardlist->dashboard[idx].id,dashboardlist->dashboard[
          idx].org_id)
        ELSE
         CALL logandexit("I was unable to find the filter definition section.")
        ENDIF
       ENDIF
       SET lpos = getnextlistitem(filters,lpos,listitem)
     ENDWHILE
     IF (lpos < 0)
      CALL logandexit("There was a problem reading the filters collection.")
     ENDIF
    ELSE
     CALL logandexit("There was a problem reading the import file.")
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE processfilter(listitem,filtergroupid,dashboardid,orgid)
   DECLARE ok = i4 WITH protect, noconstant(0)
   DECLARE filterdef = vc WITH protect, noconstant("")
   DECLARE filtername = vc WITH protect, noconstant("")
   DECLARE templatename = vc WITH protect, noconstant("")
   DECLARE filterid = f8 WITH protect, noconstant(0.0)
   DECLARE supplimentalid = f8 WITH protect, noconstant(0.0)
   CALL log_message("Entering ProcessFilter()")
   SET ok = findattrbyname(listitem,"filterDef",filterdef)
   SET ok = findattrbyname(filterdef,"filterName",filtername)
   IF (ok > 0)
    CALL log_message(concat("I've found the filter name to be: ",filtername,"."))
   ELSE
    CALL logandexit("I was unable to find the filter name.")
   ENDIF
   SET ok = findattrbyname(filterdef,"templateName",templatename)
   IF (ok > 0)
    CALL log_message(concat("I've found the template name to be: ",templatename,"."))
   ELSE
    CALL logandexit("I was unable to find the template name.")
   ENDIF
   SELECT INTO "nl:"
    FROM dash_filter df
    WHERE df.filter_name=templatename
     AND df.filter_template_name=templatename
     AND df.active_ind=1
     AND df.template_ind=1
    DETAIL
     supplimentalid = df.dash_filter_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    CALL logandexit(concat(
      "Failed trying to find out if the supplimental record is already in the system. ",errmsg))
   ENDIF
   IF (supplimentalid=0)
    SELECT INTO "nl:"
     se_id = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      filterid = se_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to get an ID for a Template Filter. ",errmsg))
    ENDIF
    INSERT  FROM dash_filter
     (dash_filter_id, orig_dash_filter_id, filter_name,
     filter_template_name, dash_dashboard_id, dash_item_group_id,
     content_data_txt, org_id, beg_effective_dt_tm,
     active_ind, active_status_dt_tm, template_ind,
     active_status_prsnl_id, last_updt_prsnl_id, updt_applctx,
     updt_cnt, updt_dt_tm, updt_id,
     updt_task)
     VALUES(filterid, filterid, templatename,
     templatename, 0, 0.0,
     listitem, 0.0, cnvtdatetime(curdate,curtime3),
     1, cnvtdatetime(curdate,curtime3), 1,
     0.0, 0.0, reqinfo->updt_applctx,
     0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
     reqinfo->updt_task)
    ;end insert
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to add the Filter Template. ",errmsg))
    ELSE
     CALL log_message(concat("I have added the new Filter Template: ",templatename,"."))
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    se_id = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     filterid = se_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    CALL logandexit(concat("Failed trying to get an ID for the Filter. ",errmsg))
   ENDIF
   INSERT  FROM dash_filter
    (dash_filter_id, orig_dash_filter_id, filter_name,
    filter_template_name, dash_dashboard_id, dash_item_group_id,
    content_data_txt, org_id, beg_effective_dt_tm,
    active_ind, active_status_dt_tm, active_status_prsnl_id,
    last_updt_prsnl_id, updt_applctx, updt_cnt,
    updt_dt_tm, updt_id, updt_task)
    VALUES(filterid, filterid, filtername,
    templatename, dashboardid, filtergroupid,
    listitem, orgid, cnvtdatetime(curdate,curtime3),
    1, cnvtdatetime(curdate,curtime3), 0.0,
    0.0, reqinfo->updt_applctx, 0,
    cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
   ;end insert
   IF (error(errmsg,0) > 0)
    CALL logandexit(concat("Failed trying to add a Filter. ",errmsg))
   ELSE
    CALL log_message(concat("I have added the new Filter: ",filtername,"."))
   ENDIF
   CALL log_message(concat("Filter ",filtername," was imported successfully."))
 END ;Subroutine
 SUBROUTINE processfiltergroup(listitem,dashboardid,orgid)
   DECLARE ok = i4 WITH protect, noconstant(0)
   DECLARE lpos = i4 WITH protect, noconstant(0)
   DECLARE filtergroupid = f8 WITH protect, noconstant(0)
   DECLARE filtergroup = vc WITH protect, noconstant("")
   DECLARE groupname = vc WITH protect, noconstant("")
   DECLARE filters = vc WITH protect, noconstant("")
   SET ok = findattrbyname(listitem,"filterGroup",filtergroup)
   SET ok = findattrbyname(filtergroup,"filters",filters)
   IF (ok > 0)
    SELECT INTO "nl:"
     se_id = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      filtergroupid = se_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to get an ID for a Filter Group. ",errmsg))
    ENDIF
    SET listitem = replace(listitem,filters,"")
    SET ok = findattrbyname(filtergroup,"groupName",groupname)
    IF (ok=0)
     CALL log_message("I was unable to find the Group Name.  Using the Label instead.")
     SET ok = findattrbyname(filtergroup,"label",groupname)
    ENDIF
    INSERT  FROM dash_item_group
     (dash_item_group_id, group_name, dash_dashboard_id,
     org_id, shipped_ind, content_data_txt,
     active_ind, active_status_dt_tm, active_status_prsnl_id,
     last_updt_prsnl_id, updt_applctx, updt_cnt,
     updt_dt_tm, updt_id, updt_task)
     VALUES(filtergroupid, groupname, dashboardid,
     orgid, 1, listitem,
     1, cnvtdatetime(curdate,curtime3), 0.0,
     0.0, reqinfo->updt_applctx, 0,
     cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
    ;end insert
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to add a Filter Group. ",errmsg))
    ELSE
     CALL log_message(concat("I have added the new Filter Group: ",groupname,"."))
    ENDIF
    SET lpos = getnextlistitem(filters,1,listitem)
    WHILE (lpos > 0)
      SET ok = findattrbyname(listitem,"filterDef",filterdef)
      IF (ok > 0)
       CALL processfilter(listitem,filtergroupid,dashboardid,orgid)
      ELSE
       CALL logandexit("I was unable to find the filter definition section.")
      ENDIF
      SET lpos = getnextlistitem(filters,lpos,listitem)
    ENDWHILE
    IF (lpos < 0)
     CALL logandexit(
      "Sorry, there was a problem reading the filters collection.  I can't complete the import.")
    ENDIF
   ELSE
    CALL logandexit("There was a problem processing a filterGroup.")
   ENDIF
 END ;Subroutine
 SUBROUTINE logandexit(message)
   ROLLBACK
   CALL log_message(message)
   SET readme_data->status = "F"
   SET readme_data->message = message
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE log_message(message)
   IF (debug_ind=1)
    CALL echo(message)
   ENDIF
 END ;Subroutine
#exit_script
END GO
