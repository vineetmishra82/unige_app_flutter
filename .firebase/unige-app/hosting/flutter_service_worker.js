'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "884d04112ec65d53609343a01c8f9dd9",
"version.json": "f51c1e33d025cf3ff0295b16c07cf6b6",
"index.html": "4c69b206e5d58b5b58460ea479c7e033",
"/": "4c69b206e5d58b5b58460ea479c7e033",
"main.dart.js": "ef8c2d7ae8cd8a10d9bf32a73bd16473",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "7df6623fed98d85d5b513cedd9c03850",
"assets/images/info.png": "95533d2bf26fc835bc3b305b30af303e",
"assets/images/email.png": "a4ada17f1c07e74b884a941ace57bbac",
"assets/images/camera%25202.png": "57b00b941b9cdd062d65db79b820bae7",
"assets/images/plusIcon.png": "7f954f3acc42c91a3f7150f190ab9a21",
"assets/images/LoginImage.png": "10a58013bad68234f81ce85059486bdb",
"assets/images/SignUpImage.png": "68a122dc72b6abe0019e34241ea94ac8",
"assets/images/mail.png": "a4ada17f1c07e74b884a941ace57bbac",
"assets/images/question.png": "1432511a547808a1e5bff102c641fbd5",
"assets/images/microphone.png": "c633bfb5527de0d0462cf2a77997f309",
"assets/images/logout.png": "3aa9b2bee3b0ee5f4abb2d672d85fea0",
"assets/images/myProfile.png": "fc4b92b75cb5429eaabac4eb54949b0a",
"assets/images/QualTrack.png": "3aa9b2bee3b0ee5f4abb2d672d85fea0",
"assets/images/EVButton.png": "567c02370cf17fb4072f6db2443a7f9e",
"assets/images/left.png": "bb2a2cbb2db9ace7635345e010943a79",
"assets/images/avatar.png": "a02aa4a9f008c39d8c0407475c227cea",
"assets/images/icons8-refresh-96.png": "d85478ba517692368c538921e8ed3962",
"assets/images/homeButton.png": "d4bf5e0a948b50d0386bccd0b1a46a64",
"assets/images/logo.png": "6d43f35f7d47f022e125bc01f43a478f",
"assets/images/upload.png": "57f900fd353e320db89d8e21d984a7f3",
"assets/images/LoginButton.png": "3ccbda4adf1b3e1e0d1281a0fdadf5aa",
"assets/images/profile.png": "a02aa4a9f008c39d8c0407475c227cea",
"assets/images/dataPrivacy.png": "54e124f7c09af0bf145694c27ea8de64",
"assets/images/deleteProfile.png": "d5794c9aa3cb72980b3dc5f4c989f233",
"assets/images/mobile.png": "e32444726264e197038d4e56a63758f1",
"assets/images/right%25202.png": "35bbe67389f736b8914f90a801baa2e4",
"assets/images/telephone.png": "e32444726264e197038d4e56a63758f1",
"assets/images/myProducts.png": "eacc3d8507c965fae51d5032a012621d",
"assets/images/name.png": "e39454bbf170e64be35bacc865b871dc",
"assets/images/left%25202.png": "bb2a2cbb2db9ace7635345e010943a79",
"assets/images/camera.png": "57b00b941b9cdd062d65db79b820bae7",
"assets/images/feedback.png": "eff6dde8f2a81ef6249f4709bf9d8f3e",
"assets/images/right.png": "35bbe67389f736b8914f90a801baa2e4",
"assets/images/myFeedback.png": "51af14aa415a3be8a26c2e8386dae4de",
"assets/images/refresh.png": "6c024c0ba110bbb2693c18c8b2f41df0",
"assets/images/mic.png": "c633bfb5527de0d0462cf2a77997f309",
"assets/AssetManifest.json": "36cfbda1f4e6af097eceaddfeb698bfd",
"assets/NOTICES": "54b1425809959281577ce9fa7427ccac",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "e61732d10be3e8caf7194ff524f73a7e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_sound/assets/js/tau_web.js": "32cc693445f561133647b10d1b97ca07",
"assets/packages/flutter_sound/assets/js/async_processor.js": "1665e1cb34d59d2769956d2f14290274",
"assets/packages/flutter_sound_web/howler/howler.js": "3030c6101d2f8078546711db0d1a24e9",
"assets/packages/flutter_sound_web/src/flutter_sound_recorder.js": "0ec45f8c46d7ddb18691714c0c7348c8",
"assets/packages/flutter_sound_web/src/flutter_sound_player.js": "b14f8d190230d77c02ffc51ce962ce80",
"assets/packages/flutter_sound_web/src/flutter_sound_stream_processor.js": "48d52b8f36a769ea0e90cf9e58eddfa7",
"assets/packages/flutter_sound_web/src/flutter_sound.js": "3c26fcc60917c4cbaa6a30a231f7d4d8",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "659d3e3cf5a7418db27036307480d994",
"assets/fonts/MaterialIcons-Regular.otf": "f212ba390c6315d94318fd65f7a4b6c3",
"assets/assets/flags/tg.png": "7f91f02b26b74899ff882868bd611714",
"assets/assets/flags/me.png": "590284bc85810635ace30a173e615ca4",
"assets/assets/flags/la.png": "e8cd9c3ee6e134adcbe3e986e1974e4a",
"assets/assets/flags/mr.png": "f2a62602d43a1ee14625af165b96ce2f",
"assets/assets/flags/ni.png": "e398dc23e79d9ccd702546cc25f126bf",
"assets/assets/flags/lv.png": "53105fea0cc9cc554e0ceaabc53a2d5d",
"assets/assets/flags/om.png": "cebd9ab4b9ab071b2142e21ae2129efc",
"assets/assets/flags/af.png": "ba710b50a060b5351381b55366396c30",
"assets/assets/flags/cy.png": "7b36f4af86257a3f15f5a5a16f4a2fcd",
"assets/assets/flags/bj.png": "6fdc6449f73d23ad3f07060f92db4423",
"assets/assets/flags/aq.png": "0c586e7b91aa192758fdd0f03adb84d8",
"assets/assets/flags/cn.png": "040539c2cdb60ebd9dc8957cdc6a8ad0",
"assets/assets/flags/gd%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/as%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gb-sct.png": "75106a5e49e3e16da76cb33bdac102ab",
"assets/assets/flags/co.png": "e3b1be16dcdae6cb72e9c238fdddce3c",
"assets/assets/flags/sl%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/cx.png": "8efa3231c8a3900a78f2b51d829f8c52",
"assets/assets/flags/ag.png": "41c11d5668c93ba6e452f811defdbb24",
"assets/assets/flags/ms.png": "9c955a926cf7d57fccb450a97192afa7",
"assets/assets/flags/md.png": "8911d3d821b95b00abbba8771e997eb3",
"assets/assets/flags/zm.png": "81cec35b715f227328cad8f314acd797",
"assets/assets/flags/vn.png": "32ff65ccbf31a707a195be2a5141a89b",
"assets/assets/flags/tf.png": "b2c044b86509e7960b5ba66b094ea285",
"assets/assets/flags/td.png": "009303b6188ca0e30bd50074b16f0b16",
"assets/assets/flags/yt.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/assets/flags/lb.png": "f80cde345f0d9bd0086531808ce5166a",
"assets/assets/flags/mf.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/assets/flags/lu.png": "6274fd1cae3c7a425d25e4ccb0941bb8",
"assets/assets/flags/mq.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/assets/flags/cz.png": "73ecd64c6144786c4d03729b1dd9b1f3",
"assets/assets/flags/ae.png": "792efc5eb6c31d780bd34bf4bad69f3f",
"assets/assets/flags/cm.png": "42d52fa71e8b4dbb182ff431749e8d0d",
"assets/assets/flags/bi.png": "adda8121501f0543f1075244a1acc275",
"assets/assets/flags/ar.png": "3bd245f8c28f70c9ef9626dae27adc65",
"assets/assets/flags/mq%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/tr%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/as.png": "d9c1da515c6f945c2e2554592a9dfaae",
"assets/assets/flags/bh.png": "a1acd86ef0e19ea5f0297bbe1de6cfd4",
"assets/assets/flags/cl.png": "6735e0e2d88c119e9ed1533be5249ef1",
"assets/assets/flags/ad.png": "384e9845debe9aca8f8586d9bedcb7e6",
"assets/assets/flags/mp.png": "87351c30a529071ee9a4bb67765fea4f",
"assets/assets/flags/lt.png": "7df2cd6566725685f7feb2051f916a3e",
"assets/assets/flags/mg.png": "0ef6271ad284ebc0069ff0aeb5a3ad1e",
"assets/assets/flags/lc.png": "8c1a03a592aa0a99fcaf2b81508a87eb",
"assets/assets/flags/tr.png": "27feab1a5ca390610d07e0c6bd4720d5",
"assets/assets/flags/ua.png": "b4b10d893611470661b079cb30473871",
"assets/assets/flags/tv.png": "c57025ed7ae482210f29b9da86b0d211",
"assets/assets/flags/vi.png": "3f317c56f31971b3179abd4e03847036",
"assets/assets/flags/mt.png": "f3119401ae0c3a9d6e2dc23803928c06",
"assets/assets/flags/no.png": "33bc70259c4908b7b9adeef9436f7a9f",
"assets/assets/flags/mc.png": "90c2ad7f144d73d4650cbea9dd621275",
"assets/assets/flags/ch.png": "a251702f7760b0aac141428ed60b7b66",
"assets/assets/flags/bl.png": "dae94f5465d3390fdc5929e4f74d3f5f",
"assets/assets/flags/aw.png": "a93ddf8e32d246dc47f6631f38e0ed92",
"assets/assets/flags/mp%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/an%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/zw%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/us%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/bt%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/bz.png": "fd2d7d27a5ddabe4eb9a10b1d3a433e4",
"assets/assets/flags/bm.png": "b366ba84cbc8286c830f392bb9086be5",
"assets/assets/flags/ci.png": "7f5ca3779d5ff6ce0c803a6efa0d2da7",
"assets/assets/flags/mu.png": "c5228d1e94501d846b5bf203f038ae49",
"assets/assets/flags/ca%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/us.png": "83b065848d14d33c0d10a13e01862f34",
"assets/assets/flags/tw.png": "b1101fd5f871a9ffe7c9ad191a7d3304",
"assets/assets/flags/ly%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/my%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/pw%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ye.png": "4cf73209d90e9f02ead1565c8fdf59e5",
"assets/assets/flags/mw.png": "ffc1f18eeedc1dfbb1080aa985ce7d05",
"assets/assets/flags/nl.png": "3649c177693bfee9c2fcc63c191a51f1",
"assets/assets/flags/ls.png": "2bca756f9313957347404557acb532b0",
"assets/assets/flags/bo.png": "3ccf6fa7f9cbc27949b8418925e4e89c",
"assets/assets/flags/at.png": "570c070177a5ea0fe03e20107ebf5283",
"assets/assets/flags/ck.png": "39f343868a8dc8ca95d27b27a5caf480",
"assets/assets/flags/ml%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/vu%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/by.png": "beabf61e94fb3a4f7c7a7890488b213d",
"assets/assets/flags/au.png": "72be14316f0af3903cdca7a726c0c589",
"assets/assets/flags/bn.png": "ed650de06fff61ff27ec92a872197948",
"assets/assets/flags/ma.png": "057ea2e08587f1361b3547556adae0c2",
"assets/assets/flags/nz.png": "65c811e96eb6c9da65538f899c110895",
"assets/assets/flags/lr.png": "b92c75e18dd97349c75d6a43bd17ee94",
"assets/assets/flags/mv.png": "d9245f74e34d5c054413ace4b86b4f16",
"assets/assets/flags/nc%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/tc.png": "d728d6763c17c520ad6bcf3c24282a29",
"assets/assets/flags/ug.png": "9a0f358b1eb19863e21ae2063fab51c0",
"assets/assets/flags/tt.png": "a8e1fc5c65dc8bc362a9453fadf9c4b3",
"assets/assets/flags/pl.png": "f20e9ef473a9ed24176f5ad74dd0d50a",
"assets/assets/flags/rs.png": "9dff535d2d08c504be63062f39eff0b7",
"assets/assets/flags/in.png": "1dec13ba525529cffd4c7f8a35d51121",
"assets/assets/flags/ge.png": "6fbd41f07921fa415347ebf6dff5b0f7",
"assets/assets/flags/gr.png": "ec11281d7decbf07b81a23a72a609b59",
"assets/assets/flags/mg%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/kp%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gn%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ss%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/rs%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gs.png": "419dd57836797a3f1bf6258ea6589f9a",
"assets/assets/flags/gd.png": "7a4864ccfa2a0564041c2d1f8a13a8c9",
"assets/assets/flags/io.png": "83d45bbbff087d47b2b39f1c20598f52",
"assets/assets/flags/hk.png": "4b5ec424348c98ec71a46ad3dce3931d",
"assets/assets/flags/kp.png": "e1c8bb52f31fca22d3368d8f492d8f27",
"assets/assets/flags/gb-nir.png": "98773db151c150cabe845183241bfe6b",
"assets/assets/flags/kg.png": "c4aa6d221d9a9d332155518d6b82dbc7",
"assets/assets/flags/cv%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/pm.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/assets/flags/sv.png": "217b691efbef7a0f48cdd53e91997f0e",
"assets/assets/flags/re.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/assets/flags/sa.png": "7c95c1a877148e2aa21a213d720ff4fd",
"assets/assets/flags/sc.png": "e969fd5afb1eb5902675b6bcf49a8c2e",
"assets/assets/flags/st.png": "fef62c31713ff1063da2564df3f43eea",
"assets/assets/flags/ke.png": "cf5aae3699d3cacb39db9803edae172b",
"assets/assets/flags/im.png": "7c9ccb825f0fca557d795c4330cf4f50",
"assets/assets/flags/kr.png": "a3b7da3b76b20a70e9cd63cc2315b51b",
"assets/assets/flags/gf.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/assets/flags/dj.png": "078bd37d41f746c3cb2d84c1e9611c55",
"assets/assets/flags/gq.png": "4286e56f388a37f64b21eb56550c06d9",
"assets/assets/flags/ae%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/na%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gp.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/assets/flags/dk.png": "abcd01bdbcc02b4a29cbac237f29cd1d",
"assets/assets/flags/gg.png": "eed435d25bd755aa7f9cd7004b9ed49d",
"assets/assets/flags/il.png": "1e06ad7783f24332405d36561024cc4c",
"assets/assets/flags/sz%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/pn.png": "0b0641b356af4c3e3489192ff4b0be77",
"assets/assets/flags/bj%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/sb.png": "296ecedbd8d1c2a6422c3ba8e5cd54bd",
"assets/assets/flags/py.png": "154d4add03b4878caf00bd3249e14f40",
"assets/assets/flags/ru.png": "6974dcb42ad7eb3add1009ea0c6003e3",
"assets/assets/flags/kw.png": "3ca448e219d0df506fb2efd5b91be092",
"assets/assets/flags/do.png": "ed35983a9263bb5713be37d9a52caddc",
"assets/assets/flags/gt.png": "706a0c3b5e0b589c843e2539e813839e",
"assets/assets/flags/km%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/jm%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/vc%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gb.png": "98773db151c150cabe845183241bfe6b",
"assets/assets/flags/gu.png": "2acb614b442e55864411b6e418df6eab",
"assets/assets/flags/je.png": "288f8dca26098e83ff0455b08cceca1b",
"assets/assets/flags/hm.png": "72be14316f0af3903cdca7a726c0c589",
"assets/assets/flags/tl%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/sg.png": "bc772e50b8c79f08f3c2189f5d8ce491",
"assets/assets/flags/pk.png": "7a6a621f7062589677b3296ca16c6718",
"assets/assets/flags/sr.png": "9f912879f2829a625436ccd15e643e39",
"assets/assets/flags/se.png": "25dd5434891ac1ca2ad1af59cda70f80",
"assets/assets/flags/jp.png": "25ac778acd990bedcfdc02a9b4570045",
"assets/assets/flags/gw.png": "05606b9a6393971bd87718b809e054f9",
"assets/assets/flags/eh.png": "515a9cf2620c802e305b5412ac81aed2",
"assets/assets/flags/fo%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ph%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/mf%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/bb%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/eu%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/dz.png": "132ceca353a95c8214676b2e94ecd40f",
"assets/assets/flags/ga.png": "b0e5b2fa1b7106c7652a955db24c11c4",
"assets/assets/flags/fr.png": "134bee9f9d794dc5c0922d1b9bdbb710",
"assets/assets/flags/dm.png": "8886b222ed9ccd00f67e8bcf86dadcc2",
"assets/assets/flags/bw%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/sg%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/hn.png": "9ecf68aed83c4a9b3f1e6275d96bfb04",
"assets/assets/flags/sd.png": "65ce270762dfc87475ea99bd18f79025",
"assets/assets/flags/rw.png": "d1aae0647a5b1ab977ae43ab894ce2c3",
"assets/assets/flags/ph.png": "e4025d1395a8455f1ba038597a95228c",
"assets/assets/flags/ss.png": "b0120cb000b31bb1a5c801c3592139bc",
"assets/assets/flags/qa.png": "eb9b3388e554cf85aea1e739247548df",
"assets/assets/flags/bg%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/pe.png": "4d9249aab70a26fadabb14380b3b55d2",
"assets/assets/flags/pr.png": "b97b2f4432c430bc340d893f36527e31",
"assets/assets/flags/si.png": "24237e53b34752554915e71e346bb405",
"assets/assets/flags/ht.png": "630f7f8567d87409a32955107ad11a86",
"assets/assets/flags/in%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/es.png": "654965f9722f6706586476fb2f5d30dd",
"assets/assets/flags/gl.png": "b79e24ee1889b7446ba3d65564b86810",
"assets/assets/flags/nl%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/br%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/xk%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ee%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gm.png": "7148d3715527544c2e7d8d6f4a445bb6",
"assets/assets/flags/er.png": "8ca78e10878a2e97c1371b38c5d258a7",
"assets/assets/flags/fi.png": "3ccd69a842e55183415b7ea2c04b15c8",
"assets/assets/flags/ee.png": "e242645cae28bd5291116ea211f9a566",
"assets/assets/flags/kn.png": "f318e2fd87e5fd2cabefe9ff252bba46",
"assets/assets/flags/hu.png": "281582a753e643b46bdd894047db08bb",
"assets/assets/flags/iq.png": "bc3e6f68c5188dbf99b473e2bea066f2",
"assets/assets/flags/ky.png": "38e39eba673e82c48a1f25bd103a7e97",
"assets/assets/flags/sh.png": "98773db151c150cabe845183241bfe6b",
"assets/assets/flags/ps.png": "52a25a48658ca9274830ffa124a8c1db",
"assets/assets/flags/pm%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/lc%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/pf.png": "1ae72c24380d087cbe2d0cd6c3b58821",
"assets/assets/flags/sj.png": "33bc70259c4908b7b9adeef9436f7a9f",
"assets/assets/flags/id.png": "80bb82d11d5bc144a21042e77972bca9",
"assets/assets/flags/is.png": "907840430252c431518005b562707831",
"assets/assets/flags/ir%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/eg.png": "311d780e8e3dd43f87e6070f6feb74c7",
"assets/assets/flags/fk.png": "da8b0fe48829aae2c8feb4839895de63",
"assets/assets/flags/ws%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/fj.png": "1c6a86752578eb132390febf12789cd6",
"assets/assets/flags/kh%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gn.png": "b2287c03c88a72d968aa796a076ba056",
"assets/assets/flags/wf%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gy.png": "159a260bf0217128ea7475ba5b272b6a",
"assets/assets/flags/ir.png": "37f67c3141e9843196cb94815be7bd37",
"assets/assets/flags/km.png": "5554c8746c16d4f482986fb78ffd9b36",
"assets/assets/flags/ie.png": "1d91912afc591dd120b47b56ea78cdbf",
"assets/assets/flags/kz.png": "cb3b0095281c9d7e7fb5ce1716ef8ee5",
"assets/assets/flags/ro.png": "85af99741fe20664d9a7112cfd8d9722",
"assets/assets/flags/sk.png": "2a1ee716d4b41c017ff1dbf3fd3ffc64",
"assets/assets/flags/pg.png": "0f7e03465a93e0b4e3e1c9d3dd5814a4",
"assets/assets/flags/pt.png": "eba93d33545c78cc67915d9be8323661",
"assets/assets/flags/so.png": "1ce20d052f9d057250be96f42647513b",
"assets/assets/flags/sx.png": "9c19254973d8acf81581ad95b408c7e6",
"assets/assets/flags/hr.png": "69711b2ea009a3e7c40045b538768d4e",
"assets/assets/flags/ki.png": "14db0fc29398730064503907bd696176",
"assets/assets/flags/jm.png": "074400103847c56c37425a73f9d23665",
"assets/assets/flags/bz%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/eu.png": "c58ece3931acb87faadc5b940d4f7755",
"assets/assets/flags/co%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ec.png": "c1ae60d080be91f3be31e92e0a2d9555",
"assets/assets/flags/et.png": "57edff61c7fddf2761a19948acef1498",
"assets/assets/flags/fo.png": "2c7d9233582e83a86927e634897a2a90",
"assets/assets/flags/kh.png": "d48d51e8769a26930da6edfc15de97fe",
"assets/assets/flags/vg%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ki%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/sy.png": "24186a0f4ce804a16c91592db5a16a3a",
"assets/assets/flags/sn.png": "68eaa89bbc83b3f356e1ba2096b09b3c",
"assets/assets/flags/pw.png": "2e697cc6907a7b94c7f94f5d9b3bdccc",
"assets/assets/flags/sl.png": "61b9d992c8a6a83abc4d432069617811",
"assets/assets/flags/ua%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/io%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gb-eng.png": "0d9f2a6775fd52b79e1d78eb1dda10cf",
"assets/assets/flags/cf%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/fm.png": "d571b8bc4b80980a81a5edbde788b6d2",
"assets/assets/flags/gi.png": "446aa44aaa063d240adab88243b460d3",
"assets/assets/flags/sv%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/de.png": "5d9561246523cf6183928756fd605e25",
"assets/assets/flags/vn%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gh.png": "b35464dca793fa33e51bf890b5f3d92b",
"assets/assets/flags/jo.png": "c01cb41f74f9db0cf07ba20f0af83011",
"assets/assets/flags/it.png": "5c8e910e6a33ec63dfcda6e8960dd19c",
"assets/assets/flags/pa.png": "78e3e4fd56f0064837098fe3f22fb41b",
"assets/assets/flags/sz.png": "d1829842e45c2b2b29222c1b7e201591",
"assets/assets/flags/sm.png": "a8d6801cb7c5360e18f0a2ed146b396d",
"assets/assets/flags/tn.png": "6612e9fec4bef022cbd45cbb7c02b2b6",
"assets/assets/flags/ml.png": "0c50dfd539e87bb4313da0d4556e2d13",
"assets/assets/flags/cg.png": "eca97338cc1cb5b5e91bec72af57b3d4",
"assets/assets/flags/cm%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ax.png": "ec2062c36f09ed8fb90ac8992d010024",
"assets/assets/flags/ao.png": "5f0a372aa3aa7150a3dafea97acfc10d",
"assets/assets/flags/bt.png": "3cfe1440e952bc7266d71f7f1454fa23",
"assets/assets/flags/cx%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/gu%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ve%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/an.png": "4e4b90fbca1275d1839ca5b44fc51071",
"assets/assets/flags/pg%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/bb.png": "a8473747387e4e7a8450c499529f1c93",
"assets/assets/flags/cf.png": "263583ffdf7a888ce4fba8487d1da0b2",
"assets/assets/flags/mm.png": "32e5293d6029d8294c7dfc3c3835c222",
"assets/assets/flags/li.png": "ecdf7b3fe932378b110851674335d9ab",
"assets/assets/flags/na.png": "cdc00e9267a873609b0abea944939ff7",
"assets/assets/flags/mz.png": "1ab1ac750fbbb453d33e9f25850ac2a0",
"assets/assets/flags/to.png": "1cdd716b5b5502f85d6161dac6ee6c5b",
"assets/assets/flags/vg.png": "fc095e11f5b58604d6f4d3c2b43d167f",
"assets/assets/flags/ve.png": "893391d65cbd10ca787a73578c77d3a7",
"assets/assets/flags/tz.png": "56ec99c7e0f68b88a2210620d873683a",
"assets/assets/flags/tm.png": "0980fb40ec450f70896f2c588510f933",
"assets/assets/flags/tv%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/mx.png": "84b12a569b209e213daccfcbdd1fc799",
"assets/assets/flags/nc.png": "cb36e0c945b79d56def11b23c6a9c7e9",
"assets/assets/flags/mo.png": "849848a26bbfc87024017418ad7a6233",
"assets/assets/flags/lk.png": "5a3a063cfff4a92fb0ba6158e610e025",
"assets/assets/flags/cd.png": "5b5f832ed6cd9f9240cb31229d8763dc",
"assets/assets/flags/sa%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/al.png": "722cf9e5c7a1d9c9e4608fb44dbb427d",
"assets/assets/flags/bw.png": "fac8b90d7404728c08686dc39bab4fb3",
"assets/assets/flags/hm%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/im%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/nz%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/fi%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/cr.png": "bfd8b41e63fc3cc829c72c4b2e170532",
"assets/assets/flags/bv.png": "33bc70259c4908b7b9adeef9436f7a9f",
"assets/assets/flags/am.png": "aaa39141fbc80205bebaa0200b55a13a",
"assets/assets/flags/az.png": "6ffa766f6883d2d3d350cdc22a062ca3",
"assets/assets/flags/ba.png": "d415bad33b35de3f095177e8e86cbc82",
"assets/assets/flags/mn.png": "16086e8d89c9067d29fd0f2ea7021a45",
"assets/assets/flags/nu.png": "f4169998548e312584c67873e0d9352d",
"assets/assets/flags/my.png": "f7f962e8a074387fd568c9d4024e0959",
"assets/assets/flags/tl.png": "c80876dc80cda5ab6bb8ef078bc6b05d",
"assets/assets/flags/ws.png": "f206322f3e22f175869869dbfadb6ce8",
"assets/assets/flags/th.png": "11ce0c9f8c738fd217ea52b9bc29014b",
"assets/assets/flags/xk.png": "079259fbcb1f3c78dafa944464295c16",
"assets/assets/flags/nf.png": "1c2069b299ce3660a2a95ec574dfde25",
"assets/assets/flags/ly.png": "8d65057351859065d64b4c118ff9e30e",
"assets/assets/flags/ai.png": "ce5e91ed1725f0499b9231b69a7fd448",
"assets/assets/flags/br.png": "5093e0cd8fd3c094664cd17ea8a36fd1",
"assets/assets/flags/cv.png": "9b1f31f9fc0795d728328dedd33eb1c0",
"assets/assets/flags/tw%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/be.png": "7e5e1831cdd91935b38415479a7110eb",
"assets/assets/flags/ca.png": "76f2fac1d3b2cc52ba6695c2e2941632",
"assets/assets/flags/ru%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/bd.png": "86a0e4bd8787dc8542137a407e0f987f",
"assets/assets/flags/cw.png": "6c598eb0d331d6b238da57055ec00d33",
"assets/assets/flags/bs.png": "2b9540c4fa514f71911a48de0bd77e71",
"assets/assets/flags/ng.png": "aedbe364bd1543832e88e64b5817e877",
"assets/assets/flags/mk.png": "835f2263974de523fa779d29c90595bf",
"assets/assets/flags/np.png": "6e099fb1e063930bdd00e8df5cef73d4",
"assets/assets/flags/va.png": "c010bf145f695d5c8fb551bafc081f77",
"assets/assets/flags/uz.png": "3adad3bac322220cac8abc1c7cbaacac",
"assets/assets/flags/um.png": "8fe7c4fed0a065fdfb9bd3125c6ecaa1",
"assets/assets/flags/tk.png": "60428ff1cdbae680e5a0b8cde4677dd5",
"assets/assets/flags/vc.png": "da3ca14a978717467abbcdece05d3544",
"assets/assets/flags/nr%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/zw.png": "078a3267ea8eabf88b2d43fe4aed5ce5",
"assets/assets/flags/nr.png": "1316f3a8a419d8be1975912c712535ea",
"assets/assets/flags/ne.png": "a20724c177e86d6a27143aa9c9664a6f",
"assets/assets/flags/ie%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/cu.png": "f41715bd51f63a9aebf543788543b4c4",
"assets/assets/flags/bq.png": "3649c177693bfee9c2fcc63c191a51f1",
"assets/assets/flags/bf.png": "63f1c67fca7ce8b52b3418a90af6ad37",
"assets/assets/flags/by%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ng%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/ps%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/bg.png": "1d24bc616e3389684ed2c9f18bcb0209",
"assets/assets/flags/cc.png": "31a475216e12fef447382c97b42876ce",
"assets/assets/flags/gb-wls.png": "d7d7c77c72cd425d993bdc50720f4d04",
"assets/assets/flags/mh.png": "18dda388ef5c1cf37cae5e7d5fef39bc",
"assets/assets/flags/mh%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/za.png": "b28280c6c3eb4624c18b5455d4a1b1ff",
"assets/assets/flags/pf%25202.png": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/flags/uy.png": "da4247b21fcbd9e30dc2b3f7c5dccb64",
"assets/assets/flags/wf.png": "6f1644b8f907d197c0ff7ed2f366ad64",
"assets/assets/flags/vu.png": "3f201fdfb6d669a64c35c20a801016d1",
"assets/assets/flags/tj.png": "c73b793f2acd262e71b9236e64c77636",
"assets/assets/audio/cow.mp3": "4712e67a0038c204f371a311d84a5c66",
"assets/assets/audio/horse.mp3": "d83495e9a3a0a5b9f613532d6e70ecfe",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
