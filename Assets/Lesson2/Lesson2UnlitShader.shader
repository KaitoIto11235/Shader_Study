Shader "Unlit/Lesson2UnlitShader"				// シェーダ名を決定。
{
    Properties									// マテリアルのInspectorで設定したいプロパティを記述。ここで設定したプロパティは頂点フラグメントシェーダ側で用意した同じ名前のプロパティに自動で渡される。
    {
		// プロパティ名（"Inspectorに表示する名前", 型）＝"デフォルト値"

		// 2D = Texture2Dの略
		// つまり通常のテクスチャ
        _MainTex ("Texture", 2D) = "white" {}

		// float
		// 小数点の値を自由に設定できる
		[Space] _FloatValue("Float", float) = 0.1

		// Range
		// 指定範囲内の値をスライダーで設定できる
		[Space] _Range("Range", Range(0.5, 1.0)) = 0.75

		// Color
		// 色をカラーピッカーで設定できる
		[Space] _Color ("Color", Color) = (1, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }			// Unity側にシェーダの設定を伝えるためにタグをつける。RenderTypeはUnity側でシェーダの種類を判定するのに使われる。半透明描画なら"RenderType" = "Transparent"
        LOD 100									// グラフィックス品質の閾値。リッチなシェーダと低品質シェーダを切り替えるときなどに使う。C#スクリプトから〇〇以下のSubShaderを有効にすると指定。

        Pass									// Passブロックの中に書くのが、頂点フラグメントシェーダ。
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

			// Propertiesブロックの_MainTexプロパティの型はTexture2Dであったが、sampler2Dと同じと思ってい良い。
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}