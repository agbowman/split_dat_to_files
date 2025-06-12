CREATE PROGRAM cn_cki_map_zt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
#cki_mapping
 RECORD ckimap(
   1 ckimap[72]
     2 gadget = vc
     2 gadget_label = vc
     2 bin_desc = vc
     2 cki = vc
     2 stnd_event_set = vc
     2 mill_cnt = i4
     2 mill[*]
       3 code_val = f8
       3 display = vc
       3 description = vc
       3 updated_by = vc
       3 updated_on = dq8
       3 event_cd = f8
       3 dta_mnemonic = f8
       3 cki = vc
       3 event_cd_disp = vc
       3 event_cd_desc = vc
 )
 SET ckimap->ckimap[1].gadget = "Temperature"
 SET ckimap->ckimap[2].gadget = "Temperature"
 SET ckimap->ckimap[3].gadget = "Temperature"
 SET ckimap->ckimap[4].gadget = "Temperature"
 SET ckimap->ckimap[5].gadget = "Temperature"
 SET ckimap->ckimap[6].gadget = "Temperature"
 SET ckimap->ckimap[7].gadget = "Temperature"
 SET ckimap->ckimap[8].gadget = "Temperature"
 SET ckimap->ckimap[9].gadget = "Temperature"
 SET ckimap->ckimap[10].gadget = "Temperature"
 SET ckimap->ckimap[11].gadget = "Temperature"
 SET ckimap->ckimap[12].gadget = "Temperature"
 SET ckimap->ckimap[13].gadget = "Heart Rate"
 SET ckimap->ckimap[14].gadget = "Heart Rate"
 SET ckimap->ckimap[15].gadget = "Heart Rate"
 SET ckimap->ckimap[16].gadget = "Heart Rate"
 SET ckimap->ckimap[17].gadget = "Heart Rate"
 SET ckimap->ckimap[18].gadget = "Heart Rate"
 SET ckimap->ckimap[19].gadget = "Heart Rate"
 SET ckimap->ckimap[20].gadget = "Heart Rate"
 SET ckimap->ckimap[21].gadget = "Respiratory Rate"
 SET ckimap->ckimap[22].gadget = "Blood Pressure"
 SET ckimap->ckimap[23].gadget = "Blood Pressure"
 SET ckimap->ckimap[24].gadget = "Blood Pressure"
 SET ckimap->ckimap[25].gadget = "Blood Pressure"
 SET ckimap->ckimap[26].gadget = "Blood Pressure"
 SET ckimap->ckimap[27].gadget = "Blood Pressure"
 SET ckimap->ckimap[28].gadget = "Blood Pressure"
 SET ckimap->ckimap[29].gadget = "Blood Pressure"
 SET ckimap->ckimap[30].gadget = "Blood Pressure"
 SET ckimap->ckimap[31].gadget = "Blood Pressure"
 SET ckimap->ckimap[32].gadget = "Blood Pressure"
 SET ckimap->ckimap[33].gadget = "Blood Pressure"
 SET ckimap->ckimap[34].gadget = "Blood Pressure"
 SET ckimap->ckimap[35].gadget = "Blood Pressure"
 SET ckimap->ckimap[36].gadget = "Blood Pressure"
 SET ckimap->ckimap[37].gadget = "Blood Pressure"
 SET ckimap->ckimap[38].gadget = "Blood Pressure"
 SET ckimap->ckimap[39].gadget = "Blood Pressure"
 SET ckimap->ckimap[40].gadget = "Mean Arterial Pressure"
 SET ckimap->ckimap[41].gadget = "Mean Arterial Pressure"
 SET ckimap->ckimap[42].gadget = "Mean Arterial Pressure"
 SET ckimap->ckimap[43].gadget = "Mean Arterial Pressure"
 SET ckimap->ckimap[44].gadget = "Oxygen Saturation (SpO2)"
 SET ckimap->ckimap[45].gadget = "Oxygen Saturation (SpO2)"
 SET ckimap->ckimap[46].gadget = "Oxygen Saturation (SpO2)"
 SET ckimap->ckimap[47].gadget = "Oxygen Saturation (SpO2)"
 SET ckimap->ckimap[48].gadget = "Oxygen Saturation (SpO2)"
 SET ckimap->ckimap[49].gadget = "Oxygen Flow Rate"
 SET ckimap->ckimap[50].gadget = "Oxygen Therapy Type"
 SET ckimap->ckimap[51].gadget = "Height/Length"
 SET ckimap->ckimap[52].gadget = "Height/Length"
 SET ckimap->ckimap[53].gadget = "Weight"
 SET ckimap->ckimap[54].gadget = "Weight"
 SET ckimap->ckimap[55].gadget = "Weight"
 SET ckimap->ckimap[56].gadget = "Weight"
 SET ckimap->ckimap[57].gadget = "Weight"
 SET ckimap->ckimap[58].gadget = "Body Mass Index"
 SET ckimap->ckimap[59].gadget = "Body Mass Index"
 SET ckimap->ckimap[60].gadget = "Body Mass Index"
 SET ckimap->ckimap[61].gadget = "Head Circumference"
 SET ckimap->ckimap[62].gadget = "Head Circumference"
 SET ckimap->ckimap[63].gadget = "Pain Score"
 SET ckimap->ckimap[64].gadget = "Pain Score"
 SET ckimap->ckimap[65].gadget = "Pain Score"
 SET ckimap->ckimap[66].gadget = "Pain Score"
 SET ckimap->ckimap[67].gadget = "Pain Score"
 SET ckimap->ckimap[68].gadget = "Pain Score"
 SET ckimap->ckimap[69].gadget = "Pain Score"
 SET ckimap->ckimap[70].gadget = "Pain Score"
 SET ckimap->ckimap[71].gadget = "Pain Score"
 SET ckimap->ckimap[72].gadget = "Last Menstrual Period"
 SET ckimap->ckimap[1].gadget_label = "Temperature Temporal Artery"
 SET ckimap->ckimap[2].gadget_label = "Temperature Esophageal"
 SET ckimap->ckimap[3].gadget_label = "Temperature Brain"
 SET ckimap->ckimap[4].gadget_label = "Temperature Axillary"
 SET ckimap->ckimap[5].gadget_label = "Temperature Bladder"
 SET ckimap->ckimap[6].gadget_label = "Temperature Intravascular"
 SET ckimap->ckimap[7].gadget_label = "Temperature Oral"
 SET ckimap->ckimap[8].gadget_label = "Temperature Rectal"
 SET ckimap->ckimap[9].gadget_label = "Temperature Tympanic"
 SET ckimap->ckimap[10].gadget_label = "Temperature Skin"
 SET ckimap->ckimap[11].gadget_label = "Core Temperature"
 SET ckimap->ckimap[12].gadget_label = "Temperature (Route not specified)"
 SET ckimap->ckimap[13].gadget_label = "Heart Rate"
 SET ckimap->ckimap[14].gadget_label = "Heart Rate Monitored"
 SET ckimap->ckimap[15].gadget_label = "Apical Heart Rate"
 SET ckimap->ckimap[16].gadget_label = "Peripheral Pulse Rate"
 SET ckimap->ckimap[17].gadget_label = "Pulse Supine"
 SET ckimap->ckimap[18].gadget_label = "Pulse Sitting"
 SET ckimap->ckimap[19].gadget_label = "Pulse Standing"
 SET ckimap->ckimap[20].gadget_label = "Heart Rate Monitored, SpO2"
 SET ckimap->ckimap[21].gadget_label = "Respiratory Rate"
 SET ckimap->ckimap[22].gadget_label = "Systolic Blood Pressure Invasive"
 SET ckimap->ckimap[23].gadget_label = "Diastolic Blood Pressure Invasive"
 SET ckimap->ckimap[24].gadget_label = "Systolic Blood Pressure Non-invasive"
 SET ckimap->ckimap[25].gadget_label = "Diastolic Blood Pressure Non-invasive"
 SET ckimap->ckimap[26].gadget_label = "Right Ventricular Systolic Pressure"
 SET ckimap->ckimap[27].gadget_label = "Right Ventricular Diastolic Pressure"
 SET ckimap->ckimap[28].gadget_label = "Pulmonary Artery Systolic Pressure"
 SET ckimap->ckimap[29].gadget_label = "Pulmonary Artery Diastolic Pressure"
 SET ckimap->ckimap[30].gadget_label = "Systolic Blood Pressure Supine"
 SET ckimap->ckimap[31].gadget_label = "Diastolic Blood Pressure Supine"
 SET ckimap->ckimap[32].gadget_label = "Systolic Blood Pressure Standing"
 SET ckimap->ckimap[33].gadget_label = "Diastolic Blood Pressure Standing"
 SET ckimap->ckimap[34].gadget_label = "Systolic Blood Pressure Sitting"
 SET ckimap->ckimap[35].gadget_label = "Diastolic Blood Pressure Sitting"
 SET ckimap->ckimap[36].gadget_label = "Systolic Blood Pressure Invasive Secondary"
 SET ckimap->ckimap[37].gadget_label = "Diastolic Blood Pressure Invasive Secondary"
 SET ckimap->ckimap[38].gadget_label = "Systolic Blood Pressure Invasive Umbilical"
 SET ckimap->ckimap[39].gadget_label = "Diastolic Blood Pressure Invasive Umbilical"
 SET ckimap->ckimap[40].gadget_label = "Mean Arterial Pressure, Cuff"
 SET ckimap->ckimap[41].gadget_label = "Mean Arterial Pressure, Invasive"
 SET ckimap->ckimap[42].gadget_label = "Mean Arterial Pressure Invasive Secondary"
 SET ckimap->ckimap[43].gadget_label = "Mean Arterial Pressure Invasive Umbilical"
 SET ckimap->ckimap[44].gadget_label = "Oxygen Saturation Arterial"
 SET ckimap->ckimap[45].gadget_label = "Oxygen Saturation"
 SET ckimap->ckimap[46].gadget_label = "Oxygen Saturation Venous"
 SET ckimap->ckimap[47].gadget_label = "Peripheral Oxygen Saturation"
 SET ckimap->ckimap[48].gadget_label = "Oxygen Saturation Capillary"
 SET ckimap->ckimap[49].gadget_label = "Oxygen Flow Rate"
 SET ckimap->ckimap[50].gadget_label = "Oxygen Therapy Type"
 SET ckimap->ckimap[51].gadget_label = "Height/Length Estimated"
 SET ckimap->ckimap[52].gadget_label = "Height/Length Measured"
 SET ckimap->ckimap[53].gadget_label = "Weight Estimated"
 SET ckimap->ckimap[54].gadget_label = "Dosing Body Weight"
 SET ckimap->ckimap[55].gadget_label = "Birth Weight"
 SET ckimap->ckimap[56].gadget_label = "Usual Weight"
 SET ckimap->ckimap[57].gadget_label = "Weight Measured"
 SET ckimap->ckimap[58].gadget_label =
 "Body Mass Index, Estimated Using Measured Weight and Estimated Height"
 SET ckimap->ckimap[59].gadget_label = "Body Mass Index, Estimated"
 SET ckimap->ckimap[60].gadget_label = "Body Mass Index, Measured"
 SET ckimap->ckimap[61].gadget_label = "Head Circumference"
 SET ckimap->ckimap[62].gadget_label = "Birth Head Circumference"
 SET ckimap->ckimap[63].gadget_label = "FACES Pain Score"
 SET ckimap->ckimap[64].gadget_label = "Numeric Pain Score"
 SET ckimap->ckimap[65].gadget_label = "NIPS Pain Assessment Score"
 SET ckimap->ckimap[66].gadget_label = "CHEOPS Pain Assessment Score"
 SET ckimap->ckimap[67].gadget_label = "PIPP Pain Score"
 SET ckimap->ckimap[68].gadget_label = "RIPS Pain Assessment Score"
 SET ckimap->ckimap[69].gadget_label = "FLACC Score"
 SET ckimap->ckimap[70].gadget_label = "CPOT Ventilated Score"
 SET ckimap->ckimap[71].gadget_label = "CPOT Nonventilated Score"
 SET ckimap->ckimap[72].gadget_label = "Last Menstrual Period"
 SET ckimap->ckimap[1].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[2].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[3].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[4].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[5].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[6].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[7].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[8].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[9].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[10].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[11].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[12].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[13].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[14].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[15].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[16].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[17].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[18].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[19].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[20].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[21].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[22].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[23].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[24].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[25].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[26].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[27].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[28].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[29].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[30].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[31].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[32].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[33].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[34].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[35].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[36].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[37].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[38].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[39].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[40].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[41].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[42].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[43].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[44].bin_desc = "CE Lab Results 93.bin"
 SET ckimap->ckimap[45].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[46].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[47].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[48].bin_desc = "CE Lab Results 93.bin"
 SET ckimap->ckimap[49].bin_desc = "CE Measurement 93.bi"
 SET ckimap->ckimap[50].bin_desc = "CE Clinical Documentation 93.bin"
 SET ckimap->ckimap[51].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[52].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[53].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[54].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[55].bin_desc = "CE Women's Health 93.bin"
 SET ckimap->ckimap[56].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[57].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[58].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[59].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[60].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[61].bin_desc = "CE Women's Health 93.bin"
 SET ckimap->ckimap[62].bin_desc = "CE Women's Health 93.bi"
 SET ckimap->ckimap[63].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[64].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[65].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[66].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[67].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[68].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[69].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[70].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[71].bin_desc = "CE Measurement 93.bin"
 SET ckimap->ckimap[72].bin_desc = "CE Women's Health 93.b"
 SET ckimap->ckimap[1].cki = "CERNER!0BF8678F-E5DD-4342-BED7-BAC7F7C7ECA0"
 SET ckimap->ckimap[2].cki = "CERNER!AC6aqgEDbA0M1oC/n4waeg"
 SET ckimap->ckimap[3].cki = "CERNER!AC6aqgEDbA0M1oC3n4waeg"
 SET ckimap->ckimap[4].cki = "CERNER!AC6aqgEDbA0M1oCnn4waeg"
 SET ckimap->ckimap[5].cki = "CERNER!AC6aqgEDbA0M1oCvn4waeg"
 SET ckimap->ckimap[6].cki = "CERNER!AC6aqgEDbA0M1oDHn4waeg"
 SET ckimap->ckimap[7].cki = "CERNER!AC6aqgEDbA0M1oDPn4waeg"
 SET ckimap->ckimap[8].cki = "CERNER!AC6aqgEDbA0M1oDXn4waeg"
 SET ckimap->ckimap[9].cki = "CERNER!AC6aqgEDbA0M1oDfn4waeg"
 SET ckimap->ckimap[10].cki = "CERNER!AE8dDQEYUgbeg4GXCqIGfA"
 SET ckimap->ckimap[11].cki = "CERNER!ANyj7QEXgx8NqoKxCqIGfQ"
 SET ckimap->ckimap[12].cki = "CERNER!AC6aqgEDbA0M1oCfn4waeg"
 SET ckimap->ckimap[13].cki = "CERNER!2999B67B-A644-4BF5-A01A-DB973CC97AF4"
 SET ckimap->ckimap[14].cki = "CERNER!AC6aqgEDbA0M1oB/n4waeg"
 SET ckimap->ckimap[15].cki = "CERNER!AC6aqgEDbA0M1oB3n4waeg"
 SET ckimap->ckimap[16].cki = "CERNER!AC6aqgEDbA0M1oCHn4waeg"
 SET ckimap->ckimap[17].cki = "CERNER!AKUJFgEW6OV+moHMCqIGfQ"
 SET ckimap->ckimap[18].cki = "CERNER!AKUJFgEW6OV+moHwCqIGfQ"
 SET ckimap->ckimap[19].cki = "CERNER!AKUJFgEW6OV+moIUCqIGfQ"
 SET ckimap->ckimap[20].cki = "CERNER!596EC6F6-BEA7-499E-ACCF-DC064F4F651F"
 SET ckimap->ckimap[21].cki = "CERNER!AC6aqgEDbA0M1oCPn4waeg"
 SET ckimap->ckimap[22].cki = "CERNER!AC6aqgEDbA0M1oCXn4waeg"
 SET ckimap->ckimap[23].cki = "CERNER!AE8dDQEYUgbeg4GiCqIGfA"
 SET ckimap->ckimap[24].cki = "CERNER!AE2lmwD9a+OCboD/n4waeg"
 SET ckimap->ckimap[25].cki = "CERNER!AE2lmwD9a+OCboERn4waeg"
 SET ckimap->ckimap[26].cki = "CERNER!AE8dDQEYUgbeg4AWCqIGfA"
 SET ckimap->ckimap[27].cki = "CERNER!AE8dDQEYUgbeg4AhCqIGfA"
 SET ckimap->ckimap[28].cki = "CERNER!AE8dDQEYUgbeg4AsCqIGfA"
 SET ckimap->ckimap[29].cki = "CERNER!AE8dDQEYUgbeg4A3CqIGfA"
 SET ckimap->ckimap[30].cki = "CERNER!AKUJFgEW6OV+moG0CqIGfQ"
 SET ckimap->ckimap[31].cki = "CERNER!AKUJFgEW6OV+moG9CqIGfQ"
 SET ckimap->ckimap[32].cki = "CERNER!AKUJFgEW6OV+moH8CqIGfQ"
 SET ckimap->ckimap[33].cki = "CERNER!AKUJFgEW6OV+moIICqIGfQ"
 SET ckimap->ckimap[34].cki = "CERNER!AKUJFgEW6OV+moHYCqIGfQ"
 SET ckimap->ckimap[35].cki = "CERNER!AKUJFgEW6OV+moHkCqIGfQ"
 SET ckimap->ckimap[36].cki = "CERNER!34CB58DD-66CB-4FCA-9542-B2860F416A3D"
 SET ckimap->ckimap[37].cki = "CERNER!A4CC5487-D9DD-42F3-9238-618D05062508"
 SET ckimap->ckimap[38].cki = "CERNER!442ED11F-801A-45A9-8940-92AFB2657B99"
 SET ckimap->ckimap[39].cki = "CERNER!83927558-A189-4935-9247-4BADA5DDAC64"
 SET ckimap->ckimap[40].cki = "CERNER!AE8dDQEYUgbeg4FVCqIGfA"
 SET ckimap->ckimap[41].cki = "CERNER!AE8dDQEYUgbeg4FgCqIGfA"
 SET ckimap->ckimap[42].cki = "CERNER!7BADB2D4-7CBE-4CA5-B962-E67DAFD703F9"
 SET ckimap->ckimap[43].cki = "CERNER!0CC24E64-F9B4-412A-A995-5A24D25D64CD"
 SET ckimap->ckimap[44].cki = "CERNER!AC6aqgEDbA0M1oBPn4waeg"
 SET ckimap->ckimap[45].cki = "CERNER!AC6aqgEDbA0M1oEnn4waeg"
 SET ckimap->ckimap[46].cki = "CERNER!AE8dDQEX618PoYA3CqIGfA"
 SET ckimap->ckimap[47].cki = "CERNER!AC6aqgEDbA0M1oEnn4waeg"
 SET ckimap->ckimap[48].cki = "CERNER!AeXiwwEJc7Lb7JwyCqk/Mw"
 SET ckimap->ckimap[49].cki = "CERNER!AE8dDQEYUgbeg4GMCqIGfA"
 SET ckimap->ckimap[50].cki = "CERNER!B7C585F3-E731-42DC-A637-DB88D870C135"
 SET ckimap->ckimap[51].cki = "CERNER!1A8B0C32-D104-4914-8A69-D83AB76F0E64"
 SET ckimap->ckimap[52].cki = "CERNER!EE30384E-7757-41E9-8DB6-A89980F9BA4A"
 SET ckimap->ckimap[53].cki = "CERNER!231D4897-58D8-4E6E-9B6A-C83764DE3E92"
 SET ckimap->ckimap[54].cki = "CERNER!ABfQJgD4st77Y5Aqn4waeg"
 SET ckimap->ckimap[55].cki = "CERNER!ASYr9AEYvUr1YoRMCqIGfQ"
 SET ckimap->ckimap[56].cki = "CERNER!B84FEA72-3438-4B49-B5AA-6D569C00051F"
 SET ckimap->ckimap[57].cki = "CERNER!E9A8D345-C87A-4034-938A-BA2349967398"
 SET ckimap->ckimap[58].cki = "CERNER!5BC27927-6D0B-44AC-82A6-28D8E389FC15"
 SET ckimap->ckimap[59].cki = "CERNER!8BBF4EE4-A443-4E6E-B1DC-04378D885AAC"
 SET ckimap->ckimap[60].cki = "CERNER!ASYr9AEYvUr1YoB1CqIGfQ"
 SET ckimap->ckimap[61].cki = "CERNER!AEO/PQD7LLZ5Xf7zn4waeg"
 SET ckimap->ckimap[62].cki = "CERNER!DF1F749C-6B87-4AC8-91FF-718C41678BC7"
 SET ckimap->ckimap[63].cki = "CERNER!0EF1A141-1B05-462F-9127-71A77A0753C6"
 SET ckimap->ckimap[64].cki = "CERNER!105497CB-503C-4B51-AFC5-91B76F3E2717"
 SET ckimap->ckimap[65].cki = "CERNER!56036F82-951C-463F-8003-8E743DD54585"
 SET ckimap->ckimap[66].cki = "CERNER!596C042F-8E80-4F41-8833-01600869098D"
 SET ckimap->ckimap[67].cki = "CERNER!7523008C-A0B3-41FE-8FD9-9BF1E84ADD66"
 SET ckimap->ckimap[68].cki = "CERNER!8F5DA6A7-2BBF-4068-863A-B599FCCC269E"
 SET ckimap->ckimap[69].cki = "CERNER!79B2AEA1-ACA9-43EE-AD53-B70B81BDA1D2"
 SET ckimap->ckimap[70].cki = "CERNER!A38C0471-0F33-4842-AFE0-7D64BCE48AF7"
 SET ckimap->ckimap[71].cki = "CERNER!8ABC0C52-D29D-4C27-9292-94334E8A46B0"
 SET ckimap->ckimap[72].cki = "CERNER!AEO/PQD7LLZ5Xf6Dn4waeg"
 SET ckimap->ckimap[1].stnd_event_set = ""
 SET ckimap->ckimap[2].stnd_event_set = ""
 SET ckimap->ckimap[3].stnd_event_set = ""
 SET ckimap->ckimap[4].stnd_event_set = ""
 SET ckimap->ckimap[5].stnd_event_set = ""
 SET ckimap->ckimap[6].stnd_event_set = ""
 SET ckimap->ckimap[7].stnd_event_set = ""
 SET ckimap->ckimap[8].stnd_event_set = ""
 SET ckimap->ckimap[9].stnd_event_set = ""
 SET ckimap->ckimap[10].stnd_event_set = ""
 SET ckimap->ckimap[11].stnd_event_set = ""
 SET ckimap->ckimap[12].stnd_event_set = ""
 SET ckimap->ckimap[13].stnd_event_set = ""
 SET ckimap->ckimap[14].stnd_event_set = ""
 SET ckimap->ckimap[15].stnd_event_set = ""
 SET ckimap->ckimap[16].stnd_event_set = ""
 SET ckimap->ckimap[17].stnd_event_set = ""
 SET ckimap->ckimap[18].stnd_event_set = ""
 SET ckimap->ckimap[19].stnd_event_set = ""
 SET ckimap->ckimap[20].stnd_event_set = ""
 SET ckimap->ckimap[21].stnd_event_set = ""
 SET ckimap->ckimap[22].stnd_event_set = ""
 SET ckimap->ckimap[23].stnd_event_set = ""
 SET ckimap->ckimap[24].stnd_event_set = ""
 SET ckimap->ckimap[25].stnd_event_set = ""
 SET ckimap->ckimap[26].stnd_event_set = ""
 SET ckimap->ckimap[27].stnd_event_set = ""
 SET ckimap->ckimap[28].stnd_event_set = ""
 SET ckimap->ckimap[29].stnd_event_set = ""
 SET ckimap->ckimap[30].stnd_event_set = ""
 SET ckimap->ckimap[31].stnd_event_set = ""
 SET ckimap->ckimap[32].stnd_event_set = ""
 SET ckimap->ckimap[33].stnd_event_set = ""
 SET ckimap->ckimap[34].stnd_event_set = ""
 SET ckimap->ckimap[35].stnd_event_set = ""
 SET ckimap->ckimap[36].stnd_event_set = ""
 SET ckimap->ckimap[37].stnd_event_set = ""
 SET ckimap->ckimap[38].stnd_event_set = ""
 SET ckimap->ckimap[39].stnd_event_set = ""
 SET ckimap->ckimap[40].stnd_event_set = ""
 SET ckimap->ckimap[41].stnd_event_set = ""
 SET ckimap->ckimap[42].stnd_event_set = ""
 SET ckimap->ckimap[43].stnd_event_set = ""
 SET ckimap->ckimap[44].stnd_event_set = ""
 SET ckimap->ckimap[45].stnd_event_set = ""
 SET ckimap->ckimap[46].stnd_event_set = ""
 SET ckimap->ckimap[47].stnd_event_set = ""
 SET ckimap->ckimap[48].stnd_event_set = ""
 SET ckimap->ckimap[49].stnd_event_set = ""
 SET ckimap->ckimap[50].stnd_event_set = ""
 SET ckimap->ckimap[51].stnd_event_set = ""
 SET ckimap->ckimap[52].stnd_event_set = ""
 SET ckimap->ckimap[53].stnd_event_set = ""
 SET ckimap->ckimap[54].stnd_event_set = ""
 SET ckimap->ckimap[55].stnd_event_set = ""
 SET ckimap->ckimap[56].stnd_event_set = ""
 SET ckimap->ckimap[57].stnd_event_set = ""
 SET ckimap->ckimap[58].stnd_event_set = ""
 SET ckimap->ckimap[59].stnd_event_set = ""
 SET ckimap->ckimap[60].stnd_event_set = ""
 SET ckimap->ckimap[61].stnd_event_set = ""
 SET ckimap->ckimap[62].stnd_event_set = ""
 SET ckimap->ckimap[63].stnd_event_set = ""
 SET ckimap->ckimap[64].stnd_event_set = ""
 SET ckimap->ckimap[65].stnd_event_set = ""
 SET ckimap->ckimap[66].stnd_event_set = ""
 SET ckimap->ckimap[67].stnd_event_set = ""
 SET ckimap->ckimap[68].stnd_event_set = ""
 SET ckimap->ckimap[69].stnd_event_set = ""
 SET ckimap->ckimap[70].stnd_event_set = ""
 SET ckimap->ckimap[71].stnd_event_set = ""
 SET ckimap->ckimap[72].stnd_event_set = ""
 SELECT INTO "NL:"
  cv1.concept_cki, cv1.code_value, cv1.display,
  cv1.description, cv1.updt_dt_tm, pr.name_full_formatted,
  ves.event_cd, uar_get_code_display(dta.task_assay_cd), uar_get_code_description(ves.event_cd),
  uar_get_code_display(ves.event_cd)
  FROM code_value cv1,
   (left JOIN prsnl pr ON pr.person_id=cv1.updt_id),
   (left JOIN v500_event_set_explode ves ON ves.event_set_cd=cv1.code_value),
   (left JOIN discrete_task_assay dta ON dta.event_cd=ves.event_cd)
  PLAN (cv1
   WHERE cv1.code_set=93
    AND cv1.concept_cki IN ("CERNER!0BF8678F-E5DD-4342-BED7-BAC7F7C7ECA0",
   "CERNER!AC6aqgEDbA0M1oC/n4waeg", "CERNER!AC6aqgEDbA0M1oC3n4waeg", "CERNER!AC6aqgEDbA0M1oCnn4waeg",
   "CERNER!AC6aqgEDbA0M1oCvn4waeg",
   "CERNER!AC6aqgEDbA0M1oDHn4waeg", "CERNER!AC6aqgEDbA0M1oDPn4waeg", "CERNER!AC6aqgEDbA0M1oDXn4waeg",
   "CERNER!AC6aqgEDbA0M1oDfn4waeg", "CERNER!AE8dDQEYUgbeg4GXCqIGfA",
   "CERNER!ANyj7QEXgx8NqoR!2999B67", "CERNER!AC6aqgEDbA0M1oCfn4waeg",
   "CERNER!2999B67B-A644-4BF5-A01A-DB973CC97AF4", "CERNER!AC6aqgEDbA0M1oB/n4waeg",
   "CERNER!AC6aqgEDbA0M1oB3n4waeg",
   "CERNER!AC6aqgEDbA0M1oCHn4waeg", "CERNER!AKUJFgEW6OV+moHMCqIGfQ", "CERNER!AKUJFgEW6OV+moHwCqIGfQ",
   "CERNER!AKUJFgEW6OV+moIUCqIGfQ", "CERNER!596EC6F6-BEA7-499E-ACCF-DC064F4F651F",
   "CERNER!AC6aqgEDbA0M1oCPn4waeg", "CERNER!AC6aqgEDbA0M1oCXn4waeg", "CERNER!AE8dDQEYUgbeg4GiCqIGfA",
   "CERNER!AE2lmwD9a+OCboD/n4waeg", "CERNER!AE2lmwD9a+OCboERn4waeg",
   "CERNER!AE8dDQEYUgbeg4AWCqIGfA", "CERNER!AE8dDQEYUgbeg4AhCqIGfA", "CERNER!AE8dDQEYUgbeg4AsCqIGfA",
   "CERNER!AE8dDQEYUgbeg4A3CqIGfA", "CERNER!AKUJFgEW6OV+moG0CqIGfQ",
   "CERNER!AKUJFgEW6OV+moG9CqIGfQ", "CERNER!AKUJFgEW6OV+moH8CqIGfQ", "CERNER!AKUJFgEW6OV+moIICqIGfQ",
   "CERNER!AKUJFgEW6OV+moHYCqIGfQ", "CERNER!AKUJFgEW6OV+moHkCqIGfQ",
   "CERNER!34CB58DD-66CB-4FCA-9542-B2860F416A3D", "CERNER!A4CC5487-D9DD-42F3-9238-618D05062508",
   "CERNER!442ED11F-801A-45A9-8940-92AFB2657B99", "CERNER!83927558-A189-4935-9247-4BADA5DDAC64",
   "CERNER!AE8dDQEYUgbeg4FVCqIGfA",
   "CERNER!AE8dDQEYUgbeg4FgCqIGfA", "CERNER!7BADB2D4-7CBE-4CA5-B962-E67DAFD703F9",
   "CERNER!0CC24E64-F9B4-412A-A995-5A24D25D64CD", "CERNER!AC6aqgEDbA0M1oBPn4waeg",
   "CERNER!AC6aqgEDbA0M1oEnn4waeg",
   "CERNER!AE8dDQEX618PoYA3CqIGfA", "CERNER!AC6aqgEDbA0M1oEnn4waeg", "CERNER!AeXiwwEJc7Lb7JwyCqk/Mw",
   "CERNER!AE8dDQEYUgbeg4GMCqIGfA", "CERNER!B7C585F3-E731-42DC-A637-DB88D870C135",
   "CERNER!1A8B0C32-D104-4914-8A69-D83AB76F0E64", "CERNER!EE30384E-7757-41E9-8DB6-A89980F9BA4A",
   "CERNER!231D4897-58D8-4E6E-9B6A-C83764DE3E92", "CERNER!ABfQJgD4st77Y5Aqn4waeg",
   "CERNER!ASYr9AEYvUr1YoRMCqIGfQ",
   "CERNER!B84FEA72-3438-4B49-B5AA-6D569C00051F", "CERNER!E9A8D345-C87A-4034-938A-BA2349967398",
   "CERNER!5BC27927-6D0B-44AC-82A6-28D8E389FC15", "CERNER!8BBF4EE4-A443-4E6E-B1DC-04378D885AAC",
   "CERNER!ASYr9AEYvUr1YoB1CqIGfQ",
   "CERNER!AEO/PQD7LLZ5Xf7zn4waeg", "CERNER!DF1F749C-6B87-4AC8-91FF-718C41678BC7",
   "CERNER!0EF1A141-1B05-462F-9127-71A77A0753C6", "CERNER!105497CB-503C-4B51-AFC5-91B76F3E2717",
   "CERNER!56036F82-951C-463F-8003-8E743DD54585",
   "CERNER!596C042F-8E80-4F41-8833-01600869098D", "CERNER!7523008C-A0B3-41FE-8FD9-9BF1E84ADD66",
   "CERNER!8F5DA6A7-2BBF-4068-863A-B599FCCC269E", "CERNER!79B2AEA1-ACA9-43EE-AD53-B70B81BDA1D2",
   "CERNER!A38C0471-0F33-4842-AFE0-7D64BCE48AF7",
   "CERNER!8ABC0C52-D29D-4C27-9292-94334E8A46B0", "CERNER!AEO/PQD7LLZ5Xf6Dn4waeg"))
   JOIN (pr)
   JOIN (ves)
   JOIN (dta)
  ORDER BY cv1.concept_cki
  HEAD REPORT
   FOR (num = 1 TO 72)
     ckimap->ckimap[num].mill_cnt = 0
   ENDFOR
  DETAIL
   FOR (num = 1 TO 72)
     IF ((ckimap->ckimap[num].cki=cv1.concept_cki))
      ckimap->ckimap[num].mill_cnt += 1, stat = alterlist(ckimap->ckimap[num].mill,ckimap->ckimap[num
       ].mill_cnt), ckimap->ckimap[num].mill[ckimap->ckimap[num].mill_cnt].code_val = cv1.code_value,
      ckimap->ckimap[num].mill[ckimap->ckimap[num].mill_cnt].description = cv1.description, ckimap->
      ckimap[num].mill[ckimap->ckimap[num].mill_cnt].display = cv1.display, ckimap->ckimap[num].mill[
      ckimap->ckimap[num].mill_cnt].updated_by = pr.name_full_formatted,
      ckimap->ckimap[num].mill[ckimap->ckimap[num].mill_cnt].updated_on = cv1.updt_dt_tm, ckimap->
      ckimap[num].mill[ckimap->ckimap[num].mill_cnt].event_cd = ves.event_cd, ckimap->ckimap[num].
      mill[ckimap->ckimap[num].mill_cnt].dta_mnemonic = dta.task_assay_cd,
      ckimap->ckimap[num].mill[ckimap->ckimap[num].mill_cnt].event_cd_disp = uar_get_code_description
      (ves.event_cd), ckimap->ckimap[num].mill[ckimap->ckimap[num].mill_cnt].event_cd_desc =
      uar_get_code_display(ves.event_cd)
     ENDIF
   ENDFOR
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO  $OUTDEV
  cki = substring(1,70,ckimap->ckimap[d1.seq].cki), bin_folder = substring(1,40,ckimap->ckimap[d1.seq
   ].bin_desc), cn_nursing_section = substring(1,30,ckimap->ckimap[d1.seq].gadget),
  bin_file_name = substring(1,70,ckimap->ckimap[d1.seq].gadget_label), mapped_to_how_many = ckimap->
  ckimap[d1.seq].mill_cnt, mapped_to_dta = uar_get_code_display(ckimap->ckimap[d1.seq].mill[d2.seq].
   dta_mnemonic),
  mapped_to_event_set_display = substring(1,70,ckimap->ckimap[d1.seq].mill[d2.seq].display),
  mapped_to_event_set_description = substring(1,70,ckimap->ckimap[d1.seq].mill[d2.seq].description),
  mapped_to_event_set_cv = ckimap->ckimap[d1.seq].mill[d2.seq].code_val,
  last_updated_by = ckimap->ckimap[d1.seq].mill[d2.seq].updated_by, last_updated_on = format(ckimap->
   ckimap[d1.seq].mill[d2.seq].updated_on,"mm/dd/yyyy hh:mm;;Q"), mapped_to_dta = ckimap->ckimap[d1
  .seq].mill[d2.seq].dta_mnemonic,
  mapped_to_event_cd_disp = substring(1,70,ckimap->ckimap[d1.seq].mill[d2.seq].event_cd_disp),
  mapped_to_event_cd_desc = substring(1,70,ckimap->ckimap[d1.seq].mill[d2.seq].event_cd_desc)
  FROM (dummyt d1  WITH seq = value(size(ckimap->ckimap,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d1,size(ckimap->ckimap[d1.seq].mill,5))
    AND maxrec(d2,size(ckimap->ckimap[d1.seq].mill,5)))
   JOIN (d2)
  ORDER BY substring(1,30,ckimap->ckimap[d1.seq].gadget), substring(1,70,ckimap->ckimap[d1.seq].
    gadget_label), substring(1,70,ckimap->ckimap[d1.seq].mill[d2.seq].display),
   substring(1,70,ckimap->ckimap[d1.seq].mill[d2.seq].description), ckimap->ckimap[d1.seq].mill[d2
   .seq].code_val, cnvtupper(uar_get_code_display(ckimap->ckimap[d1.seq].mill[d2.seq].dta_mnemonic))
  WITH nocounter, separator = " ", format,
   outerjoin = d1, outerjoin = d2
 ;end select
END GO
