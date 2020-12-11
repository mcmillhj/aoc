#!perl

use strict;
use warnings;

use feature qw(say);

my @customs_forms = do {
  local $/ = '';    # enable paragraph mode
  readline(\*DATA);
};

# --- Day 6: Custom Customs ---

# As your flight approaches the regional airport where you'll switch to a much larger plane, customs declaration forms are distributed to the passengers.

# The form asks a series of 26 yes-or-no questions marked a through z. All you need to do is identify the questions for which anyone in your group answers "yes". Since your group is just you, this doesn't take very long.

# However, the person sitting next to you seems to be experiencing a language barrier and asks if you can help. For each of the people in their group, you write down the questions for which they answer "yes", one per line. For example:

# abcx
# abcy
# abcz

# In this group, there are 6 questions to which anyone answered "yes": a, b, c, x, y, and z. (Duplicate answers to the same question don't count extra; each question counts at most once.)

# Another group asks for your help, then another, and eventually you've collected answers from every group on the plane (your puzzle input). Each group's answers are separated by a blank line, and within each group, each person's answers are on a single line. For example:

# abc

# a
# b
# c

# ab
# ac

# a
# a
# a
# a

# b

# This list represents answers from five groups:

#     The first group contains one person who answered "yes" to 3 questions: a, b, and c.
#     The second group contains three people; combined, they answered "yes" to 3 questions: a, b, and c.
#     The third group contains two people; combined, they answered "yes" to 3 questions: a, b, and c.
#     The fourth group contains four people; combined, they answered "yes" to only 1 question, a.
#     The last group contains one person who answered "yes" to only 1 question, b.

# In this example, the sum of these counts is 3 + 3 + 3 + 1 + 1 = 11.

# For each group, count the number of questions to which anyone answered "yes". What is the sum of those counts?

# --- Part Two ---

# As you finish the last group's customs declaration, you notice that you misread one word in the instructions:

# You don't need to identify the questions to which anyone answered "yes"; you need to identify the questions to which everyone answered "yes"!

# Using the same example as above:

# abc

# a
# b
# c

# ab
# ac

# a
# a
# a
# a

# b

# This list represents answers from five groups:

#     In the first group, everyone (all 1 person) answered "yes" to 3 questions: a, b, and c.
#     In the second group, there is no question to which everyone answered "yes".
#     In the third group, everyone answered yes to only 1 question, a. Since some people did not answer "yes" to b or c, they don't count.
#     In the fourth group, everyone answered yes to only 1 question, a.
#     In the fifth group, everyone (all 1 person) answered "yes" to 1 question, b.

# In this example, the sum of these counts is 3 + 0 + 1 + 1 + 1 = 6.

# For each group, count the number of questions to which everyone answered "yes". What is the sum of those counts?

my $union_sum        = 0;
my $intersection_sum = 0;
foreach my $form (@customs_forms) {
  chomp($form);

  my %union;
  my %intersection;
  my @people = grep { $_ } split /\n/, $form;
  foreach my $person (@people) {
    foreach my $answer (split //, $person) {
      $union{$answer}++;
    }
  }

  foreach my $answer (keys %union) {
    next unless $union{$answer} == @people;
    $intersection{$answer} = 1;
  }

  $union_sum        += scalar keys %union;
  $intersection_sum += scalar keys %intersection;
}

say $union_sum;
say $intersection_sum;

__DATA__
vkplsqwiftuazyje
mokluxwbsfhgc

tlfxgqinzmdju
zjmvfstnplqd
xztfjnlqemd
cmatrlfnbjqodz

xrumszojqa
mqsorcixzuja

bwdvujyzsneiom
njqzvyhceriodl

nhbxcfgwpraqje
abcqfnrpwehgxj
pqrfxancbjglewh
exhfbanpwrcgjq

skmy
koq
zqtk
vkgfjun

zkmhpcq
jnubrdys
fvdswier

nj
njehcry
yhnr
tudngxkovfa

pcnv
nscvp
nvpc

fjmpugzckbwho
quxmhkzad
uzmohyjkr

wdscxfnlgaibejomtvp
slqgmrkuyotwz

eao
woa
ao
oa

d
d
d
d

eobljmc
fdtepbjc
xnecrhbuzjg
qbceasjy
bawkdecij

tmuoedrpzabncijwx
itudehyxowpcl
gtelwqxoiudpkc

gadtfkeom
ekgtfrm
jtoeckgfm
kugtfmer
misnkqebfvtg

vn
m
ygup
nqm

fjvluqzongtmd
dyxcpbrzho

sr
rs
rs
sr
rs

tlxvdqpuear
kmdltoxuz

cgabvoz
iprelmqfju
bwzgknch

