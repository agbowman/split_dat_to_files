CREATE PROGRAM bhs_gnw_demo_bar:dba
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs263_hifin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"HIFIN"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_fin = vc
   1 s_mrn = vc
   1 s_age = vc
   1 s_name = vc
   1 s_gender = vc
   1 s_dob = vc
 )
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id, ea1.beg_effective_dt_tm DESC, ea2.beg_effective_dt_tm DESC
  HEAD e.encntr_id
   m_rec->s_fin = trim(ea1.alias,3), m_rec->s_mrn = trim(ea2.alias,3), m_rec->s_age = trim(cnvtage(
     cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),3),
   m_rec->s_name = trim(p.name_full_formatted,3), m_rec->s_gender = trim(uar_get_code_display(p
     .sex_cd),3), m_rec->s_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1
      ),"MM/DD/YYYY;;q"),3)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM encounter e,
    encntr_alias ea,
    person_alias pa,
    person p
   PLAN (e
    WHERE (e.encntr_id=request->visit[1].encntr_id))
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ea.encntr_alias_type_cd=mf_cs319_fin_cd
     AND ea.alias_pool_cd=mf_cs263_hifin_cd)
    JOIN (pa
    WHERE pa.person_id=e.person_id
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
    JOIN (p
    WHERE p.person_id=e.person_id)
   ORDER BY e.encntr_id, ea.beg_effective_dt_tm DESC
   HEAD e.encntr_id
    m_rec->s_fin = trim(ea.alias,3), m_rec->s_mrn = trim(pa.alias,3), m_rec->s_age = trim(cnvtage(
      cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),3),
    m_rec->s_name = trim(p.name_full_formatted,3), m_rec->s_gender = trim(uar_get_code_display(p
      .sex_cd),3), m_rec->s_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),
       1),"MM/DD/YYYY;;q"),3)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->text = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}"
 SET reply->text = concat(reply->text,"\fs18 ","Patient:  \b ",m_rec->s_name,"      ",
  "MRN: ",m_rec->s_mrn,"      ","FIN: ",m_rec->s_fin,
  " \b0\par")
 SET reply->text = concat(reply->text," Age: \b ",m_rec->s_age," \b0 ","      ",
  "Sex: \b ",m_rec->s_gender," \b0 ","      ","DOB: \b ",
  m_rec->s_dob," \b0\par")
 SET reply->text = build2(reply->text,"}")
#exit_script
END GO
