Shader "Custom/CookTorrance" 
{
    Properties 
    {
        _Color ("Diffuse Color", Color) = (1, 1, 1, 1)
        // マイクロファセットの粗さ
        _Roughness ("Roughness", Float) = 0.5
        // フレネル効果のパラメータ、表面との角度が0度の場合のフレネル反射率を示す
        _FresnelReflectance ("Fresnel Reflectance", Float) = 0.5
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

            uniform float _Roughness;

            uniform float _FresnelReflectance;
            
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
                float NdotL = saturate(dot(surfaceNormal, lightDirectionNormal));

                float halfLambert = max(0.0, dot(surfaceNormal, lightDirectionNormal)) * 0.5 + 0.5;

                vec3 viewDirectionNormal = normalize((vec4(_WorldSpaceCameraPos, 1.0) - glVertexWorld).xyz);
			   	float NdotV = saturate(dot(surfaceNormal, viewDirectionNormal));

                vec3 halfVector = normalize(lightDirectionNormal + viewDirectionNormal);
			    float NdotH = saturate(dot(surfaceNormal, halfVector));
			    float VdotH = saturate(dot(viewDirectionNormal, halfVector));

                // 鏡面反射
                float roughness = saturate(_Roughness);
                float alpha = roughness * roughness;
                float alpha2 = alpha * alpha;
                float t = ((NdotH * NdotH) * (alpha2 - 1.0) + 1.0);
                float PI = 3.1415926535897;
                float D = alpha2 / (PI * t * t);

                float F0 = saturate(_FresnelReflectance);
                float F = pow(1.0 - VdotH, 5.0);
                F *= (1.0 - F0);
                F += F0;

                float NH2 = 2.0 * NdotH;
                float g1 = (NH2 * NdotV) / VdotH;
                float g2 = (NH2 * NdotL) / VdotH;
                float G = min(1.0, min(g1, g2));

                float specularReflection = (D * F * G) / (4.0 * NdotV * NdotL + 0.000001);
				vec3 diffuseReflection = _LightColor0.xyz * _Color.xyz * NdotL;

                vec4 color = vec4(ambientLight + diffuseReflection + specularReflection, 1.0);
                gl_FragColor = color;
            }

            #endif
            ENDGLSL
        }
    }
    FallBack "Diffuse"
}
