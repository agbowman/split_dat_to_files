CREATE PROGRAM dcp_query_pl_provider_group:dba
 RECORD definition(
   1 patient_list_id = f8
   1 parameters[*]
     2 parameter_name = vc
     2 paramter_seq = i4
     2 values[*]
       3 value_name = vc
       3 value_seq = i4
       3 value_string = vc
       3 value_dt = dq8
       3 value_id = f8
       3 value_entity = vc
 )
 RECORD patients(
   1 patients[*]
     2 person_id = f8
     2 encntr_id = f8
     2 priority = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD providers(
   1 providers[*]
     2 person_id = f8
 )
 RECORD date(
   1 startdate = dq8
   1 enddate = dq8
 )
 SET modify = predeclare
 DECLARE paramcnt = i4 WITH constant(size(definition->parameters,5))
 DECLARE prov_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE valuecnt = i4 WITH noconstant(0)
 DECLARE provcnt = i4 WITH noconstant(0)
 DECLARE provxcnt = i4 WITH noconstant(0)
 DECLARE reltntype_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE org_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE encntrtype_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE encntrclass_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE encntrstatus_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE medserv_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE admitdt_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE healthplan_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE encntr_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE provider_id = f8 WITH noconstant(0.0)
 DECLARE provider_id2 = f8 WITH noconstant(0.0)
 DECLARE duplicate = i2 WITH noconstant(0)
 DECLARE trueprovcnt = i4 WITH noconstant(0)
 DECLARE startoffset = i4 WITH noconstant(0)
 DECLARE endoffset = i4 WITH noconstant(0)
 DECLARE patcnt = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 SET patients->status_data.status = "F"
 SET valuecnt = size(definition->parameters[1].values,5)
 IF (valuecnt > 0)
  SET prov_where = "pgr.prsnl_group_id in ("
  FOR (x = 1 TO valuecnt)
    IF ((definition->parameters[1].values[x].value_name="V_GROUP_ID"))
     SET prov_where = concat(prov_where,trim(cnvtstring(definition->parameters[1].values[x].value_id)
       ),",")
    ELSEIF ((definition->parameters[1].values[x].value_name="V_PROVIDER_ID"))
     SET provcnt = (provcnt+ 1)
     IF (mod(provcnt,10)=1)
      SET stat = alterlist(providers->providers,(provcnt+ 9))
     ENDIF
     SET providers->providers[provcnt].person_id = definition->parameters[1].values[x].value_id
    ENDIF
  ENDFOR
  IF (trim(prov_where)="pgr.prsnl_group_id in ("
   AND provcnt=0)
   FOR (x = 1 TO valuecnt)
     IF ((definition->parameters[1].values[x].value_name="R_GROUP_ID"))
      SET prov_where = concat(prov_where,trim(cnvtstring(definition->parameters[1].values[x].value_id
         )),",")
     ELSEIF ((definition->parameters[1].values[x].value_name="R_PROVIDER_ID"))
      SET provcnt = (provcnt+ 1)
      IF (mod(provcnt,10)=1)
       SET stat = alterlist(providers->providers,(provcnt+ 9))
      ENDIF
      SET providers->providers[provcnt].person_id = definition->parameters[1].values[x].value_id
     ENDIF
   ENDFOR
  ENDIF
  SET provxcnt = provcnt
  IF (trim(prov_where) != "pgr.prsnl_group_id in (")
   SET prov_where = replace(prov_where,",",")",2)
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr
    WHERE parser(trim(prov_where))
    HEAD pgr.person_id
     provcnt = (provcnt+ 1)
     IF (mod(provcnt,10)=1)
      stat = alterlist(providers->providers,(provcnt+ 9))
     ENDIF
     providers->providers[provcnt].person_id = pgr.person_id
    FOOT REPORT
     stat = alterlist(providers->providers,provcnt)
    WITH nocounter
   ;end select
  ENDIF
  FOR (x = 1 TO provxcnt)
    SET duplicate = 0
    SET provider_id = providers->providers[x].person_id
    FOR (y = (provxcnt+ 1) TO provcnt)
     SET provider_id2 = providers->providers[y].person_id
     IF (provider_id=provider_id2)
      SET duplicate = 1
     ENDIF
    ENDFOR
    IF (duplicate=0)
     SET trueprovcnt = (trueprovcnt+ 1)
     SET providers->providers[trueprovcnt].person_id = provider_id
    ENDIF
  ENDFOR
  FOR (x = (provxcnt+ 1) TO provcnt)
   SET trueprovcnt = (trueprovcnt+ 1)
   SET providers->providers[trueprovcnt].person_id = providers->providers[x].person_id
  ENDFOR
  SET stat = alterlist(providers->providers,trueprovcnt)
  SET provcnt = trueprovcnt
 ENDIF
 IF (trueprovcnt=0)
  GO TO exit_script
 ENDIF
 SET valuecnt = size(definition->parameters[2].values,5)
 IF (valuecnt > 0)
  SET reltntype_where = " and epr.encntr_prsnl_r_cd in ("
  FOR (x = 1 TO valuecnt)
    IF ((definition->parameters[2].values[x].value_name="V_ENTITY_ID"))
     SET reltntype_where = concat(reltntype_where,trim(cnvtstring(definition->parameters[2].values[x]
        .value_id)),",")
    ENDIF
  ENDFOR
  IF (trim(reltntype_where)=" and epr.encntr_prsnl_r_cd in (")
   FOR (x = 1 TO valuecnt)
     IF ((definition->parameters[2].values[x].value_name="R_ENTITY_ID"))
      SET reltntype_where = concat(reltntype_where,trim(cnvtstring(definition->parameters[2].values[x
         ].value_id)),",")
     ENDIF
   ENDFOR
  ENDIF
  IF (trim(reltntype_where) != "")
   SET reltntype_where = replace(reltntype_where,",",")",2)
  ENDIF
 ELSE
  GO TO exit_script
 ENDIF
 FOR (y = 3 TO paramcnt)
   IF ((definition->parameters[y].parameter_seq=3))
    SET valuecnt = size(definition->parameters[y].values,5)
    SET org_where = " and e.organization_id in ("
    FOR (x = 1 TO valuecnt)
      IF ((definition->parameters[y].values[x].value_name="V_ENTITY_ID"))
       SET org_where = concat(org_where,trim(cnvtstring(definition->parameters[y].values[x].value_id)
         ),",")
      ENDIF
    ENDFOR
    IF (trim(org_where)=" and e.organization_id in (")
     FOR (x = 1 TO valuecnt)
       IF ((definition->parameters[y].values[x].value_name="R_ENTITY_ID"))
        SET org_where = concat(org_where,trim(cnvtstring(definition->parameters[y].values[x].value_id
           )),",")
       ENDIF
     ENDFOR
    ENDIF
    IF (trim(org_where) != "")
     SET org_where = replace(org_where,",",")",2)
    ENDIF
   ENDIF
   IF ((definition->parameters[y].parameter_seq=4))
    SET valuecnt = size(definition->parameters[y].values,5)
    SET encntrtype_where = " and e.encntr_type_cd in ("
    FOR (x = 1 TO valuecnt)
      IF ((definition->parameters[y].values[x].value_name="V_ENTITY_ID"))
       SET encntrtype_where = concat(encntrtype_where,trim(cnvtstring(definition->parameters[y].
          values[x].value_id)),",")
      ENDIF
    ENDFOR
    IF (trim(encntrtype_where)=" and e.encntr_type_cd in (")
     FOR (x = 1 TO valuecnt)
       IF ((definition->parameters[y].values[x].value_name="R_ENTITY_ID"))
        SET encntrtype_where = concat(encntrtype_where,trim(cnvtstring(definition->parameters[y].
           values[x].value_id)),",")
       ENDIF
     ENDFOR
    ENDIF
    IF (trim(encntrtype_where) != "")
     SET encntrtype_where = replace(encntrtype_where,",",")",2)
    ENDIF
   ENDIF
   IF ((definition->parameters[y].parameter_seq=5))
    SET valuecnt = size(definition->parameters[y].values,5)
    SET encntrclass_where = " and e.encntr_class_cd in ("
    FOR (x = 1 TO valuecnt)
      IF ((definition->parameters[y].values[x].value_name="V_ENTITY_ID"))
       SET encntrclass_where = concat(encntrclass_where,trim(cnvtstring(definition->parameters[y].
          values[x].value_id)),",")
      ENDIF
    ENDFOR
    IF (trim(encntrclass_where)=" and e.encntr_class_cd in (")
     FOR (x = 1 TO valuecnt)
       IF ((definition->parameters[y].values[x].value_name="R_ENTITY_ID"))
        SET encntrclass_where = concat(encntrclass_where,trim(cnvtstring(definition->parameters[y].
           values[x].value_id)),",")
       ENDIF
     ENDFOR
    ENDIF
    IF (trim(encntrclass_where) != "")
     SET encntrclass_where = replace(encntrclass_where,",",")",2)
    ENDIF
   ENDIF
   IF ((definition->parameters[y].parameter_seq=6))
    SET valuecnt = size(definition->parameters[y].values,5)
    SET encntrstatus_where = " and e.encntr_status_cd in ("
    FOR (x = 1 TO valuecnt)
      IF ((definition->parameters[y].values[x].value_name="V_ENTITY_ID"))
       SET encntrstatus_where = concat(encntrstatus_where,trim(cnvtstring(definition->parameters[y].
          values[x].value_id)),",")
      ENDIF
    ENDFOR
    IF (trim(encntrstatus_where)=" and e.encntr_status_cd in (")
     FOR (x = 1 TO valuecnt)
       IF ((definition->parameters[y].values[x].value_name="R_ENTITY_ID"))
        SET encntrstatus_where = concat(encntrstatus_where,trim(cnvtstring(definition->parameters[y].
           values[x].value_id)),",")
       ENDIF
     ENDFOR
    ENDIF
    IF (trim(encntrstatus_where) != "")
     SET encntrstatus_where = replace(encntrstatus_where,",",")",2)
    ENDIF
   ENDIF
   IF ((definition->parameters[y].parameter_seq=7))
    SET valuecnt = size(definition->parameters[y].values,5)
    SET medserv_where = " and e.med_service_cd in ("
    FOR (x = 1 TO valuecnt)
      IF ((definition->parameters[y].values[x].value_name="V_ENTITY_ID"))
       SET medserv_where = concat(medserv_where,trim(cnvtstring(definition->parameters[y].values[x].
          value_id)),",")
      ENDIF
    ENDFOR
    IF (trim(medserv_where)=" and e.med_service_cd in (")
     FOR (x = 1 TO valuecnt)
       IF ((definition->parameters[y].values[x].value_name="R_ENTITY_ID"))
        SET medserv_where = concat(medserv_where,trim(cnvtstring(definition->parameters[y].values[x].
           value_id)),",")
       ENDIF
     ENDFOR
    ENDIF
    IF (trim(medserv_where) != "")
     SET medserv_where = replace(medserv_where,",",")",2)
    ENDIF
   ENDIF
   IF ((definition->parameters[y].parameter_seq=8))
    SET valuecnt = size(definition->parameters[y].values,5)
    IF (valuecnt > 0)
     SET admitdt_where = " and e.reg_dt_tm between "
     FOR (x = 1 TO valuecnt)
       IF ((definition->parameters[y].values[x].value_name="V_START_DT"))
        SET date->startdate = cnvtdate(definition->parameters[y].values[x].value_dt)
       ELSEIF ((definition->parameters[y].values[x].value_name="V_END_DT"))
        SET date->enddate = definition->parameters[y].values[x].value_dt
       ELSEIF ((definition->parameters[y].values[x].value_name="V_START_OFFSET"))
        SET startoffset = cnvtint(definition->parameters[y].values[x].value_string)
       ELSEIF ((definition->parameters[y].values[x].value_name="V_END_OFFSET"))
        SET endoffset = cnvtint(definition->parameters[y].values[x].value_string)
       ENDIF
     ENDFOR
     IF ((date->startdate > 0)
      AND (date->enddate > 0))
      SET admitdt_where = concat(admitdt_where," cnvtdatetime(")
      SET admitdt_where = build(admitdt_where,date->startdate)
      SET admitdt_where = concat(admitdt_where,")"," and ")
      SET admitdt_where = concat(admitdt_where," cnvtdatetime(")
      SET admitdt_where = build(admitdt_where,date->enddate)
      SET admitdt_where = concat(admitdt_where,")")
     ELSEIF (startoffset >= 0
      AND endoffset >= 0)
      SET date->startdate = cnvtdatetime((curdate - endoffset),curtime)
      SET date->enddate = cnvtdatetime((curdate - startoffset),curtime)
      SET admitdt_where = concat(admitdt_where," cnvtdatetime(")
      SET admitdt_where = build(admitdt_where,date->startdate)
      SET admitdt_where = concat(admitdt_where,")"," and ")
      SET admitdt_where = concat(admitdt_where," cnvtdatetime(")
      SET admitdt_where = build(admitdt_where,date->enddate)
      SET admitdt_where = concat(admitdt_where,")")
     ELSE
      FOR (x = 1 TO valuecnt)
        IF ((definition->parameters[y].values[x].value_name="R_START_DT"))
         SET date->startdate = definition->parameters[y].values[x].value_dt
        ELSEIF ((definition->parameters[y].values[x].value_name="R_END_DT"))
         SET date->enddate = definition->parameters[y].values[x].value_dt
        ELSEIF ((definition->parameters[y].values[x].value_name="R_START_OFFSET"))
         SET startoffset = definition->parameters[y].values[x].value_string
        ELSEIF ((definition->parameters[y].values[x].value_name="R_END_OFFSET"))
         SET endoffset = definition->parameters[y].values[x].value_string
        ENDIF
      ENDFOR
      IF ((date->startdate > 0)
       AND (date->enddate > 0))
       SET admitdt_where = concat(admitdt_where,"cnvtDateTime(")
       SET admitdt_where = build(admitdt_where,date->startdate)
       SET admitdt_where = concat(admitdt_where,")"," and ")
       SET admitdt_where = concat(admitdt_where," cnvtdatetime(")
       SET admitdt_where = build(admitdt_where,date->enddate)
       SET admitdt_where = concat(admitdt_where,")")
      ELSEIF (startoffset >= 0
       AND endoffset >= 0)
       SET date->startdate = cnvtdatetime((curdate - endoffset),curtime)
       SET date->enddate = cnvtdatetime((curdate - startoffset),curtime)
       SET admitdt_where = concat(admitdt_where," cnvtdatetime(")
       SET admitdt_where = build(admitdt_where,date->startdate)
       SET admitdt_where = concat(admitdt_where,")"," and ")
       SET admitdt_where = concat(admitdt_where," cnvtdatetime(")
       SET admitdt_where = build(admitdt_where,date->enddate)
       SET admitdt_where = concat(admitdt_where,")")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((definition->parameters[y].parameter_seq=9))
    SET valuecnt = size(definition->parameters[y].values,5)
    SET healthplan_where = "epr2.health_plan_id in ("
    FOR (x = 1 TO valuecnt)
      IF ((definition->parameters[y].values[x].value_name="V_ENTITY_ID"))
       SET healthplan_where = concat(healthplan_where,trim(cnvtstring(definition->parameters[y].
          values[x].value_id)),",")
      ENDIF
    ENDFOR
    IF (trim(healthplan_where)="epr2.health_plan_id in (")
     FOR (x = 1 TO valuecnt)
       IF ((definition->parameters[y].values[x].value_name="R_ENTITY_ID"))
        SET healthplan_where = concat(healthplan_where,trim(cnvtstring(definition->parameters[y].
           values[x].value_id)),",")
       ENDIF
     ENDFOR
    ENDIF
    IF (trim(healthplan_where) != "")
     SET healthplan_where = replace(healthplan_where,",",")",2)
    ENDIF
   ENDIF
 ENDFOR
 CALL parser("select into null")
 CALL parser("from (dummyt d with seq = value(provCnt)), encntr_prsnl_reltn epr, encounter e")
 IF (trim(healthplan_where) != "")
  CALL parser(", encntr_plan_reltn epr2")
 ENDIF
 CALL parser("plan d")
 CALL parser(
  "join epr where epr.prsnl_person_id = providers->providers[d.seq]->person_id and epr.expiration_ind=0"
  )
 IF (trim(reltntype_where) != "")
  CALL parser(reltntype_where)
 ENDIF
 CALL parser("join e where e.encntr_id = epr.encntr_id")
 IF (trim(org_where) != "")
  CALL parser(org_where)
 ENDIF
 IF (trim(encntrtype_where) != "")
  CALL parser(encntrtype_where)
 ENDIF
 IF (trim(encntrclass_where) != "")
  CALL parser(encntrclass_where)
 ENDIF
 IF (trim(encntrstatus_where) != "")
  CALL parser(encntrstatus_where)
 ENDIF
 IF (trim(medserv_where) != "")
  CALL parser(medserv_where)
 ENDIF
 IF (trim(admitdt_where) != "")
  CALL parser(admitdt_where)
 ENDIF
 IF (trim(healthplan_where) != "")
  CALL parser("join epr2 where ")
  CALL parser(healthplan_where)
 ENDIF
 CALL parser("order by e.person_id")
 CALL parser("head report")
 CALL parser("patCnt = 0")
 CALL parser("detail")
 CALL parser("patCnt = patCnt + 1")
 CALL parser("if (mod(patCnt, 10) = 1)")
 CALL parser("stat = alterlist(patients->patients, patCnt + 9)")
 CALL parser("endif")
 CALL parser("patients->patients[patCnt].person_id = e.person_id")
 CALL parser("patients->patients[patCnt].encntr_id = e.encntr_id")
 CALL parser("patients->patients[patCnt].priority = 0")
 CALL parser("foot report")
 CALL parser("stat = alterlist(patients->patients, patCnt)")
 CALL parser("with nocounter go")
 IF (patcnt > 0)
  SET patients->status_data.status = "S"
 ELSE
  SET patients->status_data.status = "Z"
 ENDIF
#exit_script
END GO
