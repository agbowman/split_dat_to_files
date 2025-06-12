CREATE PROGRAM bbd_get_venipuncture_sites:dba
 RECORD reply(
   1 qual[*]
     2 body_site_cd = f8
     2 body_site_cd_disp = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  v.body_site_cd, v.updt_cnt
  FROM donor_venipuncture_site v
  PLAN (v
   WHERE v.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].body_site_cd = v
   .body_site_cd,
   reply->qual[count].updt_cnt = v.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