ktendlaj
rqibyxfuwma
jahdtce

kjv
kvj
jkvbi
jkv
jkv

ehtypgizds
egwispytdhz
eyhzpidstg
tiyhpesdgz
ztlydgpseih

yht
doalj

fghm
fhmg
hifmgb

stgck
ajpluiyrqvhw
tsf

hwqmofuy
pnkjlbdtai
ygzx
ysfm

cfdxwnhopyvme
wvuedfhn
wahnkfgdiev
wheuvfdnj

ikylabn
lbiyank
kqilymbna

eahgurwvbt
qfskieyuz
eduvgr

oqhpjibznk
kobjqwpinh
kznpjbqohi

sujoglfhzrnmabxpi
phgubrxmsoajfznl
snjpmogrlhufaxbz
fphagxbjlrnomzsu

baotd
boaudt
botdj
gwdxtfobhq
tnjbdo

uhdiramngvtfjewq
gnmhudaqewrtfjvi
qrvaigdmhuwftjen

nmal
mal
aml
almb
nlma

x
x
x
q

kidfopmvtr
xdpifwrkotvs
eztjfqpvorhkncdau

hyu
hyu
huy
oyuh
huy

xwdupilevjcazn
bzdarpgnlivexusjc
avxujgfdwecilpnz
lcpytozuendiajxv

hwck
ckwh
kwhc
bckhw

ktbhifgn
hbvigntuk
nbihtgkf
kbgihnt
bnifkgth

a
i
i
i
k

kzvohlrcnjwuifam
lkujhzfwrcnoimav
uzlcvfhjrnmwskaio
zcojhmnvurklfiaw

htvnf
fvnth
vhtnf

ncrolpwdx
pcohxrnvdl

jxphyearvgc
rfcodbuijg

bhugktqa
bkgqs
epkqfg

ecwhuzgkmrodyj
dokqewxajuzspyc

lfqnj
njklqxfw
enfqjl
nlqfj
lqnfj

rd
ibagcyr
envtomrh

vfrdbizxwocnaks
zdavirkcsfwnob
ivcsakqunrdwbzfo
nvsxwoczidkfmrab

uehqdjmbi
jqhuefis
dejhovuqi
einktyzuqahj
ohiuwejq

fzgymun
mzyugnf
guzyfmn

fetogjqxcuvzsw
vthxugpedowq
eutmoikqvwragx

fwgujzeykqvlmidn
kvuwymijfenqgldz
gynldkjuiwzcmqefv

nyrxopqgifedsc
zdwycqjgfnhoxtiersp
nrfacpqdxyesoig
fimvyorqpekndglcsx

ajeyb
bjga
jbka
jgba

vg
v
tncd
v
v

dwpxzhi
ihbpwxtzjlr
xiewyzhdpv
xwpzhai
nhxzwiyp

dbecuzx
xbduecz
ecudxbz

e
w
e
e
e

ovrzqdjaiwb
rodebilkcwmntj
sdjvozwibrhp

h
p
gtxvfb

tnpvcfjsalyiorxzdb
irapztvynfjscoxdbl
czlnxjydbratipvfos
anoctriszvjxydblpf
lvoazndfjycbitsxpr

rubmekjfdagt
amkrxylefcbo

iyrqglom
qlitrmy
rtyilqom
yqalmire
lqriomy

whpei
eghpi
paetki

baepocmyzsd
cbezopy

lbotn
xnqzo

nqjos
wthmj
fkytdsjng
ipxzvlba

wq
q
exns
w
kw

cthavwpbkf
dsmnegrixql
zfcutvojpy

niboxrwyqscjht
ihbjsxcyronwqt
sqhyotwxbjcirn
iotrbwqjcnxsyh
qwxnshrajioctyb

vctoxkjdieyzwb
eijydzwobhxktc
iaytkjwbuxzpodscen
xtjwgydkzoecbhi
yoixtwczdqekhgbj

aprmbkdcexjw
zotyshdnbevqcj

lio
ol

rdtpzonajsymgkcubhx
ryhtsxnmjcagdzkoub
zhnyjaltgokmudrbcsx
xhrydtgjnsamcbozku
nxartdusgchzbykjom

impokzcuwnvjq
znepvyiqkmcw

mr
im

rhaijlqeu
szmhnux
nwufhb

pcihyolxetbg
enyrxhuq
xfvrejdhky

zoxgea
oxeza
xazdvoe
ozxauge
jntzwoexa

xaivusctq
tisqxva

ts
t

infzulyjrwmv
nvzubryomlifjw
wvygflurnjipzdm
ruyvjwlidfznm
iluwnryfjmvz

vw
vw
wiv
vw
vw

