CREATE PROGRAM dcp_act_pw_comp_r_pop_pw_id:dba
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
 SET readme_data->message = "Readme Failed:  Starting script DCP_ACT_PW_COMP_R_POP_PW_ID "
 DECLARE clean_pathway_reltn(dummy) = i2
 DECLARE errmsg = vc WITH protect, noconstant("")
 IF (clean_pathway_reltn(null) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update act_pw_comp_r: ",errmsg)
  GO TO exit_script
 ENDIF
 DECLARE foundvalues = i4 WITH protect, noconstant(1000)
 DECLARE pwidscnt = i4 WITH protect, noconstant(0)
 FREE RECORD pathwayids
 RECORD pathwayids(
   1 pathwayids[*]
     2 act_pw_comp_s_id = f8
     2 pathway_id = f8
 )
 SELECT INTO "nl"
  FROM act_pw_comp apc,
   act_pw_comp_r apcr
  WHERE apc.act_pw_comp_id=apcr.act_pw_comp_s_id
   AND apcr.act_pw_comp_s_id > 0.0
   AND apc.pathway_id > 0.0
   AND apcr.type_mean="TIMEZERO"
   AND apc.pathway_id != apcr.pathway_id
  DETAIL
   pwidscnt = (pwidscnt+ 1)
   IF (mod(pwidscnt,50)=1)
    stat = alterlist(pathwayids->pathwayids,(pwidscnt+ 49))
   ENDIF
   pathwayids->pathwayids[pwidscnt].act_pw_comp_s_id = apcr.act_pw_comp_s_id, pathwayids->pathwayids[
   pwidscnt].pathway_id = apc.pathway_id
  FOOT REPORT
   stat = alterlist(pathwayids->pathwayids,pwidscnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed in collection from ACT_PW_COMP: ",errmsg)
  GO TO exit_script
 ELSEIF (pwidscnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = "No ACT_PW_COMP entries found; auto-successing"
  GO TO exit_script
 ENDIF
 WHILE (foundvalues=1000)
  UPDATE  FROM act_pw_comp_r apcr,
    (dummyt d  WITH seq = value(pwidscnt))
   SET apcr.pathway_id = pathwayids->pathwayids[d.seq].pathway_id, apcr.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), apcr.updt_applctx = reqinfo->updt_applctx,
    apcr.updt_id = reqinfo->updt_id, apcr.updt_task = reqinfo->updt_task, apcr.updt_cnt = (apcr
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (apcr
    WHERE (apcr.act_pw_comp_s_id=pathwayids->pathwayids[d.seq].act_pw_comp_s_id)
     AND apcr.act_pw_comp_s_id > 0.0
     AND apcr.type_mean="TIMEZERO")
   WITH nocounter, maxqual(apcr,1000)
  ;end update
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update act_pw_comp_r: ",errmsg)
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
 SUBROUTINE clean_pathway_reltn(dummy)
   DECLARE idump_comp_idx = i4 WITH noconstant(0)
   FREE RECORD dup_comp_reltn
   RECORD dup_comp_reltn(
     1 list[*]
       2 comp_s_id = f8
       2 comp_t_id = f8
       2 pathway_id = f8
   )
   SELECT INTO "nl:"
    apcr.act_pw_comp_s_id, apcr.act_pw_comp_t_id, apc.pathway_id,
    count(*)
    FROM act_pw_comp apc,
     act_pw_comp_r apcr
    WHERE apc.pathway_comp_id > 0
     AND apcr.act_pw_comp_s_id=apc.pathway_comp_id
     AND apcr.type_mean="TIMEZERO"
    GROUP BY apcr.act_pw_comp_s_id, apcr.act_pw_comp_t_id, apc.pathway_id
    HAVING count(*) > 1
    DETAIL
     idump_comp_idx = (idump_comp_idx+ 1)
     IF (mod(idump_comp_idx,10)=1)
      stat = alterlist(dup_comp_reltn->list,(idump_comp_idx+ 9))
     ENDIF
     dup_comp_reltn->list[idump_comp_idx].comp_s_id = apcr.act_pw_comp_s_id, dup_comp_reltn->list[
     idump_comp_idx].comp_t_id = apcr.act_pw_comp_t_id, dup_comp_reltn->list[idump_comp_idx].
     pathway_id = apc.pathway_id
    FOOT REPORT
     stat = alterlist(dup_comp_reltn->list,idump_comp_idx)
    WITH nocounter
   ;end select
   CALL echorecord(dup_comp_reltn)
   IF (idump_comp_idx > 0)
    DELETE  FROM act_pw_comp_r apcr,
      (dummyt d  WITH seq = value(idump_comp_idx))
     SET apcr.seq = 1
     PLAN (d)
      JOIN (apcr
      WHERE (apcr.pathway_comp_s_id=dup_comp_reltn->list[d.seq].comp_s_id)
       AND (apcr.pathway_comp_t_id=dup_comp_reltn->list[d.seq].comp_t_id)
       AND (apcr.pathway_id != dup_comp_reltn->list[d.seq].pathway_id)
       AND apcr.type_mean="TIMEZERO")
     WITH counter
    ;end delete
   ENDIF
   SET ierrcode = 0
   SET ierrcode = error(errmsg,1)
   RETURN(ierrcode)
 END ;Subroutine
END GO
