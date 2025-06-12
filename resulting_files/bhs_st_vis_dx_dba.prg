CREATE PROGRAM bhs_st_vis_dx:dba
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
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE mf_cs17_final = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!13984"))
 DECLARE mf_cs400_icd10 = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_dx = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM diagnosis dx,
   nomenclature n,
   diagnosis dx2
  PLAN (dx
   WHERE (dx.encntr_id=request->visit[1].encntr_id)
    AND dx.end_effective_dt_tm > sysdate
    AND dx.active_ind=1
    AND dx.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.nomenclature_id=dx.nomenclature_id
    AND n.source_vocabulary_cd=mf_cs400_icd10)
   JOIN (dx2
   WHERE dx2.diagnosis_group=dx.diagnosis_group)
  ORDER BY dx.diagnosis_group, dx2.beg_effective_dt_tm
  HEAD REPORT
   pl_cnt = 0
  HEAD dx.diagnosis_group
   pl_cnt += 1
   IF (pl_cnt=1)
    ms_dx = trim(dx2.diagnosis_display,3)
   ELSE
    ms_dx = concat(ms_dx,ms_reol," ",trim(dx2.diagnosis_display,3))
   ENDIF
  WITH nocounter
 ;end select
 SET ms_tmp = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET ms_tmp = concat(ms_tmp,ms_dx,"}")
 SET reply->text = ms_tmp
 CALL echo(reply->text)
#exit_script
END GO
