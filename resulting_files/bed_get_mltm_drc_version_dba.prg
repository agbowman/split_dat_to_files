CREATE PROGRAM bed_get_mltm_drc_version:dba
 FREE SET reply
 RECORD reply(
   1 pma_ind = i2
   1 clinical_condition_ind = i2
   1 crcl_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 lexicomp_ind = i2
   1 multum_ind = i2
 )
 SET reply->status_data.status = "F"
 SET version = 0.0
 SET version = curcclrev
 IF (version >= 8.3)
  SET reply->pma_ind = 1
  SET reply->clinical_condition_ind = 1
  SET reply->crcl_ind = 1
 ENDIF
 IF (findfile("cer_install:lexicomp_drc_extract.csv")=1)
  SET reply->lexicomp_ind = 1
  SELECT INTO "nl:"
   FROM mltm_drc_premise m
   WHERE ((m.age_low_nbr > 18
    AND cnvtupper(m.age_unit_disp)="YEAR*") OR (m.age_low_nbr=18
    AND m.age_operator_txt != "<"
    AND cnvtupper(m.age_unit_disp)="YEAR*"))
   ORDER BY cnvtupper(m.grouper_name)
   HEAD REPORT
    reply->multum_ind = 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM mltm_drc_premise m
   WHERE m.drc_cki > " "
   HEAD REPORT
    reply->multum_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (version > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
