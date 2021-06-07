Shader "Custom/Test" 
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
            GLSLPROGRAM
            #include "UnityCG.glslinc"

            #ifdef VERTEX
            void main() {
                // モデルビュープロジェクション変換行列
                // バーテックスシェーダーに入力されてくる頂点情報
                // gl_Position プリミティブアセンブリーに渡す出力情報
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            }
            #endif

            #ifdef FRAGMENT
            void main() {
                gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
            }
            #endif
            ENDGLSL
        }
    }
    FallBack "Diffuse"
}
