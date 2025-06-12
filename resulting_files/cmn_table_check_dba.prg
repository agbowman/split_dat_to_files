CREATE PROGRAM cmn_table_check:dba
 PROMPT
  "outdev    :  " = mine,
  "table name:  " = ""
  WITH outdev, tablename
 RECORD response(
   1 table_name = vc
   1 node[*]
     2 node_name = vc
     2 table_exists_on_node = vc
     2 table_exists_on_node_bool = i2
     2 table_exists_in_mpage_server = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD tableresponse(
   1 table_exists_on_node = vc
   1 table_exists_on_node_bool = i2
   1 table_exists_in_mpage_server = vc
 ) WITH protect
 DECLARE PUBLIC::main_cmn_table_check(null) = null WITH protect
 DECLARE PUBLIC::forceauthentication(null) = null WITH protect
 DECLARE PUBLIC::checktablenode(nodename=vc,tablename=vc,responsebuffer=vc(ref)) = null WITH protect
 DECLARE PUBLIC::preparecrmhandles(app=i4,task=i4,req=i4,happ=i4(ref),htask=i4(ref),
  hstep=i4(ref)) = i2 WITH protect
 DECLARE PUBLIC::destroycrmhandles(happ=i4(ref),htask=i4(ref),hstep=i4(ref)) = null WITH protect
 SUBROUTINE PUBLIC::forceauthentication(null)
   DECLARE message = vc WITH protect, constant(
    "The CCL sesion must be authenticated in order to run this script")
   IF ((xxcclseclogin->loggedin != true))
    EXECUTE cclseclogin
   ENDIF
   IF ((xxcclseclogin->loggedin != true))
    SET response->status_data.status = "F"
    SET response->status_data.subeventstatus[1].operationname = "Authenticate"
    SET response->status_data.subeventstatus[1].operationstatus = "F"
    SET response->status_data.subeventstatus[1].targetobjectname = "Login"
    SET response->status_data.subeventstatus[1].targetobjectvalue = message
    SELECT INTO  $OUTDEV
     x = 0
     FROM dummyt
     DETAIL
      message
     WITH nocounter
    ;end select
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::preparecrmhandles(app,task,req,happ,htask,hstep)
   CALL uar_crmbeginapp(app,happ)
   IF (happ=0)
    SET response->status_data.status = "F"
    SET response->status_data.subeventstatus[1].operationname = "CrmBeginApp"
    SET response->status_data.subeventstatus[1].operationstatus = "F"
    SET response->status_data.subeventstatus[1].targetobjectname = "3202004"
    SET response->status_data.subeventstatus[1].targetobjectvalue = build2("user ",reqinfo->updt_id,
     " not authorized for application number ",trim(cnvtstring(app),3),".")
    RETURN(false)
   ENDIF
   CALL uar_crmbegintask(happ,task,htask)
   IF (htask=0)
    SET response->status_data.status = "F"
    SET response->status_data.subeventstatus[1].operationname = "CrmBeginTask"
    SET response->status_data.subeventstatus[1].operationstatus = "F"
    SET response->status_data.subeventstatus[1].targetobjectname = "3202004"
    SET response->status_data.subeventstatus[1].targetobjectvalue = build2("user ",reqinfo->updt_id,
     " not authorized for task number ",trim(cnvtstring(task),3),".")
    RETURN(false)
   ENDIF
   CALL uar_crmbeginreq(htask,"",req,hstep)
   IF (hstep=0)
    SET response->status_data.status = "F"
    SET response->status_data.subeventstatus[1].operationname = "CrmBeginReq"
    SET response->status_data.subeventstatus[1].operationstatus = "F"
    SET response->status_data.subeventstatus[1].targetobjectname = "3050012"
    SET response->status_data.subeventstatus[1].targetobjectvalue = build2("request number ",trim(
      cnvtstring(req),3)," not associated to task number ",trim(cnvtstring(task),3),".")
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE PUBLIC::destroycrmhandles(happ,htask,hstep)
   IF (hstep != 0)
    CALL uar_crmendreq(hstep)
    SET hstep = 0
   ENDIF
   IF (htask != 0)
    CALL uar_crmendtask(htask)
    SET htask = 0
   ENDIF
   IF (happ != 0)
    CALL uar_crmendapp(happ)
    SET happ = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::checktablenode(nodename,tablename,responsebuffer)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrep = i4 WITH protect, noconstant(0)
   DECLARE crmprepsuccess = i2 WITH protect, noconstant(false)
   DECLARE bloblen = i4 WITH protect, noconstant(0)
   DECLARE blob = vc WITH protect, noconstant("")
   SET crmprepsuccess = preparecrmhandles(3202004,3202004,3050012,happ,htask,
    hstep)
   IF (crmprepsuccess=true)
    SET hreq = uar_crmgetrequest(hstep)
    SET stat = uar_srvsetstring(hreq,nullterm("program_name"),nullterm("cmn_table_check_node"))
    SET stat = uar_srvsetstring(hreq,nullterm("output_device"),nullterm("MINE"))
    SET stat = uar_srvsetchar(hreq,nullterm("is_odbc"),ichar("0"))
    SET stat = uar_srvsetchar(hreq,nullterm("isBlob"),ichar("1"))
    SET stat = uar_srvsetstring(hreq,nullterm("params"),nullterm(concat("^MINE^,^",tablename,"^")))
    SET stat = uar_crmperformas(hstep,nullterm(concat("cpmscript_mpage_",nullterm(nodename))))
    IF (stat=0)
     SET hrep = uar_crmgetreply(hstep)
     SET bloblen = uar_srvgetasissize(hrep,nullterm("document"))
     SET blob = substring(1,bloblen,uar_srvgetasisptr(hrep,nullterm("document")))
     IF (validate(debug_ind,0)=1)
      CALL echo(build2("blob: ",blob))
     ENDIF
     SET stat = cnvtjsontorec(blob)
     SET responsebuffer->table_exists_on_node = evaluate(record_data->table_exists,true,"yes","NO")
     SET responsebuffer->table_exists_on_node_bool = record_data->table_exists
     SET responsebuffer->table_exists_in_mpage_server = evaluate(record_data->table_accessible,true,
      "yes","NO")
    ELSE
     SET response->status_data.status = "F"
     SET response->status_data.subeventstatus[1].operationname = "CrmPerformAs"
     SET response->status_data.subeventstatus[1].operationstatus = "F"
     SET response->status_data.subeventstatus[1].targetobjectname = concat("cpmscript_mpage_",
      nodename)
     SET response->status_data.subeventstatus[1].targetobjectvalue = build2(
      "CrmPerformAs failed for request 3050012 against service cpmscript_mpage_",nodename,
      " with status ",trim(cnvtstring(stat),3))
    ENDIF
   ENDIF
   CALL destroycrmhandles(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE PUBLIC::main_cmn_table_check(null)
   DECLARE the_table_name = vc WITH protect, constant(cnvtupper( $TABLENAME))
   DECLARE nodename = vc WITH protect, noconstant("")
   DECLARE nodenames = vc WITH protect, noconstant("")
   DECLARE nodecount = i4 WITH protect, noconstant(1)
   SET response->table_name = the_table_name
   CALL forceauthentication(null)
   EXECUTE ccluarxhost:dba
   SET nodenames = uar_gethostnames(nullterm(curdomain))
   SET nodename = piece(nodenames,"|",nodecount,"|")
   WHILE (nodename != "|"
    AND (response->status_data.status != "F"))
     SET stat = initrec(tableresponse)
     CALL checktablenode(nodename,the_table_name,tableresponse)
     IF ((response->status_data.status != "F"))
      SET stat = alterlist(response->node,nodecount)
      SET response->node[nodecount].node_name = nodename
      SET response->node[nodecount].table_exists_on_node = tableresponse->table_exists_on_node
      SET response->node[nodecount].table_exists_on_node_bool = tableresponse->
      table_exists_on_node_bool
      SET response->node[nodecount].table_exists_in_mpage_server = tableresponse->
      table_exists_in_mpage_server
      SET nodecount = (nodecount+ 1)
      SET nodename = piece(nodenames,"|",nodecount,"|")
     ENDIF
   ENDWHILE
   IF ((response->status_data.status != "F"))
    SET response->status_data.status = "S"
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(response)
   ENDIF
 END ;Subroutine
 IF (validate(_memory_reply_string)=false)
  DECLARE _memory_reply_string = vc WITH protect, noconstant("")
 ENDIF
 CALL main_cmn_table_check(null)
#exit_script
 SET _memory_reply_string = cnvtrectojson(response)
END GO