x
x

bzjhrsx
zxahrs
xhyrez
rabhxjz

fwsuiqblg
fnqkdgsj
jsaqfyvgnk
gqfs
yoesrtqfag

uqxatgzhbvf
bvhzltgqfxua
rztabhfgvuxq
taxbfhvqlurgz
zhgsqvtbuxaf

e
xzyr
h
d

u
u
u

rtdyhnfliowua
sdlhfygqera
kzrmvpbxacj

kyhja
ugneb
fpbzc

u
wu

amsovxceljdygphbw
vbdhsowzagmylxecpj

uevdiqzwokgxhj
worxiusdzejgqhk
qxkthjuwiaozedg

qbtevg
wyngqzsvb
gvbtqe

lfbgch
hgbflc

vlpg
mlg
ldeg

rwsuctmyxoaipzbjlqknf
jamwspfchqkoxyrlzu
pazsmhyqolcjkwufrx
uqdrpyozhsxcjkaflwm
vyokzaupcfxjlrmqsw

exzsaqlijpdmkvgywftb
sovjewdtphybzmaqfuk
kdtyazwpbjvfsnqem

paowmuxkgysedl
wyxsokudpmaleg
gywoxakesupdlm
pyusakwegmoxld
eopslywkuaxgdm

lsxjny
yxsljn
ylnbxjs
lbjynsx
jsxylrnv

jwegoyxpa
jmcapxvbdg
swjxap
hqapzinuxrtjf
velaxypjk

m
ge

quypbjdikvletowrnasm
ywnaplqbmusdorekivzjt
jqntersduopvyblwakmi
wnkibesaypdjuxqvlomrt

pylnd
ylcp

advbre
nrjbfdvex
xberv
osekrcv

nzpwvidyetcbmorj
ibjdnroagcemwpz
qzsekmdbnxwuirolcfp

huqydt
rsbwpdmcnt

hcjbr
bhcrj
cjbhr
cbrhj
cjhrb

fpxi
ipf
ipukjbgfo
tpaif
ipwxf

hobckpqzajgsmdrwl
odrpwlsjachqgzmbk
oqragbsjkdlhzcmpw
jrgbksowmzapcdhlq
zwpmclbjhqgskraod

diezqf
zf
znhsymf
ozjf
zkrejf

esmgwuvlzixaycnfqkt
sipueyhxfqkbog

mrpscwnklxhtobauveyi
tgaivjupxhkbcszleorwmd
tbrlosnvhpecaxiukmw

flpk
rf
xquatcvji
wysr

dcfnywpotmge
ymfupe
qhmekjysf

kdgq
qcgdk

ocxbdl
wlcauqy
uwarlc

thbeswnyqm
nsqymwhbet

itmbc
tofmvcb

sw
sw
swm
wsh

orixhcu
uixhcor
hrxcuo
xhkucbo

xsowberlfigtkz
ltivwneusg
tnegisalw
gvqstmldyicwpe

yhznbodgfcqeptivx
dioaexhnczqtgv
okdgteivxszwhqmn

dokztemwprxcula
irmxpdouta
rhtuxopdbmaj
dtmaphxqroyu
mtdohsparfugx

hzcarpvyjkqduflwbxg
ctbhalfxivudonyp

gkdypu
pkgyud
kdypug
ygdkpu
gudkpy

ulw
fwul

gpwotsyxzjc
nlmuevq

zxtpjvqmsr
bmprdvquig
mpvryhq

j
j
j
kewlj

hgxscfpjol
spgfchxjlo

hwjedr
edwhr
dewrh
pewhdr
usdehwtr

jegvbfpcm
khnuldx
zyoasn

tlrpbifxsjngoduvamyhkewcqz
fjolbtkicvmhrexungdqyzsapw

is
zr

qptgfwdcbmxueoiyjs
qbfcwsugexdopjtmiry
jpwdecfyosiqmutgxb
oejyvdwfgsmptbqxicu

snqytmeualwrzogh
styeunlqzmwhgao
yhnwlesoqguatzm
unmazqlesytohgw

dftkic
xurjq

drixnqjogckuzmtl
syhkwbvdjxfr

xelvzfjd
jfelzvx
zjdfewxl
jxfle
rfejmsblxg

cz
cz
zpc
msaczrxy

rvlmfknpzxauqedwhybj
bqyksfardvxwunehlzmj
ncsmirluwabjkyzdfveqxh

gmpbcwjrs
bglcjpriwum
jbfwrvcmpg

ktfqsluvjhg
jkfbxhgvayq

uvle
lkx

ng
ng
ng

ozjnipsqxlh
oljhczqidsnpx

hqmnsiadov
ohdsnmcvai

