CREATE PROGRAM bbd_get_donation_results:dba
 RECORD reply(
   1 qual[*]
     2 donation_results_id = f8
     2 encntr_id = f8
     2 contact_id = f8
     2 drawn_dt_tm = di8
     2 start_dt_tm = di8
     2 stop_dt_tm = di8
     2 procedure_cd = f8
     2 venipuncture_site_cd = f8
     2 bag_type_cd = f8
     2 phleb_prsnl_id = f8
     2 outcome_cd = f8
     2 specimen_volume = i4
     2 total_volume = i4
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
  b.*
  FROM bbd_donation_results b,
   code_value c
  PLAN (b
   WHERE (b.person_id=request->person_id)
    AND b.active_ind=1)
   JOIN (c
   WHERE c.code_set=14221
    AND c.code_value=b.outcome_cd
    AND ((c.cdf_meaning="FAILED"
    AND (request->get_failed_outcome_ind=1)) OR (((c.cdf_meaning="PERMDEF"
    AND (request->get_perm_def_outcome_ind=1)) OR (((c.cdf_meaning="SUCCESS"
    AND (request->get_success_outcome_ind=1)) OR (c.cdf_meaning="TEMPDEF"
    AND (request->get_temp_def_outcome_ind=1))) )) )) )
  ORDER BY b.updt_dt_tm DESC
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].donation_results_id =
   b.donation_result_id,
   reply->qual[count].encntr_id = b.encntr_id, reply->qual[count].contact_id = b.contact_id, reply->
   qual[count].drawn_dt_tm = b.drawn_dt_tm,
   reply->qual[count].start_dt_tm = b.start_dt_tm, reply->qual[count].stop_dt_tm = b.stop_dt_tm,
   reply->qual[count].procedure_cd = b.procedure_cd,
   reply->qual[count].venipuncture_site_cd = b.venipuncture_site_cd, reply->qual[count].bag_type_cd
    = b.bag_type_cd, reply->qual[count].phleb_prsnl_id = b.phleb_prsnl_id,
   reply->qual[count].outcome_cd = b.outcome_cd, reply->qual[count].specimen_volume = b
   .specimen_volume, reply->qual[count].total_volume = b.total_volume,
   reply->qual[count].updt_cnt = b.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
