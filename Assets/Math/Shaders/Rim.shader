Shader "Custom/Rim" 
{
    Properties 
    {
        _Color ("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularExponent("Specular Exponent", Float) = 3
        _RimColor ("Rim Color", Color) = (0, 1, 0, 1)
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

            uniform vec4 _RimColor;
            
            #ifdef VERTEX
            out vec4 glVertexWorld;
            out vec3 surfaceNormal;
            
            void main() 
            {
                
                surfaceNormal = normalize(vec3(unity_ObjectToWorld * vec4(gl_Normal, 0.0)));
                glVertexWorld = unity_ObjectToWorld * gl_Vertex;

                // モデルビュープロジェクション変換行列
                // バーテックスシェーダーに入力されてくる頂点情報
                // gl_Position プリミティブアセンブリーに渡す出力情報
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            }
            #endif

            #ifdef FRAGMENT

            in vec4 glVertexWorld;
            in vec3 surfaceNormal;

            void main() 
            {
                // 環境光を得る
                vec3 ambientLight = gl_LightModel.ambient.xyz * vec3(_Color);

                vec3 lightDirectionNormal = normalize(vec3(_WorldSpaceLightPos0));

                float halfLambert = max(0.0, dot(surfaceNormal, lightDirectionNormal)) * 0.5 + 0.5;
                // 拡散反射
                vec3 diffuseReflection = vec3(_LightColor0) * vec3(_Color) * halfLambert * halfLambert;

                // 鏡面反射
                vec3 viewDirectionNormal = normalize((vec4(_WorldSpaceCameraPos, 1.0) - glVertexWorld).xyz);
                vec3 specularReflection = _LightColor0.xyz * _SpecularColor.xyz * pow(max(0.0, dot(reflect(-lightDirectionNormal, surfaceNormal), viewDirectionNormal)), _SpecularExponent);

                float rim = 1.0 - saturate(dot(viewDirectionNormal, surfaceNormal));
                vec4 color = vec4(ambientLight + diffuseReflection + specularReflection + vec3(smoothstep(0.5, 1.0, rim)) * _RimColor.xyz, 1.0);

                gl_FragColor = color;
            }

            #endif
            ENDGLSL
        }
    }
    FallBack "Diffuse"
}