lerquyikvxdtpn
edquylhi
ibuljedqy
elquybid

g
g
g
g

uqbemtxp
gzubdexq
qpxveb
vqszbxter
eifwxbnqkyaco

isvbajpehtdow
khdjiepawnvsg
hqacjefdwxivsrp

cnpltgfhwjiaydxqouz
acnqgjfrwiexhopdz

sjmwleyxtriqdchbk
icatnbgservmuqpfw

cela
elqbca
acle
alvce

upkctos
izbqxh
njdqevafy

t
jua
egoy
v
j

m
dwm

kipetzja
jhyeizpqvk
zjkpie
ipkjzne

tsibo
sbo
rjzqbosamn
vosb

u
j
u

mtjivuygewcolkzrpfbs
jlgcyuzpafkibwshdmovte
bskavogweclutifypmjz

ov
ov
ov

eyro
yeor
rofye
yreoz

thlknydiesxupoarcgf
gidylcsoekhnxafrt
glwyqiectnshkdbxraof
grtvasnichfyelkxod

whzu
wimcpu
gfwet
dimw
pcbwli

z
z
z

chz
hzc

nvfswzqculbtdrxey
jyludxzbwgvnhrpsfceitq
znlxeocqywmrsvfudtb

wnbz
ezugmpx
tz
idszb
znlrdw

xhipb
bphix
ipcbhx

gudlfzh
dghzuo
guhdwnz
guhdlfz
hzgdu

dczfkubhjwn
kjhcubwfzdn
zknfuwcdjhb
kzbwcdhujnf
khnzwcdfbju

wkpimxyu
uyimpkwx
wkmupxyd
ulxafnpcwshymk
wumxpkdy

jlr
l
l
gal
lg

t
t
q

cktanxyfepglowhibsjv
tbpfihyovgeacsnlwj

rzd
wyrzd
dzr
zrd
rdz

ligjhor
grlhno
yqrpsolhmwg
xelsrhogub

njrwbhvfta
jfenrhvbwt
tvwbrnlhjf
cjfzntbhvugqwr

xytgmcdaeolfqwzskr
qdfmegraxzhokcyswt

ndcywqxkfta
ckxwndyqfa
cwnkqadyxf
wkyncdqxfa
wcqdkayfxn

vbir
vrbi
bvri
vbir
rvbi

mstylwqkrnizdhjbcgeo
yvqkrbedpmwcutsfo
atpermwqfcobdysvk

sdylhzipk
zyispkd
kydizsp
zepsiydk
kdzypsi

lvpiahe
hvapeli

fwpmhryouqcktzb
bhzyucgqkmrvdo
jobackhzsreqiumyn
vchkoqdzmybru
xblhkcyoqdruzm

jkilegfoxzacr
acxkzorfpjg
ctkzrgafxoj
oacxzfjgkr
jrozkcfxga

apmksyco
acsomkpy
sopcaykm
mkcyoasp
scqkmpyoa

fpaigjltezhxwnyrvu
vftqenyjwbsuaiplhdr
ajeutynhiwrdflcspv
naeilpfjuvdkwtyhbrq
htproevliajwfynu

cwaug
augcw
cwuga
augwcy
gwcua

afqcnwebdv
aenfqbwcv
bvfeqwcjnsa

vtecwrzfa
tczvwrma
vrpwczat
xewzcavtr
vwcatpzr

rdkvyle
eglrbyadp
tmxrhszneuldyw
dleykgcqr

qsohepyxawngjd
ecaywgnhmf
wfeagtnrhuiyl
nthwgyeav
ynwgberazh

loupbihzqwady
npbtkumjdoihwy
ysguhceopbw

fy
n

ulafhmibcnqvxt
ik
i
i
psdiry

wcahpmgkjdi
lkazewjdpgbins

sy
ectfa
q
sz

idglafuxovqb
vurdigqpfoal
fgovalbuidxq

qigjvulpdaxwsbnzyc
iudbjscqwohnxlv
sjlxcdiqnuvbmwp
rsklueqxijdnwtcbfv

urxqtyshgzemca
xawgozkbejncprilyqf

irl
eurpiolqczj
lrswi
vnilwrf

viwsjgdt
yxhc

ynwkqtpageurxosvjlbc
letqbswnxcrkajvugyp
zsnjawtqgevcpkrxybulf
ynglakqevcjptxwhsrub

gabxsumno
mknawxt
anjxhfm

dimjglkvcstaqzebu
cjeqzybdkaurv
bdkoacevqzju
bdycqjkaveuz
bkcevaqzduj

z
z

rydinou
zfycpiwl
mbydiv

fzhrbc
bfszrhc

g
g
g
ag

l
l
l
lq
l

