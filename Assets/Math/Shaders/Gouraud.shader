Shader "Custom/Gouraud" 
{
    Properties 
    {
        _Color ("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularExponent("Specular Exponent", Float) = 3
    }
    SubShader 
    {
        // SharderLabでシェーダーを書く場合には
        // バーテックスシェーダーとフラグメントシェーダーは一つのファイルに両方一組で入れる
        Pass 
        {
            Tags { "LightMode" = "ForwardBase" }

            GLSLPROGRAM
            #include "UnityCG.glslinc"

            uniform vec4 _LightColor0;

            uniform vec4 _Color;

            uniform vec4 _SpecularColor;

            uniform float _SpecularExponent;
            
            #ifdef VERTEX
            out vec4 color;
            
            void main() 
            {
                // 環境光を得る
                vec3 ambientLight = gl_LightModel.ambient.xyz * vec3(_Color);

                vec3 surfaceNormal = normalize(vec3(unity_ObjectToWorld * vec4(gl_Normal, 0.0)));
                vec3 lightDirectionNormal = normalize(vec3(_WorldSpaceLightPos0));
                //vec3 diffuseReflection = vec3(_LightColor0) * vec3(_Color) * max(0.0, dot(surfaceNormal, lightDirectionNormal));

                float halfLambert = max(0.0, dot(surfaceNormal, lightDirectionNormal)) * 0.5 + 0.5;
                // 拡散反射
                vec3 diffuseReflection = vec3(_LightColor0) * vec3(_Color) * halfLambert * halfLambert;

                // 鏡面反射
                vec3 viewDirectionNormal = normalize((vec4(_WorldSpaceCameraPos, 1.0) - unity_ObjectToWorld * gl_Vertex).xyz);
                vec3 specularReflection = _LightColor0.xyz * _SpecularColor.xyz * pow(max(0.0, dot(reflect(-lightDirectionNormal, surfaceNormal), viewDirectionNormal)), _SpecularExponent);

                color = vec4(ambientLight + diffuseReflection + specularReflection, 1.0);

                // モデルビュープロジェクション変換行列
                // バーテックスシェーダーに入力されてくる頂点情報
                // gl_Position プリミティブアセンブリーに渡す出力情報
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            }
            #endif

            #ifdef FRAGMENT

            in vec4 color;

            void main() 
            {
                gl_FragColor = color;
            }

            #endif
            ENDGLSL
        }
    }
    FallBack "Diffuse"
}
