CREATE PROGRAM dcp_upd_patient_list:dba
 RECORD reply(
   1 patient_list_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE g_argument_to_add = i4 WITH public, noconstant(size(request->arguments,5))
 DECLARE g_encntr_to_add = i4 WITH public, noconstant(size(request->encntr_filters,5))
 DECLARE g_proxy_to_add = i4 WITH public, noconstant(size(request->proxies,5))
 DECLARE g_failed = c1 WITH public, noconstant("F")
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE cur_updt_cnt = i4 WITH public, noconstant(0)
 DECLARE tmp_patient_list_id = f8 WITH public, noconstant(0.0)
 DECLARE query_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",27360,"QUERY"))
 DECLARE statuscd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29804,"NOEXECUTE"))
 DECLARE updatelistname(null) = null
 DECLARE updatename = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->patient_list_id=0))
  SELECT INTO "nl:"
   nextseqnum = seq(dcp_patient_list_seq,nextval)
   FROM dual
   DETAIL
    tmp_patient_list_id = cnvtreal(nextseqnum)
   WITH nocounter
  ;end select
  INSERT  FROM dcp_patient_list pl
   SET pl.patient_list_id = tmp_patient_list_id, pl.description = substring(1,99,request->description
     ), pl.name = request->name,
    pl.owner_prsnl_id = request->owner_id, pl.patient_list_type_cd = request->patient_list_type_cd,
    pl.updt_applctx = reqinfo->updt_applctx,
    pl.updt_cnt = 0, pl.updt_dt_tm = cnvtdatetime(curdate,curtime3), pl.updt_id = reqinfo->updt_id,
    pl.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
 ELSE
  SET tmp_patient_list_id = request->patient_list_id
  DELETE  FROM dcp_pl_argument pla
   WHERE (pla.patient_list_id=request->patient_list_id)
   WITH nocounter
  ;end delete
  DELETE  FROM dcp_pl_encntr_filter plef
   WHERE (plef.patient_list_id=request->patient_list_id)
   WITH nocounter
  ;end delete
  DELETE  FROM dcp_pl_reltn plr
   WHERE (plr.patient_list_id=request->patient_list_id)
   WITH nocounter
  ;end delete
  SELECT INTO "nl:"
   FROM dcp_patient_list dpl
   WHERE (dpl.patient_list_id=request->patient_list_id)
   DETAIL
    IF ((dpl.name != request->name))
     updatename = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (updatename=1)
   CALL updatelistname(null)
  ENDIF
  SELECT INTO "nl:"
   pl.patient_list_id
   FROM dcp_patient_list pl
   WHERE (pl.patient_list_id=request->patient_list_id)
   DETAIL
    cur_updt_cnt = pl.updt_cnt
   WITH nocounter, forupdate(pl)
  ;end select
  IF (curqual=0)
   CALL echo("Lock row for DCP_PATIENT_LIST update failed")
   SET g_failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM dcp_patient_list pl
   SET pl.description = substring(1,99,request->description), pl.name = request->name, pl
    .owner_prsnl_id = request->owner_id,
    pl.patient_list_type_cd = request->patient_list_type_cd, pl.updt_applctx = reqinfo->updt_applctx,
    pl.updt_cnt = (pl.updt_cnt+ 1),
    pl.updt_dt_tm = cnvtdatetime(curdate,curtime3), pl.updt_id = reqinfo->updt_id, pl.updt_task =
    reqinfo->updt_task
   WHERE (pl.patient_list_id=request->patient_list_id)
   WITH nocounter
  ;end update
 ENDIF
 FOR (x = 1 TO g_argument_to_add)
   INSERT  FROM dcp_pl_argument pla
    SET pla.argument_id = seq(dcp_patient_list_seq,nextval), pla.argument_name = request->arguments[x
     ].argument_name, pla.argument_value = request->arguments[x].argument_value,
     pla.parent_entity_id = request->arguments[x].parent_entity_id, pla.parent_entity_name = request
     ->arguments[x].parent_entity_name, pla.patient_list_id = tmp_patient_list_id,
     pla.sequence = x, pla.updt_applctx = reqinfo->updt_applctx, pla.updt_cnt = 0,
     pla.updt_dt_tm = cnvtdatetime(curdate,curtime3), pla.updt_id = reqinfo->updt_id, pla.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
 ENDFOR
 FOR (x = 1 TO g_encntr_to_add)
   INSERT  FROM dcp_pl_encntr_filter plef
    SET plef.encntr_filter_id = seq(dcp_patient_list_seq,nextval), plef.encntr_type_cd = request->
     encntr_filters[x].encntr_type_cd, plef.encntr_class_cd = request->encntr_filters[x].
     encntr_class_cd,
     plef.patient_list_id = tmp_patient_list_id, plef.updt_applctx = reqinfo->updt_applctx, plef
     .updt_cnt = 0,
     plef.updt_dt_tm = cnvtdatetime(curdate,curtime3), plef.updt_id = reqinfo->updt_id, plef
     .updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
 ENDFOR
 FOR (x = 1 TO g_proxy_to_add)
   INSERT  FROM dcp_pl_reltn plr
    SET plr.reltn_id = seq(dcp_patient_list_seq,nextval), plr.patient_list_id = tmp_patient_list_id,
     plr.prsnl_group_id = request->proxies[x].prsnl_group_id,
     plr.prsnl_id = request->proxies[x].prsnl_id, plr.list_access_cd = request->proxies[x].
     list_access_cd, plr.beg_effective_dt_tm = cnvtdatetime(request->proxies[x].beg_dt_tm),
     plr.end_effective_dt_tm = cnvtdatetime(request->proxies[x].end_dt_tm), plr.updt_applctx =
     reqinfo->updt_applctx, plr.updt_cnt = 0,
     plr.updt_dt_tm = cnvtdatetime(curdate,curtime3), plr.updt_id = reqinfo->updt_id, plr.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
 ENDFOR
 IF ((request->patient_list_type_cd=query_type_cd))
  INSERT  FROM dcp_pl_query_list dpql
   SET dpql.patient_list_id = tmp_patient_list_id, dpql.template_id = request->template_id, dpql
    .execution_status_cd = statuscd,
    dpql.updt_applctx = reqinfo->updt_applctx, dpql.updt_cnt = 0, dpql.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    dpql.updt_id = reqinfo->updt_id, dpql.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
 ENDIF
 SET reply->patient_list_id = tmp_patient_list_id
 SUBROUTINE updatelistname(null)
   FREE RECORD prefs
   RECORD prefs(
     1 qual[*]
       2 proxy_ind = i2
       2 proxy_id = f8
       2 list_name = vc
       2 nvpid = f8
   )
   DECLARE count = i4 WITH noconstant(0)
   DECLARE patlistid = vc WITH constant(trim(cnvtstring(request->patient_list_id),3))
   DECLARE firstinitial = vc WITH noconstant(fillstring(5," "))
   DECLARE ownername = vc WITH noconstant(fillstring(100," "))
   DECLARE proxyname = vc WITH noconstant(fillstring(100," "))
   DECLARE proxyflag = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM name_value_prefs nvp,
     detail_prefs dp,
     view_prefs vp,
     name_value_prefs nvp2
    PLAN (nvp
     WHERE nvp.pvc_name="PatientListId"
      AND nvp.pvc_value=patlistid
      AND cnvtupper(nvp.parent_entity_name)="DETAIL_PREFS")
     JOIN (dp
     WHERE ((dp.detail_prefs_id+ 0)=nvp.parent_entity_id)
      AND dp.comp_name="CUSTOM"
      AND dp.view_name="PATLISTVIEW")
     JOIN (vp
     WHERE vp.prsnl_id=dp.prsnl_id
      AND vp.position_cd=dp.position_cd
      AND vp.application_number=dp.application_number
      AND vp.frame_type="PTLIST"
      AND vp.view_name=dp.view_name
      AND vp.view_seq=dp.view_seq)
     JOIN (nvp2
     WHERE nvp2.parent_entity_id=vp.view_prefs_id
      AND cnvtupper(nvp2.pvc_name)="VIEW_CAPTION")
    HEAD REPORT
     count = 0
    DETAIL
     count = (count+ 1)
     IF (mod(count,10)=1)
      stat = alterlist(prefs->qual,(count+ 9))
     ENDIF
     IF ((request->owner_id != vp.prsnl_id))
      prefs->qual[count].proxy_ind = 1, prefs->qual[count].proxy_id = vp.prsnl_id, proxyflag = 1
     ELSE
      prefs->qual[count].proxy_ind = 0, prefs->qual[count].list_name = request->name
     ENDIF
     prefs->qual[count].nvpid = nvp2.name_value_prefs_id
    FOOT REPORT
     stat = alterlist(prefs->qual,count)
    WITH nocounter
   ;end select
   IF (proxyflag=1)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=request->owner_id))
     DETAIL
      firstinitial = concat(substring(1,1,p.name_first),"."), ownername = concat(firstinitial,p
       .name_last), proxyname = concat(request->name," ("),
      proxyname = concat(proxyname,ownername), proxyname = concat(proxyname,")")
     WITH nocounter
    ;end select
    FOR (x = 1 TO count)
      IF ((prefs->qual[x].proxy_ind=1))
       SET prefs->qual[x].list_name = proxyname
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    pl.patient_list_id
    FROM (dummyt d  WITH seq = value(count)),
     name_value_prefs nvp
    PLAN (d)
     JOIN (nvp
     WHERE (prefs->qual[d.seq].nvpid=nvp.name_value_prefs_id))
    DETAIL
     cur_updt_cnt = nvp.updt_cnt
    WITH nocounter, forupdate(nvp)
   ;end select
   IF (curqual=0)
    CALL echo("Lock row for NAME_VALUE_PREFS update within UpdateListName subroutine failed")
    SET g_failed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM (dummyt d  WITH seq = value(count)),
     name_value_prefs nvp
    SET nvp.pvc_value = prefs->qual[d.seq].list_name
    PLAN (d)
     JOIN (nvp
     WHERE (prefs->qual[d.seq].nvpid=nvp.name_value_prefs_id))
    WITH nocounter
   ;end update
   FREE RECORD prefs
 END ;Subroutine
#exit_script
 IF (g_failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
