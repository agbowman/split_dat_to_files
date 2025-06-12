CREATE PROGRAM bhs_syn_med_rec_query3:dba
 FREE RECORD t_record
 RECORD t_record(
   1 encntr_id = f8
   1 elh_id1 = f8
   1 nu_id1 = f8
   1 beg_dt_tm = dq8
   1 elh_id2 = f8
   1 nu_id2 = f8
   1 end_dt_tm = dq8
   1 clinsig_dt_tm = dq8
   1 med_rec_y_or_n = i2
   1 pharm_order_y_or_n = i2
 )
 SET retval = 0
 SET t_record->encntr_id = trigger_encntrid
 DECLARE med_rec_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATION"))
 DECLARE pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE icua_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUA"))
 DECLARE icub_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUB"))
 DECLARE icuc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUC"))
 DECLARE iccu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICCU"))
 DECLARE icu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICU"))
 DECLARE c6a_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"C6A"))
 DECLARE s3_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"S3"))
 DECLARE spk4_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"SPK4"))
 DECLARE spk5_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"SPK5"))
 SELECT INTO "nl:"
  FROM clinical_event ce,
   prsnl p
  PLAN (ce
   WHERE (ce.encntr_id=t_record->encntr_id)
    AND ce.result_status_cd=25
    AND ((ce.event_cd+ 0)=med_rec_cd)
    AND ce.clinsig_updt_dt_tm >= cnvtdatetime(t_record->beg_dt_tm))
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id
    AND p.physician_ind=0)
  DETAIL
   t_record->med_rec_y_or_n = 1
  WITH nocounter, orahint("index(ce XIE19CLINICAL_EVENT)")
 ;end select
 IF ((t_record->med_rec_y_or_n=1))
  SELECT INTO "nl:"
   FROM orders o
   PLAN (o
    WHERE (o.encntr_id=t_record->encntr_id)
     AND o.catalog_type_cd=pharm_cd
     AND o.orig_ord_as_flag IN (1, 2, 3)
     AND (o.orig_order_dt_tm >= t_record->clinsig_dt_tm))
   ORDER BY o.order_id
   HEAD o.order_id
    IF ((t_record->pharm_order_y_or_n=0))
     t_record->pharm_order_y_or_n = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   IF ((t_record->pharm_order_y_or_n=1))
    retval = 100
   ELSE
    retval = 0
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(retval)
END GO
