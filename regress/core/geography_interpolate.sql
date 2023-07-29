-- #5456 garden crash
SELECT '#5456' As ticket, ST_LineLocatePoint('0102000020E610000001000000000000000000F03F0000000000000040'::geography, 'POINT(-11.1111111 40)'::geography, false);

SELECT ST_AsText(ST_LineInterpolatePoint(geography 'Linestring(4.35 50.85, 37.617222 55.755833)', 0.0));
SELECT ST_AsText(ST_LineInterpolatePoints(geography 'Linestring(4.35 50.85, 37.617222 55.755833)', 0.0, true), 6);
SELECT ST_AsText(ST_LineInterpolatePoints(geography 'Linestring(4.35 50.85, 37.617222 55.755833)', 1.0, false), 6);

SELECT (dp).path[1], ST_AsText((dp).geom,6) FROM (SELECT ST_DumpPoints(ST_LineInterpolatePoints(geography 'Linestring(4.35 50.85, 37.617222 55.755833)', 0.1, true)::geometry) ) AS t(dp);

SELECT ST_AsText(ST_LineSubstring(geography 'Linestring(1 1,2 2)', 0.1, 0.2),7);

SELECT ST_AsText(ST_LineSubstring(geography 'Linestring(1 1,1.000000001 1.000000001)', 0.1, 0.10000001));
SELECT ST_LineLocatePoint(geography 'Linestring(1 1,2 2)', 'Point(1 1)', false);

-- Empty geography -> NULL
SELECT ST_LineInterpolatePoint(geography 'Linestring empty', 0.1);
SELECT ST_LineInterpolatePoints(geography 'Linestring empty', 0.1, true);
SELECT ST_LineLocatePoint(geography 'Linestring empty', 'Point(45 45)', true);
SELECT ST_LineSubstring(geography 'Linestring empty', 0.1, 0.2);
SELECT ST_ClosestPoint(geography 'Linestring empty', 'Point(45 45)', true);
SELECT ST_ShortestLine(geography 'Linestring empty', 'Point(45 45)', true);

/* Errors */
SELECT ST_LineInterpolatePoint(geography 'Linestring(4.35 50.85, 37.617222 55.755833)', 2);
SELECT ST_LineInterpolatePoints(geography 'Point(4.35 50.85)', 0.5, true);
SELECT ST_LineInterpolatePoints(geography 'Linestring(4.35 50.85, 37.617222 55.755833)', 2, true);
SELECT ST_LineSubstring(geography 'Linestring(4.35 50.85, 37.617222 55.755833)', 2, 0.5);
SELECT ST_LineSubstring(geography 'Linestring(4.35 50.85, 37.617222 55.755833)', 0.5, 2);
SELECT ST_LineSubstring(geography 'Linestring(1 1,2 2)', 0.2, 0.1);
SELECT ST_LineSubstring(geography 'Multipoint(1 1,2 2)', 0.1, 0.2);
SELECT ST_LineLocatePoint(geography 'Multipoint(1 1,2 2)', 'Point(1 1)', false);
SELECT ST_LineLocatePoint(geography 'Linestring(1 1,2 2)', 'Multipoint(1 1,2 2)', false);

CREATE TABLE tbl_geog_linestring3d (
    k integer PRIMARY KEY,
    g geography
);