cnf
ncf

x
fzw

nhgkcomtsdxlazu
wcrexdamztyohklguin
dmxlzgnckaehtuo
doqcuhfxtlbanmgkz

omfbckilpvjgxqwthse
vpwhosebmtxgicjkfql

nmdlkxb
ihbvjk
blkx
kxbycs
bk

uxkzsavo
xosalzfbv
opvisknrxauz
xouhgzsav

wcjodbqux
patbuwvd

mb
mca
mc
cm
m

usp
aftgzcp
ztr
eyjkbmnd

zwfyeraxjdimplusbq
sjqamxiyfbduplzre

uehlcmvqagxd
ghbeylfazdcxu
clhedaxjgiptvu

vntkpmzia
pimtvyakz
tzipvakm

fgoputbi
bpiftxg
wpgtibf
fgbpit

kirsmujcn
mnkucrij
jnumckir

fubspvchiwtnjkrxomae
kvcrsdtfuwhapxemnoji
wcaknfurotjlsevmhpix

mojgstlqrebpifcvy
gpfijetbvqrloycs
lptohfsivgrjqcybe

etnjorpmshwxlcbfdugykvaiq
necvjsgwokupfdlthymqxibar
whftpldmarigjeuckxvqybson
brsovpaqykicjhutewmnfglxd

ofmkudxjpeti
okpmifxuejt

feudgmpbhzak
emjnkbzludr

wc
cw
dcw

tolg
berksqjhmgt
fwgxt
atlg
zgptn

hng
jiav

fit
htif
fit
fit

bkxgyoasj
xdinqvksb
esdtkylbo
szhfkmrpcb
uxseqbko

vgclrk
yvgalcrk

imgnj
bgm
mgb
gmcr

rc
cr
rc

bshkdmce
uyfzjwclhovae
thqdgkinsec

ckmsoxuqif
fukqxmvsic
mosqchufikx

ulmfponhvjbzs
jopbvzlgfhmusne
ovjzewfnumshlp
vhmfojlunsakxczrp

tibdoksuvaxhwyzcpjgr
ypatgvjkrcinxumqhd
lykfvurhdxiqpeajntmcg

yrvqacpmexifgkbtdwzjso
psgtcyqvnwibfuozrmxekjd
dqbcjfgrmvwpzioytesxk

rubmfhv
hbfrjdmv
rihmbvpnf
hfrdmixbv

raviz
imz
iz
mezis

xcykuferdiqzjtalhmspnvogw
elmorfsvchkjpxiqbgnztwduay

aci
aycn
caq
arc
caji

vb
vb
bv
vb
jbv

jxgarbnkwutzc
npjatuzwhkxbrg
bkdrljnasxwzgtqu

xparfjw
rfaxwjpm

jf
j
jr
ji

xrgdnqzk
zndgqrikf
znqrkxdga
rkzgqand

egizwncdbualtf
flguwazicedtbn
ulfztngaibwdce
bilncfatwzuged
nabgeclfudtiwz

d
wfdj
d
d
d

gn
n
n
n
n

dou
yunwtdohpcb
ouvd

xvayuwoe
ayuewb
yawseu

tfbso
sotf
ftos

otjcundbazgmlirkyhqpvfe
bqcduiyaentvzhklmgporjf
fyhtvnzadglcumopriqbjke
itmvuqbnrcofakelhydpgjz
konfjihzumcavgytpesqldbr

hmpqckelajgzxnyso
lmkqecuxzpysnjhgoa
zgsovhqjypnekmaxcl
pohsxaglqmfenzkyjc
pchlzengfyjoxmksaq

ohjuandzmpvwkbfclirysexg
mhresaycwovbzkdlnxpujtigf
qckxespgnlvdafiyubomhzrjw
lnjkcwahrsvipeugmzqyfxbod
mbwzfnolrxecyapsuigkhvdj

cailbjyxztvdnphkrg
nvilxeprzhajkbygcdt
jazdblghrsicxpytkv

p
fp
f
vgz

elajdxgu
jiduarlexg
xlejdaug

auh
ahu
hasu
hau

rckmqapdtse
molzwi
hgiom

asqyzrgotdlbviu
lgoztqsdbrivy
lrtybsgqvaizdo
lbdsgorzvhyqxit
alijgryqzbodvts

fpnlakbxjosd
dlpyfnjaxoks
lokfabpnsxdzj
dvmxugpoajnkclfhs
flxbknrasjodp

mprcewkzquit
ezkrcuiwqmtp
wiprkqetzmcu

alkyb
kbl
klb

iezaknbl
zo
z
oruz

