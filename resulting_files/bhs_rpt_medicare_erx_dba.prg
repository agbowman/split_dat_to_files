CREATE PROGRAM bhs_rpt_medicare_erx:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 org[*]
     2 f_org_id = f8
     2 s_org_name = vc
     2 n_phys_cnt = i4
     2 phys[*]
       3 f_phys_id = f8
       3 s_phys_name = vc
       3 s_position = vc
       3 n_ord_cnt = i4
       3 ord[*]
         4 s_pat_name = vc
         4 f_order_id = f8
         4 s_order_mnem = vc
   1 phys[*]
     2 s_name_full = vc
     2 f_phys_id = f8
 ) WITH protect
 DECLARE mf_pharm_cat_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PHARMACY"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_out_class_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",321,"OUTPATIENT"))
 DECLARE mf_triage_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"TRIAGE"))
 DECLARE mf_op_onetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTONETIME"))
 DECLARE mf_off_vis_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OFFICEVISIT"))
 DECLARE mf_disch_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHARGEDOUTPATIENT"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat(trim( $S_END_DT)," 23:59:59"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.end_effective_dt_tm > sysdate
    AND trim(cnvtupper(p.name_full_formatted)) IN ("ABARE MD , NATHAN J", "ABBOTT MD, MARY-ALICE",
   "AHMAD MD , SALMAN", "AHMED MD , MOHAMMED S", "AJELLO MD, ROBERT R",
   "ALBERT PA , GRACE", "ALEXANDER PA , JAMILAH ALI", "ALI MD , SYED S", "ALLEN MD, HOLLEY F",
   "ALLEN NP, NANCY",
   "ALLI MD, GLENN F", "ALOUIDOR MD , REGINALD", "AMES CNM, DEBBIE R", "ANFANG MD, STUART A",
   "ANGELIDES MD, ANASTASIOS G",
   "ANTILL CNM , MAGDALENE L", "APONTE MD, OLGA", "ARENAS MD, RICHARD B", "ARMON MD, CARMEL",
   "ASIK MD, ARMEN",
   "ATHREYA MD , RANI U", "AUBRY-MCAVOY NP , KATHRYN", "AULAKH MD , SUDEEP K", "AZIZ MD, HANY",
   "BAILEY-SARNELLI MD, PATRICIA E",
   "BALDER MD, ANDREW H", "BANKER MD, BRIAN", "BAQUIS MD, GEORGE D", "BARNETT MD, SCOTT",
   "BARRON NP, ROBERTA",
   "BARTLETT PA , JESSICA A", "BARTLEY MD, MARY M", "BEAN MD, MARK S", "BEAUDRY CNM , LISA A",
   "BEAULIEU NP , DANIELLE",
   "BEAUZILE MD , RONALD", "BEAUZILE-DELIMON MD , LOURDES H", "BELFORTI MD, RAQUEL",
   "BELL MD, CARRIE L", "BELLANTONIO MD, SANDRA",
   "BELO MD, ANGELICA", "BENJAMIN MD, EVAN M", "BENSON MD, BRYANT E", "BERTRAND NP, LINDA LEA",
   "BHATT MD , RITIKA",
   "BIAGINI , MARINO", "BIAGINI MD , MARINO L", "BIGNELL NP, CANDACE", "BILLINGS CNM, DEBORAH",
   "BISHOP DO , TODD M",
   "BLIER MD, PETER R", "BLUME PA , DEBORAH A", "BOLDEN NP , PHALAN LARESE", "BOOS MD , STEPHEN C",
   "BORDEN MD, SAMUEL H",
   "BOSS MD, EUGENE F", "BOURGEAULT PA , BRIAN", "BOYLE MD, ELIZABETH", "BRANCH MD, HILARY J",
   "BRENNAN MD, MAURA J",
   "BREWER MD , SARA A", "BRODER MD, MARTIN I", "BROWN MD (BMERF), RICHARD B", "BROWN MD , PATRICK J",
   "BSAT MD, FADI",
   "BURKMAN MD, RONALD T", "BUTLER MD , PETER W", "CAHILL NP , MOLLY K", "CALACCI CNM , ALICIA B",
   "CAMARANO MD , GUSTAVO P",
   "CAMERON PA , KATHERINE E", "CANNIZZO MD, FRANCIS", "CANTY MD, LINDA", "CASH MD , SUSAN M",
   "CASSELLS MD, LUCINDA",
   "CASSIDY NP, KATHLEEN A", "CHAPMAN PA , JAMIE M", "CHECCHI MD, ADELE", "CHESKY MD, ALLA",
   "CHIVERS NP, MARIE B",
   "CHRISTENSEN CNM , HOLLY", "CHRZANOWSKI NP , JAMI B", "CHURCHILL MD , ERIC C",
   "CINELLI DO , SCOTT M", "COE MD, NICHOLAS P",
   "COHEN MD, LEWIS M", "COLEY-KOUADIO CNM , THERESA M", "COLODNY MD, STEPHEN Z", "COLUCCI NP, DIANA",
   "CONTI MD , AMANDA",
   "COOK MD, JAMES R", "COPELAND MD, HERBERT WILLIAM", "CORSETTI NP, AMY L", "COSSIN MD, JEFFREY R",
   "CREMINS PA , ANGELA M",
   "DABAKIS-CHOQUETTE NP , SUZANNE F", "DARDANO MD, KRISTIN L", "DASH MD, CARY M",
   "DAVIDSON CNM , NANCY J", "DEJOY CNM , SUSAN A",
   "DERDERIAN NP , SHERYL", "DESILETS MD, DAVID", "DETTERMAN CNM , CARLY A", "DOBEN MD , ANDREW R",
   "DOLAN PA , MEGHAN E",
   "DONOVAN MD, JULIA T", "DOODY PA , AMY", "DORANTES MD, JENNIFER", "DOUBLEDAY NP , NANCY D",
   "DREDGE MD, DAVID",
   "DUDA MD, FRANCIS J", "DUFFELMEYER MD, MICHELLE E", "DUNBAR MD, NANCY", "DUNCAN MD, JOYCE E",
   "DUVAL MD , TARA",
   "EARLE MD, DAVID B", "ESPINEL MD , JOSE E", "FANTON MD, JOHN H", "FAVATA PA, LOUIS P",
   "FAY MD, ANDREW K",
   "FELDMAN MD , LAURA", "FERNANDEZ MD, BERT", "FERRO NP, SHERRY", "FICKIE MD , MATTHEW R",
   "FINNEGAN MD, COLLEEN B",
   "FINN-RIZZO PA/NP , DENISE", "FINN-RIZZO FNP, DENISE", "FISCHEL MD, STEVEN V",
   "FISHER MD, DONNA J", "FISHER PA , REBECCA A",
   "FLINK PA , LAUREN A", "FLYNN NP, GLENDA B", "FORTIER NP , AMY CELINE", "FOX MD , MARSHAL T",
   "FOX MD, STEPHEN H",
   "FRANCZYK NP , ANN", "FRANK NP , DIANE B", "GABERMAN MD, JONNA I", "GALLI CNM , AMY B",
   "GANIM MD , ROSE B",
   "GARG MD , ANUJA", "GARRETSON MD , ADAM D", "GEBHARDT MD , JAMES G", "GERSTLE MD, KATHERINE S",
   "GERSTLE MD, ROBERT S",
   "GHAOUI MD , RONY M", "GILMORE MD, HERBERT E", "GIUGLIANO MD, GREGORY", "GOFF MD, SARAH",
   "GOLDFIELD MD, NORBERT I",
   "GOLDSTEIN MD, CAROLYN", "GONCERO MD , GRACE MAY D", "GORDNER DO , CHELSEA C",
   "GOTTLIEB MD, ROBIN", "GRAICHEN PA, ALAN R",
   "GRANOWITZ MD, ERIC V", "GRAVES CNM, BARBARA W", "GREEN MD, GERALD", "GREENBACHER MD, DARIUS",
   "GREWAL MD, SATKIRAN",
   "GROSS MD , RONALD I", "GROSSMAN MD , LINDSEY K", "GROW MD, DANIEL R", "GUHN MD, AUDREY S",
   "GUL MD , MUHAMMAD A",
   "HADRO MD , NEAL CHRISTOPHER", "HAESSLER MD, SARAH", "HAKKARAINEN  PA, JENNIFER",
   "HALLISEY CNM , ANASTASIA M", "HALPERIN MD , PETER J",
   "HANKS PNP, DEBORAH L", "HARMANLI MD, OZ", "HARTENSTEIN MD , THEODORE", "HAWES NP , ZOE C",
   "HEALY MD, ANDREW J",
   "HEHN MD, BOYD", "HIGBY MD, DONALD J", "HIRKO MD , MARK", "HIRSCH MD, BARRY Z",
   "HISER MD, WILLIAM L",
   "HOAR MD, HARRY", "HOBGOOD MD , CASSANDRA D", "HOCHHEISER MD, GARY MARK", "HOFFMAN MD , BRIAN D",
   "HOUSE MD, WILLIAM",
   "HOWARD MD , LESLIE M", "HOWE NP, THERESA S", "HSU MD, PHILIP S", "HUBBARD NP, SANDRA S",
   "HURLEY NP, FRANCES M",
   "IGLESIAS LINO MD , LAURA", "ISLAM MD, ASHEQUL", "IYER MD , SMITHA S", "JABIEV MD, AZAD",
   "JACKSON KOHLIN CNM , DONNA M",
   "JACKSON MD, ANTHONY H", "JACKSON NP , JOANNE", "JAMES NP, HELEN", "JEPSEN NP, MARY ELLEN",
   "JIANG MD, LENG",
   "JOHNSON MD , KARIN G", "JOHNSON NP , CYNTHIA J", "JOHNSON NP , JALIL A", "JOHNSTON MD, ALICIA M",
   "JONES MD , KEISHA A",
   "JONES MD, EMLEN H", "KAISER NP, KRISTIN", "KANNEL MD, CRAIG E", "KAPLAN CNM , JANET L",
   "KASHEY MD, NIKOLAUS",
   "KASLOVSKY MD , ROBERT A", "KASSIS MD , PETER B", "KATZ MD(TEXAS) , DEBRA M", "KATZ MD, DEBORAH",
   "KATZ MD, DAVID E",
   "KAUFMAN MD, JEFFREY L", "KAYE MD, THOMAS S", "KELLY MD, BRENDAN P", "KELTER PA-C , RONALD A",
   "KIDDER NP, LEILANI",
   "KIRK NP, BARBARA", "KLOCZKO MD, NANCY M", "KOENIGS MD , LAURA PINKSTON", "KOGUT NP , KATHRYN",
   "KOLB NP , ERIN M",
   "KRAUSE CNM, SUSAN", "KRULEWITZ MD, ARTHUR H", "KUDLER MD, NEIL R", "KUGELMASS MD , AARON DAVID",
   "KUHN MD, JAY",
   "KUSELIAS PA , ASHLEY J", "KUTAYLI MD , ZIAD N", "LAMOUREUX NP , DEBRA A", "LANDIS MD, JOHN N",
   "LAO MD, ERIC T",
   "LARIOZA MD , JULIUS", "LATTES CNM, JAIN", "LEDERMAN MD, HARVEY", "LEE MD , JACQUELINE J",
   "LEE MD, PATRICK C",
   "LELLMAN, MD, JOSEPH E", "LEVINE MD, GARY F", "LIAUTAUD MD , SYBILLE M", "LICHTER NP , DEREK D",
   "LIDDELL CNM, SUSAN J",
   "LINCOLN MD, THOMAS A", "LIPTZIN MD, BENJAMIN", "LONDON MD, NAOMI D", "LOTFI MD , AMIR S",
   "LUCIANO MD , GINA",
   "LUIPPOLD PHY. CNS , STEPHEN A", "LUKANICH MD , JEANNE M", "LUTY MD , JOANNA G",
   "LYLE CNM , HEIDI E", "LYNAUGH MD, SARAH",
   "LYNCH MD, KELLY", "LYNE NP, LORI ANNE", "MAISSEL MD, GERDA S", "MANARITE NP, ROSE MARIE",
   "MANARITE NP, ROSE MARIE",
   "MARKENSON MD, GLENN R", "MARNIN CNM , VICKI NOLAN", "MARTAGON-VILLAMIL MD, JOSE",
   "MARTINEZ-SILVESTRIN MD, JULI", "MASON MD, HOLLY S",
   "MCCANN MD, JOHN C", "MCCARTHY PA, JEANNE", "MCCLELLAND MD, ALAN", "MCGOVERN NP , TRICIA L.",
   "MCKEE NP, KAREN M",
   "MCQUISTON PHD, SUSAN", "MCSWEENEY CNM , JENNIFER A", "MEADE MD, LAUREN B", "MECKEL PA, MARIE",
   "MERCADO MD, DONNA L",
   "MERCED PA , MARIANGELA", "MERTENS MD, WILSON", "MEYER MD, KATHLEEN M",
   "MIKKALSON CNM , GENELL LYNN", "MILLER MD, CHRISTIE",
   "MILLER MD, NANCY H", "MILLER-MACK NP , ELLEN T", "MILLS MD , CHRISTOPHER J",
   "MIRANDA-SOUSA MD , ALEJANDRO J", "MIROT MD, ADAM M",
   "MUELLER MD, STEPHEN G", "MUTHAVARAPU MD, SATISH B", "MUTLU PA , LYNN N", "MYERS MD , TASHANNA K",
   "NAGPAL MD , KIRTI",
   "NATHAN MD, MARTHA A", "NAVAB MD, FARHAD", "NELSON NP , ROSARIO M", "NESTEBY NP , JENNIFER A",
   "NICASIO DO , JOHN",
   "NIGRINY MD , JOHN F", "NORRIS MD, MARC A", "NOVICK CNM , GINA B", "ODULIO MD, ROSETTE",
   "OESER NP , LINDA J",
   "OH MD, DENNIS S", "ONEILL NP, LINDA M", "OREILLY MD, JOHN R", "OSAKWE MD, IBITORO",
   "OSHEA MD, DONNA L",
   "OSTROWSKI MD , EDWARD S", "OWEN CNM , PAMELA E", "PADDLEFORD PA , BONNIE H",
   "PAEZ MD , ARMANDO PHILIP S", "PAGE MD, DAVID W",
   "PALMER CNM, LOIS C", "PALMER NP , RACQUEL R", "PAPPAS PA , DALE C", "PARIKH MD , PRANAY M",
   "PARIS MD, YVONNE M",
   "PATEL MD , PIKESHKUMAR J", "PATTERSON MD, LISA A", "PAWLOWSKI NP , ALYSSA GISELE",
   "PECK CNM, SUSAN E", "PELUSO MD, JOHN",
   "PETERMAN MD, J MARK", "PETERSON NP , LAUREN E", "PICCHIONI MD, MICHAEL", "PIOGGIA, FNP , BELINDA",
   "PLAGER NP, JANE",
   "PLEVYAK MD, MICHAEL P", "PLUMMER MD, PIXIE", "POLONSKY MD, LINDA R", "POPKIN MD, DAVID E",
   "PRICE MD, BERNARD T",
   "PSALTIS CNM, AUDREY G", "RACE MD, THOMAS F", "RAGHUNATHAN MD, UMA", "RAHN MD, SHELLEY",
   "RANDHAWA MD , SANJEEVAN",
   "RAPPOLD CNM, MICHELLE", "RASMUSSEN MD, YEKATHERINE", "REATIRAZA MD , JOCELIN",
   "RECHTSCHAFFEN MD, ROBERT E", "REDDY MD, VASANTHA",
   "REFERMAT MD , DAVID", "REITER MD, EDWARD O", "RHEE MD, SANG WON", "RICHARDSON MD, MATTHEW",
   "RICHMOND MD , JONATHAN DAVID",
   "ROBERTS MD, HUGH", "RODSTEIN MD, BARRY", "ROMANELLI MD, JOHN R", "ROSE MD, DAVID",
   "ROSEN MD, BETH",
   "ROSENBLUM MD, MICHAEL", "ROTHBERG MD, MICHAEL", "ROTHSTEIN MD, ROBERT W", "ROURKE MD, SARA A",
   "ROWLAND MD, THOMAS W",
   "RUNGE NP , DAVID A", "RUSSELL PSYCH C.N.S. , ROBERT J", "RYZEWICZ MD, STEPHEN J",
   "SADOF MD, MATTHEW D", "SAFFORD NP, MARY JO",
   "SALAZAR MD, RODRIGO", "SAMALE PA, JENNIFER L", "SANKEY MD, HEATHER Z",
   "SANTIAGO-CRUZ MD , LUIS A", "SARVET MD, BARRY",
   "SCAVRON MD, JEFFREY", "SCHALET MD , BENJAMIN J", "SCHAPIRO MD , ROBERT N",
   "SCHIMMEL MD , JENNIFER J", "SCHIRMER MD , CLEMENS M",
   "SCHWEIGER MD, MARC J", "SEEVE MD, LEONARD M", "SEILER MD , ADRIANNE", "SEN MD, SABYASACHI",
   "SEVIGNY CNM, CHRISTINE",
   "SEVIGNY CNM, CHRISTINE", "SEYMOUR MD, NEAL", "SHARPLESS MD , KATHRYN E", "SHARRON NP, MARGARET E",
   "SHENOY MD , ANANT",
   "SHIN MD , JOSEPH H", "SHOUKRI MD, KAMAL C", "SHOUSHTARI MD, NILOUFAR", "SIEGE MD , SCOTT A",
   "SILVA MD, JORGE E",
   "SILVERMAN MD , STEPHANIE D", "SINGH MD , RACHANA", "SITES MD , CYNTHIA K", "SKIEST MD, DANIEL",
   "SLAWSKY MD, MARA T",
   "SMITH DO , ROBERT D", "SNYDER MD , JOHN", "SOLA GOMEZ MD, ORLANDO I", "SOLON MD, MICHAEL H",
   "SOUCY PA , DAVID",
   "SPELLMAN MD, NICHOLAS T", "SPENCER-LONG NP , SALLY", "STARLING CNM , SUZANNE S",
   "STARLING CNM , TARA SRI", "STATZ MD, INGRID E",
   "STECHENBERG MD , BARBARA W", "STEINGART MD, RICHARD H", "STELMOKAS NP , ANNE-MARIE",
   "STEVENS MD , JEREMY", "STEWART MD , JAMES A",
   "STOENESCU MD , MATHIAS L", "STRAUSS MD , LOUIS S", "SULLIVAN NP , SHERI LEE",
   "TAPPIN MD , DYANNE M", "TARDIFF-WEATHERBEE NP, CHRISTINA",
   "TAYLOR MD , SHERRY L", "TETER MD, GEORGE H", "THERIAULT PA, LINDA M", "THOMAS MD , ASHA",
   "THOMAS MD , DEEPU A",
   "THOMPSON DO , JULIE ANNE STANITIS", "TIPTON NP, CATHERINE H", "TOKARZ MD, JEANNETTE M",
   "TORRES MD, ORLANDO L", "TORRES-MUNIZ MD , NORAYMAR",
   "TROCZYNSKI NP , KATHY E", "TSIRKA MD, ANNA", "TYLER MD , KELLY M", "VALANIA DO , GREGORY",
   "VON GOELER MD, DOROTHEA",
   "WAIT MD, RICHARD B", "WALTING MD , PAUL J", "WANG MD , JAMES KUO CHANG", "WASEEF MD , AHMAD",
   "WASLICK MD, BRUCE",
   "WHITE MD , KATHARINE O", "WICZYK MD, HALINA", "WIENER CNM, JOAN L", "WILLERS MD , MICHAEL E",
   "WILLIAMS MD, JACKSON",
   "WILLIAMS NP , MARIA A", "WILLIAMSON NP, KATHERINE", "WINSTON MD, ELEANOR",
   "WITTCOPP MD, CHRYSTAL", "WOJCIK PA , JOHN S",
   "WOODS PA, SHARON", "WRETZEL MD , SHARON", "WU MD , HAO M", "YOSS MD, MARCI",
   "YOTOVA MD , MALINA T",
   "ZACHARIAH NP , REENA M", "ZAGHLOUL MD , SHADI", "ZIMMERMANN NP, CAROL A"))
  HEAD REPORT
   pl_cnt = 0
  HEAD p.person_id
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->phys,pl_cnt), m_rec->phys[pl_cnt].f_phys_id = p
   .person_id,
   m_rec->phys[pl_cnt].s_name_full = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  org.org_name, org.organization_id
  FROM organization org
  PLAN (org
   WHERE cnvtupper(org.org_name)="BMP*"
    AND org.active_ind=1)
  ORDER BY org.org_name
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->org,5))
    stat = alterlist(m_rec->org,(pl_cnt+ 10))
   ENDIF
   m_rec->org[pl_cnt].f_org_id = org.organization_id, m_rec->org[pl_cnt].s_org_name = org.org_name
  FOOT REPORT
   stat = alterlist(m_rec->org,pl_cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM orders o,
   order_detail od,
   order_action oa,
   encounter e,
   encntr_plan_reltn epr,
   health_plan h,
   prsnl pr,
   organization org,
   person p
  PLAN (o
   WHERE o.active_ind=1
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND o.catalog_type_cd=mf_pharm_cat_type_cd
    AND o.orig_ord_as_flag=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_status_cd=mf_ordered_cd
    AND oa.action_type_cd=mf_order_cd
    AND expand(ml_cnt,1,size(m_rec->phys,5),oa.order_provider_id,m_rec->phys[ml_cnt].f_phys_id))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="REQROUTINGTYPE"
    AND trim(cnvtupper(od.oe_field_display_value))="ROUTE TO PHARMACY ELECTRONICALLY")
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.encntr_type_cd IN (mf_off_vis_cd))
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id
    AND pr.active_ind=1)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.active_ind=1)
   JOIN (h
   WHERE h.health_plan_id=epr.health_plan_id
    AND h.active_ind=1
    AND cnvtupper(h.plan_name)="*MEDICARE*")
   JOIN (org
   WHERE org.organization_id=outerjoin(epr.organization_id))
  ORDER BY e.organization_id, pr.person_id, o.encntr_id,
   o.orig_order_dt_tm DESC
  HEAD REPORT
   pl_rx_cnt = 0, pl_phys_cnt = 0, pl_ord_cnt = 0
  HEAD e.organization_id
   pl_phys_cnt = 0
  HEAD pr.person_id
   pl_ord_cnt = 0, ml_idx = 0, ml_idx = locateval(ml_cnt,1,size(m_rec->org,5),e.organization_id,m_rec
    ->org[ml_cnt].f_org_id),
   pl_phys_cnt = (size(m_rec->org[ml_idx].phys,5)+ 1), stat = alterlist(m_rec->org[ml_idx].phys,
    pl_phys_cnt), m_rec->org[ml_idx].phys[pl_phys_cnt].f_phys_id = pr.person_id,
   m_rec->org[ml_idx].phys[pl_phys_cnt].s_phys_name = trim(pr.name_full_formatted), m_rec->org[ml_idx
   ].phys[pl_phys_cnt].s_position = trim(uar_get_code_display(pr.position_cd))
  HEAD o.encntr_id
   pl_ord_cnt = (pl_ord_cnt+ 1), stat = alterlist(m_rec->org[ml_idx].phys[pl_phys_cnt].ord,pl_ord_cnt
    ), m_rec->org[ml_idx].phys[pl_phys_cnt].ord[pl_ord_cnt].f_order_id = o.order_id,
   m_rec->org[ml_idx].phys[pl_phys_cnt].ord[pl_ord_cnt].s_order_mnem = trim(o.ordered_as_mnemonic),
   m_rec->org[ml_idx].phys[pl_phys_cnt].ord[pl_ord_cnt].s_pat_name = trim(p.name_full_formatted)
  FOOT  pr.person_id
   m_rec->org[ml_idx].phys[pl_phys_cnt].n_ord_cnt = pl_ord_cnt
  WITH nocounter, maxcol = 20000, format,
   separator = " "
 ;end select
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d1  WITH seq = value(size(m_rec->org,5)))
  PLAN (d1
   WHERE size(m_rec->org[d1.seq].phys,5) > 0)
  ORDER BY d1.seq
  HEAD REPORT
   pl_col = 0, col pl_col, "Organization",
   pl_col = (pl_col+ 60), col pl_col, "Physician",
   pl_col = (pl_col+ 60), col pl_col, "Position",
   pl_col = (pl_col+ 60), col pl_col, "Patient",
   pl_col = (pl_col+ 60), col pl_col, "Order_ID",
   pl_col = (pl_col+ 60), col pl_col, "Order_Mnemonic",
   pl_col = (pl_col+ 60), col pl_col, "Tot_Orders_for_Phys",
   pl_col = (pl_col+ 60), row + 1
  HEAD d1.seq
   FOR (ml_cnt2 = 1 TO size(m_rec->org[d1.seq].phys,5))
     FOR (ml_cnt = 1 TO m_rec->org[d1.seq].phys[ml_cnt2].n_ord_cnt)
       pl_col = 0, col pl_col, m_rec->org[d1.seq].s_org_name,
       pl_col = (pl_col+ 60), col pl_col, m_rec->org[d1.seq].phys[ml_cnt2].s_phys_name,
       pl_col = (pl_col+ 60), col pl_col, m_rec->org[d1.seq].phys[ml_cnt2].s_position,
       pl_col = (pl_col+ 60), col pl_col, m_rec->org[d1.seq].phys[ml_cnt2].ord[ml_cnt].s_pat_name,
       pl_col = (pl_col+ 60), ms_tmp = trim(cnvtstring(m_rec->org[d1.seq].phys[ml_cnt2].ord[ml_cnt].
         f_order_id)), col pl_col,
       ms_tmp, pl_col = (pl_col+ 60), col pl_col,
       m_rec->org[d1.seq].phys[ml_cnt2].ord[ml_cnt].s_order_mnem, pl_col = (pl_col+ 60), ms_tmp =
       trim(cnvtstring(m_rec->org[d1.seq].phys[ml_cnt2].n_ord_cnt)),
       col pl_col, ms_tmp, pl_col = (pl_col+ 60),
       row + 1
     ENDFOR
   ENDFOR
  WITH nocounter, maxcol = 20000, format,
   separator = " "
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
