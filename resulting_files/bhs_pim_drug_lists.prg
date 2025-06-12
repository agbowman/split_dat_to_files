CREATE PROGRAM bhs_pim_drug_lists
 FREE RECORD pim_drugs
 RECORD pim_drugs(
   1 drug_class_cnt = i4
   1 drug_classes[*]
     2 drug_class = vc
     2 message_text = vc
     2 dose_info_ind = i2
     2 drug_cnt = i4
     2 drugs[*]
       3 catalog_cd = f8
       3 displaykey = vc
       3 display = vc
       3 dose_info = vc
     2 rcmd_cnt = i4
     2 rcmd_drugs[*]
       3 catalog_cd = f8
       3 displaykey = vc
       3 display = vc
 ) WITH persist
 SET pim_drugs->drug_class_cnt = 19
 SET stat = alterlist(pim_drugs->drug_classes,pim_drugs->drug_class_cnt)
 SET pim_drugs->drug_classes[1].drug_class = "Indomethacin"
 SET pim_drugs->drug_classes[1].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible due to risk of renal failure, GI bleeding and ",
  "delirium.  You may wish to consider the following alternative medication choices:",
  "@NEWLINE If prescribing for:",fillstring(4,char(9)),
  "Consider:","@NEWLINE Gout",fillstring(6,char(9)),"Low dose prednisone","@NEWLINE Pain",
  fillstring(6,char(9)),"Acetaminophen or low dose opiate","@NEWLINE Inflammation",fillstring(4,char(
    9)),"Salsalate with or without Nexium")
 SET pim_drugs->drug_classes[1].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[1].drugs,pim_drugs->drug_classes[1].drug_cnt)
 SET pim_drugs->drug_classes[1].drugs[1].displaykey = "INDOMETHACIN"
 SET pim_drugs->drug_classes[1].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"INDOMETHACIN"
  )
 SET pim_drugs->drug_classes[1].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[1].rcmd_drugs,pim_drugs->drug_classes[1].rcmd_cnt)
 SET pim_drugs->drug_classes[1].rcmd_drugs[1].displaykey = "PREDNISONE"
 SET pim_drugs->drug_classes[1].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PREDNISONE")
 SET pim_drugs->drug_classes[1].rcmd_drugs[2].displaykey = "ACETAMINOPHEN"
 SET pim_drugs->drug_classes[1].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ACETAMINOPHEN")
 SET pim_drugs->drug_classes[1].rcmd_drugs[3].displaykey = "SALSALATE"
 SET pim_drugs->drug_classes[1].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "SALSALATE")
 SET pim_drugs->drug_classes[2].drug_class = "Muscle relaxants"
 SET pim_drugs->drug_classes[2].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided due to high risk for delirium.  Consider mechanical ",
  "interventions such as heating pads or stretching exercises.")
 SET pim_drugs->drug_classes[2].drug_cnt = 6
 SET stat = alterlist(pim_drugs->drug_classes[2].drugs,pim_drugs->drug_classes[2].drug_cnt)
 SET pim_drugs->drug_classes[2].drugs[1].displaykey = "CARISOPRODOL"
 SET pim_drugs->drug_classes[2].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"CARISOPRODOL"
  )
 SET pim_drugs->drug_classes[2].drugs[2].displaykey = "CHLORZOXAZONE"
 SET pim_drugs->drug_classes[2].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CHLORZOXAZONE")
 SET pim_drugs->drug_classes[2].drugs[3].displaykey = "CYCLOBENZAPRINE"
 SET pim_drugs->drug_classes[2].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CYCLOBENZAPRINE")
 SET pim_drugs->drug_classes[2].drugs[4].displaykey = "METAXALONE"
 SET pim_drugs->drug_classes[2].drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"METAXALONE")
 SET pim_drugs->drug_classes[2].drugs[5].displaykey = "METHOCARBAMOL"
 SET pim_drugs->drug_classes[2].drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "METHOCARBAMOL")
 SET pim_drugs->drug_classes[2].drugs[6].displaykey = "ORPHENADRINE"
 SET pim_drugs->drug_classes[2].drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"ORPHENADRINE"
  )
 SET pim_drugs->drug_classes[3].drug_class = "Antispasmodics"
 SET pim_drugs->drug_classes[3].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible, due to anticholinergic effects, orthostatic ",
  "hypotension and delirium.")
 SET pim_drugs->drug_classes[3].drug_cnt = 5
 SET stat = alterlist(pim_drugs->drug_classes[3].drugs,pim_drugs->drug_classes[3].drug_cnt)
 SET pim_drugs->drug_classes[3].drugs[1].displaykey = "DICYCLOMINE"
 SET pim_drugs->drug_classes[3].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"DICYCLOMINE")
 SET pim_drugs->drug_classes[3].drugs[2].displaykey = "PROPANTHELINE"
 SET pim_drugs->drug_classes[3].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PROPANTHELINE")
 SET pim_drugs->drug_classes[3].drugs[3].displaykey = "ATROPINEHYOSCYAMINEPBSCOPOLAMINE"
 SET pim_drugs->drug_classes[3].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ATROPINEHYOSCYAMINEPBSCOPOLAMINE")
 SET pim_drugs->drug_classes[3].drugs[4].displaykey = "CHLORDIAZEPOXIDECLIDINIUM"
 SET pim_drugs->drug_classes[3].drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CHLORDIAZEPOXIDECLIDINIUM")
 SET pim_drugs->drug_classes[3].drugs[5].displaykey = "HYOSCYAMINE"
 SET pim_drugs->drug_classes[3].drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"HYOSCYAMINE")
 SET pim_drugs->drug_classes[4].drug_class = "Amitriptyline"
 SET pim_drugs->drug_classes[4].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible, due to risk for delirium or urinary retention.  ",
  "You may wish to consider the following alternative medication choices:",
  "@NEWLINE If prescribing for:",fillstring(4,char(9)),
  "Consider:","@NEWLINE Neuropathic pain",fillstring(4,char(9)),
  "Gabapentin, valproic acid or carbamazepine","@NEWLINE Insomnia",
  fillstring(5,char(9)),"Trazodone","@NEWLINE Depression",fillstring(4,char(9)),
  "Sertraline or Mirtazapine")
 SET pim_drugs->drug_classes[4].drug_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[4].drugs,pim_drugs->drug_classes[4].drug_cnt)
 SET pim_drugs->drug_classes[4].drugs[1].displaykey = "AMITRIPTYLINE"
 SET pim_drugs->drug_classes[4].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "AMITRIPTYLINE")
 SET pim_drugs->drug_classes[4].drugs[2].displaykey = "AMITRIPTYLINECHLORDIAZEPOXIDE"
 SET pim_drugs->drug_classes[4].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "AMITRIPTYLINECHLORDIAZEPOXIDE")
 SET pim_drugs->drug_classes[4].drugs[3].displaykey = "DOXEPIN"
 SET pim_drugs->drug_classes[4].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"DOXEPIN")
 SET pim_drugs->drug_classes[4].rcmd_cnt = 6
 SET stat = alterlist(pim_drugs->drug_classes[4].rcmd_drugs,pim_drugs->drug_classes[4].rcmd_cnt)
 SET pim_drugs->drug_classes[4].rcmd_drugs[1].displaykey = "GABAPENTIN"
 SET pim_drugs->drug_classes[4].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "GABAPENTIN")
 SET pim_drugs->drug_classes[4].rcmd_drugs[2].displaykey = "VALPROICACID"
 SET pim_drugs->drug_classes[4].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "VALPROICACID")
 SET pim_drugs->drug_classes[4].rcmd_drugs[3].displaykey = "CARBAMAZEPINE"
 SET pim_drugs->drug_classes[4].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CARBAMAZEPINE")
 SET pim_drugs->drug_classes[4].rcmd_drugs[4].displaykey = "SERTRALINE"
 SET pim_drugs->drug_classes[4].rcmd_drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "SERTRALINE")
 SET pim_drugs->drug_classes[4].rcmd_drugs[5].displaykey = "TRAZODONE"
 SET pim_drugs->drug_classes[4].rcmd_drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "TRAZODONE")
 SET pim_drugs->drug_classes[4].rcmd_drugs[6].displaykey = "MIRTAZAPINE"
 SET pim_drugs->drug_classes[4].rcmd_drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "MIRTAZAPINE")
 SET pim_drugs->drug_classes[5].drug_class = "Long-acting benzodiazepines"
 SET pim_drugs->drug_classes[5].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible due to its long half-life.  Benzodiazepines should ",
  "not be stopped abruptly.  If a benzodiazepine is absolutely required (e.g. alcohol ",
  "withdrawal, benzodiazepine withdrawal, or acute panic attacks), consider using ",
  "lorazepam instead.  For other indications, consider the following substitutions:",
  "@NEWLINE If prescribing for:",fillstring(6,char(9)),"Consider:","@NEWLINE Anxiety",fillstring(7,
   char(9)),
  "Sertraline or Trazodone","@NEWLINE Depression",fillstring(6,char(9)),"Sertraline or Mirtazapine",
  "@NEWLINE Agitation, if pt is threat to self or others",
  fillstring(2,char(9)),"Quetiapine")
 SET pim_drugs->drug_classes[5].drug_cnt = 8
 SET stat = alterlist(pim_drugs->drug_classes[5].drugs,pim_drugs->drug_classes[5].drug_cnt)
 SET pim_drugs->drug_classes[5].drugs[1].displaykey = "CHLORDIAZEPOXIDE"
 SET pim_drugs->drug_classes[5].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CHLORDIAZEPOXIDE")
 SET pim_drugs->drug_classes[5].drugs[2].displaykey = "DIAZEPAM"
 SET pim_drugs->drug_classes[5].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"DIAZEPAM")
 SET pim_drugs->drug_classes[5].drugs[3].displaykey = "QUAZEPAM"
 SET pim_drugs->drug_classes[5].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"QUAZEPAM")
 SET pim_drugs->drug_classes[5].drugs[4].displaykey = "CLORAZEPATE"
 SET pim_drugs->drug_classes[5].drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"CLORAZEPATE")
 SET pim_drugs->drug_classes[5].drugs[5].displaykey = "CHLORDIAZEPOXIDECLIDINIUM"
 SET pim_drugs->drug_classes[5].drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CHLORDIAZEPOXIDECLIDINIUM")
 SET pim_drugs->drug_classes[5].drugs[6].displaykey = "AMITRIPTYLINECHLORDIAZEPOXIDE"
 SET pim_drugs->drug_classes[5].drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "AMITRIPTYLINECHLORDIAZEPOXIDE")
 SET pim_drugs->drug_classes[5].drugs[7].displaykey = "CLONAZEPAM"
 SET pim_drugs->drug_classes[5].drugs[7].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"CLONAZEPAM")
 SET pim_drugs->drug_classes[5].drugs[8].displaykey = "FLURAZEPAM"
 SET pim_drugs->drug_classes[5].drugs[8].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"FLURAZEPAM")
 SET pim_drugs->drug_classes[5].rcmd_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[5].rcmd_drugs,pim_drugs->drug_classes[5].rcmd_cnt)
 SET pim_drugs->drug_classes[5].rcmd_drugs[1].displaykey = "SERTRALINE"
 SET pim_drugs->drug_classes[5].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "SERTRALINE")
 SET pim_drugs->drug_classes[5].rcmd_drugs[2].displaykey = "QUETIAPINE"
 SET pim_drugs->drug_classes[5].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "QUETIAPINE")
 SET pim_drugs->drug_classes[5].rcmd_drugs[3].displaykey = "TRAZODONE"
 SET pim_drugs->drug_classes[5].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "TRAZODONE")
 SET pim_drugs->drug_classes[5].rcmd_drugs[4].displaykey = "MIRTAZAPINE"
 SET pim_drugs->drug_classes[5].rcmd_drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "MIRTAZAPINE")
 SET pim_drugs->drug_classes[6].drug_class = "Short-acting benzodiazepines"
 SET pim_drugs->drug_classes[6].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible.  Benzodiazepines should ",
  "not be stopped abruptly.  If a benzodiazepine is absolutely required (e.g. alcohol ",
  "withdrawal, benzodiazepine withdrawal, or acute panic attacks), a short-acting benzodiazepine ",
  "as you have ordered may be appropriate. For other indications, consider the following substitutions:",
  "@NEWLINE If prescribing for:",fillstring(6,char(9)),"Consider:","@NEWLINE Anxiety",fillstring(7,
   char(9)),
  "Sertraline or Trazodone","@NEWLINE Depression",fillstring(6,char(9)),"Sertraline or Mirtazapine",
  "@NEWLINE Agitation, if pt is threat to self or others",
  fillstring(2,char(9)),"Quetiapine")
 SET pim_drugs->drug_classes[6].drug_cnt = 15
 SET stat = alterlist(pim_drugs->drug_classes[6].drugs,pim_drugs->drug_classes[6].drug_cnt)
 SET pim_drugs->drug_classes[6].drugs[1].displaykey = "LORAZEPAM"
 SET pim_drugs->drug_classes[6].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"LORAZEPAM")
 SET pim_drugs->drug_classes[6].drugs[2].displaykey = "OXAZEPAM"
 SET pim_drugs->drug_classes[6].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"OXAZEPAM")
 SET pim_drugs->drug_classes[6].drugs[3].displaykey = "ALPRAZOLAM"
 SET pim_drugs->drug_classes[6].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"ALPRAZOLAM")
 SET pim_drugs->drug_classes[6].drugs[4].displaykey = "TEMAZEPAM"
 SET pim_drugs->drug_classes[6].drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"TEMAZEPAM")
 SET pim_drugs->drug_classes[6].drugs[5].displaykey = "TRIAZOLAM"
 SET pim_drugs->drug_classes[6].drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"TRIAZOLAM")
 SET pim_drugs->drug_classes[6].drugs[6].displaykey = "ESTAZOLAM"
 SET pim_drugs->drug_classes[6].drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"ESTAZOLAM")
 SET pim_drugs->drug_classes[6].drugs[7].displaykey = "LORAZEPAM100MGIND5W1000ML"
 SET pim_drugs->drug_classes[6].drugs[7].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM100MGIND5W1000ML")
 SET pim_drugs->drug_classes[6].drugs[8].displaykey = "LORAZEPAM100MGINNACL091000ML"
 SET pim_drugs->drug_classes[6].drugs[8].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM100MGINNACL091000ML")
 SET pim_drugs->drug_classes[6].drugs[9].displaykey = "LORAZEPAM100MGINNACL09100MLPEDI"
 SET pim_drugs->drug_classes[6].drugs[9].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM100MGINNACL09100MLPEDI")
 SET pim_drugs->drug_classes[6].drugs[10].displaykey = "LORAZEPAM25MGIND5W250ML"
 SET pim_drugs->drug_classes[6].drugs[10].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM25MGIND5W250ML")
 SET pim_drugs->drug_classes[6].drugs[11].displaykey = "LORAZEPAM25MGINNACL09250ML"
 SET pim_drugs->drug_classes[6].drugs[11].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM25MGINNACL09250ML")
 SET pim_drugs->drug_classes[6].drugs[12].displaykey = "LORAZEPAM2MGINNACL0920MLPEDIST"
 SET pim_drugs->drug_classes[6].drugs[12].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM2MGINNACL0920MLPEDIST")
 SET pim_drugs->drug_classes[6].drugs[13].displaykey = "LORAZEPAM50MGIND5W500ML"
 SET pim_drugs->drug_classes[6].drugs[13].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM50MGIND5W500ML")
 SET pim_drugs->drug_classes[6].drugs[14].displaykey = "LORAZEPAM50MGINNACL09500ML"
 SET pim_drugs->drug_classes[6].drugs[14].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM50MGINNACL09500ML")
 SET pim_drugs->drug_classes[6].drugs[15].displaykey = "LORAZEPAM50MGINNACL0950MLPEDIS"
 SET pim_drugs->drug_classes[6].drugs[15].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORAZEPAM50MGINNACL0950MLPEDIS")
 SET pim_drugs->drug_classes[6].rcmd_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[6].rcmd_drugs,pim_drugs->drug_classes[6].rcmd_cnt)
 SET pim_drugs->drug_classes[6].rcmd_drugs[1].displaykey = "SERTRALINE"
 SET pim_drugs->drug_classes[6].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "SERTRALINE")
 SET pim_drugs->drug_classes[6].rcmd_drugs[2].displaykey = "QUETIAPINE"
 SET pim_drugs->drug_classes[6].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "QUETIAPINE")
 SET pim_drugs->drug_classes[6].rcmd_drugs[3].displaykey = "TRAZODONE"
 SET pim_drugs->drug_classes[6].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "TRAZODONE")
 SET pim_drugs->drug_classes[6].rcmd_drugs[4].displaykey = "MIRTAZAPINE"
 SET pim_drugs->drug_classes[6].rcmd_drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "MIRTAZAPINE")
 SET pim_drugs->drug_classes[7].drug_class = "Promethazine"
 SET pim_drugs->drug_classes[7].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible due to anticholinergic effects and risk of ",
  "delirium.  You may wish to consider the etiology of nausea and prescribe accordingly.",
  "@NEWLINE If prescribing for:",fillstring(4,char(9)),
  "Consider:","@NEWLINE Gastric irritation",fillstring(4,char(9)),"High dose Nexium",
  "@NEWLINE Bowel obstruction",
  fillstring(3,char(9)),"Octreotide and Dexamethasone","@NEWLINE Other Causes",fillstring(4,char(9)),
  "Ondansetron")
 SET pim_drugs->drug_classes[7].drug_cnt = 2
 SET stat = alterlist(pim_drugs->drug_classes[7].drugs,pim_drugs->drug_classes[7].drug_cnt)
 SET pim_drugs->drug_classes[7].drugs[1].displaykey = "PROMETHAZINE"
 SET pim_drugs->drug_classes[7].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"PROMETHAZINE"
  )
 SET pim_drugs->drug_classes[7].drugs[2].displaykey = "PROMETHAZINE125MGCODEINE2MGML"
 SET pim_drugs->drug_classes[7].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"PROMETHAZINE"
  )
 SET pim_drugs->drug_classes[7].rcmd_cnt = 5
 SET stat = alterlist(pim_drugs->drug_classes[7].rcmd_drugs,pim_drugs->drug_classes[7].rcmd_cnt)
 SET pim_drugs->drug_classes[7].rcmd_drugs[1].displaykey = "ESOMEPRAZOLE"
 SET pim_drugs->drug_classes[7].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ESOMEPRAZOLE")
 SET pim_drugs->drug_classes[7].rcmd_drugs[2].displaykey = "OCTREOTIDE"
 SET pim_drugs->drug_classes[7].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "OCTREOTIDE")
 SET pim_drugs->drug_classes[7].rcmd_drugs[3].displaykey = "DEXAMETHASONE"
 SET pim_drugs->drug_classes[7].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "DEXAMETHASONE")
 SET pim_drugs->drug_classes[7].rcmd_drugs[4].displaykey = "ONDANSETRON"
 SET pim_drugs->drug_classes[7].rcmd_drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ONDANSETRON")
 SET pim_drugs->drug_classes[7].rcmd_drugs[5].displaykey = "ONDANSETRONIVPB"
 SET pim_drugs->drug_classes[7].rcmd_drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ONDANSETRONIVPB")
 SET pim_drugs->drug_classes[8].drug_class = "Barbiturates"
 SET pim_drugs->drug_classes[8].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible, unless being used for seizure control.  For other ",
  "indications, consider the following substitutions:","@NEWLINE If prescribing for:",fillstring(4,
   char(9)),
  "Consider:","@NEWLINE Anxiety",fillstring(5,char(9)),"Buspirone or Sertraline",
  "@NEWLINE Depression",
  fillstring(4,char(9)),"SSRI or Mirtazapine","@NEWLINE Migraine",fillstring(5,char(9)),"Oxycodone")
 SET pim_drugs->drug_classes[8].drug_cnt = 14
 SET stat = alterlist(pim_drugs->drug_classes[8].drugs,pim_drugs->drug_classes[8].drug_cnt)
 SET pim_drugs->drug_classes[8].drugs[1].displaykey = "PHENOBARBITAL"
 SET pim_drugs->drug_classes[8].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PHENOBARBITAL")
 SET pim_drugs->drug_classes[8].drugs[2].displaykey = "BUTABARBITAL"
 SET pim_drugs->drug_classes[8].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"BUTABARBITAL"
  )
 SET pim_drugs->drug_classes[8].drugs[3].displaykey = "AMOBARBITAL"
 SET pim_drugs->drug_classes[8].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"AMOBARBITAL")
 SET pim_drugs->drug_classes[8].drugs[4].displaykey = "BUTALBITAL"
 SET pim_drugs->drug_classes[8].drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"BUTALBITAL")
 SET pim_drugs->drug_classes[8].drugs[5].displaykey = "PENTOBARBITAL"
 SET pim_drugs->drug_classes[8].drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PENTOBARBITAL")
 SET pim_drugs->drug_classes[8].drugs[6].displaykey = "SECOBARBITAL"
 SET pim_drugs->drug_classes[8].drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"SECOBARBITAL"
  )
 SET pim_drugs->drug_classes[8].drugs[7].displaykey = "MEPHOBARBITAL"
 SET pim_drugs->drug_classes[8].drugs[7].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "MEPHOBARBITAL")
 SET pim_drugs->drug_classes[8].drugs[8].displaykey = "PENTOBARBITAL2500MGIN50ML"
 SET pim_drugs->drug_classes[8].drugs[8].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PENTOBARBITAL2500MGIN50ML")
 SET pim_drugs->drug_classes[8].drugs[9].displaykey = "PENTOBARBITAL2500MGIN50MLPEDISTAN"
 SET pim_drugs->drug_classes[8].drugs[9].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PENTOBARBITAL2500MGIN50MLPEDISTAN")
 SET pim_drugs->drug_classes[8].drugs[10].displaykey = "PENTOBARBITAL5000MGIN100ML"
 SET pim_drugs->drug_classes[8].drugs[10].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PENTOBARBITAL5000MGIN100ML")
 SET pim_drugs->drug_classes[8].drugs[11].displaykey = "PENTOBARBITAL5000MGIN100MLPEDISTA"
 SET pim_drugs->drug_classes[8].drugs[11].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PENTOBARBITAL5000MGIN100MLPEDISTA")
 SET pim_drugs->drug_classes[8].drugs[12].displaykey = "PENTOBARBITAL800MGINNACL09100ML"
 SET pim_drugs->drug_classes[8].drugs[12].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PENTOBARBITAL800MGINNACL09100ML")
 SET pim_drugs->drug_classes[8].drugs[13].displaykey = "PENTOBARBITALMGIND5WML"
 SET pim_drugs->drug_classes[8].drugs[13].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PENTOBARBITALMGIND5WML")
 SET pim_drugs->drug_classes[8].drugs[14].displaykey = "PENTOBARBITALMGINNACL09ML"
 SET pim_drugs->drug_classes[8].drugs[14].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PENTOBARBITALMGINNACL09ML")
 SET pim_drugs->drug_classes[8].rcmd_cnt = 8
 SET stat = alterlist(pim_drugs->drug_classes[8].rcmd_drugs,pim_drugs->drug_classes[8].rcmd_cnt)
 SET pim_drugs->drug_classes[8].rcmd_drugs[1].displaykey = "BUSPIRONE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "BUSPIRONE")
 SET pim_drugs->drug_classes[8].rcmd_drugs[2].displaykey = "SERTRALINE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "SERTRALINE")
 SET pim_drugs->drug_classes[8].rcmd_drugs[3].displaykey = "CITALOPRAM"
 SET pim_drugs->drug_classes[8].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CITALOPRAM")
 SET pim_drugs->drug_classes[8].rcmd_drugs[4].displaykey = "ESCITALOPRAM"
 SET pim_drugs->drug_classes[8].rcmd_drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ESCITALOPRAM")
 SET pim_drugs->drug_classes[8].rcmd_drugs[5].displaykey = "FLUOXETINE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "FLUOXETINE")
 SET pim_drugs->drug_classes[8].rcmd_drugs[6].displaykey = "FLUVOXAMINE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "FLUVOXAMINE")
 SET pim_drugs->drug_classes[8].rcmd_drugs[7].displaykey = "PAROXETINE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[7].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PAROXETINE")
 SET pim_drugs->drug_classes[8].rcmd_drugs[8].displaykey = "OXYCODONE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[8].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "OXYCODONE")
 SET pim_drugs->drug_classes[9].drug_class = "Meperidine"
 SET pim_drugs->drug_classes[9].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should not be used.  Acceptable alternatives include morphine, hydromorphone and ",
  "oxycodone.")
 SET pim_drugs->drug_classes[9].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[9].drugs,pim_drugs->drug_classes[9].drug_cnt)
 SET pim_drugs->drug_classes[9].drugs[1].displaykey = "MEPERIDINE"
 SET pim_drugs->drug_classes[9].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"MEPERIDINE")
 SET pim_drugs->drug_classes[9].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[9].rcmd_drugs,pim_drugs->drug_classes[9].rcmd_cnt)
 SET pim_drugs->drug_classes[9].rcmd_drugs[1].displaykey = "MORPHINE"
 SET pim_drugs->drug_classes[9].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "MORPHINE")
 SET pim_drugs->drug_classes[9].rcmd_drugs[2].displaykey = "HYDROMORPHONE"
 SET pim_drugs->drug_classes[9].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "HYDROMORPHONE")
 SET pim_drugs->drug_classes[9].rcmd_drugs[3].displaykey = "OXYCODONE"
 SET pim_drugs->drug_classes[9].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "OXYCODONE")
 SET pim_drugs->drug_classes[10].drug_class = "Ketoralac"
 SET pim_drugs->drug_classes[10].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible.  Consider treatment with an opiate (morphine, ",
  "hydromorphone or oxycodone) instead.")
 SET pim_drugs->drug_classes[10].drug_cnt = 2
 SET stat = alterlist(pim_drugs->drug_classes[10].drugs,pim_drugs->drug_classes[10].drug_cnt)
 SET pim_drugs->drug_classes[10].drugs[1].displaykey = "KETOROLAC"
 SET pim_drugs->drug_classes[10].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"KETOROLAC")
 SET pim_drugs->drug_classes[10].drugs[2].displaykey = "KETOROLACOPHTHALMIC"
 SET pim_drugs->drug_classes[10].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "KETOROLACOPHTHALMIC")
 SET pim_drugs->drug_classes[10].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[10].rcmd_drugs,pim_drugs->drug_classes[10].rcmd_cnt)
 SET pim_drugs->drug_classes[10].rcmd_drugs[1].displaykey = "MORPHINE"
 SET pim_drugs->drug_classes[10].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "MORPHINE")
 SET pim_drugs->drug_classes[10].rcmd_drugs[2].displaykey = "HYDROMORPHONE"
 SET pim_drugs->drug_classes[10].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "HYDROMORPHONE")
 SET pim_drugs->drug_classes[10].rcmd_drugs[3].displaykey = "OXYCODONE"
 SET pim_drugs->drug_classes[10].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "OXYCODONE")
 SET pim_drugs->drug_classes[11].drug_class = "NSAID"
 SET pim_drugs->drug_classes[11].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "increasing the risk for renal failure, gastrointestinal bleeding and delirium, and ",
  "therefore should be avoided if possible.  You may wish to consider the following ",
  "alternative medication choices:","@NEWLINE If prescribing for:",
  fillstring(4,char(9)),"Consider:","@NEWLINE Pain",fillstring(6,char(9)),
  "Acetaminophen or low dose opiate",
  "@NEWLINE Inflammation",fillstring(4,char(9)),"Salsalate with or without Nexium","@NEWLINE Gout",
  fillstring(6,char(9)),
  "Low dose prednisone")
 SET pim_drugs->drug_classes[11].drug_cnt = 21
 SET stat = alterlist(pim_drugs->drug_classes[11].drugs,pim_drugs->drug_classes[11].drug_cnt)
 SET pim_drugs->drug_classes[11].drugs[1].displaykey = "IBUPROFEN"
 SET pim_drugs->drug_classes[11].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"IBUPROFEN")
 SET pim_drugs->drug_classes[11].drugs[2].displaykey = "NAPROXEN"
 SET pim_drugs->drug_classes[11].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"NAPROXEN")
 SET pim_drugs->drug_classes[11].drugs[3].displaykey = "OXAPROZIN"
 SET pim_drugs->drug_classes[11].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"OXAPROZIN")
 SET pim_drugs->drug_classes[11].drugs[4].displaykey = "PIROXICAM"
 SET pim_drugs->drug_classes[11].drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"PIROXICAM")
 SET pim_drugs->drug_classes[11].drugs[5].displaykey = "NABUMETONE"
 SET pim_drugs->drug_classes[11].drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"NABUMETONE")
 SET pim_drugs->drug_classes[11].drugs[6].displaykey = "DICLOFENAC"
 SET pim_drugs->drug_classes[11].drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"DICLOFENAC")
 SET pim_drugs->drug_classes[11].drugs[7].displaykey = "DIFLUNISAL"
 SET pim_drugs->drug_classes[11].drugs[7].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"DIFLUNISAL")
 SET pim_drugs->drug_classes[11].drugs[8].displaykey = "ETODOLAC"
 SET pim_drugs->drug_classes[11].drugs[8].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"ETODOLAC")
 SET pim_drugs->drug_classes[11].drugs[9].displaykey = "KETOPROFEN"
 SET pim_drugs->drug_classes[11].drugs[9].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"KETOPROFEN")
 SET pim_drugs->drug_classes[11].drugs[10].displaykey = "MECLOFENAMATE"
 SET pim_drugs->drug_classes[11].drugs[10].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "MECLOFENAMATE")
 SET pim_drugs->drug_classes[11].drugs[11].displaykey = "MEFENAMICACID"
 SET pim_drugs->drug_classes[11].drugs[11].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "MEFENAMICACID")
 SET pim_drugs->drug_classes[11].drugs[12].displaykey = "MELOXICAM"
 SET pim_drugs->drug_classes[11].drugs[12].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"MELOXICAM")
 SET pim_drugs->drug_classes[11].drugs[13].displaykey = "SULINDAC"
 SET pim_drugs->drug_classes[11].drugs[13].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"SULINDAC")
 SET pim_drugs->drug_classes[11].drugs[14].displaykey = "TOLMETIN"
 SET pim_drugs->drug_classes[11].drugs[14].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"TOLMETIN")
 SET pim_drugs->drug_classes[11].drugs[15].displaykey = "FENOPROFEN"
 SET pim_drugs->drug_classes[11].drugs[15].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"FENOPROFEN"
  )
 SET pim_drugs->drug_classes[11].drugs[16].displaykey = "IBUPROFEN200MG10MLSUSPUD"
 SET pim_drugs->drug_classes[11].drugs[16].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "IBUPROFEN200MG10MLSUSPUD")
 SET pim_drugs->drug_classes[11].drugs[17].displaykey = "IBUPROFENOXYCODONE"
 SET pim_drugs->drug_classes[11].drugs[17].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "IBUPROFENOXYCODONE")
 SET pim_drugs->drug_classes[11].drugs[18].displaykey = "IBUPROFENPSEUDOEPHEDRINE"
 SET pim_drugs->drug_classes[11].drugs[18].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "IBUPROFENPSEUDOEPHEDRINE")
 SET pim_drugs->drug_classes[11].drugs[19].displaykey = "DICLOFENACMISOPROSTOL"
 SET pim_drugs->drug_classes[11].drugs[19].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "DICLOFENACMISOPROSTOL")
 SET pim_drugs->drug_classes[11].drugs[20].displaykey = "DICLOFENACOPHTHALMIC"
 SET pim_drugs->drug_classes[11].drugs[20].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "DICLOFENACOPHTHALMIC")
 SET pim_drugs->drug_classes[11].drugs[21].displaykey = "DICLOFENACTOPICAL"
 SET pim_drugs->drug_classes[11].drugs[21].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "DICLOFENACTOPICAL")
 SET pim_drugs->drug_classes[11].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[11].rcmd_drugs,pim_drugs->drug_classes[11].rcmd_cnt)
 SET pim_drugs->drug_classes[11].rcmd_drugs[1].displaykey = "ACETAMINOPHEN"
 SET pim_drugs->drug_classes[11].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ACETAMINOPHEN")
 SET pim_drugs->drug_classes[11].rcmd_drugs[2].displaykey = "SALSALATE"
 SET pim_drugs->drug_classes[11].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "SALSALATE")
 SET pim_drugs->drug_classes[11].rcmd_drugs[3].displaykey = "PREDNISONE"
 SET pim_drugs->drug_classes[11].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PREDNISONE")
 SET pim_drugs->drug_classes[12].drug_class = "Amiodarone"
 SET pim_drugs->drug_classes[12].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible due to multiple side effects, including pulmonary ",
  "fibrosis, abnormal thyroid function, ocular complications, hepatitis, and skin changes.  ",
  "You may wish to consider the following alternative medication choices:",
  "@NEWLINE If prescribing for:",
  fillstring(5,char(9)),"Consider:","@NEWLINE Rate control in atrial fibrillation",fillstring(2,char(
    9)),"Carvedilol or diltiazem")
 SET pim_drugs->drug_classes[12].drug_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[12].drugs,pim_drugs->drug_classes[12].drug_cnt)
 SET pim_drugs->drug_classes[12].drugs[1].displaykey = "AMIODARONE"
 SET pim_drugs->drug_classes[12].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"AMIODARONE")
 SET pim_drugs->drug_classes[12].drugs[2].displaykey = "AMIODARONE180MGIND5W100MLPEDISTA"
 SET pim_drugs->drug_classes[12].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "AMIODARONE180MGIND5W100MLPEDISTA")
 SET pim_drugs->drug_classes[12].drugs[3].displaykey = "AMIODARONE900MGIND5W500ML"
 SET pim_drugs->drug_classes[12].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "AMIODARONE900MGIND5W500ML")
 SET pim_drugs->drug_classes[12].rcmd_cnt = 2
 SET stat = alterlist(pim_drugs->drug_classes[12].rcmd_drugs,pim_drugs->drug_classes[12].rcmd_cnt)
 SET pim_drugs->drug_classes[12].rcmd_drugs[1].displaykey = "CARVEDILOL"
 SET pim_drugs->drug_classes[12].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CARVEDILOL")
 SET pim_drugs->drug_classes[12].rcmd_drugs[2].displaykey = "DILTIAZEM"
 SET pim_drugs->drug_classes[12].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "DILTIAZEM")
 SET pim_drugs->drug_classes[13].drug_class = "Nitrofurantoin"
 SET pim_drugs->drug_classes[13].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "and should be avoided if possible.  Consider using another antibiotic with similar ",
  "spectrum such as ceftriaxone, depending on the organism species and ","antibiotic sensitivity.")
 SET pim_drugs->drug_classes[13].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[13].drugs,pim_drugs->drug_classes[13].drug_cnt)
 SET pim_drugs->drug_classes[13].drugs[1].displaykey = "NITROFURANTOIN"
 SET pim_drugs->drug_classes[13].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "NITROFURANTOIN")
 SET pim_drugs->drug_classes[13].rcmd_cnt = 2
 SET stat = alterlist(pim_drugs->drug_classes[13].rcmd_drugs,pim_drugs->drug_classes[13].rcmd_cnt)
 SET pim_drugs->drug_classes[13].rcmd_drugs[1].displaykey = "LEVOFLOXACIN"
 SET pim_drugs->drug_classes[13].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LEVOFLOXACIN")
 SET pim_drugs->drug_classes[13].rcmd_drugs[2].displaykey = "CEFTRIAXONE"
 SET pim_drugs->drug_classes[13].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CEFTRIAXONE")
 SET pim_drugs->drug_classes[14].drug_class = "Antihistamines"
 SET pim_drugs->drug_classes[14].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "because it increases the risk for delirium, and it should be avoided if possible.  ",
  "You may wish to consider the following alternative medication choices:",
  "@NEWLINE If prescribing for:",fillstring(4,char(9)),
  "Consider:","@NEWLINE Allergic reaction",fillstring(4,char(9)),"Loratadine or prednisone",
  "@NEWLINE Insomnia",
  fillstring(5,char(9)),"Trazodone","@NEWLINE Pruritis",fillstring(5,char(9)),
  "Loratadine, Eucerin cream, menthol",
  "@NEWLINE",fillstring(6,char(9)),"cream or calamine lotion")
 SET pim_drugs->drug_classes[14].drug_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[14].drugs,pim_drugs->drug_classes[14].drug_cnt)
 SET pim_drugs->drug_classes[14].drugs[1].displaykey = "CHLORPHENIRAMINE"
 SET pim_drugs->drug_classes[14].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CHLORPHENIRAMINE")
 SET pim_drugs->drug_classes[14].drugs[2].display = "DiphenhydrAMINE"
 SET pim_drugs->drug_classes[14].drugs[2].catalog_cd = uar_get_code_by("DISPLAY",200,
  "DiphenhydrAMINE")
 SET pim_drugs->drug_classes[14].drugs[3].displaykey = "HYDROXYZINE"
 SET pim_drugs->drug_classes[14].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"HYDROXYZINE"
  )
 SET pim_drugs->drug_classes[14].drugs[4].displaykey = "CYPROHEPTADINE"
 SET pim_drugs->drug_classes[14].drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CYPROHEPTADINE")
 SET pim_drugs->drug_classes[14].rcmd_cnt = 6
 SET stat = alterlist(pim_drugs->drug_classes[14].rcmd_drugs,pim_drugs->drug_classes[14].rcmd_cnt)
 SET pim_drugs->drug_classes[14].rcmd_drugs[1].displaykey = "LORATADINE"
 SET pim_drugs->drug_classes[14].rcmd_drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "LORATADINE")
 SET pim_drugs->drug_classes[14].rcmd_drugs[2].displaykey = "PREDNISONE"
 SET pim_drugs->drug_classes[14].rcmd_drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PREDNISONE")
 SET pim_drugs->drug_classes[14].rcmd_drugs[3].displaykey = "EMOLLIENTSTOPICAL"
 SET pim_drugs->drug_classes[14].rcmd_drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "EMOLLIENTSTOPICAL")
 SET pim_drugs->drug_classes[14].rcmd_drugs[4].displaykey = "METHYLSALICYLATETOPICAL"
 SET pim_drugs->drug_classes[14].rcmd_drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "METHYLSALICYLATETOPICAL")
 SET pim_drugs->drug_classes[14].rcmd_drugs[5].displaykey = "CALAMINETOPICAL"
 SET pim_drugs->drug_classes[14].rcmd_drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CALAMINETOPICAL")
 SET pim_drugs->drug_classes[14].rcmd_drugs[6].displaykey = "TRAZODONE"
 SET pim_drugs->drug_classes[14].rcmd_drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "TRAZODONE")
 SET pim_drugs->drug_classes[15].drug_class = "Nifedipine"
 SET pim_drugs->drug_classes[15].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "because of the potential for hypotension and risk of precipitating myocardial ischemia.")
 SET pim_drugs->drug_classes[15].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[15].drugs,pim_drugs->drug_classes[15].drug_cnt)
 SET pim_drugs->drug_classes[15].drugs[1].displaykey = "NIFEDIPINE"
 SET pim_drugs->drug_classes[15].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"NIFEDIPINE")
 SET pim_drugs->drug_classes[16].drug_class = "Metoclopramide"
 SET pim_drugs->drug_classes[16].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years ",
  "because it can cause extrapyramidal effects including tardive dyskinesia. 2012 Beers ",
  "list criteria recommends avoiding unless for gastroparesis.")
 SET pim_drugs->drug_classes[16].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[16].drugs,pim_drugs->drug_classes[16].drug_cnt)
 SET pim_drugs->drug_classes[16].drugs[1].displaykey = "METOCLOPRAMIDE"
 SET pim_drugs->drug_classes[16].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "METOCLOPRAMIDE")
 SET pim_drugs->drug_classes[17].drug_class = "Megestrol"
 SET pim_drugs->drug_classes[17].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years ",
  "because it increases thrombotic events and possibly death in older adults.")
 SET pim_drugs->drug_classes[17].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[17].drugs,pim_drugs->drug_classes[17].drug_cnt)
 SET pim_drugs->drug_classes[17].drugs[1].displaykey = "MEGESTROL"
 SET pim_drugs->drug_classes[17].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"MEGESTROL")
 SET pim_drugs->drug_classes[18].drug_class = "Long-acting sulfonylureas"
 SET pim_drugs->drug_classes[18].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years ",
  "because it may increase the risk of prolonged hypoglycemia in older adults. Consider ",
  "short-acting sulfonylureas. ")
 SET pim_drugs->drug_classes[18].drug_cnt = 2
 SET stat = alterlist(pim_drugs->drug_classes[18].drugs,pim_drugs->drug_classes[18].drug_cnt)
 SET pim_drugs->drug_classes[18].drugs[1].displaykey = "CHLORPROPAMIDE"
 SET pim_drugs->drug_classes[18].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CHLORPROPAMIDE")
 SET pim_drugs->drug_classes[18].drugs[2].displaykey = "GLYBURIDE"
 SET pim_drugs->drug_classes[18].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"GLYBURIDE")
 SET pim_drugs->drug_classes[19].drug_class = "Antipsychotics"
 SET pim_drugs->drug_classes[19].message_text = build2(
  "@CATALOGCDDISP:3:1 is considered a high-risk drug for this patient who is over age 65 years, ",
  "due to increased risk of stroke and mortality in persons with dementia. Avoid use for ",
  "behavioral problems of dementia unless nonpharmacological options have failed and ",
  "patient is threat to self or others.")
 SET pim_drugs->drug_classes[19].drug_cnt = 22
 SET stat = alterlist(pim_drugs->drug_classes[19].drugs,pim_drugs->drug_classes[19].drug_cnt)
 SET pim_drugs->drug_classes[19].drugs[1].displaykey = "CHLORPROMAZINE"
 SET pim_drugs->drug_classes[19].drugs[1].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "CHLORPROMAZINE")
 SET pim_drugs->drug_classes[19].drugs[2].displaykey = "FLUPHENAZINE"
 SET pim_drugs->drug_classes[19].drugs[2].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "FLUPHENAZINE")
 SET pim_drugs->drug_classes[19].drugs[3].displaykey = "HALOPERIDOL"
 SET pim_drugs->drug_classes[19].drugs[3].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"HALOPERIDOL"
  )
 SET pim_drugs->drug_classes[19].drugs[4].displaykey = "MOLINDONE"
 SET pim_drugs->drug_classes[19].drugs[4].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"MOLINDONE")
 SET pim_drugs->drug_classes[19].drugs[5].displaykey = "PERPHENAZINE"
 SET pim_drugs->drug_classes[19].drugs[5].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PERPHENAZINE")
 SET pim_drugs->drug_classes[19].drugs[6].displaykey = "PIMOZIDE"
 SET pim_drugs->drug_classes[19].drugs[6].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"PIMOZIDE")
 SET pim_drugs->drug_classes[19].drugs[7].displaykey = "THIORIDAZINE"
 SET pim_drugs->drug_classes[19].drugs[7].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "THIORIDAZINE")
 SET pim_drugs->drug_classes[19].drugs[8].displaykey = "THIOTHIXENE"
 SET pim_drugs->drug_classes[19].drugs[8].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"THIOTHIXENE"
  )
 SET pim_drugs->drug_classes[19].drugs[9].displaykey = "TRIFLUOPERAZINE"
 SET pim_drugs->drug_classes[19].drugs[9].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "TRIFLUOPERAZINE")
 SET pim_drugs->drug_classes[19].drugs[10].displaykey = "ARIPIPRAZOLE"
 SET pim_drugs->drug_classes[19].drugs[10].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ARIPIPRAZOLE")
 SET pim_drugs->drug_classes[19].drugs[11].displaykey = "ASENAPINE"
 SET pim_drugs->drug_classes[19].drugs[11].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"ASENAPINE")
 SET pim_drugs->drug_classes[19].drugs[12].displaykey = "CLOZAPINE"
 SET pim_drugs->drug_classes[19].drugs[12].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"CLOZAPINE")
 SET pim_drugs->drug_classes[19].drugs[13].displaykey = "ILOPERIDONE"
 SET pim_drugs->drug_classes[19].drugs[13].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ILOPERIDONE")
 SET pim_drugs->drug_classes[19].drugs[14].displaykey = "LURASIDONE"
 SET pim_drugs->drug_classes[19].drugs[14].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"LURASIDONE"
  )
 SET pim_drugs->drug_classes[19].drugs[15].displaykey = "OLANZAPINE"
 SET pim_drugs->drug_classes[19].drugs[15].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"OLANZAPINE"
  )
 SET pim_drugs->drug_classes[19].drugs[16].displaykey = "OLANZAPINE10MGTABLET"
 SET pim_drugs->drug_classes[19].drugs[16].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "OLANZAPINE10MGTABLET")
 SET pim_drugs->drug_classes[19].drugs[17].displaykey = "OLANZAPINE20MGTABLET"
 SET pim_drugs->drug_classes[19].drugs[17].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "OLANZAPINE20MGTABLET")
 SET pim_drugs->drug_classes[19].drugs[18].displaykey = "OLANZAPINE75MGTABLET"
 SET pim_drugs->drug_classes[19].drugs[18].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "OLANZAPINE75MGTABLET")
 SET pim_drugs->drug_classes[19].drugs[19].displaykey = "PALIPERIDONE"
 SET pim_drugs->drug_classes[19].drugs[19].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "PALIPERIDONE")
 SET pim_drugs->drug_classes[19].drugs[20].displaykey = "QUETIAPINE"
 SET pim_drugs->drug_classes[19].drugs[20].catalog_cd = uar_get_code_by("DISPLAYKEY",200,"QUETIAPINE"
  )
 SET pim_drugs->drug_classes[19].drugs[21].displaykey = "RISPERIDONE"
 SET pim_drugs->drug_classes[19].drugs[21].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "RISPERIDONE")
 SET pim_drugs->drug_classes[19].drugs[22].displaykey = "ZIPRASIDONE"
 SET pim_drugs->drug_classes[19].drugs[22].catalog_cd = uar_get_code_by("DISPLAYKEY",200,
  "ZIPRASIDONE")
#exit_script
END GO
