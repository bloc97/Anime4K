// MIT License

// Copyright (c) 2019-2021 bloc97
// All rights reserved.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//!DESC Anime4K-v3.2-Upscale-CNN-x2-(S)-Conv-4x3x3x3
//!HOOK MAIN
//!BIND MAIN
//!SAVE conv2d_tf
//!WIDTH MAIN.w
//!HEIGHT MAIN.h
//!COMPONENTS 4
//!WHEN OUTPUT.w MAIN.w / 1.200 > OUTPUT.h MAIN.h / 1.200 > *
#define go_0(x_off, y_off) (MAIN_texOff(vec2(x_off, y_off)))
vec4 hook() {
    vec4 result = mat4(-0.0057322932, 0.12928207, -0.056848746, 0.18680117, -0.0306273, 0.25602463, 0.053723164, 0.20419341, 0.0018709862, 0.022848232, -0.04105527, 0.10169034, 0.0, 0.0, 0.0, 0.0) * go_0(-1.0, -1.0);
    result += mat4(0.009471417, -0.12957802, 0.096014425, 0.21836184, 0.00021601951, -0.22997683, 0.23666254, 0.41192335, 0.021762101, 0.0047863554, 0.008233427, 0.108514786, 0.0, 0.0, 0.0, 0.0) * go_0(-1.0, 0.0);
    result += mat4(-0.01156376, -0.18988979, 0.04614705, -0.044767227, 0.01050636, -0.26426336, 0.23741047, 0.0027636609, -0.027718676, -0.14202335, -0.016650287, -0.06637125, 0.0, 0.0, 0.0, 0.0) * go_0(-1.0, 1.0);
    result += mat4(0.057809234, -0.11033858, 0.056533534, -0.06292466, 0.13880666, -0.18710336, 0.2441031, -0.25326246, 0.0032683122, -0.026437074, 0.0023248852, 7.640766e-05, 0.0, 0.0, 0.0, 0.0) * go_0(0.0, -1.0);
    result += mat4(-0.49110603, 0.4429004, -0.44015464, -0.41174838, -0.87738293, 0.7808468, -1.0929365, -0.59699076, -0.18409836, 0.185138, -0.11773224, -0.17097276, 0.0, 0.0, 0.0, 0.0) * go_0(0.0, 0.0);
    result += mat4(0.10580959, -0.055947904, -0.03431237, -0.080236495, 0.14862584, -0.15393938, -0.18872876, -0.3170681, 0.03559387, -0.003990826, 0.021298569, 0.012844483, 0.0, 0.0, 0.0, 0.0) * go_0(0.0, 1.0);
    result += mat4(-0.040715586, -0.25781113, 0.08896714, -0.1225879, -0.15790503, -0.54010904, 0.29588607, 0.10401059, 0.003413123, -0.108357325, 0.0112870345, -0.11888622, 0.0, 0.0, 0.0, 0.0) * go_0(1.0, -1.0);
    result += mat4(0.0049315444, 0.02376202, -0.08224771, 0.121118225, -0.041512914, -0.027994309, -0.585988, -0.069672115, -0.017247835, 0.0056576864, 0.04319012, 0.055003505, 0.0, 0.0, 0.0, 0.0) * go_0(1.0, 0.0);
    result += mat4(0.37521392, 0.15916082, 0.059708964, 0.19046007, 0.8120325, 0.38343868, 0.3436578, 0.5287958, 0.16570656, 0.06957687, 0.014022592, 0.074799836, 0.0, 0.0, 0.0, 0.0) * go_0(1.0, 1.0);
    result += vec4(-0.01050964, -0.00939481, 0.17684458, 0.027366742);
    return result;
}
//!DESC Anime4K-v3.2-Upscale-CNN-x2-(S)-Conv-4x3x3x8
//!HOOK MAIN
//!BIND conv2d_tf
//!SAVE conv2d_1_tf
//!WIDTH conv2d_tf.w
//!HEIGHT conv2d_tf.h
//!COMPONENTS 4
//!WHEN OUTPUT.w MAIN.w / 1.200 > OUTPUT.h MAIN.h / 1.200 > *
#define go_0(x_off, y_off) (max((conv2d_tf_texOff(vec2(x_off, y_off))), 0.0))
#define go_1(x_off, y_off) (max(-(conv2d_tf_texOff(vec2(x_off, y_off))), 0.0))
vec4 hook() {
    vec4 result = mat4(-0.011029496, 0.05866063, -0.09460646, -0.017664742, -0.022488879, 0.18384217, -0.00397663, -0.064733066, 0.08466802, 0.10667488, 8.0212536e-05, 0.0908869, 0.13580276, 0.00097438256, 0.12176522, -0.08218466) * go_0(-1.0, -1.0);
    result += mat4(0.16062798, -0.10190268, 0.03280682, 0.05621916, -0.009684231, -0.08464307, 0.17058301, -0.096469186, 0.1967505, -0.1450099, 0.093607284, -0.28240147, -0.21377413, 0.10079291, -0.1741522, 0.17330575) * go_0(-1.0, 0.0);
    result += mat4(-0.060160473, 0.06316997, 0.0046929033, -0.049405966, 0.13851729, 0.06830702, -0.0586872, -0.040827133, 0.007052838, -0.03576886, -0.111261636, 0.039155316, -0.07380389, -0.09369825, 0.04471156, 0.09678487) * go_0(-1.0, 1.0);
    result += mat4(-0.36683616, -0.035950605, -0.24414362, -0.009159744, 0.19335322, -0.099253505, 0.075083904, -0.00076695543, 0.65291303, -0.25599423, 0.19827642, 0.065899536, -0.07423247, -0.068967685, 0.0050554527, -0.060272824) * go_0(0.0, -1.0);
    result += mat4(-0.020688485, -0.83178276, 0.11104878, 0.26454413, 0.13655476, 0.37675047, -0.22219229, -0.01751935, 0.44552696, 0.92510307, 0.16063261, -0.62011045, 0.19366647, -0.06996067, -0.2504841, 0.00803723) * go_0(0.0, 0.0);
    result += mat4(0.0051537007, -0.057168536, -0.16110587, 0.25232598, -0.04447099, 0.11997351, 0.14808103, -0.34443566, -0.26212573, -0.21970181, 0.2724405, 0.21050811, -0.07949061, -0.064808235, -0.21208277, -0.0042361654) * go_0(0.0, 1.0);
    result += mat4(-0.0888952, -0.20169449, 0.19144905, -0.016882861, -0.013283103, 0.07552998, -0.24686803, 0.012453213, -0.065454446, -0.016123284, -0.47316182, 0.070926026, 0.09219782, 0.13118166, 0.074736096, 0.0077910526) * go_0(1.0, -1.0);
    result += mat4(0.5832154, 0.1138069, -0.039765622, 0.3182784, -0.25497997, 0.0013993139, 0.39285088, -0.48511526, -0.39891505, -0.19094779, -0.082146175, -0.20826934, 0.020590555, -0.0012490178, -0.4398621, 0.14377014) * go_0(1.0, 0.0);
    result += mat4(0.21917395, 3.4314657e-05, 0.25734863, -0.3433305, 0.015720673, 0.2676127, -0.06807297, 0.15040149, -0.23638041, -0.0050233034, -0.13666134, 0.4542111, -0.033572577, -0.08450588, -0.23341487, 0.053490847) * go_0(1.0, 1.0);
    result += mat4(-0.17482175, 0.057647135, 0.33135444, 0.0850751, -0.1718849, -0.0854123, 0.036795795, -0.13874969, -0.10903869, -0.19007301, -0.06064334, -0.03786032, -0.036696054, 0.07844446, 0.012523185, -0.01562906) * go_1(-1.0, -1.0);
    result += mat4(-0.04411997, -0.10331819, 0.10050193, 0.12406485, 0.07431592, 0.30109692, -0.17511666, -0.13263564, -0.10192587, 0.07821255, -0.22415096, 0.25552443, 0.17881326, -0.13914281, 0.109979235, -0.0016463579) * go_1(-1.0, 0.0);
    result += mat4(-0.01911644, -0.15412527, 0.028903123, 0.20831817, 0.00375175, 0.08110953, 0.074919395, -0.17581624, -0.015677985, 0.06504228, 0.08817818, -0.12518327, -0.09537373, 0.028905088, -0.051288474, 0.054334078) * go_1(-1.0, 1.0);
    result += mat4(0.2852779, -0.28924024, 0.36805123, 0.21079305, -0.28336474, 0.1679663, -0.08641141, -0.10699407, -0.16090055, 0.1287612, -0.15910125, 0.05734755, 0.15883245, 0.0053026294, 0.080674745, 0.0505137) * go_1(0.0, -1.0);
    result += mat4(0.17639062, 0.3790122, -0.19588692, -0.020314282, 0.26197383, 0.09014768, 0.19696823, -0.41025418, -0.08308115, -0.33279485, -0.22528782, 0.06172439, -0.1365661, -0.13094363, -0.005086559, 0.089024484) * go_1(0.0, 0.0);
    result += mat4(0.05262993, 0.0006296959, 0.1657725, -0.32591924, 0.12126701, 0.061543245, -0.10526848, 0.041583937, 0.094976954, 0.09416157, -0.22019257, -0.058390073, -0.2073888, 0.057273377, 0.19558284, 0.004208022) * go_1(0.0, 1.0);
    result += mat4(0.30005738, 0.18478931, -0.23342943, 0.22455733, -0.016488122, 0.099634305, 0.31620836, -0.15731157, 0.09595808, 0.0013774688, 0.48273298, -0.07027936, -0.18764344, -0.26194447, -0.11794225, -0.012173601) * go_1(1.0, -1.0);
    result += mat4(0.117986746, -0.13846518, -0.019614812, -0.3011192, 0.5501164, 0.3408611, -0.40090847, 0.15706886, 0.13050972, 0.051776595, 0.20792943, 0.23389706, -0.22965533, -0.053367328, 0.3911586, -0.032988597) * go_1(1.0, 0.0);
    result += mat4(0.054753624, -0.008485731, -0.2451672, 0.17528129, 0.13657846, 0.010480436, 0.07651423, -0.43316832, 0.12736236, 0.13804524, 0.12529011, -0.30946237, -0.14423579, 0.08403089, 0.24335162, 0.057288036) * go_1(1.0, 1.0);
    result += vec4(0.012077211, 0.013045883, 0.0380778, -0.02908858);
    return result;
}
//!DESC Anime4K-v3.2-Upscale-CNN-x2-(S)-Conv-4x3x3x8
//!HOOK MAIN
//!BIND conv2d_1_tf
//!SAVE conv2d_2_tf
//!WIDTH conv2d_1_tf.w
//!HEIGHT conv2d_1_tf.h
//!COMPONENTS 4
//!WHEN OUTPUT.w MAIN.w / 1.200 > OUTPUT.h MAIN.h / 1.200 > *
#define go_0(x_off, y_off) (max((conv2d_1_tf_texOff(vec2(x_off, y_off))), 0.0))
#define go_1(x_off, y_off) (max(-(conv2d_1_tf_texOff(vec2(x_off, y_off))), 0.0))
vec4 hook() {
    vec4 result = mat4(-0.036115196, -0.06971895, -0.07508942, 0.016036168, 0.12120111, 0.24536026, 0.044755507, -0.20663576, 0.029635755, -0.15427187, 0.027148994, -0.20795093, 0.10170582, 0.077919215, 0.66063017, -0.4632968) * go_0(-1.0, -1.0);
    result += mat4(-0.0052889925, -0.019060908, -0.08660142, -0.022095207, -0.08097976, -0.015142803, -0.18552722, -0.078493506, -0.16293915, -0.20099808, -0.08370822, 0.3701389, 0.09094984, 0.2487225, 0.24338846, 0.044003833) * go_0(-1.0, 0.0);
    result += mat4(-0.061406493, -0.017232792, -0.10917424, 0.11203319, 0.040699825, -0.019294346, 0.084953666, -0.018133596, 0.07209552, 0.016069936, 0.17805555, -0.089537814, 0.15809004, 0.1027023, 0.15044671, -0.15530108) * go_0(-1.0, 1.0);
    result += mat4(0.0948676, -0.040305693, -0.005591629, -0.048048403, -0.07547777, 0.056606572, 0.021390207, 0.32600567, -0.20805131, -0.099587254, 0.029613169, 0.0092129605, -0.29429698, -0.09898621, 0.44470885, -0.89487344) * go_0(0.0, -1.0);
    result += mat4(-0.122259885, 0.11445877, 0.06666907, 0.1869428, -0.1553992, -0.1658741, 0.2988138, -0.57746625, -0.34609964, 0.11169158, -0.41877756, 0.38075635, 0.21293911, 0.09640372, -0.12754214, -0.08026104) * go_0(0.0, 0.0);
    result += mat4(0.15128808, 0.050087795, 0.09219755, -0.18080945, 0.0044571217, -0.046019405, -0.1289922, 0.20305426, 0.19601224, 0.04667917, 0.17465587, 0.027672665, 0.18441725, 0.06845396, 0.11288585, -0.23283863) * go_0(0.0, 1.0);
    result += mat4(-0.072962, -0.06639447, 0.049347494, -0.1386401, 0.10396071, 0.08187777, -0.04280746, 0.07390891, 0.06628344, 0.037797406, 0.021885803, -0.013147403, 0.22376558, 0.36243078, 0.12874891, -0.0023783944) * go_0(1.0, -1.0);
    result += mat4(0.074945286, 0.16045591, -0.11798349, 0.12910712, 0.054760084, -0.095626175, -0.047832094, 0.03493912, 0.11817307, 0.037452437, -0.14301221, -0.027356789, -0.052390423, 0.11373512, 0.07686775, 0.010008694) * go_0(1.0, 0.0);
    result += mat4(-0.023999173, -0.091900624, 0.02388157, 0.03173873, 0.0065633506, -0.033716757, -0.1198324, 0.12057766, 0.026465805, -0.07517131, -0.07760598, 0.060463097, 0.07345541, 0.046037503, 0.21101558, -0.26785463) * go_0(1.0, 1.0);
    result += mat4(0.15544604, -0.03902825, 0.04630384, -0.25173616, -0.0691359, 0.07476507, 0.009071253, 0.089964196, -0.26539803, -0.3958477, -0.22155671, 0.20735882, -0.105860494, -0.003996804, -0.044815883, 0.39544627) * go_1(-1.0, -1.0);
    result += mat4(0.6169709, 0.23717614, -0.37884676, -0.7484867, 0.020169826, -0.30718836, 1.0965588, -0.20711036, -0.39149985, -0.06843563, -0.06522909, 0.103805855, 0.03265825, -0.15137726, 0.12837899, -0.01294922) * go_1(-1.0, 0.0);
    result += mat4(-0.23638196, -0.4560866, -0.11948684, -0.1464144, 0.10690008, 0.007835961, 0.11864342, -0.13101323, -0.16509797, 0.075027354, 0.08122998, 0.13451207, 0.0011890623, 0.052157886, 0.08372405, -0.07085038) * go_1(-1.0, 1.0);
    result += mat4(-0.21997726, -0.16488647, -0.0291317, 0.17997476, 0.1493211, 0.027494298, 0.0034613227, -0.3207727, 0.18699001, 0.14728633, -0.042895135, -0.07612043, 0.125076, -0.14714554, -0.03480009, -0.22753975) * go_1(0.0, -1.0);
    result += mat4(-0.5342686, -0.7426105, -0.38294584, 0.42549992, 0.46053204, 0.7867879, 0.106234804, -0.041163098, 0.5198579, -0.5219404, 0.14809476, -0.41802374, 0.06810794, -0.15122683, -0.047409, 0.13178343) * go_1(0.0, 0.0);
    result += mat4(-0.50428164, 0.18220626, 0.35510704, -0.081787474, 0.03155813, 0.019284263, 0.0032388573, -0.20513348, -0.05385551, 0.17803182, -0.26206362, 0.2870375, 0.008557827, 0.08401449, -0.027598893, -0.010791235) * go_1(0.0, 1.0);
    result += mat4(0.16657415, 0.067647465, 0.093076974, -0.14438486, -0.10017002, 0.0022367141, 0.03250936, -0.052794546, -0.009178676, -0.019673595, -0.0016697067, -0.15424626, -0.112123474, -0.11079971, 0.011987111, -0.11747758) * go_1(1.0, -1.0);
    result += mat4(-0.023021797, -0.058703423, -0.037978355, -0.062433913, -0.13130441, 0.048656322, 0.056839373, 0.109036915, -0.07823158, 0.14785293, 0.058555078, -0.11679035, -0.14002073, 0.07395252, 0.098268874, -0.06710464) * go_1(1.0, 0.0);
    result += mat4(0.14906375, 0.030001195, -0.10338215, 0.0662968, -0.161953, -0.13682815, 0.09563142, 0.009514228, -0.009491218, 0.06737101, -0.1393389, 0.15231515, -0.073147796, 0.00767062, 0.028675212, 0.014213088) * go_1(1.0, 1.0);
    result += vec4(0.018736731, -0.0026039074, 0.050130025, -0.055364225);
    return result;
}
//!DESC Anime4K-v3.2-Upscale-CNN-x2-(S)-Conv-4x3x3x8
//!HOOK MAIN
//!BIND conv2d_2_tf
//!SAVE conv2d_last_tf
//!WIDTH conv2d_2_tf.w
//!HEIGHT conv2d_2_tf.h
//!COMPONENTS 4
//!WHEN OUTPUT.w MAIN.w / 1.200 > OUTPUT.h MAIN.h / 1.200 > *
#define go_0(x_off, y_off) (max((conv2d_2_tf_texOff(vec2(x_off, y_off))), 0.0))
#define go_1(x_off, y_off) (max(-(conv2d_2_tf_texOff(vec2(x_off, y_off))), 0.0))
vec4 hook() {
    vec4 result = mat4(0.019100675, -0.014241565, 0.004667036, -0.03865062, 0.106731094, 0.026099661, 0.014594411, -0.011881356, 0.0040967264, -0.004626336, 0.006469508, 0.010875305, -0.033909045, -0.085905954, 0.07861378, 0.019452631) * go_0(-1.0, -1.0);
    result += mat4(0.20777655, -0.060354974, 0.0023840065, -0.064121604, -0.17397617, 0.019293457, -0.09707183, 0.080641985, 0.01025124, -0.017382381, 0.008661793, -0.010995665, 0.21943407, -0.115574986, 0.14471593, -0.068836235) * go_0(-1.0, 0.0);
    result += mat4(0.057942886, -0.06311754, 0.2253396, -0.04159292, -0.020731755, 0.007877151, 0.041525815, 0.025278691, 0.03041967, -0.025137542, 0.024364179, -0.024543528, 0.029438615, -0.015506873, 0.081686, -0.07812221) * go_0(-1.0, 1.0);
    result += mat4(0.054237515, 0.0676094, -0.0047708177, 0.0043467237, -0.10032304, -0.020498628, 0.04240586, 0.07272254, 0.0784221, 0.017945962, -0.022310399, -0.013134622, 0.015638694, -0.10001543, 0.1043031, 0.05898838) * go_0(0.0, -1.0);
    result += mat4(-0.021652509, 0.35796642, 0.059497777, 0.23948468, 0.15454951, -0.10017235, -0.19072174, -0.44812536, -0.03974552, 0.04529369, 0.22207436, 0.026222564, -0.09705454, 0.5623026, -0.3354105, -0.017278556) * go_0(0.0, 0.0);
    result += mat4(-0.053682446, -0.03411237, -0.09399936, 0.15128824, -0.07463, -0.042020727, 0.0031783928, 0.13481957, -0.07731454, 0.044114403, -0.23085599, 0.060444202, -0.15015422, 0.0018040676, -0.18684982, 0.2812511) * go_0(0.0, 1.0);
    result += mat4(0.0029329916, 0.001596018, 0.0007512241, 0.016544111, -0.04876942, -0.05272409, 0.037884697, 0.049948208, 0.015518177, 0.11368592, -0.03815777, -0.013149978, -0.027638039, 0.107719295, -0.04115787, 0.02745414) * go_0(1.0, -1.0);
    result += mat4(0.016691081, 0.010204119, 0.04078854, 0.01613337, 0.03325829, 0.0114824055, -0.017286912, -0.07284126, -0.110984206, -0.21041764, 0.0089543555, 0.18986733, 0.01537506, -0.2059135, 0.029074017, 0.013117443) * go_0(1.0, 0.0);
    result += mat4(0.013965926, 0.029871881, 0.0034499036, -0.011343668, 0.022120327, -0.0068748263, 0.009324342, -0.039081004, 0.08032371, 0.050809264, 0.035050742, -0.2032847, 0.06305391, -0.021958945, 0.038569167, -0.22465245) * go_0(1.0, 1.0);
    result += mat4(0.046307724, -0.012419472, 0.007673863, -0.042344846, 0.011042414, 0.016994251, -0.018166406, -0.016955731, -0.13240299, 0.01768431, -0.027607648, 0.0699927, -0.02840628, 0.004414203, 0.0049618417, 0.011084679) * go_1(-1.0, -1.0);
    result += mat4(-0.119954154, -0.007455482, -0.031108133, -0.009946449, 0.0077065965, 0.01660345, 0.032943666, 0.016376585, 0.10273124, 0.1556573, -0.24643841, 0.107307844, -0.068235755, 0.0561896, -0.0104672015, 0.042693343) * go_1(-1.0, 0.0);
    result += mat4(-0.01634601, 0.04195375, -0.10401894, 0.047641944, -0.034602515, -0.0034419263, -0.010457858, 0.015194475, -0.03962551, -0.030031368, 0.16036317, 0.019283568, -0.05877721, 0.016504882, -0.15523468, 0.018161612) * go_1(-1.0, 1.0);
    result += mat4(-0.08083991, 0.0024665035, -0.049373373, 0.030371357, 0.0113322195, -0.014676956, 0.011646689, -0.01142667, 0.124930486, 0.06625774, -0.045840867, -0.009693036, -0.012649251, -0.07388084, 0.008790075, 0.0013844534) * go_1(0.0, -1.0);
    result += mat4(-0.33941835, -0.2763476, -0.118311435, -0.063535266, 0.20936015, 0.13731301, 0.13443594, 0.07464433, 0.059650812, -0.36973104, 0.16444235, -0.37082872, 0.06432777, -0.18283032, -0.044489607, -0.13895285) * go_1(0.0, 0.0);
    result += mat4(0.13533665, 0.08268915, -0.03675727, -0.14348659, 0.0186255, -0.05051692, 0.056702953, 0.0061717895, 0.047663026, -0.088188455, 0.23254345, -0.014015464, 0.08400204, -0.0073777726, 0.2202068, -0.12366078) * go_1(0.0, 1.0);
    result += mat4(0.04361004, 0.046543695, 0.0064863074, -0.03358146, -0.022602187, 0.018138997, -0.011071864, 0.010244091, -0.019814799, -0.17250171, 0.040823266, -0.040131986, 0.010125854, 0.020660749, 0.0020435036, -0.010819304) * go_1(1.0, -1.0);
    result += mat4(-0.004810193, -0.11286074, 0.051985834, 0.04788631, -0.023950428, 0.036145125, -0.038203828, 0.052401308, 0.022986965, 0.26420745, -0.06076917, -0.09252999, 0.03164547, 0.15652153, -0.037934, -0.0035418556) * go_1(1.0, 0.0);
    result += mat4(0.03358366, -0.005219482, 0.007060882, -0.06569114, -0.02941682, 0.00966056, -0.0153679885, 0.019905418, -0.107232265, -0.03405676, -0.044340115, 0.26892832, -0.04723829, -0.02589829, 0.004563232, 0.19318114) * go_1(1.0, 1.0);
    result += vec4(-0.00346731, -0.0046263863, -0.004627155, -0.0057769152);
    return result;
}
//!DESC Anime4K-v3.2-Upscale-CNN-x2-(S)-Depth-to-Space
//!HOOK MAIN
//!BIND conv2d_last_tf
//!SAVE depth_to_space2_tf
//!COMPONENTS 4
//!WIDTH conv2d_last_tf.w 2 *
//!HEIGHT conv2d_last_tf.h 2 *
//!WHEN OUTPUT.w MAIN.w / 1.200 > OUTPUT.h MAIN.h / 1.200 > *
vec4 hook() {
    vec2 f0 = fract(conv2d_last_tf_pos * conv2d_last_tf_size);
    ivec2 i0 = ivec2(f0 * vec2(2.0));
    float c0 = conv2d_last_tf_tex((vec2(0.5) - f0) * conv2d_last_tf_pt + conv2d_last_tf_pos)[i0.y * 2 + i0.x];
    float c1 = c0;
    float c2 = c1;
    float c3 = c2;
    return vec4(c0, c1, c2, c3);
}