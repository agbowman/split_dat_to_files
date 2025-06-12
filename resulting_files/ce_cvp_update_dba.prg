CREATE PROGRAM ce_cvp_update:dba
 RECORD fillrecord(
   1 rdm_current_status = c1
 )
 SET rdm_current_status = "S"
 SET count1 = 0
 SELECT INTO "nl:"
  cvp.entity_name, cvp.field_name
  FROM ce_version_parms cvp
  WHERE (cvp.entity_name= $1)
   AND (cvp.field_name= $2)
  DETAIL
   count1 += 1
  WITH nocounter
 ;end select
 IF (count1=0)
  INSERT  FROM ce_version_parms cvp
   SET cvp.entity_name =  $1, cvp.field_name =  $2, cvp.updt_cnt = 0,
    cvp.updt_dt_tm = cnvtdatetime(sysdate)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET fillrecord->rdm_current_status = "F"
  ENDIF
 ENDIF
END GO
