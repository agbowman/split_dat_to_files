CREATE PROGRAM ccl_get_rdbms_compile_objects
 RECORD reply(
   1 cust_script_objects[*]
     2 program_name = c30
     2 object_type = c1
     2 ccl_group = i1
     2 compile_date_time = dq8
     2 ccl_version = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE program_name = vc
 SET program_name = cnvtupper(trim(request->object_name))
 IF (program_name="")
  SET program_name = "*"
 ENDIF
 SELECT DISTINCT INTO "NL:"
  cb_mod.object_name, cb_mod.object_type, cb_mod.date_time"@MEDIUMDATETIME",
  d.group, d.ccl_version
  FROM (
   (
   (SELECT DISTINCT
    object_name = substring(8,30,cb.dic_key), object_type = substring(7,1,cb.dic_key), date_time = cb
    .updt_dt_tm,
    count = count(*)
    FROM cclrdbdicblob cb
    WHERE substring(8,30,cb.dic_key)=patstring(program_name)
    GROUP BY substring(8,30,cb.dic_key), substring(7,1,cb.dic_key), cb.updt_dt_tm
    ORDER BY object_name, object_type, date_time,
     count
    WITH sqltype("vc30","c1","dq8","ui1")))
   cb_mod),
   dprotect d
  PLAN (cb_mod)
   JOIN (d
   WHERE cb_mod.object_name=d.object_name
    AND cb_mod.object_type=d.object
    AND 3=d.ccl_version
    AND ((cb_mod.count=2
    AND d.group=0) OR (((cb_mod.count=1
    AND d.group=1) OR (d.object="E")) )) )
  ORDER BY cb_mod.object_type, cb_mod.object_name, d.group
  HEAD REPORT
   stat = alterlist(reply->cust_script_objects,100), pcount1 = 0
  DETAIL
   pcount1 += 1
   IF (mod(pcount1,100)=1
    AND pcount1 > 100)
    stat = alterlist(reply->cust_script_objects,(pcount1+ 99))
   ENDIF
   reply->cust_script_objects[pcount1].program_name = cb_mod.object_name, reply->cust_script_objects[
   pcount1].object_type = cb_mod.object_type, reply->cust_script_objects[pcount1].ccl_group = d.group,
   reply->cust_script_objects[pcount1].compile_date_time = cb_mod.date_time, reply->
   cust_script_objects[pcount1].ccl_version = d.ccl_version
  FOOT REPORT
   stat = alterlist(reply->cust_script_objects,pcount1)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
