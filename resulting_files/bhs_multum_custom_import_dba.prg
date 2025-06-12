CREATE PROGRAM bhs_multum_custom_import:dba
 RECORD requeststat(
   1 max_list = i2
   1 list_0[*]
     2 dnum_1 = vc
     2 dnum_2 = vc
     2 status = vc
 )
 DECLARE npersonid = f8
 CALL echo(build("Entering Multum_custom_update"))
 SELECT INTO "NL:"
  p.person_id
  FROM prsnl p
  WHERE p.username=curuser
  DETAIL
   npersonid = p.person_id
  WITH nocounter
 ;end select
 IF (npersonid=0)
  SET npersonid = 9991999
 ENDIF
 SET requeststat->max_list = size(requestin->list_0,5)
 SET stat = alterlist(requeststat->list_0,requeststat->max_list)
 FOR (x = 1 TO requeststat->max_list)
   SELECT INTO "NL:"
    der.entity_reltn_mean, der.entity1_id, der.entity2_id
    FROM dcp_entity_reltn der
    WHERE der.entity_reltn_mean="DRUG/DRUG"
     AND der.active_ind=1
     AND der.end_effective_dt_tm > sysdate
     AND der.entity1_id IN (cnvtreal(requestin->list_0[x].dnum_1), cnvtreal(requestin->list_0[x].
     dnum_2))
     AND der.entity2_id IN (cnvtreal(requestin->list_0[x].dnum_1), cnvtreal(requestin->list_0[x].
     dnum_2))
    WITH nocounter
   ;end select
   SET requeststat->list_0[x].dnum_1 = requestin->list_0[x].dnum_1
   SET requeststat->list_0[x].dnum_2 = requestin->list_0[x].dnum_2
   IF (curqual > 0)
    SET requeststat->list_0[x].status = "Z:Interaction exists"
   ELSE
    SET requeststat->list_0[x].status = "P:Processing Insert"
    IF (cnvtreal(requestin->list_0[x].dnum_1) < cnvtreal(requestin->list_0[x].dnum_2))
     INSERT  FROM dcp_entity_reltn
      SET dcp_entity_reltn_id = seq(carenet_seq,nextval), entity_reltn_mean = "DRUG/DRUG", entity1_id
        = cnvtreal(requestin->list_0[x].dnum_1),
       entity1_display = requestin->list_0[x].drug_name_1, entity2_id = cnvtreal(requestin->list_0[x]
        .dnum_2), entity2_display = requestin->list_0[x].drug_name_2,
       entity1_name = "DRUG", entity2_name = "DRUG", rank_sequence = 1,
       active_ind = 1, begin_effective_dt_tm = cnvtdatetime((curdate - 1),curtime3),
       end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
       updt_id = npersonid
     ;end insert
    ELSE
     INSERT  FROM dcp_entity_reltn
      SET dcp_entity_reltn_id = seq(carenet_seq,nextval), entity_reltn_mean = "DRUG/DRUG", entity1_id
        = cnvtreal(requestin->list_0[x].dnum_2),
       entity1_display = requestin->list_0[x].drug_name_2, entity2_id = cnvtreal(requestin->list_0[x]
        .dnum_1), entity2_display = requestin->list_0[x].drug_name_1,
       entity1_name = "DRUG", entity2_name = "DRUG", rank_sequence = 1,
       active_ind = 1, begin_effective_dt_tm = cnvtdatetime((curdate - 1),curtime3),
       end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
       updt_id = npersonid
     ;end insert
    ENDIF
    IF (curqual=0)
     SET requeststat->list_0[x].status = "F:Insert failed"
     ROLLBACK
    ELSE
     SET requeststat->list_0[x].status = "S: Insert Success"
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET filename = concat("Multum_import_status",format(cnvtdatetime(curdate,curtime3),"MMDDYYYYHH;;d"))
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
