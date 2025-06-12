CREATE PROGRAM bhs_updt_encntr:dba
 UPDATE  FROM encounter e
  SET e.encntr_status_cd = 854, e.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0)
  WHERE disch_dt_tm = null
   AND e.encntr_status_cd=856
   AND encntr_type_cd IN (679672, 679653, 679655, 679661, 679660,
  679654, 309308, 309310, 679668, 309312,
  2741499, 2742695, 679658, 679684, 2765403,
  679656, 679662, 5554258, 679664)
  WITH nocounter, maxcommit = 1000
 ;end update
 COMMIT
 UPDATE  FROM encntr_domain ed
  SET ed.end_effective_dt_tm = cnvtdatetime(cnvtdate(12312100),0), ed.active_ind = 1
  WHERE ed.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND ed.encntr_id IN (
  (SELECT
   e.encntr_id
   FROM encounter e
   WHERE ed.encntr_id=e.encntr_id
    AND e.encntr_type_cd IN (679672, 679653, 679655, 679661, 679660,
   679654, 309308, 309310, 679668, 309312,
   2741499, 2742695, 679658, 679684, 2765403,
   679656, 679662, 5554258, 679664)
    AND e.disch_dt_tm=null
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND e.encntr_status_cd=854))
  WITH nocounter, maxcommit = 1000
 ;end update
 COMMIT
 UPDATE  FROM encntr_prsnl_reltn epr
  SET epr.expiration_ind = 1, epr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE epr.expiration_ind=0
   AND epr.encntr_id IN (
  (SELECT
   e.encntr_id
   FROM encounter e
   WHERE e.encntr_id=epr.encntr_id
    AND e.med_service_cd IN (1689891, 1689892, 1689775, 1689822, 1689776,
   1689836, 2741089, 1689837, 1689824, 1689904,
   1689824)))
  WITH nocounter, maxcommit = 1000
 ;end update
 COMMIT
END GO
