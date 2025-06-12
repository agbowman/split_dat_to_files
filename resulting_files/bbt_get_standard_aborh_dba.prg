CREATE PROGRAM bbt_get_standard_aborh:dba
 RECORD reply(
   1 qual[10]
     2 active_ind = i2
     2 display = vc
     2 description = vc
     2 abo_disp = vc
     2 rh_disp = vc
     2 barcode = vc
     2 code_value = f8
     2 updt_cnt = i4
     2 abo_cd = vc
     2 rh_cd = vc
     2 isbt_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_value, c.display, cve.field_name,
  cve.field_value, aborh_disp =
  IF (((cve.field_name="ABOOnly_cd") OR (cve.field_name="RhOnly_cd")) ) uar_get_code_display(cnvtreal
    (cve.field_value))
  ELSE " "
  ENDIF
  FROM code_value c,
   code_value_extension cve
  PLAN (c
   WHERE c.code_set=1640)
   JOIN (cve
   WHERE cve.code_value=c.code_value)
  ORDER BY c.code_value
  HEAD c.code_value
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].active_ind = c.active_ind, reply->qual[count1].display = c.display, reply->
   qual[count1].description = c.description,
   reply->qual[count1].code_value = c.code_value, reply->qual[count1].isbt_meaning = c.cdf_meaning,
   reply->qual[count1].updt_cnt = c.updt_cnt
  DETAIL
   IF (cve.field_name="Barcode")
    reply->qual[count1].barcode = cve.field_value
   ENDIF
   IF (cve.field_name="ABOOnly_cd")
    reply->qual[count1].abo_cd = cve.field_value, reply->qual[count1].abo_disp = aborh_disp
   ENDIF
   IF (cve.field_name="RhOnly_cd")
    reply->qual[count1].rh_cd = cve.field_value, reply->qual[count1].rh_disp = aborh_disp
   ENDIF
  WITH counter, outerjoin = d
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alter(reply->qual,count1)
#stop
END GO
