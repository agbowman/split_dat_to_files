CREATE PROGRAM bmdi_patient_association_audit
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT
  bmd.device_alias, association_dt_tm = substring(1,25,format(badt.association_dt_tm,";;Q")),
  disassociation_dt_tm = substring(1,25,format(badt.dis_association_dt_tm,";;Q")),
  badt.person_id, person_name = substring(1,20,p.name_full_formatted)
  FROM bmdi_acquired_data_track badt,
   bmdi_monitored_device bmd,
   person p
  PLAN (badt)
   JOIN (bmd
   WHERE bmd.location_cd=badt.location_cd)
   JOIN (p
   WHERE badt.person_id > 0
    AND p.person_id=badt.person_id)
  ORDER BY badt.person_id, association_dt_tm
  WITH nocounter
 ;end select
END GO
