CREATE PROGRAM dm_omf_submission_report
 FREE SET rates
 RECORD rates(
   1 denom[9]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
   1 numer[9]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
   1 obs_rate[9]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
 )
 FREE SET continuous
 RECORD continuous(
   1 num_cases[6]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
   1 obs_mean[6]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
   1 obs_median[6]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
   1 obs_min[6]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
   1 obs_max[6]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
   1 obs_stddev[6]
     2 mean = f8
     2 median = f8
     2 minimum = f8
     2 maximum = f8
     2 std_dev = f8
 )
 SELECT INTO  $1
  ooc.*
  FROM omf_outcome_continuous ooc
  ORDER BY ooc.reporting_period, ooc.indicator_id, ooc.client_id,
   ooc.number_of_cases
  HEAD REPORT
   row + 1, col 5, "Number of Cases",
   row + 1
  HEAD ooc.indicator_id
   col + 1
  FOOT  ooc.indicator_id
   continuous->num_cases[ooc.indicator_id].mean = avg(ooc.number_of_cases), continuous->num_cases[ooc
   .indicator_id].minimum = min(ooc.number_of_cases), continuous->num_cases[ooc.indicator_id].maximum
    = max(ooc.number_of_cases),
   col 1, ooc.indicator_id, col + 1,
   ooc.reporting_period, col + 1, count(ooc.client_id),
   col + 1, sum(ooc.total_cases), col + 1,
   continuous->num_cases[ooc.indicator_id].mean, col + 1, continuous->num_cases[ooc.indicator_id].
   minimum,
   col + 1, continuous->num_cases[ooc.indicator_id].maximum, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
 SELECT INTO  $1
  ooc.*
  FROM omf_outcome_continuous ooc
  ORDER BY ooc.reporting_period, ooc.indicator_id, ooc.client_id,
   ooc.observed_mean
  HEAD REPORT
   col 5, "Observed mean", row + 1
  HEAD ooc.indicator_id
   col + 1
  FOOT  ooc.indicator_id
   continuous->obs_mean[ooc.indicator_id].mean = avg(ooc.number_of_cases), continuous->obs_mean[ooc
   .indicator_id].minimum = min(ooc.number_of_cases), continuous->obs_mean[ooc.indicator_id].maximum
    = max(ooc.number_of_cases),
   col 1, ooc.indicator_id, col + 1,
   ooc.reporting_period, col + 1, count(ooc.client_id),
   col + 1, sum(ooc.total_cases), col + 1,
   continuous->obs_mean[ooc.indicator_id].mean, col + 1, continuous->obs_mean[ooc.indicator_id].
   minimum,
   col + 1, continuous->obs_mean[ooc.indicator_id].maximum, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
 SELECT INTO  $1
  ooc.*
  FROM omf_outcome_continuous ooc
  ORDER BY ooc.reporting_period, ooc.indicator_id, ooc.client_id,
   ooc.observed_median
  HEAD REPORT
   col 5, "Observed median", row + 1
  HEAD ooc.indicator_id
   col + 1
  FOOT  ooc.indicator_id
   continuous->obs_median[ooc.indicator_id].mean = avg(ooc.observed_median), continuous->obs_median[
   ooc.indicator_id].minimum = min(ooc.observed_median), continuous->obs_median[ooc.indicator_id].
   maximum = max(ooc.observed_median),
   col 1, ooc.indicator_id, col + 1,
   ooc.reporting_period, col + 1, count(ooc.client_id),
   col + 1, sum(ooc.total_cases), col + 1,
   continuous->obs_median[ooc.indicator_id].mean, col + 1, continuous->obs_median[ooc.indicator_id].
   minimum,
   col + 1, continuous->obs_median[ooc.indicator_id].maximum, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
 SELECT INTO  $1
  ooc.*
  FROM omf_outcome_continuous ooc
  ORDER BY ooc.indicator_id, ooc.client_id, ooc.observed_minimum
  HEAD REPORT
   col 5, "Observed minimum", row + 1
  HEAD ooc.indicator_id
   col + 1
  FOOT  ooc.indicator_id
   continuous->obs_min[ooc.indicator_id].mean = avg(ooc.observed_minimum), continuous->obs_min[ooc
   .indicator_id].minimum = min(ooc.observed_minimum), continuous->obs_min[ooc.indicator_id].maximum
    = max(ooc.observed_minimum),
   col 1, ooc.indicator_id, col + 1,
   ooc.reporting_period, col + 1, count(ooc.client_id),
   col + 1, sum(ooc.total_cases), col + 1,
   continuous->obs_min[ooc.indicator_id].mean, col + 1, continuous->obs_min[ooc.indicator_id].minimum,
   col + 1, continuous->obs_min[ooc.indicator_id].maximum, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
 SELECT INTO  $1
  ooc.*
  FROM omf_outcome_continuous ooc
  ORDER BY ooc.reporting_period, ooc.indicator_id, ooc.client_id,
   ooc.observed_maximum
  HEAD REPORT
   col 5, "Observed maximum", row + 1
  HEAD ooc.indicator_id
   col + 1
  FOOT  ooc.indicator_id
   continuous->obs_max[ooc.indicator_id].mean = avg(ooc.observed_maximum), continuous->obs_max[ooc
   .indicator_id].minimum = min(ooc.observed_maximum), continuous->obs_max[ooc.indicator_id].maximum
    = max(ooc.observed_maximum),
   col 1, ooc.indicator_id, col + 1,
   ooc.reporting_period, col + 1, count(ooc.client_id),
   col + 1, sum(ooc.total_cases), col + 1,
   continuous->obs_max[ooc.indicator_id].mean, col + 1, continuous->obs_max[ooc.indicator_id].minimum,
   col + 1, continuous->obs_max[ooc.indicator_id].maximum, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
 SELECT INTO  $1
  ooc.*
  FROM omf_outcome_continuous ooc
  ORDER BY ooc.reporting_period, ooc.indicator_id, ooc.client_id,
   ooc.observed_standard_deviation
  HEAD REPORT
   col 5, "Observed standard_deviation", row + 1
  HEAD ooc.indicator_id
   col + 1
  FOOT  ooc.indicator_id
   continuous->obs_stddev[ooc.indicator_id].mean = avg(ooc.observed_standard_deviation), continuous->
   obs_stddev[ooc.indicator_id].minimum = min(ooc.observed_standard_deviation), continuous->
   obs_stddev[ooc.indicator_id].maximum = max(ooc.observed_standard_deviation),
   col 1, ooc.indicator_id, col + 1,
   ooc.reporting_period, col + 1, count(ooc.client_id),
   col + 1, sum(ooc.total_cases), col + 1,
   continuous->obs_stddev[ooc.indicator_id].mean, col + 1, continuous->obs_stddev[ooc.indicator_id].
   minimum,
   col + 1, continuous->obs_stddev[ooc.indicator_id].maximum, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
 SELECT INTO  $1
  oor.*
  FROM omf_outcome_rate oor
  ORDER BY oor.reporting_period, oor.indicator_id, oor.client_id,
   oor.denominator_value
  HEAD REPORT
   col 5, "Denominator value", row + 1
  HEAD oor.indicator_id
   col + 1
  FOOT  oor.indicator_id
   rates->denom[oor.indicator_id].mean = avg(oor.denominator_value), rates->denom[oor.indicator_id].
   minimum = min(oor.denominator_value), rates->denom[oor.indicator_id].maximum = max(oor
    .denominator_value),
   col 1, oor.indicator_id, col + 1,
   oor.reporting_period, col + 1, count(oor.client_id),
   col + 1, sum(oor.total_cases), col + 1,
   rates->denom[oor.indicator_id].mean, col + 1, rates->denom[oor.indicator_id].minimum,
   col + 1, rates->denom[oor.indicator_id].maximum, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
 SELECT INTO  $1
  oor.*
  FROM omf_outcome_rate oor
  ORDER BY oor.reporting_period, oor.indicator_id, oor.client_id,
   oor.numerator_value
  HEAD REPORT
   col 5, "Numerator value", row + 1
  HEAD oor.indicator_id
   col + 1
  FOOT  oor.indicator_id
   rates->numer[oor.indicator_id].mean = avg(oor.numerator_value), rates->numer[oor.indicator_id].
   minimum = min(oor.numerator_value), rates->numer[oor.indicator_id].maximum = max(oor
    .numerator_value),
   col 1, oor.indicator_id, col + 1,
   oor.reporting_period, col + 1, count(oor.client_id),
   col + 1, sum(oor.total_cases), col + 1,
   rates->numer[oor.indicator_id].mean, col + 1, rates->numer[oor.indicator_id].minimum,
   col + 1, rates->numer[oor.indicator_id].maximum, col + 1,
   rates->numer[oor.indicator_id].std_dev, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
 SELECT INTO  $1
  oor.*
  FROM omf_outcome_rate oor
  ORDER BY oor.reporting_period, oor.indicator_id, oor.client_id,
   oor.observed_rate
  HEAD REPORT
   col 5, "Observed rate", row + 1
  HEAD oor.indicator_id
   col + 1
  FOOT  oor.indicator_id
   rates->obs_rate[oor.indicator_id].mean = avg(oor.observed_rate), rates->obs_rate[oor.indicator_id]
   .minimum = min(oor.observed_rate), rates->obs_rate[oor.indicator_id].maximum = max(oor
    .observed_rate),
   col 1, oor.indicator_id, col + 1,
   oor.reporting_period, col + 1, count(oor.client_id),
   col + 1, sum(oor.total_cases), col + 1,
   rates->obs_rate[oor.indicator_id].mean, col + 1, rates->obs_rate[oor.indicator_id].minimum,
   col + 1, rates->obs_rate[oor.indicator_id].maximum, row + 1
  WITH format = pcformat, nocounter, append
 ;end select
END GO
