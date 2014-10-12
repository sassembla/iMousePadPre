//
//  KeysData.h
//  MousePadPre
//
//  Created by illusionismine on 2014/10/04.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

struct KeysData {
    bool left;
    bool right;
    bool center;
    Byte keySlots[8];
};

typedef struct KeysData KeysData;