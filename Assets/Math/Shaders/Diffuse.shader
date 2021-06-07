Shader "Custom/Diffuse" 
{
    Properties 
    {
        _Color ("Color", Color) = (1,1,1,1)
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
            
            #ifdef VERTEX
            out vec4 color;

            void main() 
            {
                vec3 surfaceNormal = normalize(vec3(unity_ObjectToWorld * vec4(gl_Normal, 0.0)));
                vec3 lightDirectionNormal = normalize(vec3(_WorldSpaceLightPos0));
                //vec3 diffuseReflection = vec3(_LightColor0) * vec3(_Color) * max(0.0, dot(surfaceNormal, lightDirectionNormal));

                float halfLambert = max(0.0, dot(surfaceNormal, lightDirectionNormal)) * 0.5 + 0.5;
                vec3 diffuseReflection = vec3(_LightColor0) * vec3(_Color) * halfLambert * halfLambert;

                color = vec4(diffuseReflection, 1.0);

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