COPY public.tbl_geog_linestring3d (k, g) FROM stdin;
1	01020000A0E610000000000000
2	01020000A0E6100000020000000000BC8E07AF32400000E54ED4DC4A4000800AE70A378F4085B81AABF4F22A405851C68A9D8A4B40C9B00F026BDF8040
3	01020000A0E6100000020000000000704ECA812A40000085545B834D40000080809D6C8340F749BF47373021402081326EB4274E406C04F14135548740
4	01020000A0E6100000020000000000F8CE0B3E24400000D1B4AAB6414000008486A5B87E402B9DE3B6F6A72D40E8E06B33F8AE4540EB52FC3D086B8340
5	01020000A0E6100000020000000000E00280740BC0000062B1FE354240000014460E6188400000BCCB3441394000005F37C0BA4940008078FBBB118140
6	01020000A0E61000000400000000008029015622400000DD6ED132424000009657196A614000005002357213C000005AFD6624474000800C4E7F0E80400000D80792C320400000B254C615454000008545A6C68D400000C8963EA62A4000004BB9DF504A40000090A00A023840
7	01020000A0E61000000200000000000021EF2E3D400000C1CF8D8F50400000E25EF2D16840E1C32BB0450B3C402709E9065C5650401BA1E45A97098140
8	01020000A0E6100000080000000000608906112B4000804AA0B22750400000CD8FE8D670400000F8041CAC35400000940701704F40000017E640C6894000000067500BD4BF0000A5AEB4E14F400000A43FD50A7E400000E004F10909C00000274ED0004D4000808A37E7398540000000B4E37FE93F000033FD11CC4E400000985ABE0A7740000000DE9B16F0BF000042A117FA4A4000009C3CC43A6940000084D535533F4000003149F0F648400000EAFF52EC67400000F0DF024537400000886C7DE24240000000FCEA543440
9	01020000A0E610000002000000000000B33641024000005134799A444000809E18C294874000005034F6022A4000006A5F74E849400080FB55E2528240
10	01020000A0E61000000200000000008067ADC4E63F0000722284AA5040008008EC65F18A400000E86E0A4B23C0000027C932174E400000C89C09345740
11	01020000A0E6100000020000000000A080D4D109C0000090E5403E46400000E74D88797940085436A06FAD314097FFFB2F67BA4940331CBA61867D7D40
12	01020000A0E610000002000000000014E89F5035400000C4D71354514000009F6F79C67F40E30427C787742F40C1372555CFAA4B40B3440B749F027D40
13	01020000A0E6100000020000000000005887E5D7BF00006D5931EA4A400080EC9C93538440000014FAE6C7344000001F5228144D400000969A92127140
14	01020000A0E6100000040000000000901A850921C000007CCA55AD424000800E00524982400000DCB385AE3F400000C1706F3547400000460277AF7D400000A0B0CE501EC00080825BB13A504000006680EE916B4000004C582D5F3F400000DCA4305D474000804743D3358440
15	01020000A0E61000000200000000008060D7562F4000006E8FEBD445400000E943A19D7140000000E9A12909400000FDCC7DBF4D400000A0B606FA5140
16	01020000A0E6100000030000000000C0965C81044000005F5A36684C400000550480FF82400000200BDD5312400080C329DD5250400000BC502C365D4000000CA592E63F4000001C1DA3B44B4000802961CB358740
17	01020000A0E610000004000000000010467D003940000039A996E44F400000CD38C2E674400000E044BC501E400000E013B3C04F4000008323051884400000903506873B4000005B59DA6850400000635727397C40000010F80AD614C000809C006F4550400000EEEB5E048840
18	01020000A0E6100000020000000000ECE2FD5E38400000CCCC638648400000A24F91178F40D121BF3965643340C2F27D90127B494006B8578ECF488A40
19	01020000A0E61000000400000000006CC52D783240000025F6808341400000F00FFF79784000002052603D25400000E1D956BB4F4000006C348F0D63400000806270ED07400000ADA6BA4144400000F472D46B62400000005F92CC1C400000B3A2348950400080A999F6228940
20	01020000A0E610000002000000000084F9E15F32400000473AB3914F4000009CB631757540A6184A1BDD1F2940F6220077B15F4C40AFE412676E668040
21	01020000A0E6100000020000000000400093F3194000004EA376E14240000008DE09D55240A2D3A1F5198002C07E7E496212714540B85FED6B045C7740
22	01020000A0E610000003000000000060677CCC15400000519D996D4E400000D29EC9B78240000020BA91420640000051BA00D34E400000712FD27D844025EF4F784B930AC0650A4D31EAA94440DC33BA294DE78140
23	01020000A0E610000005000000000058AA54B9244000005B7103EA4840008012DCBF6581400000E4A217DF314000006F56C2DD4F4000004302580E78400000F035B4A42E40000024847DAB4A400000AA2948A77440000098EA4DE72E400000BF3A4B104440000090DB4CC08D400000780FC6E63E400000086CF27E50400000627A16388140
24	01020000A0E6100000040000000000304D19D72A4000007B311D53454000000D7921937A400000243FE5B23240000030C4FDB94F4000806BB63D208E400000502BE653254000004C953E3851400000A46976FB8B400000E030D80D174000001252BE0B44400080D9E584E58E40
25	01020000A0E61000000200000000004845E14135400000604F5FC4484000001B941A548E40BA3B95506DC828406C3AD0CB2B654C405A521B6EEF4E8840
26	01020000A0E610000005000000000000A6FF9207C000006DB421424340008003C664B68D400000B025EAF116400000C7BDDB1F4B4000006C70D5D083400000A00EBCB90FC00000964C81754A4000003C0677865F400000D015DC081EC000001E604686484000008D47C4567F400000C07A4CA9FBBF0000A9D1B55048400000F01304D98E40
27	01020000A0E6100000030000000000E4FE82F835400000A302B19B51400000F85CFD8855400000AC1EE6D933400000B51592724C400000C06517B81E405846C4626C9C2F4061A640D306154D40B0C4A3DAD9097C40
28	01020000A0E610000004000000000000524D7F10400000D8D8A41B4C4000007A8B53556A40000070B2A69E17C0000043DE06534B400000FB1CE98C7240000010723CF237400000F8F398C5434000000F7BC9077340000030E3EDD739400080AFBA568D51400000406000CB8640
29	01020000A0E6100000020000000000D8B86B2E304000002281C9A24E40000056A9A2D38B4036CF287E26BD1C40937E967994C84940047610194ABF7F40
30	01020000A0E6100000020000000000D868F6642F40008085E3105850400000D2DB14AC8840D6AFBB783BC0B3BF04C332D3EC444640E8A72B9278AE7940
31	01020000A0E61000000200000000003433E54C344000009727B346504000001B5D181E8A40BC7DE6F21D7C2D409269B0A2479B4D40A424B5B093678640
32	01020000A0E6100000030000000000607E15DF12C000004B0A03DB4E40000017FB291B7C40000000E10A6BFA3F00005A475D204F400000F7E33D257240000050FAA6A110C000009AB5E85E4D400000B4C5D65E6E40
33	01020000A0E6100000020000000000042D3F263D4000804B5494FE504000004ED92C6D7B400000D86F451D24400000F965A2C647400000862C59086440
34	01020000A0E61000000400000000008097263305C00000331822AD4740000027B90BDA7B40000050B5799115400000FE8E4A994B400000EC80E14B6A4000000026E7E6DF3F0000AF191D5748400080BA3EB5E088400000EC0DA9C33C400000D396A0B947400000A20C62397F40
35	01020000A0E610000003000000000068B52ACA2B4000006C82AA114D400000444A089D8C400000A063886F22C00000982ABC1951400000092E8A61844000006049B0CE07400000A0903D46424000005900AA5D7240
36	01020000A0E6100000020000000000C00E89BD12C00000F2EE40AE4540000099B44CB37B40EC374555775623408D709FAAAE8F4C4079A71531250A8340
37	01020000A0E6100000040000000000A8D0B1BF3D400000169B78464E400080D7F837848B4000005837F4062C400000DEE9E3B64C4000804DB533198C400000D828E6DB234000000080AC4746400000F68F39036A400000D89D046027400000E1CB5DB74B400000DCC31EC08740
38	01020000A0E61000000200000000008C855AAF3640000099B17442454000000CAA17096A40313799D880BD2940C787D310B5555040569CF8A8655C8540
39	01020000A0E610000004000000000024F83AA630400000F5F328CE4D4000000032831F1C40000078F84C803B40000004D5DCD3504000008C8D345B804000007849C76321400000800928374D40000038401CCA644034C518470AE60040CFB1311249DF4F4044C577A616467340
40	01020000A0E6100000020000000000084F624921C0000063D5CB1451400000342F77CF84400000ACB4E5AC3A400000779A73474A400000C0C266428540
41	01020000A0E6100000030000000000D059C67B14400000A247185C4D400000407411EA6D400000105C05D412C000009FF41AB644400000D7CF944E8B4000009094B53A37400000A72D67D7444000009E82A9F58740
42	01020000A0E61000000200000000003C999991334000007BC0326B454000008C9C1F9B7240F6445F7698D139408492FAAA8D1D494088D9893792307C40
43	01020000A0E6100000020000000000C0F038741C4000004525BEEE42400000E0B6FC6486402082B7860F6924407644D0B6B3C94940426D167843D98240
44	01020000A0E61000000300000000003C647BBB38400000FCDBCAB746400000E33516EE8E400000005C2745D83F00003C104D2A42400080451F5B4E87400000C09C57F60F400000BC3565C44D40000009FCFE828E40
45	01020000A0E6100000020000000000E0B7141A2640000073F331FD4B400000DCCF50B17F40000088914A9B2C400000339F1FBF46400000BC7181085640
46	01020000A0E61000000600000000009CF2183D374000002F06549C5040000096AC15FC6E400000DC68DD783E40000014DF245647400000E4A66A35664000004010E76A204000004553888D4D4000806DF4EAF480400000E8F86CD620C00000ED8CEDCC4540000090DA5BE547400000F0EF5E3D2E400000A1CF7349484000800C5C05568B4000003C954BF73A4000003CB2F51848400000547D1F785E40
47	01020000A0E6100000030000000000103D4ACB16C00000A81158EB494000809FEA881982400000F01460C31AC00000988022C34B4000006086E619544013D97F86675910C08D12E627E8C34A40C7332AA9E19C6440
48	01020000A0E6100000020000000000988981C03C4000009FC5873A45400080470F482F8140A6E3BAE8D9103540C44925D3F8F14640B68488A584088340
49	01020000A0E6100000030000000000B8B9A3993340000006CCCE6B46400000A2AD5D5A764000001C9243F73B40000022F84C364A4000001CD712D45B40000088EBBF7A2340000004369FAF4B400080794CFA488740
50	01020000A0E6100000030000000000CC640C9735400000120146F5464000004923E01B7A400000A00C37AD1C400000F561B35849400000DE6FEB4C804004FD661FC911284010E827B089784B40BF10458D8AB87D40
51	01020000A0E610000007000000000010CF5EE91EC0000099DA398849400000501C42D47D400000A06C4A3D09C0000041BE3F454D4000005CE103C16640000008BEE2082040008039DF88F151400000B4BACA7E554000000C01D4CB3B400000B23140724340008071EECC5F814000003858ABD7214000803E25939D5040008097B614A58D40000080F1DED1F7BF00008F4B6C3044400000789009E67640000020A85F5C2F400000A9AD1F094C4000805838F0BF8B40
52	01020000A0E6100000030000000000C05D3E7EF7BF0000F940307244400000E03AA5395F4000008804CB9F33400000CED29A8643400000832BD8947B4000008079FA1FF23F000040544E004A40000022F4E2906640
53	01020000A0E610000002000000000024D2FD883B4000004EC84FAB4D400000102247227E40DA8E12D4BCDF29401656420B8871504052C605349ECA8840
54	01020000A0E61000000500000000004034AF27204000002FCD68164A400000F86FC28583400000009D21773740000073A12EE642400000A2DFD84668400000A40FD3C232400000A5A0FD2E47400000624196D5784000009C420973394000001D3F857E494000004416F9AB5940000054C0680C3E4000007CE543D450400000270B10FC7640
55	01020000A0E6100000020000000000A036B2EF1EC00000A4CE3E354E400000CB720A2C7340AC116443408D28409BD9E288E444474015180D420E3B8340
56	01020000A0E6100000050000000000385E0ED32F400000BFC46F3B43400000089AD24B6740000028C7B21633400000D8E53BD3464000807A673F398B400000D0A9EBFD3F400000CA67142D4E4000000AB9815986400000088026482040008051EEB309504000008791C9E584400000C031F0980640000042981661444000002C9715725440
57	01020000A0E61000000400000000006CC0226339400000C6311AB048400000A04BD6C251400000E0263F0623C0000068D2A9AA454000008C01EA74834000002088C79318C00000971E13564C400000ECA96AFF5840000058D67F493F400000054896244C400000D0271B934D40
58	01020000A0E61000000300000000006017704920C000002EC928CD4940008086C4008687400000D0F5FDD710C000005219CE3F4D400000A70067D57B400000B06FA5831F400000AF8599DD4A400000BBD54ED27B40
59	01020000A0E6100000020000000000007C0F63E6BF0080E462E7DC504000800A3D0B168C40000098C204633B400000B754F1DF4440000020BE01324B40
60	01020000A0E61000000300000000005841278129400080F7C3F60B514000003491AB877640000098FEE3782F400080296E7727514000002E9EA14D8240BA0FA5B1DBD12740C5629B399E404E40D7F21708AFD67B40
61	01020000A0E610000002000000000084351A8538400000AFC3E93D49400000A0146E0851400000C058B716154000009E4BD755474000005C16C7C97A40
62	01020000A0E610000003000000000080EF32F8E2BF000078C2CBC341400000AECF8A786A40000080B4297CE2BF00004BADC3EF444000800A0118198140D09825B1F877EFBF47DCC2B33FF84C408AF3C4980E3C8040
63	01020000A0E6100000020000000000E0E942E12B400000EA428D5D4240000098E38EFA53400000C8DDDF5837400000620559A142400000BD20E93A7240
64	01020000A0E6100000020000000000001DD48CD73F000071915282504000001EBD99416C40000000C67ABC03C00000A1A653F04F400080A306AA478140
65	01020000A0E610000002000000000030EDCB7D2B400000F68A81684F4000001BE4285881401B7169EE26483040DC58E67BCD5A4D40CB54385FC8758140
66	01020000A0E6100000030000000000806D6B600440000035160BC946400000441126EC604000004864F34A3A4000002BA18C31424000006C68329385400000BCFA2B183340000011F3542647400000EE7C24836F40
67	01020000A0E61000000400000000000815AAC63940000005A195C94640000033A61BB7724000006030D6400A400000255FFE604440000078D344BC77400000D06BF9B927400000C8E313AE46400000E0258D905340906FCB8DCD4237403FA8AF4483005140409ADA28E8088640
68	01020000A0E6100000030000000000E804E2DE21C00000B0A7A8374F400000985A57D7704000002057FB200F4000808F46CCF051400000E0B41C4F4340FA44B183E053F63F3BC677F058954E4070D07384C2287C40
69	01020000A0E610000002000000000060CB37E20CC00000623FB61D46400000412F2AFC8D40000090BDC99313C000803F5B7D6051400000481A6C567740
70	01020000A0E6100000020000000000A8755FA1394000004FAC661743400080EF50BA5C8940B813076DD55E3A406EFEDEBF9BC5464086AD0C6FF31B8A40
71	01020000A0E6100000030000000000A494D30F3340000008BE512E4F400000C014FCF53A400000343A903B30400000B590BF9643400000235E88958A406BCEEEC1CBE82B405EB5B5BD72284440AE1223A3A96D8840
72	01020000A0E61000000300000000001054E96B1540000011E9F9C345400080530753C8834000001058C8541EC000009FD325B951400080F9E702A0844070122039AC06DCBF90B7286A04FA4E40C425652C526D7E40
73	01020000A0E610000002000000000004366C9636400000230B3B9D45400080DA9664A484405AA276D6403B3940E36570F61A234E40B65027D353D07A40
74	01020000A0E6100000030000000000B0CD95E61EC00000811F5CFC47400000470C47C57340000004BF0CC535400000B12582934E40000034B85B985040000010EAF1B6284000006A985E5851400000E10D70B78640
75	01020000A0E6100000020000000000F80A49373B4000009932C13148400000922605006A408D1002D62F403240CC05FFCC579C4A403C845372EA007940
76	01020000A0E610000003000000000054B312033B400000F064DF3944400000B2DAA20774400000201B817E3B40000093929B9746400000BFE23B6A7740000000F226FCCB3F000077F0BE714C4000009022F9616040
77	01020000A0E6100000020000000000B0CB71A2314000008FEAC2C54D4000802D77A97A8B40FADA4B2183FC2C40405DAD3990C64A40763C19EB76D08640
78	01020000A0E6100000030000000000A0F1319F0C40008034C054115040000068153A0D53400000E40958363F400000F86A6CE849400080DAB950DC8D400000C062F28215400000B6E92E3D4B4000009F34BB878640
79	01020000A0E610000002000000000028433DDE37400000E7ECD9ED4F4000000C31934082400000B8104496224000003E4739C14F400080AADA523A8840
80	01020000A0E610000007000000000080997712054000001CCF78D447400000C152B48E7C400000D0D1DA991DC00000316DE0D749400000A67207F087400000A81333BF21C000005054D3A84940000094F92DCE6B400000A00A49E80840000092DCAF7D47400000A0CA19D18D40000098D9CBD53E400000C225D2D249400000F5BAAB5671400000505EBB0F364000006C55BC3B4B400000735C962A70400000007AEB35EBBF0000899C2B694A4000807FCA69868340
81	01020000A0E6100000020000000000401EBCD4F7BF000004B5B7254F40008044B152358140A64D51326ADD1E4004FEF54127FC4C401CC61385D0487040
82	01020000A0E6100000050000000000C0969E5B16C00000624C5FCE48400000089B10D0674000000031028230400000ADE464974D4000006DC89E85794000007008790C15C00000096B74A646400000B8B83F1463400000A0E2AFFC094000000D202CCC41400080729F62FA85400000003DA522044000000EEA0DC047400080BE8AA84A8640
83	01020000A0E610000002000000000060A0348820400000D1CAD17A494000000C3FAC435A40000018178FB63A4000002B0844B74C400000408D209C6B40
84	01020000A0E610000002000000000008A3D5F629400000A0B4A53948400000989E49E55740C1CACE6FEA543240CE7BACF931C94E405D2E867E554C8240
85	01020000A0E6100000020000000000F0CA3D7D394000004587ED5448400000CD69848F8940D4B185796D30384094A330782AA74840E124F04120648140
86	01020000A0E6100000030000000000302661B51C400000C241D89D4F4000009B830CF779400000808FC252E53F000007C9C5F2434000006AAE2A2C6D402A9942413C02304005D416CF67C94C405C99E3C504AA8440
87	01020000A0E6100000020000000000C0252B2223400000AEF4B2504540000092746E2E864050F56EBC06C7264062954D15E7AD46403307AF9801538140
88	01020000A0E6100000020000000000901AABBE3A4000000F6AB6DE494000008C455F708D40F5F1F89F85612940BD3DAA099C424C407A3602E4CEC57840
89	01020000A0E6100000020000000000281E22B939400000025F5C584C40000028A6CBF540400000B838CD773440000036C91237424000002D00BC7F8E40
90	01020000A0E61000000200000000000C92884933400000EBAD571D4D4000000EB2006774400000405A1EF80F4000000FE265154D4000802D04BE218940
91	01020000A0E610000002000000000020AD4707364000008D647B1950400080E4482D358D402B624017D8DF3740A9A5FD6BC17A4E40BF39748D02F78240
92	01020000A0E61000000700000000001847BBBC35400000DCA3076A49400000A89B344F85400000D0DC007C3740000086493EA646400000422502C27040000044D5B6E83840000014C7DE9141400000C8E17F2C734000006C274FE637400000E3FE4ACB424000000048C76210400000B056338920400000E13F4DD5484000000224691575400000B05494BC1DC0000054C113364540000054BA8C73844000004898229838400080494585F4514000007703BA688240
93	01020000A0E6100000020000000000600CA0BC00400000A388AA9046400080885AD9C883407BC603D368D0264013159858D67A4840CED9283DABE57340
94	01020000A0E6100000040000000000581CC05C3F4000005BA0F4B3434000008A05FA0289400000E4B0A0283F40000039C5E3994E4000802AC8317F8340000000274B03F43F0000EE2647D551400000664516107040B13BB3331014F23F3DB450F521B94E40C62539715DF78240
95	01020000A0E6100000030000000000F882002A21C000002F4AA1B449400000E75D31707E400000A049807022C000008AEA95E84B400000FB6825F67140E3C5A0C898910D40AB74083CDF364A401641CA9259D37A40
96	01020000A0E6100000070000000000C0233779F03F0080F106FC745140000048DFAA735E400000507335DF374000004790BCE34D40000040A7707B6D400000089E8D10324000006CDBFA244B4000801ED681F489400000D8D4BB8B3C400000288D19C14A40000032C3064E754000005C93BBF63D400080AB6BDD7A514000808C101CDF894000008C6E7BBE3E400000E1C150DE4A400000502876D15C400000F4FADBAE3E400000A471CAE04F4000004036688E3A40
97	01020000A0E610000003000000000068290D7C21C000008F62C91A4540000030B4CFE887400000C0A4F07C3A400080125B87B55040008051F4A2818A400000904406DE3B40008009CAE8FA50400080C419DD8B8040
98	01020000A0E610000003000000000058384DE73840000073BC828C4D4000003EAA7B558E40000010760010264000808912C4F450400000C7FC21F78340000090AC7E2522C00000F87E14C74E4000007A5032658140
99	01020000A0E6100000020000000000605E41281EC0000040C0AFE64A400000E26D35217D40AA40B221A6DD04C0C84AAB439AD24A40FF784E6520088340
100	01020000A0E6100000040000000000FC1CE1A33840000060686AB64E40008063E6F9228940000010C21AFD23400000BCE5942B4E40000019C3DB1173400000A0FFA804154000003A4A5F7D4740000077B3E9727440089C46523D2A01C00A77AD2ADAEA4D40D60A90AC7DC08340
\.

SELECT round(MAX(ST_Distance(ST_LineInterpolatePoint(g, 0.5), 'Point(50 50 50)'))::numeric, 6) FROM tbl_geog_linestring3D;

SELECT SUM(ST_NumGeometries(ST_LineInterpolatePoints(g, 0.3, repeat:=TRUE)::geometry)) FROM tbl_geog_linestring3D;

SELECT MAX(ST_LineLocatePoint(g, 'Point(50 50 50)')) FROM tbl_geog_linestring3D;

SELECT round(MAX(ST_Length(ST_LineSubstring(g, 0.5, 0.7)))::numeric, 6) FROM tbl_geog_linestring3D;

SELECT round(MAX(ST_Distance(ST_ClosestPoint(t1.g, t2.g), 'Point(50 50 50)'))::numeric, 6) FROM tbl_geog_linestring3D t1, tbl_geog_linestring3D t2;

SELECT round(MAX(ST_Length(ST_ShortestLine(t1.g, t2.g, false)))::numeric, 6) FROM tbl_geog_linestring3D t1, tbl_geog_linestring3D t2;

DROP TABLE tbl_geog_linestring3d;
