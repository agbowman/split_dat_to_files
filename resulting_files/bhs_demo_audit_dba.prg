CREATE PROGRAM bhs_demo_audit:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 enc[*]
 )
 DECLARE mf_enc_rows = f8 WITH protect, noconstant(0.0)
 DECLARE mf_demo_rows = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime("01-MAY-2011") AND sysdate
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
  DETAIL
   mf_enc_rows = (mf_enc_rows+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   bhs_demographics b
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime("01-MAY-2011") AND sysdate
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (b
   WHERE b.person_id=e.person_id
    AND b.active_ind=1
    AND b.description="language spoken")
  HEAD e.person_id
   mf_demo_rows = (mf_demo_rows+ 1)
  WITH nocounter
 ;end select
 CALL echo(build2("enctr rows: ",mf_enc_rows))
 CALL echo(build2("demo rows: ",mf_demo_rows))
 CALL echo(build2("percentage: ",(100 * (mf_demo_rows/ mf_enc_rows)),"%"))
END GO
