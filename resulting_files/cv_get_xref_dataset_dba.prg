CREATE PROGRAM cv_get_xref_dataset:dba
 IF (validate(requestin,"notdefined") != "notdefined")
  CALL echo("Requestin record structure  is already defined!")
 ELSE
  CALL echo("Please use the *.com file to run this!!")
  GO TO exit_script
 ENDIF
 IF (validate(cv_internal,"notdefined") != "notdefined")
  CALL echo("Cv_internal record structure  is already defined!")
 ELSE
  RECORD cv_internal(
    1 pack[*]
      2 event_cd = f8
      2 task_assay_cd = f8
      2 xref_id = f8
  )
 ENDIF
 SET packet = 0
 SET event_cnt = 0
 SET stat = alterlist(cv_internal->pack,size(requestin->list_0,5))
 SELECT INTO "NL:"
  ref.event_cd
  FROM cv_xref ref,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (ref
   WHERE ref.xref_internal_name=trim(requestin->list_0[d1.seq].xref_internal_name))
  DETAIL
   cv_internal->pack[d1.seq].xref_id = ref.xref_id, cv_internal->pack[d1.seq].event_cd = ref.event_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("The select statement Failed to get event_cd ")
 ENDIF
 SELECT INTO "NL:"
  dta.task_assay_cd
  FROM discrete_task_assay dta,
   (dummyt d2  WITH seq = value(size(cv_internal->pack,5)))
  PLAN (d2
   WHERE (cv_internal->pack[d2.seq].event_cd > 0))
   JOIN (dta
   WHERE (dta.event_cd=cv_internal->pack[d2.seq].event_cd))
  DETAIL
   event_cnt = (event_cnt+ 1), cv_internal->pack[d2.seq].task_assay_cd = dta.task_assay_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("The select statement Failed to get task_assay_cd ")
 ENDIF
 UPDATE  FROM code_value cv,
   (dummyt d3  WITH seq = value(size(cv_internal->pack,5)))
  SET cv.cdf_meaning = requestin->list_0[d3.seq].cdf_meaning
  PLAN (d3)
   JOIN (cv
   WHERE (cv.code_value=cv_internal->pack[d3.seq].task_assay_cd))
  WITH nocounter
 ;end update
 UPDATE  FROM cv_xref x,
   (dummyt d4  WITH seq = value(size(cv_internal->pack,5)))
  SET x.task_assay_cd = cv_internal->pack[d4.seq].task_assay_cd
  PLAN (d4)
   JOIN (x
   WHERE (x.xref_id=cv_internal->pack[d4.seq].xref_id))
  WITH nocounter
 ;end update
#exit_script
 SET reqinfo->commit_ind = 1
END GO
