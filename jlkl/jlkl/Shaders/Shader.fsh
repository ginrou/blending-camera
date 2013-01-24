//
//  Shader.fsh
//  jlkl
//
//  Created by 武田 祐一 on 2013/01/24.
//  Copyright (c) 2013年 武田 祐一. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
