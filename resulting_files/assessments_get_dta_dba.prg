CREATE PROGRAM assessments_get_dta:dba
 PROMPT
  "Output to File/Printer/MINE: " = "MINE",
  "JSON_REQUEST: " = ""
  WITH outdev, json_request
 DECLARE msg3208902 = i4 WITH protect, constant(3208902)
 DECLARE hmsg3208902 = i4 WITH protect, noconstant(0)
 SET hmsg3208902 = uar_srvselectmessage(msg3208902)
 SET hreq = uar_srvcreaterequest(hmsg3208902)
 SET stat = uar_srvsetstring(hreq,"json_request", $JSON_REQUEST)
 SET hrep = uar_srvcreatereply(hmsg3208902)
 SET iret = uar_srvexecute(hmsg3208902,hreq,hrep)
 SET jsonsize = uar_srvgetasissize(hrep,"json_reply")
 SET json = substring(1,jsonsize,uar_srvgetasisptr(hrep,"json_reply"))
 SET _memory_reply_string = json
END GO
