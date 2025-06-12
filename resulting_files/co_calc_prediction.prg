CREATE PROGRAM co_calc_prediction
 RECORD reply(
   1 outcome_status = i4
   1 qual[100]
     2 cversionnumber = c1
     2 dwoutcome = f8
     2 szequationname = c50
     2 nequationnamenumber = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (((cursys="AXP") OR (cursys2="HPX")) )
  RECORD aps_prediction(
    1 sicuday = i2
    1 saps3day1 = i2
    1 saps3today = i2
    1 saps3yesterday = i2
    1 sgender = i2
    1 steachtype = i2
    1 sregion = i2
    1 sbedcount = i2
    1 sadmitsource = i2
    1 sgraftcount = i2
    1 smeds = i2
    1 sverbal = i2
    1 smotor = i2
    1 seyes = i2
    1 sage = i2
    1 szicuadmitdate = c27
    1 szhospadmitdate = c27
    1 szadmitdiagnosis = c11
    1 filler1 = c1
    1 bthrombolytics = i2
    1 bdiedinhospital = i2
    1 baids = i2
    1 bhepaticfailure = i2
    1 blymphoma = i2
    1 bmetastaticcancer = i2
    1 bleukemia = i2
    1 bimmunosuppression = i2
    1 bcirrhosis = i2
    1 belectivesurgery = i2
    1 bactivetx = i2
    1 breadmit = i2
    1 bima = i2
    1 bmidur = i2
    1 bventday1 = i2
    1 boobventday1 = i2
    1 boobintubday1 = i2
    1 bdiabetes = i2
    1 bmanagementsystem = i2
    1 filler2 = c2
    1 dwvar03hspxlos = f8
    1 dwpao2 = f8
    1 dwfio2 = f8
    1 dwejectfx = f8
    1 dwcreatinine = f8
    1 sdischargelocation = i2
    1 svisitnumber = i2
    1 samilocation = i2
    1 szicuadmitdatetime = c27
    1 szhospadmitdatetime = c27
    1 sday1meds = i2
    1 sday1verbal = i2
    1 sday1motor = i2
    1 sday1eyes = i2
    1 filler3 = c4
    1 dwday1pao2 = f8
    1 dwday1fio2 = f8
  )
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c7
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c2
      2 nequationnamenumber = i2
      2 filler2 = c2
  )
 ELSE
  RECORD aps_prediction(
    1 sicuday = i2
    1 saps3day1 = i2
    1 saps3today = i2
    1 saps3yesterday = i2
    1 sgender = i2
    1 steachtype = i2
    1 sregion = i2
    1 sbedcount = i2
    1 sadmitsource = i2
    1 sgraftcount = i2
    1 smeds = i2
    1 sverbal = i2
    1 smotor = i2
    1 seyes = i2
    1 sage = i2
    1 szicuadmitdate = c27
    1 szhospadmitdate = c27
    1 szadmitdiagnosis = c11
    1 filler1 = c1
    1 bthrombolytics = i2
    1 bdiedinhospital = i2
    1 baids = i2
    1 bhepaticfailure = i2
    1 blymphoma = i2
    1 bmetastaticcancer = i2
    1 bleukemia = i2
    1 bimmunosuppression = i2
    1 bcirrhosis = i2
    1 belectivesurgery = i2
    1 bactivetx = i2
    1 breadmit = i2
    1 bima = i2
    1 bmidur = i2
    1 bventday1 = i2
    1 boobventday1 = i2
    1 boobintubday1 = i2
    1 bdiabetes = i2
    1 bmanagementsystem = i2
    1 filler2 = c2
    1 dwvar03hspxlos = f8
    1 dwpao2 = f8
    1 dwfio2 = f8
    1 dwejectfx = f8
    1 dwcreatinine = f8
    1 sdischargelocation = i2
    1 svisitnumber = i2
    1 samilocation = i2
    1 szicuadmitdatetime = c27
    1 szhospadmitdatetime = c27
    1 sday1meds = i2
    1 sday1verbal = i2
    1 sday1motor = i2
    1 sday1eyes = i2
    1 dwday1pao2 = f8
    1 dwday1fio2 = f8
  )
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c3
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c2
      2 nequationnamenumber = i2
      2 filler2 = c2
  )
 ENDIF
 SET aps_prediction->sicuday = request->cc_day
 SET aps_prediction->saps3day1 = request->aps_day1
 SET aps_prediction->saps3today = request->aps_score
 SET aps_prediction->saps3yesterday = request->aps_yesterday
 SET aps_prediction->sgender = request->gender
 SET aps_prediction->steachtype = request->teach_type_flag
 SET aps_prediction->sregion = request->region_flag
 SET aps_prediction->sbedcount = request->bedcount
 IF ((request->admit_source IN ("CHPAIN_CTR", "ICU", "ICU_TO_OR")))
  SET aps_prediction->sadmitsource = 5
 ELSEIF ((request->admit_source="OR"))
  SET aps_prediction->sadmitsource = 1
 ELSEIF ((request->admit_source="RR"))
  SET aps_prediction->sadmitsource = 2
 ELSEIF ((request->admit_source="ER"))
  SET aps_prediction->sadmitsource = 3
 ELSEIF ((request->admit_source="FLOOR"))
  SET aps_prediction->sadmitsource = 4
 ELSEIF ((request->admit_source="OTHER_HOSP"))
  SET aps_prediction->sadmitsource = 6
 ELSEIF ((request->admit_source="DIR_ADMIT"))
  SET aps_prediction->sadmitsource = 7
 ELSEIF ((request->admit_source IN ("SDU", "ICU_TO_SDU")))
  SET aps_prediction->sadmitsource = 8
 ENDIF
 SET aps_prediction->sgraftcount = request->nbr_grafts_performed
 SET aps_prediction->smeds = request->meds_ind
 SET aps_prediction->sverbal = request->verbal
 SET aps_prediction->smotor = request->motor
 SET aps_prediction->seyes = request->eyes
 SET aps_prediction->sage = request->age_in_years
 SET abc = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szicuadmitdate = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(request->hosp_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szhospadmitdate = concat(trim(abc),char(0))
 SET aps_prediction->szadmitdiagnosis = concat(trim(request->admitdiagnosis),char(0))
 SET aps_prediction->bthrombolytics = request->thrombolytics_ind
 SET aps_prediction->bdiedinhospital = request->diedinhospital_ind
 SET aps_prediction->baids = request->aids_ind
 SET aps_prediction->bhepaticfailure = request->hepaticfailure_ind
 SET aps_prediction->blymphoma = request->lymphoma_ind
 SET aps_prediction->bmetastaticcancer = request->metastaticcancer_ind
 SET aps_prediction->bleukemia = request->leukemia_ind
 SET aps_prediction->bimmunosuppression = request->immunosuppression_ind
 SET aps_prediction->bcirrhosis = request->cirrhosis_ind
 IF ((request->aids_ind=0)
  AND (request->hepaticfailure_ind=0)
  AND (request->lymphoma_ind=0)
  AND (request->metastaticcancer_ind=0)
  AND (request->leukemia_ind=0)
  AND (request->immunosuppression_ind=0)
  AND (request->cirrhosis_ind=0)
  AND (request->diabetes_ind=0)
  AND (request->copd_ind=0)
  AND (request->chronic_health_unavail_ind=0)
  AND (request->chronic_health_none_ind=0))
  SET aps_prediction->baids = - (1)
  SET aps_prediction->bhepaticfailure = - (1)
  SET aps_prediction->blymphoma = - (1)
  SET aps_prediction->bmetastaticcancer = - (1)
  SET aps_prediction->bleukemia = - (1)
  SET aps_prediction->bimmunosuppression = - (1)
  SET aps_prediction->bcirrhosis = - (1)
 ENDIF
 SET aps_prediction->belectivesurgery = request->electivesurgery_ind
 SET aps_prediction->bactivetx = request->activetx_ind
 SET aps_prediction->breadmit = request->readmit_ind
 SET aps_prediction->bima = request->ima_ind
 SET aps_prediction->bmidur = request->midur_ind
 SET aps_prediction->bventday1 = request->ventday1_ind
 SET aps_prediction->boobventday1 = maxval(request->oobventday1_ind,request->ventday1_ind)
 SET aps_prediction->boobintubday1 = request->oobintubday1_ind
 SET aps_prediction->bdiabetes = request->diabetes_ind
 SET aps_prediction->bmanagementsystem = 1
 SET aps_prediction->dwvar03hspxlos = request->var03hspxlos
 SET aps_prediction->dwpao2 = request->pao2
 SET aps_prediction->dwfio2 = request->fio2
 SET aps_prediction->dwejectfx = request->ejectfx
 SET aps_prediction->dwcreatinine = request->creatinine
 IF ((request->discharge_location="FLOOR"))
  SET aps_prediction->sdischargelocation = 4
 ELSEIF ((request->discharge_location="ICU_TRANSFER"))
  SET aps_prediction->sdischargelocation = 5
 ELSEIF ((request->discharge_location="OTHER_HOSP"))
  SET aps_prediction->sdischargelocation = 6
 ELSEIF ((request->discharge_location="HOME"))
  SET aps_prediction->sdischargelocation = 7
 ELSEIF ((request->discharge_location="OTHER"))
  SET aps_prediction->sdischargelocation = 8
 ELSEIF ((request->discharge_location="DEATH"))
  SET aps_prediction->sdischargelocation = 9
 ELSE
  SET aps_prediction->sdischargelocation = - (1)
 ENDIF
 SET aps_prediction->svisitnumber = request->visit_number
 IF ((request->ami_location="ANT"))
  SET aps_prediction->samilocation = 1
 ELSEIF ((request->ami_location="ANTLAT"))
  SET aps_prediction->samilocation = 2
 ELSEIF ((request->ami_location="ANTSEP"))
  SET aps_prediction->samilocation = 3
 ELSEIF ((request->ami_location="INF"))
  SET aps_prediction->samilocation = 4
 ELSEIF ((request->ami_location="LAT"))
  SET aps_prediction->samilocation = 5
 ELSEIF ((request->ami_location="NONQ"))
  SET aps_prediction->samilocation = 6
 ELSEIF ((request->ami_location="POST"))
  SET aps_prediction->samilocation = 7
 ELSE
  SET aps_prediction->samilocation = - (1)
 ENDIF
 SET abc = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szicuadmitdatetime = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(request->hosp_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szhospadmitdatetime = concat(trim(abc),char(0))
 SET aps_prediction->sday1meds = request->day1_meds
 SET aps_prediction->sday1verbal = request->day1_verbal
 SET aps_prediction->sday1motor = request->day1_motor
 SET aps_prediction->sday1eyes = request->day1_eyes
 SET aps_prediction->dwday1pao2 = request->day1_pao2
 SET aps_prediction->dwday1fio2 = request->day1_fio2
 SET status = uar_amscalculatepredictions(aps_prediction,aps_outcome)
 SET reply->outcome_status = status
 IF ((reply->outcome_status > 0))
  FOR (num = 1 TO 100)
    SET reply->qual[num].szequationname = trim(aps_outcome->qual[num].szequationname)
    SET reply->qual[num].cversionnumber = aps_outcome->qual[num].cversionnumber
    SET reply->qual[num].dwoutcome = aps_outcome->qual[num].dwoutcome
    SET reply->qual[num].nequationnamenumber = aps_outcome->qual[num].nequationnamenumber
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
END GO
