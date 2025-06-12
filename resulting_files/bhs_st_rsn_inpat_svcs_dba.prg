CREATE PROGRAM bhs_st_rsn_inpat_svcs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = gvc
    1 status_data[1]
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE mf_cs200_stat_inpat = f8 WITH protect, constant(uar_get_code_by_cki("CKI.ORD!1534"))
 DECLARE mf_cs400_icd10 = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946"))
 DECLARE mf_cs6000_atd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!1302985"))
 DECLARE mf_cs6004_completed = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3100"))
 DECLARE mf_cs6004_ordered = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs16449_rsn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "REASONFORINPATIENTSERVICES"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_cs6000_atd
    AND o.catalog_cd=mf_cs200_stat_inpat
    AND o.order_status_cd IN (mf_cs6004_completed, mf_cs6004_ordered)
    AND  NOT ( EXISTS (
   (SELECT
    d.diagnosis_id
    FROM diagnosis d,
     nomenclature n
    WHERE d.encntr_id=o.encntr_id
     AND d.active_ind=1
     AND d.end_effective_dt_tm > sysdate
     AND n.nomenclature_id=d.nomenclature_id
     AND n.source_vocabulary_cd=mf_cs400_icd10))))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_cs16449_rsn)
  ORDER BY o.order_id, o.orig_order_dt_tm DESC
  HEAD o.order_id
   ms_tmp = build2("{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}",
    trim(od.oe_field_display_value,3),"}")
  WITH nocounter
 ;end select
 SET reply->text = ms_tmp
 CALL echo(reply->text)
#exit_script
END GO
