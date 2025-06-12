CREATE PROGRAM assessments_write_back:dba
 PROMPT
  "Output to File/Printer/MINE: " = "MINE",
  "JSON_REQUEST: " = ""
  WITH outdev, json_request
 DECLARE msg3208903 = i4 WITH protect, constant(3208903)
 DECLARE hmsg3208903 = i4 WITH protect, noconstant(0)
 SET hmsg3208903 = uar_srvselectmessage(msg3208903)
 SET hreq = uar_srvcreaterequest(hmsg3208903)
 SET stat = uar_srvsetstring(hreq,"json_request", $JSON_REQUEST)
 SET hrep = uar_srvcreatereply(hmsg3208903)
 SET iret = uar_srvexecute(hmsg3208903,hreq,hrep)
 SET jsonsize = uar_srvgetasissize(hrep,"json_reply")
 SET json = substring(1,jsonsize,uar_srvgetasisptr(hrep,"json_reply"))
 SET _memory_reply_string = json
END GO
