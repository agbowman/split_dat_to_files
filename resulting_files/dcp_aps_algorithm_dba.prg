CREATE PROGRAM dcp_aps_algorithm:dba
 RECORD reply(
   1 aps_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD aps_variable(
   1 sintubated = i2
   1 svent = i2
   1 sdialysis = i2
   1 seyes = i2
   1 smotor = i2
   1 sverbal = i2
   1 smeds = i2
   1 filler1 = c2
   1 dwurine = f8
   1 dwwbc = f8
   1 dwtemp = f8
   1 dwrespiratoryrate = f8
   1 dwsodium = f8
   1 dwheartrate = f8
   1 dwmeanbp = f8
   1 dwph = f8
   1 dwhematocrit = f8
   1 dwcreatinine = f8
   1 dwalbumin = f8
   1 dwpao2 = f8
   1 dwpco2 = f8
   1 dwbun = f8
   1 dwglucose = f8
   1 dwbilirubin = f8
   1 dwfio2 = f8
   1 filler2 = c50
 )
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
   1 filler2 = c50
 )
 IF (((cursys="AXP") OR (cursys2="HPX")) )
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c7
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c6
  )
 ELSE
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c3
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c2
  )
 ENDIF
 DECLARE status = i4
 DECLARE aps_status = i4
 DECLARE outcome_status = i4
 EXECUTE apachertl
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_process TO 2099_process_exit
 GO TO 9999_exit_program
#1000_initialize
 SET reply->status_data.status = "S"
 DECLARE f_text = vc
 SET day_str = "   "
#1099_initialize_exit
#2000_process
 SET aps_variable->sintubated = request->intubated_ind
 SET aps_variable->svent = request->vent_ind
 SET aps_variable->sdialysis = request->dialysis_ind
 SET aps_variable->seyes = request->eyes
 SET aps_variable->smotor = request->motor
 SET aps_variable->sverbal = request->verbal
 SET aps_variable->smeds = request->meds_ind
 SET aps_variable->dwurine = request->urine
 SET aps_variable->dwwbc = request->wbc
 IF ((request->temp < 50))
  SET aps_variable->dwtemp = request->temp
 ELSE
  SET aps_variable->dwtemp = (((request->temp - 32) * 5)/ 9)
 ENDIF
 SET aps_variable->dwrespiratoryrate = request->resp
 SET aps_variable->dwsodium = request->sodium
 SET aps_variable->dwheartrate = request->heartrate
 SET aps_variable->dwmeanbp = request->meanbp
 SET aps_variable->dwph = request->ph
 SET aps_variable->dwhematocrit = request->hematocrit
 SET aps_variable->dwcreatinine = request->creatinine
 SET aps_variable->dwalbumin = request->albumin
 SET aps_variable->dwpao2 = request->pao2
 SET aps_variable->dwpco2 = request->pco2
 SET aps_variable->dwbun = request->bun
 SET aps_variable->dwglucose = request->glucose
 SET aps_variable->dwbilirubin = request->bilirubin
 SET aps_variable->dwfio2 = request->fio2
 CALL echo(build("p1=",size(aps_variable),",p2=",size(aps_prediction),",p3=",
   size(aps_outcome)))
 SET status = uar_amsapscalculate(aps_variable)
 CALL echo(build("uar_AmsApsCalculate=",status))
 SET reply->aps_status = status
 IF ((reply->aps_status < 0))
  CASE (reply->aps_status)
   OF - (22001):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for temperature.")
   OF - (22002):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for heart rate.")
   OF - (22003):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for resp rate.")
   OF - (22004):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for mean bp.")
   OF - (22005):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for sodium.")
   OF - (22006):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for glucose.")
   OF - (22007):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for albumin.")
   OF - (22008):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for creatinine.")
   OF - (22009):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for BUN.")
   OF - (22010):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for WBC.")
   OF - (22011):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for urine output.")
   OF - (22012):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for bilirubin.")
   OF - (22013):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for PCO2 & pH.")
   OF - (22014):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for hematocrit.")
   OF - (22015):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for paO2 & pcO2.")
   OF - (22017):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for meds, eyes, motor and verbal.")
   OF - (22018):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a valid value for heart rate, resp rate and mean bp.")
   OF - (22019):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating the APS requires a mimimum of 4 valid lab values.")
   OF - (23009):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid ICU Day.")
   OF - (23010):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid value for APS today.")
   OF - (23011):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid value for APS day1.")
   OF - (23013):
    SET f_text = concat("Valid DOB required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23014):
    SET f_text = concat("Valid Hosp Admit Date required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23015):
    SET f_text = concat("Valid ICU Admit Date required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23016):
    SET f_text = concat("Valid Admission Diagnosis required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23017):
    SET f_text = concat("Valid Admission Source required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23018):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a male or female gender.")
   OF - (23019):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid meds indicator.")
   OF - (23020):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid value for eyes(GCS).")
   OF - (23021):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid value for motor(GCS).")
   OF - (23022):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid value for verbal(GCS).")
   OF - (23023):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid thrombolytics indicator.")
   OF - (23024):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid AIDS indicator.")
   OF - (23025):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid hepatic failure indicator.")
   OF - (23026):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid lymphoma indicator.")
   OF - (23027):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid metastatic cancer indicator.")
   OF - (23028):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid leukemia indicator.")
   OF - (23029):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid immunosuppression indicator.")
   OF - (23030):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid cirrhosis indicator.")
   OF - (23031):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid elective surgery indicator.")
   OF - (23032):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid active treatment indicator.")
   OF - (23033):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires valid chronic health information.")
   OF - (23034):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires valid readmission information.")
   OF - (23035):
    SET f_text = concat("Valid internal mammory artery information required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23036):
    SET f_text = "Unable to calculate predictions, Hosp admission date is too early."
   OF - (23037):
    SET f_text = concat("Valid Eye value (GCS) required for Day 1(Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23038):
    SET f_text = concat("Valid Motor value (GCS) required for Day 1(Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23039):
    SET f_text = concat("Valid Verbal value (GCS) required for Day 1(Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23040):
    SET f_text = "Unable to calculate predictions, ICU admission date is too early."
   OF - (23100):
    SET f_text = concat("Unable to calculate predictions. ",
     "This patient has a nonpredictive diagnosis.")
   OF - (23103):
    SET f_text = "Nonpredictive patient age (<16 years), unable to calculate predictions."
   OF - (23110):
    SET f_text = "Invalid Age, unable to calculate predictions."
   OF - (23115):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires a valid creatinine value.")
   OF - (23116):
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "Calculating predictions requires valid Eject FX information.")
   OF - (23117):
    SET f_text = "Nonpredictive admission source (ICU), unable to calculate predictions."
   OF - (23118):
    SET f_text = concat("Valid Dicharge Location required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23119):
    SET f_text = concat("Valid Visit Number information required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   OF - (23120):
    SET f_text = concat("Valid AMI Location information required (Day ",trim(day_str),
     "). Unable to calculate predictions.")
   ELSE
    SET f_text = concat("Unable to calculate predictions for day ",trim(day_str),". ",
     "An unrecognized error occurred - error number ",cnvtstring(reply->aps_status),
     ".")
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectvalue = f_text
 ENDIF
#2099_process_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
