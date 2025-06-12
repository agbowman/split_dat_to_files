CREATE PROGRAM bsc_get_medadmin_ocs_flags:dba
 SET modify = predeclare
 RECORD reply(
   1 syn_list[*]
     2 synonym_id = f8
     2 autoprog_syn_ind = i2
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE irequestcnt = i4 WITH protect, noconstant(0)
 DECLARE ireplycnt = i4 WITH protect, noconstant(0)
 DECLARE itotal = i4 WITH protect, noconstant(0)
 DECLARE istat = i2 WITH protect, noconstant(0)
 DECLARE isize = i4 WITH protect, constant(50)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE slastmod = c3 WITH private, noconstant("")
 DECLARE smoddate = c10 WITH private, noconstant("")
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 CALL echo("********Executing bsc_get_medadmin_ocs_flags********")
 SET irequestcnt = size(request->syn_list,5)
 SET ireplycnt = 0
 IF (irequestcnt <= 0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET itotal = (ceil((cnvtreal(irequestcnt)/ isize)) * isize)
 SET istat = alterlist(request->syn_list,itotal)
 SET istat = alterlist(reply->syn_list,itotal)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(irequestcnt)),
   order_catalog_synonym ocs
  PLAN (d1)
   JOIN (ocs
   WHERE (ocs.synonym_id=request->syn_list[d1.seq].synonym_id))
  DETAIL
   ireplycnt = (ireplycnt+ 1), reply->syn_list[ireplycnt].synonym_id = ocs.synonym_id, reply->
   syn_list[ireplycnt].autoprog_syn_ind = ocs.autoprog_syn_ind,
   reply->syn_list[ireplycnt].mnemonic = ocs.mnemonic
  FOOT REPORT
   istat = alterlist(reply->syn_list,ireplycnt)
  WITH nocounter
 ;end select
 IF (ireplycnt=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = errmsg
  CALL echo(errmsg)
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
  CALL echo(errmsg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->debug_ind > 0))
  CALL echorecord(reply)
 ENDIF
#exit_script
 SET slastmod = "000"
 SET smoddate = "01/15/2013"
 SET modify = nopredeclare
END GO