ibhrojtaulvewmgczpxdqk
rcbpgidtkqouyazhevwxmlj
idzhegvwtacublomrkxqpj
vcbigrtzlowxpjhuedkmaq
ajxuctrhwepmvoilzdqgkbf

knal
nlv
qlnzb
ulknv
ln

dkfrbh
hbrdfk
hdirkfb
dfrkhbn
akedmhrfb

axeuqykc
cijxqeg
ybuzctis
zwcliq
hfodnrvcpm

k
k
k
k
k

f
yg
u
y
y

xbrgmpydio
rdxgibmpy
dryipgxmb
ihjdxygmbpr
ixgyrbmdp

xutjv
uhxtvj

dpezviroyshwaxqgjlck
ogivhpaskqrlcdjwyezx
zspkihxldaoqrjcgevwy
ckigvrljoexyhpzsadqw
hguvczomqlpnabifswjydrek

fsaonvedtjczu
setdouyfvnbjk
oftnledaqsvuj
nagujstvefdo

hbwvkftgdzsm
msvfzgwbkdht

nbxliqesfzawyk
aswzruelkfbhniqo

yobmx
jxybeo
ypsbnuxaf
ybx

yqaxjhlvrfceu
fzvpcuqaxrheyj
racjhfyqeubxv
xqjeudfvygahcsmr

xejldkfstrvubcpaig
gqxhcpbsrojditeank

favwixezjmso
ogpbvwnamz
atwvobzm
trhowanpvqmdz

qfdcv
cd
cd
cdwk
drzc

y
y
y
yl

nclrvbgzmudf
vdnlfgusir

gbnxzysckmp
zsnkmcbpyxg

zqweaofxvpjucmkts
setcuqkpfazmxwo

kxmfqdithl
hktfmdqsi
wghkmfydtiq
fiqkhmgtd
mfijqkhdt

mebnqwaxzvys
msvaotqilh

tymwfkrcsvilqodphbuzexjna
takfijusvpozeqnwxhyrdbclm
edhrynkzbispqwflvcmxotaujg

uvc
vcu
vuc
ucmv

kfzadnxwsq
lawdxkznfqs
tflqdkxasnwz
knqsrcgfozxedaw
xaqwdnsfkz

gaho
vzdecfourwpnyx
iqhaoms

kiebj
izekbj
jikeb
lbjirukqe
ijbkxez

ldwsav
srlx
cntqmikugl
ylz

yqh
h
h
h
h

jpqewnhzbyltxu
samgukw
umw
wuck
cfmwgu

hblxgkmjyc
xmesjhqaidgp

wseufabtgklimdoxnypqc
thwukpnivmxbcalesy

sfzpaeqdbhwmnlxt
btlsqpdmnwzaeh
ahwtklseqnmdpbz
mwahslezbnptqd

alhkbjrtm
mjkratblh
tbmrdkhlja
bklrmtjha

fkjwmabqy
bwayqfmpsuh
ycbaqfnkwx
trwozgyibadqlv
wxnaqpybe

dbz
bdr

evsxkiwhj
ijkwxsve
vekjiwxs
eswivxkugj
eowtsliravjkzx

i
i
i
i
l

ek
ke
ek

bk
rskpanj

jlqapcexir
rix
uxyri
hzirux
ixryzu

mbecuxkqodis
myfk

osk
kvw

k
k
h
k

slwqeticyjpdzf
gxechvlqnmsfp
qulcpsfem
quehspflrvcn
kgcqlaepfs

bhiye
bstyvrapi
uldxybmi
bioknyfwj
cenghbzyiu

ztsxu
xtszu
usbzixtc
uxtzs
uztsx

jadbkcovfyrnsx
gnqxdfycvbksr
nfsvxdbmry
ysuvnrdbhlxpfi

xchlgiaotmsuzvq
gmayopixqslcfekhz
wmsojhcbraznq

cxfky
kfcyx
fwkcyx
fxyck

xqo
q
q

sgojw
cvfm

zdfyhrqtn
tnqyrfzd
mrfjztydpnq
dqfyrtnz
dyznfrtqh

qemxlh
fbvnekpcmh
mehz
whmrdegy
emhg

mqvr
cnasrl
qdys
gmez
jptbh

epufwojvtkzld
kouedvymlgntp
okldsviptaeqxhbfu
ouibvesrcjktpld

xnhkjmvwy
mjhkvwy
hkjwvmy
wkjhmvyq
yjmkwvh

ckedjx
excjkd

znfesox
xeoh
ocenxz
eolypx

mxivwjbheynk
vtobgpxmyhkqnjiw

tsxvd
xdqcvn

ynhtcpbeourwqik
ciaoeqnvztmgybdhkws
ewckryhoqnbtfi
ihbqotncwyek
jfcwkthboeqniy

