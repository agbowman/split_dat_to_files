CREATE PROGRAM bbt_get_all_aborh_barcodes:dba
 RECORD reply(
   1 codabarbarcodes[*]
     2 barcode = c15
     2 code_value_cd = f8
     2 code_value_disp = vc
     2 code_value_mean = c12
     2 cve1_cd = f8
     2 cve1_disp = vc
     2 cve1_mean = c12
     2 cve2_cd = f8
     2 cve2_disp = vc
     2 cve2_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET codabar_barcode = fillstring(15," ")
 SET abo_cd = 0.0
 SET rh_cd = 0.0
 SET codabar_cnt = 0
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SELECT INTO "nl"
  FROM code_value cv,
   (dummyt d_cve  WITH seq = 1),
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=1640
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d_cve)
   JOIN (cve
   WHERE cve.code_value=cv.code_value)
  ORDER BY cv.code_value
  HEAD REPORT
   codabar_cnt = 0, stat = alterlist(reply->codabarbarcodes,10)
  HEAD cv.code_value
   codabar_barcode = fillstring(15," "), abo_cd = 0.0, rh_cd = 0.0
  DETAIL
   IF (cve.field_name="Barcode")
    IF (trim(cve.field_value) > ""
     AND cve.field_value != null)
     codabar_barcode = cve.field_value
    ENDIF
   ELSEIF (cve.field_name="ABOOnly_cd")
    abo_cd = cnvtreal(cve.field_value)
   ELSEIF (cve.field_name="RhOnly_cd")
    rh_cd = cnvtreal(cve.field_value)
   ENDIF
  FOOT  cv.code_value
   codabar_cnt = (codabar_cnt+ 1)
   IF (mod(codabar_cnt,10)=1
    AND codabar_cnt != 1)
    stat = alterlist(reply->codabarbarcodes,(codabar_cnt+ 9))
   ENDIF
   reply->codabarbarcodes[codabar_cnt].barcode = codabar_barcode, reply->codabarbarcodes[codabar_cnt]
   .code_value_cd = cv.code_value, reply->codabarbarcodes[codabar_cnt].cve1_cd = abo_cd,
   reply->codabarbarcodes[codabar_cnt].cve2_cd = rh_cd
  FOOT REPORT
   stat = alterlist(reply->codabarbarcodes,codabar_cnt)
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  SET reply->status_data = "S"
 ELSE
  SET reply->status_data = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_get_all_aborh_barcodes"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "select aborh barcodes"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
END GO
