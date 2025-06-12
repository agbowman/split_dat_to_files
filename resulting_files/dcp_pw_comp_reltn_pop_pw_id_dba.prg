CREATE PROGRAM dcp_pw_comp_reltn_pop_pw_id:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script DCP_PW_COMP_RELTN_POP_PW_ID "
 DECLARE clean_pathway_reltn(null) = i2
 DECLARE errmsg = vc WITH protect, noconstant("")
 IF (clean_pathway_reltn(null) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update PW_COMP_RELTN: ",errmsg)
  GO TO exit_script
 ENDIF
 DECLARE foundvalues = i4 WITH protect, noconstant(1000)
 DECLARE pwidscnt = i4 WITH protect, noconstant(0)
 FREE RECORD pathwaycatids
 RECORD pathwaycatids(
   1 pathwaycatids[*]
     2 pathway_comp_s_id = f8
     2 pathway_catalog_id = f8
 )
 SELECT INTO "nl"
  FROM pathway_comp pwc,
   pw_comp_reltn pcr
  WHERE pwc.pathway_comp_id=pcr.pathway_comp_s_id
   AND pcr.pathway_comp_s_id > 0.0
   AND pwc.pathway_comp_id > 0.0
   AND pcr.type_mean="TIMEZERO"
   AND pwc.pathway_catalog_id != pcr.pathway_catalog_id
  DETAIL
   pwidscnt = (pwidscnt+ 1)
   IF (mod(pwidscnt,50)=1)
    stat = alterlist(pathwaycatids->pathwaycatids,(pwidscnt+ 49))
   ENDIF
   pathwaycatids->pathwaycatids[pwidscnt].pathway_comp_s_id = pcr.pathway_comp_s_id, pathwaycatids->
   pathwaycatids[pwidscnt].pathway_catalog_id = pwc.pathway_catalog_id
  FOOT REPORT
   stat = alterlist(pathwaycatids->pathwaycatids,pwidscnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed in collection from pathway_comp: ",errmsg)
  GO TO exit_script
 ELSEIF (pwidscnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = "No pathway_comp entries found; auto-successing"
  GO TO exit_script
 ENDIF
 WHILE (foundvalues=1000)
  UPDATE  FROM pw_comp_reltn pcr,
    (dummyt d  WITH seq = value(pwidscnt))
   SET pcr.pathway_catalog_id = pathwaycatids->pathwaycatids[d.seq].pathway_catalog_id, pcr
    .updt_dt_tm = cnvtdatetime(curdate,curtime3), pcr.updt_applctx = reqinfo->updt_applctx,
    pcr.updt_id = reqinfo->updt_id, pcr.updt_task = reqinfo->updt_task, pcr.updt_cnt = (pcr.updt_cnt
    + 1)
   PLAN (d)
    JOIN (pcr
    WHERE (pcr.pathway_comp_s_id=pathwaycatids->pathwaycatids[d.seq].pathway_comp_s_id)
     AND pcr.pathway_comp_s_id > 0.0
     AND pcr.type_mean="TIMEZERO")
   WITH nocounter, maxqual(pcr,1000)
  ;end update
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update PW_COMP_RELTN: ",errmsg)
   GO TO exit_script
  ELSE
   SET foundvalues = curqual
   COMMIT
  ENDIF
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = "Success - Readme performed all required tasks."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SUBROUTINE clean_pathway_reltn(null)
   DECLARE idump_comp_idx = i4 WITH noconstant(0)
   FREE RECORD dup_comp_reltn
   RECORD dup_comp_reltn(
     1 list[*]
       2 comp_s_id = f8
       2 comp_t_id = f8
       2 pathway_catalog_id = f8
   )
   SELECT INTO "nl:"
    pcr.pathway_comp_s_id, pcr.pathway_comp_t_id, pc.pathway_catalog_id,
    count(*)
    FROM pathway_comp pc,
     pw_comp_reltn pcr
    WHERE pc.pathway_comp_id > 0
     AND pcr.pathway_comp_s_id=pc.pathway_comp_id
     AND pcr.type_mean="TIMEZERO"
    GROUP BY pcr.pathway_comp_s_id, pcr.pathway_comp_t_id, pc.pathway_catalog_id
    HAVING count(*) > 1
    DETAIL
     idump_comp_idx = (idump_comp_idx+ 1)
     IF (mod(idump_comp_idx,10)=1)
      stat = alterlist(dup_comp_reltn->list,(idump_comp_idx+ 9))
     ENDIF
     dup_comp_reltn->list[idump_comp_idx].comp_s_id = pcr.pathway_comp_s_id, dup_comp_reltn->list[
     idump_comp_idx].comp_t_id = pcr.pathway_comp_t_id, dup_comp_reltn->list[idump_comp_idx].
     pathway_catalog_id = pc.pathway_catalog_id
    FOOT REPORT
     stat = alterlist(dup_comp_reltn->list,idump_comp_idx)
    WITH nocounter
   ;end select
   CALL echorecord(dup_comp_reltn)
   IF (idump_comp_idx > 0)
    DELETE  FROM pw_comp_reltn pcr,
      (dummyt d  WITH seq = value(idump_comp_idx))
     SET pcr.seq = 1
     PLAN (d)
      JOIN (pcr
      WHERE (pcr.pathway_comp_s_id=dup_comp_reltn->list[d.seq].comp_s_id)
       AND (pcr.pathway_comp_t_id=dup_comp_reltn->list[d.seq].comp_t_id)
       AND (pcr.pathway_catalog_id != dup_comp_reltn->list[d.seq].pathway_catalog_id)
       AND pcr.type_mean="TIMEZERO")
     WITH counter
    ;end delete
   ENDIF
   SET ierrcode = 0
   SET ierrcode = error(errmsg,1)
   RETURN(ierrcode)
 END ;Subroutine
END GO
