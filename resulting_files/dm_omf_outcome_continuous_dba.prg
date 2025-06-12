CREATE PROGRAM dm_omf_outcome_continuous:dba
 FREE SET data
 RECORD data(
   1 num_clients = i4
   1 array[*]
     2 client_id = f8
 )
 SET month =  $1
 SET year =  $2
 SET last_year = trim(cnvtstring((cnvtint(year) - 1)))
 FREE SET startdatesstring
 FREE SET begindatesstring
 SET begindatesstring = concat("01-",concat(month,concat("-",concat(last_year," 00:00:00.00"))))
 SET startdatesstring = concat("01-",concat(month,concat("-",concat(year," 00:00:00.00"))))
 SET kount = 0
 SELECT DISTINCT INTO "nl:"
  ooc.client_id
  FROM omf_outcome_continuous ooc
  WHERE ooc.reporting_period=cnvtdatetime(startdatesstring)
  ORDER BY ooc.client_id
  DETAIL
   kount = (kount+ 1), stat = alterlist(data->array,kount), data->array[kount].client_id = ooc
   .client_id
  WITH nocounter
 ;end select
 SET data->num_clients = kount
 IF (curqual=0)
  CALL echo("No client are present for passed month and year")
  GO TO end_prg
 ENDIF
 SET overall_numerator[2] = 0.0
 SET overall_num_cases[2] = 0
 SET overall_num_minimum[2] = 1000000
 SET overall_num_minimum[1] = 1000000
 SET overall_num_maximum[2] = - (1)
 SET overall_num_maximum[1] = - (1)
 SELECT DISTINCT INTO "nl:"
  ooc.client_id, ooc.indicator_id
  FROM omf_outcome_continuous ooc
  WHERE reporting_period BETWEEN cnvtdatetime(begindatesstring) AND cnvtdatetime(startdatesstring)
  ORDER BY ooc.client_id, ooc.indicator_id
  DETAIL
   overall_numerator[(cnvtint(ooc.indicator_id) - 4)] = (overall_numerator[(cnvtint(ooc.indicator_id)
    - 4)]+ (cnvtreal(ooc.number_of_cases) * ooc.observed_mean)), overall_num_cases[(cnvtint(ooc
    .indicator_id) - 4)] = (overall_num_cases[(cnvtint(ooc.indicator_id) - 4)]+ ooc.number_of_cases)
   IF ((ooc.observed_minimum < overall_num_minimum[(cnvtint(ooc.indicator_id) - 4)]))
    overall_num_minimum[(cnvtint(ooc.indicator_id) - 4)] = ooc.observed_minimum
   ENDIF
   IF ((ooc.observed_maximum > overall_num_maximum[(cnvtint(ooc.indicator_id) - 4)]))
    overall_num_maximum[(cnvtint(ooc.indicator_id) - 4)] = ooc.observed_maximum
   ENDIF
  WITH nocounter
 ;end select
 SET count = 0
 FOR (count = 5 TO 6)
  SET counter = 0
  FOR (counter = 1 TO data->num_clients)
   IF ((overall_num_cases[(count - 4)]=0))
    SET overall_mean = 0.0
   ELSE
    SET overall_mean = (cnvtreal(overall_numerator[(count - 4)])/ cnvtreal(overall_num_cases[(count
      - 4)]))
   ENDIF
   UPDATE  FROM omf_outcome_continuous ooc
    SET ooc.overall_num_cases = overall_num_cases[(count - 4)], ooc.overall_mean = overall_mean, ooc
     .overall_num_minimum = overall_num_minimum[(count - 4)],
     ooc.overall_num_maximum = overall_num_maximum[(count - 4)], ooc.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), ooc.updt_id = reqinfo->updt_id,
     ooc.updt_task = reqinfo->updt_task, ooc.updt_applctx = reqinfo->updt_applctx, ooc.updt_cnt = (
     ooc.updt_cnt+ 1)
    WHERE (ooc.client_id=data->array[counter].client_id)
     AND ooc.indicator_id=cnvtreal(count)
     AND ooc.reporting_period=cnvtdatetime(startdatesstring)
    WITH nocounter
   ;end update
  ENDFOR
 ENDFOR
 COMMIT
#end_prg
END GO
