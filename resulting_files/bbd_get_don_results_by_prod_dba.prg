CREATE PROGRAM bbd_get_don_results_by_prod:dba
 RECORD reply(
   1 contact_id = f8
   1 donation_result_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 drawn_dt_tm = di8
   1 start_dt_tm = di8
   1 stop_dt_tm = di8
   1 procedure_cd = f8
   1 procedure_cd_disp = vc
   1 venipuncture_site_cd = f8
   1 venipuncture_site_cd_disp = vc
   1 bag_type_cd = f8
   1 bag_type_cd_disp = vc
   1 phleb_prsnl_id = f8
   1 phleb_prsnl_name = vc
   1 outcome_cd = f8
   1 outcome_cd_disp = vc
   1 specimen_volume = i4
   1 specimen_unit_meas_cd = f8
   1 specimen_unit_meas_cd_disp = vc
   1 total_volume = i4
   1 updt_cnt = i4
   1 owner_area_cd = f8
   1 owner_area_cd_disp = vc
   1 inv_area_cd = f8
   1 inv_area_cd_disp = vc
   1 draw_station_cd = f8
   1 draw_station_cd_disp = vc
   1 reasons[*]
     2 deferral_reason_id = f8
     2 updt_cnt = i4
     2 reason_cd = f8
     2 reason_cd_disp = vc
     2 reason_cd_mean = vc
     2 eligible_dt_tm = di8
     2 occurred_dt_tm = di8
     2 calc_elig_dt_tm = di8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->reasons,0)
 SET count = 0
 SELECT INTO "nl:"
  dp.product_id
  FROM bbd_don_product_r dp,
   bbd_donation_results dr,
   person p,
   (dummyt d1  WITH seq = 1),
   bbd_donor_eligibility be,
   bbd_deferral_reason de
  PLAN (dp
   WHERE (dp.product_id=request->product_id)
    AND dp.active_ind=1)
   JOIN (dr
   WHERE dr.donation_result_id=dp.donation_results_id
    AND dr.active_ind=1)
   JOIN (p
   WHERE p.person_id=dr.phleb_prsnl_id
    AND p.active_ind=1)
   JOIN (be
   WHERE be.contact_id=dr.contact_id
    AND be.person_id=dr.person_id
    AND be.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (de
   WHERE de.eligibility_id=be.eligibility_id
    AND de.active_ind=1)
  ORDER BY dp.product_id
  HEAD dp.product_id
   reply->contact_id = dp.contact_id, reply->donation_result_id = dr.donation_result_id, reply->
   encntr_id = dr.encntr_id,
   reply->person_id = dr.person_id, reply->drawn_dt_tm = dr.drawn_dt_tm, reply->start_dt_tm = dr
   .start_dt_tm,
   reply->stop_dt_tm = dr.stop_dt_tm, reply->procedure_cd = dr.procedure_cd, reply->
   venipuncture_site_cd = dr.venipuncture_site_cd,
   reply->bag_type_cd = dr.bag_type_cd, reply->phleb_prsnl_id = dr.phleb_prsnl_id, reply->
   phleb_prsnl_name = p.name_full_formatted,
   reply->outcome_cd = dr.outcome_cd, reply->specimen_volume = dr.specimen_volume, reply->
   specimen_unit_meas_cd = dr.specimen_unit_meas_cd,
   reply->total_volume = dr.total_volume, reply->updt_cnt = dr.updt_cnt, reply->owner_area_cd = dr
   .owner_area_cd,
   reply->inv_area_cd = dr.inv_area_cd, reply->draw_station_cd = dr.draw_station_cd
  DETAIL
   IF (de.deferral_reason_id > 0)
    count = (count+ 1), stat = alterlist(reply->reasons,count), reply->reasons[count].
    deferral_reason_id = de.deferral_reason_id,
    reply->reasons[count].updt_cnt = de.updt_cnt, reply->reasons[count].reason_cd = de.reason_cd,
    reply->reasons[count].eligible_dt_tm = de.eligible_dt_tm,
    reply->reasons[count].occurred_dt_tm = de.occurred_dt_tm, reply->reasons[count].calc_elig_dt_tm
     = de.calc_elig_dt_tm
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
#exitscript
END GO
