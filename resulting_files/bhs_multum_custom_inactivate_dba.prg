CREATE PROGRAM bhs_multum_custom_inactivate:dba
 RECORD requestin(
   1 list_0[*]
     2 entity1_id = vc
     2 entity1_display = vc
     2 entity2_id = vc
     2 entity2_display = vc
 )
 RECORD requeststat(
   1 max_list = i2
   1 list_0[*]
     2 dnum_1 = vc
     2 dnum_2 = vc
     2 status = vc
 )
 DECLARE npersonid = f8
 CALL echo(build("Entering Multum_custom_update"))
 SET npersonid = 9911999
 SET rundttm = cnvtdatetime(curdate,curtime3)
 SET requeststat->max_list = size(requestin->list_0,5)
 SET stat = alterlist(requeststat->list_0,requeststat->max_list)
 FOR (x = 1 TO requeststat->max_list)
   SELECT INTO "NL:"
    der.entity_reltn_mean, der.entity1_id, der.entity2_id
    FROM dcp_entity_reltn der
    WHERE der.entity1_id=cnvtreal(requestin->list_0[x].entity1_id)
     AND der.entity2_id=cnvtreal(requestin->list_0[x].entity2_id)
     AND der.entity_reltn_mean="DRUG/DRUG"
     AND der.active_ind=1
    WITH nocounter
   ;end select
   SET requeststat->list_0[x].dnum_1 = requestin->list_0[x].entity1_id
   SET requeststat->list_0[x].dnum_2 = requestin->list_0[x].entity2_id
   IF (curqual=0)
    SET requeststat->list_0[x].status = "Z:active interaction does not exist"
   ELSE
    SET requeststat->list_0[x].status = "P:Processing update"
    UPDATE  FROM dcp_entity_reltn
     SET active_ind = 0, begin_effective_dt_tm = cnvtdatetime((curdate - 1),curtime3),
      end_effective_dt_tm = cnvtdatetime(rundttm),
      updt_id = npersonid
     WHERE entity1_id=cnvtreal(requestin->list_0[x].entity1_id)
      AND entity2_id=cnvtreal(requestin->list_0[x].entity2_id)
      AND entity_reltn_mean="DRUG/DRUG"
      AND active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET requeststat->list_0[x].status = "F:update failed"
     ROLLBACK
    ELSE
     SET requeststat->list_0[x].status = "S: update Success"
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET filename = concat("multum_inact_Upd_stat",format(cnvtdatetime(curdate,curtime3),
   "MMDDYYYYHHMM;;d"))
 SELECT INTO value(filename)
  max = requeststat->max_list, dnum_1 = requeststat->list_0[d.seq].dnum_1, dnum_2 = requeststat->
  list_0[d.seq].dnum_2,
  status = requeststat->list_0[d.seq].status
  FROM (dummyt d  WITH seq = size(requeststat->list_0,5))
  PLAN (d)
  WITH nocounter, separator = " ", format,
   pcformat('"',","), append, time = 15
 ;end select
 SET last_mod = "000"
END GO
