CREATE PROGRAM ctp_execute_on_node:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Zip File" = "",
  "Node (to execute on)" = ""
  WITH outdev, zipfile, node
 CREATE CLASS crmsrv_perform
 init
 DECLARE PRIVATE::app_num = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::task_num = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::req_num = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::req_name = vc WITH protect, noconstant(" ")
 DECLARE PRIVATE::atr_str = vc WITH protect, noconstant(" ")
 DECLARE PRIVATE::err_msg = vc WITH protect, noconstant(" ")
 DECLARE PRIVATE::success = i2 WITH protect, noconstant(false)
 RECORD _::handle(
   1 app = i4
   1 task = i4
   1 step = i4
   1 req = i4
   1 rep = i4
   1 status_data = i4
 ) WITH protect
 DECLARE _::setatr(app_num=i4,task_num=i4,req_num=i4) = null WITH protect
 SUBROUTINE _::setatr(app_num,task_num,req_num)
   SET PRIVATE::app_num = app_num
   SET PRIVATE::task_num = task_num
   SET PRIVATE::req_num = req_num
 END ;Subroutine
 DECLARE _::getatrid(null) = vc WITH protect
 SUBROUTINE _::getatrid(null)
  IF (size(trim(PRIVATE::atr_str))=0)
   SET PRIVATE::atr_str = build("(",PRIVATE::app_num,",",PRIVATE::task_num,",",
    PRIVATE::req_num,")")
  ENDIF
  RETURN(PRIVATE::atr_str)
 END ;Subroutine
 DECLARE _::getrequestname(null) = vc WITH protect
 SUBROUTINE _::getrequestname(null)
  IF (size(trim(PRIVATE::req_name))=0)
   SELECT INTO "nl:"
    FROM request r
    PLAN (r
     WHERE (r.request_number=PRIVATE::req_num))
    DETAIL
     PRIVATE::req_name = r.request_name
    WITH nocounter
   ;end select
  ENDIF
  RETURN(PRIVATE::req_name)
 END ;Subroutine
 DECLARE _::crmbegin(null) = i2 WITH protect
 SUBROUTINE _::crmbegin(null)
   DECLARE atr = vc WITH protect, constant(_::getatrid(0))
   SET stat = - (1)
   SET stat = uar_crmbeginapp(PRIVATE::app_num,_::handle->app)
   IF (stat != 0)
    CALL _::logerror(concat("Error! uar_CrmBeginApp",atr," failed with status: ",build(stat)))
    RETURN(false)
   ENDIF
   SET stat = - (1)
   SET stat = uar_crmbegintask(_::handle->app,PRIVATE::task_num,_::handle->task)
   IF (stat != 0)
    CALL _::logerror(concat("Error! uar_CrmBeginTask",atr," failed with status: ",build(stat)))
    RETURN(false)
   ENDIF
   SET stat = - (1)
   SET stat = uar_crmbeginreq(_::handle->task,nullterm(" "),PRIVATE::req_num,_::handle->step)
   IF (stat != 0)
    CALL _::logerror(concat("Invalid CrmBeginReq",atr," return status of ",build(stat)))
    RETURN(false)
   ENDIF
   IF (stat=0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE _::crmgetrequest(null) = i2 WITH protect
 SUBROUTINE _::crmgetrequest(null)
   DECLARE atr = vc WITH protect, constant(_::getatrid(0))
   SET _::handle->req = uar_crmgetrequest(_::handle->step)
   IF (_::handle->req)
    RETURN(true)
   ELSE
    CALL _::logerror(concat("uar_CrmGetRequest",atr," failed"))
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE _::samenode(node=vc) = i2 WITH protect
 SUBROUTINE _::samenode(node)
   IF (cnvtupper(trim(node,3))=cnvtupper(trim(curnode,3)))
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE _::crmperformas(node_name=vc,service_name=vc) = i2 WITH protect
 SUBROUTINE _::crmperformas(node_name,service_name)
   DECLARE service_node = vc WITH protect, constant(cnvtupper(build(service_name,"_",node_name)))
   DECLARE atr = vc WITH protect, constant(_::getatrid(0))
   SET stat = - (1)
   SET stat = uar_crmperformas(_::handle->step,nullterm(service_node))
   IF (stat != 0)
    CALL _::logerror(concat("uar_CrmPerformAs",atr," returned status of ",build(stat)))
   ENDIF
   IF (stat=0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE _::crmnodeperform(node_name=vc) = i2 WITH protect
 SUBROUTINE _::crmnodeperform(node_name)
   DECLARE uar_crmnodeperform(p1=i4(value),p2=vc(ref)) = i2 WITH image_axp = "crmrtl", image_aix =
   "libcrm.a(libcrm.o)", uar = "CrmNodePerform"
   DECLARE atr = vc WITH protect, constant(_::getatrid(0))
   DECLARE node = vc WITH protect, noconstant(cnvtupper(node_name))
   IF (_::samenode(node_name))
    RETURN(_::crmperform(0))
   ENDIF
   SET stat = - (1)
   SET stat = uar_crmnodeperform(_::handle->step,nullterm(node))
   IF (stat != 0)
    CALL _::logerror(concat("uar_CrmNodePerform",atr," returned status of ",build(stat)))
   ENDIF
   IF (stat=0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE _::crmperform(null) = i2 WITH protect
 SUBROUTINE _::crmperform(null)
   DECLARE atr = vc WITH protect, constant(_::getatrid(0))
   SET stat = - (1)
   SET stat = uar_crmperform(_::handle->step)
   IF (stat != 0)
    CALL _::logerror(concat("uar_CrmPerform",atr," returned status of ",build(stat)))
   ENDIF
   IF (stat=0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE _::crmgetreply(null) = i2 WITH protect
 SUBROUTINE _::crmgetreply(null)
   DECLARE atr = vc WITH protect, constant(_::getatrid(0))
   SET _::handle->rep = uar_crmgetreply(_::handle->step)
   IF (_::handle->rep)
    RETURN(true)
   ELSE
    CALL _::logerror(concat("uar_CrmGetReply",atr," failed"))
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE _::replystatus(null) = vc WITH protect
 SUBROUTINE _::replystatus(null)
  SET _::handle->status_data = uar_srvgetstruct(_::handle->rep,"status_data")
  RETURN(trim(uar_srvgetstringptr(_::handle->status_data,"status")))
 END ;Subroutine
 DECLARE _::crmend(null) = null WITH protect
 SUBROUTINE _::crmend(null)
   IF ((_::handle->step != 0))
    CALL uar_crmendreq(_::handle->step)
   ENDIF
   IF ((_::handle->task != 0))
    CALL uar_crmendtask(_::handle->task)
   ENDIF
   IF ((_::handle->app != 0))
    CALL uar_crmendapp(_::handle->app)
   ENDIF
 END ;Subroutine
 DECLARE _::logerror(value=vc) = null
 SUBROUTINE _::logerror(value)
  DECLARE data_type = c1 WITH protect, constant(cnvtupper(reflect(value)))
  CASE (data_type)
   OF "I":
    SET PRIVATE::success = false
   ELSE
    SET PRIVATE::err_msg = value
    CALL echo(PRIVATE::err_msg)
    SET PRIVATE::success = false
  ENDCASE
 END ;Subroutine
 DECLARE _::logsuccess(null) = null
 SUBROUTINE _::logsuccess(null)
   SET PRIVATE::success = true
 END ;Subroutine
 DECLARE _::getstatus(message=vc(ref)) = i2 WITH protect
 SUBROUTINE _::getstatus(message)
  SET message = PRIVATE::err_msg
  RETURN(PRIVATE::success)
 END ;Subroutine
 END; class scope:init
 WITH copy = 0
 DECLARE loadwrapperoutput(node_name=vc,out_file_name=vc,file_content=vc(ref),msg=vc(ref)) = i2 WITH
 protect
 SUBROUTINE loadwrapperoutput(node_name,out_file_name,file_content,msg)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrep = i4 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE success = i2 WITH protect, noconstant(0)
   DECLARE status = vc WITH protect, noconstant(" ")
   DECLARE module_dir = vc WITH protect, noconstant(" ")
   DECLARE module_name = vc WITH protect, noconstant(" ")
   DECLARE request_name = vc WITH protect, noconstant(" ")
   DECLARE DISCERN::eksgetsource = null WITH class(crmsrv_perform)
   SET pos = findstring("/",out_file_name,1,1)
   SET module_dir = substring(1,pos,out_file_name)
   SET module_name = substring((pos+ 1),size(out_file_name),out_file_name)
   CALL DISCERN::eksgetsource.setatr(5000,3202004,3011001)
   IF (DISCERN::eksgetsource.crmbegin(0))
    IF (DISCERN::eksgetsource.crmgetrequest(0))
     SET hreq = discern::eksgetsource.handle->req
     SET stat = uar_srvsetstring(hreq,"Module_Dir",nullterm(module_dir))
     SET stat = uar_srvsetstring(hreq,"Module_Name",nullterm(module_name))
     SET stat = uar_srvsetshort(hreq,"bAsBlob",1)
     IF (DISCERN::eksgetsource.crmperformas(node_name,"cpmscript"))
      IF (DISCERN::eksgetsource.crmgetreply(0))
       SET status = DISCERN::eksgetsource.replystatus(0)
       IF (status="S")
        SET file_content = uar_srvgetasisptr(discern::eksgetsource.handle->rep,"Data_Blob")
        CALL DISCERN::eksgetsource.logsuccess(1)
       ELSE
        SET request_name = DISCERN::eksgetsource.getrequestname(0)
        CALL DISCERN::eksgetsource.logerror(concat(request_name," returned status = ",status))
        SET hrep = discern::eksgetsource.handle->status_data
        FOR (idx = 1 TO uar_srvgetitemcount(hrep,"subeventstatus"))
         SET hitem = uar_srvgetitem(hrep,"subeventstatus",(idx - 1))
         CALL cclexception(0,"E",uar_srvgetstringptr(hitem,"TargetObjectValue"))
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL DISCERN::eksgetsource.crmend(0)
   SET success = DISCERN::eksgetsource.getstatus(msg)
   RETURN(success)
 END ;Subroutine
 DECLARE executewrapper(zip_file_name=vc,out_file_name=vc,node_name=vc,msg=vc(ref)) = i2 WITH protect
 SUBROUTINE executewrapper(zip_file_name,out_file_name,node_name,msg)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrep = i4 WITH protect, noconstant(0)
   DECLARE hqualreq = i4 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE status = vc WITH protect, noconstant(" ")
   DECLARE success = i2 WITH protect, noconstant(0)
   DECLARE request_name = vc WITH protect, noconstant(" ")
   DECLARE DISCERN::vcclrunprogram = null WITH class(crmsrv_perform)
   CALL DISCERN::vcclrunprogram.setatr(5000,3202004,3050002)
   IF (DISCERN::vcclrunprogram.crmbegin(0))
    IF (DISCERN::vcclrunprogram.crmgetrequest(0))
     SET hreq = discern::vcclrunprogram.handle->req
     SET stat = uar_srvsetstring(hreq,"program_name","CTP_EXTRACT_WRAPPER")
     SET stat = uar_srvsetstring(hreq,"output_device","NL:")
     SET stat = uar_srvsetstring(hreq,"IsBlob","1")
     SET stat = uar_srvsetstring(hreq,"params",nullterm(build('"',out_file_name,'","',zip_file_name,
        '"')))
     SET hqualreq = uar_srvadditem(hreq,"qual")
     SET stat = uar_srvsetstring(hqualreq,"parameter",nullterm(out_file_name))
     SET hqualreq = uar_srvadditem(hreq,"qual")
     SET stat = uar_srvsetstring(hqualreq,"parameter",nullterm(zip_file_name))
     IF (DISCERN::vcclrunprogram.crmnodeperform(node_name))
      IF (DISCERN::vcclrunprogram.crmgetreply(0))
       SET status = DISCERN::vcclrunprogram.replystatus(0)
       IF (status IN ("S", "Z"))
        CALL DISCERN::vcclrunprogram.logsuccess(1)
       ELSE
        SET request_name = DISCERN::vcclrunprogram.getrequestname(0)
        CALL DISCERN::vcclrunprogram.logerror(concat(request_name," returned status = ",status))
        SET hrep = discern::vcclrunprogram.handle->rep
        FOR (idx = 1 TO uar_srvgetitemcount(hrep,"info_line"))
         SET hitem = uar_srvgetitem(hrep,"info_line",(idx - 1))
         CALL cclexception(0,"E",uar_srvgetstringptr(hitem,"new_line"))
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL DISCERN::vcclrunprogram.crmend(0)
   SET success = DISCERN::vcclrunprogram.getstatus(msg)
   RETURN(success)
 END ;Subroutine
 EXECUTE cpm_create_file_name "ctp", "dat"
 DECLARE outdev_file = vc WITH protect, constant(cpm_cfn_info->file_name_full_path)
 DECLARE lf = c1 WITH protect, constant(char(10))
 DECLARE error_message = vc WITH protect, noconstant("<<unknown>>")
 DECLARE contents = vc WITH protect, noconstant(" ")
 DECLARE success = i2 WITH protect, noconstant(false)
 IF (executewrapper( $ZIPFILE,outdev_file, $NODE,error_message))
  IF (loadwrapperoutput( $NODE,outdev_file,contents,error_message))
   SET success = true
  ENDIF
 ENDIF
 IF (success)
  SET _memory_reply_string = contents
 ELSE
  SET _memory_reply_string = concat(">>>>ERROR<<<<",lf,error_message)
 ENDIF
#abort
 SET last_mod = "001 03/13/18 CJ012163 Class/Subroutine incompatibility"
END GO
