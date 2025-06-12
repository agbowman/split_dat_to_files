CREATE PROGRAM bsc_get_org_ids_by_encntr_ids:dba
 RECORD reply(
   1 org_list[*]
     2 encntr_id = f8
     2 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE item_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE iterator = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, constant(40)
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 DECLARE encntr_id_cnt = i4 WITH protect, constant(size(request->encntr_list,5))
 IF (encntr_id_cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET ntotal = (ceil((cnvtreal(encntr_id_cnt)/ nsize)) * nsize)
 SET stat = alterlist(request->encntr_list,ntotal)
 FOR (i = (encntr_id_cnt+ 1) TO ntotal)
   SET request->encntr_list[i].encntr_id = request->encntr_list[encntr_id_cnt].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   encounter e
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
   JOIN (e
   WHERE expand(iterator,start,(start+ (nsize - 1)),e.encntr_id,request->encntr_list[iterator].
    encntr_id)
    AND e.encntr_id > 0)
  HEAD REPORT
   item_cnt = 0
  DETAIL
   item_cnt = (item_cnt+ 1)
   IF (item_cnt > size(reply->org_list,5))
    stat = alterlist(reply->org_list,(item_cnt+ 9))
   ENDIF
   reply->org_list[item_cnt].encntr_id = e.encntr_id, reply->org_list[item_cnt].organization_id = e
   .organization_id
  FOOT REPORT
   stat = alterlist(reply->org_list,item_cnt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
  CALL echo(errmsg)
 ELSEIF (item_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 GO TO exit_script
#exit_script
 SET last_mod = "000"
 SET mod_date = "06/18/2009"
 SET modify = nopredeclare
END GO
