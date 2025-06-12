CREATE PROGRAM apacheiv:dba
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
 IF (((cursys="AXP") OR (cursys2="HPX")) )
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
 EXECUTE apachertl
 DECLARE status = i4
 SET aps_variable->sintubated = 1
 SET aps_variable->svent = 1
 SET aps_variable->sdialysis = 0
 SET aps_variable->seyes = 1
 SET aps_variable->smotor = 1
 SET aps_variable->sverbal = 1
 SET aps_variable->smeds = 0
 SET aps_variable->dwurine = 1946
 SET aps_variable->dwwbc = 9.4
 SET aps_variable->dwtemp = 35.7
 SET aps_variable->dwrespiratoryrate = 8
 SET aps_variable->dwsodium = 137
 SET aps_variable->dwheartrate = 50
 SET aps_variable->dwmeanbp = 60
 SET aps_variable->dwph = 7.26
 SET aps_variable->dwhematocrit = - (1)
 SET aps_variable->dwcreatinine = - (1.0)
 SET aps_variable->dwalbumin = - (1.0)
 SET aps_variable->dwpao2 = 97.6
 SET aps_variable->dwpco2 = 65
 SET aps_variable->dwbun = 11
 SET aps_variable->dwglucose = - (1.0)
 SET aps_variable->dwbilirubin = - (1.0)
 SET aps_variable->dwfio2 = 30
 CALL echo(build("p1=",size(aps_variable),",p2=",size(aps_prediction),",p3=",
   size(aps_outcome)))
 SET status = uar_amsapscalculate(aps_variable)
 CALL echo(build("uar_AmsApsCalculate (should return 63) =",status))
 IF (status < 0)
  CALL echo(build("uar_AmsApsCalculate err=",uar_amsraprinterror(status)))
 ENDIF
 SET aps_prediction->sicuday = 1
 SET aps_prediction->saps3day1 = status
 SET aps_prediction->saps3today = status
 SET aps_prediction->saps3yesterday = status
 SET aps_prediction->sgender = 0
 SET aps_prediction->steachtype = 2
 SET aps_prediction->sregion = 4
 SET aps_prediction->sbedcount = 200
 SET aps_prediction->sadmitsource = 3
 SET aps_prediction->sgraftcount = 0
 SET aps_prediction->smeds = 0
 SET aps_prediction->sverbal = 1
 SET aps_prediction->smotor = 5
 SET aps_prediction->seyes = 1
 SET aps_prediction->sage = 81
 SET aps_prediction->szicuadmitdate = concat("12/31/2001",char(0))
 SET aps_prediction->szhospadmitdate = concat("12/31/2001",char(0))
 SET aps_prediction->szadmitdiagnosis = concat("CARDIOMYOP",char(0))
 SET aps_prediction->bthrombolytics = 0
 SET aps_prediction->bdiedinhospital = 1
 SET aps_prediction->baids = 0
 SET aps_prediction->bhepaticfailure = 1
 SET aps_prediction->blymphoma = 0
 SET aps_prediction->bmetastaticcancer = 0
 SET aps_prediction->bleukemia = 0
 SET aps_prediction->bimmunosuppression = 0
 SET aps_prediction->bcirrhosis = 0
 SET aps_prediction->belectivesurgery = - (1)
 SET aps_prediction->bactivetx = 1
 SET aps_prediction->breadmit = 0
 SET aps_prediction->bima = 0
 SET aps_prediction->bmidur = 0
 SET aps_prediction->bventday1 = 0
 SET aps_prediction->boobventday1 = 0
 SET aps_prediction->boobintubday1 = 0
 SET aps_prediction->bdiabetes = 0
 SET aps_prediction->bmanagementsystem = 1
 SET aps_prediction->dwvar03hspxlos = 0.0
 SET aps_prediction->dwpao2 = - (1.0)
 SET aps_prediction->dwfio2 = - (1.0)
 SET aps_prediction->dwejectfx = - (1.0)
 SET aps_prediction->dwcreatinine = 1.4
 SET aps_prediction->sdischargelocation = - (1)
 SET aps_prediction->svisitnumber = 1
 SET aps_prediction->samilocation = - (1)
 SET aps_prediction->szicuadmitdatetime = concat("08/15/2003 21:25",char(0))
 SET aps_prediction->szhospadmitdatetime = concat("08/15/2003 20:36",char(0))
 SET aps_prediction->sday1meds = 0
 SET aps_prediction->sday1verbal = 1
 SET aps_prediction->sday1motor = 5
 SET aps_prediction->sday1eyes = 1
 SET aps_prediction->dwday1pao2 = - (1.0)
 SET aps_prediction->dwday1fio2 = - (1.0)
 SET status = uar_amscalculatepredictions(aps_prediction,aps_outcome)
 CALL echo(build("uar_AmsCalculatePredictions=",status))
 FOR (num = 1 TO 100)
   IF (nullterm(aps_outcome->qual[num].szequationname) > " ")
    CALL echo(build(num,"|",aps_outcome->qual[num].cversionnumber,"|",aps_outcome->qual[num].
      dwoutcome,
      "|",nullterm(aps_outcome->qual[num].szequationname),"|",aps_outcome->qual[num].
      nequationnamenumber))
   ENDIF
 ENDFOR
 CALL echo("CHECK OUTCOME RESULTS")
 CALL echo("ICU_DEATH should be 0.307173737")
 CALL echo("HSP_DEATH shoud be 0.668504546")
 CALL echo("NTL_ICU_LOS should be 3.98916288")
 CALL echo("NTL_HSP_LOS should be 8.28339007")
 CALL echo("DISCHG_ALIVE_TMR should be 0.334132618")
 IF (status < 0)
  CALL echo(build("uar_AmsCalculatePredictions err=",uar_amsraprinterror(status)))
 ENDIF
END GO
