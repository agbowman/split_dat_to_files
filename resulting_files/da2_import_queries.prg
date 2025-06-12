CREATE PROGRAM da2_import_queries
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting da2_import_queries script."
 DECLARE app = i4 WITH noconstant(5000)
 DECLARE task = i4 WITH noconstant(3202004)
 DECLARE req = i4 WITH noconstant(5009201)
 DECLARE happ = i4 WITH noconstant(0)
 DECLARE htask = i4 WITH noconstant(0)
 DECLARE hrequest = i4 WITH noconstant(0)
 DECLARE hreq = i4 WITH noconstant(0)
 DECLARE hreply = i4 WITH noconstant(0)
 DECLARE hitem = i4 WITH noconstant(0)
 DECLARE crmstatus = i4 WITH noconstant(0)
 DECLARE vc_return_message = vc WITH noconstant("")
 DECLARE i_fail = i4 WITH noconstant(0)
 DECLARE ecrmok = i4 WITH constant(0)
 DECLARE rdm_infile_name = vc WITH noconstant("")
 DECLARE rdm_length = i4 WITH noconstant(0)
 DECLARE rdm_rptcnt = i4 WITH noconstant(0)
 DECLARE rdm_filename = vc WITH noconstant("")
 DECLARE file = vc WITH noconstant("")
 DECLARE path = vc WITH noconstant("")
 DECLARE path2 = vc WITH noconstant("")
 DECLARE length = i4 WITH noconstant(0)
 DECLARE index = i4 WITH noconstant(0)
 DECLARE install_dir = vc WITH constant("cer_install:")
 SET rdm_current_status = "S"
 FREE RECORD queries
 RECORD queries(
   1 list[*]
     2 filename = vc
 )
 SET rdm_infile_name =  $1
 SET index = findstring(":",rdm_infile_name)
 IF (index=0)
  SET rdm_infile_name = build(build(install_dir, $1))
 ENDIF
 CALL echo(build2("Importing ",rdm_infile_name))
 SET logical csv_name value(rdm_infile_name)
 SET rdm_stat = findfile(rdm_infile_name)
 IF (rdm_stat=0)
  SET vc_return_message = concat(trim(rdm_infile_name)," file was not found.")
  SET i_fail = 1
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  DETAIL
   rdm_rptcnt += 1
   IF (mod(rdm_rptcnt,10)=1)
    rdm_stat = alterlist(queries->list,(rdm_rptcnt+ 9))
   ENDIF
   rdm_filename = trim(t.line),
   CALL echo(build2("rdm_filename=",rdm_filename)), index = findstring(":",rdm_filename)
   IF (index=0)
    rdm_filename = build(install_dir,rdm_filename), index = size(install_dir)
   ENDIF
   length = size(rdm_filename), path = logical(nullterm(substring(1,(index - 1),rdm_filename)))
   IF (substring(size(path),1,path) != "/")
    path2 = concat(path,"/"), path = path2
   ENDIF
   CALL echo(build2("path=",path)), file = substring((index+ 1),(length - index),rdm_filename),
   CALL echo(build2("file=",file)),
   queries->list[rdm_rptcnt].filename = concat(path,file)
  WITH nocounter, maxcol = 2100
 ;end select
 SET rdm_stat = alterlist(queries->list,rdm_rptcnt)
 CALL echorecord(queries)
 SET crmstatus = uar_crmbeginapp(app,happ)
 IF (((crmstatus != ecrmok) OR (happ=0)) )
  SET vc_return_message = "Failed return from uar_crmBeginApp"
  SET i_fail = 1
  GO TO exit_script
 ELSE
  CALL echo("Good return from CrmBeginApp")
 ENDIF
 SET crmstatus = uar_crmbegintask(happ,task,htask)
 IF (((crmstatus != ecrmok) OR (htask=0)) )
  SET vc_return_message = "Failed return from uar_crmBeginTask"
  SET stat = uar_crmendapp(happ)
  SET i_fail = 1
  GO TO exit_script
 ELSE
  CALL echo("Good return from CrmBeginTask")
 ENDIF
 SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
 IF (((crmstatus != ecrmok) OR (hreq=0)) )
  SET vc_return_message = concat("Begin request failed with status: ",build(crmstatus))
  SET stat = uar_crmendtask(htask)
  SET stat = uar_crmendapp(happ)
  SET i_fail = 1
  GO TO exit_script
 ELSE
  CALL echo("Good return from CrmBeginReq")
 ENDIF
 SET hrequest = uar_crmgetrequest(hreq)
 IF (hrequest=0)
  SET vc_return_message = concat("Invalid hRequest handle returned from CrmGetRequest")
  SET stat = uar_crmendreq(hreq)
  SET stat = uar_crmendtask(htask)
  SET stat = uar_crmendapp(happ)
  SET i_fail = 1
  GO TO exit_script
 ELSE
  CALL echo("Good return from CrmGetReq")
  SET querycount = size(queries->list,5)
  FOR (queryindex = 1 TO querycount)
    SET hitem = uar_srvadditem(hrequest,"queries")
    SET stat = uar_srvsetstring(hitem,"filename",nullterm(queries->list[querycount].filename))
    IF (stat=0)
     SET vc_return_message = concat("Unable to set request data for filename")
     SET stat = uar_crmendreq(hreq)
     SET stat = uar_crmendtask(htask)
     SET stat = uar_crmendapp(happ)
     SET i_fail = 1
     GO TO exit_script
    ELSE
     CALL echo("Good return from SrvSetString")
    ENDIF
  ENDFOR
 ENDIF
 SET crmstatus = uar_crmperform(hreq)
 IF (crmstatus != ecrmok)
  SET vc_return_message = concat("Invalid CrmPerform return status of ",cnvtstring(crmstatus))
  SET stat = uar_crmendreq(hreq)
  SET stat = uar_crmendtask(htask)
  SET stat = uar_crmendapp(happ)
  SET i_fail = 1
  GO TO exit_script
 ELSE
  CALL echo("Good return from CrmPerform")
  SET hreply = uar_crmgetreply(hreq)
  IF (hreply=0)
   SET vc_return_message = concat("Error in CrmGetReply, invalid handle returned.")
   SET stat = uar_crmendreq(hreq)
   SET stat = uar_crmendtask(htask)
   SET stat = uar_crmendapp(happ)
   SET i_fail = 1
   GO TO exit_script
  ELSE
   SET htransstat = uar_srvgetstruct(hreply,"transaction_status")
   IF (htransstat=null)
    SET vc_return_message = concat(
     "Error in CrmGetReply, invalid transaction_status handle returned.")
    SET stat = uar_crmendreq(hreq)
    SET stat = uar_crmendtask(htask)
    SET stat = uar_crmendapp(happ)
    SET i_fail = 1
    GO TO exit_script
   ELSE
    CALL echo(build("success_ind = ",uar_srvgetshort(htransstat,"success_ind")))
    CALL echo(build("debug_error_message = ",uar_srvgetstringptr(htransstat,"debug_error_message")))
   ENDIF
  ENDIF
 ENDIF
 SET stat = uar_crmendreq(hreq)
 SET stat = uar_crmendtask(htask)
 SET stat = uar_crmendapp(happ)
#exit_script
 IF (i_fail=1)
  CALL echo(vc_return_message)
  SET rdm_current_status = "F"
  SET readme_data->status = "F"
  SET readme_data->message = vc_return_message
 ENDIF
END GO
