CREATE PROGRAM cdi_get_alias_source_cds:dba
 RECORD reply(
   1 source[*]
     2 contributor_source_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT DISTINCT
  bc.alias_contrib_src_cd
  FROM cdi_ac_batchclass bc
  WHERE bc.cdi_ac_batchclass_id != 0
  ORDER BY bc.alias_contrib_src_cd
  DETAIL
   count = (count+ 1)
   IF (mod(count,50)=1)
    stat = alterlist(reply->source,(count+ 50))
   ENDIF
   reply->source[count].contributor_source_cd = bc.alias_contrib_src_cd
  FOOT REPORT
   stat = alterlist(reply->source,count)
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
END GO
