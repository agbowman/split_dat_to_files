CREATE PROGRAM bhs_rpt_vitamin_k_given:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 673936.00,
  "Start Admit Date" = "SYSDATE",
  "Ending Admit Date" = "SYSDATE"
  WITH outdev, fname, start_date,
  end_date
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_cs3_newborn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",3,"NEWBORN")), protect
 DECLARE unit = vc WITH protect
 DECLARE ordered_as = vc WITH protect
 DECLARE did_not_receive = vc WITH protect
 DECLARE received = vc WITH protect
 DECLARE mrn = vc WITH protect
 DECLARE facility = vc WITH protect
 DECLARE mf_cs200_phytonadione = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PHYTONADIONE")),
 protect
 SELECT INTO  $OUTDEV
  facility = substring(1,50,uar_get_code_display(enc.loc_facility_cd)), mrn = trim(mrn.alias,3),
  received =
  IF (o.order_id != null) "Received"
  ENDIF
  ,
  did_not_recieve =
  IF (o.order_id=null) "Did not receive"
  ENDIF
  , ordered_as = substring(1,50,o.order_mnemonic), unit = substring(1,50,uar_get_code_display(enc
    .loc_nurse_unit_cd))
  FROM encounter enc,
   orders o,
   med_admin_event mae,
   encntr_alias mrn
  PLAN (enc
   WHERE enc.active_ind=1
    AND enc.reg_dt_tm BETWEEN cnvtdatetime( $START_DATE) AND cnvtdatetime( $END_DATE)
    AND (enc.loc_facility_cd= $FNAME)
    AND enc.admit_type_cd IN (mf_cs3_newborn_cd)
    AND enc.active_ind=1)
   JOIN (mrn
   WHERE mrn.encntr_id=enc.encntr_id
    AND mrn.active_ind=1
    AND mrn.end_effective_dt_tm > sysdate
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (o
   WHERE (o.active_ind= Outerjoin(1))
    AND (o.encntr_id= Outerjoin(enc.encntr_id))
    AND (o.person_id= Outerjoin(enc.person_id))
    AND (o.catalog_cd= Outerjoin(mf_cs200_phytonadione)) )
   JOIN (mae
   WHERE (mae.template_order_id= Outerjoin(o.order_id)) )
  WITH nocounter, format, separator = " "
 ;end select
END GO
