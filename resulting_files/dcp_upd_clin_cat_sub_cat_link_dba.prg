CREATE PROGRAM dcp_upd_clin_cat_sub_cat_link:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "FAIL:dcp_upd_clin_cat_sub_cat_link.prg failed"
 RECORD internal1(
   1 list[267]
     2 clin_cat_mean = c12
     2 clin_sub_cat_mean = c12
 )
 RECORD internal2(
   1 list[*]
     2 dcp_clin_cat_cd = f8
     2 clin_cat_mean = c12
     2 dcp_clin_sub_cat_cd = f8
     2 clin_sub_cat_mean = c12
     2 clin_sub_cat_display = c40
     2 sub_cat_active_ind = i2
 )
 SET internal1->list[1].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[2].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[3].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[4].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[5].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[6].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[7].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[8].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[9].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[10].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[11].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[12].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[13].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[14].clin_cat_mean = "LABORATORY"
 SET internal1->list[15].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[16].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[17].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[18].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[19].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[20].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[21].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[22].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[23].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[24].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[25].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[26].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[27].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[28].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[29].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[30].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[31].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[32].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[33].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[34].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[35].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[36].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[37].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[38].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[39].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[40].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[41].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[42].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[43].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[44].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[45].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[46].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[47].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[48].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[49].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[50].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[51].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[52].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[53].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[54].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[55].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[56].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[57].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[58].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[59].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[60].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[61].clin_cat_mean = "SPECIAL"
 SET internal1->list[62].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[63].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[64].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[65].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[66].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[67].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[68].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[69].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[70].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[71].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[72].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[73].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[74].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[75].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[76].clin_cat_mean = "LABORATORY"
 SET internal1->list[77].clin_cat_mean = "LABORATORY"
 SET internal1->list[78].clin_cat_mean = "SPECIAL"
 SET internal1->list[79].clin_cat_mean = "LABORATORY"
 SET internal1->list[80].clin_cat_mean = "SPECIAL"
 SET internal1->list[81].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[82].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[83].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[84].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[85].clin_cat_mean = "NURSORDERS"
 SET internal1->list[86].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[87].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[88].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[89].clin_cat_mean = "LABORATORY"
 SET internal1->list[90].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[91].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[92].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[93].clin_cat_mean = "SPECIAL"
 SET internal1->list[94].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[95].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[96].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[97].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[98].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[99].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[100].clin_cat_mean = "LABORATORY"
 SET internal1->list[101].clin_cat_mean = "LABORATORY"
 SET internal1->list[102].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[103].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[104].clin_cat_mean = "LABORATORY"
 SET internal1->list[105].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[106].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[107].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[108].clin_cat_mean = "NURSORDERS"
 SET internal1->list[109].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[110].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[111].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[112].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[113].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[114].clin_cat_mean = "CONSULTS"
 SET internal1->list[115].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[116].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[117].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[118].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[119].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[120].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[121].clin_cat_mean = "NURSORDERS"
 SET internal1->list[122].clin_cat_mean = "NURSORDERS"
 SET internal1->list[123].clin_cat_mean = "LABORATORY"
 SET internal1->list[124].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[125].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[126].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[127].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[128].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[129].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[130].clin_cat_mean = "SPECIAL"
 SET internal1->list[131].clin_cat_mean = "NURSORDERS"
 SET internal1->list[132].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[133].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[134].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[135].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[136].clin_cat_mean = "NURSORDERS"
 SET internal1->list[137].clin_cat_mean = "SPECIAL"
 SET internal1->list[138].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[139].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[140].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[141].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[142].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[143].clin_cat_mean = "NURSORDERS"
 SET internal1->list[144].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[145].clin_cat_mean = "NURSORDERS"
 SET internal1->list[146].clin_cat_mean = "LABORATORY"
 SET internal1->list[147].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[148].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[149].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[150].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[151].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[152].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[153].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[154].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[155].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[156].clin_cat_mean = "LABORATORY"
 SET internal1->list[157].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[158].clin_cat_mean = "LABORATORY"
 SET internal1->list[159].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[160].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[161].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[162].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[163].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[164].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[165].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[166].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[167].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[168].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[169].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[170].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[171].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[172].clin_cat_mean = "NURSORDERS"
 SET internal1->list[173].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[174].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[175].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[176].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[177].clin_cat_mean = "SPECIAL"
 SET internal1->list[178].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[179].clin_cat_mean = "SPECIAL"
 SET internal1->list[180].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[181].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[182].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[183].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[184].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[185].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[186].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[187].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[188].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[189].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[190].clin_cat_mean = "LABORATORY"
 SET internal1->list[191].clin_cat_mean = "NURSORDERS"
 SET internal1->list[192].clin_cat_mean = "NURSORDERS"
 SET internal1->list[193].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[194].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[195].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[196].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[197].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[198].clin_cat_mean = "NURSORDERS"
 SET internal1->list[199].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[200].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[201].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[202].clin_cat_mean = "LABORATORY"
 SET internal1->list[203].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[204].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[205].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[206].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[207].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[208].clin_cat_mean = "IVSOLUTIONS"
 SET internal1->list[209].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[210].clin_cat_mean = "SPECIAL"
 SET internal1->list[211].clin_cat_mean = "DIET"
 SET internal1->list[212].clin_cat_mean = "NURSORDERS"
 SET internal1->list[213].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[214].clin_cat_mean = "LABORATORY"
 SET internal1->list[215].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[216].clin_cat_mean = "SPECIAL"
 SET internal1->list[217].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[218].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[219].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[220].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[221].clin_cat_mean = "DIAGTESTS"
 SET internal1->list[222].clin_cat_mean = "SPECIAL"
 SET internal1->list[223].clin_cat_mean = "CONSULTS"
 SET internal1->list[224].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[225].clin_cat_mean = "NURSORDERS"
 SET internal1->list[226].clin_cat_mean = "IVSOLUTIONS"
 SET internal1->list[227].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[228].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[229].clin_cat_mean = "LABORATORY"
 SET internal1->list[230].clin_cat_mean = "LABORATORY"
 SET internal1->list[231].clin_cat_mean = "LABORATORY"
 SET internal1->list[232].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[233].clin_cat_mean = "LABORATORY"
 SET internal1->list[234].clin_cat_mean = "LABORATORY"
 SET internal1->list[235].clin_cat_mean = "SPECIAL"
 SET internal1->list[236].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[237].clin_cat_mean = "LABORATORY"
 SET internal1->list[238].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[239].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[240].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[241].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[242].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[243].clin_cat_mean = "DIET"
 SET internal1->list[244].clin_cat_mean = "NURSORDERS"
 SET internal1->list[245].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[246].clin_cat_mean = "NURSORDERS"
 SET internal1->list[247].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[248].clin_cat_mean = "SPECIAL"
 SET internal1->list[249].clin_cat_mean = "LABORATORY"
 SET internal1->list[250].clin_cat_mean = "LABORATORY"
 SET internal1->list[251].clin_cat_mean = "NURSORDERS"
 SET internal1->list[252].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[253].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[254].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[255].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[256].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[257].clin_cat_mean = "LABORATORY"
 SET internal1->list[258].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[259].clin_cat_mean = "LABORATORY"
 SET internal1->list[260].clin_cat_mean = "DIET"
 SET internal1->list[261].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[262].clin_cat_mean = "NURSORDERS"
 SET internal1->list[263].clin_cat_mean = "LABORATORY"
 SET internal1->list[264].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[265].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[266].clin_cat_mean = "MEDICATIONS"
 SET internal1->list[267].clin_cat_mean = "NURSORDERS"
 SET internal1->list[1].clin_sub_cat_mean = "ADRENAGNT"
 SET internal1->list[2].clin_sub_cat_mean = "AGINH"
 SET internal1->list[3].clin_sub_cat_mean = "ALDOANTAG"
 SET internal1->list[4].clin_sub_cat_mean = "ALPHABLK"
 SET internal1->list[5].clin_sub_cat_mean = "AMINOGLYC"
 SET internal1->list[6].clin_sub_cat_mean = "ANALG"
 SET internal1->list[7].clin_sub_cat_mean = "ANALG:AA"
 SET internal1->list[8].clin_sub_cat_mean = "ANALG:CA"
 SET internal1->list[9].clin_sub_cat_mean = "ANALG:NO"
 SET internal1->list[10].clin_sub_cat_mean = "ANALG:OP"
 SET internal1->list[11].clin_sub_cat_mean = "ANALG:OTH"
 SET internal1->list[12].clin_sub_cat_mean = "ANALG:PCA"
 SET internal1->list[13].clin_sub_cat_mean = "ANALG:UA"
 SET internal1->list[14].clin_sub_cat_mean = "ANATPATH"
 SET internal1->list[15].clin_sub_cat_mean = "ANCILMED"
 SET internal1->list[16].clin_sub_cat_mean = "ANGIOCEI"
 SET internal1->list[17].clin_sub_cat_mean = "ANGIORB"
 SET internal1->list[18].clin_sub_cat_mean = "ANTACIDS"
 SET internal1->list[19].clin_sub_cat_mean = "ANTIADREN"
 SET internal1->list[20].clin_sub_cat_mean = "ANTIAR"
 SET internal1->list[21].clin_sub_cat_mean = "ANTIAR:IA"
 SET internal1->list[22].clin_sub_cat_mean = "ANTIAR:IB"
 SET internal1->list[23].clin_sub_cat_mean = "ANTIAR:IC"
 SET internal1->list[24].clin_sub_cat_mean = "ANTIAR:II"
 SET internal1->list[25].clin_sub_cat_mean = "ANTIAR:III"
 SET internal1->list[26].clin_sub_cat_mean = "ANTICHOL"
 SET internal1->list[27].clin_sub_cat_mean = "ANTICOAG"
 SET internal1->list[28].clin_sub_cat_mean = "ANTICOAG:DTI"
 SET internal1->list[29].clin_sub_cat_mean = "ANTICOAG:OA"
 SET internal1->list[30].clin_sub_cat_mean = "ANTICOAG:W"
 SET internal1->list[31].clin_sub_cat_mean = "ANTICONV"
 SET internal1->list[32].clin_sub_cat_mean = "ANTIDIMM"
 SET internal1->list[33].clin_sub_cat_mean = "ANTIEMET"
 SET internal1->list[34].clin_sub_cat_mean = "ANTIFUNG"
 SET internal1->list[35].clin_sub_cat_mean = "ANTIHIST"
 SET internal1->list[36].clin_sub_cat_mean = "ANTIHYP"
 SET internal1->list[37].clin_sub_cat_mean = "ANTIHYP:D"
 SET internal1->list[38].clin_sub_cat_mean = "ANTIHYPO"
 SET internal1->list[39].clin_sub_cat_mean = "ANTIMIC"
 SET internal1->list[40].clin_sub_cat_mean = "ANTIMIC:AG"
 SET internal1->list[41].clin_sub_cat_mean = "ANTIMIC:AGIV"
 SET internal1->list[42].clin_sub_cat_mean = "ANTIMIC:AGN"
 SET internal1->list[43].clin_sub_cat_mean = "ANTIMIC:AM"
 SET internal1->list[44].clin_sub_cat_mean = "ANTIMIC:BLC"
 SET internal1->list[45].clin_sub_cat_mean = "ANTIMIC:BLC2"
 SET internal1->list[46].clin_sub_cat_mean = "ANTIMIC:BLC3"
 SET internal1->list[47].clin_sub_cat_mean = "ANTIMIC:BLC4"
 SET internal1->list[48].clin_sub_cat_mean = "ANTIMIC:BLI"
 SET internal1->list[49].clin_sub_cat_mean = "ANTIMIC:BLI"
 SET internal1->list[50].clin_sub_cat_mean = "ANTIMIC:BLP"
 SET internal1->list[51].clin_sub_cat_mean = "ANTIMIC:D"
 SET internal1->list[52].clin_sub_cat_mean = "ANTIMIC:OA"
 SET internal1->list[53].clin_sub_cat_mean = "ANTIMIC:Q"
 SET internal1->list[54].clin_sub_cat_mean = "ANTIMIC:T"
 SET internal1->list[55].clin_sub_cat_mean = "ANTIOBAGNT"
 SET internal1->list[56].clin_sub_cat_mean = "ANTIPYR"
 SET internal1->list[57].clin_sub_cat_mean = "ANTIRETAGNT"
 SET internal1->list[58].clin_sub_cat_mean = "ANTIVIRAGNT"
 SET internal1->list[59].clin_sub_cat_mean = "APPSTIM"
 SET internal1->list[60].clin_sub_cat_mean = "ASA"
 SET internal1->list[61].clin_sub_cat_mean = "BALLOONTAMP"
 SET internal1->list[62].clin_sub_cat_mean = "BARB"
 SET internal1->list[63].clin_sub_cat_mean = "BETAAG"
 SET internal1->list[64].clin_sub_cat_mean = "BETAAG:ILAB2"
 SET internal1->list[65].clin_sub_cat_mean = "BETAAG:ISAB2"
 SET internal1->list[66].clin_sub_cat_mean = "BETAAG:LAB2"
 SET internal1->list[67].clin_sub_cat_mean = "BETAAG:SBA"
 SET internal1->list[68].clin_sub_cat_mean = "BETABLOCK"
 SET internal1->list[69].clin_sub_cat_mean = "BIGUAN"
 SET internal1->list[70].clin_sub_cat_mean = "BIOPTISSDIAG"
 SET internal1->list[71].clin_sub_cat_mean = "BIPYRID"
 SET internal1->list[72].clin_sub_cat_mean = "BLACT:C4G"
 SET internal1->list[73].clin_sub_cat_mean = "BLACT:CARB"
 SET internal1->list[74].clin_sub_cat_mean = "BLACT:PEN"
 SET internal1->list[75].clin_sub_cat_mean = "BLACT:PEN4G"
 SET internal1->list[76].clin_sub_cat_mean = "BLOODBANK"
 SET internal1->list[77].clin_sub_cat_mean = "BLOODCOMPTST"
 SET internal1->list[78].clin_sub_cat_mean = "BLOODDON"
 SET internal1->list[79].clin_sub_cat_mean = "BLOODGAS"
 SET internal1->list[80].clin_sub_cat_mean = "BLOODTRANS"
 SET internal1->list[81].clin_sub_cat_mean = "BOWELPREP"
 SET internal1->list[82].clin_sub_cat_mean = "BOWELPREP1"
 SET internal1->list[83].clin_sub_cat_mean = "BOWELPREP2"
 SET internal1->list[84].clin_sub_cat_mean = "BOWELPREP3"
 SET internal1->list[85].clin_sub_cat_mean = "BREASTCARE"
 SET internal1->list[86].clin_sub_cat_mean = "BRONCH"
 SET internal1->list[87].clin_sub_cat_mean = "CALCCB"
 SET internal1->list[88].clin_sub_cat_mean = "CALCSUPP"
 SET internal1->list[89].clin_sub_cat_mean = "CARDENZ"
 SET internal1->list[90].clin_sub_cat_mean = "CARDGLYC"
 SET internal1->list[91].clin_sub_cat_mean = "CARDIAC"
 SET internal1->list[92].clin_sub_cat_mean = "CARDIMAG"
 SET internal1->list[93].clin_sub_cat_mean = "CARDSTRTST"
 SET internal1->list[94].clin_sub_cat_mean = "CAROTULTRA"
 SET internal1->list[95].clin_sub_cat_mean = "CEPH"
 SET internal1->list[96].clin_sub_cat_mean = "CEPH1G"
 SET internal1->list[97].clin_sub_cat_mean = "CEPH2G"
 SET internal1->list[98].clin_sub_cat_mean = "CEPH3G"
 SET internal1->list[99].clin_sub_cat_mean = "CEREBIMAG"
 SET internal1->list[100].clin_sub_cat_mean = "CHEM"
 SET internal1->list[101].clin_sub_cat_mean = "CHEMPAN"
 SET internal1->list[102].clin_sub_cat_mean = "CHROM"
 SET internal1->list[103].clin_sub_cat_mean = "CNSSTIM"
 SET internal1->list[104].clin_sub_cat_mean = "COAG"
 SET internal1->list[105].clin_sub_cat_mean = "COLPURAGNT"
 SET internal1->list[106].clin_sub_cat_mean = "COMBHYPOAGNT"
 SET internal1->list[107].clin_sub_cat_mean = "CONTIVII"
 SET internal1->list[108].clin_sub_cat_mean = "CONTORD"
 SET internal1->list[109].clin_sub_cat_mean = "CONTRAC"
 SET internal1->list[110].clin_sub_cat_mean = "CONTRAC:COC"
 SET internal1->list[111].clin_sub_cat_mean = "CONTRAC:OTH"
 SET internal1->list[112].clin_sub_cat_mean = "CONTRAC:POC"
 SET internal1->list[113].clin_sub_cat_mean = "CORTICOS"
 SET internal1->list[114].clin_sub_cat_mean = "DECOMPSURG"
 SET internal1->list[115].clin_sub_cat_mean = "DIAMINO"
 SET internal1->list[116].clin_sub_cat_mean = "DIUR"
 SET internal1->list[117].clin_sub_cat_mean = "DIUR:ID"
 SET internal1->list[118].clin_sub_cat_mean = "DIUR:LD"
 SET internal1->list[119].clin_sub_cat_mean = "DIUR:QD"
 SET internal1->list[120].clin_sub_cat_mean = "DIUR:TD"
 SET internal1->list[121].clin_sub_cat_mean = "DRAINMGMT"
 SET internal1->list[122].clin_sub_cat_mean = "DRESSCARE"
 SET internal1->list[123].clin_sub_cat_mean = "DRUGSOFABUSE"
 SET internal1->list[124].clin_sub_cat_mean = "DVTP:FXI"
 SET internal1->list[125].clin_sub_cat_mean = "DVTP:GH"
 SET internal1->list[126].clin_sub_cat_mean = "DVTP:LDUH"
 SET internal1->list[127].clin_sub_cat_mean = "DVTP:OA"
 SET internal1->list[128].clin_sub_cat_mean = "DVTPROPH"
 SET internal1->list[129].clin_sub_cat_mean = "EJECFRACEVAL"
 SET internal1->list[130].clin_sub_cat_mean = "ENDOSCOPY"
 SET internal1->list[131].clin_sub_cat_mean = "FETALMON"
 SET internal1->list[132].clin_sub_cat_mean = "FLUOROQ"
 SET internal1->list[133].clin_sub_cat_mean = "FOOTEXAM"
 SET internal1->list[134].clin_sub_cat_mean = "GASAGNT"
 SET internal1->list[135].clin_sub_cat_mean = "GASAGNT:H2A"
 SET internal1->list[136].clin_sub_cat_mean = "GENERAL"
 SET internal1->list[137].clin_sub_cat_mean = "GENETICTST"
 SET internal1->list[138].clin_sub_cat_mean = "GIPROPH"
 SET internal1->list[139].clin_sub_cat_mean = "GLUCIPI"
 SET internal1->list[140].clin_sub_cat_mean = "GLUCMGMT"
 SET internal1->list[141].clin_sub_cat_mean = "GLYCCONT"
 SET internal1->list[142].clin_sub_cat_mean = "GLYCOPEP"
 SET internal1->list[143].clin_sub_cat_mean = "GROINCAREINS"
 SET internal1->list[144].clin_sub_cat_mean = "GRPBSP"
 SET internal1->list[145].clin_sub_cat_mean = "HAIRREMOVAL"
 SET internal1->list[146].clin_sub_cat_mean = "HEMAT"
 SET internal1->list[147].clin_sub_cat_mean = "HEMATOAGNT"
 SET internal1->list[148].clin_sub_cat_mean = "HEMOSTAGNT"
 SET internal1->list[149].clin_sub_cat_mean = "HETOSSPROPH"
 SET internal1->list[150].clin_sub_cat_mean = "HISRECANTAG"
 SET internal1->list[151].clin_sub_cat_mean = "HMGCOARI"
 SET internal1->list[152].clin_sub_cat_mean = "HPYLE"
 SET internal1->list[153].clin_sub_cat_mean = "HPYLE:A"
 SET internal1->list[154].clin_sub_cat_mean = "HPYLE:BC"
 SET internal1->list[155].clin_sub_cat_mean = "HPYLE:CA"
 SET internal1->list[156].clin_sub_cat_mean = "HPYLTST"
 SET internal1->list[157].clin_sub_cat_mean = "HUMBNATPEP"
 SET internal1->list[158].clin_sub_cat_mean = "HYPERCOSTUD"
 SET internal1->list[159].clin_sub_cat_mean = "IMAGING"
 SET internal1->list[160].clin_sub_cat_mean = "IMMUN"
 SET internal1->list[161].clin_sub_cat_mean = "IMMUN:CI"
 SET internal1->list[162].clin_sub_cat_mean = "IMMUN:I"
 SET internal1->list[163].clin_sub_cat_mean = "IMMUN:P"
 SET internal1->list[164].clin_sub_cat_mean = "IMMUN:R"
 SET internal1->list[165].clin_sub_cat_mean = "INDAUG"
 SET internal1->list[166].clin_sub_cat_mean = "INHBR"
 SET internal1->list[167].clin_sub_cat_mean = "INHBR:IAB"
 SET internal1->list[168].clin_sub_cat_mean = "INHBR:IB2ALA"
 SET internal1->list[169].clin_sub_cat_mean = "INHBR:IB2ASA"
 SET internal1->list[170].clin_sub_cat_mean = "INHBR:ICB"
 SET internal1->list[171].clin_sub_cat_mean = "INHCORT"
 SET internal1->list[172].clin_sub_cat_mean = "INSTRUCT"
 SET internal1->list[173].clin_sub_cat_mean = "INSUL"
 SET internal1->list[174].clin_sub_cat_mean = "INSUL:CIVII"
 SET internal1->list[175].clin_sub_cat_mean = "INSUL:CSCII"
 SET internal1->list[176].clin_sub_cat_mean = "INTRAEST"
 SET internal1->list[177].clin_sub_cat_mean = "INVMECHVENT"
 SET internal1->list[178].clin_sub_cat_mean = "IRONSUPP"
 SET internal1->list[179].clin_sub_cat_mean = "LARYNGOSC"
 SET internal1->list[180].clin_sub_cat_mean = "LEUKRECANTAG"
 SET internal1->list[181].clin_sub_cat_mean = "LINCOS"
 SET internal1->list[182].clin_sub_cat_mean = "LIPMGMT"
 SET internal1->list[183].clin_sub_cat_mean = "LIPMGMT:BAS"
 SET internal1->list[184].clin_sub_cat_mean = "LIPMGMT:FAD"
 SET internal1->list[185].clin_sub_cat_mean = "LIPMGMT:NAD"
 SET internal1->list[186].clin_sub_cat_mean = "MACROL"
 SET internal1->list[187].clin_sub_cat_mean = "MAGSUPP"
 SET internal1->list[188].clin_sub_cat_mean = "MEGLIT"
 SET internal1->list[189].clin_sub_cat_mean = "METHYLX"
 SET internal1->list[190].clin_sub_cat_mean = "MICRO"
 SET internal1->list[191].clin_sub_cat_mean = "MISCNURSORD"
 SET internal1->list[192].clin_sub_cat_mean = "MONITOR"
 SET internal1->list[193].clin_sub_cat_mean = "MONOBACT"
 SET internal1->list[194].clin_sub_cat_mean = "MUCOLYT"
 SET internal1->list[195].clin_sub_cat_mean = "NITR"
 SET internal1->list[196].clin_sub_cat_mean = "NITROFUR"
 SET internal1->list[197].clin_sub_cat_mean = "NITROIMID"
 SET internal1->list[198].clin_sub_cat_mean = "NOTIFY"
 SET internal1->list[199].clin_sub_cat_mean = "OPANALG"
 SET internal1->list[200].clin_sub_cat_mean = "OSMDIUR"
 SET internal1->list[201].clin_sub_cat_mean = "OXAZ"
 SET internal1->list[202].clin_sub_cat_mean = "OXYGENASMT"
 SET internal1->list[203].clin_sub_cat_mean = "PA"
 SET internal1->list[204].clin_sub_cat_mean = "PAI"
 SET internal1->list[205].clin_sub_cat_mean = "PANCENZY"
 SET internal1->list[206].clin_sub_cat_mean = "PAO"
 SET internal1->list[207].clin_sub_cat_mean = "PARENB2AG"
 SET internal1->list[208].clin_sub_cat_mean = "PARENNUTR"
 SET internal1->list[209].clin_sub_cat_mean = "PATDUCARTCL"
 SET internal1->list[210].clin_sub_cat_mean = "PATHTUMSTUD"
 SET internal1->list[211].clin_sub_cat_mean = "PEDFORM"
 SET internal1->list[212].clin_sub_cat_mean = "PERINEALCARE"
 SET internal1->list[213].clin_sub_cat_mean = "PHOSACIDDER"
 SET internal1->list[214].clin_sub_cat_mean = "PLEUFLSTUD"
 SET internal1->list[215].clin_sub_cat_mean = "POTSUPP"
 SET internal1->list[216].clin_sub_cat_mean = "PROCEDURE"
 SET internal1->list[217].clin_sub_cat_mean = "PROTPMPINH"
 SET internal1->list[218].clin_sub_cat_mean = "RADIOG"
 SET internal1->list[219].clin_sub_cat_mean = "RADIOGCHEST"
 SET internal1->list[220].clin_sub_cat_mean = "RADIOGHIP"
 SET internal1->list[221].clin_sub_cat_mean = "RADIOGKNEE"
 SET internal1->list[222].clin_sub_cat_mean = "RADIOTHER"
 SET internal1->list[223].clin_sub_cat_mean = "RETINOSCRN"
 SET internal1->list[224].clin_sub_cat_mean = "RIFAMYC"
 SET internal1->list[225].clin_sub_cat_mean = "RISCSS"
 SET internal1->list[226].clin_sub_cat_mean = "ROUTINE"
 SET internal1->list[227].clin_sub_cat_mean = "SALICYLATES"
 SET internal1->list[228].clin_sub_cat_mean = "SALINEEXP"
 SET internal1->list[229].clin_sub_cat_mean = "SCRTST"
 SET internal1->list[230].clin_sub_cat_mean = "SCRTSTDIAB"
 SET internal1->list[231].clin_sub_cat_mean = "SCRTSTNEPH"
 SET internal1->list[232].clin_sub_cat_mean = "SEDATIVES"
 SET internal1->list[233].clin_sub_cat_mean = "SEROLOGY"
 SET internal1->list[234].clin_sub_cat_mean = "SERUMSTUD"
 SET internal1->list[235].clin_sub_cat_mean = "SMBOWELEVAL"
 SET internal1->list[236].clin_sub_cat_mean = "SMKCESSMED"
 SET internal1->list[237].clin_sub_cat_mean = "SPUTUMSTUD"
 SET internal1->list[238].clin_sub_cat_mean = "STOOLSOFT"
 SET internal1->list[239].clin_sub_cat_mean = "SULFONAM"
 SET internal1->list[240].clin_sub_cat_mean = "SULFONYL"
 SET internal1->list[241].clin_sub_cat_mean = "SULFONYL:1G"
 SET internal1->list[242].clin_sub_cat_mean = "SULFONYL:2G"
 SET internal1->list[243].clin_sub_cat_mean = "SUPP"
 SET internal1->list[244].clin_sub_cat_mean = "SUPPOX"
 SET internal1->list[245].clin_sub_cat_mean = "SURFACT"
 SET internal1->list[246].clin_sub_cat_mean = "SURGPREP"
 SET internal1->list[247].clin_sub_cat_mean = "SYSCORT"
 SET internal1->list[248].clin_sub_cat_mean = "TEMPCARDPAC"
 SET internal1->list[249].clin_sub_cat_mean = "THERDRUGS"
 SET internal1->list[250].clin_sub_cat_mean = "THERMON"
 SET internal1->list[251].clin_sub_cat_mean = "THERMOREG"
 SET internal1->list[252].clin_sub_cat_mean = "THIAZOLID"
 SET internal1->list[253].clin_sub_cat_mean = "THIENOPYR"
 SET internal1->list[254].clin_sub_cat_mean = "THROMBAGNT"
 SET internal1->list[255].clin_sub_cat_mean = "THYROIDANTAG"
 SET internal1->list[256].clin_sub_cat_mean = "THYROIDHORM"
 SET internal1->list[257].clin_sub_cat_mean = "THYROIDSTUD"
 SET internal1->list[258].clin_sub_cat_mean = "TOCOLYTAGNT"
 SET internal1->list[259].clin_sub_cat_mean = "TPNLABS"
 SET internal1->list[260].clin_sub_cat_mean = "TUBEFEED"
 SET internal1->list[261].clin_sub_cat_mean = "URINANALG"
 SET internal1->list[262].clin_sub_cat_mean = "URINCATHMGMT"
 SET internal1->list[263].clin_sub_cat_mean = "URINESTUD"
 SET internal1->list[264].clin_sub_cat_mean = "VASOACTAGNT"
 SET internal1->list[265].clin_sub_cat_mean = "VASODIL"
 SET internal1->list[266].clin_sub_cat_mean = "VITK"
 SET internal1->list[267].clin_sub_cat_mean = "IPMVD"
 DECLARE clin_cat_cd = f8 WITH noconstant(0.0)
 DECLARE clin_sub_cat_cd = f8 WITH noconstant(0.0)
 DECLARE high1 = i4 WITH noconstant(0)
 DECLARE high2 = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 SET high1 = value(size(internal1->list,5))
 SET high2 = high1
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d1  WITH seq = high1)
  PLAN (d1)
   JOIN (cv
   WHERE (cv.cdf_meaning=internal1->list[d1.seq].clin_cat_mean)
    AND cv.code_set=16389
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(internal2->list,5))
    stat = alterlist(internal2->list,(cnt+ 10))
   ENDIF
   internal2->list[cnt].clin_cat_mean = cv.cdf_meaning, internal2->list[cnt].dcp_clin_cat_cd = cv
   .code_value
  FOOT REPORT
   cnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  clin_cat_mean = internal1->list[d.seq].clin_cat_mean
  FROM code_value cv,
   (dummyt d  WITH seq = high1)
  PLAN (d)
   JOIN (cv
   WHERE (cv.cdf_meaning=internal1->list[d.seq].clin_sub_cat_mean)
    AND cv.code_set=29700)
  ORDER BY clin_cat_mean, cv.cdf_meaning, cv.code_value
  HEAD REPORT
   cnt = 0
  HEAD clin_cat_mean
   clin_cat_meaning = internal1->list[d.seq].clin_cat_mean
  HEAD cv.cdf_meaning
   dup_cnt = 0, idx = 0, idx2 = 0,
   prev = 0
  DETAIL
   cnt = (cnt+ 1), dup_cnt = (dup_cnt+ 1)
   IF (dup_cnt > 1
    AND prev != cv.code_value)
    high2 = (high2+ 1), stat = alterlist(internal2->list,high2), idx2 = locateval(idx2,1,high1,
     clin_cat_meaning,internal1->list[idx2].clin_cat_mean),
    internal2->list[high2].dcp_clin_cat_cd = internal2->list[idx2].dcp_clin_cat_cd, internal2->list[
    high2].clin_cat_mean = clin_cat_meaning, internal2->list[high2].dcp_clin_sub_cat_cd = cv
    .code_value,
    internal2->list[high2].clin_sub_cat_mean = cv.cdf_meaning, internal2->list[high2].
    clin_sub_cat_display = trim(cv.display), internal2->list[high2].sub_cat_active_ind = cv
    .active_ind
   ELSEIF (dup_cnt=1)
    idx = locateval(idx,1,high1,cv.cdf_meaning,internal1->list[idx].clin_sub_cat_mean), internal2->
    list[idx].dcp_clin_sub_cat_cd = cv.code_value, internal2->list[idx].clin_sub_cat_mean = cv
    .cdf_meaning,
    internal2->list[idx].clin_sub_cat_display = trim(cv.display), internal2->list[idx].
    sub_cat_active_ind = cv.active_ind
   ENDIF
   idx = 0, idx2 = 0, prev = cv.code_value
  FOOT  cv.cdf_meaning
   dup_cnt = dup_cnt
  FOOT  clin_cat_mean
   cnt = cnt
  FOOT REPORT
   cnt = cnt
  WITH nocounter
 ;end select
 SET high = value(size(internal2->list,5))
 SET active = "N"
 SET group = "N"
 FOR (i = 1 TO high)
   SET active = "N"
   SET group = "N"
   SET activematchcd = 0.0
   IF ((internal2->list[i].dcp_clin_cat_cd > 0)
    AND (internal2->list[i].dcp_clin_sub_cat_cd > 0)
    AND (internal2->list[i].clin_cat_mean > "")
    AND (internal2->list[i].clin_sub_cat_mean > ""))
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=29700
       AND trim(cv.display)=trim(internal2->list[i].clin_sub_cat_display)
       AND (cv.code_value != internal2->list[i].dcp_clin_sub_cat_cd)
       AND cv.active_ind=1)
     DETAIL
      activematchcd = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET active = "Y"
    ENDIF
    IF (active="N")
     IF ((internal2->list[i].sub_cat_active_ind=0))
      UPDATE  FROM code_value cv
       SET cv.active_ind = 1, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = 0,
        cv.updt_task = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = 0
       WHERE (cv.code_value=internal2->list[i].dcp_clin_sub_cat_cd)
      ;end update
     ENDIF
     SELECT INTO "nl:"
      FROM code_value_group cvg
      PLAN (cvg
       WHERE (cvg.parent_code_value=internal2->list[i].dcp_clin_cat_cd)
        AND (cvg.child_code_value=internal2->list[i].dcp_clin_sub_cat_cd))
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET group = "Y"
     ENDIF
     IF (group="N")
      INSERT  FROM code_value_group cvg
       SET cvg.parent_code_value = internal2->list[i].dcp_clin_cat_cd, cvg.child_code_value =
        internal2->list[i].dcp_clin_sub_cat_cd, cvg.collation_seq = 0,
        cvg.code_set = 29700, cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_id = 0,
        cvg.updt_task = 0, cvg.updt_cnt = 0, cvg.updt_applctx = 0
       WITH nocounter
      ;end insert
     ENDIF
    ELSEIF (activematchcd > 0)
     UPDATE  FROM code_value cv
      SET cv.cdf_meaning = trim(internal2->list[i].clin_sub_cat_mean), cv.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), cv.updt_id = 0,
       cv.updt_task = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = 0
      WHERE cv.code_value=activematchcd
       AND cv.cdf_meaning=null
     ;end update
    ENDIF
   ENDIF
 ENDFOR
 FREE RECORD internal1
 FREE RECORD internal2
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Readme 3259 completed successfully"
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
