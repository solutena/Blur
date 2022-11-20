Shader "Solutena/Sprite/Blur"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Blur ("Blur", Range(1,100)) = 1
        [HideInInspector] _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex SpriteVert
            #pragma fragment Frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile_local _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnitySprites.cginc"
            
            float _Blur;
            float4 _MainTex_TexelSize;

            fixed4 Frag(v2f IN) : SV_Target
            {
                float4 c = 0;
                float total = 0;
                for(int i=-_Blur;i<=_Blur;i++)
                {
                    float distance = abs(i/_Blur);
                    float weight = exp(-0.5 * pow(distance,2)*5);
                    total += weight;
                    c += SampleSpriteTexture(IN.texcoord + float4(0,i* _MainTex_TexelSize.y,0,0))*weight;
                }

                for(int i=-_Blur;i<=_Blur;i++)
                {
                    float distance = abs(i/_Blur);
                    float weight = exp(-0.5 * pow(distance,2)*5);
                    total += weight;
                    c += SampleSpriteTexture(IN.texcoord + float4(i* _MainTex_TexelSize.x,0,0,0))*weight;
                }

                c /= total;
                c *= IN.color;
                c.rgb *= c.a;

                return c;
            }

        ENDCG
        }
    }
}