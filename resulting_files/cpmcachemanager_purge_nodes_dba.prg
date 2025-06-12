CREATE PROGRAM cpmcachemanager_purge_nodes:dba
 FREE RECORD reply
 RECORD reply(
   1 nodes[*]
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD purge
 RECORD purge(
   1 nodes[*]
     2 id = f8
 )
 SUBROUTINE purge_node(node_id)
  DELETE  FROM code_value_changes cvc
   WHERE cvc.code_value_node_id=node_id
   WITH nocounter
  ;end delete
  DELETE  FROM code_value_node cvn
   WHERE cvn.code_value_node_id=node_id
   WITH nocounter
  ;end delete
 END ;Subroutine
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE nodecnt = i4 WITH noconstant(0), protect
 CALL echorecord(request)
 SET reply->status_data.status = "F"
 SET nodecnt = size(request->nodes,5)
 FOR (i = 1 TO nodecnt)
   SET request->nodes[i].name = trim(cnvtlower(request->nodes[i].name),3)
 ENDFOR
 SET i = 0
 SELECT INTO "nl:"
  cvn.node_name, cvn.code_value_node_id
  FROM code_value_node cvn
  WHERE  NOT (expand(nodecnt,1,nodecnt,trim(cnvtlower(cvn.node_name),3),request->nodes[nodecnt].name)
  )
  DETAIL
   i = (i+ 1), stat = alterlist(reply->nodes,i), stat = alterlist(purge->nodes,i),
   reply->nodes[i].name = trim(cnvtlower(cvn.node_name),3), purge->nodes[i].id = cvn
   .code_value_node_id
  WITH nocounter
 ;end select
 SET nodecnt = size(reply->nodes,5)
 FOR (i = 1 TO nodecnt)
   CALL purge_node(purge->nodes[i].id)
 ENDFOR
 COMMIT
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