zaefxrolby
vdfztseoqhgly

woiyfq
iqfyw
wiqfy
wqyif
wqfiy

czojbsdtxhnwvuygfmkeaq
lwjqbtyngfzuxkecoadsvh

celw
tywbeuascvz
ekgcinwrox

cy
yc
yc
cy
cy

jxpwoydmhblcrai
qmfykpsrxlvda

o
vx

uptwyrij
jiyturwp
wqbtpyujir
rjuytpiw

meqghcrlnfjkyw
avjcixbspgfqz

dyz
l
p
pul
i

l
l
l
l

dhua
aguid
aud

rqnfj
nfbqdj
fqjnu
fjnq
nqjf

scfvjmnxeag
cudpbwfnxalzsotqk

abzfcdpnyxg
dcmrbnpxfzya

aexvdqroyncwl
qrowycxvnaled

scznoldgrut
orcduszlgt

zofhkcrsjm
mfsozrhxayk

nehxkswcz
cvwnekxy
aewxkscqjn

stpwkqyzgm
wkjpzygtsm
yqmspwgztk
pztsymgkw

wcipmryqalvzbkghtsofxj
pbjixyckrgzmfvslhtaw
ivrzglbuxtsjhwcpamfkye
nckmdqfbgtasijyropxvwzhl

qtfyr
yrtfq

xkijmzgyeplvubr
kzsdpxjbhne
zxhbtkpjse

tvm
zvm

naqbrui
rbgiuqans
bnrqaiu

dulxmsoavhciyqpfzketnbr
obnxqmidafpresytlzckhvu
otxrdwpumcivyshfaqkgeblzn
hyrmlzkstpvifucxedbaqon
qrpndcmtoevkzlysaxuhbfi

kbisedtufjvmroq
dfubrkimtjseq
bqdsuktemirjfw
ukpdqtshgerfimbyj

br
rkb
rcb
br
rbm

lm
lfh
ml
lo

uigbrefdqzoaklhwcjxntm
cublkmtxeqwgrhonifyd
bsleinxukwdmftrcqhog

zicwhktunjxgfpodsbye
nfteiwpudgcxovjbsyak
ywegkintxqbpdujosfc

f
e
t
e
d

btxnpqyrshjcz
qstfkgioavjlwe
sbdqjpturcm

mpi
ipm

bxqlyckzwrgu
ywulzqkgbrcx

lmpys
mypsl
smlyp
pdlmsy
ysmpl

gxbsvalu
gxlabvsu
xgbvauls

jd
jd

v
vb
v

helzqfkyadcjtrpom
yjcqdrzeftlkmhao
eolhdvkmjqfxctzyar
lzcrhsfdjoeyamtqk
lcreftdozqmskjahy

tavjmbdeznxquyws
bejtfcgrpwisu

rinkdgteosbupalcwfm
opcbulmgsrnidewafkt
cpdbrmnuaeftlwgosik
wiedgctfrkunomlasbp

qenyztwigf
finwzbeqy
bfzpeiysqnw
wyienfzqb

fximacpqjvrozwu
aproqwzficuvx
aozqprxftwvicyu

wxedbjgki
wxgjzikde
iyekzgwxdj

ghsde
hsd
sthd

cafgyinvxmqsukot
utnsfycxkmoagviq
vkqystxmaniofgcu
nmtyavikgsfcqxou
fcxoyniumkvqsgta

sq
q
q

szvxhg
sgvzxh

orwyznm
tynzw

ivzcoaenfbrm
imecrfnovabtz
dnwgzobcvfmyirea
ebfnairctzmvo

yjtznqpvsldf
ilxahurg
ykjcsbel

lhiubo
uboihlma
hlgufnkprcvoib
ilbhtou
bisoulhj

vhiapgbtjlcwuxs
ibauwcjsptglxv
gcsopxwuajvilbt

oqbadzwepv
kbxdetcliprquvsn
dqhvwymbpe

ce
wcpo
c
octrn

swpd
clb

mxjwhr
marhxewj
wigrcjpmx
bjrwqxm

l
ulyt
bl
gl

gofskm
mgk

dscxkpviur
lpicsbuk
jkibcupsr
eucsifnkp

vs
c
c
c

i
i
b

cuv
cv
ceb
cv
cnhtm

ox
tx

rheungozl
eznoglrhuj
gnhozrlue
nhlrzuoge
urhognlez

lnkcuajziqwxtev
fzauikcjtxvqlnem

fmjbugerkdyaiqcxnw
kxhanqgjcfbyeurdmi

qjrleua
rujleaq
aejquzrl
rejxuqla

okagijrelbc
rbikajtglc

e
e
pa
y

