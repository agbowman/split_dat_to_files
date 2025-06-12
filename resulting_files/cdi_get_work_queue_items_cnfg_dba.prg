CREATE PROGRAM cdi_get_work_queue_items_cnfg:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 queue_qual[*]
      2 work_queue_id = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 queue_qual[*]
      2 work_queue_id = f8
      2 attr_cnfg_qual[*]
        3 attr_code_value = f8
        3 req_ind = i2
        3 warn_ind = i2
        3 multi_select_enable_ind = i2
    1 elapsed_time = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lquecnt = i4 WITH protect, noconstant(0)
 DECLARE lqueidx = i4 WITH protect, noconstant(0)
 DECLARE lstatuscnt = i4 WITH protect, noconstant(0)
 DECLARE lexpandidx = i4 WITH protect, noconstant(0)
 DECLARE lcvcnt = i4 WITH protect, noconstant(0)
 DECLARE lattrcnfgcnt = i4 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE cblocksize = i4 WITH protect, constant(100)
 CALL echo(sline)
 CALL echo("********** BEGIN cdi_get_work_queue_items_cnfg **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 SET lquecnt = size(request->queue_qual,5)
 IF (lquecnt <= 0)
  SET sscriptstatus = "F"
  SET sscriptmsg = "REQUEST WAS EMPTY"
  GO TO exit_script
 ENDIF
 SET dstat = alterlist(reply->queue_qual,lquecnt)
 FOR (lqueidx = 1 TO lquecnt)
   SET reply->queue_qual[lqueidx].work_queue_id = request->queue_qual[lqueidx].work_queue_id
 ENDFOR
 SELECT INTO "NL:"
  FROM cdi_work_item_attrib_cnfg ac
  PLAN (ac
   WHERE expand(lexpandidx,1,lquecnt,ac.cdi_work_queue_id,reply->queue_qual[lexpandidx].work_queue_id
    )
    AND ac.cdi_work_queue_id > 0)
  ORDER BY ac.cdi_work_queue_id, ac.attribute_cd
  HEAD REPORT
   lqueidx = 0
  HEAD ac.cdi_work_queue_id
   lqueidx = locateval(lcnt,1,lquecnt,ac.cdi_work_queue_id,reply->queue_qual[lcnt].work_queue_id),
   lattrcnfgcnt = 0
  DETAIL
   IF (lqueidx > 0)
    lattrcnfgcnt = (lattrcnfgcnt+ 1)
    IF (mod(lattrcnfgcnt,cblocksize)=1)
     dstat = alterlist(reply->queue_qual[lqueidx].attr_cnfg_qual,((lattrcnfgcnt+ cblocksize) - 1))
    ENDIF
    reply->queue_qual[lqueidx].attr_cnfg_qual[lattrcnfgcnt].attr_code_value = ac.attribute_cd, reply
    ->queue_qual[lqueidx].attr_cnfg_qual[lattrcnfgcnt].req_ind = ac.required_ind, reply->queue_qual[
    lqueidx].attr_cnfg_qual[lattrcnfgcnt].warn_ind = ac.warn_ind,
    reply->queue_qual[lqueidx].attr_cnfg_qual[lattrcnfgcnt].multi_select_enable_ind = ac
    .multi_select_enable_ind
   ENDIF
  FOOT  ac.cdi_work_queue_id
   IF (lqueidx > 0)
    dstat = alterlist(reply->queue_qual[lqueidx].attr_cnfg_qual,lattrcnfgcnt)
   ENDIF
  WITH nocounter
 ;end select
 SET sscriptstatus = "S"
 SET sscriptmsg = "GET ATTRIBUTE CONFIGURATION SUCCESS"
#exit_script
 SET reply->status_data.status = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationname = "GET"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_work_queue_items_cnfg"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 SET reply->elapsed_time = delapsedtime
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 04/07/2016")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END cdi_get_work_queue_items_cnfg **********")
 CALL echo(sline)
END GO
