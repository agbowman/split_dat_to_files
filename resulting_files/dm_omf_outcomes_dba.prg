CREATE PROGRAM dm_omf_outcomes:dba
 FREE SET data
 RECORD data(
   1 client_id = f8
   1 client_name = c40
   1 health_system_name = c80
   1 health_plan_name = c80
   1 num_patients = i4
 )
 FREE SET clist
 RECORD clist(
   1 num_clients = i4
   1 list[*]
     2 client_id = f8
     2 health_system_name = c80
     2 health_plan_name = c80
 )
 SET stat = alterlist(clist->list,1)
 SET clist->num_clients = 0
 SET month =  $2
 SET year =  $3
 FREE SET startdatesstring
 FREE SET enddatesstring
 SET startdatesstring = concat("01-",concat(month,concat("-",concat(year," 00:00:00.00"))))
 IF (((month="jan") OR (((month="mar") OR (((month="may") OR (((month="jul") OR (((month="aug") OR (
 ((month="oct") OR (month="dec")) )) )) )) )) )) )
  SET enddatesstring = concat("31-",concat(month,concat("-",concat(year," 23:59:59.59"))))
 ELSEIF (((month="apr") OR (((month="jun") OR (((month="sep") OR (month="nov")) )) )) )
  SET enddatesstring = concat("30-",concat(month,concat("-",concat(year," 23:59:59.59"))))
 ELSEIF (month="feb")
  SET enddatesstring = concat("28-",concat(month,concat("-",concat(year," 23:59:59.59"))))
 ELSE
  CALL echo(concat(month," is an invalid month."))
  GO TO end_prg
 ENDIF
 SET startdate = cnvtdatetime(startdatesstring)
 SET enddate = cnvtdatetime(enddatesstring)
 IF (cnvtreal( $1) != 0)
  SET clist->num_clients = 1
  SET clist->list[1].client_id = cnvtreal( $1)
  SET clist->list[1].health_system_name =  $4
  SET clist->list[1].health_plan_name =  $5
 ELSE
  SELECT DISTINCT INTO "nl:"
   ooc.client_id
   FROM omf_outcome_client ooc,
    ub92_mon_encounter me
   PLAN (ooc)
    JOIN (me
    WHERE me.client_id_fl01=ooc.client_id
     AND me.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
     enddatesstring))
   ORDER BY ooc.client_id
   DETAIL
    clist->num_clients = (clist->num_clients+ 1)
    IF (mod(clist->num_clients,10)=1)
     stat = alterlist(clist->list,(clist->num_clients+ 9))
    ENDIF
    clist->list[clist->num_clients].client_id = ooc.client_id
   WITH nocounter
  ;end select
 ENDIF
 SET counter = 0
 FOR (counter = 1 TO clist->num_clients)
   SET kount = 0
   SELECT DISTINCT INTO "nl:"
    me.patient_control_nbr_fl03, me.cover_period_to_fl06, me.cover_period_from_fl06,
    me.client_id_fl01
    FROM ub92_mon_encounter me,
     ub92_mon_encounter_error mee
    PLAN (me
     WHERE (me.client_id_fl01=clist->list[counter].client_id)
      AND me.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
      enddatesstring))
     JOIN (mee
     WHERE outerjoin(me.ub92_mon_encounter_seq)=mee.ub92_mon_encounter_seq)
    ORDER BY me.client_id_fl01, me.patient_control_nbr_fl03, me.cover_period_from_fl06,
     me.cover_period_to_fl06
    DETAIL
     data->client_name = me.client_name_fl01, kount = (kount+ 1), row + 1
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("No patients qualify for passed client, month and year")
   ELSE
    SET data->num_patients = kount
    SET data->client_id = clist->list[counter].client_id
    SET data->health_system_name = clist->list[counter].health_system_name
    SET data->health_plan_name = clist->list[counter].health_plan_name
    IF (cnvtreal( $1) != 0)
     UPDATE  FROM omf_outcome_client ooc
      SET ooc.hospital_name = data->client_name, ooc.health_system_name = data->health_system_name,
       ooc.health_plan_name = data->health_plan_name
      WHERE (ooc.client_id=data->client_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM omf_outcome_client ooc
       SET ooc.client_id = data->client_id, ooc.health_system_name = data->health_system_name, ooc
        .health_plan_name = data->health_plan_name,
        ooc.hospital_name = data->client_name
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    EXECUTE dm_omf_1
    COMMIT
    EXECUTE dm_omf_2
    COMMIT
    EXECUTE dm_omf_3
    COMMIT
    EXECUTE dm_omf_4
    COMMIT
    EXECUTE dm_omf_5
    COMMIT
    EXECUTE dm_omf_6
    COMMIT
    EXECUTE dm_omf_7
    COMMIT
    EXECUTE dm_omf_8
    COMMIT
    EXECUTE dm_omf_9
    COMMIT
   ENDIF
 ENDFOR
#end_prg
END GO
