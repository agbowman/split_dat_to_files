CREATE PROGRAM bsc_set_medadmin_ocs_flags:dba
 SET modify = nopredeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE slastmod = c3 WITH private, noconstant("")
 DECLARE smoddate = c10 WITH private, noconstant("")
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE isyncnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET isyncnt = size(request->syn_list,5)
 IF (isyncnt <= 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "No data submitted"
  GO TO exit_script
 ENDIF
 FOR (lcnt = 1 TO isyncnt)
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.autoprog_syn_ind = request->syn_list[lcnt].autoprog_syn_ind
    PLAN (ocs
     WHERE (ocs.synonym_id=request->syn_list[lcnt].synonym_id))
    WITH nocounter
   ;end update
 ENDFOR
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
  CALL echo(errmsg)
  ROLLBACK
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#exit_script
 SET slastmod = "000"
 SET smoddate = "01/15/2013"
END GO
