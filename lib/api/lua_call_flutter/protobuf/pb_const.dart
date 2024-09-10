


const PB_TVARINT = 0;
const PB_T64BIT = 1;
const PB_TBYTES = 2;
const PB_TGSTART = 3;
const PB_TGEND = 4;
const PB_T32BIT = 5;
const PB_TWIRECOUNT = 6;


const PB_TNONE = 0;
const PB_Tdouble = 1;
const PB_Tfloat = 2;
const PB_Tint64 = 3;
const PB_Tuint64 = 4;
const PB_Tint32 = 5;
const PB_Tfixed64 = 6;
const PB_Tfixed32 = 7;
const PB_Tbool = 8;
const PB_Tstring = 9;
const PB_Tgroup = 10;
const PB_Tmessage = 11;
const PB_Tbytes = 12;
const PB_Tuint32 = 13;
const PB_Tenum = 14;
const PB_Tsfixed32 = 15;
const PB_Tsfixed64 = 16;
const PB_Tsint32 = 17;
const PB_Tsint64 = 18;
const PB_TYPECOUNT = 19;


// const PB_PAIR_1_PB_TBYTES = pb_pair(1, PbWireType.PB_TBYTES.index);
const PB_PAIR_1_PB_TBYTES = (1 << 3) | PB_TBYTES & 7;
const PB_PAIR_2_PB_TBYTES = (2 << 3) | PB_TBYTES & 7;
const PB_PAIR_3_PB_TBYTES = (3 << 3) | PB_TBYTES & 7;
const PB_PAIR_4_PB_TBYTES = (4 << 3) | PB_TBYTES & 7;
const PB_PAIR_5_PB_TBYTES = (5 << 3) | PB_TBYTES & 7;
const PB_PAIR_6_PB_TBYTES = (6 << 3) | PB_TBYTES & 7;
const PB_PAIR_7_PB_TBYTES = (7 << 3) | PB_TBYTES & 7;
const PB_PAIR_8_PB_TBYTES = (8 << 3) | PB_TBYTES & 7;
const PB_PAIR_12_PB_TBYTES = (12 << 3) | PB_TBYTES & 7;

const PB_PAIR_2_PB_TVARINT = (2 << 3) | PB_TVARINT & 7;
const PB_PAIR_3_PB_TVARINT = (3 << 3) | PB_TVARINT & 7;
const PB_PAIR_4_PB_TVARINT = (4 << 3) | PB_TVARINT & 7;
const PB_PAIR_5_PB_TVARINT = (5 << 3) | PB_TVARINT & 7;
const PB_PAIR_7_PB_TVARINT = (7 << 3) | PB_TVARINT & 7;
const PB_PAIR_9_PB_TVARINT = (9 << 3) | PB_TVARINT & 7;

const PB_OK = 0;
const PB_ERROR = 1;
const PB_ENOMEM = 2;

const PB_HASHLIMIT = 5;

const PB_Lrepeated = 3;
