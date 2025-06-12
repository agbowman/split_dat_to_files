CREATE PROGRAM cern_dcp_rpt_admission:dba
 RECORD temp(
   1 emergcon = vc
   1 emergcon_note_ind = i2
   1 emergcon_event_id = f8
   1 emergcon_note_text = vc
   1 emergcon_status = i2
   1 arrival = vc
   1 arrival_note_ind = i2
   1 arrival_event_id = f8
   1 arrival_note_text = vc
   1 arrival_status = i2
   1 height = f8
   1 height_note_ind = i2
   1 height_event_id = f8
   1 height_note_text = vc
   1 height_status = i2
   1 weight = f8
   1 weight_note_ind = i2
   1 weight_event_id = f8
   1 weight_note_text = vc
   1 weight_status = i2
   1 edc = vc
   1 edc_note_ind = i2
   1 edc_event_id = f8
   1 edc_note_text = vc
   1 edc_status = i2
   1 pregnant = vc
   1 pregnant_note_ind = i2
   1 pregnant_event_id = f8
   1 pregnant_note_text = vc
   1 pregnant_status = i2
   1 immun = vc
   1 immun_note_ind = i2
   1 immun_event_id = f8
   1 immun_note_text = vc
   1 immun_status = i2
   1 histdef = vc
   1 histdef_note_ind = i2
   1 histdef_event_id = f8
   1 histdef_note_text = vc
   1 histdef_status = i2
   1 lmp = vc
   1 lmp_note_ind = i2
   1 lmp_event_id = f8
   1 lmp_note_text = vc
   1 lmp_status = i2
   1 tetanus = vc
   1 tetanus_note_ind = i2
   1 tetanus_event_id = f8
   1 tetanus_note_text = vc
   1 tetanus_status = i2
   1 doctor = vc
   1 doctor_note_ind = i2
   1 doctor_event_id = f8
   1 doctor_note_text = vc
   1 doctor_status = i2
   1 complaint = vc
   1 complaint_note_ind = i2
   1 complaint_event_id = f8
   1 complaint_note_text = vc
   1 complaint_status = i2
   1 hmphone = vc
   1 hmphone_note_ind = i2
   1 hmphone_event_id = f8
   1 hmphone_note_text = vc
   1 hmphone_status = i2
   1 wkphone = vc
   1 wkphone_note_ind = i2
   1 wkphone_event_id = f8
   1 wkphone_note_text = vc
   1 wkphone_status = i2
   1 cell = vc
   1 cell_note_ind = i2
   1 cell_event_id = f8
   1 cell_note_text = vc
   1 cell_status = i2
   1 pager = vc
   1 pager_note_ind = i2
   1 pager_event_id = f8
   1 pager_note_text = vc
   1 pager_status = i2
 )
 RECORD allergy(
   1 latex1 = vc
   1 doc1 = vc
   1 date1 = dq8
   1 note1_ind = i2
   1 event1_id = f8
   1 note1_text = vc
   1 latex1_status = i2
   1 latex1_status_name = vc
   1 latex1_status_dt_tm = dq8
   1 latex2 = vc
   1 doc2 = vc
   1 date2 = dq8
   1 note2_ind = i2
   1 event2_id = f8
   1 note2_text = vc
   1 latex2_status = i2
   1 latex2_status_name = vc
   1 latex2_status_dt_tm = dq8
   1 latex3 = vc
   1 doc3 = vc
   1 date3 = dq8
   1 note3_ind = i2
   1 event3_id = f8
   1 note3_text = vc
   1 latex3_status = i2
   1 latex3_status_name = vc
   1 latex3_status_dt_tm = dq8
   1 cnt = i2
   1 qual[*]
     2 list = vc
     2 doc = vc
     2 date = dq8
     2 rlist = vc
     2 date_tz = vc
   1 date1_tz = vc
   1 date2_tz = vc
   1 date3_tz = vc
   1 latex1_status_tz = vc
   1 latex2_status_tz = vc
   1 latex3_status_tz = vc
 )
 RECORD curmed(
   1 list = vc
   1 text = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD hosp(
   1 list = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD habit(
   1 tobac = vc
   1 tobacdoc = vc
   1 tobacdate = dq8
   1 tobac_note_ind = i2
   1 tobac_event_id = f8
   1 tobac_note_text = vc
   1 tobac_status = i2
   1 tobac_status_name = vc
   1 tobac_status_dt_tm = dq8
   1 drug = vc
   1 drugdoc = vc
   1 drugdate = dq8
   1 drug_note_ind = i2
   1 drug_event_id = f8
   1 drug_note_text = vc
   1 drug_status = i2
   1 drug_status_name = vc
   1 drug_status_dt_tm = dq8
   1 alc = vc
   1 alcdoc = vc
   1 alcdate = dq8
   1 alc_note_ind = i2
   1 alc_event_id = f8
   1 alc_note_text = vc
   1 alc_status = i2
   1 alc_status_name = vc
   1 alc_status_dt_tm = dq8
   1 drugdate_tz = vc
   1 drug_status_tz = vc
   1 tobacdate_tz = vc
   1 tobac_status_tz = vc
   1 alcdate_tz = vc
   1 alc_status_tz = vc
 )
 RECORD med(
   1 neuro = vc
   1 neurodoc = vc
   1 neurodate = dq8
   1 neuro_note_ind = i2
   1 neuro_event_id = f8
   1 neuro_note_text = vc
   1 neuro_status = i2
   1 neuro_status_name = vc
   1 neuro_status_dt_tm = dq8
   1 cva = vc
   1 cvadoc = vc
   1 cvadate = dq8
   1 cva_note_ind = i2
   1 cva_event_id = f8
   1 cva_note_text = vc
   1 cva_status = i2
   1 cva_status_name = vc
   1 cva_status_dt_tm = dq8
   1 brain = vc
   1 braindoc = vc
   1 braindate = dq8
   1 brain_note_ind = i2
   1 brain_event_id = f8
   1 brain_note_text = vc
   1 brain_status = i2
   1 brain_status_name = vc
   1 brain_status_dt_tm = dq8
   1 eent = vc
   1 eentdoc = vc
   1 eentdate = dq8
   1 eent_note_ind = i2
   1 eent_event_id = f8
   1 eent_note_text = vc
   1 eent_status = i2
   1 eent_status_name = vc
   1 eent_status_dt_tm = dq8
   1 mental = vc
   1 mentaldoc = vc
   1 mentaldate = dq8
   1 mental_note_ind = i2
   1 mental_event_id = f8
   1 mental_note_text = vc
   1 mental_status = i2
   1 mental_status_name = vc
   1 mental_status_dt_tm = dq8
   1 heart = vc
   1 heartdoc = vc
   1 heartdate = dq8
   1 heart_note_ind = i2
   1 heart_event_id = f8
   1 heart_note_text = vc
   1 heart_status = i2
   1 heart_status_name = vc
   1 heart_status_dt_tm = dq8
   1 hyper = vc
   1 hyperdoc = vc
   1 hyperdate = dq8
   1 hyper_note_ind = i2
   1 hyper_event_id = f8
   1 hyper_note_text = vc
   1 hyper_status = i2
   1 hyper_status_name = vc
   1 hyper_status_dt_tm = dq8
   1 pacemaker = vc
   1 pacemakerdoc = vc
   1 pacemakerdate = dq8
   1 pace_note_ind = i2
   1 pace_event_id = f8
   1 pace_note_text = vc
   1 pace_status = i2
   1 pace_status_name = vc
   1 pace_status_dt_tm = dq8
   1 defib = vc
   1 defibdoc = vc
   1 defibdate = dq8
   1 defib_note_ind = i2
   1 defib_event_id = f8
   1 defib_note_text = vc
   1 defib_status = i2
   1 defib_status_name = vc
   1 defib_status_dt_tm = dq8
   1 pulmonary = vc
   1 pulmonarydoc = vc
   1 pulmonarydate = dq8
   1 pulm_note_ind = i2
   1 pulm_event_id = f8
   1 pulm_note_text = vc
   1 pulm_status = i2
   1 pulm_status_name = vc
   1 pulm_status_dt_tm = dq8
   1 tb = vc
   1 tbdoc = vc
   1 tbdate = dq8
   1 tb_note_ind = i2
   1 tb_event_id = f8
   1 tb_note_text = vc
   1 tb_status = i2
   1 tb_status_name = vc
   1 tb_status_dt_tm = dq8
   1 gi = vc
   1 gidoc = vc
   1 gidate = dq8
   1 gi_note_ind = i2
   1 gi_event_id = f8
   1 gi_note_text = vc
   1 gi_status = i2
   1 gi_status_name = vc
   1 gi_status_dt_tm = dq8
   1 hepatitis = vc
   1 hepatitisdoc = vc
   1 hepatitisdate = dq8
   1 hep_note_ind = i2
   1 hep_event_id = f8
   1 hep_note_text = vc
   1 hep_status = i2
   1 hep_status_name = vc
   1 hep_status_dt_tm = dq8
   1 endo = vc
   1 endodoc = vc
   1 endodate = dq8
   1 endo_note_ind = i2
   1 endo_event_id = f8
   1 endo_note_text = vc
   1 endo_status = i2
   1 endo_status_name = vc
   1 endo_status_dt_tm = dq8
   1 bone = vc
   1 bonedoc = vc
   1 bonedate = dq8
   1 bone_note_ind = i2
   1 bone_event_id = f8
   1 bone_note_text = vc
   1 bone_status = i2
   1 bone_status_name = vc
   1 bone_status_dt_tm = dq8
   1 ortho = vc
   1 orthodoc = vc
   1 orthodate = dq8
   1 ortho_note_ind = i2
   1 ortho_event_id = f8
   1 ortho_note_text = vc
   1 ortho_status = i2
   1 ortho_status_name = vc
   1 ortho_status_dt_tm = dq8
   1 implant = vc
   1 implantdoc = vc
   1 implantdate = dq8
   1 implant_note_ind = i2
   1 implant_event_id = f8
   1 implant_note_text = vc
   1 implant_status = i2
   1 implant_status_name = vc
   1 implant_status_dt_tm = dq8
   1 blood = vc
   1 blooddoc = vc
   1 blooddate = dq8
   1 blood_note_ind = i2
   1 blood_event_id = f8
   1 blood_note_text = vc
   1 blood_status = i2
   1 blood_status_name = vc
   1 blood_status_dt_tm = dq8
   1 cancer = vc
   1 cancerdoc = vc
   1 cancerdate = dq8
   1 cancer_note_ind = i2
   1 cancer_event_id = f8
   1 cancer_note_text = vc
   1 cancer_status = i2
   1 cancer_status_name = vc
   1 cancer_status_dt_tm = dq8
   1 skin = vc
   1 skindoc = vc
   1 skindate = dq8
   1 skin_note_ind = i2
   1 skin_event_id = f8
   1 skin_note_text = vc
   1 skin_status = i2
   1 skin_status_name = vc
   1 skin_status_dt_tm = dq8
   1 rash = vc
   1 rashdoc = vc
   1 rashdate = dq8
   1 rash_note_ind = i2
   1 rash_event_id = f8
   1 rash_note_text = vc
   1 rash_status = i2
   1 rash_status_name = vc
   1 rash_status_dt_tm = dq8
   1 infect = vc
   1 infectdoc = vc
   1 infectdate = dq8
   1 infect_note_ind = i2
   1 infect_event_id = f8
   1 infect_note_text = vc
   1 infect_status = i2
   1 infect_status_name = vc
   1 infect_status_dt_tm = dq8
   1 trans = vc
   1 transdoc = vc
   1 transdate = dq8
   1 trans_note_ind = i2
   1 trans_event_id = f8
   1 trans_note_text = vc
   1 trans_status = i2
   1 trans_status_name = vc
   1 trans_status_dt_tm = dq8
   1 other = vc
   1 otherdoc = vc
   1 otherdate = dq8
   1 other_note_ind = i2
   1 other_event_id = f8
   1 other_note_text = vc
   1 other_status = i2
   1 other_status_name = vc
   1 other_status_dt_tm = dq8
   1 renal = vc
   1 renaldoc = vc
   1 renaldate = dq8
   1 renal_note_ind = i2
   1 renal_event_id = f8
   1 renal_note_text = vc
   1 renal_status = i2
   1 renal_status_name = vc
   1 renal_status_dt_tm = dq8
   1 gugyn = vc
   1 gugyndoc = vc
   1 gugyndate = dq8
   1 gugyn_note_ind = i2
   1 gugyn_event_id = f8
   1 gugyn_note_text = vc
   1 gugyn_status = i2
   1 gugyn_status_name = vc
   1 gugyn_status_dt_tm = dq8
   1 neurodate_tz = vc
   1 neuro_status_tz = vc
   1 cvadate_tz = vc
   1 cva_status_tz = vc
   1 braindate_tz = vc
   1 brain_status_tz = vc
   1 mentaldate_tz = vc
   1 mental_status_tz = vc
   1 heartdate_tz = vc
   1 heart_status_tz = vc
   1 hyperdate_tz = vc
   1 hyper_status_tz = vc
   1 pacemakerdate_tz = vc
   1 pace_status_tz = vc
   1 defibdate_tz = vc
   1 defib_status_tz = vc
   1 pulmonarydate_tz = vc
   1 pulm_status_tz = vc
   1 gugyndate_tz = vc
   1 gugyn_status_tz = vc
   1 tbdate_tz = vc
   1 tb_status_tz = vc
   1 eentdate_tz = vc
   1 eent_status_tz = vc
   1 gidate_tz = vc
   1 gi_status_tz = vc
   1 hepatitisdate_tz = vc
   1 hep_status_tz = vc
   1 endodate_tz = vc
   1 endo_status_tz = vc
   1 bonedate_tz = vc
   1 bone_status_tz = vc
   1 orthodate_tz = vc
   1 ortho_status_tz = vc
   1 implantdate_tz = vc
   1 implant_status_tz = vc
   1 blooddate_tz = vc
   1 blood_status_tz = vc
   1 transdate_tz = vc
   1 trans_status_tz = vc
   1 cancerdate_tz = vc
   1 cancer_status_tz = vc
   1 skindate_tz = vc
   1 skin_status_tz = vc
   1 renaldate_tz = vc
   1 renal_status_tz = vc
   1 rashdate_tz = vc
   1 rash_status_tz = vc
   1 infectdate_tz = vc
   1 infect_status_tz = vc
   1 otherdate_tz = vc
   1 other_status_tz = vc
 )
 RECORD treat(
   1 list = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD surg(
   1 list = vc
   1 text = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD curtreat(
   1 list = vc
   1 text = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD sensory(
   1 hear_list = vc
   1 hear_doc = vc
   1 hear_date = dq8
   1 hear_note_ind = i2
   1 hear_event_id = f8
   1 hear_note_text = vc
   1 hear_cnt = i2
   1 hear_qual[*]
     2 hear_line = vc
   1 hear_line3 = vc
   1 hear_list_ln_cnt = i2
   1 hear_list_tag[*]
     2 hear_list_line = vc
   1 hear_disp_line1 = vc
   1 hear_disp_line2 = vc
   1 hear_status = i2
   1 hear_status_name = vc
   1 hear_status_dt_tm = dq8
   1 speech_list = vc
   1 speech_doc = vc
   1 speech_date = dq8
   1 speech_note_ind = i2
   1 speech_event_id = f8
   1 speech_note_text = vc
   1 speech_cnt = i2
   1 speech_qual[*]
     2 speech_line = vc
   1 speech_line3 = vc
   1 speech_list_ln_cnt = i2
   1 speech_list_tag[*]
     2 speech_list_line = vc
   1 speech_disp_line1 = vc
   1 speech_disp_line2 = vc
   1 speech_status = i2
   1 speech_status_name = vc
   1 speech_status_dt_tm = dq8
   1 visual_list = vc
   1 visual_doc = vc
   1 visual_date = dq8
   1 visual_note_ind = i2
   1 visual_event_id = f8
   1 visual_note_text = vc
   1 visual_cnt = i2
   1 visual_qual[*]
     2 visual_line = vc
   1 visual_line3 = vc
   1 visual_list_ln_cnt = i2
   1 visual_list_tag[*]
     2 visual_list_line = vc
   1 visual_disp_line1 = vc
   1 visual_disp_line2 = vc
   1 visual_status = i2
   1 visual_status_name = vc
   1 visual_status_dt_tm = dq8
   1 visual_date_tz = vc
   1 visual_status_tz = vc
   1 speech_date_tz = vc
   1 speech_status_tz = vc
   1 hear_date_tz = vc
   1 hear_status_tz = vc
 )
 RECORD prosthetic(
   1 list = vc
   1 list2 = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
   1 list_ln_cnt = i2
   1 list_tag[*]
     2 list_line = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD nutrition(
   1 list = vc
   1 list2 = vc
   1 list_ln_cnt = i2
   1 list_tag[*]
     2 list_line = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD elim(
   1 list = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
   1 line3 = vc
   1 list_ln_cnt = i2
   1 list_tag[*]
     2 list_line = vc
   1 disp_line1 = vc
   1 disp_line2 = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD psycho(
   1 list = vc
   1 list2 = vc
   1 list_ln_cnt = i2
   1 list_tag[*]
     2 list_line = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD function(
   1 list = vc
   1 list2 = vc
   1 list_ln_cnt = i2
   1 list_tag[*]
     2 list_line = vc
   1 doc = vc
   1 date = dq8
   1 note_ind = i2
   1 event_id = f8
   1 note_text = vc
   1 status = i2
   1 status_name = vc
   1 status_dt_tm = dq8
   1 date_tz = vc
   1 status_tz = vc
 )
 RECORD social(
   1 cnt = i2
   1 qual[*]
     2 list = vc
     2 list_ln_cnt = i2
     2 list_tag[*]
       3 list_line = vc
     2 doc = vc
     2 date = dq8
     2 note_ind = i2
     2 event_id = f8
     2 note_text = vc
     2 status = i2
     2 status_name = vc
     2 status_dt_tm = dq8
     2 date_tz = vc
     2 status_tz = vc
 )
 RECORD spirit(
   1 support_list = vc
   1 support_doc = vc
   1 support_date = dq8
   1 support_note_ind = i2
   1 support_event_id = f8
   1 support_note_text = vc
   1 support_cnt = i2
   1 support_qual[*]
     2 support_line = vc
   1 support_line3 = vc
   1 support_list_ln_cnt = i2
   1 support_list_tag[*]
     2 support_list_line = vc
   1 support_disp_line1 = vc
   1 support_disp_line2 = vc
   1 support_status = i2
   1 support_status_name = vc
   1 support_status_dt_tm = dq8
   1 pref = vc
   1 prefdoc = vc
   1 prefdate = dq8
   1 pref_note_ind = i2
   1 pref_event_id = f8
   1 pref_note_text = vc
   1 pref_status = i2
   1 pref_status_name = vc
   1 pref_status_dt_tm = dq8
   1 support_date_tz = vc
   1 support_status_tz = vc
   1 prefdate_tz = vc
   1 pref_status_tz = vc
 )
 RECORD education(
   1 pref_list = vc
   1 pref_doc = vc
   1 pref_date = dq8
   1 pref_note_ind = i2
   1 pref_event_id = f8
   1 pref_note_text = vc
   1 pref_cnt = i2
   1 pref_qual[*]
     2 pref_line = vc
   1 pref_line3 = vc
   1 pref_list_ln_cnt = i2
   1 pref_list_tag[*]
     2 pref_list_line = vc
   1 pref_disp_line1 = vc
   1 pref_disp_line2 = vc
   1 pref_status = i2
   1 pref_status_name = vc
   1 pref_status_dt_tm = dq8
   1 barriers_list = vc
   1 barriers_doc = vc
   1 barriers_date = dq8
   1 barriers_note_ind = i2
   1 barriers_event_id = f8
   1 barriers_note_text = vc
   1 barriers_cnt = i2
   1 barriers_qual[*]
     2 barriers_line = vc
   1 barriers_line3 = vc
   1 barriers_list_ln_cnt = i2
   1 barriers_list_tag[*]
     2 barriers_list_line = vc
   1 barriers_disp_line1 = vc
   1 barriers_disp_line2 = vc
   1 barriers_status = i2
   1 barriers_status_name = vc
   1 barriers_status_dt_tm = dq8
   1 need_list = vc
   1 need_doc = vc
   1 need_date = dq8
   1 need_note_ind = i2
   1 need_event_id = f8
   1 need_note_text = vc
   1 need_cnt = i2
   1 need_qual[*]
     2 need_line = vc
   1 need_line3 = vc
   1 need_list_ln_cnt = i2
   1 need_list_tag[*]
     2 need_list_line = vc
   1 need_disp_line1 = vc
   1 need_disp_line2 = vc
   1 need_status = i2
   1 need_status_name = vc
   1 need_status_dt_tm = dq8
   1 so = vc
   1 sodoc = vc
   1 sodate = dq8
   1 so_note_ind = i2
   1 so_event_id = f8
   1 so_note_text = vc
   1 so_status = i2
   1 so_status_name = vc
   1 so_status_dt_tm = dq8
   1 sodate_tz = vc
   1 so_status_tz = vc
   1 pref_date_tz = vc
   1 pref_status_tz = vc
   1 barriers_date_tz = vc
   1 barriers_status_tz = vc
   1 need_date_tz = vc
   1 need_status_tz = vc
 )
 RECORD discharge(
   1 home = vc
   1 homedoc = vc
   1 homedate = dq8
   1 home_note_ind = i2
   1 home_event_id = f8
   1 home_note_text = vc
   1 home_status = i2
   1 home_status_name = vc
   1 home_status_dt_tm = dq8
   1 lives = vc
   1 livesdoc = vc
   1 livesdate = dq8
   1 lives_note_ind = i2
   1 lives_event_id = f8
   1 lives_note_text = vc
   1 lives_status = i2
   1 lives_status_name = vc
   1 lives_status_dt_tm = dq8
   1 tran = vc
   1 trandoc = vc
   1 trandate = dq8
   1 tran_note_ind = i2
   1 tran_event_id = f8
   1 tran_note_text = vc
   1 tran_status = i2
   1 tran_status_name = vc
   1 tran_status_dt_tm = dq8
   1 care = vc
   1 caredoc = vc
   1 caredate = dq8
   1 care_note_ind = i2
   1 care_event_id = f8
   1 care_note_text = vc
   1 care_status = i2
   1 care_status_name = vc
   1 care_status_dt_tm = dq8
   1 referral = vc
   1 referraldoc = vc
   1 referraldate = dq8
   1 referral_note_ind = i2
   1 referral_event_id = f8
   1 referral_note_text = vc
   1 referral_status = i2
   1 referral_status_name = vc
   1 referral_status_dt_tm = dq8
   1 homedate_tz = vc
   1 home_status_tz = vc
   1 livesdate_tz = vc
   1 lives_status_tz = vc
   1 trandate_tz = vc
   1 tran_status_tz = vc
   1 caredate_tz = vc
   1 care_status_tz = vc
   1 referraldate_tz = vc
   1 referral_status_tz = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD dash(
   1 n = i4
   1 ln = vc
 )
 SET modify = predeclare
 DECLARE alc_cd = i4 WITH constant(0)
 DECLARE arrival_cd = i4 WITH constant(0)
 DECLARE barriers_cd = i4 WITH constant(0)
 DECLARE blood_cd = i4 WITH constant(0)
 DECLARE bone_cd = i4 WITH constant(0)
 DECLARE brain_cd = i4 WITH constant(0)
 DECLARE cancer_cd = i4 WITH constant(0)
 DECLARE care_cd = i4 WITH constant(0)
 DECLARE cell_cd = i4 WITH constant(0)
 DECLARE complaint_cd = i4 WITH constant(0)
 DECLARE curmed_cd = i4 WITH constant(0)
 DECLARE curtreat_cd = i4 WITH constant(0)
 DECLARE cva_cd = i4 WITH constant(0)
 DECLARE defib_cd = i4 WITH constant(0)
 DECLARE doctor_cd = i4 WITH constant(0)
 DECLARE drug_cd = i4 WITH constant(0)
 DECLARE edc_cd = i4 WITH constant(0)
 DECLARE edpref_cd = i4 WITH constant(0)
 DECLARE eent_cd = i4 WITH constant(0)
 DECLARE elim_cd = i4 WITH constant(0)
 DECLARE emergcon_cd = i4 WITH constant(0)
 DECLARE endo_cd = i4 WITH constant(0)
 DECLARE function_cd = i4 WITH constant(0)
 DECLARE gi_cd = i4 WITH constant(0)
 DECLARE gugyn_cd = i4 WITH constant(0)
 DECLARE hear_cd = i4 WITH constant(0)
 DECLARE heart_cd = i4 WITH constant(0)
 DECLARE height_cd = i4 WITH constant(0)
 DECLARE hepatitis_cd = i4 WITH constant(0)
 DECLARE histdef_cd = i4 WITH constant(0)
 DECLARE hmphone_cd = i4 WITH constant(0)
 DECLARE home_cd = i4 WITH constant(0)
 DECLARE hosp_cd = i4 WITH constant(0)
 DECLARE hyper_cd = i4 WITH constant(0)
 DECLARE immun_cd = i4 WITH constant(0)
 DECLARE implant_cd = i4 WITH constant(0)
 DECLARE infect_cd = i4 WITH constant(0)
 DECLARE latex1_cd = i4 WITH constant(0)
 DECLARE latex2_cd = i4 WITH constant(0)
 DECLARE latex3_cd = i4 WITH constant(0)
 DECLARE lives_cd = i4 WITH constant(0)
 DECLARE lmp_cd = i4 WITH constant(0)
 DECLARE mental_cd = i4 WITH constant(0)
 DECLARE need_cd = i4 WITH constant(0)
 DECLARE neuro_cd = i4 WITH constant(0)
 DECLARE nutrition_cd = i4 WITH constant(0)
 DECLARE ortho_cd = i4 WITH constant(0)
 DECLARE other_cd = i4 WITH constant(0)
 DECLARE pacemaker_cd = i4 WITH constant(0)
 DECLARE pager_cd = i4 WITH constant(0)
 DECLARE pref_cd = i4 WITH constant(0)
 DECLARE pregnant_cd = i4 WITH constant(0)
 DECLARE prosthetic_cd = i4 WITH constant(0)
 DECLARE psycho_cd = i4 WITH constant(0)
 DECLARE pulmonary_cd = i4 WITH constant(0)
 DECLARE rash_cd = i4 WITH constant(0)
 DECLARE referral_cd = i4 WITH constant(0)
 DECLARE renal_cd = i4 WITH constant(0)
 DECLARE skin_cd = i4 WITH constant(0)
 DECLARE so_cd = i4 WITH constant(0)
 DECLARE social_cd = i4 WITH constant(0)
 DECLARE social_list_cd = i4 WITH constant(0)
 DECLARE speech_cd = i4 WITH constant(0)
 DECLARE support_cd = i4 WITH constant(0)
 DECLARE surg_cd = i4 WITH constant(0)
 DECLARE tb_cd = i4 WITH constant(0)
 DECLARE tetanus_cd = i4 WITH constant(0)
 DECLARE tobac_cd = i4 WITH constant(0)
 DECLARE tran_cd = i4 WITH constant(0)
 DECLARE trans_cd = i4 WITH constant(0)
 DECLARE treat_cd = i4 WITH constant(0)
 DECLARE visual_cd = i4 WITH constant(0)
 DECLARE weight_cd = i4 WITH constant(0)
 DECLARE wkphone_cd = i4 WITH constant(0)
 DECLARE l1 = vc WITH noconstant(fillstring(130,"_"))
 DECLARE room = vc WITH noconstant(fillstring(20," "))
 DECLARE unit = vc WITH noconstant(fillstring(20," "))
 DECLARE bed = vc WITH noconstant(fillstring(20," "))
 DECLARE name = vc WITH noconstant(fillstring(30," "))
 DECLARE admitdoc = vc WITH noconstant(fillstring(30," "))
 DECLARE sex = vc WITH noconstant(fillstring(10," "))
 DECLARE mrn = vc WITH noconstant(fillstring(20," "))
 DECLARE finnbr = vc WITH noconstant(fillstring(20," "))
 DECLARE age = vc WITH noconstant(fillstring(10," "))
 DECLARE date = vc WITH noconstant(fillstring(20," "))
 DECLARE ycol = i4 WITH noconstant(0)
 DECLARE xcol = i4 WITH noconstant(0)
 DECLARE xxx = vc WITH noconstant(fillstring(40," "))
 DECLARE person_id = f8 WITH noconstant(0.0)
 DECLARE lf = vc WITH noconstant(concat(char(13),char(10)))
 DECLARE r = vc WITH noconstant(fillstring(2," "))
 DECLARE s = vc WITH noconstant(fillstring(2," "))
 DECLARE t = vc WITH noconstant(fillstring(2," "))
 DECLARE u = vc WITH noconstant(fillstring(8," "))
 DECLARE person_mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE encntr_mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE attend_doc_cd = f8 WITH noconstant(0.0)
 DECLARE finnbr_cd = f8 WITH noconstant(0.0)
 DECLARE ocfcomp_cd = f8 WITH noconstant(0.0)
 DECLARE inerror_cd = f8 WITH noconstant(0.0)
 DECLARE modified_cd = f8 WITH noconstant(0.0)
 DECLARE canceled_cd = f8 WITH noconstant(0.0)
 DECLARE event_id = f8 WITH noconstant(0.0)
 DECLARE max_length = i4 WITH noconstant(0)
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE daylight = i2 WITH protect, noconstant(0)
 SET person_mrn_alias_cd = uar_get_code_by("MEANING",4,"MRN")
 SET encntr_mrn_alias_cd = uar_get_code_by("MEANING",319,"MRN")
 SET attend_doc_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 SET finnbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET ocfcomp_cd = uar_get_code_by("MEANING",120,"OCFCOMP")
 SET inerror_cd = uar_get_code_by("MEANING",8,"INERROR")
 SET modified_cd = uar_get_code_by("MEANING",8,"MODIFIED")
 SET canceled_cd = uar_get_code_by("MEANING",12025,"CANCELED")
 IF ((request->visit[1].encntr_id <= 0))
  GO TO report_failed
 ENDIF
 SELECT INTO "nl:"
  e.encntr_id, e.loc_nurse_unit_cd, e.loc_room_cd,
  e.loc_bed_cd, e.reg_dt_tm, p.name_full_formatted,
  p.birth_dt_tm, p.sex_cd, pl.name_full_formatted,
  epr.seq
  FROM encounter e,
   person p,
   prsnl pl,
   encntr_prsnl_reltn epr,
   encntr_alias ea,
   (dummyt d3  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (d3)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (finnbr_cd, encntr_mrn_alias_cd))
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   name = substring(1,30,p.name_full_formatted), age = cnvtage(cnvtdate(p.birth_dt_tm),curdate),
   admitdoc = substring(1,30,pl.name_full_formatted),
   unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,20,
    uar_get_code_display(e.loc_room_cd)), bed = substring(1,20,uar_get_code_display(e.loc_bed_cd)),
   sex = substring(1,10,uar_get_code_display(p.sex_cd)), date = format(e.reg_dt_tm,"mm/dd/yy;;d"),
   person_id = e.person_id
  DETAIL
   IF (ea.encntr_alias_type_cd=finnbr_cd)
    finnbr = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSEIF (ea.encntr_alias_type_cd=encntr_mrn_alias_cd)
    mrn = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ENDIF
  WITH nocounter, outerjoin = d2, dontcare = epr,
   outerjoin = d3, dontcare = ea
 ;end select
 IF (mrn <= " ")
  SELECT INTO "nl"
   FROM person_alias pa
   WHERE pa.person_id=person_id
    AND pa.person_alias_type_cd=person_mrn_alias_cd
    AND pa.active_ind=1
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
  ;end select
 ENDIF
 SELECT INTO "nl:"
  c1.event_end_dt_tm, c.event_cd, c.person_id,
  c.encntr_id, c.event_end_dt_tm, c.performed_prsnl_id,
  cv.code_value, cv2.code_value, pl.person_id,
  pl2.person_id
  FROM clinical_event c1,
   clinical_event c,
   code_value cv,
   code_value cv2,
   prsnl pl,
   prsnl pl2
  PLAN (c1
   WHERE (c1.encntr_id=request->visit[1].encntr_id)
    AND c1.publish_flag=1
    AND c1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND c1.event_cd=social_cd)
   JOIN (c
   WHERE c.parent_event_id=c1.event_id
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND c.event_cd=social_list_cd)
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
   JOIN (pl2
   WHERE pl2.person_id=c.verified_prsnl_id)
   JOIN (cv
   WHERE cv.code_value=pl.position_cd)
   JOIN (cv2
   WHERE cv2.code_value=pl2.position_cd)
  ORDER BY cnvtdatetime(c1.event_end_dt_tm) DESC
  HEAD REPORT
   social->cnt = 0, first_time = "Y"
  DETAIL
   IF (first_time="Y")
    social->cnt = (social->cnt+ 1), stat = alterlist(social->qual,social->cnt), social->qual[social->
    cnt].list = c.event_tag,
    social->qual[social->cnt].doc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)),
    social->qual[social->cnt].date = c.event_end_dt_tm, social->qual[social->cnt].date_tz = concat(
     format(datetimezone(c.event_end_dt_tm,c.event_end_tz),"mm/dd/yy hh:mm;;d")," ",
     datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm)),
    social->qual[social->cnt].note_ind = btest(c.subtable_bit_map,1), social->qual[social->cnt].
    event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     social->qual[social->cnt].status = 1, social->qual[social->cnt].status_name = concat(trim(pl2
       .name_full_formatted)," ",trim(cv2.definition)), social->qual[social->cnt].status_dt_tm = c
     .verified_dt_tm,
     social->qual[social->cnt].status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     social->qual[social->cnt].status = 2, social->qual[social->cnt].status_name = concat(trim(pl2
       .name_full_formatted)," ",trim(cv2.definition)), social->qual[social->cnt].status_dt_tm = c
     .verified_dt_tm,
     social->qual[social->cnt].status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
  FOOT  c1.event_end_dt_tm
   first_time = "N"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.event_cd, c.person_id, c.encntr_id,
  c.event_end_dt_tm, c.performed_prsnl_id, pl.person_id,
  pl2.person_id, cv.code_value, cv2.code_value,
  c.event_id, ccr.event_id, n.nomenclature_id,
  n.source_string
  FROM clinical_event c,
   prsnl pl,
   prsnl pl2,
   code_value cv,
   code_value cv2,
   (dummyt d1  WITH seq = 1),
   nomenclature n,
   ce_coded_result ccr
  PLAN (c
   WHERE (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND c.event_cd IN (trans_cd, elim_cd, hear_cd, visual_cd, speech_cd,
   barriers_cd, edpref_cd, need_cd, support_cd))
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
   JOIN (pl2
   WHERE pl2.person_id=c.verified_prsnl_id)
   JOIN (cv
   WHERE cv.code_value=pl.position_cd)
   JOIN (cv2
   WHERE cv2.code_value=pl2.position_cd)
   JOIN (d1)
   JOIN (ccr
   WHERE ccr.event_id=c.event_id)
   JOIN (n
   WHERE n.nomenclature_id=ccr.nomenclature_id)
  ORDER BY c.event_cd, cnvtdatetime(c.event_end_dt_tm)
  HEAD REPORT
   elim->cnt = 0, spirit->support_cnt = 0, sensory->visual_cnt = 0,
   sensory->speech_cnt = 0, sensory->hear_cnt = 0, education->barriers_cnt = 0,
   education->pref_cnt = 0, education->need_cnt = 0
  DETAIL
   IF (c.event_cd=trans_cd)
    med->trans = c.event_tag, med->transdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->transdate = c.event_end_dt_tm,
    med->transdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->trans_note_ind = btest(c.subtable_bit_map,1), med->trans_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->trans_status = 1, med->trans_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->trans_status_dt_tm = c.verified_dt_tm,
     med->trans_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->trans_status = 2, med->trans_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->trans_status_dt_tm = c.verified_dt_tm,
     med->trans_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=elim_cd)
    elim->list = c.event_tag, elim->doc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)
     ), elim->date = c.event_end_dt_tm,
    elim->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),"mm/dd/yy hh:mm;;d"),
     " ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm)), elim->note_ind =
    btest(c.subtable_bit_map,1), elim->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     elim->status = 1, elim->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), elim->status_dt_tm = c.verified_dt_tm,
     elim->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),"mm/dd/yy hh:mm;;d"
       )," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm))
    ELSEIF (c.result_status_cd=modified_cd)
     elim->status = 2, elim->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), elim->status_dt_tm = c.verified_dt_tm,
     elim->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),"mm/dd/yy hh:mm;;d"
       )," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm))
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     elim->cnt = (elim->cnt+ 1), stat = alterlist(elim->qual,elim->cnt), elim->qual[elim->cnt].line
      = n.source_string
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     FOR (b = 1 TO elim->cnt)
       IF (b=1)
        elim->line3 = concat(trim(elim->qual[b].line))
       ELSE
        elim->line3 = concat(trim(elim->line3),", ",trim(elim->qual[b].line))
       ENDIF
     ENDFOR
    ELSE
     elim->line3 = " "
    ENDIF
    IF ((elim->line3 > "     ")
     AND substring(1,5,elim->line3) != "Other")
     elim->line3 = concat(trim(elim->line3),", ",trim(elim->list))
    ELSE
     elim->line3 = elim->list
    ENDIF
   ENDIF
   IF (c.event_cd=visual_cd)
    sensory->visual_list = c.event_tag, sensory->visual_doc = concat(trim(pl.name_full_formatted)," ",
     trim(cv.definition)), sensory->visual_date = c.event_end_dt_tm,
    sensory->visual_date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), sensory->visual_note_ind = btest(c.subtable_bit_map,1), sensory->visual_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     sensory->visual_status = 1, sensory->visual_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), sensory->visual_status_dt_tm = c.verified_dt_tm,
     sensory->visual_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     sensory->visual_status = 2, sensory->visual_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), sensory->visual_status_dt_tm = c.verified_dt_tm,
     sensory->visual_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     sensory->visual_cnt = (sensory->visual_cnt+ 1), stat = alterlist(sensory->visual_qual,sensory->
      visual_cnt), sensory->visual_qual[sensory->visual_cnt].visual_line = n.source_string
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     FOR (b = 1 TO sensory->visual_cnt)
       IF (b=1)
        sensory->visual_line3 = concat(trim(sensory->visual_qual[b].visual_line))
       ELSE
        sensory->visual_line3 = concat(trim(sensory->visual_line3),", ",trim(sensory->visual_qual[b].
          visual_line))
       ENDIF
     ENDFOR
    ELSE
     sensory->visual_line3 = " "
    ENDIF
    IF ((sensory->visual_line3 > "     ")
     AND substring(1,5,sensory->visual_line3) != "Other")
     sensory->visual_line3 = concat(trim(sensory->visual_line3),", ",trim(sensory->visual_list))
    ELSE
     sensory->visual_line3 = sensory->visual_list
    ENDIF
   ENDIF
   IF (c.event_cd=hear_cd)
    sensory->hear_list = c.event_tag, sensory->hear_doc = concat(trim(pl.name_full_formatted)," ",
     trim(cv.definition)), sensory->hear_date = c.event_end_dt_tm,
    sensory->hear_date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), sensory->hear_note_ind = btest(c.subtable_bit_map,1), sensory->hear_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     sensory->hear_status = 1, sensory->hear_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), sensory->hear_status_dt_tm = c.verified_dt_tm,
     sensory->hear_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     sensory->hear_status = 2, sensory->hear_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), sensory->hear_status_dt_tm = c.verified_dt_tm,
     sensory->hear_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     sensory->hear_cnt = (sensory->hear_cnt+ 1), stat = alterlist(sensory->hear_qual,sensory->
      hear_cnt), sensory->hear_qual[sensory->hear_cnt].hear_line = n.source_string
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     FOR (b = 1 TO sensory->hear_cnt)
       IF (b=1)
        sensory->hear_line3 = concat(trim(sensory->hear_qual[b].hear_line))
       ELSE
        sensory->hear_line3 = concat(trim(sensory->hear_line3),", ",trim(sensory->hear_qual[b].
          hear_line))
       ENDIF
     ENDFOR
    ELSE
     sensory->hear_line3 = " "
    ENDIF
    IF ((sensory->hear_line3 > "     ")
     AND substring(1,5,sensory->hear_line3) != "Other")
     sensory->hear_line3 = concat(trim(sensory->hear_line3),", ",trim(sensory->hear_list))
    ELSE
     sensory->hear_line3 = sensory->hear_list
    ENDIF
   ENDIF
   IF (c.event_cd=speech_cd)
    sensory->speech_list = c.event_tag, sensory->speech_doc = concat(trim(pl.name_full_formatted)," ",
     trim(cv.definition)), sensory->speech_date = c.event_end_dt_tm,
    sensory->speech_date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), sensory->speech_note_ind = btest(c.subtable_bit_map,1), sensory->speech_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     sensory->speech_status = 1, sensory->speech_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), sensory->speech_status_dt_tm = c.verified_dt_tm,
     sensory->speech_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     sensory->speech_status = 2, sensory->speech_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), sensory->speech_status_dt_tm = c.verified_dt_tm,
     sensory->speech_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     sensory->speech_cnt = (sensory->speech_cnt+ 1), stat = alterlist(sensory->speech_qual,sensory->
      speech_cnt), sensory->speech_qual[sensory->speech_cnt].speech_line = n.source_string
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     FOR (b = 1 TO sensory->speech_cnt)
       IF (b=1)
        sensory->speech_line3 = concat(trim(sensory->speech_qual[b].speech_line))
       ELSE
        sensory->speech_line3 = concat(trim(sensory->speech_line3),", ",trim(sensory->speech_qual[b].
          speech_line))
       ENDIF
     ENDFOR
    ELSE
     sensory->speech_line3 = " "
    ENDIF
    IF ((sensory->speech_line3 > "     ")
     AND substring(1,5,sensory->speech_line3) != "Other")
     sensory->speech_line3 = concat(trim(sensory->speech_line3),", ",trim(sensory->speech_list))
    ELSE
     sensory->speech_line3 = sensory->speech_list
    ENDIF
   ENDIF
   IF (c.event_cd=support_cd)
    spirit->support_list = c.event_tag, spirit->support_doc = concat(trim(pl.name_full_formatted)," ",
     trim(cv.definition)), spirit->support_date = c.event_end_dt_tm,
    spirit->support_date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), spirit->support_note_ind = btest(c.subtable_bit_map,1), spirit->support_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     spirit->support_status = 1, spirit->support_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), spirit->support_status_dt_tm = c.verified_dt_tm,
     spirit->support_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     spirit->support_status = 2, spirit->support_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), spirit->support_status_dt_tm = c.verified_dt_tm,
     spirit->support_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     spirit->support_cnt = (spirit->support_cnt+ 1), stat = alterlist(spirit->support_qual,spirit->
      support_cnt), spirit->support_qual[spirit->support_cnt].support_line = n.source_string
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     FOR (b = 1 TO spirit->support_cnt)
       IF (b=1)
        spirit->support_line3 = concat(trim(spirit->support_qual[b].support_line))
       ELSE
        spirit->support_line3 = concat(trim(spirit->support_line3),", ",trim(spirit->support_qual[b].
          support_line))
       ENDIF
     ENDFOR
    ELSE
     spirit->support_line3 = " "
    ENDIF
    IF ((spirit->support_line3 > "     ")
     AND substring(1,5,spirit->support_line3) != "Other")
     spirit->support_line3 = concat(trim(spirit->support_line3),", ",trim(spirit->support_list))
    ELSE
     spirit->support_line3 = spirit->support_list
    ENDIF
   ENDIF
   IF (c.event_cd=edpref_cd)
    education->pref_list = c.event_tag, education->pref_doc = concat(trim(pl.name_full_formatted)," ",
     trim(cv.definition)), education->pref_date = c.event_end_dt_tm,
    education->pref_date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), education->pref_note_ind = btest(c.subtable_bit_map,1), education->pref_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     education->pref_status = 1, education->pref_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), education->pref_status_dt_tm = c.verified_dt_tm,
     education->pref_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     education->pref_status = 2, education->pref_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), education->pref_status_dt_tm = c.verified_dt_tm,
     education->pref_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     education->pref_cnt = (education->pref_cnt+ 1), stat = alterlist(education->pref_qual,education
      ->pref_cnt), education->pref_qual[education->pref_cnt].pref_line = n.source_string
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     FOR (b = 1 TO education->pref_cnt)
       IF (b=1)
        education->pref_line3 = concat(trim(education->pref_qual[b].pref_line))
       ELSE
        education->pref_line3 = concat(trim(education->pref_line3),", ",trim(education->pref_qual[b].
          pref_line))
       ENDIF
     ENDFOR
    ELSE
     education->pref_line3 = " "
    ENDIF
    IF ((education->pref_line3 > "     ")
     AND substring(1,5,education->pref_line3) != "Other")
     education->pref_line3 = concat(trim(education->pref_line3),", ",trim(education->pref_list))
    ELSE
     education->pref_line3 = education->pref_list
    ENDIF
   ENDIF
   IF (c.event_cd=barriers_cd)
    education->barriers_list = c.event_tag, education->barriers_doc = concat(trim(pl
      .name_full_formatted)," ",trim(cv.definition)), education->barriers_date = c.event_end_dt_tm,
    education->barriers_date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), education->barriers_note_ind = btest(c.subtable_bit_map,1), education->barriers_event_id =
    c.event_id
    IF (c.result_status_cd=inerror_cd)
     education->barriers_status = 1, education->barriers_status_name = concat(trim(pl2
       .name_full_formatted)," ",trim(cv2.definition)), education->barriers_status_dt_tm = c
     .verified_dt_tm,
     education->barriers_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     education->barriers_status = 2, education->barriers_status_name = concat(trim(pl2
       .name_full_formatted)," ",trim(cv2.definition)), education->barriers_status_dt_tm = c
     .verified_dt_tm,
     education->barriers_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     education->barriers_cnt = (education->barriers_cnt+ 1), stat = alterlist(education->
      barriers_qual,education->barriers_cnt), education->barriers_qual[education->barriers_cnt].
     barriers_line = n.source_string
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     FOR (b = 1 TO education->barriers_cnt)
       IF (b=1)
        education->barriers_line3 = concat(trim(education->barriers_qual[b].barriers_line))
       ELSE
        education->barriers_line3 = concat(trim(education->barriers_line3),", ",trim(education->
          barriers_qual[b].barriers_line))
       ENDIF
     ENDFOR
    ELSE
     education->barriers_line3 = " "
    ENDIF
    IF ((education->barriers_line3 > "     ")
     AND substring(1,5,education->barriers_line3) != "Other")
     education->barriers_line3 = concat(trim(education->barriers_line3),", ",trim(education->
       barriers_list))
    ELSE
     education->barriers_line3 = education->barriers_list
    ENDIF
   ENDIF
   IF (c.event_cd=need_cd)
    education->need_list = c.event_tag, education->need_doc = concat(trim(pl.name_full_formatted)," ",
     trim(cv.definition)), education->need_date = c.event_end_dt_tm,
    education->need_date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), education->need_note_ind = btest(c.subtable_bit_map,1), education->need_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     education->need_status = 1, education->need_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), education->need_status_dt_tm = c.verified_dt_tm,
     education->need_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     education->need_status = 2, education->need_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), education->need_status_dt_tm = c.verified_dt_tm,
     education->need_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     education->need_cnt = (education->need_cnt+ 1), stat = alterlist(education->need_qual,education
      ->need_cnt), education->need_qual[education->need_cnt].need_line = n.source_string
    ENDIF
    IF (substring(1,5,c.event_tag)="Other")
     FOR (b = 1 TO education->need_cnt)
       IF (b=1)
        education->need_line3 = concat(trim(education->need_qual[b].need_line))
       ELSE
        education->need_line3 = concat(trim(education->need_line3),", ",trim(education->need_qual[b].
          need_line))
       ENDIF
     ENDFOR
    ELSE
     education->need_line3 = " "
    ENDIF
    IF ((education->need_line3 > "     ")
     AND substring(1,5,education->need_line3) != "Other")
     education->need_line3 = concat(trim(education->need_line3),", ",trim(education->need_list))
    ELSE
     education->need_line3 = education->need_list
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  c.event_cd, c.person_id, c.event_end_dt_tm,
  c.encntr_id, c.performed_prsnl_id, cv.code_value,
  cv2.code_value, pl.person_id, pl2.person_id,
  c.event_id, ccr.event_id, n.nomenclature_id,
  n.source_string
  FROM clinical_event c,
   prsnl pl,
   prsnl pl2,
   code_value cv,
   code_value cv2,
   nomenclature n,
   ce_coded_result ccr
  PLAN (c
   WHERE (c.encntr_id=request->visit[1].encntr_id)
    AND c.event_cd IN (prosthetic_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
   JOIN (pl2
   WHERE pl2.person_id=c.verified_prsnl_id)
   JOIN (ccr
   WHERE ccr.event_id=c.event_id)
   JOIN (cv
   WHERE cv.code_value=pl.position_cd)
   JOIN (cv2
   WHERE cv2.code_value=pl2.position_cd)
   JOIN (n
   WHERE n.nomenclature_id=ccr.nomenclature_id)
  ORDER BY c.event_cd, cnvtdatetime(c.event_end_dt_tm) DESC, ccr.sequence_nbr
  HEAD REPORT
   cnt = 0, first_time = "Y"
  HEAD c.event_end_dt_tm
   IF (first_time="Y")
    IF (c.event_cd=prosthetic_cd)
     prosthetic->list = c.event_tag, prosthetic->doc = concat(trim(pl.name_full_formatted)," ",trim(
       cv.definition)), prosthetic->date = c.event_end_dt_tm,
     prosthetic->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c
       .event_end_dt_tm)), prosthetic->note_ind = btest(c.subtable_bit_map,1), prosthetic->event_id
      = c.event_id
     IF (c.result_status_cd=inerror_cd)
      prosthetic->status = 1, prosthetic->status_name = concat(trim(pl2.name_full_formatted)," ",trim
       (cv2.definition)), prosthetic->status_dt_tm = c.verified_dt_tm,
      prosthetic->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
        "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm
        ))
     ELSEIF (c.result_status_cd=modified_cd)
      prosthetic->status = 2, prosthetic->status_name = concat(trim(pl2.name_full_formatted)," ",trim
       (cv2.definition)), prosthetic->status_dt_tm = c.verified_dt_tm,
      prosthetic->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
        "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm
        ))
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (first_time="Y")
    IF ((prosthetic->list > " "))
     cnt = (cnt+ 1), prosthetic->cnt = cnt, stat = alterlist(prosthetic->qual,cnt),
     prosthetic->qual[cnt].line = n.source_string
    ENDIF
    IF ((prosthetic->list > " "))
     FOR (b = 1 TO prosthetic->cnt)
       IF (b=1)
        prosthetic->list = concat(trim(prosthetic->qual[b].line))
       ELSE
        prosthetic->list = concat(trim(prosthetic->list),",",trim(prosthetic->qual[b].line))
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
  FOOT  c.event_end_dt_tm
   first_time = "N"
  WITH nocounter
 ;end select
 CALL echo(build("cd--",inerror_cd))
 SELECT INTO "nl:"
  c.event_cd, c.person_id, c.encntr_id,
  c.event_end_dt_tm, c.performed_prsnl_id, cv.code_value,
  cv2.code_value, pl.person_id, pl2.person_id
  FROM clinical_event c,
   code_value cv,
   code_value cv2,
   prsnl pl,
   prsnl pl2
  PLAN (c
   WHERE (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND c.event_cd IN (weight_cd, height_cd, emergcon_cd, immun_cd, arrival_cd,
   pregnant_cd, lmp_cd, histdef_cd, hmphone_cd, wkphone_cd,
   edc_cd, tetanus_cd, doctor_cd, cell_cd, pager_cd,
   complaint_cd, nutrition_cd, function_cd, latex1_cd, latex2_cd,
   hosp_cd, drug_cd, alc_cd, tobac_cd, latex3_cd,
   home_cd, lives_cd, tran_cd, care_cd, referral_cd,
   psycho_cd, pref_cd, neuro_cd, cva_cd, brain_cd,
   eent_cd, mental_cd, heart_cd, hyper_cd, pacemaker_cd,
   defib_cd, pulmonary_cd, tb_cd, gi_cd, hepatitis_cd,
   endo_cd, bone_cd, ortho_cd, implant_cd, blood_cd,
   cancer_cd, skin_cd, rash_cd, infect_cd, other_cd,
   gugyn_cd, renal_cd, surg_cd, curtreat_cd, so_cd,
   treat_cd, curmed_cd, trans_cd))
   JOIN (pl
   WHERE pl.person_id=c.performed_prsnl_id)
   JOIN (pl2
   WHERE pl2.person_id=c.verified_prsnl_id)
   JOIN (cv
   WHERE cv.code_value=pl.position_cd)
   JOIN (cv2
   WHERE cv2.code_value=pl2.position_cd)
  ORDER BY c.event_cd, cnvtdatetime(c.event_end_dt_tm) DESC
  HEAD REPORT
   curmed->cnt = 0, curtreat->cnt = 0, surg->cnt = 0,
   tot = 0
  HEAD c.event_cd
   person_id = c.person_id
   IF (c.event_cd=weight_cd)
    temp->weight = cnvtreal(c.event_tag), temp->weight_note_ind = btest(c.subtable_bit_map,1), temp->
    weight_event_id = c.event_id
   ELSEIF (c.event_cd=height_cd)
    temp->height = cnvtreal(c.event_tag), temp->height_note_ind = btest(c.subtable_bit_map,1), temp->
    height_event_id = c.event_id
   ELSEIF (c.event_cd=emergcon_cd)
    temp->emergcon = c.event_tag, temp->emergcon_note_ind = btest(c.subtable_bit_map,1), temp->
    emergcon_event_id = c.event_id
   ELSEIF (c.event_cd=immun_cd)
    temp->immun = c.event_tag, temp->immun_note_ind = btest(c.subtable_bit_map,1), temp->
    immun_event_id = c.event_id
   ELSEIF (c.event_cd=arrival_cd)
    temp->arrival = c.event_tag, temp->arrival_note_ind = btest(c.subtable_bit_map,1), temp->
    arrival_event_id = c.event_id
   ELSEIF (c.event_cd=pregnant_cd)
    temp->pregnant = c.event_tag, temp->pregnant_note_ind = btest(c.subtable_bit_map,1), temp->
    pregnant_event_id = c.event_id
   ELSEIF (c.event_cd=lmp_cd)
    temp->lmp = c.event_tag, temp->lmp_note_ind = btest(c.subtable_bit_map,1), temp->lmp_event_id = c
    .event_id
   ELSEIF (c.event_cd=histdef_cd)
    temp->histdef = c.event_tag, temp->histdef_note_ind = btest(c.subtable_bit_map,1), temp->
    histdef_event_id = c.event_id
   ELSEIF (c.event_cd=hmphone_cd)
    temp->hmphone = c.event_tag, temp->hmphone_note_ind = btest(c.subtable_bit_map,1), temp->
    hmphone_event_id = c.event_id
   ELSEIF (c.event_cd=wkphone_cd)
    temp->wkphone = c.event_tag, temp->wkphone_note_ind = btest(c.subtable_bit_map,1), temp->
    wkphone_event_id = c.event_id
   ELSEIF (c.event_cd=edc_cd)
    temp->edc = c.event_tag, temp->edc_note_ind = btest(c.subtable_bit_map,1), temp->edc_event_id = c
    .event_id
   ELSEIF (c.event_cd=tetanus_cd)
    temp->tetanus = c.event_tag, temp->tetanus_note_ind = btest(c.subtable_bit_map,1), temp->
    tetanus_event_id = c.event_id
   ELSEIF (c.event_cd=doctor_cd)
    temp->doctor = c.event_tag, temp->doctor_note_ind = btest(c.subtable_bit_map,1), temp->
    doctor_event_id = c.event_id
   ELSEIF (c.event_cd=cell_cd)
    temp->cell = c.event_tag, temp->cell_note_ind = btest(c.subtable_bit_map,1), temp->cell_event_id
     = c.event_id
   ELSEIF (c.event_cd=pager_cd)
    temp->pager = c.event_tag, temp->pager_note_ind = btest(c.subtable_bit_map,1), temp->
    pager_event_id = c.event_id
   ELSEIF (c.event_cd=complaint_cd)
    temp->complaint = c.event_tag, temp->complaint_note_ind = btest(c.subtable_bit_map,1), temp->
    complaint_event_id = c.event_id
   ENDIF
   IF (c.event_cd=nutrition_cd)
    nutrition->list = c.event_tag, nutrition->doc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), nutrition->date = c.event_end_dt_tm,
    nutrition->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), nutrition->note_ind = btest(c.subtable_bit_map,1), nutrition->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     nutrition->status = 1, nutrition->status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), nutrition->status_dt_tm = c.verified_dt_tm,
     nutrition->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     nutrition->status = 2, nutrition->status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), nutrition->status_dt_tm = c.verified_dt_tm,
     nutrition->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=function_cd)
    function->list = c.event_tag, function->doc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), function->date = c.event_end_dt_tm,
    function->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), function->note_ind = btest(c.subtable_bit_map,1), function->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     function->status = 1, function->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), function->status_dt_tm = c.verified_dt_tm,
     function->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     function->status = 2, function->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), function->status_dt_tm = c.verified_dt_tm,
     function->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=latex1_cd)
    allergy->latex1 = c.event_tag, allergy->doc1 = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), allergy->date1 = c.event_end_dt_tm,
    allergy->date1_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), allergy->note1_ind = btest(c.subtable_bit_map,1), allergy->event1_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     allergy->latex1_status = 1, allergy->latex1_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), allergy->latex1_status_dt_tm = c.verified_dt_tm,
     allergy->latex1_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     allergy->latex1_status = 2, allergy->latex1_status_name = concat(trim(pl2.name_full_formatted),
      " ",cv2.definition), allergy->latex1_status_dt_tm = c.verified_dt_tm,
     allergy->latex1_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=latex2_cd)
    allergy->latex2 = c.event_tag, allergy->doc2 = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), allergy->date2 = c.event_end_dt_tm,
    allergy->date2_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), allergy->note2_ind = btest(c.subtable_bit_map,1), allergy->event2_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     allergy->latex2_status = 1, allergy->latex2_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), allergy->latex2_status_dt_tm = c.verified_dt_tm,
     allergy->latex2_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     allergy->latex2_status = 2, allergy->latex2_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), allergy->latex2_status_dt_tm = c.verified_dt_tm,
     allergy->latex2_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=latex3_cd)
    allergy->latex3 = c.event_tag, allergy->doc3 = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), allergy->date3 = c.event_end_dt_tm,
    allergy->date3_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), allergy->note3_ind = btest(c.subtable_bit_map,1), allergy->event3_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     allergy->latex3_status = 1, allergy->latex3_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), allergy->latex3_status_dt_tm = c.verified_dt_tm,
     allergy->latex3_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     allergy->latex3_status = 2, allergy->latex3_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), allergy->latex3_status_dt_tm = c.verified_dt_tm,
     allergy->latex3_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=home_cd)
    discharge->home = c.event_tag, discharge->homedoc = concat(trim(pl.name_full_formatted)," ",trim(
      cv.definition)), discharge->homedate = c.event_end_dt_tm,
    discharge->homedate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), discharge->home_note_ind = btest(c.subtable_bit_map,1), discharge->home_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     discharge->home_status = 1, discharge->home_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), discharge->home_status_dt_tm = c.verified_dt_tm,
     discharge->home_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     discharge->home_status = 2, discharge->home_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), discharge->home_status_dt_tm = c.verified_dt_tm,
     discharge->home_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=lives_cd)
    discharge->lives = c.event_tag, discharge->livesdoc = concat(trim(pl.name_full_formatted)," ",
     trim(cv.definition)), discharge->livesdate = c.event_end_dt_tm,
    discharge->livesdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), discharge->lives_note_ind = btest(c.subtable_bit_map,1), discharge->lives_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     discharge->lives_status = 1, discharge->lives_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), discharge->lives_status_dt_tm = c.verified_dt_tm,
     discharge->lives_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     discharge->lives_status = 2, discharge->lives_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), discharge->lives_status_dt_tm = c.verified_dt_tm,
     discharge->lives_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=tran_cd)
    discharge->tran = c.event_tag, discharge->trandoc = concat(trim(pl.name_full_formatted)," ",trim(
      cv.definition)), discharge->trandate = c.event_end_dt_tm,
    discharge->trandate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), discharge->tran_note_ind = btest(c.subtable_bit_map,1), discharge->tran_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     discharge->tran_status = 1, discharge->tran_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), discharge->tran_status_dt_tm = c.verified_dt_tm,
     discharge->tran_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     discharge->tran_status = 2, discharge->tran_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), discharge->tran_status_dt_tm = c.verified_dt_tm,
     discharge->tran_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=care_cd)
    discharge->care = c.event_tag, discharge->caredoc = concat(trim(pl.name_full_formatted)," ",trim(
      cv.definition)), discharge->caredate = c.event_end_dt_tm,
    discharge->caredate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), discharge->care_note_ind = btest(c.subtable_bit_map,1), discharge->care_event_id = c
    .event_id
    IF (c.result_status_cd=inerror_cd)
     discharge->care_status = 1, discharge->care_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), discharge->care_status_dt_tm = c.verified_dt_tm,
     discharge->care_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     discharge->care_status = 2, discharge->care_status_name = concat(trim(pl2.name_full_formatted),
      " ",trim(cv2.definition)), discharge->care_status_dt_tm = c.verified_dt_tm,
     discharge->care_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=referral_cd)
    discharge->referral = c.event_tag, discharge->referraldoc = concat(trim(pl.name_full_formatted),
     " ",trim(cv.definition)), discharge->referraldate = c.event_end_dt_tm,
    discharge->referraldate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), discharge->referral_note_ind = btest(c.subtable_bit_map,1), discharge->referral_event_id =
    c.event_id
    IF (c.result_status_cd=inerror_cd)
     discharge->referral_status = 1, discharge->referral_status_name = concat(trim(pl2
       .name_full_formatted)," ",trim(cv2.definition)), discharge->referral_status_dt_tm = c
     .verified_dt_tm,
     discharge->referral_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     discharge->referral_status = 2, discharge->referral_status_name = concat(trim(pl2
       .name_full_formatted)," ",trim(cv2.definition)), discharge->referral_status_dt_tm = c
     .verified_dt_tm,
     discharge->referral_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=psycho_cd)
    psycho->list = c.event_tag, psycho->doc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), psycho->date = c.event_end_dt_tm,
    psycho->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), psycho->note_ind = btest(c.subtable_bit_map,1), psycho->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     psycho->status = 1, psycho->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), psycho->status_dt_tm = c.verified_dt_tm,
     psycho->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     psycho->status = 2, psycho->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), psycho->status_dt_tm = c.verified_dt_tm,
     psycho->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=pref_cd)
    spirit->pref = c.event_tag, spirit->prefdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), spirit->prefdate = c.event_end_dt_tm,
    spirit->prefdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), spirit->pref_note_ind = btest(c.subtable_bit_map,1), spirit->pref_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     spirit->pref_status = 1, spirit->pref_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), spirit->pref_status_dt_tm = c.verified_dt_tm,
     spirit->pref_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     spirit->pref_status = 2, spirit->pref_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), spirit->pref_status_dt_tm = c.verified_dt_tm,
     spirit->pref_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=neuro_cd)
    med->neuro = c.event_tag, med->neurodoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->neurodate = c.event_end_dt_tm,
    med->neurodate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->neuro_note_ind = btest(c.subtable_bit_map,1), med->neuro_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->neuro_status = 1, med->neuro_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->neuro_status_dt_tm = c.verified_dt_tm,
     med->neuro_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->neuro_status = 2, med->neuro_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->neuro_status_dt_tm = c.verified_dt_tm,
     med->neuro_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=cva_cd)
    med->cva = c.event_tag, med->cvadoc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)
     ), med->cvadate = c.event_end_dt_tm,
    med->cvadate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->cva_note_ind = btest(c.subtable_bit_map,1), med->cva_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->cva_status = 1, med->cva_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->cva_status_dt_tm = c.verified_dt_tm,
     med->cva_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->cva_status = 2, med->cva_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->cva_status_dt_tm = c.verified_dt_tm,
     med->cva_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=brain_cd)
    med->brain = c.event_tag, med->braindoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->braindate = c.event_end_dt_tm,
    med->braindate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->brain_note_ind = btest(c.subtable_bit_map,1), med->brain_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->brain_status = 1, med->brain_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->brain_status_dt_tm = c.verified_dt_tm,
     med->brain_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->brain_status = 2, med->brain_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->brain_status_dt_tm = c.verified_dt_tm,
     med->brain_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=eent_cd)
    med->eent = c.event_tag, med->eentdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->eentdate = c.event_end_dt_tm,
    med->eentdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->eent_note_ind = btest(c.subtable_bit_map,1), med->eent_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->eent_status = 1, med->eent_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->eent_status_dt_tm = c.verified_dt_tm,
     med->eent_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->eent_status = 2, med->eent_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->eent_status_dt_tm = c.verified_dt_tm,
     med->eent_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=mental_cd)
    med->mental = c.event_tag, med->mentaldoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->mentaldate = c.event_end_dt_tm,
    med->mentaldate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->mental_note_ind = btest(c.subtable_bit_map,1), med->mental_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->mental_status = 1, med->mental_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->mental_status_dt_tm = c.verified_dt_tm,
     med->mental_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->mental_status = 2, med->mental_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->mental_status_dt_tm = c.verified_dt_tm,
     med->mental_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=heart_cd)
    med->heart = c.event_tag, med->heartdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->heartdate = c.event_end_dt_tm,
    med->heartdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->heart_note_ind = btest(c.subtable_bit_map,1), med->heart_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->heart_status = 1, med->heart_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->heart_status_dt_tm = c.verified_dt_tm,
     med->heart_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->heart_status = 2, med->heart_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->heart_status_dt_tm = c.verified_dt_tm,
     med->heart_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=hyper_cd)
    med->hyper = c.event_tag, med->hyperdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->hyperdate = c.event_end_dt_tm,
    med->hyperdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->hyper_note_ind = btest(c.subtable_bit_map,1), med->hyper_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->hyper_status = 1, med->hyper_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->hyper_status_dt_tm = c.verified_dt_tm,
     med->hyper_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->hyper_status = 2, med->hyper_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->hyper_status_dt_tm = c.verified_dt_tm,
     med->hyper_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=pacemaker_cd)
    med->pacemaker = c.event_tag, med->pacemakerdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->pacemakerdate = c.event_end_dt_tm,
    med->pacemakerdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->pace_note_ind = btest(c.subtable_bit_map,1), med->pace_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->pace_status = 1, med->pace_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->pace_status_dt_tm = c.verified_dt_tm,
     med->pace_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->pace_status = 2, med->pace_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->pace_status_dt_tm = c.verified_dt_tm,
     med->pace_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=defib_cd)
    med->defib = c.event_tag, med->defibdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->defibdate = c.event_end_dt_tm,
    med->defibdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->defib_note_ind = btest(c.subtable_bit_map,1), med->defib_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->defib_status = 1, med->defib_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->defib_status_dt_tm = c.verified_dt_tm,
     med->defib_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->defib_status = 2, med->defib_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->defib_status_dt_tm = c.verified_dt_tm,
     med->defib_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=pulmonary_cd)
    med->pulmonary = c.event_tag, med->pulmonarydoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->pulmonarydate = c.event_end_dt_tm,
    med->pulmonarydate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->pulm_note_ind = btest(c.subtable_bit_map,1), med->pulm_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->pulm_status = 1, med->pulm_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->pulm_status_dt_tm = c.verified_dt_tm,
     med->pulm_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->pulm_status = 2, med->pulm_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->pulm_status_dt_tm = c.verified_dt_tm,
     med->pulm_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=tb_cd)
    med->tb = c.event_tag, med->tbdoc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)),
    med->tbdate = c.event_end_dt_tm,
    med->tbdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),"mm/dd/yy hh:mm;;d"
      )," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm)), med->
    tb_note_ind = btest(c.subtable_bit_map,1), med->tb_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->tb_status = 1, med->tb_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->tb_status_dt_tm = c.verified_dt_tm,
     med->tb_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->tb_status = 2, med->tb_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->tb_status_dt_tm = c.verified_dt_tm,
     med->tb_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=gi_cd)
    med->gi = c.event_tag, med->gidoc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)),
    med->gidate = c.event_end_dt_tm,
    med->gidate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),"mm/dd/yy hh:mm;;d"
      )," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm)), med->
    gi_note_ind = btest(c.subtable_bit_map,1), med->gi_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->gi_status = 1, med->gi_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->gi_status_dt_tm = c.verified_dt_tm,
     med->gi_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->gi_status = 2, med->gi_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->gi_status_dt_tm = c.verified_dt_tm,
     med->gi_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=hepatitis_cd)
    med->hepatitis = c.event_tag, med->hepatitisdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->hepatitisdate = c.event_end_dt_tm,
    med->hepatitisdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->hep_note_ind = btest(c.subtable_bit_map,1), med->hep_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->hep_status = 1, med->hep_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->hep_status_dt_tm = c.verified_dt_tm,
     med->hep_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->hep_status = 2, med->hep_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->hep_status_dt_tm = c.verified_dt_tm,
     med->hep_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=endo_cd)
    med->endo = c.event_tag, med->endodoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->endodate = c.event_end_dt_tm,
    med->endodate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->endo_note_ind = btest(c.subtable_bit_map,1), med->endo_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->endo_status = 1, med->endo_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->endo_status_dt_tm = c.verified_dt_tm,
     med->endo_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->endo_status = 2, med->endo_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->endo_status_dt_tm = c.verified_dt_tm,
     med->endo_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=bone_cd)
    med->bone = c.event_tag, med->bonedoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->bonedate = c.event_end_dt_tm,
    med->bonedate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->bone_note_ind = btest(c.subtable_bit_map,1), med->bone_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->bone_status = 1, med->bone_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->bone_status_dt_tm = c.verified_dt_tm,
     med->bone_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->bone_status = 2, med->bone_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->bone_status_dt_tm = c.verified_dt_tm,
     med->bone_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=ortho_cd)
    med->ortho = c.event_tag, med->orthodoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->orthodate = c.event_end_dt_tm,
    med->orthodate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->ortho_note_ind = btest(c.subtable_bit_map,1), med->ortho_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->ortho_status = 1, med->ortho_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->ortho_status_dt_tm = c.verified_dt_tm,
     med->ortho_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->ortho_status = 2, med->ortho_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->ortho_status_dt_tm = c.verified_dt_tm,
     med->ortho_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=implant_cd)
    med->implant = c.event_tag, med->implantdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->implantdate = c.event_end_dt_tm,
    med->implantdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->implant_note_ind = btest(c.subtable_bit_map,1), med->implant_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->implant_status = 1, med->implant_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), med->implant_status_dt_tm = c.verified_dt_tm,
     med->implant_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->implant_status = 2, med->implant_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), med->implant_status_dt_tm = c.verified_dt_tm,
     med->implant_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=blood_cd)
    med->blood = c.event_tag, med->blooddoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->blooddate = c.event_end_dt_tm,
    med->blooddate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->blood_note_ind = btest(c.subtable_bit_map,1), med->blood_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->blood_status = 1, med->blood_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->blood_status_dt_tm = c.verified_dt_tm,
     med->blood_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->blood_status = 2, med->blood_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->blood_status_dt_tm = c.verified_dt_tm,
     med->blood_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=cancer_cd)
    med->cancer = c.event_tag, med->cancerdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->cancerdate = c.event_end_dt_tm,
    med->cancerdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->cancer_note_ind = btest(c.subtable_bit_map,1), med->cancer_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->cancer_status = 1, med->cancer_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->cancer_status_dt_tm = c.verified_dt_tm,
     med->cancer_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->cancer_status = 2, med->cancer_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->cancer_status_dt_tm = c.verified_dt_tm,
     med->cancer_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=skin_cd)
    med->skin = c.event_tag, med->skindoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->skindate = c.event_end_dt_tm,
    med->skindate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->skin_note_ind = btest(c.subtable_bit_map,1), med->skin_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->skin_status = 1, med->skin_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->skin_status_dt_tm = c.verified_dt_tm,
     med->skin_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->skin_status = 2, med->skin_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->skin_status_dt_tm = c.verified_dt_tm,
     med->skin_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=rash_cd)
    med->rash = c.event_tag, med->rashdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->rashdate = c.event_end_dt_tm,
    med->rashdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->rash_note_ind = btest(c.subtable_bit_map,1), med->rash_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->rash_status = 1, med->rash_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->rash_status_dt_tm = c.verified_dt_tm,
     med->rash_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->rash_status = 2, med->rash_status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), med->rash_status_dt_tm = c.verified_dt_tm,
     med->rash_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=infect_cd)
    med->infect = c.event_tag, med->infectdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->infectdate = c.event_end_dt_tm,
    med->infectdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->infect_note_ind = btest(c.subtable_bit_map,1), med->infect_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->infect_status = 1, med->infect_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->infect_status_dt_tm = c.verified_dt_tm,
     med->infect_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->infect_status = 2, med->infect_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->infect_status_dt_tm = c.verified_dt_tm,
     med->infect_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=other_cd)
    med->other = c.event_tag, med->otherdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->otherdate = c.event_end_dt_tm,
    med->otherdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->other_note_ind = btest(c.subtable_bit_map,1), med->other_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->other_status = 1, med->other_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->other_status_dt_tm = c.verified_dt_tm,
     med->other_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->other_status = 2, med->other_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->other_status_dt_tm = c.verified_dt_tm,
     med->other_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=gugyn_cd)
    med->gugyn = c.event_tag, med->gugyndoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->gugyndate = c.event_end_dt_tm,
    med->gugyndate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->gugyn_note_ind = btest(c.subtable_bit_map,1), med->gugyn_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->gugyn_status = 1, med->gugyn_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->gugyn_status_dt_tm = c.verified_dt_tm,
     med->gugyn_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->gugyn_status = 2, med->gugyn_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->gugyn_status_dt_tm = c.verified_dt_tm,
     med->gugyn_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=renal_cd)
    med->renal = c.event_tag, med->renaldoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), med->renaldate = c.event_end_dt_tm,
    med->renaldate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), med->renal_note_ind = btest(c.subtable_bit_map,1), med->renal_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     med->renal_status = 1, med->renal_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->renal_status_dt_tm = c.verified_dt_tm,
     med->renal_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     med->renal_status = 2, med->renal_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), med->renal_status_dt_tm = c.verified_dt_tm,
     med->renal_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=so_cd)
    education->so = c.event_tag, education->sodoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), education->sodate = c.event_end_dt_tm,
    education->sodate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), education->so_note_ind = btest(c.subtable_bit_map,1), education->so_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     education->so_status = 1, education->so_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), education->so_status_dt_tm = c.verified_dt_tm,
     education->so_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     education->so_status = 2, education->so_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), education->so_status_dt_tm = c.verified_dt_tm,
     education->so_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=treat_cd)
    treat->list = c.event_tag, treat->doc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), treat->date = c.event_end_dt_tm,
    treat->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),"mm/dd/yy hh:mm;;d"
      )," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm)), treat->note_ind
     = btest(c.subtable_bit_map,1), treat->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     treat->status = 1, treat->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), treat->status_dt_tm = c.verified_dt_tm,
     treat->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     treat->status = 2, treat->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), treat->status_dt_tm = c.verified_dt_tm,
     treat->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=hosp_cd)
    hosp->list = c.event_tag, hosp->doc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)
     ), hosp->date = c.event_end_dt_tm,
    hosp->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),"mm/dd/yy hh:mm;;d"),
     " ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm)), hosp->note_ind =
    btest(c.subtable_bit_map,1), hosp->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     hosp->status = 1, hosp->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), hosp->status_dt_tm = c.verified_dt_tm,
     hosp->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),"mm/dd/yy hh:mm;;d"
       )," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm))
    ELSEIF (c.result_status_cd=modified_cd)
     hosp->status = 2, hosp->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), hosp->status_dt_tm = c.verified_dt_tm,
     hosp->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),"mm/dd/yy hh:mm;;d"
       )," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm))
    ENDIF
   ENDIF
   IF (c.event_cd=drug_cd)
    habit->drug = c.event_tag, habit->drugdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), habit->drugdate = c.event_end_dt_tm,
    habit->drugdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), habit->drug_note_ind = btest(c.subtable_bit_map,1), habit->drug_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     habit->drug_status = 1, habit->drug_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), habit->drug_status_dt_tm = c.verified_dt_tm,
     habit->drug_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     habit->drug_status = 2, habit->drug_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), habit->drug_status_dt_tm = c.verified_dt_tm,
     habit->drug_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=alc_cd)
    habit->alc = c.event_tag, habit->alcdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), habit->alcdate = c.event_end_dt_tm,
    habit->alcdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), habit->alc_note_ind = btest(c.subtable_bit_map,1), habit->alc_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     habit->alc_status = 1, habit->alc_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), habit->alc_status_dt_tm = c.verified_dt_tm,
     habit->alc_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     habit->alc_status = 2, habit->alc_status_name = concat(trim(pl2.name_full_formatted)," ",trim(
       cv2.definition)), habit->alc_status_dt_tm = c.verified_dt_tm,
     habit->alc_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ELSEIF (c.event_cd=tobac_cd)
    habit->tobac = c.event_tag, habit->tobacdoc = concat(trim(pl.name_full_formatted)," ",trim(cv
      .definition)), habit->tobacdate = c.event_end_dt_tm,
    habit->tobacdate_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )), habit->tobac_note_ind = btest(c.subtable_bit_map,1), habit->tobac_event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     habit->tobac_status = 1, habit->tobac_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), habit->tobac_status_dt_tm = c.verified_dt_tm,
     habit->tobac_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     habit->tobac_status = 2, habit->tobac_status_name = concat(trim(pl2.name_full_formatted)," ",
      trim(cv2.definition)), habit->tobac_status_dt_tm = c.verified_dt_tm,
     habit->tobac_status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
   ENDIF
   IF (c.event_cd=curmed_cd)
    curmed->doc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)), curmed->date = c
    .event_end_dt_tm, curmed->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )),
    curmed->note_ind = btest(c.subtable_bit_map,1), curmed->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     curmed->status = 1, curmed->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), curmed->status_dt_tm = c.verified_dt_tm,
     curmed->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     curmed->status = 2, curmed->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), curmed->status_dt_tm = c.verified_dt_tm,
     curmed->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    blob_out = c.event_tag, a = findstring(lf,blob_out)
    WHILE (a > 0)
     stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
    ENDWHILE
    curmed->list = concat(trim(blob_out,3))
   ENDIF
   IF (c.event_cd=surg_cd)
    surg->doc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)), surg->date = c
    .event_end_dt_tm, surg->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz),
      "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c.event_end_dt_tm
      )),
    surg->note_ind = btest(c.subtable_bit_map,1), surg->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     surg->status = 1, surg->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), surg->status_dt_tm = c.verified_dt_tm,
     surg->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),"mm/dd/yy hh:mm;;d"
       )," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm))
    ELSEIF (c.result_status_cd=modified_cd)
     surg->status = 2, surg->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), surg->status_dt_tm = c.verified_dt_tm,
     surg->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),"mm/dd/yy hh:mm;;d"
       )," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm))
    ENDIF
    blob_out = c.event_tag, a = findstring(lf,blob_out)
    WHILE (a > 0)
     stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
    ENDWHILE
    surg->list = concat(trim(blob_out,3))
   ENDIF
   IF (c.event_cd=curtreat_cd)
    curtreat->doc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition)), curtreat->date = c
    .event_end_dt_tm, curtreat->date_tz = concat(format(datetimezone(c.event_end_dt_tm,c.event_end_tz
       ),"mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.event_end_tz,offset,daylight,7,c
      .event_end_dt_tm)),
    curtreat->note_ind = btest(c.subtable_bit_map,1), curtreat->event_id = c.event_id
    IF (c.result_status_cd=inerror_cd)
     curtreat->status = 1, curtreat->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), curtreat->status_dt_tm = c.verified_dt_tm,
     curtreat->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ELSEIF (c.result_status_cd=modified_cd)
     curtreat->status = 2, curtreat->status_name = concat(trim(pl2.name_full_formatted)," ",trim(cv2
       .definition)), curtreat->status_dt_tm = c.verified_dt_tm,
     curtreat->status_tz = concat(format(datetimezone(c.verified_dt_tm,c.verified_tz),
       "mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(c.verified_tz,offset,daylight,7,c.verified_dt_tm)
      )
    ENDIF
    blob_out = c.event_tag, a = findstring(lf,blob_out)
    WHILE (a > 0)
     stat = movestring("--",1,blob_out,a,2),a = findstring(lf,blob_out)
    ENDWHILE
    curtreat->list = concat(trim(blob_out,3))
   ENDIF
  DETAIL
   surg->list = concat(trim(surg->list),"--  "), tot = textlen(surg->list), a = 0,
   a = findstring("--",surg->list)
   WHILE (a > 0)
     surg->text = substring(1,(a - 1),surg->list), surg->list = substring((a+ 2),(tot - (a+ 2)),surg
      ->list), surg->cnt = (surg->cnt+ 1),
     stat = alterlist(surg->qual,surg->cnt), surg->qual[surg->cnt].line = surg->text, a = findstring(
      "--",surg->list)
   ENDWHILE
   curmed->list = concat(trim(curmed->list),"--."), tot = textlen(curmed->list), a = 0,
   a = findstring("--",curmed->list)
   WHILE (a > 0)
     curmed->text = substring(1,(a - 1),curmed->list), curmed->list = substring((a+ 2),(tot - (a+ 2)),
      curmed->list), curmed->cnt = (curmed->cnt+ 1),
     stat = alterlist(curmed->qual,curmed->cnt), curmed->qual[curmed->cnt].line = curmed->text, a =
     findstring("--",curmed->list)
   ENDWHILE
   curtreat->list = concat(trim(curtreat->list),"--."), tot = textlen(curtreat->list), a = 0,
   a = findstring("--",curtreat->list)
   WHILE (a > 0)
     curtreat->text = substring(1,(a - 1),curtreat->list), curtreat->list = substring((a+ 2),(tot - (
      a+ 2)),curtreat->list), curtreat->cnt = (curtreat->cnt+ 1),
     stat = alterlist(curtreat->qual,curtreat->cnt), curtreat->qual[curtreat->cnt].line = curtreat->
     text, a = findstring("--",curtreat->list)
   ENDWHILE
  WITH nocounter
 ;end select
 CALL echo(build("cnt--",surg->cnt))
 FOR (w = 1 TO surg->cnt)
   CALL echo(build("line--",surg->qual[w].line))
 ENDFOR
 SELECT INTO "nl:"
  a.allergy_id
  FROM allergy a,
   (dummyt d1  WITH seq = 1),
   nomenclature n,
   (dummyt d3  WITH seq = 1),
   nomenclature n2,
   (dummyt d2  WITH seq = 1),
   reaction r,
   (dummyt d4  WITH seq = 1),
   prsnl pl,
   code_value cv
  PLAN (a
   WHERE a.person_id=person_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
   JOIN (d2)
   JOIN (r
   WHERE r.allergy_id=a.allergy_id
    AND r.active_ind=1
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d3)
   JOIN (n2
   WHERE n2.nomenclature_id=r.reaction_nom_id)
   JOIN (d4)
   JOIN (pl
   WHERE pl.person_id=a.created_prsnl_id)
   JOIN (cv
   WHERE cv.code_value=pl.position_cd)
  ORDER BY a.onset_dt_tm
  HEAD REPORT
   allergy->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    allergy->cnt = (allergy->cnt+ 1), stat = alterlist(allergy->qual,allergy->cnt), allergy->qual[
    allergy->cnt].list = a.substance_ftdesc
    IF (n.source_string > " ")
     allergy->qual[allergy->cnt].list = n.source_string
    ENDIF
    IF (((r.reaction_ftdesc > " ") OR (n2.source_string > " ")) )
     allergy->qual[allergy->cnt].rlist = r.reaction_ftdesc
     IF (n2.source_string > " ")
      allergy->qual[allergy->cnt].rlist = n2.source_string
     ENDIF
    ENDIF
    allergy->qual[allergy->cnt].date = a.onset_dt_tm, allergy->qual[allergy->cnt].date_tz = concat(
     format(datetimezone(a.onset_dt_tm,a.onset_tz),"mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(a
      .onset_tz,offset,daylight,7,a.onset_dt_tm)), allergy->qual[allergy->cnt].doc = concat(trim(pl
      .name_full_formatted)," ",trim(cv.definition))
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = r,
   dontcare = n, dontcare = n2
 ;end select
 SET event_id = 0
 IF ((temp->weight_note_ind=1))
  SET event_id = temp->weight_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->weight_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->height_note_ind=1))
  SET event_id = temp->height_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->height_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->emergcon_note_ind=1))
  SET event_id = temp->emergcon_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->emergcon_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->hmphone_note_ind=1))
  SET event_id = temp->hmphone_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->hmphone_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->wkphone_note_ind=1))
  SET event_id = temp->wkphone_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->wkphone_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->cell_note_ind=1))
  SET event_id = temp->cell_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->cell_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->pager_note_ind=1))
  SET event_id = temp->pager_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->pager_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->arrival_note_ind=1))
  SET event_id = temp->arrival_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->arrival_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->histdef_note_ind=1))
  SET event_id = temp->histdef_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->histdef_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->edc_note_ind=1))
  SET event_id = temp->edc_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->edc_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->pregnant_note_ind=1))
  SET event_id = temp->pregnant_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->pregnant_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->lmp_note_ind=1))
  SET event_id = temp->lmp_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->lmp_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->immun_note_ind=1))
  SET event_id = temp->immun_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->immun_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->tetanus_note_ind=1))
  SET event_id = temp->tetanus_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->tetanus_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->complaint_note_ind=1))
  SET event_id = temp->complaint_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->complaint_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((temp->doctor_note_ind=1))
  SET event_id = temp->doctor_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET temp->doctor_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((curmed->note_ind=1))
  SET event_id = curmed->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET curmed->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->neuro_note_ind=1))
  SET event_id = med->neuro_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->neuro_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->cva_note_ind=1))
  SET event_id = med->cva_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->cva_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->brain_note_ind=1))
  SET event_id = med->brain_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->brain_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->eent_note_ind=1))
  SET event_id = med->eent_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->eent_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->mental_note_ind=1))
  SET event_id = med->mental_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->mental_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->heart_note_ind=1))
  SET event_id = med->heart_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->heart_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->hyper_note_ind=1))
  SET event_id = med->hyper_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->hyper_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->pace_note_ind=1))
  SET event_id = med->pace_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->pace_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->defib_note_ind=1))
  SET event_id = med->defib_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->defib_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->pulm_note_ind=1))
  SET event_id = med->pulm_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->pulm_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->tb_note_ind=1))
  SET event_id = med->tb_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->tb_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->gi_note_ind=1))
  SET event_id = med->gi_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->gi_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->hep_note_ind=1))
  SET event_id = med->hep_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->hep_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->endo_note_ind=1))
  SET event_id = med->endo_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->endo_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->bone_note_ind=1))
  SET event_id = med->bone_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->bone_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->ortho_note_ind=1))
  SET event_id = med->ortho_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->ortho_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->implant_note_ind=1))
  SET event_id = med->implant_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->implant_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->blood_note_ind=1))
  SET event_id = med->blood_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->blood_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->cancer_note_ind=1))
  SET event_id = med->cancer_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->cancer_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->skin_note_ind=1))
  SET event_id = med->skin_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->skin_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->rash_note_ind=1))
  SET event_id = med->rash_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->rash_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->infect_note_ind=1))
  SET event_id = med->infect_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->infect_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->trans_note_ind=1))
  SET event_id = med->trans_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->trans_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->other_note_ind=1))
  SET event_id = med->other_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->other_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->renal_note_ind=1))
  SET event_id = med->renal_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->renal_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((med->gugyn_note_ind=1))
  SET event_id = med->gugyn_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET med->gugyn_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((curtreat->note_ind=1))
  SET event_id = curtreat->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET curtreat->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((treat->note_ind=1))
  SET event_id = treat->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET treat->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((hosp->note_ind=1))
  SET event_id = hosp->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET hosp->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((habit->drug_note_ind=1))
  SET event_id = habit->drug_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET habit->drug_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((habit->alc_note_ind=1))
  SET event_id = habit->alc_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET habit->alc_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((habit->tobac_note_ind=1))
  SET event_id = habit->tobac_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET habit->tobac_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((surg->note_ind=1))
  SET event_id = surg->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET surg->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((sensory->hear_note_ind=1))
  SET event_id = sensory->hear_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET sensory->hear_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((sensory->speech_note_ind=1))
  SET event_id = sensory->speech_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET sensory->speech_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((sensory->visual_note_ind=1))
  SET event_id = sensory->visual_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET sensory->visual_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((prosthetic->note_ind=1))
  SET event_id = prosthetic->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET prosthetic->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((nutrition->note_ind=1))
  SET event_id = nutrition->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET nutrition->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((elim->note_ind=1))
  SET event_id = elim->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET elim->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((psycho->note_ind=1))
  SET event_id = psycho->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET psycho->note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((function->note_ind=1))
  SET event_id = function->event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET function->note_text = concat(trim(blob_out,3))
 ENDIF
 FOR (x = 1 TO social->cnt)
   IF ((social->qual[x].note_ind=1))
    SET event_id = social->qual[x].event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET social->qual[x].note_text = blob_out
   ENDIF
 ENDFOR
 IF ((spirit->support_note_ind=1))
  SET event_id = spirit->support_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET spirit->support_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((spirit->pref_note_ind=1))
  SET event_id = spirit->pref_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET spirit->pref_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((education->pref_note_ind=1))
  SET event_id = education->pref_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET education->pref_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((education->barriers_note_ind=1))
  SET event_id = education->barriers_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET education->barriers_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((education->need_note_ind=1))
  SET event_id = education->need_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET education->need_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((education->so_note_ind=1))
  SET event_id = education->so_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET education->so_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((discharge->home_note_ind=1))
  SET event_id = discharge->home_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET discharge->home_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((discharge->tran_note_ind=1))
  SET event_id = discharge->tran_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET discharge->tran_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((discharge->care_note_ind=1))
  SET event_id = discharge->care_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET discharge->care_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((discharge->lives_note_ind=1))
  SET event_id = discharge->lives_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET discharge->lives_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((discharge->referral_note_ind=1))
  SET event_id = discharge->referral_event_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET discharge->referral_note_text = concat(trim(blob_out,3))
 ENDIF
 IF ((allergy->note1_ind=1))
  SET event_id = allergy->event1_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET allergy->note1_text = concat(trim(blob_out,3))
 ENDIF
 IF ((allergy->note2_ind=1))
  SET event_id = allergy->event2_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET allergy->note2_text = concat(trim(blob_out,3))
 ENDIF
 IF ((allergy->note3_ind=1))
  SET event_id = allergy->event3_id
  EXECUTE FROM get_note_begin TO get_note_end
  SET allergy->note3_text = concat(trim(blob_out,3))
 ENDIF
 SET pt->line_cnt = 0
 SET max_length = 95
 SET modify = nopredeclare
 EXECUTE dcp_parse_text value(psycho->list), value(max_length)
 SET stat = alterlist(psycho->list_tag,pt->line_cnt)
 SET psycho->list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET psycho->list_tag[x].list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 95
 EXECUTE dcp_parse_text value(function->list), value(max_length)
 SET stat = alterlist(function->list_tag,pt->line_cnt)
 SET function->list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET function->list_tag[x].list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 95
 EXECUTE dcp_parse_text value(prosthetic->list), value(max_length)
 SET stat = alterlist(prosthetic->list_tag,pt->line_cnt)
 SET prosthetic->list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET prosthetic->list_tag[x].list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 95
 EXECUTE dcp_parse_text value(nutrition->list), value(max_length)
 SET stat = alterlist(nutrition->list_tag,pt->line_cnt)
 SET nutrition->list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET nutrition->list_tag[x].list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 95
 EXECUTE dcp_parse_text value(elim->line3), value(max_length)
 SET stat = alterlist(elim->list_tag,pt->line_cnt)
 SET elim->list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET elim->list_tag[x].list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 80
 EXECUTE dcp_parse_text value(sensory->visual_line3), value(max_length)
 SET stat = alterlist(sensory->visual_list_tag,pt->line_cnt)
 SET sensory->visual_list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET sensory->visual_list_tag[x].visual_list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 78
 EXECUTE dcp_parse_text value(sensory->hear_line3), value(max_length)
 SET stat = alterlist(sensory->hear_list_tag,pt->line_cnt)
 SET sensory->hear_list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET sensory->hear_list_tag[x].hear_list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 78
 EXECUTE dcp_parse_text value(sensory->speech_line3), value(max_length)
 SET stat = alterlist(sensory->speech_list_tag,pt->line_cnt)
 SET sensory->speech_list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET sensory->speech_list_tag[x].speech_list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 80
 EXECUTE dcp_parse_text value(spirit->support_line3), value(max_length)
 SET stat = alterlist(spirit->support_list_tag,pt->line_cnt)
 SET spirit->support_list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET spirit->support_list_tag[x].support_list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 37
 EXECUTE dcp_parse_text value(education->pref_line3), value(max_length)
 SET stat = alterlist(education->pref_list_tag,pt->line_cnt)
 SET education->pref_list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET education->pref_list_tag[x].pref_list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 45
 EXECUTE dcp_parse_text value(education->barriers_line3), value(max_length)
 SET stat = alterlist(education->barriers_list_tag,pt->line_cnt)
 SET education->barriers_list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET education->barriers_list_tag[x].barriers_list_line = pt->lns[x].line
 ENDFOR
 SET pt->line_cnt = 0
 SET max_length = 65
 EXECUTE dcp_parse_text value(education->need_line3), value(max_length)
 SET modify = predeclare
 SET stat = alterlist(education->need_list_tag,pt->line_cnt)
 SET education->need_list_ln_cnt = pt->line_cnt
 FOR (x = 1 TO pt->line_cnt)
   SET education->need_list_tag[x].need_list_line = pt->lns[x].line
 ENDFOR
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   thead = "                                                       ", dln = fillstring(255,"_")
  HEAD PAGE
   "{f/9}{cpi/11}", row + 1, "{POS/200/62}HOSPITAL ADMISSION DATABASE",
   row + 1, "{CPI/16}{POS/40/65}", l1,
   row + 1, "{f/8}{pos/40/77}Patient Name: ", name,
   row + 1, "{pos/300/77}Age: ", age,
   row + 1, "{pos/420/77}Financial Num: ", finnbr,
   row + 1, "{pos/40/89}MRN: ", mrn,
   row + 1, "{pos/300/89}Gender: ", sex,
   row + 1, "{pos/40/101}Admission Date: ", date,
   row + 1, "{pos/300/101}Location: ", unit,
   row + 1, "{pos/40/113}Admitting Physician: ", admitdoc,
   row + 1, xxx = concat(trim(room)," ; ",trim(bed)), "{pos/300/113}Room & Bed: ",
   xxx, row + 1, "{f/9}{CPI/16}{POS/40/117}",
   l1, row + 1, "{f/8}",
   row + 1, ycol = 137, xcol = 45
   IF (thead > " ")
    "{pos/45/137}{f/9}{u}", thead, row + 1
   ENDIF
   "{f/8}", row + 1
  DETAIL
   "{pos/45/137}{f/9}{u}GENERAL", row + 1, "{pos/45/149}{f/8}Emergency Contact: ",
   temp->emergcon, row + 1, "{pos/280/149}Contact Home Phone: ",
   temp->hmphone, row + 1, "{pos/450/149}Contact Work Phone: ",
   temp->wkphone, row + 1, "{pos/280/161}Contact Cellular Phone: ",
   temp->cell, row + 1, "{pos/450/161}Contact Pager: ",
   temp->pager, row + 1, "{pos/45/173}Mode of Arrival: ",
   temp->arrival, row + 1, "{pos/280/173}History Deferred: ",
   temp->histdef, row + 1, r = substring(7,2,temp->edc),
   s = substring(9,2,temp->edc), t = substring(5,2,temp->edc), u = concat(trim(r),"/",trim(s),"/",
    trim(t))
   IF ((temp->edc="In Error"))
    u = temp->edc
   ENDIF
   "{pos/450/173}EDC: ", u, row + 1,
   "{pos/45/185}Height:", temp->height, " cm",
   row + 1, "{pos/180/185}Weight:", temp->weight,
   " kg", row + 1, "{pos/280/185}Pregnant: ",
   temp->pregnant, row + 1, "{pos/450/185}LMP: ",
   temp->lmp, row + 1, "{pos/45/197}Immunizations Current: ",
   temp->immun, row + 1, "{pos/280/197}Date of last tetanus: ",
   temp->tetanus, row + 1, "{pos/45/221}Family Physician: ",
   temp->doctor, row + 1, "{pos/45/209}Chief Complaint: ",
   temp->complaint, row + 1, ycol = 233
   IF ((temp->emergcon_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Emergency Contact comment: ",
    temp->emergcon_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->hmphone_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Home Phone comment: ",
    temp->hmphone_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->wkphone_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Work Phone comment: ",
    temp->wkphone_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->cell_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Cellular Phone comment: ",
    temp->cell_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->pager_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Pager Number comment: ",
    temp->pager_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->arrival_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Mode of Arrival comment: ",
    temp->arrival_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->histdef_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "History Deferred comment: ",
    temp->histdef_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->edc_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "EDC comment: ",
    temp->edc_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->height_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Height comment: ",
    temp->height_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->weight_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Weight comment: ",
    temp->weight_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->pregnant_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Pregnant comment: ",
    temp->pregnant_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->lmp_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "LMP comment: ",
    temp->lmp_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->immun_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Immunizations comment: ",
    temp->immun_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->tetanus_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Tetanus Date comment: ",
    temp->tetanus_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->complaint_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Chief Complaint comment: ",
    temp->complaint_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF ((temp->doctor_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), "Family Physician comment: ",
    temp->doctor_note_text, row + 1, ycol = (ycol+ 12)
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   xcol = 45, ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)),
   "{u}{f/9}ALLERGIES/SENSITIVITIES", row + 1, thead = "ALLERGIES/SENSITIVITIES(cont.)",
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", allergy->doc1, xcol = 400,
   CALL print(calcpos(xcol,ycol)), "{f/8}", allergy->date1_tz,
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Known Latex Allergy: ",
   allergy->latex1, row + 1
   IF ((allergy->latex1_status=1))
    dash->n = (textlen(allergy->latex1)+ 21)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   IF ((allergy->latex1_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", allergy->latex1_status_name,
    "   ", allergy->latex1_status_tz, row + 1
   ENDIF
   IF ((allergy->note1_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    allergy->note1_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", allergy->doc2, xcol = 400,
   CALL print(calcpos(xcol,ycol)), "{f/8}", allergy->date2_tz,
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Reaction to Rubber Gloves: ",
   allergy->latex2, row + 1
   IF ((allergy->latex2_status=1))
    dash->n = (textlen(allergy->latex2)+ 27)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF (ycol > 680)
    BREAK
   ENDIF
   ycol = (ycol+ 12)
   IF ((allergy->latex2_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", allergy->latex2_status_name,
    "   ", allergy->latex2_status_tz, row + 1
   ENDIF
   IF ((allergy->note2_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    allergy->note2_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", allergy->doc3, xcol = 400,
   CALL print(calcpos(xcol,ycol)), "{f/8}", allergy->date3_tz,
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Reaction to Balloons: ",
   allergy->latex3, row + 1
   IF ((allergy->latex3_status=1))
    dash->n = (textlen(allergy->latex3)+ 22)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF (ycol > 680)
    BREAK
   ENDIF
   IF ((allergy->latex3_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    allergy->latex3_status_name, "   ", allergy->latex3_status_tz,
    row + 1
   ENDIF
   IF ((allergy->note3_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    allergy->note3_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)), "{f/8}{u}Allergy",
   row + 1, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "{u}Reaction", row + 1, ycol = (ycol+ 12)
   FOR (y = 1 TO allergy->cnt)
     xcol = 45,
     CALL print(calcpos(xcol,ycol)), allergy->qual[y].list,
     xcol = 250,
     CALL print(calcpos(xcol,ycol)), allergy->qual[y].rlist,
     row + 1, xcol = 400,
     CALL print(calcpos(xcol,ycol)),
     allergy->qual[y].date_tz, xcol = 470,
     CALL print(calcpos(xcol,ycol)),
     allergy->qual[y].doc, row + 1, ycol = (ycol+ 12)
   ENDFOR
   IF ((allergy->cnt=0))
    xcol = 45,
    CALL print(calcpos(xcol,ycol)), "No Known Allergies",
    row + 1, ycol = (ycol+ 12)
   ENDIF
   xcol = 45, thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}CURRENT MEDICATIONS",
   row + 1, thead = "CURRENT MEDICATIONS(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   curmed->doc, row + 1, xcol = 400,
   CALL print(calcpos(xcol,ycol)), "{f/8}", curmed->date_tz,
   row + 1, xcol = 45
   FOR (y = 1 TO curmed->cnt)
     IF ((curmed->qual[y].line > " ")
      AND (curmed->qual[y].line != "."))
      CALL print(calcpos(xcol,ycol)), curmed->qual[y].line, row + 1
      IF ((curmed->status=1))
       dash->n = textlen(curmed->qual[y].line)
       IF ((dash->n > 20))
        dash->n = (dash->n - 5)
       ENDIF
       IF ((dash->n > 80))
        dash->n = 80
       ENDIF
       dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
       CALL print(calcpos(xcol,ycol)),
       dash->ln, row + 1, ycol = (ycol+ 3)
      ENDIF
      ycol = (ycol+ 12)
     ENDIF
   ENDFOR
   IF ((curmed->status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", curmed->status_name,
    "   ", curmed->status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((curmed->note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), curmed->note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}MEDICAL HISTORY",
   row + 1, thead = "MEDICAL HISTORY(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   med->neurodoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->neurodate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Neuro disorders/seizures: ", med->neuro,
   row + 1
   IF ((med->neuro_status=1))
    dash->n = (textlen(med->neuro)+ 26)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->neuro_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->neuro_status_name, "   ", med->neuro_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->neuro_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->neuro_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->cvadoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->cvadate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "CVA/Stroke: ", med->cva,
   row + 1
   IF ((med->cva_status=1))
    dash->n = (textlen(med->cva)+ 12)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->cva_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->cva_status_name, "   ", med->cva_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->cva_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->cva_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->braindoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->braindate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Brain injury: ", med->brain,
   row + 1
   IF ((med->brain_status=1))
    dash->n = (textlen(med->neuro)+ 14)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->brain_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->brain_status_name, "   ", med->brain_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->brain_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->brain_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->mentaldoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->mentaldate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Mental Illness: ", med->mental,
   row + 1
   IF ((med->mental_status=1))
    dash->n = (textlen(med->mental)+ 16)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->mental_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->mental_status_name, "   ", med->mental_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->mental_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->mental_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->heartdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->heartdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Heart/Vascular disease: ", med->heart,
   row + 1
   IF ((med->heart_status=1))
    dash->n = (textlen(med->heart)+ 24)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->heart_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->heart_status_name, "   ", med->heart_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->heart_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->heart_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->hyperdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->hyperdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Hypertension: ", med->hyper,
   row + 1
   IF ((med->hyper_status=1))
    dash->n = (textlen(med->neuro)+ 14)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->hyper_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->hyper_status_name, "   ", med->hyper_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->hyper_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->hyper_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->pacemakerdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->pacemakerdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Pacemaker: ", med->pacemaker,
   row + 1
   IF ((med->pace_status=1))
    dash->n = (textlen(med->pacemaker)+ 11)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->pace_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->pace_status_name, "   ", med->pace_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->pace_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->pace_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->defibdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->defibdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Internal defibrillator: ", med->defib,
   row + 1
   IF ((med->defib_status=1))
    dash->n = (textlen(med->neuro)+ 24)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->defib_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->defib_status_name, "   ", med->defib_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->defib_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->defib_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->pulmonarydoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->pulmonarydate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Pulmonary disease/asthma: ", med->pulmonary,
   row + 1
   IF ((med->pulm_status=1))
    dash->n = (textlen(med->pulmonary)+ 26)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->pulm_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->pulm_status_name, "   ", med->pulm_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->pulm_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->pulm_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->gugyndoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->gugyndate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "GU/GYN Disorder: ", med->gugyn,
   row + 1
   IF ((med->gugyn_status=1))
    dash->n = (textlen(med->gugyn)+ 17)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->gugyn_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->gugyn_status_name, "   ", med->gugyn_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->gugyn_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->gugyn_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->tbdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->tbdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Risk factors for TB: ", med->tb,
   row + 1
   IF ((med->tb_status=1))
    dash->n = (textlen(med->tb)+ 21)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->tb_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->tb_status_name, "   ", med->tb_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->tb_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->tb_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->eentdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->eentdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "EENT disorders: ", med->eent,
   row + 1
   IF ((med->eent_status=1))
    dash->n = (textlen(med->eent)+ 16)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->eent_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->eent_status_name, "   ", med->eent_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->eent_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->eent_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->gidoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->gidate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "GI disorders/Bleed: ", med->gi,
   row + 1
   IF ((med->gi_status=1))
    dash->n = (textlen(med->gi)+ 20)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->gi_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->gi_status_name, "   ", med->gi_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->gi_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->gi_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->hepatitisdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->hepatitisdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Hepatitis/Liver disease: ", med->hepatitis,
   row + 1
   IF ((med->hep_status=1))
    dash->n = (textlen(med->hepatitis)+ 25)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->hep_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->hep_status_name, "   ", med->hep_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->hep_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->hep_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->endodoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->endodate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Endocrine disorder/Diabetes: ", med->endo,
   row + 1
   IF ((med->endo_status=1))
    dash->n = (textlen(med->endo)+ 29)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->endo_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->endo_status_name, "   ", med->endo_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->endo_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->endo_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->bonedoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->bonedate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Bone disorder: ", med->bone,
   row + 1
   IF ((med->bone_status=1))
    dash->n = (textlen(med->bone)+ 15)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->bone_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->bone_status_name, "   ", med->bone_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->bone_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->bone_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->orthodoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->orthodate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Orthopedic problems: ", med->ortho,
   row + 1
   IF ((med->ortho_status=1))
    dash->n = (textlen(med->ortho)+ 21)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->ortho_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->ortho_status_name, "   ", med->ortho_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->ortho_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->ortho_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->implantdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->implantdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Implant (cochlear, hip, etc.): ", med->implant,
   row + 1
   IF ((med->implant_status=1))
    dash->n = (textlen(med->implant)+ 31)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->implant_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->implant_status_name, "   ", med->implant_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->implant_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->implant_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->blooddoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->blooddate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Blood disorder/Sickle cell: ", med->blood,
   row + 1
   IF ((med->blood_status=1))
    dash->n = (textlen(med->blood)+ 28)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->blood_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->blood_status_name, "   ", med->blood_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->blood_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->blood_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->transdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->transdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Blood transfusion: ", med->trans,
   row + 1
   IF ((med->trans_status=1))
    dash->n = (textlen(med->trans)+ 19)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->trans_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->trans_status_name, "   ", med->trans_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->trans_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->trans_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->cancerdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->cancerdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Cancer/Multiple Myeloma: ", med->cancer,
   row + 1
   IF ((med->cancer_status=1))
    dash->n = (textlen(med->cancer)+ 25)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->cancer_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->cancer_status_name, "   ", med->cancer_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->cancer_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->cancer_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->skindoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->skindate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "History of Skin Condition: ", med->skin,
   row + 1
   IF ((med->skin_status=1))
    dash->n = (textlen(med->skin)+ 27)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->skin_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->skin_status_name, "   ", med->skin_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->skin_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->skin_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->renaldoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->renaldate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Renal Disease/Disorder: ", med->renal,
   row + 1
   IF ((med->renal_status=1))
    dash->n = (textlen(med->renal)+ 24)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->renal_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->renal_status_name, "   ", med->renal_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->renal_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->renal_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->rashdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->rashdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Rash: ", med->rash,
   row + 1
   IF ((med->rash_status=1))
    dash->n = (textlen(med->rash)+ 6)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->rash_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->rash_status_name, "   ", med->rash_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->rash_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->rash_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->infectdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->infectdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Infectious Condition: ", med->infect,
   row + 1
   IF ((med->infect_status=1))
    dash->n = (textlen(med->infect)+ 22)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->infect_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->infect_status_name, "   ", med->infect_status_tz,
    row + 1
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   IF ((med->infect_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->infect_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", med->otherdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), med->otherdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Other: ", med->other,
   row + 1
   IF ((med->other_status=1))
    dash->n = (textlen(med->other)+ 7)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 50))
     dash->n = 50
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((med->other_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    med->other_status_name, "   ", med->other_status_tz,
    row + 1
   ENDIF
   IF ((med->other_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    med->other_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   thead = " ", ycol = (ycol+ 24)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{u}{f/9}CURRENT MEDICAL TREATMENTS",
   row + 1, thead = "CURRENT MEDICAL TREATMENTS(cont.)"
   IF ((treat->list="No"))
    ycol = (ycol+ 12), xcol = 470,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}", treat->doc, row + 1,
    xcol = 400,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    treat->date_tz, row + 1, xcol = 45,
    CALL print(calcpos(xcol,ycol)), "{f/8}", treat->list,
    row + 1
    IF ((treat->status=1))
     dash->n = textlen(treat->list)
     IF ((dash->n > 20))
      dash->n = (dash->n - 5)
     ENDIF
     IF ((dash->n > 50))
      dash->n = 50
     ENDIF
     dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
     CALL print(calcpos(xcol,ycol)),
     dash->ln, row + 1, ycol = (ycol+ 3)
    ENDIF
    IF ((treat->status=1))
     ycol = (ycol+ 12),
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
     treat->status_name, "   ", treat->status_tz,
     row + 1
    ENDIF
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
    IF ((treat->note_ind=1))
     xcol = 50,
     CALL print(calcpos(xcol,ycol)), treat->note_text
     IF (ycol > 700)
      BREAK
     ENDIF
     ycol = (ycol+ 12)
    ENDIF
   ELSE
    ycol = (ycol+ 12), xcol = 470,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}", curtreat->doc, row + 1,
    xcol = 400,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    curtreat->date_tz, row + 1, xcol = 45
    FOR (y = 1 TO curtreat->cnt)
      IF ((curtreat->qual[y].line > " ")
       AND (curtreat->qual[y].line != "."))
       CALL print(calcpos(xcol,ycol)), curtreat->qual[y].line, row + 1
       IF ((curtreat->status=1))
        dash->n = textlen(curtreat->qual[y].line)
        IF ((dash->n > 20))
         dash->n = (dash->n - 5)
        ENDIF
        IF ((dash->n > 80))
         dash->n = 80
        ENDIF
        dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
        CALL print(calcpos(xcol,ycol)),
        dash->ln, row + 1, ycol = (ycol+ 3)
       ENDIF
       ycol = (ycol+ 12)
      ENDIF
    ENDFOR
    IF ((curtreat->status=1))
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ", curtreat->status_name,
     "   ", curtreat->status_tz, row + 1
     IF (ycol > 680)
      BREAK
     ENDIF
     ycol = (ycol+ 12)
    ENDIF
    IF ((curtreat->note_ind=1))
     xcol = 50,
     CALL print(calcpos(xcol,ycol)), curtreat->note_text
     IF (ycol > 700)
      BREAK
     ENDIF
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}PREVIOUS HOSPITALIZATIONS/SURGERIES",
   row + 1, thead = "PREVIOUS HOSPITALIZATIONS/SURGERIES(Cont.)", ycol = (ycol+ 12)
   IF ((hosp->list="No"))
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    hosp->doc, row + 1, xcol = 400,
    CALL print(calcpos(xcol,ycol)), "{f/8}", hosp->date_tz,
    row + 1, xcol = 45,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}", hosp->list, row + 1
    IF ((hosp->status=1))
     dash->n = textlen(hosp->list)
     IF ((dash->n > 20))
      dash->n = (dash->n - 5)
     ENDIF
     IF ((dash->n > 50))
      dash->n = 50
     ENDIF
     dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
     CALL print(calcpos(xcol,ycol)),
     dash->ln, row + 1, ycol = (ycol+ 3)
    ENDIF
    IF ((hosp->status=1))
     ycol = (ycol+ 12),
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
     hosp->status_name, "   ", hosp->status_tz,
     row + 1
    ENDIF
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
    IF ((hosp->note_ind=1))
     ycol = (ycol+ 12), xcol = 50,
     CALL print(calcpos(xcol,ycol)),
     hosp->note_text
     IF (ycol > 700)
      BREAK
     ENDIF
    ENDIF
    ycol = (ycol+ 12)
   ELSE
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    surg->doc, row + 1, xcol = 400,
    CALL print(calcpos(xcol,ycol)), "{f/8}", surg->date_tz,
    row + 1, xcol = 45
    FOR (y = 1 TO surg->cnt)
      IF ((surg->qual[y].line > "    ")
       AND (surg->qual[y].line != "."))
       CALL print(calcpos(xcol,ycol)), surg->qual[y].line, row + 1
       IF ((surg->status=1))
        dash->n = textlen(surg->qual[y].line)
        IF ((dash->n > 20))
         dash->n = (dash->n - 5)
        ENDIF
        IF ((dash->n > 80))
         dash->n = 80
        ENDIF
        dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
        CALL print(calcpos(xcol,ycol)),
        dash->ln, row + 1, ycol = (ycol+ 3)
       ENDIF
       ycol = (ycol+ 12)
      ENDIF
    ENDFOR
    IF ((surg->status=1))
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ", surg->status_name,
     "   ", surg->status_tz, row + 1
     IF (ycol > 680)
      BREAK
     ENDIF
     ycol = (ycol+ 12)
    ENDIF
    IF ((surg->note_ind=1))
     xcol = 50,
     CALL print(calcpos(xcol,ycol)), surg->note_text
     IF (ycol > 700)
      BREAK
     ENDIF
     ycol = (ycol+ 12)
    ENDIF
   ENDIF
   thead = "     ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}SENSORY ABILITY",
   row + 1, thead = "SENSORY ABILITY(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   sensory->visual_doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", sensory->visual_date_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Visual Status:  ", row + 1,
   xcol = 95
   FOR (y = 1 TO sensory->visual_list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), sensory->visual_list_tag[y].visual_list_line, row + 1
     IF ((sensory->visual_status=1))
      dash->n = (textlen(sensory->visual_list_tag[y].visual_list_line)+ 16)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 60))
       dash->n = 60
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((sensory->visual_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", sensory->visual_status_name,
    "   ", sensory->visual_status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((sensory->visual_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), sensory->visual_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   sensory->speech_doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   sensory->speech_date_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)),
   "Speech Status:  ", row + 1, xcol = 100
   FOR (y = 1 TO sensory->speech_list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), sensory->speech_list_tag[y].speech_list_line, row + 1
     IF ((sensory->speech_status=1))
      dash->n = (textlen(sensory->speech_list_tag[y].speech_list_line)+ 16)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 60))
       dash->n = 60
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((sensory->speech_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", sensory->speech_status_name,
    "   ", sensory->speech_status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((sensory->speech_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), sensory->speech_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   sensory->hear_doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   sensory->hear_date_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)),
   "Hearing Status:  ", row + 1, xcol = 100
   FOR (y = 1 TO sensory->hear_list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), sensory->hear_list_tag[y].hear_list_line, row + 1
     IF ((sensory->hear_status=1))
      dash->n = (textlen(sensory->hear_list_tag[y].hear_list_line)+ 17)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 60))
       dash->n = 60
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((sensory->hear_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", sensory->hear_status_name,
    "   ", sensory->hear_status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((sensory->hear_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), sensory->hear_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}PROSTHETIC/ASSISTIVE DEVICES",
   row + 1, thead = "PROSTHETIC/ASSISTIVE DEVICES(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   prosthetic->doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   prosthetic->date_tz, xcol = 45
   FOR (y = 1 TO prosthetic->list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), prosthetic->list_tag[y].list_line, row + 1
     IF ((prosthetic->status=1))
      dash->n = textlen(prosthetic->list_tag[y].list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((prosthetic->status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", prosthetic->status_name,
    "   ", prosthetic->status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((prosthetic->note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), prosthetic->note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}NUTRITION SCREEN",
   row + 1, thead = "NUTRITION SCREEN(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{F/8}",
   nutrition->doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   nutrition->date_tz, xcol = 45
   FOR (y = 1 TO nutrition->list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), nutrition->list_tag[y].list_line, row + 1
     IF ((nutrition->status=1))
      dash->n = textlen(nutrition->list_tag[y].list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((nutrition->status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", nutrition->status_name,
    "   ", nutrition->status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((nutrition->note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), nutrition->note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}ELIMINATION/TOILETING",
   row + 1, thead = "ELIMINATION/TOILETING(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{F/8}",
   elim->doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   elim->date_tz, xcol = 45
   FOR (y = 1 TO elim->list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), elim->list_tag[y].list_line, row + 1
     IF ((elim->status=1))
      dash->n = textlen(elim->list_tag[y].list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((elim->status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", elim->status_name,
    "   ", elim->status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((elim->note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), elim->note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}PSYCHOSOCIAL",
   row + 1, thead = "PSYCHOSOCIAL(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{F/8}",
   psycho->doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   psycho->date_tz, xcol = 45
   FOR (y = 1 TO psycho->list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), psycho->list_tag[y].list_line, row + 1
     IF ((psycho->status=1))
      dash->n = textlen(psycho->list_tag[y].list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((psycho->status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", psycho->status_name,
    "   ", psycho->status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((psycho->note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), psycho->note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{u}{f/9}FUNCTIONAL ASSESSMENT/REHAB SCREEN",
   row + 1, thead = "FUNCTIONAL ASSESSMENT/REHAB SCREEN(CONT.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{F/8}",
   function->doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   function->date_tz, xcol = 45
   FOR (y = 1 TO function->list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), function->list_tag[y].list_line, row + 1
     IF ((function->status=1))
      dash->n = textlen(function->list_tag[y].list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((function->status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", function->status_name,
    "   ", function->status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((function->note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), function->note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}SOCIAL HABITS",
   row + 1, thead = "SOCIAL HABITS(cont.)", ycol = (ycol+ 12)
   IF ((habit->drug="No"))
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    habit->drugdoc, xcol = 400,
    CALL print(calcpos(xcol,ycol)),
    habit->drugdate_tz, xcol = 45,
    CALL print(calcpos(xcol,ycol)),
    "Recreational Drug Use: ", habit->drug, row + 1
    IF ((habit->drug_status=1))
     dash->n = (textlen(habit->drug)+ 23)
     IF ((dash->n > 20))
      dash->n = (dash->n - 5)
     ENDIF
     IF ((dash->n > 50))
      dash->n = 50
     ENDIF
     dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
     CALL print(calcpos(xcol,ycol)),
     dash->ln, row + 1, ycol = (ycol+ 3)
    ENDIF
    IF ((habit->drug_status=1))
     ycol = (ycol+ 12),
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
     habit->drug_status_name, "   ", habit->drug_status_tz,
     row + 1
    ENDIF
    IF (ycol > 700)
     BREAK
    ENDIF
    IF ((habit->drug_note_ind=1))
     ycol = (ycol+ 12), xcol = 50,
     CALL print(calcpos(xcol,ycol)),
     habit->drug_note_text
     IF (ycol > 700)
      BREAK
     ENDIF
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((habit->drug="Previous Use"))
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    habit->drugdoc, xcol = 400,
    CALL print(calcpos(xcol,ycol)),
    habit->drugdate_tz, xcol = 45,
    CALL print(calcpos(xcol,ycol)),
    "Recreational Drug Use: ", habit->drug, row + 1
    IF ((habit->drug_status=1))
     dash->n = (textlen(habit->drug)+ 23)
     IF ((dash->n > 20))
      dash->n = (dash->n - 5)
     ENDIF
     IF ((dash->n > 50))
      dash->n = 50
     ENDIF
     dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
     CALL print(calcpos(xcol,ycol)),
     dash->ln, row + 1, ycol = (ycol+ 3)
    ENDIF
    IF ((habit->drug_status=1))
     ycol = (ycol+ 12),
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
     habit->drug_status_name, "   ", habit->drug_status_tz,
     row + 1
    ENDIF
    IF (ycol > 700)
     BREAK
    ENDIF
    IF ((habit->drug_note_ind=1))
     ycol = (ycol+ 12), xcol = 50,
     CALL print(calcpos(xcol,ycol)),
     habit->drug_note_text
     IF (ycol > 700)
      BREAK
     ENDIF
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((habit->tobac="No"))
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    habit->tobacdoc, xcol = 400,
    CALL print(calcpos(xcol,ycol)),
    habit->tobacdate_tz, xcol = 45,
    CALL print(calcpos(xcol,ycol)),
    "Tobacco Use: ", habit->tobac, row + 1
    IF ((habit->tobac_status=1))
     dash->n = (textlen(habit->tobac)+ 13)
     IF ((dash->n > 20))
      dash->n = (dash->n - 5)
     ENDIF
     IF ((dash->n > 50))
      dash->n = 50
     ENDIF
     dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
     CALL print(calcpos(xcol,ycol)),
     dash->ln, row + 1, ycol = (ycol+ 3)
    ENDIF
    IF ((habit->tobac_status=1))
     ycol = (ycol+ 12),
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
     habit->tobac_status_name, "   ", habit->tobac_status_tz,
     row + 1
    ENDIF
    IF (ycol > 700)
     BREAK
    ENDIF
    IF ((habit->tobac_note_ind=1))
     ycol = (ycol+ 12), xcol = 50,
     CALL print(calcpos(xcol,ycol)),
     habit->tobac_note_text
     IF (ycol > 700)
      BREAK
     ENDIF
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((habit->tobac="Previous Use"))
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    habit->tobacdoc, xcol = 400,
    CALL print(calcpos(xcol,ycol)),
    habit->tobacdate_tz, xcol = 45,
    CALL print(calcpos(xcol,ycol)),
    "Tobacco Use: ", habit->tobac, row + 1
    IF ((habit->tobac_status=1))
     dash->n = (textlen(habit->tobac)+ 13)
     IF ((dash->n > 20))
      dash->n = (dash->n - 5)
     ENDIF
     IF ((dash->n > 50))
      dash->n = 50
     ENDIF
     dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
     CALL print(calcpos(xcol,ycol)),
     dash->ln, row + 1, ycol = (ycol+ 3)
    ENDIF
    IF ((habit->tobac_status=1))
     ycol = (ycol+ 12),
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
     habit->tobac_status_name, "   ", habit->tobac_status_tz,
     row + 1
    ENDIF
    IF (ycol > 700)
     BREAK
    ENDIF
    IF ((habit->tobac_note_ind=1))
     ycol = (ycol+ 12), xcol = 50,
     CALL print(calcpos(xcol,ycol)),
     habit->tobac_note_text
     IF (ycol > 700)
      BREAK
     ENDIF
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((habit->alc="No"))
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    habit->alcdoc, xcol = 400,
    CALL print(calcpos(xcol,ycol)),
    habit->alcdate_tz, xcol = 45,
    CALL print(calcpos(xcol,ycol)),
    "Alcohol Use: ", habit->alc, row + 1
    IF ((habit->alc_status=1))
     dash->n = (textlen(habit->alc)+ 13)
     IF ((dash->n > 20))
      dash->n = (dash->n - 5)
     ENDIF
     IF ((dash->n > 50))
      dash->n = 50
     ENDIF
     dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
     CALL print(calcpos(xcol,ycol)),
     dash->ln, row + 1, ycol = (ycol+ 3)
    ENDIF
    IF ((habit->alc_status=1))
     ycol = (ycol+ 12),
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
     habit->alc_status_name, "   ", habit->alc_status_tz,
     row + 1
    ENDIF
    IF (ycol > 700)
     BREAK
    ENDIF
    IF ((habit->alc_note_ind=1))
     ycol = (ycol+ 12), xcol = 50,
     CALL print(calcpos(xcol,ycol)),
     habit->alc_note_text
     IF (ycol > 700)
      BREAK
     ENDIF
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((habit->alc="Previous Use"))
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{f/8}",
    habit->alcdoc, xcol = 400,
    CALL print(calcpos(xcol,ycol)),
    habit->alcdate_tz, xcol = 45,
    CALL print(calcpos(xcol,ycol)),
    "Alcohol Use: ", habit->alc, row + 1
    IF ((habit->alc_status=1))
     dash->n = (textlen(habit->alc)+ 13)
     IF ((dash->n > 20))
      dash->n = (dash->n - 5)
     ENDIF
     IF ((dash->n > 50))
      dash->n = 50
     ENDIF
     dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
     CALL print(calcpos(xcol,ycol)),
     dash->ln, row + 1, ycol = (ycol+ 3)
    ENDIF
    IF ((habit->alc_status=1))
     ycol = (ycol+ 12),
     CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
     habit->alc_status_name, "   ", habit->alc_status_tz,
     row + 1
    ENDIF
    IF (ycol > 700)
     BREAK
    ENDIF
    IF ((habit->alc_note_ind=1))
     ycol = (ycol+ 12), xcol = 50,
     CALL print(calcpos(xcol,ycol)),
     habit->alc_note_text
     IF (ycol > 700)
      BREAK
     ENDIF
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   FOR (x = 1 TO social->cnt)
     IF ((social->qual[x].date=social->qual[1].date))
      xcol = 470,
      CALL print(calcpos(xcol,ycol)), "{f/8}",
      social->qual[x].doc, xcol = 400,
      CALL print(calcpos(xcol,ycol)),
      social->qual[x].date_tz, xcol = 45,
      CALL print(calcpos(xcol,ycol)),
      social->qual[x].list, row + 1
      IF ((social->qual[x].status=1))
       dash->n = textlen(social->qual[x].list)
       IF ((dash->n > 20))
        dash->n = (dash->n - 5)
       ENDIF
       IF ((dash->n > 50))
        dash->n = 50
       ENDIF
       dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
       CALL print(calcpos(xcol,ycol)),
       dash->ln, row + 1, ycol = (ycol+ 3)
      ENDIF
      IF ((social->qual[x].status=1))
       ycol = (ycol+ 12),
       CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
       social->qual[x].status_name, "   ", social->qual[x].status_tz,
       row + 1
      ENDIF
      IF ((social->qual[x].note_ind=1))
       ycol = (ycol+ 12), xcol = 50,
       CALL print(calcpos(xcol,ycol)),
       social->qual[x].note_text
       IF (ycol > 700)
        BREAK
       ENDIF
      ENDIF
      ycol = (ycol+ 12)
     ENDIF
   ENDFOR
   thead = "    ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}SPIRITUAL/CULTURAL NEEDS ASSESSMENT",
   row + 1, thead = "SPIRITUAL/CULTURAL NEEDS ASSESSMENT(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   spirit->support_doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", spirit->support_date_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Specific request for spiritual support: "
   FOR (y = 1 TO spirit->support_list_ln_cnt)
     xcol = 173,
     CALL print(calcpos(xcol,ycol)), spirit->support_list_tag[y].support_list_line,
     row + 1
     IF ((spirit->support_status=1))
      dash->n = textlen(spirit->support_list_tag[y].support_list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((spirit->support_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", spirit->support_status_name,
    "   ", spirit->support_status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((spirit->support_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), spirit->support_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   spirit->prefdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   spirit->prefdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)),
   "Religious preference: ", spirit->pref
   IF ((spirit->pref_status=1))
    dash->n = (textlen(spirit->pref)+ 22)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 80))
     dash->n = 80
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((spirit->pref_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    spirit->pref_status_name, "   ", spirit->pref_status_tz,
    row + 1
   ENDIF
   IF ((spirit->pref_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    spirit->pref_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{F/9}{u}PATIENT EDUCATION NEEDS",
   row + 1, thead = "PATIENT EDUCATION NEEDS(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   education->sodoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   education->sodate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}Pt./SO oriented to room/waiting area: ", education->so, row + 1
   IF ((education->so_status=1))
    dash->n = (textlen(education->so)+ 39)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 80))
     dash->n = 80
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   ycol = (ycol+ 12)
   IF ((education->so_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", education->so_status_name,
    "   ", education->so_status_tz, row + 1,
    ycol = (ycol+ 12)
   ENDIF
   IF ((education->so_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), education->so_note_text,
    ycol = (ycol+ 12)
   ENDIF
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   education->barriers_doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", education->barriers_date_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Pt.'s barriers to learning/motivation to learn include: ", row +
   1,
   xcol = 220
   FOR (y = 1 TO education->barriers_list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), education->barriers_list_tag[y].barriers_list_line, row + 1
     IF ((education->barriers_status=1))
      dash->n = textlen(education->barriers_list_tag[y].barriers_list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((education->barriers_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", education->barriers_status_name,
    "   ", education->barriers_status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((education->barriers_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), education->barriers_note_text
   ENDIF
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   education->pref_doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   education->pref_date_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)),
   "Pt. preference for learning about procedures/hospital care: ", row + 1, xcol = 243
   FOR (y = 1 TO education->pref_list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), education->pref_list_tag[y].pref_list_line, row + 1
     IF ((education->pref_status=1))
      dash->n = textlen(education->pref_list_tag[y].pref_list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((education->pref_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", education->pref_status_name,
    "   ", education->pref_status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((education->pref_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), education->pref_note_text
   ENDIF
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{f/8}",
   education->need_doc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   education->need_date_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}Pt.'s anticipated learning needs: ", row + 1, xcol = 156
   FOR (y = 1 TO education->need_list_ln_cnt)
     CALL print(calcpos(xcol,ycol)), education->need_list_tag[y].need_list_line, row + 1
     IF ((education->need_status=1))
      dash->n = textlen(education->need_list_tag[y].need_list_line)
      IF ((dash->n > 20))
       dash->n = (dash->n - 5)
      ENDIF
      IF ((dash->n > 80))
       dash->n = 80
      ENDIF
      dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
      CALL print(calcpos(xcol,ycol)),
      dash->ln, row + 1, ycol = (ycol+ 3)
     ENDIF
     ycol = (ycol+ 12)
   ENDFOR
   IF ((education->need_status=1))
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ", education->need_status_name,
    "   ", education->need_status_tz, row + 1
    IF (ycol > 680)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   IF ((education->need_note_ind=1))
    xcol = 50,
    CALL print(calcpos(xcol,ycol)), education->need_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
    ycol = (ycol+ 12)
   ENDIF
   thead = "   ", ycol = (ycol+ 12)
   IF (ycol > 680)
    BREAK
   ENDIF
   xcol = 45,
   CALL print(calcpos(xcol,ycol)), "{f/9}{u}DISCHARGE PLANNING",
   row + 1, thead = "DISCHARGE PLANNING(cont.)", ycol = (ycol+ 12),
   xcol = 470,
   CALL print(calcpos(xcol,ycol)), "{F/8}",
   discharge->homedoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   "{F/8}", discharge->homedate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Pt. plans to return home after discharge: ", discharge->home,
   row + 1
   IF ((discharge->home_status=1))
    dash->n = (textlen(discharge->home)+ 42)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 80))
     dash->n = 80
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((discharge->home_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    discharge->home_status_name, "   ", discharge->home_status_tz,
    row + 1
   ENDIF
   IF ((discharge->home_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    discharge->home_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", discharge->trandoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), discharge->trandate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Pt. has transportation available for discharge: ", discharge->
   tran,
   row + 1
   IF ((discharge->tran_status=1))
    dash->n = (textlen(discharge->tran)+ 48)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 80))
     dash->n = 80
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((discharge->tran_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    discharge->tran_status_name, "   ", discharge->tran_status_tz,
    row + 1
   ENDIF
   IF ((discharge->tran_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    discharge->tran_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", discharge->caredoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), discharge->caredate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Pt. will care for self at home: ", discharge->care,
   row + 1
   IF ((discharge->care_status=1))
    dash->n = (textlen(discharge->care)+ 32)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 80))
     dash->n = 80
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((discharge->care_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    discharge->care_status_name, "   ", discharge->care_status_tz,
    row + 1
   ENDIF
   IF ((discharge->care_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    discharge->care_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   IF (ycol > 700)
    BREAK
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", discharge->livesdoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), discharge->livesdate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Pt. lives with: ", discharge->lives,
   row + 1
   IF ((discharge->lives_status=1))
    dash->n = (textlen(discharge->lives)+ 16)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 80))
     dash->n = 80
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((discharge->lives_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    discharge->lives_status_name, "   ", discharge->lives_status_tz,
    row + 1
   ENDIF
   IF ((discharge->lives_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    discharge->lives_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   ycol = (ycol+ 12), xcol = 470,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}", discharge->referraldoc, xcol = 400,
   CALL print(calcpos(xcol,ycol)), discharge->referraldate_tz, xcol = 45,
   CALL print(calcpos(xcol,ycol)), "Anticipated referrals/agencies needed at discharge: ", discharge
   ->referral,
   row + 1
   IF ((discharge->referral_status=1))
    dash->n = (textlen(discharge->referral)+ 52)
    IF ((dash->n > 20))
     dash->n = (dash->n - 5)
    ENDIF
    IF ((dash->n > 80))
     dash->n = 80
    ENDIF
    dash->ln = substring(1,dash->n,dln), ycol = (ycol - 3),
    CALL print(calcpos(xcol,ycol)),
    dash->ln, row + 1, ycol = (ycol+ 3)
   ENDIF
   IF ((discharge->referral_status=1))
    ycol = (ycol+ 12),
    CALL print(calcpos(xcol,ycol)), "Uncharted By: ",
    discharge->referral_status_name, "   ", discharge->referral_status_tz,
    row + 1
   ENDIF
   IF ((discharge->referral_note_ind=1))
    ycol = (ycol+ 12), xcol = 50,
    CALL print(calcpos(xcol,ycol)),
    discharge->referral_note_text
    IF (ycol > 700)
     BREAK
    ENDIF
   ENDIF
   thead = "   ", ycol = (ycol+ 24)
   IF (ycol > 680)
    BREAK
   ENDIF
   CALL print(calcpos(xcol,ycol)), "{u}{f/9}PATIENT PROPERTY/VALUABLES STATEMENT", row + 1,
   thead = "PATIENT PROPERTY/VALUABLES STATEMENT(cont.)", ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)),
   "{f/12}{cpi/14}I understand that I am personally and solely responsible for",
   " my personal property and/or valuables that I have"
   IF (ycol > 680)
    BREAK
   ENDIF
   ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)), "{f/12}{cpi/14}chosen to keep with me, and for any other",
   " personal property and/or valuables brought to me. I hereby release", row + 1, ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)), "{f/12}{cpi/14}the Hospital from",
   " liability for the loss or damage of my personal property and/or valuables.",
   row + 1
   IF (ycol > 680)
    BREAK
   ENDIF
   ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)),
   "{f/12}{cpi/14}Patient Signature:___________________________________",
   "________________________________________________________________", row + 1, xcol = 370,
   ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)), "Date",
   row + 1, xcol = 500,
   CALL print(calcpos(xcol,ycol)),
   "Time", row + 1, xcol = 45
   IF (ycol > 680)
    BREAK
   ENDIF
   ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)), "{f/12}{cpi/14}Pt. incapacitated at this time.___________________",
   "_____________ notified to receive patient's ", "personal property and/or valuables.", row + 1
   IF (ycol > 700)
    BREAK
   ENDIF
   ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)), "HCP Initials_____________________________",
   row + 1
  FOOT PAGE
   ycol = 750, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}{cpi/16}Page", curpage, row + 1,
   xcol = 310,
   CALL print(calcpos(xcol,ycol)), curdate,
   col + 3, curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 200
 ;end select
 GO TO exit_program
#report_failed
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   thead = "                                                       ", dln = fillstring(255,"_")
  HEAD PAGE
   "{f/9}{cpi/11}", row + 1, "{POS/200/62}HOSPITAL ADMISSION DATABASE",
   row + 1, "{CPI/16}{POS/40/65}", l1,
   row + 1, "{f/8}{pos/40/77}Report Failed: Invalid encounter id used (", request->visit[1].encntr_id,
   ").", row + 1, "{f/9}{CPI/16}{POS/40/117}",
   l1, row + 1, "{f/8}",
   row + 1, ycol = 137, xcol = 45
   IF (thead > " ")
    "{pos/45/137}{f/9}{u}", thead, row + 1
   ENDIF
   "{f/8}", row + 1
  FOOT PAGE
   ycol = 750, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}{cpi/16}Page", curpage, row + 1,
   xcol = 310,
   CALL print(calcpos(xcol,ycol)), curdate,
   col + 3, curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 200
 ;end select
 GO TO exit_program
#get_note_begin
 SET blob_out = fillstring(32000," ")
 SELECT INTO "nl:"
  cen.seq, lb.long_blob
  FROM ce_event_note cen,
   long_blob lb
  PLAN (cen
   WHERE cen.event_id=event_id)
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id
    AND lb.parent_entity_name="CE_EVENT_NOTE")
  DETAIL
   IF (cen.compression_cd=ocfcomp_cd)
    blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000,
     " "),
    blob_ret_len = 0,
    CALL uar_ocf_uncompress(lb.long_blob,textlen(lb.long_blob),blob_out,32000,blob_ret_len)
   ELSE
    blob_out = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),
     lb.long_blob)
   ENDIF
   CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2
  WITH nocounter
 ;end select
#get_note_end
#exit_program
END GO
