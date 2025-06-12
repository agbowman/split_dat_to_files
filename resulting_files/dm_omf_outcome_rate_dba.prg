CREATE PROGRAM dm_omf_outcome_rate:dba
 FREE SET data
 RECORD data(
   1 array[*]
     2 client_id = f8
 )
 SET month =  $1
 SET year =  $2
 SET last_year = trim(cnvtstring((cnvtint(year) - 1)))
 SET this_year = year
 IF (month="jan")
  SET last_month = "feb"
 ELSEIF (month="feb")
  SET last_month = "mar"
 ELSEIF (month="mar")
  SET last_month = "apr"
 ELSEIF (month="apr")
  SET last_month = "may"
 ELSEIF (month="may")
  SET last_month = "jun"
 ELSEIF (month="jun")
  SET last_month = "jul"
 ELSEIF (month="jul")
  SET last_month = "aug"
 ELSEIF (month="aug")
  SET last_month = "sep"
 ELSEIF (month="sep")
  SET last_month = "oct"
 ELSEIF (month="oct")
  SET last_month = "nov"
 ELSEIF (month="nov")
  SET last_month = "dec"
 ELSEIF (month="dec")
  SET last_month = "jan"
 ENDIF
 FREE SET startdatesstring
 FREE SET enddatesstring
 SET startdatesstring = concat("01-",concat(last_month,concat("-",concat(last_year," 00:00:00.00"))))
 SET enddatesstring = concat("31-",concat(month,concat("-",concat(this_year," 00:00:00.00"))))
 SELECT DISTINCT INTO "nl:"
  oor.client_id
  FROM omf_outcome_rate oor
  WHERE oor.reporting_period=cnvtdatetime(concat("01-",month,"-",this_year))
  ORDER BY oor.client_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No clients are present for passed month and year")
  GO TO end_prg
 ENDIF
 SET total_num[9] = 0.0
 SET total_denom[9] = 0.0
 SET sum_num[9] = 0.0
 SELECT DISTINCT INTO "nl:"
  oor.client_id, oor.indicator_id
  FROM omf_outcome_rate oor
  WHERE oor.reporting_period BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(enddatesstring)
  ORDER BY oor.client_id, oor.indicator_id
  DETAIL
   total_num[cnvtint(oor.indicator_id)] = (total_num[cnvtint(oor.indicator_id)]+ oor.numerator_value),
   total_denom[cnvtint(oor.indicator_id)] = (total_denom[cnvtint(oor.indicator_id)]+ oor
   .denominator_value)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  oor.client_id
  FROM omf_outcome_rate oor
  WHERE oor.reporting_period BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(enddatesstring)
   AND oor.indicator_id=1
  ORDER BY oor.client_id
  DETAIL
   sum_num = (sum_num+ cnvtreal(oor.total_cases))
  WITH nocounter
 ;end select
 SET count = 0
 FOR (count = 1 TO 9)
   IF (count=5)
    SET count = 7
   ENDIF
   SET kount = 0
   SELECT DISTINCT INTO "nl:"
    oor.observed_rate, oor.client_id
    FROM omf_outcome_rate oor
    WHERE oor.indicator_id=cnvtreal(count)
     AND oor.reporting_period=cnvtdatetime(enddatesstring)
    ORDER BY oor.observed_rate DESC
    DETAIL
     kount = (kount+ 1), stat = alterlist(data->array,kount), data->array[kount].client_id = oor
     .client_id
    WITH nocounter
   ;end select
   SET counter = 0
   FOR (counter = 1 TO kount)
     SET observed_percentile = (cnvtreal(counter)/ cnvtreal(kount))
     IF ((total_denom[count]=0))
      SET total_rate = 0.0
     ELSE
      SET total_rate = (cnvtreal(total_num[count])/ cnvtreal(total_denom[count]))
     ENDIF
     UPDATE  FROM omf_outcome_rate oor
      SET oor.total_num = total_num[count], oor.total_denom = total_denom[count], oor
       .overall_num_cases = sum_num[count],
       oor.total_rate = total_rate, oor.observed_percentile = observed_percentile, oor.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       oor.updt_id = reqinfo->updt_id, oor.updt_task = reqinfo->updt_task, oor.updt_applctx = reqinfo
       ->updt_applctx,
       oor.updt_cnt = (oor.updt_cnt+ 1)
      WHERE (oor.client_id=data->array[counter].client_id)
       AND oor.indicator_id=cnvtreal(count)
       AND oor.reporting_period=cnvtdatetime(enddatesstring)
      WITH nocounter
     ;end update
   ENDFOR
 ENDFOR
 COMMIT
#end_prg
END GO
