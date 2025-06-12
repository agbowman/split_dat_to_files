CREATE PROGRAM bsc_get_med_interval_flags:dba
 SET modify = predeclare
 RECORD reply(
   1 syn_list[*]
     2 synonym_id = f8
     2 last_admin_disp_basis_flag = i2
     2 med_interval_warn_flag = i2
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
 DECLARE istart = i4 WITH protect, noconstant(1)
 DECLARE isize = i4 WITH protect, constant(50)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE slastmod = c3 WITH private, noconstant("")
 DECLARE smoddate = c10 WITH private, noconstant("")
 SET reply->status_data.status = "F"
 CALL echo("********Executing bsc_get_med_interval_flags********")
 SET irequestcnt = size(request->syn_list,5)
 IF (irequestcnt <= 0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET itotal = (ceil((cnvtreal(irequestcnt)/ isize)) * isize)
 SET istat = alterlist(request->syn_list,itotal)
 SET istart = 1
 FOR (i = (irequestcnt+ 1) TO itotal)
   SET request->syn_list[i].synonym_id = request->syn_list[irequestcnt].synonym_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((itotal - 1)/ isize)))),
   order_catalog_synonym ocs
  PLAN (d1
   WHERE initarray(istart,evaluate(d1.seq,1,1,(istart+ isize))))
   JOIN (ocs
   WHERE expand(i,istart,(istart+ (isize - 1)),ocs.synonym_id,request->syn_list[i].synonym_id))
  HEAD REPORT
   ireplycnt = 0, istat = alterlist(reply->syn_list,itotal)
  HEAD ocs.synonym_id
   ireplycnt = (ireplycnt+ 1), reply->syn_list[ireplycnt].synonym_id = ocs.synonym_id, reply->
   syn_list[ireplycnt].last_admin_disp_basis_flag = ocs.last_admin_disp_basis_flag,
   reply->syn_list[ireplycnt].med_interval_warn_flag = ocs.med_interval_warn_flag
  FOOT REPORT
   istat = alterlist(reply->syn_list,ireplycnt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
  CALL echo(errmsg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SET slastmod = "000"
 SET smoddate = "08/19/2009"
 SET modify = nopredeclare
END GO
