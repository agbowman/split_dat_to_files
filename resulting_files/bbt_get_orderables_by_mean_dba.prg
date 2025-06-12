CREATE PROGRAM bbt_get_orderables_by_mean:dba
 RECORD reply(
   1 qual[*]
     2 catalog_cd = f8
     2 catalog_disp = c40
     2 catalog_mean = c12
     2 catalog_desc = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET gsub_program_name = "bbt_get_orderables_by_mean"
 SET activity_type_code_set = 106
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET select_ok_ind = 0
 SET qual_cnt = 0
 SET type_cnt = size(request->typelist,5)
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET idx = 0
 SET failed = 0
 FOR (idx = 1 TO type_cnt)
   SET cdf_meaning = request->typelist[idx].activity_type_mean
   SET stat = uar_get_meaning_by_codeset(activity_type_code_set,cdf_meaning,1,code_value)
   IF (stat=0)
    SET request->typelist[idx].activity_type_cd = code_value
   ELSE
    SET failed = 1
   ENDIF
   CALL echo(request->typelist[idx].activity_type_cd)
 ENDFOR
 IF (failed=1)
  CALL load_process_status("F","select code_value for activity_type_cd's",
   "code_value select FAILED--Script Error!")
  GO TO exit_script
 ENDIF
 SET select_ok_ind = 0
 SET stat = alterlist(reply->qual,50)
 SELECT INTO "nl:"
  d.seq, activity_type_mean = request->typelist[d.seq].activity_type_mean, oc.catalog_cd
  FROM (dummyt d  WITH seq = value(type_cnt)),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (oc.activity_type_cd=request->typelist[d.seq].activity_type_cd)
    AND oc.active_ind=1)
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,50)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 49))
   ENDIF
   reply->qual[qual_cnt].catalog_cd = oc.catalog_cd
  FOOT REPORT
   stat = alterlist(reply->qual,qual_cnt), select_ok_ind = 1
  WITH nocounter, nullreport
 ;end select
 IF (select_ok_ind=1)
  IF (curqual=0)
   CALL load_process_status("Z","select order_catalog",
    "ZERO order_catalog rows found for requested activity-type cdf_meanings")
   GO TO exit_script
  ELSE
   CALL load_process_status("S","select order_catalog","SUCCESS")
   GO TO exit_script
  ENDIF
 ELSE
  CALL load_process_status("F","select order_catalog","select order_catalog FAILED--Script error!")
  GO TO exit_script
 ENDIF
 GO TO exit_script
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = gsub_program_name
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
END GO
