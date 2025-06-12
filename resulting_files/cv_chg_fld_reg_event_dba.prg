CREATE PROGRAM cv_chg_fld_reg_event:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
        3 operationnmae = c25
  )
 ENDIF
 RECORD internal(
   1 buf_ctr[*]
     2 event_id = f8
   1 buf_a[*]
     2 parent_event_id = f8
   1 buf_b[*]
     2 event_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 clinical_event_id = f8
     2 parent_event_id = f8
   1 buf_c[*]
     2 event_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 clinical_event_id = f8
     2 parent_event_id = f8
 )
 SET reply->status_data.status = "F"
 SET founded = "F"
 SET holder = 0
 SET orphan = "F"
 SET count = 0
 SET cntx = 0
 SET cnt0 = 0
 SET cnt1 = 0
 SET cnt2 = 0
 SET max_c = 0
 SELECT INTO "nl:"
  cr.event_id, cr.parent_event_id
  FROM cv_registry_event cr
  WHERE cr.encntr_id != cr.parent_event_id
   AND cr.parent_event_id > 0
  DETAIL
   founded = "T", cnt0 = (cnt0+ 1), stat = alterlist(internal->buf_ctr,cnt0),
   internal->buf_ctr[cnt0].event_id = cr.event_id
   IF (holder != cr.parent_event_id)
    count = (count+ 1), stat = alterlist(internal->buf_a,count), holder = cr.parent_event_id,
    internal->buf_a[count].parent_event_id = holder,
    CALL echo(build("The record number in CV_Registry_Event is :",count)),
    CALL echo(internal->buf_a[count].parent_event_id)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cr.xref_id
  FROM cv_registry_event cr
  WHERE cr.xref_id > 0
  DETAIL
   cntx = (cntx+ 1),
   CALL echo(build("Number of children:",cntx))
  WITH nocounter
 ;end select
 SET max_a = value(size(internal->buf_a,5))
 SET max_b = value(size(internal->buf_ctr,5))
 SET max_c = (1+ cntx)
 IF (max_c=0)
  CALL echo("All records are orphans!")
 ENDIF
 FOR (n = 1 TO max_a)
   CALL echo("****************************************************")
   CALL echo(build("Iteam #:",n))
   CALL echo(build("cntx:",cntx))
   CALL echo(build("max_b:",max_b))
   FOR (m = max_c TO max_b)
     IF ((internal->buf_a[n].parent_event_id=internal->buf_ctr[m].event_id))
      SET internal->buf_a[n].parent_event_id = 0
      CALL echo(build("peid_E:",internal->buf_a[n].parent_event_id))
     ELSE
      SET orphan = "T"
      CALL echo(build("peid_F:",internal->buf_a[n].parent_event_id))
     ENDIF
   ENDFOR
 ENDFOR
 IF (((orphan="T") OR (cntx=max_b)) )
  SET root = "F"
  CALL echo("Orphan records are in cv_registry_event table.")
 ELSE
  SET root = "T"
  CALL echo("No orphan records are in cv_registry_event table.")
 ENDIF
 WHILE (root="F")
   CALL echo("*****************************")
   CALL echo("A new loop starts from here!")
   CALL echo("==============================")
   SELECT INTO "nl:"
    ce.event_id, ce.parent_event_id
    FROM clinical_event ce,
     (dummyt t  WITH seq = value(size(internal->buf_a,5)))
    PLAN (t
     WHERE t.seq > 0)
     JOIN (ce
     WHERE (internal->buf_a[t.seq].parent_event_id=ce.event_id)
      AND ce.event_id != ce.parent_event_id
      AND ce.event_id > 0
      AND ce.parent_event_id > 0)
    HEAD REPORT
     cnt1 = 0
    DETAIL
     founded = "T", root = "F", cnt1 = (cnt1+ 1),
     stat = alterlist(internal->buf_b,cnt1), internal->buf_b[cnt1].event_id = ce.event_id, internal->
     buf_b[cnt1].encntr_id = ce.encntr_id,
     internal->buf_b[cnt1].person_id = ce.person_id, internal->buf_b[cnt1].clinical_event_id = ce
     .clinical_event_id, internal->buf_b[cnt1].parent_event_id = ce.parent_event_id,
     internal->buf_a[cnt1].parent_event_id = ce.parent_event_id,
     CALL echo(build("Event_Id to be inserted:",internal->buf_b[cnt1].event_id)),
     CALL echo(build("Parent_Event_Id to be inserted:",internal->buf_b[cnt1].parent_event_id)),
     CALL echo(build("Buf_A new values:",internal->buf_a[cnt1].parent_event_id)),
     CALL echo("********************************************************")
    FOOT REPORT
     stat = alterlist(internal->buf_a,cnt1)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(build("******** CURQUAL IS: ",curqual," **********"))
    SET root = "T"
    CALL echo(build("******** Root is: ",root," **********"))
    CALL echo("************ Looping End! *************")
   ENDIF
   INSERT  FROM cv_registry_event cr,
     (dummyt d  WITH seq = value(size(internal->buf_b,5)))
    SET cr.registry_event_id = seq(card_vas_seq,nextval), cr.event_id = internal->buf_b[d.seq].
     event_id, cr.encntr_id = internal->buf_b[d.seq].encntr_id,
     cr.person_id = internal->buf_b[d.seq].person_id, cr.clinical_event_id = internal->buf_b[d.seq].
     clinical_event_id, cr.parent_event_id = internal->buf_b[d.seq].parent_event_id,
     cr.harvested = 0, cr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cr
     .end_effective_dt_tm = cnvtdatetime("01-31-2000 00:00:00.00"),
     cr.updt_cnt = 0, cr.active_ind = 1, cr.active_status_cd = reqdata->active_status_cd,
     cr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cr.active_status_prsnl_id = reqinfo->
     updt_id, cr.data_status_cd = reqdata->data_status_cd,
     cr.data_status_prsnl_id = reqinfo->updt_id, cr.updt_id = reqinfo->updt_id, cr.updt_task =
     reqinfo->updt_task,
     cr.updt_applctx = reqinfo->updt_applctx, cr.updt_app = reqinfo->updt_app
    PLAN (d)
     JOIN (cr)
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    CALL echo("****************************************************************")
    CALL echo("Parents' records were inserted into CV_REGISTRY_EVENT table!")
    CALL echo("****************************************************************")
   ELSE
    GO TO error_check
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  ce.parent_event_id
  FROM clinical_event ce,
   (dummyt d  WITH seq = value(size(internal->buf_b,5)))
  PLAN (d)
   JOIN (ce
   WHERE ce.event_id=ce.parent_event_id
    AND (ce.event_id=internal->buf_b[d.seq].parent_event_id))
  DETAIL
   founded = "T", cnt2 = (cnt2+ 1), stat = alterlist(internal->buf_c,cnt2),
   internal->buf_c[cnt2].event_id = ce.event_id, internal->buf_c[cnt2].encntr_id = ce.encntr_id,
   internal->buf_c[cnt2].person_id = ce.person_id,
   internal->buf_c[cnt2].clinical_event_id = ce.clinical_event_id, internal->buf_c[cnt2].
   parent_event_id = ce.parent_event_id,
   CALL echo("*****************************************************"),
   CALL echo(build("Root EID: ",ce.event_id)),
   CALL echo(build("Root PEID: ",ce.parent_event_id))
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND founded="T")
  CALL echo("****************************************************************")
  CALL echo("Roots' records were successfully loaded!")
  CALL echo("****************************************************************")
 ELSE
  GO TO error_check
 ENDIF
 INSERT  FROM cv_registry_event cr,
   (dummyt d  WITH seq = value(size(internal->buf_c,5)))
  SET cr.registry_event_id = seq(card_vas_seq,nextval), cr.event_id = internal->buf_c[d.seq].event_id,
   cr.encntr_id = internal->buf_c[d.seq].encntr_id,
   cr.person_id = internal->buf_c[d.seq].person_id, cr.clinical_event_id = internal->buf_c[d.seq].
   clinical_event_id, cr.parent_event_id = internal->buf_c[d.seq].parent_event_id,
   cr.harvested = 0, cr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cr.end_effective_dt_tm
    = cnvtdatetime("01-31-2000 00:00:00.00"),
   cr.updt_cnt = 0, cr.active_ind = 1, cr.active_status_cd = reqdata->active_status_cd,
   cr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cr.active_status_prsnl_id = reqinfo->
   updt_id, cr.data_status_cd = reqdata->data_status_cd,
   cr.data_status_prsnl_id = reqinfo->updt_id, cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo
   ->updt_task,
   cr.updt_applctx = reqinfo->updt_applctx, cr.updt_app = reqinfo->updt_app
  PLAN (d)
   JOIN (cr)
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  CALL echo("**********************************************************")
  CALL echo("Root's records were inserted into cv_registry_event table!")
  CALL echo("**********************************************************")
 ELSE
  GO TO error_check
 ENDIF
#error_check
 SET reply->status_data.subeventstatus[1].targetobjectname = "cv_registry_event"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_ce_to_cr_event"
 GO TO exit_script
#exit_script
 IF (founded="T")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ENDIF
 GO TO end_program
#end_program
END GO
