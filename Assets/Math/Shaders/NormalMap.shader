Shader "Custom/NormalMap" 
{
    Properties 
    {
        _Color ("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularExponent("Specular Exponent", Float) = 3
        _Texture ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
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
            uniform sampler2D _Texture;
            uniform sampler2D _NormalMap;
            uniform vec4 _NormalMap_ST;
            
            #ifdef VERTEX
            out vec4 glVertexWorld;
            out vec4 textureCoord;
            out vec4 normalMapCoord;
            out mat3 tbn;
            
            attribute vec4 Tangent;

            void main() 
            {
                glVertexWorld = unity_ObjectToWorld * gl_Vertex;

                // モデルビュープロジェクション変換行列
                // バーテックスシェーダーに入力されてくる頂点情報
                // gl_Position プリミティブアセンブリーに渡す出力情報
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                textureCoord = gl_MultiTexCoord0;
                normalMapCoord = gl_MultiTexCoord1;

                // 法線ベクトル、接線ベクトルから従接線ベクトルを外積で求め、接空間からの変換行列tbnを求める
                vec3 n = normalize((unity_ObjectToWorld * vec4(gl_Normal, 0.0)).xyz);
                vec3 t = normalize((unity_ObjectToWorld * vec4(Tangent.xyz, 0.0)).xyz);
                vec3 b = normalize(cross(n, t) * Tangent.w);
                tbn = mat3(t, b, n);
            }

            #endif

            #ifdef FRAGMENT

            in vec4 glVertexWorld;
            in vec4 textureCoord;
            in vec4 normalMapCoord;
            in mat3 tbn;

            vec3 unpackNormalDXT5nm(vec4 packednormal)
            {
                vec3 normal;
                normal.xy = packednormal.wy * 2.0 - 1.0;
                normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
                return normal;
            }

            vec3 unpackNormal(vec4 packednormal)
            {
                #if defined(UNITY_ND_DXT5nm)
                    return packednormal.xyz * 2.0 - 1.0;
                #else
                    return unpackNormalDXT5nm(packednormal);
                #endif
            }

            void main() 
            {
                // 環境光を得る
                vec3 ambientLight = gl_LightModel.ambient.xyz * vec3(_Color);

                vec3 lightDirectionNormal = normalize(vec3(_WorldSpaceLightPos0));

                // NormalMap計算
                vec4 packedNormal = texture2D(_NormalMap, _NormalMap_ST.xy * normalMapCoord.xy + _NormalMap_ST.zw);
                vec3 tangentSpaceVector = unpackNormal(packedNormal);
                vec3 surfaceNormal = normalize(tbn * tangentSpaceVector);

                float halfLambert = max(0.0, dot(surfaceNormal, lightDirectionNormal)) * 0.5 + 0.5;
                // 拡散反射
                vec3 diffuseReflection = vec3(_LightColor0) * vec3(_Color) * halfLambert * halfLambert;

                // 鏡面反射
                vec3 viewDirectionNormal = normalize((vec4(_WorldSpaceCameraPos, 1.0) - glVertexWorld).xyz);
                vec3 specularReflection = _LightColor0.xyz * _SpecularColor.xyz * pow(max(0.0, dot(reflect(-lightDirectionNormal, surfaceNormal), viewDirectionNormal)), _SpecularExponent);

                vec4 color = vec4(ambientLight + diffuseReflection + specularReflection, 1.0);
                gl_FragColor = texture2D(_Texture, vec2(textureCoord)) * color;
            }
            #endif
            ENDGLSL
        }
    }
    FallBack "Diffuse"
}
