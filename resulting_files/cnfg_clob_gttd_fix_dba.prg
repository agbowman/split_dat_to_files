CREATE PROGRAM cnfg_clob_gttd_fix:dba
 PROMPT
  "output device [MINE]:" = mine,
  "format (HTML, JSON, XML, ECHO) [HTML]" = "HTML"
  WITH outdev, format
 DECLARE PUBLIC::main_cnfg_clob_gttd_check(null) = null
 DECLARE PUBLIC::forceauthentication(null) = null
 DECLARE PUBLIC::fixit(null) = null
 DECLARE PUBLIC::fixnode(nodename=vc) = null
 RECORD reply_data(
   1 repaired_node[*]
     2 node_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
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
    SELECT
     x = 0
     FROM dummyt
     DETAIL
      message
     WITH nocounter
    ;end select
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::fixit(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE repairedcount = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO size(response->node,5))
     IF ((response->node[idx].table_exists_on_node_bool=false))
      CALL fixnode(response->node[idx].node_name)
      SET repairedcount = (repairedcount+ 1)
      SET stat = alterlist(reply_data->repaired_node,repairedcount)
      SET reply_data->repaired_node[repairedcount].node_name = response->node[idx].node_name
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE PUBLIC::fixnode(nodename)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrep = i4 WITH protect, noconstant(0)
   DECLARE bloblen = i4 WITH protect, noconstant(0)
   DECLARE blob = vc WITH protect, noconstant("")
   DECLARE first_occurrence = i4 WITH protect, constant(1)
   CALL uar_crmbeginapp(3202004,happ)
   CALL uar_crmbegintask(happ,3202004,htask)
   CALL uar_crmbeginreq(htask,"",3050012,hstep)
   IF (happ=0)
    SET response->status_data.status = "F"
    SET response->status_data.subeventstatus[1].operationname = "CrmBeginApp"
    SET response->status_data.subeventstatus[1].operationstatus = "F"
    SET response->status_data.subeventstatus[1].targetobjectname = "3202004"
    SET response->status_data.subeventstatus[1].targetobjectvalue = build2("user ",reqinfo->updt_id,
     " not authorized for application number 3202004.")
   ELSEIF (htask=0)
    SET response->status_data.status = "F"
    SET response->status_data.subeventstatus[1].operationname = "CrmBeginTask"
    SET response->status_data.subeventstatus[1].operationstatus = "F"
    SET response->status_data.subeventstatus[1].targetobjectname = "3202004"
    SET response->status_data.subeventstatus[1].targetobjectvalue = build2("user ",reqinfo->updt_id,
     " not authorized for task number 3202004.")
   ELSEIF (hstep=0)
    SET response->status_data.status = "F"
    SET response->status_data.subeventstatus[1].operationname = "CrmBeginReq"
    SET response->status_data.subeventstatus[1].operationstatus = "F"
    SET response->status_data.subeventstatus[1].targetobjectname = "3050012"
    SET response->status_data.subeventstatus[1].targetobjectvalue = build2(
     "request number 3050012 not associated to task number 3202004.")
   ELSE
    SET hreq = uar_crmgetrequest(hstep)
    SET stat = uar_srvsetstring(hreq,nullterm("program_name"),nullterm("cmn_run_create_clob_gttd"))
    SET stat = uar_srvsetstring(hreq,nullterm("output_device"),nullterm("MINE"))
    SET stat = uar_srvsetchar(hreq,nullterm("is_odbc"),ichar("0"))
    SET stat = uar_srvsetchar(hreq,nullterm("isBlob"),ichar("1"))
    SET stat = uar_srvsetstring(hreq,nullterm("params"),nullterm(concat("^MINE^,^",tablename,"^")))
    SET stat = uar_crmperformas(hstep,nullterm(concat("cpmscriptbatchp_",nullterm(nodename))))
    IF (stat=0)
     SET hrep = uar_crmgetreply(hstep)
     SET bloblen = uar_srvgetasissize(hrep,nullterm("document"))
     SET blob = substring(1,bloblen,uar_srvgetasisptr(hrep,nullterm("document")))
     IF (validate(debug_ind,0)=1)
      CALL echo(build2("blob: ",blob))
     ENDIF
     SET blob = replace(blob,"RESPONSE","NODE_RESPONSE",first_occurrence)
     SET stat = cnvtjsontorec(blob)
     IF ((node_response->status_data.status="F"))
      SET response->status_data.status = "F"
      SET response->status_data.subeventstatus[1].operationname = node_response->status_data.
      subeventstatus[1].operationname
      SET response->status_data.subeventstatus[1].operationstatus = node_response->status_data.
      subeventstatus[1].operationstatus
      SET response->status_data.subeventstatus[1].targetobjectname = node_response->status_data.
      subeventstatus[1].targetobjectname
      SET response->status_data.subeventstatus[1].targetobjectvalue = node_response->status_data.
      subeventstatus[1].targetobjectvalue
     ENDIF
    ELSE
     SET response->status_data.status = "F"
     SET response->status_data.subeventstatus[1].operationname = "CrmPerformAs"
     SET response->status_data.subeventstatus[1].operationstatus = "F"
     SET response->status_data.subeventstatus[1].targetobjectname = concat("cpmscript_mpage_",
      nodename)
     SET response->status_data.subeventstatus[1].targetobjectvalue = build2(
      "CrmPerformAs faile for request 3050012 against service cpmscript_mpage_",nodename,
      " with status ",stat)
    ENDIF
   ENDIF
   CALL uar_crmendreq(hstep)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
 END ;Subroutine
 SUBROUTINE PUBLIC::main_cnfg_clob_gttd_check(null)
   IF (validate(_memory_reply_string)=false)
    DECLARE _memory_reply_string = vc WITH protect, noconstant("")
   ENDIF
   CALL forceauthentication(null)
   EXECUTE cmn_table_check  $OUTDEV, "cnfg_clob_gttd"
   SET stat = cnvtjsontorec(_memory_reply_string)
   CALL fixit(null)
 END ;Subroutine
 CALL main_cnfg_clob_gttd_check(null)
#exit_script
 SET _memory_reply_string = cnvtrectojson(reply_data)
END GO