c
hc
liasmwofn
ytkev
pczj

tkpnzsvmrdijfwobghqcaxeu
whfpjgeavdkbzmnurotiqscx
fqvuropcmkzinbdwashjxetg
hqkuzafetjpbwyirdxngvsmco

szxa
axzs
xzas
xasz
szxa

nscjgi
jgcns
gjcsi
scjg
szjgc

zuadipsnxhqgfjv
zjpdugisfv
dgfskzvjuip
fvugpidszj

qpcbui
qntkmsxlia

at
yta
ft

letsxrmgabi
gnpqaecbmxfwi
mciujqgehbax
ekgmixohyanb

epnlovurz
oqferplx
lrnedoqp
lroupe
awelogcikprm

nwyuzvrlmbhtjfqaedxocgi
cufibmwaxdljyzovqrtnegh

eoxvphlgnjcmb
omvghcpejnlx

mournjwlvsckdt
jumlnvrweozpkc
vbgawlrnmkijcox
nryelovjqchdkwm

iqbyaxh
gxbqnhi
xyibhqm

rqxbago
xvq
iyfqujdpwcn
xqamhg

gbxszymv
vhlnfdmg
mvgkdnj

almux
axulm
xmaul
ualmx

fdseyvrjkolcinw
idxynrvjakolmcfu
ycfbknvtijlurado

rewtmvgcnhqaolkjbiuds
atougievfqhwsdcbxjknp
ogakhvbcsijenutqwd
ckungoviwqjbthmeads
veyuawsiothnjdqbcgk

gvuqtmnxhoepfw
efqwtmnovupg
oevuqtfpmwng

trdyigx
nbtmzrygpxi
rxtyzbg
ygtwxrefu

akflh
lakf
afkl
ablqfk
zkalgf

gsuo
ywuvt

pcbe
lptbc
picba
plcb

wt
k
t

qnjo
xqgjyv

iozkwcxuhapnqg
pawxsihqkclzvgunm
kxawgbihuqcpfnz
ikgrpunhqwafzxc

bywxros
rsowbyx

wjxhogyipvanmbcrste
dcmgwqnepiajvxkbsth

zbmicrsajtqe
miecstjbarq

paxrhzkyslnq
zakyxhqslrn
yslaxhzqnwkr

jkleg
ekyl
kyle

ydvkwga
nxqarwd
wxakpq
cefbauhmjtoz
kai

bhwzivoacl
zcwqtxhsakyb

fsnged
ocmlx
wol
brc

ztswjbceaolgi
jlsmcupgw
rxsgkyjhdqfwnv

xtqjfacuirwvzksmlbhodnep
btremfjsvncyzapowqxidklhu

bmtz
ytjmhezbf
bwmtz
mwtzb
mtbz

bju
ubj

zywb
bwy
bwyz
wby
buwye

nerhbp
htbple

beurhjyvtdimocqn
hcvniqytrjeobumd
mncoeuqtihydrvjb
qibvdmywzrehcnout

egc
k
s

deltoa
etdoal
aedolt
amdtleo

gdwalptufnsxhr
uwgadebmvrhnlxfpcst
hlwsrfungajxdpt
ygnfwhrtaldpuxs
rzxalndgutkpswfh

mucn
hewbdvanpomyrj
mnsik
tmnqu
fnxm

gvykqxtmzwfsbrcleahjnod
hunoyzdjrmsvtbqckfaexlg
acketzflmjhqdrosbnvxyg
fevrokybsmxcatzhnldqgj
toqeprafdycksnhlvxzjgmb

ou
uo
ou
wuno
uo

eyfckdvlwibquogtsnrpazjxm
ybdsnauwojtxpilqmzvcgrkehf
lmtjdcxwvpysezqkonfrguiab
caferxuopydjsvtgbmlziwqnk

jgxudzlbswaefhpk
xzrcbshwdlkgjpfaen
kxbaemgwzoytidfjl

czjw
gykomq
xthi
nxzsp

exyjs
jxsyd
xeydsj
jsxyvg
wixbsyfjl

ultdkrv
udlrkv
drkuavl
kravldu
dvfrlkua

zjgofiydu
zijfdougy
yoizudjgf
jdogzfiuy
jziugdfoy

cdxlhpgtzrmubyse
owcrpythmfuxbe
xymtcphrdbueqis

drfatx
xfrad
rafdx
fdaxr

tuxmnqvwiodzl
znwmiuxvldtqo
qxwidtoplzuvem

l
dle
l

uv
fabuvn
zvdu

htgwvcus

kzfijesnvuhlqd
trudmvekzjisofl

qbltyocnjvigse
oriqujavzntpblfw
vmqltjciondkeb
