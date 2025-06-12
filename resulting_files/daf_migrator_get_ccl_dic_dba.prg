CREATE PROGRAM daf_migrator_get_ccl_dic:dba
 RECORD reply(
   1 message = vc
   1 list_length = i4
   1 obj_list[*]
     2 script_name = vc
     2 script_date = dq8
     2 script_group = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 SELECT INTO "nl:"
  d.object_name, d.datestamp, d.timestamp,
  d.group
  FROM dprotect d
  WHERE d.object="P"
   AND d.group BETWEEN 0 AND 100
  HEAD REPORT
   loopctr = 0
  DETAIL
   IF (mod(loopctr,100)=0)
    stat = alterlist(reply->obj_list,(loopctr+ 100))
   ENDIF
   loopctr = (loopctr+ 1), reply->obj_list[loopctr].script_name = d.object_name, reply->obj_list[
   loopctr].script_date = cnvtdatetime(d.datestamp,cnvttime2(format(d.timestamp,"######;rp0"),
     "HHMMSS")),
   reply->obj_list[loopctr].script_group = d.group
  FOOT REPORT
   reply->list_length = loopctr, stat = alterlist(reply->obj_list,loopctr)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to fetch Dictionary objects:",errmsg)
  SET reply->list_length = 0
  SET stat = alterlist(reply->obj_list,0)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->message = "No scripts found in the object dictionary."
  SET reply->list_length = 0
  SET stat = alterlist(reply->obj_list,0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->message = "Successfully retrieved objects from the CCL Dictionary"
#exit_script
END GO
