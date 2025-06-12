CREATE PROGRAM dash_rdm_import_comp:dba
 PROMPT
  "Config String:" = "",
  "Dashboard ID:" = 0,
  "Component Type" = ""
  WITH configstr, dashboardid, comptype
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
 DECLARE templateind = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE importdata(null) = null WITH protect
 DECLARE processcomponent(p1=vc(val)) = null WITH protect
 DECLARE logandexit(p1=vc(val)) = null WITH protect
 DECLARE log_message(p1=vc(val)) = null WITH protect
 SET log_program_name = "DASH_RDM_IMPORT_COMP"
 CALL log_message(concat("Begin script ",log_program_name))
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed during script DASH_RDM_IMPORT_COMP..."
 CALL importdata(null)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: dashboard loaded successfully."
 GO TO exit_script
 SUBROUTINE importdata(null)
   DECLARE begin_date_time = dq8 WITH private, constant(cnvtdatetime(curdate,curtime3))
   DECLARE json = vc WITH protect, noconstant("")
   DECLARE ok = i4 WITH protect, noconstant(0)
   DECLARE components = vc WITH protect, noconstant("")
   DECLARE component = vc WITH protect, noconstant("")
   CALL log_message("Entering importData()")
   SET json = trim( $CONFIGSTR)
   SET ok = findattrbyname(json,"components",components)
   IF (ok > 0)
    SET lpos = getnextlistitem(components,1,component)
    WHILE (lpos > 0)
     CALL processcomponent(component)
     SET lpos = getnextlistitem(components,lpos,component)
    ENDWHILE
    IF (lpos < 0)
     CALL logandexit("There was a problem reading the components collection.")
    ENDIF
   ELSE
    CALL logandexit("There was a problem reading the import file.")
   ENDIF
 END ;Subroutine
 SUBROUTINE processcomponent(component)
   DECLARE begin_date_time = dq8 WITH private, constant(cnvtdatetime(curdate,curtime3))
   DECLARE ok = i4 WITH protect, noconstant(0)
   DECLARE compname = vc WITH protect, noconstant("")
   DECLARE comptemplatename = vc WITH protect, noconstant("")
   DECLARE temporarydashid = f8 WITH protect, noconstant(0.0)
   DECLARE filterkey = vc WITH protect, noconstant("")
   DECLARE periodpos = i4 WITH protect, noconstant(0)
   DECLARE startpos = i4 WITH protect, noconstant(0)
   DECLARE endpos = i4 WITH protect, noconstant(0)
   DECLARE substringlen = i4 WITH protect, noconstant(0)
   DECLARE componentid = f8 WITH protect, noconstant(0.0)
   DECLARE dashtypecomprltnid = f8 WITH protect, noconstant(0.0)
   DECLARE dashtypeid = f8 WITH protect, noconstant(0.0)
   DECLARE recomdimltxt = vc WITH protect, noconstant("")
   DECLARE recomdimrtxt = vc WITH protect, noconstant("")
   DECLARE recomdimttxt = vc WITH protect, noconstant("")
   DECLARE recomdimbtxt = vc WITH protect, noconstant("")
   DECLARE recomdimwint = i4 WITH protect, noconstant(1)
   DECLARE recomdimhint = i4 WITH protect, noconstant(1)
   DECLARE recomdimtxt = vc WITH protect, noconstant("")
   DECLARE componentfilter = vc WITH protect, noconstant("")
   DECLARE dashtemplatename = vc WITH protect, noconstant("")
   DECLARE dashname = vc WITH protect, noconstant("")
   DECLARE searchstring = vc WITH protect, noconstant("")
   DECLARE replacestring = vc WITH protect, noconstant("")
   DECLARE dashcompid = f8 WITH protect, noconstant(0.0)
   DECLARE contentdataid = f8 WITH protect, noconstant(0.0)
   SET ok = findattrbyname(component,"componentName",compname)
   IF (ok > 0)
    CALL log_message(concat("I've found the component name to be: ",compname))
   ELSE
    CALL logandexit("I was unable to find the component name.")
   ENDIF
   SET ok = findattrbyname(component,"templateName",comptemplatename)
   IF (ok > 0)
    CALL log_message(concat("I've found the component template name to be: ",comptemplatename))
   ELSE
    CALL logandexit("I was unable to find the template name.")
   ENDIF
   SET ok = findattrbyname(component,"gridPosLeft",recomdimltxt)
   IF (ok > 0)
    CALL log_message(concat("I found the left position to be ",recomdimltxt))
   ELSE
    CALL logandexit(
     "I wasn't able to find the left position indicator for the recommended dimensions.")
   ENDIF
   SET ok = findattrbyname(component,"gridPosRight",recomdimrtxt)
   IF (ok > 0)
    CALL log_message(concat("I found the right position to be ",recomdimrtxt))
   ELSE
    CALL logandexit(
     "I wasn't able to find the right position indicator for the recommended dimensions.")
   ENDIF
   SET ok = findattrbyname(component,"gridPosTop",recomdimttxt)
   IF (ok > 0)
    CALL log_message(concat("I found the top position to be ",recomdimttxt))
   ELSE
    CALL logandexit(
     "I wasn't able to find the top position indicator for the recommended dimensions.")
   ENDIF
   SET ok = findattrbyname(component,"gridPosBottom",recomdimbtxt)
   IF (ok > 0)
    CALL log_message(concat("I found the bottom position to be ",recomdimbtxt))
   ELSE
    CALL logandexit(
     "I wasn't able to find the bottom position indicator for the recommended dimensions.")
   ENDIF
   SET recomdimwint = ((cnvtint(recomdimrtxt) - cnvtint(recomdimltxt))+ 1)
   SET recomdimhint = ((cnvtint(recomdimbtxt) - cnvtint(recomdimttxt))+ 1)
   SET recomdimtxt = build(recomdimwint,"x",recomdimhint)
   CALL log_message(concat("So, it looks like the recommended dimensions are ",recomdimtxt))
   IF (((( $COMPTYPE="available")) OR (( $COMPTYPE="component template"))) )
    SET ok = findattrbyname(component,"componentFilters",componentfilter)
    IF (ok > 0)
     CALL log_message(concat("I've found the component Filter attribute."))
    ELSE
     CALL logandexit("I wasn't able to find the component Filter attribute.")
    ENDIF
    SET dashtemplatename = "DashboardTemplateName"
    SET dashname = "DashboardName"
    SET startpos = (findstring("dashMaster.",componentfilter,1,0)+ 11)
    SET endpos = (findstring(".pageFilters",componentfilter,1,0) - 12)
    SET searchstring = trim(substring(startpos,endpos,componentfilter))
    SET replacestring = trim(concat(dashtemplatename,".",dashname))
    SET newcomponentfilter = replace(componentfilter,searchstring,replacestring)
    CALL log_message(concat("Replacing componentFilter: '",searchstring,"' with: '",replacestring,
      "'.<br>"))
    SET component = replace(component,componentfilter,newcomponentfilter)
   ENDIF
   IF (( $COMPTYPE="dashboard template"))
    SELECT INTO "nl:"
     se_id = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      dashcompid = se_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to get an ID for the Component. ",errmsg))
    ENDIF
    INSERT  FROM dash_component
     (dash_component_id, orig_dash_component_id, component_name,
     component_template_name, dash_dashboard_id, recommended_dimensions_txt,
     sample_data_txt, content_data_id, org_id,
     shipped_ind, beg_effective_dt_tm, active_ind,
     template_ind, active_status_prsnl_id, last_updt_prsnl_id,
     updt_applctx, updt_cnt, updt_dt_tm,
     updt_id, updt_task)
     VALUES(dashcompid, dashcompid, compname,
     comptemplatename,  $DASHBOARDID, recomdimtxt,
     "", 0, 0.0,
     1, cnvtdatetime(curdate,curtime3), 1,
     1, 0.0, 0.0,
     reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task)
    ;end insert
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to add the Component record. ",errmsg))
    ENDIF
    SELECT INTO "nl:"
     se_id = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      contentdataid = se_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to get an ID for the Component Long Text. ",errmsg))
    ENDIF
    INSERT  FROM long_text_reference
     (long_text_id, long_text, parent_entity_name,
     parent_entity_id, active_ind, active_status_prsnl_id,
     updt_applctx, updt_cnt, updt_dt_tm,
     updt_id, updt_task)
     VALUES(contentdataid, component, "DASH_COMPONENT",
     dashcompid, 1, 0.0,
     reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task)
    ;end insert
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to add the Component Long Text record. ",errmsg))
    ENDIF
    UPDATE  FROM dash_component dc
     SET dc.content_data_id = contentdataid, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt = (
      dc.updt_cnt+ 1),
      dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
      reqinfo->updt_task
     WHERE dc.dash_component_id=dashcompid
    ;end update
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to update the Component record with the Long Text ID. ",
       errmsg))
    ELSE
     CALL log_message(concat("I have added the new Component: ",compname))
    ENDIF
   ENDIF
   IF (( $COMPTYPE="component template"))
    SELECT INTO "nl:"
     FROM dash_component dc
     WHERE dc.component_name=comptemplatename
      AND dc.component_template_name=comptemplatename
      AND dc.active_ind=1
      AND dc.template_ind=1
      AND dc.org_id=0.0
     DETAIL
      componentid = dc.dash_component_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to confirm if the Component Template is in the system. ",
       errmsg))
    ENDIF
    IF (componentid=0.0)
     SELECT INTO "nl:"
      se_id = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       dashcompid = se_id
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to get an ID for the Component. ",errmsg))
     ENDIF
     INSERT  FROM dash_component
      (dash_component_id, orig_dash_component_id, component_name,
      component_template_name, recommended_dimensions_txt, sample_data_txt,
      content_data_id, org_id, shipped_ind,
      beg_effective_dt_tm, active_ind, template_ind,
      active_status_prsnl_id, last_updt_prsnl_id, updt_applctx,
      updt_cnt, updt_dt_tm, updt_id,
      updt_task)
      VALUES(dashcompid, dashcompid, comptemplatename,
      comptemplatename, recomdimtxt, "",
      0, 0.0, 1,
      cnvtdatetime(curdate,curtime3), 1, 1,
      0.0, 0.0, reqinfo->updt_applctx,
      0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
      reqinfo->updt_task)
     ;end insert
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to add the Component record. ",errmsg))
     ENDIF
     SELECT INTO "nl:"
      se_id = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       contentdataid = se_id
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to get an ID for the Component Long Text. ",errmsg))
     ENDIF
     INSERT  FROM long_text_reference
      (long_text_id, long_text, parent_entity_name,
      parent_entity_id, active_ind, active_status_prsnl_id,
      updt_applctx, updt_cnt, updt_dt_tm,
      updt_id, updt_task)
      VALUES(contentdataid, component, "DASH_COMPONENT",
      dashcompid, 1, 0.0,
      reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
      reqinfo->updt_id, reqinfo->updt_task)
     ;end insert
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to add the Component Long Text record. ",errmsg))
     ENDIF
     UPDATE  FROM dash_component dc
      SET dc.content_data_id = contentdataid, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
       (dc.updt_cnt+ 1),
       dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
       reqinfo->updt_task
      WHERE dc.dash_component_id=dashcompid
     ;end update
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to update the Component record with the Long Text ID. ",
        errmsg))
     ELSE
      CALL log_message(concat("I have added the new Component: ",compname))
     ENDIF
    ENDIF
   ENDIF
   IF (( $COMPTYPE="available"))
    SET compname = concat(compname," Avail")
    SELECT INTO "nl:"
     FROM dash_component dc
     WHERE dc.component_name=compname
      AND dc.component_template_name=comptemplatename
      AND dc.active_ind=1
      AND dc.template_ind=0
      AND dc.org_id=0.0
     DETAIL
      componentid = dc.dash_component_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     CALL logandexit(concat("Failed trying to confirm if the Available Component is in the system. ",
       errmsg))
    ENDIF
    IF (componentid=0.0)
     SELECT INTO "nl:"
      se_id = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       dashcompid = se_id
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to get an ID for the Component. ",errmsg))
     ENDIF
     INSERT  FROM dash_component
      (dash_component_id, orig_dash_component_id, component_name,
      component_template_name, recommended_dimensions_txt, sample_data_txt,
      content_data_id, org_id, shipped_ind,
      beg_effective_dt_tm, active_ind, template_ind,
      active_status_prsnl_id, last_updt_prsnl_id, updt_applctx,
      updt_cnt, updt_dt_tm, updt_id,
      updt_task)
      VALUES(dashcompid, dashcompid, compname,
      comptemplatename, recomdimtxt, "",
      0, 0.0, 1,
      cnvtdatetime(curdate,curtime3), 1, 0,
      0.0, 0.0, reqinfo->updt_applctx,
      0, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
      reqinfo->updt_task)
     ;end insert
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to add the Component record. ",errmsg))
     ENDIF
     SELECT INTO "nl:"
      se_id = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       contentdataid = se_id
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to get an ID for the Component Long Text. ",errmsg))
     ENDIF
     INSERT  FROM long_text_reference
      (long_text_id, long_text, parent_entity_name,
      parent_entity_id, active_ind, active_status_prsnl_id,
      updt_applctx, updt_cnt, updt_dt_tm,
      updt_id, updt_task)
      VALUES(contentdataid, component, "DASH_COMPONENT",
      dashcompid, 1, 0.0,
      reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
      reqinfo->updt_id, reqinfo->updt_task)
     ;end insert
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to add the Component Long Text record. ",errmsg))
     ENDIF
     UPDATE  FROM dash_component dc
      SET dc.content_data_id = contentdataid, dc.updt_applctx = reqinfo->updt_applctx, dc.updt_cnt =
       (dc.updt_cnt+ 1),
       dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
       reqinfo->updt_task
      WHERE dc.dash_component_id=dashcompid
     ;end update
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to update the Component record with the Long Text ID. ",
        errmsg))
     ELSE
      CALL log_message(concat("I have added the new Component: ",compname))
     ENDIF
     SELECT INTO "nl:"
      FROM dash_dashboard dd
      PLAN (dd
       WHERE (dd.dash_dashboard_id= $DASHBOARDID))
      DETAIL
       dashtypeid = dd.dash_type_id
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to get the Dash Type ID. ",errmsg))
     ENDIF
     SELECT INTO "nl:"
      se_id = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       dashtypecomprltnid = se_id
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat(
        "Failed trying to get an ID for the Dash Type/Component Relationship record. ",errmsg))
     ENDIF
     INSERT  FROM dash_type_component_reltn
      (dash_type_component_reltn_id, dash_type_id, dash_component_id,
      updt_applctx, updt_cnt, updt_dt_tm,
      updt_id, updt_task)
      VALUES(dashtypecomprltnid, dashtypeid, dashcompid,
      reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
      reqinfo->updt_id, reqinfo->updt_task)
     ;end insert
     IF (error(errmsg,0) > 0)
      CALL logandexit(concat("Failed trying to add the Dash Type/Component Relationship record. ",
        errmsg))
     ELSE
      CALL log_message("I have added the new Dash Type/Component Relationship.")
     ENDIF
    ENDIF
   ENDIF
   CALL log_message("The component was loaded successfully.")
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
