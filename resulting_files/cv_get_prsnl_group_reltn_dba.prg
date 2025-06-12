CREATE PROGRAM cv_get_prsnl_group_reltn:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 RECORD reply(
   1 qual[*]
     2 prsnl_group_id = f8
     2 person_id = f8
     2 prsnl_group_r_cd = f8
     2 prsnl_group_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 EXECUTE FROM 1000_initialize TO 1099_initializeend
 EXECUTE FROM 2000_loadgroups TO 2099_loadgroupsend
 EXECUTE FROM 3000_test TO 3099_testend
 GO TO 9999_end
#1000_initialize
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_to_get = cnvtint(size(request->qual,5))
#1099_initializeend
#2000_loadgroups
 SELECT INTO "nl:"
  p.prsnl_group_id
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   prsnl_group_reltn p
  PLAN (d)
   JOIN (p
   WHERE (p.prsnl_group_id=request->qual[d.seq].prsnl_group_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].prsnl_group_id = p.prsnl_group_id, reply->qual[count1].prsnl_group_reltn_id =
   p.prsnl_group_reltn_id, reply->qual[count1].prsnl_group_r_cd = p.prsnl_group_r_cd,
   reply->qual[count1].person_id = p.person_id
  WITH counter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#2099_loadgroupsend
#3000_test
 FOR (i = 1 TO count1)
   CALL echo(build("index ::",i))
   CALL echo(build("prsnl_group_id ::",reply->qual[i].prsnl_group_id))
   CALL echo(build("prsnl_group_reltn_id ::",reply->qual[i].prsnl_group_reltn_id))
   CALL echo(build("prsnl_group_r_cd ::",reply->qual[i].prsnl_group_r_cd))
   CALL echo(build("person_id ::",reply->qual[i].person_id))
 ENDFOR
#3099_testend
#9999_end
END GO
