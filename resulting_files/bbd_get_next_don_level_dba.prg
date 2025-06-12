CREATE PROGRAM bbd_get_next_don_level:dba
 RECORD reply(
   1 new_level_ind = i2
   1 new_don_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET grand_total = 0.00
 SET floor_grand_total = 0
 SET current_don_level = 0.0
 SET donor_nbr_cd = 0
 SELECT INTO "nl:"
  pd.person_id, pd.donation_level, pd.donation_level_trans,
  dp.nbr_per_volume_level
  FROM person_donor pd,
   bbd_donation_procedure dp
  PLAN (pd
   WHERE (pd.person_id=request->person_id)
    AND pd.active_ind=1)
   JOIN (dp
   WHERE (dp.procedure_cd=request->procedure_cd)
    AND dp.active_ind=1)
  DETAIL
   grand_total = ((pd.donation_level_trans+ pd.donation_level)+ (1.0/ dp.nbr_per_volume_level)),
   current_don_level = (pd.donation_level_trans+ pd.donation_level)
   IF (((floor(grand_total) - floor(current_don_level)) > 0))
    reply->new_level_ind = 1, reply->new_don_level = floor(grand_total)
   ELSE
    reply->new_level_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
