CREATE PROGRAM bed_rec_pharm_synm_no_cki_id
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET cpharm = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   cpharm = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   order_catalog oc,
   code_value cv
  PLAN (ocs
   WHERE ocs.catalog_type_cd=cpharm
    AND ocs.active_ind=1
    AND ocs.hide_flag != 1
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.synonym_id IN (
   (SELECT DISTINCT
    synonym_id
    FROM ocs_facility_r)))
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1
    AND oc.cki="MUL.ORD*")
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd)
  DETAIL
   IF (trim(ocs.cki) IN (null, " "))
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
