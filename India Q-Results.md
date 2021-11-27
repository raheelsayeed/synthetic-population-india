Census India Query Results 
===========================


# Population Data
### Level #1: State - Andhra Pradesh
### State Code: 28

RegionCode  Name            Population  Males       Females   
----------  --------------  ----------  ----------  ----------
28          Andhra Pradesh  84580777    42442146    42138631  


# Population At Districts - AP

>   select r.districtcode, (select name from Region where code = r.districtcode)  DistrictName, sum(p.total) TotalPopulation from Population p Join Region r ON r.code = p.region_code GROUP BY r.districtcode;


districtcode  DistrictName  TotalPopulation  Males       Females   
------------  ------------  ---------------  ----------  ----------
532           Adilabad      2743537          1370731     1372806   
533           Nizamabad     2551335          1250641     1300694   
534           Karimnagar    3776269          1880800     1895469   
535           Medak         3033288          1523030     1510258   
536           Hyderabad     3965194          2029646     1935548   
537           Rangareddy    5530255          2820143     2710112   
538           Mahbubnagar   4053028          2050386     2002642   
539           Nalgonda      3488809          1759772     1729037   
540           Warangal      3512576          1759281     1753295   
541           Khammam       2797370          1390988     1406382   
542           Srikakulam    2703114          1341738     1361376   
543           Vizianagaram  2344474          1161477     1182997   
544           Visakhapatna  4664475          2330832     2333643   
545           East Godavar  5154296          2569688     2584608   
546           West Godavar  3936966          1964918     1972048   
547           Krishna       4517398          2267375     2250023   
548           Guntur        4887813          2440521     2447292   
549           Prakasam      3397448          1714764     1682684   
550           Sri Potti Sr  2963557          1492974     1470583   
551           Y.S.R.        2910308          1466052     1444256   
552           Kurnool       4053463          2039227     2014236   
553           Anantapur     4081148          2064495     2016653   
554           Chittoor      4174064          2090204     2083860   












# Population At SubDistricts - AP


subdistrictcode  Subdistrict  TotalPopulation  Males       Females   
---------------  -----------  ---------------  ----------  ----------
4305             Tamsi        39631            19615       20016     
4306             Adilabad     198338           100054      98284     
4307             Jainad       47904            23797       24107     
4308             Bela         38318            19942       18376     
4309             Talamadugu   34632            17227       17405     
4310             Gudihathnoo  30339            15185       15154     
4311             Inderavelly  47506            23592       23914     
4312             Narnoor      49239            25789       23450     
4313             Kerameri     30724            15466       15258     
4314             Wankdi       35523            17724       17799     
4315             Sirpur (T)   31130            15607       15523     
4316             Kouthala     50938            25638       25300     
4317             Bejjur       49284            24330       24954     
4318             Kagaznagar   110078           55168       54910     
4319             Asifabad     58511            29374       29137     
4320             Jainoor      31453            15584       15869     
4321             Utnoor       63465            32358       31107     
4322             Ichoda       52840            26265       26575     
4323             Bazarhathno  28911            14546       14365     
4324             Boath        48216            23589       24627     
4325             Neradigonda  29633            14448       15185     
4326             Sirpur       26097            12972       13125     
4327             Rebbana      35859            18513       17346     
4328             Bhimini      26285            13225       13060     
4329             Dahegaon     34712            17131       17581     
4330             Vemanpalle   19532            9809        9723      
4331             Nennal       23534            11722       11812     
4332             Tandur       32617            16393       16224     
4333             Tiryani      26410            13129       13281     
4334             Jannaram     52883            26235       26648     
4335             Kaddam (Ped  52703            25937       26766     
4336             Sarangapur   48820            22936       25884     
4337             Kuntala      34190            16674       17516     
4338             Kubeer       47984            23773       24211     
4339             Bhainsa      89417            44383       45034     
4340             Tanoor       39752            19852       19900     
4341             Mudhole      55923            27401       28522     
4342             Lokeswaram   34253            16309       17944     
4343             Dilawarpur   35780            17130       18650     











# Population At Village/Town Level (Includes Wards)
## SubDistrict Adilabad: 4302

>  select region_code, level, total, males, females, (select area from Region where code  = region_code) Area from Population where region_code IN (select code from Region where subdistrictcode = 4306)

region_code  level       total       males       females     Area      
-----------  ----------  ----------  ----------  ----------  ----------
568976       4           1359        669         690         7.72      
568977       4           0           0           0           4.61      
568978       4           309         153         156         1.64      
568979       4           1321        614         707         2.86      
568980       4           0           0           0           2.03      
568981       4           1057        507         550         1.98      
568982       4           1922        962         960         5.92      
568983       4           2765        1406        1359        8.04      
568984       4           0           0           0           3.28      
568985       4           1641        806         835         5.37      
568986       4           20          11          9           4.2       
568987       4           943         482         461         8.46      
568988       4           29          17          12          3.87      
568989       4           538         266         272         4.03      
568990       4           1581        792         789         9.15      
568991       4           242         127         115         4.53      
568992       4           3598        1777        1821        18.53     
568993       4           2918        1436        1482        10.97     
568994       4           7172        3607        3565        7.39      
568995       4           9633        4829        4804        23.68     
568996       4           1460        731         729         7.9       
568997       4           1959        980         979         10.43     
568998       4           169         72          97          2.9       
568999       4           496         258         238         3.36      
569000       4           1034        522         512         10.83     
569001       4           2505        1334        1171        19.58     
569002       4           1407        656         751         9.88      
569003       4           501         252         249         7.17      
569004       4           1335        690         645         7.24      
569005       4           554         273         281         10.58     
569006       4           595         303         292         12.86     
569007       4           1608        810         798         15.66     
569008       4           2389        1054        1335        6.56      
569009       4           466         231         235         6.36      
569010       4           1390        689         701         20.89     
569011       4           913         467         446         10.68     
569012       4           779         331         448         6.21      
569013       4           352         170         182         9.83      
569014       4           167         82          85          6.3       
569015       4           1216        624         592         7.84      
569016       4           612         302         310         11.72     
8028960001   5           25286       12813       12473                 
8028960002   5           21971       11140       10831                 
8028960003   5           35166       17727       17439                 
8028960004   5           26832       13694       13138                 
8028960005   5           7912        4074        3838                  
5690170001   5           22216       11314       10902         

