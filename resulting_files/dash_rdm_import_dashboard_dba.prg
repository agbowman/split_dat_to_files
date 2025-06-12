CREATE PROGRAM dash_rdm_import_dashboard:dba
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
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE importdata(null) = null WITH protect
 DECLARE logandexit(p1=vc(val)) = null WITH protect
 DECLARE log_message(p1=vc(val)) = null WITH protect
 SET log_program_name = "DASH_RDM_IMPORT_DASHBOARD"
 CALL log_message(concat("Begin script ",log_program_name))
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed during script DASH_RDM_IMPORT_DASHBOARD..."
 CALL importdata(null)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: dashboard loaded successfully."
 GO TO exit_script
 SUBROUTINE importdata(null)
   DECLARE startpos = i4 WITH protect, noconstant(0)
   DECLARE endpos = i4 WITH protect, noconstant(0)
   DECLARE substrlength = i4 WITH protect, noconstant(0)
   DECLARE dashboardid = f8 WITH protect, noconstant(0.0)
   DECLARE dashboardtemplateid = f8 WITH protect, noconstant(0.0)
   DECLARE json = vc WITH protect, noconstant("")
   DECLARE tmpjson = vc WITH protect, noconstant("")
   DECLARE layoutjson = vc WITH protect, noconstant("")
   DECLARE layoutsect = vc WITH protect, noconstant("")
   DECLARE dashboardtype = vc WITH protect, noconstant("")
   DECLARE instancename = vc WITH protect, noconstant("")
   DECLARE templatename = vc WITH protect, noconstant("")
   DECLARE actionstring = vc WITH protect, noconstant("")
   DECLARE dashtypeid = f8 WITH protect, noconstant(0.0)
   DECLARE filtersind = i4 WITH protect, noconstant(0)
   IF (validate(request->blob_in))
    IF ((request->blob_in > " "))
     SET json = request->blob_in
    ELSE
     CALL logandexit("No configuration string was supplied.")
    ENDIF
   ELSE
    CALL logandexit("No configuration string was supplied.")
   ENDIF
   SET json = trim(json)
   SET startpos = findstring("if (typeof dashMaster",json,1,0)
   IF (startpos=0)
    CALL logandexit("I couldn't identify the dashMaster section.")
   ENDIF
   SET endpos = findstring("if (typeof dashMaster",json,(startpos+ 1),0)
   IF (endpos=0)
    CALL logandexit("I couldn't identify the dashMaster section.")
   ENDIF
   SET substrlength = (endpos - startpos)
   SET substrlength = (textlen(json) - substrlength)
   SET json = trim(substring(endpos,substrlength,json))
   CALL log_message("I have removed the dashMaster section.")
   SET startpos = findstring("if (typeof dashMaster",json,1,0)
   IF (startpos=0)
    CALL logandexit("I couldn't identify the Dashboard Template section.")
   ENDIF
   SET endpos = findstring("if (typeof dashMaster",json,(startpos+ 1),0)
   IF (endpos=0)
    CALL logandexit("I couldn't identify the Dashboard Template section.")
   ENDIF
   SET substrlength = (endpos - startpos)
   SET tmpjson = trim(substring(startpos,substrlength,json))
   SET templatenamestartpos = (findstring('"dashboardTemplateName"',tmpjson,1,1)+ 27)
   SET templatenameendpos = findstring('"',tmpjson,templatenamestartpos,0)
   SET templatename = substring(templatenamestartpos,(templatenameendpos - templatenamestartpos),
    tmpjson)
   SET templatename = trim(templatename)
   CALL log_message(concat("I've found the Dashboard Template Name to be: ",templatename,"."))
   SET substrlength = (textlen(json) - substrlength)
   SET json = trim(substring(endpos,substrlength,json))
   SET startpos = findstring("if (typeof dashMaster",json,1,0)
   IF (startpos=0)
    CALL logandexit("I couldn't identify the Dashboard Instance section.")
   ENDIF
   SET endpos = findstring("if (typeof dashMaster",json,(startpos+ 1),0)
   IF (endpos=0)
    CALL logandexit("I couldn't identify the Dashboard Instance section.")
   ENDIF
   SET substrlength = (endpos - startpos)
   SET tmpjson = trim(substring(startpos,substrlength,json))
   SET instancenamestartpos = (findstring('"dashboardName"',tmpjson,1,1)+ 19)
   SET instancenameendpos = findstring('"',tmpjson,instancenamestartpos,0)
   SET instancename = trim(substring(instancenamestartpos,(instancenameendpos - instancenamestartpos),
     tmpjson))
   CALL log_message(concat("I've found the Dashboard Instance Name to be: ",instancename,"."))
   SET substrlength = (textlen(json) - substrlength)
   SET json = trim(substring(endpos,substrlength,json))
   SELECT INTO "nl:"
    FROM dash_dashboard dd
    WHERE dd.dashboard_name=templatename
     AND dd.dashboard_template_name=templatename
     AND dd.active_ind=1
    DETAIL
     dashboardtemplateid = dd.dash_dashboard_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    CALL logandexit(concat("Failed trying to find out if the Template is already in the system. ",
      errmsg))
   ENDIF
   IF ( NOT (dashboardtemplateid=0))
    CALL log_message("This dashboard template has already been imported into the system.")
    SET readme_data->status = "S"
    SET readme_data->message = "Success: dashboard is already loaded in the system."
    GO TO exit_script
   ENDIF
   SET startpos = findstring("if (typeof dashMaster",json,1,0)
   IF (startpos=0)
    CALL logandexit("I couldn't identify the Dashboard Layout section.")
   ENDIF
   SET endpos = findstring("if (typeof dashMaster",json,(startpos+ 1),0)
   IF (endpos=0)
    CALL logandexit("I couldn't identify the Dashboard Layout section.")
   ENDIF
   SET substrlength = (endpos - startpos)
   SET tmpjson = trim(substring(startpos,substrlength,json))
   SET layoutsectionstartpos = findstring("layout = {",tmpjson,1,1)
   IF (layoutsectionstartpos=0)
    CALL logandexit("I couldn't identify the Dashboard Layout section.")
   ENDIF
   SET layoutjson = substring(layoutsectionstartpos,(textlen(tmpjson) - layoutsectionstartpos),
    tmpjson)
   SET layoutjson = replace(layoutjson,"layout =",'"layout" :')
   CALL log_message("I've extracted the Layout section.")
   SET ok = findattrbyname(layoutjson,"layout",layoutsect)
   SET ok = findattrbyname(layoutsect,"dashboardType",dashboardtype)
   SELECT
    "nl:"
    FROM dash_type dt
    PLAN (dt
     WHERE dt.dash_type_name=trim(dashboardtype))
    DETAIL
     dashtypeid = dt.dash_type_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    CALL logandexit(concat(
      "Failed trying to find out if the Dashboard Type is already in the system. ",errmsg))
   ENDIF
   IF (dashtypeid=0.0)
    SELECT INTO "nl:"
     se_id = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      dashtypeid = se_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to get an ID for the Dashboard Type. ",errmsg))
    ENDIF
    INSERT  FROM dash_type
     (dash_type_id, dash_type_name, active_ind,
     org_id, updt_applctx, updt_cnt,
     updt_dt_tm, updt_id, updt_task)
     VALUES(dashtypeid, dashboardtype, 1,
     0.0, reqinfo->updt_applctx, 0,
     cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
    ;end insert
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to add the Dashboard Type. ",errmsg))
    ELSE
     CALL log_message(concat("I have added the new Dashboard Type: ",dashboardtype,"."))
    ENDIF
   ENDIF
   SET substrlength = (textlen(json) - substrlength)
   SET json = trim(substring(endpos,substrlength,json))
   SET startpos = findstring("if (typeof dashMaster",json,1,0)
   IF (startpos=0)
    CALL logandexit("I couldn't identify the Page Filters section.")
   ENDIF
   SET endpos = findstring("if (typeof dashMaster",json,(startpos+ 1),0)
   IF (endpos=0)
    SET endpos = findstring("}",json,startpos,1)
    IF (endpos=0)
     CALL logandexit("I couldn't identify the Page Filters section.")
    ENDIF
   ENDIF
   SET substrlength = (endpos - startpos)
   SET tmpjson = trim(substring(startpos,substrlength,json))
   SET pagefilterstartpos = findstring("pageFilters = [",tmpjson,1,1)
   IF (pagefilterstartpos=0)
    CALL log_message("I did not find a page filter section.")
   ELSE
    SET filtersind = 1
    SET pagefilterjson = trim(substring(pagefilterstartpos,(textlen(tmpjson) - pagefilterstartpos),
      tmpjson))
    SET pagefilterjson = replace(pagefilterjson,"pageFilters =",'"pageFilters" :')
    CALL log_message("I've extracted the Page Filter section.")
    SET substrlength = (textlen(json) - substrlength)
    SET json = trim(substring(endpos,substrlength,json))
   ENDIF
   IF (filtersind=1)
    SET startpos = findstring("if (typeof dashMaster",json,1,0)
    IF (startpos=0)
     CALL logandexit("I couldn't identify the Components section.")
    ENDIF
   ENDIF
   SET endpos = textlen(json)
   IF (endpos=0)
    CALL logandexit("I couldn't identify the Components section.")
   ENDIF
   SET substrlength = (endpos - startpos)
   SET tmpjson = trim(substring(startpos,substrlength,json))
   SET componentssectionstartpos = findstring("components = [",tmpjson,1,1)
   SET componentsjson = trim(substring(componentssectionstartpos,((textlen(tmpjson) -
     componentssectionstartpos)+ 1),tmpjson))
   SET componentsjson = replace(componentsjson,"components =",'"components" :')
   CALL log_message("I've extracted the Components section.")
   CALL log_message("I'm inserting the Template records, now.")
   SELECT INTO "nl:"
    se_id = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     dashboardid = se_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    CALL logandexit(concat("Failed trying to get an ID for the Dashboard. ",errmsg))
   ENDIF
   INSERT  FROM dash_dashboard
    (dash_dashboard_id, orig_dash_dashboard_id, dashboard_name,
    dashboard_template_name, org_id, dash_type_id,
    content_data_txt, shipped_ind, beg_effective_dt_tm,
    active_ind, template_ind, active_status_prsnl_id,
    last_updt_prsnl_id, updt_applctx, updt_cnt,
    updt_dt_tm, updt_id, updt_task)
    VALUES(dashboardid, dashboardid, templatename,
    templatename, 0.0, dashtypeid,
    layoutsect, 1, cnvtdatetime(curdate,curtime3),
    1, 1, 0.0,
    0.0, reqinfo->updt_applctx, 0,
    cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task)
   ;end insert
   IF (error(errmsg,0) > 0)
    CALL logandexit(concat("Failed trying to add the Dashboard Template record. ",errmsg))
   ELSE
    CALL log_message(concat("I have added the new Dashboard Template: ",templatename,"."))
   ENDIF
   COMMIT
   IF ( NOT (pagefilterjson=""))
    EXECUTE dash_rdm_import_filter "MINE", pagefilterjson, dashboardid
    IF ((readme_data->status != "S"))
     GO TO exit_script
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message =
     "Readme Failed: Continuing script dash_rdm_import_dashboard after Filter import..."
    ENDIF
   ENDIF
   IF ( NOT (componentsjson=""))
    EXECUTE dash_rdm_import_comp componentsjson, dashboardid, "dashboard template"
    IF ((readme_data->status != "S"))
     GO TO exit_script
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message =
     "Readme Failed: Continuing script dash_rdm_import_dashboard after first comp import..."
    ENDIF
    EXECUTE dash_rdm_import_comp componentsjson, 0.0, "component template"
    IF ((readme_data->status != "S"))
     GO TO exit_script
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message =
     "Readme Failed: Continuing script dash_rdm_import_dashboard after second comp import..."
    ENDIF
    EXECUTE dash_rdm_import_comp componentsjson, dashboardid, "available"
    IF ((readme_data->status != "S"))
     GO TO exit_script
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message =
     "Readme Failed: Continuing script dash_rdm_import_dashboard after third comp import..."
    ENDIF
   ENDIF
   CALL log_message(concat("Dashboard ",instancename," was imported successfully."))
   SET readme_data->status = "S"
   SET readme_data->message = "Success: dashboard loaded successfully"
 END ;Subroutine
 SUBROUTINE logandexit(message)
   ROLLBACK
   CALL log_message(message)
   IF ( NOT (dashtypeid=0))
    DELETE  FROM dash_type dt
     WHERE dt.dash_type_id=dashtypeid
    ;end delete
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("An error occurred rolling back the dash_type record. ",errmsg
      )
     GO TO exit_script
    ENDIF
   ENDIF
   IF ( NOT (dashboardid=0))
    DELETE  FROM dash_dashboard dd
     WHERE dd.dash_dashboard_id=dashboardid
    ;end delete
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("An error occurred rolling back the dashboard record. ",errmsg
      )
     GO TO exit_script
    ENDIF
   ENDIF
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
