CREATE PROGRAM cnfg_clob_gttd_check:dba
 PROMPT
  "output device [MINE]:" = mine,
  "format (HTML, JSON, XML, ECHO) [HTML]:" = "HTML"
  WITH outdev, format
 DECLARE PUBLIC::main_cnfg_clob_gttd_check(null) = null WITH protect
 DECLARE PUBLIC::generatehtml(null) = vc WITH protect
 DECLARE PUBLIC::generatefailbody(null) = vc WITH protect
 DECLARE PUBLIC::generatesuccessbody(null) = vc WITH protect
 SUBROUTINE PUBLIC::generatehtml(null)
   DECLARE html = vc WITH protect, noconstant("")
   SET html = concat("<!DOCTYPE html>","<html>","<head>","<title>",response->table_name,
    " existence check</title>","<style>","table, th, td {","border: 1px solid black;","}",
    "</style>","</head>")
   IF ((response->status_data.status="S"))
    SET html = concat(html,generatesuccessbody(null))
   ELSE
    SET html = concat(html,generatefailbody(null))
   ENDIF
   SET html = concat(html,"</html>")
   RETURN(html)
 END ;Subroutine
 SUBROUTINE PUBLIC::generatefailbody(null)
   DECLARE html = vc WITH protect, noconstant("")
   SET html = concat("<body>","<span>",response->table_name," existence check failed.</span>",
    "<span>OperationName = ",
    response->status_data.subeventstatus[1].operationname,"</span>","<span>OperationStatus = ",
    response->status_data.subeventstatus[1].operationstatus,"</span>",
    "<span>TargetObjectName = ",response->status_data.subeventstatus[1].targetobjectname,"</span>",
    "<span>TargetObjectValue= ",response->status_data.subeventstatus[1].targetobjectvalue,
    "</span>","</body>")
   RETURN(html)
 END ;Subroutine
 SUBROUTINE PUBLIC::generatesuccessbody(null)
   DECLARE html = vc WITH protect, noconstant("")
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET html = concat("<body>","<span>",response->table_name," existence check</span>","<div>",
    "<table>","<tr>","<th>node name</td>","<th>table exists?</td>",
    "<th>table exists in mpage server?</td>",
    "</tr>")
   FOR (idx = 1 TO size(response->node,5))
     SET html = concat(html,"<tr>","<td>",response->node[idx].node_name,"</td>",
      "<td>",response->node[idx].table_exists_on_node,"</td>","<td>",response->node[idx].
      table_exists_in_mpage_server,
      "</td>","</tr>")
   ENDFOR
   SET html = concat(html,"</table>","</div>","</body>")
   RETURN(html)
 END ;Subroutine
 SUBROUTINE PUBLIC::main_cnfg_clob_gttd_check(null)
   IF (validate(_memory_reply_string)=false)
    DECLARE _memory_reply_string = vc WITH protect, noconstant("")
   ENDIF
   EXECUTE cmn_table_check  $OUTDEV, "cnfg_clob_gttd"
   SET stat = cnvtjsontorec(_memory_reply_string)
   CASE (cnvtupper( $FORMAT))
    OF "HTML":
     SET _memory_reply_string = generatehtml(null)
    OF "XML":
     SET _memory_reply_string = cnvtrectoxml(response)
    OF "ECHO":
     CALL echorecord(response)
   ENDCASE
 END ;Subroutine
 CALL main_cnfg_clob_gttd_check(null)
END GO
