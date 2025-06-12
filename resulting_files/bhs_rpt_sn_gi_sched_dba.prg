CREATE PROGRAM bhs_rpt_sn_gi_sched:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE mf_cs212_email = f8 WITH constant(uar_get_code_by("DISPLAYKEY",212,"EMAIL")), protect
 DECLARE mf_cs43_mobil_ph = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"CELL")), protect
 DECLARE mf_cs71_snoutpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"SNOUTPATIENT")),
 protect
 DECLARE mf_cs71_sndaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"SNDAYSTAY")), protect
 DECLARE mf_cs16289_publicschedulingcomments = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16289,
   "PUBLICSCHEDULINGCOMMENTS")), protect
 DECLARE mf_cs6011_ancillary = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6011,"ANCILLARY")),
 protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs4_corporatemedicalrecordnumber = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN")),
 protect
 DECLARE mf_cs6000_surgery = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"SURGERY")), protect
 DECLARE ml_cnt_pat = i4 WITH noconstant(0), protect
 DECLARE md_age = dq8 WITH constant(cnvtagedatetime(18,0,0,0)), protect
 DECLARE ml_num = i4 WITH noconstant(0), protect
 FREE RECORD catcodes
 RECORD catcodes(
   1 cntcats = i4
   1 codes[*]
     2 cat_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv,
   order_catalog oc
  PLAN (cv
   WHERE cv.code_set=200
    AND ((cv.display_key="*COLONOSCOPY*") OR (((cv.display_key="*ENTEROSCOPY*") OR (((cv.display_key=
   "*ENDOBRONCHIAL*") OR (((cv.display_key="*GASTROSCOPY*") OR (((cv.display_key=
   "*FLEXIBLESIGMOIDOSCOPYENDOSCOPICSUBMUCOSA*") OR (cv.display_key="*ILEOSCOPY*")) )) )) )) ))
    AND cv.active_ind=1
    AND cv.active_type_cd=mf_cs48_active)
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=cv.code_value
    AND oc.catalog_type_cd=value(uar_get_code_by("DISPLAYKEY",6000,"SURGERY")))
  ORDER BY cv.display_key
  HEAD REPORT
   stat = alterlist(catcodes->codes,10)
  HEAD oc.catalog_cd
   catcodes->cntcats += 1
   IF (mod(catcodes->cntcats,10)=1
    AND (catcodes->cntcats > 1))
    stat = alterlist(catcodes->codes,(catcodes->cntcats+ 9))
   ENDIF
   catcodes->codes[catcodes->cntcats].cat_cd = oc.catalog_cd
  FOOT REPORT
   stat = alterlist(catcodes->codes,catcodes->cntcats)
  WITH ncocounter
 ;end select
 SELECT INTO  $OUTDEV
  sc.surg_case_nbr_formatted, schedule_start = format(sc.sched_start_dt_tm,"mm/dd/yyyy;;D"), ocs
  .mnemonic,
  ocs2.mnemonic, scp2.primary_proc_ind, oc_catalog_disp = uar_get_code_display(ocs.catalog_cd),
  sc_surg_area_disp = uar_get_code_display(sc.sched_surg_area_cd), sc_sched_pat_type_disp =
  uar_get_code_display(sc.sched_pat_type_cd), patient = substring(1,100,per.name_full_formatted),
  dob = format(cnvtdatetimeutc(datetimezone(per.birth_dt_tm,per.birth_tz),1),"mm/dd/yyyy;;d"), cmrn
   = substring(1,12,pa.alias), pa.person_alias_id,
  email = substring(1,100,email.street_addr), mobile_phone = ph.phone_num, pg.prsnl_group_name,
  health_plan = substring(1,100,hp.plan_name), per.person_id
  FROM surgical_case sc,
   surg_case_procedure scp2,
   encounter enc,
   person per,
   address email,
   phone ph,
   sn_comment_text snc,
   long_text lt,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   person_alias pa,
   prsnl_group pg,
   encntr_plan_reltn epr,
   health_plan hp
  PLAN (sc
   WHERE sc.sched_start_dt_tm BETWEEN cnvtdatetime(curdate,0) AND cnvtdatetime((curdate+ 7),235959)
    AND sc.sched_pat_type_cd IN (1607087909.00, value(uar_get_code_by("DISPLAYKEY",71,"SNOUTPATIENT")
    ), value(uar_get_code_by("DISPLAYKEY",71,"SNDAYSTAY")))
    AND sc.sched_qty=1
    AND sc.cancel_reason_cd=0
    AND sc.cancel_req_by_id=0)
   JOIN (pa
   WHERE pa.active_ind=1
    AND pa.person_alias_type_cd=mf_cs4_corporatemedicalrecordnumber
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.person_id=sc.person_id
    AND pa.active_status_cd=mf_cs48_active)
   JOIN (scp2
   WHERE scp2.surg_case_id=sc.surg_case_id
    AND scp2.sched_primary_ind=1
    AND ((scp2.active_ind=1
    AND scp2.sched_surg_proc_cd > 0) OR (scp2.active_ind=0
    AND scp2.sched_surg_proc_cd > 0
    AND scp2.surg_proc_cd > 0))
    AND scp2.active_ind=1)
   JOIN (pg
   WHERE (pg.prsnl_group_id= Outerjoin(scp2.sched_surg_specialty_id))
    AND (pg.active_ind= Outerjoin(1))
    AND pg.prsnl_group_name_key IN ("SN - Zichittella (BWH)", "SN ENDOSCOPY", "SN GENERAL"))
   JOIN (ocs
   WHERE ocs.synonym_id=scp2.synonym_id
    AND ocs.active_ind=1
    AND ocs.active_status_cd=mf_cs48_active
    AND ocs.catalog_type_cd=mf_cs6000_surgery
    AND expand(ml_num,1,size(catcodes->codes,5),ocs.catalog_cd,catcodes->codes[ml_num].cat_cd))
   JOIN (ocs2
   WHERE (ocs2.catalog_cd= Outerjoin(ocs.catalog_cd))
    AND (ocs2.mnemonic_type_cd= Outerjoin(mf_cs6011_ancillary))
    AND (ocs2.active_ind= Outerjoin(1))
    AND (ocs2.active_ind= Outerjoin(1))
    AND (ocs2.active_status_cd= Outerjoin(mf_cs48_active))
    AND (ocs2.synonym_id= Outerjoin(ocs.synonym_id)) )
   JOIN (snc
   WHERE (snc.root_id= Outerjoin(sc.surg_case_id))
    AND (snc.comment_type_cd= Outerjoin(mf_cs16289_publicschedulingcomments))
    AND (snc.root_name= Outerjoin("SURGICAL_CASE"))
    AND (snc.active_ind= Outerjoin(1))
    AND (snc.active_status_cd= Outerjoin(mf_cs48_active)) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(snc.long_text_id))
    AND (lt.active_ind= Outerjoin(1))
    AND (lt.active_status_cd= Outerjoin(mf_cs48_active)) )
   JOIN (enc
   WHERE enc.encntr_id=sc.encntr_id)
   JOIN (per
   WHERE per.person_id=sc.person_id
    AND per.active_ind=1
    AND per.active_status_cd=188)
   JOIN (epr
   WHERE (epr.active_ind= Outerjoin(1))
    AND (epr.encntr_id= Outerjoin(enc.encntr_id))
    AND (epr.end_effective_dt_tm> Outerjoin(sysdate))
    AND (epr.priority_seq= Outerjoin(1)) )
   JOIN (hp
   WHERE (hp.health_plan_id= Outerjoin(epr.health_plan_id))
    AND (hp.active_ind= Outerjoin(1)) )
   JOIN (email
   WHERE (email.parent_entity_id= Outerjoin(per.person_id))
    AND (email.parent_entity_name= Outerjoin("PERSON"))
    AND (email.address_type_cd= Outerjoin(mf_cs212_email))
    AND (email.active_ind= Outerjoin(1))
    AND (email.active_status_cd= Outerjoin(188))
    AND (email.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(per.person_id))
    AND (ph.parent_entity_name= Outerjoin("PERSON"))
    AND (ph.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ph.phone_type_cd= Outerjoin(mf_cs43_mobil_ph))
    AND (ph.active_ind= Outerjoin(1)) )
  ORDER BY sc_surg_area_disp
  WITH maxrec = 5000, nocounter, time = 30,
   expand = 1, format, separator = " "
 ;end select
END GO
