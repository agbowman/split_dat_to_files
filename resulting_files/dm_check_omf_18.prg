CREATE PROGRAM dm_check_omf_18
 FREE SET data
 RECORD data(
   1 count = i4
   1 list[*]
     2 ub92_mon_proc_phys_seq = i4
     2 flag = c1
     2 updt_task = c40
 )
 SET data->count = 0
 SELECT INTO "nl:"
  *
  FROM ub92_mon_encounter_error mee,
   ub92_mon_encounter me,
   ub92_mon_proc_phys mpp,
   ub92_mon_proc_phys_error mppe
  PLAN (mpp
   WHERE mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (mppe
   WHERE mpp.ub92_mon_proc_phys_seq=mppe.ub92_mon_proc_phys_seq
    AND mppe.status_flg="W")
   JOIN (me
   WHERE me.client_id_fl01=mpp.client_id_fl01
    AND me.patient_control_nbr_fl03=mpp.patient_control_nbr_fl03
    AND me.cover_period_from_fl06=mpp.cover_period_from_fl06
    AND me.cover_period_to_fl06=mpp.cover_period_to_fl06)
   JOIN (mee
   WHERE mee.ub92_mon_encounter_seq=me.ub92_mon_encounter_seq
    AND mee.status_flg="R")
  DETAIL
   data->count = (data->count+ 1)
   IF (mod(data->count,10)=1)
    stat = alterlist(data->list,(data->count+ 9))
   ENDIF
   data->list[data->count].ub92_mon_proc_phys_seq = mpp.ub92_mon_proc_phys_seq, data->list[data->
   count].updt_task = mpp.updt_task
  WITH nocounter
 ;end select
 IF (curqual != 0)
  UPDATE  FROM ub92_mon_proc_phys_error mee,
    (dummyt d  WITH seq = value(data->count))
   SET mee.error_cd = 9907, mee.status_flg = "R", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    mee.updt_task = data->list[d.seq].updt_task
   PLAN (d)
    JOIN (mee
    WHERE mee.reporting_period=cnvtdatetime(startdatesstring)
     AND (mee.ub92_mon_proc_phys_seq=data->list[d.seq].ub92_mon_proc_phys_seq))
   WITH nocounter
  ;end update
 ENDIF
 SET data->count = 0
 SELECT
  *
  FROM ub92_mon_encounter_error mee,
   ub92_mon_encounter me,
   ub92_mon_proc_phys mpp,
   ub92_mon_proc_phys_error mppe
  PLAN (mpp
   WHERE mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (mppe
   WHERE outerjoin(mpp.ub92_mon_proc_phys_seq)=mppe.ub92_mon_proc_phys_seq)
   JOIN (me
   WHERE me.client_id_fl01=mpp.client_id_fl01
    AND me.patient_control_nbr_fl03=mpp.patient_control_nbr_fl03
    AND me.cover_period_from_fl06=mpp.cover_period_from_fl06
    AND me.cover_period_to_fl06=mpp.cover_period_to_fl06)
   JOIN (mee
   WHERE mee.ub92_mon_encounter_seq=me.ub92_mon_encounter_seq
    AND mee.status_flg IN ("R", "W"))
  DETAIL
   IF ( NOT (mppe.status_flg IN ("R", "W")))
    data->count = (data->count+ 1)
    IF (mod(data->count,10)=1)
     stat = alterlist(data->list,(data->count+ 9))
    ENDIF
    data->list[data->count].ub92_mon_proc_phys_seq = mpp.ub92_mon_proc_phys_seq, data->list[data->
    count].flag = mee.status_flg, data->list[data->count].updt_task = mpp.updt_task
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual != 0)
  INSERT  FROM ub92_mon_proc_phys_error mee,
    (dummyt d  WITH seq = value(data->count))
   SET mee.error_cd = 9907, mee.reporting_period = cnvtdatetime(startdatesstring), mee
    .ub92_mon_proc_phys_seq = data->list[d.seq].ub92_mon_proc_phys_seq,
    mee.status_flg = data->list[d.seq].flag, mee.updt_dt_tm = cnvtdatetime(curdate,curtime3), mee
    .updt_task = data->list[d.seq].updt_task
   PLAN (d)
    JOIN (mee)
   WITH nocounter
  ;end insert
 ENDIF
 FREE SET data
 RECORD data(
   1 count = i4
   1 list[*]
     2 ub92_mon_diagnosis_seq = i4
     2 flag = c1
     2 updt_task = c40
 )
 SET data->count = 0
 SELECT INTO "nl:"
  *
  FROM ub92_mon_encounter_error mee,
   ub92_mon_encounter me,
   ub92_mon_diagnosis mpp,
   ub92_mon_diagnosis_error mppe
  PLAN (mpp
   WHERE mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (mppe
   WHERE mpp.ub92_mon_diagnosis_seq=mppe.ub92_mon_diagnosis_seq
    AND mppe.status_flg="W")
   JOIN (me
   WHERE me.client_id_fl01=mpp.client_id_fl01
    AND me.patient_control_nbr_fl03=mpp.patient_control_nbr_fl03
    AND me.cover_period_from_fl06=mpp.cover_period_from_fl06
    AND me.cover_period_to_fl06=mpp.cover_period_to_fl06)
   JOIN (mee
   WHERE mee.ub92_mon_encounter_seq=me.ub92_mon_encounter_seq
    AND mee.status_flg="R")
  DETAIL
   data->count = (data->count+ 1)
   IF (mod(data->count,10)=1)
    stat = alterlist(data->list,(data->count+ 9))
   ENDIF
   data->list[data->count].ub92_mon_diagnosis_seq = mpp.ub92_mon_diagnosis_seq, data->list[data->
   count].updt_task = mpp.updt_task
  WITH nocounter
 ;end select
 IF (curqual != 0)
  UPDATE  FROM ub92_mon_diagnosis_error mee,
    (dummyt d  WITH seq = value(data->count))
   SET mee.error_cd = 9907, mee.status_flg = "R", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    mee.updt_task = data->list[d.seq].updt_task
   PLAN (d)
    JOIN (mee
    WHERE mee.reporting_period=cnvtdatetime(startdatesstring)
     AND (mee.ub92_mon_diagnosis_seq=data->list[d.seq].ub92_mon_diagnosis_seq))
   WITH nocounter
  ;end update
 ENDIF
 SET data->count = 0
 SELECT INTO "nl:"
  *
  FROM ub92_mon_encounter_error mee,
   ub92_mon_encounter me,
   ub92_mon_diagnosis mpp,
   ub92_mon_diagnosis_error mppe
  PLAN (mpp
   WHERE mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (mppe
   WHERE outerjoin(mpp.ub92_mon_diagnosis_seq)=mppe.ub92_mon_diagnosis_seq)
   JOIN (me
   WHERE me.client_id_fl01=mpp.client_id_fl01
    AND me.patient_control_nbr_fl03=mpp.patient_control_nbr_fl03
    AND me.cover_period_from_fl06=mpp.cover_period_from_fl06
    AND me.cover_period_to_fl06=mpp.cover_period_to_fl06)
   JOIN (mee
   WHERE mee.ub92_mon_encounter_seq=me.ub92_mon_encounter_seq
    AND mee.status_flg IN ("R", "W"))
  DETAIL
   IF ( NOT (mppe.status_flg IN ("R", "W")))
    data->count = (data->count+ 1)
    IF (mod(data->count,10)=1)
     stat = alterlist(data->list,(data->count+ 9))
    ENDIF
    data->list[data->count].ub92_mon_diagnosis_seq = mpp.ub92_mon_diagnosis_seq, data->list[data->
    count].flag = mee.status_flg, data->list[data->count].updt_task = mpp.updt_task
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual != 0)
  INSERT  FROM ub92_mon_diagnosis_error mee,
    (dummyt d  WITH seq = value(data->count))
   SET mee.error_cd = 9907, mee.reporting_period = cnvtdatetime(startdatesstring), mee
    .ub92_mon_diagnosis_seq = data->list[d.seq].ub92_mon_diagnosis_seq,
    mee.status_flg = data->list[d.seq].flag, mee.updt_dt_tm = cnvtdatetime(curdate,curtime3), mee
    .updt_task = data->list[d.seq].updt_task
   PLAN (d)
    JOIN (mee)
   WITH nocounter
  ;end insert
 ENDIF
END GO
