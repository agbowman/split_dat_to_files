CREATE PROGRAM bed_get_ens_tasks_charttask:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status_list[*]
       3 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD vprequest(
   1 vplist[*]
     2 action_flag = c1
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 frame_type = c12
     2 view_name = c12
     2 view_seq = i4
 )
 FREE SET vpreply
 RECORD vpreply(
   1 vplist[*]
     2 view_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD vcprequest(
   1 vcplist[*]
     2 action_flag = c1
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 view_name = c12
     2 view_seq = i4
     2 comp_name = c12
     2 comp_seq = i4
 )
 FREE SET vcpreply
 RECORD vcpreply(
   1 vcplist[*]
     2 view_comp_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD nvprequest(
   1 nvplist[*]
     2 action_flag = c1
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 pvc_name = c32
     2 pvc_value = c256
 )
 FREE SET nvpreply
 RECORD nvpreply(
   1 nvplist[*]
     2 name_value_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD ordtaskrequest(
   1 action_flag = c1
   1 position_cd = f8
   1 olist[*]
     2 order_task_id = f8
 )
 FREE SET ordtaskreply
 RECORD ordtaskreply(
   1 olist[*]
     2 task_exists = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD multitaskrequest(
   1 action = c1
   1 task_list[*]
     2 task = c50
     2 on_off_ind = i2
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
 )
 FREE SET multitaskreply
 RECORD multitaskreply(
   1 status_data
     2 status_list[*]
       3 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD chartedtasks(
   1 clist[64]
     2 task_id = f8
     2 task_exists = i2
 )
 FOR (c = 1 TO 64)
  SET chartedtasks->clist[c].task_id = 0.0
  SET chartedtasks->clist[c].task_exists = 0
 ENDFOR
 SELECT INTO "NL:"
  FROM order_task ot
  WHERE ot.active_ind=1
   AND ot.task_description IN ("Adult Ambulatory Care Intake", "Pediatric Ambulatory Care Intake",
  "Blood Glucose Monitoring POC", "PPD Reading", "Pulse Oximetry",
  "Stool for Occult Blood POC", "Urine Dipstick POC", "Urine Pregnancy Test POC", "Vision Testing",
  "Advance Directive Ambulatory",
  "Asthma Assessment", "Asthma Scoring", "Blood Pressure", "Croup Scoring",
  "Domestic Violence Screen",
  "Enema Administration", "Head Circumference", "Heart Rate", "Height and Weight", "Height/Length",
  "Intake and Output", "Nasogastric/Orogastric Tube Care", "Neurovascular Assessment Lower Extremity",
  "Neurovascular Assessment Upper Extremity", "NIH Stroke Scale",
  "Orthostatic Vital Signs", "Pain Assessment Pediatric", "Pain Asessment Pediatric",
  "Pain Assessment Adult", "Patient Transfer",
  "Pediatric Growth Chart", "Peripheral IV Care", "Peripheral Pulse Rate", "Respiratory Rate",
  "Return to Work Status",
  "Temperature", "Valuables and Belongings", "Vital Signs", "Vitals/Height/Weight Ambulatory",
  "Weight",
  "Education Cardiac", "Education Diabetes", "Education Heart Failure", "Education Pre-op Orthopedic",
  "Patient Education",
  "Preprocedure Education", "Postprocedure Education", "Smoking Cessation",
  "Adult Moderate Sedation Monitoring", "Adult Postprocedure Assessment",
  "Cast Application", "Central Venous Line Care", "Orthopedic Device Care",
  "Pediatric Moderate Sedation Monitoring", "Preprocedure Checklist",
  "Urinary Catheter Insertion/Discontinuation", "Wound Care", "Respiratory Pretreatment Assessment",
  "RT Pretreatment Assessment", "Aerosol Therapy",
  "RT Aerosol Therapy", "Incentive Spirometry", "Oxygen Therapy", "RT Oxygen Therapy",
  "Antepartum, Initial Exam",
  "Antepartum, Supplemental Visits", "Adult Ambulatory Patient History",
  "Pediatric Ambulatory Patient History")
  DETAIL
   IF (ot.task_description="Adult Ambulatory Care Intake")
    chartedtasks->clist[1].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Pediatric Ambulatory Care Intake")
    chartedtasks->clist[2].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Blood Glucose Monitoring POC")
    chartedtasks->clist[3].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="PPD Reading")
    chartedtasks->clist[4].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Pulse Oximetry")
    chartedtasks->clist[5].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Stool for Occult Blood POC")
    chartedtasks->clist[6].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Urine Dipstick POC")
    chartedtasks->clist[7].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Urine Pregnancy Test POC")
    chartedtasks->clist[8].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Vision Testing")
    chartedtasks->clist[9].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Advance Directive Ambulatory")
    chartedtasks->clist[10].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Asthma Assessment")
    chartedtasks->clist[11].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Asthma Scoring")
    chartedtasks->clist[12].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Blood Pressure")
    chartedtasks->clist[13].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Croup Scoring")
    chartedtasks->clist[14].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Domestic Violence Screen")
    chartedtasks->clist[15].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Enema Administration")
    chartedtasks->clist[16].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Head Circumference")
    chartedtasks->clist[17].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Heart Rate")
    chartedtasks->clist[18].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Height and Weight")
    chartedtasks->clist[19].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Height/Length")
    chartedtasks->clist[20].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Intake and Output")
    chartedtasks->clist[21].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Nasogastric/Orogastric Tube Care")
    chartedtasks->clist[22].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Neurovascular Assessment Lower Extremity")
    chartedtasks->clist[23].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Neurovascular Assessment Upper Extremity")
    chartedtasks->clist[24].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="NIH Stroke Scale")
    chartedtasks->clist[25].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Orthostatic Vital Signs")
    chartedtasks->clist[26].task_id = ot.reference_task_id
   ELSEIF (((ot.task_description="Pain Assessment Pediatric") OR (ot.task_description=
   "Pain Asessment Pediatric")) )
    chartedtasks->clist[27].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Pain Assessment Adult")
    chartedtasks->clist[28].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Patient Transfer")
    chartedtasks->clist[29].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Pediatric Growth Chart")
    chartedtasks->clist[30].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Peripheral IV Care")
    chartedtasks->clist[31].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Peripheral Pulse Rate")
    chartedtasks->clist[32].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Respiratory Rate")
    chartedtasks->clist[33].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Return to Work Status")
    chartedtasks->clist[34].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Temperature")
    chartedtasks->clist[35].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Valuables and Belongings")
    chartedtasks->clist[36].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Vital Signs")
    chartedtasks->clist[37].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Vitals/Height/Weight Ambulatory")
    chartedtasks->clist[38].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Weight")
    chartedtasks->clist[39].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Education Cardiac")
    chartedtasks->clist[40].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Education Diabetes")
    chartedtasks->clist[41].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Education Heart Failure")
    chartedtasks->clist[42].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Education Pre-op Orthopedic")
    chartedtasks->clist[43].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Patient Education")
    chartedtasks->clist[44].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Preprocedure Education")
    chartedtasks->clist[45].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Postprocedure Education")
    chartedtasks->clist[46].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Smoking Cessation")
    chartedtasks->clist[47].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Adult Moderate Sedation Monitoring")
    chartedtasks->clist[48].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Adult Postprocedure Assessment")
    chartedtasks->clist[49].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Cast Application")
    chartedtasks->clist[50].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Central Venous Line Care")
    chartedtasks->clist[51].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Orthopedic Device Care")
    chartedtasks->clist[52].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Pediatric Moderate Sedation Monitoring")
    chartedtasks->clist[53].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Preprocedure Checklist")
    chartedtasks->clist[54].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Urinary Catheter Insertion/Discontinuation")
    chartedtasks->clist[55].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Wound Care")
    chartedtasks->clist[56].task_id = ot.reference_task_id
   ELSEIF (((ot.task_description="Respiratory Pretreatment Assessment") OR (ot.task_description=
   "RT Pretreatment Assessment")) )
    chartedtasks->clist[57].task_id = ot.reference_task_id
   ELSEIF (((ot.task_description="Aerosol Therapy") OR (ot.task_description="RT Aerosol Therapy")) )
    chartedtasks->clist[58].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Incentive Spirometry")
    chartedtasks->clist[59].task_id = ot.reference_task_id
   ELSEIF (((ot.task_description="Oxygen Therapy") OR (ot.task_description="RT Oxygen Therapy")) )
    chartedtasks->clist[60].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Antepartum, Initial Exam")
    chartedtasks->clist[61].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Antepartum, Supplemental Visits")
    chartedtasks->clist[62].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Adult Ambulatory Patient History")
    chartedtasks->clist[63].task_id = ot.reference_task_id
   ELSEIF (ot.task_description="Pediatric Ambulatory Patient History")
    chartedtasks->clist[64].task_id = ot.reference_task_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM order_task_position_xref otpx
  WHERE (otpx.position_cd=request->position_cd)
   AND otpx.reference_task_id > 0
   AND otpx.reference_task_id IN (chartedtasks->clist[1].task_id, chartedtasks->clist[2].task_id,
  chartedtasks->clist[3].task_id, chartedtasks->clist[4].task_id, chartedtasks->clist[5].task_id,
  chartedtasks->clist[6].task_id, chartedtasks->clist[7].task_id, chartedtasks->clist[8].task_id,
  chartedtasks->clist[9].task_id, chartedtasks->clist[10].task_id,
  chartedtasks->clist[11].task_id, chartedtasks->clist[12].task_id, chartedtasks->clist[13].task_id,
  chartedtasks->clist[14].task_id, chartedtasks->clist[15].task_id,
  chartedtasks->clist[16].task_id, chartedtasks->clist[17].task_id, chartedtasks->clist[18].task_id,
  chartedtasks->clist[19].task_id, chartedtasks->clist[20].task_id,
  chartedtasks->clist[21].task_id, chartedtasks->clist[22].task_id, chartedtasks->clist[23].task_id,
  chartedtasks->clist[24].task_id, chartedtasks->clist[25].task_id,
  chartedtasks->clist[26].task_id, chartedtasks->clist[27].task_id, chartedtasks->clist[28].task_id,
  chartedtasks->clist[29].task_id, chartedtasks->clist[30].task_id,
  chartedtasks->clist[31].task_id, chartedtasks->clist[32].task_id, chartedtasks->clist[33].task_id,
  chartedtasks->clist[34].task_id, chartedtasks->clist[35].task_id,
  chartedtasks->clist[36].task_id, chartedtasks->clist[37].task_id, chartedtasks->clist[38].task_id,
  chartedtasks->clist[39].task_id, chartedtasks->clist[40].task_id,
  chartedtasks->clist[41].task_id, chartedtasks->clist[42].task_id, chartedtasks->clist[43].task_id,
  chartedtasks->clist[44].task_id, chartedtasks->clist[45].task_id,
  chartedtasks->clist[46].task_id, chartedtasks->clist[47].task_id, chartedtasks->clist[48].task_id,
  chartedtasks->clist[49].task_id, chartedtasks->clist[50].task_id,
  chartedtasks->clist[51].task_id, chartedtasks->clist[52].task_id, chartedtasks->clist[53].task_id,
  chartedtasks->clist[54].task_id, chartedtasks->clist[55].task_id,
  chartedtasks->clist[56].task_id, chartedtasks->clist[57].task_id, chartedtasks->clist[58].task_id,
  chartedtasks->clist[59].task_id, chartedtasks->clist[60].task_id,
  chartedtasks->clist[61].task_id, chartedtasks->clist[62].task_id, chartedtasks->clist[63].task_id,
  chartedtasks->clist[64].task_id)
  DETAIL
   IF ((otpx.reference_task_id=chartedtasks->clist[1].task_id))
    chartedtasks->clist[1].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[2].task_id))
    chartedtasks->clist[2].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[3].task_id))
    chartedtasks->clist[3].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[4].task_id))
    chartedtasks->clist[4].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[5].task_id))
    chartedtasks->clist[5].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[6].task_id))
    chartedtasks->clist[6].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[7].task_id))
    chartedtasks->clist[7].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[8].task_id))
    chartedtasks->clist[8].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[9].task_id))
    chartedtasks->clist[9].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[10].task_id))
    chartedtasks->clist[10].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[11].task_id))
    chartedtasks->clist[11].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[12].task_id))
    chartedtasks->clist[12].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[13].task_id))
    chartedtasks->clist[13].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[14].task_id))
    chartedtasks->clist[14].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[15].task_id))
    chartedtasks->clist[15].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[16].task_id))
    chartedtasks->clist[16].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[17].task_id))
    chartedtasks->clist[17].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[18].task_id))
    chartedtasks->clist[18].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[19].task_id))
    chartedtasks->clist[19].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[20].task_id))
    chartedtasks->clist[20].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[21].task_id))
    chartedtasks->clist[21].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[22].task_id))
    chartedtasks->clist[22].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[23].task_id))
    chartedtasks->clist[23].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[24].task_id))
    chartedtasks->clist[24].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[25].task_id))
    chartedtasks->clist[25].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[26].task_id))
    chartedtasks->clist[26].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[27].task_id))
    chartedtasks->clist[27].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[28].task_id))
    chartedtasks->clist[28].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[29].task_id))
    chartedtasks->clist[29].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[30].task_id))
    chartedtasks->clist[30].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[31].task_id))
    chartedtasks->clist[31].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[32].task_id))
    chartedtasks->clist[32].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[33].task_id))
    chartedtasks->clist[33].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[34].task_id))
    chartedtasks->clist[34].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[35].task_id))
    chartedtasks->clist[35].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[36].task_id))
    chartedtasks->clist[36].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[37].task_id))
    chartedtasks->clist[37].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[38].task_id))
    chartedtasks->clist[38].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[39].task_id))
    chartedtasks->clist[39].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[40].task_id))
    chartedtasks->clist[40].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[41].task_id))
    chartedtasks->clist[41].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[42].task_id))
    chartedtasks->clist[42].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[43].task_id))
    chartedtasks->clist[43].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[44].task_id))
    chartedtasks->clist[44].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[45].task_id))
    chartedtasks->clist[45].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[46].task_id))
    chartedtasks->clist[46].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[47].task_id))
    chartedtasks->clist[47].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[48].task_id))
    chartedtasks->clist[48].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[49].task_id))
    chartedtasks->clist[49].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[50].task_id))
    chartedtasks->clist[50].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[51].task_id))
    chartedtasks->clist[51].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[52].task_id))
    chartedtasks->clist[52].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[53].task_id))
    chartedtasks->clist[53].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[54].task_id))
    chartedtasks->clist[54].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[55].task_id))
    chartedtasks->clist[55].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[56].task_id))
    chartedtasks->clist[56].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[57].task_id))
    chartedtasks->clist[57].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[58].task_id))
    chartedtasks->clist[58].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[59].task_id))
    chartedtasks->clist[59].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[60].task_id))
    chartedtasks->clist[60].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[61].task_id))
    chartedtasks->clist[61].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[62].task_id))
    chartedtasks->clist[62].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[63].task_id))
    chartedtasks->clist[63].task_exists = 1
   ELSEIF ((otpx.reference_task_id=chartedtasks->clist[64].task_id))
    chartedtasks->clist[64].task_exists = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->status_data.status_list,2)
 SET dummy_parm1 = 0
 SET dummy_parm2 = 0
 IF ((request->action="0"))
  SET single_comp_auth_exists = 0
  CALL complete_single_vp(dummy_parm1)
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_single_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[2].name_value_prefs_id > 0))
    CALL complete_single_vcp(dummy_parm1)
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_single_vcp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[1].action_flag = "0"
     SET nvprequest->nvplist[2].action_flag = "0"
     SET nvprequest->nvplist[3].action_flag = "0"
     SET nvprequest->nvplist[4].action_flag = "0"
     SET nvprequest->nvplist[5].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[3].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[4].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[5].name_value_prefs_id > 0))
      SET single_comp_auth_exists = 1
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  SET multi_comp_auth_exists = 0
  CALL complete_multi_vp(dummy_parm1)
  SET vprequest->vplist[1].action_flag = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
  IF ((vpreply->vplist[1].view_prefs_id > 0))
   CALL complete_multi_vp_nvp(dummy_parm1)
   SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
   SET nvprequest->nvplist[1].action_flag = "0"
   SET nvprequest->nvplist[2].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
   IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
    AND (nvpreply->nvplist[2].name_value_prefs_id > 0))
    CALL complete_multi_vcp(dummy_parm1)
    SET vcprequest->vcplist[1].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
     CALL complete_multi_vcp_nvp(dummy_parm1)
     SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
     SET nvprequest->nvplist[1].action_flag = "0"
     SET nvprequest->nvplist[2].action_flag = "0"
     SET nvprequest->nvplist[3].action_flag = "0"
     SET nvprequest->nvplist[4].action_flag = "0"
     SET nvprequest->nvplist[5].action_flag = "0"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
     IF ((nvpreply->nvplist[1].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[2].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[3].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[4].name_value_prefs_id > 0)
      AND (nvpreply->nvplist[5].name_value_prefs_id > 0))
      SET multi_comp_auth_exists = 1
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  SET all_tasks = 1
  FOR (c = 1 TO 64)
    IF ((chartedtasks->clist[c].task_exists=0))
     SET all_tasks = 0
     SET c = 65
    ENDIF
  ENDFOR
  SET reply->status_data.status_list[1].status = "0"
  SET reply->status_data.status_list[2].status = "0"
  IF (single_comp_auth_exists=1
   AND multi_comp_auth_exists=1
   AND all_tasks=1)
   SET reply->status_data.status_list[2].status = "1"
  ELSE
   IF (single_comp_auth_exists=1
    AND multi_comp_auth_exists=1)
    SET reply->status_data.status_list[1].status = "1"
   ENDIF
  ENDIF
 ELSEIF ((request->action="2"))
  SET view_off_on_ind = request->task_list[1].on_off_ind
  SET upd_off_on_ind = request->task_list[2].on_off_ind
  IF (((view_off_on_ind=1) OR (upd_off_on_ind=1)) )
   CALL complete_single_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id=0))
    SET vprequest->vplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   ENDIF
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_single_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSEIF ((nvpreply->nvplist[1].name_value_prefs_id=0))
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSEIF ((nvpreply->nvplist[2].name_value_prefs_id=0))
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
     SET nvprequest->nvplist[1].pvc_value = "38"
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
   CALL complete_single_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id=0))
    SET vcprequest->vcplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
   ENDIF
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_single_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET nvprequest->nvplist[4].action_flag = "0"
    SET nvprequest->nvplist[5].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0)
     AND (nvpreply->nvplist[3].name_value_prefs_id=0)
     AND (nvpreply->nvplist[4].name_value_prefs_id=0)
     AND (nvpreply->nvplist[5].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET nvprequest->nvplist[4].action_flag = "1"
     SET nvprequest->nvplist[5].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
     SET hold_nvp4 = nvpreply->nvplist[4].name_value_prefs_id
     SET hold_nvp5 = nvpreply->nvplist[5].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "COMP_TYPE"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp3=0)
      SET nvprequest->nvplist[1].pvc_name = "LIST_VIEW"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp4=0)
      SET nvprequest->nvplist[1].pvc_name = "PREFMGR_ENABLED"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp5=0)
      SET nvprequest->nvplist[1].pvc_name = "COMMAND_ID"
      SET nvprequest->nvplist[1].pvc_value = "33242"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
  ELSE
   CALL complete_single_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_single_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET vprequest->vplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   CALL complete_single_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_single_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET vcprequest->vcplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET nvprequest->nvplist[3].action_flag = "3"
    SET nvprequest->nvplist[4].action_flag = "3"
    SET nvprequest->nvplist[5].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  IF (((view_off_on_ind=1) OR (upd_off_on_ind=1)) )
   CALL complete_multi_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id=0))
    SET vprequest->vplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   ENDIF
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_multi_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSEIF ((nvpreply->nvplist[1].name_value_prefs_id=0))
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSEIF ((nvpreply->nvplist[2].name_value_prefs_id=0))
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     SET nvprequest->nvplist[1].pvc_name = "DISPLAY_SEQ"
     SET nvprequest->nvplist[1].pvc_value = "22"
     SET nvprequest->nvplist[1].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ENDIF
   ENDIF
   CALL complete_multi_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id=0))
    SET vcprequest->vcplist[1].action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
   ENDIF
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_multi_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[1].action_flag = "0"
    SET nvprequest->nvplist[2].action_flag = "0"
    SET nvprequest->nvplist[3].action_flag = "0"
    SET nvprequest->nvplist[4].action_flag = "0"
    SET nvprequest->nvplist[5].action_flag = "0"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
    IF ((nvpreply->nvplist[1].name_value_prefs_id=0)
     AND (nvpreply->nvplist[2].name_value_prefs_id=0)
     AND (nvpreply->nvplist[3].name_value_prefs_id=0)
     AND (nvpreply->nvplist[4].name_value_prefs_id=0)
     AND (nvpreply->nvplist[5].name_value_prefs_id=0))
     SET nvprequest->nvplist[1].action_flag = "1"
     SET nvprequest->nvplist[2].action_flag = "1"
     SET nvprequest->nvplist[3].action_flag = "1"
     SET nvprequest->nvplist[4].action_flag = "1"
     SET nvprequest->nvplist[5].action_flag = "1"
     SET trace = recpersist
     EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
      nvpreply)
    ELSE
     SET hold_nvp1 = nvpreply->nvplist[1].name_value_prefs_id
     SET hold_nvp2 = nvpreply->nvplist[2].name_value_prefs_id
     SET hold_nvp3 = nvpreply->nvplist[3].name_value_prefs_id
     SET hold_nvp4 = nvpreply->nvplist[4].name_value_prefs_id
     SET hold_nvp5 = nvpreply->nvplist[5].name_value_prefs_id
     SET nvprequest->nvplist[1].action_flag = "1"
     SET stat = alterlist(nvprequest->nvplist,1)
     SET stat = alterlist(nvpreply->nvplist,1)
     IF (hold_nvp1=0)
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp2=0)
      SET nvprequest->nvplist[1].pvc_name = "COMP_TYPE"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp3=0)
      SET nvprequest->nvplist[1].pvc_name = "LIST_VIEW"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp4=0)
      SET nvprequest->nvplist[1].pvc_name = "PREFMGR_ENABLED"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
     IF (hold_nvp5=0)
      SET nvprequest->nvplist[1].pvc_name = "COMMAND_ID"
      SET nvprequest->nvplist[1].pvc_value = "0"
      SET trace = recpersist
      EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
       nvpreply)
     ENDIF
    ENDIF
   ENDIF
  ELSE
   CALL complete_multi_vp(dummy_parm1)
   SET vprequest->vplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
   IF ((vpreply->vplist[1].view_prefs_id > 0))
    CALL complete_multi_vp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vpreply->vplist[1].view_prefs_id
    SET vprequest->vplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_prefs  WITH replace("REQUEST",vprequest), replace("REPLY",vpreply)
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
   CALL complete_multi_vcp(dummy_parm1)
   SET vcprequest->vcplist[1].action_flag = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply)
   IF ((vcpreply->vcplist[1].view_comp_prefs_id > 0))
    CALL complete_multi_vcp_nvp(dummy_parm1)
    SET nvprequest->nvplist[1].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[2].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[3].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[4].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET nvprequest->nvplist[5].parent_entity_id = vcpreply->vcplist[1].view_comp_prefs_id
    SET vcprequest->vcplist[1].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_view_comp_prefs  WITH replace("REQUEST",vcprequest), replace("REPLY",vcpreply
     )
    SET nvprequest->nvplist[1].action_flag = "3"
    SET nvprequest->nvplist[2].action_flag = "3"
    SET nvprequest->nvplist[3].action_flag = "3"
    SET nvprequest->nvplist[4].action_flag = "3"
    SET nvprequest->nvplist[5].action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ENDIF
  IF (upd_off_on_ind=1)
   SET nbr_tasks = 0
   FOR (c = 1 TO 64)
     IF ((chartedtasks->clist[c].task_exists=0))
      SET nbr_tasks = (nbr_tasks+ 1)
      SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
      SET ordtaskrequest->olist[nbr_tasks].order_task_id = chartedtasks->clist[c].task_id
     ENDIF
   ENDFOR
   IF (nbr_tasks > 0)
    SET ordtaskrequest->position_cd = request->position_cd
    SET ordtaskrequest->action_flag = "1"
    SET trace = recpersist
    EXECUTE bed_get_ens_ord_task_psn_xref  WITH replace("REQUEST",ordtaskrequest), replace("REPLY",
     ordtaskreply)
   ENDIF
  ELSE
   SET multitaskrequest->action = "0"
   SET multitaskrequest->application_number = 961000
   SET multitaskrequest->position_cd = request->position_cd
   SET multitaskrequest->prsnl_id = 0.0
   SET stat = alterlist(multitaskrequest->task_list,4)
   SET stat = alterlist(multitaskreply->status_data.status_list,4)
   SET multitaskrequest->task_list[1].task = "VIEWPTHIST"
   SET multitaskrequest->task_list[2].task = "UPDPTHIST"
   SET multitaskrequest->task_list[3].task = "VIEWRESULT"
   SET multitaskrequest->task_list[4].task = "COMMENTRESULT"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_pthistrslt  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET updpthist_stat = multitaskreply->status_data.status_list[2].status
   SET nbr_tasks = 0
   FOR (c = 1 TO 64)
     IF ((chartedtasks->clist[c].task_exists=1))
      IF (((c=63) OR (c=64))
       AND updpthist_stat="1")
       SET nbr_tasks = nbr_tasks
      ELSE
       SET nbr_tasks = (nbr_tasks+ 1)
       SET stat = alterlist(ordtaskrequest->olist,nbr_tasks)
       SET ordtaskrequest->olist[nbr_tasks].order_task_id = chartedtasks->clist[c].task_id
      ENDIF
     ENDIF
   ENDFOR
   IF (nbr_tasks > 0)
    SET ordtaskrequest->position_cd = request->position_cd
    SET ordtaskrequest->action_flag = "3"
    SET trace = recpersist
    EXECUTE bed_get_ens_ord_task_psn_xref  WITH replace("REQUEST",ordtaskrequest), replace("REPLY",
     ordtaskreply)
   ENDIF
  ENDIF
 ENDIF
 GO TO exitscript
 SUBROUTINE complete_single_vp(dummy_parm2)
   SET stat = alterlist(vprequest->vplist,1)
   SET vprequest->vplist[1].application_number = request->application_number
   SET vprequest->vplist[1].position_cd = request->position_cd
   SET vprequest->vplist[1].prsnl_id = request->prsnl_id
   SET vprequest->vplist[1].frame_type = "CHART"
   SET vprequest->vplist[1].view_name = "SPTASKLIST"
   SET vprequest->vplist[1].view_seq = 0
 END ;Subroutine
 SUBROUTINE complete_single_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Task List"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "38"
 END ;Subroutine
 SUBROUTINE complete_single_vcp(dummy_parm2)
   SET stat = alterlist(vcprequest->vcplist,1)
   SET vcprequest->vcplist[1].application_number = request->application_number
   SET vcprequest->vcplist[1].position_cd = request->position_cd
   SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
   SET vcprequest->vcplist[1].view_name = "SPTASKLIST"
   SET vcprequest->vcplist[1].view_seq = 0
   SET vcprequest->vcplist[1].comp_name = "SPTASKLIST"
   SET vcprequest->vcplist[1].comp_seq = 0
 END ;Subroutine
 SUBROUTINE complete_single_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[1].pvc_value = "PVTaskList.dll"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "COMP_TYPE"
   SET nvprequest->nvplist[2].pvc_value = "0"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "LIST_VIEW"
   SET nvprequest->nvplist[3].pvc_value = "0"
   SET nvprequest->nvplist[4].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[4].pvc_name = "PREFMGR_ENABLED"
   SET nvprequest->nvplist[4].pvc_value = "0"
   SET nvprequest->nvplist[5].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[5].pvc_name = "COMMAND_ID"
   SET nvprequest->nvplist[5].pvc_value = "33242"
 END ;Subroutine
 SUBROUTINE complete_multi_vp(dummy_parm2)
   SET stat = alterlist(vprequest->vplist,1)
   SET vprequest->vplist[1].application_number = request->application_number
   SET vprequest->vplist[1].position_cd = request->position_cd
   SET vprequest->vplist[1].prsnl_id = request->prsnl_id
   SET vprequest->vplist[1].frame_type = "ORG"
   SET vprequest->vplist[1].view_name = "MPTASKLIST"
   SET vprequest->vplist[1].view_seq = 0
 END ;Subroutine
 SUBROUTINE complete_multi_vp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,2)
   SET stat = alterlist(nvpreply->nvplist,2)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "VIEW_CAPTION"
   SET nvprequest->nvplist[1].pvc_value = "Multi-Patient Task List"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "DISPLAY_SEQ"
   SET nvprequest->nvplist[2].pvc_value = "22"
 END ;Subroutine
 SUBROUTINE complete_multi_vcp(dummy_parm2)
   SET stat = alterlist(vcprequest->vcplist,1)
   SET vcprequest->vcplist[1].application_number = request->application_number
   SET vcprequest->vcplist[1].position_cd = request->position_cd
   SET vcprequest->vcplist[1].prsnl_id = request->prsnl_id
   SET vcprequest->vcplist[1].view_name = "MPTASKLIST"
   SET vcprequest->vcplist[1].view_seq = 0
   SET vcprequest->vcplist[1].comp_name = "MPTASKLIST"
   SET vcprequest->vcplist[1].comp_seq = 0
 END ;Subroutine
 SUBROUTINE complete_multi_vcp_nvp(dummy_parm2)
   SET stat = alterlist(nvprequest->nvplist,5)
   SET stat = alterlist(nvpreply->nvplist,5)
   SET nvprequest->nvplist[1].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[1].pvc_name = "COMP_DLLNAME"
   SET nvprequest->nvplist[1].pvc_value = "PVTaskList.dll"
   SET nvprequest->nvplist[2].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[2].pvc_name = "COMP_TYPE"
   SET nvprequest->nvplist[2].pvc_value = "0"
   SET nvprequest->nvplist[3].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[3].pvc_name = "LIST_VIEW"
   SET nvprequest->nvplist[3].pvc_value = "0"
   SET nvprequest->nvplist[4].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[4].pvc_name = "PREFMGR_ENABLED"
   SET nvprequest->nvplist[4].pvc_value = "0"
   SET nvprequest->nvplist[5].parent_entity_name = "VIEW_COMP_PREFS"
   SET nvprequest->nvplist[5].pvc_name = "COMMAND_ID"
   SET nvprequest->nvplist[5].pvc_value = "0"
 END ;Subroutine
#exitscript
END GO
